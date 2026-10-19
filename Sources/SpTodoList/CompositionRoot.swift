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
        viewModel = TodoListViewModel(
            repository: repository,
            preferences: UserDefaultsDisplayPreferences()
        )
        // Load before building the view so a relaunch restores items in the first layout.
        viewModel.load()
        let hosting = NSHostingView(rootView: TodoListContainer(viewModel: viewModel))
        let controller = PanelController(contentView: hosting)
        panelController = controller
        // The view reports its natural size; the panel follows it (frame-change observation can't,
        // because the panel itself dictates the hosting view's frame).
        hosting.rootView = TodoListContainer(
            viewModel: viewModel,
            onContentSizeChange: { [weak controller] size in
                MainActor.assumeIsolated { controller?.contentSizeDidChange(size) }
            }
        )
    }

    func start() {
        panelController.show()
    }

    func stop() {
        panelController.tearDown()
    }
}
