# HU1 Spike Manual Checklist (outcome: PENDING)

Run from the repo root. Quit via the "Spike" status item > Quit Spike, or Ctrl-C in the terminal.

```
swift run Spike                      # level .screenSaver (default)
swift run Spike --level statusBar    # level .statusBar
SPIKE_LEVEL=statusBar swift run Spike  # same, via env var
```

Test BOTH levels. Record Pass/Fail per level.

| # | Criterion | Do | Expected | screenSaver | statusBar |
|---|-----------|----|----------|-------------|-----------|
| 1 | Placement | Launch | Panel at top-right, just under the menu bar, 12pt margin; not hidden by the notch | | |
| 2 | Full-screen overlay | Put another app in native full screen, switch to its Space | Panel visible above the full-screen app | | |
| 3 | Space switch | Swipe between Spaces (Ctrl+Left/Right) | Panel appears on every Space without re-launch | | |
| 4 | Typing w/o activation | Click the text field in the panel while another app is frontmost, type | Text appears in the field AND the other app stays frontmost (menu bar name unchanged) | | |
| 5 | Notch | On a notch Mac, launch | Panel sits below the menu bar/notch area, not clipped | | |
| 6 | Display change | Change resolution, or plug/unplug a display, or move the menu bar display | Panel re-positions to top-right of the main screen (terminal prints `reposition: ...`) | | |
| 7 | Quit | Status item > Quit Spike, or Ctrl-C | Panel disappears, process exits; no Dock icon during the run | | |

Decision to record in engram (`sdd/macos-floating-todo-widget/spike-outcome`): the chosen level
(.screenSaver if 2 passes with it, otherwise .statusBar if it passes), plus any failed criteria.
