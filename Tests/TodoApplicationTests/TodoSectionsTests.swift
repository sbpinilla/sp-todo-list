import Foundation
import Testing
import TodoDomain
@testable import TodoApplication

@Suite struct TodoSectionsTests {
    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 2 * 3600)!
        return calendar
    }()

    private func date(_ day: Int, _ hour: Int = 12, _ minute: Int = 0, _ second: Int = 0) -> Date {
        let components = DateComponents(
            year: 2026, month: 10, day: day, hour: hour, minute: minute, second: second
        )
        return Self.calendar.date(from: components)!
    }

    private func item(_ title: String, at createdAt: Date, done: Bool = false) -> TodoItem {
        TodoItem(title: title, isDone: done, createdAt: createdAt)
    }

    private func make(_ items: [TodoItem], now: Date, onlyToday: Bool = false) -> [TodoDaySection] {
        TodoSections.make(items: items, now: now, calendar: Self.calendar, onlyToday: onlyToday)
    }

    @Test func emptyInputYieldsNoSections() {
        #expect(make([], now: date(18)).isEmpty)
        #expect(make([], now: date(18), onlyToday: true).isEmpty)
    }

    @Test func groupsByDayNewestDayFirst() {
        let old = item("old", at: date(17, 9))
        let recent = item("recent", at: date(18, 9))
        let sections = make([old, recent], now: date(18, 15))
        #expect(sections.map(\.day) == [date(18, 0), date(17, 0)])
        #expect(sections[0].items == [recent])
        #expect(sections[1].items == [old])
    }

    @Test func itemsWithinDaySortedNewestFirst() {
        let morning = item("morning", at: date(18, 8))
        let evening = item("evening", at: date(18, 20))
        let noon = item("noon", at: date(18, 12))
        let sections = make([morning, evening, noon], now: date(18, 23))
        #expect(sections.count == 1)
        #expect(sections[0].items == [evening, noon, morning])
    }

    @Test func sameTimestampLaterStoredFirst() {
        let stamp = date(18, 10)
        let first = item("first", at: stamp)
        let second = item("second", at: stamp)
        let third = item("third", at: stamp)
        let sections = make([first, second, third], now: date(18, 11))
        #expect(sections[0].items == [third, second, first])
    }

    @Test func onlyTodayKeepsTodayItemsOnly() {
        let yesterday = item("yesterday", at: date(17, 12))
        let today = item("today", at: date(18, 1))
        let sections = make([yesterday, today], now: date(18, 15), onlyToday: true)
        #expect(sections.count == 1)
        #expect(sections[0].items == [today])
    }

    @Test func onlyTodayOffShowsAllDays() {
        let yesterday = item("yesterday", at: date(17, 12))
        let today = item("today", at: date(18, 1))
        let sections = make([yesterday, today], now: date(18, 15), onlyToday: false)
        #expect(sections.count == 2)
    }

    @Test func allHiddenByFilterIsEmpty() {
        let items = [item("a", at: date(16)), item("b", at: date(17))]
        #expect(make(items, now: date(18), onlyToday: true).isEmpty)
    }

    @Test func midnightBoundaryGroupsSeparately() {
        let lastSecond = item("late", at: date(17, 23, 59, 59))
        let firstSecond = item("early", at: date(18, 0, 0, 0))
        let sections = make([lastSecond, firstSecond], now: date(18, 12))
        #expect(sections.map(\.day) == [date(18, 0), date(17, 0)])
        #expect(sections[0].items == [firstSecond])
        #expect(sections[1].items == [lastSecond])
    }

    @Test func midnightBoundaryWithFilter() {
        let lastSecond = item("late", at: date(17, 23, 59, 59))
        let firstSecond = item("early", at: date(18, 0, 0, 0))
        let sections = make([lastSecond, firstSecond], now: date(18, 0, 0, 0), onlyToday: true)
        #expect(sections.flatMap(\.items) == [firstSecond])
        let atLastSecond = make([lastSecond, firstSecond], now: date(17, 23, 59, 59), onlyToday: true)
        #expect(atLastSecond.flatMap(\.items) == [lastSecond])
    }

    @Test func futureCreatedAtHiddenWhenOnlyToday() {
        let future = item("future", at: date(19, 9))
        let today = item("today", at: date(18, 9))
        let filtered = make([today, future], now: date(18, 12), onlyToday: true)
        #expect(filtered.flatMap(\.items) == [today])
    }

    @Test func futureCreatedAtShownWhenNotFiltered() {
        let future = item("future", at: date(19, 9))
        let today = item("today", at: date(18, 9))
        let sections = make([today, future], now: date(18, 12))
        #expect(sections.map(\.day) == [date(19, 0), date(18, 0)])
    }

    @Test func doneItemsAreKept() {
        let done = item("done", at: date(18, 9), done: true)
        let sections = make([done], now: date(18, 12), onlyToday: true)
        #expect(sections[0].items == [done])
    }

    @Test func sectionIdentityIsDay() {
        let sections = make([item("a", at: date(18, 9))], now: date(18, 12))
        #expect(sections[0].id == date(18, 0))
    }

    @Test func resultIsStableAndDoesNotMutateInput() {
        let items = [item("a", at: date(18, 9)), item("b", at: date(17, 9)), item("c", at: date(18, 9))]
        let copy = items
        let first = make(items, now: date(18, 12))
        let second = make(items, now: date(18, 12))
        #expect(first == second)
        #expect(items == copy)
    }
}
