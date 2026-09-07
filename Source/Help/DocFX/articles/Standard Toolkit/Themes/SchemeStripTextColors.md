# Scheme strip text colours

## Overview

Menu, tool, status, and context/menu-item text can be themed independently. Before this change, ColorTables aliased menu and tool strip text to the status-strip (or label/button) colour, so `SetSchemeColor(MenuStripText, …)` had no effect on chrome.

Package owners: `Krypton.Toolkit` (enum, ColorTables, official palettes) and `Krypton.Themes` (extra palettes and scheme generators).

Button hover text is **not** part of this feature. Use `SchemeBaseColors.ButtonTextTracking` (Issue #880).

## Architecture

`SchemeBaseColors` is the indexed scheme used by `PaletteBase.SchemeColors`. ColorTables read those slots when building `ProfessionalColorTable` properties (`MenuStripText`, `ToolStripText`, `StatusStripText`, `MenuItemText`). `KryptonContextMenu` item text uses palette content styles, not the ColorTable, so those styles were retargeted as well.

```
SetSchemeColor(slot)
        │
        ▼
PaletteBase.SchemeColors[]  (+ matching BaseColors property, when the palette has one)
        │
        ├─ ColorTable.MenuStripText / ToolStripText / StatusStripText / MenuItemText
        │     (strips, ToolStripMenuItem, ContextMenuStrip)
        └─ GetContentShortTextColor*(ContextMenuItemText*)
              (KryptonContextMenu item captions and shortcuts)
```

`SchemeBaseColorsExtensions.Resolve` / `Coalesce` / `Get` treat `Color.Empty` (and `SharedStaticVariables.EMPTY_COLOR`, which is the same) as “use the family fallback”. Builtin schemes default the new slot to empty so appearance stays historic until a consumer sets a colour.

## Public API

### `SchemeBaseColors.ToolStripText = 242`

Appended after `TextListItem = 241`. Existing members keep their numeric values. Do not insert new members in the middle of this enum.

Related slots:

| Slot | Typical chrome |
|------|----------------|
| `MenuStripText` (232) | `KryptonMenuStrip` / `MenuStrip` top-level text |
| `ToolStripText` (242) | `KryptonToolStrip` / `ToolStrip` item text |
| `StatusStripText` (21) | `KryptonStatusStrip` / `StatusStrip` text |
| `MenuItemText` | Dropdown items, `ContextMenuStrip` items, `KryptonContextMenu` item text |

### `KryptonColorSchemeBase.ToolStripText`

Abstract property on every scheme. Generators (`LimeGreenSchemeHelper`, `MaterializeSchemeHelper`, `CustomThemeSchemeRemapper`) assign it with `MenuStripText`.

### Runtime

```csharp
var palette = KryptonManager.CurrentGlobalPalette;
palette.SetSchemeColor(SchemeBaseColors.MenuStripText, Color.Firebrick);
palette.SetSchemeColor(SchemeBaseColors.ToolStripText, Color.MediumBlue);
palette.SetSchemeColor(SchemeBaseColors.StatusStripText, Color.DarkGreen);
palette.SetSchemeColor(SchemeBaseColors.MenuItemText, Color.DarkOrange);

Color current = palette.GetSchemeColor(SchemeBaseColors.ToolStripText);
palette.SetSchemeColor(SchemeBaseColors.ToolStripText, Color.Empty); // restore fallback
```

Professional palettes may use a shorter hand-built colour array. `Get` / `Resolve` are bounds-safe; `SetSchemeColor` can throw `IndexOutOfRangeException` — catch that when driving unknown palettes from a demo.

Custom palettes that already expose independent `ToolMenuStatus` colours (`KryptonInternalKCT`) are unchanged.

## Family fallbacks

When the primary slot is empty, ColorTables use:

| Family | MenuStripText | ToolStripText | MenuItemText |
|--------|---------------|---------------|--------------|
| Office 2010 / 2013 / 365 / Visual Studio | `StatusStripText` | `StatusStripText` | `TextButtonNormal` (or the table's previous hardcoded colour) |
| Office 2007 | `TextLabelPanel` | `TextButtonNormal` | `TextButtonNormal` |
| Sparkle | `TextLabelPanel` | `TextLabelPanel` | Sparkle `_menuItemText` |
| White subclasses (2010/2013/365) | Coalesce with `Color.FromArgb(255, 30, 30, 30)` | family tool-strip fallback | family menu-item fallback |

Helpers:

- `SchemeBaseColorsExtensions.Coalesce(primary, fallback)`
- `colors.Resolve(primary, fallback)`
- `colors.Get(index)`
- `PaletteBase.GetSchemeColorOrFallback(primary, fallback)` (protected)

## Context menus

`PaletteContentStyle.ContextMenuItemTextStandard`, `ContextMenuItemTextAlternate`, and `ContextMenuItemShortcutText` now coalesce `MenuItemText` onto `TextLabelControl` (Material uses `HeaderText`).

Official palettes read that colour from the live `SchemeColors` array. Extra Office/365 palettes still read `BaseColors.MenuItemText`; `SetSchemeColor` therefore also writes the matching property on the palette's `BaseColors` object so those menus follow the override.

Native `ContextMenuStrip` and File/Edit dropdown items use `ColorTable.MenuItemText` (fallback `TextButtonNormal` on Office 2010/2013/365). That is the same slot, so they should match `KryptonContextMenu` once `MenuItemText` is set.

`ContextMenuItemImage` stays on the label/image arm (glyph, not item text). Menu headings stay on `ContextMenuHeadingText`.

`PaletteRelativeAlign.Center` arms that still list those styles are font/alignment only — do not split them.

## Edge cases

- **Do not insert enum members** before `Custom` or in the middle of `SchemeBaseColors`. Append only.
- Material and macOS schemes that already stored a non-empty `MenuStripText` now honour that slot (previously ignored by ColorTables). That is intended.
- `KryptonThemeComboBox` / theme re-apply restores builtin scheme values and clears live `SetSchemeColor` overrides — re-select the theme after **Reset all**.
- Native WinForms `MenuStrip` / `ToolStrip` / `StatusStrip` / `ContextMenuStrip` share the same `ColorTable` as the Krypton wraps when `ToolStripManager.Renderer` is the Krypton renderer.
