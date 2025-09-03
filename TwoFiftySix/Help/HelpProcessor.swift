/// Processor containing the logic for the help module.
@MainActor
final class HelpProcessor: Processor {
    
    /// Reference to the presenter. Set by the coordinator on module creation.
    weak var presenter: (any ReceiverPresenter<Void, HelpState>)?
    
    /// Reference to the coordinator. Set by the coordinator on module creation.
    weak var coordinator: (any RootCoordinatorType)?
    
    /// State to be presented via the presenter.
    var state = HelpState()
    
    func receive(_ action: HelpAction) async {
        switch action {
        case .done:
            coordinator?.dismiss()
        }
    }
}
