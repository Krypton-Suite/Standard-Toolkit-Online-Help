# KryptonEqualizer

Maintainer guide for the multi-band equalizer in `Krypton.Gauges` (issue #4660).

## Overview

`KryptonEqualizer` draws N frequency bands as spectrum **levels** (solid bars or LED segments) and exposes interactive **gain** thumbs for a graphic-EQ style UI. Levels come from the application or from WASAPI capture + FFT. Gains are never overwritten by capture.

The assembly is `IsPackable=false` and ships inside `Krypton.Standard.Toolkit`.

## Architecture

| Piece | Role |
|-------|------|
| `KryptonEqualizer` | Toolbox control (`VisualSimpleBase`) |
| `EqualizerValues` / `EqualizerBand` | Settings and per-band Level / Gain |
| `ViewDrawEqualizer` | Paint bars, peaks, thumbs, labels |
| `PaletteEqualizer*` | Palette-backed face / low / mid / high / peak / thumb colours |
| `WasapiCapturePump` | Shared WASAPI capture thread (also used by `KryptonVuMeter`) |
| `EqualizerCapture` + `EqualizerFft` | Window → Hann → FFT → log-spaced band levels |

```text
Manual SetLevels / Band.Level --> Level --> ballistics --> paint
Capture FFT ------------------> Level
User drag / keyboard ---------> Gain --> GainChanged --> paint
```

## Public API (high level)

- `Values.Style` — `Bars` or `Segments`
- `Values.InputMode` — `Manual` or `Capture`
- `Values.BandCount` — 3…31 (default 10)
- `Values.Interactive` — gain thumbs (default true)
- `Values.PeakHold`, attack/release timings
- `SetLevels` / `GetLevels` / `GetGains`
- Events: `LevelsChanged`, `GainChanged`, `CaptureFailed`

Reuse `VuMeterChannel` for Left / Right / Mix while capturing.

## Capture notes

- No NAudio package. Shared-mode WASAPI on the default recording device.
- FFT length 2048 with 50% overlap.
- `CalibrationOffsetDb` (default −18) aligns dBFS into the 0…1 level scale (`EqualizerScale.LevelFloorDb` = −60).
- Designer never starts capture; handle destroy stops it.

## Related

- `KryptonVuMeter` (#4655) — single-level meter; shares `WasapiCapturePump`
- Analogue gauges (#4656) — separate dashboard indicators