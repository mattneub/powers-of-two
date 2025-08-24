import UIKit

/// Type that embodies our calls to user defaults, so we can mock them.
protocol UserDefaultsType {
    func set(_: Any?, forKey: String)
    func object(forKey: String) -> Any?
    func array(forKey: String) -> [Any]?
}

extension UserDefaults: UserDefaultsType {}
