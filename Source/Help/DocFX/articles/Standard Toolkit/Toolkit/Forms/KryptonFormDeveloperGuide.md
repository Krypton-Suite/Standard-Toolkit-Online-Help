# KryptonForm Developer Guide

## Quick Start

### Basic Usage
```csharp
// Create a KryptonForm with themed system menu
var form = new KryptonForm();
form.Text = "My Application";
form.Size = new Size(800, 600);

// Add controls normally
var button = new Button { Text = "Click Me" };
form.Controls.Add(button); // Goes to InternalPanel automatically

// System menu is automatically available
// Right-click title bar to see themed menu
```

### Designer Usage
1. **Add KryptonForm** to your project
2. **Open in Visual Studio designer**
3. **Drag controls** from toolbox onto form
4. **Configure properties** in Properties window
5. **No special setup required** - everything works automatically

## Common Development Patterns

### 1. Form with Custom System Menu
```csharp
public partial class MainForm : KryptonForm
{
    public MainForm()
    {
        InitializeComponent();
    }
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        SetupSystemMenu();
    }
    
    private void SetupSystemMenu()
    {
        var systemMenu = KryptonSystemMenu;
        if (systemMenu != null)
        {
            systemMenu.AddSeparator();
            systemMenu.AddCustomMenuItem("Settings", OnSettings);
            systemMenu.AddCustomMenuItem("About", OnAbout);
            systemMenu.Refresh();
        }
    }
    
    private void OnSettings(object sender, EventArgs e)
    {
        var settingsForm = new SettingsForm();
        settingsForm.ShowDialog(this);
    }
    
    private void OnAbout(object sender, EventArgs e)
    {
        MessageBox.Show("My Application v1.0", "About", 
                       MessageBoxButtons.OK, MessageBoxIcon.Information);
    }
}
```

### 2. Theme-Aware Application
```csharp
public partial class ThemedForm : KryptonForm
{
    public ThemedForm()
    {
        InitializeComponent();
        
        // Set initial theme
        PaletteMode = PaletteMode.Office2013White;
    }
    
    private void ChangeTheme(PaletteMode newTheme)
    {
        // Change form theme
        PaletteMode = newTheme;
        
        // System menu automatically adapts
        // No additional code needed
        
        // Force refresh if needed
        KryptonSystemMenu?.RefreshThemeIcons();
    }
    
    private void OnThemeMenuClick(object sender, EventArgs e)
    {
        if (sender is ToolStripMenuItem item)
        {
            var theme = (PaletteMode)item.Tag;
            ChangeTheme(theme);
        }
    }
}
```

### 3. Configuration-Driven System Menu
```csharp
public partial class ConfigurableForm : KryptonForm
{
    public ConfigurableForm()
    {
        InitializeComponent();
    }
    
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        LoadSystemMenuConfiguration();
    }
    
    private void LoadSystemMenuConfiguration()
    {
        // Load from app settings
        SystemMenuValues.Enabled = Properties.Settings.Default.SystemMenuEnabled;
        SystemMenuValues.ShowOnRightClick = Properties.Settings.Default.ShowOnRightClick;
        SystemMenuValues.ShowOnAltSpace = Properties.Settings.Default.ShowOnAltSpace;
        
        // Add custom items based on user role
        if (User.IsAdmin)
        {
            AddAdminMenuItems();
        }
        
        if (User.IsPowerUser)
        {
            AddPowerUserMenuItems();
        }
    }
    
    private void AddAdminMenuItems()
    {
        var systemMenu = KryptonSystemMenu;
        if (systemMenu != null)
        {
            systemMenu.AddSeparator();
            systemMenu.AddCustomMenuItem("Admin Panel", OnAdminPanel);
            systemMenu.AddCustomMenuItem("User Management", OnUserManagement);
            systemMenu.Refresh();
        }
    }
}
```

## Advanced Techniques

### 1. Dynamic Menu Updates
```csharp
private void UpdateMenuBasedOnState()
{
    var systemMenu = KryptonSystemMenu;
    if (systemMenu == null) return;
    
    // Clear existing custom items
    systemMenu.ClearCustomItems();
    
    // Add items based on current application state
    if (documentLoaded)
    {
        systemMenu.AddCustomMenuItem("Save Document", OnSaveDocument);
        systemMenu.AddCustomMenuItem("Export", OnExport);
    }
    
    if (hasUnsavedChanges)
    {
        systemMenu.AddCustomMenuItem("Discard Changes", OnDiscardChanges);
    }
    
    // Apply changes
    systemMenu.Refresh();
}
```

### 2. Context-Sensitive Menus
```csharp
private void UpdateMenuForContext(ApplicationContext context)
{
    var systemMenu = KryptonSystemMenu;
    if (systemMenu == null) return;
    
    // Get existing custom items
    var existingItems = systemMenu.GetCustomMenuItems();
    
    // Only update if context changed
    if (ShouldUpdateMenu(context, existingItems))
    {
        RebuildMenuForContext(context);
    }
}

private void RebuildMenuForContext(ApplicationContext context)
{
    var systemMenu = KryptonSystemMenu;
    systemMenu.ClearCustomItems();
    
    switch (context)
    {
        case ApplicationContext.Editing:
            systemMenu.AddCustomMenuItem("Undo", OnUndo);
            systemMenu.AddCustomMenuItem("Redo", OnRedo);
            break;
            
        case ApplicationContext.Viewing:
            systemMenu.AddCustomMenuItem("Zoom In", OnZoomIn);
            systemMenu.AddCustomMenuItem("Zoom Out", OnZoomOut);
            break;
    }
    
    systemMenu.Refresh();
}
```

