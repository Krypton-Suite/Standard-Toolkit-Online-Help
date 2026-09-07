# Custom palette files

Maintainer notes for `.kthemex` XML, the optional native `.ktheme` KPLT container, and
multi-theme `.ktheme` collections used by `KryptonCustomPaletteBase`.

These names were never in a public release. Do **not** keep `.kpalx` or `.kpal` as
aliases. The only shipped legacy extension is **`.xml`**.

## Overview

Custom palettes persist as versioned XML (`KryptonPalette` root, schema
`SharedStaticConstants.CURRENT_SUPPORTED_PALETTE_VERSION`). The dedicated XML extension is
**`.kthemex`** — the same human-readable XML previously saved as `.xml`. Legacy `.xml`
paths remain supported until V120 LTS.

An optional compact `.ktheme` KPLT container (native persist by default, or compressed XML
via explicit `KryptonPaletteFileFormat`) is available from a `.ktheme` path. A `.ktheme`
**collection** (payload kind 2) stores several named themes in one file. `.kthemex` remains
one document.

| Extension | Role |
|-----------|------|
| `.kthemex` | Preferred XML theme (`KryptonPaletteFile.Extension`) |
| `.ktheme` | Optional KPLT binary container (`BinaryExtension`) |
| `.xml` | Released legacy XML (`XmlExtension`); remove in V120 LTS |

**`.xml` is legacy.** New files should be `.kthemex`. Call `KryptonPaletteFile.UpgradeXmlToKthemex`
(or `KryptonCustomPaletteBase.UpgradeXmlToKthemex` to rewrite and load) to convert
`theme.xml` → `theme.kthemex` (source left in place; schema upgraded via
`ImportWithUpgrade`). Interactive loads warn first — see **Legacy `.xml` load warning**.
V120 LTS TODOs mark where `.xml` extension support can be removed; `.kthemex` stays an
XML document and `Export(bool)` still returns XML bytes.

Package: `Krypton.Toolkit` owns persistence and `KryptonCustomPaletteBase` import/export
(Toolkit cannot project-reference Themes). `Krypton.Themes` consumes those APIs through
`KryptonThemeCustomPaletteHelper` so extra palettes (macOS, Material, Visual Studio, …)
can be populated and written as `.kthemex`, `.ktheme`, or XML. Folder selectors that list
those files live in `Krypton.Toolkit.Utilities` (see **Selector controls**).

Authoring and maintaining files is a Demos app, not a Toolkit package: **Krypton Palette
Author** (see **Authoring app**). Palette Upgrade Tool remains the separate installer for
pre-v21 XML schema upgrades. TestForm `PaletteBinaryDemo` is the maintainer round-trip
harness, not an editor.

## Preferred format: `.kthemex`

`.kthemex` is XML. `Export("theme.kthemex")` writes `ExportToXmlDocument` bytes (UTF-8, with
BOM when that is how XML export already behaves). A text editor can open the file.
`Import` sniffs XML (`<`, optional UTF-8 BOM / whitespace) regardless of extension.

## Optional KPLT container

Little-endian `BinaryReader` / `BinaryWriter`, used only for `.ktheme` / explicit
`PaletteCompressedXml` / `PaletteBinary`:

| Offset | Size | Field |
|--------|------|-------|
| 0 | 4 | ASCII magic `KPLT` |
| 4 | 2 | Container version (`uint16`, currently 1) |
| 6 | 2 | Payload kind (`uint16`): 0 = Deflate XML, 1 = native persist, 2 = named collection |
| 8 | 4 | Palette schema version (`int32`, same as XML `Version`) |
| 12 | 2 | Name length (`uint16`) |
| 14 | N | UTF-8 palette or collection name (may be empty) |
| 14+N | * | Payload |

Do **not** bump the KPLT container version for collections or the thumbnail catalog.
Implementation: `KryptonPaletteBinaryPersistence` (internal). Public surface:
`KryptonPaletteFileFormat`, `KryptonPaletteFile`, and the import/export overloads on
`KryptonCustomPaletteBase`.

