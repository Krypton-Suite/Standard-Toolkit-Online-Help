# Mica Themes Documentation

## Overview

The Mica themes provide Windows 11 Fluent Design-inspired subtle transparency effects that create a modern, layered appearance. Mica is designed to be more performance-friendly than Acrylic while maintaining visual appeal through subtle transparency and depth.

## Architecture

### Theme Structure

The Mica themes follow the Material palette structure pattern:

```
PaletteMicaBase (Abstract)
├── PaletteMicaLight
└── PaletteMicaDark

PaletteMicaLight_BaseScheme (Color Scheme)
PaletteMicaDark_BaseScheme (Color Scheme)
```

### Key Components

#### 1. PaletteMicaBase
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Palette Builtin/Mica/Bases/PaletteMicaBase.cs`
- **Purpose**: Abstract base class providing common Mica functionality
- **Inherits**: `PaletteMicrosoft365Base`
- **Key Features**:
  - Subtle transparency effects
  - Mica-specific color calculations
  - Renderer assignment (`KryptonManager.RenderMica`)

#### 2. PaletteMicaLight & PaletteMicaDark
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Palette Builtin/Mica/`
- **Purpose**: Concrete theme implementations
- **Features**:
  - Light/Dark mode variants
  - Microsoft 365 image integration
  - Context menu glyph support

#### 3. Color Schemes
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Palette Builtin/Mica/Schemes/`
- **Purpose**: Explicit color definitions
- **Pattern**: Inherit from `KryptonColorSchemeBase` and override all 250+ color properties
- **Transparency**: Colors use alpha values (80-120 range) for subtle transparency

#### 4. RenderMica
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Rendering/RenderMica.cs`
- **Purpose**: Custom renderer for Mica effects
- **Key Method**: `EvalTransparentPaint()` - Always returns `true` to enable transparency

## Usage

### Basic Theme Application

```csharp
// Apply Mica Light theme
KryptonManager.GlobalPalette = KryptonManager.PaletteMicaLight;

// Apply Mica Dark theme
KryptonManager.GlobalPalette = KryptonManager.PaletteMicaDark;

// Or using PaletteMode
KryptonManager.GlobalPaletteMode = PaletteMode.MicaLight;
KryptonManager.GlobalPaletteMode = PaletteMode.MicaDark;
```

### Programmatic Theme Switching

```csharp
public void SwitchToMicaLight()
{
    KryptonManager.GlobalPaletteMode = PaletteMode.MicaLight;
}

public void SwitchToMicaDark()
{
    KryptonManager.GlobalPaletteMode = PaletteMode.MicaDark;
}
```

### Theme Detection

```csharp
public bool IsMicaTheme()
{
    return KryptonManager.GlobalPaletteMode == PaletteMode.MicaLight ||
           KryptonManager.GlobalPaletteMode == PaletteMode.MicaDark;
}
```

## Color Characteristics

### Transparency Values
- **Background Colors**: Alpha 80-120 (subtle transparency)
- **Border Colors**: Alpha 60-100 (more subtle than Acrylic)
- **Text Colors**: Alpha 255 (fully opaque for readability)

### Color Palette
- **Light Theme**: 
  - Primary: `Color.FromArgb(120, 255, 255, 255)` (subtle transparent white)
  - Accent: `Color.FromArgb(255, 0, 120, 215)` (Microsoft blue)
- **Dark Theme**:
  - Primary: `Color.FromArgb(100, 0, 0, 0)` (subtle transparent black)
  - Accent: `Color.FromArgb(255, 96, 205, 255)` (Microsoft light blue)

## Integration Points

### PaletteMode Enum
```csharp
public enum PaletteMode
{
    // ... existing values
    MicaLight,
    MicaDark,
    // ... other values
}
```

### PaletteModeStrings
```csharp
internal const string DEFAULT_PALETTE_MICA_LIGHT = @"Mica - Light";
internal const string DEFAULT_PALETTE_MICA_DARK = @"Mica - Dark";
```

