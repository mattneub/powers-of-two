import UIKit

/// View controller of the stats scene.
final class StatsViewController: UIViewController, ReceiverPresenter {
    
    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<StatsAction, StatsState, Void>)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
        Task {
            await processor?.receive(.initialInterface)
        }
    }

    func present(_ state: StatsState) async {
        print(state.histogram)
    }
}
