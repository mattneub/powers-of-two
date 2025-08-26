/// Processor containing the logic for the stats module.
@MainActor
final class StatsProcessor: Processor {

    /// Reference to the presenter. Set by the coordinator on module creation.
    weak var presenter: (any ReceiverPresenter<Void, StatsState>)?

    /// Reference to the coordinator. Set by the coordinator on module creation.
    weak var coordinator: (any RootCoordinatorType)?

    var state = StatsState()

    func receive(_ action: StatsAction) async {
        switch action {
        case .initialInterface:
            state.histogram = scoresHistogram()
            await presenter?.present(state)
        }
    }

    fileprivate func scoresHistogram() -> [HistogramEntry] {
        let array = services.persistence.loadHighScores() ?? []
        let histogram = array.reduce(into: [Int: Int]()) { partial, element in
            partial[element] = partial[element, default: 0] + 1
        }.sorted { $0.key < $1.key }
        return histogram.map { HistogramEntry(score: $0.key, count: $0.value) }
    }

    struct HistogramEntry: Equatable {
        let score: Int
        let count: Int
    }
}
