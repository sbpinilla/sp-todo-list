# Tasks: macOS Floating To-Do Widget

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~1,100 total, 40-220 per HU |
| 400-line budget risk | Low (per commit) |
| Chained PRs recommended | No (N/A: no PRs) |
| Suggested split | 9 commits on `master`, one per HU |
| Delivery strategy | direct commits on master, conventional, no AI attribution |
| Chain strategy | N/A |

Decision needed before apply: Yes (open items below)
Chained PRs recommended: No
Chain strategy: pending
400-line budget risk: Low

| HU | Est. lines | Focused test | Rollback |
|----|-----------|--------------|----------|
| 1 | ~120 | manual spike | delete spike target |
| 2 | ~90 | `swift test` | revert skeleton |
| 3 | ~60 | `swift test --filter TodoDomainTests` | revert Domain |
| 4 | ~220 | `--filter TodoApplicationTests` | revert Application |
| 5 | ~180 | `--filter TodoInfrastructureTests` | revert JSON repo |
| 6 | ~170 | `swift build` + UI smoke | revert TodoUI |
| 7 | ~170 | `--filter WindowPositionerTests` + manual | revert panel |
| 8 | ~110 | `swift build`; manual run | revert wiring |
| 9 | ~60 | manual checklist | revert fixes |

## Open items (user confirmation required, NOT decided here)
- [x] O1 `TodoItem: Codable` in Domain vs DTO in Infrastructure (affects HU 3, 5). (DECIDED: Codable in Domain, no DTO; engram #654)
- [ ] O2 Storage folder name (`<bundle-id>` vs `sp-todo-list`) (HU 5).
- [ ] O3 Panel size, margin, styling (HU 6, 7).
- [ ] O4 Error presentation for `lastError` (HU 4, 6).

## HU 1: Spike (throwaway) - `spike: validate panel level, focus and placement`
- [x] 1.1 `Package.swift` minimal + `Sources/Spike/main.swift`: accessory app, NSPanel (.nonactivatingPanel+.borderless, canBecomeKey) with a text field.
- [x] 1.2 Try `.screenSaver` then `.statusBar`; verify criteria 1-5 from design; record outcome in engram. (DONE: user reported `.screenSaver` stays above everything; `.statusBar` untested; per-criterion results not itemized, so HU9 manual QA still covers typing, Spaces, notch, display change. Outcome in engram `sdd/macos-floating-todo-widget/spike-outcome`.)
- Satisfies [MANUAL]: full-screen overlay, Space switch, typing w/o activation, notch, display change.

## HU 2: Package skeleton + test command - `build: add swiftpm skeleton and swift test`
- [x] 2.1 Replace spike: `Package.swift` (Swift 6, 5 targets + 4 test targets), placeholder files per target.
- [x] 2.2 Edit `openspec/config.yaml`: test command `swift test`, Strict TDD true.
- [x] 2.3 One trivial test per test target; `swift test` passes.

## HU 3: Domain - `feat(domain): add TodoItem`
- [x] 3.1 RED `Tests/TodoDomainTests/TodoItemTests.swift`: init defaults not-done, Codable round-trip (per O1).
- [x] 3.2 GREEN `Sources/TodoDomain/TodoItem.swift`.

## HU 4: Application - `feat(application): add use cases, port and view model`
- [ ] 4.1 RED `Tests/TodoApplicationTests/`: add valid/trimmed, blank rejected, remove, toggle, toggle twice = original, load error, persist on each change (fake repo).
- [ ] 4.2 GREEN `TodoRepository.swift`, `AddTodo/RemoveTodo/ToggleTodo/LoadTodos.swift`, `TodoListViewModel.swift`.
- Satisfies: todo-management Add, Remove, Toggle, Persistence (port).

## HU 5: JSON repository - `feat(infrastructure): add JSONTodoRepository`
- [ ] 5.1 RED `Tests/TodoInfrastructureTests/JSONTodoRepositoryTests.swift` (temp dir): round-trip same order, missing file = [], corrupt file quarantined + [] no crash, atomic overwrite.
- [ ] 5.2 GREEN `Sources/TodoInfrastructure/JSONTodoRepository.swift` (versioned envelope, ISO8601).
- Satisfies: Persistence restore/missing/corrupt.

## HU 6: UI - `feat(ui): add todo list views`
- [ ] 6.1 Atoms `CheckboxButton`, `DeleteButton`, `AddTodoField`, `TodoRowView` in `Sources/TodoUI/`.
- [ ] 6.2 `TodoListView` (props+closures), `TodoListContainer` (binds VM); smoke test in `Tests/TodoUITests/`.
- Satisfies: add field accepts typing [MANUAL].

## HU 7: Panel - `feat(infrastructure): add floating panel and positioner`
- [ ] 7.1 RED `WindowPositionerTests.swift`: top-right, notch/menu-bar/Dock rects.
- [ ] 7.2 GREEN `WindowPositioner.swift`; `FloatingPanel.swift` (level/focus from HU 1 outcome); `PanelController.swift` (show + didChangeScreenParameters).
- Satisfies: Placement initial, not draggable; Visibility above windows; display change/notch/full-screen/Space [MANUAL].

## HU 8: App wiring - `feat(app): wire composition root and status item`
- [ ] 8.1 `Sources/SpTodoList/{main,AppDelegate,CompositionRoot,StatusItemController}.swift`: accessory policy, panel on launch, Quit item, no hotkey.
- Satisfies [MANUAL]: no Dock icon, Quit removes panel, relaunch restores data.

## HU 9: Hardening - `fix: harden screen change and notch behavior`
- [ ] 9.1 Run full manual checklist (all [MANUAL] scenarios) on a notch Mac; fix findings; `swift test` green.
