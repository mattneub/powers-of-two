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
final class Grid: GridType, CustomStringConvertible {
    /// Array of arrays where the tiles live.
    private lazy var grid: [[Tile?]] = .init(repeating: .init(repeating: nil, count: 4), count: 4)

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

    /// For what a traversal is, see `traversals(forMoveDirection:)`. There are four traversals
    /// for each of the four possible moves the user can make, and they are unchanging, so it is
    /// silly to calculate them all every time the user moves; therefore we calculate them just
    /// once at the start of the game and retain them in this dictionary, keyed by direction.
    lazy var allTraversals: [MoveDirection: [[Slot]]] = {
        MoveDirection.allCases.reduce(into: [MoveDirection: [[Slot]]]()) { result, direction in
            result[direction] = traversals(forMoveDirection: direction)
        }
    }()

    /// A _traversal_ is a linear sequence of four slots, either all the slots of a row or
    /// all the slots of a column, in one direction or the other. It represents the steps
    /// by which we examine the contents of the row-or-column to see what needs to be done
    /// in consequence of the user's move. The direction of the sequence is thus the _opposite_
    /// of the direction of the user's move, i.e. it is the opposite of the direction of the
    /// "gravity" applied to the tiles: we start by looking at the furthest extreme in the
    /// direction the user swiped, and then look at the slot before that, and so on.
    /// - Parameter direction: The direction of the user's move.
    /// - Returns: An array of four traversals, one for each column or row of the grid. We can
    /// thus apply "gravity" to the entire grid by cycling through each of the four traversals
    /// in the array that is returned.
    func traversals(forMoveDirection direction: MoveDirection) -> [[Slot]] {
        var starts = [Slot]()
        switch direction {
        case .up:
            for column in 0..<4 {
                starts.append(Slot(column: column, row: 0))
            }
        case .right:
            for row in 0..<4 {
                starts.append(Slot(column: 3, row: row))
            }
        case .down:
            for column in 0..<4 {
                starts.append(Slot(column: column, row: 3))
            }
        case .left:
            for row in 0..<4 {
                starts.append(Slot(column: 0, row: row))
            }
        }
        var result = starts.map { [$0] }
        for index in 0..<4 {
            for _ in 0..<3 {
                guard let prev = result[index].last else {
                    continue // won't happen
                }
                result[index].append(prev - direction.vector)
            }
        }
        return result
    }

    /// As we walk the traversal to apply gravity, if we encounter a tile, we must move it
    /// _as far as possible_ in the gravity direction (the direction of the user's move). Well,
    /// what slot exactly is "as far as possible"? It is the furthest empty slot, starting at
    /// the slot where we encountered the tile, in the direction of user's move. This works
    /// because if we encounter a tile, any tiles that precede it in the direction of the user's
    /// move have already been encountered and moved.
    /// - Parameters:
    ///   - traversal: An array of four slots.
    ///   - slot: The slot (in the `traversal`) where we encountered the tile we are considering
    ///    moving.
    ///   - direction: The direction of the user's move.
    /// - Returns: The slot to which to move the tile, or `nil` if no empty slot was found in the
    /// given direction, in which case there is nothing to do — the tile is already as far as
    /// possible in that direction.
    func furthestEmpty(in traversal: [Slot], from slot: Slot, direction: MoveDirection) -> Slot? {
        guard traversal.contains(slot) else {
            return nil // shouldn't happen
        }
        var result: Slot? = nil
        var current = slot + direction.vector
        while traversal.contains(current) {
            if self[current] == nil {
                result = current
            }
            current = current + direction.vector
        }
        return result
    }

    /// Enact "gravity" in the given direction upon all the tiles found within the given
    /// traversal.
    /// - Parameters:
    ///   - traversal: The traversal.
    ///   - direction: The direction of the user's move.
    func closeUp(traversal: [Slot], direction: MoveDirection) {
        for slot in traversal {
            if let tile = self[slot] {
                if let empty = furthestEmpty(in: traversal, from: slot, direction: direction) {
                    self[empty] = tile
                    self[slot] = nil
                }
            }
        }
    }

    /// After `closeUp(traversal:direction:)` is initially applied to a traversal, if any tiles
    /// with the same value are now adjacent, they must be merged. Do that! We are saved from
    /// having to think about what the concept of examining all the adjacent pairs by
    /// the existence in the Swift Algorithms of `windows(ofCount:)`.
    /// - Parameter traversal: The traversal.
    func merge(traversal: [Slot]) {
        for pair in traversal.windows(ofCount: 2) {
            let pair = Array(pair) // important, because otherwise we don't know the indices!
            if let tile1 = self[pair[0]], let tile2 = self[pair[1]], tile1.value == tile2.value {
                tile1.absorb(tile: tile2)
                self[pair[1]] = nil
            }
        }
    }

    /// The only truly public entry point to the Grid. The user has moved by swiping in the given
    /// direction: okay, apply the logic of the game rules! This means, simply, for each of the
    /// four traversals appropriate to the direction in the user moves, apply gravity to
    /// close up all gaps, perform any merges, and then do another gravity pass in case the
    /// performance of merges itself left any gaps.
    /// - Parameter direction: The direction of the user's move.
    /// - Returns: The assessment describing the changes to the grid (see `assess()`).
    func userMoved(direction: MoveDirection) -> Assessment {
        for traversal in (allTraversals[direction] ?? []) {
            closeUp(traversal: traversal, direction: direction)
            merge(traversal: traversal)
            closeUp(traversal: traversal, direction: direction)
        }
        return assess()
    }

    /// This is the Really Tricky Part. After a call to `userMoved(direction:)`, the grid may
    /// have changed. We need to enact those same changes in the visible interface. In order to
    /// do so, we need to know what those changes are! This method returns an Assessment, which is
    /// simply a description of the changes that took place. I suppose we could have tracked the
    /// changes as we performed them, but we didn't. So how do we know what they were? This is why
    /// a Tile has `column` and `row` properties and an `absorbed` property. If a tile's `column`
    /// and/or `row` do not match the slot where it is now, it was moved from
    /// the `column` and `row` of its properties; so report the movement, and rectify
    /// its `column` and `row`. If a tile has
    /// an `absorbed` tile, that tile was merged into this one; so report that, and nilify its
    /// `absorbed` property.
    /// - Returns: A description of what happened in consequence of the user's move, entirely in
    /// terms of tile UUIDs, slots, and values. In other words, we _reduce_ the information about
    /// the move so that no actual tile escapes from the grid.
    func assess() -> Assessment {
        var movedTiles = [Move]()
        var mergedTiles = [Merge]()
        for column in 0..<4 {
            for row in 0..<4 {
                if let tile = self[column, row] {
                    if tile.column != column || tile.row != row {
                        movedTiles.append((
                            tile: tile.id,
                            to: Slot(column: column, row: row)
                        ))
                        (tile.column, tile.row) = (column, row)
                    }
                    if let absorbed = tile.absorbed {
                        mergedTiles.append((
                            tile: tile.id,
                            absorbedTile: absorbed.id,
                            newValue: tile.value
                        ))
                        tile.absorbed = nil
                    }
                }
            }
        }
        return (moves: movedTiles, merges: mergedTiles)
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

/// An address in the grid — usable also to position a tile within the board. It is simply a
/// column–row pair, so it is mostly a mere convenience. However, it also has the ability to be
/// incremented or decremented in a given direction, by means of a vector, in order to reach
/// the next/previous adjacent slot.
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

