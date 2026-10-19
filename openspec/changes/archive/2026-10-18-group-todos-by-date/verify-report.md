```yaml
schema: gentle-ai.verify-result/v1
evidence_revision: sha256:e608e4fca723403bf7591d0deab5c52f1ff9f34ea3e047a411701bbd1bcfb341
verdict: pass_with_warnings
blockers: 0
critical_findings: 0
requirements: 8/8
scenarios: 24/24
test_command: swift test
test_exit_code: 0
test_output_hash: sha256:5f79a8c14b2393d19b00816262b762e8d136e35a21c38a5d352a063fa12e1561
build_command: swift build
build_exit_code: 0
build_output_hash: sha256:c77cd73241c4f4e7b387f9f21a79014f7ebbd891f54d250675f6d8e22fd74f84
```

## Verification Report

**Change**: group-todos-by-date
**Version**: N/A (3 delta specs: display-preferences new, todo-management added+modified, app-lifecycle modified)
**Mode**: Strict TDD (runner: swift test, Swift Testing)
**HEAD**: ef4efea (master; only this report is untracked; no source modified by verify). Re-verify #2: commits 159780e (new test) and ef4efea (future-date confirmed) since the previous FAIL.
**Date**: 2026-10-18

**Verdict**: PASS WITH WARNINGS (0 CRITICAL, 5 open WARNING W3-W7, 6 SUGGESTION). Previous verify was FAIL only because todo-management > "Add shows on top" was PARTIAL (W1). It is now COMPLIANT (test `addedItemShowsFirstInTodaySectionWithAndWithoutFilter`, commit 159780e). All 24 scenarios are COMPLIANT or MANUAL-CONFIRMED; 8/8 requirements verified.

### Completeness
| Metric | Value |
|--------|-------|
| Tasks total | 18 (0.1, 0.2, 1.1-1.2, 2.1-2.5, 3.1-3.3, 4.1-4.2, 5.1-5.2, 6.1-6.2) |
| Tasks complete | 18 |
| Tasks incomplete | 0 |

### Build & Tests Execution
**Build**: Passed (`swift build`, exit 0, "Build complete!").
**Tests**: 76 passed / 0 failed / 0 skipped (`swift test`, exit 0, re-run at HEAD ef4efea). Swift Testing: UI 16 tests/4 suites, Infrastructure 18/3, Domain 4/1, Application 38/3. XCTest runners report 0 tests (expected).
```text
✔ Test run with 16 tests in 4 suites passed
✔ Test run with 18 tests in 3 suites passed
✔ Test run with 4 tests in 1 suite passed
✔ Test run with 38 tests in 3 suites passed
```
**Coverage** (previous run, `swift test --enable-code-coverage`, exit 0; not re-run, only one test added): the codecov JSON only contained the Application test product: TodoSections.swift 100% (36/36), TodoListViewModel.swift 98.2% (56/57), AddTodo/LoadTodos/RemoveTodo/ToggleTodo/TodoItem 100%. Infrastructure, UI and SpTodoList files were not in the report -> not available for those (informational, not a failure).
**Quality**: no linter installed; compiler is the type checker (clean build).

### TDD Compliance
| Check | Result | Details |
|-------|--------|---------|
| TDD Evidence reported | WARNING | apply-progress #666/#667 hold per-HU sections with RED/GREEN lines, but as prose, not the full "TDD Cycle Evidence" table (no safety-net / triangulation / refactor columns) |
| All tasks have tests | OK | HU1, HU2, HU3 have test files; HU4 has no unit test (justified, see below); HU0/HU5 are docs |
| RED evidence per HU | WARNING | HU1 RED quoted ("cannot find type 'TodoDaySection'"); HU2 RED quoted ("cannot find type 'DisplayPreferences'"); HU3 has NO RED evidence recorded (only GREEN/decision/smoke); HU4 n/a (no test); HU0/HU5 docs |
| RED-before-GREEN provable from git | WARNING | each HU commit lands tests and code together (bc0e710, 3782574, b6ca94a); ordering cannot be proven from history |
| GREEN confirmed | OK | 76/76 pass on my run (16+18+4+38) |
| Triangulation | OK | TodoSectionsTests 14 cases (tie of 3, two boundary tests, future shown/hidden, filter on/off), DaySeparator 7 cases (padding, year boundary, tz, ar locale, buddhist and japanese calendars), VM 6 new, adapter 3 |
| Safety net for modified files | WARNING | TodoListViewModelTests, CompositionRoot, TodoListView/Container modified; safety-net run not recorded per HU (HU4 notes a full suite run after the change) |

