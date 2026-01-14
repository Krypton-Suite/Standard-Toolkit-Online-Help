# KryptonSplitter

## Overview

`KryptonSplitter` is a Krypton-themed wrapper around the standard `System.Windows.Forms.Splitter` control. It enables users to resize docked controls within a container while integrating seamlessly with the Krypton palette system for consistent theming across your application.

### Key Features

- **Full Splitter Compatibility**: Drop-in replacement with identical API
- **Krypton Palette Integration**: Supports all Krypton palette modes (Global, Professional, Office, etc.)
- **Design-Time Support**: Available in Visual Studio toolbox
- **Event Forwarding**: All standard Splitter events are properly inherited
- **Visual Consistency**: Matches the look and feel of other Krypton controls

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(Splitter))]
[DefaultEvent(nameof(SplitterMoved))]
[DefaultProperty(nameof(Dock))]
[DesignerCategory(@"code")]
[Description(@"Enables the user to resize docked controls.")]
public class KryptonSplitter : Splitter
```

## Inheritance Hierarchy

```
System.Object
  └─ System.MarshalByRefObject
      └─ System.ComponentModel.Component
          └─ System.Windows.Forms.Control
              └─ System.Windows.Forms.Splitter
                  └─ Krypton.Toolkit.KryptonSplitter
