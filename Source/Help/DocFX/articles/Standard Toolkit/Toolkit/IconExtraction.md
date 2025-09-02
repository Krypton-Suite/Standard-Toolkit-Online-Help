# Developer Guide: Icon Extraction from Imageres.dll

## Quick Start

Extract Windows system icons with a single method call:

```csharp
// Extract a shield icon at default size (32x32)
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield);

// Extract a lock icon at large size (96x96)
var lockIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Lock, UACShieldIconSize.Large);
```

## What You Need to Know

### The Method
```csharp
public static Icon? ExtractIconFromImageres(PI.ImageresIconID iconId, UACShieldIconSize iconSize = UACShieldIconSize.MediumSmall)
```

### Parameters
- **iconId**: Choose from the comprehensive `ImageresIconID` enum (200+ icons available)
- **iconSize**: Optional size parameter (defaults to 32x32 pixels)

### Returns
- **Icon?**: The extracted icon, or `null` if extraction fails

## Available Icon Sizes

| Size | Pixels | Use Case |
|------|--------|----------|
| `Tiny` | 8x8 | Very small UI elements |
| `ExtraSmall` | 16x16 | Toolbars, menus |
| `Small` | 24x24 | Standard small icons |
| `MediumSmall` | 32x32 | **Default** - Standard size |
| `Medium` | 48x48 | Dialogs, larger buttons |
| `MediumLarge` | 64x64 | High-DPI displays |
| `Large` | 96x96 | Large buttons, headers |
| `ExtraLarge` | 128x128 | Very large displays |
| `Huge` | 192x192 | High-resolution displays |
| `Maximum` | 256x256 | Maximum quality |

## Common Icon Categories

### Security Icons
```csharp
var shieldIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield);
var lockIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Lock);
var unlockIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Unlock);
var keyIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Key);
```

### User & System Icons
```csharp
var userIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.User);
var usersIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Users);
var computerIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Computer);
var networkIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Network);
```

### File & Folder Icons
```csharp
var folderIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Folder);
var fileIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.File);
var fileTextIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.FileText);
var fileImageIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.FileImage);
```

### Application Icons
```csharp
var settingsIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationSettings);
var helpIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationHelp);
var infoIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationInfo);
var warningIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationWarning);
```

### Media Icons
```csharp
var playIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.MediaPlay);
var pauseIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.MediaPause);
var stopIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.MediaStop);
var volumeIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.MediaVolume);
```

## Practical Examples

### 1. Button Icons
```csharp
// Create a button with a shield icon
var button = new KryptonButton();
button.Text = "Run as Administrator";
button.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield, UACShieldIconSize.Small)?.ToBitmap();

// Create a settings button
var settingsButton = new KryptonButton();
settingsButton.Text = "Settings";
settingsButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationSettings, UACShieldIconSize.Small)?.ToBitmap();
```

### 2. Menu Items
```csharp
// Add icons to menu items
var menuItem = new KryptonContextMenuItem("Save");
menuItem.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ActionSave, UACShieldIconSize.ExtraSmall)?.ToBitmap();

var helpMenuItem = new KryptonContextMenuItem("Help");
helpMenuItem.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationHelp, UACShieldIconSize.ExtraSmall)?.ToBitmap();
```

### 3. Toolbar Icons
```csharp
// Create toolbar buttons with system icons
var toolbar = new KryptonToolStrip();

var newButton = new KryptonToolStripButton();
newButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ActionAdd, UACShieldIconSize.ExtraSmall)?.ToBitmap();
newButton.Text = "New";

var openButton = new KryptonToolStripButton();
openButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ActionOpen, UACShieldIconSize.ExtraSmall)?.ToBitmap();
openButton.Text = "Open";

toolbar.Items.Add(newButton);
toolbar.Items.Add(openButton);
```

### 4. Status Bar Icons
```csharp
// Add status indicators
var statusStrip = new KryptonStatusStrip();

var statusLabel = new KryptonStatusStripLabel();
statusLabel.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.SystemStatusOk, UACShieldIconSize.Tiny)?.ToBitmap();
statusLabel.Text = "Ready";

statusStrip.Items.Add(statusLabel);
```

### 5. Error Handling
```csharp
// Safe icon extraction with fallback
public Image? GetSafeIcon(PI.ImageresIconID iconId, UACShieldIconSize size = UACShieldIconSize.MediumSmall)
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
var icon = GetSafeIcon(PI.ImageresIconID.Shield) ?? Properties.Resources.DefaultShield;
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
    button1.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield, UACShieldIconSize.Small)?.ToBitmap();
    button2.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationSettings, UACShieldIconSize.Small)?.ToBitmap();
    // ... refresh other icons
}
```

### 7. Conditional Icons
```csharp
// Show different icons based on application state
public void UpdateStatusIcon(bool isConnected)
{
    var iconId = isConnected ? PI.ImageresIconID.SystemStatusOk : PI.ImageresIconID.SystemStatusError;
    statusLabel.Image = GraphicsExtensions.ExtractIconFromImageres(iconId, UACShieldIconSize.Tiny)?.ToBitmap();
}
```

## Best Practices

### 1. Choose Appropriate Sizes
```csharp
// Use smaller sizes for toolbars and menus
var toolbarIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ActionSave, UACShieldIconSize.ExtraSmall);

// Use larger sizes for buttons and dialogs
var buttonIcon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield, UACShieldIconSize.Medium);
```

### 2. Cache Frequently Used Icons
```csharp
private static readonly Dictionary<PI.ImageresIconID, Image> _iconCache = new();

public static Image? GetCachedIcon(PI.ImageresIconID iconId, UACShieldIconSize size = UACShieldIconSize.MediumSmall)
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
var icon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield);
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
using var icon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield);
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
adminButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield, UACShieldIconSize.Small)?.ToBitmap();
```

### Security Dialogs
```csharp
// Use lock icon for security dialogs
var securityForm = new KryptonForm();
securityForm.Icon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Lock, UACShieldIconSize.Medium);
```

### File Operations
```csharp
// Use appropriate icons for file operations
var openButton = new KryptonButton();
openButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ActionOpen, UACShieldIconSize.Small)?.ToBitmap();

var saveButton = new KryptonButton();
saveButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ActionSave, UACShieldIconSize.Small)?.ToBitmap();
```

### Application Settings
```csharp
// Settings and configuration icons
var settingsButton = new KryptonButton();
settingsButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationSettings, UACShieldIconSize.Small)?.ToBitmap();

var helpButton = new KryptonButton();
helpButton.Image = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.ApplicationHelp, UACShieldIconSize.Small)?.ToBitmap();
```

## Troubleshooting

### Icon Not Found
```csharp
// Check if icon extraction failed
var icon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield);
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
        var icon = GraphicsExtensions.ExtractIconFromImageres(PI.ImageresIconID.Shield);
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
