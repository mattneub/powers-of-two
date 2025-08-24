@testable import TwoFiftySix

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var tilesToSave = [TileReducer]()
    var tilesToReturn: [TileReducer]?

    func save(tiles: [TileReducer]) {
        methodsCalled.append(#function)
        self.tilesToSave = tiles
    }
    
    func loadTiles() -> [TileReducer]? {
        methodsCalled.append(#function)
        return tilesToReturn
    }
    
    
}
