import Foundation

/// Text shown in a day separator: a fixed `dd/MM/yyyy` label plus a spoken form.
struct DaySeparatorPresentation: Equatable {
    /// Fixed numeric label, independent of the user's locale and calendar system.
    let label: String
    /// Locale-aware complete date, read by VoiceOver instead of the numeric label.
    let spokenLabel: String

    init(day: Date, calendar: Calendar) {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = calendar.timeZone
        gregorian.locale = Locale(identifier: "en_US_POSIX")
        let style = Date.VerbatimFormatStyle(
            format: "\(day: .twoDigits)/\(month: .twoDigits)/\(year: .padded(4))",
            locale: Locale(identifier: "en_US_POSIX"),
            timeZone: calendar.timeZone,
            calendar: gregorian
        )
        self.label = day.formatted(style)
        self.spokenLabel = day.formatted(
            Date.FormatStyle(
                date: .complete, time: .omitted,
                locale: calendar.locale ?? .autoupdatingCurrent,
                calendar: calendar, timeZone: calendar.timeZone
            )
        )
    }
}
