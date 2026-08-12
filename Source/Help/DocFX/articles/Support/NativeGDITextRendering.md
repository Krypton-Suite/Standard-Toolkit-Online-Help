# Native GDI Text Rendering

## Overview

Issue [#1103](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1103) investigates whether calling Win32 GDI text APIs directly (via P/Invoke) can outperform `TextRenderer.DrawText` and GDI+ `Graphics.DrawString` / `MeasureString` for Krypton paint paths.

The toolkit ships an **opt-in** native GDI backend for horizontal text in `AccurateText`. The default path is unchanged (`MeasureString` + `TextRenderer.DrawText` for `VisualOrientation.Top`).

Owned by: `Krypton.Toolkit` (with Win32 declarations in `Krypton.Interop`).

## Architecture

```text
RenderStandard / content draw
        |
        v
  AccurateText.MeasureString / DrawString
        |
        +-- PreferNativeGdiText == false (default)
        |       Measure: Graphics.MeasureString
        |       Draw Top: TextRenderer.DrawText
        |       Draw rotated: Graphics.DrawString + transforms
        |
        +-- PreferNativeGdiText == true
                Measure: GdiNativeText.Measure (DrawTextW + DT_CALCRECT)
                Draw Top: GdiNativeText.Draw (DrawTextW / DrawTextExW)
                Draw rotated: still Graphics.DrawString + transforms
```

`GdiNativeText` wraps `GetHdc` / `SelectObject(HFONT)` / `SetBkMode(TRANSPARENT)` / `SetTextColor` / `DrawTextW` (or `DrawTextExW` when `NoPadding` is set), then restores the DC. HFONT handles are cached by font name/size/style/unit/charset so paint loops do not create and destroy a font object per string.

## Public API

### `AccurateText.PreferNativeGdiText`

```csharp
// Opt in early in application startup (before heavy UI layout):
AccurateText.PreferNativeGdiText = true;
```

- Type: `bool` static property; default `false`.
- When `true`, horizontal measure and draw both use `GdiNativeText` so sizes and pixels stay paired.
- Rotated orientations (`Left` / `Right` / `Bottom`) always use GDI+ because GDI ignores `Graphics` transforms.
- Not a designer property; set from application code.

### `GdiNativeText`

| Member | Purpose |
| --- | --- |
| `Measure(Graphics, string, Font, TextFormatFlags, Size, bool useFontCache = true)` | Flag-aware measure via `DT_CALCRECT`. |
| `Draw(Graphics, string, Font, Rectangle, Color, TextFormatFlags, bool useFontCache = true)` | Flag-aware draw via `DrawTextW` / `DrawTextExW`. |
| `ExtTextOut(...)` | Fast single-line baseline for benchmarks only (no wrap/ellipsis/hotkey). |
| `ClearFontCache()` | Deletes cached HFONTs after a global font/theme change if needed. |
| `ToDrawTextFlags(TextFormatFlags)` | Strips managed-only flags before Win32. |

`TextFormatFlags` map to Win32 `DT_*` the same way `TextRenderer` does (managed-only bits such as `PreserveGraphicsClipping` are cleared).

## Usage

Minimal enable:

```csharp
static class Program
{
    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        AccurateText.PreferNativeGdiText = true; // optional
        Application.Run(new MainForm());
    }
}
```

Keep `SetCompatibleTextRenderingDefault(false)` when comparing against `TextRenderer` (see [Stack Overflow](https://stackoverflow.com/a/23230570)).

## Constraints and edge cases

- **No Graphics transforms** — do not use `GdiNativeText` for rotated content; `AccurateText` already keeps that on GDI+.
- **Printing** — continue to use `Graphics.DrawString` for print documents.
- **Solid colour only** — same limitation as the existing `TextRenderer` branch (brush colour is extracted from `SolidBrush` or the first gradient stop).
- **Measure/draw pairing** — never mix GDI+ measure with native draw (or the reverse) for the same layout pass; enabling `PreferNativeGdiText` keeps them paired.
- **Uncached HFONT** — calling with `useFontCache: false` is usually slower than `TextRenderer`; always prefer the cache in production.
- **Theme/font swap** — if you replace system fonts wholesale and see stale metrics, call `GdiNativeText.ClearFontCache()`.

Related reading: [Art of Dev — GDI vs GDI+](https://theartofdev.com/2014/04/21/text-rendering-methods-comparison-or-gdi-vs-gdi-revised/), [SO fastest WinForms text API](https://stackoverflow.com/a/72720).
