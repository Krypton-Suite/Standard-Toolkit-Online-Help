# KryptonPropertyGrid

## Overview

The `KryptonPropertyGrid` class provides a Krypton-themed wrapper around the standard Windows `PropertyGrid` control. It inherits from `VisualControlBase` and implements `IContainedInputControl` to provide enhanced appearance, consistent theming, and improved visual integration while maintaining full compatibility with the standard `PropertyGrid` functionality.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── Krypton.Toolkit.VisualControlBase
                └── Krypton.Toolkit.KryptonPropertyGrid
```

## Constructor and Initialization

```csharp
public KryptonPropertyGrid
```

The constructor initializes enhanced features:
- **Internal PropertyGrid**: Creates and manages the contained `PropertyGrid` instance
- **Visual States**: Sets up Common, Normal, Disabled, and Active palette states
- **Event Delegation**: Proper event routing to the contained control
- **Context Menu**: Integrated Krypton context menu with reset functionality
- **Palette Integration**: Automatic theme detection and application

## Key Properties

### ContainedControl Property

```csharp
[Browsable(false)]
public Control ContainedControl => _propertyGrid;
```

- **Purpose**: Provides access to the underlying `PropertyGrid` for advanced customization
- **Category**: Runtime only (hidden from designer)
- **Access Level**: Protected but accessible for integration scenarios

### PropertyGrid Property

```csharp
[Browsable(false)]
public PropertyGrid PropertyGrid => _propertyGrid;
```

- **Purpose**: Direct access to the wrapped `PropertyGrid` instance
- **Usage**: For scenarios requiring access to native `PropertyGrid` features
- **Integration**: Allows custom `PropertyGrid`-specific configuration

### Visual State Properties

```csharp
public PaletteInputControlTripleRedirect StateCommon { get; }
public PaletteInputControlTripleStates StateDisabled { get; }
public PaletteInputControlTripleStates StateNormal { get; }
public PaletteInputControlTripleStates StateActive { get; }
```

- **StateCommon**: Base styling configuration for all states
- **StateNormal**: Default appearance when enabled but not active
- **StateActive**: Highlighted appearance when focused/active
- **StateDisabled**: Appearance when control is disabled

### AlwaysActive Property

```csharp
[DefaultValue(false)]
public bool AlwaysActive { get; set; }
```

- **Purpose**: Forces the control to always appear in active state
- **Category**: Visuals
- **Use Case**: When PropertyGrid should always look selected/focused

### IsActive Property

```csharp
[Browsable(false)]
public bool IsActive { get; }
```

- **Purpose**: Read-only property indicating current active state
- **Logic**: `DesignMode || AlwaysActive || ContainsFocus`

## Standard PropertyGrid Properties

### CommandsVisibleIfAvailable Property

```csharp
[DefaultValue(true)]
public bool CommandsVisibleIfAvailable { get; set; }
```

- **Purpose**: Shows commands pane for objects that expose verbs
- **Category**: Appearance
- **Integration**: Directly bound to contained `PropertyGrid`

### HelpVisible Property

```csharp
[DefaultValue(true)]
public bool HelpVisible { get; set; }
```

- **Purpose**: Controls visibility of the help description pane
- **Category**: Appearance
- **Localizable**: Yes

### CanShowVisualStyleGlyphs Property

```csharp
[DefaultValue(true)]
public bool CanShowVisualStyleGlyphs { get; set; }
```

- **Purpose**: Uses OS-specific visual style glyphs for expansion nodes
- **Category**: Appearance
- **Effect**: Modern glyphs vs. legacy symbols

### PropertySort Property

```csharp
[DefaultValue(PropertySort.CategorizedAlphabetical)]
public PropertySort PropertySort { get; set; }
```

- **Available Options**:
  - `Alphabetical`: Alphabetical sorting only
  - `Categorized`: Category grouping only
  - `CategorizedAlphabetical`: Categories with alphabetical order (default)
  - `NoSort`: Display properties in declaration order

### SelectedObject Property

```csharp
[TypeConverter(typeof(SelectedObjectConverter))]
public object? SelectedObject { get; set; }
```

- **Purpose**: Sets the primary object for property inspection
- **Category**: Behavior
- **TypeConverter**: Specialized converter for IComponent objects

### Multi-Object Selection

```csharp
[Browsable(false)]
public object[] SelectedObjects { get; set; }
```

- **Purpose**: Supports inspection of multiple objects simultaneously
- **Category**: Runtime only
- **Use Case**: Comparing properties across multiple instances

### Appearance Options

```csharp
[DefaultValue(false)]
public bool LargeButtons { get; set; }

