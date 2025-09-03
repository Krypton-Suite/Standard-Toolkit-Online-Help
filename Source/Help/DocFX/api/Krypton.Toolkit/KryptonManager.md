# KryptonManager

The `KryptonManager` class is a global component that manages theme settings and provides centralized control over the appearance of all Krypton controls in an application.

## Overview

`KryptonManager` is a singleton component that serves as the central hub for managing global theme settings across all Krypton controls. It provides access to built-in themes, custom palettes, and global behavior settings that affect the entire application.

## Namespace

```csharp
Krypton.Toolkit
```

## Inheritance

```csharp
public sealed class KryptonManager : Component
```

## Key Features

- **Global Theme Management**: Centralized control over application-wide themes
- **Built-in Themes**: Extensive collection of pre-built themes (Office 2007, 2010, 2013, Sparkle, Microsoft 365)
- **Custom Palette Support**: Support for custom palette implementations
- **Global Settings**: Application-wide behavior settings
- **Theme Switching**: Dynamic theme switching at runtime
- **Designer Integration**: Full Visual Studio designer support
- **Performance Optimization**: Efficient theme caching and propagation

## Static Properties

### Global Theme Management

#### GlobalPaletteMode
```csharp
[Category("Appearance")]
[Description("Gets and sets the global palette mode.")]
[DefaultValue(PaletteMode.Global)]
public static PaletteMode GlobalPaletteMode { get; set; }
```

Gets and sets the global palette mode that affects all Krypton controls.

**Default Value**: `PaletteMode.Global`

#### GlobalPalette
```csharp
[Category("Appearance")]
[Description("Gets and sets the global palette.")]
[DefaultValue(null)]
public static IPalette GlobalPalette { get; set; }
```

Gets and sets the global palette that affects all Krypton controls.

**Default Value**: `null`

### Global Behavior Settings

#### GlobalApplyToolstrips
```csharp
[Category("Behavior")]
[Description("Gets and sets if toolstrips should be themed globally.")]
[DefaultValue(true)]
public static bool GlobalApplyToolstrips { get; set; }
```

Gets and sets whether toolstrips should be themed globally.

**Default Value**: `true`

#### GlobalUseThemeFormChromeBorderWidth
```csharp
[Category("Behavior")]
[Description("Gets and sets if theme form chrome border width should be used.")]
[DefaultValue(true)]
public static bool GlobalUseThemeFormChromeBorderWidth { get; set; }
```

Gets and sets whether theme form chrome border width should be used.

**Default Value**: `true`

#### GlobalShowAdministratorSuffix
```csharp
[Category("Behavior")]
[Description("Gets and sets if administrator suffix should be shown.")]
[DefaultValue(true)]
public static bool GlobalShowAdministratorSuffix { get; set; }
```

Gets and sets whether administrator suffix should be shown in form titles.

**Default Value**: `true`

#### GlobalUseKryptonFileDialogs
```csharp
[Category("Behavior")]
[Description("Gets and sets if Krypton file dialogs should be used.")]
[DefaultValue(true)]
public static bool GlobalUseKryptonFileDialogs { get; set; }
```

Gets and sets whether Krypton file dialogs should be used instead of standard Windows dialogs.

**Default Value**: `true`

### Base Font Settings

#### BaseFont
```csharp
[Category("Appearance")]
[Description("Gets and sets the base font for the application.")]
[DefaultValue(null)]
public static Font BaseFont { get; set; }
```

Gets and sets the base font for the application.

**Default Value**: `null`

## Instance Properties

### PaletteMode
```csharp
[Category("Appearance")]
[Description("Gets and sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }
```

Gets and sets the palette mode for this manager instance.

**Default Value**: `PaletteMode.Global`

### Palette
```csharp
[Category("Appearance")]
[Description("Gets and sets the custom palette.")]
[DefaultValue(null)]
public IPalette Palette { get; set; }
```

Gets and sets the custom palette for this manager instance.

**Default Value**: `null`

## Events

### GlobalPaletteChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the global palette changes.")]
public static event EventHandler GlobalPaletteChanged;
```

Occurs when the global palette changes.

### PaletteChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the palette changes.")]
public event EventHandler PaletteChanged;
```

Occurs when the palette changes.

## Static Methods

### SetGlobalPalette(IPalette palette)
```csharp
public static void SetGlobalPalette(IPalette palette)
```

Sets the global palette for all Krypton controls.

### GetGlobalPalette()
```csharp
public static IPalette GetGlobalPalette()
```

Gets the current global palette.

### SetGlobalPaletteMode(PaletteMode mode)
```csharp
public static void SetGlobalPaletteMode(PaletteMode mode)
```

Sets the global palette mode.

### GetGlobalPaletteMode()
```csharp
public static PaletteMode GetGlobalPaletteMode()
```

Gets the current global palette mode.

## Available Built-in Themes

### Office 2007 Themes
- `PaletteMode.Office2007Blue` - Office 2007 Blue theme
- `PaletteMode.Office2007BlueDarkMode` - Office 2007 Blue Dark Mode
- `PaletteMode.Office2007BlueLightMode` - Office 2007 Blue Light Mode
- `PaletteMode.Office2007Silver` - Office 2007 Silver theme
- `PaletteMode.Office2007SilverDarkMode` - Office 2007 Silver Dark Mode
- `PaletteMode.Office2007SilverLightMode` - Office 2007 Silver Light Mode
- `PaletteMode.Office2007White` - Office 2007 White theme
- `PaletteMode.Office2007Black` - Office 2007 Black theme
- `PaletteMode.Office2007BlackDarkMode` - Office 2007 Black Dark Mode
- `PaletteMode.Office2007DarkGray` - Office 2007 Dark Gray theme

