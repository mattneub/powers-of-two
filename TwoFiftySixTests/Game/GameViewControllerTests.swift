@testable import TwoFiftySix
import UIKit
import Testing
import WaitWhile

struct GameViewControllerTests {
    let subject = GameViewController()
    let processor = MockProcessor<GameAction, GameState, GameEffect>()
    let board = MockBoard()
    let highest = UILabel()
    let serializer = MockSerializer<UISwipeGestureRecognizer.Direction>()

    init() {
        subject.processor = processor
        subject.board = board
        subject.highest = highest
        subject.serializer = serializer
        highest.text = "hello"
    }

    @Test("viewDidLoad: adds toolbar items, makes swipe gesture recognizers, empties highest label")
    func viewDidLoad() throws {
        subject.loadViewIfNeeded()
        let items = try #require(subject.toolbarItems)
        #expect(items.count == 3)
        #expect(items[0].title == "New Game")
        #expect(items[0].image == nil)
        #expect(items[0].target === subject)
        #expect(items[0].action == #selector(subject.doNew))
        // items 1 is flexible space, no test (could do it by subclassing)
        #expect(items[2].title == nil)
        #expect(items[2].image == UIImage(systemName: "questionmark.circle"))
        #expect(items[2].target === subject)
        #expect(items[2].action == #selector(subject.doHelp))
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

    @Test("viewDidLoad: configures the serializer")
    func viewDidLoadSerializer() async throws {
        subject.loadViewIfNeeded()
        await #while(await serializer.methodsCalled.isEmpty)
        #expect(await serializer.methodsCalled.first == "startStream(_:)")
        try? await serializer.handler?(.left)
        #expect(processor.thingsReceived.first == .userMoved(direction: .left))
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

    @Test("receive: noStats puts up alert")
    func receiveNoStats() async throws {
        makeWindow(viewController: subject)
        await subject.receive(.noStats)
        await #while(subject.presentedViewController == nil)
        let alert = try #require(subject.presentedViewController as? UIAlertController)
        #expect(alert.title == "No high scores yet.")
        #expect(alert.actions.count == 1)
        #expect(alert.actions.first?.title == "OK")
        #expect(alert.preferredStyle == .actionSheet)
        let popover = try #require(alert.popoverPresentationController)
        #expect(popover.sourceItem as? UIButton === subject.statsButton)
    }

    @Test("receive: otherwise passes effect on to board")
    func receiveOther() async {
        await subject.receive(.empty)
        #expect(board.thingsReceived == [.empty])
        await subject.receive(.perform(assessment: Assessment(moves: [], merges: [])))
        #expect(board.thingsReceived == [.empty, .perform(assessment: Assessment(moves: [], merges: []))])
        let tile = Tile(value: 1, column: 2, row: 3)
        let tileReducer = TileReducer(tile: tile)
        await subject.receive(.add([tileReducer]))
        #expect(board.thingsReceived == [.empty, .perform(assessment: Assessment(moves: [], merges: [])), .add([tileReducer])])
    }

    @Test("swipe: sends the swipe direction to the serializer's `vend`")
    func swipe() async throws {
        let recognizer = UISwipeGestureRecognizer()
        recognizer.direction = .right
        subject.swipe(recognizer)
        await #while(await serializer.value == nil)
        #expect(await serializer.methodsCalled.first == "vend(_:)")
        #expect(await serializer.value == .right)
    }

    @Test("doNew: calls newGame")
    func doNew() async throws {
        subject.doNew(self)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .newGame)
    }

    @Test("doStats: calls stats")
    func doStats() async throws {
        let sender = UIButton()
        subject.doStats(sender)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .stats(source: sender))
    }

    @Test("doHelp: calls help")
    func doHelp() async throws {
        let sender = UIBarButtonItem()
        subject.doHelp(sender)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .help(source: sender))
    }
}

final class MockBoard: UIView, Receiver {
    var thingsReceived = [GameEffect]()
    func receive(_ effect: GameEffect) {
        thingsReceived.append(effect)
    }
}
