# ButtonValues Theme-Aware Integration

## Overview

The `ButtonValues` class now supports **theme-aware UAC shield icon selection**, allowing buttons to automatically use icons that match your application's Krypton theme. This creates a more cohesive and professional appearance by ensuring UAC shield icons align with your chosen theme.

## New Feature: IconSelectionStrategy Property

### The New Property

```csharp
/// <summary>Gets or sets the strategy for selecting UAC shield icons.</summary>
/// <value>The strategy for selecting UAC shield icons.</value>
[DefaultValue(IconSelectionStrategy.OSBased), Description(@"The strategy for selecting UAC shield icons (OS-based or theme-based).")]
public IconSelectionStrategy IconSelectionStrategy
{
    get => _iconSelectionStrategy;
    set
    {
        if (_iconSelectionStrategy != value)
        {
            _iconSelectionStrategy = value;

            // Refresh the UAC shield if it's currently enabled
            if (_useAsUACElevationButton)
            {
                ShowUACShieldImage(true, _iconSize);
            }
        }
    }
}
```

### Theme Mapping

When using `ThemeBased` strategy, UAC shield icons are selected based on your current Krypton theme:

| Theme Category | Windows Icon Style | Example Themes |
|----------------|-------------------|----------------|
| **Professional/Office 2007/Sparkle** | Windows Vista | ProfessionalSystem, Office2007Blue, SparkleBlue |
| **Office 2010/2013** | Windows 7/8.x | Office2010Blue, Office2013White, VisualStudio2010Render2010 |
| **Microsoft 365/Material** | Windows 10/11 | Microsoft365Blue, MaterialLight, MaterialDark |

## Usage Examples

### 1. Basic Theme-Aware Button Creation

```csharp
// Create a button with theme-aware UAC shield
var button = new KryptonButton();
button.Values.UseAsUACElevationButton = true;
button.Values.IconSize = IconSize.Medium;
button.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
button.Text = "Run as Administrator";
```

### 2. Comparison: OS-Based vs Theme-Based

```csharp
// OS-based selection (default behavior)
var osBasedButton = new KryptonButton();
osBasedButton.Values.UseAsUACElevationButton = true;
osBasedButton.Values.IconSelectionStrategy = IconSelectionStrategy.OSBased;
// Uses Windows version-specific icons

// Theme-based selection
var themeBasedButton = new KryptonButton();
themeBasedButton.Values.UseAsUACElevationButton = true;
themeBasedButton.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
// Uses theme-appropriate icons
```

### 3. Dynamic Theme-Aware Button Updates

```csharp
public class ThemeAwareButton : KryptonButton
{
    public ThemeAwareButton()
    {
        // Enable UAC shield with theme-aware selection
        Values.UseAsUACElevationButton = true;
        Values.IconSize = IconSize.Small;
        Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
        
        // Listen for theme changes
        KryptonManager.GlobalPaletteChanged += OnThemeChanged;
    }
    
    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // Force refresh of UAC shield icon
        Values.UseAsUACElevationButton = false;
        Values.UseAsUACElevationButton = true;
    }
}
```

## Integration with Existing Properties

### Existing ButtonValues Properties

The new theme-aware system integrates seamlessly with existing `ButtonValues` properties:

| Property | Description | Theme-Aware Support |
|----------|-------------|-------------------|
| `UseAsUACElevationButton` | Enables UAC shield functionality | ✅ Full support |
| `IconSize` | Sets predefined icon sizes | ✅ Full support |
| `CustomIconSize` | Sets custom icon dimensions | ✅ Full support |

### Backward Compatibility

All existing code continues to work without changes:

```csharp
// This existing code still works (uses OS-based selection)
var button = new KryptonButton();
button.Values.UseAsUACElevationButton = true;
button.Values.IconSize = IconSize.Medium;
// Defaults to OS-based selection
```

## Real-World Scenarios

### Scenario 1: Professional Application with Office 2007 Theme

