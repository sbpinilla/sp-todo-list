# app-lifecycle Specification

## Purpose

Run as a background (accessory) app with a menu bar status item to quit.

## Requirements

### Requirement: Accessory app

The app MUST run without a Dock icon and MUST show the panel on launch. It MUST NOT register a global hotkey.

#### Scenario: Launch

- GIVEN the app is not running
- WHEN it is launched
- THEN no Dock icon appears and the panel is shown

### Requirement: Status item with Quit

The app MUST show a menu bar status item whose menu has a Quit entry. Choosing Quit MUST terminate the app and remove the panel.

#### Scenario: Quit

- GIVEN the app is running
- WHEN the user chooses Quit from the status item
- THEN the process terminates and the panel disappears

#### Scenario: Data kept on quit

- GIVEN items exist
- WHEN the user quits and relaunches
- THEN the items are restored
