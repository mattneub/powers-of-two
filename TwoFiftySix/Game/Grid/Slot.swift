/// An address in the grid, where a tile can go — usable also to position a tile view within
/// the board. It is simply a column–row pair, so it is mostly a mere convenience.
/// However, it also has the ability to be incremented or decremented in a given direction,
/// by means of a vector, in order to reach the next/previous adjacent slot.
struct Slot: Equatable, Codable {
    let column: Int
    let row: Int
    static func +(lhs: Slot, rhs: MoveDirection.Vector) -> Slot {
        Slot(column: lhs.column + rhs.x, row: lhs.row + rhs.y)
    }
    static func -(lhs: Slot, rhs: MoveDirection.Vector) -> Slot {
        Slot(column: lhs.column - rhs.x, row: lhs.row - rhs.y)
    }
}
