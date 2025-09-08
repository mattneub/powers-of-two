import Foundation

/// Protocol describing Bundle, so we can make it a service and mock it for testing.
protocol BundleType {
    func url(
        forResource name: String?,
        withExtension ext: String?
    ) -> URL?
}

extension Bundle: BundleType {}
