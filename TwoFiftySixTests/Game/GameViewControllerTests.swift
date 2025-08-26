@testable import TwoFiftySix
import UIKit
import Testing
import WaitWhile

@MainActor
struct GameViewControllerTests {
    let subject = GameViewController()
    let processor = MockProcessor<GameAction, GameState, GameEffect>()
    let board = MockBoard()
    let highest = UILabel()

    init() {
        subject.processor = processor
        subject.board = board
        subject.highest = highest
        highest.text = "hello"
    }

    @Test("viewDidLoad: adds swipe gesture recognizers, empties highest label")
    func viewDidLoad() throws {
        let recognizers = try #require(subject.view.gestureRecognizers)
        #expect(recognizers.count == 4)
        #expect(recognizers.allSatisfy { $0 is UISwipeGestureRecognizer })
        let directions = recognizers.map { ($0 as! UISwipeGestureRecognizer).direction }
        #expect(directions.contains(.up))
        #expect(directions.contains(.down))
        #expect(directions.contains(.left))
        #expect(directions.contains(.right))
        #expect(recognizers.allSatisfy { ($0 as! MySwipeGestureRecognizer).target === subject })
        #expect(recognizers.allSatisfy { ($0 as! MySwipeGestureRecognizer).action == #selector(subject.swipe) })
        #expect(highest.text == " ")
    }

    @Test("layoutSubviews: sends processor initialInterface first time only")
    func layoutSubviews() async throws {
        subject.view.layoutIfNeeded()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialInterface])
        subject.view.setNeedsLayout()
        subject.view.layoutIfNeeded()
        try await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived == [.initialInterface])
    }

    @Test("present: sets highest label to empty or highest value, cutting above 4")
    func present() async {
        var state = GameState(highestValue: 4)
        await subject.present(state)
        #expect(highest.text == " ")
        state.highestValue = 5
        await subject.present(state)
        #expect(highest.text == "5")
    }

    @Test("receive: passes effect on to board")
    func receive() async {
        await subject.receive(.empty)
        #expect(board.thingsReceived == [.empty])
        await subject.receive(.perform(assessment: Assessment(moves: [], merges: [])))
        #expect(board.thingsReceived == [.empty, .perform(assessment: Assessment(moves: [], merges: []))])
        let tile = Tile(value: 1, column: 2, row: 3)
        let tileReducer = TileReducer(tile: tile)
        await subject.receive(.add([tileReducer]))
        #expect(board.thingsReceived == [.empty, .perform(assessment: Assessment(moves: [], merges: [])), .add([tileReducer])])
    }

    @Test("swipe: calls userMoved with the given direction")
    func swipe() async {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.direction = .right
        subject.swipe(recognizer)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .userMoved(direction: .right))
    }

    @Test("doNew: calls newGame")
    func doNew() async {
        subject.doNew(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .newGame)
    }

    @Test("doStats: calls stats")
    func doStats() async {
        subject.doStats(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .stats)
    }
}

final class MockBoard: UIView, Receiver {
    var thingsReceived = [GameEffect]()
    func receive(_ effect: GameEffect) {
        thingsReceived.append(effect)
    }
}
