/// A direction in which the user can move.
enum MoveDirection: CaseIterable {
    case up
    case right
    case down
    case left
    // The vector that, when added to a slot, yields the next slot in this direction.
    var vector: Vector {
        switch self {
        case .up: Vector(x: 0, y: -1)
        case .right: Vector(x: 1, y: 0)
        case .down: Vector(x: 0, y: 1)
        case .left: Vector(x: -1, y: 0)
        }
    }
    /// A slot increment, i.e. the x and y (column and row) values that would need to be
    /// _added to a slot_ in order to get the next slot in the given direction.
    struct Vector {
        let x: Int
        let y: Int
    }
}