## Payload kinds

- **Kind 0 (`PaletteCompressedXml`)** — `DeflateStream` of the existing
  `ExportToXmlDocument` output. Upgrade path: inflate, then the XML PaletteUpgradeTool /
  `ImportWithUpgrade` XSLT.
- **Kind 1 (`PaletteBinary`, default for `.ktheme`)** — tagged persist stream that
  walks the same `[KryptonPersist]` tree as XML. Leaf values use the same type names and
  invariant `TypeConverter` strings (including Font `"(none)"`). Images are a PNG blob
  table at the start of the payload, referenced by string id. Unknown properties are
  skipped; missing properties keep their current values.
- **Kind 2 (collection)** — several named kind-1 payloads in one container. See
  **Multi-theme `.ktheme` collection**. New single-theme files must stay readable by older
  toolkits, so the container version stays 1.

Native files are written at the current schema version only. Pre-v21 themes stay XML +
PaletteUpgradeTool. `BinaryFormatter` is not used. JSON is not a palette format.

## Import sniffing

`Import(string)` / `Import(Stream)` peek the first bytes:

1. `KPLT` → container (switch on payload kind)
2. XML (`<`, optional UTF-8 BOM / whitespace) → `ImportFromXmlDocument`
3. Otherwise → throw

`ThemeManager.ApplyTheme(string)` therefore accepts both formats with no call-site change.
A non-silent apply of a `.xml` path shows **Legacy `.xml` load warning** and may rewrite
to `.kthemex` before applying. Silent apply still loads `.xml` as-is.
A multi-theme collection needs `ApplyTheme(themeFile, themeName, silent, manager)` (or
`Import(path, themeName)`). Unnamed `Import` on a collection with more than one theme throws
and lists the names. A collection with exactly one theme loads that entry.

XML documents write a `Name` attribute on the `KryptonPalette` root when
`PaletteName` is set. `ImportFromXmlDocument` restores that attribute so `.kthemex`
round-trips the display name the same way the KPLT header does.

## Persist type map

Leaf `[KryptonPersist]` properties are written with a `Type` attribute from
`KryptonCustomPaletteBase.TypeToString`. New persistable value types **must** be
added to `_typeTests` (import uses the inverse `StringToType` map). Missing entries
throw `Unrecognised type '…' for export` — that is how `PaletteCornerRounding`
broke full exports until it was registered.

## Shell icons

`.ktheme` and `.kthemex` share the Stable Kr tile (`Krypton.Toolkit.Utilities` resource
`Krypton Stable.png`, embedded as `Resources/KryptonPalette.ico`, 16/32/48).

| API | Role |
|-----|------|
| `IsPaletteExtension` | True for `.ktheme` / `.kthemex` only (path or extension). False for `.xml`, `.kpal`, `.kpalx` |
| `CreateShellIcon` | Icon from the embedded ICO (caller disposes) |
| `EnsureShellAssociations` | Per-user `HKCU\Software\Classes` ProgIds + `DefaultIcon` |

`EnsureShellAssociations` extracts the ICO to
`%LocalAppData%\Krypton-Suite\KryptonPalette.ico`, registers
`Krypton.Toolkit.PaletteXml` (`.kthemex`) and `Krypton.Toolkit.PaletteBinary` (`.ktheme`),
then notifies the shell. It also removes leftover per-user `.kpal` / `.kpalx` keys from
this unreleased work when they still point at those ProgIds. Import/export dialogs, the
theme browser export, and `PaletteBinaryDemo` call it automatically.
`FileSystemIconHelper.GetFileIcon` returns the embedded icon for `IsPaletteExtension`
so Krypton file dialogs do not wait on Explorer.

## Export rules

