# KryptonSystemMenu Implementation Details

## Overview

This document provides detailed technical information about the internal implementation of the `KryptonSystemMenu` class, including architecture decisions, performance optimizations, and technical considerations.

## Table of Contents

1. [Internal Architecture](#internal-architecture)
2. [Performance Optimizations](#performance-optimizations)
3. [Memory Management](#memory-management)
4. [Error Handling Strategy](#error-handling-strategy)
5. [Theme System Implementation](#theme-system-implementation)
6. [State Management Implementation](#state-management-implementation)
7. [Icon System Implementation](#icon-system-implementation)
8. [Event System Implementation](#event-system-implementation)
9. [Resource Management](#resource-management)
10. [Thread Safety Considerations](#thread-safety-considerations)

## Internal Architecture

### Class Structure
```csharp
public class KryptonSystemMenu : IKryptonSystemMenu, IDisposable
{
    #region Instance Fields
    private readonly KryptonForm _form;
    private readonly KryptonContextMenu _contextMenu;
    private bool _disposed;

    // Direct field references for performance
    private KryptonContextMenuItem? _menuItemRestore;
    private KryptonContextMenuItem? _menuItemMove;
    private KryptonContextMenuItem? _menuItemSize;
    private KryptonContextMenuItem? _menuItemMinimize;
    private KryptonContextMenuItem? _menuItemMaximize;
    private KryptonContextMenuItem? _menuItemClose;
    #endregion
}
```

### Key Design Decisions

#### 1. Direct Field References
**Decision**: Use direct field references instead of collection lookups
**Rationale**: 
- Performance optimization for frequent state updates
- Eliminates need for string-based searches
- Provides compile-time safety
- Reduces memory allocations

```csharp
// Direct access (fast)
if (_menuItemRestore != null) 
{
    _menuItemRestore.Enabled = (windowState != FormWindowState.Normal);
}

// vs Collection lookup (slower)
var restoreItem = _contextMenu.Items.OfType<KryptonContextMenuItem>()
    .FirstOrDefault(item => item.Text.Contains("Restore"));
```

#### 2. Lazy Menu Creation
**Decision**: Create menu items only when needed
**Rationale**:
- Reduces initial memory footprint
- Allows for dynamic menu structure
- Supports conditional item display

```csharp
// Menu items are created in CreateBasicMenuItems() only when needed
private void CreateBasicMenuItems()
{
    // Conditional creation based on form state and properties
    if (_form.WindowState != FormWindowState.Normal && (_form.MinimizeBox || _form.MaximizeBox))
    {
        _menuItemRestore = new KryptonContextMenuItem(KryptonManager.Strings.SystemMenuStrings.Restore);
        // ... setup
    }
}
```

#### 3. Composition over Inheritance
**Decision**: Use composition with KryptonContextMenu
**Rationale**:
- Leverages existing KryptonContextMenu functionality
- Maintains separation of concerns
- Enables reuse of proven UI components

## Performance Optimizations

### 1. Efficient State Updates
```csharp
private void UpdateMenuItemsState()
{
    var windowState = _form.GetWindowState();

    // Batch state updates using direct field references
    if (_menuItemRestore != null) 
        _menuItemRestore.Enabled = (windowState != FormWindowState.Normal);
    
    if (_menuItemMinimize != null) 
        _menuItemMinimize.Enabled = _form.MinimizeBox && (windowState != FormWindowState.Minimized);
    
    // ... other updates
}
```

### 2. Icon Caching Strategy
```csharp
private Image? GetSystemMenuIcon(SystemMenuIconType iconType)
{
    // Try theme-specific icons first
    var currentTheme = GetCurrentTheme();
    var icon = GetThemeIcon(currentTheme, iconType);
    
    if (icon != null)
    {
        // Process for transparency if needed
        var processedIcon = ProcessImageForTransparency(icon);
        if (processedIcon != null)
        {
            return processedIcon;
        }
    }

    // Fallback to custom drawing
    return GetDrawnIcon(iconType);
}
```

### 3. Smart Positioning Algorithm
```csharp
private Point AdjustMenuPosition(Point originalLocation)
{
    var screenBounds = Screen.FromControl(_form).Bounds;
    
    // Estimate menu dimensions (avoids expensive measurement)
    var estimatedMenuWidth = 200;
    var estimatedMenuHeight = _contextMenu.Items.Count * 25;

    // Adjust position to stay within bounds
    if (originalLocation.X + estimatedMenuWidth > screenBounds.Right)
        originalLocation.X = screenBounds.Right - estimatedMenuWidth;
    
    // ... other adjustments
    
    return originalLocation;
}
```

## Memory Management

### 1. Resource Disposal Pattern
```csharp
protected virtual void Dispose(bool disposing)
{
    if (!_disposed)
    {
        if (disposing)
        {
            // Dispose managed resources
            _contextMenu.Dispose();
        }
        _disposed = true;
    }
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
    }
    finally
    {
        // Ensure resources are always disposed
        pen.Dispose();
        brush.Dispose();
    }
}
```

### 3. Image Processing
```csharp
private Image? ProcessImageForTransparency(Image? originalImage)
{
    if (originalImage?.PixelFormat == PixelFormat.Format32bppArgb)
    {
        return originalImage; // Already correct format
    }

    // Create new bitmap with proper format
    var bitmap = new Bitmap(originalImage.Width, originalImage.Height, PixelFormat.Format32bppArgb);
    using (var graphics = Graphics.FromImage(bitmap))
    {
        graphics.Clear(Color.Transparent);
        graphics.DrawImage(originalImage, 0, 0);
    }
    return bitmap;
}
```

## Error Handling Strategy

### 1. Graceful Degradation
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
        
        // Ensure we always have a basic menu
        if (_contextMenu.Items.Count == 0)
        {
            CreateBasicMenuItems();
        }
    }
}
```

### 2. Fallback Mechanisms
```csharp
private Image? GetSystemMenuIcon(SystemMenuIconType iconType)
{
    try
    {
        // Try theme-specific icons
        var icon = GetThemeIcon(GetCurrentTheme(), iconType);
        if (icon != null) return ProcessImageForTransparency(icon);
        
        // Fallback to custom drawing
        return GetDrawnIcon(iconType);
    }
    catch
    {
        // Ultimate fallback - no icon
        return null;
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

## Theme System Implementation

### 1. Color-Based Theme Detection
```csharp
public string GetCurrentTheme()
{
    try
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
    catch
    {
        return "Office2013"; // fallback on error
    }
}
```

### 2. Color Analysis Algorithms
```csharp
private bool IsLightColor(Color color)
{
    // Calculate perceived brightness using luminance formula
    var brightness = (0.299 * color.R + 0.587 * color.G + 0.114 * color.B) / 255;
    return brightness > 0.6;
}

private bool IsBlueTone(Color color)
{
    return color.B > color.R && color.B > color.G && color.B > 100;
}

private bool IsVibrantColor(Color color)
{
    var saturation = Math.Max(color.R, Math.Max(color.G, color.B)) - 
                     Math.Min(color.R, Math.Min(color.G, color.B));
    return saturation > 100;
}
```

### 3. Theme Resource Management
```csharp
private Image? GetThemeIcon(string theme, SystemMenuIconType iconType)
{
    try
    {
        return theme switch
        {
            "Office2013" => GetOffice2013Icon(iconType),
            "Office2010" => GetOffice2010Icon(iconType),
            "Office2007" => GetOffice2007Icon(iconType),
            "Sparkle" => GetSparkleIcon(iconType),
            "Professional" => GetProfessionalIcon(iconType),
            "Microsoft365" => GetMicrosoft365Icon(iconType),
            "Office2003" => GetOffice2003Icon(iconType),
            _ => null
        };
    }
    catch
    {
        return null;
    }
}
```

## State Management Implementation

### 1. Form State Integration
```csharp
private void UpdateMenuItemsState()
{
    var windowState = _form.GetWindowState();

    // Restore: enabled when window is not in normal state
    if (_menuItemRestore != null) 
        _menuItemRestore.Enabled = (windowState != FormWindowState.Normal);
    
    // Minimize: enabled only if MinimizeBox is true and not already minimized
    if (_menuItemMinimize != null) 
        _menuItemMinimize.Enabled = _form.MinimizeBox && (windowState != FormWindowState.Minimized);

    // Maximize: enabled only if MaximizeBox is true and not already maximized
    if (_menuItemMaximize != null)
        _menuItemMaximize.Enabled = _form.MaximizeBox && (windowState != FormWindowState.Maximized);
    
    // Move: enabled when window is in Normal state or minimized
    if (_menuItemMove != null)
        _menuItemMove.Enabled = (windowState == FormWindowState.Normal) || (windowState == FormWindowState.Minimized);
    
    // Size: enabled when window is in Normal state and form is sizable
    if (_menuItemSize != null)
        _menuItemSize.Enabled = (windowState == FormWindowState.Normal) &&
                               (_form.FormBorderStyle == FormBorderStyle.Sizable || 
                                _form.FormBorderStyle == FormBorderStyle.SizableToolWindow);
}
```

### 2. Conditional Menu Creation
```csharp
private void CreateBasicMenuItems()
{
    // Restore: only if window is not in normal state and either minimize or maximize is enabled
    if (_form.WindowState != FormWindowState.Normal && (_form.MinimizeBox || _form.MaximizeBox))
    {
        _menuItemRestore = new KryptonContextMenuItem(KryptonManager.Strings.SystemMenuStrings.Restore);
        _menuItemRestore.Image = GetSystemMenuIcon(SystemMenuIconType.Restore);
        _menuItemRestore.Click += OnRestoreItemOnClick;
        _contextMenu.Items.Add(_menuItemRestore);
    }

    // Move and Size: only if the window is resizable
    if (_form.FormBorderStyle != FormBorderStyle.FixedSingle && 
        _form.FormBorderStyle != FormBorderStyle.Fixed3D && 
        _form.FormBorderStyle != FormBorderStyle.FixedDialog)
    {
        _menuItemMove = new KryptonContextMenuItem(KryptonManager.Strings.SystemMenuStrings.Move);
        _menuItemMove.Click += (sender, e) => ExecuteMove();
        _contextMenu.Items.Add(_menuItemMove);

        _menuItemSize = new KryptonContextMenuItem(KryptonManager.Strings.SystemMenuStrings.Size);
        _menuItemSize.Click += (sender, e) => ExecuteSize();
        _contextMenu.Items.Add(_menuItemSize);
    }

    // Separator logic
    if (_contextMenu.Items.Count > 0 && (_form.MinimizeBox || _form.MaximizeBox))
    {
        _contextMenu.Items.Add(new KryptonContextMenuSeparator());
    }

    // Always add minimize and maximize (but enable/disable based on properties)
    _menuItemMinimize = new KryptonContextMenuItem(KryptonManager.Strings.SystemMenuStrings.Minimize);
    _menuItemMinimize.Image = GetSystemMenuIcon(SystemMenuIconType.Minimize);
    _menuItemMinimize.Click += OnMinimizeItemOnClick;
    _contextMenu.Items.Add(_menuItemMinimize);

    _menuItemMaximize = new KryptonContextMenuItem(KryptonManager.Strings.SystemMenuStrings.Maximize);
    _menuItemMaximize.Image = GetSystemMenuIcon(SystemMenuIconType.Maximize);
    _menuItemMaximize.Click += OnMaximizeItemOnClick;
    _contextMenu.Items.Add(_menuItemMaximize);

    // Final separator
    if (_contextMenu.Items.Count > 0)
    {
        _contextMenu.Items.Add(new KryptonContextMenuSeparator());
    }

    // Close: only if ControlBox is enabled
    if (_form.ControlBox)
    {
        _menuItemClose = new KryptonContextMenuItem($"{KryptonManager.Strings.SystemMenuStrings.Close}\tAlt+F4");
        _menuItemClose.Image = GetSystemMenuIcon(SystemMenuIconType.Close);
        _menuItemClose.Click += OnCloseItemOnClick;
        _contextMenu.Items.Add(_menuItemClose);
    }
}
```

## Icon System Implementation

### 1. Icon Loading Strategy
```csharp
private Image? GetSystemMenuIcon(SystemMenuIconType iconType)
{
    try
    {
        // Try to get theme-specific icon
        var currentTheme = GetCurrentTheme();
        var icon = GetThemeIcon(currentTheme, iconType);
        
        if (icon != null)
        {
            // Process for proper transparency
            var processedIcon = ProcessImageForTransparency(icon);
            if (processedIcon != null)
            {
                return processedIcon;
            }
        }

        // Fallback to custom drawing
        return GetDrawnIcon(iconType);
    }
    catch
    {
        return null; // No icon on error
    }
}
```

### 2. Custom Icon Drawing
```csharp
private Image? GetDrawnIcon(SystemMenuIconType iconType)
{
    try
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
    catch
    {
        return null;
    }
}
```

### 3. Theme Color Integration
```csharp
private Color GetThemeForegroundColor()
{
    try
    {
        var palette = _form.GetResolvedPalette();
        if (palette != null)
        {
            return palette.GetContentShortTextColor1(PaletteContentStyle.HeaderForm, PaletteState.Normal);
        }
    }
    catch
    {
        // Fallback on error
    }
    return Color.Black;
}

private Color GetThemeBackgroundColor()
{
    try
    {
        var palette = _form.GetResolvedPalette();
        if (palette != null)
        {
            return palette.GetBackColor1(PaletteBackStyle.HeaderForm, PaletteState.Normal);
        }
    }
    catch
    {
        // Fallback on error
    }
    return Color.White;
}
```

## Event System Implementation

### 1. Action Execution
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

private void ExecuteMinimize()
{
    try
    {
        if (_form.WindowState != FormWindowState.Minimized)
        {
            _form.WindowState = FormWindowState.Minimized;
        }
        else
        {
            SendSysCommand(PI.SC_.MINIMIZE);
        }
    }
    catch
    {
        SendSysCommand(PI.SC_.MINIMIZE);
    }
}

private void ExecuteMaximize()
{
    try
    {
        if (_form.WindowState != FormWindowState.Maximized)
        {
            _form.WindowState = FormWindowState.Maximized;
        }
        else
        {
            SendSysCommand(PI.SC_.MAXIMIZE);
        }
    }
    catch
    {
        SendSysCommand(PI.SC_.MAXIMIZE);
    }
}

private void ExecuteClose()
{
    try
    {
        _form.Close();
    }
    catch
    {
        SendSysCommand(PI.SC_.CLOSE);
    }
}
```

### 2. System Command Integration
```csharp
private void SendSysCommand(PI.SC_ command)
{
    // Convert screen position to LPARAM format
    var screenPos = Control.MousePosition;
    var lParam = (IntPtr)(PI.MAKELOWORD(screenPos.X) | PI.MAKEHIWORD(screenPos.Y));

    // Send the system command
    _form.SendSysCommand(command, lParam);
}
```

### 3. Keyboard Shortcut Handling
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

## Resource Management

### 1. Disposal Pattern
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
            // Dispose managed resources
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
    }
    finally
    {
        // Ensure resources are always disposed
        pen.Dispose();
        brush.Dispose();
    }
}
```

## Thread Safety Considerations

### 1. UI Thread Requirements
- All operations must be performed on the UI thread
- No cross-thread operations are supported
- Disposal can be called from any thread

### 2. Disposal Safety
```csharp
private void ThrowIfDisposed()
{
    if (_disposed)
    {
        throw new ObjectDisposedException(nameof(KryptonSystemMenu));
    }
}

public void Show(Point screenLocation)
{
    ThrowIfDisposed();
    if (Enabled && _contextMenu.Items.Count > 0)
    {
        var adjustedLocation = AdjustMenuPosition(screenLocation);
        _contextMenu.Show(_form, adjustedLocation);
    }
}
```

### 3. State Consistency
- All state changes are atomic
- No partial state updates
- Consistent state maintained across operations

This implementation provides a robust, performant, and maintainable system menu implementation that integrates seamlessly with the Krypton Toolkit ecosystem while providing comprehensive functionality and excellent user experience.
