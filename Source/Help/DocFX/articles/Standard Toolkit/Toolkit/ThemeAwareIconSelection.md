# Theme-Aware Icon Selection

## Overview

The `ExtractIconFromImageres` method now supports **theme-aware icon selection**, allowing you to choose icons that match your application's visual theme rather than just the operating system. This creates a more cohesive and professional appearance by ensuring icons align with your chosen Krypton theme.

## New Feature: IconSelectionStrategy

### The Strategy Enum

```csharp
public enum IconSelectionStrategy
{
    /// <summary>Use OS-based icon selection (default behavior).</summary>
    OSBased = 0,

    /// <summary>Use theme-based icon selection.</summary>
    ThemeBased = 1
}
```

### Theme Mapping

When using `ThemeBased` strategy, icons are selected based on your current Krypton theme:

| Theme Category | Windows Icon Style | Example Themes |
|----------------|-------------------|----------------|
| **Professional/Office 2007/Sparkle** | Windows Vista | ProfessionalSystem, Office2007Blue, SparkleBlue |
| **Office 2010/2013** | Windows 7/8.x | Office2010Blue, Office2013White, VisualStudio2010Render2010 |
| **Microsoft 365/Material** | Windows 10/11 | Microsoft365Blue, MaterialLight, MaterialDark |

## Usage Examples

### Basic Theme-Aware Usage

```csharp
// Use theme-based icon selection
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.ThemeBased
);
```

### Comparison: OS-Based vs Theme-Based

```csharp
// OS-based selection (default)
var osBasedIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);

// Theme-based selection
var themeBasedIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.ThemeBased
);
```

## Theme Compatibility Guide

### Windows Vista Compatible Themes
These themes use Windows Vista-style icons for a classic, professional look:

```csharp
// Professional themes
PaletteMode.ProfessionalSystem
PaletteMode.ProfessionalOffice2003

// Office 2007 themes
PaletteMode.Office2007Blue
PaletteMode.Office2007BlueDarkMode
PaletteMode.Office2007BlueLightMode
PaletteMode.Office2007Silver
PaletteMode.Office2007SilverDarkMode
PaletteMode.Office2007SilverLightMode
PaletteMode.Office2007White
PaletteMode.Office2007Black
PaletteMode.Office2007BlackDarkMode

// Sparkle themes
PaletteMode.SparkleBlue
PaletteMode.SparkleBlueDarkMode
PaletteMode.SparkleBlueLightMode
PaletteMode.SparkleOrange
PaletteMode.SparkleOrangeDarkMode
PaletteMode.SparkleOrangeLightMode
PaletteMode.SparklePurple
PaletteMode.SparklePurpleDarkMode
PaletteMode.SparklePurpleLightMode
```

### Windows 7/8.x Compatible Themes
These themes use Windows 7/8.x-style icons for a modern, refined appearance:

```csharp
// Office 2010 themes
PaletteMode.Office2010Blue
PaletteMode.Office2010BlueDarkMode
PaletteMode.Office2010BlueLightMode
PaletteMode.Office2010Silver
PaletteMode.Office2010SilverDarkMode
PaletteMode.Office2010SilverLightMode
PaletteMode.Office2010White
PaletteMode.Office2010Black
PaletteMode.Office2010BlackDarkMode

// Office 2013 themes
PaletteMode.Office2013White

// Visual Studio 2010 themes
PaletteMode.VisualStudio2010Render2007
PaletteMode.VisualStudio2010Render2010
PaletteMode.VisualStudio2010Render2013
PaletteMode.VisualStudio2010Render365
```

### Windows 10/11 Compatible Themes
These themes use Windows 10/11-style icons for a contemporary, sleek appearance:

```csharp
// Microsoft 365 themes
PaletteMode.Microsoft365Blue
PaletteMode.Microsoft365BlueDarkMode
PaletteMode.Microsoft365BlueLightMode
PaletteMode.Microsoft365Silver
PaletteMode.Microsoft365SilverDarkMode
PaletteMode.Microsoft365SilverLightMode
PaletteMode.Microsoft365White
PaletteMode.Microsoft365Black
PaletteMode.Microsoft365BlackDarkMode
PaletteMode.Microsoft365BlackDarkModeAlternate

// Material themes
PaletteMode.MaterialLight
PaletteMode.MaterialDark
PaletteMode.MaterialLightRipple
PaletteMode.MaterialDarkRipple
```

## Practical Implementation Examples