| API | Result |
|-----|--------|
| `Export(string path, …)` | `.kthemex` / `.xml` / other → XML; `.ktheme` → native persist stream |
| `Export(string, bool, bool, KryptonPaletteFileFormat)` | Explicit XML / compressed-XML / native |
| `ExportPalette(Stream, format, ignoreDefaults)` | Stream equivalent of the explicit format |
| `Export(bool)` / `Export(Stream)` | **XML bytes** (unchanged, binary compatible) |

File dialogs use `KryptonPaletteFile.DialogFilter`: `.kthemex` first, then `.ktheme`
(Krypton theme containers), then legacy `.xml`.

`FormatFromPath` maps `.ktheme` to `PaletteBinary` and every other extension (including
`.kthemex` and `.xml`) to `Xml`. That is not an alias for unreleased names: `.kpal` is
not listed, not scanned, and `IsPaletteExtension` is false.

## Convert / rewrite

`KryptonPaletteFile.Convert(source, destination)` loads the source with
`ImportWithUpgrade`, then exports to the destination path (or an explicit
`KryptonPaletteFileFormat`). Use this to rewrite current `.kthemex` / `.ktheme`, or to
produce an optional native `.ktheme` from XML.

`ImportWithUpgrade` peeks the schema version first. When it is below
`CURRENT_SUPPORTED_PALETTE_VERSION`, XML (and kind-0 compressed XML) is upgraded
**before** import: structural XSLT for versions below 20, then the `Version`
attribute is set to the current persist version (so schema 20 and 21 convert
without a version-mismatch dialog). Native `.ktheme` that is not already current
still cannot be upgraded.

For the dedicated **`.xml` → `.kthemex`** path, prefer `UpgradeXmlToKthemex`. Interactive
loads should go through `PromptLegacyXmlUpgrade` (already called from `Import` when
`silent` is false).

To convert a folder of legacy `.xml` palettes:

```csharp
var result = KryptonPaletteFile.UpgradeXmlToKthemexFromDirectory(@"C:\Themes", searchSubdirectories: true);
// result.ConvertedPaths / SourcePaths / SkippedPaths / Errors
```

Nested folders are included by default. Non-palette `.xml` is skipped. One failure does not
stop the rest. `KryptonCustomPaletteBase.UpgradeXmlToKthemexFromDirectory` is the same rewrite
(optionally with a folder dialog) and does **not** import into the component.

```csharp
// Same folder: theme.xml → theme.kthemex (source .xml is not deleted)
var kthemexPath = KryptonPaletteFile.UpgradeXmlToKthemex(@"C:\Themes\theme.xml");

// Explicit destination (must be .kthemex)
KryptonPaletteFile.UpgradeXmlToKthemex(@"C:\Themes\theme.xml", @"C:\Themes\Out\theme.kthemex");

using (var palette = new KryptonCustomPaletteBase())
{
    // Rewrite and import into this instance
    palette.UpgradeXmlToKthemex(@"C:\Themes\theme.xml");

    // Interactive: warn, then upgrade / load anyway / cancel
    var toLoad = KryptonPaletteFile.PromptLegacyXmlUpgrade(@"C:\Themes\other.xml", silent: false);
    if (toLoad != null)
    {
        palette.Import(toLoad, silent: true);
    }
}
```

| Source | Result |
|--------|--------|
| Legacy `.xml` via `UpgradeXmlToKthemex` | `.kthemex` beside the source (or an explicit `.kthemex` path) |
| Folder of `.xml` via `UpgradeXmlToKthemexFromDirectory` | Each palette `.xml` → `.kthemex` beside the source; non-palette XML skipped |
| Current-schema `.xml` / `.kthemex` via `Convert` | Re-exported at the current schema |
| Older XML (schema below current, including 21) | Schema raised, then export |
| Older XML with structural XSLT (below 20), or compressed-XML `.ktheme` kind 0 | XSLT, version bump, then export |
| Native `.ktheme` (kind 1) | Import only when already current schema |
| `.json` | Throws — JSON is not a Krypton palette document |

Default `ignoreDefaults` is `false` so converted files keep explicit persist values.

