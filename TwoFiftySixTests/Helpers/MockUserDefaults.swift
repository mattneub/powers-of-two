@testable import TwoFiftySix

final class MockUserDefaults: UserDefaultsType {
    var methodsCalled = [String]()
    var arrayToReturn: [Any]?
    var objectToReturn: Any?
    var objectSet: Any?
    var key: String?

    func set(_ object: Any?, forKey key: String) {
        methodsCalled.append(#function)
        self.objectSet = object
        self.key = key
    }
    
    func object(forKey key: String) -> Any? {
        methodsCalled.append(#function)
        self.key = key
        return self.objectToReturn
    }

    func array(forKey key: String) -> [Any]? {
        methodsCalled.append(#function)
        self.key = key
        return self.arrayToReturn
    }

}
