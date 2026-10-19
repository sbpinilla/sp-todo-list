import Foundation
import TodoApplication

/// `DisplayPreferences` backed by `UserDefaults`; the defaults instance is injectable for tests.
@MainActor
public final class UserDefaultsDisplayPreferences: DisplayPreferences {
    private static let showOnlyTodayKey = "showOnlyToday"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var showOnlyToday: Bool {
        get { defaults.bool(forKey: Self.showOnlyTodayKey) }
        set { defaults.set(newValue, forKey: Self.showOnlyTodayKey) }
    }
}