**HU4 case with no unit test**: StatusItemController/CompositionRoot/AppDelegate wiring is AppKit-bound; apply-progress justifies it (only logic is Bool -> NSControl.StateValue ternary). The persistence/toggle logic it delegates (VM.toggleOnlyToday, adapter) is unit-tested; the menu itself is covered only by the user's blanket manual confirmation. Accepted as WARNING, not CRITICAL.

### Test Layer Distribution
| Layer | Tests | Files | Tools |
|-------|-------|-------|-------|
| Unit | 76 (change-related: 14 TodoSections, 7 DaySeparator, 3 adapter, 7 new VM + 8 VM adjusted) | 9 | Swift Testing |
| Integration | 0 | 0 | not installed |
| E2E | 0 | 0 | not installed |

### Assertion Quality
Scanned TodoSectionsTests, DaySeparatorPresentationTests, UserDefaultsDisplayPreferencesTests, FakeDisplayPreferences, TodoListViewModelTests (new tests). No tautologies, no ghost loops, no assertions without production calls. Observations: `emptyInputYieldsNoSections` and `allHiddenByFilterIsEmpty` assert empty but have companion non-empty tests (OK). `spokenLabelIsLocaleAwareAndNotTheNumericLabel` is weak (non-empty, != label, contains "2026") but asserts value-level properties. `FakeDisplayPreferences.writeCount` is never asserted (dead). **Assertion quality**: 0 CRITICAL, 1 WARNING (dead writeCount counter).

### Spec Compliance Matrix
Rule: COMPLIANT needs a passing covering test. [MANUAL] / AppKit scenarios are MANUAL-CONFIRMED only because qa-report.md records the user's answer "Todo funciona" (2026-10-18) to the 8-step checklist; it is a BLANKET confirmation, no per-step detail. Verified-complete = COMPLIANT or MANUAL-CONFIRMED.

**display-preferences (4 requirements, 8 scenarios)**
| Requirement | Scenario | Evidence | Result |
|-------------|----------|----------|--------|
| Show only today preference | Default | UserDefaultsDisplayPreferencesTests.defaultsToFalse; VM onlyTodayIsLoadedFromPreferences (!onlyToday); TodoSectionsTests.onlyTodayOffShowsAllDays; manual step 2 | COMPLIANT |
| Show only today preference | Filter on | TodoSectionsTests.onlyTodayKeepsTodayItemsOnly; VM sectionsFollowOnlyTodayFilter; manual step 3 | COMPLIANT |
| Show only today preference | Filter off | VM sectionsFollowOnlyTodayFilter (toggle back -> 2 sections); onlyTodayOffShowsAllDays; manual step 4 | COMPLIANT |
| Preference persistence | Relaunch keeps checked state [MANUAL] | adapter roundTripsValue + secondInstanceReadsStoredValue (persistence unit-proven); VM toggleOnlyTodayPersistsThroughPort; manual step 7 (blanket) | MANUAL-CONFIRMED |
| Today evaluation | Day rolled over | TodoSectionsTests.midnightBoundaryWithFilter, onlyTodayKeepsTodayItemsOnly (yesterday hidden); VM `sections` is computed from now() on every read | COMPLIANT |
| Today evaluation | Future createdAt (assumption) | TodoSectionsTests.futureCreatedAtHiddenWhenOnlyToday, futureCreatedAtShownWhenNotFiltered (hidden when on, newest-first top section when off). The user CONFIRMED the behavior on 2026-10-18; requirement now MUST with "(Confirmed by the user on 2026-10-18.)" | COMPLIANT |
| Empty and fully-filtered list | All hidden | TodoSectionsTests.allHiddenByFilterIsEmpty; TodoListView renders the list only if `!sections.isEmpty` (inspection). State never exercised manually (checklist did not reach an all-hidden state) | COMPLIANT (logic; view by inspection) |
| Empty and fully-filtered list | Add while filtered | VM addingWhileFilteredShowsNewItem; manual step 5 | COMPLIANT |

