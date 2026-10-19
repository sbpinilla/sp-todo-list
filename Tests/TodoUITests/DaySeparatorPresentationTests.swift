import Foundation
import Testing
@testable import TodoUI

@Suite struct DaySeparatorPresentationTests {
    private func calendar(
        _ id: Calendar.Identifier = .gregorian,
        tz: String = "UTC",
        locale: String = "en_US"
    ) -> Calendar {
        var c = Calendar(identifier: id)
        c.timeZone = TimeZone(identifier: tz)!
        c.locale = Locale(identifier: locale)
        return c
    }

    private func date(_ y: Int, _ m: Int, _ d: Int, _ h: Int = 12, tz: String = "UTC") -> Date {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: tz)!
        return c.date(from: DateComponents(year: y, month: m, day: d, hour: h))!
    }

    @Test func formatsDayMonthYear() {
        let p = DaySeparatorPresentation(day: date(2026, 10, 18), calendar: calendar())
        #expect(p.label == "18/10/2026")
    }

    @Test func zeroPadsDayAndMonth() {
        let p = DaySeparatorPresentation(day: date(2026, 1, 5), calendar: calendar())
        #expect(p.label == "05/01/2026")
    }

    @Test func yearBoundary() {
        #expect(DaySeparatorPresentation(day: date(2026, 1, 1, 0), calendar: calendar()).label == "01/01/2026")
        #expect(DaySeparatorPresentation(day: date(2025, 12, 31, 23), calendar: calendar()).label == "31/12/2025")
    }

    @Test func usesCalendarTimeZone() {
        let instant = date(2026, 1, 1, 23, tz: "UTC")
        #expect(DaySeparatorPresentation(day: instant, calendar: calendar(tz: "UTC")).label == "01/01/2026")
        #expect(DaySeparatorPresentation(day: instant, calendar: calendar(tz: "Pacific/Auckland")).label == "02/01/2026")
    }

    @Test func ignoresLocaleDigitsAndOrder() {
        let p = DaySeparatorPresentation(day: date(2026, 10, 18), calendar: calendar(locale: "ar"))
        #expect(p.label == "18/10/2026")
    }

    @Test func ignoresNonGregorianCalendar() {
        let buddhist = calendar(.buddhist)
        #expect(DaySeparatorPresentation(day: date(2026, 10, 18), calendar: buddhist).label == "18/10/2026")
        let japanese = calendar(.japanese, locale: "ja_JP")
        #expect(DaySeparatorPresentation(day: date(2026, 10, 18), calendar: japanese).label == "18/10/2026")
    }

    @Test func spokenLabelIsLocaleAwareAndNotTheNumericLabel() {
        let p = DaySeparatorPresentation(day: date(2026, 10, 18), calendar: calendar())
        #expect(!p.spokenLabel.isEmpty)
        #expect(p.spokenLabel != p.label)
        #expect(p.spokenLabel.contains("2026"))
    }
}
