import AppKit

/// Hosts a plain `NSView` (built by the app) in a `FloatingPanel` anchored top-right.
@MainActor
public final class PanelController {
    private let panel: FloatingPanel
    private let contentView: NSView
    private let margin: CGFloat
    private let maxHeight: CGFloat
    private var screenObserver: NSObjectProtocol?
    private var sizeObserver: NSObjectProtocol?

    public init(
        contentView: NSView,
        margin: CGFloat = WindowPositioner.defaultMargin,
        maxHeight: CGFloat = WindowPositioner.defaultMaxHeight
    ) {
        self.contentView = contentView
        self.margin = margin
        self.maxHeight = maxHeight
        self.panel = FloatingPanel()
        panel.contentView = contentView
    }

    /// Hides the panel and stops observing. The controller lives for the app lifetime, so no deinit cleanup.
    public func tearDown() {
        hide()
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        if let sizeObserver { NotificationCenter.default.removeObserver(sizeObserver) }
        screenObserver = nil
        sizeObserver = nil
    }

    public func show() {
        observeIfNeeded()
        reposition()
        panel.orderFrontRegardless()
    }

    public func hide() {
        panel.orderOut(nil)
    }

    /// Recomputes the frame from the live main-screen visible frame (never cached).
    public func reposition() {
        guard let screen = NSScreen.main else { return }
        let size = contentSize()
        let frame = WindowPositioner.frame(
            visibleFrame: screen.visibleFrame,
            contentSize: size,
            margin: margin,
            maxHeight: maxHeight
        )
        panel.setFrame(frame, display: true)
    }

    private func contentSize() -> CGSize {
        contentView.layoutSubtreeIfNeeded()
        let fitting = contentView.fittingSize
        let width = fitting.width > 0 ? fitting.width : panel.frame.width
        let height = fitting.height > 0 ? fitting.height : panel.frame.height
        return CGSize(width: width, height: height)
    }

    private func observeIfNeeded() {
        if screenObserver == nil {
            screenObserver = NotificationCenter.default.addObserver(
                forName: NSApplication.didChangeScreenParametersNotification,
                object: nil, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.reposition() }
            }
        }
        if sizeObserver == nil {
            // Content-size changes (list grows/shrinks) re-anchor the top-right corner.
            contentView.postsFrameChangedNotifications = true
            sizeObserver = NotificationCenter.default.addObserver(
                forName: NSView.frameDidChangeNotification,
                object: contentView, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.reposition() }
            }
        }
    }
}
