# Design: macOS Floating To-Do Widget

## Technical Approach

Greenfield SwiftPM package, Swift 6 language mode (strict concurrency), hexagonal. Dependencies point inward only: Domain <- Application <- (Infrastructure, UI) <- App. Window behavior follows the proposal (NSPanel + SwiftUI, level `.screenSaver`); every window-level claim is empirical and gated by the spike HU.

## Package Layout

| Target | Kind | Contents | Imports |
|---|---|---|---|
| `TodoDomain` | lib | `TodoItem` | Foundation |
| `TodoApplication` | lib | `TodoRepository` port, use cases, `TodoListViewModel` | Domain, Observation |
| `TodoInfrastructure` | lib | `JSONTodoRepository`, `WindowPositioner` (pure), `FloatingPanel` (NSPanel), `PanelController` | Application, AppKit |
| `TodoUI` | lib | atoms, `TodoListView`, `TodoListContainer` | Application, SwiftUI |
| `SpTodoList` | executable | `main.swift`, `AppDelegate`, `CompositionRoot`, `StatusItemController` | all |
| `*Tests` (4) | test | Swift Testing, one per lib | own lib |

Infrastructure never imports UI: `PanelController` receives a generic `NSView`; the App builds `NSHostingView(TodoListContainer)`.

## Contracts

```swift
public struct TodoItem: Identifiable, Hashable, Codable, Sendable {
  public let id: UUID; public var title: String; public var isDone: Bool; public let createdAt: Date
}
public protocol TodoRepository: Sendable { func load() throws -> [TodoItem]; func save(_ items: [TodoItem]) throws }
// Use cases: AddTodo (trims, rejects empty), RemoveTodo(id), ToggleTodo(id), LoadTodos
@MainActor @Observable public final class TodoListViewModel { public private(set) var items: [TodoItem]; public private(set) var lastError: TodoError? ... }
```

`TodoItem` codable lives in Domain only for pragmatism; if purity is wanted, a DTO in Infrastructure is the alternative (open question). Use cases are small `Sendable` structs over the port; the VM is `@MainActor` and is the only mutable state holder. Persistence calls are synchronous on MainActor (file is tiny).

## Architecture Decisions

| Decision | Choice | Rejected (why) |
|---|---|---|
| Persistence | `JSONTodoRepository` at `~/Library/Application Support/<bundle-id or "sp-todo-list">/todos.json`, `Data.write(.atomic)`, ISO8601 dates, versioned envelope `{version, items}`; directory created on save; injectable URL for tests | SwiftData (setup/test cost), UserDefaults (not for lists) |
| Corrupt file | On decode failure rename to `todos.corrupt-<timestamp>.json`, return `[]`, surface `lastError`; missing file = `[]`. Never overwrite unreadable data | Silent reset (data loss), crash |
| Repository API | Sync `throws`, `Sendable` | async/actor (needless complexity for tiny file) |
| State | `@Observable` VM, `@MainActor`; views take VM via container only | `ObservableObject` (older), TCA (overkill) |
| Panel | `FloatingPanel: NSPanel`, `.nonactivatingPanel + .borderless`, `canBecomeKey = true`, `canBecomeMain = false`, `isFloatingPanel`, `hidesOnDeactivate = false`, `isMovable = false`, level `.screenSaver`, `collectionBehavior [.canJoinAllSpaces,.canJoinAllApplications,.fullScreenAuxiliary,.stationary]`, shown with `orderFrontRegardless()` | SwiftUI `Window`/`MenuBarExtra` (no level control), WidgetKit (no free text, no floating) |
| Level | Constant chosen by spike; `.statusBar` is the documented fallback, selected in one place (`FloatingPanel.preferredLevel`) | Hardcoding without evidence |
| Positioning | `WindowPositioner.frame(size:, visibleFrame:, margin:) -> CGRect` pure: `x = maxX - w - margin`, `y = maxY - h - margin`. `PanelController` reads `NSScreen.main?.visibleFrame` on every show and on `NSApplication.didChangeScreenParametersNotification`; never cached. Notch handled by `visibleFrame` | Caching frame, `NSScreen.screens.first` |
| Activation | `NSApp.setActivationPolicy(.accessory)` in code at launch (no Info.plist in bare SwiftPM); `NSStatusItem` with menu: Quit (`NSApp.terminate`) | `LSUIElement` (needs bundle; deferred to a later bundling script) |
| Composition | `CompositionRoot` in the executable builds repo -> use cases -> VM -> container -> hosting view -> `PanelController`; sole place that knows concrete types | Service locator/singletons |
| UI | Container-presentational: `TodoListContainer` (binds VM) -> `TodoListView` (pure props + closures) -> atoms `TodoRowView`, `AddTodoField`, `CheckboxButton`, `DeleteButton`. Styling is a placeholder (undecided product item) | Views reading VM directly |

## Data Flow

    AddTodoField -> Container closure -> VM (MainActor) -> UseCase -> TodoRepository(JSON file)
         ^                                   |
         +------- @Observable items ---------+
    NSScreen.visibleFrame -> WindowPositioner -> PanelController.setFrame (show / screen-change)

## File Changes

All new: `Package.swift`; `Sources/{TodoDomain,TodoApplication,TodoInfrastructure,TodoUI,SpTodoList}/...`; `Tests/{...}Tests/...`; modify `openspec/config.yaml` (test command `swift test`, Strict TDD). The spike lives in a throwaway `Sources/Spike` target (or a scratch executable), deleted or folded into HU 7/8.

## Testing Strategy

| Layer | Automated (`swift test`) | Manual |
|---|---|---|
| Domain | invariants, Codable round-trip | - |
| Application | use cases and VM with in-memory fake repo (`@MainActor` tests): add/trim/empty, remove, toggle, load error | - |
| Infrastructure | JSON repo in temp dir: round-trip, missing file, corrupt file quarantine, atomic overwrite; `WindowPositioner` with notch/menu-bar/Dock rects | panel level, Spaces, full-screen, focus |
| UI | construct presentational views with fixtures (compile/smoke); no snapshot tooling | visual check |
| App | composition smoke only | status item Quit, no Dock icon, relaunch persistence, screen change, notch Mac (HU 9 checklist) |

## Spike Decision Criteria (HU 1)

Pass `.screenSaver` if, on the target macOS, the panel: (1) stays above another app's full-screen Space; (2) appears on all Spaces; (3) accepts typed text and Return without activating the app or leaving full-screen; (4) lands top-right under the menu bar and re-lands after display change; (5) does not obstruct menu bar/Control Center interaction. If (5) fails or (1) fails only at `.statusBar`, record the result; if (3) fails with `canBecomeKey`, try `needsPanelToBecomeKey` on the text view. Outcome (level, focus mechanism) is recorded in engram and fixes HU 7 constants.

## Threat Matrix

N/A — no routing, shell, subprocess, VCS/PR automation, executable-file classification, or process-integration boundary.

## Migration / Rollout

No migration; file carries `version: 1` for future migrations.

## Open Questions

- [ ] Spike outcome: final level and focus mechanism.
- [ ] Domain `Codable` vs infrastructure DTO.
- [ ] Panel size, styling, error presentation (undecided product items).
