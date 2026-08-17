# Materialize Blue, Light Blue, and Silver Dark Alternate themes

## Overview

Issue [#1551](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1551) adds three accent packs as first-class builtin palettes:

- **Materialize Blue** — [ColorsWall palette 8](https://colorswall.com/palette/8) (`#2196f3` and the lighten/darken ramp).
- **Materialize Light Blue** — [ColorsWall palette 13](https://colorswall.com/palette/13) (`#03a9f4` ramp).
- **Silver Dark Alternate** — near-black silver chrome (`#0F0F0F` / `#1F1F1F` surfaces, silver buttons), analogue of `Microsoft365BlackDarkModeAlternate`.

Each pack is available on Office 2007, Office 2010, Office 2013, Microsoft 365, and Material. Material also has Ripple siblings.

## Architecture

`MaterializeSchemeHelper` copies a donor `KryptonColorSchemeBase` (Blue / Blue Dark / White / Dark Gray / Material Light or Dark / Silver Dark) then overwrites accent slots. Family wrappers under `Palette Builtin/Issue1551` reuse that family's renderer, control-box glyphs, and metrics.

`RegisterButtonStateColors<TOwner>` fills Tracking / Pressed / Checked LUT slots so Office orange/gold defaults do not leak.

## Public API

New `PaletteMode` values (appended before `Custom`), for example:

- `Office2007MaterializeBlue` / `Office2007MaterializeBlueDark` / `Office2007MaterializeLightBlue` / `Office2007MaterializeLightBlueDark` / `Office2007SilverDarkModeAlternate`
- Matching `Office2010*`, `Office2013*`, `Microsoft365*`
- `MaterialMaterializeBlue`, `MaterialMaterializeBlueRipple`, dark/ripple variants, and `MaterialSilverDarkModeAlternate`

Apply with:

```csharp
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365MaterializeBlue;
```

## Validation

TestForm **1551 Materialize Themes** (`Issue1551ThemeDemo`) lists every new mode. Theme selectors also include the display names from `PaletteModeStrings`.
