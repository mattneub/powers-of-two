@testable import TwoFiftySix
import Foundation
import Testing

@MainActor
struct MoveDirectionTests {
    @Test("Slot-vector addition works as expect")
    func addition() {
        var slot = Slot(column: 0, row: 0)
        slot = slot + MoveDirection.right.vector
        slot = slot + MoveDirection.right.vector
        #expect(slot == Slot(column: 2, row: 0))
        slot = slot + MoveDirection.down.vector
        slot = slot + MoveDirection.down.vector
        #expect(slot == Slot(column: 2, row: 2))
        slot = slot + MoveDirection.left.vector
        slot = slot + MoveDirection.left.vector
        #expect(slot == Slot(column: 0, row: 2))
        slot = slot + MoveDirection.up.vector
        slot = slot + MoveDirection.up.vector
        #expect(slot == Slot(column: 0, row: 0))
    }

    @Test("Slot-vector subtraction works as expect")
    func subtraction() {
        var slot = Slot(column: 0, row: 0)
        slot = slot - MoveDirection.left.vector
        slot = slot - MoveDirection.left.vector
        #expect(slot == Slot(column: 2, row: 0))
        slot = slot - MoveDirection.up.vector
        slot = slot - MoveDirection.up.vector
        #expect(slot == Slot(column: 2, row: 2))
        slot = slot - MoveDirection.right.vector
        slot = slot - MoveDirection.right.vector
        #expect(slot == Slot(column: 0, row: 2))
        slot = slot - MoveDirection.down.vector
        slot = slot - MoveDirection.down.vector
        #expect(slot == Slot(column: 0, row: 0))
    }
}
