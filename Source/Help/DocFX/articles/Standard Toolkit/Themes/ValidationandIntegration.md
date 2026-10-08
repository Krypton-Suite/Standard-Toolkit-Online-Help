# 08 — Validation and Integration

[← Utilities UI](./07-Utilities-UI.md) · [Index](./README.md)

## TestForm

| Demo | What to exercise |
|------|------------------|
| `PaletteBinaryDemo` | Export/import `.kthemex` / `.ktheme`, convert, upgrade, collection + folder pack, Utilities selectors, shell associations (icons) |
| `PaletteCollectionEditorDemo` | Add/remove themes, header name, Details columns, thumbnails |

Run:

```powershell
dotnet run --project ".\Source\Krypton Components\TestForm\TestForm.csproj" -c Debug
```

## Unit tests

| Script | Coverage |
|--------|----------|
| `Scripts/UnitTests/UnitTest-PaletteBinary.ps1` | Round-trip, Convert, UpgradeXml*, collections, Add/Remove, directory pack, KPTH, JSON rejection, `FromDirectory`, shell ProgIDs, `.kpal` not accepted |
| `Scripts/UnitTests/UnitTest-ThemePreview.ps1` | Thumbnail / `.kthemex` with theme preview (#3870) |

Screenshots (local PR artefacts only):

- `Scripts/UnitTests/Invoke-PaletteBinaryScreenshot.ps1`
- `Scripts/UnitTests/Invoke-PaletteCollectionEditorScreenshot.ps1`

Document new scripts in `Scripts/UnitTests/README.md` when adding keepers.

## Standard-Toolkit-Demos

Reuse `..\Standard-Toolkit-Demos` if present (do not re-clone). Feature work belongs on an `alpha-…` branch from `alpha`.

Known consumer examples:

- **KryptonPalette Examples** — import/export/collection/folder/selectors
- **Krypton Palette Author** — fuller authoring (open/save/convert/upgrade/collection/tree)

Append to existing examples; do not overwrite. Demos changes are **not** part of the Standard-Toolkit PR.

## Palette Designer (external)

Sources live under Theme-Palettes (`Z:\Development\Krypton\Theme-Palettes\Applications\Source\Palette Designer`), not in Standard-Toolkit.

Expected integration:

1. `EnsureShellAssociations(Application.ExecutablePath)` for Open + exe icon.
2. Open/Save through `KryptonCustomPaletteBase` / `KryptonPaletteFile` (prompt for collection theme when opening kind 2).
3. Before Export, optionally `KryptonThemePreview.AssignGeneratedThumbnail` so `Thumbnail` is populated.
4. Optional menu entry that hosts `KryptonPaletteCollectionEditor`.

## Edge-case checklist

| Topic | Expected behaviour |
|-------|--------------------|
| Missing Themes assembly | File I/O works; extra builtin modes fall back via catalog |
| Multi-theme import without name | Throws if count > 1 |
| Empty collection | Forbidden on export / last-remove |
| `ignoreDefaults` | Omits values matching base on export; collection rewrites use `false` |
| Silent import | No message boxes; no legacy XML prompt |
| Non-interactive | Prompt returns path unchanged |
| JSON | Rejected |
| Non-palette `.xml` in bulk upgrade | Skipped |
| Native schema upgrade | Not via XSLT |
| Compressed-XML collection entries | Readable; new writes are native |
| Thumbnail catalog | Collections only; missing → null; 1 MiB cap |
| Self-add to collection | Rejected |
| Duplicate theme names | Case-insensitive; replace or throw |
| Path separators | Stored `/`; display OS-specific |
| Shell without admin | HKCU only; failures ignored |
| Open verb preservation | Won’t overwrite existing exe Open unless registering with path |

## Source files to keep in sync with this guide

When behaviour changes, update the matching chapter and this checklist:

- `Krypton.Toolkit/Palette Base/KryptonPaletteFile*.cs`
- `Krypton.Toolkit/Palette Base/KryptonPaletteBinaryPersistence.cs`
- `Krypton.Toolkit/Controls Toolkit/KryptonCustomPaletteBase.cs` (Import/Export/Upgrade)
- `Krypton.Toolkit/Rendering/ThemeManager.cs`
- Utilities selector + collection editor trees
- `Scripts/UnitTests/UnitTest-PaletteBinary.ps1`
- Changelog #2117 bullets (consumer wording only — not this guide)

## Changelog reference

Consumer summary: `Documents/Changelog/Changelog.md` → Implemented [#2117](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2117).

Do **not** add Changelog entries for edits to these Development docs alone.

[← Utilities UI](./07-Utilities-UI.md) · [Index](./README.md)
