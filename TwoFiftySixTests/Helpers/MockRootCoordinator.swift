@testable import TwoFiftySix
import UIKit

final class MockRootCoordinator: RootCoordinatorType {
    var window: UIWindow?
    var methodsCalled = [String]()

    func createInitialInterface(window: UIWindow) {
        methodsCalled.append(#function)
        self.window = window
    }
    
    func enteringBackground() {
        methodsCalled.append(#function)
    }
}
