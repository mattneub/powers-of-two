import UIKit

/// Actions sent to the GameProcessor, usually from its presenter.
enum GameAction: Equatable {
    case enteringBackground
    case initialInterface
    case newGame
    case stats(source: UIButton)
    case help(source: UIBarButtonItem)
    case userMoved(direction: UISwipeGestureRecognizer.Direction)
}
