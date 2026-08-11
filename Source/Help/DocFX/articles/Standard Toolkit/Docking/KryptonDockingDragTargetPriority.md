# Docking Drag Target Priority

Maintainer guide for drag-target selection used by docking and navigator page drag
feedback (Issue [#3858](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3858)).

## Overview

When the user drags a `KryptonPage` (tab, floating window, or auto-hide content),
`DragManager` / `DockingDragManager` builds a `DragTargetList` and routes mouse
moves through a `DragFeedback` implementation. The feedback object decides:

1. Which visual cues to show (docking diamonds vs solid hot rectangles).
2. Which `DragTarget` is active for the current screen point (and therefore which
   `PerformDrop` runs on mouse-up).

Packages involved:

| Package | Role |
|---------|------|
| `Krypton.Docking` | Generates control-edge, dockspace, workspace, and navigator targets |
| `Krypton.Navigator` | `DragManager`, `DragFeedbackDocking`, `DragFeedbackSolid`, `DragViewController` |
| `Krypton.Workspace` | Cell / sequence geometry for nested drop targets |

## Target generation order

`DockingDragTargetProvider` asks `KryptonDockingManager.PropogateDragTargets` to
walk the docking hierarchy. `KryptonDockingControl` adds targets in this order:

1. **Outer control edges** (`DragTargetControlEdge` with `ExcludeCluster`) — left,
   right, top, bottom for the managed control.
2. **Inner control edges** (when there is free centre space or an inner navigator).
3. **Child elements** via `base.PropogateDragTargets` (dockspaces, workspace cells,
   navigators, floatspaces).

Control edges are therefore **earlier** in the list than nested cell targets. The
source comment in `KryptonDockingControl` states they are higher priority than
cell targets.

## Feedback modes

`DragManager.ResolveDragFeedback` reads `PaletteDragDrop.Feedback`:

| Mode | Implementation | Hit rule |
|------|----------------|----------|
| `Rounded` / `Square` | `DragFeedbackDocking` | Indicator glyph under the mouse |
| `Block` | `DragFeedbackSolid` | First `DragTarget.IsMatch` (`HotRect`) |

Rounded falls back to Square when layered windows or colour depth are insufficient.

## Priority algorithm

### Block feedback (`DragFeedbackSolid`)

- Keep the previous target while `IsMatch` remains true (stickiness).
- Otherwise take `DragTargets.FirstOrDefault(t => t.IsMatch(...))`.
- Because generation puts control edges first, overlapping hot rects favour edges.

### Docking indicator feedback (`DragFeedbackDocking`)

1. Group targets into `DockCluster`s by equal `ScreenRect`, unless
   `DragTargetHint.ExcludeCluster` is set (each exclusive target is its own cluster).
2. On every mouse move, call `Feedback` on **every** cluster so indicators show/hide
   (side effects).
3. Return the **first** non-null indicator hit in cluster list order.
4. Ignore the previous-target parameter; hit-testing always selects the active target.

First-hit matches solid feedback and the control-edge-first generation order.
Choosing last-hit would invert priority and favour nested cells over outer edges.

```
Mouse move
   │
   ▼
foreach cluster (in generation order)
   │  update indicators (always)
   │  if glyph hit && matchTarget == null → keep this hit
   ▼
SolidRect = matchTarget?.DrawRect
return matchTarget
```

## `DragViewController` cancel path

Tab dragging uses `DragViewController` for mouse capture. On Escape or lost focus
while capturing:

- Escape releases capture, quits an in-progress drag, and returns `Captured`
  (false after release).
- Lost focus quits the drag (keeping capture if still dragging) or releases
  capture when not dragging.

There is no button hover state on this controller; do not copy
`ButtonController`’s `_mouseOver = ClientRectangle.Contains(...)` pattern here.
