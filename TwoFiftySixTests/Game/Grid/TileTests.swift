@testable import TwoFiftySix
import Foundation
import Testing

struct TileTests {
    @Test("Initializer from tile reducer works as expected")
    func initializeReducer() {
        let tile1 = Tile(value: 2, column: 3, row: 4)
        let tile2 = Tile(tileReducer: .init(tile: tile1))
        #expect(tile1.value == tile2.value)
        #expect(tile1.column == tile2.column)
        #expect(tile1.row == tile2.row)
        #expect(tile1.id != tile2.id)
    }

    @Test("absorb: absorbs the tile and adds its value")
    func absorb() {
        let tile1 = Tile(value: 2, column: 3, row: 4)
        let tile2 = Tile(value: 2, column: 4, row: 5)
        tile1.absorb(tile: tile2)
        #expect(tile1.value == 4)
        #expect(tile1.absorbed?.id == tile2.id)
    }

    @Test("tile reducer expresses tile")
    func reducer() {
        let tile = Tile(value: 2, column: 3, row: 4)
        let reducer = TileReducer(tile: tile)
        #expect(reducer.id == tile.id)
        #expect(reducer.slot.column == tile.column)
        #expect(reducer.slot.row == tile.row)
        #expect(reducer.value == tile.value)
    }
}

