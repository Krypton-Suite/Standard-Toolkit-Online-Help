# KryptonDocking

The `KryptonDocking` library provides a comprehensive docking system that allows users to create flexible, dockable window layouts similar to Visual Studio and other professional development environments.

## Overview

`KryptonDocking` extends the workspace functionality with advanced docking capabilities, allowing users to drag and drop panels, create floating windows, auto-hide panels, and save/restore docking layouts. It provides a complete docking solution that integrates seamlessly with other Krypton components.

## Namespace

```csharp
Krypton.Docking
```

## Key Components

### KryptonSpace
The base class for docking spaces that extends `KryptonWorkspace` with docking-specific functionality.

### KryptonDockspace
A specialized docking space that provides the main docking area for panels.

### KryptonFloatspace
A floating docking space that allows panels to be docked in floating windows.

### KryptonAutoHiddenPanel
A panel that can be auto-hidden and shown when needed.

### KryptonFloatingWindow
A floating window that contains dockable panels.

## Key Features

- **Advanced Docking**: Full docking capabilities with drag-and-drop support
- **Floating Windows**: Support for floating dockable panels
- **Auto-Hide Panels**: Panels that can be auto-hidden and shown on demand
- **Layout Persistence**: Save and restore docking layouts
- **Multiple Docking Areas**: Support for multiple docking spaces
- **Themed Appearance**: Full Krypton theme integration
- **Design-Time Support**: Complete Visual Studio designer integration
- **Performance Optimization**: Efficient docking operations

## Properties

### Docking Behavior

#### AllowPageDrag
```csharp
[Category("Docking")]
[Description("Gets and sets if page dragging is allowed.")]
[DefaultValue(true)]
public bool AllowPageDrag { get; set; }
```

Gets and sets whether page dragging is allowed.

**Default Value**: `true`

#### AllowPageClose
```csharp
[Category("Docking")]
[Description("Gets and sets if page closing is allowed.")]
[DefaultValue(true)]
public bool AllowPageClose { get; set; }
```

Gets and sets whether page closing is allowed.

**Default Value**: `true`

#### AllowPageDropDown
```csharp
[Category("Docking")]
[Description("Gets and sets if page dropdown is allowed.")]
[DefaultValue(true)]
public bool AllowPageDropDown { get; set; }
```

Gets and sets whether page dropdown is allowed.

**Default Value**: `true`

### Auto-Hide Settings

#### AutoHiddenPanel
```csharp
[Category("Auto-Hide")]
[Description("Gets the auto-hidden panel.")]
public KryptonAutoHiddenPanel AutoHiddenPanel { get; }
```

Gets the auto-hidden panel for this docking space.

#### AutoHiddenSlidePanel
```csharp
[Category("Auto-Hide")]
[Description("Gets the auto-hidden slide panel.")]
public KryptonAutoHiddenSlidePanel AutoHiddenSlidePanel { get; }
```

Gets the auto-hidden slide panel for this docking space.

### Floating Windows

#### FloatingWindows
```csharp
[Category("Floating")]
[Description("Collection of floating windows.")]
public KryptonFloatingWindowCollection FloatingWindows { get; }
```

Gets the collection of floating windows.

## Events

### CellGainsFocus
```csharp
[Category("DockableWorkspace")]
[Description("Occurs when the focus moves to be inside the KryptonWorkspaceCell instance.")]
public event EventHandler<WorkspaceCellEventArgs> CellGainsFocus;
```

Occurs when the focus moves to be inside a workspace cell.

### CellLosesFocus
```csharp
[Category("DockableWorkspace")]
[Description("Occurs when the focus moves away from inside the KryptonWorkspaceCell instance.")]
public event EventHandler<WorkspaceCellEventArgs> CellLosesFocus;
```

Occurs when the focus moves away from inside a workspace cell.

### CellPageInserting
```csharp
[Category("DockableWorkspace")]
[Description("Occurs when a page is being inserted into a cell.")]
public event EventHandler<KryptonPageEventArgs> CellPageInserting;
```

Occurs when a page is being inserted into a cell.

### PageCloseRequest
```csharp
[Category("Docking")]
[Description("Occurs when a page requests that it be closed.")]
public event EventHandler<KryptonPageEventArgs> PageCloseRequest;
```

