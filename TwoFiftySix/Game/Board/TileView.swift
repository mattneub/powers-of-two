import UIKit

/// A tile view is a numbered square that appears in the interface. It _portrays_ a tile in
/// the grid, but it has no knowledge of this fact; the sole point of absolute contact between
/// a tile view and the tile it represents is that they _must have same id_.
final class TileView: UIView {
    /// The value (2, 4, 8, etc.) to be displayed. Changing the value changes the display.
    var value: Int {
        didSet {
            update()
        }
    }

    /// Label that portrays the value.
    lazy var valueLabel = UILabel(frame: .zero).applying {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = UIFont(name: "Gill Sans", size: 30)
        $0.textAlignment = .center
        $0.minimumScaleFactor = 0.5
        $0.adjustsFontSizeToFitWidth = true
    }

    /// The tile view's id, which must match the id of the tile that it portrays.
    let id: UUID

    /// Make a new tile view.
    /// - Parameters:
    ///   - frame: The new tile view's frame.
    ///   - id: The new tile view's id.
    ///   - value: The new tile view's value.
    init(frame: CGRect, id: UUID, value: Int) {
        self.id = id
        self.value = value
        super.init(frame: frame)
        layer.borderWidth = 2
        layer.cornerRadius = 16
        clipsToBounds = true
        isOpaque = false
        addSubview(valueLabel)
        NSLayoutConstraint.activate([
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
        ])
        update()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Generate the tile's background color based on its proposed value. The colors come from
    /// the original app, https://github.com/gabrielecirulli/2048/blob/master/style/main.css
    /// - Parameter value: The proposed value for the tile.
    /// - Returns: The color to use as the background color.
    func backgroundColor(forValue value: Int) -> UIColor {
        let hex: Int = switch value {
        case 2: 0xeee4da
        case 4: 0xede0c8
        case 8: 0xf2b179
        case 16: 0xf59563
        case 32: 0xf67c5f
        case 64: 0xf65e3b
        case 128: 0xedcf72
        case 256: 0xedcc61
        case 512: 0xedc850
        case 1024: 0xedc53f
        default: 0xedc22e
        }
        // print("value", value, String(format:"%02x", hex))
        return UIColor(rgb: hex)
    }

    /// Generate the tile's text color based on its proposed value. The colors come from
    /// the original app, https://github.com/gabrielecirulli/2048/blob/master/style/main.css
    /// but I've made some modifications.
    /// - Parameter value: The proposed value for the tile.
    /// - Returns: The color to use as the text color.
    func textColor(forValue value: Int) -> UIColor {
        let hex: Int = switch value {
        case 2, 4: 0x000000
        case 8, 16, 32, 64: 0xf9f6f2
        default: 0x000000
        }
        return UIColor(rgb: hex)
    }

    /// Adjust text value and color, and background color, to match current value.
    func update() {
        valueLabel.text = String(value)
        valueLabel.textColor = textColor(forValue: value)
        backgroundColor = backgroundColor(forValue: value)
    }
}
