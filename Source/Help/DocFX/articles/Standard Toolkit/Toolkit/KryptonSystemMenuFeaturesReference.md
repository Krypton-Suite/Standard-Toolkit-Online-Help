# KryptonSystemMenu Complete Features Reference

## Overview

The `KryptonSystemMenu` is a comprehensive themed system menu implementation that provides complete replacement functionality for the native Windows system menu. This document provides detailed information about all features, capabilities, and implementation details.

## Table of Contents

1. [Core Features](#core-features)
2. [Menu Item Management](#menu-item-management)
3. [Icon System](#icon-system)
4. [Theme Integration](#theme-integration)
5. [Positioning and Display](#positioning-and-display)
6. [State Management](#state-management)
7. [Event Handling](#event-handling)
8. [Performance Features](#performance-features)
9. [Error Handling](#error-handling)
10. [Resource Management](#resource-management)
11. [Advanced Features](#advanced-features)

## Core Features

### 1. Themed System Menu Replacement
- **Complete Native Replacement**: Fully replaces the native Windows system menu
- **KryptonContextMenu Integration**: Built on top of KryptonContextMenu for consistent theming
- **Seamless Integration**: Works with existing KryptonForm infrastructure
- **Cross-Platform Compatibility**: Designed for Windows Forms applications

### 2. Standard Menu Items Support
The system supports all standard Windows system menu items:

| Menu Item | Description | Icon Support | State Management |
|-----------|-------------|--------------|------------------|
| **Restore** | Restore window to normal size | ✅ | Dynamic enable/disable |
| **Move** | Allow window dragging | ❌ | Based on form border style |
| **Size** | Allow window resizing | ❌ | Based on form border style |
| **Minimize** | Minimize window to taskbar | ✅ | Based on MinimizeBox property |
| **Maximize** | Maximize window to full screen | ✅ | Based on MaximizeBox property |
| **Close** | Close the window | ✅ | Based on ControlBox property |

### 3. Dynamic Menu Structure
- **Conditional Item Display**: Menu items appear/disappear based on form state and properties
- **Separator Management**: Automatic separator insertion between logical groups
- **Keyboard Shortcuts**: Support for Alt+F4 (Close) and Alt+Space (Show menu)
- **Context-Aware**: Menu content adapts to current window state

## Menu Item Management

### 1. Menu Item Creation and Management
```csharp
// Direct field references for efficient access
private KryptonContextMenuItem? _menuItemRestore;
private KryptonContextMenuItem? _menuItemMove;
private KryptonContextMenuItem? _menuItemSize;
private KryptonContextMenuItem? _menuItemMinimize;
private KryptonContextMenuItem? _menuItemMaximize;
private KryptonContextMenuItem? _menuItemClose;
```

### 2. Conditional Menu Item Logic
The system implements sophisticated logic for when to show each menu item:

#### Restore Item
```csharp
// Only show if window is not in normal state and either minimize or maximize is enabled
if (_form.WindowState != FormWindowState.Normal && (_form.MinimizeBox || _form.MaximizeBox))
{
    // Add restore item
}
```

#### Move and Size Items
```csharp
// Only add if the window is resizable
if (_form.FormBorderStyle != FormBorderStyle.FixedSingle && 
    _form.FormBorderStyle != FormBorderStyle.Fixed3D && 
    _form.FormBorderStyle != FormBorderStyle.FixedDialog)
{
    // Add move and size items
}
```

#### Separator Logic
```csharp
// Add separator if we have items before it and either minimize or maximize is enabled
if (_contextMenu.Items.Count > 0 && (_form.MinimizeBox || _form.MaximizeBox))
{
    _contextMenu.Items.Add(new KryptonContextMenuSeparator());
}
```

### 3. Menu Item State Management
Dynamic enable/disable based on current form state:

```csharp
private void UpdateMenuItemsState()
{
    var windowState = _form.GetWindowState();

    // Restore: enabled when window is not in normal state
    if (_menuItemRestore != null) 
    {
        _menuItemRestore.Enabled = (windowState != FormWindowState.Normal);
    }
    
    // Minimize: enabled only if MinimizeBox is true and not already minimized
    if (_menuItemMinimize != null) 
    {
        _menuItemMinimize.Enabled = _form.MinimizeBox && (windowState != FormWindowState.Minimized);
    }

    // Maximize: enabled only if MaximizeBox is true and not already maximized
    if (_menuItemMaximize != null)
    {
        _menuItemMaximize.Enabled = _form.MaximizeBox && (windowState != FormWindowState.Maximized);
    }
    
    // Move: enabled when window is in Normal state or minimized
    if (_menuItemMove != null)
    {
        _menuItemMove.Enabled = (windowState == FormWindowState.Normal) || (windowState == FormWindowState.Minimized);
    }
    
    // Size: enabled when window is in Normal state and form is sizable
    if (_menuItemSize != null)
    {
        _menuItemSize.Enabled = (windowState == FormWindowState.Normal) &&
                               (_form.FormBorderStyle == FormBorderStyle.Sizable || 
                                _form.FormBorderStyle == FormBorderStyle.SizableToolWindow);
    }
}
```

## Icon System

### 1. Multi-Theme Icon Support
The system supports 7 different icon themes:

| Theme | Description | Icon Style |
|-------|-------------|------------|
| **Office2013** | Modern, clean icons | Flat, minimal design |
| **Office2010** | Classic Office 2010 | Traditional Windows style |
| **Office2007** | Office 2007 style | Ribbon-era design |
| **Sparkle** | Vibrant, colorful | Bright, eye-catching |
| **Professional** | Neutral, professional | Business-appropriate |
| **Microsoft365** | Modern Microsoft 365 | Contemporary design |
| **Office2003** | Classic Office 2003 | Legacy Windows style |

### 2. Automatic Theme Detection
```csharp
public string GetCurrentTheme()
{
    var palette = _form.GetResolvedPalette();
    var headerColor = palette.GetBackColor1(PaletteBackStyle.HeaderForm, PaletteState.Normal);

    return headerColor switch
    {
        var color when IsLightColor(color) => "Office2013",
        var color when IsBlueTone(color) => "Office2010",
        var color when IsDarkBlueTone(color) => "Office2007",
        var color when IsVibrantColor(color) => "Sparkle",
        var color when IsNeutralTone(color) => "Professional",
        var color when IsModernColor(color) => "Microsoft365",
        var color when IsClassicColor(color) => "Office2003",
        _ => "Office2013" // default fallback
    };
}
```

### 3. Color-Based Theme Detection
The system uses sophisticated color analysis to determine the appropriate theme:

#### Light Color Detection
```csharp
private bool IsLightColor(Color color)
{
    var brightness = (0.299 * color.R + 0.587 * color.G + 0.114 * color.B) / 255;
    return brightness > 0.6;
}
```

#### Blue Tone Detection
```csharp
private bool IsBlueTone(Color color)
{
    return color.B > color.R && color.B > color.G && color.B > 100;
}
```

#### Dark Blue Tone Detection
```csharp
private bool IsDarkBlueTone(Color color)
{
    return color.B > color.R && color.B > color.G && color.B < 100;
}
```

### 4. Fallback Icon Generation
When theme-specific icons are unavailable, the system generates custom drawn icons:

```csharp
private Image? GetDrawnIcon(SystemMenuIconType iconType)
{
    const int iconSize = 16;
    var bitmap = new Bitmap(iconSize, iconSize);

    using (var graphics = Graphics.FromImage(bitmap))
    {
        graphics.SmoothingMode = SmoothingMode.AntiAlias;
        graphics.Clear(Color.Transparent);

        var foregroundColor = GetThemeForegroundColor();
        var backgroundColor = GetThemeBackgroundColor();

        switch (iconType)
        {
            case SystemMenuIconType.Restore:
                DrawRestoreIcon(graphics, iconSize, foregroundColor, backgroundColor);
                break;
            case SystemMenuIconType.Minimize:
                DrawMinimizeIcon(graphics, iconSize, foregroundColor);
                break;
            case SystemMenuIconType.Maximize:
                DrawMaximizeIcon(graphics, iconSize, foregroundColor);
                break;
            case SystemMenuIconType.Close:
                DrawCloseIcon(graphics, iconSize, foregroundColor);
                break;
        }
    }

    return bitmap;
}
```

### 5. Custom Icon Drawing
The system includes custom drawing methods for each icon type:

#### Restore Icon
```csharp
private void DrawRestoreIcon(Graphics graphics, int size, Color foregroundColor, Color backgroundColor)
{
    var pen = new Pen(foregroundColor, 1);
    var brush = new SolidBrush(backgroundColor);

    // Draw the main square
    var rect = new Rectangle(2, 2, size - 4, size - 4);
    graphics.FillRectangle(brush, rect);
    graphics.DrawRectangle(pen, rect);

    // Draw the arrow pointing to the square
    var arrowPoints = new Point[]
    {
        new Point(size - 6, 4),
        new Point(size - 6, size - 6),
        new Point(4, size - 6)
    };
    graphics.FillPolygon(brush, arrowPoints);
    graphics.DrawPolygon(pen, arrowPoints);

    pen.Dispose();
    brush.Dispose();
}
```

#### Minimize Icon
```csharp
private void DrawMinimizeIcon(Graphics graphics, int size, Color foregroundColor)
{
    var pen = new Pen(foregroundColor, 2);
    var y = size / 2;
    graphics.DrawLine(pen, 3, y, size - 3, y);
    pen.Dispose();
}
```

#### Maximize Icon
```csharp
private void DrawMaximizeIcon(Graphics graphics, int size, Color foregroundColor)
{
    var pen = new Pen(foregroundColor, 1);
    var rect = new Rectangle(2, 2, size - 4, size - 4);
    graphics.DrawRectangle(pen, rect);
    pen.Dispose();
}
```

#### Close Icon
```csharp
private void DrawCloseIcon(Graphics graphics, int size, Color foregroundColor)
{
    var pen = new Pen(foregroundColor, 2);
    graphics.DrawLine(pen, 3, 3, size - 3, size - 3);
    graphics.DrawLine(pen, 3, size - 3, size - 3, 3);
    pen.Dispose();
}
```

## Theme Integration

### 1. Palette Integration
The system integrates deeply with the Krypton palette system:

```csharp
private Color GetThemeForegroundColor()
{
    var palette = _form.GetResolvedPalette();
    if (palette != null)
    {
        return palette.GetContentShortTextColor1(PaletteContentStyle.HeaderForm, PaletteState.Normal);
    }
    return Color.Black; // fallback
}

private Color GetThemeBackgroundColor()
{
    var palette = _form.GetResolvedPalette();
    if (palette != null)
    {
        return palette.GetBackColor1(PaletteBackStyle.HeaderForm, PaletteState.Normal);
    }
    return Color.White; // fallback
}
```

### 2. Theme Change Handling
```csharp
public void RefreshThemeIcons()
{
    RefreshIcons();
}

public void SetIconTheme(string themeName)
{
    if (string.IsNullOrEmpty(themeName))
    {
        return;
    }
    RefreshIcons();
}

public void SetThemeType(ThemeType themeType)
{
    string themeName = themeType switch
    {
        ThemeType.Black => "Office2013",
        ThemeType.Blue => "Office2010",
        ThemeType.Silver => "Office2013",
        ThemeType.DarkBlue => "Office2010",
        ThemeType.LightBlue => "Office2010",
        ThemeType.WarmSilver => "Office2013",
        ThemeType.ClassicSilver => "Office2007",
        _ => "Office2013"
    };
    SetIconTheme(themeName);
}
```

## Positioning and Display

### 1. Smart Positioning
The system includes intelligent positioning logic to ensure menus stay within screen bounds:

```csharp
private Point AdjustMenuPosition(Point originalLocation)
{
    var screenBounds = Screen.FromControl(_form).Bounds;
    var estimatedMenuWidth = 200;
    var estimatedMenuHeight = _contextMenu.Items.Count * 25;

    // Check if menu would go off the right edge
    if (originalLocation.X + estimatedMenuWidth > screenBounds.Right)
    {
        originalLocation.X = screenBounds.Right - estimatedMenuWidth;
    }

    // Check if menu would go off the bottom edge
    if (originalLocation.Y + estimatedMenuHeight > screenBounds.Bottom)
    {
        originalLocation.Y = screenBounds.Bottom - estimatedMenuHeight;
    }

    // Ensure menu doesn't go off the left or top edges
    if (originalLocation.X < screenBounds.Left)
    {
        originalLocation.X = screenBounds.Left;
    }

    if (originalLocation.Y < screenBounds.Top)
    {
        originalLocation.Y = screenBounds.Top;
    }

    return originalLocation;
}
```

### 2. Multiple Display Methods
- **Show(Point)**: Show at specific screen coordinates
- **ShowAtFormTopLeft()**: Show at form's top-left corner (native behavior)
- **Automatic positioning**: Adjusts position to stay within screen bounds

### 3. Screen Awareness
```csharp
public void Show(Point screenLocation)
{
    if (Enabled && _contextMenu.Items.Count > 0)
    {
        var adjustedLocation = AdjustMenuPosition(screenLocation);
        _contextMenu.Show(_form, adjustedLocation);
    }
}
```

## State Management

### 1. Form State Integration
The system monitors and responds to form state changes:

```csharp
public void Refresh()
{
    ThrowIfDisposed();
    BuildSystemMenu();
    UpdateMenuItemsState();
    RefreshIcons();
}
```

### 2. Property-Based State Management
Menu items are enabled/disabled based on form properties:

| Form Property | Affects | Logic |
|---------------|---------|-------|
| `MinimizeBox` | Minimize item | Must be true to enable minimize |
| `MaximizeBox` | Maximize item | Must be true to enable maximize |
| `ControlBox` | Close item | Must be true to show close |
| `FormBorderStyle` | Move/Size items | Must be resizable to show move/size |
| `WindowState` | All items | Current state affects availability |

### 3. Dynamic State Updates
```csharp
private void UpdateMenuItemsState()
{
    var windowState = _form.GetWindowState();

    // Update each menu item based on current state
    if (_menuItemRestore != null) 
    {
        _menuItemRestore.Enabled = (windowState != FormWindowState.Normal);
    }
    // ... other items
}
```

## Event Handling

### 1. Menu Item Click Events
Each menu item has dedicated event handlers:

```csharp
private void OnRestoreItemOnClick(object? sender, EventArgs e) => ExecuteRestore();
private void OnMinimizeItemOnClick(object? sender, EventArgs e) => ExecuteMinimize();
private void OnMaximizeItemOnClick(object? sender, EventArgs e) => ExecuteMaximize();
private void OnCloseItemOnClick(object? sender, EventArgs e) => ExecuteClose();
```

### 2. Action Execution
Each action is implemented with proper fallback mechanisms:

#### Restore Action
```csharp
private void ExecuteRestore()
{
    try
    {
        if (_form.WindowState != FormWindowState.Normal)
        {
            _form.WindowState = FormWindowState.Normal;
        }
        else
        {
            SendSysCommand(PI.SC_.RESTORE);
        }
    }
    catch
    {
        SendSysCommand(PI.SC_.RESTORE);
    }
}
```

#### Move Action
```csharp
private void ExecuteMove()
{
    try
    {
        SendSysCommand(PI.SC_.MOVE);
    }
    catch
    {
        SendSysCommand(PI.SC_.MOVE);
    }
}
```

#### Size Action
```csharp
private void ExecuteSize()
{
    try
    {
        SendSysCommand(PI.SC_.SIZE);
    }
    catch
    {
        SendSysCommand(PI.SC_.SIZE);
    }
}
```

### 3. System Command Integration
```csharp
private void SendSysCommand(PI.SC_ command)
{
    var screenPos = Control.MousePosition;
    var lParam = (IntPtr)(PI.MAKELOWORD(screenPos.X) | PI.MAKEHIWORD(screenPos.Y));
    _form.SendSysCommand(command, lParam);
}
```

## Performance Features

### 1. Efficient Resource Management
- **Direct Field References**: Uses direct field references for menu items instead of searching collections
- **Icon Caching**: Icons are cached and only regenerated when themes change
- **Lazy Loading**: Menu items are created only when needed
- **Memory Management**: Proper disposal of graphics resources

### 2. Optimized State Updates
```csharp
private void UpdateMenuItemsState()
{
    // Direct field access for performance
    if (_menuItemRestore != null) 
    {
        _menuItemRestore.Enabled = (windowState != FormWindowState.Normal);
    }
    // ... efficient updates
}
```

### 3. Smart Refresh Logic
```csharp
public void Refresh()
{
    ThrowIfDisposed();
    BuildSystemMenu();        // Rebuild structure
    UpdateMenuItemsState();   // Update states
    RefreshIcons();          // Update icons
}
```

## Error Handling

### 1. Comprehensive Exception Handling
```csharp
private void BuildSystemMenu()
{
    try
    {
        _contextMenu.Items.Clear();
        CreateBasicMenuItems();
    }
    catch (Exception ex)
    {
        Debug.WriteLine($"Error building system menu: {ex.Message}");
        
        if (_contextMenu.Items.Count == 0)
        {
            CreateBasicMenuItems();
        }
    }
}
```

### 2. Graceful Degradation
```csharp
private Image? GetSystemMenuIcon(SystemMenuIconType iconType)
{
    try
    {
        var currentTheme = GetCurrentTheme();
        var icon = GetThemeIcon(currentTheme, iconType);
        if (icon != null)
        {
            var processedIcon = ProcessImageForTransparency(icon);
            if (processedIcon != null)
            {
                return processedIcon;
            }
        }
        return GetDrawnIcon(iconType);
    }
    catch
    {
        return null; // Graceful fallback
    }
}
```

### 3. Disposal Safety
```csharp
public void Show(Point screenLocation)
{
    ThrowIfDisposed();
    if (Enabled && _contextMenu.Items.Count > 0)
    {
        var adjustedLocation = AdjustMenuPosition(screenLocation);
        _contextMenu.Show(_form, adjustedLocation);
    }
}

private void ThrowIfDisposed()
{
    if (_disposed)
    {
        throw new ObjectDisposedException(nameof(KryptonSystemMenu));
    }
}
```

## Resource Management

### 1. IDisposable Implementation
```csharp
public void Dispose()
{
    Dispose(true);
    GC.SuppressFinalize(this);
}

protected virtual void Dispose(bool disposing)
{
    if (!_disposed)
    {
        if (disposing)
        {
            _contextMenu.Dispose();
        }
        _disposed = true;
    }
}

~KryptonSystemMenu()
{
    Dispose(false);
}
```

### 2. Graphics Resource Management
```csharp
private void DrawRestoreIcon(Graphics graphics, int size, Color foregroundColor, Color backgroundColor)
{
    var pen = new Pen(foregroundColor, 1);
    var brush = new SolidBrush(backgroundColor);

    try
    {
        // Drawing operations
        var rect = new Rectangle(2, 2, size - 4, size - 4);
        graphics.FillRectangle(brush, rect);
        graphics.DrawRectangle(pen, rect);
        // ... more drawing
    }
    finally
    {
        pen.Dispose();
        brush.Dispose();
    }
}
```

### 3. Image Processing
```csharp
private Image? ProcessImageForTransparency(Image? originalImage)
{
    if (originalImage == null)
    {
        return null;
    }

    try
    {
        if (originalImage.PixelFormat == PixelFormat.Format32bppArgb)
        {
            return originalImage; // Already in correct format
        }

        var bitmap = new Bitmap(originalImage.Width, originalImage.Height, PixelFormat.Format32bppArgb);
        using (var graphics = Graphics.FromImage(bitmap))
        {
            graphics.Clear(Color.Transparent);
            graphics.DrawImage(originalImage, 0, 0);
        }
        return bitmap;
    }
    catch (Exception ex)
    {
        Debug.WriteLine($"Failed to process image transparency: {ex.Message}");
        return originalImage;
    }
}
```

## Advanced Features

### 1. Keyboard Shortcut Handling
```csharp
public bool HandleKeyboardShortcut(Keys keyData)
{
    ThrowIfDisposed();
    if (!Enabled)
    {
        return false;
    }

    // Handle Alt+F4 for Close
    if (keyData == (Keys.Alt | Keys.F4))
    {
        ExecuteClose();
        return true;
    }

    // Handle Alt+Space for showing the menu
    if (keyData == (Keys.Alt | Keys.Space) && ShowOnAltSpace)
    {
        ShowAtFormTopLeft();
        return true;
    }

    return false;
}
```

### 2. Icon Type Detection
```csharp
private SystemMenuIconType? GetIconTypeFromText(string text)
{
    if (string.IsNullOrEmpty(text))
    {
        return null;
    }

    var normalizedText = text.ToLowerInvariant().Trim();

    if (normalizedText.StartsWith(KryptonManager.Strings.SystemMenuStrings.Restore.ToLower()))
    {
        return SystemMenuIconType.Restore;
    }
    // ... other types
    return null;
}
```

### 3. Theme Resource Management
```csharp
private Image? GetOffice2013Icon(SystemMenuIconType iconType)
{
    try
    {
        switch (iconType)
        {
            case SystemMenuIconType.Restore:
                return SystemMenuImageResources.Microsoft365SystemMenuRestoreNormalSmall;
            case SystemMenuIconType.Minimize:
                return SystemMenuImageResources.Microsoft365SystemMenuMinimiseNormalSmall;
            case SystemMenuIconType.Maximize:
                return SystemMenuImageResources.Microsoft365SystemMenuMaximiseNormalSmall;
            case SystemMenuIconType.Close:
                return SystemMenuImageResources.Microsoft365SystemMenuCloseNormalSmall;
            default:
                return null;
        }
    }
    catch
    {
        return null;
    }
}
```

### 4. Multi-Screen Support
The positioning system is aware of multiple screens and adjusts menu position accordingly:

```csharp
private Point AdjustMenuPosition(Point originalLocation)
{
    var screenBounds = Screen.FromControl(_form).Bounds;
    // ... positioning logic that respects screen boundaries
}
```

## Configuration Options

### 1. Behavior Configuration
- `Enabled`: Enable/disable the entire system menu
- `ShowOnLeftClick`: Control left-click behavior
- `ShowOnRightClick`: Control right-click behavior  
- `ShowOnAltSpace`: Control Alt+Space behavior

### 2. Theme Configuration
- `CurrentIconTheme`: Get current theme name
- `SetIconTheme(string)`: Set specific theme
- `SetThemeType(ThemeType)`: Set theme by type
- `RefreshThemeIcons()`: Force icon refresh

### 3. State Configuration
- `MenuItemCount`: Get number of menu items
- `HasMenuItems`: Check if menu has items
- `Refresh()`: Force complete refresh

## Integration Points

### 1. KryptonForm Integration
- Direct integration through form properties
- Automatic state synchronization
- Theme inheritance from form palette

### 2. KryptonContextMenu Integration
- Built on top of KryptonContextMenu
- Inherits all context menu features
- Consistent theming and behavior

### 3. Palette System Integration
- Automatic theme detection
- Color-based theme selection
- Dynamic icon adaptation

This comprehensive feature reference covers all aspects of the KryptonSystemMenu implementation, from basic functionality to advanced features and performance optimizations.
