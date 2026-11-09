# Krypton Analogue Gauges (#4656)

Local developer guide — do not include in pull requests.

## Overview

Dashboard-style analogue gauges live in `Krypton.Gauges` (packed only via `Krypton.Standard.Toolkit`):

| Control | Role |
|---------|------|
| `KryptonCircularGauge` | Arc face with needle, ticks, optional peak marker |
| `KryptonLinearGauge` | Horizontal/vertical track with fill |
| `KryptonRectangularGauge` | Compact solid or segmented indicator |
| `KryptonThermometerGauge` | Classic bulb + tube liquid fill (vertical by default) |
| `KryptonAmpereMeterGauge` | Square panel meter, short upper arc, bottom pivot (AC or DC) |

They share value/range/palette/animation/input behaviour through `KryptonGaugeBase`.

## Architecture

- `KryptonGaugeBase` : `VisualSimpleBase` — shared `Values`, palette states, animation (`DisplayedValue` / `PeakValue`), interactive input hooks
- Per-face `ViewDraw*Gauge` : `ViewDrawPanel` — GDI+ painting in `RenderAfter`
- Designers dual-compile into `Krypton.Gauges.Design` (same `Components/**/Designers/**` pattern as the VU meter)

## Public API (essentials)

- `GaugeValues`: `Minimum`, `Maximum`, `Value`, `Ranges`, `Animate`, `AnimationMilliseconds`, `InputMode` (`Manual` | `Interactive`), `ShowScaleLabels`, `Caption`, `Units`, `SmallChange`, `LargeChange`
- Face subclasses:
  - `CircularGaugeValues` (`StartAngle`, `SweepAngle`, ticks, needle/peak)
  - `LinearGaugeValues` (`Orientation`, ticks)
  - `RectangularGaugeValues` (`Style`, `Orientation`, `SegmentCount`, `ShowValueText`)
  - `ThermometerGaugeValues` (`Orientation`, `MajorTickCount`, `MinorTickCount`, `ShowBulb`, `BulbScale`)
  - `AmpereMeterGaugeValues` (`StartAngle`, `SweepAngle`, ticks, `ShowCenterZeroMark`; factory `Maximum = 10`, `Units = "A"`)
- `GaugeRange` / `GaugeRangeCollection`: coloured bands with `Severity` or explicit `Color`
- Palette: `Face`, `Tick`, `Needle`, `Fill`, `RangeWarning`, `RangeError`, `Cap`, `Peak`, `SegmentOff`
- Events: `ValueChanged` (`GaugeValueChangedEventArgs` with old/new)

## Thermometer face

- Default size is roughly `64×220` (vertical). Horizontal places the bulb at the minimum end.
- Liquid uses palette `Fill`; tube glass uses `Face` / border; ticks and range bands follow the same palette as linear.
- Hit-testing maps along the **tube** rectangle only (`GaugeGeometry.PointToLinearNormalized`).
- `ShowBulb = false` draws a tube-only face for tight panels. `BulbScale` (0.5–2.0) scales the bulb relative to tube thickness.

## Ampere meter face

- Default size is roughly `160×160` (square panel bezel).
- Default arc is a short upper fan (`StartAngle ≈ 200°`, `SweepAngle ≈ 140°`) with the needle pivot near the bottom of the dial.
- **AC (default):** `Minimum = 0`, `Maximum = 10`, units `A`.
- **DC / bipolar:** set `Minimum < 0` (e.g. −10…+10). `ShowCenterZeroMark` emphasises the zero tick when bipolar.
- Hit-testing maps against the pivot + start/sweep (same geometry helper as circular).

## Interactive input

When `InputMode == Interactive` and enabled:

- Pointer drag/click maps through face geometry
- Arrow / Page / Home / End keys adjust `Value` when focused
- Manual mode ignores user input; apps still set `Value`

## Related

- VU meter (#4655) remains a separate audio-oriented control in the same assembly.
