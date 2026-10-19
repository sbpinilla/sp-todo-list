import AppKit

/// Borderless, non-activating, always-visible panel (recipe validated in the HU1 spike).
@MainActor
public final class FloatingPanel: NSPanel {
    /// `.screenSaver` was confirmed by the user to stay above every app, including full-screen ones.
    public static let preferredLevel: NSWindow.Level = .screenSaver

    public init(contentRect: NSRect = NSRect(x: 0, y: 0, width: 280, height: 100)) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        level = Self.preferredLevel
        collectionBehavior = [.canJoinAllSpaces, .canJoinAllApplications, .fullScreenAuxiliary, .stationary]
        hidesOnDeactivate = false
        isFloatingPanel = true
        isMovable = false
        isMovableByWindowBackground = false
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
    }

    // Needed so the add field can take keyboard input without activating the app.
    public override var canBecomeKey: Bool { true }
    public override var canBecomeMain: Bool { false }
}
