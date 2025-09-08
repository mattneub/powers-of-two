@testable import TwoFiftySix
import Foundation

final class MockBundle: BundleType {
    var methodsCalled = [String]()
    var name: String?
    var ext: String?
    var urlToReturn: URL?

    func url(forResource name: String?, withExtension ext: String?) -> URL? {
        methodsCalled.append(#function)
        self.name = name
        self.ext = ext
        return self.urlToReturn
    }
}
