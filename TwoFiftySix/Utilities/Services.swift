import UIKit

/// Class of global instance of services.
final class Services {
    var bundle: BundleType = Bundle.main
    var persistence: PersistenceType = Persistence()
    var userDefaults: UserDefaultsType = UserDefaults.standard
}