Occurs when a page requests that it be closed.

### PageDropDownRequest
```csharp
[Category("Docking")]
[Description("Occurs when a page requests a dropdown.")]
public event EventHandler<KryptonPageEventArgs> PageDropDownRequest;
```

Occurs when a page requests a dropdown.

### AutoHiddenGroupShowing
```csharp
[Category("Auto-Hide")]
[Description("Occurs when an auto-hidden group is showing.")]
public event EventHandler<KryptonAutoHiddenGroupEventArgs> AutoHiddenGroupShowing;
```

Occurs when an auto-hidden group is showing.

### AutoHiddenGroupHiding
```csharp
[Category("Auto-Hide")]
[Description("Occurs when an auto-hidden group is hiding.")]
public event EventHandler<KryptonAutoHiddenGroupEventArgs> AutoHiddenGroupHiding;
```

Occurs when an auto-hidden group is hiding.

## Methods

### ShowAutoHiddenGroup(KryptonAutoHiddenGroup group)
```csharp
public void ShowAutoHiddenGroup(KryptonAutoHiddenGroup group)
```

Shows the specified auto-hidden group.

### HideAutoHiddenGroup(KryptonAutoHiddenGroup group)
```csharp
public void HideAutoHiddenGroup(KryptonAutoHiddenGroup group)
```

Hides the specified auto-hidden group.

### CreateFloatingWindow()
```csharp
public KryptonFloatingWindow CreateFloatingWindow()
```

Creates a new floating window.

### CloseFloatingWindow(KryptonFloatingWindow window)
```csharp
public void CloseFloatingWindow(KryptonFloatingWindow window)
```

Closes the specified floating window.

### SaveConfigToXml(XmlWriter xmlWriter)
```csharp
public void SaveConfigToXml(XmlWriter xmlWriter)
```

Saves the docking configuration to XML.

### LoadConfigFromXml(XmlReader xmlReader)
```csharp
public void LoadConfigFromXml(XmlReader xmlReader)
```

Loads the docking configuration from XML.

### SaveConfigToFile(string filename)
```csharp
public void SaveConfigToFile(string filename)
```

Saves the docking configuration to a file.

### LoadConfigFromFile(string filename)
```csharp
public void LoadConfigFromFile(string filename)
```

Loads the docking configuration from a file.

## Usage Examples

### Basic Docking Setup
```csharp
// Create a docking space
KryptonDockspace dockspace = new KryptonDockspace();
dockspace.Dock = DockStyle.Fill;

// Create auto-hidden panel
KryptonAutoHiddenPanel autoHiddenPanel = new KryptonAutoHiddenPanel();
autoHiddenPanel.Dock = DockStyle.Left;

// Add to form
form.Controls.Add(dockspace);
form.Controls.Add(autoHiddenPanel);
```

### Creating Dockable Panels
```csharp
// Create a dockable navigator
KryptonDockableNavigator dockableNavigator = new KryptableNavigator();
dockableNavigator.Text = "Toolbox";

// Add pages to the navigator
KryptonPage toolboxPage = new KryptonPage();
toolboxPage.Text = "Toolbox";
dockableNavigator.Pages.Add(toolboxPage);

// Add to docking space
dockspace.AddToWorkspace("Toolbox", dockableNavigator);
```

### Auto-Hide Panels
```csharp
// Create auto-hidden group
KryptonAutoHiddenGroup autoHiddenGroup = new KryptonAutoHiddenGroup();
autoHiddenGroup.Text = "Properties";

// Add pages to auto-hidden group
KryptonPage propertiesPage = new KryptonPage();
propertiesPage.Text = "Properties";
autoHiddenGroup.Pages.Add(propertiesPage);

// Add to auto-hidden panel
autoHiddenPanel.AddToAutoHiddenPanel("Properties", autoHiddenGroup);

// Handle auto-hidden events
dockspace.AutoHiddenGroupShowing += (sender, e) =>
{
    Console.WriteLine($"Auto-hidden group showing: {e.AutoHiddenGroup.Text}");
};

dockspace.AutoHiddenGroupHiding += (sender, e) =>
{
    Console.WriteLine($"Auto-hidden group hiding: {e.AutoHiddenGroup.Text}");
};
```

