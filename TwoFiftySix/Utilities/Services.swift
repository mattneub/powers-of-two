import UIKit

/// Class of global instance of services.
final class Services {
    var persistence: PersistenceType = Persistence()
    var userDefaults: UserDefaultsType = UserDefaults.standard
}
