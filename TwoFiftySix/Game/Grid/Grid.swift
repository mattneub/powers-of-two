import Foundation
import Algorithms

/// Type aliases used to communicate info back from the Grid to the caller without
/// exposing any Tile objects.
typealias TileReducer = (slot: Slot, id: UUID, value: Int)
typealias Move = (tile: UUID, to: Slot)
typealias Merge = (tile: UUID, absorbedTile: UUID, newValue: Int)
typealias Assessment = (moves: [Move], merges: [Merge])

/// Protocol describing the public face of the Grid.
protocol GridType {
    func empty()
    func insertRandomTile() -> TileReducer?
    func userMoved(direction: MoveDirection) -> Assessment
}

/// The Grid is the model object that embodies everything that happens in the game. It consists
/// of slots, and manages tiles which go into those slots. It is the source of truth for the
/// game state and its move logic, that is, the logic of gravity and merges when the user moves.
/// A single instance exists, the servant of the GameProcessor.
final class Grid: GridType, CustomStringConvertible {
    /// Array of arrays where the tiles live.
    private lazy var grid: [[Tile?]] = .init(repeating: .init(repeating: nil, count: 4), count: 4)

    /// GridLogic object that knows how to move, merge, and assess in response to user's move.
    lazy var gridLogic: GridLogicType = GridLogic(grid: self)

    /// The description of the Grid is merely the description of the array of array of tiles.
    var description: String { grid.description }

    /// Subscripts into the array of arrays, for convenience. You can say column-comma-row, or you
    /// can supply a slot.
    subscript(column: Int, row: Int) -> Tile? {
        get { grid[column][row] }
        set { grid[column][row] = newValue }
    }
    subscript(slot: Slot) -> Tile? {
        get { grid[slot.column][slot.row] }
        set { grid[slot.column][slot.row] = newValue }
    }

    /// The only truly public entry point to the Grid. The user has moved by swiping in the given
    /// direction: okay, apply the logic of the game rules! This means, simply, for each of the
    /// four traversals appropriate to the direction in the user moves, apply gravity to
    /// close up all gaps, perform any merges, and then do another gravity pass in case the
    /// performance of merges itself left any gaps. Finally, request an immediate assessment of what
    /// just happened, so that the changes can be enacted in the interface as wsell.
    /// - Parameter direction: The direction of the user's move.
    /// - Returns: The assessment describing the changes to the grid.
    func userMoved(direction: MoveDirection) -> Assessment {
        for traversal in (gridLogic.allTraversals[direction] ?? []) {
            gridLogic.closeUp(traversal: traversal, direction: direction)
            gridLogic.merge(traversal: traversal)
            gridLogic.closeUp(traversal: traversal, direction: direction)
        }
        return gridLogic.assess()
    }

    /// Find and list all empty slots, so that we know where we can insert a new tile at random.
    var emptySlots: [Slot] {
        var empties = [Slot]()
        for column in 0..<4 {
            for row in 0..<4 {
                if self[column, row] == nil {
                    empties.append(Slot(column: column, row: row))
                }
            }
        }
        return empties
    }

    /// Insert a tile with a correctly randomized value ("usually 2, but possibly 4") into a
    /// random empty slot, and report what you did by returning a reducer describing the new tile.
    /// - Returns: Reducer describing the newly inserted tile, or nil if there was no room.
    func insertRandomTile() -> TileReducer? {
        let rand = Double.random(in: 0.1...1.0)
        let value = rand < 0.9 ? 2 : 4
        let empties = emptySlots.shuffled().shuffled().shuffled().shuffled()
        if let slot = empties.first {
            let tile = Tile(value: value, column: slot.column, row: slot.row)
            self[slot] = tile
            return ((slot: slot, id: tile.id, value: value))
        }
        return nil // no room
    }

    /// Clear the grid, removing all tiles. This happens when a new game begins.
    func empty() {
        grid = .init(repeating: .init(repeating: nil, count: 4), count: 4)
    }
}

/// An address in the grid, where a tile can go — usable also to position a tile view within
/// the board. It is simply a column–row pair, so it is mostly a mere convenience.
/// However, it also has the ability to be incremented or decremented in a given direction,
/// by means of a vector, in order to reach the next/previous adjacent slot.
struct Slot: Equatable {
    let column: Int
    let row: Int
    static func +(lhs: Slot, rhs: MoveDirection.Vector) -> Slot {
        Slot(column: lhs.column + rhs.x, row: lhs.row + rhs.y)
    }
    static func -(lhs: Slot, rhs: MoveDirection.Vector) -> Slot {
        Slot(column: lhs.column - rhs.x, row: lhs.row - rhs.y)
    }
}

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

