# KryptonThemeListView / theme previews

## Overview

Issue [#3870](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3870) adds preview images for custom palettes so `KryptonThemeListView` can show them in Large Icon, Tile, Small Icon, and Details views.

Custom palettes persist `KryptonCustomPaletteBase.Thumbnail` as base64 PNG in `.kthemex` (issue #2117). Palette Designer and Theme Browser **Export** write a generated window mock-up into that property on save. If a custom palette has no thumbnail, the list view uses the Stable Kr tile.

Package: `Krypton.Toolkit`.

## Architecture

```
Palette Designer save / Theme Browser Export
        │
        ▼
KryptonThemePreview.AssignGeneratedThumbnail(customPalette)
        │  64×64 window mock-up from ColorTable + HeaderForm / PanelClient / ButtonStandalone
        ▼
KryptonCustomPaletteBase.Thumbnail  →  .kthemex / .ktheme persist
        │
        ▼
KryptonThemeListView
        │  stored Thumbnail → KryptonPaletteFile.CreateThemeIcon (Kr overlay)
        │  no Thumbnail (custom) → Kr tile alone
        │  builtin theme → generated mock-up + Kr overlay
        ▼
LargeImageList 48×48 / SmallImageList 16×16
```

`KryptonThemePreview.Create` paints without showing a form. `KryptonThemePreview.Resolve` is the selector lookup.

## Public API

- `KryptonThemeListView` — `KryptonListView` + `IKryptonThemeSelectorBase`. `DefaultPalette`, `ShowExtraThemes`, `ShowThemePreviews` (default true), `LivePreviewOnHover` (default true). Default `View` is `LargeIcon`. Image lists are owned by the control.
- `KryptonThemePreview.Create(PaletteBase, Size|int)` — new bitmap; caller disposes.
- `KryptonThemePreview.AssignGeneratedThumbnail(KryptonCustomPaletteBase)` — replaces `Thumbnail` (disposes the previous image).
- `KryptonThemePreview.Resolve(themeName, localCustom, generateWhenMissing)` — stored custom thumbnail, else generated builtin mock-up, else `null` (Kr tile).
- `ThemeManager.TryCreateRegisteredTheme` — factory peek without applying globally.

## Usage

Drop `KryptonThemeListView` next to `KryptonThemeComboBox` / `KryptonThemeListBox`. Switch `View` to `LargeIcon`, `Tile`, or `Details` to see previews.

Register a custom theme with a stored preview:

```csharp
ThemeManager.RegisterCustomTheme("My Theme", () =>
{
    var palette = new KryptonCustomPaletteBase();
    palette.Import(@"C:\Themes\MyTheme.kthemex", silent: true);
    return palette;
});
```

To embed a preview from code (same as Palette Designer save):

```csharp
KryptonThemePreview.AssignGeneratedThumbnail(palette);
palette.Export(path, ignoreDefaults: true, silent: true);
```

## Live hover preview

`LivePreviewOnHover` (default on) applies the theme under the pointer without changing the committed (clicked) selection. Leaving the list restores the last clicked theme. Click still commits. Set the property to `false` to turn it off.

Mouse events are hooked on the inner `ListView`, not the Krypton chrome. Apply is immediate on `MouseMove` when the hovered row changes (the same row is skipped). Empty space between icons keeps the last hovered preview.

Palette apply recreates the inner list handle. That path:

- Ignores `MouseLeave` while `RecreatingHandle` is set, or while the pointer is still over the selector.
- Ignores `SelectedIndexChanged` for the committed row while a hover preview is active, so recreate does not snap back to the clicked theme.

Do **not** enable `HoverSelection`; that would change the committed selection.

## Palette Designer

On Save / Save As / save into a `.ktheme` collection, `MainForm` calls `AssignGeneratedThumbnail` before export so the file carries the mock-up.
