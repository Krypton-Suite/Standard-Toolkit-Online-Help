# KryptonLoadingCircle

## Overview

`KryptonLoadingCircle` is an animated spoke spinner in `Krypton.Toolkit.Utilities`. It can be hosted on a form (Toolbox item) or inside a ToolStrip via `KryptonLoadingCircleToolStripMenuItem`.

When `CircleValues.Color` is `Color.Empty` (the default), spoke colours resolve from the active Krypton palette and refresh when the global theme changes. Set a concrete colour to override the theme.

Related determinate control: `KryptonCircularProgressBar` (percentage / marquee arc), not an indeterminate busy spinner.

Toolkit also ships an **`internal`** twin, `InternalKryptonLoadingCircle` (`Controls Toolkit/Internal/`), for Toolkit-only hosts. Same palette/`Timer` behaviour; not Toolbox-visible. Prefer the Utilities type for applications.

## Architecture

- Owner-draw `Control` with double buffering.
- UI-thread `Timer` advances the leading spoke index and calls `Invalidate`.
- Spoke geometry comes from `LoadingCircleValues` (radii, thickness, spoke count, style presets).
- Palette wiring mirrors other lightweight Utilities paint controls (`KryptonSliderButton`):
  - Subscribe to `KryptonManager.GlobalPaletteChanged` and `PaletteBase.PalettePaint`.
  - On change, regenerate the spoke colour array and invalidate.
  - Unsubscribe in `Dispose`.

```text
Color.Empty  -->  GetContentShortTextColor1(LabelNormalControl, Normal|Disabled)
Concrete Color -->  use override as the lightest spoke
                   |
                   v
         GenerateColoursPallet (alpha fade across spokes)
                   |
                   v
              OnPaint (DrawLine spokes)
```

## Public API

### `KryptonLoadingCircle`

| Member | Role |
|--------|------|
| `CircleValues` | Expandable `LoadingCircleValues` bag (designer Content). |
| `Color` / `Active` / `StylePreset` / radii / thickness | Convenience forwards to `CircleValues` (hidden from the property grid; use the bag). |
| `SetCircleAppearance(...)` | Sets spoke count and radii in one call. |
| `Active` | Starts/stops the rotation timer. |

### `LoadingCircleValues`

| Property | Default | Notes |
|----------|---------|-------|
| `Color` | `Empty` | Empty = palette; otherwise override. |
| `Active` | `false` | Animation on/off. |
| `StylePreset` | `Custom` | `MacOSX`, `Firefox`, `IE7`, or `Custom`. |
| `InnerCircleRadius` / `OuterCircleRadius` / `SpokeThickness` / `NumberSpoke` | Custom defaults | Logical 96 DPI units; scaled in paint. |
| `RotationSpeed` | timer interval | Higher is slower. |

### Palette resolution

```csharp
palette.GetContentShortTextColor1(
    PaletteContentStyle.LabelNormalControl,
    Enabled ? PaletteState.Normal : PaletteState.Disabled);
```

Disabled state uses `PaletteState.Disabled` so spokes mute with the theme.

## Usage

```csharp
var spinner = new KryptonLoadingCircle
{
    Size = new Size(64, 64),
    StylePreset = StylePresets.MacOSX,
    Active = true
    // Color remains Empty → follows KryptonManager theme
};

// Override theme colour:
spinner.Color = Color.SteelBlue;

// Return to palette:
spinner.Color = Color.Empty;
```

ToolStrip:

```csharp
var item = new KryptonLoadingCircleToolStripMenuItem();
item.LoadingCircleControl!.Active = true;
```

## Designer notes

- Fresh Toolbox drop: `CircleValues.IsDefault` is true (`Color.Empty`, inactive, Custom preset).
- `ShouldSerializeColor` / `ResetColor` keep Empty from serializing as Modified.

## Edge cases

- No local `PaletteMode`; always tracks `KryptonManager.CurrentGlobalPalette`.
- If no palette is available, falls back to `SystemColors.ControlText`.
- Stop the timer when inactive; dispose unhooks palette events and disposes the timer.