### 3. Integration with Application Framework
```csharp
public abstract class BaseKryptonForm : KryptonForm
{
    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        InitializeBaseSystemMenu();
    }
    
    protected virtual void InitializeBaseSystemMenu()
    {
        var systemMenu = KryptonSystemMenu;
        if (systemMenu != null)
        {
            // Add common items to all forms
            systemMenu.AddSeparator();
            systemMenu.AddCustomMenuItem("Help", OnShowHelp);
            
            // Let derived classes add their items
            AddCustomSystemMenuItems(systemMenu);
            
            systemMenu.Refresh();
        }
    }
    
    protected virtual void AddCustomSystemMenuItems(KryptonSystemMenu systemMenu)
    {
        // Override in derived classes to add specific items
    }
    
    private void OnShowHelp(object sender, EventArgs e)
    {
        // Show context-sensitive help
        Help.ShowHelp(this, GetHelpFile(), GetHelpTopic());
    }
    
    protected abstract string GetHelpFile();
    protected abstract string GetHelpTopic();
}

// Usage in specific forms
public partial class DocumentForm : BaseKryptonForm
{
    protected override void AddCustomSystemMenuItems(KryptonSystemMenu systemMenu)
    {
        systemMenu.AddCustomMenuItem("Document Properties", OnDocumentProperties);
        systemMenu.AddCustomMenuItem("Print Preview", OnPrintPreview);
    }
    
    protected override string GetHelpFile() => "DocumentHelp.chm";
    protected override string GetHelpTopic() => "DocumentEditing";
}
```

## Testing Strategies

### Unit Testing
```csharp
[Test]
public void SystemMenu_InDesignMode_ShouldBeNull()
{
    // Simulate design mode
    using var form = new KryptonForm();
    
    // In design mode, system menu should be null
    Assert.IsNull(form.KryptonSystemMenu);
    Assert.IsNull(form.SystemMenuService);
}

[Test]
public void SystemMenu_AtRuntime_ShouldBeAvailable()
{
    // Simulate runtime
    using var form = new KryptonForm();
    form.CreateControl(); // Simulate runtime creation
    
    // At runtime, system menu should be available
    Assert.IsNotNull(form.KryptonSystemMenu);
    Assert.IsNotNull(form.SystemMenuService);
}
```

### Integration Testing
```csharp
[Test]
public void CustomMenuItem_ShouldAppearInMenu()
{
    using var form = new KryptonForm();
    form.CreateControl();
    
    var systemMenu = form.KryptonSystemMenu;
    Assert.IsNotNull(systemMenu);
    
    // Add custom item
    bool clicked = false;
    systemMenu.AddCustomMenuItem("Test", (s, e) => clicked = true);
    systemMenu.Refresh();
    
    // Verify item was added
    var customItems = systemMenu.GetCustomMenuItems();
    Assert.Contains("Test", customItems);
}
```

### Designer Testing
```csharp
// Manual testing in Visual Studio designer:
// 1. Open KryptonForm in designer
// 2. Verify no red rectangle appears
// 3. Test drag and drop from toolbox
// 4. Confirm form selection works
// 5. Check Properties window shows KryptonForm
```

## Performance Optimization

### Best Practices

#### 1. Minimize System Menu Operations
```csharp
// Batch operations together
var systemMenu = KryptonSystemMenu;
if (systemMenu != null)
{
    systemMenu.AddCustomMenuItem("Item1", OnItem1);
    systemMenu.AddCustomMenuItem("Item2", OnItem2);
    systemMenu.AddCustomMenuItem("Item3", OnItem3);
    
    // Single refresh for all changes
    systemMenu.Refresh();
}
```

#### 2. Cache System Menu Reference
```csharp
public partial class OptimizedForm : KryptonForm
{
    private KryptonSystemMenu? _cachedSystemMenu;
    
    private KryptonSystemMenu? CachedSystemMenu
    {
        get
        {
            if (_cachedSystemMenu == null)
            {
                _cachedSystemMenu = KryptonSystemMenu;
            }
            return _cachedSystemMenu;
        }
    }
    
    private void UseSystemMenu()
    {
        var systemMenu = CachedSystemMenu;
        if (systemMenu != null)
        {
            // Use cached reference
            systemMenu.Refresh();
        }
    }
}
```

#### 3. Efficient Event Handling
```csharp
// Use lightweight event handlers
private void OnQuickAction(object sender, EventArgs e)
{
    // Keep handlers simple and fast
    PerformQuickAction();
}

// For complex operations, use async patterns
private async void OnComplexAction(object sender, EventArgs e)
{
    // Show progress
    Cursor = Cursors.WaitCursor;
    
    try
    {
        await PerformComplexOperationAsync();
    }
    finally
    {
        Cursor = Cursors.Default;
    }
}
```

## Deployment Considerations

### Distribution
- **No Special Requirements**: System menu is part of Krypton.Toolkit
- **Theme Resources**: Icons embedded in assembly
- **Dependencies**: Standard Krypton.Toolkit dependencies only

### Configuration
- **App.config**: No special configuration required
- **Registry**: No registry dependencies
- **User Settings**: Can store SystemMenuValues preferences

### Compatibility
- **Windows Versions**: Works on all supported Windows versions
- **.NET Versions**: Supports all Krypton.Toolkit target frameworks
- **DPI Awareness**: Automatically handles high-DPI scenarios

## Related Documentation

- [System Menu Overview](KryptonForm-SystemMenu-Overview.md)
- [API Reference](KryptonSystemMenu-API-Reference.md)
- [Service Documentation](KryptonSystemMenuService-Documentation.md)
- [Troubleshooting Guide](KryptonForm-Troubleshooting.md)
- [Migration Guide](KryptonForm-Migration-Guide.md)
- [InternalPanel Architecture](KryptonForm-InternalPanel-Architecture.md)
