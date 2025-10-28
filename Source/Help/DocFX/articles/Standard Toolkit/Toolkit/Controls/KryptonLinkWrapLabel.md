# KryptonLinkWrapLabel

## Overview

`KryptonLinkWrapLabel` is a Windows Forms control that extends the standard `LinkLabel` with Krypton palette styling and theming capabilities. It provides a themed link label with automatic text wrapping, supporting all Krypton visual styles and palettes.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `Label` → `LinkLabel` → `KryptonLinkWrapLabel`

## Key Features

### Palette Integration
- Full Krypton palette support with automatic theme switching
- Support for built-in and custom palettes
- Responds to global palette changes
- State-based styling (Normal, Disabled, Common)

### Visual Capabilities
- Automatic text wrapping
- Transparent background rendering
- Custom font and color overrides per state
- Text rendering hints (ClearType, AntiAlias, etc.)
- Multiple label styles (NormalPanel, BoldPanel, ItalicPanel, etc.)

### Behavior Features
- Mnemonic support with target control focus
- KryptonContextMenu integration
- Right-click context menu with keyboard shortcuts
- Designer-friendly with proper serialization

### Performance
- Double-buffered rendering to reduce flicker
- Optimized palette change handling
- Efficient parent background painting

---

## Constructor

### KryptonLinkWrapLabel()

Initializes a new instance of the `KryptonLinkWrapLabel` class.

```csharp
public KryptonLinkWrapLabel()
```

**Default Settings:**
- `AutoSize` = `true`
- `TabStop` = `false`
- `LabelStyle` = `LabelStyle.NormalPanel`
- `PaletteMode` = `PaletteMode.Global`
- Double buffering enabled

---

## Properties

### Appearance Properties

#### LabelStyle
Gets or sets the visual style of the label.

```csharp
[Category("Visuals")]
[Description("Label style.")]
[DefaultValue(LabelStyle.NormalPanel)]
public LabelStyle LabelStyle { get; set; }
```

**Available Styles:**
- `NormalPanel` - Standard panel label
- `BoldPanel` - Bold panel label
- `ItalicPanel` - Italic panel label
- `TitlePanel` - Title-style panel label
- `NormalControl` - Standard control label
- `BoldControl` - Bold control label
- `ItalicControl` - Italic control label
- `TitleControl` - Title-style control label
- `GroupBoxCaption` - Group box caption style
- `ToolTip` - Tooltip style
- `SuperTip` - Super tooltip style
- `KeyTip` - Key tip style
- `Custom1` through `Custom3` - Custom styles

**Example:**
```csharp
kryptonLinkWrapLabel1.LabelStyle = LabelStyle.BoldPanel;
```

---

#### AutoSize
Gets or sets whether the control automatically resizes to fit its content.

```csharp
[DefaultValue(true)]
public override bool AutoSize { get; set; }
```

**Default:** `true`

---

### Palette Properties

#### PaletteMode
Gets or sets the palette mode to use for styling.

```csharp
[Category("Visuals")]
[Description("Palette applied to drawing.")]
public PaletteMode PaletteMode { get; set; }
```

**Available Modes:**
- `Global` - Use the global palette (default)
- `ProfessionalSystem` - Professional system palette
- `ProfessionalOffice2003` - Office 2003 style
- `Office2007Blue/Silver/Black` - Office 2007 variants
- `Office2010Blue/Silver/Black` - Office 2010 variants
- `Office2013White` - Office 2013 style
- `Office365Blue/Silver/Black` - Office 365 variants
- `SparkleBlue/Orange/Purple` - Sparkle variants
- `Custom` - Use custom palette (set via `Palette` property)

**Example:**
```csharp
kryptonLinkWrapLabel1.PaletteMode = PaletteMode.Office2010Blue;
```

---

#### Palette
Gets or sets a custom palette for the control.

```csharp
[Category("Visuals")]
[Description("Custom palette applied to drawing.")]
[DefaultValue(null)]
public PaletteBase? Palette { get; set; }
```

