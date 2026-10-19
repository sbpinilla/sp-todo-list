import SwiftUI
import TodoApplication
import TodoDomain

/// Presentational list: data and closures in, no view model.
public struct TodoListView: View {
    public static let width: CGFloat = 280
    /// Scroll area cap so the whole panel stays within ~360pt (field + padding take the rest).
    static let listMaxHeight: CGFloat = 270

    let sections: [TodoDaySection]
    let errorMessage: String?
    let onAdd: (String) -> Void
    let onToggle: (TodoItem.ID) -> Void
    let onDelete: (TodoItem.ID) -> Void
    let onContentSizeChange: (CGSize) -> Void

    /// Measured natural height of the rows; drives the scroll area height explicitly.
    @State private var listContentHeight: CGFloat = 0

    public init(
        sections: [TodoDaySection],
        errorMessage: String?,
        onAdd: @escaping (String) -> Void,
        onToggle: @escaping (TodoItem.ID) -> Void,
        onDelete: @escaping (TodoItem.ID) -> Void,
        onContentSizeChange: @escaping (CGSize) -> Void = { _ in }
    ) {
        self.sections = sections
        self.errorMessage = errorMessage
        self.onAdd = onAdd
        self.onToggle = onToggle
        self.onDelete = onDelete
        self.onContentSizeChange = onContentSizeChange
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AddTodoField(errorMessage: errorMessage, onSubmit: onAdd)
            if !sections.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(sections) { section in
                            DaySeparatorView(day: section.day)
                            ForEach(section.items) { item in
                                TodoRowView(
                                    item: item,
                                    onToggle: { onToggle(item.id) },
                                    onDelete: { onDelete(item.id) }
                                )
                            }
                        }
                    }
                    .onGeometryChange(for: CGFloat.self, of: { $0.size.height }) { listContentHeight = $0 }
                }
                .scrollBounceBehavior(.basedOnSize)
                .frame(height: ListSizing.height(forContent: listContentHeight, max: Self.listMaxHeight))
            }
        }
        .padding(12)
        .frame(width: Self.width)
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: onContentSizeChange)
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
        sections: [
            TodoDaySection(day: Date(), items: [
                TodoItem(title: "Buy milk"),
                TodoItem(title: "Send report", isDone: true),
            ]),
        ],
        errorMessage: nil,
        onAdd: { _ in }, onToggle: { _ in }, onDelete: { _ in }
    )
    .padding()
}
