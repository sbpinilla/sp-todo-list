import AppKit

/// Menu bar status item whose menu exposes the "Show only today" toggle and Quit.
@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let isOnlyToday: () -> Bool
    private let onToggleOnlyToday: () -> Void
    private let onQuit: () -> Void
    private let onlyTodayItem: NSMenuItem

    init(
        isOnlyToday: @escaping () -> Bool,
        onToggleOnlyToday: @escaping () -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.isOnlyToday = isOnlyToday
        self.onToggleOnlyToday = onToggleOnlyToday
        self.onQuit = onQuit
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        onlyTodayItem = NSMenuItem(title: "Show only today", action: #selector(toggleOnlyToday), keyEquivalent: "")
        super.init()
        statusItem.button?.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "To-Do")
        if statusItem.button?.image == nil { statusItem.button?.title = "To-Do" }
        let menu = NSMenu()
        menu.delegate = self
        onlyTodayItem.target = self
        menu.addItem(onlyTodayItem)
        menu.addItem(.separator())
        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
        refreshCheckmark()
    }

    func menuWillOpen(_ menu: NSMenu) { refreshCheckmark() }

    private func refreshCheckmark() {
        onlyTodayItem.state = isOnlyToday() ? .on : .off
    }

    @objc private func toggleOnlyToday() {
        onToggleOnlyToday()
        refreshCheckmark()
    }

    @objc private func quit() { onQuit() }
}
