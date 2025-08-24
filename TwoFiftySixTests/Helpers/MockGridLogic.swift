@testable import TwoFiftySix

final class MockGridLogic: GridLogicType {
    var methodsCalled = [String]()
    var _allTraversals = [MoveDirection: [Traversal]]()
    var traversals = [Traversal]()
    var assessment = Assessment(moves: [], merges: [])

    func traversals(_ direction: MoveDirection) -> [Traversal] {
        return _allTraversals[direction, default: []]
    }

    func closeUp(traversal: Traversal) {
        methodsCalled.append(#function)
        self.traversals.append(traversal)
    }
    
    func merge(traversal: Traversal) {
        methodsCalled.append(#function)
        self.traversals.append(traversal)
    }
    
    func assess() -> Assessment {
        methodsCalled.append(#function)
        return assessment
    }
}
