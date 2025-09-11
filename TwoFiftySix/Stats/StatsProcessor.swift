/// Processor containing the logic for the stats module.
final class StatsProcessor: Processor {

    /// Reference to the presenter. Set by the coordinator on module creation.
    weak var presenter: (any ReceiverPresenter<Void, StatsState>)?

    /// Reference to the coordinator. Set by the coordinator on module creation.
    weak var coordinator: (any RootCoordinatorType)?

    /// State to be presented via the presenter.
    var state = StatsState()

    func receive(_ action: StatsAction) async {
        switch action {
        case .done:
            coordinator?.dismiss()
        case .initialInterface:
            state.histogram = scoresHistogram()
            await presenter?.present(state)
        }
    }
    
    /// Transform the high scores as stored in persistence (an array of Int) into a histogram.
    /// - Returns: The resulting histogram, as an array, each element of which is a score and
    /// a count of how many times it appears in the list of scores, in ascending score order.
    fileprivate func scoresHistogram() -> [StatsState.HistogramEntry] {
        let array = services.persistence.loadHighScores() ?? []
        let histogram = array.reduce(into: [Int: Int]()) { partial, element in
            partial[element] = partial[element, default: 0] + 1
        }.sorted { $0.key < $1.key }
        return histogram.map { .init(score: $0.key, count: $0.value) }
    }

}
