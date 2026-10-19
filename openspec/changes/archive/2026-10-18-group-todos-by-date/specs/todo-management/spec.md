# Delta for todo-management

## ADDED Requirements

### Requirement: Group by creation day

The system MUST display to-dos in sections, one per creation day (by `createdAt`). Each section MUST start with a separator row showing the date in fixed `dd/MM/yyyy` format (not locale-based) and a horizontal line, with that day's items below. Sections MUST be ordered newest day first; items within a section MUST be ordered newest first, with a stable tie-break for equal `createdAt` (the later-stored item first). Storage order and JSON format MUST NOT change. Toggle and delete MUST act by item id and MUST NOT move items between sections.

#### Scenario: Two days

- GIVEN item A created 17/10/2026 and items B, C created 18/10/2026 (C later)
- WHEN the list is shown
- THEN order is "18/10/2026", C, B, "17/10/2026", A

#### Scenario: Same timestamp

- GIVEN items X then Y stored with identical `createdAt`
- WHEN the list is shown, repeatedly
- THEN Y is always above X

#### Scenario: Empty list

- GIVEN no items
- WHEN the list is shown
- THEN no separator is shown, only the add field

#### Scenario: Toggle and delete by id

- GIVEN items in two sections
- WHEN the user toggles one and deletes another
- THEN the right items change and remaining items stay in their sections

#### Scenario: Separator look [MANUAL]

- GIVEN the panel shows two days
- WHEN the user inspects it
- THEN each separator shows the date and a line filling the width, and the panel height fits the content

## MODIFIED Requirements

### Requirement: Add to-do

The system MUST add a new, not-done item, stamped with the current time, when the user submits non-empty text. It MUST be displayed newest-first (top of today's section). The system MUST NOT add an item whose text is empty or whitespace-only.

#### Scenario: Add valid text

- GIVEN a list with 0 items
- WHEN the user submits "Buy milk"
- THEN the list contains one not-done item "Buy milk"

#### Scenario: Add shows on top

- GIVEN a list with an item created today
- WHEN the user submits "Call Ana"
- THEN "Call Ana" appears first under today's separator

#### Scenario: Reject blank text

- GIVEN any list
- WHEN the user submits "   "
- THEN the list is unchanged

### Requirement: Persistence

The system MUST persist every change to a JSON file in Application Support via a `TodoRepository` port, using atomic writes. On launch it MUST restore the saved list, preserving the STORED order of the items. The display order is derived from the stored items (newest first, grouped by creation day) and MUST NOT alter the stored order or the JSON format. If the file is missing, it MUST start with an empty list.

#### Scenario: Survives relaunch

- GIVEN items were added and one toggled done
- WHEN the app is relaunched
- THEN the same items and done states are restored, in the same stored order, and the display stays newest-first grouped by day

#### Scenario: No file

- GIVEN no data file exists
- WHEN the app launches
- THEN an empty list is shown and no error is surfaced

#### Scenario: Corrupt file

- GIVEN the data file is not valid JSON
- WHEN the app launches
- THEN the app SHOULD start with an empty list and MUST NOT crash
