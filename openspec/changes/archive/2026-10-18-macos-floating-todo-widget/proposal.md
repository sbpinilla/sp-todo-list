# Proposal: macOS Floating To-Do Widget

## Intent
Native macOS app to add, remove, and mark to-dos done, via an always-visible floating panel pinned top-right under the menu bar, above all windows (incl. other apps' full-screen) on all Spaces.

## Scope
### In Scope
- Fixed (non-draggable) always-expanded panel, main display only, top-right of `visibleFrame`.
- Add / remove / toggle-done; JSON persistence (Application Support) behind `TodoRepository` port.
- `.accessory` app with menu bar status item (Quit).
- Hexagonal layering: Domain, Application, Infrastructure, UI (container-presentational/atomic).
- Workspace test command (`swift test`) documented in `openspec/config.yaml`.

### Out of Scope / Open Questions (undecided, not invented)
- Visual styling (blur/Liquid Glass/colors/size); launch at login; edit/reorder/due dates; click-through; signed .app distribution; per-display behavior beyond main; global hotkey (rejected).

## Capabilities
### New Capabilities
- `todo-management`: add, remove, toggle done, persisted list.
- `floating-panel`: pinned top-right, always-on-top, all Spaces/full-screen, non-activating, text input works.
- `app-lifecycle`: accessory app with status item to quit.
### Modified Capabilities
None (greenfield).

## Approach
SwiftPM package (Domain/Application/Infrastructure libs, executable, tests). `NSPanel(.nonactivatingPanel, .borderless)` hosting SwiftUI via `NSHostingView`; level `.screenSaver`; collectionBehavior `[.canJoinAllSpaces,.canJoinAllApplications,.fullScreenAuxiliary,.stationary]`; `hidesOnDeactivate=false`; `canBecomeKey` override verified in spike. Reposition on `didChangeScreenParametersNotification` using `visibleFrame`. WidgetKit rejected (no free text, no floating).

## Affected Areas
| Area | Impact | Description |
|------|--------|-------------|
| `Package.swift`, `Sources/*`, `Tests/*` | New | Layers + app target |
| `openspec/config.yaml` | Modified | Test command |

## Risks
| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Level over full-screen is empirical, single source | Med | Spike HU first |
| Text focus quirks (non-activating, Tahoe) | Med | Spike; `canBecomeKey` |
| Notch placement | Low | `visibleFrame`/safeAreaInsets |
| `.screenSaver` may cover system UI | Med | Smallest panel; fallback `.statusBar` |
| Bare SwiftPM lacks Info.plist | Med | Set policy in code; bundle script later |

## HU Breakdown (one commit each, <400 lines)
1. Spike: panel level/full-screen, text focus, placement (throwaway-ish).
2. Test command definition + Package skeleton; enable Strict TDD.
3. Domain: `TodoItem`.
4. Application: use cases + `TodoRepository` port + view model.
5. Infrastructure: `JSONTodoRepository` (atomic writes).
6. UI: presentational atoms + container.
7. Infra: `PanelController` + `WindowPositioner`.
8. App wiring: accessory policy, status item/Quit.
9. Hardening: screen-change, notch, manual QA checklist.

## Rollback Plan
No external side effects; revert per-HU commits on `master`. Data file in Application Support is deletable.

## Dependencies
macOS with Swift toolchain; Swift Testing.

## Success Criteria
- [ ] Panel at top-right below menu bar, above full-screen apps, all Spaces.
- [ ] Can type, add, remove, toggle; state survives relaunch.
- [ ] Status item quits app; no Dock icon.
- [ ] `swift test` passes; layers have no inward-violating imports.
