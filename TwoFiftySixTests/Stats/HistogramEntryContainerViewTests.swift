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

    @Test("present: sets text of labels, including padding count")
    func present() {
        subject.present((.init(score: 100, count: 2), 3))
        #expect(subject.score.text == "100")
        #expect(subject.times.text == "\u{2007}\u{2007}2")
    }

    @Test("view looks right")
    func viewAppearance() {
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.present((.init(score: 100, count: 200), 3))
        subject.widthAnchor.constraint(equalTo: viewController.view.widthAnchor).isActive = true
        subject.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor).isActive = true
        assertSnapshot(of: viewController.view, as: .image)
    }
}
