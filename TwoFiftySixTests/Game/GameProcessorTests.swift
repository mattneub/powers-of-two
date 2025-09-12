@testable import TwoFiftySix
import Foundation
import Testing

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
        grid.highestValue = 200
        await subject.receive(.initialInterface)
        #expect(grid.methodsCalled == ["setup(tiles:)"])
        #expect(presenter.thingsReceived == [.add([reducer2])])
        #expect(presenter.statesPresented.last?.highestValue == 200)
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

    @Test("receive newGame: if grid highest value is under 64, no calls to persistence")
    func newGameHighestValueLow() async {
        grid.highestValue = 2
        await subject.receive(.newGame)
        #expect(persistence.methodsCalled.isEmpty)
    }

    @Test("receive newGame: if grid highest value is over 64, saves it to persistence")
    func newGameHighestValueHigh() async {
        grid.highestValue = 65
        await subject.receive(.newGame)
        #expect(persistence.methodsCalled == ["append(highScore:)"])
        #expect(persistence.scoreToAppend == 65)
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

    @Test("receive stats: calls coordinator showStats")
    func stats() async {
        await subject.receive(.stats)
        #expect(coordinator.methodsCalled == ["showStats()"])
    }

    @Test("receive help: calls coordinator showHelp")
    func help() async {
        await subject.receive(.help)
        #expect(coordinator.methodsCalled == ["showHelp()"])
    }

    @Test("receive userMoved(direction:): calls grid userMoved with direction, passes assessment to presenter perform")
    func userMoved() async throws {
        let assessment = Assessment(
            moves: [.init(tile: UUID(), slot: .init(column: 1, row: 2))],
            merges: [.init(tile: UUID(), absorbedTile: UUID(), newValue: 100)]
        )
        grid.assessment = assessment
        grid.highestValue = 200
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled.first == "userMoved(direction:)")
        #expect(grid.direction == .up)
        #expect(presenter.thingsReceived.first == .perform(assessment: assessment))
        await waitWhile { presenter.statesPresented.isEmpty }
        #expect(presenter.statesPresented.first?.highestValue == 200)
    }

    @Test("received userMoved(direction:): if assessment is empty, stops")
    func userMovedEmptyAssessment() async throws {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        grid.tilesToReturn = [reducer]
        let assessment = Assessment(
            moves: [],
            merges: []
        )
        grid.assessment = assessment
        grid.highestValue = 200
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled == ["userMoved(direction:)"])
        #expect(presenter.thingsReceived == [.perform(assessment: assessment)])
        await waitWhile { presenter.statesPresented.isEmpty }
        #expect(presenter.statesPresented.first?.highestValue == 200)
    }

    @Test("receive userMoved(direction:): if assessment not empty, calls grid insertRandomTile() once, if not nil, sends result to presenter add")
    func userMovedPartTwo() async throws {
        let reducer = TileReducer(tile: Tile(value: 1, column: 2, row: 3))
        grid.tilesToReturn = [reducer]
        let assessment = Assessment(
            moves: [.init(tile: UUID(), slot: .init(column: 1, row: 2))],
            merges: []
        )
        grid.assessment = assessment
        grid.highestValue = 200
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled == ["userMoved(direction:)", "insertRandomTile()"])
        #expect(presenter.thingsReceived == [.perform(assessment: assessment), .add([reducer])])
        await waitWhile { presenter.statesPresented.isEmpty }
        #expect(presenter.statesPresented.first?.highestValue == 200)
    }

    @Test("receive userMoved(direction:): if assessment not empty, calls grid insertRandomTile() once, if nil, stops")
    func userMovedPartTwoNilRandomTile() async throws {
        grid.tilesToReturn = [] // mock grid will return nil
        let assessment = Assessment(
            moves: [.init(tile: UUID(), slot: .init(column: 1, row: 2))],
            merges: []
        )
        grid.assessment = assessment
        grid.highestValue = 200
        await subject.receive(.userMoved(direction: .up))
        #expect(grid.methodsCalled == ["userMoved(direction:)", "insertRandomTile()"])
        #expect(presenter.thingsReceived == [.perform(assessment: assessment)])
        await waitWhile { presenter.statesPresented.isEmpty }
        #expect(presenter.statesPresented.first?.highestValue == 200)
    }
}
