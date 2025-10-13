# KryptonForm System Menu - Troubleshooting Guide

## Common Issues and Solutions

### Designer Issues

#### ❌ Problem: Cannot Drag Controls from Toolbox
**Symptoms:**
- Red rectangle appears when trying to drag controls
- Controls cannot be dropped onto KryptonForm
- Designer appears "locked" or unresponsive

**Root Cause:**
System menu interference with designer operations

**Solution:**
This should be resolved with the new implementation. Verify:
```csharp
// Check that system menu service is null in design mode
var service = form.SystemMenuService; // Should be null in designer
```

**If still occurring:**
1. Rebuild the solution completely
2. Close and reopen Visual Studio
3. Check that `LicenseManager.UsageMode == LicenseUsageMode.Designtime` in designer

#### ❌ Problem: InternalPanel Selectable in Designer
**Symptoms:**
- Clicking on form client area selects InternalPanel instead of KryptonForm
- Properties window shows InternalPanel properties

**Root Cause:**
InternalPanel being treated as separate control

**Solution:**
With the new implementation, InternalPanel should be transparent. Verify:
```csharp
// InternalPanel should not have special designer logic anymore
// It's now a standard KryptonPanel
```

#### ❌ Problem: Form Selection Issues
**Symptoms:**
- Cannot select KryptonForm by clicking on it
- Must click title bar to select form

**Root Cause:**
Hit testing interference

**Solution:**
The `WindowChromeHitTest` method now includes designer mode detection:
```csharp
protected override IntPtr WindowChromeHitTest(Point pt)
{
    if (IsInDesignMode())
    {
        return base.WindowChromeHitTest(pt); // Let designer handle
    }
    // ... runtime hit testing
}
```

### Runtime Issues

#### ❌ Problem: System Menu Not Appearing
**Symptoms:**
- Right-click on title bar doesn't show menu
- Alt+Space doesn't work
- No system menu functionality

**Possible Causes & Solutions:**

1. **System Menu Disabled**
   ```csharp
   // Check and fix
   form.SystemMenuValues.Enabled = true;
   ```

2. **Right-Click Disabled**
   ```csharp
   // Check and fix
   form.SystemMenuValues.ShowOnRightClick = true;
   ```

3. **ControlBox Disabled**
   ```csharp
   // Check and fix
   form.ControlBox = true;
   ```

4. **Service Not Created**
   ```csharp
   // Check if service exists
   if (form.SystemMenuService == null)
   {
       // This is normal in design mode
       // At runtime, this indicates an initialization issue
   }
   ```

#### ❌ Problem: System Menu Shows Native Menu Instead of Themed
**Symptoms:**
- Right-click shows Windows default system menu
- No themed appearance

**Root Cause:**
Themed system menu not properly initialized or disabled

**Solution:**
```csharp
// Verify system menu is enabled and service exists
bool isEnabled = form.SystemMenuValues.Enabled;
bool serviceExists = form.SystemMenuService != null;
bool hasMenu = form.KryptonSystemMenu != null;

// If any are false at runtime, check initialization
```

#### ❌ Problem: Custom Menu Items Not Appearing
**Symptoms:**
- Added custom items don't show in menu
- Menu appears but without custom items

**Solutions:**

1. **Refresh After Adding Items**
   ```csharp
   systemMenu.AddCustomMenuItem("Settings", OnSettingsClick);
   systemMenu.Refresh(); // Important!
   ```

2. **Check Item Visibility**
   ```csharp
   // Ensure custom items are visible
   foreach (var item in systemMenu.DesignerMenuItems)
   {
       item.Visible = true;
   }
   ```

3. **Verify Service Exists**
   ```csharp
   var systemMenu = form.KryptonSystemMenu;
   if (systemMenu == null)
   {
       // System menu not available (design mode or initialization issue)
   }
   ```

#### ❌ Problem: Menu Items Wrong State (Enabled/Disabled)
**Symptoms:**
- Minimize/Maximize items disabled when they should be enabled
- Restore item not appearing when window is maximized

**Root Cause:**
Menu state not synchronized with form state

**Solution:**
```csharp
// Force refresh to update item states
form.KryptonSystemMenu?.Refresh();

// Check form properties
bool canMinimize = form.MinimizeBox;
bool canMaximize = form.MaximizeBox;
var windowState = form.WindowState;
```

### Theme Issues

#### ❌ Problem: Icons Not Matching Theme
**Symptoms:**
- Menu icons don't match current application theme
- Icons appear generic or incorrect

**Solutions:**

1. **Force Theme Refresh**
   ```csharp
   form.KryptonSystemMenu?.RefreshThemeIcons();
   ```

2. **Manually Set Theme**
   ```csharp
   form.KryptonSystemMenu?.SetIconTheme("Office2013");
   ```

3. **Check Theme Detection**
   ```csharp
   string currentTheme = form.KryptonSystemMenu?.CurrentIconTheme;
   // Should match your application's theme
   ```

#### ❌ Problem: Menu Colors Wrong
**Symptoms:**
- Menu appears with wrong colors
- Doesn't match form theme

**Root Cause:**
Theme not properly applied to context menu

**Solution:**
```csharp
// Ensure form palette is properly set
form.PaletteMode = PaletteMode.Office2013White; // or appropriate theme

// Force refresh
form.KryptonSystemMenu?.Refresh();
```

### Performance Issues

#### ❌ Problem: Slow Menu Appearance
**Symptoms:**
- Delay when right-clicking to show menu
- Menu takes time to appear

**Possible Causes & Solutions:**

1. **Icon Generation Overhead**
   ```csharp
   // Icons are generated on-demand
   // First appearance may be slower
   // Subsequent appearances should be fast due to caching
   ```

