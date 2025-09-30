# Fluent Design Themes Developer Guide

## Overview

This guide provides comprehensive documentation for the Fluent Design-inspired themes in the Krypton Toolkit. These themes implement Windows 10 Acrylic and Windows 11 Mica material effects, providing modern, semi-transparent UI surfaces with depth and visual hierarchy.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Acrylic Themes](#acrylic-themes)
3. [Mica Themes](#mica-themes)
4. [Implementation Details](#implementation-details)
5. [Usage Examples](#usage-examples)
6. [Customization Guide](#customization-guide)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting](#troubleshooting)
9. [API Reference](#api-reference)

## Architecture Overview

### Theme System Structure

The Fluent Design themes follow a consistent architecture pattern:

```
Abstract Base Class (PaletteXXXBase)
├── Light Theme Implementation
└── Dark Theme Implementation

Color Scheme Classes
├── Light Scheme (PaletteXXXLight_BaseScheme)
└── Dark Scheme (PaletteXXXDark_BaseScheme)

Custom Renderer (RenderXXX)
└── Transparency Support
```

### Key Design Principles

1. **Consistency**: All themes follow the Material palette structure
2. **Transparency**: Semi-transparent surfaces for depth and layering
3. **Performance**: Optimized rendering for smooth user experience
4. **Extensibility**: Easy to create custom variants
5. **Integration**: Seamless integration with existing Krypton Toolkit

## Acrylic Themes

### Overview
Acrylic themes provide Windows 10 Fluent Design-inspired semi-transparent surfaces with pronounced blur effects. These themes create bold visual hierarchy through transparency and layered backgrounds.

### Key Features
- **Semi-transparent backgrounds** (Alpha 120-180)
- **Enhanced visual depth** through layering
- **Microsoft 365 integration** for consistent iconography
- **Custom renderer** for transparency support

### Quick Start
```csharp
// Apply Acrylic Light theme
KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicLight;

// Apply Acrylic Dark theme
KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicDark;
```

### Files Structure
```
Palette Builtin/Acrylic/
├── Bases/
│   └── PaletteAcrylicBase.cs
├── Schemes/
│   ├── PaletteAcrylicLight_BaseScheme.cs
│   └── PaletteAcrylicDark_BaseScheme.cs
├── PaletteAcrylicLight.cs
├── PaletteAcrylicDark.cs
└── README.md
```

## Mica Themes

### Overview
Mica themes provide Windows 11 Fluent Design-inspired subtle transparency effects. These themes offer better performance than Acrylic while maintaining modern visual appeal through subtle transparency and depth.

### Key Features
- **Subtle transparency** (Alpha 80-120)
- **Better performance** than Acrylic
- **Modern appearance** with minimal visual impact
- **Hardware-friendly** rendering

### Quick Start
```csharp
// Apply Mica Light theme
KryptonManager.GlobalPaletteMode = PaletteMode.MicaLight;

// Apply Mica Dark theme
KryptonManager.GlobalPaletteMode = PaletteMode.MicaDark;
```

### Files Structure
```
Palette Builtin/Mica/
├── Bases/
│   └── PaletteMicaBase.cs
├── Schemes/
│   ├── PaletteMicaLight_BaseScheme.cs
│   └── PaletteMicaDark_BaseScheme.cs
├── PaletteMicaLight.cs
├── PaletteMicaDark.cs
└── README.md
```

## Implementation Details

### Base Classes

#### PaletteAcrylicBase & PaletteMicaBase
- **Inherit from**: `PaletteMicrosoft365Base`
- **Purpose**: Provide common functionality for theme variants
- **Key Methods**:
  - `GetAcrylicSurfaceColor()` / `GetMicaSurfaceColor()`
  - `IsDarkSurface()`
  - `BlendOverlayColor()`

#### Color Schemes
- **Inherit from**: `KryptonColorSchemeBase`
- **Pattern**: Explicit override of all 250+ color properties
- **Transparency**: Alpha values for semi-transparent effects

### Custom Renderers

#### RenderAcrylic & RenderMica
- **Inherit from**: `RenderMicrosoft365`
- **Key Method**: `EvalTransparentPaint()` - Always returns `true`
- **Purpose**: Enable transparency for theme-specific effects

### Integration Points

#### PaletteMode Enum
```csharp
public enum PaletteMode
{
    // ... existing values
    AcrylicLight,
    AcrylicDark,
    MicaLight,
    MicaDark,
    // ... other values
}
```

#### KryptonManager Properties
```csharp
public static PaletteAcrylicLight PaletteAcrylicLight { get; }
public static PaletteAcrylicDark PaletteAcrylicDark { get; }
public static PaletteMicaLight PaletteMicaLight { get; }
public static PaletteMicaDark PaletteMicaDark { get; }
public static RenderAcrylic RenderAcrylic { get; }
public static RenderMica RenderMica { get; }
```

## Usage Examples

### Basic Theme Application

```csharp
public class ThemeManager
{
    public void ApplyAcrylicLight()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicLight;
    }
    
    public void ApplyAcrylicDark()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicDark;
    }
    
    public void ApplyMicaLight()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.MicaLight;
    }
    
    public void ApplyMicaDark()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.MicaDark;
    }
}
```

### Dynamic Theme Switching

```csharp
public class DynamicThemeManager
{
    private readonly Dictionary<string, PaletteMode> _themes = new()
    {
        { "Acrylic Light", PaletteMode.AcrylicLight },
        { "Acrylic Dark", PaletteMode.AcrylicDark },
        { "Mica Light", PaletteMode.MicaLight },
        { "Mica Dark", PaletteMode.MicaDark }
    };
    
    public void SwitchTheme(string themeName)
    {
        if (_themes.TryGetValue(themeName, out var paletteMode))
        {
            KryptonManager.GlobalPaletteMode = paletteMode;
        }
    }
    
    public string[] GetAvailableThemes()
    {
        return _themes.Keys.ToArray();
    }
}
```

### Theme Detection

```csharp
public static class ThemeHelper
{
    public static bool IsAcrylicTheme()
    {
        var mode = KryptonManager.GlobalPaletteMode;
        return mode == PaletteMode.AcrylicLight || mode == PaletteMode.AcrylicDark;
    }
    
    public static bool IsMicaTheme()
    {
        var mode = KryptonManager.GlobalPaletteMode;
        return mode == PaletteMode.MicaLight || mode == PaletteMode.MicaDark;
    }
    
    public static bool IsFluentTheme()
    {
        return IsAcrylicTheme() || IsMicaTheme();
    }
    
    public static bool IsLightTheme()
    {
        var mode = KryptonManager.GlobalPaletteMode;
        return mode == PaletteMode.AcrylicLight || mode == PaletteMode.MicaLight;
    }
    
    public static bool IsDarkTheme()
    {
        var mode = KryptonManager.GlobalPaletteMode;
        return mode == PaletteMode.AcrylicDark || mode == PaletteMode.MicaDark;
    }
}
```

## Customization Guide

### Creating Custom Acrylic Variants

```csharp
// 1. Create custom color scheme
public sealed class PaletteAcrylicCustom_BaseScheme : KryptonColorSchemeBase
{
    public override Color TextLabelControl { get; set; } = Color.FromArgb(255, 25, 25, 25);
    public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(150, 220, 220, 220);
    // Override all other color properties...
}

// 2. Create custom palette
public class PaletteAcrylicCustom : PaletteAcrylicBase
{
    public PaletteAcrylicCustom() : base(new PaletteAcrylicCustom_BaseScheme())
    {
    }
}

// 3. Register in PaletteMode enum
public enum PaletteMode
{
    // ... existing values
    AcrylicCustom,
}
```

### Modifying Transparency Levels

```csharp
// More transparent (subtle effect)
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(80, 220, 220, 220);

// Less transparent (bold effect)
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(200, 220, 220, 220);
```

### Custom Color Palettes

```csharp
public class CustomAcrylicPalette : PaletteAcrylicBase
{
    public CustomAcrylicPalette() : base(new CustomColorScheme())
    {
    }
    
    // Override specific color methods for custom behavior
    public override Color GetBackColor1(PaletteState state)
    {
        // Custom color logic
        return base.GetBackColor1(state);
    }
}
```

## Performance Considerations

### Transparency Impact

| Theme | Transparency Level | Performance Impact | Use Case |
|-------|-------------------|-------------------|----------|
| Acrylic | High (120-180 alpha) | Moderate | Desktop applications |
| Mica | Subtle (80-120 alpha) | Low | Performance-critical apps |

### Optimization Tips

1. **Choose the Right Theme**:
   - Use Mica for performance-critical applications
   - Use Acrylic for visual impact

2. **Hardware Considerations**:
   - Test on target hardware
   - Consider disabling transparency on low-end devices

3. **Selective Application**:
   - Apply themes to specific UI elements
   - Avoid transparency on large surfaces

### Performance Testing

```csharp
public class PerformanceTester
{
    public void TestThemePerformance()
    {
        var themes = new[] 
        { 
            PaletteMode.AcrylicLight, 
            PaletteMode.AcrylicDark,
            PaletteMode.MicaLight, 
            PaletteMode.MicaDark 
        };
        
        foreach (var theme in themes)
        {
            var stopwatch = Stopwatch.StartNew();
            KryptonManager.GlobalPaletteMode = theme;
            stopwatch.Stop();
            
            Console.WriteLine($"{theme}: {stopwatch.ElapsedMilliseconds}ms");
        }
    }
}
```

## Troubleshooting

### Common Issues

#### 1. Theme Not Applying
**Symptoms**: UI doesn't change when switching themes
**Solutions**:
- Verify `KryptonManager.GlobalPaletteMode` is set correctly
- Check that the palette is properly registered
- Ensure the application is using Krypton controls

#### 2. Transparency Not Working
**Symptoms**: Surfaces appear opaque instead of transparent
**Solutions**:
- Verify `RenderAcrylic.EvalTransparentPaint()` returns `true`
- Check that colors have alpha values < 255
- Ensure the renderer is properly assigned

#### 3. Performance Issues
**Symptoms**: Slow rendering or high CPU usage
**Solutions**:
- Switch to Mica theme for better performance
- Reduce transparency levels
- Test on target hardware

### Debug Utilities

```csharp
public static class ThemeDebugger
{
    public static void LogCurrentTheme()
    {
        var palette = KryptonManager.GlobalPalette;
        var mode = KryptonManager.GlobalPaletteMode;
        var renderer = KryptonManager.GlobalRenderer;
        
        Console.WriteLine($"Current Palette: {palette?.GetType().Name}");
        Console.WriteLine($"Palette Mode: {mode}");
        Console.WriteLine($"Renderer: {renderer?.GetType().Name}");
        Console.WriteLine($"Is Acrylic: {ThemeHelper.IsAcrylicTheme()}");
        Console.WriteLine($"Is Mica: {ThemeHelper.IsMicaTheme()}");
    }
    
    public static void TestTransparency()
    {
        var palette = KryptonManager.GlobalPalette;
        if (palette != null)
        {
            var color = palette.GetBackColor1(PaletteState.Normal);
            Console.WriteLine($"Background Color: {color}");
            Console.WriteLine($"Alpha Value: {color.A}");
            Console.WriteLine($"Is Transparent: {color.A < 255}");
        }
    }
}
```

## API Reference

### PaletteMode Enum Values

| Value | Description |
|-------|-------------|
| `AcrylicLight` | Acrylic theme with light colors |
| `AcrylicDark` | Acrylic theme with dark colors |
| `MicaLight` | Mica theme with light colors |
| `MicaDark` | Mica theme with dark colors |

### KryptonManager Properties

| Property | Type | Description |
|----------|------|-------------|
| `PaletteAcrylicLight` | `PaletteAcrylicLight` | Acrylic light theme instance |
| `PaletteAcrylicDark` | `PaletteAcrylicDark` | Acrylic dark theme instance |
| `PaletteMicaLight` | `PaletteMicaLight` | Mica light theme instance |
| `PaletteMicaDark` | `PaletteMicaDark` | Mica dark theme instance |
| `RenderAcrylic` | `RenderAcrylic` | Acrylic renderer instance |
| `RenderMica` | `RenderMica` | Mica renderer instance |

### Key Methods

#### PaletteAcrylicBase & PaletteMicaBase
- `GetAcrylicSurfaceColor()` / `GetMicaSurfaceColor()`: Get theme-specific surface colors
- `IsDarkSurface()`: Determine if surface should use dark colors
- `BlendOverlayColor()`: Blend colors with transparency

#### RenderAcrylic & RenderMica
- `EvalTransparentPaint()`: Always returns `true` to enable transparency

## Future Enhancements

### Planned Features
- Windows API integration for true blur effects
- Dynamic transparency based on system settings
- Hardware acceleration support
- Custom blur intensity controls
- Desktop wallpaper integration

### Windows API Integration
Future versions may integrate with:
- `SetWindowCompositionAttribute` API
- DirectComposition for hardware acceleration
- Windows 10+ Fluent Design APIs
- Windows 11 Mica APIs

## Related Documentation
- [Acrylic Themes Documentation](./Acrylic/README.md)
- [Mica Themes Documentation](./Mica/README.md)
- [Material Themes Documentation](./Material/README.md)
- [Krypton Toolkit Palette System](../../Documents/palette-mechanics-intro.md)
