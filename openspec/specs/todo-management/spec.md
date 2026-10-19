# todo-management Specification

## Purpose

Add, remove, and mark to-dos done, with a list that persists across launches.

## Requirements

### Requirement: Add to-do

The system MUST append a new, not-done item when the user submits non-empty text. The system MUST NOT add an item whose text is empty or whitespace-only.

#### Scenario: Add valid text

- GIVEN a list with 0 items
- WHEN the user submits "Buy milk"
- THEN the list contains one not-done item "Buy milk"

#### Scenario: Reject blank text

- GIVEN any list
- WHEN the user submits "   "
- THEN the list is unchanged

### Requirement: Remove to-do

The system MUST remove the selected item from the list.

#### Scenario: Remove item

- GIVEN a list with items A and B
- WHEN the user removes A
- THEN the list contains only B

### Requirement: Toggle done

The system MUST toggle an item between done and not-done, and MUST keep it in the list.

#### Scenario: Toggle twice

- GIVEN a not-done item
- WHEN the user toggles it twice
- THEN it is not-done again

### Requirement: Persistence

The system MUST persist every change to a JSON file in Application Support via a `TodoRepository` port, using atomic writes. On launch it MUST restore the saved list. If the file is missing, it MUST start with an empty list.

#### Scenario: Survives relaunch

- GIVEN items were added and one toggled done
- WHEN the app is relaunched
- THEN the same items and done states are shown, in the same order

#### Scenario: No file

- GIVEN no data file exists
- WHEN the app launches
- THEN an empty list is shown and no error is surfaced

#### Scenario: Corrupt file

- GIVEN the data file is not valid JSON
- WHEN the app launches
- THEN the app SHOULD start with an empty list and MUST NOT crash
