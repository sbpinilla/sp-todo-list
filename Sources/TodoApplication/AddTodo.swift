import Foundation
import TodoDomain

public struct AddTodo: Sendable {
    private let repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    /// Appends a not-done item with the trimmed title and persists the list.
    public func execute(title: String, to items: [TodoItem]) throws -> [TodoItem] {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw TodoError.blankTitle }
        let updated = items + [TodoItem(title: trimmed)]
        try repository.save(updated)
        return updated
    }
}
