# 04 — Collections

[← Core API](./CoreAPI.md) · [Index](./PaletteFilesIndex.md) · [Next: Upgrade →](./UpgradeConvertMigration.md)

A **collection** is a `.ktheme` file with KPLT payload kind **2**: several named themes in one container. Single-theme `.ktheme` files (kind 0/1) are **not** collections (`IsCollection` is false) until promoted.

## Creating collections

### From in-memory palettes

```csharp
var ocean = new KryptonCustomPaletteBase();
ocean.SetPaletteName("Ocean");
// ... edit colours ...

var dusk = new KryptonCustomPaletteBase();
dusk.SetPaletteName("Dusk");

KryptonPaletteFile.ExportCollection(
    @"C:\Themes\Suite.ktheme",
    new[] { ocean, dusk },
    ignoreDefaults: false,
    collectionName: "My Suite");
```

Rules:

- Destination extension must be `.ktheme` (`.kthemex` / JSON rejected).
- Names from `SetPaletteName` must be unique (ordinal ignore-case).
- At least one palette required.
- Optional `collectionName` becomes the KPLT header display name (`GetCollectionName` / `SetCollectionName`).

### From a directory tree

```csharp
KryptonPaletteFile.ExportCollectionFromDirectory(
    @"C:\Themes\Catalog.ktheme",
    @"C:\Theme-Palettes\Palettes",
    searchSubdirectories: true,
    ignoreDefaults: false,
    collectionName: "Theme-Palettes");
```

Theme names are **relative paths** with `/`, e.g. `Office Themes/2013/Access 2013`.

- Nested `.ktheme` packs under the folder are flattened into the parent path space.
- Does **not** bump container version.
- Colliding names get disambiguating suffixes.

## Listing and loading themes

```csharp
string[] names = KryptonPaletteFile.GetThemeNames(path);
bool multi = KryptonPaletteFile.IsCollection(path);

var palette = new KryptonCustomPaletteBase();
palette.Import(path, themeName: names[0], silent: true);

// or
ThemeManager.ApplyTheme(path, names[0], silent: true, kryptonManager);
```

Importing a multi-theme collection **without** `themeName` throws when more than one theme is present. A collection with exactly one theme imports that entry.

Single-theme `.kthemex` / `.xml` / kind 0–1 `.ktheme` return one name from `GetThemeNames`.

## Add / remove / rename

```csharp
// Create or update; promotes single-theme .ktheme to kind 2
KryptonPaletteFile.AddToCollection(collectionPath, sourcePath);
KryptonPaletteFile.AddToCollection(collectionPath, sourcePath, themeName, replaceExisting: true);
KryptonPaletteFile.AddToCollection(collectionPath, sourcePaths, replaceExisting: false);
KryptonPaletteFile.AddToCollection(collectionPath, paletteInstance, replaceExisting: false);

KryptonPaletteFile.RemoveFromCollection(collectionPath, themeName);

KryptonPaletteFile.SetCollectionName(collectionPath, "Display Name");
string header = KryptonPaletteFile.GetCollectionName(collectionPath);
```

Behaviour notes:

| Case | Result |
|------|--------|
| Missing destination `.ktheme` | Created on first successful add |
| Destination is single-theme `.ktheme` | Promoted to collection |
| Source is a collection | Adds every named theme (or one when `themeName` selects it) |
| Duplicate name | Throw unless `replaceExisting: true` |
| Self-add (same path) | Rejected |
| Remove last theme | Forbidden — delete the file instead |
| Rewrites after add/remove | `ignoreDefaults: false` |

UI wrapper: `KryptonPaletteCollectionEditor` — see [Utilities UI](./UtilitiesUI.md).

## Path separators

Stored names use `/`. UI should call `ToDisplayPath` / `SplitCollectionThemePath` when showing folder columns (collection editor Details view uses Theme + Folder).

## Thumbnails in collections

`ExportCollection` writes an optional trailing `KPTH` catalog from each palette’s `Thumbnail`. Selectors call `GetThemeThumbnails` so previews load **without** a full theme import. See [Thumbnails and Shell](./ThumbnailsandShell.md).

## Cookbook: apply from `*.ktheme`

```csharp
void ApplyFromKtheme(string path, string? themeName, KryptonManager manager)
{
    if (KryptonPaletteFile.IsCollection(path))
    {
        var names = KryptonPaletteFile.GetThemeNames(path);
        var pick = themeName ?? (names.Length == 1 ? names[0] : throw new InvalidOperationException("Pick a theme name."));
        ThemeManager.ApplyTheme(path, pick, silent: true, manager);
        return;
    }

    ThemeManager.ApplyTheme(path, silent: true, manager);
}
```

[← Core API](./CoreAPI.md) · [Index](./PaletteFilesIndex.md) · [Next: Upgrade →](./UpgradeConvertMigration.md)
