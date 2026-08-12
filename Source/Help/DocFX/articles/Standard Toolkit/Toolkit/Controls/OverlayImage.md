# Overlay Image

Maintainer guide for overlay images on Krypton content controls (`#1205`, `#4157`).

## Overview

Overlay images draw a second glyph on top of a control's main content image (notification badges, status indicators, etc.). Layout and paint live in `RenderStandard`; hosts expose configuration through `OverlayImageValues`.

**Package:** `Krypton.Toolkit`

## Architecture

```text
IContentValues.GetOverlayImage*(state)
        │
        ▼
ViewDrawContent / ViewDrawButton
        │
        ▼
RenderStandard (AllocateImageSpace → Layout → DrawContent)
        │
        ▼
Draw main ImageRect, then OverlayImageRect (paint-only; does not grow preferred size)
```

Key types:

| Type | Role |
|------|------|
| `OverlayImageValues` | Shared bag: default `Image`, transparent color, `Position`, scale settings, nested `ImageStates` |
| `OverlayImageStates` | Per-state images (`Normal` / `Disabled` / `Pressed` / `Tracking`) |
| `CheckOverlayImageStates` / `CheckOverlayImageValues` | Checked-state overlays for check buttons and `ButtonSpec` |
| `IContentValues` | Overlay getters already take `PaletteState` |
| `RenderStandard.StandardContentMemento` | Caches overlay + RTL flag; `CalculateOverlayImagePosition` |

## Public API

### Values bag (`OverlayImageValues`)

```csharp
button.Values.OverlayImage.Image = badge;
button.Values.OverlayImage.ImageTransparentColor = Color.Magenta;
button.Values.OverlayImage.Position = OverlayImagePosition.TopRight; // TL / TR / BL / BR
button.Values.OverlayImage.ScaleMode = OverlayImageScaleMode.ProportionalToMain;
button.Values.OverlayImage.ScaleFactor = 0.5f;   // Percentage / ProportionalToMain
button.Values.OverlayImage.FixedSize = new Size(16, 16); // FixedSize mode
```

### Per-state overlays

```csharp
button.Values.OverlayImage.ImageStates.ImageNormal = normalBadge;
button.Values.OverlayImage.ImageStates.ImageTracking = hoverBadge;
button.Values.OverlayImage.ImageStates.ImagePressed = pressedBadge;
button.Values.OverlayImage.ImageStates.ImageDisabled = disabledBadge;
```

Resolution: state-specific image, else `OverlayImage.Image`. Position and scale stay shared.

### Check buttons / ButtonSpec checked states

`CheckButtonValues` and `ButtonSpec` use `CheckOverlayImageValues`:

```csharp
checkButton.Values.OverlayImage.ImageStates.ImageCheckedNormal = checkedBadge;
checkButton.Values.OverlayImage.ImageStates.ImageCheckedTracking = ...;
checkButton.Values.OverlayImage.ImageStates.ImageCheckedPressed = ...;
```

### Hosts

| Host | Access |
|------|--------|
| `KryptonButton` / `KryptonDropButton` / `KryptonCheckButton` | `Values.OverlayImage` |
| `KryptonLabel` | `Values.OverlayImage` |
| `KryptonColorButton` | `Values.OverlayImage` |
| `ButtonSpec` / `ButtonSpecAny` | `OverlayImage` on the spec (drawn via `ButtonSpecView`) |

## RTL behavior

When the host control's `RightToLeft` is `Yes`, Left/Right corners are mirrored automatically (`TopRight` ↔ `TopLeft`, `BottomRight` ↔ `BottomLeft`). Vertical content orientation continues to force LTR for overlay placement (same rule as main content layout). There is no separate mirror flag.

## Edge cases

- Overlay requires a main image; if the main image is not drawn, the overlay is skipped.
- Overlay does not affect preferred size — it is painted onto the main image rectangle only.
- Disabled / palette image effects applied to the main image are also applied to the overlay.
- `KryptonCommand` can override the main image; overlay still comes from `Values.OverlayImage` / `ButtonSpec.OverlayImage`.
- Tooltip mapping (`ButtonSpecToContent`) does not surface overlays.
- `FixedSize` is in pixels; Percentage / Proportional modes follow the laid-out main image size (DPI-friendly).

## Validation

TestForm demo: **Overlay Image Test** (`OverlayImageTest`), registered from `StartScreen`.

Exercises:

1. Positions and scale modes on buttons/labels (`#1205`).
2. Per-state overlays (hover / press / disabled).
3. `KryptonColorButton` overlay.
4. `ButtonSpec` on a `KryptonTextBox`.
5. Side-by-side LTR vs RTL with `Position = TopRight` (RTL badge appears on the left of the glyph).
