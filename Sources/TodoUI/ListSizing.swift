import CoreGraphics

/// Pure sizing rule for the scrolling list: follow measured content up to a cap.
enum ListSizing {
    static func height(forContent content: CGFloat, max cap: CGFloat) -> CGFloat {
        min(Swift.max(content, 0), cap)
    }
}
