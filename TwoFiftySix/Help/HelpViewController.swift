import UIKit
import WebKit

/// View controller of the help scene.
final class HelpViewController: UIViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<HelpAction, HelpState, Void>)?

    /// The web view that constitutes the bulk of our interface.
    var webView: WKWebView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let font = UIFont(name: "Georgia-Bold", size: 26) {
            navigationItem.attributedTitle = .init("Help", attributes: .init().font(font))
        } else {
            navigationItem.title = "Help"
        }
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doDone))
        doneButton.style = .plain
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
        webView.navigationDelegate = self
        Task {
            await processor?.receive(.initialInterface)
        }
    }

    /// Flag so we don't set the web view content twice.
    var presentedInitialInterface = false

    func present(_ state: HelpState) async {
        if !presentedInitialInterface {
            if let url = state.contentURL {
                presentedInitialInterface = true
                webView?.loadFileURL(url, allowingReadAccessTo: url.appendingPathComponent("helppix", conformingTo: .directory))
            }
        }
    }

    /// Action of the done button.
    @objc func doDone(_ sender: Any) {
        Task {
            await processor?.receive(.done)
        }
    }
}

/// Extension that routes external links to the default browser. No tests for this.
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
