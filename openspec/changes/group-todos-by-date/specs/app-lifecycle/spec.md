# Delta for app-lifecycle

## MODIFIED Requirements

### Requirement: Status item with Quit

The app MUST show a menu bar status item whose menu has a "Show only today" item and a Quit entry. "Show only today" MUST display a checkmark if and only if the preference is on, and choosing it MUST toggle the preference. Choosing Quit MUST terminate the app and remove the panel.
(Previously: the menu only had a Quit entry.)

#### Scenario: Quit

- GIVEN the app is running
- WHEN the user chooses Quit from the status item
- THEN the process terminates and the panel disappears

#### Scenario: Data kept on quit

- GIVEN items exist
- WHEN the user quits and relaunches
- THEN the items are restored

#### Scenario: Menu contents

- GIVEN a fresh install
- WHEN the status item menu is built
- THEN it has "Show only today" (unchecked) and Quit

#### Scenario: Toggle item

- GIVEN "Show only today" is unchecked
- WHEN the user chooses it
- THEN it becomes checked and the list is filtered; choosing again unchecks and unfilters

#### Scenario: Checkmark in real menu [MANUAL]

- GIVEN the filter is on
- WHEN the user opens the real menu bar menu
- THEN the checkmark is visible next to "Show only today"
