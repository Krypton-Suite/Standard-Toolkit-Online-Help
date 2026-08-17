# Krypton Screen Colour Picker

## Overview

`KryptonScreenColorPicker` is a PowerToys-style eyedropper for WinForms. The consumer calls a static `TryPick` method; the toolkit freezes a screenshot of the virtual desktop, shows a full-screen overlay with a magnified pixel grid, and returns the colour under the cursor when the user clicks.

**Problem solved.** Palette and theme UIs need colours taken from other windows, not only from a standard colour dialog. The Windows `ColorDialog` cannot sample the screen. This API fills that gap without adding Cyotek ColorPicker (or any other third-party colour package) to `Krypton.Toolkit.Utilities`.

**Scope.** Screen capture, overlay UX, hex/RGB readout, zoom, cancel, and a small eyedropper glyph for buttons. It does **not** persist history, copy to the clipboard, or host a colour wheel.

**Package.** `Krypton.Toolkit.Utilities` (`Krypton.Standard.Toolkit` NuGet). Namespace `Krypton.Toolkit.Utilities`. Original Krypton code inspired by the [PowerToys Color Picker](https://github.com/microsoft/PowerToys/tree/main/src/modules/colorPicker) overlay behaviour (screenshot, zoomed grid, hex/RGB). Do not copy PowerToys sources.

Related: [Custom Theme Generator](CustomThemeGenerator.md) uses dropper buttons that call this API.

## Architecture

Three types live under `Source/Krypton Components/Krypton.Toolkit.Utilities/Components/Krypton Screen Color Picker/`:

| Type | Visibility | File | Role |
|---|---|---|---|
| `KryptonScreenColorPicker` | public static | `Controls Toolkit/KryptonScreenColorPicker.cs` | Entry point: hide owner, capture, show overlay, restore owner |
| `VisualScreenColorPickerOverlay` | internal `Form` | `Controls Visuals/VisualScreenColorPickerOverlay.cs` | Full-screen frozen desktop + magnifier HUD |
| `ScreenColorPickerGlyph` | internal static | `General/ScreenColorPickerGlyph.cs` | 16×16 eyedropper bitmap used by `CreateDropperGlyphImage` |

The overlay is a **borderless `Form`**, not a `KryptonForm`. It must sit above everything, match `SystemInformation.VirtualScreen`, and paint a bitmap 1:1. Krypton chrome would fight that.

```
TryPick(owner)
    --> resolve owner Form (or FindForm)
    --> Opacity = 0 on that form (so colours behind it can be sampled)
    --> CopyFromScreen(VirtualScreen) into a 32bpp bitmap
    --> ShowDialog VisualScreenColorPickerOverlay (TopMost, no owner parent)
            paint screenshot
            mouse move: sample GetPixel, invalidate old+new magnifier
            click / Enter / Space --> DialogResult.OK
            Esc / right-click --> Cancel
    --> restore owner Opacity
    --> overlay Dispose disposes the screenshot bitmap
```

Ownership of the screenshot bitmap transfers to the overlay constructor. `using` on the overlay always disposes the bitmap, including cancel and capture-success paths after the dialog closes.

## Features

### Capture

- Snapshot covers the **virtual screen** (all monitors), not only the primary display.
- Format is `PixelFormat.Format32bppArgb`.
- `CopyFromScreen` failures (secure desktop, some GPU/capture policies) dispose the bitmap and make `TryPick` return `false`.
- Empty or invalid `VirtualScreen` also returns `false`.

### Owner hiding

When `owner` is (or belongs to) a **visible** `Form`:

1. Previous `Opacity` is stored.
2. `Opacity` is set to `0`, `Update()` + `DoEvents()` run so the compositor shows whatever was behind the dialog.
3. The snapshot is taken.
4. `finally` restores opacity even if capture or the overlay throws.

The overlay is **not** shown with `ShowDialog(ownerForm)`. A fully transparent owner as dialog parent is unreliable; `TopMost` plus `WS_EX_TOPMOST` is enough.

Passing `null`, a non-form `IWin32Window` that does not map to a `Form`, or a hidden form skips the opacity dance.

### Overlay HUD

- Cross cursor, no taskbar button, key preview, mouse capture on show.
- Banner: `Click to pick  ·  Esc or right-click to cancel  ·  Mouse wheel zooms`.
- Magnifier: 11×11 source pixels, nearest-neighbour scale, optional grid when zoom ≥ 8, white/black outline on the centre pixel.
- Footer: colour swatch, `#RRGGBB`, `RGB(r, g, b)`, current zoom.
- Magnifier prefers the lower-right of the cursor and flips left/up when it would leave the overlay. It stays below the banner.

### Zoom

| Constant | Value |
|---|---|
| Default `_zoom` | 12 |
| Minimum | 6 |
| Maximum | 24 |
| Wheel step | ±2 |

### Confirm / cancel

| Input | Result |
|---|---|
| Left click, Enter, Space | `TryPick` returns `true`; `color` is the hover pixel |
| Escape, right click | `TryPick` returns `false`; `color` is `Color.Empty` |

### Painting (why trails were a bug)

The overlay is a full-screen bitmap. Invalidating only the **new** magnifier rectangle left previous rounded frames on screen.

Current rules:

- `ControlStyles.Opaque` so WinForms does not fill the clip with `BackColor`.
- `OnPaintBackground` / `OnPaint` blit the screenshot **1:1** into `ClipRectangle` (`CompositingMode.SourceCopy`, `PixelOffsetMode.None`).
- Mouse-move and wheel invalidate the **union** of previous and current magnifier bounds, inflated by 8px for anti-aliased corners.
- Nearest-neighbour + `PixelOffsetMode.Half` is used **only** for the magnified 11×11 patch, not for restoring the desktop.

### Eyedropper glyph

`CreateDropperGlyphImage()` returns a new 16×16 ARGB bitmap (dark shaft, steel-blue bulb). Callers **must dispose** it (typically from the host form `Dispose`). Sharing one instance across several buttons is supported; dispose once.

## Public API

Namespace: `Krypton.Toolkit.Utilities`

```csharp
[ToolboxItem(false)]
[DesignerCategory("code")]
public static class KryptonScreenColorPicker
{
    public static Image CreateDropperGlyphImage();
    public static bool TryPick(out Color color);
    public static bool TryPick(IWin32Window? owner, out Color color);
}
```

### `CreateDropperGlyphImage`

- Returns a disposable `Image` for `KryptonButton.Values.Image` (or any `Image` slot).
- Not designer-serialised; create at runtime.

### `TryPick(out Color color)`

Equivalent to `TryPick(null, out color)`. Does not hide any window. Useful when nothing on-screen needs to be sampled **through** the caller.

### `TryPick(IWin32Window? owner, out Color color)`

| Return | `color` | Meaning |
|---|---|---|
| `true` | sampled ARGB from `GetPixel` | User confirmed |
| `false` | `Color.Empty` | Cancel, failed capture, or invalid virtual screen |

`owner` may be a `Form` or a `Control` (resolved with `FindForm()`). Null is allowed.

There are no events, no instance, no designer toolbox item, and no configuration object.

## Usage

### Minimal

```csharp
using Krypton.Toolkit.Utilities;

if (KryptonScreenColorPicker.TryPick(this, out Color color))
{
    kbtnAccent.SelectedColor = color;
}
```

### Dropper button on a Krypton form

```csharp
_dropperGlyph = KryptonScreenColorPicker.CreateDropperGlyphImage();
kbtnPick.Values.Image = _dropperGlyph;
kbtnPick.Values.Text = string.Empty;
kbtnPick.AccessibleName = "Pick colour from screen";
kbtnPick.ToolTipValues.EnableToolTips = true;
kbtnPick.ToolTipValues.Heading = "Screen colour picker";
kbtnPick.ToolTipValues.Description =
    "Hides this form, then magnifies pixels under the cursor. Click to sample, Esc or right-click to cancel.";

private void kbtnPick_Click(object sender, EventArgs e)
{
    if (!KryptonScreenColorPicker.TryPick(this, out Color color))
    {
        return;
    }

    kbtnAccent.SelectedColor = color;
    ktxtHex.Text = KryptonCustomThemeGenerator.FormatColor(color);
}

protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        components?.Dispose();
        _dropperGlyph?.Dispose();
    }
    base.Dispose(disposing);
}
```

Call `TryPick` from the UI thread (STA). `ShowDialog` and `CopyFromScreen` are not marshalled.

### Theme builder integration

`VisualCustomThemeBuilderForm` and `CustomThemeGeneratorDemo` wire Primary / Secondary / Surface droppers this way. Secondary and Surface also check their enable checkboxes when a colour is picked.

## Configuration / persistence

None. Zoom is session-only (starts at 12). There is no XML, no user setting, and no MSBuild property. Sampled colours are returned to the caller; persistence is the caller's job (theme seed, colour button, file, and so on).

## Edge cases

- **UI thread.** Must run on the WinForms STA thread that owns the owner form.
- **net472.** Uses only APIs available on .NET Framework 4.7.2 (no `CopyFromScreen` overloads or C# features beyond the Utilities ceiling).
- **DPI.** Overlay `Bounds` = `VirtualScreen`. Capture and `Cursor.Position` use the same screen space. Per-monitor DPI mismatches can still offset the sample if the process DPI awareness disagrees with `CopyFromScreen`; the host app's `ApplicationHighDpiMode` applies (`SystemAware` in Toolkit/Utilities projects).
- **Protected content.** DRM / UAC secure desktop / some full-screen exclusive apps can make `CopyFromScreen` throw or return black. `TryPick` returns `false`; it does not show an error dialog.
- **Multi-monitor.** Virtual screen can have a negative origin. Sample coordinates subtract `_virtualScreen.Left/Top` before `GetPixel`.
- **Magnifier source rect.** The 11×11 `DrawImage` source may extend past bitmap edges; GDI+ clips. The confirmed colour is always a clamped centre pixel.
- **Owner dispose.** `finally` checks `!ownerForm.IsDisposed` before restoring opacity.
- **Modal overlay.** `ShowDialog()` without an owner. The caller’s message loop is blocked until pick or cancel. Nested `TryPick` from the overlay is not supported.
- **Performance.** `GetPixel` on mouse move is acceptable for this modal path. Do not call `Invalidate()` for the entire 4K surface on every move; dirty-rect restore is required to avoid trails.
- **Not a live sampler.** The desktop is frozen at click-to-start time. Animations and videos will not update under the cursor.
- **Glyph lifetime.** Each `CreateDropperGlyphImage()` allocates. Do not call it per paint.
- **Breaking changes.** First release of this type; no migration. It is not in `Krypton.Toolkit` (core). Consumers that only reference Toolkit must add Utilities.
