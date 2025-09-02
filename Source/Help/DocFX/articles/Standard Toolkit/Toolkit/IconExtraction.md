# Icon Extraction from `Imageres.dll`

## Quick Start

Extract Windows system icons with a single method call:

```csharp
// Extract a shield icon at default size (32x32)
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);

// Extract a lock icon at large size (96x96)
var lockIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Lock, IconSize.Large);
```

## What You Need to Know

### The Method
```csharp
public static Icon? ExtractIconFromImageres(int iconId, IconSize iconSize = IconSize.Medium, IconSelectionStrategy selectionStrategy = IconSelectionStrategy.OSBased)
```

### Parameters
- **iconId**: Choose from the comprehensive `ImageresIconID` enum (200+ icons available) - cast to `int`
- **iconSize**: Optional size parameter (defaults to 32x32 pixels)
- **selectionStrategy**: Optional strategy for theme-aware selection (defaults to OS-based)

### Returns
- **Icon?**: The extracted icon, or `null` if extraction fails

## Available Icon Sizes

| Size | Pixels | Use Case |
|------|--------|----------|
| `IconSize.Small` | 8x8 | Very small UI elements |
| `IconSize.Small` | 16x16 | Toolbars, menus |
| `IconSize.Small` | 20x20 | Standard small icons |
| `IconSize.Medium` | 24x24 | Standard medium icons |
| `IconSize.Medium` | 32x32 | **Default** - Standard size |
| `IconSize.Medium` | 40x40 | Dialogs, larger buttons |
| `IconSize.Medium` | 48x48 | High-DPI displays |
| `IconSize.Large` | 64x64 | Large buttons, headers |
| `IconSize.Large` | 128x128 | Very large displays |
| `IconSize.Large` | 256x256 | Maximum quality |

## Common Icon Categories

### Security Icons
```csharp
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);
var lockIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Lock);
var unlockIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Unlock);
var keyIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Key);
```

### User & System Icons
```csharp
var userIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.User);
var usersIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Users);
var computerIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Computer);
var networkIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Network);
```

### File & Folder Icons
```csharp
var folderIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Folder);
var fileIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.File);
var fileTextIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.FileText);
var fileImageIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.FileImage);
```

### Application Icons
```csharp
var settingsIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationSettings);
var helpIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationHelp);
var infoIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationInfo);
var warningIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationWarning);
```

### Media Icons
```csharp
var playIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.MediaPlay);
var pauseIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.MediaPause);
var stopIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.MediaStop);
var volumeIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.MediaVolume);
```

## Practical Examples

### 1. Button Icons
```csharp
// Create a button with a shield icon
var button = new KryptonButton();
button.Text = "Run as Administrator";
button.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield, IconSize.Small)?.ToBitmap();

// Create a settings button
var settingsButton = new KryptonButton();
settingsButton.Text = "Settings";
settingsButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationSettings, IconSize.Small)?.ToBitmap();
```

### 2. Menu Items
```csharp
// Add icons to menu items
var menuItem = new KryptonContextMenuItem("Save");
menuItem.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ActionSave, IconSize.Small)?.ToBitmap();

var helpMenuItem = new KryptonContextMenuItem("Help");
helpMenuItem.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationHelp, IconSize.Small)?.ToBitmap();
```

### 3. Toolbar Icons
```csharp
// Create toolbar buttons with system icons
var toolbar = new KryptonToolStrip();

var newButton = new KryptonToolStripButton();
newButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ActionAdd, IconSize.Small)?.ToBitmap();
newButton.Text = "New";

var openButton = new KryptonToolStripButton();
openButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ActionOpen, IconSize.Small)?.ToBitmap();
openButton.Text = "Open";

toolbar.Items.Add(newButton);
toolbar.Items.Add(openButton);
```

### 4. Status Bar Icons
```csharp
// Add status indicators
var statusStrip = new KryptonStatusStrip();

var statusLabel = new KryptonStatusStripLabel();
statusLabel.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.SystemStatusOk, IconSize.Small)?.ToBitmap();
statusLabel.Text = "Ready";

statusStrip.Items.Add(statusLabel);
```

### 5. Error Handling
```csharp
// Safe icon extraction with fallback
public Image? GetSafeIcon(int iconId, IconSize size = IconSize.Medium)
{
    try
    {
        var icon = GraphicsExtensions.ExtractIconFromImageres(iconId, size);
        return icon?.ToBitmap();
    }
    catch (Exception ex)
    {
        // Log the error and return null or a fallback icon
        Debug.WriteLine($"Failed to extract icon {iconId}: {ex.Message}");
        return null;
    }
}

// Usage
var icon = GetSafeIcon((int)PI.ImageresIconID.Shield) ?? Properties.Resources.DefaultShield;
```

