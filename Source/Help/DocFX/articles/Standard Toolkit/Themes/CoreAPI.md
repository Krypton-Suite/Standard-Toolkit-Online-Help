# 03 — Core API

[← File Formats](./02-File-Formats.md) · [Index](./README.md) · [Next: Collections →](./04-Collections.md)

Namespace: `Krypton.Toolkit` unless noted.

## `KryptonPaletteFile` (static partial)

| Partial file | Responsibility |
|--------------|----------------|
| `KryptonPaletteFileFormat.cs` | Constants, convert/upgrade prompts, theme names/thumbs, `ExportCollection`, shell |
| `KryptonPaletteFile.Collection.cs` | Add / remove / rename collection |
| `KryptonPaletteFile.Directory.cs` | Directory scan, path helpers, bulk upgrade, pack-from-folder |
| `KryptonPaletteFile.Icons.cs` | Badge / thumbnail overlay icons |

### Constants

| Member | Value |
|--------|-------|
| `Extension` | `"kthemex"` |
| `XmlExtension` | `"xml"` |
| `BinaryExtension` | `"ktheme"` |
| `XmlProgId` | `"kthemexfile"` |
| `BinaryProgId` | `"kthemefile"` |
| `DialogFilter` | Open/Save filter string |
| `ContainerMagic` | `"KPLT"` |
| `ThumbnailCatalogMagic` | `"KPTH"` |
| `RecommendedThumbnailSize` | `64` |
| `CollectionPathSeparator` | `'/'` |

### Path and format

```csharp
KryptonPaletteFileFormat FormatFromPath(string path);
bool IsPaletteExtension(string? pathOrExtension);
bool IsLegacyXmlExtension(string? pathOrExtension);
bool IsCollection(string path);
string[] GetThemeNames(string path);
Image?[] GetThemeThumbnails(string path); // caller disposes non-null
string GetCollectionName(string path);
string SetCollectionName(string collectionPath, string? collectionName);
```

`GetPaletteFiles(directory, searchSubdirectories, includeKthemex, includeKtheme, includeXml)` lists matching files under a folder.

### Convert and upgrade

```csharp
string Convert(string sourcePath, string destinationPath);
string Convert(string sourcePath, string destinationPath, KryptonPaletteFileFormat format);
string Convert(string sourcePath, string destinationPath, KryptonPaletteFileFormat format, bool ignoreDefaults);

string UpgradeXmlToKthemex(string sourcePath);
string UpgradeXmlToKthemex(string sourcePath, string destinationPath);

KryptonPaletteDirectoryUpgradeResult UpgradeXmlToKthemexFromDirectory(
    string directory, bool searchSubdirectories = true);

string? PromptLegacyXmlUpgrade(string sourcePath, bool silent);
```

- `Convert` runs `ImportWithUpgrade` then `Export`. Rejects `.json`.
- `UpgradeXmlToKthemex` requires source `.xml` and destination `.kthemex`; **source file left in place**.
- `PromptLegacyXmlUpgrade`: Yes → rewrite and return `.kthemex` path; No → return original `.xml`; Cancel → `null`. Silent / non-interactive → return path unchanged (no dialog).

### Collection export (also see [04-Collections](./04-Collections.md))

```csharp
string ExportCollection(string destinationPath, IEnumerable<KryptonCustomPaletteBase> palettes);
string ExportCollection(..., bool ignoreDefaults);
string ExportCollection(..., bool ignoreDefaults, string? collectionName);

string ExportCollectionFromDirectory(string destinationPath, string sourceDirectory,
    bool searchSubdirectories = true, bool ignoreDefaults = false, string? collectionName = null);
```

Destination must be `.ktheme`. Each palette needs a unique `SetPaletteName` (ordinal ignore-case).

### Shell and icons

```csharp
void EnsureShellAssociations();
void EnsureShellAssociations(string? openWithExecutable);
Icon? CreateShellIcon(bool largeIcon = false);
Image GetThemeBadgeImage();
Image CreateThemeIcon(Image? thumbnail, Size size /* or int */);
Icon? CreateThemeFileIcon(string path, bool largeIcon = false);
```

