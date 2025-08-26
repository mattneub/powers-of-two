@testable import TwoFiftySix
import UIKit
import Testing
import WaitWhile

@MainActor
struct RootCoordinatorTests {
    @Test("createInitialInterface: creates and configures game module, sets up initial interface")
    func createInitialInterface() throws {
        let window = UIWindow()
        let subject = RootCoordinator()
        subject.createInitialInterface(window: window)
        let processor = try #require(subject.gameProcessor as? GameProcessor)
        let viewController = try #require(subject.rootViewController as? GameViewController)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(window.rootViewController === viewController)
        #expect(processor.coordinator === subject)
        #expect(window.backgroundColor == .white)
    }

    @Test("showStats: creates and configures stats module, presents view controller")
    func showStats() async throws {
        let dummyViewController = UIViewController()
        makeWindow(viewController: dummyViewController)
        let subject = RootCoordinator()
        subject.rootViewController = dummyViewController
        subject.showStats()
        await #while(dummyViewController.presentedViewController == nil)
        let viewController = try #require(dummyViewController.presentedViewController as? StatsViewController)
        let processor = try #require(subject.statsProcessor as? StatsProcessor)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(processor.coordinator === subject)
    }

    @Test("enteringBackground: sends enteringBackground to game processor")
    func enteringBackground() async {
        let processor = MockProcessor<GameAction, GameState, GameEffect>()
        let subject = RootCoordinator()
        subject.gameProcessor = processor
        subject.enteringBackground()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .enteringBackground)
    }
}
