# KryptonToggleSwitch Knob Styles

## Overview

Issue [#3890](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3890) adds selectable knob rendering styles to `KryptonToggleSwitch`. The feature is owned by `Krypton.Toolkit` and extends the existing `ToggleSwitchValues` appearance model without changing the default `Classic` behavior.

## Architecture

`KryptonToggleSwitch` keeps its public appearance settings in `ToggleSwitchValues`. The new `ToggleSwitchKnobStyle` enum selects the knob drawing path while the control continues to use the same palette state, switch geometry, colors, and checked-state animation.

The rendering flow is:

1. `OnPaint` resolves the active palette state and draws the switch track.
2. `DrawKnob` calculates the animated knob rectangle from `_animationPosition`.
3. `ResolveKnobColors` chooses the face, secondary, border, and track colors from `ToggleSwitchValues` and the active palette state.
4. The selected `ToggleSwitchKnobStyle` dispatches to a style-specific drawing helper.
5. `DrawOnOffText` paints the localized on/off label when `ToggleSwitchValues.ShowText` is enabled.

## Public API

The public style selector is `ToggleSwitchValues.KnobStyle`:

```csharp
public ToggleSwitchKnobStyle KnobStyle { get; set; }
```

The enum values are:

- `Classic`: the default ellipse rendering path.
- `Gradient`: an ellipse with a two tone gradient.
- `Flat`: a solid ellipse with a palette border.
- `Radial`: an ellipse with a radial highlight.
- `Ring`: a ring-shaped knob using the track color for the centre.
- `Bevel`: an ellipse with bevel highlight and shadow arcs.
- `RoundedSquare`: a rounded-square knob.

`Classic` remains the default and is included in `ToggleSwitchValues.Reset()` and `ToggleSwitchValues.IsDefault`.

## Usage

Configure the style through the expandable `ToggleSwitchValues` object:

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.KnobStyle = ToggleSwitchKnobStyle.RoundedSquare;
kryptonToggleSwitch1.ToggleSwitchValues.EnableKnobGradient = true;
kryptonToggleSwitch1.ToggleSwitchValues.AnimateGradientEffect = true;
```

The style works with the existing color settings:

- `UseThemeColors`
- `OnlyShowColorOnKnob`
- `OnColor`
- `OffColor`
- `EnableKnobGradient`
- `GradientDirection`
- `AnimateGradientEffect`

## Edge Cases

The knob position is stored in logical left-to-right coordinates and mirrored at draw time when `RightToLeft` is enabled. This keeps animation math shared between LTR and RTL layouts.

When `AnimateGradientEffect` is disabled, gradient colors resolve directly from the checked state. When it is enabled, colors interpolate with the animated knob position.

