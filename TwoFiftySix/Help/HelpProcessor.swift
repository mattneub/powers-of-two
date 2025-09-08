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
        case .initialInterface:
            guard let contentURL = services.bundle.url(forResource: "help", withExtension: "html") else {
                return
            }
            state.contentURL = contentURL
            await presenter?.present(state)
        }
    }
}
