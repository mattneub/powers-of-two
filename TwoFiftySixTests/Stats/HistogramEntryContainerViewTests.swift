@testable import TwoFiftySix
import UIKit
import Testing
import SnapshotTesting

struct HistogramEntryContainerViewTests {
    let subject = HistogramEntryContainerView(frame: CGRect(origin: .zero, size: .init(width: 400, height: 100)))

    @Test("initialize: structure is correct")
    func initialize() throws {
        let entry = try #require(subject.subviews.first as? HistogramEntry)
        #expect(subject.score.isDescendant(of: entry))
        #expect(subject.times.isDescendant(of: entry))
    }

    @Test("present: sets text of labels")
    func present() {
        subject.present(.init(score: 100, count: 200))
        #expect(subject.score.text == "100")
        #expect(subject.times.text == "200")
    }

    @Test("view looks right")
    func viewAppearance() {
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.present(.init(score: 100, count: 200))
        subject.widthAnchor.constraint(equalTo: viewController.view.widthAnchor).isActive = true
        subject.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true
        assertSnapshot(of: viewController.view, as: .image)
    }
}
