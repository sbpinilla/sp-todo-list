import Foundation
import TodoApplication
import TodoDomain

struct FakeRepositoryError: Error, Equatable {}

final class FakeTodoRepository: TodoRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var stored: [TodoItem]
    private var _saveCount = 0
    var failOnLoad = false
    var failOnSave = false

    init(items: [TodoItem] = []) { stored = items }

    var saveCount: Int { lock.withLock { _saveCount } }
    var items: [TodoItem] { lock.withLock { stored } }

    func load() throws -> [TodoItem] {
        if failOnLoad { throw FakeRepositoryError() }
        return lock.withLock { stored }
    }

    func save(_ items: [TodoItem]) throws {
        if failOnSave { throw FakeRepositoryError() }
        lock.withLock {
            stored = items
            _saveCount += 1
        }
    }
}
