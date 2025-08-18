@MainActor
final class GameProcessor: Processor {
    
    /// Reference to our chief presenter. Set by the coordinator on module creation.
    weak var presenter: (any ReceiverPresenter<GameEffect, GameState>)?
    
    /// Reference to the coordinator. Set by the coordinator on module creation.
    weak var coordinator: (any RootCoordinatorType)?
    
    /// State to be passed to the presenter for reflection in the interface.
    var state = GameState()

    /// The Grid, where the game model is stored and move logic is enacted upon that model.
    let grid: (any GridType) = Grid()

    func receive(_ action: GameAction) async {
        switch action {
        case .initialInterface:
            if let tile1 = grid.insertRandomTile(), let tile2 = grid.insertRandomTile() {
                await presenter?.receive(.add([tile1, tile2]))
            }
        case .newGame:
            grid.empty()
            await presenter?.receive(.empty)
            if let tile1 = grid.insertRandomTile(), let tile2 = grid.insertRandomTile() {
                await presenter?.receive(.add([tile1, tile2]))
            }
        case .userMoved(let direction):
            let assessment = grid.userMoved(direction: direction.gridDirection)
            await presenter?.receive(.perform(assessment: assessment))
            if !assessment.moves.isEmpty || !assessment.merges.isEmpty {
                if let tile = grid.insertRandomTile() {
                    await presenter?.receive(.add([tile]))
                }
            }
        }
    }
}
