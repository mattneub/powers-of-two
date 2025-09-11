@testable import TwoFiftySix
import UIKit
import Testing

struct PersistenceTests {
    let subject = Persistence()
    let userDefaults = MockUserDefaults()

    init() {
        services.userDefaults = userDefaults
    }

    @Test("save(tiles:) encodes tile reducer array and saves under tiles key")
    func saveTiles() throws {
        let tile = Tile(value: 1, column: 2, row: 3)
        let tiles: [TileReducer] = [.init(tile: tile)]
        subject.save(tiles: tiles)
        #expect(userDefaults.methodsCalled == ["set(_:forKey:)"])
        #expect(userDefaults.key == "tiles")
        let data = try #require(userDefaults.objectSet as? Data)
        let result = try JSONDecoder().decode([TileReducer].self, from: data)
        #expect(result == tiles)
    }

    @Test("loadTiles: fetches via tiles key")
    func loadTiles() throws {
        let tile = Tile(value: 1, column: 2, row: 3)
        let tiles: [TileReducer] = [.init(tile: tile)]
        let data = try JSONEncoder().encode(tiles)
        userDefaults.objectToReturn = data
        let result = subject.loadTiles()
        #expect(userDefaults.methodsCalled == ["object(forKey:)"])
        #expect(userDefaults.key == "tiles")
        #expect(result == tiles)
    }

    @Test("append(highScore:) calls array for highScores, set for highScores with appended score")
    func appendHighScore() {
        userDefaults.arrayToReturn = nil
        subject.append(highScore: 1)
        #expect(userDefaults.methodsCalled == ["array(forKey:)", "set(_:forKey:)"])
        #expect(userDefaults.key == "highScores") // not a very good test
        #expect(userDefaults.objectSet as? [Int] == [1])
        //
        userDefaults.arrayToReturn = [1, 2]
        userDefaults.methodsCalled = []
        subject.append(highScore: 3)
        #expect(userDefaults.methodsCalled == ["array(forKey:)", "set(_:forKey:)"])
        #expect(userDefaults.key == "highScores") // not a very good test
        #expect(userDefaults.objectSet as? [Int] == [1, 2, 3])
    }

    @Test("loadHighScores: calls array for high scores")
    func loadHighScores() {
        userDefaults.arrayToReturn = nil
        var result = subject.loadHighScores()
        #expect(userDefaults.methodsCalled == ["array(forKey:)"])
        #expect(userDefaults.key == "highScores")
        #expect(result == nil)
        //
        userDefaults.arrayToReturn = [1, 2]
        result = subject.loadHighScores()
        #expect(userDefaults.methodsCalled == ["array(forKey:)", "array(forKey:)"])
        #expect(userDefaults.key == "highScores")
        #expect(result == [1, 2])
    }
}
