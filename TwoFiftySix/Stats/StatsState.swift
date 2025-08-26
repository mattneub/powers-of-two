/// State presented from the processor to the presenter.
struct StatsState: Equatable {
    var histogram = [StatsProcessor.HistogramEntry]()
}
