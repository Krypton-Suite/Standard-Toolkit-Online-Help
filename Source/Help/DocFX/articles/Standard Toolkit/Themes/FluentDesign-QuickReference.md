# Fluent Design Themes - Quick Reference

## Theme Overview

| Theme | Description | Transparency | Performance | Best For |
|-------|-------------|--------------|-------------|----------|
| **Acrylic Light** | Windows 10 Fluent Design with light colors | High (120-180 alpha) | Moderate | Desktop apps, visual impact |
| **Acrylic Dark** | Windows 10 Fluent Design with dark colors | High (120-180 alpha) | Moderate | Desktop apps, visual impact |
| **Mica Light** | Windows 11 Fluent Design with light colors | Subtle (80-120 alpha) | High | Performance-critical apps |
| **Mica Dark** | Windows 11 Fluent Design with dark colors | Subtle (80-120 alpha) | High | Performance-critical apps |

## Quick Start

### Apply Themes
```csharp
// Acrylic Themes
KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicLight;
KryptonManager.GlobalPaletteMode = PaletteMode.AcrylicDark;

// Mica Themes
KryptonManager.GlobalPaletteMode = PaletteMode.MicaLight;
KryptonManager.GlobalPaletteMode = PaletteMode.MicaDark;
```

### Theme Detection
```csharp
// Check theme type
bool isAcrylic = ThemeHelper.IsAcrylicTheme();
bool isMica = ThemeHelper.IsMicaTheme();
bool isFluent = ThemeHelper.IsFluentTheme();

// Check light/dark
bool isLight = ThemeHelper.IsLightTheme();
bool isDark = ThemeHelper.IsDarkTheme();
```

## File Structure

```
Palette Builtin/
├── Acrylic/
│   ├── Bases/PaletteAcrylicBase.cs
│   ├── Schemes/
│   │   ├── PaletteAcrylicLight_BaseScheme.cs
│   │   └── PaletteAcrylicDark_BaseScheme.cs
│   ├── PaletteAcrylicLight.cs
│   ├── PaletteAcrylicDark.cs
│   └── README.md
├── Mica/
│   ├── Bases/PaletteMicaBase.cs
│   ├── Schemes/
│   │   ├── PaletteMicaLight_BaseScheme.cs
│   │   └── PaletteMicaDark_BaseScheme.cs
│   ├── PaletteMicaLight.cs
│   ├── PaletteMicaDark.cs
│   └── README.md
├── FluentDesign-DeveloperGuide.md
└── FluentDesign-QuickReference.md
```

## Color Characteristics

### Transparency Levels
- **Acrylic**: Alpha 120-180 (pronounced transparency)
- **Mica**: Alpha 80-120 (subtle transparency)
- **Text**: Alpha 255 (fully opaque for readability)

### Color Palettes
- **Light Themes**: Semi-transparent white backgrounds
- **Dark Themes**: Semi-transparent black backgrounds
- **Accent Colors**: Microsoft blue variants

## Integration Points

### PaletteMode Enum
```csharp
public enum PaletteMode
{
    AcrylicLight,
    AcrylicDark,
    MicaLight,
    MicaDark,
    // ... other themes
}
```

### KryptonManager Properties
```csharp
// Palette instances
KryptonManager.PaletteAcrylicLight
KryptonManager.PaletteAcrylicDark
KryptonManager.PaletteMicaLight
KryptonManager.PaletteMicaDark

// Renderer instances
KryptonManager.RenderAcrylic
KryptonManager.RenderMica
```

## Customization

### Modify Transparency
```csharp
// In base scheme class
public override Color ButtonNormalBorder { get; set; } = Color.FromArgb(150, 220, 220, 220);
//                                                                    ^^^ Alpha value (0-255)
```

### Create Custom Variants
```csharp
// 1. Create custom scheme
public sealed class PaletteAcrylicCustom_BaseScheme : KryptonColorSchemeBase
{
    // Override all color properties...
}

// 2. Create custom palette
public class PaletteAcrylicCustom : PaletteAcrylicBase
{
    public PaletteAcrylicCustom() : base(new PaletteAcrylicCustom_BaseScheme()) { }
}

// 3. Register in PaletteMode enum
```

## Performance Tips

### Choose the Right Theme
- **Use Mica** for performance-critical applications
- **Use Acrylic** for visual impact and modern desktop apps

### Optimization
- Test on target hardware
- Consider disabling transparency on low-end devices
- Apply themes selectively to specific UI elements

## Troubleshooting

### Common Issues
1. **Theme not applying**: Check `KryptonManager.GlobalPaletteMode`
2. **No transparency**: Verify `EvalTransparentPaint()` returns `true`
3. **Performance issues**: Switch to Mica theme or reduce transparency

### Debug Code
```csharp
public static void DebugTheme()
{
    Console.WriteLine($"Palette: {KryptonManager.GlobalPalette?.GetType().Name}");
    Console.WriteLine($"Mode: {KryptonManager.GlobalPaletteMode}");
    Console.WriteLine($"Renderer: {KryptonManager.GlobalRenderer?.GetType().Name}");
}
```

## Related Files
- [Acrylic Documentation](./Acrylic/README.md)
- [Mica Documentation](./Mica/README.md)
- [Developer Guide](./FluentDesign-DeveloperGuide.md)
- [Palette System Documentation](../../Documents/palette-mechanics-intro.md)
