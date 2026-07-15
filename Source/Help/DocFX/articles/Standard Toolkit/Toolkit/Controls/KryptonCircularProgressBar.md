# KryptonCircularProgressBar

## Overview

`KryptonCircularProgressBar` is a circular, Krypton-themed progress indicator. It extends [`KryptonProgressBar`](KryptonProgressBar.md) with ring-based rendering, optional superscript/subscript text, animated value transitions, and full palette integration for outer ring, inner ring, progress arc, and text.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities` (included in the `Krypton.Standard.Toolkit` NuGet package)  
**Default binding property:** `Value`  
**Inheritance:** `Control` → `KryptonProgressBar` → `KryptonCircularProgressBar`

## Key features

- Circular progress arc with configurable ring widths and margins
- Inherits `KryptonProgressBar` styles (`Continuous`, `Marquee`, `Blocks`) and value range
- Animated value changes via `AnimationFunction` and `AnimationSpeed`
- Superscript and subscript text with independent palette states
- `AutoSize` layout that fits centre text and ring geometry
- Designer support via `KryptonCircularProgressBarDesigner`

## Constructor

```csharp
public KryptonCircularProgressBar()
```

Initializes ring palette states, animation defaults, and secondary font for subscript text.

## Notable properties

### Ring layout

| Property | Default | Description |
| --- | --- | --- |
| `ProgressWidth` | `25` | Width of the progress arc stroke |
| `OuterWidth` | `26` | Width of the outer decorative ring |
| `OuterMargin` | `-25` | Offset of the outer ring from the control edge |
| `InnerWidth` | `-1` | Inner ring width (`-1` = auto) |
| `InnerMargin` | `2` | Gap between progress arc and inner ring |

### Text

| Property | Description |
| --- | --- |
| `SuperscriptText` | Text above the centre value |
| `SubscriptText` | Text below the centre value |
| `SuperscriptMargin` / `SubscriptMargin` / `TextMargin` | Padding around text regions |
| `SecondaryFont` | Font used for superscript and subscript |

### Animation

```csharp
[Category("Behavior"), DefaultValue(KnownAnimationFunctions.Linear)]
public KnownAnimationFunctions AnimationFunction { get; set; }

[Category("Behavior"), DefaultValue(500)]
public int AnimationSpeed { get; set; }
```

Assign `CustomAnimationFunction` in code for non-standard easing (hidden from the designer).

### Palette states

- **Outer ring:** `OuterRingStateCommon`, `OuterRingStateNormal`, `OuterRingStateDisabled`
- **Inner ring:** `InnerRingStateCommon`, `InnerRingStateNormal`, `InnerRingStateDisabled`
- **Superscript / subscript:** `SuperscriptState*`, `SubscriptState*` triple states

Inherited from `KryptonProgressBar`: `StateCommon`, `StateNormal`, `StateDisabled`, `Values`, `Style`, `Value`, `Minimum`, `Maximum`.

## Usage

```csharp
using Krypton.Toolkit.Utilities;

var progress = new KryptonCircularProgressBar
{
    Value = 0,
    Maximum = 100,
    SuperscriptText = "Installing",
    SubscriptText = "Please wait…",
    AnimationFunction = WinFormAnimation.KnownAnimationFunctions.EaseOut,
    AnimationSpeed = 400,
    Dock = DockStyle.Fill
};

// Update during work
progress.Value = 75;
```

Add the control from the toolbox after referencing `Krypton.Standard.Toolkit`. The type appears under **Krypton Toolkit Utilities**.

## Best practices

- Set a minimum control size of roughly 48×48 pixels; the control enforces a minimum diameter internally.
- Use `Style = ProgressBarStyle.Marquee` for indeterminate operations; use `Continuous` with `Value` for determinate progress.
- Prefer palette states over hard-coded colours so the ring tracks global theme changes from `KryptonManager`.

## See also

- [KryptonProgressBar](KryptonProgressBar.md) — linear progress bar base type
- [Controls index](../Controls.md)
- `TestForm/CircularProgressBarTest` — interactive demo
