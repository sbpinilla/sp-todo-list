# Tasks: Group To-dos by Date

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~700-900 (HU1 ~170, HU2 ~190, HU3 ~230, HU4 ~90, HU5 ~30, HU0 ~25) |
| 400-line budget risk | High (waived by user) |
| Chained PRs recommended | No (N/A: no PRs) |
| Suggested split | One conventional commit per HU directly on `master` |
| Delivery strategy | exception-ok (budget waived, commit on master) |
| Chain strategy | size-exception |

Decision needed before apply: No
Chained PRs recommended: No
Chain strategy: size-exception
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Focused test | Runtime harness | Rollback |
|------|------|--------------|-----------------|----------|
| HU0 | Spec wording | N/A | N/A (docs) | revert commit |
| HU1 | Pure TodoSections | `swift test --filter TodoSectionsTests` | N/A (pure) | revert; no callers |
| HU2 | Port, adapter, VM | `swift test --filter 'UserDefaultsDisplayPreferencesTests|TodoListViewModelTests'` | N/A | revert HU2 |
| HU3 | Sections UI | `swift test --filter DaySeparatorPresentationTests` | manual panel (HU5) | revert HU3 |
| HU4 | Status item toggle | `swift build` | manual menu (HU5) | revert HU4 |
| HU5 | Manual QA | `swift test` | run app | N/A |

## HU0: Spec wording fixes (docs)

- [x] 0.1 Edit `openspec/changes/group-todos-by-date/specs/todo-management/spec.md`: add MODIFIED "Persistence" requirement; scenario "same items and done states restored, in the same stored order (display stays newest-first by day)". Main spec `openspec/specs/todo-management/spec.md:53` says "same order".
- [x] 0.2 Keep requirement name "Status item with Quit" unchanged in `specs/app-lifecycle/spec.md`.
- Commit: `docs(openspec): clarify persistence scenario wording for group-todos-by-date`

## HU1: Pure TodoSections (Application)

- [x] 1.1 RED `Tests/TodoApplicationTests/TodoSectionsTests.swift`: Two days, Same timestamp (reverse-index tie), Empty list, desc order, day boundaries with fixed-TZ calendar, onlyToday filter, future createdAt hidden/shown, done items kept.
- [x] 1.2 GREEN `Sources/TodoApplication/TodoSections.swift`: `TodoSections.make(items:now:calendar:onlyToday:)`, `TodoDaySection` (D1, D2).
- Satisfies: Group by creation day (Two days, Same timestamp, Empty list), Show only today (Filter on/off), Today evaluation (Day rolled over, Future createdAt).
- Commit: `feat(application): add pure TodoSections grouping by creation day`

## HU2: Preference port, adapter, VM wiring

- [x] 2.1 RED `Tests/TodoApplicationTests/FakeDisplayPreferences.swift` + `UserDefaultsDisplayPreferencesTests` in `Tests/TodoInfrastructureTests/` (unique suite, default false, round trip, second instance).
- [x] 2.2 GREEN `Sources/TodoApplication/DisplayPreferences.swift`, `Sources/TodoInfrastructure/UserDefaultsDisplayPreferences.swift`.
- [x] 2.3 RED in `Tests/TodoApplicationTests/TodoListViewModelTests.swift`: `makeViewModel` helper (8 call sites, lines 10-77); new tests: sections with injected now, onlyToday read/persist, storage order unchanged, toggle/delete by id across sections, add-while-filtered.
- [x] 2.4 GREEN `Sources/TodoApplication/TodoListViewModel.swift` (D4: required `preferences`, `now`, `calendar`, `sections`, `toggleOnlyToday`).
- [x] 2.5 Keep build green: `Sources/SpTodoList/CompositionRoot.swift:15` builds `UserDefaultsDisplayPreferences()` and passes it; `TodoListContainer` still passes `items`.
- Satisfies: Preference persistence, Default, Add valid text, Add shows on top, Add while filtered, Toggle and delete by id.
- Commit: `feat(preferences): persist show-only-today and expose sections in view model`

## HU3: UI sections and date label

- [x] 3.1 RED `Tests/TodoUITests/DaySeparatorPresentationTests.swift`: `18/10/2026`, `05/01/2026`, locales `en_US` and `ar`, non-Gregorian calendar, spoken label. Decision at RED: if `Date.VerbatimFormatStyle` misbehaves on Swift 6.4, fall back to per-call `DateFormatter` (`dd/MM/yyyy`, same locale/calendar/TZ).
- [x] 3.2 GREEN `Sources/TodoUI/DaySeparatorPresentation.swift`, `DaySeparatorView.swift` (HStack text + 1pt line hidden from AX, `.isHeader`).
- [x] 3.3 Modify `Sources/TodoUI/TodoListView.swift` (`sections:`, preview at line 77, `!sections.isEmpty`) and `TodoListContainer.swift:18` (pass `viewModel.sections`); no `ListSizing` change. Update `Tests/TodoUITests/PresentationTests.swift` if it builds the view.
- Satisfies: Group by creation day, Empty list, All hidden.
- Commit: `feat(ui): render to-dos in day sections with dd/MM/yyyy separators`

## HU4: Status item toggle

- [x] 4.1 `Sources/SpTodoList/CompositionRoot.swift`: `showOnlyToday`, `toggleShowOnlyToday()`.
- [x] 4.2 `Sources/SpTodoList/StatusItemController.swift`: new init (D9), NSMenuDelegate, checkmark in action and `menuWillOpen`; update `AppDelegate.swift:12` with `[weak root]` closures.
- Satisfies: Menu contents, Toggle item, Quit, Data kept on quit (no unit test: AppKit; build + HU5).
- Commit: `feat(app): add Show only today checkmark item to status menu`

## HU5: Manual QA and hardening

- [x] 5.1 [MANUAL] Confirmed by user ("Todo funciona", 8-step checklist): separator look, panel resize, menu checkmark, relaunch persistence. NOT verified: VoiceOver header, midnight limitation (out of scope), future createdAt, glass look/locales. See `qa-report.md`.
- [x] 5.2 Full `swift build` and `swift test` run (75 Swift Testing tests, 0 failures); results recorded in `qa-report.md`.
- Commit: `docs(openspec): record manual QA for group-todos-by-date`

## Open assumptions (user confirmation needed, not decided)

- Future `createdAt` is treated as not-today (hidden when filter on).
- No midnight regroup (stale until next evaluation).
