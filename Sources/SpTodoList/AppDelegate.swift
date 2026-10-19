import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var root: CompositionRoot?
    private var statusItem: StatusItemController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        let root = CompositionRoot()
        root.start()
        self.root = root
        statusItem = StatusItemController(
            isOnlyToday: { [weak root] in root?.isOnlyToday ?? false },
            onToggleOnlyToday: { [weak root] in root?.toggleOnlyToday() },
            onQuit: { NSApp.terminate(nil) }
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        root?.stop()
    }
}