**Remarks:**
- Setting this property automatically changes `PaletteMode` to `PaletteMode.Custom`
- Setting to `null` reverts to `PaletteMode.Global`

**Example:**
```csharp
var customPalette = new KryptonPalette();
// Configure custom palette...
kryptonLinkWrapLabel1.Palette = customPalette;
```

---

### State Properties

#### StateCommon
Gets access to common appearance settings that other states can override.

```csharp
[Category("Visuals")]
[Description("Overrides for defining common wrap label appearance that other states can override.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteWrapLabel StateCommon { get; }
```

**Properties Available:**
- `Font` - Override font
- `TextColor` - Override text color
- `Hint` - Text rendering hint

**Example:**
```csharp
kryptonLinkWrapLabel1.StateCommon.Font = new Font("Segoe UI", 10F, FontStyle.Bold);
kryptonLinkWrapLabel1.StateCommon.TextColor = Color.Navy;
kryptonLinkWrapLabel1.StateCommon.Hint = PaletteTextHint.ClearTypeGridFit;
```

---

#### StateNormal
Gets access to normal state appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining normal wrap label appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteWrapLabel StateNormal { get; }
```

**Remarks:**
- Applied when the control is enabled
- Overrides `StateCommon` settings

**Example:**
```csharp
kryptonLinkWrapLabel1.StateNormal.TextColor = Color.Blue;
```

---

#### StateDisabled
Gets access to disabled state appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled wrap label appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteWrapLabel StateDisabled { get; }
```

**Remarks:**
- Applied when `Enabled = false`
- Overrides `StateCommon` settings

**Example:**
```csharp
kryptonLinkWrapLabel1.StateDisabled.TextColor = Color.Gray;
```

---

### Behavior Properties

#### Target
Gets or sets the target control for mnemonic and click actions.

```csharp
[Category("Visuals")]
[Description("Target control for mnemonic and click actions.")]
[DefaultValue(null)]
public Control? Target { get; set; }
```

**Remarks:**
- When a mnemonic is activated (e.g., Alt+Key), focus moves to the target control
- The target must have `CanFocus = true`

**Example:**
```csharp
kryptonLinkWrapLabel1.Text = "&Name:";
kryptonLinkWrapLabel1.Target = kryptonTextBox1;
// Pressing Alt+N will focus kryptonTextBox1
```

---

#### KryptonContextMenu
Gets or sets the KryptonContextMenu to display on right-click.

```csharp
[Category("Behavior")]
[Description("The shortcut menu to show when the user right-clicks the page.")]
[DefaultValue(null)]
public KryptonContextMenu? KryptonContextMenu { get; set; }
```

**Example:**
```csharp
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Copy"));
contextMenu.Items.Add(new KryptonContextMenuItem("Paste"));
kryptonLinkWrapLabel1.KryptonContextMenu = contextMenu;
```

---

### Hidden Properties

The following base class properties are hidden as they conflict with Krypton theming:

- `BackColor` - Use palette settings instead
- `ForeColor` - Use `StateNormal.TextColor` or `StateDisabled.TextColor`
- `Font` - Use `StateNormal.Font` or `StateDisabled.Font`
- `BorderStyle` - Not supported
- `FlatStyle` - Not supported
- `TabIndex` - Hidden (but functional)
- `TabStop` - Hidden (defaults to `false`)

---

## Methods

### Public Methods

#### UpdateFont()
Manually updates the font based on current state and palette settings.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public void UpdateFont()
```

**Remarks:**
- Automatically called during paint operations
- Rarely needs to be called manually
- Respects state hierarchy: State-specific → StateCommon → Palette default

---

#### GetResolvedPalette()
Gets the actual palette being used for rendering.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public PaletteBase GetResolvedPalette()
```

**Returns:** The active `PaletteBase` instance.

**Example:**
```csharp
var activePalette = kryptonLinkWrapLabel1.GetResolvedPalette();
Console.WriteLine($"Using palette: {activePalette.GetType().Name}");
```

---