### KryptonManager Integration
```csharp
public static PaletteMicaLight PaletteMicaLight => _paletteMicaLight ??= new PaletteMicaLight();
public static PaletteMicaDark PaletteMicaDark => _paletteMicaDark ??= new PaletteMicaDark();
public static RenderMica RenderMica => _renderMica ??= new RenderMica();
```

## Customization

### Extending Mica Themes

To create custom Mica variants:

1. **Create Custom Base Scheme**:
```csharp
public sealed class PaletteMicaCustom_BaseScheme : KryptonColorSchemeBase
{
    public override Color TextLabelControl { get; set; } = Color.FromArgb(255, 25, 25, 25);
    // Override all color properties...
}
```

2. **Create Custom Palette**:
```csharp
public class PaletteMicaCustom : PaletteMicaBase
{
    public PaletteMicaCustom() : base(new PaletteMicaCustom_BaseScheme())
    {
    }
}
```

3. **Register in PaletteMode**:
```csharp
public enum PaletteMode
{
    // ... existing values
    MicaCustom,
}
```

### Modifying Transparency Levels

To adjust transparency, modify the alpha values in the base scheme:

```csharp
// More subtle transparency
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(60, 220, 220, 220);

// Less subtle transparency
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(120, 220, 220, 220);
```

## Performance Considerations

### Mica vs Acrylic Performance
- **Better Performance**: Mica uses more subtle transparency effects
- **Lower CPU Usage**: Reduced alpha blending operations
- **Memory Efficient**: Less memory overhead than Acrylic
- **Hardware Friendly**: Better performance on older hardware

### Optimization Tips
- Mica is the recommended choice for performance-critical applications
- Use Mica for large UI surfaces
- Consider Mica for mobile or embedded applications

## Troubleshooting

### Common Issues

1. **Theme Not Applying**
   - Ensure `KryptonManager.GlobalPaletteMode` is set correctly
   - Check that the palette is properly registered

2. **Transparency Too Subtle**
   - Increase alpha values in the base scheme
   - Verify `RenderMica.EvalTransparentPaint()` returns `true`

3. **Performance Issues**
   - Mica should perform better than Acrylic
   - Check for other performance bottlenecks

### Debug Information

```csharp
public void DebugMicaTheme()
{
    var palette = KryptonManager.GlobalPalette;
    Console.WriteLine($"Current Palette: {palette?.GetType().Name}");
    Console.WriteLine($"Palette Mode: {KryptonManager.GlobalPaletteMode}");
    Console.WriteLine($"Renderer: {KryptonManager.GlobalRenderer?.GetType().Name}");
}
```

## Comparison with Acrylic

### Visual Differences
| Aspect | Mica | Acrylic |
|--------|------|---------|
| Transparency | Subtle (80-120 alpha) | More pronounced (120-180 alpha) |
| Blur Effect | Minimal | More noticeable |
| Performance | Better | Good |
| Visual Impact | Subtle, modern | Bold, layered |

### When to Use Mica vs Acrylic

**Use Mica when:**
- Performance is critical
- You want subtle, modern appearance
- Targeting older hardware
- Building mobile applications

**Use Acrylic when:**
- You want bold visual effects
- Performance is not a concern
- Targeting modern hardware
- Building desktop applications

## Future Enhancements

### Planned Features
- Windows 11 API integration for true Mica effects
- Dynamic transparency based on system wallpaper
- Hardware acceleration support
- Custom transparency controls

### Windows API Integration
Future versions may integrate with:
- Windows 11 Mica APIs
- `SetWindowCompositionAttribute` with Mica flags
- Desktop wallpaper integration
- System theme adaptation

## Related Documentation
- [Acrylic Themes Documentation](../Acrylic/README.md)
- [Material Themes Documentation](../Material/README.md)
- [Krypton Toolkit Palette System](../../../Documents/palette-mechanics-intro.md)