Designer verbs on `KryptonCustomPaletteBase`:

| Verb | API | File rewrite | Loads into the component |
|------|-----|--------------|--------------------------|
| **Upgrade Palette** | `ImportWithUpgrade` | No | Yes (schema XSLT) |
| **Upgrade .xml to .kthemex...** | `UpgradeXmlToKthemex(bool)` | Yes (`theme.xml` → `theme.kthemex`) | Yes |
| **Upgrade folder .xml to .kthemex...** | `UpgradeXmlToKthemexFromDirectory(bool)` | Yes (each `theme.xml` → `theme.kthemex`) | No |
| **Convert palette file...** | `ConvertFile(bool)` | Yes (chosen destination) | Yes |

TestForm `PaletteBinaryDemo` has **Upgrade .xml to .kthemex...**
(`KryptonCustomPaletteBase.UpgradeXmlToKthemex`), **Upgrade folder .xml to .kthemex...**
(`UpgradeXmlToKthemexFromDirectory`), and **Convert XML to .kthemex...**
(`ConvertFile`).

`Convert` is single-theme. Unnamed import of a multi-theme collection fails, so those files
are not rewritten as a unit.

### Phasing out `.xml` (V120 LTS)

`// ToDo V120 LTS:` comments mark the `.xml` **extension** (not `.kthemex` XML content):

- `KryptonPaletteFile.XmlExtension`, `DialogFilter` (`*.xml`), `FormatFromPath`
- `IsLegacyXmlExtension` / `PromptLegacyXmlUpgrade` (stop offering “load .xml anyway”)
- `GetPaletteFiles` / selector `IncludeXml` (default true)
- `UpgradeXmlToKthemexFromDirectory` / designer folder verb
- Designer convert open-dialog `DefaultExt`
- Path `Export` / `Import` remarks that still advertise `.xml`
- `LegacyXmlUpgradeTitle` / `LegacyXmlUpgradeMessage` once the prompt is removed

Leave in place at V120: sniffing XML **content** for `.kthemex`, KPLT kind 0 compressed
XML inside `.ktheme`, and `Export(bool)` XML bytes. Workspace, docking, translations, and
toolbar XML files are unrelated.

## Legacy `.xml` load warning

Interactive loads of a `.xml` palette (import with `silent: false`, theme apply from
selectors, `ThemeManager.ApplyTheme` when not silent, designer **Upgrade Palette**)
call `KryptonPaletteFile.PromptLegacyXmlUpgrade`. The dialog is localisable:

| String | Location |
|--------|----------|
| Title | `KryptonManager.Strings.MiscellaneousThemeStrings.LegacyXmlUpgradeTitle` |
| Body | `LegacyXmlUpgradeMessage` (`{0}` file name, `{1}` Yes, `{2}` No, `{3}` Cancel) |
| Buttons | `GeneralToolkitStrings` Yes / No / Cancel (already localised) |

| Choice | Result |
|--------|--------|
| Yes | `UpgradeXmlToKthemex` then apply the `.kthemex` (source `.xml` left in place) |
| No | Apply the `.xml` file without rewriting |
| Cancel | Do not import or apply |

Silent imports (`Import(path)` / `Import(path, true)`) skip the prompt so tests and
batch loads keep working. Translators should keep `{0}`–`{3}` in `LegacyXmlUpgradeMessage`.
Export/import these strings with the rest of `KryptonManager.ToolkitStrings`
(Translations.xml / JSON).

`KryptonPaletteFile.IsLegacyXmlExtension` is the counterpart to `IsPaletteExtension`
(which already excludes `.xml`).

## Multi-theme `.ktheme` collection

Single-theme `.ktheme` files are unchanged (container version 1, kind 0 or 1). Collections
use the same header with **kind 2**. Header name is an optional collection display name,
not a theme name.

Kind 2 payload (after the usual KPLT header):

