import UIKit

enum GameAction {
    case enteringBackground
    case initialInterface
    case newGame
    case userMoved(direction: UISwipeGestureRecognizer.Direction)
}
