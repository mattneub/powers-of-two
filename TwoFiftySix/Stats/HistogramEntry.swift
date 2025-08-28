import UIKit

/// Class of the histogram entry view. It is instantiated from a nib.
final class HistogramEntry: UIView {
    override func draw(_ rect: CGRect) {
        UIColor.systemGray3.setFill()
        UIBezierPath(rect: CGRect(
            x: rect.minX,
            y: rect.maxY - 2,
            width: rect.width,
            height: 2
        )).fill()
    }
}
