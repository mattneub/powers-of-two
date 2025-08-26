import UIKit

/// Main view controller of the app.
final class GameViewController: UIViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<GameAction, GameState, GameEffect>)?

    @IBOutlet var board: UIView!

    @IBOutlet var highest: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        highest.text = " "
        // prepare to respond to swipe gestures
        do {
            let g = MySwipeGestureRecognizer(target: self, action: #selector(swipe))
            g.direction = .up
            view.addGestureRecognizer(g)
        }
        do {
            let g = MySwipeGestureRecognizer(target: self, action: #selector(swipe))
            g.direction = .down
            view.addGestureRecognizer(g)
        }
        do {
            let g = MySwipeGestureRecognizer(target: self, action: #selector(swipe))
            g.direction = .left
            view.addGestureRecognizer(g)
        }
        do {
            let g = MySwipeGestureRecognizer(target: self, action: #selector(swipe))
            g.direction = .right
            view.addGestureRecognizer(g)
        }
    }

    var firstTime = true
    override func viewDidLayoutSubviews() {
        if firstTime {
            firstTime = false
            Task {
                await processor?.receive(.initialInterface)
            }
        }
    }

    func present(_ state: GameState) async {
        if state.highestValue > 4 {
            highest.text = String(state.highestValue)
        } else {
            highest.text = " "
        }
    }

    func receive(_ effect: GameEffect) async {
        if let board = board as? any Receiver<GameEffect> {
            await board.receive(effect)
        }
    }

    /// The user performed a swipe gesture, which constitutes a move.
    @objc func swipe(_ g: UISwipeGestureRecognizer) {
        Task {
            await processor?.receive(.userMoved(direction: g.direction))
        }
    }

    /// The user tapped the New Game button.
    @IBAction func doNew(_ sender: Any) {
        Task {
            await processor?.receive(.newGame)
        }
    }

    /// The user tapped the Stats button.
    @IBAction func doStats(_ sender: Any) {
        Task {
            await processor?.receive(.stats)
        }
    }

}

