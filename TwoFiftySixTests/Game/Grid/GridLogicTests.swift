@testable import TwoFiftySix
import Foundation
import Testing

struct GridLogicTests {
    @Test("traversals: is correct for every move direction")
    func traversals() throws {
        let grid = Grid()
        let subject = GridLogic(grid: grid)
        do {
            let traversals = subject.traversals(.up)
            let expected: [[Slot]] = [
                [Slot(column: 0, row: 0), Slot(column: 0, row: 1), Slot(column: 0, row: 2), Slot(column: 0, row: 3)],
                [Slot(column: 1, row: 0), Slot(column: 1, row: 1), Slot(column: 1, row: 2), Slot(column: 1, row: 3)],
                [Slot(column: 2, row: 0), Slot(column: 2, row: 1), Slot(column: 2, row: 2), Slot(column: 2, row: 3)],
                [Slot(column: 3, row: 0), Slot(column: 3, row: 1), Slot(column: 3, row: 2), Slot(column: 3, row: 3)],
            ]
            #expect(traversals.map(\.array) == expected)
            #expect(traversals.allSatisfy { $0.direction == .up })
        }
        do {
            let traversals = subject.traversals(.down)
            let expected: [[Slot]] = [
                [Slot(column: 0, row: 3), Slot(column: 0, row: 2), Slot(column: 0, row: 1), Slot(column: 0, row: 0)],
                [Slot(column: 1, row: 3), Slot(column: 1, row: 2), Slot(column: 1, row: 1), Slot(column: 1, row: 0)],
                [Slot(column: 2, row: 3), Slot(column: 2, row: 2), Slot(column: 2, row: 1), Slot(column: 2, row: 0)],
                [Slot(column: 3, row: 3), Slot(column: 3, row: 2), Slot(column: 3, row: 1), Slot(column: 3, row: 0)],
            ]
            #expect(traversals.map(\.array) == expected)
            #expect(traversals.allSatisfy { $0.direction == .down })
        }
        do {
            let traversals = subject.traversals(.left)
            let expected: [[Slot]] = [
                [Slot(column: 0, row: 0), Slot(column: 1, row: 0), Slot(column: 2, row: 0), Slot(column: 3, row: 0)],
                [Slot(column: 0, row: 1), Slot(column: 1, row: 1), Slot(column: 2, row: 1), Slot(column: 3, row: 1)],
                [Slot(column: 0, row: 2), Slot(column: 1, row: 2), Slot(column: 2, row: 2), Slot(column: 3, row: 2)],
                [Slot(column: 0, row: 3), Slot(column: 1, row: 3), Slot(column: 2, row: 3), Slot(column: 3, row: 3)],
            ]
            #expect(traversals.map(\.array) == expected)
            #expect(traversals.allSatisfy { $0.direction == .left })
        }
        do {
            let traversals = subject.traversals(.right)
            let expected: [[Slot]] = [
                [Slot(column: 3, row: 0), Slot(column: 2, row: 0), Slot(column: 1, row: 0), Slot(column: 0, row: 0)],
                [Slot(column: 3, row: 1), Slot(column: 2, row: 1), Slot(column: 1, row: 1), Slot(column: 0, row: 1)],
                [Slot(column: 3, row: 2), Slot(column: 2, row: 2), Slot(column: 1, row: 2), Slot(column: 0, row: 2)],
                [Slot(column: 3, row: 3), Slot(column: 2, row: 3), Slot(column: 1, row: 3), Slot(column: 0, row: 3)],
            ]
            #expect(traversals.map(\.array) == expected)
            #expect(traversals.allSatisfy { $0.direction == .right })
        }
    }

