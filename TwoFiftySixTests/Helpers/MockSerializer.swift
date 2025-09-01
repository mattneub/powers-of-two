@testable import TwoFiftySix
import Foundation

actor MockSerializer<T: Sendable>: SerializerType {
    var methodsCalled = [String]()
    var value: T?
    var handler: (@Sendable (T) async throws -> Void)?

    func startStream(_ handler: @Sendable @escaping (T) async throws -> Void) {
        methodsCalled.append(#function)
        self.handler = handler
    }

    func vend(_ value: T) {
        methodsCalled.append(#function)
        self.value = value
    }

    func cancel() {
        methodsCalled.append(#function)
    }
}
