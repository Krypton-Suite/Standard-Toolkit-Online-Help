# Screen colour picker and custom theme generator

## Overview

`KryptonScreenColorPicker` is a **static** helper in `Krypton.Toolkit.Utilities` that captures a colour from the virtual desktop with a full-screen magnifier overlay. `KryptonColorPicker` is a **toolbox / component-tray** wrapper (same idea as `ColorDialog`) that stores `Color`, flyout style, zoom, magnifier size, visible formats, and raises `ColorChanged`.

The **Custom Theme Generator** (`KryptonCustomThemeBuilder` / `KryptonCustomThemeGenerator`) uses the same picker as an eyedropper so authors can sample seed colours, remap a builtin donor scheme into a `KryptonCustomPaletteBase`, register it, and export XML.

Packages: `Krypton.Toolkit.Utilities` (picker and generator). Optional extra palettes still come from `Krypton.Themes`.

## Architecture

| Type | Role |
|------|------|
| `KryptonScreenColorPicker` | Public static API (`TryPick`, `FormatColor`, `BindColorFormatList`, `DefaultFlyoutStyle`, `VisibleColorFormats`, `Strings`) |
| `KryptonColorPicker` | `Component` for the VS toolbox / form tray; `ShowDialog` / `TryPick` plus bindable `Color` |
| `KryptonScreenColorPickerFlyoutStyle` | Classic vs Krypton flyout chrome |
| `KryptonScreenColorPickerColorFormat` | Flags for which colour representations appear on the flyout |
| `KryptonScreenColorPickerStrings` | Localisable overlay, flyout, format, and style strings (`[Localizable(true)]`) |
| `VisualScreenColorPickerOverlay` | Full-screen `TransparencyKey` form; live neighbourhood capture; keyboard/wheel zoom |
| `VisualScreenColorPickerKryptonFlyoutForm` | TopMost click-through window hosting the themed flyout (not a child of the overlay) |
| `VisualScreenColorPickerKryptonFlyout` | `KryptonHeaderGroup`: colour-name heading, magnifier, swatch, format labels |
| `VisualScreenColorPickerClassicFlyoutForm` | TopMost click-through window that GDI-paints the PowerToys-style HUD |
| `ScreenColorPickerMagnifierPainter` | Shared nearest-neighbour magnifier draw |
| `ScreenColorPickerColorFormatter` | Formats a `Color` according to `KryptonScreenColorPickerColorFormat` |
| `KryptonCustomThemeBuilder` | Static `Show` for the generator dialog |
| `KryptonCustomThemeGenerator` | Seed-to-palette remapper (`Create`, `Register`, `Export`) |
| `KryptonCustomThemeSeed` | Name, primary/secondary/surface colours, and donor `PaletteMode` |
| `VisualCustomThemeBuilderForm` | Seed editor with eyedropper, flyout/format options, apply/register/export |

The overlay is **not** the flyout parent. Both Classic and Krypton HUDs live in their own small TopMost forms (`WS_EX_NOACTIVATE`, `ShowWithoutActivation`). Mouse hits pass through (`WM_NCHITTEST` → `HTTRANSPARENT`) so the overlay still receives click-to-sample. The overlay only paints the instruction banner (Classic GDI or a `KryptonPanel`). That keeps the magnifier from leaving trails when the cursor moves quickly.

```
KryptonColorPicker.ShowDialog / KryptonScreenColorPicker.TryPick
        │
        ▼
  hide owner (Opacity = 0)  ──►  VisualScreenColorPickerOverlay.ShowDialog (no owner)
        │                              │
        │                              ├─ 16 ms timer: CopyFromScreen neighbourhood
        │                              ├─ Classic: VisualScreenColorPickerClassicFlyoutForm
        │                              └─ Krypton: VisualScreenColorPickerKryptonFlyoutForm
        │                                        └─ VisualScreenColorPickerKryptonFlyout
        ▼
  restore owner Opacity
```

`TryPick` hides a visible owner (`Opacity = 0`) so the dialog chrome is not sampled, then restores it. The overlay is shown **without** a WinForms owner so the hidden form is not treated as a modal parent. When the owner is a `KryptonForm`, its `LocalCustomPalette` is passed to the Krypton flyout.

### Colour capture

`Graphics.CopyFromScreen` reads an odd-sized square around the cursor (`MagnifierSize` 7–21, default 11). The overlay timer (16 ms) recaptures while the cursor is still so the readout stays live if the pixel under the cursor changes (video, animations). Mouse-move skips recapture when the cursor has not moved, to avoid redundant GDI copies. The centre cell is the picked colour.