### 1. Theme-Aware Button Creation

```csharp
public class ThemeAwareButton : KryptonButton
{
    public ThemeAwareButton()
    {
        // Automatically use theme-appropriate shield icon
        var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
            (int)PI.ImageresIconID.Shield, 
            IconSize.Small, 
            IconSelectionStrategy.ThemeBased
        );
        
        if (shieldIcon != null)
        {
            Image = shieldIcon.ToBitmap();
            shieldIcon.Dispose();
        }
    }
}
```

### 2. Dynamic Icon Updates on Theme Change

```csharp
public class ThemeAwareIconManager
{
    private readonly Dictionary<IconSize, Image> _iconCache = new();
    
    public ThemeAwareIconManager()
    {
        // Listen for theme changes
        KryptonManager.GlobalPaletteChanged += OnThemeChanged;
    }
    
    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // Clear cache when theme changes
        _iconCache.Clear();
    }
    
    public Image? GetShieldIcon(IconSize size)
    {
        if (!_iconCache.ContainsKey(size))
        {
            var icon = GraphicsExtensions.ExtractIconFromImageres(
                (int)PI.ImageresIconID.Shield, 
                size, 
                IconSelectionStrategy.ThemeBased
            );
            
            if (icon != null)
            {
                _iconCache[size] = icon.ToBitmap();
                icon.Dispose();
            }
        }
        
        return _iconCache[size];
    }
}
```

### 3. Application-Wide Icon Strategy

```csharp
public static class IconStrategyManager
{
    private static IconSelectionStrategy _currentStrategy = IconSelectionStrategy.OSBased;
    
    public static IconSelectionStrategy CurrentStrategy
    {
        get => _currentStrategy;
        set
        {
            if (_currentStrategy != value)
            {
                _currentStrategy = value;
                OnStrategyChanged();
            }
        }
    }
    
    public static Icon? GetShieldIcon(IconSize size = IconSize.Medium)
    {
        return GraphicsExtensions.ExtractIconFromImageres(
            (int)PI.ImageresIconID.Shield, 
            size, 
            _currentStrategy
        );
    }
    
    private static void OnStrategyChanged()
    {
        // Notify UI components to refresh their icons
        // Implementation depends on your application architecture
    }
}
```

## Real-World Scenarios

### Scenario 1: Professional Application with Office 2007 Theme

```csharp
// User selects Office 2007 Blue theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2007Blue;

// Icons automatically use Windows Vista style
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.ThemeBased
);
// Result: Windows Vista shield icon
```

### Scenario 2: Modern Application with Microsoft 365 Theme

```csharp
// User selects Microsoft 365 Blue theme
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;

// Icons automatically use Windows 10/11 style
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.ThemeBased
);
// Result: Windows 10/11 shield icon (depending on OS)
```

### Scenario 3: Development Tool with Visual Studio Theme

```csharp
// User selects Visual Studio 2010 with Office 2010 renderer
KryptonManager.GlobalPaletteMode = PaletteMode.VisualStudio2010Render2010;

// Icons automatically use Windows 7/8.x style
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.ThemeBased
);
// Result: Windows 7/8.x shield icon
```

## Best Practices

### 1. Choose the Right Strategy

```csharp
// Use OS-based for system utilities
if (isSystemUtility)
{
    return GraphicsExtensions.ExtractIconFromImageres(
        (int)PI.ImageresIconID.Shield, 
        size, 
        IconSelectionStrategy.OSBased
    );
}

// Use theme-based for custom applications
else
{
    return GraphicsExtensions.ExtractIconFromImageres(
        (int)PI.ImageresIconID.Shield, 
        size, 
        IconSelectionStrategy.ThemeBased
    );
}
```

### 2. Cache Icons Appropriately

```csharp
public class IconCache
{
    private static readonly Dictionary<(IconSize, IconSelectionStrategy), Image> _cache = new();
    
    public static Image? GetCachedIcon(IconSize size, IconSelectionStrategy strategy)
    {
        var key = (size, strategy);
        
        if (!_cache.ContainsKey(key))
        {
            var icon = GraphicsExtensions.ExtractIconFromImageres(
                (int)PI.ImageresIconID.Shield, 
                size, 
                strategy
            );
            
            if (icon != null)
            {
                _cache[key] = icon.ToBitmap();
                icon.Dispose();
            }
        }
        
        return _cache[key];
    }
    
    public static void ClearCache()
    {
        foreach (var image in _cache.Values)
        {
            image?.Dispose();
        }
        _cache.Clear();
    }
}
```

