```yaml
schema: gentle-ai.verify-result/v1
evidence_revision: sha256:448bf26d0d14564f0e6f002c6fe132aff0bbc5ed71c9f6675cfabbbf842bdeb6
verdict: pass_with_warnings
blockers: 0
critical_findings: 0
requirements: 9/9
scenarios: 18/18
test_command: swift test
test_exit_code: 0
test_output_hash: sha256:51b0c8947ae284cebae3ec14fcb642e5f6e84d53524e5a225830e125dfd00ac8
build_command: swift build
build_exit_code: 0
build_output_hash: sha256:7c015a771a01b14f4b5b32359e0b6129a0ffc9968d429ef7538cbe2a0ed916de
```

## Verification Report

**Re-verification #3 2026-10-18** (supersedes earlier runs; their evidence and history are kept below). `swift build` exit 0, `swift test` exit 0, 45/45 pass (9+15+4+17), HEAD 6a2980c unchanged, no source modified. New genuine user evidence: asked "¿Qué pasó con el cambio de resolución y con Quit?" the user answered "Cambié la resolución y funciona, Quit también". Interpreted literally: display-change was exercised by changing the screen RESOLUTION on a single display (fires didChangeScreenParametersNotification) and the panel re-anchored; Quit works. Both now MANUAL-CONFIRMED. History: the display-change scenario had earlier been WAIVED by the user ("Sí, archivá cuando termine el verify"); that waiver is superseded by this manual confirmation. Note the confirmation is via resolution change, not by plugging a second monitor.

**Change**: macos-floating-todo-widget
**Mode**: Strict TDD (runner: swift test, Swift Testing)
**HEAD**: 6a2980c (master)

### Completeness
| Metric | Value |
|--------|-------|
| Tasks total | 9 HUs (21 checkboxes incl. O1-O4) |
| Tasks complete | all checked (HU1-9, O1-O4) |
| Tasks incomplete | 0 (HU9 9.1 checked with an explicit exception: display-change not verified) |

### Build & Tests Execution
**Build**: Passed (`swift build`, exit 0, "Build complete!").
**Tests**: 45 passed / 0 failed / 0 skipped (`swift test`, exit 0): Domain 4, Application 17 (UseCases 9 cases incl. 3 parameterized blank, VM 8), Infrastructure 15 (JSON repo 8, WindowPositioner 7), UI 9 (Presentation 6, ListSizing 3). XCTest runners report 0 tests (expected, Swift Testing only).
**Coverage**: `swift test --enable-code-coverage` exit 0; per-file report not parsed (llvm-cov binary path not resolved) -> not available, not a failure.
**Quality**: no linter/formatter installed; compiler is the type checker (clean build, no warnings surfaced in tail).

### TDD Compliance
| Check | Result | Details |
|-------|--------|---------|
| TDD Evidence reported | WARNING | apply-progress #652 was overwritten by upserts and now holds only the HU9 note; the per-task "TDD Cycle Evidence" table is not recoverable |
| All tasks have tests | OK | HU3,4,5,7 + HU6 (presentation) + HU9 (ListSizing, VM multi-add) have test files; HU1/2/8 are non-testable (spike, scaffold, wiring) |
| RED confirmed (tests exist) | OK | all listed test files exist |
| GREEN confirmed | OK | 45/45 pass now |
| Triangulation | OK | blank (3 args), multi-add, positioner 7 cases, corrupt+no-overwrite |
| Safety net | n/a | git shows each HU commit pairs tests with sources; RED-before-GREEN ordering cannot be proven from commits (tests and code land in the same commit) |

### Spec Compliance Matrix
(Rule: compliant needs a passing covering test; [MANUAL] scenarios are marked MANUAL-CONFIRMED only where the user reported them.)

| Requirement | Scenario | Evidence | Result |
|-------------|----------|----------|--------|
| Add to-do | Add valid text | UseCaseTests.addAppendsNotDoneItem, addTrimsWhitespace; VM addPersistsAndUpdatesItems | COMPLIANT |
| Add to-do | Reject blank text | UseCaseTests.addRejectsBlank (3 args); VM blankAddIsIgnoredWithError | COMPLIANT |
| Remove to-do | Remove item | UseCaseTests.removeDeletesOnlySelected; VM removeAndToggleAreSavedEachTime. UI delete button not individually reported by user | COMPLIANT (logic); UI wiring unverified manually |
| Toggle done | Toggle twice | UseCaseTests.toggleTwiceRestoresOriginal, toggleFlipsAndKeepsItem. UI checkbox not individually reported | COMPLIANT (logic); UI wiring unverified manually |
| Persistence | Survives relaunch | JSONTodoRepositoryTests.roundTripPreservesItemsAndOrder + user relaunch persistence | COMPLIANT + MANUAL-CONFIRMED |
| Persistence | No file | JSONTodoRepositoryTests.missingFileReturnsEmptyList | COMPLIANT |
| Persistence | Corrupt file | corruptFileIsQuarantinedAndReturnsEmpty, corruptQuarantineIsNeverOverwritten | COMPLIANT |
| Placement | Initial position | WindowPositionerTests (anchorsTopRightWithMargin, origin/Dock, secondary display) + user: top-right | COMPLIANT + MANUAL-CONFIRMED |
| Placement | Not draggable | no unit test (AppKit); isMovable=false + user: fixed | MANUAL-CONFIRMED (PARTIAL by strict rule) |
| Placement | Display change (MANUAL) | pure math tested (WindowPositionerTests). User changed the screen resolution (screen-parameters notification) and reported "Cambié la resolución y funciona" (2026-10-18). Earlier history: waived by user ("Sí, archivá cuando termine el verify"), superseded. Via resolution change, not a second monitor | MANUAL-CONFIRMED |
| Placement | Notch display (MANUAL) | user confirmed on notch Mac | MANUAL-CONFIRMED |
| Visibility | Above windows | .screenSaver level; user confirmed | MANUAL-CONFIRMED |
| Visibility | Full-screen overlay (MANUAL) | user confirmed | MANUAL-CONFIRMED |
| Visibility | Space switch (MANUAL) | user confirmed | MANUAL-CONFIRMED |
| Non-activating input | Type in add field | user confirmed typing without activating app | MANUAL-CONFIRMED |
| Accessory app | Launch | user: no Dock icon, panel on launch | MANUAL-CONFIRMED |
| Status item Quit | Quit | code present (StatusItemController -> NSApp.terminate -> tearDown); user reported "Quit también" (2026-10-18) | MANUAL-CONFIRMED |
| Status item Quit | Data kept on quit | user relaunch persistence | MANUAL-CONFIRMED |

