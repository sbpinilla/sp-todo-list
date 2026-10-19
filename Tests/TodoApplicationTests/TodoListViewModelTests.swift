import Foundation
import Testing
import TodoDomain
@testable import TodoApplication

@MainActor
@Suite struct TodoListViewModelTests {
    private static let utc: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()
    /// 2026-10-18 12:00 UTC.
    private static let now = Date(timeIntervalSince1970: 1_792_324_800)
    private static let yesterday = now.addingTimeInterval(-86_400)

    private func makeViewModel(
        repository: FakeTodoRepository = FakeTodoRepository(),
        preferences: FakeDisplayPreferences = FakeDisplayPreferences(),
        now: Date = TodoListViewModelTests.now
    ) -> TodoListViewModel {
        TodoListViewModel(
            repository: repository,
            preferences: preferences,
            now: { now },
            calendar: Self.utc
        )
    }

    @Test func loadPopulatesItems() {
        let a = TodoItem(title: "A")
        let vm = makeViewModel(repository: FakeTodoRepository(items: [a]))
        vm.load()
        #expect(vm.items == [a])
        #expect(vm.lastError == nil)
    }

    @Test func loadErrorExposesLastErrorAndEmptyList() {
        let repo = FakeTodoRepository()
        repo.failOnLoad = true
        let vm = makeViewModel(repository: repo)
        vm.load()
        #expect(vm.items.isEmpty)
        #expect(vm.lastError != nil)
    }

    @Test func addPersistsAndUpdatesItems() {
        let repo = FakeTodoRepository()
        let vm = makeViewModel(repository: repo)
        vm.add(title: " Buy milk ")
        #expect(vm.items.map(\.title) == ["Buy milk"])
        #expect(repo.items == vm.items)
        #expect(repo.saveCount == 1)
    }

    @Test func blankAddIsIgnoredWithError() {
        let repo = FakeTodoRepository()
        let vm = makeViewModel(repository: repo)
        vm.add(title: "   ")
        #expect(vm.items.isEmpty)
        #expect(repo.saveCount == 0)
        #expect(vm.lastError != nil)
    }

    @Test func successfulActionClearsLastError() {
        let vm = makeViewModel(repository: FakeTodoRepository())
        vm.add(title: "")
        #expect(vm.lastError != nil)
        vm.add(title: "ok")
        #expect(vm.lastError == nil)
    }

    @Test func removeAndToggleAreSavedEachTime() {
        let repo = FakeTodoRepository()
        let vm = makeViewModel(repository: repo)
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
        let vm = makeViewModel(repository: repo)
        vm.add(title: "A")
        repo.failOnSave = true
        vm.add(title: "B")
        #expect(vm.items.map(\.title) == ["A"])
        #expect(vm.lastError != nil)
    }

    @Test func addingSeveralItemsKeepsAllInOrderAndPersistsThem() {
        let repo = FakeTodoRepository()
        let vm = makeViewModel(repository: repo)
        vm.add(title: "A")
        vm.add(title: "B")
        vm.add(title: "C")
        #expect(vm.items.map(\.title) == ["A", "B", "C"])
        #expect(repo.items == vm.items)
    }

    // MARK: HU2 - sections and onlyToday

    @Test func onlyTodayIsLoadedFromPreferences() {
        #expect(makeViewModel(preferences: FakeDisplayPreferences(showOnlyToday: true)).onlyToday)
        #expect(!makeViewModel().onlyToday)
    }

    @Test func toggleOnlyTodayPersistsThroughPort() {
        let prefs = FakeDisplayPreferences()
        let vm = makeViewModel(preferences: prefs)
        vm.toggleOnlyToday()
        #expect(vm.onlyToday)
        #expect(prefs.showOnlyToday)
        vm.setOnlyToday(false)
        #expect(!vm.onlyToday)
        #expect(!prefs.showOnlyToday)
    }

    @Test func sectionsGroupNewestDayFirstUsingInjectedNow() {
        let old = TodoItem(title: "old", createdAt: Self.yesterday)
        let new = TodoItem(title: "new", createdAt: Self.now)
        let vm = makeViewModel(repository: FakeTodoRepository(items: [old, new]))
        vm.load()
        #expect(vm.sections.map(\.items) == [[new], [old]])
        #expect(vm.items == [old, new])
    }

    @Test func sectionsFollowOnlyTodayFilter() {
        let old = TodoItem(title: "old", createdAt: Self.yesterday)
        let new = TodoItem(title: "new", createdAt: Self.now)
        let vm = makeViewModel(repository: FakeTodoRepository(items: [old, new]))
        vm.load()
        vm.toggleOnlyToday()
        #expect(vm.sections.map(\.items) == [[new]])
        vm.toggleOnlyToday()
        #expect(vm.sections.count == 2)
    }

    @Test func addingWhileFilteredShowsNewItem() {
        let vm = makeViewModel(
            repository: FakeTodoRepository(items: [TodoItem(title: "old", createdAt: Self.yesterday)]),
            now: Date()
        )
        vm.load()
        vm.setOnlyToday(true)
        #expect(vm.sections.isEmpty)
        vm.add(title: "fresh")
        #expect(vm.sections.flatMap(\.items).map(\.title) == ["fresh"])
        #expect(vm.items.map(\.title) == ["old", "fresh"])
    }

    @Test func toggleAndRemoveByIdWorkAcrossSections() {
        let old = TodoItem(title: "old", createdAt: Self.yesterday)
        let new = TodoItem(title: "new", createdAt: Self.now)
        let repo = FakeTodoRepository(items: [old, new])
        let vm = makeViewModel(repository: repo)
        vm.load()
        vm.toggle(id: old.id)
        #expect(vm.sections[1].items[0].isDone)
        vm.remove(id: new.id)
        #expect(vm.sections.map(\.items.count) == [1])
        #expect(repo.items == vm.items)
    }
}
