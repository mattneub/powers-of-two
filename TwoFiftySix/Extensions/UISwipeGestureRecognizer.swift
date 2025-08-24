import UIKit

extension UISwipeGestureRecognizer.Direction {
    /// Convert a swipe direction to a move direction.
    var moveDirection: MoveDirection {
        switch self {
        case .up: .up
        case .down: .down
        case .right: .right
        case .left: .left
        default: .up // won't happen
        }
    }
}

/// Subclass of swipe gesture recognizer that gives us access to the target and action, for testing.
final class MySwipeGestureRecognizer: UISwipeGestureRecognizer {
    weak var target: AnyObject?
    var action: Selector?
    override init(target: Any?, action: Selector?) {
        self.target = target as? AnyObject
        self.action = action
        super.init(target: target, action: action)
    }
}
