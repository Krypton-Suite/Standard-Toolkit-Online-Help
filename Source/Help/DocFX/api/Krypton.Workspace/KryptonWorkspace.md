# KryptonWorkspace

The `KryptonWorkspace` class is a sophisticated layout control that manages a hierarchy of `KryptonNavigator` instances, providing a flexible docking and layout system similar to Visual Studio's workspace.

## Overview

`KryptonWorkspace` is a powerful layout control that provides a flexible docking and workspace management system. It allows you to create complex multi-pane layouts with resizable panels, docking capabilities, and workspace persistence. It's designed to work seamlessly with `KryptonNavigator` controls to create professional development environments.

## Namespace

```csharp
Krypton.Workspace
```

## Inheritance

```csharp
public class KryptonWorkspace : VisualContainerControl, IDragTargetProvider
```

## Key Features

- **Flexible Layout System**: Hierarchical layout of navigator instances
- **Docking Support**: Full docking capabilities for panels
- **Resizable Panels**: Adjustable panel sizes with splitters
- **Workspace Persistence**: Save and restore workspace layouts
- **Maximized Mode**: Support for maximized panels
- **Context Menus**: Built-in context menu support
- **Drag and Drop**: Full drag-and-drop support for panel management
- **Themed Appearance**: Full Krypton theme integration
- **Design-Time Support**: Complete Visual Studio designer integration

## Properties

### Workspace Structure

#### Root
```csharp
[Category("Workspace")]
[Description("Gets and sets the root workspace sequence.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public KryptonWorkspaceSequence Root { get; set; }
```

Gets and sets the root workspace sequence that defines the layout hierarchy.

#### ActiveCell
```csharp
[Category("Workspace")]
[Description("Gets and sets the active workspace cell.")]
[DefaultValue(null)]
public KryptonWorkspaceCell ActiveCell { get; set; }
```

Gets and sets the currently active workspace cell.

**Default Value**: `null`

#### MaximizedCell
```csharp
[Category("Workspace")]
[Description("Gets and sets the maximized workspace cell.")]
[DefaultValue(null)]
public KryptonWorkspaceCell MaximizedCell { get; set; }
```

Gets and sets the currently maximized workspace cell.

**Default Value**: `null`

### Behavior Settings

#### AllowResizing
```csharp
[Category("Behavior")]
[Description("Gets and sets if resizing is allowed.")]
[DefaultValue(true)]
public bool AllowResizing { get; set; }
```

Gets and sets whether panel resizing is allowed.

**Default Value**: `true`

#### ShowMaximizeButton
```csharp
[Category("Behavior")]
[Description("Gets and sets if maximize buttons are shown.")]
[DefaultValue(true)]
public bool ShowMaximizeButton { get; set; }
```

Gets and sets whether maximize buttons are shown on panels.

**Default Value**: `true`

#### SplitterWidth
```csharp
[Category("Behavior")]
[Description("Gets and sets the width of splitters.")]
[DefaultValue(4)]
public int SplitterWidth { get; set; }
```

Gets and sets the width of splitters between panels.

**Default Value**: `4`

### Appearance

#### SeparatorStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the separator style.")]
[DefaultValue(SeparatorStyle.LowProfile)]
public SeparatorStyle SeparatorStyle { get; set; }
```

Gets and sets the style of separators between panels.

**Default Value**: `SeparatorStyle.LowProfile`

#### CompactFlags
```csharp
[Category("Behavior")]
[Description("Gets and sets the compact flags.")]
[DefaultValue(CompactFlags.All)]
public CompactFlags CompactFlags { get; set; }
```

Gets and sets the compact flags that control workspace behavior.

**Default Value**: `CompactFlags.All`

## Events

### WorkspaceCellAdded
```csharp
[Category("Workspace")]
[Description("Occurs when a workspace cell is added.")]
public event EventHandler<KryptonWorkspaceCellEventArgs> WorkspaceCellAdded;
```

Occurs when a workspace cell is added to the workspace.

### WorkspaceCellRemoved
```csharp
[Category("Workspace")]
[Description("Occurs when a workspace cell is removed.")]
public event EventHandler<KryptonWorkspaceCellEventArgs> WorkspaceCellRemoved;
```

Occurs when a workspace cell is removed from the workspace.

### ActiveCellChanged
```csharp
[Category("Workspace")]
[Description("Occurs when the active cell changes.")]
public event EventHandler ActiveCellChanged;
```

Occurs when the active cell changes.

### MaximizedCellChanged
```csharp
[Category("Workspace")]
[Description("Occurs when the maximized cell changes.")]
public event EventHandler MaximizedCellChanged;
```

Occurs when the maximized cell changes.

### PageCloseRequest
```csharp
[Category("Workspace")]
[Description("Occurs when a page close is requested.")]
public event EventHandler<KryptonPageEventArgs> PageCloseRequest;
```

Occurs when a page close is requested.

### PageDropDown
```csharp
[Category("Workspace")]
[Description("Occurs when a page dropdown is requested.")]
public event EventHandler<KryptonPageEventArgs> PageDropDown;
```

Occurs when a page dropdown is requested.

### CellDropDown
```csharp
[Category("Workspace")]
[Description("Occurs when a cell dropdown is requested.")]
public event EventHandler<KryptonWorkspaceCellEventArgs> CellDropDown;
```

Occurs when a cell dropdown is requested.

### WorkspaceDropDown
```csharp
[Category("Workspace")]
[Description("Occurs when a workspace dropdown is requested.")]
public event EventHandler WorkspaceDropDown;
```

Occurs when a workspace dropdown is requested.

## Methods

### MaximizeCell(KryptonWorkspaceCell cell)
```csharp
public void MaximizeCell(KryptonWorkspaceCell cell)
```

Maximizes the specified workspace cell.

### RestoreCell(KryptonWorkspaceCell cell)
```csharp
public void RestoreCell(KryptonWorkspaceCell cell)
```

Restores the specified workspace cell from maximized state.

### CloseCell(KryptonWorkspaceCell cell)
```csharp
public void CloseCell(KryptonWorkspaceCell cell)
```

Closes the specified workspace cell.

### CloseAllCells()
```csharp
public void CloseAllCells()
```

Closes all workspace cells.

### CloseAllCellsButThis(KryptonWorkspaceCell cell)
```csharp
public void CloseAllCellsButThis(KryptonWorkspaceCell cell)
```

Closes all workspace cells except the specified one.

### ShowContextMenu(Point screenPoint)
```csharp
public void ShowContextMenu(Point screenPoint)
```

Shows the context menu at the specified screen point.

### ShowContextMenu(KryptonWorkspaceCell cell, Point screenPoint)
```csharp
public void ShowContextMenu(KryptonWorkspaceCell cell, Point screenPoint)
```

Shows the context menu for the specified cell at the specified screen point.

### SaveConfigToXml(XmlWriter xmlWriter)
```csharp
public void SaveConfigToXml(XmlWriter xmlWriter)
```

Saves the workspace configuration to XML.

### LoadConfigFromXml(XmlReader xmlReader)
```csharp
public void LoadConfigFromXml(XmlReader xmlReader)
```

Loads the workspace configuration from XML.

### SaveConfigToFile(string filename)
```csharp
public void SaveConfigToFile(string filename)
```

Saves the workspace configuration to a file.

### LoadConfigFromFile(string filename)
```csharp
public void LoadConfigFromFile(string filename)
```

Loads the workspace configuration from a file.

## Usage Examples

### Basic Workspace Setup
```csharp
// Create a basic workspace
KryptonWorkspace workspace = new KryptonWorkspace();
workspace.Dock = DockStyle.Fill;

// Create the root sequence
KryptonWorkspaceSequence rootSequence = new KryptonWorkspaceSequence(Orientation.Horizontal);
workspace.Root = rootSequence;

// Add cells to the workspace
KryptonWorkspaceCell leftCell = new KryptonWorkspaceCell();
KryptonWorkspaceCell rightCell = new KryptonWorkspaceCell();

rootSequence.Children.Add(leftCell);
rootSequence.Children.Add(rightCell);
```

### Horizontal Layout
```csharp
// Create a horizontal layout
KryptonWorkspaceSequence horizontalSequence = new KryptonWorkspaceSequence(Orientation.Horizontal);

// Add cells with specific sizes
KryptonWorkspaceCell leftCell = new KryptonWorkspaceCell();
leftCell.StarSize = new StarNumber(1);

KryptonWorkspaceCell rightCell = new KryptonWorkspaceCell();
rightCell.StarSize = new StarNumber(2);

horizontalSequence.Children.Add(leftCell);
horizontalSequence.Children.Add(rightCell);

workspace.Root = horizontalSequence;
```

### Vertical Layout
```csharp
// Create a vertical layout
KryptonWorkspaceSequence verticalSequence = new KryptonWorkspaceSequence(Orientation.Vertical);

// Add cells with specific sizes
KryptonWorkspaceCell topCell = new KryptonWorkspaceCell();
topCell.StarSize = new StarNumber(1);

KryptonWorkspaceCell bottomCell = new KryptonWorkspaceCell();
bottomCell.StarSize = new StarNumber(1);

verticalSequence.Children.Add(topCell);
verticalSequence.Children.Add(bottomCell);

workspace.Root = verticalSequence;
```

### Complex Layout
```csharp
// Create a complex layout with nested sequences
KryptonWorkspaceSequence rootSequence = new KryptonWorkspaceSequence(Orientation.Horizontal);