### Office 2010 Themes
- `PaletteMode.Office2010Blue` - Office 2010 Blue theme
- `PaletteMode.Office2010BlueDarkMode` - Office 2010 Blue Dark Mode
- `PaletteMode.Office2010BlueLightMode` - Office 2010 Blue Light Mode
- `PaletteMode.Office2010Silver` - Office 2010 Silver theme
- `PaletteMode.Office2010SilverDarkMode` - Office 2010 Silver Dark Mode
- `PaletteMode.Office2010SilverLightMode` - Office 2010 Silver Light Mode
- `PaletteMode.Office2010White` - Office 2010 White theme
- `PaletteMode.Office2010Black` - Office 2010 Black theme
- `PaletteMode.Office2010BlackDarkMode` - Office 2010 Black Dark Mode
- `PaletteMode.Office2010DarkGray` - Office 2010 Dark Gray theme

### Office 2013 Themes
- `PaletteMode.Office2013White` - Office 2013 White theme
- `PaletteMode.Office2013LightGray` - Office 2013 Light Gray theme
- `PaletteMode.Office2013DarkGray` - Office 2013 Dark Gray theme

### Sparkle Themes
- `PaletteMode.SparkleBlue` - Sparkle Blue theme
- `PaletteMode.SparkleBlueDarkMode` - Sparkle Blue Dark Mode
- `PaletteMode.SparkleBlueLightMode` - Sparkle Blue Light Mode
- `PaletteMode.SparkleOrange` - Sparkle Orange theme
- `PaletteMode.SparkleOrangeDarkMode` - Sparkle Orange Dark Mode
- `PaletteMode.SparkleOrangeLightMode` - Sparkle Orange Light Mode
- `PaletteMode.SparklePurple` - Sparkle Purple theme
- `PaletteMode.SparklePurpleDarkMode` - Sparkle Purple Dark Mode
- `PaletteMode.SparklePurpleLightMode` - Sparkle Purple Light Mode

### Microsoft 365 Themes
- `PaletteMode.Microsoft365Blue` - Microsoft 365 Blue theme
- `PaletteMode.Microsoft365BlueDarkMode` - Microsoft 365 Blue Dark Mode
- `PaletteMode.Microsoft365Black` - Microsoft 365 Black theme
- `PaletteMode.Microsoft365BlackDarkMode` - Microsoft 365 Black Dark Mode
- `PaletteMode.Microsoft365BlackDarkModeAlternate` - Microsoft 365 Black Dark Mode Alternate
- `PaletteMode.Microsoft365DarkGray` - Microsoft 365 Dark Gray theme

### System Themes
- `PaletteMode.ProfessionalSystem` - Professional System theme
- `PaletteMode.ProfessionalOffice2003` - Professional Office 2003 theme

## Usage Examples

### Basic Theme Setup
```csharp
// Set a global theme for the entire application
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
```

### Custom Palette
```csharp
// Create and set a custom palette
CustomPalette customPalette = new CustomPalette();
KryptonManager.GlobalPalette = customPalette;
```

### Dynamic Theme Switching
```csharp
// Switch themes at runtime
private void SwitchToDarkTheme()
{
    KryptonManager.GlobalPaletteMode = PaletteMode.Office2010BlackDarkMode;
}

private void SwitchToLightTheme()
{
    KryptonManager.GlobalPaletteMode = PaletteMode.Office2010White;
}
```

### Global Behavior Settings
```csharp
// Configure global behavior settings
KryptonManager.GlobalApplyToolstrips = true;
KryptonManager.GlobalUseThemeFormChromeBorderWidth = true;
KryptonManager.GlobalShowAdministratorSuffix = true;
KryptonManager.GlobalUseKryptonFileDialogs = true;
```

### Base Font Configuration
```csharp
// Set a custom base font for the application
KryptonManager.BaseFont = new Font("Segoe UI", 9f);
```

### Event Handling
```csharp
// Subscribe to global palette changes
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    Console.WriteLine("Global theme changed!");
    // Update application-specific settings
};
```

### Designer Integration
```csharp
// Add KryptonManager to a form for design-time configuration
// The manager will appear in the component tray
// and can be configured through the property grid
```

## Design-Time Support

The `KryptonManager` component includes comprehensive design-time support:

- **Component Tray**: Appears in the Visual Studio component tray
- **Property Grid**: Full property grid integration with categorized properties
- **Smart Tags**: Quick access to common theme settings
- **Designer Serialization**: Proper serialization of all properties
- **Toolbox Integration**: Available in the Visual Studio toolbox

## Performance Considerations

- Themes are cached as singleton instances for optimal performance
- Theme changes are efficiently propagated to all controls
- Memory usage is optimized through shared palette instances
- Global settings are applied efficiently across the application

## Best Practices

1. **Initialize Early**: Set the global palette mode early in application startup
2. **Use Consistent Themes**: Maintain theme consistency across the application
3. **Handle Theme Changes**: Subscribe to `GlobalPaletteChanged` for theme-dependent updates
4. **Custom Palettes**: Implement custom palettes for specialized requirements
5. **Performance**: Avoid frequent theme switching in performance-critical scenarios

## Related Components

- `KryptonForm` - Themed form control
- `IPalette` - Palette interface for custom themes
- `PaletteMode` - Theme mode enumeration
- All Krypton controls that automatically use the global theme
