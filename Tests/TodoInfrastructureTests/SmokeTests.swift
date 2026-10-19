import Testing
@testable import TodoInfrastructure

@Suite struct TodoInfrastructureSmokeTests {
    @Test func moduleLoads() {
        #expect(TodoInfrastructureModule.name == "TodoInfrastructure")
    }
}
