@testable import TwoFiftySix
import UIKit
import Testing

@MainActor
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
}
