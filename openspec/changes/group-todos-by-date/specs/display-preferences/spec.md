# display-preferences Specification

## Purpose

User display preferences for the to-do list, starting with a persisted "Show only today" filter.

## Requirements

### Requirement: Show only today preference

The system MUST provide a boolean "Show only today" preference, unchecked (false) by default. When checked, the list MUST show only to-dos created on the current calendar day. When unchecked, the list MUST NOT be filtered. The filter MUST NOT alter stored items.

#### Scenario: Default

- GIVEN a fresh install with no saved preference
- WHEN the app launches
- THEN the preference is unchecked and all to-dos are shown

#### Scenario: Filter on

- GIVEN to-dos created today and on earlier days
- WHEN the preference is checked
- THEN only today's to-dos are shown, still grouped under today's separator

#### Scenario: Filter off

- GIVEN the preference is checked
- WHEN the user unchecks it
- THEN all to-dos are shown again, grouped by day

### Requirement: Preference persistence

The system MUST persist the preference across relaunches through a preference port. If no value is stored, it MUST behave as unchecked.

#### Scenario: Relaunch keeps checked state [MANUAL]

- GIVEN the user checked "Show only today"
- WHEN the app is quit and relaunched
- THEN the menu item is checked and the list is filtered

### Requirement: Today evaluation

"Today" MUST be evaluated against the current date each time the list is evaluated (launch, add, toggle, delete, preference change). To-dos with a `createdAt` later than the end of the current day (future) SHOULD be treated as not-today. (Assumption, not confirmed by the user.)

#### Scenario: Day rolled over

- GIVEN the filter is on and an item was created yesterday
- WHEN the list is next evaluated today
- THEN that item is hidden

#### Scenario: Future createdAt (assumption)

- GIVEN an item whose `createdAt` is after today
- WHEN the filter is on
- THEN the item is hidden; when off, it is shown in the newest-first order

### Requirement: Empty and fully-filtered list

When the filter hides every item, the system MUST show only the add field, with no separators.

#### Scenario: All hidden

- GIVEN all to-dos were created before today and the filter is on
- WHEN the list is shown
- THEN only the add field is visible

#### Scenario: Add while filtered

- GIVEN the filter is on
- WHEN the user adds a to-do
- THEN the new item is visible under today's separator
