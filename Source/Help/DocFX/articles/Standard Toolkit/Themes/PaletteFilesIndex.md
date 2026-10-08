# Krypton Palette Files (`.kthemex` / `.ktheme`)



## Packages

| Package | Role |
|---------|------|
| `Krypton.Toolkit` | File formats, `KryptonPaletteFile`, `KryptonCustomPaletteBase` Import/Export/Upgrade, `ThemeManager.ApplyTheme` file overloads, shell registration, designer verbs |
| `Krypton.Toolkit.Utilities` | Folder selectors (`ComboBox` / `ListBox` / `TreeView`), `KryptonPaletteCollectionEditor`, localisable string bags |
| `Krypton.Themes` | Optional: `KryptonThemeCustomPaletteHelper` exports extra builtin modes through the same file APIs (Toolkit must **not** project-reference Themes) |

Utilities UI requires the [Krypton.Standard.Toolkit](https://www.nuget.org/packages/Krypton.Standard.Toolkit) NuGet package (or a project reference to Utilities).

## Document map

| Document | Contents |
|----------|----------|
| [Overview and Architecture](OverviewandArchitecture.md) | Goals, rename history, type map, end-to-end data flow |
| [File Formats](FileFormats.md) | Extensions, `KPLT` / `KPTH` layout, `KryptonPaletteFileFormat`, sniffing |
| [Core API](CoreAPI.md) | `KryptonPaletteFile`, `KryptonCustomPaletteBase`, `ThemeManager`, related types |
| [Collections](Collections.md) | Multi-theme `.ktheme`, directory packing, add/remove/rename |
| [Upgrade Convert Migration](UpgradeConvertMigration.md) | Schema upgrade, `.xml` → `.kthemex`, Convert, V120 retirement |
| [Thumbnails and Shell](ThumbnailsandShell.md) | `Thumbnail`, KPTH catalog, HKCU associations, icon overlays |
| [Utilities UI](UtilitiesUI.md) | Selectors, collection editor, localisation |
| [Validation and Integration](ValidationandIntegration.md) | TestForm, unit tests, Demos, Palette Designer hooks, edge cases |

## Quick start

**Apply a single-theme file:**

```csharp
ThemeManager.ApplyTheme(@"C:\Themes\Ocean.kthemex", silent: true, kryptonManager);
```

**Apply a named theme from a collection:**

```csharp
ThemeManager.ApplyTheme(@"C:\Themes\Suite.ktheme", @"Office Themes/2013/Access 2013", silent: true, kryptonManager);
```

**Export / import on a component:**

```csharp
palette.Export(@"C:\Themes\Mine.kthemex", ignoreDefaults: true, silent: true);
palette.Import(@"C:\Themes\Mine.kthemex", silent: true);
```

**Create a collection from a folder tree:**

```csharp
KryptonPaletteFile.ExportCollectionFromDirectory(
    @"C:\Themes\Catalog.ktheme",
    @"C:\Theme-Palettes\Palettes",
    searchSubdirectories: true);
```

## Source map

| Area | Path under `Source/Krypton Components/` |
|------|------------------------------------------|
| File API (format, convert, shell) | `Krypton.Toolkit/Palette Base/KryptonPaletteFileFormat.cs` |
| Collections | `Krypton.Toolkit/Palette Base/KryptonPaletteFile.Collection.cs` |
| Directory / bulk upgrade | `Krypton.Toolkit/Palette Base/KryptonPaletteFile.Directory.cs` |
| Icons | `Krypton.Toolkit/Palette Base/KryptonPaletteFile.Icons.cs` |
| Binary I/O (internal) | `Krypton.Toolkit/Palette Base/KryptonPaletteBinaryPersistence.cs` |
| Component Import/Export | `Krypton.Toolkit/Controls Toolkit/KryptonCustomPaletteBase.cs` |
| Apply from file | `Krypton.Toolkit/Rendering/ThemeManager.cs` |
| Selectors | `Krypton.Toolkit.Utilities/Components/Krypton Palette File Selector/` |
| Collection editor | `Krypton.Toolkit.Utilities/Components/Krypton Palette Collection Editor/` |