```csharp
// Set theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2007Blue;

// Create UAC button with theme-aware icons
var adminButton = new KryptonButton();
adminButton.Values.UseAsUACElevationButton = true;
adminButton.Values.IconSize = IconSize.Medium;
adminButton.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
adminButton.Text = "Install Software";

// Result: Uses Windows Vista shield icon to match Office 2007 theme
```

### Scenario 2: Modern Application with Microsoft 365 Theme

```csharp
// Set theme
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;

// Create UAC button with theme-aware icons
var adminButton = new KryptonButton();
adminButton.Values.UseAsUACElevationButton = true;
adminButton.Values.IconSize = IconSize.Medium;
adminButton.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
adminButton.Text = "Run as Administrator";

// Result: Uses Windows 10/11 shield icon to match Microsoft 365 theme
```

### Scenario 3: Development Tool with Visual Studio Theme

```csharp
// Set theme
KryptonManager.GlobalPaletteMode = PaletteMode.VisualStudio2010Render2010;

// Create UAC button with theme-aware icons
var adminButton = new KryptonButton();
adminButton.Values.UseAsUACElevationButton = true;
adminButton.Values.IconSize = IconSize.Small;
adminButton.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
adminButton.Text = "Debug as Administrator";

// Result: Uses Windows 7/8.x shield icon to match Visual Studio theme
```

## Advanced Usage Patterns

### 1. Application-Wide Theme-Aware Strategy

```csharp
public static class UACButtonManager
{
    private static IconSelectionStrategy _globalStrategy = IconSelectionStrategy.OSBased;
    
    public static IconSelectionStrategy GlobalStrategy
    {
        get => _globalStrategy;
        set
        {
            if (_globalStrategy != value)
            {
                _globalStrategy = value;
                OnStrategyChanged();
            }
        }
    }
    
    public static void ConfigureButton(KryptonButton button, IconSize size = IconSize.Medium)
    {
        button.Values.UseAsUACElevationButton = true;
        button.Values.IconSize = size;
        button.Values.IconSelectionStrategy = _globalStrategy;
    }
    
    private static void OnStrategyChanged()
    {
        // Notify all UAC buttons to refresh
        // Implementation depends on your application architecture
    }
}

// Usage
UACButtonManager.GlobalStrategy = IconSelectionStrategy.ThemeBased;
UACButtonManager.ConfigureButton(adminButton, IconSize.Medium);
```

### 2. Conditional Theme-Aware Selection

```csharp
public static class UACButtonFactory
{
    public static KryptonButton CreateUACButton(string text, bool useThemeAware = true)
    {
        var button = new KryptonButton();
        button.Text = text;
        button.Values.UseAsUACElevationButton = true;
        button.Values.IconSize = IconSize.Medium;
        
        if (useThemeAware)
        {
            button.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
        }
        else
        {
            button.Values.IconSelectionStrategy = IconSelectionStrategy.OSBased;
        }
        
        return button;
    }
}

// Usage
var adminButton = UACButtonFactory.CreateUACButton("Run as Administrator", useThemeAware: true);
var systemButton = UACButtonFactory.CreateUACButton("System Settings", useThemeAware: false);
```

### 3. Dynamic Theme Response

```csharp
public class ThemeAwareUACButton : KryptonButton
{
    private readonly List<KryptonButton> _relatedButtons = new();
    
    public ThemeAwareUACButton()
    {
        Values.UseAsUACElevationButton = true;
        Values.IconSize = IconSize.Medium;
        Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
        
        KryptonManager.GlobalPaletteChanged += OnThemeChanged;
    }
    
    public void AddRelatedButton(KryptonButton button)
    {
        _relatedButtons.Add(button);
    }
    
    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // Refresh this button
        RefreshUACShield();
        
        // Refresh related buttons
        foreach (var button in _relatedButtons)
        {
            if (button.Values.UseAsUACElevationButton)
            {
                button.Values.UseAsUACElevationButton = false;
                button.Values.UseAsUACElevationButton = true;
            }
        }
    }
    
    private void RefreshUACShield()
    {
        Values.UseAsUACElevationButton = false;
        Values.UseAsUACElevationButton = true;
    }
}
```

