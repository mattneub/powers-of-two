import Foundation
import Algorithms


/// Protocol describing the public face of the Grid.
protocol GridType {
    var tiles: [TileReducer] { get }
    var highestValue: Int { get }
    func empty()
    func insertRandomTile() -> TileReducer?
    func setup(tiles: [TileReducer]) -> [TileReducer]
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

    /// An array of reducers describing all tiles. The row and column are known because a tile
    /// knows its own row and column, unless it has just been moved, in which case we shouldn't
    /// be asking for this property!
    var tiles: [TileReducer] {
        grid.flatMap { $0 }.compactMap { $0 }.map { TileReducer(tile: $0) }
    }

    /// The highest value of any tile in the grid.
    var highestValue: Int {
        tiles.map { $0.value }.max() ?? 2
    }

    /// The user has moved by swiping in the given direction: okay, apply the logic of the game
    /// rules! This means, simply, for each of the four traversals appropriate to the direction in
    /// the user moves, apply gravity to close up all gaps, perform any merges, and then do another
    /// gravity pass in case the performance of merges itself left any gaps. Finally, request an
    /// immediate assessment of what just happened, so that the changes can be enacted in the
    /// interface as well.
    /// - Parameter direction: The direction of the user's move.
    /// - Returns: The assessment describing the changes to the grid.
    func userMoved(direction: MoveDirection) -> Assessment {
        for traversal in gridLogic.traversals(direction) {
            gridLogic.closeUp(traversal: traversal)
            gridLogic.merge(traversal: traversal)
            gridLogic.closeUp(traversal: traversal)
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

    /// Create and insert the tiles described by the incoming tile reducers, and return a list of
    /// tile reducers describing those tiles. The returned list is new, because the UUIDs of the
    /// incoming tile reducers are ignored and are replaced by the UUIDs of the new tiles.
    /// - Parameter tiles: The incoming tile reducers.
    /// - Returns: The tile reducers representing the created and inserted tiles.
    func setup(tiles: [TileReducer]) -> [TileReducer] {
        var realTiles = [TileReducer]()
        for tileReducer in tiles {
            let tile = Tile(tileReducer: tileReducer)
            self[tileReducer.slot] = tile
            realTiles.append(TileReducer(tile: tile)) // get the new id
        }
        return realTiles
    }

    /// Insert a tile with a correctly randomized value ("usually 2, but possibly 4") into a
    /// random empty slot, and report what you did by returning a reducer describing the new tile.
    /// - Returns: Reducer describing the newly inserted tile, or nil if there was no room.
    func insertRandomTile() -> TileReducer? {
        var empties = emptySlots
        guard empties.count > 0 else {
            return nil // no room
        }
        let value = Double.random(in: 0.1...1.0) < 0.9 ? 2 : 4 // straight from the original code
        empties = empties.shuffled().shuffled().shuffled().shuffled()
        let slot = empties[Int.random(in: 0..<empties.count)]
        let tile = Tile(value: value, column: slot.column, row: slot.row)
        self[slot] = tile
        return (TileReducer(tile: tile))
    }

    /// Clear the grid, removing all tiles. This happens when a new game begins.
    func empty() {
        grid = .init(repeating: .init(repeating: nil, count: 4), count: 4)
    }
}



