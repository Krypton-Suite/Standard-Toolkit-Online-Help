# KryptonRibbon

The `KryptonRibbon` class is a comprehensive ribbon control that provides a modern, tabbed interface for organizing application functionality, similar to Microsoft Office applications.

## Overview

`KryptonRibbon` is a sophisticated ribbon control that implements the Microsoft Office-style ribbon interface. It provides a modern, intuitive way to organize application commands and features into logical groups and tabs, with support for quick access toolbar, contextual tabs, and minimized mode.

## Namespace

```csharp
Krypton.Ribbon
```

## Inheritance

```csharp
public class KryptonRibbon : VisualSimple, IMessageFilter
```

## Key Features

- **Tabbed Interface**: Organize functionality into logical tabs
- **Quick Access Toolbar**: Frequently used commands always accessible
- **Contextual Tabs**: Context-sensitive tabs that appear when needed
- **Minimized Mode**: Collapsible ribbon to maximize workspace
- **Button Specifications**: Customizable buttons and controls
- **Themed Appearance**: Full Krypton theme integration
- **Keyboard Navigation**: Full keyboard accessibility support
- **Design-Time Support**: Complete Visual Studio designer integration

## Properties

### Ribbon Structure

#### RibbonTabs
```csharp
[Category("Ribbon")]
[Description("Collection of ribbon tabs.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public KryptonRibbonTabCollection RibbonTabs { get; }
```

Gets access to the collection of ribbon tabs.

#### SelectedTab
```csharp
[Category("Ribbon")]
[Description("Gets and sets the selected tab.")]
[DefaultValue(null)]
public KryptonRibbonTab SelectedTab { get; set; }
```

Gets and sets the currently selected tab.

**Default Value**: `null`

#### SelectedContext
```csharp
[Category("Ribbon")]
[Description("Gets and sets the selected context.")]
[DefaultValue("")]
public string SelectedContext { get; set; }
```

Gets and sets the selected context for contextual tabs.

**Default Value**: `""`

### Quick Access Toolbar

#### QATLocation
```csharp
[Category("Quick Access Toolbar")]
[Description("Gets and sets the location of the quick access toolbar.")]
[DefaultValue(QATLocation.Above)]
public QATLocation QATLocation { get; set; }
```

Gets and sets the location of the quick access toolbar.

**Default Value**: `QATLocation.Above`

#### QATUserChange
```csharp
[Category("Quick Access Toolbar")]
[Description("Gets and sets if the user can change the QAT.")]
[DefaultValue(true)]
public bool QATUserChange { get; set; }
```

Gets and sets whether the user can modify the quick access toolbar.

**Default Value**: `true`

#### QATVisible
```csharp
[Category("Quick Access Toolbar")]
[Description("Gets and sets if the QAT is visible.")]
[DefaultValue(true)]
public bool QATVisible { get; set; }
```

Gets and sets whether the quick access toolbar is visible.

**Default Value**: `true`

### Minimized Mode

#### MinimizedMode
```csharp
[Category("Behavior")]
[Description("Gets and sets if the ribbon is in minimized mode.")]
[DefaultValue(false)]
public bool MinimizedMode { get; set; }
```

Gets and sets whether the ribbon is in minimized mode.

**Default Value**: `false`

#### ShowMinimizeButton
```csharp
[Category("Behavior")]
[Description("Gets and sets if the minimize button is shown.")]
[DefaultValue(true)]
public bool ShowMinimizeButton { get; set; }
```

Gets and sets whether the minimize button is shown.

**Default Value**: `true`

#### HideRibbonSize
```csharp
[Category("Behavior")]
[Description("Gets and sets the size when ribbon is hidden.")]
[DefaultValue(typeof(Size), "0, 0")]
public Size HideRibbonSize { get; set; }
```

Gets and sets the size of the ribbon when it is hidden.

**Default Value**: `Size(0, 0)`

### Button Styles

#### GroupButtonStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the group button style.")]
[DefaultValue(ButtonStyle.LowProfile)]
public ButtonStyle GroupButtonStyle { get; set; }
```

Gets and sets the button style for group buttons.

**Default Value**: `ButtonStyle.LowProfile`

#### GroupClusterButtonStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the group cluster button style.")]
[DefaultValue(ButtonStyle.LowProfile)]
public ButtonStyle GroupClusterButtonStyle { get; set; }
```

Gets and sets the button style for group cluster buttons.

**Default Value**: `ButtonStyle.LowProfile`

#### GroupDialogButtonStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the group dialog button style.")]
[DefaultValue(ButtonStyle.LowProfile)]
public ButtonStyle GroupDialogButtonStyle { get; set; }
```

Gets and sets the button style for group dialog buttons.

**Default Value**: `ButtonStyle.LowProfile`

#### QATButtonStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the QAT button style.")]
[DefaultValue(ButtonStyle.LowProfile)]
public ButtonStyle QATButtonStyle { get; set; }
```

Gets and sets the button style for quick access toolbar buttons.

**Default Value**: `ButtonStyle.LowProfile`

### Appearance

#### BackStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the background style.")]
[DefaultValue(PaletteBackStyle.PanelClient)]
public PaletteBackStyle BackStyle { get; set; }
```

Gets and sets the background style for the ribbon.

**Default Value**: `PaletteBackStyle.PanelClient`

#### BackInactiveStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the inactive background style.")]
[DefaultValue(PaletteBackStyle.PanelAlternate)]
public PaletteBackStyle BackInactiveStyle { get; set; }
```

Gets and sets the inactive background style for the ribbon.

**Default Value**: `PaletteBackStyle.PanelAlternate`

### Button Specifications

#### ButtonSpecs
```csharp
[Category("Visuals")]
[Description("Collection of button specifications.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public RibbonButtonSpecAnyCollection ButtonSpecs { get; }
```

Gets access to the collection of button specifications for the ribbon.

## Events

### SelectedTabChanged
```csharp
[Category("Ribbon")]
[Description("Occurs when the selected tab changes.")]
public event EventHandler SelectedTabChanged;
```

Occurs when the selected tab changes.

### MinimizedChanged
```csharp
[Category("Behavior")]
[Description("Occurs when the minimized state changes.")]
public event EventHandler MinimizedChanged;
```

Occurs when the minimized state changes.

### QATLocationChanged
```csharp
[Category("Quick Access Toolbar")]
[Description("Occurs when the QAT location changes.")]
public event EventHandler QATLocationChanged;
```

Occurs when the quick access toolbar location changes.

### ButtonSpecClick
```csharp
[Category("Action")]
[Description("Occurs when a button specification is clicked.")]
public event EventHandler<ButtonSpecClickEventArgs> ButtonSpecClick;
```

Occurs when a button specification is clicked.

## Methods

### MinimizeRibbon()
```csharp
public void MinimizeRibbon()
```

Minimizes the ribbon to show only the tab headers.

### RestoreRibbon()
```csharp
public void RestoreRibbon()
```

Restores the ribbon from minimized mode.

### ToggleMinimizedMode()
```csharp
public void ToggleMinimizedMode()
```

Toggles the minimized mode of the ribbon.

### ShowContextualTabs(string contextName)
```csharp
public void ShowContextualTabs(string contextName)
```

Shows contextual tabs for the specified context.

### HideContextualTabs(string contextName)
```csharp
public void HideContextualTabs(string contextName)
```

Hides contextual tabs for the specified context.

### ClearContextualTabs()
```csharp
public void ClearContextualTabs()
```

Clears all contextual tabs.

## Usage Examples

### Basic Ribbon Setup
```csharp
// Create a basic ribbon
KryptonRibbon ribbon = new KryptonRibbon();
ribbon.Dock = DockStyle.Top;

// Add tabs
KryptonRibbonTab homeTab = new KryptonRibbonTab();
homeTab.Text = "Home";
ribbon.RibbonTabs.Add(homeTab);

// Add groups to the tab
KryptonRibbonGroup clipboardGroup = new KryptonRibbonGroup();
clipboardGroup.Text = "Clipboard";
homeTab.RibbonGroups.Add(clipboardGroup);
```

