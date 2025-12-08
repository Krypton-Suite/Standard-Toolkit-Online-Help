# KryptonToolStripContainer Developer Documentation

## Overview

`KryptonToolStripContainer` is a Krypton-themed wrapper for the standard WinForms `ToolStripContainer` control. It provides full Krypton palette integration, allowing the `ContentPanel` to be themed consistently with the rest of your Krypton application.

## Key Features

- **Full Krypton Theming**: The `ContentPanel` is automatically themed using Krypton palette colors
- **Palette Support**: Supports `PaletteMode` and custom `Palette` properties
- **State Management**: Provides `StateCommon`, `StateDisabled`, and `StateNormal` properties for fine-grained appearance control
- **Global Palette Integration**: Automatically responds to global palette changes
- **Standard ToolStripContainer Features**: Inherits all functionality from the standard `ToolStripContainer`

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
public class KryptonToolStripContainer : ToolStripContainer
```

## Properties

### Palette Properties

#### `PaletteMode`
```csharp
[Category("Visuals")]
[Description("Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }
```

Gets or sets the palette mode. Valid values:
- `PaletteMode.Global` (default) - Uses the global palette from `KryptonManager`
- `PaletteMode.ProfessionalSystem` - Uses the Professional System palette
- `PaletteMode.ProfessionalOffice2003` - Uses the Office 2003 palette
- `PaletteMode.Office2007Blue`, `Office2007Silver`, `Office2007Black` - Office 2007 palettes
- `PaletteMode.Office2010Blue`, `Office2010Silver`, `Office2010Black`, `Office2010White` - Office 2010 palettes
- `PaletteMode.Office2013` - Office 2013 palette
- `PaletteMode.Microsoft365Dark`, `Microsoft365Light` - Microsoft 365 palettes
- `PaletteMode.SparkleBlue`, `SparkleOrange`, `SparklePurple` - Sparkle palettes
- `PaletteMode.Custom` - Uses a custom palette (requires `Palette` property to be set)

#### `Palette`
```csharp
[Category("Visuals")]
[Description("Sets the custom palette to be used.")]
[DefaultValue(null)]
public PaletteBase? Palette { get; set; }
```

Gets or sets a custom palette implementation. When set, `PaletteMode` automatically changes to `PaletteMode.Custom`. Setting to `null` reverts to `PaletteMode.Global`.

### State Properties

#### `StateCommon`
```csharp
[Category("Visuals")]
[Description("Overrides for defining common appearance that other states can override.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteBack StateCommon { get; }
```

Gets access to the common appearance settings that other states can override. This is the base state from which `StateDisabled` and `StateNormal` inherit.

**Sub-properties:**
- `StateCommon.Back` - Background appearance settings
  - `Back.Color1`, `Back.Color2` - Background colors
  - `Back.ColorStyle` - Color style (Solid, Linear, etc.)
  - `Back.ColorAlign` - Color alignment
  - `Back.ColorAngle` - Gradient angle
  - `Back.Image` - Background image
  - `Back.ImageStyle` - Image style
  - `Back.ImageAlign` - Image alignment

#### `StateDisabled`
```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteBack StateDisabled { get; }
```

Gets access to the disabled state appearance settings. Used when the control is disabled.

#### `StateNormal`
```csharp
[Category("Visuals")]
[Description("Overrides for defining normal appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteBack StateNormal { get; }
```

Gets access to the normal state appearance settings. Used when the control is enabled and in normal state.

### Inherited Properties

`KryptonToolStripContainer` inherits all properties from `ToolStripContainer`, including:
- `ContentPanel` - The main content panel that can be themed
- `TopToolStripPanel`, `BottomToolStripPanel`, `LeftToolStripPanel`, `RightToolStripPanel` - Tool strip panels
- `Dock` - Docking behavior
- `Enabled` - Control enabled state
- All standard `Control` properties

## Methods

### `SetFixedState`
```csharp
public virtual void SetFixedState(PaletteState state)
```

Fixes the control to a particular palette state. This method is provided for API consistency with other Krypton controls but is not typically used for `ToolStripContainer`.

**Parameters:**
- `state` - The palette state to fix (Normal, Disabled, etc.)

## Events

`KryptonToolStripContainer` inherits all events from `ToolStripContainer` and `Control`, including:
- `Paint` - Raised when the control is painted
- `EnabledChanged` - Raised when the `Enabled` property changes
- Standard control events

## Usage Examples

### Basic Usage

```csharp
// Create a KryptonToolStripContainer
var container = new KryptonToolStripContainer
{
    Dock = DockStyle.Fill
};

// Add tool strips to the panels
var menuStrip = new KryptonMenuStrip();
container.TopToolStripPanel.Controls.Add(menuStrip);

var toolStrip = new KryptonToolStrip();
container.TopToolStripPanel.Controls.Add(toolStrip);

var statusStrip = new KryptonStatusStrip();
container.BottomToolStripPanel.Controls.Add(statusStrip);

// Add content to the content panel
var panel = new KryptonPanel { Dock = DockStyle.Fill };
container.ContentPanel.Controls.Add(panel);
```

### Custom Palette Mode

```csharp
// Use a specific built-in palette
var container = new KryptonToolStripContainer
{
    PaletteMode = PaletteMode.Office2013,
    Dock = DockStyle.Fill
};
```

### Custom Palette

```csharp
// Create and use a custom palette
var customPalette = new KryptonCustomPalette();
// ... configure custom palette ...

var container = new KryptonToolStripContainer
{
    Palette = customPalette,
    Dock = DockStyle.Fill
};
```

### Customizing Appearance

```csharp
var container = new KryptonToolStripContainer();

// Customize the common state background
container.StateCommon.Back.Color1 = Color.LightBlue;
container.StateCommon.Back.Color2 = Color.White;
container.StateCommon.Back.ColorStyle = PaletteColorStyle.Linear;

// Customize the normal state (overrides common)
container.StateNormal.Back.Color1 = Color.LightGray;

// Customize the disabled state
container.StateDisabled.Back.Color1 = Color.Gray;
```

### Responding to Global Palette Changes

```csharp
// The control automatically responds to global palette changes
// when PaletteMode is set to Global (default)

// Change the global palette
KryptonManager.GlobalPalette = new PaletteOffice2013();

// All KryptonToolStripContainer instances with PaletteMode.Global
// will automatically update their appearance
```

## Best Practices

1. **Use Global Palette for Consistency**: Unless you need per-control theming, use `PaletteMode.Global` (the default) to ensure consistency across your application.

2. **ContentPanel Theming**: The `ContentPanel` is automatically themed. If you need additional theming, add a `KryptonPanel` to the `ContentPanel`.

3. **State Customization**: Use `StateCommon` for shared settings, and override with `StateNormal` or `StateDisabled` only when necessary.

4. **Disposal**: The control properly disposes of palette resources. Ensure proper disposal when removing from forms.

5. **Performance**: The control uses efficient palette redirection. Avoid creating unnecessary custom palettes for simple color changes; use state properties instead.

## Integration with Other Controls

`KryptonToolStripContainer` works seamlessly with:
- `KryptonMenuStrip` - Add to `TopToolStripPanel`
- `KryptonToolStrip` - Add to any tool strip panel
- `KryptonStatusStrip` - Add to `BottomToolStripPanel`
- `KryptonPanel` - Add to `ContentPanel` for additional theming
- All standard WinForms controls

## Technical Details

### Palette Architecture

The control uses the Krypton palette system:
1. **PaletteRedirect**: Redirects palette requests to the current palette
2. **PaletteDoubleRedirect**: Manages background and border styles
3. **PaletteDouble**: Provides state-specific overrides

### ContentPanel Painting

The `ContentPanel` is a standard `Panel` control. The theming is applied by:
1. Hooking into the `ContentPanel.Paint` event
2. Querying the palette for background colors based on the current state
3. Drawing the background using `Graphics.FillRectangle` with palette colors

### State Management

- **Common State**: Base settings shared by all states
- **Normal State**: Used when the control is enabled
- **Disabled State**: Used when the control is disabled

States inherit from each other in this order: `StateDisabled`/`StateNormal` → `StateCommon` → Palette.

## See Also

- `KryptonPanel` - For additional panel theming
- `KryptonMenuStrip` - Menu strip control
- `KryptonToolStrip` - Tool strip control
- `KryptonStatusStrip` - Status strip control
- `PaletteMode` - Enumeration of available palette modes
- `PaletteBase` - Base class for custom palettes

