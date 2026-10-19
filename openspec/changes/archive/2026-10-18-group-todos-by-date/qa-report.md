# QA Report: Group To-dos by Date

Date: 2026-10-18. Environment: notch Mac, `swift run SpTodoList`, prepared multi-day `todos.json` (8 to-dos over 4 days, including a same-timestamp pair and done items). The user's original data file was backed up beforehand.

## Manual QA (user evidence)

The user was given an 8-step checklist and answered literally: **"Todo funciona"**. This is recorded as a blanket manual confirmation of the 8 steps below. No per-step detail was reported and none is invented here.

1. Order is newest-first with 4 day separators (18/10/2026, 17/10/2026, 15/10/2026, 01/01/2026), including the tie pair (B above A).
2. Menu item "Show only today" is unchecked by default.
3. Checking it leaves only the 18/10/2026 group.
4. Unchecking it restores all 4 groups.
5. Adding a to-do with the filter on shows it in today's group.
6. Toggling done and deleting keep items in their group.
7. Quit and relaunch keeps the check and the filter.
8. The panel grows with separators and scrolls past ~360pt.

## [MANUAL] scenario mapping

| Scenario | Spec | Steps | Status |
|----------|------|-------|--------|
| Separator look | todo-management | 1, 8 | MANUAL-CONFIRMED (blanket) |
| Checkmark in real menu | app-lifecycle | 2, 3, 4 | MANUAL-CONFIRMED (blanket) |
| Relaunch keeps checked state | display-preferences | 7 | MANUAL-CONFIRMED (blanket) |

## Automated evidence

- `swift build`: Build complete.
- `swift test`: all suites passed, 0 failures. Swift Testing runs: 16 tests in 4 suites, 18 tests in 3 suites, 4 tests in 1 suite, 38 tests in 3 suites (76 tests total). XCTest runners executed 0 tests (expected, no XCTest cases).

## NOT verified

- VoiceOver header behavior: not tested.
- Automatic regroup at midnight: known limitation, out of scope, not tested.
- Future `createdAt` behavior (treated as not-today, hidden when filter is on): unit-tested only; the assumption is now user-confirmed (2026-10-18).
- Glass look and other locales: not tested.
- Risk: `DaySeparatorView` calendar vs view-model calendar could mismatch; not exercised manually.
