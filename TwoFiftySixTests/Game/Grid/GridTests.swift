@testable import TwoFiftySix
import Foundation
import Testing

@MainActor
struct GridTests {
    let subject = Grid()
    let gridLogic = MockGridLogic()

    init() {
        subject.gridLogic = gridLogic
    }

    @Test("the grid is born empty")
    func initialize() {
        for column in 0..<4 {
            for row in 0..<4 {
                #expect(subject[column, row] == nil)
            }
        }
    }

    @Test("subscripting behaves as expected")
    func subscripting() throws{
        let initialTile = Tile(value: 1, column: 1, row: 1)
        subject[1,1] = initialTile
        for column in 0..<4 {
            for row in 0..<4 {
                if column != 1 && row != 1 {
                    #expect(subject[column, row] == nil)
                }
            }
        }
        let tile = try #require(subject[1,1])
        #expect(tile === initialTile)
    }

    @Test("subscripting the other way behaves as expected")
    func subscriptingOther() throws{
        let initialTile = Tile(value: 1, column: 1, row: 1)
        let slot = Slot(column: 1, row: 1)
        subject[slot] = initialTile
        for column in 0..<4 {
            for row in 0..<4 {
                if column != 1 && row != 1 {
                    #expect(subject[Slot(column: column, row: row)] == nil)
                }
            }
        }
        let tile = try #require(subject[slot])
        #expect(tile === initialTile)
    }

    @Test("tiles: lists all the existing tiles as TileReducers")
    func tiles() throws {
        #expect(subject.tiles.isEmpty)
        let initialTile1 = Tile(value: 1, column: 1, row: 1)
        let initialTile2 = Tile(value: 2, column: 2, row: 2)
        subject[1,1] = initialTile1
        subject[2,2] = initialTile2
        let result = subject.tiles
        #expect(result.count == 2)
        let tile1 = try #require(result.first(where: { $0.id == initialTile1.id }))
        let tile2 = try #require(result.first(where: { $0.id == initialTile2.id }))
        #expect(tile1 == TileReducer(tile: initialTile1))
        #expect(tile2 == TileReducer(tile: initialTile2))
    }

