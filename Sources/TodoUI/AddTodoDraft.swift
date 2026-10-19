/// Text-entry state for the add field. Validation stays in the view model.
struct AddTodoDraft: Equatable {
    static let placeholder = "Add a to-do"

    var text = ""

    /// Returns the typed text and clears the field.
    mutating func submit() -> String {
        defer { text = "" }
        return text
    }
}
