/// Processor that manages the overall game logic and app behavior.
@MainActor
final class GameProcessor: Processor {
    
    /// Reference to our chief presenter. Set by the coordinator on module creation.
    weak var presenter: (any ReceiverPresenter<GameEffect, GameState>)?
    
    /// Reference to the coordinator. Set by the coordinator on module creation.
    weak var coordinator: (any RootCoordinatorType)?
    
    /// State to be passed to the presenter for reflection in the interface.
    var state = GameState()

    /// The Grid, where the game model is stored and move logic is enacted upon that model.
    var grid: (any GridType) = Grid()

    func receive(_ action: GameAction) async {
        switch action {
        case .enteringBackground:
            services.persistence.save(tiles: grid.tiles)
        case .initialInterface:
            assert(grid.tiles.isEmpty, "grid not empty")
            if let tiles = services.persistence.loadTiles() {
                let newTiles = grid.setup(tiles: tiles)
                await presenter?.receive(.add(newTiles))
            } else if let tile1 = grid.insertRandomTile(), let tile2 = grid.insertRandomTile() {
                await presenter?.receive(.add([tile1, tile2]))
            }
            await presentHighestValue()
        case .help:
            coordinator?.showHelp()
        case .newGame:
            // Only when the user starts a new game, and only when the highest tile value in the
            // grid is larger than 64, we append that value to the saved list of high scores
            // before emptying the grid and starting a new game.
            let highest = grid.highestValue
            if highest > 64 {
                services.persistence.append(highScore: highest)
            }
            // To start a new game, empty the grid and the board and insert two tiles.
            grid.empty()
            await presentHighestValue()
            await presenter?.receive(.empty)
            if let tile1 = grid.insertRandomTile(), let tile2 = grid.insertRandomTile() {
                await presenter?.receive(.add([tile1, tile2]))
            }
        case .stats:
            coordinator?.showStats()
        case .userMoved(let direction):
            let assessment = grid.userMoved(direction: direction.moveDirection)
            // We want the `await` here to be as short as possible, so that the serializer
            // doesn't fall too far behind the user's gestures. So we combine the two
            // aspects of the board animation into a single task group — and we move the
            // presentation of the highest value out of the `await` altogether.
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.presenter?.receive(.perform(assessment: assessment))
                }
                group.addTask {
                    if !assessment.moves.isEmpty || !assessment.merges.isEmpty {
                        if let tile = await self.grid.insertRandomTile() {
                            await self.presenter?.receive(.add([tile]))
                        }
                    }
                }
                for await _ in group {}
            }
            Task {
                await presentHighestValue()
            }
        }
    }

    /// Private function to set the state's `highestValue` property and present it (via the
    /// presenter) to the user.
    fileprivate func presentHighestValue() async {
        state.highestValue = grid.highestValue
        await presenter?.present(state)
    }
}
