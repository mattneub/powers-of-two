import UIKit

extension UISwipeGestureRecognizer.Direction {
    /// Convert a swipe direction to a move direction.
    var gridDirection: MoveDirection {
        switch self {
        case .up: .up
        case .down: .down
        case .right: .right
        case .left: .left
        default: .up // won't happen
        }
    }
}
