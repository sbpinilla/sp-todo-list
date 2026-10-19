import CoreGraphics

/// Pure placement math for the floating panel (no AppKit dependency).
public enum WindowPositioner {
    public static let defaultMargin: CGFloat = 12
    public static let defaultMaxHeight: CGFloat = 360

    public static func frame(
        visibleFrame: CGRect,
        contentSize: CGSize,
        margin: CGFloat = defaultMargin,
        maxHeight: CGFloat = defaultMaxHeight
    ) -> CGRect {
        let width = min(contentSize.width, max(0, visibleFrame.width - 2 * margin))
        let height = min(contentSize.height, maxHeight, max(0, visibleFrame.height - 2 * margin))
        return CGRect(
            x: visibleFrame.maxX - margin - width,
            y: visibleFrame.maxY - margin - height,
            width: width,
            height: height
        )
    }
}