```

## Constructors

### KryptonSplitter()

Creates a new instance of `KryptonSplitter` with default settings.

```csharp
var splitter = new KryptonSplitter();
```

**Initial Values:**
- `Dock`: `DockStyle.None`
- `MinSize`: `(25, 25)`
- `MinExtra`: `25`
- `BorderStyle`: `BorderStyle.None`
- `PaletteMode`: `PaletteMode.Global`
- `TabStop`: `false` (inherited from Splitter)
- `Size`: `(3, 3)` (default splitter size)

## Properties

### Dock

Gets or sets which edge of the parent container the splitter is docked to.

```csharp
[Category(@"Layout")]
[Description(@"Determines which edge of the parent container a control is docked to.")]
[DefaultValue(DockStyle.None)]
[Localizable(true)]
public DockStyle Dock { get; set; }
```

**DockStyle Enum Values:**
- `None` - Not docked (default)
- `Top` - Docked to top edge
- `Bottom` - Docked to bottom edge
- `Left` - Docked to left edge
- `Right` - Docked to right edge
- `Fill` - Fills entire container (not typically used for splitters)

**Example:**
```csharp
splitter.Dock = DockStyle.Left;   // Vertical splitter on left
splitter.Dock = DockStyle.Top;    // Horizontal splitter on top
splitter.Dock = DockStyle.Right;  // Vertical splitter on right
splitter.Dock = DockStyle.Bottom; // Horizontal splitter on bottom
```

**Usage Pattern:**
Typically used between two docked controls:
1. First control docks to one edge (e.g., `DockStyle.Left`)
2. Splitter docks to the same edge (e.g., `DockStyle.Left`)
3. Second control docks to fill remaining space (e.g., `DockStyle.Fill`)

### MinSize

Gets or sets the minimum size of the splitter control itself.

```csharp
[Category(@"Layout")]
[Description(@"The minimum size of the splitter.")]
[Localizable(true)]
[DefaultValue(typeof(Size), "25,25")]
public Size MinSize { get; set; }
```

**Example:**
```csharp
splitter.MinSize = new Size(50, 50);  // Minimum 50x50 pixels
splitter.MinSize = new Size(25, 25);  // Default minimum
```

**Note:** This controls the minimum size of the splitter control itself, not the minimum size of the adjacent controls.

### MinExtra

Gets or sets the minimum size of the target control that the splitter is docked to.

```csharp
[Category(@"Layout")]
[Description(@"The minimum size of the target control that the splitter is docked to.")]
[Localizable(true)]
[DefaultValue(25)]
public int MinExtra { get; set; }
```

**Example:**
```csharp
splitter.MinExtra = 100;  // Adjacent control must be at least 100 pixels
splitter.MinExtra = 25;   // Default minimum
```

**Usage:**
- For vertical splitters (`DockStyle.Left` or `Right`): Minimum width of adjacent control
- For horizontal splitters (`DockStyle.Top` or `Bottom`): Minimum height of adjacent control

### SplitPosition

Gets or sets the location of the splitter, in pixels, from the left or top edge of the docked control.

```csharp
[Category(@"Layout")]
[Description(@"The location of the splitter, in pixels, from the left or top edge of the docked control.")]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public int SplitPosition { get; set; }
```

**Example:**
```csharp
splitter.SplitPosition = 200;  // Position splitter 200 pixels from edge
```

**Notes:**
- Not browsable in property grid
- Automatically updated when user drags the splitter
- Can be set programmatically to position the splitter
- For vertical splitters: distance from left edge
- For horizontal splitters: distance from top edge

### BorderStyle

Gets or sets the border style for the splitter control.

```csharp
[Category(@"Appearance")]
[Description(@"The border style for the control.")]
[DefaultValue(BorderStyle.None)]
public BorderStyle BorderStyle { get; set; }
```

**BorderStyle Enum Values:**
- `None` - No border (default)
- `FixedSingle` - Single-line border
- `Fixed3D` - 3D border

**Example:**
```csharp
splitter.BorderStyle = BorderStyle.FixedSingle;  // Single-line border
splitter.BorderStyle = BorderStyle.Fixed3D;      // 3D border
splitter.BorderStyle = BorderStyle.None;         // No border (default)
```

### PaletteMode

Gets or sets the palette mode for Krypton integration.

```csharp
[Category(@"Visuals")]
[Description(@"Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PaletteMode PaletteMode { get; set; }
```

**PaletteMode Values:**
- `Global` - Uses the global Krypton palette (default)
- `ProfessionalSystem` - Professional system theme
- `ProfessionalOffice2003` - Office 2003 theme
- `ProfessionalOffice2007` - Office 2007 theme
- `ProfessionalOffice2010` - Office 2010 theme
- `ProfessionalOffice2013` - Office 2013 theme
- `SparkleBlue` - Sparkle Blue theme
- `SparkleOrange` - Sparkle Orange theme
- `SparklePurple` - Sparkle Purple theme
- `Custom` - Use custom palette (requires `Palette` property)

**Example:**
```csharp
splitter.PaletteMode = PaletteMode.ProfessionalOffice2010;
```

**Note:** This property is not browsable in the property grid but can be set programmatically.

### Palette

Gets or sets the custom palette (only used when `PaletteMode` is `Custom`).

```csharp
[Category(@"Visuals")]
[Description(@"Sets the custom palette to be used.")]
[DefaultValue(null)]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PaletteBase? Palette { get; set; }
```

**Example:**
```csharp
var customPalette = new KryptonPalette();
// Configure custom palette...
splitter.PaletteMode = PaletteMode.Custom;
splitter.Palette = customPalette;
```

**Note:** This property is not browsable in the property grid but can be set programmatically.

## Inherited Properties

Since `KryptonSplitter` inherits from `Splitter`, it also has access to all standard Control and Splitter properties:

### Common Control Properties

- `BackColor` - Background color
- `ForeColor` - Foreground color
- `Enabled` - Whether the control is enabled
- `Visible` - Whether the control is visible
- `Size` - Size of the control
- `Location` - Location of the control
- `Width` - Width of the control
- `Height` - Height of the control
- `TabStop` - Whether the control can receive focus via Tab key (default: `false`)

### Splitter-Specific Properties

- `Cursor` - Cursor displayed when hovering over the splitter
- `DefaultCursor` - Default cursor for the splitter

## Events

### SplitterMoved

Occurs when the splitter control is moved.

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when the splitter control is moved.")]
public event SplitterEventHandler? SplitterMoved;
```

**Event Handler Signature:**
```csharp
void OnSplitterMoved(object sender, SplitterEventArgs e)
```

**SplitterEventArgs Properties:**
- `X` (int): X-coordinate of the splitter
- `Y` (int): Y-coordinate of the splitter
- `SplitX` (int): X-coordinate where the splitter was moved
- `SplitY` (int): Y-coordinate where the splitter was moved

**Example:**
```csharp
splitter.SplitterMoved += (sender, e) =>
{
    Console.WriteLine($"Splitter moved to: ({e.SplitX}, {e.SplitY})");
    Console.WriteLine($"SplitPosition: {splitter.SplitPosition}");
    
    // Update UI, save position, etc.
    SaveSplitterPosition(splitter.SplitPosition);
};
```

### SplitterMoving

Occurs when the splitter control is in the process of being moved.

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when the splitter control is in the process of being moved.")]
public event SplitterEventHandler? SplitterMoving;
```

**Example:**
```csharp
splitter.SplitterMoving += (sender, e) =>
{
    // Update preview, show position indicator, etc.
    UpdatePositionIndicator(e.SplitX, e.SplitY);
};
```

**Note:** This event fires continuously while the user is dragging the splitter.

## Usage Examples

### Basic Vertical Splitter

```csharp
using Krypton.Toolkit;
using System.Windows.Forms;

public partial class MainForm : KryptonForm
{
    private KryptonPanel _leftPanel;
    private KryptonSplitter _splitter;
    private KryptonPanel _rightPanel;

    public MainForm()
    {
        InitializeComponent();
        SetupSplitter();
    }

    private void SetupSplitter()
    {
        // Left panel
        _leftPanel = new KryptonPanel
        {
            Dock = DockStyle.Left,
            Width = 200,
            BackColor = Color.LightGray
        };
        Controls.Add(_leftPanel);

        // Splitter
        _splitter = new KryptonSplitter
        {
            Dock = DockStyle.Left,
            MinExtra = 100,  // Right panel minimum width
            MinSize = 25      // Left panel minimum width
        };
        _splitter.SplitterMoved += OnSplitterMoved;
        Controls.Add(_splitter);

        // Right panel
        _rightPanel = new KryptonPanel
        {
            Dock = DockStyle.Fill,
            BackColor = Color.White
        };
        Controls.Add(_rightPanel);
    }

    private void OnSplitterMoved(object sender, SplitterEventArgs e)
    {
        // Save position or update UI
        Properties.Settings.Default.SplitterPosition = _splitter.SplitPosition;
    }
}
```

### Horizontal Splitter

```csharp
private void SetupHorizontalSplitter()
{
    // Top panel
    var topPanel = new KryptonPanel
    {
        Dock = DockStyle.Top,
        Height = 150,
        BackColor = Color.LightBlue
    };
    Controls.Add(topPanel);

    // Horizontal splitter
    var splitter = new KryptonSplitter
    {
        Dock = DockStyle.Top,
        MinExtra = 50,   // Bottom panel minimum height
        MinSize = 50     // Top panel minimum height
    };
    Controls.Add(splitter);

    // Bottom panel
    var bottomPanel = new KryptonPanel
    {
        Dock = DockStyle.Fill,
        BackColor = Color.LightGreen
    };
    Controls.Add(bottomPanel);
}
```

### Three-Panel Layout

```csharp
private void SetupThreePanelLayout()
{
    // Left panel
    var leftPanel = new KryptonPanel
    {
        Dock = DockStyle.Left,
        Width = 150
    };
    Controls.Add(leftPanel);

    // First splitter (vertical)
    var splitter1 = new KryptonSplitter
    {
        Dock = DockStyle.Left,
        MinExtra = 200,
        MinSize = 100
    };
    Controls.Add(splitter1);

    // Middle panel
    var middlePanel = new KryptonPanel
    {
        Dock = DockStyle.Left,
        Width = 300
    };
    Controls.Add(middlePanel);

    // Second splitter (vertical)
    var splitter2 = new KryptonSplitter
    {
        Dock = DockStyle.Left,
        MinExtra = 200,
        MinSize = 100
    };
    Controls.Add(splitter2);

    // Right panel
    var rightPanel = new KryptonPanel
    {
        Dock = DockStyle.Fill
    };
    Controls.Add(rightPanel);
}
```

### Splitter with Saved Position

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonSplitter _splitter;

    public MainForm()
    {
        InitializeComponent();
        SetupSplitter();
        LoadSplitterPosition();
    }

    private void SetupSplitter()
    {
        var leftPanel = new KryptonPanel { Dock = DockStyle.Left, Width = 200 };
        Controls.Add(leftPanel);

        _splitter = new KryptonSplitter
        {
            Dock = DockStyle.Left,
            MinExtra = 100,
            MinSize = 100
        };
        _splitter.SplitterMoved += OnSplitterMoved;
        Controls.Add(_splitter);

        var rightPanel = new KryptonPanel { Dock = DockStyle.Fill };
        Controls.Add(rightPanel);
    }

    private void LoadSplitterPosition()
    {
        var savedPosition = Properties.Settings.Default.SplitterPosition;
        if (savedPosition > 0)
        {
            _splitter.SplitPosition = savedPosition;
        }
    }

    private void OnSplitterMoved(object sender, SplitterEventArgs e)
    {
        Properties.Settings.Default.SplitterPosition = _splitter.SplitPosition;
        Properties.Settings.Default.Save();
    }
}
```

### Splitter with Custom Palette

```csharp
private void SetupSplitterWithCustomPalette()
{
    var splitter = new KryptonSplitter
    {
        Dock = DockStyle.Left,
        PaletteMode = PaletteMode.ProfessionalOffice2010
    };
    Controls.Add(splitter);
}
```

### Splitter in User Control

```csharp
public partial class ResizablePanelControl : UserControl
{
    private KryptonSplitter _splitter;

    public ResizablePanelControl()
    {
        InitializeComponent();
        SetupSplitter();
    }

    private void SetupSplitter()
    {
        var panel1 = new KryptonPanel
        {
            Dock = DockStyle.Left,
            Width = 200
        };
        Controls.Add(panel1);

        _splitter = new KryptonSplitter
        {
            Dock = DockStyle.Left,
            MinExtra = 150,
            MinSize = 150
        };
        Controls.Add(_splitter);

        var panel2 = new KryptonPanel
        {
            Dock = DockStyle.Fill
        };
        Controls.Add(panel2);
    }

    public int SplitterPosition
    {
        get => _splitter.SplitPosition;
        set => _splitter.SplitPosition = value;
    }
}
```

## Best Practices

### 1. Control Order Matters

Add controls to the container in the correct order:

```csharp
// Correct order:
Controls.Add(leftPanel);      // 1. First panel
Controls.Add(splitter);       // 2. Splitter
Controls.Add(rightPanel);     // 3. Second panel (fills remaining)
```

### 2. Set Minimum Sizes

Always set `MinExtra` and `MinSize` to prevent panels from becoming too small:

```csharp
splitter.MinExtra = 100;  // Minimum size for adjacent control
splitter.MinSize = 50;    // Minimum size for control before splitter
```

### 3. Save and Restore Position

Save the splitter position for user preferences:

```csharp
// Save
Properties.Settings.Default.SplitterPosition = splitter.SplitPosition;
Properties.Settings.Default.Save();

// Restore
if (Properties.Settings.Default.SplitterPosition > 0)
{
    splitter.SplitPosition = Properties.Settings.Default.SplitterPosition;
}
```

### 4. Handle SplitterMoved Event

Use the `SplitterMoved` event to respond to user actions:

```csharp
splitter.SplitterMoved += (sender, e) =>
{
    // Update layout, save preferences, refresh content, etc.
};
```

### 5. Use Appropriate Dock Values

- For vertical splitters: Use `DockStyle.Left` or `DockStyle.Right`
- For horizontal splitters: Use `DockStyle.Top` or `DockStyle.Bottom`
- Never use `DockStyle.Fill` for splitters

### 6. Consider BorderStyle

Set `BorderStyle` for visual feedback:

```csharp
splitter.BorderStyle = BorderStyle.FixedSingle;  // Visible border
```

### 7. Set TabStop to False

Splitters should not receive keyboard focus:

```csharp
splitter.TabStop = false;  // Default, but good to be explicit
```

## Integration with Krypton Palette System

### Using Global Palette

```csharp
var splitter = new KryptonSplitter();
// Uses global palette automatically
```

### Using Specific Theme

```csharp
splitter.PaletteMode = PaletteMode.ProfessionalOffice2010;
```

### Using Custom Palette

```csharp
var customPalette = new KryptonPalette();
// Configure palette...
splitter.PaletteMode = PaletteMode.Custom;
splitter.Palette = customPalette;
```

### Responding to Palette Changes

The splitter automatically responds to global palette changes when `PaletteMode` is set to `Global`:

```csharp
// When global palette changes, splitter automatically updates
KryptonManager.GlobalPalette = new PaletteOffice2010Blue();
// Splitter will reflect the new palette
```

## Layout Considerations

### Vertical Splitter Layout

```
┌─────────┬──────────────┐
│         │              │
│  Left   │   Splitter   │   Right
│  Panel  │              │   Panel
│         │              │
└─────────┴──────────────┘
```

**Dock Values:**
- Left Panel: `DockStyle.Left`
- Splitter: `DockStyle.Left`
- Right Panel: `DockStyle.Fill`

### Horizontal Splitter Layout

```
┌──────────────────────┐
│     Top Panel        │
├──────────────────────┤
│     Splitter         │
├──────────────────────┤
│    Bottom Panel      │
└──────────────────────┘
```

**Dock Values:**
- Top Panel: `DockStyle.Top`
- Splitter: `DockStyle.Top`
- Bottom Panel: `DockStyle.Fill`

## Common Patterns

### Explorer-Style Layout

```csharp
// Tree view on left, content on right
var treeView = new KryptonTreeView { Dock = DockStyle.Left, Width = 200 };
Controls.Add(treeView);

var splitter = new KryptonSplitter { Dock = DockStyle.Left, MinExtra = 300 };
Controls.Add(splitter);

var contentPanel = new KryptonPanel { Dock = DockStyle.Fill };
Controls.Add(contentPanel);
```

### Property Grid Layout

```csharp
// Properties on right, content on left
var contentPanel = new KryptonPanel { Dock = DockStyle.Fill };
Controls.Add(contentPanel);

var splitter = new KryptonSplitter { Dock = DockStyle.Right, MinExtra = 200 };
Controls.Add(splitter);

var propertyGrid = new KryptonPropertyGrid { Dock = DockStyle.Right, Width = 300 };
Controls.Add(propertyGrid);
```

## Limitations and Considerations

1. **Deprecated Control**: The underlying `Splitter` control is deprecated in favor of `SplitContainer`. Consider using `KryptonSplitContainer` for new development.

2. **Control Order**: The order in which controls are added to the container is critical for proper layout.

3. **Docking Required**: Splitters must be docked to function properly. They don't work well with absolute positioning.

4. **Minimum Sizes**: Always set appropriate minimum sizes to prevent UI issues.

5. **Visual Appearance**: The splitter's visual appearance is limited compared to `KryptonSplitContainer`.

## Troubleshooting

### Splitter Not Appearing

- Ensure controls are added in correct order
- Verify `Dock` property is set correctly
- Check that `Visible` is `true`
- Verify `Size` is appropriate (default is 3x3 pixels)

### Splitter Not Resizing

- Check `MinExtra` and `MinSize` values
- Verify adjacent controls are properly docked
- Ensure splitter is between two docked controls

### Splitter Position Not Saving

- Save position in `SplitterMoved` event
- Restore position after controls are added and layout is complete
- Consider using `Form.Load` or `Form.Shown` event

### Visual Inconsistencies

- Set `PaletteMode` to match application theme
- Use `KryptonSplitContainer` for better visual integration

## Migration from Standard Splitter

To migrate from standard `Splitter` to `KryptonSplitter`:

```csharp
// Before
var splitter = new Splitter();

// After
var splitter = new KryptonSplitter();
```

All properties and events remain the same - it's a drop-in replacement.

## Related Components

- `KryptonSplitContainer` - Modern alternative with better visual integration
- `KryptonSeparator` - For visual separators without resizing
- `KryptonPanel` - Container panels for splitter layouts
- `KryptonManager` - For global palette management

## See Also

- [System.Windows.Forms.Splitter Documentation](https://docs.microsoft.com/dotnet/api/system.windows.forms.splitter)
- [KryptonSplitContainer Documentation](./KryptonSplitContainer.md)

## Notes

- `KryptonSplitter` is provided for compatibility with existing code that uses the standard `Splitter` control
- For new development, consider using `KryptonSplitContainer` which provides better visual integration and more features
- The splitter automatically integrates with the Krypton palette system for consistent theming