[DefaultValue(true)]
public bool ToolbarVisible { get; set; }
```

- **LargeButtons**: Increases command button sizes for better accessibility
- **ToolbarVisible**: Shows/hides the toolbar strip with commands

## Advanced Features

### Dark Mode Integration

The `PropertyGrid` automatically adapts to dark themes:

```csharp
public void ConfigureDarkMode()
{
    var palette = KryptonManager.CurrentGlobalPalette;
    var colorTable = palette.ColorTable;
    
    // Automatically adjusts colors for dark themes
    propertyGrid.CategoryForeColor = palette.ToString().Contains("DarkMode")
        ? colorTable.MenuStripText
        : colorTable.ToolStripDropDownBackground;
}
```

### Custom Context Menu

The control provides an enhanced context menu with reset functionality:

```csharp
public partial class EnhancedPropertyGrid : KryptonPropertyGrid
{
    protected override void OnPropertyValueChanged(PropertyValueChangedEventArgs e)
    {
        base.OnPropertyValueChanged(e);
        
        // Log property changes for debugging
        Console.WriteLine($"Property '{e.ChangedItem.PropertyDescriptor.Name}' changed from '{e.OldValue}' to '{e.ChangedItem.Value}'");
    }
}
```

### Theme-Aware Property Editing

```csharp
public class ThemeAwarePropertyEditor : Form
{
    private KryptonPropertyGrid propertyGrid;

    public void EditComponent(IComponent component)
    {
        propertyGrid.SelectedObject = component;
        
        // Configure appearance based on component type
        ConfigureForComponentType(component.GetType());
    }

    private void ConfigureForComponentType(Type componentType)
    {
        // Example: Different configuration for different component types
        if (componentType.IsSubclassOf(typeof(Control)))
        {
            propertyGrid.ToolbarVisible = true;
            propertyGrid.LargeButtons = true;
        }
        else
        {
            propertyGrid.ToolbarVisible = false;
            propertyGrid.LargeButtons = false;
        }

        propertyGrid.PropertySort = PropertySort.CategorizedAlphabetical;
        propertyGrid.HelpVisible = true;
    }
}
```

## Integration Patterns

### Design-Time Property Editing

```csharp
public class ComponentDesigner : Form
{
    private KryptonPropertyGrid propertyGrid;

    public void EditComponent(IComponent component)
    {
        propertyGrid.SelectedObject = component;
        
        // Enable design-time specific features
        propertyGrid.CommandsVisibleIfAvailable = true;
        propertyGrid.CanShowVisualStyleGlyphs = true;
        
        // Configure context for design-time
        SetupDesignTimeContext();
    }

    private void SetupDesignTimeContext()
    {
        // Show design-time specific commands
        propertyGrid.ToolbarVisible = true;
        
        // Enable help pane for designer guidance
        propertyGrid.HelpVisible = true;
    }
}
```

### Runtime Configuration Editor

```csharp
public class ConfigurationEditor : UserControl
{
    private KryptonPropertyGrid configGrid;

    public void EditSettings(SettingsBase settings)
    {
        configGrid.SelectedObject = settings;
        
        // Configure for runtime settings editing
        configGrid.ToolbarVisible = false; // Cleaner appearance
        configGrid.HelpVisible = false; // Reduce UI clutter
        
        // Sort settings logically
        configGrid.PropertySort = PropertySort.CategorizedAlphabetical;
    }

