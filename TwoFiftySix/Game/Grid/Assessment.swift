import Foundation

/// Value types used to communicate assessment info back from the Grid to the caller without
/// exposing any Tile objects.
struct Move: Equatable {
    let tile: UUID
    let slot: Slot
}
struct Merge: Equatable {
    let tile: UUID
    let absorbedTile: UUID
    let newValue: Int
}
struct Assessment: Equatable {
    let moves: [Move]
    let merges: [Merge]
}
