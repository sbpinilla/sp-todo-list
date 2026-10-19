import Foundation
import Testing
import TodoDomain
@testable import TodoApplication

@Suite struct UseCaseTests {
    @Test func addAppendsNotDoneItem() throws {
        let repo = FakeTodoRepository()
        let result = try AddTodo(repository: repo).execute(title: "Buy milk", to: [])
        #expect(result.count == 1)
        #expect(result[0].title == "Buy milk")
        #expect(result[0].isDone == false)
        #expect(repo.items == result)
    }

    @Test func addTrimsWhitespace() throws {
        let repo = FakeTodoRepository()
        let result = try AddTodo(repository: repo).execute(title: "  Buy milk \n", to: [])
        #expect(result[0].title == "Buy milk")
    }

    @Test(arguments: ["", "   ", "\n\t "])
    func addRejectsBlank(title: String) {
        let repo = FakeTodoRepository()
        #expect(throws: TodoError.blankTitle) {
            try AddTodo(repository: repo).execute(title: title, to: [])
        }
        #expect(repo.saveCount == 0)
    }

    @Test func addKeepsExistingOrder() throws {
        let repo = FakeTodoRepository()
        let first = TodoItem(title: "A")
        let result = try AddTodo(repository: repo).execute(title: "B", to: [first])
        #expect(result.map(\.title) == ["A", "B"])
    }

    @Test func removeDeletesOnlySelected() throws {
        let a = TodoItem(title: "A"), b = TodoItem(title: "B")
        let repo = FakeTodoRepository()
        let result = try RemoveTodo(repository: repo).execute(id: a.id, from: [a, b])
        #expect(result == [b])
        #expect(repo.items == [b])
    }

    @Test func toggleFlipsAndKeepsItem() throws {
        let a = TodoItem(title: "A")
        let repo = FakeTodoRepository()
        let result = try ToggleTodo(repository: repo).execute(id: a.id, in: [a])
        #expect(result.count == 1)
        #expect(result[0].isDone)
        #expect(repo.items == result)
    }

    @Test func toggleTwiceRestoresOriginal() throws {
        let a = TodoItem(title: "A")
        let toggle = ToggleTodo(repository: FakeTodoRepository())
        let result = try toggle.execute(id: toggle.execute(id: a.id, in: [a])[0].id, in: toggle.execute(id: a.id, in: [a]))
        #expect(result == [a])
    }

    @Test func loadReturnsStoredItems() throws {
        let a = TodoItem(title: "A")
        #expect(try LoadTodos(repository: FakeTodoRepository(items: [a])).execute() == [a])
    }

    @Test func loadPropagatesError() {
        let repo = FakeTodoRepository()
        repo.failOnLoad = true
        #expect(throws: FakeRepositoryError.self) {
            try LoadTodos(repository: repo).execute()
        }
    }
}
