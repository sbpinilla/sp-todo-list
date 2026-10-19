import AppKit
import SwiftUI
import TodoApplication
import TodoInfrastructure
import TodoUI

/// Single composition root: builds repository, view model, hosting view and floating panel.
@MainActor
final class CompositionRoot {
    private let viewModel: TodoListViewModel
    private let panelController: PanelController

    init() {
        let repository = JSONTodoRepository(directory: JSONTodoRepository.defaultDirectory)
        viewModel = TodoListViewModel(repository: repository)
        // Load before building the view so a relaunch restores items in the first layout.
        viewModel.load()
        let hosting = NSHostingView(rootView: TodoListContainer(viewModel: viewModel))
        panelController = PanelController(contentView: hosting)
    }

    func start() {
        panelController.show()
    }

    func stop() {
        panelController.tearDown()
    }
}
