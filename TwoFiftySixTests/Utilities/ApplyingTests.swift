@testable import TwoFiftySix
import UIKit
import Testing

struct ApplyingTests {
    @Test("applying works as expected")
    func applying() {
        let view = UIView().applying {
            $0.backgroundColor = .green
            $0.layer.borderWidth = 3
        }
        #expect(view.backgroundColor == .green)
        #expect(view.layer.borderWidth == 3)
    }
}
