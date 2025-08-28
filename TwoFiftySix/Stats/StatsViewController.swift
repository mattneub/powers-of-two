import UIKit

/// View controller of the stats scene.
final class StatsViewController: UIViewController, ReceiverPresenter {
    
    /// Reference to the processor, set by the coordinator at module creation time.
    weak var processor: (any Processor<StatsAction, StatsState, Void>)?

    /// Scroll view content view in the nib, where we will create the remaining interface.
    @IBOutlet var contentView: UIView!

    /// The type of the entry container view, factored out so we can inject a mock for testing.
    typealias ContainerView = UIView & Presenter<StatsState.HistogramEntry>
    var containerViewType: any ContainerView.Type = HistogramEntryContainerView.self

    /// Flag so we don't accidentally create the histogram entry container interface twice.
    var entriesConfigured = false

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialInterface)
        }
    }

    func present(_ state: StatsState) async {
        await configureHistogramEntries(histogram: state.histogram)
    }

    /// Gorgeous utility method that builds the contents of the scroll view as a column of
    /// histogram entry container views.
    /// - Parameter histogram: The overall histogram received in the state.
    func configureHistogramEntries(histogram: [StatsState.HistogramEntry]) async {
        guard !entriesConfigured else {
            return
        }
        entriesConfigured = true
        var previous: UIView?
        for entry in histogram {
            let entryContainerView = containerViewType.init(frame: .zero)
            contentView.addSubview(entryContainerView)
            entryContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            entryContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            if let previous {
                entryContainerView.topAnchor.constraint(equalTo: previous.bottomAnchor).isActive = true
            } else {
                entryContainerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
            }
            previous = entryContainerView
            await entryContainerView.present(entry) // pass presentation for this one entry on to the subview
        }
        previous?.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }

    /// Action method of the done button.
    @IBAction func doDone(_ sender: Any) {
        Task {
            await processor?.receive(.done)
        }
    }

}
