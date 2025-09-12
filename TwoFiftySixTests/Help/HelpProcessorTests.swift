@testable import TwoFiftySix
import Foundation
import Testing

struct HelpProcessorTests {
    let subject = HelpProcessor()
    let presenter = MockReceiverPresenter<Void, HelpState>()
    let coordinator = MockRootCoordinator()
    let bundle = MockBundle()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.bundle = bundle
    }

    @Test("receive done: calls coordinator dismiss")
    func done() async {
        await subject.receive(.done)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("receive initialInterface: call bundle for url, presents it")
    func initialInterface() async {
        bundle.urlToReturn = URL(string: "http://www.example.com")!
        await subject.receive(.initialInterface)
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:)"])
        #expect(bundle.name == "help")
        #expect(bundle.ext == "html")
        #expect(presenter.statesPresented.first?.contentURL == URL(string: "http://www.example.com")!)
    }
}
