@testable import TwoFiftySix
import UIKit
import WebKit
import Testing
import WaitWhile

struct HelpViewControllerTests {
    let subject = HelpViewController()
    let processor = MockProcessor<HelpAction, HelpState, Void>()

    init() {
        subject.processor = processor
    }

    @Test("viewDidLoad: configures the view, calls initialInterface")
    func viewDidLoad() async throws {
        subject.loadViewIfNeeded()
        #expect(subject.title == "Help")
        let doneButton = try #require(subject.navigationItem.rightBarButtonItem)
        #expect(doneButton.target === subject)
        #expect(doneButton.action == #selector(subject.doDone))
        let webView = try #require(subject.webView)
        #expect(webView.superview === subject.view)
        #expect(webView.navigationDelegate === subject)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .initialInterface)
    }

    @Test("present: with url sets presentedInitialInterface to true, calls web view loadFile")
    func present() async {
        let webView = MockWebView()
        subject.webView = webView
        #expect(subject.presentedInitialInterface == false)
        let url = URL(string: "http://www.example.com")!
        await subject.present(HelpState(contentURL: url))
        #expect(subject.presentedInitialInterface == true)
        #expect(webView.methodsCalled == ["loadFileURL(_:allowingReadAccessTo:)"])
        #expect(webView.loadURL == url)
        #expect(webView.readAccessURL == url)
    }

    @Test("doDone: calls done")
    func doDone() async throws {
        subject.doDone(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .done)
    }

    // No test for navigation delegate, because I can't create a WKNavigationAction.
    // I think I see how to work around this, but it isn't worth worrying about.
}

final class MockWebView: WKWebView {
    var methodsCalled = [String]()
    var loadURL: URL?
    var readAccessURL: URL?

    override func loadFileURL(_ loadURL: URL, allowingReadAccessTo readAccessURL: URL) -> WKNavigation? {
        methodsCalled.append(#function)
        self.loadURL = loadURL
        self.readAccessURL = readAccessURL
        return nil
    }
}

