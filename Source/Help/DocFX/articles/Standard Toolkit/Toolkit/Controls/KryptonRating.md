# KryptonRating developer guide

## Overview

`KryptonRating` is a Toolbox control in `Krypton.Toolkit` that lets the user pick a rating by clicking a strip of glyphs (stars by default). It is an interactive form control, not a replacement for `KryptonDataGridViewRatingColumn` (display-only byte images in a grid cell).

## Architecture

- `KryptonRating` inherits `VisualSimpleBase` and hosts a `ViewManager` whose root is `ViewDrawRating`.
- `RatingController` implements mouse, key, and focus routing (`IMouseController`, `IKeyController`, `ISourceController`).
- `RatingGlyphPainter` draws vector Star / Heart / Circle paths (or stock/custom images) and snaps values.
- Appearance uses TrackBar-style `StateCommon` / `StateNormal` / `StateTracking` / `StateDisabled` (`PaletteRatingStates`: `Fill` and `Empty`). `Color.Empty` inherits along that chain, then built-in gold fill and palette-based empty/outline. There is no `StatePressed` (click commits immediately) and no new `SchemeBaseColors` / `PaletteElement` slot.

```
KryptonRating
  ViewManager
    ViewDrawRating
      RatingGlyphPainter
  RatingValues
  StateCommon / StateNormal / StateTracking / StateDisabled
```

## Public API

| Member | Default | Notes |
|--------|---------|--------|
| `Value` | `0` | `decimal`, range `0`..`Maximum`. Binding default. |
| `Maximum` | `5` | Glyph count, clamped `1`..`32`. |
| `Precision` | `Full` | `Full` (step 1), `Half` (0.5), `Exact` (click fraction, 2 d.p.; keys step 0.1). |
| `ReadOnly` | `false` | Hover preview still updates; click/keys do not commit. |
| `AllowClear` | `true` | Click the current rating again, or before the first glyph, to set `0`. |
| `Orientation` | `Horizontal` | Vertical stacks glyphs. `RightToLeft` reverses order. |
| `AutoSize` | `true` | Sizes to glyphs like `KryptonTrackBar`. |
| `RatingValues` | factory | `ItemSize` 20, `ItemSpacing` 4, `Glyph` Star, optional images. |
| `StateCommon` / `StateNormal` / `StateTracking` / `StateDisabled` | inherit | `PaletteRatingStates.Fill` / `Empty`. Tracking is hover; Disabled is gray when unset. |
| `HoverValue` | equals `Value` | Live preview while the mouse is over the strip. |
| `ValueChanged` | | Raised when `Value` changes. |

`Text` is hidden from the property grid.

## Painting

Vector glyphs fill empty, then clip to the committed or hover fraction and fill. Image mode uses `RatingValues.ImageFilled` / `ImageEmpty` / `ImageHalf`, falling back to `StarImageResources.star_yellow` (and half/disabled stock images). Do not use the old `star0`–`star5` composite strips; they assume a fixed five-star bitmap.

Colour overrides (no new theme slot):

```csharp
rating.StateNormal.Fill = Color.DodgerBlue;
rating.StateTracking.Fill = Color.SkyBlue;
rating.StateCommon.Empty = Color.LightSteelBlue;
rating.StateDisabled.Fill = Color.Gray;
```

`Color.Empty` inherits: Tracking from Normal from Common, Disabled from Common, then the built-in gold / hover / gray defaults.

## Designer

`KryptonRatingDesigner` + `KryptonRatingActionList` expose Value, Maximum, Precision, ReadOnly, Orientation, Glyph, and Palette. Fresh drop must not show nested **Modified** storage (`IsDefault` on `RatingValues` / `PaletteRatingStates`).
