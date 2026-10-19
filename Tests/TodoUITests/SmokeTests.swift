import Testing
@testable import TodoUI

@Suite struct TodoUISmokeTests {
    @Test func moduleLoads() {
        #expect(TodoUIModule.name == "TodoUI")
    }
}
