@testable import TwoFiftySix
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var window: UIWindow?
    var methodsCalled = [String]()
    var button: UIButton?
    var barButtonItem: UIBarButtonItem?

    func createInitialInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showStats(source: UIButton) {
        methodsCalled.append(#function)
        self.button = source
    }

    func showHelp(source: UIBarButtonItem) {
        methodsCalled.append(#function)
        self.barButtonItem = source
    }

    func dismiss() {
        methodsCalled.append(#function)
    }

    func enteringBackground() {
        methodsCalled.append(#function)
    }
}
