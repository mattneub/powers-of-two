@testable import TwoFiftySix

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var tilesToSave = [TileReducer]()
    var tilesToReturn: [TileReducer]?
    var scoreToAppend: Int?
    var scoresToReturn: [Int]?

    func save(tiles: [TileReducer]) {
        methodsCalled.append(#function)
        self.tilesToSave = tiles
    }
    
    func loadTiles() -> [TileReducer]? {
        methodsCalled.append(#function)
        return tilesToReturn
    }
    
    func append(highScore: Int) {
        methodsCalled.append(#function)
        self.scoreToAppend = highScore
    }

    func loadHighScores() -> [Int]? {
        methodsCalled.append(#function)
        return scoresToReturn
    }

}
