import CoreGraphics
import Testing
@testable import TodoUI

@Suite struct ListSizingTests {
    @Test func growsWithMeasuredContentUnderTheCap() {
        #expect(ListSizing.height(forContent: 24, max: 270) == 24)
        #expect(ListSizing.height(forContent: 96, max: 270) == 96)
    }

    @Test func capsAtMaximumSoTheListScrolls() {
        #expect(ListSizing.height(forContent: 500, max: 270) == 270)
    }

    @Test func unmeasuredOrNegativeContentIsZero() {
        #expect(ListSizing.height(forContent: 0, max: 270) == 0)
        #expect(ListSizing.height(forContent: -5, max: 270) == 0)
    }
}
