# Custom Theme Generator

## Overview

Issue [#4234](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4234) asked for an easier way to create custom themes: the consumer supplies a few colours (hexadecimal or RGB) and the toolkit builds a full palette from those seeds and related colours in the spectrum.

The feature lives in `Krypton.Toolkit.Utilities`. It does **not** add new `PaletteMode` values. Generated themes are `KryptonCustomPaletteBase` instances that can be applied immediately, registered with `ThemeManager.RegisterCustomTheme` so they appear in theme selectors, or exported as Krypton palette XML.

Screen sampling for seed colours is documented separately in [Krypton Screen Colour Picker](KryptonScreenColorPicker.md).

## Architecture

A builtin palette is a 242-slot `KryptonColorSchemeBase` plus family look-up tables for hover/pressed buttons. XML customs snapshot thousands of per-style/state properties. The generator therefore:

1. Copies a **donor** builtin scheme (Office 2010 Blue or Microsoft 365 Blue, light or dark).
2. **Hue-shifts** chromatic slots toward the seed primary (neutrals stay readable).
3. **Overwrites** button, header, form, input, and menu accent slots with tints and shades derived from primary / secondary / surface.
4. Applies the remapped scheme to a **new** family palette instance (`ApplyScheme`). It never mutates `KryptonManager.GetPaletteForMode` singletons.
5. Snapshots that instance into `KryptonCustomPaletteBase.PopulateFromBase`.
6. **Patches** Tracking / Pressed / Checked button colours on the custom tree. Those fills come from a type-keyed LUT (Office gold/orange) and would otherwise leak after snapshot.

```
Seed colours --> Remap donor scheme --> Throwaway family palette
        --> PopulateFromBase --> Patch LUT states --> Custom palette
        --> Apply / Register / Export
```

## Public API

Namespace: `Krypton.Toolkit.Utilities`

### `KryptonCustomThemeSeed`

| Property | Role |
|---|---|
| `Name` | Display name for selectors and XML |
| `Primary` | Required brand / accent colour |
| `Secondary` | Optional; analogous hue (~30°) when omitted |
| `Surface` | Optional panel/client colour; derived from primary when omitted |
| `DonorMode` | One of the supported donors below |

### `KryptonCustomThemeGenerator`

Supported donors (`SupportedDonorModes`):

- `PaletteMode.Office2010Blue`
- `PaletteMode.Office2010BlueDarkMode`
- `PaletteMode.Microsoft365Blue`
- `PaletteMode.Microsoft365BlackDarkMode`

Colour parse (`TryParseColor`): `#RGB`, `#RRGGBB`, `#AARRGGBB`, `r,g,b`, `rgb(r,g,b)`, or a named HTML colour. `FormatColor` writes `#RRGGBB`.

```csharp
var palette = KryptonCustomThemeGenerator.Create("Contoso", "#0078D4");
ThemeManager.RegisterCustomTheme("Contoso", () => KryptonCustomThemeGenerator.Create("Contoso", "#0078D4"));
ThemeManager.ApplyTheme(palette, kryptonManager);

KryptonCustomThemeGenerator.Register(new KryptonCustomThemeSeed
{
    Name = "Contoso Dark",
    Primary = Color.FromArgb(0x00, 0x78, 0xD4),
    DonorMode = PaletteMode.Microsoft365BlackDarkMode
}, apply: true, manager: kryptonManager);

KryptonCustomThemeGenerator.Export(palette, @"C:\Themes\Contoso.xml");
```

### `KryptonCustomThemeBuilder`

Interactive dialog (`Show()` / `Show(owner)` / `Show(seed)`): colour pickers, hex fields, dropper buttons, donor combo, live preview on the dialog, Apply, Register, Export XML, Reset. Droppers call `KryptonScreenColorPicker` (see [Krypton Screen Colour Picker](KryptonScreenColorPicker.md)).

## Usage

1. Reference `Krypton.Toolkit.Utilities` (NuGet package `Krypton.Standard.Toolkit`).
2. Create a seed (or call `Create(name, primaryHex)`).
3. Apply with `ThemeManager.ApplyTheme`, and/or `Register` so `KryptonThemeComboBox` lists the name.
4. Optionally export XML and load later with `KryptonCustomPaletteBase.Import`.

## Edge cases

- **Do not** add a `PaletteMode` per user theme. The enum is closed and must stay aligned with `PaletteModeStrings`.
- **Do not** call `PaletteBase.RegisterColor<PaletteOffice2010Blue, …>` from consumer code. That LUT is type-keyed and would retint every Office 2010 Blue instance in the process.
- Material / Sparkle / Visual Studio donors are out of scope for v1 (Material uses an overlay fill model).
- Glyphs (checkboxes, caption buttons) are reused from the donor family; they are not recoloured bitmaps.
- `RegisterCustomTheme` names must not collide with builtin theme display names or the `"Custom"` / `"Custom - "` prefix.
- net472 compatible; no new `PaletteMode` values.
