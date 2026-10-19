import Foundation
import Testing
@testable import TodoInfrastructure

@MainActor
@Suite struct UserDefaultsDisplayPreferencesTests {
    private func withIsolatedDefaults(_ body: (UserDefaults, String) -> Void) {
        let suite = "sp-todo-list-tests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defer { defaults.removePersistentDomain(forName: suite) }
        body(defaults, suite)
    }

    @Test func defaultsToFalse() {
        withIsolatedDefaults { defaults, _ in
            #expect(UserDefaultsDisplayPreferences(defaults: defaults).showOnlyToday == false)
        }
    }

    @Test func roundTripsValue() {
        withIsolatedDefaults { defaults, _ in
            let prefs = UserDefaultsDisplayPreferences(defaults: defaults)
            prefs.showOnlyToday = true
            #expect(prefs.showOnlyToday == true)
            prefs.showOnlyToday = false
            #expect(prefs.showOnlyToday == false)
        }
    }

    @Test func secondInstanceReadsStoredValue() {
        withIsolatedDefaults { defaults, suite in
            UserDefaultsDisplayPreferences(defaults: defaults).showOnlyToday = true
            let other = UserDefaults(suiteName: suite)!
            #expect(UserDefaultsDisplayPreferences(defaults: other).showOnlyToday == true)
        }
    }
}