## Performance Considerations

### 1. Efficient Icon Loading

```csharp
public class UACIconCache
{
    private static readonly Dictionary<(IconSize, IconSelectionStrategy), Image> _cache = new();
    
    public static Image? GetCachedIcon(IconSize size, IconSelectionStrategy strategy)
    {
        var key = (size, strategy);
        
        if (!_cache.ContainsKey(key))
        {
            // Use our new theme-aware system
            var icon = GraphicsExtensions.ExtractIconFromImageres(
                PI.ImageresIconID.Shield, 
                size, 
                strategy
            );
            
            if (icon != null)
            {
                var targetSize = GetSizeFromIconSize(size);
                _cache[key] = new Bitmap(icon.ToBitmap(), targetSize);
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
    
    private static Size GetSizeFromIconSize(IconSize iconSize)
    {
        return new Size((int)iconSize, (int)iconSize);
    }
}
```

### 2. Memory Management

```csharp
public class UACButtonManager : IDisposable
{
    private readonly List<KryptonButton> _managedButtons = new();
    
    public void AddButton(KryptonButton button)
    {
        if (button.Values.UseAsUACElevationButton)
        {
            _managedButtons.Add(button);
        }
    }
    
    public void SetThemeAware(bool themeAware)
    {
        var strategy = themeAware 
            ? IconSelectionStrategy.ThemeBased 
            : IconSelectionStrategy.OSBased;
            
        foreach (var button in _managedButtons)
        {
            button.Values.IconSelectionStrategy = strategy;
        }
    }
    
    public void Dispose()
    {
        UACIconCache.ClearCache();
        _managedButtons.Clear();
    }
}
```

## Migration Guide

### From OS-Based to Theme-Based

If you're updating existing code to use theme-aware UAC shields:

```csharp
// Old code (OS-based only)
var button = new KryptonButton();
button.Values.UseAsUACElevationButton = true;
button.Values.IconSize = IconSize.Medium;

// New code (theme-aware)
var button = new KryptonButton();
button.Values.UseAsUACElevationButton = true;
button.Values.IconSize = IconSize.Medium;
button.Values.IconSelectionStrategy = IconSelectionStrategy.ThemeBased;
```

### Backward Compatibility

The new property is optional, so existing code continues to work:

```csharp
// This still works (uses OS-based selection)
var button = new KryptonButton();
button.Values.UseAsUACElevationButton = true;
button.Values.IconSize = IconSize.Medium;
// Defaults to OS-based selection

// This also works (explicit OS-based selection)
var button = new KryptonButton();
button.Values.UseAsUACElevationButton = true;
button.Values.IconSize = IconSize.Medium;
button.Values.IconSelectionStrategy = IconSelectionStrategy.OSBased;
```

## Benefits

### 1. Visual Consistency
- UAC shield icons match your application's theme
- Professional, cohesive appearance
- Better user experience

### 2. Flexibility
- Choose between OS-based and theme-based selection
- Automatic adaptation to theme changes
- Backward compatibility maintained

### 3. Performance
- Efficient icon loading with caching
- Memory management best practices
- Seamless integration with existing code

### 4. Developer Experience
- Simple property-based configuration
- Clear theme mapping documentation
- Comprehensive examples and best practices

## Summary

The theme-aware integration with `ButtonValues` provides:

- **Automatic UAC shield matching** to your Krypton theme
- **Flexible selection strategy** (OS-based or theme-based)
- **Seamless integration** with existing ButtonValues properties
- **Performance optimization** through efficient icon loading
- **Professional appearance** that enhances user experience

This integration ensures your UAC buttons always look professional and consistent with your chosen theme, creating a more polished and cohesive user interface throughout your application.
