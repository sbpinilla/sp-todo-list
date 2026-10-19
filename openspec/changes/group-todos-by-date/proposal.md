# Proposal: Group To-dos by Date

## Intent

The list is shown oldest-first with no time context. Users want newest-first to-dos grouped by creation day, plus a remembered "Show only today" filter.

## Scope

### In Scope
- Display newest to oldest by `createdAt`; storage stays append-ordered (derived display order).
- Day separator row `dd/MM/yyyy` + horizontal line filling the width (fixed format, not locale-based).
- Status-bar menu item "Show only today" with checkmark; unchecked by default; persisted across relaunches (UserDefaults behind a port).
- "Today" evaluated from the current date whenever the list is evaluated (add, toggle, delete, show, option toggle).

### Out of Scope
- Automatic regroup at midnight while the app stays open (future; user confirmed simple behavior).
- Hiding done items, JSON schema change or migration, locale-based date format, research phase (declined).

## Capabilities

### New Capabilities
- `display-preferences`: persisted "Show only today" preference and its filtering semantics.

### Modified Capabilities
- `todo-management`: MODIFY "Add to-do" (drop "append" wording; display order is newest-first); ADD requirement "Group by creation day" (sections, separator, ordering).
- `app-lifecycle`: MODIFY status-item requirement to include the "Show only today" checkmark item besides Quit.

## Approach

Exploration option A. Pure `TodoSections.make(items, now, calendar, onlyToday)` in Application returns day sections sorted by `createdAt` desc, tie-break by reversed storage index. View model exposes `sections` and `onlyToday`, backed by a preference port with a UserDefaults adapter in Infrastructure. `TodoListView` renders sections with a separator row (date label presentation struct, header accessibility trait, line hidden from AX). `StatusItemController` adds a checkmark `NSMenuItem` with a callback.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| Application (`TodoSections`, preference port) | New | Grouping, sorting, filter |
| Infrastructure (UserDefaults adapter) | New | Persist preference |
| ViewModel, `TodoListView`, `ListSizing` | Modified | Sections, separators, height |
| `StatusItemController`, `AppDelegate` | Modified | Menu item wiring |
| `openspec/specs/*` | Modified | Deltas above |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Same-timestamp ordering | Med | Stable tie-break by reversed index; tested |
| Panel sizing with separators | Med | Include separator height in `ListSizing`; manual QA |
| Glass look unverified | Med | Manual QA on real panel |
| Stale "today" after midnight (known limitation) | Med | Re-evaluated on next list change; regroup deferred |
| Existing order tests (`addKeepsExistingOrder`, etc.) | Low | Update to storage order; add display tests |

## Rollback Plan

One commit per HU on `master`; revert in reverse order. No data migration, so reverting is safe. The stored preference key is inert.

## Dependencies

None external.

## Success Criteria

- [ ] List shows newest first with `dd/MM/yyyy` separators and full-width line.
- [ ] "Show only today" is unchecked by default, filters only when checked, and persists across relaunch.
- [ ] Storage order and JSON unchanged; `swift test` passes under Strict TDD.
- [ ] Panel resizes correctly; manual QA done.

## Proposed HU Breakdown (one commit each)

1. Pure `TodoSections` (group/sort/filter, tie-break) in Application, tests first.
2. Preference port + UserDefaults adapter + view model wiring (`sections`, `onlyToday`).
3. `TodoListView` separators/sections + date label presentation struct + sizing.
4. Status-item checkmark menu wiring in `StatusItemController`/`AppDelegate`.
5. Manual QA and hardening.
