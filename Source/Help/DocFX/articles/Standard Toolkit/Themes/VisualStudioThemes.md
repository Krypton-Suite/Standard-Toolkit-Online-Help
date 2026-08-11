# Visual Studio Themes

## Overview

Issue [#1083](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1083) expands built-in `PaletteMode` themes to Visual Studio years **2010–2026**.

| Family | Variants | Notes |
|--------|----------|--------|
| Visual Studio 2010 | Four Office-renderer variations | VS2010-style chrome; Office 2007 / 2010 / 2013 / Microsoft 365 renderers |
| Visual Studio 2012–2022 | Dark + Light + Blue | Classic product themes; Light/Blue share `PaletteVisualStudio2022LightBase`; Dark shares `PaletteVisualStudio2022DarkBase` |
| Visual Studio 2026 | Dark + Light | Fluent design tokens from [Theme Color Tokens](https://learn.microsoft.com/en-us/visualstudio/extensibility/ux-guidelines/theme-color-token-reference) (no Blue; HC covered by Accessibility themes) |

## Architecture

```text
Fluent theme color tokens (2026 Light/Dark columns)
        │
        ▼
PaletteVisualStudio2026{Light|Dark}_BaseScheme
        │
        ▼
PaletteVisualStudio2026{Light|Dark}
  └─ Light → PaletteVisualStudio2022LightBase
  └─ Dark  → PaletteVisualStudio2022DarkBase
        │
        ▼
PaletteVisualStudioBase → RenderVisualStudio
```

Locations under `Source/Krypton Components/Krypton.Toolkit/`:

- `Palette Builtin/Visual Studio/Official Themes/{year}/` (includes `2026/`)
- `Palette Builtin/Visual Studio/Official Themes/{year}/Schemes/`
- `Palette Base/PaletteMode.cs`
- `Translations/Converters/PaletteModeStrings.cs`
- `Controls Toolkit/KryptonManager.cs`

## Fluent token → scheme mapping (VS2026)

Source: [Visual Studio Theme Color Tokens](https://learn.microsoft.com/en-us/visualstudio/extensibility/ux-guidelines/theme-color-token-reference). Hex `#AARRGGBB` → opaque `Color.FromArgb` for WinForms (alpha discarded unless a solid sibling exists).

| Scheme property | Light token | Dark token |
|-----------------|-------------|------------|
| `PanelClient` | `EnvironmentBody` `#FFEEEEEE` | `#FF1C1C1C` |
| `PanelAlternative` | white / quaternary | `SolidBackgroundFillQuaternary` `#FF2C2C2C` |
| `HeaderPrimaryBack*` | `EnvironmentHeader` `#FFF9F9F9` | `#FF282828` |
| `FormBorderActive*` | `EnvironmentBorder` / `AccentFillDefault` `#FF5649B0` | `#FF9184EE` |
| Default button / app button / status strip | `AccentFillDefault` / `AccentFillAlt` | same Dark column |
| `GridListSelected` / selection | `AccentFillSelectedTextBackground` `#FF0078D4` | `#FF005FB7` |
| Links | `HyperlinkFillPrimary` `#FF003E92` | `#FF99EBFF` |
| Text | `TextFillPrimary` (near-black solid) | white |

## Classic Blue (2012–2022 only)

| Surface | Value |
|---------|-------|
| Title / form header active | `#293955` + white caption |
| Panels / toolstrips | `#EEF0F4` / `#CED4DF` |
| Accent | `#007ACC` |

## Adding another year

1. Copy an existing year scheme + palette under `Official Themes/{year}/`.
2. For Fluent-era years, map tokens from the MS reference (prefer purple accents over classic blue).
3. Keep `PaletteMode` and `PaletteModeStrings.SupportedThemes` in lockstep (#1328).
4. Wire `KryptonManager`, `PaletteClassTypeConverter`, `GraphicsExtensions`.
5. Extend `VisualStudioThemesDemo` and changelog.

## Validation

- TestForm: **1083 Visual Studio Themes** — exercise **2026 Light/Dark** first (Fluent purple chrome).
- `dotnet build ".\Source\Krypton Components\TestForm\TestForm.csproj" -c Debug -f net472`
