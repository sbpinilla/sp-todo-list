import SwiftUI

/// Day header row: `01/01/2026 ────────────`.
struct DaySeparatorView: View {
    let presentation: DaySeparatorPresentation

    init(day: Date, calendar: Calendar = .current) {
        self.presentation = DaySeparatorPresentation(day: day, calendar: calendar)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(presentation.label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityLabel(presentation.spokenLabel)
            Rectangle()
                .fill(.secondary.opacity(0.4))
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }
}

#Preview("Day separator") {
    DaySeparatorView(day: Date())
        .padding()
        .frame(width: 280)
}