### Flyout placement

`MoveFlyout` places the HUD at cursor + (4, 4), then clamps it to the virtual screen with an 8 px inset and below the instruction banner. The overlay does not invalidate the whole virtual desktop on mouse move.

### Magnifier preview size

Classic preview width is an exact multiple of the odd source-pixel count so nearest-neighbour cells stay square, with a minimum of about 220 px. Krypton sizes the magnifier as `magnifierSize * zoom` and keeps a minimum flyout width of 280 px.

## Features

- **Left click / Enter / Space:** accept the colour under the cursor.
- **Right click / Escape:** cancel (`DialogResult.Cancel`; `TryPick` returns `false`).
- **Wheel:** change zoom (6–24, default 12, steps of 2). **Ctrl+wheel:** change magnifier source size (7–21 odd).
- **Keyboard zoom (no wheel):** `+` / `-` (including numpad), Page Up/Down, Up/Down. **Magnifier size:** `[` / `]`, or Ctrl with `+`/`-` / Page / arrows.
- **F12 / Print Screen:** copy a screenshot of the current screen (desktop through the transparent overlay, plus banner and flyout) to the clipboard.
- **Classic flyout:** dark rounded HUD (PowerToys-style), independent of the current palette; painted in its own window. Visible formats are listed under the preview (including known name when that flag is on).
- **Krypton flyout:** `KryptonHeaderGroup` using `KryptonManager.CurrentGlobalPalette` and an optional owner `LocalCustomPalette`. Header **heading** is the nearest web `KnownColor` name when `KnownName` is visible, otherwise hex. Header **description** is empty. Remaining visible formats are stacked as `KryptonLabel`s in a `KryptonPanel` (`PanelBackStyle = PanelAlternate`) with a colour swatch.
- **Visible formats:** `Hex`, `HexAlpha`, `HexInteger`, `Rgb`, `Rgba`, `Hsl`, `Hsv`, `Cmyk`, `Decimal`, `Vector`, `KnownName`. Default: `KnownName | Hex | Rgb | Hsl`. Empty or unknown bits fall back to that default set.
- **Localisation:** `KryptonScreenColorPicker.Strings` / `KryptonColorPicker.Strings` (same singleton). Overlay instructions, window title, flyout style names, format labels, “Custom”, and `string.Format` templates for RGB/HSL/etc. are properties with `DefaultValue` / `ShouldSerialize*` / `Reset*`.
- **Global defaults:** `DefaultFlyoutStyle` (defaults to **Krypton**), `DefaultMagnifierSize`, `DefaultZoom`, and `VisibleColorFormats` apply to static `TryPick` when those arguments are omitted. After a session, magnifier size and zoom are written back to the static defaults. A `KryptonColorPicker` instance has its own copies (except `Strings`).
- **Multi-monitor:** overlay union of all screens (`SystemInformation.VirtualScreen`).

## Public API

### Static picker

```csharp
public static class KryptonScreenColorPicker
{
    public const int MinimumMagnifierSize = 7;
    public const int MaximumMagnifierSize = 21;
    public const int MinimumZoom = 6;
    public const int MaximumZoom = 24;

    public static KryptonScreenColorPickerFlyoutStyle DefaultFlyoutStyle { get; set; }
    public static int DefaultMagnifierSize { get; set; }
    public static int DefaultZoom { get; set; }
    public static KryptonScreenColorPickerColorFormat VisibleColorFormats { get; set; }
    public static KryptonScreenColorPickerStrings Strings { get; }
    public static IReadOnlyList<KryptonScreenColorPickerColorFormat> DefinedColorFormats { get; }
    public static KryptonScreenColorPickerColorFormat AllColorFormats { get; }

    public static int ClampMagnifierSize(int size);
    public static int ClampZoom(int zoom);

    public static bool TryPick(out Color color);
    public static bool TryPick(IWin32Window? owner, out Color color);
    public static bool TryPick(IWin32Window? owner, KryptonScreenColorPickerFlyoutStyle flyoutStyle, out Color color);
    public static bool TryPick(IWin32Window? owner, KryptonScreenColorPickerFlyoutStyle flyoutStyle, int magnifierSize, out Color color);
    public static bool TryPick(IWin32Window? owner, KryptonScreenColorPickerFlyoutStyle flyoutStyle, int magnifierSize, int zoom, KryptonScreenColorPickerColorFormat visibleFormats, out Color color);

    public static string FormatColor(Color color, KryptonScreenColorPickerColorFormat format);
    public static string GetColorFormatDisplayName(KryptonScreenColorPickerColorFormat format);
    public static void BindColorFormatList(KryptonCheckedListBox list);
    public static string GetFlyoutStyleDisplayName(KryptonScreenColorPickerFlyoutStyle style);
    public static Image CreateDropperGlyphImage();
}
```

