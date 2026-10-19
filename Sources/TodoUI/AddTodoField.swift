import SwiftUI

/// Text field plus the single red error line shown directly below it.
struct AddTodoField: View {
    let errorMessage: String?
    let onSubmit: (String) -> Void

    @State private var draft = AddTodoDraft()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(AddTodoDraft.placeholder, text: $draft.text)
                .textFieldStyle(.roundedBorder)
                .onSubmit { onSubmit(draft.submit()) }
                .accessibilityLabel(AddTodoDraft.placeholder)
            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error: \(errorMessage)")
            }
        }
    }
}

#Preview("Add field") {
    VStack {
        AddTodoField(errorMessage: nil) { _ in }
        AddTodoField(errorMessage: "The to-do text cannot be empty.") { _ in }
    }
    .padding()
    .frame(width: 280)
}
