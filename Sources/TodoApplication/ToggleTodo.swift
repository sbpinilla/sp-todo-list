import TodoDomain

public struct ToggleTodo: Sendable {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    public func execute(id: TodoItem.ID, in items: [TodoItem]) throws -> [TodoItem] {
        var updated = items
        if let index = updated.firstIndex(where: { $0.id == id }) {
            updated[index].isDone.toggle()
        }
        try repository.save(updated)
        return updated
    }
}
