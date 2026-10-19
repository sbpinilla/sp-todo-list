import Foundation
import Testing
@testable import TodoDomain

@Suite struct TodoItemTests {
    @Test func newItemDefaultsToNotDone() {
        let item = TodoItem(title: "Buy milk")
        #expect(item.title == "Buy milk")
        #expect(item.isDone == false)
    }

    @Test func itemsGetDistinctIds() {
        #expect(TodoItem(title: "A").id != TodoItem(title: "A").id)
    }

    @Test func explicitFieldsArePreserved() {
        let id = UUID()
        let date = Date(timeIntervalSince1970: 1_000)
        let item = TodoItem(id: id, title: "X", isDone: true, createdAt: date)
        #expect(item.id == id)
        #expect(item.isDone)
        #expect(item.createdAt == date)
    }

    @Test func codableRoundTripPreservesItem() throws {
        let item = TodoItem(
            id: UUID(), title: "Buy milk", isDone: true,
            createdAt: Date(timeIntervalSince1970: 1_000)
        )
        let data = try JSONEncoder().encode(item)
        let decoded = try JSONDecoder().decode(TodoItem.self, from: data)
        #expect(decoded == item)
    }
}
