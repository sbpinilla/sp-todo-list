import AppKit

/// Menu bar status item whose menu exposes Quit.
@MainActor
final class StatusItemController: NSObject {
    private let statusItem: NSStatusItem
    private let onQuit: () -> Void

    init(onQuit: @escaping () -> Void) {
        self.onQuit = onQuit
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        statusItem.button?.image = NSImage(systemSymbolName: "checklist", accessibilityDescription: "To-Do")
        if statusItem.button?.image == nil { statusItem.button?.title = "To-Do" }
        let menu = NSMenu()
        let quit = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)
        statusItem.menu = menu
    }

    @objc private func quit() { onQuit() }
}
