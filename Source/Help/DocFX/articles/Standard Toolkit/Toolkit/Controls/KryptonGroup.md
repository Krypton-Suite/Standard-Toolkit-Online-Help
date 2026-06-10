# KryptonGroup

## Overview

`KryptonGroup` groups related controls inside a themed border and background. It exposes an inner `Panel` for child controls and supports auto-size, themed scroll bars, and full palette state customization.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `VisualControlBase` → `KryptonGroup`

## Key features

- Bordered container with `GroupBackStyle` and `GroupBorderStyle`
- Inner `KryptonGroupPanel` for child controls at design time and run time
- `DisplayRectangle` reports the fill area inside the border (designer-friendly)
- Optional `UseKryptonScrollbars`
- `AutoSize` / `AutoSizeMode` for grow/shrink layout

## Class hierarchy

```text
Krypton.Toolkit.VisualControlBase
└── Krypton.Toolkit.KryptonGroup
    └── Panel (KryptonGroupPanel) — child container
```

## Constructor

```csharp
public KryptonGroup()
```

Creates palette states, inner panel, view manager, and wires the panel into the control collection.

## Properties

### Panel

```csharp
public KryptonGroupPanel Panel { get; }
```

Host surface for child controls. Place controls on the group in the designer; they are parented to `Panel`.

### GroupBackStyle / GroupBorderStyle

```csharp
[DefaultValue(PaletteBackStyle.ControlClient)]
public PaletteBackStyle GroupBackStyle { get; set; }

[DefaultValue(PaletteBorderStyle.ControlClient)]
public PaletteBorderStyle GroupBorderStyle { get; set; }
```

Top-level palette styles for background and border.

### StateCommon / StateDisabled / StateNormal

```csharp
public PaletteDoubleRedirect StateCommon { get; }
public PaletteDouble? StateDisabled { get; }
public PaletteDouble? StateNormal { get; }
```

Per-state back and border overrides (`PaletteDouble`).

### AutoSize / AutoSizeMode

```csharp
public override bool AutoSize { get; set; }
[DefaultValue(AutoSizeMode.GrowAndShrink)]
public AutoSizeMode AutoSizeMode { get; set; }
```

**Default:** `AutoSizeMode.GrowAndShrink` (differs from many WinForms controls).

### UseKryptonScrollbars / ScrollbarManager

Same pattern as [KryptonPanel](KryptonPanel.md).

### DisplayRectangle

```csharp
public override Rectangle DisplayRectangle { get; }
```

Returns the client fill rectangle inside the border (used by the designer for child placement).

## Methods

### GetPreferredSize

```csharp
public override Size GetPreferredSize(Size proposedSize)
```

Layout measurement including border and panel content.

### SetFixedState

```csharp
public virtual void SetFixedState(PaletteState state)
```

Forces rendering state (advanced).

## Usage with KryptonDataGridView

Place a [KryptonDataGridView](KryptonDataGridView.md) inside a group with `Dock = Fill` for group chrome around a grid. Set `HideOuterBorders = true` on the grid if cell borders clash with the group border, unless you use the grid's own [corner rounding](KryptonDataGridView.md#external-corner-rounding).

## Best practices

- Parent child controls to the group in the designer (not only to the form) so they move with the group.
- Prefer native grid corner rounding over group + grid double borders when only rounding is needed.

## See also

- [KryptonGroupBox](KryptonGroupBox.md) — captioned variant
- [KryptonPanel](KryptonPanel.md) — borderless background
- [KryptonDataGridView](KryptonDataGridView.md)
