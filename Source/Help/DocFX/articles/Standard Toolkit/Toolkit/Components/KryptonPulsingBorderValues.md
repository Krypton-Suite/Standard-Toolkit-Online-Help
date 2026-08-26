# Global Pulsing Border Values

## Overview

Optional pulsing (glowing) borders on Krypton input controls and `KryptonForm`, introduced in [#3784](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3784) and extended with application-wide defaults in [#4248](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4248).

Owned by `Krypton.Toolkit`.

## Architecture

- `InputPulsingBorderValues` / `InputPulsingBorderColorValues` — public storage (Enable, Animate, AnimationSpeed, ShowWhen, Style, Colors).
- `KryptonManager.PulsingBorderValues` — the global instance. Control-owned values inherit unset properties from here.
- `InputPulsingBorderHost` — per-control host; subscribes to `KryptonManager.GlobalPulsingBorderChanged` so a global edit repaints and starts/stops animation.
- `InputPulsingBorderViewIntegration` — wraps the control border view with `ViewDecoratorInputGlow`.
- `InputPulsingBorderRenderer` — draws the bottom-edge or full-border glow.

```
KryptonManager.PulsingBorderValues  (global, inheritFromGlobal: false)
        ^
        | inherit unset properties
Control.PulsingBorderValues         (per control, inheritFromGlobal: true)
        |
InputPulsingBorderHost
        |
ViewDecoratorInputGlow → InputPulsingBorderRenderer
```

## Public API

### Global defaults

```csharp
KryptonManager.PulsingBorderValues.Enable = true;
KryptonManager.PulsingBorderValues.Style = InputPulsingBorderStyle.Bottom;
KryptonManager.PulsingBorderValues.ShowWhen = InputPulsingBorderShowWhen.Focused;
KryptonManager.PulsingBorderValues.Animate = true;
KryptonManager.PulsingBorderValues.AnimationSpeed = 1f;
KryptonManager.PulsingBorderValues.Colors.Color1 = Color.FromArgb(64, 132, 255);
```

The designer exposes the same object as `KryptonManager.GlobalPulsingBorderValues` on a `KryptonManager` component (instance and static members cannot share the name `PulsingBorderValues`).

`KryptonManager.GlobalPulsingBorderChanged` fires when the global values change.

### Per-control override

Supported types: `KryptonTextBox`, `KryptonMaskedTextBox`, `KryptonComboBox`, `KryptonRichTextBox`, `KryptonNumericUpDown`, `KryptonDomainUpDown`, `KryptonDateTimePicker`, `KryptonCalcInput`, `KryptonButton`, `KryptonForm`.

```csharp
// Opt a single control out of the global enable.
textBox.PulsingBorderValues.Enable = false;

// Pin a local style; other properties still inherit.
textBox.PulsingBorderValues.Style = InputPulsingBorderStyle.All;

// Clear local overrides and inherit everything again.
textBox.PulsingBorderValues.Reset();
```

Getters return the local value when set, otherwise the global value, otherwise the factory default (`Enable = false`, `Animate = true`, `AnimationSpeed = 1`, `ShowWhen = Focused`, `Style = Bottom`).

Designer serialization writes only local overrides (`ShouldSerialize*` is based on whether a local value is present). Existing forms that already set `Enable = true` on individual controls keep that override.

## Usage

1. Drop a `KryptonManager` on the form (or call the static API at startup).
2. Set `PulsingBorderValues.Enable = true` (and any shared style/colors).
3. Override individual controls only where they should differ.
4. Call `Reset()` on a control (or `ResetEnable()`, `ResetStyle()`, …) to inherit again.

`KryptonForm` inherits the same way. If you enable glow globally and do not want form chrome to pulse, set `form.PulsingBorderValues.Enable = false`.

## Edge cases

- Changing global values at runtime updates already-created controls (hosts subscribe to `GlobalPulsingBorderChanged`).
- Binary compatibility: control `PulsingBorderValues` signatures are unchanged. Existing `Enable = true` assignments remain local overrides.
- Default global `Enable` is `false`, so apps that never set the manager property behave as before.
