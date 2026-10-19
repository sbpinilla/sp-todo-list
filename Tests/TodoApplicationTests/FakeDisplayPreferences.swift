import TodoApplication

@MainActor
final class FakeDisplayPreferences: DisplayPreferences {
    private(set) var writeCount = 0
    var showOnlyToday: Bool {
        didSet { writeCount += 1 }
    }

    init(showOnlyToday: Bool = false) { self.showOnlyToday = showOnlyToday }
}
