# Office grey chrome themes (2007 / 2010 / 2013 / 365 / Material)

## Overview

Issue [#942](https://github.com/Krypton-Suite/Standard-Toolkit/issues/942) is **grey window chrome** with a light document area. Dark Grey is not a full dark mode and is not Microsoft 365 dark mode.

Office 2013 Light Grey / Dark Grey already had `PaletteMode` values. Family variants reuse the same colour maps (`PaletteOffice2013LightGray_BaseScheme` / `PaletteOffice2013DarkGray_BaseScheme`) with each family's renderer and glyphs.

## Architecture

| Type | Role |
|---|---|
| `PaletteOffice2013LightGray_BaseScheme` / `DarkGray_BaseScheme` | Shared chrome + light document colours |
| `PaletteOffice2013LightGray` / `DarkGray` | Office 2013 renderer |
| `PaletteOffice2007LightGray` / `DarkGray` | Office 2007 renderer |
| `PaletteOffice2010LightGray` / `DarkGray` | Office 2010 renderer |
| `PaletteMicrosoft365LightGray` / `DarkGray` | Microsoft 365 renderer |
| `PaletteMaterialLightGray` / `DarkGray` (+ Ripple subclasses) | Material renderer |

Grey themes keep a **light client/document surface**. The ribbon control still uses `PaletteBackStyle.PanelClient` (light). `ViewDrawRibbonPanel` paints the **tabs strip** with `GetRibbonTabRowBackgroundSolidColor` when that colour is not empty.

## Chrome colours (sampled)

Light Grey:

- Title / tab row / status: `230,230,230`
- Ribbon groups / selected tab: `243,243,243`
- Caption and header text: `59,59,59`

Dark Grey:

- Title / tab row / status: `51,51,51` (active header `38,38,38`)
- Ribbon groups / selected tab: `102,102,102`
- Caption and header text: white
- Client / inputs / grids: same light colours as Office 2013 White
- File / App tab: charcoal (`51,51,51` / hover `70,70,70`) with white text
- Dark Grey paints `RibbonGroupArea` as a solid fill so light group/button text stays readable

## Glyphs

- Light Grey: dark glyphs on light chrome (2007 Silver, 2013/2010 light, Material generated from the light scheme).
- Dark Grey: light-on-dark control-box glyphs (2007 Black, 2010 Black). Checkboxes and radios stay on Silver/light strips because the document area is light.

## Public API

Office 2013 values already existed. **2007 / 2010 / 365 / Material grey modes are appended immediately before `PaletteMode.Custom`** so existing enum integers do not shift.

```csharp
kryptonManager.GlobalPaletteMode = PaletteMode.Office2013DarkGray;
kryptonManager.GlobalPaletteMode = PaletteMode.Office2007LightGray;
kryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365DarkGray;
kryptonManager.GlobalPaletteMode = PaletteMode.MaterialLightGrayRipple;
```

## Validation

TestForm demo: **942 Grey Themes** (`Office2013GrayThemesDemo`), registered in `StartScreen.AddButtons()`. Switch family variants and check caption contrast, ribbon tab row, headers, status strip, and light client controls.