### 6. Theme-Aware Icons
```csharp
// Refresh icons when theme changes
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    // Re-extract icons to match new theme
    RefreshAllIcons();
};

private void RefreshAllIcons()
{
    // Re-extract all icons used in your application
    button1.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield, IconSize.Small)?.ToBitmap();
    button2.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationSettings, IconSize.Small)?.ToBitmap();
    // ... refresh other icons
}
```

### 7. Conditional Icons
```csharp
// Show different icons based on application state
public void UpdateStatusIcon(bool isConnected)
{
    var iconId = isConnected ? (int)PI.ImageresIconID.SystemStatusOk : (int)PI.ImageresIconID.SystemStatusError;
    statusLabel.Image = GraphicsExtensions.ExtractIconFromImageres(iconId, IconSize.Small)?.ToBitmap();
}
```

## Best Practices

### 1. Choose Appropriate Sizes
```csharp
// Use smaller sizes for toolbars and menus
var toolbarIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ActionSave, IconSize.Small);

// Use larger sizes for buttons and dialogs
var buttonIcon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield, IconSize.Medium);
```

### 2. Cache Frequently Used Icons
```csharp
private static readonly Dictionary<int, Image> _iconCache = new();

public static Image? GetCachedIcon(int iconId, IconSize size = IconSize.Medium)
{
    var key = $"{iconId}_{size}";
    
    if (!_iconCache.ContainsKey(iconId))
    {
        var icon = GraphicsExtensions.ExtractIconFromImageres(iconId, size);
        _iconCache[iconId] = icon?.ToBitmap();
    }
    
    return _iconCache[iconId];
}
```

### 3. Handle Null Returns
```csharp
// Always check for null returns
var icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);
if (icon != null)
{
    button.Image = icon.ToBitmap();
}
else
{
    // Use fallback icon or handle gracefully
    button.Image = Properties.Resources.DefaultShield;
}
```

### 4. Dispose Icons Properly
```csharp
// Icons should be disposed when no longer needed
using var icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);
if (icon != null)
{
    button.Image = icon.ToBitmap();
}
```

## Common Use Cases

### UAC Shield Buttons
```csharp
// Create an "Run as Administrator" button
var adminButton = new KryptonButton();
adminButton.Text = "Run as Administrator";
adminButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield, IconSize.Small)?.ToBitmap();
```

### Security Dialogs
```csharp
// Use lock icon for security dialogs
var securityForm = new KryptonForm();
securityForm.Icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Lock, IconSize.Medium);
```

### File Operations
```csharp
// Use appropriate icons for file operations
var openButton = new KryptonButton();
openButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ActionOpen, IconSize.Small)?.ToBitmap();

var saveButton = new KryptonButton();
saveButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ActionSave, IconSize.Small)?.ToBitmap();
```

### Application Settings
```csharp
// Settings and configuration icons
var settingsButton = new KryptonButton();
settingsButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationSettings, IconSize.Small)?.ToBitmap();

var helpButton = new KryptonButton();
helpButton.Image = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.ApplicationHelp, IconSize.Small)?.ToBitmap();
```

## Troubleshooting

### Icon Not Found
```csharp
// Check if icon extraction failed
var icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);
if (icon == null)
{
    // Icon extraction failed - use fallback
    Debug.WriteLine("Failed to extract shield icon from imageres.dll");
}
```

### Performance Issues
```csharp
// For frequently used icons, cache them
private static Image? _cachedShieldIcon;

public static Image GetShieldIcon()
{
    if (_cachedShieldIcon == null)
    {
        var icon = GraphicsExtensions.ExtractIconFromImageres((int)PI.ImageresIconID.Shield);
        _cachedShieldIcon = icon?.ToBitmap();
    }
    return _cachedShieldIcon;
}
```

### Theme Changes
```csharp
// Clear cache when theme changes
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    _cachedShieldIcon = null; // Force re-extraction
    RefreshIcons();
};
```

## Summary

The `ExtractIconFromImageres` method provides easy access to Windows system icons with:

- **200+ available icons** across multiple categories
- **10 different sizes** from 8x8 to 256x256 pixels
- **Automatic theme integration** with Krypton Toolkit
- **Simple API** - just one method call
- **Robust error handling** with null returns

Use this feature to create professional, consistent user interfaces that match the Windows design language while maintaining your application's branding.