### Floating Windows
```csharp
// Create a floating window
KryptonFloatingWindow floatingWindow = dockspace.CreateFloatingWindow();
floatingWindow.Text = "Floating Panel";

// Add content to floating window
KryptonDockableNavigator floatingNavigator = new KryptonDockableNavigator();
KryptonPage floatingPage = new KryptonPage();
floatingPage.Text = "Floating Content";
floatingNavigator.Pages.Add(floatingPage);

floatingWindow.AddToWorkspace("Floating", floatingNavigator);

// Show the floating window
floatingWindow.Show();
```

### Docking Events
```csharp
// Handle docking events
dockspace.CellGainsFocus += (sender, e) =>
{
    Console.WriteLine($"Cell gained focus: {e.Cell}");
};

dockspace.CellLosesFocus += (sender, e) =>
{
    Console.WriteLine($"Cell lost focus: {e.Cell}");
};

dockspace.PageCloseRequest += (sender, e) =>
{
    Console.WriteLine($"Page close requested: {e.Page.Text}");
    // Handle page close request
};
```

### Layout Persistence
```csharp
// Save docking layout
string layoutFile = "docking_layout.xml";
dockspace.SaveConfigToFile(layoutFile);

// Load docking layout
dockspace.LoadConfigFromFile(layoutFile);
```

### XML Configuration
```csharp
// Save to XML string
using (StringWriter stringWriter = new StringWriter())
using (XmlWriter xmlWriter = XmlWriter.Create(stringWriter))
{
    dockspace.SaveConfigToXml(xmlWriter);
    string xmlConfig = stringWriter.ToString();
}

// Load from XML string
using (StringReader stringReader = new StringReader(xmlConfig))
using (XmlReader xmlReader = XmlReader.Create(stringReader))
{
    dockspace.LoadConfigFromXml(xmlReader);
}
```

### Multiple Docking Areas
```csharp
// Create multiple docking areas
KryptonDockspace leftDockspace = new KryptonDockspace();
leftDockspace.Dock = DockStyle.Left;

KryptonDockspace rightDockspace = new KryptonDockspace();
rightDockspace.Dock = DockStyle.Right;

KryptonDockspace bottomDockspace = new KryptonDockspace();
bottomDockspace.Dock = DockStyle.Bottom;

// Add to form
form.Controls.Add(leftDockspace);
form.Controls.Add(rightDockspace);
form.Controls.Add(bottomDockspace);
```

### Custom Docking Behavior
```csharp
// Configure docking behavior
dockspace.AllowPageDrag = true;
dockspace.AllowPageClose = true;
dockspace.AllowPageDropDown = true;

// Handle page insertion
dockspace.CellPageInserting += (sender, e) =>
{
    Console.WriteLine($"Page being inserted: {e.Page.Text}");
    // Customize page insertion behavior
};
```

## Design-Time Support

The `KryptonDocking` components include comprehensive design-time support:

- **Docking Designer**: Specialized designer for docking layouts
- **Property Grid**: Full property grid integration
- **Smart Tags**: Quick access to common docking properties
- **Designer Serialization**: Proper serialization of all properties
- **Toolbox Integration**: Available in the Visual Studio toolbox
- **Context Menu**: Right-click context menu for docking operations

## Accessibility

The docking system provides full accessibility support:

- **Screen Reader Support**: Properly announces docking structure and state
- **Keyboard Navigation**: Full keyboard navigation support
- **Focus Management**: Proper focus handling and indicators
- **High Contrast**: Support for high contrast themes
- **Panel Announcements**: Proper announcement of panel changes

## Performance Considerations

- The docking system is optimized for performance with efficient layout calculations
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Docking operations and layout changes are optimized
- Drag-and-drop operations are optimized for smooth performance

## Related Components

- `KryptonDockspace` - Main docking space
- `KryptonFloatspace` - Floating docking space
- `KryptonAutoHiddenPanel` - Auto-hidden panel
- `KryptonFloatingWindow` - Floating window
- `KryptonDockableNavigator` - Dockable navigator
- `KryptonDockableWorkspace` - Dockable workspace
- `KryptonAutoHiddenGroup` - Auto-hidden group
- `KryptonAutoHiddenSlidePanel` - Auto-hidden slide panel
