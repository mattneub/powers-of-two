import UIKit

class GameViewController: UIViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<GameAction, GameState, GameEffect>)?

    @IBOutlet var board: Board!

    override func viewDidLoad() {
        super.viewDidLoad()
        // prepare to respond to swipe gestures
        do {
            let g = UISwipeGestureRecognizer()
            g.direction = .up
            g.addTarget(self, action: #selector(swipe))
            view.addGestureRecognizer(g)
        }
        do {
            let g = UISwipeGestureRecognizer()
            g.direction = .down
            g.addTarget(self, action: #selector(swipe))
            view.addGestureRecognizer(g)
        }
        do {
            let g = UISwipeGestureRecognizer()
            g.direction = .left
            g.addTarget(self, action: #selector(swipe))
            view.addGestureRecognizer(g)
        }
        do {
            let g = UISwipeGestureRecognizer()
            g.direction = .right
            g.addTarget(self, action: #selector(swipe))
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

    func present(_ state: GameState) async {}

    func receive(_ effect: GameEffect) async {
        await board.receive(effect)
    }

    /// The user performed a swipe gesture, which constitutes a move.
    @objc func swipe(_ g: UISwipeGestureRecognizer) {
        Task {
            await processor?.receive(.userMoved(direction: g.direction))
        }
    }

    /// The user tapped the New Game button.
    @IBAction func doNew (_ sender:Any) {
        Task {
            await processor?.receive(.newGame)
        }
    }

}

