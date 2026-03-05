# KryptonFloatingMenuAndToolbars

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Core Components](#core-components)
4. [API Reference](#api-reference)
5. [Features](#features)
6. [Usage Guide](#usage-guide)
7. [Designer Integration](#designer-integration)
8. [Best Practices](#best-practices)
9. [Troubleshooting](#troubleshooting)
10. [Examples](#examples)

---

## Overview

The **KryptonFloatingMenuAndToolbars** feature provides a comprehensive solution for creating dockable and floatable toolbars and menu strips in Windows Forms applications using the Krypton Toolkit. This feature allows users to drag toolbars and menu strips out of their docked positions and float them as separate windows, then dock them back into designated panel areas.

### Key Capabilities

- **Drag-and-Drop Floating**: Users can drag toolbars/menu strips by their grip handles to float them as separate windows
- **Automatic Docking**: Floating toolbars automatically dock when dragged over designated panel areas
- **Panel Management**: Extended panel controls provide docking zones for toolbars and menu strips
- **Visual Feedback**: Smooth transitions between docked and floating states
- **Designer Support**: Full Visual Studio designer integration with collection editors

### Use Cases

- Applications requiring customizable toolbar layouts
- MDI applications with multiple document windows
- Professional software with advanced UI customization
- Applications where users need to reorganize their workspace

---

## Architecture

The KryptonFloatingMenuAndToolbars feature consists of several interconnected components:

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Form                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  KryptonToolStripPanelExtended /                     │  │
│  │  KryptonMenuStripPanelExtended                       │  │
│  │  (Docking Zones)                                     │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  KryptonFloatableToolStrip /                         │  │
│  │  KryptonFloatableMenuStrip                           │  │
│  │  (Floatable Controls)                                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                          │
                          │ (when floating)
                          ▼
┌─────────────────────────────────────────────────────────────┐
│  VisualToolStripContainerForm /                            │
│  VisualMenuStripContainerForm                              │
│  (Floating Window Container)                               │
└─────────────────────────────────────────────────────────────┘
```

### Component Relationships

1. **Floatable Controls** (`KryptonFloatableToolStrip`, `KryptonFloatableMenuStrip`)
   - Extend standard Krypton toolstrip controls
   - Handle mouse events for drag-to-float functionality
   - Manage floating state and container forms

2. **Panel Extensions** (`KryptonToolStripPanelExtended`, `KryptonMenuStripPanelExtended`)
   - Extend `ToolStripPanel` with active docking zones
   - Calculate active rectangles for docking detection
   - Manage layout styles based on orientation

3. **Container Forms** (`VisualToolStripContainerForm`, `VisualMenuStripContainerForm`)
   - Host floating toolbars/menu strips
   - Provide window chrome and resize constraints
   - Handle window events (close, double-click to dock)

4. **Designer Support** (Collection Editors)
   - Visual Studio designer integration
   - Component chooser dialogs for panel selection

---

## Core Components

### KryptonFloatableToolStrip

A `KryptonToolStrip` that can be dragged to float as a separate window and docked back into designated panels.

**Inheritance Hierarchy:**
```
KryptonToolStrip → KryptonFloatableToolStrip
```

**Key Features:**
- Drag-to-float via grip handle
- Automatic docking detection
- Panel collection management
- Floating state tracking

### KryptonFloatableMenuStrip

A `KryptonMenuStrip` that can be dragged to float as a separate window and docked back into designated panels.

**Inheritance Hierarchy:**
```
KryptonMenuStrip → KryptonFloatableMenuStrip
```

**Key Features:**
- Drag-to-float via grip handle
- Configurable window control box
- Customizable floating window text
- Panel collection management

### KryptonToolStripPanelExtended

An extended `ToolStripPanel` that provides docking zones for `KryptonFloatableToolStrip` controls.

**Inheritance Hierarchy:**
```
ToolStripPanel → KryptonToolStripPanelExtended
```

**Key Features:**
- Active rectangle calculation for docking detection
- Automatic layout style management
- Orientation-aware sizing

### KryptonMenuStripPanelExtended

An extended `ToolStripPanel` that provides docking zones for `KryptonFloatableMenuStrip` controls.

**Inheritance Hierarchy:**
```
ToolStripPanel → KryptonMenuStripPanelExtended
```

**Key Features:**
- Active rectangle calculation for docking detection
- Menu strip-specific layout management
- Reference to associated menu strip

### KryptonFloatablePanelHost

A flexible panel host that can accommodate both tool strips and menu strips.

**Inheritance Hierarchy:**
```
ToolStripPanel → KryptonFloatablePanelHost
```

**Key Features:**
- Dual support for tool strips and menu strips
- Active area calculation
- Orientation-aware layout

---

## API Reference

### KryptonFloatableToolStrip

#### Properties

##### `KryptonToolStripPanelExtendedList`
```csharp
[Editor(typeof(KryptonToolStripPanelCollectionEditor), typeof(UITypeEditor))]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public List<KryptonToolStripPanelExtended> KryptonToolStripPanelExtendedList { get; set; }
```
Gets or sets the list of `KryptonToolStripPanelExtended` panels where this toolbar can dock.

**Usage:**
```csharp
toolStrip.KryptonToolStripPanelExtendedList.Add(panel1);
toolStrip.KryptonToolStripPanelExtendedList.Add(panel2);
```

##### `IsFloating`
```csharp
public bool IsFloating { get; }
```
Gets a value indicating whether the toolbar is currently floating.

**Returns:** `true` if floating; otherwise, `false`.

**Usage:**
```csharp
if (toolStrip.IsFloating)
{
    // Handle floating state
}
```

##### `Visible`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new bool Visible { get; set; }
```
Gets or sets the visibility of the control. When floating, controls the container form visibility.

**Usage:**
```csharp
toolStrip.Visible = false; // Hides toolbar whether docked or floating
```

##### `FloatingToolBarWindowText`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public string FloatingToolBarWindowText { get; set; }
```
Gets or sets the text displayed in the floating window title bar.

**Default:** `"Tool Bar"`

**Usage:**
```csharp
toolStrip.FloatingToolBarWindowText = "My Custom Toolbar";
```

##### `EnableAnimation`
```csharp
[DefaultValue(true)]
public bool EnableAnimation { get; set; }
```
Gets or sets a value indicating whether animation is enabled during dock/float transitions.

**Default:** `true`

**Usage:**
```csharp
toolStrip.EnableAnimation = true; // Enable smooth animations
toolStrip.EnableAnimation = false; // Instant transitions
```

##### `AnimationDuration`
```csharp
[DefaultValue(200)]
public int AnimationDuration { get; set; }
```
Gets or sets the duration of dock/float animations in milliseconds.

**Default:** `200`

**Usage:**
```csharp
toolStrip.AnimationDuration = 300; // 300ms animation
toolStrip.AnimationDuration = 0; // No animation (same as EnableAnimation = false)
```

##### `FloatingWindowStyle`
```csharp
[DefaultValue(FloatingWindowStyle.Default)]
public FloatingWindowStyle FloatingWindowStyle { get; set; }
```
Gets or sets the style of the floating window.

**Default:** `FloatingWindowStyle.Default`

**Available Styles:**
- `Default`: Standard window with full chrome
- `Minimal`: No border or title bar
- `ToolWindow`: Smaller title bar, tool window style
- `Custom`: For future customization options

**Usage:**
```csharp
toolStrip.FloatingWindowStyle = FloatingWindowStyle.Minimal;
toolStrip.FloatingWindowStyle = FloatingWindowStyle.ToolWindow;
```

#### Internal Properties

##### `OriginalParent`
```csharp
internal Control? OriginalParent { get; }
```
Gets the original parent control before floating. Used internally for restoration.

#### Events

##### `FloatingStateChanged`
```csharp
public event EventHandler<FloatingStateChangedEventArgs>? FloatingStateChanged;
```
Occurs when the floating state of the toolbar changes (becomes floating or docked).

**Event Args:** `FloatingStateChangedEventArgs` containing `IsFloating` property.

**Usage:**
```csharp
toolStrip.FloatingStateChanged += (sender, e) =>
{
    if (e.IsFloating)
    {
        // Toolbar is now floating
    }
    else
    {
        // Toolbar is now docked
    }
};
```

The control also inherits all standard `KryptonToolStrip` events and handles:

- **Mouse Events**: `OnMouseDown`, `OnMouseUp`, `OnMouseEnter` - Handle drag-to-float
- **Parent Changed**: `OnParentChanged` - Tracks parent changes during docking/floating

#### Methods

##### `Float(Point?)`
```csharp
public bool Float(Point? location = null)
```
Programmatically floats the toolbar at the specified location.

**Parameters:**
- `location` (optional): The screen location where the floating window should appear. If `null`, uses current control location.

**Returns:** `true` if the toolbar was successfully floated; `false` if it was already floating or cannot be floated.

**Usage:**
```csharp
// Float at current location
toolStrip.Float();

// Float at specific location
toolStrip.Float(new Point(100, 100));
```

##### `Dock(KryptonToolStripPanelExtended?)`
```csharp
public bool Dock(KryptonToolStripPanelExtended? targetPanel = null)
```
Programmatically docks the toolbar to the specified panel or original parent.

**Parameters:**
- `targetPanel` (optional): The panel to dock to. If `null`, docks to original parent.

**Returns:** `true` if the toolbar was successfully docked; `false` if it was not floating or cannot be docked.

**Usage:**
```csharp
// Dock to original parent
toolStrip.Dock();

// Dock to specific panel
toolStrip.Dock(targetPanel);
```

##### `SaveState()`
```csharp
public FloatingToolbarState? SaveState()
```
Saves the current floating state to a `FloatingToolbarState` object.

**Returns:** A `FloatingToolbarState` object containing the current state, or `null` if the control has no name.

**Usage:**
```csharp
// Ensure toolbar has a name
toolStrip.Name = "MainToolbar";

// Save state
var state = toolStrip.SaveState();
if (state != null)
{
    // Save to file or store in settings
    FloatingToolbarStateManager.SaveStatesToFile(new[] { state }, "states.xml");
}
```

##### `LoadState(FloatingToolbarState?)`
```csharp
public bool LoadState(FloatingToolbarState? state)
```
Loads a floating state from a `FloatingToolbarState` object.

**Parameters:**
- `state`: The `FloatingToolbarState` object to load.

**Returns:** `true` if the state was loaded successfully; otherwise, `false`.

**Usage:**
```csharp
// Load from file
var collection = FloatingToolbarStateManager.LoadStatesFromFile("states.xml");
if (collection != null)
{
    var state = collection.ToolbarStates.FirstOrDefault(s => s.Name == "MainToolbar");
    toolStrip.LoadState(state);
}
```

##### `OnFloatingStateChanged(bool)`
```csharp
protected virtual void OnFloatingStateChanged(bool isFloating)
```
Raises the `FloatingStateChanged` event. Can be overridden in derived classes.

**Parameters:**
- `isFloating`: `true` if the toolbar is now floating; `false` if docked.

#### Override Methods

##### `OnMouseDown(MouseEventArgs)`
```csharp
protected override void OnMouseDown(MouseEventArgs mea)
```
Handles mouse down events. Initiates floating when grip handle is clicked.

##### `OnMouseUp(MouseEventArgs)`
```csharp
protected override void OnMouseUp(MouseEventArgs mea)
```
Handles mouse up events. Creates floating window if dragged outside original parent.

##### `OnParentChanged(EventArgs)`
```csharp
protected override void OnParentChanged(EventArgs e)
```
Tracks parent changes and stores original parent reference.

---

### KryptonFloatableMenuStrip

#### Properties

##### `MenuStripPanelExtendedList`
```csharp
[Editor(typeof(KryptonMenuStripPanelCollectionEditor), typeof(UITypeEditor))]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public List<KryptonMenuStripPanelExtended>? MenuStripPanelExtendedList { get; set; }
```
Gets or sets the list of `KryptonMenuStripPanelExtended` panels where this menu strip can dock.

**Usage:**
```csharp
menuStrip.MenuStripPanelExtendedList = new List<KryptonMenuStripPanelExtended> { panel1, panel2 };
```

##### `IsFloating`
```csharp
public bool IsFloating { get; }
```
Gets a value indicating whether the menu strip is currently floating.

**Returns:** `true` if floating; otherwise, `false`.

##### `Visible`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new bool Visible { get; set; }
```
Gets or sets the visibility of the control. When floating, controls the container form visibility.

##### `ShowFloatingWindowControlBox`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool ShowFloatingWindowControlBox { get; set; }
```
Gets or sets whether the floating window displays a control box (minimize/maximize/close buttons).

**Default:** `true`

**Usage:**
```csharp
menuStrip.ShowFloatingWindowControlBox = false; // Hide control box
```

##### `FloatingWindowText`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public string FloatingWindowText { get; set; }
```
Gets or sets the text displayed in the floating window title bar.

**Default:** `"Menu"`

**Usage:**
```csharp
menuStrip.FloatingWindowText = "Main Menu";
```

##### `EnableAnimation`
```csharp
[DefaultValue(true)]
public bool EnableAnimation { get; set; }
```
Gets or sets a value indicating whether animation is enabled during dock/float transitions.

**Default:** `true`

**Usage:**
```csharp
menuStrip.EnableAnimation = true; // Enable smooth animations
menuStrip.EnableAnimation = false; // Instant transitions
```

##### `AnimationDuration`
```csharp
[DefaultValue(200)]
public int AnimationDuration { get; set; }
```
Gets or sets the duration of dock/float animations in milliseconds.

**Default:** `200`

**Usage:**
```csharp
menuStrip.AnimationDuration = 300; // 300ms animation
menuStrip.AnimationDuration = 0; // No animation
```

##### `FloatingWindowStyle`
```csharp
[DefaultValue(FloatingWindowStyle.Default)]
public FloatingWindowStyle FloatingWindowStyle { get; set; }
```
Gets or sets the style of the floating window.

**Default:** `FloatingWindowStyle.Default`

**Available Styles:**
- `Default`: Standard window with full chrome
- `Minimal`: No border or title bar
- `ToolWindow`: Smaller title bar, tool window style
- `Custom`: For future customization options

**Usage:**
```csharp
menuStrip.FloatingWindowStyle = FloatingWindowStyle.Minimal;
menuStrip.FloatingWindowStyle = FloatingWindowStyle.ToolWindow;
```

#### Events

##### `FloatingStateChanged`
```csharp
public event EventHandler<FloatingStateChangedEventArgs>? FloatingStateChanged;
```
Occurs when the floating state of the menu strip changes (becomes floating or docked).

**Event Args:** `FloatingStateChangedEventArgs` containing `IsFloating` property.

**Usage:**
```csharp
menuStrip.FloatingStateChanged += (sender, e) =>
{
    if (e.IsFloating)
    {
        // Menu strip is now floating
    }
    else
    {
        // Menu strip is now docked
    }
};
```

#### Methods

##### `Float(Point?)`
```csharp
public bool Float(Point? location = null)
```
Programmatically floats the menu strip at the specified location.

**Parameters:**
- `location` (optional): The screen location where the floating window should appear. If `null`, uses current control location.

**Returns:** `true` if the menu strip was successfully floated; `false` if it was already floating or cannot be floated.

**Usage:**
```csharp
// Float at current location
menuStrip.Float();

// Float at specific location
menuStrip.Float(new Point(100, 100));
```

##### `Dock(KryptonMenuStripPanelExtended?)`
```csharp
public bool Dock(KryptonMenuStripPanelExtended? targetPanel = null)
```
Programmatically docks the menu strip to the specified panel or original parent.

**Parameters:**
- `targetPanel` (optional): The panel to dock to. If `null`, docks to original parent.

**Returns:** `true` if the menu strip was successfully docked; `false` if it was not floating or cannot be docked.

**Usage:**
```csharp
// Dock to original parent
menuStrip.Dock();

// Dock to specific panel
menuStrip.Dock(targetPanel);
```

##### `SaveState()`
```csharp
public FloatingToolbarState? SaveState()
```
Saves the current floating state to a `FloatingToolbarState` object.

**Returns:** A `FloatingToolbarState` object containing the current state, or `null` if the control has no name.

**Usage:**
```csharp
// Ensure menu strip has a name
menuStrip.Name = "MainMenu";

// Save state
var state = menuStrip.SaveState();
if (state != null)
{
    FloatingToolbarStateManager.SaveStatesToFile(new[] { state }, "states.xml");
}
```

##### `LoadState(FloatingToolbarState?)`
```csharp
public bool LoadState(FloatingToolbarState? state)
```
Loads a floating state from a `FloatingToolbarState` object.

**Parameters:**
- `state`: The `FloatingToolbarState` object to load.

**Returns:** `true` if the state was loaded successfully; otherwise, `false`.

**Usage:**
```csharp
// Load from file
var collection = FloatingToolbarStateManager.LoadStatesFromFile("states.xml");
if (collection != null)
{
    var state = collection.ToolbarStates.FirstOrDefault(s => s.Name == "MainMenu");
    menuStrip.LoadState(state);
}
```

##### `OnFloatingStateChanged(bool)`
```csharp
protected virtual void OnFloatingStateChanged(bool isFloating)
```
Raises the `FloatingStateChanged` event. Can be overridden in derived classes.

**Parameters:**
- `isFloating`: `true` if the menu strip is now floating; `false` if docked.

#### Constructor

##### `KryptonFloatableMenuStrip()`
```csharp
public KryptonFloatableMenuStrip()
```
Initializes a new instance with default settings:
- `ShowFloatingWindowControlBox = true`
- `Dock = DockStyle.None`
- `GripStyle = ToolStripGripStyle.Visible`
- `FloatingWindowText = "Menu"`

---

### FloatingStateChangedEventArgs

Event arguments class for the `FloatingStateChanged` event.

#### Properties

##### `IsFloating`
```csharp
public bool IsFloating { get; }
```
Gets a value indicating whether the control is now floating.

**Returns:** `true` if the control is floating; `false` if docked.

#### Constructor

##### `FloatingStateChangedEventArgs(bool)`
```csharp
public FloatingStateChangedEventArgs(bool isFloating)
```
Initializes a new instance of the `FloatingStateChangedEventArgs` class.

**Parameters:**
- `isFloating`: `true` if the control is floating; otherwise, `false`.

---

### FloatingToolbarStateManager

Static helper class for saving and loading floating toolbar states to/from XML files.

#### Methods

##### `SaveStatesToFile(IEnumerable<FloatingToolbarState>, string)`
```csharp
public static bool SaveStatesToFile(IEnumerable<FloatingToolbarState> states, string filePath)
```
Saves a collection of floating toolbar states to an XML file.

**Parameters:**
- `states`: The collection of toolbar states to save.
- `filePath`: The path to the XML file.

**Returns:** `true` if the save was successful; otherwise, `false`.

##### `LoadStatesFromFile(string)`
```csharp
public static FloatingToolbarStateCollection? LoadStatesFromFile(string filePath)
```
Loads floating toolbar states from an XML file.

**Parameters:**
- `filePath`: The path to the XML file.

**Returns:** A `FloatingToolbarStateCollection` object, or `null` if loading failed.

##### `SaveStatesToString(IEnumerable<FloatingToolbarState>)`
```csharp
public static string? SaveStatesToString(IEnumerable<FloatingToolbarState> states)
```
Saves a collection of floating toolbar states to an XML string.

**Parameters:**
- `states`: The collection of toolbar states to save.

**Returns:** The XML string representation, or `null` if serialization failed.

##### `LoadStatesFromString(string)`
```csharp
public static FloatingToolbarStateCollection? LoadStatesFromString(string xmlString)
```
Loads floating toolbar states from an XML string.

**Parameters:**
- `xmlString`: The XML string to deserialize.

**Returns:** A `FloatingToolbarStateCollection` object, or `null` if loading failed.

---

### KryptonToolStripPanelExtended

#### Properties

##### `ActiveRectangle`
```csharp
public Rectangle ActiveRectangle { get; }
```
Gets the active rectangle where floating toolbars can dock. This rectangle is calculated based on panel size and orientation.

**Returns:** A `Rectangle` representing the docking zone.

**Note:** The active rectangle is automatically calculated when the panel size changes. For small panels (< 23 pixels), the rectangle extends beyond the panel bounds to provide a larger docking target.

#### Methods

##### `OnSizeChanged(EventArgs)`
```csharp
protected override void OnSizeChanged(EventArgs e)
```
Recalculates the active rectangle when the panel size changes.

##### `OnControlAdded(ControlEventArgs)`
```csharp
protected override void OnControlAdded(ControlEventArgs e)
```
Automatically sets the layout style of added tool strips based on panel orientation.

---

### KryptonMenuStripPanelExtended

#### Properties

##### `KryptonFloatableMenuStrip`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonFloatableMenuStrip KryptonFloatableMenuStrip { get; set; }
```
Gets or sets the associated floatable menu strip.

##### `ActiveRectangle`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public Rectangle ActiveRectangle { get; }
```
Gets the active rectangle where floating menu strips can dock.

#### Methods

##### `OnControlAdded(ControlEventArgs)`
```csharp
protected override void OnControlAdded(ControlEventArgs e)
```
Automatically sets the layout style of added menu strips based on panel orientation.

---

### KryptonFloatablePanelHost

#### Properties

##### `KryptonFloatableMenuStrip`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonFloatableMenuStrip? KryptonFloatableMenuStrip { get; set; }
```
Gets or sets the associated floatable menu strip (optional).

##### `KryptonFloatableToolStrip`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonFloatableToolStrip? KryptonFloatableToolStrip { get; set; }
```
Gets or sets the associated floatable tool strip (optional).

##### `ActiveArea`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public Rectangle ActiveArea { get; }
```
Gets the active area where floating controls can dock.

---

### VisualToolStripContainerForm

A `KryptonForm` that hosts floating `KryptonFloatableToolStrip` controls.

#### Properties

##### `KryptonFloatableToolStrip`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonFloatableToolStrip? KryptonFloatableToolStrip { get; set; }
```
Gets or sets the tool strip hosted in this floating window.

**Note:** Setting this property automatically configures the form size and layout.

#### Events

##### `NCLBUTTONDBLCLK`
```csharp
public event EventHandler NCLBUTTONDBLCLK;
```
Raised when the non-client area (title bar) is double-clicked. Typically used to dock the toolbar back.

#### Features

- **Auto-sizing**: Form size automatically adjusts to toolbar content
- **Resize constraints**: Minimum and maximum width constraints based on toolbar items
- **System menu**: Minimize, maximize, and restore options are removed
- **Double-click to dock**: Double-clicking the title bar docks the toolbar back

---

### VisualMenuStripContainerForm

A `KryptonForm` that hosts floating `KryptonFloatableMenuStrip` controls.

#### Properties

##### `KryptonFloatableMenuStrip`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonFloatableMenuStrip KryptonFloatableMenuStrip { get; set; }
```
Gets or sets the menu strip hosted in this floating window.

##### `ShowWindowFrame`
```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool ShowWindowFrame { get; set; }
```
Gets or sets whether to show a window frame border.

#### Features

- **Configurable control box**: Can show/hide window control box based on menu strip settings
- **Custom window text**: Uses `FloatingWindowText` from the menu strip
- **Auto-sizing**: Form size automatically adjusts to menu strip content

---

## Features

### 1. Drag-to-Float

Users can drag toolbars and menu strips by their grip handles to float them as separate windows.

**How it works:**
1. User clicks and holds the grip handle (`GripRectangle`)
2. User drags the control outside its parent's bounds
3. A floating container form is created
4. The control is moved to the floating form
5. The floating form is displayed

### 2. Automatic Docking

When a floating toolbar/menu strip is dragged over a designated panel's active rectangle, it automatically docks.

**How it works:**
1. Floating container form's `LocationChanged` event fires
2. Cursor position is checked against all panels in the collection
3. If cursor is within a panel's `ActiveRectangle`, docking occurs:
   - Control is removed from floating form
   - Control is added to the panel
   - Floating form is hidden
   - Control's floating state is reset

### 3. Panel Active Rectangles

Panels calculate "active rectangles" that define docking zones:

- **Normal panels**: Active rectangle equals client rectangle
- **Small panels** (< 23 pixels): Active rectangle extends beyond bounds to provide larger docking target
- **Orientation-aware**: Horizontal panels extend height, vertical panels extend width

### 4. Window Management

Floating windows provide:

- **Auto-sizing**: Size adjusts to content
- **Resize constraints**: Minimum width based on largest item, maximum width based on preferred size
- **Double-click to dock**: Double-clicking title bar returns control to original parent
- **Close button**: Closing window docks control back (canceled, form hidden)

### 5. State Management

Controls track:

- **Floating state**: `IsFloating` property
- **Original parent**: Stored for restoration
- **Panel collections**: Lists of valid docking targets

### 6. Designer Integration

Visual Studio designer support includes:

- **Collection editors**: Visual editors for panel collections
- **Component choosers**: Dialogs to select existing panels
- **Property serialization**: Proper serialization of panel lists

---

## Usage Guide

### Basic Setup

#### Step 1: Add Panels to Form

Add `KryptonToolStripPanelExtended` or `KryptonMenuStripPanelExtended` panels to your form:

```csharp
// In form designer or code
var topPanel = new KryptonToolStripPanelExtended
{
    Name = "topPanel",
    Dock = DockStyle.Top,
    Orientation = Orientation.Horizontal
};
this.Controls.Add(topPanel);
```

#### Step 2: Create Floatable Toolbar

Create a `KryptonFloatableToolStrip`:

```csharp
var toolStrip = new KryptonFloatableToolStrip
{
    Name = "mainToolStrip",
    FloatingToolBarWindowText = "Main Toolbar"
};

// Add items
toolStrip.Items.Add(new KryptonButton { Text = "New" });
toolStrip.Items.Add(new KryptonButton { Text = "Open" });
toolStrip.Items.Add(new KryptonButton { Text = "Save" });
```

#### Step 3: Configure Panel Collection

Add panels where the toolbar can dock:

```csharp
toolStrip.KryptonToolStripPanelExtendedList.Add(topPanel);
toolStrip.KryptonToolStripPanelExtendedList.Add(bottomPanel);
```

#### Step 4: Add Toolbar to Panel

Add the toolbar to a panel:

```csharp
topPanel.Controls.Add(toolStrip);
```

### Complete Example

```csharp
using Krypton.Toolkit;
using Krypton.Utilities;
using System.Drawing;
using System.Windows.Forms;

public partial class MainForm : KryptonForm
{
    private KryptonFloatableToolStrip _toolStrip;
    private KryptonToolStripPanelExtended _topPanel;
    private KryptonToolStripPanelExtended _bottomPanel;

    public MainForm()
    {
        InitializeComponent();
        SetupFloatingToolbars();
    }

    private void SetupFloatingToolbars()
    {
        // Create panels
        _topPanel = new KryptonToolStripPanelExtended
        {
            Name = "topPanel",
            Dock = DockStyle.Top,
            Orientation = Orientation.Horizontal,
            Height = 30
        };

        _bottomPanel = new KryptonToolStripPanelExtended
        {
            Name = "bottomPanel",
            Dock = DockStyle.Bottom,
            Orientation = Orientation.Horizontal,
            Height = 30
        };

        this.Controls.Add(_topPanel);
        this.Controls.Add(_bottomPanel);

        // Create floatable toolbar
        _toolStrip = new KryptonFloatableToolStrip
        {
            Name = "mainToolStrip",
            FloatingToolBarWindowText = "Main Toolbar",
            GripStyle = ToolStripGripStyle.Visible
        };

        // Add toolbar items
        _toolStrip.Items.Add(new ToolStripButton("New", null, OnNewClick));
        _toolStrip.Items.Add(new ToolStripButton("Open", null, OnOpenClick));
        _toolStrip.Items.Add(new ToolStripButton("Save", null, OnSaveClick));
        _toolStrip.Items.Add(new ToolStripSeparator());
        _toolStrip.Items.Add(new ToolStripButton("Cut", null, OnCutClick));
        _toolStrip.Items.Add(new ToolStripButton("Copy", null, OnCopyClick));
        _toolStrip.Items.Add(new ToolStripButton("Paste", null, OnPasteClick));

        // Configure docking panels
        _toolStrip.KryptonToolStripPanelExtendedList.Add(_topPanel);
        _toolStrip.KryptonToolStripPanelExtendedList.Add(_bottomPanel);

        // Add to panel
        _topPanel.Controls.Add(_toolStrip);
    }

    private void OnNewClick(object sender, EventArgs e) { /* ... */ }
    private void OnOpenClick(object sender, EventArgs e) { /* ... */ }
    private void OnSaveClick(object sender, EventArgs e) { /* ... */ }
    private void OnCutClick(object sender, EventArgs e) { /* ... */ }
    private void OnCopyClick(object sender, EventArgs e) { /* ... */ }
    private void OnPasteClick(object sender, EventArgs e) { /* ... */ }
}
```

### Menu Strip Example

```csharp
private void SetupFloatingMenuStrip()
{
    // Create menu strip panel
    var menuPanel = new KryptonMenuStripPanelExtended
    {
        Name = "menuPanel",
        Dock = DockStyle.Top,
        Orientation = Orientation.Horizontal,
        Height = 25
    };
    this.Controls.Add(menuPanel);

    // Create floatable menu strip
    var menuStrip = new KryptonFloatableMenuStrip
    {
        Name = "mainMenuStrip",
        FloatingWindowText = "Main Menu",
        ShowFloatingWindowControlBox = true,
        GripStyle = ToolStripGripStyle.Visible
    };

    // Add menu items
    var fileMenu = new ToolStripMenuItem("File");
    fileMenu.DropDownItems.Add("New", null, OnNewClick);
    fileMenu.DropDownItems.Add("Open", null, OnOpenClick);
    fileMenu.DropDownItems.Add("Save", null, OnSaveClick);
    menuStrip.Items.Add(fileMenu);

    var editMenu = new ToolStripMenuItem("Edit");
    editMenu.DropDownItems.Add("Cut", null, OnCutClick);
    editMenu.DropDownItems.Add("Copy", null, OnCopyClick);
    editMenu.DropDownItems.Add("Paste", null, OnPasteClick);
    menuStrip.Items.Add(editMenu);

    // Configure docking panels
    menuStrip.MenuStripPanelExtendedList = new List<KryptonMenuStripPanelExtended> { menuPanel };

    // Add to panel
    menuPanel.Controls.Add(menuStrip);
    menuPanel.KryptonFloatableMenuStrip = menuStrip;
}
```

### Programmatic Floating

You can programmatically float a toolbar or menu strip using the `Float()` method:

```csharp
// Float at current location
if (toolStrip.Float())
{
    Console.WriteLine("Toolbar floated successfully");
}

// Float at specific screen location
Point customLocation = new Point(100, 100);
if (toolStrip.Float(customLocation))
{
    Console.WriteLine("Toolbar floated at custom location");
}

// Float menu strip
if (menuStrip.Float())
{
    Console.WriteLine("Menu strip floated successfully");
}
```

**Returns:** `true` if floating was successful; `false` if already floating or cannot float.

### Programmatic Docking

You can programmatically dock a floating toolbar or menu strip using the `Dock()` method:

```csharp
// Dock to original parent
if (toolStrip.Dock())
{
    Console.WriteLine("Toolbar docked to original parent");
}

// Dock to specific panel
var targetPanel = toolStrip.KryptonToolStripPanelExtendedList.FirstOrDefault();
if (targetPanel != null && toolStrip.Dock(targetPanel))
{
    Console.WriteLine("Toolbar docked to specified panel");
}

// Dock menu strip to specific panel
var menuPanel = menuStrip.MenuStripPanelExtendedList?.FirstOrDefault();
if (menuPanel != null && menuStrip.Dock(menuPanel))
{
    Console.WriteLine("Menu strip docked successfully");
}
```

**Returns:** `true` if docking was successful; `false` if not floating or cannot dock.

### Floating State Events

You can subscribe to the `FloatingStateChanged` event to be notified when a toolbar or menu strip changes between floating and docked states:

```csharp
toolStrip.FloatingStateChanged += (sender, e) =>
{
    if (e.IsFloating)
    {
        Console.WriteLine("Toolbar is now floating");
        // Update UI, save state, etc.
    }
    else
    {
        Console.WriteLine("Toolbar is now docked");
        // Update UI, save state, etc.
    }
};

menuStrip.FloatingStateChanged += (sender, e) =>
{
    // Handle state change
    UpdateMenuStripUI(e.IsFloating);
};
```

---

## Designer Integration

### Collection Editors

The floating toolbar controls provide custom collection editors for managing panel lists in the Visual Studio designer.

#### ToolStripPanelCollectionEditor

Accessed via the `KryptonToolStripPanelExtendedList` property in the Properties window.

**Features:**
- Visual dialog to select existing `KryptonToolStripPanelExtended` controls
- Add/remove panels from the collection
- Shows available panels from the form
- Shows currently selected panels

**Usage:**
1. Select `KryptonFloatableToolStrip` in designer
2. Find `KryptonToolStripPanelExtendedList` property
3. Click the ellipsis (...) button
4. Use the dialog to select panels

#### MenuStripPanelCollectionEditor

Accessed via the `MenuStripPanelExtendedList` property in the Properties window.

**Features:**
- Visual dialog to select existing `KryptonMenuStripPanelExtended` controls
- Similar interface to ToolStripPanelCollectionEditor

### Component Chooser Forms

#### VisualToolStripExistingComponentChooserForm

A dialog form that allows selecting `KryptonToolStripPanelExtended` controls.

**Properties:**
- `SourceComponentContainer`: The container control to search for panels
- `SelectedComponents`: Returns the list of selected panels

#### VisualMenuStripExistingComponentChooserForm

A dialog form that allows selecting `KryptonMenuStripPanelExtended` controls.

**Properties:**
- `SourceComponentContainer`: The container control to search for panels
- `SelectedComponents`: Returns the list of selected panels

---

## Best Practices

### 1. Panel Configuration

**DO:**
- Use descriptive names for panels (e.g., "TopToolbarPanel", "BottomStatusPanel")
- Set appropriate `Orientation` based on panel position
- Ensure panels have adequate size (minimum 23 pixels recommended)
- Use `Dock` property to position panels correctly

**DON'T:**
- Don't create panels that are too small (< 23 pixels)
- Don't forget to set `Orientation` property
- Don't add panels to the collection that aren't on the form

### 2. Toolbar Configuration

**DO:**
- Set meaningful `FloatingToolBarWindowText` / `FloatingWindowText`
- Configure `GripStyle = ToolStripGripStyle.Visible` to enable dragging
- Add all valid docking panels to the collection
- Use consistent naming conventions

**DON'T:**
- Don't forget to add panels to the collection before users try to dock
- Don't set `Dock` property directly on floatable controls (let panels manage it)
- Don't modify `OriginalParent` property (internal use only)

### 3. State Management

**DO:**
- Check `IsFloating` property before performing operations
- Handle visibility through the `Visible` property (works for both states)
- Store panel references if you need to programmatically manage docking

**DON'T:**
- Don't manually manipulate parent controls during floating operations
- Don't assume control location when floating (use `IsFloating` check)
- Don't modify internal state fields directly

### 4. Performance Considerations

**DO:**
- Limit the number of panels in collections (only add necessary ones)
- Reuse panel instances when possible
- Consider panel visibility when calculating active rectangles

**DON'T:**
- Don't add every panel on the form to every toolbar's collection
- Don't create excessive floating windows simultaneously

### 5. User Experience

**DO:**
- Provide visual feedback during drag operations
- Use descriptive window titles
- Ensure adequate docking targets are available
- Test drag-to-float and dock-back scenarios

**DON'T:**
- Don't make docking zones too small
- Don't use generic window titles
- Don't remove panels while toolbars are floating

---

## Troubleshooting

### Toolbar Won't Float

**Symptoms:** Clicking and dragging the grip handle doesn't create a floating window.

**Possible Causes:**
1. `GripStyle` is not set to `Visible`
2. Toolbar is not in a valid parent container
3. Mouse events are being intercepted by another control

**Solutions:**
```csharp
// Ensure grip is visible
toolStrip.GripStyle = ToolStripGripStyle.Visible;

// Check parent
if (toolStrip.Parent == null)
{
    // Add to a panel first
    panel.Controls.Add(toolStrip);
}
```

### Toolbar Won't Dock

**Symptoms:** Dragging floating toolbar over panel doesn't dock it.

**Possible Causes:**
1. Panel is not in the toolbar's panel collection
2. Panel's `ActiveRectangle` is too small
3. Cursor position calculation issue

**Solutions:**
```csharp
// Verify panel is in collection
if (!toolStrip.KryptonToolStripPanelExtendedList.Contains(panel))
{
    toolStrip.KryptonToolStripPanelExtendedList.Add(panel);
}

// Check panel size
if (panel.Width < 23 || panel.Height < 23)
{
    // Panel may be too small - increase size
    panel.Height = 30; // or appropriate size
}
```

### Floating Window Too Small/Large

**Symptoms:** Floating window size doesn't match toolbar content.

**Possible Causes:**
1. Toolbar items have unusual sizes
2. Minimum/maximum width calculations incorrect

**Solutions:**
- Check toolbar item sizes
- Verify `PreferredSize` is calculated correctly
- Container form auto-sizes based on toolbar content

### Panel Active Rectangle Issues

**Symptoms:** Docking zone doesn't match panel visual bounds.

**Possible Causes:**
1. Panel size changed after active rectangle calculation
2. Orientation mismatch

**Solutions:**
```csharp
// Force recalculation by resizing panel
panel.Size = new Size(panel.Width + 1, panel.Height);
panel.Size = new Size(panel.Width - 1, panel.Height);

// Or check orientation
if (panel.Orientation != Orientation.Horizontal && panel.Dock == DockStyle.Top)
{
    // Mismatch - fix orientation
    panel.Orientation = Orientation.Horizontal;
}
```

### Designer Serialization Issues

**Symptoms:** Panel collections don't persist in designer.

**Possible Causes:**
1. Panels not properly named
2. Collection editor not saving correctly

**Solutions:**
- Ensure panels have unique, valid names
- Use the collection editor in Properties window
- Check `.Designer.cs` file for serialized code

### Multiple Floating Windows

**Symptoms:** Multiple floating windows created for same toolbar.

**Possible Causes:**
1. Rapid clicking/dragging
2. Event handler issues

**Solutions:**
- This is typically prevented by internal state management
- Check for event handler conflicts
- Ensure `_aboutToFloat` flag is working correctly

---

## Examples

### Example 1: Simple Floating Toolbar

```csharp
public partial class SimpleToolbarForm : KryptonForm
{
    public SimpleToolbarForm()
    {
        InitializeComponent();
        SetupToolbar();
    }

    private void SetupToolbar()
    {
        // Panel
        var panel = new KryptonToolStripPanelExtended
        {
            Dock = DockStyle.Top,
            Height = 30
        };
        Controls.Add(panel);

        // Toolbar
        var toolbar = new KryptonFloatableToolStrip
        {
            FloatingToolBarWindowText = "Tools"
        };
        toolbar.Items.Add(new ToolStripButton("Button 1"));
        toolbar.Items.Add(new ToolStripButton("Button 2"));

        toolbar.KryptonToolStripPanelExtendedList.Add(panel);
        panel.Controls.Add(toolbar);
    }
}
```

### Example 2: Multiple Docking Zones

```csharp
public partial class MultiPanelForm : KryptonForm
{
    private KryptonFloatableToolStrip _toolbar;
    private KryptonToolStripPanelExtended _topPanel;
    private KryptonToolStripPanelExtended _leftPanel;
    private KryptonToolStripPanelExtended _rightPanel;

    public MultiPanelForm()
    {
        InitializeComponent();
        SetupMultiPanelToolbar();
    }

    private void SetupMultiPanelToolbar()
    {
        // Create multiple panels
        _topPanel = new KryptonToolStripPanelExtended
        {
            Name = "TopPanel",
            Dock = DockStyle.Top,
            Height = 30
        };

        _leftPanel = new KryptonToolStripPanelExtended
        {
            Name = "LeftPanel",
            Dock = DockStyle.Left,
            Width = 30,
            Orientation = Orientation.Vertical
        };

        _rightPanel = new KryptonToolStripPanelExtended
        {
            Name = "RightPanel",
            Dock = DockStyle.Right,
            Width = 30,
            Orientation = Orientation.Vertical
        };

        Controls.Add(_topPanel);
        Controls.Add(_leftPanel);
        Controls.Add(_rightPanel);

        // Create toolbar
        _toolbar = new KryptonFloatableToolStrip
        {
            FloatingToolBarWindowText = "Multi-Panel Toolbar"
        };
        _toolbar.Items.Add(new ToolStripButton("A"));
        _toolbar.Items.Add(new ToolStripButton("B"));
        _toolbar.Items.Add(new ToolStripButton("C"));

        // Add all panels to collection
        _toolbar.KryptonToolStripPanelExtendedList.Add(_topPanel);
        _toolbar.KryptonToolStripPanelExtendedList.Add(_leftPanel);
        _toolbar.KryptonToolStripPanelExtendedList.Add(_rightPanel);

        // Start docked in top panel
        _topPanel.Controls.Add(_toolbar);
    }
}
```

### Example 3: Floating Menu Strip with Custom Settings

```csharp
public partial class MenuStripForm : KryptonForm
{
    public MenuStripForm()
    {
        InitializeComponent();
        SetupMenuStrip();
    }

    private void SetupMenuStrip()
    {
        var panel = new KryptonMenuStripPanelExtended
        {
            Dock = DockStyle.Top,
            Height = 25
        };
        Controls.Add(panel);

        var menuStrip = new KryptonFloatableMenuStrip
        {
            FloatingWindowText = "Application Menu",
            ShowFloatingWindowControlBox = false, // No control box
            GripStyle = ToolStripGripStyle.Visible
        };

        // Build menu
        var fileMenu = new ToolStripMenuItem("File");
        fileMenu.DropDownItems.Add("New");
        fileMenu.DropDownItems.Add("Open");
        fileMenu.DropDownItems.Add("Exit");

        var editMenu = new ToolStripMenuItem("Edit");
        editMenu.DropDownItems.Add("Undo");
        editMenu.DropDownItems.Add("Redo");

        menuStrip.Items.Add(fileMenu);
        menuStrip.Items.Add(editMenu);

        menuStrip.MenuStripPanelExtendedList = new List<KryptonMenuStripPanelExtended> { panel };
        panel.Controls.Add(menuStrip);
        panel.KryptonFloatableMenuStrip = menuStrip;
    }
}
```

### Example 4: State-Aware Toolbar Handling

```csharp
public partial class StateAwareForm : KryptonForm
{
    private KryptonFloatableToolStrip _toolbar;

    public StateAwareForm()
    {
        InitializeComponent();
        SetupToolbar();
        SetupEventHandlers();
    }

    private void SetupToolbar()
    {
        var panel = new KryptonToolStripPanelExtended { Dock = DockStyle.Top, Height = 30 };
        Controls.Add(panel);

        _toolbar = new KryptonFloatableToolStrip { FloatingToolBarWindowText = "State Toolbar" };
        _toolbar.Items.Add(new ToolStripButton("Action"));
        _toolbar.KryptonToolStripPanelExtendedList.Add(panel);
        panel.Controls.Add(_toolbar);
    }

    private void SetupEventHandlers()
    {
        // Monitor floating state changes
        // Note: There's no direct event, but you can check periodically
        // or hook into parent changed events
        
        _toolbar.ParentChanged += (s, e) =>
        {
            UpdateUIForFloatingState();
        };
    }

    private void UpdateUIForFloatingState()
    {
        if (_toolbar.IsFloating)
        {
            // Toolbar is floating - adjust UI accordingly
            Text = "Main Window - Toolbar Floating";
        }
        else
        {
            // Toolbar is docked
            Text = "Main Window";
        }
    }

    private void SomeAction()
    {
        // Always check state before operations
        if (_toolbar.IsFloating)
        {
            // Handle floating state
        }
        else
        {
            // Handle docked state
        }

        // Visibility works for both states
        _toolbar.Visible = true;
    }
}
```

---

## Additional Resources

### Related Components

- **KryptonToolStrip**: Base toolbar control
- **KryptonMenuStrip**: Base menu strip control
- **ToolStripPanel**: Standard .NET panel for tool strips
- **KryptonForm**: Krypton-themed form container

### Namespace

All components are in the `Krypton.Utilities` namespace:

```csharp
using Krypton.Utilities;
```

### Dependencies

- Krypton.Toolkit (for base controls and theming)
- System.Windows.Forms (for standard controls)
- System.Drawing (for rectangles and points)

---

## Version History

This documentation covers the KryptonFloatingMenuAndToolbars feature as implemented in the Standard Toolkit.

### Known Limitations

1. **Single Container**: Each floatable control maintains a single container form instance (this is intentional for efficiency - the container is reused)
2. **Panel Types**: Tool strips and menu strips use separate panel types (cannot mix in same panel). However, `KryptonFloatablePanelHost` can accommodate both types.

### Additional Features

The following features are now available:

#### Save/Load Floating Positions

You can save and restore the floating state and positions of toolbars:

```csharp
// Save state of a toolbar
var state = toolStrip.SaveState();
if (state != null)
{
    // Save to file
    FloatingToolbarStateManager.SaveStatesToFile(new[] { state }, "toolbar_states.xml");
    
    // Or save to string
    string xml = FloatingToolbarStateManager.SaveStatesToString(new[] { state });
}

// Load states from file
var collection = FloatingToolbarStateManager.LoadStatesFromFile("toolbar_states.xml");
if (collection != null)
{
    foreach (var state in collection.ToolbarStates)
    {
        // Find toolbar by name and load its state
        var toolbar = Controls.Find(state.Name, true).FirstOrDefault() as KryptonFloatableToolStrip;
        toolbar?.LoadState(state);
    }
}
```

#### Animation

Smooth animations during dock/float transitions can be enabled:

```csharp
// Enable animation with custom duration
toolStrip.EnableAnimation = true;
toolStrip.AnimationDuration = 300; // milliseconds

// Disable animation for instant transitions
toolStrip.EnableAnimation = false;
```

#### Custom Window Styles

Customize the appearance of floating windows:

```csharp
// Set window style
toolStrip.FloatingWindowStyle = FloatingWindowStyle.Minimal; // No border
toolStrip.FloatingWindowStyle = FloatingWindowStyle.ToolWindow; // Tool window style
toolStrip.FloatingWindowStyle = FloatingWindowStyle.Default; // Standard window
```

Available styles:
- **Default**: Standard window with full chrome
- **Minimal**: No border or title bar
- **ToolWindow**: Smaller title bar, tool window style
- **Custom**: For future customization options

### Additional Advanced Features

The following advanced features are now available:

#### Enhanced Docking Preview Indicators

Visual feedback when dragging toolbars over dock zones:

```csharp
// Enable/disable preview indicators
toolStrip.ShowDockingPreview = true;

// Customize preview colors
toolStrip.DockingPreviewColor = Color.FromArgb(100, 0, 120, 215); // Fill color
toolStrip.DockingPreviewBorderColor = Color.FromArgb(200, 0, 120, 215); // Border color
```

The preview indicator shows a semi-transparent overlay with animated borders when dragging over valid dock zones.

#### Custom Window Themes and Colors

Apply custom themes to floating windows:

```csharp
// Use predefined themes
toolStrip.WindowTheme = FloatingWindowTheme.Dark;
toolStrip.WindowTheme = FloatingWindowTheme.Light;
toolStrip.WindowTheme = FloatingWindowTheme.BlueAccent;

// Create custom theme
var customTheme = new FloatingWindowTheme
{
    BackColor = Color.FromArgb(240, 240, 240),
    BorderColor = Color.FromArgb(100, 100, 100),
    TitleBarColor = Color.FromArgb(50, 50, 50),
    TitleTextColor = Color.White,
    Opacity = 0.95,
    UseGradient = true,
    GradientEndColor = Color.FromArgb(220, 220, 220)
};
toolStrip.WindowTheme = customTheme;
```

#### Per-Toolbar Animation Settings

Each toolbar can have its own animation settings:

```csharp
// Different animation settings per toolbar
toolStrip1.EnableAnimation = true;
toolStrip1.AnimationDuration = 200;

toolStrip2.EnableAnimation = true;
toolStrip2.AnimationDuration = 400; // Slower animation

toolStrip3.EnableAnimation = false; // No animation
```

#### State Persistence with User Preferences

Save and load toolbar states from user application data:

```csharp
// Save to user preferences folder (AppData)
var states = toolbars.Select(t => t.SaveState()).Where(s => s != null);
FloatingToolbarStateManager.SaveStatesToUserPreferences(states, "MyApplication");

// Load from user preferences
var collection = FloatingToolbarStateManager.LoadStatesFromUserPreferences("MyApplication");
if (collection != null)
{
    foreach (var state in collection.ToolbarStates)
    {
        var toolbar = Controls.Find(state.Name, true).FirstOrDefault() as KryptonFloatableToolStrip;
        toolbar?.LoadState(state);
    }
}

// Get preferences path
string prefsPath = FloatingToolbarStateManager.GetUserPreferencesPath("MyApplication");
```

The user preferences are stored in: `%AppData%\YourApplication\FloatingToolbars\toolbar_states.xml`

### Advanced Features

The following advanced features are now available:

#### Advanced Theme Customization with Custom Painting

Create fully custom window appearances using the custom painter interface:

```csharp
// Create a custom painter
public class MyCustomPainter : IFloatingWindowCustomPainter
{
    public void PaintBackground(PaintEventArgs e, Rectangle rect)
    {
        // Custom background painting
        using (var brush = new LinearGradientBrush(rect, Color.Blue, Color.DarkBlue, 45f))
        {
            e.Graphics.FillRectangle(brush, rect);
        }
    }

    public void PaintTitleBar(PaintEventArgs e, Rectangle rect, string text)
    {
        // Custom title bar painting
        using (var brush = new SolidBrush(Color.Navy))
        {
            e.Graphics.FillRectangle(brush, rect);
        }
        // Draw text, icons, etc.
    }

    public void PaintBorder(PaintEventArgs e, Rectangle rect)
    {
        // Custom border painting
        using (var pen = new Pen(Color.Gold, 2f))
        {
            e.Graphics.DrawRectangle(pen, rect);
        }
    }
}

// Apply custom painter
var theme = new FloatingWindowTheme();
theme.CustomPainter = new MyCustomPainter();
toolStrip.WindowTheme = theme;

// Or use default painter with theme
theme.CustomPainter = new FloatingWindowDefaultPainter(theme);
toolStrip.WindowTheme = theme;
```

#### Animated Docking Preview Transitions

The docking preview indicators now feature smooth animations:

- **Pulsing border**: Border opacity pulses smoothly
- **Animated dash offset**: Dashed border animates continuously
- **60 FPS animation**: Smooth 60 frames per second updates

The animation automatically starts when preview is shown and stops when hidden.

#### Multi-Monitor Support Enhancements

Enhanced support for multi-monitor setups:

```csharp
// Ensure toolbar floats on visible screen
Point location = new Point(2000, 100); // Might be off-screen
location = MultiMonitorHelper.EnsurePointOnScreen(location);

// Get screen information
Screen currentScreen = MultiMonitorHelper.GetScreenFromPoint(location);
Screen[] allScreens = MultiMonitorHelper.GetAllScreens();
int screenCount = MultiMonitorHelper.GetScreenCount();

// Check if point is on any screen
bool isOnScreen = MultiMonitorHelper.IsPointOnScreen(location);

// Ensure rectangle is visible
Rectangle rect = new Rectangle(2000, 100, 200, 50);
rect = MultiMonitorHelper.EnsureRectangleOnScreen(rect);
```

Floating toolbars automatically ensure they appear on visible screens when programmatically floated.

#### Toolbar Grouping and Tabbing

Organize toolbars into groups that can be managed together:

```csharp
// Create a toolbar group
var group = FloatingToolbarGroupManager.CreateGroup("MainToolbars");

// Add toolbars to group
group.AddToolbar(toolStrip1);
group.AddToolbar(toolStrip2);
group.AddMenuStrip(menuStrip1);

// Enable tabbing (future feature - groups can be tabbed together)
group.IsTabbed = true;
group.ActiveTabIndex = 0;

// Find group containing a toolbar
var foundGroup = FloatingToolbarGroupManager.FindGroupContaining(toolStrip1);

// Remove toolbar from group
group.RemoveToolbar(toolStrip1);

// Find group by name
var mainGroup = FloatingToolbarGroupManager.FindGroup("MainToolbars");

// Get all groups
foreach (var g in FloatingToolbarGroupManager.Groups)
{
    Console.WriteLine($"Group: {g.Name}, Count: {g.Count}");
}
```

Groups allow you to:
- Organize related toolbars together
- Manage multiple toolbars as a unit
- Display toolbars in a tabbed interface
- Drag-and-drop toolbars between groups
- Save and restore group configurations
- Track toolbar relationships

### Advanced Group Features (Implemented)

The following advanced features are now available:

#### Full Tabbed Interface Implementation

Groups can now display toolbars in a tabbed interface using `FloatingToolbarTabbedContainerForm`:

```csharp
// Create a group and enable tabbing
var group = FloatingToolbarGroupManager.CreateGroup("MyGroup");
group.IsTabbed = true; // Automatically creates tabbed container

// Add toolbars - they will appear as tabs
group.AddToolbar(toolbar1);
group.AddToolbar(toolbar2);
group.AddMenuStrip(menuStrip1);

// Access the tabbed container
var container = group.TabbedContainerForm;
container.Show(); // Display the tabbed interface
```

#### Drag-and-Drop Between Groups

Toolbars can be dragged between groups:

```csharp
// Move a toolbar from one group to another
FloatingToolbarGroupManager.MoveToolbarToGroup(toolbar, targetGroup);

// Move a menu strip between groups
FloatingToolbarGroupManager.MoveMenuStripToGroup(menuStrip, targetGroup);

// When dragging a floating toolbar over a tabbed group container,
// it will automatically be added to that group on mouse release
```

#### Group State Persistence

Save and load group configurations:

```csharp
// Save all group states
var groupStates = FloatingToolbarGroupManager.SaveAllGroupStates();
FloatingToolbarStateManager.SaveGroupStatesToUserPreferences(
    groupStates.GroupStates,
    "MyApplication",
    "group_states.xml"
);

// Load group states
var collection = FloatingToolbarStateManager.LoadGroupStatesFromUserPreferences(
    "MyApplication",
    "group_states.xml"
);

if (collection != null)
{
    var toolbars = Controls.OfType<KryptonFloatableToolStrip>()
        .ToDictionary(t => t.Name, t => t);
    var menuStrips = Controls.OfType<KryptonFloatableMenuStrip>()
        .ToDictionary(m => m.Name, m => m);
    
    FloatingToolbarGroupManager.LoadGroupStates(collection, toolbars, menuStrips);
}
```

#### Advanced Multi-Monitor Layout Management

Enhanced multi-monitor support with layout management:

```csharp
// Get best screen for a window
Screen bestScreen = MultiMonitorHelper.GetBestScreenForWindow(preferredLocation);

// Calculate optimal window position
Point optimalPos = MultiMonitorHelper.CalculateOptimalWindowPosition(
    bestScreen,
    windowSize,
    preferredLocation
);

// Distribute multiple windows across screens
var windowSizes = new List<Size> { size1, size2, size3 };
var preferredLocations = new List<Point> { loc1, loc2, loc3 };
var positions = MultiMonitorHelper.DistributeWindowsAcrossScreens(
    windowSizes,
    preferredLocations
);

// Get detailed screen layout information
var layoutInfo = MultiMonitorHelper.GetScreenLayoutInfo();
foreach (var screen in layoutInfo.Values)
{
    Console.WriteLine($"Screen: {screen.DeviceName}, Primary: {screen.IsPrimary}");
    Console.WriteLine($"Bounds: {screen.Bounds}, Working Area: {screen.WorkingArea}");
}
```

---

## Support

For issues, questions, or contributions related to KryptonFloatingMenuAndToolbars:

- Check the troubleshooting section above
- Review example code in the TestForm project
- Consult the main Krypton Toolkit documentation
- Report issues on the project repository