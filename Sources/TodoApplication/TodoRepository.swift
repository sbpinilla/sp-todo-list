import TodoDomain

/// Persistence port. Implemented by the infrastructure layer.
public protocol TodoRepository: Sendable {
    func load() throws -> [TodoItem]
    func save(_ items: [TodoItem]) throws
}
