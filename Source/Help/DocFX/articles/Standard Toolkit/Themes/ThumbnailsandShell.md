# 06 — Thumbnails and Shell Associations

[← Upgrade](./UpgradeConvertMigration.md) · [Index](./PaletteFilesIndex.md) · [Next: Utilities UI →](./UtilitiesUI.md)

## Palette thumbnail

`KryptonCustomPaletteBase.Thumbnail` is an optional preview image.

| Concern | Guidance |
|---------|----------|
| Recommended size | `KryptonPaletteFile.RecommendedThumbnailSize` (**64×64**) |
| `.kthemex` storage | Base64 PNG in the XML image cache |
| Collection storage | Trailing `KPTH` catalog after kind-2 entries |
| Generation | `KryptonThemePreview` / `AssignGeneratedThumbnail` (Designer, Theme Browser Export) |
| Builtin themes | Generated mock-up in Theme Browser / list views (not file-based) |

Selectors and the collection editor composite the preview with the Stable Kr tile as a **corner overlay**. Without a preview, the Kr tile fills the icon.

### Reading thumbnails without full import

```csharp
Image?[] thumbs = KryptonPaletteFile.GetThemeThumbnails(path);
try
{
    // same order as GetThemeNames(path); null = missing
}
finally
{
    foreach (var img in thumbs)
    {
        img?.Dispose();
    }
}
```

For collections, this reads the `KPTH` catalog. For single `.kthemex`, a lightweight import path may be used. Catalog version mismatch or missing catalog → null slots.

`KPTH` constraints: max **1 MiB** PNG per theme; does not bump KPLT container version.

## Icon helpers

```csharp
Image badge = KryptonPaletteFile.GetThemeBadgeImage();
Image composed = KryptonPaletteFile.CreateThemeIcon(thumbnailOrNull, size: 32);
Icon? shell = KryptonPaletteFile.CreateShellIcon(largeIcon: false);
Icon? fileIcon = KryptonPaletteFile.CreateThemeFileIcon(path, largeIcon: true);
```

`CreateThemeIcon` draws the preview full-frame and a Kr tile at ~45% size bottom-right.

## Shell associations (HKCU)

```csharp
KryptonPaletteFile.EnsureShellAssociations();
KryptonPaletteFile.EnsureShellAssociations(openWithExecutable: applicationExePath);
```

### Behaviour

| Aspect | Detail |
|--------|--------|
| Hive | **HKCU only** — no admin rights |
| `.kthemex` | ProgID `kthemexfile` (“Krypton Theme XML”) |
| `.ktheme` | ProgID `kthemefile` (“Krypton Theme Container”) |
| DefaultIcon (no Open override) | Stable Kr `.ico` under `%LocalAppData%\Krypton-Suite\KryptonPalette.ico` |
| DefaultIcon (with exe) | `"exePath",0` |
| Open verb | Set only when `openWithExecutable` is provided (Palette Designer). Otherwise does **not** replace an existing Open that already points at an `.exe` |
| Cleanup | Unregisters unreleased `.kpal` / `.kpalx` if still tied to old toolkit ProgIDs |
| Refresh | `SHChangeNotify` (ASSOCCHANGED + UPDATEIMAGE) so Explorer updates without restart |
| Failures | Swallowed; call is idempotent for icon-only registration |

### Palette Designer integration

At startup (or first palette open), call:

```csharp
KryptonPaletteFile.EnsureShellAssociations(Application.ExecutablePath);
```

so double-click Open launches the Designer and file icons match the app icon. Toolkit hosts that only need Explorer icons can call the parameterless overload.

### Import dialogs

`KryptonCustomPaletteBase.Import(bool)` / export dialogs call `EnsureShellAssociations()` so first-run associations exist without a separate setup step.

[← Upgrade](./UpgradeConvertMigration.md) · [Index](./PaletteFilesIndex.md) · [Next: Utilities UI →](./UtilitiesUI.md)
