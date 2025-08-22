@testable import TwoFiftySix
import Foundation
import Testing

@MainActor
struct GridLogicTests {
    @Test("allTraversals is correct")
    func allTraversals() throws {
        let grid = Grid()
        let subject = GridLogic(grid: grid)
        let result = subject.allTraversals
        do {
            let traversals = try #require(result[.up])
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
            let traversals = try #require(result[.down])
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
            let traversals = try #require(result[.left])
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
            let traversals = try #require(result[.right])
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
        let traversal = subject.allTraversals[.up]![0]
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
        let traversal = subject.allTraversals[.up]![0]
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
        let traversal = subject.allTraversals[.up]![0]
        subject.closeUp(traversal: traversal)
        let unmovedTile1 = try #require(grid[0, 0])
        let unmovedTile2 = try #require(grid[0, 1])
        #expect(unmovedTile1 === tile1)
        #expect(unmovedTile2 === tile2)
    }

}
