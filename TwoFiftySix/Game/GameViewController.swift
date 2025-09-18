import UIKit

/// Main view controller of the app.
final class GameViewController: UIViewController, ReceiverPresenter {

    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<GameAction, GameState, GameEffect>)?

    /// Serializer that serializes user swipe actions.
    lazy var serializer: any SerializerType<UISwipeGestureRecognizer.Direction> = Serializer()

    @IBOutlet var board: UIView!

    @IBOutlet var highest: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        highest.text = " "
        let newGame = UIBarButtonItem(title: "New Game", image: nil, target: self, action: #selector(doNew))
        let flex = UIBarButtonItem.flexibleSpace()
        let help = UIBarButtonItem(title: nil, image: UIImage(systemName: "questionmark.circle"), target: self, action: #selector(doHelp))
        setToolbarItems([newGame, flex, help], animated: true)
        // Prepare to respond to swipe gestures.
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
        // Start the serializer and configure its task to send `.userMoved`
        // to the processor.
        Task {
            await serializer.startStream { @MainActor [weak self] direction in
                await self?.processor?.receive(.userMoved(direction: direction))
            }
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
            if String(state.highestValue) != highest.text {
                highest.text = String(state.highestValue)
                await animateHighest()
            }
        } else {
            highest.text = " "
        }
    }

    func receive(_ effect: GameEffect) async {
        switch effect {
        case .noStats: // put up an alert explaining why nothing happens
            let alert = UIAlertController(
                title: "No high scores yet.",
                message: nil,
                preferredStyle: .alert
            )
            alert.addAction(.init(title: "OK", style: .default))
            present(alert, animated: unlessTesting(true))
        default: // other effects are passed on to the board
            if let board = board as? any Receiver<GameEffect> {
                await board.receive(effect)
            }
        }
    }

    /// Animate flipping the `highest` label. Called by `present`.
    private func animateHighest() async {
        await UIView.transitionAsync(with: highest, duration: 0.25, options: [.transitionFlipFromBottom])
    }

    /// The user performed a swipe gesture, which constitutes a move. Pass it on to the
    /// serializer, which in turn will send it on to the processor.
    @objc func swipe(_ g: UISwipeGestureRecognizer) {
        Task {
            await serializer.vend(g.direction)
        }
    }

    /// The user tapped the New Game button.
    @objc func doNew(_ sender: Any) {
        Task {
            await processor?.receive(.newGame)
        }
    }

    /// The user tapped the Stats button.
    @IBAction func doStats(_ sender: UIButton) {
        Task {
            await processor?.receive(.stats(source: sender))
        }
    }

    /// The user tapped the Help button.
    @objc func doHelp(_ sender: UIBarButtonItem) {
        Task {
            await processor?.receive(.help(source: sender))
        }
    }
}

