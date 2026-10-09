# 05 — Upgrade, Convert, and Migration

[← Collections](./Collections.md) · [Index](./PaletteFilesIndex.md) · [Next: Thumbnails & Shell →](./ThumbnailsandShell.md)

## Current schema

Palette schema version is `SharedStaticConstants.CURRENT_SUPPORTED_PALETTE_VERSION` (currently **22**). Older XML (e.g. 20/21) must go through an upgrade path before a plain silent Import succeeds.

## Upgrade strategies

| API | Rewrites file? | Imports into component? | Typical use |
|-----|----------------|-------------------------|-------------|
| Designer **Upgrade Palette** | No | Yes (schema only) | Fix in-memory / open document |
| `UpgradeXmlToKthemex` | Yes (`.xml` → `.kthemex`) | File API: no; component overload: yes | Dedicated extension migration |
| `UpgradeXmlToKthemexFromDirectory` | Yes (batch) | No | Catalogs / Theme-Palettes trees |
| `Convert` / `ConvertFile` | Yes (any supported → dest) | Component overload: yes | Format change + schema raise |
| `ImportWithUpgrade` | No (unless paired with Export) | Yes | Load older XML/kind-0 into memory |
| `PromptLegacyXmlUpgrade` | On Yes | Caller imports returned path | Interactive warn on `.xml` open |

### Single-file XML → kthemex

```csharp
// Source.xml remains; Mine.kthemex written beside it (default dest)
string dest = KryptonPaletteFile.UpgradeXmlToKthemex(@"C:\Themes\Source.xml");

// Or explicit destination
KryptonPaletteFile.UpgradeXmlToKthemex(source, dest);
```

Source must be `.xml`; destination must be `.kthemex`.

### Bulk folder upgrade

```csharp
var result = KryptonPaletteFile.UpgradeXmlToKthemexFromDirectory(
    @"C:\Theme-Palettes\Palettes",
    searchSubdirectories: true);

Console.WriteLine(result.ToSummaryString());
// ConvertedPaths / SourcePaths / SkippedPaths / Errors
```

Non-palette `.xml` files are **skipped** (counted). One failure does not stop the rest.

### Convert between formats

```csharp
KryptonPaletteFile.Convert(source, dest);
KryptonPaletteFile.Convert(source, dest, KryptonPaletteFileFormat.PaletteBinary, ignoreDefaults: true);
```

Uses `ImportWithUpgrade` then `Export`. JSON destinations/sources are rejected.

## Interactive legacy XML prompt

When a non-silent Import hits `.xml`:

1. `PromptLegacyXmlUpgrade` shows Yes / No / Cancel.
2. Strings: `KryptonManager.Strings.MiscellaneousThemeStrings.LegacyXmlUpgradeTitle` / `LegacyXmlUpgradeMessage` (`[Localizable(true)]`).
3. Button text from `GeneralToolkitStrings` (accelerators stripped). Bad format → English fallback.
4. Silent imports and non-`UserInteractive` sessions skip the dialog and leave the `.xml` path.

## What can be schema-upgraded

| Payload | XSLT / ImportWithUpgrade |
|---------|--------------------------|
| Plain XML / `.kthemex` / `.xml` | Yes |
| KPLT kind 0 (compressed XML) | Yes (`TryCopyXmlForUpgrade`) |
| KPLT kind 1 (native) | **No** — must already be current schema |
| Collection entries | Inner payloads follow the same rules; new exports write native |

## V120 LTS plan (ToDo in source)

Marked throughout the file API:

- Remove `XmlExtension` and `.xml` from `DialogFilter`.
- Drop `IncludeXml` on selectors (or always false).
- Prefer upgrade-or-cancel over “load `.xml` without rewrite”.
- Consumers should already prefer `.kthemex`.

Do not delete those ToDos when editing adjacent code; implement them only when the V120 work is scheduled.

## Consumer migration checklist

1. Prefer `.kthemex` for single themes; use `.ktheme` for collections or compact binary.
2. Replace any pre-release `.kpal` / `.kpalx` references (never shipped as public names).
3. Call `EnsureShellAssociations` once at app start (or from Palette Designer with exe path) to fix Explorer icons / leftover ProgIDs.
4. For older schema XML, use Upgrade/Convert/`ImportWithUpgrade` — do not rely on plain Import.
5. Utilities selectors / collection editor need **Krypton.Standard.Toolkit** (or Utilities project reference).
6. This feature is **additive** in Changelog (#2117); no README **Breaking Changes** entry as of the V110 nightly notes. Future XML removal **will** be breaking — document then.

## Extra builtin export

When `Krypton.Themes` is loaded:

```csharp
KryptonThemeCustomPaletteHelper.ExportToFile(PaletteMode.SomeExtra, path, ignoreDefaults: true);
```

Missing Themes does not break file I/O; applying missing **extra** builtin modes falls back via the theme catalog (see Themes catalog docs).

[← Collections](./Collections.md) · [Index](./PaletteFilesIndex.md) · [Next: Thumbnails & Shell →](./ThumbnailsandShell.md)