    public void EditMultipleSettings(SettingsBase[] settingsArray)
    {
        // Enable multi-object inspection for comparing settings
        configGrid.SelectedObjects = settingsArray;
        
        // Configure multi-object display
        configGrid.HelpVisible = true; // Show help for multi-object scenarios
    }
}
```

### Dynamic Property Inspection

```csharp
public class DynamicPropertyInspector : UserControl
{
    private KryptonPropertyGrid inspector;
    
    public void InspectObject(object targetObject)
    {
        inspector.SelectedObject = targetObject;
        
        // Configure based on object characteristics
        ConfigureInspection(targetObject);
    }

    private void ConfigureInspection(object target)
    {
        if (target is IComponent component)
        {
            // Enable component-specific features
            inspector.CommandsVisibleIfAvailable = true;
        }
        else
        {
            // Standard object inspection
            inspector.CommandsVisibleIfAvailable = false;
        }

        // Always show categorization for complex objects
        inspector.PropertySort = PropertySort.CategorizedAlphabetical;
        inspector.HelpVisible = true;
    }
}
```

## Event Handling

### Property Change Events

```csharp
public partial class PropertyMonitor : UserControl
{
    private KryptonPropertyGrid monitoredGrid;

    public PropertyMonitor()
    {
        InitializeComponent();
        SetupEventHandling();
    }

    private void SetupEventHandling()
    {
        // Monitor property value changes
        monitoredGrid.PropertyValueChanged += OnPropertyChanged;
        
        // Monitor tab changes
        monitoredGrid.PropertyTabChanged += OnPropertyTabChanged;
        
        // Monitor sort changes
        monitoredGrid.PropertySortChanged += OnPropertySortChanged;
    }

    private void OnPropertyChanged(object? sender, PropertyValueChangedEventArgs e)
    {
        // Track property modifications
        LogPropertyChange(e.PropertyDescriptor.Name, e.OldValue, e.ChangedItem.Value);
        
        // Trigger validation if needed
        ValidateProperty(e.PropertyDescriptor, e.ChangedItem.Value);
    }

    private void OnPropertyTabChanged(object? sender, PropertyTabChangedEventArgs e)
    {
        // Handle tab switching for context-aware help
        UpdateHelpContext(e.Tab);
    }

    private void OnPropertySortChanged(object? sender, EventArgs e)
    {
        // Save user's sorting preference
        SaveSortingPreference(monitoredGrid.PropertySort);
    }
}
```

## Custom Property Tab Integration

```csharp
public class CustomPropertyTab : PropertyTab
{
    public override PropertyDescriptorCollection GetProperties(object component, Attribute[]? attributes)
    {
        var properties = TypeDescriptor.GetProperties(component);
        
        // Filter and customize properties for this tab
        var filteredProps = new List<PropertyDescriptor>();
        
        foreach (PropertyDescriptor prop in properties)
        {
            if (ShouldShowInThisTab(prop))
            {
                filteredProps.Add(prop);
            }
        }
        
        return new PropertyDescriptorCollection(filteredProps.ToArray());
    }

    public override string TabName => "Custom Tab";
}

// Usage
var propertyGrid = new KryptonPropertyGrid();
var customTab = new CustomPropertyTab();
propertyGrid.PropertyTabs?.AddTabProperty(customTab, PropertyTabScope.Component);
```

## Performance Considerations

- **Efficient Rendering**: Custom paint handling prevents flicker
- **Memory Management**: Proper disposal of graphics resources  
- **Theme Switching**: Optimized palette switching without full recreation
- **Context Menu**: Minimal overhead for enhanced context menu features

## Common Issues and Solutions

### Properties Not Showing

**Issue**: SelectedObject properties not visible  
**Solution**: Ensure TypeConverter and Designer configuration:

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class MyCustomObject
{
    [Category("Appearance")]
    [Description("Visible property")]
    public string MyVisibleProperty { get; set; }
}
```

### Theme Not Applied Correctly

**Issue**: Colors not matching theme  
**Solution**: Force theme refresh:

```csharp
propertyGridViewDrawPanel.Recreate();
propertyGrid.Invalidate();
UpdateStateAndPalettes();
```

### Context Menu Reset Not Working

