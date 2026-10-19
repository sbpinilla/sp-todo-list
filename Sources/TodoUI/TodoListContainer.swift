import SwiftUI
import TodoApplication

/// Container: binds the view model to the presentational list.
public struct TodoListContainer: View {
    private let viewModel: TodoListViewModel
    private let onContentSizeChange: (CGSize) -> Void

    public init(
        viewModel: TodoListViewModel,
        onContentSizeChange: @escaping (CGSize) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.onContentSizeChange = onContentSizeChange
    }

    public var body: some View {
        TodoListView(
            sections: viewModel.sections,
            errorMessage: viewModel.lastError,
            onAdd: { viewModel.add(title: $0) },
            onToggle: { viewModel.toggle(id: $0) },
            onDelete: { viewModel.remove(id: $0) },
            onContentSizeChange: onContentSizeChange
        )
        .onAppear { viewModel.load() }
    }
}
