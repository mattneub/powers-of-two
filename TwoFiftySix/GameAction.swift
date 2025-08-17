import UIKit

enum GameAction {
    case initialInterface
    case newGame
    case userMoved(direction: UISwipeGestureRecognizer.Direction)
}
