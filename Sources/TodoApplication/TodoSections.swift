import Foundation
import TodoDomain

/// A group of to-dos created on the same calendar day.
public struct TodoDaySection: Identifiable, Equatable, Sendable {
    /// Start of the day (`calendar.startOfDay(for:)`).
    public let day: Date
    public let items: [TodoItem]
    public var id: Date { day }

    public init(day: Date, items: [TodoItem]) {
        self.day = day
        self.items = items
    }
}

/// Pure grouping of to-dos by creation day, newest day first.
public enum TodoSections {
    /// Items are ordered by `createdAt` descending; ties go to the later-stored item.
    /// A `createdAt` in the future is not "today", so `onlyToday` hides it.
    public static func make(
        items: [TodoItem],
        now: Date,
        calendar: Calendar,
        onlyToday: Bool
    ) -> [TodoDaySection] {
        let ordered = items.enumerated()
            .filter { !onlyToday || calendar.isDate($0.element.createdAt, inSameDayAs: now) }
            .sorted { lhs, rhs in
                if lhs.element.createdAt != rhs.element.createdAt {
                    return lhs.element.createdAt > rhs.element.createdAt
                }
                return lhs.offset > rhs.offset
            }
            .map(\.element)

        var sections: [TodoDaySection] = []
        for item in ordered {
            let day = calendar.startOfDay(for: item.createdAt)
            if let last = sections.last, last.day == day {
                sections[sections.count - 1] = TodoDaySection(day: day, items: last.items + [item])
            } else {
                sections.append(TodoDaySection(day: day, items: [item]))
            }
        }
        return sections
    }
}
