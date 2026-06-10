# KryptonBorderEdge

## Overview

`KryptonBorderEdge` draws a single horizontal or vertical themed line, typically used as a separator between UI regions. It is a lightweight, non-focusable control with auto-size defaults.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`  
**Default property:** `Orientation`  
**Inheritance:** `VisualControlBase` → `KryptonBorderEdge`

## Key features

- Horizontal or vertical orientation
- `BorderStyle` maps to palette border style
- `StateCommon`, `StateNormal`, `StateDisabled`
- Auto-size by default (`AutoSize = true`, `GrowAndShrink`)

## Constructor

```csharp
public KryptonBorderEdge()
```

## Properties

### Orientation

```csharp
[DefaultValue(Orientation.Horizontal)]
public virtual Orientation Orientation { get; set; }
```

Direction of the edge line.

### BorderStyle

```csharp
[DefaultValue(PaletteBorderStyle.ControlClient)]
public PaletteBorderStyle BorderStyle { get; set; }
```

Palette border style used for drawing.

### StateCommon / StateDisabled / StateNormal

```csharp
public PaletteBorderEdgeRedirect StateCommon { get; }
public PaletteBorderEdge StateDisabled { get; }
public PaletteBorderEdge StateNormal { get; }
```

Per-state border overrides.

### AutoSize / AutoSizeMode

```csharp
[DefaultValue(true)]
public override bool AutoSize { get; set; }

[DefaultValue(AutoSizeMode.GrowAndShrink)]
public AutoSizeMode AutoSizeMode { get; set; }
```

## Methods

### GetPreferredSize

```csharp
public override Size GetPreferredSize(Size proposedSize)
```

Returns thickness appropriate for orientation.

### SetFixedState

```csharp
public virtual void SetFixedState(PaletteState state)
```

Forces palette state for rendering.

## Hidden properties

`BackColor`, `ForeColor`, `Font`, `TabIndex`, `TabStop`, and `Padding` are hidden; appearance is border-only.

## Usage example

```csharp
kryptonBorderEdge1.Orientation = Orientation.Horizontal;
kryptonBorderEdge1.BorderStyle = PaletteBorderStyle.ControlClient;
kryptonBorderEdge1.Dock = DockStyle.Top;
```

## Best practices

- Use `KryptonSeparator` when you need a separator with extra chrome; use `KryptonBorderEdge` for a minimal line.
- Dock or anchor the control; rely on `AutoSize` for thickness in the cross-axis.

## See also

- [KryptonSeparator](KryptonSeparator.md)
- [Controls index](../Controls.md)
