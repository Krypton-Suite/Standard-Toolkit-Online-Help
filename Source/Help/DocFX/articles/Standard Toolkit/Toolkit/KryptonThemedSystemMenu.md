# Krypton Themed System Menu

## Quick Start

The themed system menu is automatically enabled on `KryptonForm`:

```csharp
// Create a form - themed system menu works automatically
var form = new KryptonForm();
form.Text = "My Application";

// Users can trigger the menu by:
// - Left-clicking on the title bar
// - Right-clicking on the title bar  
// - Pressing Alt+Space
```

## What You Need to Know

### Automatic Integration
- **KryptonForm** automatically includes themed system menu functionality
- **No setup required** - it works out of the box
- **Native behavior** - works exactly like the Windows system menu
- **Theme integration** - matches your application's theme

### Trigger Methods
The menu can be triggered in three ways:
1. **Left-click** on title bar (except control buttons)
2. **Right-click** on title bar (except control buttons)
3. **Alt+Space** keyboard shortcut

## Basic Configuration

### Enable/Disable the Feature
```csharp
var form = new KryptonForm();

// Disable themed system menu (falls back to native)
form.UseThemedSystemMenu = false;

// Re-enable it
form.UseThemedSystemMenu = true;
```

### Configure Trigger Methods
```csharp
var form = new KryptonForm();

// Enable all trigger methods (default)
form.ShowThemedSystemMenuOnLeftClick = true;
form.ShowThemedSystemMenuOnRightClick = true;
form.ShowThemedSystemMenuOnAltSpace = true;

// Disable specific triggers
form.ShowThemedSystemMenuOnLeftClick = false;   // Disable left-click only
form.ShowThemedSystemMenuOnRightClick = false;  // Disable right-click only
form.ShowThemedSystemMenuOnAltSpace = false;    // Disable Alt+Space only
```

## Adding Custom Menu Items

### Simple Custom Items
```csharp
var form = new KryptonForm();

// Add a custom menu item before the Close item
if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.AddCustomMenuItem("Settings", (sender, e) =>
    {
        // Open settings dialog
        OpenSettingsDialog();
    }, insertBeforeClose: true);
}
```

### Multiple Custom Items
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    // Add a separator first
    form.KryptonSystemMenu.AddSeparator(insertBeforeClose: true);
    
    // Add custom items
    form.KryptonSystemMenu.AddCustomMenuItem("Save", (sender, e) => SaveDocument());
    form.KryptonSystemMenu.AddCustomMenuItem("Print", (sender, e) => PrintDocument());
    form.KryptonSystemMenu.AddCustomMenuItem("Settings", (sender, e) => OpenSettings());
}
```

### Items at the End
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    // Add items at the end (after Close)
    form.KryptonSystemMenu.AddCustomMenuItem("About", (sender, e) => ShowAboutDialog(), insertBeforeClose: false);
    form.KryptonSystemMenu.AddCustomMenuItem("Help", (sender, e) => ShowHelp(), insertBeforeClose: false);
}
```

## Advanced Customization

### Direct Access to Context Menu
```csharp
var form = new KryptonForm();

// Get direct access for advanced customization
if (form.KryptonSystemMenu is KryptonThemedSystemMenu themedMenu)
{
    var contextMenu = themedMenu.ContextMenu;
    
    // Add custom items with full control
    var customItem = new KryptonContextMenuItem("Advanced Action");
    customItem.Click += (sender, e) => PerformAdvancedAction();
    
    // Add separator and item
    contextMenu.Items.Add(new KryptonContextMenuSeparator());
    contextMenu.Items.Add(customItem);
}
```

### Conditional Menu Items
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    // Only show "Save" if document is modified
    if (IsDocumentModified)
    {
        form.KryptonSystemMenu.AddCustomMenuItem("Save", (sender, e) => SaveDocument());
    }
    
    // Only show "Print" if printer is available
    if (IsPrinterAvailable)
    {
        form.KryptonSystemMenu.AddCustomMenuItem("Print", (sender, e) => PrintDocument());
    }
}
```

### Dynamic Menu Updates
```csharp
var form = new KryptonForm();