#### CreateToolStripRenderer()
Creates a ToolStripRenderer matching the current palette.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Advanced)]
public ToolStripRenderer? CreateToolStripRenderer()
```

**Returns:** A `ToolStripRenderer` instance configured for the current palette.

**Example:**
```csharp
var contextMenuStrip = new ContextMenuStrip();
contextMenuStrip.Renderer = kryptonLinkWrapLabel1.CreateToolStripRenderer();
```

---

#### AttachGlobalEvents() / UnattachGlobalEvents()
Controls whether the control responds to global palette changes.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public void AttachGlobalEvents()

[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public void UnattachGlobalEvents()
```

**Remarks:**
- Automatically managed by the control
- Useful for temporarily suspending palette updates during batch operations

---

#### ResetPaletteMode() / ResetPalette() / ResetLabelStyle()
Resets properties to their default values.

```csharp
public void ResetPaletteMode()  // Resets to PaletteMode.Global
public void ResetPalette()       // Resets to null (uses Global)
public void ResetLabelStyle()    // Resets to LabelStyle.NormalPanel
```

---

### Protected Methods

#### ProcessMnemonic(char)
Processes mnemonic characters for keyboard navigation.

```csharp
protected override bool ProcessMnemonic(char charCode)
```

**Remarks:**
- Automatically handles Alt+Key combinations
- Focuses the `Target` control if set
- Respects `UseMnemonic` property

---

#### ProcessCmdKey(ref Message, Keys)
Processes keyboard shortcuts for the context menu.

```csharp
protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
```

**Remarks:**
- Automatically invokes `KryptonContextMenu` shortcuts

---

## Events

### PaletteChanged
Occurs when the palette is changed.

```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the Palette property is changed.")]
public event EventHandler? PaletteChanged
```

**Example:**
```csharp
kryptonLinkWrapLabel1.PaletteChanged += (s, e) => 
{
    Console.WriteLine("Palette changed!");
};
```

---

### Inherited Link Events

All standard `LinkLabel` events are available:

- `LinkClicked` (Default Event)
- `LinkArea`
- `Links`
- `LinkBehavior`
- `LinkColor`
- `ActiveLinkColor`
- `VisitedLinkColor`
- `DisabledLinkColor`

---

## Usage Examples

### Basic Usage

```csharp
var linkLabel = new KryptonLinkWrapLabel
{
    Text = "Click here to visit our website",
    LabelStyle = LabelStyle.NormalPanel,
    AutoSize = true,
    Location = new Point(10, 10)
};

linkLabel.LinkClicked += (s, e) => 
{
    System.Diagnostics.Process.Start("https://example.com");
};

this.Controls.Add(linkLabel);
```

---

### With Custom Styling

```csharp
var linkLabel = new KryptonLinkWrapLabel
{
    Text = "Important Link",
    LabelStyle = LabelStyle.BoldPanel
};

// Customize normal state
linkLabel.StateNormal.Font = new Font("Segoe UI", 12F, FontStyle.Bold);
linkLabel.StateNormal.TextColor = Color.DarkBlue;

// Customize disabled state
linkLabel.StateDisabled.TextColor = Color.LightGray;
```

---

### With Mnemonic Support

```csharp
var nameLabel = new KryptonLinkWrapLabel
{
    Text = "&Username:",
    Target = usernameTextBox,
    Location = new Point(10, 10)
};

// User can press Alt+U to focus the username textbox
```

---

### With Context Menu

```csharp
var linkLabel = new KryptonLinkWrapLabel
{
    Text = "Right-click for options"
};

var contextMenu = new KryptonContextMenu();
var menuItems = contextMenu.Items.Add(new KryptonContextMenuItems());

menuItems.Items.Add(new KryptonContextMenuItem("Copy Link", null, (s, e) => 
{
    Clipboard.SetText(linkLabel.Text);
}));

menuItems.Items.Add(new KryptonContextMenuItem("Open in Browser", null, (s, e) => 
{
    // Open link logic
}));

linkLabel.KryptonContextMenu = contextMenu;
```

---

### Dynamic Palette Switching

