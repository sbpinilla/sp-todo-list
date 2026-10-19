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

    public init(repository: any TodoRepository) {
        loadTodos = LoadTodos(repository: repository)
        addTodo = AddTodo(repository: repository)
        removeTodo = RemoveTodo(repository: repository)
        toggleTodo = ToggleTodo(repository: repository)
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
