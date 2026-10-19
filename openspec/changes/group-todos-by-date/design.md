# Design: Group To-dos by Date

## Technical Approach

Storage stays append-ordered (JSON untouched). Display order is derived by a pure function `TodoSections.make` in `TodoApplication`. The view model exposes `sections` (computed) and `onlyToday` (persisted through a port). `TodoListView` renders sections with a header row. The status item gets a checkmark item. No `ListSizing` change is needed (see D6).

## Architecture Decisions

| # | Decision | Rejected | Rationale |
|---|----------|----------|-----------|
| D1 | `enum TodoSections { static func make(items:now:calendar:onlyToday:) -> [TodoDaySection] }`. Steps: enumerate (index), filter `calendar.isDate(createdAt, inSameDayAs: now)` when `onlyToday`, sort by `(createdAt desc, index desc)`, then group adjacent items by `calendar.startOfDay(for:)`. | Reordering storage; sorting in the view | Pure and deterministic; unit-testable with no UI; no migration. Sorted-desc input makes same-day items contiguous, so one pass is enough. |
| D2 | `TodoDaySection: Identifiable, Equatable, Sendable { day: Date (startOfDay); items: [TodoItem]; id = day }` | Dictionary by day | Ordered and ForEach-friendly. |
| D3 | Port `@MainActor public protocol DisplayPreferences: AnyObject { var showOnlyToday: Bool { get set } }` in Application. Adapter `UserDefaultsDisplayPreferences(defaults: UserDefaults = .standard)`, key `showOnlyToday`, default `false`, in Infrastructure. Fake `FakeDisplayPreferences` in Tests/TodoApplicationTests. | Non-isolated protocol (needs Sendable plumbing for a main-only consumer); `@AppStorage` (couples UI to storage) | Matches `@MainActor` VM. Suite injection gives isolated adapter tests. |
| D4 | VM `init(repository:, preferences:, now: @escaping () -> Date = Date.init, calendar: Calendar = .current)`. `preferences` is required. `public private(set) var onlyToday` is initialised from the port. `setOnlyToday(_:)` / `toggleOnlyToday()` update the property and write to the port. `public var sections: [TodoDaySection]` is computed from `items`, `onlyToday` and `now()`. | Default in-memory preference in production code; a stored `sections` copy | Explicit composition. Computed `sections` cannot go stale relative to `items` and reads `onlyToday` (observed), so SwiftUI re-evaluates. Existing VM tests move to a `makeViewModel` helper with the fake. |
| D5 | Date label: `DaySeparatorPresentation(day:calendar:locale:)` in TodoUI, with `text` and `spokenLabel`. `text` uses `Date.VerbatimFormatStyle("\(day: .twoDigits)/\(month: .twoDigits)/\(year: .padded(4))")` with `locale: en_US_POSIX`, a Gregorian `Calendar`, and `timeZone: calendar.timeZone`. `spokenLabel` is `Date.FormatStyle(date: .complete, time: .omitted, locale:, calendar:, timeZone:)`, for example "Sunday, 18 October 2026". | Locale `.numeric` format (rejected by the proposal); a shared static `DateFormatter` (not Sendable) | Fixed output regardless of locale, digits or calendar. The group boundary uses the injected calendar's time zone, so label and group agree. If the Verbatim API misbehaves, fall back to a per-call `DateFormatter` with the same locale, calendar and time zone and `dateFormat "dd/MM/yyyy"`. |
| D6 | View: `TodoListView(sections:)` replaces `items:`. `ForEach(sections) { s in DaySeparatorView(s.day); ForEach(s.items) { TodoRowView } }` inside the existing `LazyVStack`. Header = `HStack(Text(label), line)` where the line is a 1pt `Rectangle().fill(.separator)` with `.accessibilityHidden(true)`. The header carries `.accessibilityAddTraits(.isHeader)` and `.accessibilityLabel(spokenLabel)`. Identity: header by `day`, rows by `item.id`. Toggle and delete closures stay id-based (`onToggle(item.id)`). No `ListSizing` change: the `onGeometryChange` on the `LazyVStack` already measures headers, so `ListSizing.height` is unchanged and `PanelController.contentSizeDidChange` re-anchors as before. | Adding a header-height constant to `ListSizing` (duplicates the measurement); a flat enum row list | The proposal's "include separator height in ListSizing" is superseded by measurement. Manual QA checks it. |
| D7 | Empty state: `if !sections.isEmpty` replaces `!items.isEmpty`. With the filter on and no to-dos today, only the add field shows. | Placeholder text | No product decision beyond the proposal. |
| D8 | Ownership: `CompositionRoot` builds `UserDefaultsDisplayPreferences` and the VM, and exposes `var showOnlyToday: Bool` and `func toggleShowOnlyToday()`. `AppDelegate` passes closures with `[weak root]`. `StatusItemController` knows nothing about the VM. | Giving the VM to `AppDelegate`; building the status item inside the root | Keeps one composition root for state. The controller stays AppKit-only. |
| D9 | `StatusItemController(isOnlyToday: () -> Bool, onToggleOnlyToday: () -> Void, onQuit:)`. Menu: "Show only today" (`#selector`), separator, "Quit". It is an `NSMenuDelegate`. `menuWillOpen` and the action handler both set `item.state = isOnlyToday() ? .on : .off`. | KVO; stored duplicate state | One source of truth, the VM. |

