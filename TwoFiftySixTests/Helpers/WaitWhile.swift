import Testing

func waitWhile(_ condition: () async throws -> Bool) async throws {
    while try await condition() {
        try? await Task.sleep(for: .seconds(0.01))
        await Task.yield()
    }
}