| Field | Size |
|-------|------|
| Count | `uint16` |
| Per entry: name length, UTF-8 name, inner kind (`uint16`, 0 or 1), payload length (`int32`), payload | repeating |

Each collected palette must have a unique `SetPaletteName` (ordinal ignore-case). Inner
payloads are native persist (kind 1) at the current schema. Destination must be `.ktheme`
(`.kthemex` and JSON are rejected).

Folder catalogs (for example `Theme-Palettes\Palettes\Office Themes\2013\…`) are stored
with `ExportCollectionFromDirectory`. Theme names are the relative paths using `/`
(`Office Themes/2013/Access 2013`). That does **not** bump the container version. Nested
`.ktheme` collections in the folder are flattened. `Import(path, themeName)` uses that full
path as `themeName`.

| API | Role |
|-----|------|
| `KryptonPaletteFile.ExportCollection` | Write `.ktheme` only |
| `KryptonPaletteFile.ExportCollectionFromDirectory` | Store a folder tree; names are relative `/` paths |
| `KryptonPaletteFile.AddToCollection` | Add a `.kthemex` / `.xml` / `.ktheme` (or an in-memory palette) to a collection; creates or promotes as needed |
| `KryptonPaletteFile.RemoveFromCollection` | Drop a named theme; throws if it would leave the collection empty |
| `KryptonPaletteFile.GetCollectionName` / `SetCollectionName` | Kind-2 header display name |
| `KryptonPaletteFile.GetPaletteFiles` | List `.kthemex` / `.ktheme` / `.xml` under a folder |
| `KryptonPaletteFile.GetThemeNames` | Names in file order (one name for single-theme files) |
| `KryptonPaletteFile.GetThemeThumbnails` | Optional previews in the same order (caller disposes) |
| `KryptonPaletteFile.IsCollection` | True only for kind 2 |
| `KryptonPaletteFile.IsCollectionThemePath` / `SplitCollectionThemePath` / `ToDisplayPath` | Path-named themes |
| `KryptonPaletteFile.CollectionPathSeparator` | `/` stored in path-named theme names |
| `KryptonCustomPaletteBase.Import(path, themeName)` | Load one named theme |
| `ThemeManager.ApplyTheme(file, themeName, silent, manager)` | Apply one collected theme |

Older toolkits skip unknown persist properties, so adding `Thumbnail` later did not require a schema bump.

## Thumbnails

`KryptonCustomPaletteBase.Thumbnail` is an optional `Image` (recommended
`KryptonPaletteFile.RecommendedThumbnailSize`, 64×64 PNG). It persists in `.kthemex` / XML
and in native `.ktheme` payloads. There is no automatic preview generator: set the image
in the designer, in code, or in **Krypton Palette Author** (Load thumbnail / Clear).
Leave it null when the file has no preview.

Kind 2 collections append an optional **KPTH** catalog after the last entry (container
version stays 1):

| Field | Size |
|-------|------|
| Magic | 4 ASCII `KPTH` |
| Catalog version | `uint16` (currently 1) |
| Byte length | `int32` of the following payload |
| Payload: count, then per image name / width / height / PNG | `byte length` |

Readers that do not understand a newer catalog version skip `byte length` bytes.
`KryptonPaletteFile.GetThemeThumbnails` returns images in `GetThemeNames` order (caller
disposes). Selectors: `ShowThumbnails` / `ThumbnailSize` on the list, combo, and tree.

## Selector controls (Utilities)

`KryptonPaletteFileListBox`, `KryptonPaletteFileComboBox`, and `KryptonPaletteFileTreeView`
live in `Krypton.Toolkit.Utilities` (NuGet: `Krypton.Standard.Toolkit`). They are not
substitutes for `KryptonThemeListBox` / `KryptonThemeComboBox`, which list builtin catalog
modes.

