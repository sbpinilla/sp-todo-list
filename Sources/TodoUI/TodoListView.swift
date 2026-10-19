import SwiftUI
import TodoDomain

/// Presentational list: data and closures in, no view model.
public struct TodoListView: View {
    public static let width: CGFloat = 280

    let items: [TodoItem]
    let errorMessage: String?
    let onAdd: (String) -> Void
    let onToggle: (TodoItem.ID) -> Void
    let onDelete: (TodoItem.ID) -> Void

    public init(
        items: [TodoItem],
        errorMessage: String?,
        onAdd: @escaping (String) -> Void,
        onToggle: @escaping (TodoItem.ID) -> Void,
        onDelete: @escaping (TodoItem.ID) -> Void
    ) {
        self.items = items
        self.errorMessage = errorMessage
        self.onAdd = onAdd
        self.onToggle = onToggle
        self.onDelete = onDelete
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AddTodoField(errorMessage: errorMessage, onSubmit: onAdd)
            if !items.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(items) { item in
                            TodoRowView(
                                item: item,
                                onToggle: { onToggle(item.id) },
                                onDelete: { onDelete(item.id) }
                            )
                        }
                    }
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .padding(12)
        .frame(width: Self.width)
        .modifier(GlassBackground())
    }
}

/// Translucent glass look: macOS 26 glass when available, material fallback otherwise.
struct GlassBackground: ViewModifier {
    private let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

    func body(content: Content) -> some View {
        if #available(macOS 26, *) {
            content.glassEffect(.regular, in: shape)
        } else {
            content.background(.regularMaterial, in: shape)
        }
    }
}

#Preview("List") {
    TodoListView(
        items: [
            TodoItem(title: "Buy milk"),
            TodoItem(title: "Send report", isDone: true),
        ],
        errorMessage: nil,
        onAdd: { _ in }, onToggle: { _ in }, onDelete: { _ in }
    )
    .padding()
}
