@testable import TwoFiftySix
import UIKit
import Testing
import WaitWhile

@MainActor
struct StatsViewControllerTests {
    let subject = StatsViewController()
    let processor = MockProcessor<StatsAction, StatsState, Void>()
    
    init() {
        subject.processor = processor
    }

    @Test("viewDidLoad: sends initialInterface")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialInterface])
        #expect(subject.containerViewType == HistogramEntryContainerView.self)
        #expect(subject.entriesConfigured == false)
    }

    @Test("present: first time, creates interface based on state histogram")
    func present() async throws {
        makeWindow(viewController: subject)
        let contentView = UIView()
        subject.contentView = contentView
        subject.view.addSubview(contentView)
        contentView.frame = subject.view.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let histogram: [StatsState.HistogramEntry] = [
            .init(score: 1, count: 2),
            .init(score: 3, count: 4),
            .init(score: 5, count: 6),
        ]
        subject.containerViewType = MockContainer.self
        await subject.present(StatsState(histogram: histogram))
        subject.view.layoutIfNeeded()
        var containers = subject.view.subviews(ofType: MockContainer.self)
        #expect(containers.count == 3)
        containers.forEach {
            #expect($0.bounds.width == subject.contentView.bounds.width)
            // good enough, we've got layout
            #expect($0.statesPresented.count == 1)
        }
        // one histogram entry was presented to each container view
        #expect(containers.map { $0.statesPresented[0] } == histogram)
        #expect(subject.entriesConfigured == true)
        // try presenting again, even though this should never happen
        await subject.present(StatsState(histogram: histogram))
        containers = subject.view.subviews(ofType: MockContainer.self)
        #expect(containers.count == 3) // we didn't add any more containers
    }

    @Test("doDone: sends done to processor")
    func doDone() async {
        subject.doDone(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .done)
    }
}

final class MockContainer: UIView, Presenter {
    var statesPresented = [StatsState.HistogramEntry]()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func present(_ state: StatsState.HistogramEntry) async {
        statesPresented.append(state)
    }
}