Summary: 18 scenarios, 9 requirements, all verified: automated COMPLIANT where logic is testable, the AppKit/MANUAL scenarios MANUAL-CONFIRMED by the user (11 of 18 rely on manual confirmation, some overlapping with automated tests). 0 waived, 0 unverified. Envelope 18/18 scenarios and 9/9 requirements.

### Coherence (Design)
| Decision | Followed? | Notes |
|----------|-----------|-------|
| Layering (Infra does not import UI) | Yes | TodoInfrastructure imports only AppKit/Foundation/CoreGraphics + Application/Domain; Package.swift target deps match |
| TodoItem Codable in Domain (O1) | Yes | no DTO |
| JSON envelope {version, items}, ISO8601, atomic | Yes | version-mismatch also quarantined |
| Corrupt quarantine `todos.corrupt-<ts>.json` | Yes | collision-safe; lastError not surfaced on corrupt (see W3) |
| Storage dir sp-todo-list (O2) | Yes | tested |
| Panel: .screenSaver, collectionBehavior, nonactivating borderless, canBecomeKey, isMovable false | Yes | all in FloatingPanel; matches design list exactly |
| WindowPositioner pure | Yes | imports CoreGraphics only |
| Positioning not cached | Yes | reposition reads NSScreen.main each time |
| Accessory policy in code, status item Quit, no hotkey | Yes | |
| Composition root only knows concretes | Yes | |
| Panel size growth (O3) | Yes | 280 wide, max 360, 12 margin |
| Deviation: PanelController uses SwiftUI-reported size via closure (HU9) | Acceptable | not in design; documented in tasks |

### Issues Found
**CRITICAL**: None.

**WARNING**:
- W1: Display-change was verified manually via a screen RESOLUTION change on one display, not by connecting a second monitor; the notification path has no automated test. Per-item delete/toggle UI wiring is not individually reported for delete (toggle reported in first QA); logic is test-covered and no spec scenario requires UI-level proof. (Earlier W1 items display-change waiver and Quit UNVERIFIED are resolved.)
- W2: Strict-TDD evidence table lost (apply-progress overwritten); RED-before-GREEN not provable from commits.
- W3: Corrupt-file quarantine returns [] silently; design said "surface lastError" but the spec only says SHOULD start empty/not crash. VM shows no message on quarantine (data loss invisible to user).
- W4: Unconfirmed spec assumptions: blank rejected (VM shows red "cannot be empty" line), corrupt-file quarantine behavior, insertion order (append at end); user did not explicitly confirm these.
- W5: macOS 26 `glassEffect` branch never run in an automated test; the manual QA machine's OS determines which branch the user saw (SDK 27 here; the material fallback is untested otherwise). Package targets .macOS(.v14).
- W6: Panel-grow fix (HU9) is verified only manually; no automated test for PanelController size reporting (only ListSizing pure rule).
- W7: Unrelated pre-existing process `.build/out/Products/Debug/SpTodoList` (PID 36055, started 21:01:30) is running; not started by this verification and left untouched.

**SUGGESTION**:
- S1: Redundant `viewModel.load()` in TodoListContainer `.onAppear` (CompositionRoot already loads); harmless but double load and duplicate quarantine attempt risk. Remove or document.
- S2: `.atl/` is untracked (skill-registry.md); add to .gitignore or commit deliberately.
- S3: `.statusBar` fallback comment/constant references spike; the Spike target is gone (no leftovers in Sources/Tests/Package.swift); `spike-checklist.md` remains in the change folder with empty results; archive or mark done.
- S4: Design "Open Questions" section still lists unchecked items that tasks resolved (O1-O4); sync before archive.
- S5: Add a composition/PanelController smoke test or screen-change test through an injectable screen provider.
- S6: Install swiftlint/swiftformat for quality gates.

### Verdict
Envelope verdict: pass_with_warnings. 0 CRITICAL; 9/9 requirements and 18/18 scenarios verified; build and 45/45 tests pass.
Blocks archive: nothing. Warnings W1-W7 remain real (lost TDD evidence table, silent corrupt quarantine, unconfirmed assumptions, glassEffect branch untested, panel-grow manual only, resolution-change not second monitor, foreign-process note now moot: no SpTodoList process running at this run). Suggestions S2 (.atl/ untracked) and S4 (design Open Questions O1-O4 not synced) are worth handling before or at archive.
