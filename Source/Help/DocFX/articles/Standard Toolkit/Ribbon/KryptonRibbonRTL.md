# Krypton Ribbon right-to-left layout

## Overview

Issue [#2382](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2382) adds Office-style **logical** RTL packing to `Krypton.Ribbon`. `KryptonRibbon` inherits `VisualSimple` (not `VisualSimpleBase`), so it exposes its own `bool RightToLeftLayout` matching WinForms `Form` / `VisualSimpleBase`. That value is copied from the parent `KryptonForm`. `VisualPopup` has the same flag so docker-based overflow, app-menu, and minimized-group popups pack correctly. Do not confuse the property with the Toolkit `RightToLeftLayout` enum (LeftToRight / RightToLeft) used by toast data.

Logical RTL means sequential chrome packs from the reading-order start edge. Glyphs and Arabic/Hebrew text stay readable. Do not use `Graphics.ScaleTransform` or `WS_EX_LAYOUTRTL` for the ribbon body.

## Consumer API

```csharp
RightToLeft = RightToLeft.Yes;
RightToLeftLayout = true; // on the KryptonForm; the ribbon syncs
```

Both flags are required for packing. Setting only `RightToLeft` changes text direction (`AccurateText` / content rendering), not item order.

Do **not** reverse public `RibbonTabs`, `Groups`, or `QATButtons` collections. Collection order stays LTR in the object model; the first item is drawn on the start edge (right when RTL).

## Architecture

```
KryptonForm RightToLeft + RightToLeftLayout
        → KryptonRibbon.SyncRightToLeftLayoutFromParent
        → ViewLayoutDocker.CalculateDock (Left ↔ Right)
        → sequential Layout methods via RibbonRtlLayout
        → draw / hit-test the laid-out rectangles
```

Gate every packing decision on `ViewLayoutContext.IsRightToLeftLayout` or `CommonHelper.IsRightToLeftLayout` (both flags). `RibbonRtlLayout` wraps start-X, item rect, remainder, Left/Right key remap, and popup `ApplyTo`.

WinForms does **not** inherit `RightToLeftLayout`. Without the form sync, caption chrome can flip while the ribbon body stays LTR.

## Layout layers

1. **Plumbing** — `KryptonRibbon` copies `RightToLeftLayout` from the parent `KryptonForm`, hooks `RightToLeftChanged` / `RightToLeftLayoutChanged`, and `PerformNeedPaint(true)`. An explicit ribbon `RightToLeftLayout` remains valid when the parent is not a `KryptonForm`.
2. **Docker chrome** — Tabs area (Office 2007 orb / File tab docked Left), QAT mini overflow (Right), group dialog launcher (Right), and caption injection pick up RTL from `ViewLayoutDocker.CalculateDock`. The orb’s window-edge gap uses `StartBorderWidth`. Caption QAT minibar overlap extends toward the orb on the start edge (`ViewDrawRibbonQATBorder`). Context-title icon filler uses an RTL remainder so the form icon stays on the start edge. `ViewLayoutRibbonScrollPort` treats near as start and far as end.
3. **Sequential packing** — Tabs, groups, QAT contents, group content/cluster/lines/triple, gallery items, and row-center start at `ClientRectangle.Right` and subtract width when RTL.
4. **Popups** — App menu, QAT overflow, minimized groups, and `KryptonGallery` call `RibbonRtlLayout.ApplyTo`.
5. **Keyboard** — Controllers remap Left/Right through `RibbonRtlLayout.HorizontalKey` so existing switch arms follow visual start/end. `GetViewForFirstRibbonTab` stays collection-order (first = visual start). Do not also remap in `ProcessDialogKey` (double-flip).

## Drawing

Prefer `Near` / `Far` alignment. `RenderStandardContent` / `AccurateText` already honor `RightToLeft`. Do not globally mirror bitmaps. Adjust tab chrome paths only if a selected-tab overlap looks wrong after reverse packing.

Hosted editors inherit `RightToLeft` from the ribbon; their `Bounds` come from the RTL layout rectangles.

## Out of scope

- Do not add `KryptonUseRTLLayout` (dialog dual-form switch).
- Do not reverse public collections.
- Design-time selection flaps may stay physical-left (not user-facing).
