@testable import TwoFiftySix
import UIKit
import Testing
import WaitWhile

struct RootCoordinatorTests {
    @Test("createInitialInterface: creates and configures game module, sets up initial interface")
    func createInitialInterface() throws {
        let window = makeWindow()
        let subject = RootCoordinator()
        subject.createInitialInterface(window: window)
        let processor = try #require(subject.gameProcessor as? GameProcessor)
        let viewController = try #require(subject.rootViewController as? GameViewController)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(window.rootViewController === viewController)
        #expect(processor.coordinator === subject)
    }

    @Test("showStats: creates and configures stats module, presents view controller")
    func showStats() async throws {
        let dummyViewController = UIViewController()
        makeWindow(viewController: dummyViewController)
        let subject = RootCoordinator()
        subject.rootViewController = dummyViewController
        subject.showStats()
        let navigationController = try #require(dummyViewController.presentedViewController as? UINavigationController)
        let viewController = try #require(navigationController.viewControllers[0] as? StatsViewController)
        let processor = try #require(subject.statsProcessor as? StatsProcessor)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(processor.coordinator === subject)
    }

    @Test("showHelp: creates and configures help module, presents nav controller")
    func showHelp() async throws {
        let dummyViewController = UIViewController()
        makeWindow(viewController: dummyViewController)
        let subject = RootCoordinator()
        subject.rootViewController = dummyViewController
        subject.showHelp()
        let navController = try #require(dummyViewController.presentedViewController as? UINavigationController)
        let viewController = try #require(navController.viewControllers.first as? HelpViewController)
        let processor = try #require(subject.helpProcessor as? HelpProcessor)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(processor.coordinator === subject)
    }

    @Test("dismiss: dismisses presented view controller")
    func dismiss() async throws {
        let rootViewController = UIViewController()
        makeWindow(viewController: rootViewController)
        let subject = RootCoordinator()
        subject.rootViewController = rootViewController
        let presentedViewController = UIViewController()
        rootViewController.present(presentedViewController, animated: false)
        #expect(rootViewController.presentedViewController === presentedViewController)
        subject.dismiss() // this is the test
        await #while(rootViewController.presentedViewController != nil)
        #expect(rootViewController.presentedViewController == nil)
    }

    @Test("enteringBackground: sends enteringBackground to game processor")
    func enteringBackground() async throws {
        let processor = MockProcessor<GameAction, GameState, GameEffect>()
        let subject = RootCoordinator()
        subject.gameProcessor = processor
        subject.enteringBackground()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .enteringBackground)
    }
}
