import Foundation
import Testing
import TodoDomain
@testable import TodoApplication

@MainActor
@Suite struct TodoListViewModelTests {
    @Test func loadPopulatesItems() {
        let a = TodoItem(title: "A")
        let vm = TodoListViewModel(repository: FakeTodoRepository(items: [a]))
        vm.load()
        #expect(vm.items == [a])
        #expect(vm.lastError == nil)
    }

    @Test func loadErrorExposesLastErrorAndEmptyList() {
        let repo = FakeTodoRepository()
        repo.failOnLoad = true
        let vm = TodoListViewModel(repository: repo)
        vm.load()
        #expect(vm.items.isEmpty)
        #expect(vm.lastError != nil)
    }

    @Test func addPersistsAndUpdatesItems() {
        let repo = FakeTodoRepository()
        let vm = TodoListViewModel(repository: repo)
        vm.add(title: " Buy milk ")
        #expect(vm.items.map(\.title) == ["Buy milk"])
        #expect(repo.items == vm.items)
        #expect(repo.saveCount == 1)
    }

    @Test func blankAddIsIgnoredWithError() {
        let repo = FakeTodoRepository()
        let vm = TodoListViewModel(repository: repo)
        vm.add(title: "   ")
        #expect(vm.items.isEmpty)
        #expect(repo.saveCount == 0)
        #expect(vm.lastError != nil)
    }

    @Test func successfulActionClearsLastError() {
        let vm = TodoListViewModel(repository: FakeTodoRepository())
        vm.add(title: "")
        #expect(vm.lastError != nil)
        vm.add(title: "ok")
        #expect(vm.lastError == nil)
    }

    @Test func removeAndToggleAreSavedEachTime() {
        let repo = FakeTodoRepository()
        let vm = TodoListViewModel(repository: repo)
        vm.add(title: "A")
        vm.add(title: "B")
        let a = vm.items[0], b = vm.items[1]
        vm.toggle(id: a.id)
        #expect(vm.items[0].isDone)
        vm.remove(id: b.id)
        #expect(vm.items.map(\.id) == [a.id])
        #expect(repo.items == vm.items)
        #expect(repo.saveCount == 4)
    }

    @Test func saveFailureKeepsItemsAndSetsError() {
        let repo = FakeTodoRepository()
        let vm = TodoListViewModel(repository: repo)
        vm.add(title: "A")
        repo.failOnSave = true
        vm.add(title: "B")
        #expect(vm.items.map(\.title) == ["A"])
        #expect(vm.lastError != nil)
    }
}
