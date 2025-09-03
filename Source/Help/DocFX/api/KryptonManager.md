# KryptonManager

The `KryptonManager` class is the central component for managing global settings that affect all Krypton controls in an application.

## Overview

`KryptonManager` exposes global settings that affect all Krypton controls. It provides centralized theme management, palette configuration, and global visual settings.

## Namespace

```csharp
Krypton.Toolkit
```

## Inheritance

```csharp
public sealed class KryptonManager : Component
```

## Key Features

- **Global Theme Management**: Set and manage themes across all Krypton controls
- **Palette Configuration**: Configure custom palettes and color schemes
- **ToolStrip Integration**: Control whether palette colors are applied to toolstrips
- **Form Chrome Settings**: Manage form border width and administrator suffix display
- **File Dialog Integration**: Control the use of Krypton file dialogs

## Properties

### GlobalPaletteMode
```csharp
[Category("GlobalPalette")]
[Description("Easy Set for the theme palette")]
[DefaultValue(PaletteMode.Microsoft365Blue)]
public PaletteMode GlobalPaletteMode { get; set; }
```

Gets or sets the global palette mode used for drawing. This property determines which built-in theme is applied to all Krypton controls.

**Default Value**: `PaletteMode.Microsoft365Blue`

**Available Modes**:
- `Microsoft365Blue` (default)
- `Microsoft365Black`
- `Microsoft365Silver`
- `Office2007Blue`
- `Office2007Silver`
- `Office2007Black`
- `Office2010Blue`
- `Office2010Silver`
- `Office2010Black`
- `Office2013White`
- `Office2013LightGray`
- `Office2013DarkGray`
- `SparkleBlue`
- `SparkleOrange`
- `SparklePurple`
- `ProfessionalSystem`
- `ProfessionalOffice2003`
- `Custom`

### GlobalCustomPalette
```csharp
[Category("GlobalPalette")]
[Description("Global custom palette applied to drawing.")]
[DefaultValue(null)]
public KryptonCustomPaletteBase? GlobalCustomPalette { get; set; }
```

Gets and sets the global custom palette applied to drawing. When set to a custom palette, the `GlobalPaletteMode` is automatically set to `PaletteMode.Custom`.

### BaseFont
```csharp
[Category("GlobalPalette")]
[Description("Override the Current global palette font.")]
public Font BaseFont { get; set; }
```

Gets or sets the base font that overrides the current global palette font. This affects the default font used by all Krypton controls.

### GlobalApplyToolstrips
```csharp
[Category("Visuals")]
[Description("Should the palette colors be applied to the toolstrips.")]
[DefaultValue(true)]
public bool GlobalApplyToolstrips { get; set; }
```

Gets or sets a value indicating if the palette colors are applied to the toolstrips. When `true`, Krypton will automatically apply the current theme to all `ToolStrip` controls.

**Default Value**: `true`

### UseKryptonFileDialogs
```csharp
[Category("Visuals")]
[Description("Should use krypton file dialogs for internal openings like CustomPalette Import")]
[DefaultValue(true)]
public bool UseKryptonFileDialogs { get; set; }
```

Gets or sets a value indicating whether to use Krypton file dialogs for internal operations like CustomPalette import.

**Default Value**: `true`

### GlobalUseThemeFormChromeBorderWidth
```csharp
[Category("Visuals")]
[Description("Should KryptonForm instances be allowed to UseThemeFormChromeBorderWidth.")]
[DefaultValue(true)]
public bool GlobalUseThemeFormChromeBorderWidth { get; set; }
```

Gets or sets a value indicating if `KryptonForm` instances are allowed to use theme-specific form chrome border width.

**Default Value**: `true`

### ShowAdministratorSuffix
```csharp
[Category("Visuals")]
[Description("Should the administrator suffix be shown in KryptonForm title bars when running with elevated privileges.")]
[DefaultValue(true)]
public bool ShowAdministratorSuffix { get; set; }
```

Gets or sets a value indicating if the administrator suffix should be shown in `KryptonForm` title bars when running with elevated privileges.

**Default Value**: `true`

## Events

### GlobalPaletteChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the GlobalPalette property is changed.")]
public static event EventHandler? GlobalPaletteChanged;
```

Occurs when the global palette changes. This event is raised whenever the `GlobalPaletteMode` or `GlobalCustomPalette` properties are modified.

### GlobalUseThemeFormChromeBorderWidthChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the GlobalUseThemeFormChromeBorderWidth property is changed.")]
public static event EventHandler? GlobalUseThemeFormChromeBorderWidthChanged;
```

Occurs when the `GlobalUseThemeFormChromeBorderWidth` property changes.

## Methods

### Reset()
```csharp
public void Reset()
```

Resets all global values to their default settings. This method resets:
- GlobalCustomPalette
- ToolkitColors
- GlobalApplyToolstrips
- GlobalUseThemeFormChromeBorderWidth
- ShowAdministratorSuffix
- ToolkitStrings
- UseKryptonFileDialogs
- BaseFont
- GlobalPaletteMode

### IsDefault
```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool IsDefault { get; }
```

Gets a value indicating whether any of the global values have been modified from their defaults.

## Usage Examples

### Basic Theme Setup
```csharp
// Create a KryptonManager instance
KryptonManager manager = new KryptonManager();

// Set a global theme
manager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// Apply to toolstrips
manager.GlobalApplyToolstrips = true;
```

### Custom Palette Setup
```csharp
// Create a custom palette
KryptonCustomPaletteBase customPalette = new MyCustomPalette();

// Apply the custom palette globally
manager.GlobalCustomPalette = customPalette;
```

### Event Handling
```csharp
// Subscribe to palette changes
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    Console.WriteLine("Global palette has changed");
    // Refresh your application's visual appearance
};
```

### Form Integration
```csharp
// In your form's constructor or Load event
private void Form1_Load(object sender, EventArgs e)
{
    // The KryptonManager will automatically apply the current theme
    // to all Krypton controls on this form
}
```

## Design-Time Support

The `KryptonManager` component includes full design-time support with:
- Toolbox integration
- Property grid support
- Designer serialization
- Default property specification

## Thread Safety

The `KryptonManager` class is not thread-safe. All operations should be performed on the UI thread.

## Related Components

- `KryptonCustomPaletteBase` - Base class for custom palettes
- `PaletteMode` - Enumeration of available theme modes
- `KryptonForm` - Themed form that respects global settings
- `KryptonControlCollection` - Collection of Krypton controls

## Notes

- The `KryptonManager` automatically handles system color changes through the `SystemEvents.UserPreferenceChanged` event
- When a custom palette is assigned, the `GlobalPaletteMode` is automatically set to `PaletteMode.Custom`
- The component implements `IDisposable` and should be properly disposed when no longer needed
- Static events are used to notify all instances of palette changes across the application