**Issue**: Reset context menu disabled unexpectedly  
**Solution**: Ensure valid reset values:

```csharp
[DefaultValue("Default Value")]
public string MyProperty { get; set; } = "Default Value";
```

## Design-Time Integration

### Visual Studio Designer

- **Designer**: Custom `KryptonPropertyGridDesigner` provides enhanced design-time experience
- **Toolbox**: Available with specialized bitmap representation
- **Property Window**: Comprehensive visual state configuration
- **Containment**: Properly integrates with Visual Studio's designer

### Property Categories

- **Appearance**: Visual properties (`CommandsVisibleIfAvailable`, `HelpVisible`, `LargeButtons`)
- **Behavior**: Functional properties (`PropertySort`, `SelectedObject`)
- **Visuals**: Theme and styling properties (`StateCommon`, `StateNormal`, `AlwaysActive`)

## Migration from Standard PropertyGrid

### Direct Replacement

```csharp
// Old code
PropertyGrid propertyGrid = new PropertyGrid();

// New code
KryptonPropertyGrid propertyGrid = new KryptonPropertyGrid();
```

### Enhanced Features

```csharp
// Standard PropertyGrid (basic)
var standardPg = new PropertyGrid();

// KryptonPropertyGrid (enhanced)
var kryptonPg = new KryptonPropertyGrid
{
    ToolbarVisible = true,
    HelpVisible = true,
    PropertySort = PropertySort.CategorizedAlphabetical,
    CommandsVisibleIfAvailable = true,
    AlwaysActive = false, // Theme-aware activation
    StateNormal = // Full theme control
};
```

## Real-World Integration Examples

### Configuration Property Editor

```csharp
public partial class ConfigPropertyEditor : Form
{
    private KryptonPropertyGrid configGrid;
    private Button applyButton;
    private Button resetButton;

    public ConfigPropertyEditor()
    {
        InitializeComponent();
        SetupPropertyGrid();
    }

    private void SetupPropertyGrid()
    {
        configGrid.PropertyValueChanged += OnConfigChanged;
        configGrid.ToolbarVisible = false; // Use custom buttons instead
        configGrid.HelpVisible = true; // Show descriptions
        configGrid.PropertySort = PropertySort.CategorizedAlphabetical;
    }

    public void EditConfiguration(AppConfig config)
    {
        configGrid.SelectedObject = config;
        UpdateButtonStates();
    }

    private void OnConfigChanged(object? sender, PropertyValueChangedEventArgs e)
    {
        applyButton.Enabled = true;
        resetButton.Enabled = true;
        
        // Track changes for undo functionality
        TrackConfigurationChange(e.PropertyDescriptor.Name, e.OldValue, e.ChangedItem.Value);
    }
}
```

### Component Inspector Form

```csharp
public class ComponentInspector : Form
{
    private KryptonPropertyGrid inspector;
    private ComboBox componentSelector;

    public ComponentInspector()
    {
        InitializeComponent();
    }

    public void InspectComponents(IList<IComponent> components)
    {
        // Populate component selector
        componentSelector.DataSource = components;
        componentSelector.DisplayMember = "GetType().Name";
        
        // Configure inspector for component inspection
        inspector.CommandsVisibleIfAvailable = true;
        inspector.CanShowVisualStyleGlyphs = true;
        inspector.PropertySort = PropertySort.CategorizedAlphabetical;
        
        if (components.Count > 0)
        {
            inspector.SelectedObject = components[0];
        }
    }

    private void ComponentSelector_SelectedIndexChanged(object sender, EventArgs e)
    {
        if (componentSelector.SelectedItem is IComponent selectedComponent)
        {
            inspector.SelectedObject = selectedComponent;
            UpdateComponentContext(selectedComponent);
        }
    }

    private void UpdateComponentContext(IComponent component)
    {
        // Update title and context based on selected component
        Text = $"Inspecting {component.GetType().Name}";
        
        // Configure visual state based on component type
        if (component is Control control)
        {
            inspector.AlwaysActive = control.ContainsFocus;
        }
        else
        {
            inspector.AlwaysActive = false;
        }
    }
}
```