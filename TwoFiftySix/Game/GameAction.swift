import UIKit

/// Actions sent to the GameProcessor, usually from its presenter.
enum GameAction: Equatable {
    case enteringBackground
    case initialInterface
    case newGame
    case userMoved(direction: UISwipeGestureRecognizer.Direction)
}
