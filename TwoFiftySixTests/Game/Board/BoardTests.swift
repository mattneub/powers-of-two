@testable import TwoFiftySix
import UIKit
import Testing
import SnapshotTesting

@MainActor
struct BoardTests {
    let subject = Board(frame: .zero)

    @Test("board looks okay")
    func boardAppearance() {
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        assertSnapshot(of: subject, as: .image)
    }

    @Test("layout calculations are correct")
    func boardCalculations() {
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        viewController.view.layoutIfNeeded()
        #expect(subject.currentBounds == CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        #expect(subject.tileWidth == 75)
        #expect(subject.tileHeight == 75)
    }

    @Test("rectForTileView gives expected result")
    func rectForTileView() { // actually, we already tested this via `boardAppearance`
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        viewController.view.layoutIfNeeded()
        let result = subject.rectForTileView(at: Slot(column: 3, row: 3))
        #expect(result == CGRect(origin: .init(x: 305, y: 305), size: .init(width: 75, height: 75)))
    }

    @Test("tileView(for:) retrieves tile view with given id")
    func tileViewForId() {
        var tileViews = [TileView]()
        for value in 1...3 {
            let id = UUID()
            let tileView = TileView(frame: .zero, id: id, value: value)
            tileViews.append(tileView)
            subject.tiles[id] = tileView
        }
        let result = subject.tileView(id: tileViews[1].id)
        #expect(result == tileViews[1])
    }

    @Test("receive add: adds given tiles to interface with correct frame, and to tile views dictionary")
    func add() async {
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        viewController.view.layoutIfNeeded()
        var tiles = [Tile]()
        for value in 1...3 {
            let tileView = Tile(value: value, column: value, row: value)
            tiles.append(tileView)
        }
        await subject.add(tiles.map(TileReducer.init(tile:)))
        #expect(subject.tiles.count == 3)
        #expect(subject.subviews(ofType: TileView.self).count == 3)
        let ids = tiles.map(\.id)
        do {
            let tile = subject.tiles[ids[0]]!
            #expect(tile.value == 1)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 115, y: 115, width: 75, height: 75))
            #expect(tile.id == ids[0])
        }
        do {
            let tile = subject.tiles[ids[1]]!
            #expect(tile.value == 2)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 210, y: 210, width: 75, height: 75))
            #expect(tile.id == ids[1])
        }
        do {
            let tile = subject.tiles[ids[2]]!
            #expect(tile.value == 3)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 305, y: 305, width: 75, height: 75))
            #expect(tile.id == ids[2])
        }
    }

    @Test("perform: responds to Moves by changing the frame of the given tiles")
    func performMove() async {
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        viewController.view.layoutIfNeeded()
        var tiles = [Tile]()
        for value in 1...3 {
            let tileView = Tile(value: value, column: value, row: value)
            tiles.append(tileView)
        }
        await subject.add(tiles.map(TileReducer.init(tile:)))
        let ids = tiles.map(\.id)
        let moves: [Move] = [
            (tile: ids[1], to: Slot(column: 0, row: 0)),
            (tile: ids[2], to: Slot(column: 0, row: 0)),
        ]
        let assessment = Assessment(moves: moves, merges: [])
        // that was prep, here comes the test
        await subject.perform(assessment: assessment)
        #expect(subject.tiles.count == 3)
        do {
            let tile = subject.tiles[ids[0]]!
            #expect(tile.value == 1)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 115, y: 115, width: 75, height: 75))
            #expect(tile.id == ids[0])
        }
        do {
            let tile = subject.tiles[ids[1]]!
            #expect(tile.value == 2)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 20, y: 20, width: 75, height: 75)) // *
            #expect(tile.id == ids[1])
        }
        do {
            let tile = subject.tiles[ids[2]]!
            #expect(tile.value == 3)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 20, y: 20, width: 75, height: 75)) // *
            #expect(tile.id == ids[2])
        }
    }

    @Test("perform: responds to Merges by setting the value of the absorbing tile and removing the absorbed tile")
    func performMerge() async {
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        viewController.view.layoutIfNeeded()
        var tiles = [Tile]()
        for value in 1...3 {
            let tileView = Tile(value: value, column: value, row: value)
            tiles.append(tileView)
        }
        await subject.add(tiles.map(TileReducer.init(tile:)))
        let ids = tiles.map(\.id)
        let merges: [Merge] = [
            (tile: ids[1], absorbedTile: ids[2], newValue: 100),
        ]
        let assessment = Assessment(moves: [], merges: merges)
        // that was prep, here comes the test
        await subject.perform(assessment: assessment)
        #expect(subject.tiles.count == 2)
        do {
            let tile = subject.tiles[ids[0]]!
            #expect(tile.value == 1)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 115, y: 115, width: 75, height: 75))
            #expect(tile.id == ids[0])
        }
        do {
            let tile = subject.tiles[ids[1]]!
            #expect(tile.value == 100)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 210, y: 210, width: 75, height: 75))
            #expect(tile.id == ids[1])
        }
    }

    @Test("perform with both moves and merges does both")
    func performMovesAndMerges() async {
        let subject = Board(frame: CGRect(origin: .zero, size: .init(width: 400, height: 400)))
        let viewController = UIViewController()
        makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        viewController.view.layoutIfNeeded()
        var tiles = [Tile]()
        for value in 1...3 {
            let tileView = Tile(value: value, column: value, row: value)
            tiles.append(tileView)
        }
        await subject.add(tiles.map(TileReducer.init(tile:)))
        let ids = tiles.map(\.id)
        let moves: [Move] = [
            (tile: ids[1], to: Slot(column: 0, row: 0)),
            (tile: ids[2], to: Slot(column: 0, row: 0)),
        ]
        let merges: [Merge] = [
            (tile: ids[0], absorbedTile: ids[2], newValue: 100),
        ]
        let assessment = Assessment(moves: moves, merges: merges)
        // that was prep, here comes the test
        await subject.perform(assessment: assessment)
        #expect(subject.tiles.count == 2)
        do {
            let tile = subject.tiles[ids[0]]!
            #expect(tile.value == 100)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 115, y: 115, width: 75, height: 75))
            #expect(tile.id == ids[0])
        }
        do {
            let tile = subject.tiles[ids[1]]!
            #expect(tile.value == 2)
            #expect(tile.superview == subject)
            #expect(tile.frame == CGRect(x: 20, y: 20, width: 75, height: 75))
            #expect(tile.id == ids[1])
        }
    }

    @Test("empty: removes all tile views and clears the tiles dictionary")
    func empty() async {
        var tiles = [Tile]()
        for value in 1...3 {
            let tileView = Tile(value: value, column: value, row: value)
            tiles.append(tileView)
        }
        await subject.add(tiles.map(TileReducer.init(tile:)))
        #expect(subject.tiles.count == 3)
        #expect(subject.subviews(ofType: TileView.self).count == 3)
        await subject.empty()
        #expect(subject.tiles.count == 0)
        #expect(subject.subviews(ofType: TileView.self).count == 0)
    }
}
