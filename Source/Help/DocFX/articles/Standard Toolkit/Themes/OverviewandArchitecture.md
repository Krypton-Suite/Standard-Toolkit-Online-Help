# 01 — Overview and Architecture

[Index](PaletteFilesIndex.md) · [Next: File Formats →](FileFormats.md)

## Goals

Issue [#2117](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2117) adds first-class palette file I/O beyond ad-hoc XML:

- A dedicated **XML** extension (`.kthemex`) for human-editable single themes.
- An optional **binary container** (`.ktheme`) for compact single themes and **multi-theme collections**.
- **Upgrade / convert** paths from legacy `.xml` (and older schema versions).
- **Thumbnails**, **per-user shell associations**, and Utilities **selectors / collection editor**.

Toolkit owns formats and core APIs. Utilities owns consumer UI that lists and edits files. Themes remains optional for exporting **extra** builtin modes.

## Rename history (pre-release)

Development briefly used other names. Current public surface uses:

| Unreleased | Current |
|------------|---------|
| `.kpal` | `.ktheme` |
| `.kpalx` | `.kthemex` |
| Pack / `ExportPack` / `IsPack` | Collection / `ExportCollection` / `IsCollection` |
| ProgIDs `Krypton.Toolkit.PaletteBinary` / `PaletteXml` | `kthemefile` / `kthemexfile` |

`EnsureShellAssociations` **unregisters** leftover `.kpal` / `.kpalx` associations when they still point at the old toolkit ProgIDs. Do not reintroduce those extensions in docs or new APIs.

## Owning types

```
KryptonCustomPaletteBase          ← designer/runtime component; Import/Export/Upgrade
        │
        ▼
KryptonPaletteFile (static)       ← path helpers, convert, collections, shell, icons
        │
        ▼
KryptonPaletteBinaryPersistence   ← internal sniff / read / write of KPLT + XML
        │
        ▼
ThemeManager.ApplyTheme(file…)    ← load into GlobalCustomPalette

Utilities (optional package):
  KryptonPaletteFile* selectors   ← scan folder → ThemeItem → Apply
  KryptonPaletteCollectionEditor  ← UI over Add/Remove/SetCollectionName
```

## Data flow (summary)

### Export single theme

1. Caller: `KryptonCustomPaletteBase.Export(path, …)` or `Export(bool)` (XML bytes).
2. `KryptonPaletteFile.FormatFromPath` chooses XML vs native binary for path-based export.
3. `KryptonPaletteBinaryPersistence.Export` writes either:
   - Plain `KryptonPalette` XML (`.kthemex` / `.xml`), or
   - `KPLT` kind 0 (compressed XML) or kind 1 (native) for `.ktheme`.

### Export collection

1. Caller: `ExportCollection` / `ExportCollectionFromDirectory` / `AddToCollection` rewrite.
2. Destination **must** be `.ktheme`.
3. Persistence writes `KPLT` kind 2 (named entries, typically native payloads) plus optional trailing `KPTH` thumbnail catalog.

### Import / apply

1. Open stream/path → sniff XML vs `KPLT`.
2. Optional `PromptLegacyXmlUpgrade` for interactive `.xml` loads.
3. Multi-theme files require `themeName` (or exactly one entry).
4. `ThemeManager.ApplyTheme` sets `KryptonManager.GlobalCustomPalette`.

### Upgrade / convert

1. `ImportWithUpgrade` / `Convert` / `UpgradeXmlToKthemex*` raise schema via the existing XSLT path when the payload is XML (or compressed-XML kind 0).
2. Native kind-1 payloads must already be at the current schema; they are not XSLT-upgraded.

## Design constraints

- **No Toolkit → Themes project reference** (cycle). Extra-mode export goes through `Krypton.Themes.KryptonThemeCustomPaletteHelper` when that assembly is loaded.
- **C# 7.3 / net472** compatibility on public Toolkit APIs.
- **Empty collections are forbidden** — export requires ≥1 theme; `RemoveFromCollection` cannot remove the last theme.
- **JSON is not a palette format** — rejected by convert/path helpers.
- **V120 LTS** is planned to drop remaining `.xml` palette support (ToDo comments throughout the file API). Prefer `.kthemex` in new code.

## Related features

- Builtin theme catalog: `Documents/Development/KryptonThemesCatalog.md` (when present) — orthogonal to custom file I/O.
- Theme preview generation: `KryptonThemePreview` / `AssignGeneratedThumbnail` (Designer and Theme Browser Export).
- Schema tool: Palette Upgrade Tool (via Krypton Explorer) for interactive XSLT upgrades.

[Index](PaletteFilesIndex.md) · [Next: File Formats →](FileFormats.md)
