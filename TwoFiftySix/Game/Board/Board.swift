import UIKit

/// The board is the background view on which the tile views appear. It draws itself with squares
/// representing the places where the tiles can go.
final class Board: UIView, Receiver {

    /// The width of a tile view, as set by `calculateDimensions`.
    var tileWidth = 0 as CGFloat

    /// The height of a tile view, as set by `calculateDimensions`. This is actually the same
    /// as `tileWidth`, as the tile views are square and the board is square.
    var tileHeight = 0 as CGFloat

    /// The last recorded `bounds` value, from `layoutSubviews`. If this changes, we need to
    /// recalculate tile dimensions and redraw.
    var currentBounds = CGRect.zero

    /// Thickness of the "bars" that appear between the tile view places and round the outside.
    let borderWidth: CGFloat = 20

    /// Dictionary hashed on the UUID of every currently visible tile view. This is so that we
    /// don't have to cycle through all tile views merely to find the right one.
    var tiles = [UUID: TileView]()

    /// Given `currentBounds`, calculate the `tileWidth` and `tileHeight` and redraw.
    func calculateDimensions() {
        let widthWithoutBorders = currentBounds.width - 5 * borderWidth
        let heightWithoutBorders = currentBounds.height - 5 * borderWidth
        tileWidth = widthWithoutBorders / 4
        tileHeight = heightWithoutBorders / 4
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        // Pointless to draw if we have not set the `currentBounds` yet.
        guard currentBounds != .zero else {
            return
        }
        // margins (bars)
        UIColor.systemGray5.setFill()
        UIBezierPath(rect: self.bounds).fill()
        // squares
        UIColor.systemGray6.setFill()
        for x in 0..<4 {
            for y in 0..<4 {
                let rect = rectForTileView(at: Slot(column: x, row: y))
                UIBezierPath(roundedRect: rect, cornerRadius: 16).fill()
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // If the bounds change, record the new value and recalculate dimensions, which in turn
        // triggers a redraw.
        // You'll notice that I don't redraw the _tiles_. This is because I don't expect
        // our bounds to change after the time when any tile views have been added.
        if self.bounds != currentBounds {
            currentBounds = self.bounds
            calculateDimensions()
        }
    }

    /// Given a slot, calculate the frame of a tile view that goes in that slot.
    /// - Parameter slot: The slot.
    /// - Returns: The frame.
    func rectForTileView(at slot: Slot) -> CGRect {
        let origin = CGPoint(
            x: CGFloat(slot.column) * (borderWidth + tileWidth) + borderWidth,
            y: CGFloat(slot.row) * (borderWidth + tileHeight) + borderWidth
        )
        let size = CGSize(
            width: tileWidth,
            height: tileHeight
        )
        return CGRect(origin: origin, size: size)
    }

    /// Given a UUID, return the tile view with that UUID.
    /// - Parameter id: The UUID.
    /// - Returns: The tile view.
    ///
    /// We return an actual tile view, not an Optional. This is because we would rather die
    /// than fail. If we can be given an id for which no tile view is in the `tiles` dictionary,
    /// we've written the program incorrectly.
    func tileView(id: UUID) -> TileView {
        if let tileView = tiles[id] {
            return tileView
        }
        fatalError("failed to find tile view with given id")
    }

    func receive(_ effect: GameEffect) async {
        switch effect {
        case .add(let tiles):
            await add(tiles)
        case .empty:
            await empty()
        case .perform(let assessment):
            await perform(assessment: assessment)
        default: break
        }
    }

    /// Given an array of tiles, create corresponding TileViews with corresponding values
    /// in corresponding slots, recording each one also in the `tiles` dictionary.
    /// - Parameter newTiles: The tiles, described by reducers. In real life there will be
    /// only one except at the start of a game or when restoring a board at launch.
    func add(_ newTiles: [TileReducer]) async {
        var newTileViews = [TileView]()
        for tile in newTiles {
            let frame = rectForTileView(at: tile.slot)
            let tileView = TileView(frame: frame, id: tile.id, value: tile.value)
            tiles[tile.id] = tileView
            tileView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
            addSubview(tileView)
            newTileViews.append(tileView)
        }
        await UIView.animateAsync(withDuration: unlessTesting(0.1), delay: unlessTesting(0.1), options: []) {
            for tileView in newTileViews {
                tileView.transform = .identity
            }
        }
    }

    /// An Assessment is a description of how the tiles of the grid were changed by the user's
    /// move. Enact that description with the tile views.
    /// - Parameter assessment: The Assessment.
    func perform(assessment: Assessment) async {
        var tilesToRemove = [TileView]()
        var tilesToChangeValue = [(TileView, Int)]()
        // Part One: move everything that needs to move.
        await UIView.animateAsync(withDuration: unlessTesting(0.2), delay: 0, options: []) { [self] in
            // To enact a move, animate the change in the tile view's frame origin.
            for move in assessment.moves {
                let tile = tileView(id: move.tile)
                tile.frame.origin = rectForTileView(at: move.slot).origin
            }
            // To enact a merge, animate the change in the absorbed tile view's frame origin.
            // (We send it to the back first, so that it passes behind the merge tile.)
            for merge in assessment.merges {
                let absorbedTile = tileView(id: merge.absorbedTile)
                let tile = tileView(id: merge.tile)
                UIView.performWithoutAnimation {
                    sendSubviewToBack(absorbedTile)
                    tilesToRemove.append(absorbedTile)
                }
                absorbedTile.frame.origin = tile.frame.origin
                tilesToChangeValue.append((tile, merge.newValue))
            }
        }
        // Part Two: remove all absorbed tiles. This is invisible to the user, as the absorbed
        // tile is behind the merge tile.
        for tile in tilesToRemove {
            tile.removeFromSuperview()
            tiles[tile.id] = nil // release the tile view
        }
        // Part Three: Finish enacting merges, by changing the value of the merge tile, with
        // cute pop animation, which is moved off to a task so we don't have to wait for it.
        for (tile, newValue) in tilesToChangeValue {
            tile.value = newValue
        }
        Task {
            await UIView.animateAsync(withDuration: unlessTesting(0.1), delay: 0, options: []) {
                for (tile, _) in tilesToChangeValue {
                    tile.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                }
            }
            await UIView.animateAsync(withDuration: unlessTesting(0.1), delay: 0, options: []) {
                for (tile, _) in tilesToChangeValue {
                    tile.transform = .identity
                }
            }
        }
    }

    /// Clear the board (and the `tiles` list) of all tile views.
    func empty() async {
        for view in self.subviews(ofType: TileView.self) {
            view.removeFromSuperview()
        }
        tiles.removeAll()
    }
}
