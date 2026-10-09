# Office 2024 ribbon

Office 2024 ribbon chrome for issue [#4496](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4496). The selected tab is an underline, groups have no boxes, and File is a text tab. Microsoft 365 and Office 2013 keep their existing folder-tab ribbon.

## Overview

`Krypton.Toolkit` owns the shape and the renderer. `Krypton.Ribbon` branches layout and painting on that shape. `Krypton.Themes` ships twelve extra palettes. Consumers opt in by selecting a palette mode. There is no `KryptonRibbon.RibbonStyle` property.

Out of scope: the simplified one-row ribbon, and Word title-bar widgets (Search, AutoSave, Comments, Editing, Share). Group captions stay. Button images stay consumer-supplied.

## Architecture

```
PaletteMode.Office2024Black
  -> PaletteOffice2024Black : PaletteMicrosoft365Black
  -> GetRibbonShape() = Office2024
  -> GetRenderer() = RenderOffice2024
  -> ViewDrawRibbon* / CalculatedValues branch on the shape
  -> RenderStandard.DrawRibbonBack
       RibbonTabSelected2024  underline (color 1)
       RibbonTabTracking2024  hover pill (color 1)
       RibbonGroupArea2024    rounded group card (color 1)
```

`RenderOffice2024` derives from `RenderMicrosoft365`. It skips the filled File block and the cluster edge when the shape is `Office2024`. Control colours, form chrome, and toolbar images stay on the Microsoft 365 base. Toolbar and shield images still use `KryptonThemeChromeKind.Microsoft365`.

## Public API

| Member | Meaning |
|--------|---------|
| `PaletteRibbonShape.Office2024` | Underline tabs, flat groups, text File tab. Appended after `MacOS`. |
| `PaletteRibbonColorStyle.RibbonTabSelected2024` | Color 1 is the underline. |
| `PaletteRibbonColorStyle.RibbonTabTracking2024` | Color 1 is the hover fill. |
| `RendererMode.Office2024` | Selects `KryptonManager.RenderOffice2024` for a custom palette. |
| `PaletteMode.Office2024Blue` | Light blue body, navy tab text, Fluent blue underline `#0F6CBD`. |
| `PaletteMode.Office2024BlueDarkMode` | Deep blue body, light tab text, light underline. |
| `PaletteMode.Office2024BlueLightMode` | White body, navy tab text, Fluent blue underline `#0F6CBD`. |
| `PaletteMode.Office2024Silver` | Silver body, dark tab text, Fluent blue underline `#0F6CBD`. |
| `PaletteMode.Office2024SilverDarkMode` | Slate body, light tab text, light underline. |
| `PaletteMode.Office2024SilverLightMode` | Light silver body, dark tab text, Fluent blue underline `#0F6CBD`. |
| `PaletteMode.Office2024White` | White body, dark tab text, Fluent blue underline `#0F6CBD`. |
| `PaletteMode.Office2024LightGray` | Body `#F3F2F1`, same blue underline. |
| `PaletteMode.Office2024DarkGray` | Body `#2D2D2D`, light text and underline. |
| `PaletteMode.Office2024Black` | Body `#1F1F1F`, white selected text and underline. |
| `PaletteMode.Office2024BlackDarkMode` | Body `#0A0A0A`, white selected text and underline. |
| `PaletteMode.Office2024BlackDarkModeAlternate` | Body `#181818`, white selected text and underline. |

Display names follow the Microsoft 365 pattern, for example `Office 2024 - Blue`, `Office 2024 - Blue (Dark Mode)`, `Office 2024 - Silver (Light Mode)`, and `Office 2024 - Black (Dark Mode - Alternate)`.

Family key: `KryptonThemeFamilies.Office2024`. `KryptonThemeAvailability.SetFamilyEnabled` can hide this family without hiding Microsoft 365.

There are no `KryptonManager.PaletteOffice2024*` properties. Resolve extras with `KryptonManager.GetPaletteForMode`.

`PaletteRibbonGeneral.RibbonShape` stays default `Inherit`, so existing designer files do not change. A custom palette can set `Ribbon.RibbonGeneral.RibbonShape = PaletteRibbonShape.Office2024` and `RendererMode.Office2024`.

These properties are on the ribbon, under `StateCommon.RibbonGeneral`. They apply only when the shape is `Office2024`. Microsoft 365 ignores them.

| Member | Meaning |
|--------|---------|
| `GroupAreaBevelEdges` | Optional bevel. Default off. Light top-left edge, dark bottom-right edge. |
| `GroupAreaBevelLight` | Light edge. `Color.Empty` derives a lighter colour from the group area. |
| `GroupAreaBevelDark` | Dark edge. `Color.Empty` derives a darker colour from the group area. |
| `GroupAreaBevelSize` | Visible bevel width in pixels at 96 DPI. Default 2. Minimum 1. |
| `GroupAreaGap` | Gap between group cards in pixels at 96 DPI. Zero, the default, keeps one card. |

Inserting the twelve modes immediately before `PaletteMode.Custom` shifts `Custom`'s integer. Names stay stable through `PaletteModeStrings`.

## Usage

Reference `Krypton.Themes` (it is packed into `Krypton.Standard.Toolkit`).

```csharp
var manager = new KryptonManager();
manager.GlobalPaletteMode = PaletteMode.Office2024Black;
```

Or on one form and ribbon:

```csharp
kryptonForm.PaletteMode = PaletteMode.Office2024White;
kryptonRibbon.PaletteMode = PaletteMode.Office2024White;
```

## Edge cases

- Office 2024 allows the File application menu and backstage. Office 2007 still does not.
- The form icon stays visible when the File tab is showing, same as Microsoft 365.
- Contextual tabs keep their title colour. They do not draw a folder-tab fill.
- Explicit ribbon group separators take space and do not stroke.
- Normal group borders are `Empty`. Tracking and pressed collapsed groups still use the Microsoft 365 border styles.
- Group button text uses the lighter tab colour on dark ribbons so labels stay readable on the flat body.
- The tab strip and the group area are painted separately. The tab strip uses `PaletteBackStyle.PanelClient` and stays square. The group area is its own inset card of the ribbon body colour, rounded on all four corners. At 96 DPI the card is inset 6px, and the items sit 10px inside the card above and below and 8px on each side. Those distances scale with DPI. A `GroupAreaGap` above zero paints one card per group and adds 10px inside the left and right of each card. Tab text and the selected underline switch to a contrasting colour when `PanelClient` would hide the body-coloured text. The caption quick-access strip does not paint its own bar, so icons sit on the title bar.
