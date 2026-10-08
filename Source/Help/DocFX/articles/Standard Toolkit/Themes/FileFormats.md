# 02 — File Formats

[← Overview](./01-Overview-and-Architecture.md) · [Index](./README.md) · [Next: Core API →](./03-Core-API.md)

## Extensions

| Extension | Constant | Role | Content |
|-----------|----------|------|---------|
| `.kthemex` | `KryptonPaletteFile.Extension` (`"kthemex"`) | Preferred single-theme file | Plain `KryptonPalette` XML |
| `.ktheme` | `KryptonPaletteFile.BinaryExtension` (`"ktheme"`) | Binary container (single or collection) | `KPLT` + payload kind |
| `.xml` | `KryptonPaletteFile.XmlExtension` (`"xml"`) | Legacy single-theme | Same XML document; retire in **V120 LTS** |
| `.json` | — | Not supported | Rejected with `ArgumentException` |

`IsPaletteExtension` is true only for `.kthemex` and `.ktheme` (not `.xml`).

`DialogFilter` lists kthemex, ktheme, xml, and `*.*` (xml entry marked ToDo for V120).

## `KryptonPaletteFileFormat`

```csharp
public enum KryptonPaletteFileFormat
{
    Xml = 0,                  // .kthemex / .xml; also Export(bool) byte[]
    PaletteCompressedXml = 1, // .ktheme KPLT kind 0 (Deflate XML)
    PaletteBinary = 2         // .ktheme KPLT kind 1 (native); default for .ktheme paths
}
```

`FormatFromPath`:

- `.ktheme` → `PaletteBinary`
- Everything else (including `.kthemex` / `.xml`) → `Xml`

Compressed-XML `.ktheme` requires the explicit format overload; path-only export writes native.

## When to use which format

| Scenario | Prefer |
|----------|--------|
| Designer / hand-edit / source control | `.kthemex` |
| Compact single theme | `.ktheme` native (`PaletteBinary`) |
| Single theme as compressed XML inside KPLT | `.ktheme` + `PaletteCompressedXml` |
| Several named themes in one file | `.ktheme` collection (kind 2 only) |
| Entire folder catalog | `ExportCollectionFromDirectory` → kind 2 |
| Legacy Theme-Palettes trees | Still `.xml` until upgraded |

Collections **cannot** be written as `.kthemex`.

## KPLT container layout

Magic: `KryptonPaletteFile.ContainerMagic` = `"KPLT"`.

Little-endian layout (`KryptonPaletteBinaryPersistence`):

1. Magic — 4 ASCII bytes `KPLT`
2. Container version — `uint16` (`CurrentContainerVersion = 1`)
3. Payload kind — `uint16`
   - `0` — compressed XML (Deflate)
   - `1` — native persist stream (+ PNG image table)
   - `2` — named multi-theme collection
4. Palette schema version — `int32` (`SharedStaticConstants.CURRENT_SUPPORTED_PALETTE_VERSION`, currently **22**)
5. Name length (`uint16`) + UTF-8 name (header / single-theme display name)
6. Payload bytes

### Kind 2 collection payload

1. `uint16` theme count
2. Per entry: UTF-8 name, `uint16` inner kind, `int32` length, payload
3. New exports use **native** (kind 1) inner payloads; older compressed-XML entries remain readable

### Trailing thumbnail catalog (collections only)

After kind-2 entries:

1. Magic `KPTH` (`ThumbnailCatalogMagic`)
2. Catalog version `uint16` (`ThumbnailCatalogVersion = 1`)
3. Payload length + per-theme PNG previews (name, width, height, bytes; max **1 MiB** per image)

Does **not** bump the KPLT container version. Older readers ignore bytes past the pack entries. Catalog version mismatch → treat as no thumbnails.

Recommended stored size: `KryptonPaletteFile.RecommendedThumbnailSize` = **64**.

## XML document (`.kthemex` / `.xml`)

- Root: `KryptonPalette` with `Version` and optional `Name`
- Thumbnail: optional base64 PNG in the XML image cache (`KryptonCustomPaletteBase.Thumbnail`)
- No magic bytes; sniff looks for XML

## Native payload (kind 1)

1. Image table: `int32` count, then name + PNG length + PNG
2. Property records walking the `[KryptonPersist]` graph:
   - `RecordEnd = 0`
   - `RecordNavigate = 1`
   - `RecordValue = 2`

## Sniffing

`KryptonPaletteBinaryPersistence.Sniff` (seekable stream) distinguishes:

- KPLT container
- XML palette
- Unknown

Public helpers (`IsCollection`, `GetThemeNames`, Import) open the file and delegate to persistence.

## Schema version

| Path | Behaviour |
|------|-----------|
| XML / kind 0 | Can be raised via `ImportWithUpgrade` / Convert / UpgradeXml* (XSLT) |
| Native kind 1 | Must already match current schema; no XSLT upgrade |
| Plain Import of older schema XML | Throws without upgrading (use upgrade APIs) |

## Path helpers for collection theme names

Folder-derived theme names use portable `/` (`CollectionPathSeparator`):

- `NormalizeCollectionThemeName`
- `IsCollectionThemePath` / `SplitCollectionThemePath` / `CombineCollectionThemePath`
- `ToDisplayPath` (OS separators for UI)
- `GetRelativeCollectionThemeName(filePath, rootDirectory)`

Nested `.ktheme` files under a directory pack are **flattened** under the parent relative path. Name collisions get `" (2)"`-style suffixes.

[← Overview](./01-Overview-and-Architecture.md) · [Index](./README.md) · [Next: Core API →](./03-Core-API.md)
