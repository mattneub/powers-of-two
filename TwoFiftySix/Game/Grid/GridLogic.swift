/// Public face of the `GridLogic` object.
protocol GridLogicType {
    var allTraversals: [MoveDirection: [[Slot]]] { get }
    func closeUp(traversal: [Slot], direction: MoveDirection)
    func merge(traversal: [Slot])
    func assess() -> Assessment
}

/// Struct embodying the heart of the game logic for the grid. It moves and merges the tiles
/// of the grid in response to a user's move, and reports an Assessment describing what
/// was done so that the visible game board's tile views can reflect this.
/// A single instance exists, as the servant of the Grid; the code is factored out of the Grid
/// to make the code more testable.
struct GridLogic: GridLogicType {
    unowned let grid: Grid

    /// A _traversal_ is a linear sequence of four slots, either all the slots of a row or
    /// all the slots of a column, in one direction or the other. It represents the steps
    /// by which we examine the contents of the row-or-column to see what needs to be done
    /// in consequence of the user's move. The direction of the sequence is thus the _opposite_
    /// of the direction of the user's move, i.e. it is the opposite of the direction of the
    /// "gravity" applied to the tiles: we start by looking at the furthest extreme in the
    /// direction the user swiped, and then look at the slot before that, and so on.
    /// There are four traversals for each of the four possible moves the user can make,
    /// and they are unchanging, so it is silly to calculate them all every time the user moves;
    /// therefore we calculate them just once at the start of the game and retain them in
    /// this dictionary, keyed by direction.
    let allTraversals: [MoveDirection: [[Slot]]]

    init(grid: Grid) {
        self.grid = grid
        // Calculate by rule the four traversals for one direction.
        func traversals(forMoveDirection direction: MoveDirection) -> [[Slot]] {
            var starts = [Slot]()
            switch direction {
            case .up:
                for column in 0..<4 {
                    starts.append(Slot(column: column, row: 0))
                }
            case .right:
                for row in 0..<4 {
                    starts.append(Slot(column: 3, row: row))
                }
            case .down:
                for column in 0..<4 {
                    starts.append(Slot(column: column, row: 3))
                }
            case .left:
                for row in 0..<4 {
                    starts.append(Slot(column: 0, row: row))
                }
            }
            var result = starts.map { [$0] }
            for index in 0..<4 {
                for _ in 0..<3 {
                    guard let prev = result[index].last else {
                        continue // won't happen
                    }
                    result[index].append(prev - direction.vector)
                }
            }
            return result
        }
        // Set `allTraversals` to a dictionary of the four traversals for _all four_ directions.
        self.allTraversals = MoveDirection.allCases.reduce(into: [MoveDirection: [[Slot]]]()) {
            result, direction in
            result[direction] = traversals(forMoveDirection: direction)
        }
    }

    /// As we walk a traversal to apply gravity, if we encounter a tile, we must move it
    /// _as far as possible_ in the gravity direction (the direction of the user's move). Well,
    /// what slot exactly is "as far as possible"? It is the furthest empty slot, starting at
    /// the slot where we encountered the tile, in the direction of user's move. This works
    /// because if we encounter a tile, any tiles that precede it in the direction of the user's
    /// move have already been encountered and moved.
    /// - Parameters:
    ///   - traversal: An array of four slots.
    ///   - slot: The slot (in the `traversal`) where we encountered the tile we are considering
    ///    moving.
    ///   - direction: The direction of the user's move.
    /// - Returns: The slot to which to move the tile, or `nil` if no empty slot was found in the
    /// given direction, in which case there is nothing to do — the tile is already as far as
    /// possible in that direction.
    func furthestEmpty(in traversal: [Slot], from slot: Slot, direction: MoveDirection) -> Slot? {
        guard traversal.contains(slot) else {
            return nil // shouldn't happen
        }
        var result: Slot? = nil
        var current = slot + direction.vector
        while traversal.contains(current) {
            if grid[current] == nil {
                result = current
            }
            current = current + direction.vector
        }
        return result
    }

    /// Enact "gravity" in the given direction upon all the tiles found within the given
    /// traversal.
    /// - Parameters:
    ///   - traversal: The traversal.
    ///   - direction: The direction of the user's move.
    func closeUp(traversal: [Slot], direction: MoveDirection) {
        for slot in traversal {
            if let tile = grid[slot] {
                if let empty = furthestEmpty(in: traversal, from: slot, direction: direction) {
                    grid[empty] = tile
                    grid[slot] = nil
                }
            }
        }
    }

    /// After `closeUp(traversal:direction:)` is initially applied to a traversal, if any tiles
    /// with the same value are now adjacent, they must be merged. Do that! We are saved from
    /// having to think about what the concept of examining all the adjacent pairs by
    /// the existence in the Swift Algorithms of `windows(ofCount:)`.
    /// - Parameter traversal: The traversal.
    func merge(traversal: [Slot]) {
        for pair in traversal.windows(ofCount: 2) {
            let pair = Array(pair) // important, because otherwise we don't know the indices!
            if let tile1 = grid[pair[0]], let tile2 = grid[pair[1]], tile1.value == tile2.value {
                tile1.absorb(tile: tile2)
                grid[pair[1]] = nil
            }
        }
    }

    /// This is the Really Tricky Part. After a call to `userMoved(direction:)`, the grid may
    /// have changed. We need to enact those same changes in the visible interface. In order to
    /// do so, we need to know what those changes are! This method returns an Assessment, which is
    /// simply a description of the changes that took place. I suppose we could have tracked the
    /// changes as we performed them, but we didn't. So how do we know what they were? This is why
    /// a Tile has `column` and `row` properties and an `absorbed` property. If a tile's `column`
    /// and/or `row` do not match the slot where it is now, it was moved from
    /// the `column` and `row` of its properties; so report the movement, and rectify
    /// its `column` and `row`. If a tile has
    /// an `absorbed` tile, that tile was merged into this one; so report that, and nilify its
    /// `absorbed` property.
    /// - Returns: A description of what happened in consequence of the user's move, entirely in
    /// terms of tile UUIDs, slots, and values. In other words, we _reduce_ the information about
    /// the move so that no actual tile escapes from the grid.
    func assess() -> Assessment {
        var movedTiles = [Move]()
        var mergedTiles = [Merge]()
        for column in 0..<4 {
            for row in 0..<4 {
                if let tile = grid[column, row] {
                    if tile.column != column || tile.row != row {
                        movedTiles.append((
                            tile: tile.id,
                            to: Slot(column: column, row: row)
                        ))
                        (tile.column, tile.row) = (column, row)
                    }
                    if let absorbed = tile.absorbed {
                        mergedTiles.append((
                            tile: tile.id,
                            absorbedTile: absorbed.id,
                            newValue: tile.value
                        ))
                        tile.absorbed = nil
                    }
                }
            }
        }
        return (moves: movedTiles, merges: mergedTiles)
    }
}
