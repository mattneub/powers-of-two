import UIKit
import WebKit

/// View controller of the help scene.
final class HelpViewController: UIViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<HelpAction, HelpState, Void>)?

    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Help"
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doDone))
        navigationItem.rightBarButtonItem = doneButton
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webView = webView
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        guard let contentURL = Bundle.main.url(forResource: "help", withExtension: "html") else {
            return
        }
        webView.loadFileURL(contentURL, allowingReadAccessTo: contentURL)
        webView.navigationDelegate = self
    }

    func present(_ state: HelpState) async {
    }

    @objc func doDone(_ sender: Any) {
        Task {
            await processor?.receive(.done)
        }
    }
}

extension HelpViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction
    ) async -> WKNavigationActionPolicy {
        if let url = navigationAction.request.url {
            if url.isFileURL {
                return .allow
            }
            await UIApplication.shared.open(url)
        }
        return .cancel
    }
}