**todo-management (3 requirements, 11 scenarios)**
| Requirement | Scenario | Evidence | Result |
|-------------|----------|----------|--------|
| Group by creation day | Two days | TodoSectionsTests.groupsByDayNewestDayFirst + itemsWithinDaySortedNewestFirst; VM sectionsGroupNewestDayFirstUsingInjectedNow; manual step 1 (4 separators) | COMPLIANT |
| Group by creation day | Same timestamp | TodoSectionsTests.sameTimestampLaterStoredFirst (3 items), resultIsStableAndDoesNotMutateInput (repeatable); manual step 1 tie pair | COMPLIANT |
| Group by creation day | Empty list | TodoSectionsTests.emptyInputYieldsNoSections; view hides list when sections empty | COMPLIANT |
| Group by creation day | Toggle and delete by id | VM toggleAndRemoveByIdWorkAcrossSections; manual step 6 | COMPLIANT |
| Group by creation day | Separator look [MANUAL] | DaySeparatorPresentationTests (7 cases, label dd/MM/yyyy); manual steps 1, 8 (blanket) | MANUAL-CONFIRMED |
| Add to-do | Add valid text | UseCaseTests.addAppendsNotDoneItem, addTrimsWhitespace; VM addPersistsAndUpdatesItems | COMPLIANT |
| Add to-do | Add shows on top | VM `addedItemShowsFirstInTodaySectionWithAndWithoutFilter` (real clock `Date.init`, existing same-day item at startOfDay, `add` then asserts the added item is first of the single today section, and still first with `onlyToday` on; passed in this run). Author proved RED by flipping the sort comparator (new test + 4 TodoSections tests failed, then restored; claim from apply notes, not re-executed here). Supported by itemsWithinDaySortedNewestFirst | COMPLIANT |
| Add to-do | Reject blank text | UseCaseTests.addRejectsBlank (3 cases); VM blankAddIsIgnoredWithError | COMPLIANT |
| Persistence | Survives relaunch | JSONTodoRepositoryTests.roundTripPreservesItemsAndOrder (stored order); VM sectionsGroupNewestDayFirst... asserts vm.items == [old, new] while sections are newest-first; manual step 7 | COMPLIANT |
| Persistence | No file | JSONTodoRepositoryTests.missingFileReturnsEmptyList | COMPLIANT |
| Persistence | Corrupt file | corruptFileIsQuarantinedAndReturnsEmpty, corruptQuarantineIsNeverOverwritten | COMPLIANT |

**app-lifecycle (1 requirement, 5 scenarios)**
| Requirement | Scenario | Evidence | Result |
|-------------|----------|----------|--------|
| Status item with Quit | Quit | no unit test (AppKit); Quit path unchanged in intent; previous change MANUAL-CONFIRMED; this change's step 7 (quit and relaunch, blanket) | MANUAL-CONFIRMED |
| Status item with Quit | Data kept on quit | JSONTodoRepositoryTests.roundTripPreservesItemsAndOrder; manual step 7 | COMPLIANT + MANUAL-CONFIRMED |
| Status item with Quit | Menu contents | no unit test (AppKit); manual step 2 (blanket) | MANUAL-CONFIRMED (PARTIAL by strict rule: no automated test) |
| Status item with Quit | Toggle item | logic: VM toggleOnlyTodayPersistsThroughPort + sectionsFollowOnlyTodayFilter; menu item itself manual steps 3-4 (blanket) | MANUAL-CONFIRMED (logic COMPLIANT) |
| Status item with Quit | Checkmark in real menu [MANUAL] | manual steps 2-4 (blanket) | MANUAL-CONFIRMED |

**Compliance summary**: 24 scenarios: 18 COMPLIANT, 6 MANUAL-CONFIRMED (blanket user confirmation), 0 PARTIAL, 0 UNTESTED, 0 FAIL. Requirements: 8/8 verified. Envelope: requirements 8/8, scenarios 24/24 (counted from `### Requirement:` and `#### Scenario:` headings of the three delta specs: 4+3+1 requirements, 8+11+5 scenarios; unchanged since the previous verify). Note: the 3 app-lifecycle UI scenarios rely on the blanket manual answer (see W4); the validator counts them as complete under the project's [MANUAL] convention.

### Correctness (Static Evidence)
| Requirement | Status | Notes |
|------------|--------|-------|
| Show only today preference | Implemented | boolean port, default false, filter applied in TodoSections only; items never mutated |
| Preference persistence | Implemented | UserDefaults key `showOnlyToday`, missing key -> false |
| Today evaluation | Implemented | `sections` computed from now() on each read; future createdAt not same day -> hidden when filtered |
| Empty and fully-filtered list | Implemented | `if !sections.isEmpty` |
| Group by creation day | Implemented | sections newest day first, items newest first, tie by storage index; toggle/delete by id; storage and JSON untouched (no change to JSONTodoRepository or TodoItem in this change) |
| Add to-do (modified) | Implemented | AddTodo unchanged, display derived |
| Persistence (modified) | Implemented | stored order preserved; existing storage-order tests (addKeepsExistingOrder, addingSeveralItemsKeepsAllInOrder..., roundTripPreservesItemsAndOrder) still valid and passing |
| Status item with Quit | Implemented | item "Show only today", separator, Quit; checkmark refreshed in init, menuWillOpen and action |