// Update menu when application state changes
public void UpdateSystemMenu()
{
    if (form.KryptonSystemMenu != null)
    {
        // Clear existing custom items
        form.KryptonSystemMenu.ClearCustomItems();
        
        // Add items based on current state
        if (IsDocumentModified)
        {
            form.KryptonSystemMenu.AddCustomMenuItem("Save", (sender, e) => SaveDocument());
        }
        
        if (CanUndo)
        {
            form.KryptonSystemMenu.AddCustomMenuItem("Undo", (sender, e) => UndoAction());
        }
    }
}
```

## Keyboard Shortcut Handling

### Override ProcessCmdKey
```csharp
public partial class MyForm : KryptonForm
{
    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        // Let the themed system menu handle its shortcuts first
        if (KryptonSystemMenu?.HandleKeyboardShortcut(keyData) == true)
        {
            return true;
        }

        // Handle your own shortcuts
        if (keyData == (Keys.Control | Keys.S))
        {
            SaveDocument();
            return true;
        }

        if (keyData == (Keys.Control | Keys.O))
        {
            OpenDocument();
            return true;
        }

        return base.ProcessCmdKey(ref msg, keyData);
    }
}
```

### Custom Shortcuts
```csharp
var form = new KryptonForm();

// Add custom shortcuts to the system menu
if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.AddCustomMenuItem("Save\tCtrl+S", (sender, e) => SaveDocument());
    form.KryptonSystemMenu.AddCustomMenuItem("Open\tCtrl+O", (sender, e) => OpenDocument());
}
```

## Theme Integration

### Theme-Aware Icons
```csharp
var form = new KryptonForm();

// Refresh icons when theme changes
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    if (form.KryptonSystemMenu != null)
    {
        form.KryptonSystemMenu.RefreshThemeIcons();
    }
};
```

### Manual Refresh
```csharp
var form = new KryptonForm();

// Manually refresh the menu
if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.Refresh();
}
```

## Error Handling

### Safe Access Pattern
```csharp
var form = new KryptonForm();

// Always check for null before using
if (form.KryptonSystemMenu != null)
{
    try
    {
        form.KryptonSystemMenu.AddCustomMenuItem("Safe Action", (sender, e) =>
        {
            // Your action here
        });
    }
    catch (Exception ex)
    {
        // Handle any errors gracefully
        Debug.WriteLine($"Failed to add custom menu item: {ex.Message}");
    }
}
```

### Graceful Fallback
```csharp
public void AddSystemMenuItem(string text, EventHandler clickHandler)
{
    if (KryptonSystemMenu != null)
    {
        try
        {
            KryptonSystemMenu.AddCustomMenuItem(text, clickHandler);
        }
        catch
        {
            // Fall back to native system menu or handle gracefully
            Debug.WriteLine("Failed to add themed system menu item");
        }
    }
}
```

## Common Use Cases

### Application Settings
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.AddSeparator(insertBeforeClose: true);
    form.KryptonSystemMenu.AddCustomMenuItem("Settings", (sender, e) => OpenSettings());
    form.KryptonSystemMenu.AddCustomMenuItem("Preferences", (sender, e) => OpenPreferences());
}
```

### File Operations
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.AddSeparator(insertBeforeClose: true);
    form.KryptonSystemMenu.AddCustomMenuItem("New", (sender, e) => CreateNewDocument());
    form.KryptonSystemMenu.AddCustomMenuItem("Open", (sender, e) => OpenDocument());
    form.KryptonSystemMenu.AddCustomMenuItem("Save", (sender, e) => SaveDocument());
    form.KryptonSystemMenu.AddCustomMenuItem("Save As", (sender, e) => SaveDocumentAs());
}
```

### Help and Support
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.AddSeparator(insertBeforeClose: false);
    form.KryptonSystemMenu.AddCustomMenuItem("Help", (sender, e) => ShowHelp());
    form.KryptonSystemMenu.AddCustomMenuItem("About", (sender, e) => ShowAbout());
    form.KryptonSystemMenu.AddCustomMenuItem("Support", (sender, e) => OpenSupport());
}
```

### Application-Specific Actions
```csharp
var form = new KryptonForm();

if (form.KryptonSystemMenu != null)
{
    form.KryptonSystemMenu.AddSeparator(insertBeforeClose: true);
    form.KryptonSystemMenu.AddCustomMenuItem("Export Data", (sender, e) => ExportData());
    form.KryptonSystemMenu.AddCustomMenuItem("Import Data", (sender, e) => ImportData());
    form.KryptonSystemMenu.AddCustomMenuItem("Generate Report", (sender, e) => GenerateReport());
}
```

## Best Practices

