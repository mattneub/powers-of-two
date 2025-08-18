import UIKit

@MainActor
protocol RootCoordinatorType: AnyObject {

    /// Set up the initial module for the entire app, putting the interface into the window.
    /// - Parameter window: The window.
    func createInitialInterface(window: UIWindow)

    /// Deal with the fact that the app is entering the background.
    func enteringBackground()
}

@MainActor
final class RootCoordinator: RootCoordinatorType {
    var gameProcessor: (any Processor<GameAction, GameState, GameEffect>)?

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
        window.backgroundColor = .white
    }

    func enteringBackground() {
        Task {
            await gameProcessor?.receive(.enteringBackground)
        }
    }
}
