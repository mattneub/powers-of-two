/// A _traversal_ is the element of thought, as it were, of the GridLogic object.
/// It comprises a linear sequence of four slots, either all the slots of a row or
/// all the slots of a column, in one direction or the other. This sequence represents the steps
/// by which the GridLogic examines the contents of the row-or-column to see what needs to be done
/// in consequence of the user's move. The direction of the sequence is thus the _opposite_
/// of the direction of the user's move, i.e. it is the opposite of the direction of the
/// "gravity" applied to the tiles: we start by looking at the furthest extreme in the
/// direction the user swiped, and then look at the slot before that, and so on.
struct Traversal: Equatable {
    /// The array of slots represented by the traversal.
    let array: [Slot]

    /// The direction of the user's move for this traversal; the slots of the `array`
    /// are in the _opposite_ order.
    let direction: MoveDirection

    /// Forbid the default initializer.
    private init(array: [Slot], direction: MoveDirection) {
        fatalError("no entry")
    }
}

