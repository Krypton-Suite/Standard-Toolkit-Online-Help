# KryptonCustomPaletteBase — BasePaletteMode and the color table

## Overview

Until V85, dropping a `KryptonCustomPaletteBase` on a form and setting `BasePaletteMode` to a builtin theme (for example Office 2010 Silver) made every unset color and style inherit from that theme. V90 removed `BasePaletteMode`. Custom palettes then always inherited Microsoft 365 Blue unless the consumer assigned `BasePalette` in code. Issue [#1870](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1870).

V110 restores `BasePaletteMode` and keeps the inherited `ColorTable` in sync with the selected builtin palette.

Package: `Krypton.Toolkit`.

## How inheritance works

```
KryptonCustomPaletteBase
  BasePaletteMode  →  KryptonManager.GetPaletteForMode(mode)
  BasePalette      →  that builtin instance (or another custom palette)
  ToolMenuStatus   →  KryptonInternalKCT wrapping BasePalette.ColorTable
  ColorTable       →  ToolMenuStatus.InternalKCT (resolved colors)
```

Unset palette storage (buttons, headers, ribbons, …) redirects through `PaletteRedirect` to `BasePalette`. Unset `ToolMenuStatus` colors inherit from `BaseKCT`. Only properties you override are stored on the custom palette.

## Public API

### `BasePaletteMode`

- Type: `PaletteMode`
- Default: `ThemeManager.DefaultGlobalPalette` (Microsoft 365 Blue)
- Designer: Visuals category, `PaletteModeConverter` drop-down
- Setting `Custom` is ignored. To inherit from another `KryptonCustomPaletteBase`, assign `BasePalette`.
- Persisted in XML (`KryptonPersist(false, false)`) and in the designer when not the default.

### `BasePalette`

- Type: `PaletteBase?`
- Assigning a **builtin** instance (from `KryptonManager.GetPaletteForMode`) sets `BasePaletteMode` to that catalog mode, not `Custom`.
- Assigning another `KryptonCustomPaletteBase` sets `BasePaletteMode` to `Custom`.
- Designer-serialized only when `BasePaletteMode` is `Custom`.

### `ColorTable`

- Read-only resolved `KryptonColorTable` for menus, tool strips, and status strips.
- Visible in the designer so you can see inherited colors change with `BasePaletteMode`.
- Not serialized. Override individual entries through `ToolMenuStatus`.

## Usage

Designer:

1. Add `KryptonCustomPaletteBase` and `KryptonManager`.
2. Set `KryptonManager.GlobalCustomPalette` to the custom palette.
3. Set `BasePaletteMode` to the theme to inherit (Office 2010 Silver, Office 2007 Silver, …).
4. Override only the colors you need (`ButtonStyles`, `ToolMenuStatus`, …).

Code (same as the V90 workaround, now also sets the mode):

```csharp
kryptonCustomPaletteBase1.BasePaletteMode = PaletteMode.Office2010Silver;
// equivalent:
kryptonCustomPaletteBase1.BasePalette =
    KryptonManager.GetPaletteForMode(PaletteMode.Office2010Silver);
```

`Populate from Base` copies every value from the current `BasePalette` into the custom storage. Use it when you want a snapshot, not live inheritance. XML import applies only the properties present in the file; omitted items still inherit from `BasePaletteMode`.

## Validation

- TestForm: **Bug 1870 Custom palette base** (`Bug1870CustomPaletteBaseDemo`).
- `Scripts/UnitTests/UnitTest-CustomPaletteBasePaletteMode.ps1` (`UnitTest-CI: include`).
