/// State presented from the processor to the presenter.
struct StatsState: Equatable {
    var histogram = [Self.HistogramEntry]()

    /// A single entry in the histogram of past scores. One such entry corresponds to one
    /// HistogramEntry view.
    struct HistogramEntry: Equatable {
        let score: Int
        let count: Int
    }

}
