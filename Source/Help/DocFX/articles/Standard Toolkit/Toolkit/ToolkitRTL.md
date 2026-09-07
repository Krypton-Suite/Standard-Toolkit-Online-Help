# Krypton.Toolkit right-to-left layout

## Overview

Issue [#2379](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2379) extends the Form/Ribbon two-flag RTL contract to Toolkit visual bases and the remaining control chrome (spin buttons, lists, split/group). Ribbon RTL is [#2382](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2382). Workspace RTL is a separate branch ([#2383](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2383)).

## Contract

| Flag | Meaning |
|------|---------|
| `Control.RightToLeft = Yes` | Reading order; renderer Near/Far content (`AccurateText`, `RenderStandard.RightToLeftIndex`). ComboBox drop glyph follows this for WinForms parity. |
| `RightToLeftLayout = true` | Layout mirroring when **also** `RightToLeft.Yes`. |

Gate: `CommonHelper.IsRightToLeftLayout(control)` (both flags).

Named to match WinForms `Form.RightToLeftLayout` (bool). Distinct from the Toolkit `RightToLeftLayout` enum used by dialog routing.

## Where the layout flag lives

- `VisualControlBase` — ComboBox, TextBox, NUD, ListBox, SplitContainer (`VisualControlContainment`), GroupBox, HeaderGroup, DateTimePicker, TreeView, ListView, MonthCalendar (`VisualSimpleBase`), Ribbon override.
- `VisualPanel` — `KryptonPanel` (does not inherit `VisualControlBase`).
- `VisualContainerControlBase` — container visuals that do not inherit `VisualControlBase`.
- `VisualPopup`, `KryptonForm` — existing bool flags.

`CommonHelper.GetRightToLeftLayout` fast-paths those types, then reflects for WinForms `Form` / `ListView` / `TreeView`.

## Docker double-flip rule

`ViewLayoutDocker.CalculateDock` and `ViewDrawDocker.CalculateDock` swap Left/Right when `IsRightToLeftLayout` is true, unless `IgnoreRightToLeftLayout` is set.

- **Rely on docker** for ButtonSpecs (Near→Left, then docker flips) and GroupBox/HeaderGroup Left/Right captions.
- **Or** set `IgnoreRightToLeftLayout` and assign docks yourself (`KryptonDateTimePicker`, CheckBox/RadioButton `UpdateForOrientation`).

Never both.

## Helpers

`ToolkitRtlLayout` (`Krypton.Toolkit/General/ToolkitRtlLayout.cs`): `IsRtl`, `MirrorDock`, `ApplyTo` (copy both flags onto a hosted control), `FlipHorizontal`, `MapNearFar`.

## Per-control notes

- **NumericUpDown / DomainUpDown:** `UpDownAlign` Left when both flags, Right otherwise.
- **ListBox / CheckedListBox:** inner native `RightToLeft` only (WinForms `ListBox` has no layout bool). Scrollbar moves with native RTL.
- **RichTextBox:** inner `RightToLeft`. Paragraph `SelectionAlignment` is unchanged (Left remains Left).
- **ComboBox drop:** still keys off `RightToLeft` alone (WinForms combo parity). ButtonSpecs use docker + layout flag.
- **CheckBox / RadioButton:** glyph side from `RightToLeft`; docker Ignore so both flags do not invert twice.
- **KryptonHScrollBar / KryptonVScrollBar:** no thumb reversal; list RTL is native VScroll-on-the-left.
- **Context menu:** `Show` copies both flags from the caller onto `VisualContextMenu`. Item docks rely on docker flip (do not also MirrorDock). Submenus use `ShowHorz = Before`; Left/Right keys swap; split hit-test uses the separator side; chevron is flipped. Horizontal `ViewLayoutStack` reverses column order.
- **TaskDialog:** owner flags copy onto the dialog form; element `TableLayoutPanel`s set `RightToLeft` only when both flags are on (so icon/text/footer columns reverse). Heading Near/Far maps through `MapNearFar`.
- **PropertyGrid:** host `RightToLeft` is forwarded to `InternalPropertyGrid` and its children. Native category UI is not rewritten.
- **CommandLink:** docker packs the arrow to the start edge; `CommandLinkArrowHelper.GetDefaultArrowImage(..., rightToLeft: true)` supplies a mirrored arrow when both flags are set.
- **MonthCalendar:** both flags pack the day-name row and date grid from the start edge (first weekday on the right). Do not also reverse the day index. Prev/Next ButtonSpecs stay Near/Far Left/Right and rely on docker flip.
