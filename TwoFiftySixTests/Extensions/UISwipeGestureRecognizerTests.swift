@testable import TwoFiftySix
import UIKit
import Testing

struct UISwipeGestureRecognizerTests {
    @Test("swipe direction converts correctly to move direction")
    func direction() {
        do {
            let subject = UISwipeGestureRecognizer.Direction.up
            let result = subject.moveDirection
            #expect(result == .up)
        }
        do {
            let subject = UISwipeGestureRecognizer.Direction.down
            let result = subject.moveDirection
            #expect(result == .down)
        }
        do {
            let subject = UISwipeGestureRecognizer.Direction.left
            let result = subject.moveDirection
            #expect(result == .left)
        }
        do {
            let subject = UISwipeGestureRecognizer.Direction.right
            let result = subject.moveDirection
            #expect(result == .right)
        }
    }
}
