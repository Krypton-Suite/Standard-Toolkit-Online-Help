# KryptonWrapLabel

## Overview

`KryptonWrapLabel` extends `Label` with Krypton palette fonts, colors, and word wrapping. Use it for descriptive text that must wrap within a fixed width while staying on-theme.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`  
**Default property:** `Text`  
**Inheritance:** `Label` → `KryptonWrapLabel`

## Key features

- `LabelStyle` and palette content integration
- `StateCommon`, `StateNormal`, `StateDisabled`
- `PaletteMode` / `Palette` with `PaletteChanged` event
- `Target` for forwarding mnemonics and clicks
- `KryptonContextMenu` support
- `AutoSize` with wrapping behavior

## Constructor

```csharp
public KryptonWrapLabel()
```

## Properties

### LabelStyle

```csharp
public LabelStyle LabelStyle { get; set; }
```

**Default:** `LabelStyle.NormalPanel` (set in constructor). Controls font and color mapping from the palette.

### PaletteMode / Palette

```csharp
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }

public PaletteBase? Palette { get; set; }
```

Theme source; `ResetPaletteMode()` / `ResetPalette()` restore global palette.

### StateCommon / StateNormal / StateDisabled

```csharp
public PaletteWrapLabel StateCommon { get; }
public PaletteWrapLabel StateDisabled { get; }
public PaletteWrapLabel StateNormal { get; }
```

Content and short-text overrides per state.

### Target

```csharp
[DefaultValue(null)]
public Control? Target { get; set; }
```

Optional control that receives mnemonic activation and click forwarding.

### KryptonContextMenu

```csharp
public KryptonContextMenu? KryptonContextMenu { get; set; }
```

Themed context menu on right-click.

### Renderer

```csharp
public IRenderer? Renderer { get; }
```

Resolved renderer from the active palette.

## Events

### PaletteChanged

```csharp
public event EventHandler? PaletteChanged;
```

Raised when `Palette` or `PaletteMode` changes.

## Methods

### UpdateFont

```csharp
public void UpdateFont()
```

Refreshes font metrics from the current palette (call after palette or `LabelStyle` changes if text layout is stale).

### CreateToolStripRenderer

```csharp
public ToolStripRenderer? CreateToolStripRenderer()
```

Creates a tool strip renderer consistent with the label palette.

### GetResolvedPalette

Returns the palette instance used for drawing.

## Hidden WinForms properties

`BackColor`, `ForeColor`, `Font`, `BorderStyle`, and `FlatStyle` are hidden; use palette states and `LabelStyle` instead.

## Usage example

```csharp
kryptonWrapLabel1.Text = "Long description text that wraps within the control width.";
kryptonWrapLabel1.LabelStyle = LabelStyle.NormalPanel;
kryptonWrapLabel1.AutoSize = false;
kryptonWrapLabel1.Width = 240;
kryptonWrapLabel1.Target = kryptonButton1;
```

## Best practices

- Set `AutoSize = false` and a fixed width when you need predictable wrapping in layouts.
- Use [KryptonLabel](KryptonLabel.md) for single-line labels without wrap semantics.

## See also

- [KryptonLabel](KryptonLabel.md)
- [KryptonLinkWrapLabel](KryptonLinkWrapLabel.md)
- [Controls index](../Controls.md)
