# Archive Report: macos-floating-todo-widget

**Archived on**: 2026-10-18
**Archive location**: `openspec/changes/archive/2026-10-18-macos-floating-todo-widget/`
**Artifact store**: hybrid (engram + openspec)
**Engram topic key**: `sdd/macos-floating-todo-widget/archive-report`
**Archive status**: closed, no intentional overrides, no partial archive, no stale-checkbox reconciliation

## Final State at Close

Final-state facts below are ranked per the Final-State Authority: (1) persisted `tasks.md`, (2) orchestrator launch facts, (3) `verify-report` and `apply-progress` snapshots.

- **Tasks**: 21/21 checkboxes complete in `tasks.md` (HU1-HU9 and O1-O4). Native status: `taskProgress` 21/21, `archive: ready`, `nextRecommended: archive`, `blockedReasons: []`.
- **Open items O1-O4**: all resolved.
  - O1: `TodoItem` stays `Codable` in the Domain layer (no DTO). Engram #654.
  - O2: storage at `~/Library/Application Support/sp-todo-list/todos.json`. Engram #656.
  - O3: translucent glass style. Size and margin were NOT chosen by the user; the assumed values (~280pt width, ~360pt max height, 12pt margin) remain assumptions. Engram #657.
  - O4: `lastError` shown as a red text line under the add field. Engram #655.
