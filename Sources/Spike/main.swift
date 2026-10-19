// THROWAWAY spike (HU1): validates panel level, focus and placement.
// Usage: swift run Spike [--level screenSaver|statusBar]   (or SPIKE_LEVEL env var)
import AppKit
import SwiftUI

final class SpikePanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

struct SpikeView: View {
    @State private var text = ""
    let levelName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spike - level: \(levelName)").font(.headline)
            TextField("Type here to test focus", text: $text)
                .textFieldStyle(.roundedBorder)
            Text("Typed: \(text)").font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(width: 280, height: 110)
        .background(.regularMaterial)
    }
}

@MainActor
final class SpikeController: NSObject, NSApplicationDelegate {
    private let panel: SpikePanel
    private let levelName: String
    private let margin: CGFloat = 12
    private var statusItem: NSStatusItem?

    override init() {
        let args = CommandLine.arguments
        var name = ProcessInfo.processInfo.environment["SPIKE_LEVEL"] ?? "screenSaver"
        if let i = args.firstIndex(of: "--level"), args.indices.contains(i + 1) {
            name = args[i + 1]
        }
        levelName = name == "statusBar" ? "statusBar" : "screenSaver"
        panel = SpikePanel(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 110),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        panel.level = levelName == "statusBar" ? .statusBar : .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .canJoinAllApplications, .fullScreenAuxiliary, .stationary]
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.contentView = NSHostingView(rootView: SpikeView(levelName: levelName))

        reposition()
        panel.orderFrontRegardless()
        panel.makeKey()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.reposition() }
        }

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "Spike"
        let menu = NSMenu()
        menu.addItem(withTitle: "Quit Spike", action: #selector(quit), keyEquivalent: "q").target = self
        item.menu = menu
        statusItem = item
    }

    private func reposition() {
        guard let screen = NSScreen.main else { return }
        let vf = screen.visibleFrame
        let size = panel.frame.size
        let origin = NSPoint(x: vf.maxX - size.width - margin, y: vf.maxY - size.height - margin)
        panel.setFrameOrigin(origin)
        print("reposition: visibleFrame=\(vf) origin=\(origin)")
    }

    @objc private func quit() { NSApp.terminate(nil) }
}

let app = NSApplication.shared
app.setActivationPolicy(.accessory)
let controller = SpikeController()
app.delegate = controller
app.run()
