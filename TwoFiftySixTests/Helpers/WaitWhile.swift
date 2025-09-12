import Testing

// Introduced this as a way to explore the macro functionality, but now I've updated
// the macro to match, so there is no need for it; it is unused.
func waitWhileNOT(_ seconds: Double = 5, condition: () async -> Bool) async {
    var timedOut = false
    let timer = Task {
        try await Task.sleep(for: .seconds(seconds))
        timedOut = true
    }
    while await condition() {
        try? await Task.sleep(for: .seconds(0.01))
        await Task.yield()
        if timedOut {
            Issue.record("timed out")
            break
        }
    }
    timer.cancel()
}
