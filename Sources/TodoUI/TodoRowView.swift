import SwiftUI
import TodoDomain

struct TodoRowView: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onDelete: () -> Void

    var body: some View {
        let p = TodoRowPresentation(item: item)
        HStack(spacing: 8) {
            CheckboxButton(isDone: p.isDone, label: p.toggleLabel, action: onToggle)
            Text(p.title)
                .strikethrough(p.isStrikethrough)
                .opacity(p.opacity)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityValue(p.accessibilityValue)
            DeleteButton(label: p.deleteLabel, action: onDelete)
        }
    }
}

#Preview("Rows") {
    VStack {
        TodoRowView(item: TodoItem(title: "Buy milk"), onToggle: {}, onDelete: {})
        TodoRowView(item: TodoItem(title: "Send report", isDone: true), onToggle: {}, onDelete: {})
    }
    .padding()
    .frame(width: 280)
}