- **Spike (HU1)**: `.screenSaver` window level confirmed by the user to stay above everything. Engram #653.
- **Manual confirmations by the user (notch Mac)**: top-right placement with glass, no Dock icon, typing without activating the app, full-screen overlay, Space switch, not draggable, notch placement, relaunch persistence, panel grows after the fix in `8a897c4`, display change exercised by changing the screen RESOLUTION on a single display (not a second monitor), Quit menu item.
- **Not individually reported by the user**: per-item delete from the UI (logic is covered by tests).
- **Test and build at close**: `swift build` ok; `swift test` 45/45 (Domain 4, Application 17, Infrastructure 15, UI 9). These numbers come from `verify-report` #658 (verification re-run #3, HEAD `6a2980c`); no source changed after that run.
- **Verdict at verification time**: `pass_with_warnings`, 0 CRITICAL, 9/9 requirements, 18/18 scenarios (per `verify-report` #658, 2026-10-18 21:05).

### Commits on master (no PRs)

`9e9f4d3` spike, `214c7f7` openspec docs, `4642010` skeleton and strict TDD, `890f381` domain, `513c71c` application, `01e2a66` infrastructure JSON repo, `e9a0bc5` UI, `16a1958` panel and positioner, `ae0c26f` app wiring, `8a897c4` fix(panel) panel growth after adding to-dos (found in manual QA), `6a2980c` tasks update.

## Specs Synced (openspec/specs)

`openspec/specs/` did not exist before this archive. Each delta spec is a full spec (no ADDED/MODIFIED/REMOVED/RENAMED sections), so each was copied mechanically as the new main spec.

| Domain | Action | Details |
|--------|--------|---------|
| todo-management | Created | 4 requirements (Add, Remove, Toggle done, Persistence) |
| floating-panel | Created | 3 requirements (Placement, Visibility, Non-activating text input) |
| app-lifecycle | Created | 2 requirements (Accessory app, Status item with Quit) |

Copy readback (`diff -r` source vs. destination, verbatim output, all empty):

```
== diff -r openspec/changes/macos-floating-todo-widget/specs/todo-management/spec.md openspec/specs/todo-management/.spec.md.Ujy9rp
(empty)
== diff -r openspec/changes/macos-floating-todo-widget/specs/todo-management/spec.md openspec/specs/todo-management/spec.md
(empty)
== diff -r openspec/changes/macos-floating-todo-widget/specs/floating-panel/spec.md openspec/specs/floating-panel/.spec.md.05Ek8C
(empty)
== diff -r openspec/changes/macos-floating-todo-widget/specs/floating-panel/spec.md openspec/specs/floating-panel/spec.md
(empty)
== diff -r openspec/changes/macos-floating-todo-widget/specs/app-lifecycle/spec.md openspec/specs/app-lifecycle/.spec.md.iY8Idn
(empty)
== diff -r openspec/changes/macos-floating-todo-widget/specs/app-lifecycle/spec.md openspec/specs/app-lifecycle/spec.md
(empty)
```

## Change Folder Move

Snapshot taken before the move, then `git mv` to `openspec/changes/archive/2026-10-18-macos-floating-todo-widget/`. Readback (snapshot vs. archive, verbatim output):

```
== diff -r (snapshot vs archive)
(empty)
```

Source `openspec/changes/macos-floating-todo-widget/` no longer exists. This report is additive and was written after the readback, so it is excluded from the comparison.

## Design Open Questions Sync (verify suggestion S4)

Before the snapshot, the three unchecked Open Questions in `design.md` were marked resolved with pointers to the decisions above. This is the only content edit made to an artifact during archive. Spike outcome, O1, and O2-O4 are reflected there.

## Artifact Observation IDs Read (traceability)

| Artifact | Engram ID | Topic key | Role in this archive |
|----------|-----------|-----------|----------------------|
| proposal | #648 | `sdd/macos-floating-todo-widget/proposal` | Read (openspec file also read) |
| spec | #649 | `sdd/macos-floating-todo-widget/spec` | Read (openspec delta specs are the copied source) |
| design | #650 | `sdd/macos-floating-todo-widget/design` | Read (openspec file also read) |
| tasks | #651 | `sdd/macos-floating-todo-widget/tasks` | Read. Stale on O1-O4 (planning version). Authoritative completion came from `tasks.md` (hybrid rule) |
| verify-report | #658 | `sdd/macos-floating-todo-widget/verify-report` | Read (openspec `verify-report.md` also read, identical verdict) |
| apply-progress | #652 | `sdd/macos-floating-todo-widget/apply-progress` | Read as intermediate snapshot only. Its "Task 9.1 UNCHECKED" line is superseded by `tasks.md` (21/21) and the launch facts |

Supporting decisions read: #653 (spike), #654 (O1), #655 (O4), #656 (O2), #657 (O3), #645 (explore), #646 (visual reference), #647 (research).

## Remaining Warnings Carried Into the Archive (recorded, not resolved)

Per `verify-report` #658 (verification time), still true at close unless marked:

- W2: the strict-TDD per-HU evidence table was lost (apply-progress #652 overwritten by upserts). RED-before-GREEN is not provable from commits.
- W3: a corrupt JSON file is quarantined silently and returns an empty list; the VM does not show `lastError`, although the design said to surface it. Data loss is invisible to the user.
- W4: spec assumptions not confirmed by the user: blank input rejected, corrupt-file quarantine behavior, insertion order (append at end).
- W5: the macOS 26 `glassEffect` branch is not exercised by any automated test.
- W6: the panel-grow fix (`8a897c4`) is verified manually only; the user confirmed it on the notch Mac. No automated test covers `PanelController` size reporting.
- W1 (narrowed): display change verified by a screen resolution change on one display, not a second monitor. Per-item delete UI wiring not individually reported by the user (logic is test-covered).
- W7: no longer applicable. It concerned an unrelated process observed at verification time; no such process was running at that run.

Suggestions still open at close:

- S1: redundant `viewModel.load()` in `TodoListContainer` `.onAppear`.
- S2: `.atl/` is untracked (skill registry). Left untouched by design.
- S3: `spike-checklist.md` moved with the change folder; its results were never filled in. Archived as-is.
- S5: no composition or screen-change smoke test.
- S6: no linter or formatter installed.

S4 (design Open Questions unsynced) is closed by this archive.

## Contradictions

None unresolved. Where a snapshot (`apply-progress` #652 "Task 9.1 UNCHECKED"; engram tasks #651 "O1-O4 open") disagrees with the persisted `tasks.md` (21/21), the higher-ranked `tasks.md` and the launch facts were used.

## Reconciliation and Overrides

None. No stale-checkbox reconciliation, no partial archive, no CRITICAL override. `verify-report` had 0 CRITICAL.
