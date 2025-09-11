import Testing

func waitWhile(_ seconds: Double = 5, condition: () async throws -> Bool) async throws {
    enum TimeOutError: Error {
        case timedOut
    }
    var timer: Task<Void, Error>?
    var timedOut = false
    timer = Task {
        try await Task.sleep(for: .seconds(seconds))
        timedOut = true
    }
    while try await condition() {
        try await Task.sleep(for: .seconds(0.01))
        await Task.yield()
        if timedOut {
            throw TimeOutError.timedOut
        }
    }
    timer?.cancel()
}
