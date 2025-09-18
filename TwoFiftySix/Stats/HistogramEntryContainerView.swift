import UIKit

/// Class of the container view of the histogram entry view, so that we can hoover the view
/// itself out of a nib.
final class HistogramEntryContainerView: UIView, Presenter {
    // The outlets are to labels in the HistogramEntry view, which is instantiated from a nib
    // with this view as file's owner.
    @IBOutlet var score: UILabel!
    @IBOutlet var times: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        let views = UINib(nibName: "HistogramEntry", bundle: nil).instantiate(withOwner: self)
        guard let entry = views.first as? HistogramEntry else {
            return
        }
        entry.translatesAutoresizingMaskIntoConstraints = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(entry)
        NSLayoutConstraint.activate([
            entry.topAnchor.constraint(equalTo: self.topAnchor),
            entry.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            entry.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            entry.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func present(_ state: (StatsState.HistogramEntry, Int)) {
        let (entry, maxLengthNeeded) = state
        score.text = String(entry.score)
        var count = String(entry.count)
        while count.count < maxLengthNeeded {
            count = "\u{2007}" + count // pad on left with space the width of a digit
        }
        times.text = count
    }
}

