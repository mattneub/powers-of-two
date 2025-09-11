@testable import TwoFiftySix

final class MockGrid: GridType, @unchecked Sendable {
    var methodsCalled = [String]()
    var tiles: [TileReducer] = [TileReducer]()
    var highestValue = 2
    var tilesToReturn = [TileReducer]()
    var assessment = Assessment(moves: [], merges: [])
    var direction: MoveDirection?

    func empty() {
        methodsCalled.append(#function)
    }
    
    func insertRandomTile() -> TileReducer? {
        methodsCalled.append(#function)
        return tilesToReturn.popLast()
    }
    
    func setup(tiles: [TileReducer]) -> [TileReducer] {
        methodsCalled.append(#function)
        self.tiles = tiles
        return tilesToReturn
    }
    
    func userMoved(direction: MoveDirection) -> Assessment {
        methodsCalled.append(#function)
        self.direction = direction
        return assessment
    }
    
}
