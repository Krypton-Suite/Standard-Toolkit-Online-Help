# Color live preview

Opt-in hover preview for color drop-downs. A highlighted swatch can be shown before it is written to `SelectedColor`. The session is public so later color controls can raise the same stages.

## Overview

`TrackingColor` still reports the swatch under the pointer, and `Color.Empty` when the pointer leaves a swatch. That event does not say whether the drop-down is still open, or whether the user chose No Color.

`LivePreview` (default `false`) adds a session on top of that signal:

| Stage | When | Color to paint |
| --- | --- | --- |
| `Preview` | A swatch is highlighted (mouse or keyboard) | That swatch |
| `Revert` | The pointer leaves the swatches while the drop-down stays open | The color committed when the drop-down opened |
| `Commit` | The user clicks a swatch or No Color | The chosen color, including `Color.Empty` |
| `Cancel` | The drop-down closes without a choice | The color committed when the drop-down opened |

`SelectedColor` and the recent-color list change only on a real choice. A later `Cancel` after `Commit` is ignored.

`Color.Empty` from `TrackingColor` means the pointer left the swatches. No Color is a menu item, so it is committed on click and is not a hover preview.

## Architecture

`KryptonColorLivePreviewSession` (`Krypton.Toolkit`) is the state machine. Color controls call `Open`, `Track`, `Commit`, and `Cancel`. Methods other than `Cancel` do nothing while `Enabled` is false. Setting `Enabled` to false while a drop-down is open cancels the preview.

`IKryptonColorLivePreview` is the surface hosts bind to:

- `LivePreview`
- `IsColorPreviewActive`
- `DisplayColor` (highlighted swatch while a preview is active, otherwise the committed color)
- `ColorPreview`

Implemented by:

- `KryptonColorButton` (color bar uses `DisplayColor` without assigning `SelectedColor`)
- `KryptonColorButtonToolStripMenuItem` (forwards the hosted button)
- `KryptonRibbonGroupColorButton`
- `KryptonRibbonGroupClusterColorButton` (glyph reads `DisplayColor`)

A future color control creates a `KryptonColorLivePreviewSession`, sets `Enabled` from its own `LivePreview` property, and forwards `PreviewChanged`.

`KryptonColorDialog` is the Win32 color dialog. It has no hover callback. Opening More Colors cancels the swatch preview. OK assigns `SelectedColor` and raises `SelectedColorChanged`. It does not raise `ColorPreview` with `Commit`.

## Usage

```csharp
colorButton.LivePreview = true;
colorButton.ColorPreview += (sender, e) =>
{
    sample.BackColor = e.Color.IsEmpty ? Color.White : e.Color;
};
colorButton.SelectedColorChanged += (sender, e) =>
{
    // More Colors OK arrives here. Swatch clicks also raise SelectedColorChanged.
    sample.BackColor = e.Color.IsEmpty ? Color.White : e.Color;
};
```

`KryptonColorLivePreviewEventArgs.CommittedColor` is the color that was committed when the drop-down opened. `Color` is the color to paint for this stage.

## Edge cases

- `LivePreview` defaults to false. Existing `TrackingColor` handlers keep the same payload.
- Highlighting the color that is already committed still previews, then `Commit` restores that color if the bar was showing a different swatch.
- Turning `LivePreview` off while the drop-down is open cancels the preview.
- Keyboard movement uses the same highlight path as the mouse, so it previews as well.