```csharp
private void SwitchTheme(PaletteMode mode)
{
    kryptonLinkWrapLabel1.PaletteMode = mode;
    // Label automatically updates its appearance
}

// Example usage:
buttonOffice2010.Click += (s, e) => SwitchTheme(PaletteMode.Office2010Blue);
buttonOffice365.Click += (s, e) => SwitchTheme(PaletteMode.Office365Blue);
```

---

### Transparent Background

```csharp
// The control automatically paints a transparent background
// when placed on a parent with a background image or gradient

var linkLabel = new KryptonLinkWrapLabel
{
    Text = "Transparent label",
    BackColor = Color.Transparent  // Automatically handled
};

// Place on a panel with a background image
panelWithImage.Controls.Add(linkLabel);
```

---

## Design Considerations

### State Hierarchy

The control resolves appearance properties using the following priority:

1. **State-specific property** (e.g., `StateNormal.Font`)
2. **StateCommon property** (e.g., `StateCommon.Font`)
3. **Palette default** (from current palette)

**Example:**
```csharp
// If StateNormal.Font is null, falls back to StateCommon.Font
// If StateCommon.Font is also null, uses palette default font
```

---

### Performance Tips

1. **Batch Updates:** Suspend drawing during multiple property changes
```csharp
kryptonLinkWrapLabel1.SuspendLayout();
kryptonLinkWrapLabel1.Text = "New text";
kryptonLinkWrapLabel1.LabelStyle = LabelStyle.BoldPanel;
kryptonLinkWrapLabel1.StateNormal.TextColor = Color.Blue;
kryptonLinkWrapLabel1.ResumeLayout();
```

2. **Global Events:** Automatically attached/detached - no manual management needed

3. **Palette Caching:** The control caches palette references for efficient lookups

---

### Designer Support

The control is fully designer-compatible:

- Appears in the Toolbox under "Krypton Toolkit"
- Property grid shows categorized properties
- Smart tags for common operations
- Serializes only non-default values

---

## Common Scenarios

### Read-only Information Display

```csharp
var infoLabel = new KryptonLinkWrapLabel
{
    Text = "Learn more about this feature",
    LabelStyle = LabelStyle.NormalPanel,
    AutoSize = true
};

infoLabel.LinkClicked += (s, e) => 
{
    // Show help or documentation
    ShowHelp();
};
```

---

### Status Indicator with Link

```csharp
var statusLabel = new KryptonLinkWrapLabel
{
    Text = "Update available - Click to download",
    LabelStyle = LabelStyle.BoldPanel
};

statusLabel.StateNormal.TextColor = Color.Orange;

statusLabel.LinkClicked += async (s, e) => 
{
    await DownloadUpdate();
};
```

---

### Multi-line Wrapped Link

```csharp
var wrappedLink = new KryptonLinkWrapLabel
{
    Text = "This is a very long link label that will automatically " +
           "wrap to multiple lines when the control width is constrained.",
    MaximumSize = new Size(300, 0),  // Constrain width, allow height to grow
    AutoSize = true
};
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** Krypton.Toolkit core components

---

## See Also

- [KryptonLabel](KryptonLabel.md) - Non-link label variant
- [KryptonWrapLabel](KryptonWrapLabel.md) - Plain wrap label
- [PaletteBase](../Palette/PaletteBase.md) - Palette system
- [LabelStyle Enumeration](../Enumerations/LabelStyle.md) - Available styles
- [PaletteMode Enumeration](../Enumerations/PaletteMode.md) - Palette modes

---

## Remarks

### Differences from Standard LinkLabel

1. **Theming:** Full Krypton palette integration
2. **States:** Separate styling for normal and disabled states
3. **Transparent:** Automatic transparent background painting
4. **Context Menu:** Native KryptonContextMenu support
5. **Target:** Built-in mnemonic target support

---

### When to Use

**Use KryptonLinkWrapLabel when:**
- You need a link label that matches Krypton theme
- You want automatic text wrapping
- You need separate normal/disabled styling
- You want transparent background support