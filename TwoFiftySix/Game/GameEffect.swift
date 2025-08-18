enum GameEffect {
    case add([TileReducer])
    case empty
    case perform(assessment: Assessment)
}
