import TodoDomain

/// Plain presentation mapping for one row: keeps strings and state mapping testable.
struct TodoRowPresentation: Equatable {
    let title: String
    let isDone: Bool

    init(item: TodoItem) {
        title = item.title
        isDone = item.isDone
    }

    var isStrikethrough: Bool { isDone }
    var opacity: Double { isDone ? 0.5 : 1 }
    var toggleLabel: String { isDone ? "Mark as not done" : "Mark as done" }
    var deleteLabel: String { "Delete" }
    var accessibilityValue: String { "\(title), \(isDone ? "done" : "not done")" }
}