    @Test("userMoved: for each traversal for given direction, calls closeUp, merge, closeUp; then calls and returns assess")
    func userMoved() {
        let allTraversals = GridLogic(grid: Grid()).traversals
        let ups = allTraversals(.up)
        let up1 = ups[0]
        let up2 = ups[1]
        gridLogic._allTraversals[.up] = [up1, up2]
        let down = allTraversals(.down)[0]
        gridLogic._allTraversals[.down] = [down]
        let id = UUID()
        gridLogic.assessment = Assessment(moves: [Move(tile: id, slot: Slot(column: 3, row: 3))], merges: [])
        let result = subject.userMoved(direction: .up)
        #expect(gridLogic.methodsCalled == [
            "closeUp(traversal:)", "merge(traversal:)", "closeUp(traversal:)",
            "closeUp(traversal:)", "merge(traversal:)", "closeUp(traversal:)",
            "assess()"
        ])
        #expect(gridLogic.traversals == [up1, up1, up1, up2, up2, up2])
        //
        gridLogic.methodsCalled = []
        gridLogic.traversals = []
        //
        let _ = subject.userMoved(direction: .down)
        #expect(gridLogic.methodsCalled == [
            "closeUp(traversal:)", "merge(traversal:)", "closeUp(traversal:)",
            "assess()"
        ])
        #expect(gridLogic.traversals == [down, down, down])
        #expect(result.moves.count == 1)
        #expect(result.moves.first?.tile == id)
        #expect(result.moves.first?.slot.column == 3)
        #expect(result.moves.first?.slot.row == 3)
        #expect(result.merges.isEmpty)
    }

    @Test("emptySlots: lists all empty slots")
    func emptySlots() {
        let initialTile = Tile(value: 1, column: 1, row: 1)
        let slot = Slot(column: 1, row: 1)
        subject[slot] = initialTile
        let empties = subject.emptySlots
        for column in 0..<4 {
            for row in 0..<4 {
                if column != 1 && row != 1 {
                    #expect(empties.contains(Slot(column: column, row: row)))
                }
            }
        }
        #expect(!empties.contains(slot))
    }

    @Test("setup: puts tiles into the places described by tile reducers, returns tile reducers with new ids")
    func setup() throws {
        let initialTileReducer1 = TileReducer(tile: Tile(value: 1, column: 1, row: 1))
        let initialTileReducer2 = TileReducer(tile: Tile(value: 2, column: 2, row: 2))
        let result = subject.setup(tiles: [initialTileReducer1, initialTileReducer2])
        let tile1 = try #require(subject[Slot(column: 1, row: 1)])
        let tile2 = try #require(subject[Slot(column: 2, row: 2)])
        #expect(tile1.value == 1)
        #expect(tile1.column == 1)
        #expect(tile1.row == 1)
        #expect(tile2.value == 2)
        #expect(tile2.column == 2)
        #expect(tile2.row == 2)
        #expect(result.count == 2)
        #expect(result[0] == TileReducer(tile: tile1))
        #expect(result[1] == TileReducer(tile: tile2))
    }

    @Test("insertRandomTile: returns nil if there is no room")
    func insertRandomTileNoRoom() {
        let initialTile = TileReducer(tile: Tile(value: 1, column: 1, row: 1))
        for column in 0..<4 {
            for row in 0..<4 {
                subject[column, row] = Tile(tileReducer: initialTile)
            }
        }
        let result = subject.insertRandomTile()
        #expect(result == nil)
    }

    @Test("insertRandomTile: fills single empty slot")
    func insertRandomTileOneSlot() throws {
        let initialTile = TileReducer(tile: Tile(value: 1, column: 1, row: 1))
        for column in 0..<4 {
            for row in 0..<4 {
                subject[column, row] = Tile(tileReducer: initialTile)
            }
        }
        subject[2, 2] = nil
        let result = try #require(subject.insertRandomTile())
        #expect(result.value == 2 || result.value == 4)
        #expect(result.slot == Slot(column: 2, row: 2))
    }

    @Test("insertRandomTile: if two empty slots, fills one at random; mostly 2 but occasionally 4")
    func insertRandomTileTwoSlots() throws {
        var results = [TileReducer]()
        for _ in 0..<1000 {
            let initialTile = TileReducer(tile: Tile(value: 1, column: 1, row: 1))
            for column in 0..<4 {
                for row in 0..<4 {
                    subject[column, row] = Tile(tileReducer: initialTile)
                }
            }
            subject[2, 2] = nil
            subject[3, 3] = nil
            let result = try #require(subject.insertRandomTile())
            results.append(result)
        }
        let slot1results = results.filter { $0.slot == Slot(column: 2, row: 2) }
        let slot2results = results.filter { $0.slot == Slot(column: 3, row: 3) }
        let twoResults = results.filter { $0.value == 2 }
        let fourResults = results.filter { $0.value == 4 }
        // probablistic results; it would be nice to know how far I can push this :)
        #expect(slot1results.count > 450) // ideally 500
        #expect(slot2results.count > 450) // ideally 500
        #expect(twoResults.count + fourResults.count == 1000)
        #expect(twoResults.count > 850) // ideally 900
        #expect(fourResults.count > 50) // ideally 100
    }

    @Test("empty: nilifies the whole grid")
    func empty() {
        let initialTile = TileReducer(tile: Tile(value: 1, column: 1, row: 1))
        for column in 0..<4 {
            for row in 0..<4 {
                subject[column, row] = Tile(tileReducer: initialTile)
            }
        }
        #expect(subject.tiles.count == 16)
        subject.empty()
        #expect(subject.tiles.count == 0)
    }
}
