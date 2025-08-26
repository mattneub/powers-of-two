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
    }
}