### Coherence (Design)
| Decision | Followed? | Notes |
|----------|-----------|-------|
| TodoSections pure, in Application (D1, D2) | Yes | enum, no UI/AppKit imports, Foundation + TodoDomain only |
| DisplayPreferences @MainActor port, UserDefaults adapter in Infrastructure (D3) | Yes | Infrastructure imports only Foundation + TodoApplication; does NOT import TodoUI (Package.swift deps confirm) |
| VM init, computed sections, persisted onlyToday (D4) | Yes | required preferences, injectable now/calendar |
| Date label fixed dd/MM/yyyy, en_US_POSIX, locale-independent (D5) | Yes | Date.VerbatimFormatStyle with en_US_POSIX + Gregorian calendar + calendar timezone; tested with ar, buddhist, japanese. Minor: initializer is `(day:calendar:)`, design said `(day:calendar:locale:)` |
| View renders sections, header row, AX trait, no ListSizing change (D6, D7) | Yes | 1pt line fill is `.secondary.opacity(0.4)` rather than `.separator` (cosmetic); VoiceOver header not verified |
| Ownership: root exposes toggle, AppDelegate [weak root] closures, StatusItemController never sees VM (D8, D9) | Yes with naming drift | controller takes closures only; implemented names are `isOnlyToday`/`toggleOnlyToday()`, design/tasks 4.1 said `showOnlyToday`/`toggleShowOnlyToday()` |
| JSON format / storage order unchanged | Yes | no diff to JSONTodoRepository.swift, TodoItem.swift |

### Issues Found
**CRITICAL**: None.

**WARNING**:
- (RESOLVED, was W1) "Add shows on top" now COMPLIANT: test `addedItemShowsFirstInTodaySectionWithAndWithoutFilter` passes in this run.
- (RESOLVED, was W2) Future `createdAt` confirmed by the user on 2026-10-18. Consistency check: requirement text in specs/display-preferences/spec.md (MUST, confirmed note), design.md "Assumptions and Limitations", tasks.md "Open assumptions" + 6.2, and qa-report.md "NOT verified" all state the confirmed behavior. Residual wording drift is only cosmetic (S6).
- W3: Strict-TDD evidence is prose per HU, not a full table; HU3 has no RED evidence; RED-before-GREEN is not provable from commits (tests and code in the same commit, except HU6 whose test-only commit is a gap fix on already-implemented behavior, so its RED rests on the author's comparator-flip claim); no safety-net record.
- W4: Manual evidence is one blanket answer ("Todo funciona") for 8 steps. Menu contents, Toggle item, Quit and the 4 [MANUAL] scenarios depend on it. All-hidden state was never explicitly exercised. NOT verified: VoiceOver header, midnight regroup (out of scope, known limitation), glass look and non-English locales.
- W5: HU4 (StatusItemController/CompositionRoot/AppDelegate) has no automated test; only a compile check and the blanket manual confirmation.
- W6: DaySeparatorView defaults to `Calendar.current` and TodoListView/TodoListContainer do not pass the view model's calendar. In production both are `.current` so they agree; they would diverge if the system time zone changes while the app runs or if a non-current calendar is injected into the VM. Not exercised by any test or by manual QA.
- W7: Dead test code: `FakeDisplayPreferences.writeCount` (Tests/TodoApplicationTests/FakeDisplayPreferences.swift) is never asserted.

**SUGGESTION**:
- S1: TodoSections.make appends with `last.items + [item]` (O(k^2) per day group, array copy per item) and replaces the last section each time. Negligible for a to-do list; could be done in one pass with an index-based append.
- S2: `TodoDaySection.day` already carries the grouping day; pass the VM calendar to DaySeparatorView (or have the VM expose labels) to remove W6 entirely.
- S3: Delta specs contain "(Previously: ...)" annotation lines inside three requirement bodies (todo-management lines 44 and 67, app-lifecycle line 8). They are not stray in the Add to-do block, but they would be merged into the main specs at archive; strip or keep deliberately. Display-preferences "Today evaluation" mixes a normative SHOULD with a parenthetical assumption.
- S4: Align design/tasks names with the code (`isOnlyToday`/`toggleOnlyToday`, `DaySeparatorPresentation(day:calendar:)`) before archive, or note the drift.
- S5: Coverage tooling only reports the Application test product; configure merged coverage to measure Infrastructure/UI changed files.

- S6: Cosmetic drift after the confirmation: scenario heading still reads "Future createdAt (assumption)" in the display-preferences spec; qa-report "Automated evidence" still says 37/75 tests (now 38/76); tasks 5.1 still lists "future createdAt" under NOT verified (historical). Do not rename the heading without care, status matches headings.

### Verdict
PASS WITH WARNINGS (0 CRITICAL, 5 WARNING open + 2 resolved, 6 SUGGESTION). Build and all 76 tests pass; design is followed; all 24 scenarios and 8 requirements verified. Nothing blocks archive. Open warnings W3-W7 are accepted limitations (numbering preserved from the previous report).