Details: [06-Thumbnails-and-Shell](./06-Thumbnails-and-Shell.md).

---

## `KryptonCustomPaletteBase`

### Import

| Overload | Notes |
|----------|-------|
| `Import(bool silent = false)` | File dialog; calls `EnsureShellAssociations` |
| `Import(string filename)` | Silent |
| `Import(string filename, bool silent)` | May prompt legacy XML upgrade when not silent |
| `Import(string filename, string themeName[, bool silent])` | Named theme from a collection |
| `Import(Stream…)` / `Import(byte[]…)` | Stream sniff via binary persistence |

**`silent`:** `true` suppresses success/error message boxes and skips `PromptLegacyXmlUpgrade`. Prefer trusting the implementation over any inverted XML comments.

### Export

| Overload | Notes |
|----------|-------|
| `Export()` | Dialog; default `.kthemex` |
| `Export(string path, bool ignoreDefaults[, bool silent[, format]])` | Path selects Xml vs native; format overload for compressed-XML `.ktheme` |
| `Export(bool ignoreDefaults)` | Returns XML **bytes** |

### Upgrade / convert on the component

```csharp
void UpgradeXmlToKthemex(...);           // rewrite file + import into this instance
KryptonPaletteDirectoryUpgradeResult UpgradeXmlToKthemexFromDirectory(...); // batch; does not import
void ConvertFile(string source, string dest[, bool silent]);
void ConvertFile(bool silent);           // dialogs
```

Designer verbs on `KryptonCustomPaletteBaseDesigner`:

- Import / Export
- **Upgrade Palette** — schema into the component only (no file rewrite)
- **Upgrade .xml to .kthemex...** / **Upgrade folder .xml to .kthemex...**
- **Convert palette file...**

### Thumbnail

```csharp
Image? Thumbnail { get; set; } // optional preview; recommended 64×64
```

---

## `ThemeManager` file apply

```csharp
public static void ApplyTheme(string themeFile, bool silent, KryptonManager manager);
public static void ApplyTheme(string themeFile, string themeName, bool silent, KryptonManager manager);
```

Creates a `KryptonCustomPaletteBase`, imports (named when provided), then assigns `manager.GlobalCustomPalette`.

Also: `ApplyTheme(PaletteMode)`, `ApplyTheme(string themeName)`, `ApplyTheme(KryptonCustomPaletteBase, …)` for builtins / in-memory palettes.

---

## Related Toolkit types

| Type | Role |
|------|------|
| `KryptonPaletteFileFormat` | Persist format enum |
| `KryptonPaletteDirectoryUpgradeResult` | `ConvertedPaths`, `SourcePaths`, `SkippedPaths`, `Errors`, counts, `ToSummaryString()`, `Empty` |
| `KryptonPaletteDirectoryUpgradeError` | `SourcePath`, `Message` |
| `KryptonThemePreview` | Generated mock-up; `AssignGeneratedThumbnail` for Export |
| `KryptonMiscellaneousThemeStrings` | `LegacyXmlUpgradeTitle` / `LegacyXmlUpgradeMessage`; Themes-missing fallbacks |

---

## `Krypton.Themes.KryptonThemeCustomPaletteHelper`

Optional assembly helper (not referenced by Toolkit):

- `CreateCustomPalette(PaletteMode)` — `PopulateFromBase` + display name
- `ExportToFile(mode, path[, ignoreDefaults])` / format overload

Use when exporting **extra** builtin modes to `.kthemex` / `.ktheme`.

---

## Internal: `KryptonPaletteBinaryPersistence`

Document for maintainers; do not call from consumer code.

| Concern | Behaviour |
|---------|-----------|
| `Sniff` | KPLT vs XML vs unknown |
| `Import` / `Export` | Dispatch by format / kind |
| `ExportCollection` | Kind 2 + optional KPTH |
| `TryCopyXmlForUpgrade` | XML or kind 0 only |
| `TryGetSchemaVersion` | XML attribute or KPLT header |
| Collection import without name | Exactly one theme → import it; more than one → throw |

[← File Formats](./02-File-Formats.md) · [Index](./README.md) · [Next: Collections →](./04-Collections.md)