    @Test("closeUp: closes up all tiles in a traversal")
    func closeUp() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 1)
        grid[0, 1] = tile1
        let tile2 = Tile(value: 16, column: 0, row: 3)
        grid[0, 3] = tile2
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.closeUp(traversal: traversal)
        let movedTile1 = try #require(grid[0, 0])
        let movedTile2 = try #require(grid[0, 1])
        #expect(movedTile1 === tile1)
        #expect(movedTile2 === tile2)
    }

    @Test("closeUp: does nothing if the traversal is empty")
    func closeUpEmpty() {
        let grid = Grid()
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.closeUp(traversal: traversal)
        for slot in traversal.array {
            #expect(grid[slot] == nil)
        }
    }

    @Test("closeUp: does nothing if existing tiles cannot be moved")
    func closeUpFull() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 0)
        grid[0, 0] = tile1
        let tile2 = Tile(value: 16, column: 0, row: 1)
        grid[0, 1] = tile2
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.closeUp(traversal: traversal)
        let unmovedTile1 = try #require(grid[0, 0])
        let unmovedTile2 = try #require(grid[0, 1])
        #expect(unmovedTile1 === tile1)
        #expect(unmovedTile2 === tile2)
    }

    @Test("merge: if matching adjacent tiles exist, removes second one, makes it absorbed by first one")
    func merge() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 0)
        grid[0, 0] = tile1
        let tile2 = Tile(value: 8, column: 0, row: 1)
        grid[0, 1] = tile2
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.merge(traversal: traversal)
        let foundTile1 = try #require(grid[0, 0])
        #expect(foundTile1.value == 16)
        #expect(foundTile1.absorbed === tile2)
        #expect(grid[0, 1] == nil)
    }

    @Test("merge: if multiple matching adjacent tiles exist, merges both as pairs, leaving a gap")
    func merge2() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 0)
        grid[0, 0] = tile1
        let tile2 = Tile(value: 8, column: 0, row: 1)
        grid[0, 1] = tile2
        let tile3 = Tile(value: 8, column: 0, row: 2)
        grid[0, 2] = tile3
        let tile4 = Tile(value: 8, column: 0, row: 3)
        grid[0, 3] = tile4
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.merge(traversal: traversal)
        let foundTile1 = try #require(grid[0, 0])
        #expect(foundTile1.value == 16)
        #expect(foundTile1.absorbed === tile2)
        #expect(grid[0, 1] == nil)
        let foundTile3 = try #require(grid[0, 2])
        #expect(foundTile3.value == 16)
        #expect(foundTile3.absorbed === tile4)
        #expect(grid[0, 3] == nil)
    }

    @Test("merge: does nothing if no adjacent tiles exist")
    func mergeNothingToDo() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 0)
        grid[0, 0] = tile1
        let tile2 = Tile(value: 8, column: 0, row: 2)
        grid[0, 2] = tile2
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.merge(traversal: traversal)
        let foundTile1 = try #require(grid[0, 0])
        let foundTile2 = try #require(grid[0, 2])
        #expect(foundTile1.value == 8)
        #expect(foundTile1.absorbed == nil)
        #expect(foundTile2.value == 8)
    }

    @Test("merge: does nothing if adjacent tiles do not match")
    func mergeNothingToDo2() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 0)
        grid[0, 0] = tile1
        let tile2 = Tile(value: 16, column: 0, row: 1)
        grid[0, 1] = tile2
        let subject = GridLogic(grid: grid)
        let traversal = subject.traversals(.up)[0]
        subject.merge(traversal: traversal)
        let foundTile1 = try #require(grid[0, 0])
        let foundTile2 = try #require(grid[0, 1])
        #expect(foundTile1.value == 8)
        #expect(foundTile1.absorbed == nil)
        #expect(foundTile2.value == 16)
    }

    @Test("assess: if any tile's column and row are wrong, reports a Move, fixes the tile")
    func assessMove() throws {
        let grid = Grid()
        let tile1 = Tile(value: 8, column: 0, row: 1)
        grid[0, 0] = tile1
        let subject = GridLogic(grid: grid)
        let result = subject.assess()
        let move = try #require(result.moves.first)
        #expect(move.tile == tile1.id)
        #expect(move.slot == Slot(column: 0, row: 0))
    }

    @Test("assess: if any tile has an absorbed tile, reports a Merge, nilifies the absorbed")
    func assessMerge() throws {
        let grid = Grid()
        let tile1 = Tile(value: 16, column: 0, row: 0)
        grid[0, 0] = tile1
        let tile2 = Tile(value: 8, column: 0, row: 1)
        tile1.absorbed = tile2
        let subject = GridLogic(grid: grid)
        let result = subject.assess()
        let merge = try #require(result.merges.first)
        #expect(merge.absorbedTile == tile2.id)
        #expect(merge.newValue == 16)
        #expect(merge.tile == tile1.id)
        #expect(tile1.absorbed == nil)
    }
}
