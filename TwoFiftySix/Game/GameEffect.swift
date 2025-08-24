/// Effects sent by the GameProcessor to its presenter.
enum GameEffect: Equatable {
    case add([TileReducer])
    case empty
    case perform(assessment: Assessment)
}