### 3. Handle Theme Changes Gracefully

```csharp
public class ThemeAwareForm : KryptonForm
{
    private readonly List<Control> _iconControls = new();
    
    public ThemeAwareForm()
    {
        KryptonManager.GlobalPaletteChanged += OnThemeChanged;
    }
    
    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // Refresh all icon controls
        foreach (var control in _iconControls)
        {
            RefreshControlIcon(control);
        }
    }
    
    private void RefreshControlIcon(Control control)
    {
        if (control is KryptonButton button && button.Tag?.ToString() == "ShieldIcon")
        {
            var icon = GraphicsExtensions.ExtractIconFromImageres(
                (int)PI.ImageresIconID.Shield, 
                IconSize.Small, 
                IconSelectionStrategy.ThemeBased
            );
            
            if (icon != null)
            {
                button.Image = icon.ToBitmap();
                icon.Dispose();
            }
        }
    }
}
```

## Performance Considerations

### 1. Lazy Loading

```csharp
public class LazyIconProvider
{
    private Image? _cachedIcon;
    private IconSize _cachedSize;
    private IconSelectionStrategy _cachedStrategy;
    private PaletteMode _cachedTheme;
    
    public Image? GetIcon(IconSize size, IconSelectionStrategy strategy)
    {
        var currentTheme = KryptonManager.CurrentGlobalPaletteMode;
        
        // Check if we need to refresh the cache
        if (_cachedIcon == null || 
            _cachedSize != size || 
            _cachedStrategy != strategy || 
            _cachedTheme != currentTheme)
        {
            // Dispose old icon
            _cachedIcon?.Dispose();
            
            // Load new icon
            var icon = GraphicsExtensions.ExtractIconFromImageres(
                (int)PI.ImageresIconID.Shield, 
                size, 
                strategy
            );
            
            if (icon != null)
            {
                _cachedIcon = icon.ToBitmap();
                icon.Dispose();
                
                // Update cache metadata
                _cachedSize = size;
                _cachedStrategy = strategy;
                _cachedTheme = currentTheme;
            }
        }
        
        return _cachedIcon;
    }
}
```

### 2. Memory Management

```csharp
public class IconManager : IDisposable
{
    private readonly Dictionary<string, Image> _iconCache = new();
    
    public Image? GetIcon(string key, IconSize size, IconSelectionStrategy strategy)
    {
        if (!_iconCache.ContainsKey(key))
        {
            var icon = GraphicsExtensions.ExtractIconFromImageres(
                (int)PI.ImageresIconID.Shield, 
                size, 
                strategy
            );
            
            if (icon != null)
            {
                _iconCache[key] = icon.ToBitmap();
                icon.Dispose();
            }
        }
        
        return _iconCache[key];
    }
    
    public void Dispose()
    {
        foreach (var image in _iconCache.Values)
        {
            image?.Dispose();
        }
        _iconCache.Clear();
    }
}
```

## Migration Guide

### From OS-Based to Theme-Based

If you're updating existing code to use theme-aware icons:

```csharp
// Old code (OS-based only)
var icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);

// New code (theme-aware)
var icon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.ThemeBased
);
```

### Backward Compatibility

The new parameter is optional, so existing code continues to work:

```csharp
// This still works (uses OS-based selection)
var icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);

// This also works (explicit OS-based selection)
var icon = GraphicsExtensions.ExtractIconFromImageres(
    (int)PI.ImageresIconID.Shield, 
    IconSize.Medium, 
    IconSelectionStrategy.OSBased
);
```

## Benefits

### 1. Visual Consistency
- Icons match your application's theme
- Professional, cohesive appearance
- Better user experience

### 2. Flexibility
- Choose between OS-based and theme-based selection
- Automatic adaptation to theme changes
- Backward compatibility maintained

### 3. Performance
- Efficient caching strategies
- Lazy loading support
- Memory management best practices

### 4. Developer Experience
- Simple API with optional parameters
- Clear theme mapping documentation
- Comprehensive examples and best practices

## Summary

The theme-aware icon selection feature provides:

- **Automatic icon matching** to your Krypton theme
- **Flexible selection strategy** (OS-based or theme-based)
- **Seamless integration** with existing code
- **Performance optimization** through caching
- **Professional appearance** that enhances user experience

This feature ensures your application's icons always look professional and consistent with your chosen theme, creating a more polished and cohesive user interface.
