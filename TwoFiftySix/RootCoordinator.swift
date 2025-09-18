import UIKit

protocol RootCoordinatorType: AnyObject {

    /// Set up the initial module for the entire app, putting the interface into the window.
    /// - Parameter window: The window.
    func createInitialInterface(window: UIWindow)

    /// Show the stats screen.
    func showStats(source: UIButton)

    /// Show the help screen.
    func showHelp(source: UIBarButtonItem)

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
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        navigationController.isToolbarHidden = false
        window.rootViewController = navigationController
        self.rootViewController = navigationController
        processor.coordinator = self
    }

    func showHelp(source: UIBarButtonItem) {
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
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceItem = source
        self.rootViewController?.present(navigationController, animated: unlessTesting(true))
    }

    func showStats(source: UIButton) {
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
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.sourceItem = source
        navigationController.popoverPresentationController?.delegate = viewController
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