The static type stays `[ToolboxItem(false)]` because a `static` class cannot be a tray component. Drop `KryptonColorPicker` from the toolbox onto a form instead.

There is no throwing `Pick` helper; prefer `TryPick` or `KryptonColorPicker.ShowDialog`. `BindColorFormatList` takes a `KryptonCheckedListBox` and writes check changes back to `VisibleColorFormats`.

### Toolbox component

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(KryptonColorDialog), "ToolboxBitmaps.KryptonColorDialog.bmp")]
public class KryptonColorPicker : Component
{
    public Color Color { get; set; }
    public KryptonScreenColorPickerFlyoutStyle FlyoutStyle { get; set; }
    public int MagnifierSize { get; set; }
    public int Zoom { get; set; }
    public KryptonScreenColorPickerColorFormat VisibleColorFormats { get; set; }
    public KryptonScreenColorPickerStrings Strings { get; }

    public event EventHandler? ColorChanged;

    public DialogResult ShowDialog();
    public DialogResult ShowDialog(IWin32Window? owner);
    public bool TryPick(out Color color);
    public bool TryPick(IWin32Window? owner, out Color color);
    public void BindColorFormatList(KryptonCheckedListBox list);
}
```

`Strings` is the same shared instance as `KryptonScreenColorPicker.Strings`. After a pick session, the component copies the last magnifier size and zoom from the static defaults.

### Flyout style

```csharp
public enum KryptonScreenColorPickerFlyoutStyle
{
    Classic = 0,
    Krypton = 1
}
```

### Colour formats

```csharp
[Flags]
public enum KryptonScreenColorPickerColorFormat
{
    None = 0,
    Hex = 1,
    HexAlpha = 2,
    HexInteger = 4,
    Rgb = 8,
    Rgba = 16,
    Hsl = 32,
    Hsv = 64,
    Cmyk = 128,
    Decimal = 256,
    Vector = 512,
    KnownName = 1024
}
```

### Custom theme generator

```csharp
public static class KryptonCustomThemeBuilder
{
    public static DialogResult Show();
    public static DialogResult Show(IWin32Window? owner);
    public static DialogResult Show(KryptonCustomThemeSeed seed);
    public static DialogResult Show(IWin32Window? owner, KryptonCustomThemeSeed seed);
}

public static class KryptonCustomThemeGenerator
{
    public static IReadOnlyList<PaletteMode> SupportedDonorModes { get; }
    public static bool IsSupportedDonor(PaletteMode mode);
    public static string GetDonorDisplayName(PaletteMode mode);
    public static bool TryParseColor(string? text, out Color color);
    public static string FormatColor(Color color);
    public static KryptonCustomThemeSeed CreateRandomSeed(string? namePrefix = null);
    public static KryptonCustomPaletteBase Create(string name, string primaryHex);
    public static KryptonCustomPaletteBase Create(string name, Color primary, Color? secondary, Color? surface, PaletteMode donorMode);
    public static KryptonCustomPaletteBase Create(KryptonCustomThemeSeed seed);
    public static void Register(KryptonCustomThemeSeed seed, bool apply = false, KryptonManager? manager = null);
    public static void Export(KryptonCustomPaletteBase palette, string filePath, bool ignoreDefaults = true);
}
```

Supported donors: Office 2010 Blue, Office 2010 Blue Dark, Microsoft 365 Blue, Microsoft 365 Black Dark.

## Usage

```csharp
if (KryptonScreenColorPicker.TryPick(this, out Color color))
{
    kryptonPanel1.StateCommon.Color1 = color;
}

KryptonScreenColorPicker.DefaultFlyoutStyle = KryptonScreenColorPickerFlyoutStyle.Krypton;
KryptonScreenColorPicker.VisibleColorFormats =
    KryptonScreenColorPickerColorFormat.Hex |
    KryptonScreenColorPickerColorFormat.Rgb |
    KryptonScreenColorPickerColorFormat.Hsl;

KryptonScreenColorPicker.Strings.OverlayInstructions =
    "Click to pick · Esc cancel · +/- zoom";
