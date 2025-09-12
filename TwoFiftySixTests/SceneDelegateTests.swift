@testable import TwoFiftySix
import UIKit
import Testing

struct SceneDelegateTests {
    @Test("bootstrap: tells the root coordinator to create the interface")
    func bootstrap() async throws {
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        let subject = SceneDelegate()
        let mockRootCoordinator = MockRootCoordinator()
        subject.rootCoordinator = mockRootCoordinator
        subject.bootstrap(scene: scene)
        let window = try #require(subject.window)
        #expect(window.isKeyWindow)
        #expect(mockRootCoordinator.methodsCalled == ["createInitialInterface(window:)"])
        #expect(mockRootCoordinator.window === window)
    }

    @Test("sceneDidEnterBackground calls root coordinator enteringBackground")
    func didBecomeActive() throws {
        let subject = SceneDelegate()
        let mockRootCoordinator = MockRootCoordinator()
        subject.rootCoordinator = mockRootCoordinator
        let scene = try #require(UIApplication.shared.connectedScenes.first as? UIWindowScene)
        subject.sceneDidEnterBackground(scene)
        #expect(mockRootCoordinator.methodsCalled == ["enteringBackground()"])
    }
}
