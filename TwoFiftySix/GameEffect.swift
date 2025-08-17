enum GameEffect {
    case add([Grid.TileReducer])
    case empty
    case perform(assessment: Grid.Assessment)
}
