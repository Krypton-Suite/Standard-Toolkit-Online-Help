# Custom Theme Generator

## Overview

Issue [#4234](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4234) asked for an easier way to create custom themes: the consumer supplies a few colours (hexadecimal or RGB) and the toolkit builds a full palette from those seeds.

The feature lives in `Krypton.Toolkit.Utilities`. It does **not** add new `PaletteMode` values. Generated themes are `KryptonCustomPaletteBase` instances.

Screen sampling is documented in [Krypton Screen Colour Picker](Krypton-Screen-Color-Picker.md).

## Architecture

1. Copy a donor builtin scheme (Office 2010 Blue or Microsoft 365 Blue, light or dark).
2. Hue-shift chromatic slots toward the seed primary.
3. Overwrite accent slots from primary / secondary / surface.
4. `ApplyScheme` on a **new** family palette instance (never mutate `GetPaletteForMode` singletons).
5. `KryptonCustomPaletteBase.PopulateFromBase`.
6. Patch Tracking / Pressed / Checked button LUT colours.

## Public API

Namespace: `Krypton.Toolkit.Utilities`

`KryptonCustomThemeSeed` (`Name`, `Primary`, `Secondary?`, `Surface?`, `DonorMode`).

`KryptonCustomThemeGenerator`: `Create` / `CreateRandomSeed` / `Register` / `Export` / `TryParseColor` / `FormatColor`. Donors: `Office2010Blue`, `Office2010BlueDarkMode`, `Microsoft365Blue`, `Microsoft365BlackDarkMode`.

`KryptonCustomThemeBuilder.Show()` / `Show(owner)` / `Show(seed)`.

## Usage

```csharp
var palette = KryptonCustomThemeGenerator.Create("Contoso", "#0078D4");
var seed = KryptonCustomThemeGenerator.CreateRandomSeed();
KryptonCustomThemeGenerator.Register(seed, apply: true, manager: kryptonManager);
KryptonCustomThemeGenerator.Export(palette, @"C:\Themes\Contoso.xml");
```

The TestForm demo and builder both expose a `Randomize` action that loads a generated seed into the current fields, including donor, primary, secondary, and surface colours.

## Edge cases

Do not add a `PaletteMode` per user theme. Do not call `PaletteBase.RegisterColor<PaletteOffice2010Blue, …>` from Utilities. Material / Sparkle / VS donors are out of scope for v1.
