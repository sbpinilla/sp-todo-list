# floating-panel Specification

## Purpose

A fixed, always-visible, always-expanded panel showing the to-do list on the main display.

## Requirements

### Requirement: Placement

The panel MUST be anchored at the top-right of the main display's visible frame, directly below the menu bar, and MUST be recomputed on each show and on display parameter changes. It MUST NOT be draggable. It MUST always show the full list (no collapsed state).

#### Scenario: Initial position

- GIVEN a main display with a menu bar
- WHEN the panel is shown
- THEN its top-right corner touches the visible frame's top-right (plus margin)

#### Scenario: Not draggable

- GIVEN the panel is shown
- WHEN the user drags its background
- THEN the panel does not move

#### Scenario: Display change (MANUAL)

- GIVEN the panel is shown
- WHEN the resolution changes or a display is connected/disconnected
- THEN the panel re-anchors top-right on the main display

#### Scenario: Notch display (MANUAL)

- GIVEN a notched Mac
- WHEN the panel is shown
- THEN it is fully visible and not clipped by the notch

### Requirement: Visibility

The panel MUST stay visible when the app is inactive, MUST appear on all Spaces, and MUST render above other apps' windows, including full-screen apps. It MUST NOT appear in the Dock or window cycling.

#### Scenario: Above windows

- GIVEN another app is frontmost
- WHEN the panel is shown
- THEN it remains visible above that app's windows

#### Scenario: Full-screen overlay (MANUAL)

- GIVEN another app is full-screen
- WHEN the user views that Space
- THEN the panel is visible above the full-screen content

#### Scenario: Space switch (MANUAL)

- GIVEN the panel is visible
- WHEN the user switches Spaces
- THEN the panel is visible in the new Space

### Requirement: Non-activating text input

Interacting with the panel MUST NOT activate the app or exit another app's full-screen Space. The add field MUST accept typing.

#### Scenario: Type in add field (MANUAL for full-screen)

- GIVEN the panel is visible over another app
- WHEN the user clicks the add field and types
- THEN the text is entered and the other app stays frontmost
