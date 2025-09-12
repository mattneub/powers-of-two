import Testing

func waitWhile(_ seconds: Double = 5, condition: () async -> Bool) async {
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
