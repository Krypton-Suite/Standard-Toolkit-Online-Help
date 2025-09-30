# Acrylic Themes Documentation

## Overview

The Acrylic themes provide Windows 10 Fluent Design-inspired semi-transparent surfaces with subtle blur effects. These themes are designed to create depth and visual hierarchy through transparency and layered backgrounds.

## Architecture

### Theme Structure

The Acrylic themes follow the Material palette structure pattern:

```
PaletteAcrylicBase (Abstract)
├── PaletteAcrylicLight
└── PaletteAcrylicDark

PaletteAcrylicLight_BaseScheme (Color Scheme)
PaletteAcrylicDark_BaseScheme (Color Scheme)
```

### Key Components

#### 1. PaletteAcrylicBase
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Palette Builtin/Acrylic/Bases/PaletteAcrylicBase.cs`
- **Purpose**: Abstract base class providing common acrylic functionality
- **Inherits**: `PaletteMicrosoft365Base`
- **Key Features**:
  - Semi-transparent color blending
  - Acrylic-specific color calculations
  - Renderer assignment (`KryptonManager.RenderAcrylic`)

#### 2. PaletteAcrylicLight & PaletteAcrylicDark
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Palette Builtin/Acrylic/`
- **Purpose**: Concrete theme implementations
- **Features**:
  - Light/Dark mode variants
  - Microsoft 365 image integration
  - Context menu glyph support

#### 3. Color Schemes
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Palette Builtin/Acrylic/Schemes/`
- **Purpose**: Explicit color definitions
- **Pattern**: Inherit from `KryptonColorSchemeBase` and override all 250+ color properties
- **Transparency**: Colors use alpha values (120-180 range) for semi-transparency

#### 4. RenderAcrylic
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Rendering/RenderAcrylic.cs`
- **Purpose**: Custom renderer for acrylic effects
- **Key Method**: `EvalTransparentPaint()` - Always returns `true` to enable transparency

## Usage

### Basic Theme Application

```csharp
// Apply Acrylic Light theme
KryptonManager.GlobalPalette = KryptonManager.PaletteAcrylicLight;

// Apply Acrylic Dark theme
KryptonManager.GlobalPalette = KryptonManager.PaletteAcrylicDark;

// Or using PaletteMode
KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicLight;
KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicDark;
```

### Programmatic Theme Switching

```csharp
public void SwitchToAcrylicLight()
{
    KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicLight;
}

public void SwitchToAcrylicDark()
{
    KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicDark;
}
```

### Theme Detection

```csharp
public bool IsAcrylicTheme()
{
    return KryptonManager.GlobalPaletteMode == PaletteMode.AcrylicLight ||
           KryptonManager.GlobalPaletteMode == PaletteMode.AcrylicDark;
}
```

## Color Characteristics

### Transparency Values
- **Background Colors**: Alpha 120-180 (semi-transparent)
- **Border Colors**: Alpha 80-120 (more transparent)
- **Text Colors**: Alpha 255 (fully opaque for readability)

### Color Palette
- **Light Theme**: 
  - Primary: `Color.FromArgb(180, 255, 255, 255)` (semi-transparent white)
  - Accent: `Color.FromArgb(255, 0, 120, 215)` (Microsoft blue)
- **Dark Theme**:
  - Primary: `Color.FromArgb(120, 0, 0, 0)` (semi-transparent black)
  - Accent: `Color.FromArgb(255, 96, 205, 255)` (Microsoft light blue)

## Integration Points

### PaletteMode Enum
```csharp
public enum PaletteMode
{
    // ... existing values
    AcrylicLight,
    AcrylicDark,
    // ... other values
}
```

### PaletteModeStrings
```csharp
internal const string DEFAULT_PALETTE_ACRYLIC_LIGHT = @"Acrylic - Light";
internal const string DEFAULT_PALETTE_ACRYLIC_DARK = @"Acrylic - Dark";
```

### KryptonManager Integration
```csharp
public static PaletteAcrylicLight PaletteAcrylicLight => _paletteAcrylicLight ??= new PaletteAcrylicLight();
public static PaletteAcrylicDark PaletteAcrylicDark => _paletteAcrylicDark ??= new PaletteAcrylicDark();
public static RenderAcrylic RenderAcrylic => _renderAcrylic ??= new RenderAcrylic();
```

## Customization

### Extending Acrylic Themes

To create custom acrylic variants:

1. **Create Custom Base Scheme**:
```csharp
public sealed class PaletteAcrylicCustom_BaseScheme : KryptonColorSchemeBase
{
    public override Color TextLabelControl { get; set; } = Color.FromArgb(255, 25, 25, 25);
    // Override all color properties...
}
```

2. **Create Custom Palette**:
```csharp
public class PaletteAcrylicCustom : PaletteAcrylicBase
{
    public PaletteAcrylicCustom() : base(new PaletteAcrylicCustom_BaseScheme())
    {
    }
}
```

3. **Register in PaletteMode**:
```csharp
public enum PaletteMode
{
    // ... existing values
    AcrylicCustom,
}
```

### Modifying Transparency Levels

To adjust transparency, modify the alpha values in the base scheme:

```csharp
// More transparent
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(80, 220, 220, 220);

// Less transparent
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(150, 220, 220, 220);
```

## Performance Considerations

### Transparency Impact
- **CPU Usage**: Semi-transparent surfaces require additional compositing
- **Memory**: Alpha blending increases memory usage
- **Rendering**: May impact performance on older hardware

### Optimization Tips
- Use acrylic themes selectively (not for all UI elements)
- Consider disabling transparency on low-end devices
- Test performance on target hardware

## Troubleshooting

### Common Issues

1. **Theme Not Applying**
   - Ensure `KryptonManager.GlobalPaletteMode` is set correctly
   - Check that the palette is properly registered

2. **Transparency Not Working**
   - Verify `RenderAcrylic.EvalTransparentPaint()` returns `true`
   - Check that colors have alpha values < 255

3. **Performance Issues**
   - Consider reducing transparency levels
   - Test on target hardware configuration

### Debug Information

```csharp
public void DebugAcrylicTheme()
{
    var palette = KryptonManager.GlobalPalette;
    Console.WriteLine($"Current Palette: {palette?.GetType().Name}");
    Console.WriteLine($"Palette Mode: {KryptonManager.GlobalPaletteMode}");
    Console.WriteLine($"Renderer: {KryptonManager.GlobalRenderer?.GetType().Name}");
}
```

## Future Enhancements

### Planned Features
- Windows API integration for true acrylic blur effects
- Dynamic transparency based on system settings
- Hardware acceleration support
- Custom blur intensity controls

### Windows API Integration
Future versions may integrate with:
- `SetWindowCompositionAttribute` API
- DirectComposition for hardware acceleration
- Windows 10+ Fluent Design APIs

## Related Documentation
- [Mica Themes Documentation](../Mica/README.md)
- [Material Themes Documentation](../Material/README.md)
- [Krypton Toolkit Palette System](../../../Documents/palette-mechanics-intro.md)
