@testable import TwoFiftySix
import Foundation
import Testing

@MainActor
struct StatsProcessorTests {
    let subject = StatsProcessor()
    let presenter = MockReceiverPresenter<Void, StatsState>()
    let coordinator = MockRootCoordinator()
    let persistence = MockPersistence()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        services.persistence = persistence
    }

    @Test("receive initialInterface: fetches high scores, sets state histogram and presents it")
    func initialInterface() async {
        persistence.scoresToReturn = [2, 1, 2, 1]
        await subject.receive(.initialInterface)
        #expect(persistence.methodsCalled == ["loadHighScores()"])
        #expect(subject.state.histogram == [.init(score: 1, count: 2), .init(score: 2, count: 2)])
        #expect(presenter.statesPresented.first?.histogram == [.init(score: 1, count: 2), .init(score: 2, count: 2)])
    }

    @Test("receive done: calls coordinator dismiss")
    func receiveDone() async {
        await subject.receive(.done)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }
}