Set `PaletteDirectory` to a folder of `.kthemex` / `.ktheme` / `.xml` files. `SearchSubdirectories`
(default **true** on the tree, **false** on list/combo) includes nested folders. Collections
expand to one item per named theme. Path-named collection themes
(`Office Themes/2013/Access 2013`) rebuild the same tree as the original directory.
Unreadable files are skipped. `AutoApply` (default true) imports the selection and assigns
it as the global custom palette. Applying a `.xml` item calls `PromptLegacyXmlUpgrade`
(`TryImportInto` with `promptLegacyXml: true`). Folder nodes on the tree do not apply.
`Reload()` rescans; `ApplySelected()` applies without `AutoApply`.

`KryptonPaletteFileThemeItem.FromDirectory` is the scan API. `TreePath` is the `/`-separated
folder path used by the tree and by nested list labels. `Thumbnail` is filled when
`ShowThumbnails` / `loadThumbnails` is true.

| Property | Default | Role |
|----------|---------|------|
| `PaletteDirectory` | empty | Folder to scan (`FolderNameEditor` in the designer) |
| `SearchSubdirectories` | false (list/combo), true (tree) | Nested folders |
| `IncludeKthemex` / `IncludeKtheme` / `IncludeXml` | true | Extension filters |
| `ShowThumbnails` | false | Load and show `Thumbnail` when present |
| `ThumbnailSize` | 32×32 | Display size for loaded previews |
| `KryptonManager` | new instance | Target for apply |
| `SelectedPaletteTheme` | — | Current `KryptonPaletteFileThemeItem` (null on folder nodes) |

## Collection editor (Utilities)

`KryptonPaletteCollectionEditor` is a toolbox `Component` in `Krypton.Toolkit.Utilities`.
Call `ShowDialog` / static `Show(owner, collectionPath)` to add `.kthemex` (or `.ktheme` /
`.xml`) files and remove named themes. Add and remove save immediately through
`AddToCollection` / `RemoveFromCollection`. The last theme cannot be removed.

TestForm: `PaletteCollectionEditorDemo` under `KryptonUtilities\Feature` (StartScreen
**2117 Palette collection editor**). `PaletteBinaryDemo` also has **Edit .ktheme collection...**.

## Authoring app

**Krypton Palette Author** is a Demos WinExe (`Source/Krypton Toolkit Examples/KryptonPalette Author`,
assembly `Krypton Palette Author`).
Krypton Explorer launches it from the Toolkit examples page (link **Krypton Palette Author**).
Do not put this project in Standard-Toolkit.

It is the place to create and edit palette files:

- New / Open / Save / Save As (`.kthemex` default, `.ktheme` native, `.xml` legacy)
- **Upgrade .xml to .kthemex** via `KryptonCustomPaletteBase.UpgradeXmlToKthemex` (same folder; source left in place; loads into the editor)
- **Upgrade folder .xml to .kthemex** via `KryptonPaletteFile.UpgradeXmlToKthemexFromDirectory` (nested folders; source left in place; does not load into the editor)
- Convert via `KryptonCustomPaletteBase.ConvertFile` (uses `UpgradeXmlToKthemex` when the source is `.xml` and the destination is `.kthemex`)
- Open of `.xml` uses silent `Import` (no load warning); use **Upgrade .xml to .kthemex** or the Toolkit prompt on apply
- Store a folder tree via `ExportCollectionFromDirectory`
- **Edit .ktheme collection** via `KryptonPaletteCollectionEditor` (add `.kthemex` files, remove named themes)
- Populate from a builtin or extra catalog theme (`BasePaletteMode` + `PopulateFromBase`)
- Palette name and optional `Thumbnail`
- Property grid on the working `KryptonCustomPaletteBase` with a live control preview
- `KryptonPaletteFileTreeView` of a working folder (`AutoApply` false; double-click loads
  into the editor). Multi-theme collections prompt for a name.

`KryptonPalette Examples` stays the control sample (import/export, **Upgrade .xml to .kthemex**, **Upgrade folder .xml to .kthemex**, and **Edit .ktheme collection** appended for #2117).
Do not overwrite that project.