## Data Flow

    NSMenuItem ─► onToggleOnlyToday ─► CompositionRoot ─► VM.toggleOnlyToday ─► DisplayPreferences (UserDefaults)
                                                             │ (@Observable)
    VM.items + onlyToday + now() ─► TodoSections.make ─► sections ─► TodoListContainer ─► TodoListView
                                                                                   │
                                      onGeometryChange ─► PanelController.contentSizeDidChange

## File Changes

| File | Action |
|------|--------|
| `Sources/TodoApplication/TodoSections.swift` | Create (`TodoSections`, `TodoDaySection`) |
| `Sources/TodoApplication/DisplayPreferences.swift` | Create |
| `Sources/TodoApplication/TodoListViewModel.swift` | Modify (D4) |
| `Sources/TodoInfrastructure/UserDefaultsDisplayPreferences.swift` | Create |
| `Sources/TodoUI/DaySeparatorPresentation.swift`, `DaySeparatorView.swift` | Create |
| `Sources/TodoUI/TodoListView.swift`, `TodoListContainer.swift` | Modify (`sections`) |
| `Sources/SpTodoList/CompositionRoot.swift`, `AppDelegate.swift`, `StatusItemController.swift` | Modify |
| `Tests/...` | `TodoSectionsTests`, `FakeDisplayPreferences`, `UserDefaultsDisplayPreferencesTests`, `DaySeparatorPresentationTests`; update `TodoListViewModelTests` |

## Concurrency

The VM, port, adapter, root and controller are all `@MainActor`. `Calendar`, `Date` and `TodoDaySection` are `Sendable`. The `now` closure is main-actor-bound and not `Sendable`. There are no new isolation boundaries. `NSMenuDelegate` is implemented on the `@MainActor` class.

## Assumptions and Limitations

- A future `createdAt` is treated as not-today: hidden when the filter is on, and shown in its own top section when it is off (assumption).
- Stale today: "now" is read on each evaluation (add, toggle, delete, option toggle, launch). There is no midnight regroup, which is a documented limitation.
- `add` stamps `createdAt` with the real clock (`AddTodo`), while the VM `now` is injectable. VM tests preload items with explicit dates.

## Testing Strategy

| Layer | Approach |
|-------|----------|
| Application unit (Swift Testing, RED first) | `TodoSectionsTests`: desc order, same-timestamp reverse-index tie-break, multi-day grouping, day boundaries with a fixed-time-zone calendar, onlyToday filter, future date, empty input, done items kept. VM: `sections` with injected `now`; `onlyToday` is read from and persisted to the fake; storage order is unchanged. |
| Existing tests | `addKeepsExistingOrder`, `addingSeveralItemsKeepsAllInOrder` and `roundTripPreservesItemsAndOrder` stay valid because they assert storage. Only VM construction changes. |
| Infrastructure | The adapter uses a unique suite name (`removePersistentDomain` in teardown). Tests cover default false, a round trip, and a second instance reading the stored value. |
| UI unit | `DaySeparatorPresentation`: `18/10/2026` and zero-padding (`05/01/2026`) under both `en_US` and `ar` locales and a non-Gregorian calendar; spoken label with injected locale. |
| Manual (HU5) | Real panel appearance on glass, resize on add and delete, menu checkmark, relaunch persistence, VoiceOver header, midnight limitation. Display-change QA remains. |

## Threat Matrix

N/A: no routing, shell, subprocess, VCS/PR automation, executable-file classification, or process-integration boundary.

## Migration / Rollout

No migration. One commit per HU in order (1 sections, 2 port+adapter+VM, 3 UI, 4 menu, 5 QA). Rollback is a reverse revert; the `showOnlyToday` key is inert. The HU2 and HU3 commits must keep `swift test` and the build green. HU2 changes the VM API, but `TodoListContainer` still passes `items` until HU3.

## Open Questions

- [ ] Verify `Date.VerbatimFormatStyle` behaves as D5 specifies on Swift 6.4 during HU3 RED. The fallback is a per-call `DateFormatter`.
