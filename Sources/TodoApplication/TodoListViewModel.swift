import Foundation
import Observation
import TodoDomain

@MainActor
@Observable
public final class TodoListViewModel {
    public private(set) var items: [TodoItem] = []
    /// Message of the last failed action; `nil` after a successful one.
    public private(set) var lastError: String?

    private let loadTodos: LoadTodos
    private let addTodo: AddTodo
    private let removeTodo: RemoveTodo
    private let toggleTodo: ToggleTodo
    private let preferences: any DisplayPreferences
    private let now: () -> Date
    private let calendar: Calendar

    /// Whether only to-dos created today are shown; persisted through `DisplayPreferences`.
    public private(set) var onlyToday: Bool

    /// Items grouped by creation day (newest first), derived from `items`, `onlyToday` and `now()`.
    public var sections: [TodoDaySection] {
        TodoSections.make(items: items, now: now(), calendar: calendar, onlyToday: onlyToday)
    }

    public init(
        repository: any TodoRepository,
        preferences: any DisplayPreferences,
        now: @escaping () -> Date = Date.init,
        calendar: Calendar = .current
    ) {
        self.preferences = preferences
        self.now = now
        self.calendar = calendar
        onlyToday = preferences.showOnlyToday
        loadTodos = LoadTodos(repository: repository)
        addTodo = AddTodo(repository: repository)
        removeTodo = RemoveTodo(repository: repository)
        toggleTodo = ToggleTodo(repository: repository)
    }

    public func setOnlyToday(_ value: Bool) {
        onlyToday = value
        preferences.showOnlyToday = value
    }

    public func toggleOnlyToday() {
        setOnlyToday(!onlyToday)
    }

    public func load() {
        perform(onFailure: { self.items = [] }) { try self.loadTodos.execute() }
    }

    public func add(title: String) {
        perform { try self.addTodo.execute(title: title, to: self.items) }
    }

    public func remove(id: TodoItem.ID) {
        perform { try self.removeTodo.execute(id: id, from: self.items) }
    }

    public func toggle(id: TodoItem.ID) {
        perform { try self.toggleTodo.execute(id: id, in: self.items) }
    }

    private func perform(
        onFailure: () -> Void = {},
        _ action: () throws -> [TodoItem]
    ) {
        do {
            items = try action()
            lastError = nil
        } catch {
            onFailure()
            lastError = Self.message(for: error)
        }
    }

    private static func message(for error: Error) -> String {
        switch error {
        case TodoError.blankTitle:
            "The to-do text cannot be empty."
        default:
            "Something went wrong: \(error.localizedDescription)"
        }
    }
}