// Left side - vertical stack
KryptonWorkspaceSequence leftSequence = new KryptonWorkspaceSequence(Orientation.Vertical);
KryptonWorkspaceCell leftTopCell = new KryptonWorkspaceCell();
KryptonWorkspaceCell leftBottomCell = new KryptonWorkspaceCell();
leftSequence.Children.Add(leftTopCell);
leftSequence.Children.Add(leftBottomCell);

// Right side - single cell
KryptonWorkspaceCell rightCell = new KryptonWorkspaceCell();

// Set star sizes for proportional sizing
leftSequence.StarSize = new StarNumber(1);
rightCell.StarSize = new StarNumber(2);

rootSequence.Children.Add(leftSequence);
rootSequence.Children.Add(rightCell);

workspace.Root = rootSequence;
```

### Adding Navigators to Cells
```csharp
// Add navigators to workspace cells
KryptonNavigator leftNavigator = new KryptonNavigator();
leftNavigator.Mode = NavigatorMode.BarTabGroup;

KryptonNavigator rightNavigator = new KryptonNavigator();
rightNavigator.Mode = NavigatorMode.BarTabGroup;

// Add pages to navigators
KryptonPage leftPage = new KryptonPage();
leftPage.Text = "Left Panel";
leftNavigator.Pages.Add(leftPage);

KryptonPage rightPage = new KryptonPage();
rightPage.Text = "Right Panel";
rightNavigator.Pages.Add(rightPage);

// Add navigators to cells
leftCell.Pages.Add(leftNavigator);
rightCell.Pages.Add(rightNavigator);
```

### Maximized Mode
```csharp
// Handle maximized mode
workspace.MaximizedCellChanged += (sender, e) =>
{
    if (workspace.MaximizedCell != null)
    {
        Console.WriteLine($"Cell maximized: {workspace.MaximizedCell}");
    }
    else
    {
        Console.WriteLine("No cell maximized");
    }
};

// Maximize a cell
workspace.MaximizeCell(leftCell);

// Restore a cell
workspace.RestoreCell(leftCell);
```

### Active Cell Management
```csharp
// Handle active cell changes
workspace.ActiveCellChanged += (sender, e) =>
{
    Console.WriteLine($"Active cell: {workspace.ActiveCell}");
};

// Set active cell
workspace.ActiveCell = rightCell;
```

### Context Menus
```csharp
// Handle context menu requests
workspace.CellDropDown += (sender, e) =>
{
    Point screenPoint = Control.MousePosition;
    workspace.ShowContextMenu(e.Cell, screenPoint);
};

workspace.PageDropDown += (sender, e) =>
{
    Point screenPoint = Control.MousePosition;
    // Show page-specific context menu
};
```

### Workspace Persistence
```csharp
// Save workspace configuration
string configFile = "workspace_config.xml";
workspace.SaveConfigToFile(configFile);

// Load workspace configuration
workspace.LoadConfigFromFile(configFile);
```

### XML Configuration
```csharp
// Save to XML string
using (StringWriter stringWriter = new StringWriter())
using (XmlWriter xmlWriter = XmlWriter.Create(stringWriter))
{
    workspace.SaveConfigToXml(xmlWriter);
    string xmlConfig = stringWriter.ToString();
}

// Load from XML string
using (StringReader stringReader = new StringReader(xmlConfig))
using (XmlReader xmlReader = XmlReader.Create(stringReader))
{
    workspace.LoadConfigFromXml(xmlReader);
}
```

### Cell Management
```csharp
// Close specific cell
workspace.CloseCell(leftCell);

// Close all cells except one
workspace.CloseAllCellsButThis(rightCell);

// Close all cells
workspace.CloseAllCells();
```

## Design-Time Support

The `KryptonWorkspace` control includes comprehensive design-time support:

- **Workspace Designer**: Specialized designer for workspace layout
- **Property Grid**: Full property grid integration
- **Smart Tags**: Quick access to common workspace properties
- **Designer Serialization**: Proper serialization of all properties
- **Toolbox Integration**: Available in the Visual Studio toolbox
- **Context Menu**: Right-click context menu for workspace operations

## Accessibility

The control provides full accessibility support:

- **Screen Reader Support**: Properly announces workspace structure and state
- **Keyboard Navigation**: Full keyboard navigation support
- **Focus Management**: Proper focus handling and indicators
- **High Contrast**: Support for high contrast themes
- **Panel Announcements**: Proper announcement of panel changes

## Performance Considerations

- The workspace is optimized for performance with efficient layout calculations
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Layout changes and cell management are optimized
- Drag-and-drop operations are optimized for smooth performance

## Related Components

- `KryptonWorkspaceSequence` - Workspace sequence for layout organization
- `KryptonWorkspaceCell` - Individual workspace cell
- `KryptonNavigator` - Navigator control for cell content
- `KryptonPage` - Page content for navigators
- `SeparatorStyle` - Separator style enumeration
- `CompactFlags` - Compact flags enumeration
- `Orientation` - Layout orientation enumeration
