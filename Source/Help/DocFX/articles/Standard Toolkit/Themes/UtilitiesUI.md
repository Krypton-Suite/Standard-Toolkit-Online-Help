# 07 — Utilities UI

[← Thumbnails & Shell](./06-Thumbnails-and-Shell.md) · [Index](./README.md) · [Next: Validation →](./08-Validation-and-Integration.md)

Assembly: `Krypton.Toolkit.Utilities` (shipped via [Krypton.Standard.Toolkit](https://www.nuget.org/packages/Krypton.Standard.Toolkit)).

## Folder selectors

Three controls share the same controller (`KryptonPaletteFileThemeSelectorController`):

| Control | Base |
|---------|------|
| `KryptonPaletteFileComboBox` | `KryptonComboBox` |
| `KryptonPaletteFileListBox` | `KryptonListBox` |
| `KryptonPaletteFileTreeView` | `KryptonTreeView` |

### Shared properties

| Property | Default | Meaning |
|----------|---------|---------|
| `PaletteDirectory` | (empty) | Folder to scan |
| `SearchSubdirectories` | `false` | Recurse like Theme-Palettes catalogs |
| `IncludeKthemex` | `true` | Include `.kthemex` |
| `IncludeKtheme` | `true` | Include `.ktheme` (expands collections) |
| `IncludeXml` | `true` | Include legacy `.xml` (V120 ToDo) |
| `AutoApply` | `true` | Apply selection to `KryptonManager` |
| `ShowThumbnails` | `true` | Load stored previews; false still shows Kr tile |
| `ThumbnailSize` | `32×32` | List/combo icon size |
| `KryptonManager` | — | Apply target |
| `SelectedPaletteTheme` | — | Current `KryptonPaletteFileThemeItem?` |
| `Strings` | — | `KryptonPaletteFileSelectorStrings` |

### Methods

- `Reload()` — rescan directory
- `ApplySelected()` — import + apply without relying on AutoApply

Apply path: `TryImportInto(..., promptLegacyXml: true)` then `ThemeManager.ApplyTheme`.

### `KryptonPaletteFileThemeItem`

| Member | Meaning |
|--------|---------|
| `FilePath` | Source file |
| `ThemeName` | Name inside collection, or single-theme name |
| `IsCollection` | Theme came from a kind-2 file |
| `TreePath` | `/`-separated path for TreeView |
| `DisplayName` | Caption (duplicate format from Strings) |
| `Thumbnail` | Optional preview |
| `FromDirectory(...)` | Static scan helper |
| `ImportInto` / `TryImportInto` / `Apply` | Load into palette / manager |

Implements `IContentValues` for Krypton list rendering (composed icon or badge).

### Localisation (`KryptonPaletteFileSelectorStrings`)

- `DuplicateDisplayNameFormat` — default `"{0} ({1)}"`
- `[Localizable(true)]`; `IsDefault` / `Reset` pattern like other Toolkit string bags
- Static `Default` used by `FromDirectory` when no control instance is present

## Collection editor

### Public component

`KryptonPaletteCollectionEditor` (`Component`):

| Member | Role |
|--------|------|
| `CollectionPath` | Current `.ktheme` path |
| `Strings` | `KryptonPaletteCollectionEditorStrings` |
| `ShowDialog([owner])` | Modal editor |
| `Show(owner, path, strings?)` | Static convenience |

### Internal UI

`VisualKryptonPaletteCollectionEditorForm`:

- Browse / create `.ktheme`
- Edit and save collection header name (`SetCollectionName`)
- Add files (multiselect `.kthemex` / `.ktheme` / `.xml`)
- Remove selected theme (`RemoveFromCollection`)
- View modes: Large Icon, Details, Small Icon, List, Tile
- Details columns: **Theme**, **Folder** (from path segments)
- Immediate disk rewrites via Toolkit collection APIs
- ImageList uses thumbnail + Kr overlay; opening a collection must not throw on invalid images (.NET ImageList edge case fixed)

### Localisation (`KryptonPaletteCollectionEditorStrings`)

All dialog captions, filters, status formats, view names, column headers, and duplicate-replace prompts are `[Localizable(true)]` properties on the string bag. Prefer editing `Strings` on the component rather than hard-coding UI text.

## Minimal host setup

```csharp
var selector = new KryptonPaletteFileTreeView
{
    Dock = DockStyle.Fill,
    PaletteDirectory = @"C:\Theme-Palettes\Palettes",
    SearchSubdirectories = true,
    KryptonManager = kryptonManager1,
    AutoApply = true,
    ShowThumbnails = true
};
selector.Reload();

var editor = new KryptonPaletteCollectionEditor
{
    CollectionPath = @"C:\Themes\Suite.ktheme"
};
editor.ShowDialog(this);
```

## TestForm demos

| Demo | StartScreen | Location |
|------|-------------|----------|
| Palette binary / files | “2117 Palette .kthemex save/load” | `TestForm/PaletteBinaryDemo.cs` (legacy root location) |
| Collection editor | “2117 Palette collection editor” | `TestForm/KryptonUtilities/Feature/PaletteCollectionEditorDemo.cs` |

New demos for Toolkit.Utilities belong under `TestForm/KryptonToolkitUtilities/` per `AGENTS.md`; the collection editor demo currently lives under the older `KryptonUtilities` folder name — do not relocate unless that is the task.

[← Thumbnails & Shell](./06-Thumbnails-and-Shell.md) · [Index](./README.md) · [Next: Validation →](./08-Validation-and-Integration.md)
