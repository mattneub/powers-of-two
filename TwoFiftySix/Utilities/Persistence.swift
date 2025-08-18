import Foundation

/// Bottleneck service class that communicates with user defaults.
final class Persistence {

    /// Save the given tile reducers as a representation of our tiles.
    /// - Parameter tiles: The tile reducers to save.
    func save(tiles: [TileReducer]) {
        guard let data = try? JSONEncoder().encode(tiles) else {
            return
        }
        UserDefaults.standard.set(data, forKey: "tiles")
    }

    /// Return the previously saved tile reducers, or nil if none.
    /// - Returns: The previously saved tile reducers.
    func loadTiles() -> [TileReducer]? {
        guard let data = UserDefaults.standard.object(forKey: "tiles") as? Data else {
            return nil
        }
        guard let tiles = try? JSONDecoder().decode([TileReducer].self, from: data) else {
            return nil
        }
        return tiles
    }
}
