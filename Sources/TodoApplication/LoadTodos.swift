import TodoDomain

public struct LoadTodos: Sendable {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    public func execute() throws -> [TodoItem] {
        try repository.load()
    }
}
