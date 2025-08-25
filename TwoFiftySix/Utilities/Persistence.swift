import Foundation

/// Protocol describing the public face of our Persistence type, so we can mock it for testing.
protocol PersistenceType {
    func save(tiles: [TileReducer])
    func loadTiles() -> [TileReducer]?
    func append(highScore: Int)
    func loadHighScores() -> [Int]?
}

/// Bottleneck service class that communicates with user defaults.
final class Persistence: PersistenceType {

    /// Save the given tile reducers as a representation of our tiles.
    /// - Parameter tiles: The tile reducers to save.
    func save(tiles: [TileReducer]) {
        guard let data = try? JSONEncoder().encode(tiles) else {
            return
        }
        services.userDefaults.set(data, forKey: "tiles")
    }

    /// Return the previously saved tile reducers, or nil if none.
    /// - Returns: The previously saved tile reducers.
    func loadTiles() -> [TileReducer]? {
        guard let data = services.userDefaults.object(forKey: "tiles") as? Data else {
            return nil
        }
        guard let tiles = try? JSONDecoder().decode([TileReducer].self, from: data) else {
            return nil
        }
        return tiles
    }
    
    /// Save the given score as an integer appended to the existing list of scores (or to an
    /// empty list if there is no existing list).
    /// - Parameter highScore: The high score to append.
    func append(highScore: Int) {
        var array = loadHighScores() ?? []
        array.append(highScore)
        services.userDefaults.set(array, forKey: "highScores")
    }
    
    /// Return the previously saved list of high scores, or nil if there is no list.
    /// - Returns: The previously saved high scores list.
    func loadHighScores() -> [Int]? {
        return services.userDefaults.array(forKey: "highScores") as? [Int]
    }
}
