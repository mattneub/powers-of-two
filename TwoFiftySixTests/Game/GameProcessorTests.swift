@testable import TwoFiftySix
import Foundation
import Testing

@MainActor
struct GameProcessorTests {
    let subject = GameProcessor()
    let presenter = MockReceiverPresenter<GameEffect, GameState>()
    let coordinator = MockRootCoordinator()
    let persistence = MockPersistence()
    let grid = MockGrid()

    init() {
        subject.presenter = presenter
        subject.coordinator = coordinator
        subject.grid = grid
        services.persistence = persistence
    }

    @Test("receive enteringBackground: calls persistence save tiles")
    func enteringBackground() async {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        grid.tiles = [reducer]
        await subject.receive(.enteringBackground)
        #expect(persistence.methodsCalled == ["save(tiles:)"])
        #expect(persistence.tilesToSave == [reducer])
    }

    @Test("receive initialInterface: if persistence loadTiles returns array, calls grid setup, feeds returned value to presenter add")
    func initialInterfacePersistence() async {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        persistence.tilesToReturn = [reducer]
        let reducer2 = TileReducer(tile: Tile(value: 2, column: 3, row: 4))
        grid.tilesToReturn = [reducer2]
        await subject.receive(.initialInterface)
        #expect(grid.methodsCalled == ["setup(tiles:)"])
        #expect(presenter.thingsReceived == [.add([reducer2])])
    }

    @Test("receive initialInterface: if persistence return nil, calls insertRandomTile twice, sends results to presenter add")
    func initialInterfaceNoPersistence() async {
        persistence.tilesToReturn = nil
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        let reducer2 = TileReducer(tile: Tile(value: 2, column: 3, row: 4))
        grid.tilesToReturn = [reducer2, reducer] // mock grid will reverse this
        await subject.receive(.initialInterface)
        #expect(grid.methodsCalled == ["insertRandomTile()", "insertRandomTile()"])
        #expect(presenter.thingsReceived == [.add([reducer, reducer2])])
    }

    @Test("receive newGame: calls grid and presenter empty, calls insertRandomTile twice, sends results to presenter add")
    func newGame() async {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        let reducer2 = TileReducer(tile: Tile(value: 2, column: 3, row: 4))
        grid.tilesToReturn = [reducer2, reducer] // mock grid will reverse this
        await subject.receive(.newGame)
        #expect(grid.methodsCalled == ["empty()", "insertRandomTile()", "insertRandomTile()"])
        #expect(presenter.thingsReceived == [.empty, .add([reducer, reducer2])])
    }

    @Test("receive userMoved(direction:): calls grid userMoved with direction, passes assessment to presenter perform")
    func userMoved() async {
        let assessment = Assessment(
            moves: [.init(tile: UUID(), slot: .init(column: 1, row: 2))],
            merges: [.init(tile: UUID(), absorbedTile: UUID(), newValue: 100)]
        )
        grid.assessment = assessment
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled.first == "userMoved(direction:)")
        #expect(grid.direction == .up)
        #expect(presenter.thingsReceived.first == .perform(assessment: assessment))
    }

    @Test("received userMoved(direction:): if assessment is empty, stops")
    func userMovedEmptyAssessment() async {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        grid.tilesToReturn = [reducer]
        let assessment = Assessment(
            moves: [],
            merges: []
        )
        grid.assessment = assessment
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled == ["userMoved(direction:)"])
        #expect(presenter.thingsReceived == [.perform(assessment: assessment)])
    }

    @Test("receive userMoved(direction:): if assessment not empty, calls grid insertRandomTile() once, if not nil, sends result to presenter add")
    func userMovedPartTwo() async {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        grid.tilesToReturn = [reducer]
        let assessment = Assessment(
            moves: [.init(tile: UUID(), slot: .init(column: 1, row: 2))],
            merges: []
        )
        grid.assessment = assessment
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled == ["userMoved(direction:)", "insertRandomTile()"])
        #expect(presenter.thingsReceived == [.perform(assessment: assessment), .add([reducer])])
    }

    @Test("receive userMoved(direction:): if assessment not empty, calls grid insertRandomTile() once, if nil, stops")
    func userMovedPartTwoNilRandomTile() async {
        grid.tilesToReturn = [] // mock grid will return nil
        let assessment = Assessment(
            moves: [.init(tile: UUID(), slot: .init(column: 1, row: 2))],
            merges: []
        )
        grid.assessment = assessment
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled == ["userMoved(direction:)", "insertRandomTile()"])
        #expect(presenter.thingsReceived == [.perform(assessment: assessment)])
    }
}
