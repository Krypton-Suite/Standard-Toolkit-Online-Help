# Accessibility Themes

## Overview

Issue [#4168](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4168) adds fixed builtin `PaletteMode` accessibility themes:

| Accent set | Surfaces | Accents (#4165 philosophy) |
|------------|----------|----------------------------|
| High Contrast | Black / white | Neon green, yellow, cyan |
| Deuteranopia | Cool neutrals | Blue / orange / purple |
| Protanopia | Warm neutrals | Blue / brown / magenta |

Each accent set is available on five renderers:

| Renderer | PaletteMode examples | Display names |
|----------|----------------------|---------------|
| Microsoft 365 (default) | `HighContrast`, `Deuteranopia`, `Protanopia` | High Contrast, … |
| Office 2007 | `Office2007HighContrast`, … | Office 2007 - High Contrast, … |
| Office 2010 | `Office2010HighContrast`, … | Office 2010 - High Contrast, … |
| Office 2013 | `Office2013HighContrast`, … | Office 2013 - High Contrast, … |
| Sparkle | `SparkleHighContrast`, … | Sparkle - High Contrast, … |

These are **app-wide themes**, not Windows SystemColors High Contrast binding, and not light/dark pairs.

## Relationship to dialog button colors (#4165)

`KryptonDialogButtonColorScheme` remains **orthogonal**. Selecting an accessibility `PaletteMode` does **not** automatically set `KryptonManager.DialogButtonColors`.

## Architecture

```
ThemeComboBox / ThemeManager.ApplyTheme
        |
PaletteModeStrings.SupportedThemes  (order-locked with PaletteMode enum)
        |
KryptonManager.GetPaletteForMode
        |
Palette{OfficeYear?}{Accent}
        |
PaletteMicrosoft365Base | PaletteOffice2007Base | PaletteOffice2010Base | PaletteOffice2013Base
        + AccessibilityPaletteAccents.Apply* (SetArrayColor gold remaps)
        + shared Schemes/Palette{Accent}_BaseScheme
```

## Public API

```csharp
ThemeManager.ApplyTheme(PaletteMode.Office2010Deuteranopia, manager);
// or
KryptonManager.GlobalPaletteMode = PaletteMode.Office2007HighContrast;
```

Unprefixed modes (`HighContrast`, …) keep Microsoft 365 chrome. Office-prefixed modes reuse the same colour schemes with era-specific geometry, control-box images, and toolbar packs.

## Colour schemes

Under `Palette Builtin/Accessibility/`:

- Shared schemes: `Schemes/PaletteHighContrast_BaseScheme.cs`, `PaletteDeuteranopia_BaseScheme.cs`, `PaletteProtanopia_BaseScheme.cs`
- M365: `PaletteHighContrast.cs`, `PaletteDeuteranopia.cs`, `PaletteProtanopia.cs`
- Office: `PaletteOffice2007*`, `PaletteOffice2010*`, `PaletteOffice2013*` (nine thin palette classes)
- Sparkle: `PaletteSparkleHighContrast`, `PaletteSparkleDeuteranopia`, `PaletteSparkleProtanopia` + `AccessibilitySparkleAccents` (Sparkle chrome arrays, not `SetArrayColor`)
- `AccessibilityPaletteAccents.cs` — remaps family gold hover/checked arrays via `SetArrayColor`
- `AccessibilityHighContrastChrome.cs` — High Contrast overrides for ControlClient / context-menu backs (combo drop-downs)

## Validation

TestForm: **4168 Accessibility Themes** (`AccessibilityThemesDemo`).

1. Switch M365, Office 2007 / 2010 / 2013, and Sparkle variants; confirm accents and family chrome.
2. Open the Theme combo on High Contrast; drop-down list should be black (not white SystemColors.Window).
3. Confirm all fifteen themes appear in Theme Controls / ThemeComboBox.
4. Optional MessageBox compares matching #4165 dialog button schemes.
5. Closing the demo restores the previous global theme.

## Edge cases

- Enum order must stay aligned with `PaletteModeStrings.SupportedThemes` ([#1328](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1328)).
- Not a dynamic OS High Contrast theme; colours are fixed design tokens.
- Toolbar images follow the renderer family (M365 / Office 2007 / 2010 / 2013 packs).
- Family bases hardcode `ControlClient` / context-menu backs to `SystemColors.Window` / white; High Contrast palettes override via `AccessibilityHighContrastChrome` so combo drop-downs stay black.
