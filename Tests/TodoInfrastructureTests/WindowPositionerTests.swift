import CoreGraphics
import Testing
@testable import TodoInfrastructure

@Suite("WindowPositioner")
struct WindowPositionerTests {
    private let size = CGSize(width: 280, height: 200)

    @Test func anchorsTopRightWithMargin() {
        let vf = CGRect(x: 0, y: 0, width: 1440, height: 875)
        let f = WindowPositioner.frame(visibleFrame: vf, contentSize: size, margin: 12)
        #expect(f.maxX == vf.maxX - 12)
        #expect(f.maxY == vf.maxY - 12)
        #expect(f.size == size)
    }

    @Test func respectsVisibleFrameOriginBelowMenuBarAndDock() {
        // Dock on the left (x offset 70) and menu bar/notch strip removed from the top.
        let vf = CGRect(x: 70, y: 0, width: 1370, height: 832)
        let f = WindowPositioner.frame(visibleFrame: vf, contentSize: size, margin: 12)
        #expect(f.maxX == CGFloat(1440 - 12))
        #expect(f.maxY == CGFloat(832 - 12))
        #expect(vf.contains(f))
    }

    @Test func secondaryDisplayWithNonZeroOrigin() {
        let vf = CGRect(x: -1920, y: 100, width: 1920, height: 1055)
        let f = WindowPositioner.frame(visibleFrame: vf, contentSize: size, margin: 12)
        #expect(f.maxX == CGFloat(-12))
        #expect(f.maxY == CGFloat(1155 - 12))
    }

    @Test func clampsHeightToMax() {
        let vf = CGRect(x: 0, y: 0, width: 1440, height: 875)
        let f = WindowPositioner.frame(
            visibleFrame: vf, contentSize: CGSize(width: 280, height: 900), margin: 12, maxHeight: 360)
        #expect(f.height == CGFloat(360))
        #expect(f.maxY == vf.maxY - 12)
    }

    @Test func clampsHeightToVisibleFrameOnSmallScreens() {
        let vf = CGRect(x: 0, y: 0, width: 800, height: 200)
        let f = WindowPositioner.frame(
            visibleFrame: vf, contentSize: CGSize(width: 280, height: 300), margin: 12, maxHeight: 360)
        #expect(f.height == CGFloat(200 - 24))
        #expect(vf.contains(f))
    }

    @Test func clampsWidthToVisibleFrame() {
        let vf = CGRect(x: 0, y: 0, width: 200, height: 600)
        let f = WindowPositioner.frame(visibleFrame: vf, contentSize: size, margin: 12)
        #expect(f.width == CGFloat(200 - 24))
        #expect(f.minX == vf.minX + 12)
    }

    @Test func smallContentKeepsItsHeight() {
        let vf = CGRect(x: 0, y: 0, width: 1440, height: 875)
        let f = WindowPositioner.frame(
            visibleFrame: vf, contentSize: CGSize(width: 280, height: 50), margin: 12)
        #expect(f.height == CGFloat(50))
    }
}
