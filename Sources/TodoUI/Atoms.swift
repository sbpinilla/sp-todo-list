import SwiftUI

struct CheckboxButton: View {
    let isDone: Bool
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                .imageScale(.large)
                .foregroundStyle(isDone ? Color.accentColor : Color.secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

struct DeleteButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
    }
}

#Preview("Atoms") {
    HStack {
        CheckboxButton(isDone: false, label: "Mark as done") {}
        CheckboxButton(isDone: true, label: "Mark as not done") {}
        DeleteButton(label: "Delete") {}
    }
    .padding()
}
