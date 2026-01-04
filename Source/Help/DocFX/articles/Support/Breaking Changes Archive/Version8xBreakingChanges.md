# Version 8x Breaking Changes

## V85.00 (2025-02-01 - Build 2502 (Patch 5) - February 2025)

- Resolved [#1212](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1842), **[Breaking Change]** `KColorButton` 'drop-down' arrow should be drawn
  - Create Scaled Drop Glyph and use for colour button and comboDrops
  - Remove the `PaletteRedirectDropDownButton`
  - Remove `KryptonPaletteImagesDropDownButton`
  - **Breaking Change**: Remove `DropDownButtonImages` from designers

## V85.00 (2024-06-24 - Build 2406 - June 2024)

There are a list of changes that have occurred during the development of the V85.00 version

- [#1302](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1302), **[Breaking Change]** Font being used by "Professional" theme is pants !
  - The Option to use `SystemDefault` no longer exists a font rendering hint
- [#1508](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1508), **[Breaking Change]** ButtonSpec does not open assigned context menu when clicked.
  - Added property `ShowDrop`, which displays a drop-down arrow on the button.
  - When a `KryptonContextMenu` is connected the menu is shown when the button is clicked.
  - When a WinForms `ContextMenuStrip` is connected the menu is shown when the button is clicked.
  - When both type of the above ContextMenus are connected the `KryptonContextMenu` takes precedence.
  - The ButtonSpec's `Type` property does not need setting to "Context" to display the menu.
- [#1424](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1424), **[Breaking Change]** `KryptonMessageBox` does not obey tab characters like `MessageBox`

## V80.00 (2023-11-14 - Build 2311 - November 2023) (RTM)

There are list of changes that have occurred during the development of the V80.00 version

### Support for .NET Core 3.1 and .NET 5

As of V80.00, support for .NET Core 3.1 and .NET 5 has been removed due to their release cadences. It is strongly advised that you migrate your application to .NET 8, as the latest LTS version, or the slightly older .NET 6, if you require a more supported version. If you do not make these mitigations, the packages **will** fail to install when upgrading, if your project is configured to use either .NET Core 3.1 and .NET 5.

### KryptonMessageBoxButtons

- <https://github.com/Krypton-Suite/Standard-Toolkit/issues/728>:
Bring MessageBox States inline with latest .Net 6 by using a new `KryptonMessageBoxButtons` type, which is effectively the same as .NET 6 enum version of `MessageBoxButtons` but backward compatible with .NET Framework 4.6.x onwards.

### Palette usages

- `KryptonPalette` has become `KryptonCustomPaletteBase` to better signify it's usage.
- `IPalette` has been removed, and the usage of `PaletteBase` throughout the toolkit is used; to ensure consistent usage.

### Depreciation of `KryptonManager.Strings`

In a effort to support translations, `KryptonManager.Strings` is now obsolete. As such, the new `KryptonLanguageManager` will handle such strings.