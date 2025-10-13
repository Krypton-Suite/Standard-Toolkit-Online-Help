# KryptonForm System Menu - Developer Documentation

## Overview

The KryptonForm includes a comprehensive themed system menu implementation that replaces the native Windows system menu with a fully customizable KryptonContextMenu. This documentation covers the architecture, implementation, and usage of this feature.

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Key Components](#key-components)
3. [Designer Mode Integration](#designer-mode-integration)
4. [Usage Examples](#usage-examples)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)

## Architecture Overview

The themed system menu consists of three main components:

```
KryptonForm
├── KryptonSystemMenuService (Orchestrates system menu behavior)
├── KryptonSystemMenu (Provides the actual themed menu)
└── SystemMenuValues (Configuration and customization)
```

### Key Design Principles

1. **Designer-First**: Complete transparency in Visual Studio designer mode
2. **Performance-Optimized**: Minimal overhead during runtime operations
3. **Fully Customizable**: All aspects can be themed and configured
4. **Backward Compatible**: Maintains standard Windows system menu behavior
5. **Robust**: Multiple fallback mechanisms for reliable operation

## Key Components

### 1. KryptonSystemMenuService
- **Purpose**: Orchestrates system menu behavior and event handling
- **Location**: `Source/Krypton Components/Krypton.Toolkit/General/KryptonSystemMenuService.cs`
- **Responsibilities**:
  - Mouse event handling (left/right clicks)
  - Keyboard shortcut processing
  - Designer mode detection
  - Service lifecycle management

### 2. KryptonSystemMenu
- **Purpose**: Provides the actual themed context menu
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonSystemMenu.cs`
- **Responsibilities**:
  - Menu item creation and management
  - Theme-appropriate icon generation
  - Menu positioning and display
  - Custom menu item support

### 3. SystemMenuValues
- **Purpose**: Configuration and customization options
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Values/SystemMenuValues.cs`
- **Responsibilities**:
  - Behavior configuration (when to show menu)
  - Custom menu item management
  - Property change notifications

## Designer Mode Integration

### Problem Solved
The system menu was interfering with Visual Studio designer operations, preventing proper drag and drop of controls onto KryptonForm.

### Solution Implemented
**Complete system menu disabling in design mode** through multiple detection methods:

```csharp
private bool IsInDesignMode()
{
    return LicenseManager.UsageMode == LicenseUsageMode.Designtime ||
           Site?.DesignMode == true ||
           (Site?.Container?.Components?.OfType<Control>().Any(c => c.Site?.DesignMode == true) == true);
}
```

### Key Features
- **Multi-layered detection**: Uses three different methods for robust design-time detection
- **Performance optimized**: System menu service not created in design mode
- **Zero interference**: Designer operations work without any system menu blocking
- **Runtime preservation**: Full functionality available at runtime

## Usage Examples

### Basic Usage
```csharp
// The system menu is automatically available on any KryptonForm
var form = new KryptonForm();
// System menu appears on:
// - Right-click on title bar
// - Left-click on form icon (if enabled)
// - Alt+Space keyboard shortcut
```

### Accessing the System Menu
```csharp
// Get access to the system menu for customization
IKryptonSystemMenu systemMenu = form.KryptonSystemMenu;
if (systemMenu != null)
{
    // Add custom menu items, modify behavior, etc.
}
```

### Configuration
```csharp
// Configure system menu behavior
form.SystemMenuValues.ShowOnRightClick = true;  // Default: true
form.SystemMenuValues.ShowOnIconClick = true;   // Default: true
form.SystemMenuValues.ShowOnAltSpace = true;    // Default: true
form.SystemMenuValues.Enabled = true;           // Default: true
```

## Customization

### Adding Custom Menu Items
```csharp
// Access the system menu
var systemMenu = form.KryptonSystemMenu;
if (systemMenu != null)
{
    // Add a custom menu item
    systemMenu.AddCustomMenuItem("Settings", OnSettingsClick, true);
    
    // Add a separator
    systemMenu.AddSeparator(true);
}

private void OnSettingsClick(object sender, EventArgs e)
{
    // Handle custom menu item click
    MessageBox.Show("Settings clicked!");
}
```

### Theme Integration
The system menu automatically adapts to the current Krypton theme:
- **Icons**: Theme-appropriate icons for all standard menu items
- **Colors**: Menu colors match the current palette
- **Styling**: Consistent with other Krypton components

## Troubleshooting

### Common Issues

#### 1. System Menu Not Appearing
**Symptoms**: Right-click on title bar doesn't show menu
**Causes**:
- `SystemMenuValues.Enabled = false`
- `SystemMenuValues.ShowOnRightClick = false`
- `ControlBox = false`

**Solution**:
```csharp
form.SystemMenuValues.Enabled = true;
form.SystemMenuValues.ShowOnRightClick = true;
form.ControlBox = true;
```

#### 2. Designer Drag and Drop Issues
**Symptoms**: Cannot drag controls from toolbox to form
**Causes**: System menu interference (should be fixed with this implementation)

**Solution**: The new implementation automatically disables system menu in design mode.

#### 3. Custom Menu Items Not Showing
**Symptoms**: Added custom items don't appear
**Causes**: Items added after menu is built

**Solution**:
```csharp
// Refresh the menu after adding custom items
systemMenu.Refresh();
```

### Debug Information

#### Checking System Menu State
```csharp
// Check if system menu is available
bool hasSystemMenu = form.KryptonSystemMenu != null;

// Check configuration
bool isEnabled = form.SystemMenuValues.Enabled;
bool showOnRightClick = form.SystemMenuValues.ShowOnRightClick;

// Get menu item count
int itemCount = form.KryptonSystemMenu?.MenuItemCount ?? 0;
```

#### Design Mode Detection
```csharp
// The form uses multiple methods to detect design mode:
// 1. LicenseManager.UsageMode == LicenseUsageMode.Designtime
// 2. Site?.DesignMode == true
// 3. Container component checks
```

## Performance Considerations

### Optimizations Implemented
1. **Conditional Creation**: System menu service only created when needed (not in design mode)
2. **Lazy Loading**: Menu items created on-demand
3. **Efficient Detection**: Design mode detection cached and optimized
4. **Minimal Overhead**: No complex logic in frequently-called methods

### Best Practices
1. **Cache References**: Store system menu reference if accessing frequently
2. **Batch Operations**: Group multiple customizations together
3. **Event Handling**: Use proper event handlers for custom menu items
4. **Resource Management**: System menu resources are automatically managed

## Related Files

- `KryptonForm.cs` - Main form implementation
- `KryptonSystemMenuService.cs` - Service orchestration
- `KryptonSystemMenu.cs` - Menu implementation
- `SystemMenuValues.cs` - Configuration values
- `VisualForm.cs` - Base form with designer mode detection

## Version History

### Current Implementation
- **Designer Mode Support**: Complete transparency in Visual Studio designer
- **Robust Detection**: Multiple fallback methods for design-time detection
- **Performance Optimized**: Minimal runtime overhead
- **Fully Customizable**: Support for custom menu items and themes