```

```csharp
// Component on the form (or created in code)
kryptonColorPicker1.FlyoutStyle = KryptonScreenColorPickerFlyoutStyle.Krypton;
if (kryptonColorPicker1.ShowDialog() == DialogResult.OK)
{
    kryptonButton1.StateCommon.Back.Color1 = kryptonColorPicker1.Color;
}
```

```csharp
var seed = new KryptonCustomThemeSeed
{
    Name = "Acme Blue",
    Primary = Color.FromArgb(0x00, 0x78, 0xD4),
    DonorMode = PaletteMode.Office2010Blue
};

KryptonCustomThemeBuilder.Show(this, seed);

KryptonCustomPaletteBase palette = KryptonCustomThemeGenerator.Create(seed);
KryptonCustomThemeGenerator.Register(seed, apply: true);
```

Designer: drop `KryptonColorPicker` in the tray. Set `FlyoutStyle`, `VisibleColorFormats`, `Zoom`, and `MagnifierSize` in the property grid. Assign `Strings` only when you need non-English (or custom) overlay text; it is the same shared instance as `KryptonScreenColorPicker.Strings`.

## Configuration / persistence

The picker itself does not persist. After a pick, `DefaultMagnifierSize` and `DefaultZoom` remember the last session values for the process.

The theme generator writes `KryptonCustomPaletteBase` XML via `KryptonCustomThemeGenerator.Export`. `Register` stores a factory under the seed name so the theme appears in theme selectors. The builder dialog samples colours with `KryptonScreenColorPicker.TryPick` into the seed (primary / secondary / surface).

## Edge cases

- **Owner hide:** sampling the owner form is avoided by opacity, not by excluding a rectangle (the overlay still covers that area).
- **Cancellation:** `TryPick` returns `false` and `color` is `Color.Empty`.
- **MagnifierSize:** odd integers 7–21; even values are decremented into range. `Zoom` is 6–24.
- **Krypton flyout theme:** uses `KryptonManager.CurrentGlobalPalette` plus the owner form’s `LocalCustomPalette` when present. It does not take a separate palette argument on `TryPick`.
- **Click-through flyout:** `WM_NCHITTEST` → `HTTRANSPARENT` so clicks pass through to the overlay. Do not parent the flyout to the overlay (`TransparencyKey` would punch through child pixels).
- **Classic vs overlay paint:** Classic chrome used to be drawn on the overlay (trails while moving). It now uses `VisualScreenColorPickerClassicFlyoutForm`, same window model as Krypton.
- **Visible formats = 0:** `Normalize` substitutes the default set (`KnownName | Hex | Rgb | Hsl`), not hex-only.
- **KnownName:** nearest opaque non-system `KnownColor` by RGB distance. Exact matches return immediately; otherwise the closest web colour name.
- **Localisation scope:** strings are application-wide (one static instance), not per `KryptonColorPicker` component.
- **Clipboard:** F12 / Print Screen copy an image, not format text. Another process holding the clipboard is ignored.
- **net472:** supported; no APIs newer than the Utilities project C# language version.

## File map

| Path | Contents |
|------|----------|
| `…/Krypton Screen Color Picker/Controls Toolkit/KryptonScreenColorPicker.cs` | Static picker API |
| `…/Krypton Screen Color Picker/Controls Toolkit/KryptonColorPicker.cs` | Toolbox `Component` |
| `…/Krypton Screen Color Picker/General/Definitions.cs` | `KryptonScreenColorPickerColorFormat`, `KryptonScreenColorPickerFlyoutStyle` |
| `…/Krypton Screen Color Picker/General/ScreenColorPickerColorFormatter.cs` | Format / bind helpers |
| `…/Krypton Screen Color Picker/General/ScreenColorPickerMagnifierPainter.cs` | Magnifier GDI |
| `…/Krypton Screen Color Picker/General/ScreenColorPickerGlyph.cs` | Eyedropper glyph |
| `…/Krypton Screen Color Picker/General/VisualScreenColorPickerClassicFlyoutForm.cs` | Classic HUD window |
| `…/Krypton Screen Color Picker/Controls Visuals/VisualScreenColorPickerOverlay.cs` | Overlay + input |
| `…/Krypton Screen Color Picker/Controls Visuals/VisualScreenColorPickerKryptonFlyout.cs` | Themed flyout control + form |
| `…/Krypton Screen Color Picker/Translations/KryptonScreenColorPickerStrings.cs` | Localisable strings |
| `…/Krypton Custom Theme Generator/…` | Seed types, remapper, builder form, `KryptonCustomThemeBuilder` / `KryptonCustomThemeGenerator` |
