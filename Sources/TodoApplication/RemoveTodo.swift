import TodoDomain

public struct RemoveTodo: Sendable {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    public func execute(id: TodoItem.ID, from items: [TodoItem]) throws -> [TodoItem] {
        let updated = items.filter { $0.id != id }
        try repository.save(updated)
        return updated
    }
}