### 1. Check for Null
```csharp
// Always check if the system menu is available
if (form.KryptonSystemMenu != null)
{
    // Safe to use
    form.KryptonSystemMenu.AddCustomMenuItem("Action", (sender, e) => { });
}
```

### 2. Use Appropriate Positioning
```csharp
// Use insertBeforeClose: true for main application actions
form.KryptonSystemMenu.AddCustomMenuItem("Save", (sender, e) => Save(), insertBeforeClose: true);

// Use insertBeforeClose: false for secondary actions
form.KryptonSystemMenu.AddCustomMenuItem("About", (sender, e) => ShowAbout(), insertBeforeClose: false);
```

### 3. Add Separators
```csharp
// Add separators to organize menu items
form.KryptonSystemMenu.AddSeparator(insertBeforeClose: true);
form.KryptonSystemMenu.AddCustomMenuItem("Action 1", (sender, e) => { });
form.KryptonSystemMenu.AddCustomMenuItem("Action 2", (sender, e) => { });
form.KryptonSystemMenu.AddSeparator(insertBeforeClose: true);
```

### 4. Handle Theme Changes
```csharp
// Refresh icons when theme changes
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    if (form.KryptonSystemMenu != null)
    {
        form.KryptonSystemMenu.RefreshThemeIcons();
    }
};
```

### 5. Clean Up Event Handlers
```csharp
// Store references to event handlers for cleanup
private EventHandler _saveHandler;

public void AddSaveMenuItem()
{
    _saveHandler = (sender, e) => SaveDocument();
    form.KryptonSystemMenu?.AddCustomMenuItem("Save", _saveHandler);
}

public void RemoveSaveMenuItem()
{
    // Remove the event handler when no longer needed
    if (_saveHandler != null)
    {
        // Implementation depends on your cleanup strategy
    }
}
```

## Troubleshooting

### Menu Not Appearing
```csharp
// Check if themed system menu is enabled
if (!form.UseThemedSystemMenu)
{
    // Enable it
    form.UseThemedSystemMenu = true;
}

// Check trigger methods
if (!form.ShowThemedSystemMenuOnLeftClick && 
    !form.ShowThemedSystemMenuOnRightClick && 
    !form.ShowThemedSystemMenuOnAltSpace)
{
    // Enable at least one trigger method
    form.ShowThemedSystemMenuOnLeftClick = true;
}
```

### Custom Items Not Working
```csharp
// Check if system menu is available
if (form.KryptonSystemMenu == null)
{
    Debug.WriteLine("Themed system menu is not available");
    return;
}

// Check if menu has items
if (!form.KryptonSystemMenu.HasMenuItems)
{
    Debug.WriteLine("System menu has no items");
    return;
}
```

### Performance Issues
```csharp
// Avoid frequent menu updates
private bool _menuNeedsUpdate = false;

public void MarkMenuForUpdate()
{
    _menuNeedsUpdate = true;
}

public void UpdateMenuIfNeeded()
{
    if (_menuNeedsUpdate && form.KryptonSystemMenu != null)
    {
        form.KryptonSystemMenu.Refresh();
        _menuNeedsUpdate = false;
    }
}
```

## Testing

### Manual Testing Steps
1. **Build and run** your KryptonForm application
2. **Left-click** on the title bar (not on minimize/maximize/close buttons)
3. **Right-click** on the title bar
4. **Press Alt+Space** keyboard shortcut
5. **Verify** the themed menu appears with your custom items
6. **Test** different window states (normal, maximized, minimized)

### Test Different Scenarios
```csharp
// Test with different configurations
form.ShowThemedSystemMenuOnLeftClick = false;   // Test right-click only
form.ShowThemedSystemMenuOnRightClick = false;  // Test left-click only
form.ShowThemedSystemMenuOnAltSpace = false;   // Test mouse clicks only

// Test with custom items
form.KryptonSystemMenu?.AddCustomMenuItem("Test Item", (sender, e) => 
{
    MessageBox.Show("Test item clicked!");
});
```

## Summary

The themed system menu provides:

- **Automatic integration** with KryptonForm
- **Native behavior** with themed appearance
- **Multiple trigger methods** (left-click, right-click, Alt+Space)
- **Easy customization** with simple API
- **Theme integration** that matches your application
- **Robust error handling** with graceful fallbacks

Use this feature to enhance your application's user experience with a professional, consistent system menu that integrates seamlessly with the Krypton Toolkit theming system.
