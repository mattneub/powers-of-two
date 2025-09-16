import UIKit

protocol RootCoordinatorType: AnyObject {

    /// Set up the initial module for the entire app, putting the interface into the window.
    /// - Parameter window: The window.
    func createInitialInterface(window: UIWindow)

    /// Show the stats screen.
    func showStats()

    /// Show the help screen.
    func showHelp()

    /// Dismiss presented view controller.
    func dismiss()

    /// Deal with the fact that the app is entering the background.
    func enteringBackground()
}

final class RootCoordinator: RootCoordinatorType {
    var gameProcessor: (any Processor<GameAction, GameState, GameEffect>)?
    var statsProcessor: (any Processor<StatsAction, StatsState, Void>)?
    var helpProcessor: (any Processor<HelpAction, HelpState, Void>)?

    /// Reference to the root view controller of the app.
    weak var rootViewController: UIViewController?

    func createInitialInterface(window: UIWindow) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "game"
        ) as? GameViewController else {
            return
        }

        let processor = GameProcessor()
        viewController.processor = processor
        processor.presenter = viewController
        self.gameProcessor = processor
        window.rootViewController = viewController
        self.rootViewController = viewController
        processor.coordinator = self
    }

    func showHelp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "help"
        ) as? HelpViewController else {
            return
        }
        let processor = HelpProcessor()
        viewController.processor = processor
        processor.presenter = viewController
        self.helpProcessor = processor
        processor.coordinator = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    func showStats() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "stats"
        ) as? StatsViewController else {
            return
        }
        let processor = StatsProcessor()
        viewController.processor = processor
        processor.presenter = viewController
        self.statsProcessor = processor
        processor.coordinator = self
        let navigationController = UINavigationController(rootViewController: viewController)
        self.rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    func dismiss() {
        self.rootViewController?.dismiss(animated: unlessTesting(true))
    }

    func enteringBackground() {
        Task {
            await gameProcessor?.receive(.enteringBackground)
        }
    }
}
