# Archive Report: group-todos-by-date

**Archived**: 2026-10-18
**Artifact store**: hybrid (Engram `sdd/group-todos-by-date/archive-report` + this folder)
**Archive folder**: `openspec/changes/archive/2026-10-18-group-todos-by-date/`
**Branch**: master (no PRs, no push)

## Final State at Close

Final-state authority: launch facts and the tasks artifact outrank the intermediate `verify-report` and `apply-progress` snapshots.

- Tasks: 18/18 complete in the archived `tasks.md` (0 unchecked). No stale-checkbox reconciliation was needed.
- Native status at archive time: `dependencies.archive: ready`, `taskProgress.allComplete: true`, `remediationState.required: false`.
- Tests at close: `swift build` ok; `swift test` 76/76 (UI 16, Infrastructure 18, Domain 4, Application 38). Source: launch facts, which report the state after commit 159780e (W1 test) and ef4efea (W2 confirmation). The verify snapshot #668 (re-verify #2, HEAD ef4efea) records the same 76/76 result.
- Verdict at verification time (per verify #668, 2026-10-18 21:50): PASS WITH WARNINGS, 0 CRITICAL, 0 blockers, requirements 8/8, scenarios 24/24.
- W1 ("Add shows on top" test gap) and W2 (future `createdAt` assumption) were resolved after verification. Fixes landed in 159780e and ef4efea. Per verify #668, both are resolved.

### Commits on master

| Commit | Unit |
|--------|------|
| bc0e710 | HU1 pure TodoSections |
| 3782574 | HU2 preference port, adapter, view model |
| b6ca94a | HU3 UI day sections and separators |
| c4d1b17 | HU4 "Show only today" status menu item |
| b98ebef | HU0 persistence wording (spec) |
| 7d8c2f1 | HU5 manual QA record |
| 159780e | HU6 test closing verify gap W1 |
| ef4efea | HU6 docs confirming future-date assumption (W2) |

### Future `createdAt` behavior (user-confirmed)

To-dos with `createdAt` after today are treated as not-today: hidden when "Show only today" is on, shown newest-first when it is off. The user confirmed this behavior on 2026-10-18 ("Sí"). This is recorded in the `display-preferences` spec under "Today evaluation" with a confirmation note.

## Specs Synced

| Domain | Action | Details |
|--------|--------|---------|
| display-preferences | Created | New capability: 4 requirements, 8 scenarios (full spec copied from the delta) |
| todo-management | Updated | MODIFIED "Add to-do" (+1 scenario "Add shows on top"); MODIFIED "Persistence" (stored vs display order wording); ADDED "Group by creation day" (5 scenarios). Total 5 requirements, 13 scenarios |
| app-lifecycle | Updated | MODIFIED "Status item with Quit" (+3 scenarios: menu contents, toggle item, checkmark [MANUAL]). Total 2 requirements, 6 scenarios |

Merge method: mechanical splice of whole requirement blocks extracted from the delta specs (no model-authored spec text). `(Previously: ...)` annotation lines were stripped from the delta specs before merge (verify S3), so they do not enter the main specs.

## Pre-archive Content Edits (change folder only)

These edits were made before the snapshot and move, inside `openspec/changes/group-todos-by-date/`. No file under `Sources/` or `Tests/` was modified.

- `specs/display-preferences/spec.md`: scenario heading "Future createdAt (assumption)" changed to "Future createdAt". The requirement's confirmation note is kept.
- `qa-report.md`: automated counts updated from "37 tests in 3 suites (75 tests total)" to "38 tests in 3 suites (76 tests total)" (verify S6).
- `tasks.md` 5.1: "future createdAt" removed from the NOT verified list (user-confirmed).
- `specs/todo-management/spec.md` and `specs/app-lifecycle/spec.md`: `(Previously: ...)` lines removed (verify S3). Requirement text and scenarios unchanged.

## Engram Observations Read (traceability)

| Artifact | Topic key | Observation ID |
|----------|-----------|----------------|
| proposal | `sdd/group-todos-by-date/proposal` | #662 |
| spec | `sdd/group-todos-by-date/spec` | #663 |
| design | `sdd/group-todos-by-date/design` | #664 |
| tasks | `sdd/group-todos-by-date/tasks` | #665 |
| verify-report | `sdd/group-todos-by-date/verify-report` | #668 (revision 2) |
| apply-progress (context) | `sdd/group-todos-by-date/apply-progress` | #666, #667 |

Filesystem copies were read as the primary source (hybrid mode, path locators): `proposal.md`, `specs/*/spec.md`, `design.md`, `tasks.md`, `verify-report.md` in this folder.

## Warnings Carried Forward (open at close, not resolved by this archive)

Source: verify-report #668 (at verification time). These are accepted limitations, not CRITICAL.

- **W3** TDD evidence is prose per HU, not the full TDD table. HU3 has no RED evidence recorded. RED-before-GREEN is not provable from commit history, because tests and code land in the same commit (except HU6, whose RED rests on the author's comparator-flip claim). No per-HU safety-net record.
- **W4** Manual evidence is one blanket answer, "Todo funciona", for the 8-step checklist (`qa-report.md`). Menu contents, toggle item, Quit, and the [MANUAL] scenarios depend on it. Not verified: VoiceOver header behavior, automatic midnight regroup (known limitation, out of scope), glass look and non-English locales, and an explicit all-hidden state.
- **W5** HU4 (`StatusItemController`, `CompositionRoot`, `AppDelegate`) has no automated test. Only a compile check and the blanket manual confirmation.
- **W6** `DaySeparatorView` defaults to `Calendar.current`, and the list views do not pass the view model's calendar. They agree in production. Not exercised by tests.
- **W7** `FakeDisplayPreferences.writeCount` is never asserted (dead test code).

Suggestions from verify #668 and their status at close:

- S1 (O(k²) append in `TodoSections.make`): open.
- S2 (pass calendar to `DaySeparatorView`, which would close W6): open.
- S3 (`(Previously: ...)` lines in delta specs): resolved (stripped before merge).
- S4 (design/tasks naming drift `showOnlyToday`/`toggleShowOnlyToday` vs code `isOnlyToday`/`toggleOnlyToday`): open. Not corrected by this archive; the naming drift remains in `design.md` and `tasks.md`.
- S5 (coverage reports only the Application test product): open.
- S6 (cosmetic drift): resolved for the heading, the qa-report counts, and tasks 5.1. Residual, left as historical record: `qa-report.md` line 35 still lists future `createdAt` under NOT verified with a "now user-confirmed" note; `tasks.md` 5.2 records the HU5 run as "75 tests", which is the historical count at that run.

## Record Notes (contradictions and discrepancies)

- Future `createdAt`: `apply-progress` #667 and the spec observation #663 describe it as an unconfirmed assumption. That was true at their write time. The user confirmation of 2026-10-18 and commit ef4efea outrank them, so the archived spec states it as confirmed.
- Artifact store: native status reported `artifactStore: openspec`, while the launch declared hybrid. Both stores were written, as hybrid requires. No store was re-derived for reads.
- Apply-progress locator: native status reported `applyProgress: missing` (no repo path), while Engram holds #666 and #667. They were used as Engram context only.

## Archive Readback (mechanical)

- Main specs: block-level comparison of each merged requirement against its delta block was identical for "Add to-do", "Persistence", "Group by creation day" (todo-management) and "Status item with Quit" (app-lifecycle). `diff -r` of `specs/display-preferences` against the delta was empty.
- Move: `diff -r` of the pre-move snapshot against the archived folder was empty (exit 0). The active `openspec/changes/group-todos-by-date/` folder no longer exists.
- This `archive-report.md` is additive and excluded from the snapshot comparison.

## Not Done

- No push (per launch instructions).
- The user's running `SpTodoList` process was not touched.
- No changes to `Sources/` or `Tests/`.
