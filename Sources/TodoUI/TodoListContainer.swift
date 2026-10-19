import SwiftUI
import TodoApplication

/// Container: binds the view model to the presentational list.
public struct TodoListContainer: View {
    private let viewModel: TodoListViewModel

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TodoListView(
            items: viewModel.items,
            errorMessage: viewModel.lastError,
            onAdd: { viewModel.add(title: $0) },
            onToggle: { viewModel.toggle(id: $0) },
            onDelete: { viewModel.remove(id: $0) }
        )
        .onAppear { viewModel.load() }
    }
}
