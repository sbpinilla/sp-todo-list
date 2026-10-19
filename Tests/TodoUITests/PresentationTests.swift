import Foundation
import Testing
import TodoDomain
@testable import TodoUI

@Suite struct TodoRowPresentationTests {
    @Test func pendingItemIsNotDimmedNorStruck() {
        let p = TodoRowPresentation(item: TodoItem(title: "Buy milk"))
        #expect(p.title == "Buy milk")
        #expect(!p.isStrikethrough)
        #expect(p.opacity == 1)
        #expect(p.toggleLabel == "Mark as done")
    }

    @Test func doneItemIsStruckAndDimmed() {
        let p = TodoRowPresentation(item: TodoItem(title: "Buy milk", isDone: true))
        #expect(p.isStrikethrough)
        #expect(p.opacity < 1)
        #expect(p.toggleLabel == "Mark as not done")
    }

    @Test func labelsDescribeTheItem() {
        let p = TodoRowPresentation(item: TodoItem(title: "Buy milk"))
        #expect(p.deleteLabel == "Delete")
        #expect(p.accessibilityValue == "Buy milk, not done")
        let done = TodoRowPresentation(item: TodoItem(title: "Buy milk", isDone: true))
        #expect(done.accessibilityValue == "Buy milk, done")
    }
}

@Suite struct AddTodoDraftTests {
    @Test func submitReturnsRawTextAndClears() {
        var draft = AddTodoDraft()
        draft.text = "  Call mom "
        let submitted = draft.submit()
        #expect(submitted == "  Call mom ")
        #expect(draft.text.isEmpty)
    }

    @Test func blankSubmitIsForwardedSoViewModelReportsError() {
        var draft = AddTodoDraft()
        draft.text = "   "
        #expect(draft.submit() == "   ")
    }

    @Test func placeholderIsEnglish() {
        #expect(AddTodoDraft.placeholder == "Add a to-do")
    }
}