### Quick Access Toolbar Configuration
```csharp
// Configure the quick access toolbar
ribbon.QATLocation = QATLocation.Above;
ribbon.QATUserChange = true;
ribbon.QATVisible = true;

// Add items to the QAT
KryptonRibbonQATButton saveButton = new KryptonRibbonQATButton();
saveButton.Text = "Save";
ribbon.QATButtons.Add(saveButton);
```

### Contextual Tabs
```csharp
// Create contextual tabs
KryptonRibbonContext pictureContext = new KryptonRibbonContext();
pictureContext.ContextName = "PictureTools";
pictureContext.ContextTitle = "Picture Tools";

KryptonRibbonTab formatTab = new KryptonRibbonTab();
formatTab.Text = "Format";
formatTab.ContextName = "PictureTools";
pictureContext.RibbonTabs.Add(formatTab);

ribbon.RibbonContexts.Add(pictureContext);

// Show contextual tabs when needed
ribbon.ShowContextualTabs("PictureTools");
```

### Minimized Mode
```csharp
// Configure minimized mode
ribbon.ShowMinimizeButton = true;
ribbon.MinimizedMode = false;

// Handle minimized state changes
ribbon.MinimizedChanged += (sender, e) =>
{
    if (ribbon.MinimizedMode)
    {
        Console.WriteLine("Ribbon minimized");
    }
    else
    {
        Console.WriteLine("Ribbon restored");
    }
};
```

### Custom Button Specifications
```csharp
// Add custom buttons to the ribbon
ButtonSpecAny customButton = new ButtonSpecAny();
customButton.Type = PaletteButtonSpecStyle.PendantClose;
customButton.Text = "Custom";
customButton.Click += (sender, e) => MessageBox.Show("Custom button clicked!");
ribbon.ButtonSpecs.Add(customButton);
```

### Tab Selection
```csharp
// Handle tab selection changes
ribbon.SelectedTabChanged += (sender, e) =>
{
    Console.WriteLine($"Selected tab: {ribbon.SelectedTab?.Text}");
};

// Programmatically select a tab
if (ribbon.RibbonTabs.Count > 0)
{
    ribbon.SelectedTab = ribbon.RibbonTabs[0];
}
```

### Custom Styling
```csharp
// Customize ribbon appearance
ribbon.BackStyle = PaletteBackStyle.PanelClient;
ribbon.GroupButtonStyle = ButtonStyle.LowProfile;
ribbon.QATButtonStyle = ButtonStyle.LowProfile;
```

## Design-Time Support

The `KryptonRibbon` control includes comprehensive design-time support:

- **Ribbon Designer**: Specialized designer for ribbon layout
- **Property Grid**: Full property grid integration
- **Smart Tags**: Quick access to common ribbon properties
- **Designer Serialization**: Proper serialization of all properties
- **Toolbox Integration**: Available in the Visual Studio toolbox
- **Context Menu**: Right-click context menu for ribbon operations

## Accessibility

The control provides full accessibility support:

- **Screen Reader Support**: Properly announces ribbon structure and state
- **Keyboard Navigation**: Full keyboard navigation with arrow keys and Tab
- **Key Tips**: Alt key navigation support
- **Focus Management**: Proper focus handling and indicators
- **High Contrast**: Support for high contrast themes

## Performance Considerations

- The ribbon is optimized for performance with efficient rendering
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Tab switching and contextual tab management are optimized

## Related Components

- `KryptonRibbonTab` - Individual ribbon tab
- `KryptonRibbonGroup` - Group of controls within a tab
- `KryptonRibbonContext` - Contextual tab collection
- `KryptonRibbonQATButton` - Quick access toolbar button
- `ButtonSpecAny` - Button specification for custom buttons
- `QATLocation` - Quick access toolbar location enumeration
