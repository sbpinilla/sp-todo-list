import Testing
@testable import TodoDomain

@Suite struct TodoDomainSmokeTests {
    @Test func moduleLoads() {
        #expect(TodoDomainModule.name == "TodoDomain")
    }
}
