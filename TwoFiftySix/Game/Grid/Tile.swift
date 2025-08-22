import Foundation

/// A _tile_ is a value-carrying object whose main job is to occupy a slot of the Grid.
/// It is _not_ a view; rather, it is part of the model-object source of truth that
/// dictates where the tile views need to go.
final class Tile: CustomStringConvertible {
    /// The tile's value (2, 4, 8, etc.). It is publicly gettable.
    private(set) var value: Int

    /// The tile's slot's column, i.e. where it thinks it is in the grid. We maintain this information
    /// because if a tile is _not_ where it thinks it is, it is because it has just been moved.
    var column: Int

    /// The tile's slot's row, i.e. where it thinks it is in the grid. We maintain this information
    /// because if a tile is _not_ where it thinks it is, it is because it has just been moved.
    var row: Int

    /// The tile, if any, that was absorbed into this tile as a result of a merge. This has a value
    /// only right after the merge takes place.
    var absorbed: Tile?

    /// The tile's unique identifier. This is the sole source-of-truth point of contact between a
    /// tile in the grid and the tile view that represents it in the visible interface.
    let id: UUID = UUID()
    
    /// Create a tile.
    /// - Parameters:
    ///   - value: The tile's initial value.
    ///   - column: The tile's initial slot column.
    ///   - row: The tile's initial slot row.
    init(value: Int, column: Int, row: Int) {
        self.value = value
        self.column = column
        self.row = row
    }

    /// Create a tile.
    /// - Parameter tileReducer: A tile reducer describing the desired tile.
    convenience init(tileReducer: TileReducer) {
        self.init(
            value: tileReducer.value,
            column: tileReducer.slot.column,
            row: tileReducer.slot.row
        )
    }

    /// Merge the given tile into this tile. To do so, sum their values (which had better be
    /// identical) and set this tile's `absorbed` to record what happened.
    func absorb(tile: Tile) {
        assert(self.value == tile.value)
        self.value = self.value + tile.value
        absorbed = tile
    }

    var description: String {
        "\(value), (\(column),\(row))"
    }
}

/// Reducer that lets us communicate information about a tile without sharing the tile itself.
struct TileReducer: Equatable, Codable {
    let slot: Slot
    let id: UUID
    let value: Int

    init(tile: Tile) {
        self.slot = Slot(column: tile.column, row: tile.row)
        self.id = tile.id
        self.value = tile.value
    }
}

