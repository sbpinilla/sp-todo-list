import Testing
@testable import TodoApplication

@Suite struct TodoApplicationSmokeTests {
    @Test func moduleLoads() {
        #expect(TodoApplicationModule.name == "TodoApplication")
    }
}
