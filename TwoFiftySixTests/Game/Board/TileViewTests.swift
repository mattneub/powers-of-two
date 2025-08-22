@testable import TwoFiftySix
import UIKit
import Testing
import SnapshotTesting

@MainActor
struct TileViewTests {
    @Test("init: making a tile view sets up the view as expected")
    func initialize() async {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 80, height: 80)),
            id: id,
            value: 8
        )
        #expect(subject.id == id)
        #expect(subject.frame == CGRect(origin: .zero, size: .init(width: 80, height: 80)))
        #expect(subject.value == 8)
        #expect(subject.layer.borderWidth == 2)
        #expect(subject.layer.cornerRadius == 16)
        #expect(subject.clipsToBounds == true)
        #expect(subject.isOpaque == false)
        #expect(subject.subviews.first == subject.valueLabel)
        #expect(subject.valueLabel.text == "8")
        #expect(subject.valueLabel.textColor == subject.textColor(forValue: 8))
        #expect(subject.backgroundColor == subject.backgroundColor(forValue: 8))
    }

    @Test("valueLabel is correctly constructed")
    func valueLabel() {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 80, height: 80)),
            id: id,
            value: 8
        )
        let label = subject.valueLabel
        #expect(label.translatesAutoresizingMaskIntoConstraints == false)
        #expect(label.font == UIFont(name: "Gill Sans", size: 30))
        #expect(label.textAlignment == .center)
        #expect(label.minimumScaleFactor == 0.5)
        #expect(label.adjustsFontSizeToFitWidth == true)
    }

    @Test("view looks okay")
    func appearance() {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 50, height: 50)),
            id: id,
            value: 8
        )
        assertSnapshot(of: subject, as: .image)
    }

    @Test("view looks okay with value 2048")
    func appearance2048() {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 50, height: 50)),
            id: id,
            value: 2048
        )
        assertSnapshot(of: subject, as: .image)
    }

    @Test("backgroundColor(forValue:) gives right color")
    func backgroundColor() {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 80, height: 80)),
            id: id,
            value: 8
        )
        #expect(subject.backgroundColor(forValue: 2) == UIColor(rgb: 0xeee4da))
        #expect(subject.backgroundColor(forValue: 4) == UIColor(rgb: 0xede0c8))
        #expect(subject.backgroundColor(forValue: 8) == UIColor(rgb: 0xf2b179))
        #expect(subject.backgroundColor(forValue: 16) == UIColor(rgb: 0xf59563))
        #expect(subject.backgroundColor(forValue: 32) == UIColor(rgb: 0xf67c5f))
        #expect(subject.backgroundColor(forValue: 64) == UIColor(rgb: 0xf65e3b))
        #expect(subject.backgroundColor(forValue: 128) == UIColor(rgb: 0xedcf72))
        #expect(subject.backgroundColor(forValue: 256) == UIColor(rgb: 0xedcc61))
        #expect(subject.backgroundColor(forValue: 512) == UIColor(rgb: 0xedc850))
        #expect(subject.backgroundColor(forValue: 1024) == UIColor(rgb: 0xedc53f))
        #expect(subject.backgroundColor(forValue: 2048) == UIColor(rgb: 0xedc22e))
    }

    @Test("textColor(forValue:) gives right color")
    func textColor() {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 80, height: 80)),
            id: id,
            value: 8
        )
        #expect(subject.textColor(forValue: 2) == UIColor(rgb: 0x000000))
        #expect(subject.textColor(forValue: 4) == UIColor(rgb: 0x000000))
        #expect(subject.textColor(forValue: 8) == UIColor(rgb: 0xf9f6f2))
        #expect(subject.textColor(forValue: 16) == UIColor(rgb: 0xf9f6f2))
        #expect(subject.textColor(forValue: 32) == UIColor(rgb: 0xf9f6f2))
        #expect(subject.textColor(forValue: 64) == UIColor(rgb: 0xf9f6f2))
        #expect(subject.textColor(forValue: 128) == UIColor(rgb: 0x000000))
        #expect(subject.textColor(forValue: 256) == UIColor(rgb: 0x000000))
        #expect(subject.textColor(forValue: 512) == UIColor(rgb: 0x000000))
        #expect(subject.textColor(forValue: 1024) == UIColor(rgb: 0x000000))
        #expect(subject.textColor(forValue: 2048) == UIColor(rgb: 0x000000))
    }

    @Test("setting value sets label text, label text color, and background color")
    func update() {
        let id = UUID()
        let subject = TileView(
            frame: CGRect(origin: .zero, size: .init(width: 80, height: 80)),
            id: id,
            value: 2
        )
        subject.valueLabel.text = "hello"
        subject.valueLabel.textColor = .green
        subject.backgroundColor = .yellow
        subject.value = 8 // this is the test
        #expect(subject.valueLabel.text == "8")
        #expect(subject.valueLabel.textColor == subject.textColor(forValue: 8))
        #expect(subject.backgroundColor == subject.backgroundColor(forValue: 8))
    }
}