2. **Complex Custom Items**
   ```csharp
   // Simplify custom menu item creation
   // Avoid complex operations in click handlers
   ```

#### ❌ Problem: Memory Usage
**Symptoms:**
- High memory usage with multiple KryptonForms
- Memory not released when forms closed

**Solution:**
```csharp
// Ensure proper disposal
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // System menu is automatically disposed
        // No manual cleanup required
    }
    base.Dispose(disposing);
}
```

## Diagnostic Tools

### Checking System Menu State
```csharp
public void DiagnoseSystemMenu(KryptonForm form)
{
    Console.WriteLine($"Design Mode: {LicenseManager.UsageMode == LicenseUsageMode.Designtime}");
    Console.WriteLine($"Site Design Mode: {form.Site?.DesignMode}");
    Console.WriteLine($"Service Exists: {form.SystemMenuService != null}");
    Console.WriteLine($"System Menu Exists: {form.KryptonSystemMenu != null}");
    Console.WriteLine($"Enabled: {form.SystemMenuValues?.Enabled}");
    Console.WriteLine($"Show on Right Click: {form.SystemMenuValues?.ShowOnRightClick}");
    Console.WriteLine($"Control Box: {form.ControlBox}");
    Console.WriteLine($"Menu Item Count: {form.KryptonSystemMenu?.MenuItemCount ?? 0}");
    Console.WriteLine($"Current Theme: {form.KryptonSystemMenu?.CurrentIconTheme ?? "None"}");
}
```

### Debug Event Handlers
```csharp
// Add debug handlers to track system menu events
form.SystemMenuValues.PropertyChanged += (s, e) => 
{
    Console.WriteLine($"SystemMenuValues.{e.PropertyName} changed");
};
```

### Logging System Menu Operations
```csharp
// Enable debug output in KryptonSystemMenu
// Look for Debug.WriteLine statements in the implementation
// Use Debug output window in Visual Studio
```

## Best Practices

### 1. Always Check for Null
```csharp
// System menu will be null in design mode
var systemMenu = form.KryptonSystemMenu;
if (systemMenu != null)
{
    // Safe to use
}
```

### 2. Refresh After Changes
```csharp
// After modifying form properties that affect menu
form.MinimizeBox = false;
form.KryptonSystemMenu?.Refresh(); // Update menu state
```

### 3. Handle Events Properly
```csharp
// Use proper event handlers for custom items
systemMenu.AddCustomMenuItem("Settings", OnSettingsClick);

private void OnSettingsClick(object sender, EventArgs e)
{
    // Handle the click
    // Don't perform long-running operations here
}
```

### 4. Theme Integration
```csharp
// Let system menu auto-detect theme
// Manual theme setting only needed for special cases
form.PaletteMode = PaletteMode.Office2013White;
// System menu automatically adapts
```

## Advanced Scenarios

### Custom Menu Item with Icon
```csharp
// Add custom item with icon
var customItem = new KryptonContextMenuItem("Settings");
customItem.Image = Properties.Resources.SettingsIcon;
customItem.Click += OnSettingsClick;

// Add to context menu directly
systemMenu.ContextMenu.Items.Add(customItem);
systemMenu.Refresh();
```

### Dynamic Menu Updates
```csharp
// Update menu based on application state
private void UpdateSystemMenu()
{
    var systemMenu = form.KryptonSystemMenu;
    if (systemMenu != null)
    {
        // Clear existing custom items
        systemMenu.ClearCustomItems();
        
        // Add items based on current state
        if (userLoggedIn)
        {
            systemMenu.AddCustomMenuItem("Logout", OnLogout);
        }
        else
        {
            systemMenu.AddCustomMenuItem("Login", OnLogin);
        }
        
        systemMenu.Refresh();
    }
}
```

### Integration with Application Settings
```csharp
// Save/load system menu preferences
private void LoadSystemMenuSettings()
{
    form.SystemMenuValues.ShowOnRightClick = Settings.ShowSystemMenuOnRightClick;
    form.SystemMenuValues.ShowOnAltSpace = Settings.ShowSystemMenuOnAltSpace;
    form.SystemMenuValues.Enabled = Settings.SystemMenuEnabled;
}

private void SaveSystemMenuSettings()
{
    Settings.ShowSystemMenuOnRightClick = form.SystemMenuValues.ShowOnRightClick;
    Settings.ShowSystemMenuOnAltSpace = form.SystemMenuValues.ShowOnAltSpace;
    Settings.SystemMenuEnabled = form.SystemMenuValues.Enabled;
}
```

## Getting Help

### Debug Steps
1. **Check Design Mode**: Verify `LicenseManager.UsageMode` value
2. **Verify Service**: Ensure `SystemMenuService` is not null at runtime
3. **Check Configuration**: Verify `SystemMenuValues` properties
4. **Test Incrementally**: Start with basic functionality, add complexity gradually

### Support Resources
- [KryptonForm API Reference](KryptonFormAPIReference.md)
- [System Menu Overview](KryptonForm-SystemMenu-Overview.md)
- [Designer Implementation](KryptonForm-DesignerMode-Implementation.md)
- [Krypton Toolkit Documentation](https://github.com/Krypton-Suite/Standard-Toolkit/wiki)

### Reporting Issues
When reporting issues, include:
1. **Design Mode Status**: Whether issue occurs in designer or runtime
2. **Configuration**: SystemMenuValues property values
3. **Form Properties**: ControlBox, MinimizeBox, MaximizeBox, FormBorderStyle
4. **Steps to Reproduce**: Detailed reproduction steps
5. **Expected vs Actual**: What should happen vs what actually happens
