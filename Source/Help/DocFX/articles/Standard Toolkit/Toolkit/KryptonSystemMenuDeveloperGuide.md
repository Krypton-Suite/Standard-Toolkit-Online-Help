# `KryptonSystemMenu`

## Overview

The `KryptonSystemMenu` class provides a themed system menu that replaces the native Windows system menu with a `KryptonContextMenu`. This allows for consistent theming and enhanced functionality while maintaining compatibility with standard Windows system menu behavior.

## Table of Contents

1. [Features](#features)
2. [Architecture](#architecture)
3. [Getting Started](#getting-started)
4. [API Reference](#api-reference)
5. [Theming and Icons](#theming-and-icons)
6. [Event Handling](#event-handling)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Examples](#examples)
10. [Complete Features Reference](#complete-features-reference)

## Complete Features Reference

For comprehensive information about all features, implementation details, and advanced capabilities, see the [KryptonSystemMenu Complete Features Reference](./KryptonSystemMenuFeaturesReference.md) document.

## Features

### Core Functionality
- **Themed System Menu**: Complete replacement of native Windows system menu with Krypton-themed context menu
- **Standard Menu Items**: Full support for Restore, Move, Size, Minimize, Maximize, and Close operations
- **Dynamic State Management**: Intelligent enable/disable logic based on form state and properties
- **Keyboard Shortcuts**: Native-like support for Alt+F4 (Close) and Alt+Space (Show menu)
- **Icon Integration**: Comprehensive themed icon system with automatic adaptation

### Advanced Features
- **Multi-Theme Icon Support**: 8 supported themes (Office 2013, 2010, 2007, Sparkle, Professional, Microsoft 365, Office 2003, Material)
- **Fallback Icon Generation**: Custom-drawn icons when theme-specific resources are unavailable
- **Smart Positioning**: Intelligent menu positioning with screen bounds awareness
- **Form State Integration**: Deep integration with form properties (MinimizeBox, MaximizeBox, ControlBox, FormBorderStyle)
- **Performance Optimization**: Efficient resource management with direct field references
- **Error Handling**: Comprehensive exception handling with graceful degradation
- **Resource Management**: Proper disposal patterns and memory management

### Technical Features
- **Palette Integration**: Automatic theme detection based on form palette colors
- **Multi-Screen Support**: Screen-aware positioning for multi-monitor setups
- **State Synchronization**: Real-time synchronization with form state changes
- **Icon Caching**: Performance-optimized icon loading and caching
- **Custom Drawing**: Fallback icon generation with theme-appropriate colors
- **Event Handling**: Complete event system for menu interactions
- **Thread Safety**: UI-thread-safe implementation with proper disposal patterns

## Architecture

### Class Hierarchy

```cs
KryptonSystemMenu : IKryptonSystemMenu, IDisposable
```

### Key Components
- **KryptonContextMenu**: The underlying menu container
- **Menu Item References**: Direct field references for efficient state management
- **Icon Management System**: Handles theme-specific icon loading and fallback generation
- **State Management**: Updates menu item states based on form properties

### Dependencies
- `KryptonForm`: Required form type for integration
- `KryptonContextMenu`: Core menu functionality
- `SystemMenuImageResources`: Icon resources for different themes

## Getting Started

### Basic Usage

```csharp
// Create a KryptonSystemMenu instance
var systemMenu = new KryptonSystemMenu(kryptonForm);

// Show the menu at a specific location
systemMenu.Show(new Point(100, 100));

// Show the menu at the form's top-left corner (like native system menu)
systemMenu.ShowAtFormTopLeft();

// Refresh the menu to update states
systemMenu.Refresh();
```

### Integration with KryptonForm

The `KryptonSystemMenu` is typically integrated through the `KryptonForm.KryptonSystemMenu` property:

```csharp
// Access the system menu from a KryptonForm
var systemMenu = myKryptonForm.KryptonSystemMenu;

if (systemMenu != null)
{
    // Custom menu items are not supported in this version
    systemMenu.Refresh();
}
```

## API Reference

### Public Properties

#### `ContextMenu`
```csharp
public KryptonContextMenu ContextMenu { get; }
```
Gets the underlying themed context menu. This property is read-only and provides access to the menu for advanced customization.

#### `Enabled`
```csharp
public bool Enabled { get; set; }
```
Gets or sets whether the themed system menu is enabled. When disabled, the menu will not respond to show requests.

#### `MenuItemCount`
```csharp
public int MenuItemCount { get; }
```
Gets the number of items currently in the themed system menu.

#### `HasMenuItems`
```csharp
public bool HasMenuItems { get; }
```
Gets whether the themed system menu contains any items.

#### `ShowOnLeftClick`
```csharp
public bool ShowOnLeftClick { get; set; }
```
Gets or sets whether left-click on title bar shows the themed system menu.

#### `ShowOnRightClick`
```csharp
public bool ShowOnRightClick { get; set; }
```
Gets or sets whether right-click on title bar shows the themed system menu.

#### `ShowOnAltSpace`
```csharp
public bool ShowOnAltSpace { get; set; }
```
Gets or sets whether Alt+Space shows the themed system menu.

#### `CurrentIconTheme`
```csharp
public string CurrentIconTheme { get; }
```
Gets the current theme name being used for system menu icons.

### Public Methods

#### `Show(Point screenLocation)`
```csharp
public void Show(Point screenLocation)
```
Shows the themed system menu at the specified screen location. The position is automatically adjusted to ensure the menu stays within screen bounds.

**Parameters:**
- `screenLocation`: The screen coordinates where to show the menu.

#### `ShowAtFormTopLeft()`
```csharp
public void ShowAtFormTopLeft()
```
Shows the themed system menu at the top-left corner of the form, mimicking the native system menu behavior.

#### `Refresh()`
```csharp
public void Refresh()
```
Refreshes the system menu items based on current form state. This method:
- Rebuilds the menu structure
- Updates menu item states (enabled/disabled)
- Refreshes icons to match current theme

#### `HandleKeyboardShortcut(Keys keyData)`
```csharp
public bool HandleKeyboardShortcut(Keys keyData)
```
Handles keyboard shortcuts for system menu actions.

**Parameters:**
- `keyData`: The key combination pressed.

**Returns:** `true` if the shortcut was handled; otherwise `false`.

**Supported Shortcuts:**
- `Alt+F4`: Close the form
- `Alt+Space`: Show the system menu (if enabled)

#### `GetCurrentTheme()`
```csharp
public string GetCurrentTheme()
```
Determines the current theme based on the form's palette.

**Returns:** The current theme name.

#### `RefreshThemeIcons()`
```csharp
public void RefreshThemeIcons()
```
Manually refreshes all icons to match the current theme. Call this method when the application theme changes.

#### `SetIconTheme(string themeName)`
```csharp
public void SetIconTheme(string themeName)
```
Manually sets the theme for icon selection.

**Parameters:**
- `themeName`: The theme name to use for icons.

#### `SetThemeType(ThemeType themeType)`
```csharp
public void SetThemeType(ThemeType themeType)
```
Sets the theme based on specific theme types.

**Parameters:**
- `themeType`: The theme type to use (Black, Blue, Silver, etc.).

### Constructor

#### `KryptonSystemMenu(KryptonForm form)`
```csharp
public KryptonSystemMenu(KryptonForm form)
```
Initializes a new instance of the KryptonSystemMenu class.

**Parameters:**
- `form`: The KryptonForm to attach the themed system menu to.

**Exceptions:**
- `ArgumentNullException`: Thrown when `form` is null.

## Theming and Icons

### Supported Themes

The `KryptonSystemMenu` supports 7 comprehensive themes for icons, each with distinct visual characteristics:

| Theme | Description | Visual Style | Use Case |
|-------|-------------|--------------|----------|
| **Office 2013** | Default modern theme | Clean, flat design with minimal details | Modern applications, default choice |
| **Office 2010** | Classic Office 2010 | Traditional Windows style with subtle gradients | Business applications, classic look |
| **Office 2007** | Office 2007 style | Ribbon-era design with moderate styling | Legacy compatibility, ribbon applications |
| **Sparkle** | Vibrant theme | Bright, colorful with high contrast | Creative applications, eye-catching design |
| **Professional** | Neutral theme | Business-appropriate, conservative styling | Enterprise applications, professional look |
| **Microsoft 365** | Modern Microsoft 365 | Contemporary design with balanced colors | Cloud applications, modern interfaces |
| **Office 2003** | Classic Office 2003 | Legacy Windows style with traditional appearance | Legacy applications, classic Windows look |

### Icon Types

The system supports comprehensive icon types with intelligent fallback mechanisms:

| Icon Type | Description | Visual Representation | Theme Support | Fallback |
|-----------|-------------|----------------------|---------------|----------|
| **Restore** | Restore window to normal size | Square with overlapping arrow | ✅ All themes | ✅ Custom drawn |
| **Minimize** | Minimize window to taskbar | Horizontal line (underscore) | ✅ All themes | ✅ Custom drawn |
| **Maximize** | Maximize window to full screen | Square outline | ✅ All themes | ✅ Custom drawn |
| **Close** | Close the window | X symbol | ✅ All themes | ✅ Custom drawn |
| **Move** | Allow window dragging | Text only (no icon) | ❌ N/A | ❌ N/A |
| **Size** | Allow window resizing | Text only (no icon) | ❌ N/A | ❌ N/A |

### Icon Characteristics
- **Size**: Standard 16x16 pixel icons
- **Format**: 32-bit ARGB with proper transparency support
- **Anti-aliasing**: Smooth rendering with anti-aliasing enabled
- **Color Adaptation**: Icons automatically adapt to current theme colors
- **Transparency**: Full alpha channel support for seamless integration

### Theme Detection

The system automatically detects the current theme based on the form's palette:

```csharp
// Theme detection logic
var palette = _form.GetResolvedPalette();
var headerColor = palette.GetBackColor1(PaletteBackStyle.HeaderForm, PaletteState.Normal);

// Theme selection based on color characteristics
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
```

### Fallback Icon Generation

When theme-specific icons are not available, the system generates custom drawn icons:

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
            // ... other icon types
        }
    }
    
    return bitmap;
}
```

## Event Handling

### Menu Item Click Events

The system menu handles click events for all standard menu items:

```csharp
// Event handlers are automatically wired up
private void OnRestoreItemOnClick(object? sender, EventArgs e) => ExecuteRestore();
private void OnMinimizeItemOnClick(object? sender, EventArgs e) => ExecuteMinimize();
private void OnMaximizeItemOnClick(object? sender, EventArgs e) => ExecuteMaximize();
private void OnCloseItemOnClick(object? sender, EventArgs e) => ExecuteClose();
```

### Action Execution

Each menu item action is executed through dedicated methods:

```csharp
private void ExecuteRestore()
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
```

## Best Practices

### 1. Proper Initialization
Always initialize the `KryptonSystemMenu` with a valid `KryptonForm`:

```csharp
// Good
var systemMenu = new KryptonSystemMenu(myKryptonForm);

// Bad - will throw ArgumentNullException
var systemMenu = new KryptonSystemMenu(null);
```

### 2. Theme Integration
Call `RefreshThemeIcons()` when the application theme changes:

```csharp
// When theme changes
kryptonManager.GlobalPalette = newPalette;
systemMenu.RefreshThemeIcons();
```

### 3. State Management
The system automatically manages menu item states, but you can manually refresh when needed:

```csharp
// Refresh after form state changes
_form.WindowState = FormWindowState.Maximized;
systemMenu.Refresh();
```

### 4. Error Handling
The system includes comprehensive error handling, but you should handle disposal properly:

```csharp
using (var systemMenu = new KryptonSystemMenu(form))
{
    // Use the system menu
    systemMenu.ShowAtFormTopLeft();
} // Automatically disposed
```

### 5. Performance Considerations
- Menu items are created once and reused
- Icons are cached and only regenerated when theme changes
- State updates are efficient using direct field references

## Troubleshooting

### Common Issues

#### Menu Not Showing
**Problem**: Menu doesn't appear when called.

**Solutions**:
1. Check if `Enabled` property is set to `true`
2. Verify the form has menu items: `systemMenu.HasMenuItems`
3. Ensure the form is not disposed

```csharp
if (systemMenu.Enabled && systemMenu.HasMenuItems)
{
    systemMenu.ShowAtFormTopLeft();
}
```

#### Icons Not Displaying
**Problem**: Menu items show without icons.

**Solutions**:
1. Check if icon resources are available
2. Call `RefreshThemeIcons()` after theme changes
3. Verify theme detection is working: `systemMenu.CurrentIconTheme`

```csharp
// Debug theme detection
var currentTheme = systemMenu.CurrentIconTheme;
Debug.WriteLine($"Current theme: {currentTheme}");

// Force icon refresh
systemMenu.RefreshThemeIcons();
```

#### Menu Items Not Responding
**Problem**: Clicking menu items doesn't perform actions.

**Solutions**:
1. Check if the form is in a valid state
2. Verify form properties (MinimizeBox, MaximizeBox, ControlBox)
3. Call `Refresh()` to update menu states

```csharp
// Check form state
Debug.WriteLine($"Window State: {_form.WindowState}");
Debug.WriteLine($"MinimizeBox: {_form.MinimizeBox}");
Debug.WriteLine($"MaximizeBox: {_form.MaximizeBox}");

// Refresh menu
systemMenu.Refresh();
```

### Debug Information

Enable debug output to troubleshoot issues:

```csharp
// The system includes debug output for errors
Debug.WriteLine($"Error building system menu: {ex.Message}");
```

## Examples

### Example 1: Basic Integration

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;

    public MainForm()
    {
        InitializeComponent();
        
        // Initialize system menu
        _systemMenu = new KryptonSystemMenu(this);
    }

    private void MainForm_Load(object sender, EventArgs e)
    {
        // Show system menu on Alt+Space
        if (_systemMenu != null)
        {
            _systemMenu.ShowOnAltSpace = true;
        }
    }

    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        // Handle system menu shortcuts
        if (_systemMenu?.HandleKeyboardShortcut(keyData) == true)
        {
            return true;
        }
        
        return base.ProcessCmdKey(ref msg, keyData);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _systemMenu?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```

### Example 2: Custom Menu Positioning

```csharp
private void ShowSystemMenuAtCursor()
{
    if (_systemMenu != null && _systemMenu.Enabled)
    {
        // Show menu at current cursor position
        var cursorPos = Cursor.Position;
        _systemMenu.Show(cursorPos);
    }
}

private void ShowSystemMenuAtFormCenter()
{
    if (_systemMenu != null && _systemMenu.Enabled)
    {
        // Calculate form center position
        var formCenter = new Point(
            Location.X + Width / 2,
            Location.Y + Height / 2
        );
        _systemMenu.Show(formCenter);
    }
}
```

### Example 3: Theme Integration

```csharp
private void ChangeTheme(PaletteMode mode)
{
    // Change the global palette
    kryptonManager.GlobalPaletteMode = mode;
    
    // Refresh system menu icons to match new theme
    if (_systemMenu != null)
    {
        _systemMenu.RefreshThemeIcons();
    }
}

private void SetSpecificTheme()
{
    if (_systemMenu != null)
    {
        // Set specific theme type
        _systemMenu.SetThemeType(ThemeType.Office2010Blue);
        
        // Or set specific theme name
        _systemMenu.SetIconTheme("Sparkle");
    }
}
```

### Example 4: Advanced State Management

```csharp
private void UpdateSystemMenuState()
{
    if (_systemMenu != null)
    {
        // Enable/disable based on custom logic
        _systemMenu.ShowOnLeftClick = AllowLeftClickMenu;
        _systemMenu.ShowOnRightClick = AllowRightClickMenu;
        _systemMenu.ShowOnAltSpace = AllowAltSpaceMenu;
        
        // Refresh to apply changes
        _systemMenu.Refresh();
        
        // Get debug information
        Debug.WriteLine($"Menu enabled: {_systemMenu.Enabled}");
        Debug.WriteLine($"Menu item count: {_systemMenu.MenuItemCount}");
        Debug.WriteLine($"Current theme: {_systemMenu.CurrentIconTheme}");
    }
}
```

### Example 5: Event Integration

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;

    public MainForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
    }

    private void InitializeSystemMenu()
    {
        _systemMenu = new KryptonSystemMenu(this);
        
        // Hook into form events
        Load += OnFormLoad;
        WindowStateChanged += OnWindowStateChanged;
        Resize += OnFormResize;
    }

    private void OnFormLoad(object? sender, EventArgs e)
    {
        // Initial setup
        _systemMenu?.Refresh();
    }

    private void OnWindowStateChanged(object? sender, EventArgs e)
    {
        // Update menu when window state changes
        _systemMenu?.Refresh();
    }

    private void OnFormResize(object? sender, EventArgs e)
    {
        // Update menu when form is resized
        _systemMenu?.Refresh();
    }
}
```

## Conclusion

The `KryptonSystemMenu` provides a powerful and flexible way to implement themed system menus in Krypton applications. By following the guidelines and examples in this documentation, developers can effectively integrate and customize the system menu to meet their specific requirements.

For additional support and updates, refer to the main Krypton Toolkit documentation and community resources.