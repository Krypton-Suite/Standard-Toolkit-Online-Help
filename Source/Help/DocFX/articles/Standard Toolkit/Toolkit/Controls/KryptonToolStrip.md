# KryptonToolStrip

## Overview

`KryptonToolStrip` is a thin wrapper around the standard Windows Forms `ToolStrip` that automatically applies Krypton theme rendering. It provides a themeable toolbar with all standard ToolStrip functionality while integrating seamlessly with the Krypton design system.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `ScrollableControl` → `ToolStrip` → `KryptonToolStrip`

## Key Features

### Automatic Theming
- Applies Krypton renderer automatically
- Updates with global palette changes
- No configuration required

### Full ToolStrip Functionality
- All standard ToolStrip items supported
- Docking and overflow support
- Customizable layout
- Image scaling

### Minimal Code
- Single line change from ToolStrip
- Drop-in replacement
- Inherits all ToolStrip behavior

---

## Constructor

### KryptonToolStrip()

Initializes a new instance with Krypton rendering enabled.

```csharp
public KryptonToolStrip()
```

**Initialization:**
- Sets `RenderMode` to `ToolStripRenderMode.ManagerRenderMode`
- Automatically uses the Krypton renderer from ToolStripManager

---

## Properties

### Inherited Properties

All standard `ToolStrip` properties are available:

#### Items
Gets the collection of items in the ToolStrip.

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public ToolStripItemCollection Items { get; }
```

---

#### Dock
Gets or sets which edge of the parent container the ToolStrip is docked to.

```csharp
[DefaultValue(DockStyle.Top)]
public override DockStyle Dock { get; set; }
```

---

#### GripStyle
Gets or sets whether the ToolStrip displays a grip for moving.

```csharp
[DefaultValue(ToolStripGripStyle.Visible)]
public ToolStripGripStyle GripStyle { get; set; }
```

---

#### ImageScalingSize
Gets or sets the size of the images used on the ToolStrip.

```csharp
[DefaultValue(typeof(Size), "16, 16")]
public Size ImageScalingSize { get; set; }
```

---

#### LayoutStyle
Gets or sets how items are laid out.

```csharp
[DefaultValue(ToolStripLayoutStyle.HorizontalStackWithOverflow)]
public ToolStripLayoutStyle LayoutStyle { get; set; }
```

---

#### ShowItemToolTips
Gets or sets whether tooltips are shown for items.

```csharp
[DefaultValue(true)]
public bool ShowItemToolTips { get; set; }
```

---

#### Renderer
Gets or sets the renderer (automatically set to Krypton renderer).

```csharp
[Browsable(false)]
public ToolStripRenderer Renderer { get; set; }
```

**Remarks:**
- Automatically managed by `RenderMode = ManagerRenderMode`
- Should not normally need to set manually

---

## Usage Examples

### Basic Toolbar

```csharp
var toolStrip = new KryptonToolStrip
{
    Dock = DockStyle.Top
};

// Add standard items
toolStrip.Items.Add(new ToolStripButton("New", Properties.Resources.NewIcon));
toolStrip.Items.Add(new ToolStripButton("Open", Properties.Resources.OpenIcon));
toolStrip.Items.Add(new ToolStripButton("Save", Properties.Resources.SaveIcon));
toolStrip.Items.Add(new ToolStripSeparator());
toolStrip.Items.Add(new ToolStripButton("Cut", Properties.Resources.CutIcon));
toolStrip.Items.Add(new ToolStripButton("Copy", Properties.Resources.CopyIcon));
toolStrip.Items.Add(new ToolStripButton("Paste", Properties.Resources.PasteIcon));

this.Controls.Add(toolStrip);
```

---

### File Operations Toolbar

```csharp
var fileToolbar = new KryptonToolStrip();

var newButton = new ToolStripButton
{
    Text = "New",
    Image = Properties.Resources.NewDocument,
    DisplayStyle = ToolStripItemDisplayStyle.Image,
    ToolTipText = "Create a new document (Ctrl+N)"
};
newButton.Click += NewDocument_Click;

var openButton = new ToolStripButton
{
    Text = "Open",
    Image = Properties.Resources.OpenFolder,
    DisplayStyle = ToolStripItemDisplayStyle.Image,
    ToolTipText = "Open an existing document (Ctrl+O)"
};
openButton.Click += OpenDocument_Click;

var saveButton = new ToolStripButton
{
    Text = "Save",
    Image = Properties.Resources.SaveIcon,
    DisplayStyle = ToolStripItemDisplayStyle.Image,
    ToolTipText = "Save the current document (Ctrl+S)"
};
saveButton.Click += SaveDocument_Click;

fileToolbar.Items.AddRange(new ToolStripItem[] 
{
    newButton,
    openButton,
    saveButton
});
```

---

### Toolbar with Dropdown

```csharp
var toolbar = new KryptonToolStrip();

// Create dropdown button
var fileDropDown = new ToolStripDropDownButton
{
    Text = "File",
    Image = Properties.Resources.FileIcon
};

// Add menu items to dropdown
fileDropDown.DropDownItems.Add("New", null, (s, e) => NewFile());
fileDropDown.DropDownItems.Add("Open", null, (s, e) => OpenFile());
fileDropDown.DropDownItems.Add("Save", null, (s, e) => SaveFile());
fileDropDown.DropDownItems.Add(new ToolStripSeparator());
fileDropDown.DropDownItems.Add("Exit", null, (s, e) => Application.Exit());

toolbar.Items.Add(fileDropDown);
```

---

### Toolbar with ComboBox

```csharp
var toolbar = new KryptonToolStrip();

toolbar.Items.Add(new ToolStripLabel("Font:"));

var fontCombo = new ToolStripComboBox
{
    Width = 150,
    DropDownStyle = ComboBoxStyle.DropDownList
};
fontCombo.Items.AddRange(new object[] 
{
    "Arial",
    "Calibri",
    "Times New Roman",
    "Verdana"
});
fontCombo.SelectedIndex = 0;
fontCombo.SelectedIndexChanged += (s, e) => 
{
    ApplyFont(fontCombo.SelectedItem.ToString());
};

toolbar.Items.Add(fontCombo);

toolbar.Items.Add(new ToolStripSeparator());

var sizeCombo = new ToolStripComboBox
{
    Width = 60
};
sizeCombo.Items.AddRange(new object[] { "8", "10", "12", "14", "16", "18", "20" });
sizeCombo.SelectedIndex = 2;

toolbar.Items.Add(new ToolStripLabel("Size:"));
toolbar.Items.Add(sizeCombo);
```

---

### Formatting Toolbar

```csharp
var formatToolbar = new KryptonToolStrip();

// Text formatting
var boldButton = new ToolStripButton
{
    Text = "B",
    Font = new Font("Arial", 10, FontStyle.Bold),
    ToolTipText = "Bold (Ctrl+B)",
    CheckOnClick = true
};
boldButton.CheckedChanged += (s, e) => ApplyBold(boldButton.Checked);

var italicButton = new ToolStripButton
{
    Text = "I",
    Font = new Font("Arial", 10, FontStyle.Italic),
    ToolTipText = "Italic (Ctrl+I)",
    CheckOnClick = true
};
italicButton.CheckedChanged += (s, e) => ApplyItalic(italicButton.Checked);

var underlineButton = new ToolStripButton
{
    Text = "U",
    Font = new Font("Arial", 10, FontStyle.Underline),
    ToolTipText = "Underline (Ctrl+U)",
    CheckOnClick = true
};
underlineButton.CheckedChanged += (s, e) => ApplyUnderline(underlineButton.Checked);

formatToolbar.Items.AddRange(new ToolStripItem[]
{
    boldButton,
    italicButton,
    underlineButton
});
```

---

### Multiple Toolbars

```csharp
public class MainForm : KryptonForm
{
    public MainForm()
    {
        // Standard toolbar
        var standardToolbar = new KryptonToolStrip
        {
            Dock = DockStyle.Top,
            Name = "standardToolbar"
        };
        standardToolbar.Items.Add(new ToolStripButton("New"));
        standardToolbar.Items.Add(new ToolStripButton("Open"));
        standardToolbar.Items.Add(new ToolStripButton("Save"));
        
        // Formatting toolbar
        var formatToolbar = new KryptonToolStrip
        {
            Dock = DockStyle.Top,
            Name = "formatToolbar"
        };
        formatToolbar.Items.Add(new ToolStripButton("Bold"));
        formatToolbar.Items.Add(new ToolStripButton("Italic"));
        formatToolbar.Items.Add(new ToolStripButton("Underline"));
        
        // Add in reverse order (top to bottom)
        Controls.Add(formatToolbar);
        Controls.Add(standardToolbar);
    }
}
```

---

### Dynamic Toolbar

```csharp
private void BuildDynamicToolbar()
{
    var toolbar = new KryptonToolStrip();
    
    // Dynamically create buttons based on available commands
    foreach (var command in GetAvailableCommands())
    {
        var button = new ToolStripButton
        {
            Text = command.Name,
            Image = command.Icon,
            ToolTipText = command.Description,
            Tag = command
        };
        
        button.Click += (s, e) =>
        {
            if (s is ToolStripButton btn && btn.Tag is Command cmd)
            {
                cmd.Execute();
            }
        };
        
        toolbar.Items.Add(button);
    }
}
```

---

### Context-Sensitive Toolbar

```csharp
private KryptonToolStrip toolbar;

private void UpdateToolbarState()
{
    // Enable/disable buttons based on context
    var hasSelection = textBox.SelectionLength > 0;
    var canUndo = textBox.CanUndo;
    
    cutButton.Enabled = hasSelection;
    copyButton.Enabled = hasSelection;
    pasteButton.Enabled = Clipboard.ContainsText();
    undoButton.Enabled = canUndo;
}

private void textBox_SelectionChanged(object sender, EventArgs e)
{
    UpdateToolbarState();
}
```

---

### ToolStrip with Progress

```csharp
var toolbar = new KryptonToolStrip();

var progressBar = new ToolStripProgressBar
{
    Width = 200,
    Style = ProgressBarStyle.Marquee,
    Visible = false
};

var statusLabel = new ToolStripLabel
{
    Text = "Ready",
    Spring = true,
    TextAlign = ContentAlignment.MiddleLeft
};

toolbar.Items.Add(new ToolStripButton("Process"));
toolbar.Items.Add(progressBar);
toolbar.Items.Add(statusLabel);

private void StartProcess()
{
    progressBar.Visible = true;
    statusLabel.Text = "Processing...";
    
    // Do work
    
    progressBar.Visible = false;
    statusLabel.Text = "Complete";
}
```

---

### Custom ToolStrip Item

```csharp
public class ColorPickerToolStripItem : ToolStripControlHost
{
    public ColorPickerToolStripItem() 
        : base(new KryptonColorButton())
    {
    }
    
    public KryptonColorButton ColorButton => Control as KryptonColorButton;
}

// Usage:
var toolbar = new KryptonToolStrip();
var colorPicker = new ColorPickerToolStripItem();
colorPicker.ColorButton.SelectedColorChanged += (s, e) =>
{
    ApplyColor(colorPicker.ColorButton.SelectedColor);
};
toolbar.Items.Add(colorPicker);
```

---

### Toolbar Overflow Handling

```csharp
var toolbar = new KryptonToolStrip
{
    LayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow,
    CanOverflow = true
};

// Set overflow behavior for individual items
var alwaysVisibleButton = new ToolStripButton("Important")
{
    Overflow = ToolStripItemOverflow.Never // Always visible
};

var overflowButton = new ToolStripButton("Optional")
{
    Overflow = ToolStripItemOverflow.AsNeeded // Can overflow
};

toolbar.Items.Add(alwaysVisibleButton);
toolbar.Items.Add(overflowButton);
```

---

## Design Considerations

### Rendering

The control automatically uses the Krypton renderer through:

```csharp
RenderMode = ToolStripRenderMode.ManagerRenderMode
```

This tells the ToolStrip to use the renderer set in `ToolStripManager`, which Krypton configures globally.

---

### Theme Updates

Theme changes are handled automatically:
1. Global palette changes
2. ToolStripManager updates renderer
3. ToolStrip repaints with new theme

**No code required** - happens automatically!

---

### Performance

- Lightweight wrapper (minimal overhead)
- Native ToolStrip rendering performance
- Efficient item management

---

## Common Scenarios

### Application Menu Bar Alternative

```csharp
// Use as a modern alternative to MenuStrip
var menuToolbar = new KryptonToolStrip
{
    Dock = DockStyle.Top,
    GripStyle = ToolStripGripStyle.Hidden
};

var fileMenu = new ToolStripDropDownButton("File");
var editMenu = new ToolStripDropDownButton("Edit");
var viewMenu = new ToolStripDropDownButton("View");

menuToolbar.Items.AddRange(new ToolStripItem[] { fileMenu, editMenu, viewMenu });
```

---

### Status Toolbar

```csharp
// Bottom-docked toolbar for status info
var statusToolbar = new KryptonToolStrip
{
    Dock = DockStyle.Bottom,
    GripStyle = ToolStripGripStyle.Hidden,
    LayoutStyle = ToolStripLayoutStyle.HorizontalStackWithOverflow
};

var lineLabel = new ToolStripLabel("Line: 1");
var columnLabel = new ToolStripLabel("Column: 1");
var zoomLabel = new ToolStripLabel("100%");

statusToolbar.Items.AddRange(new ToolStripItem[] 
{
    lineLabel,
    new ToolStripSeparator(),
    columnLabel,
    new ToolStripSeparator(),
    zoomLabel
});
```

---

### Ribbon Alternative (Simple)

```csharp
// Create a simple ribbon-like interface
var quickAccessToolbar = new KryptonToolStrip
{
    Dock = DockStyle.Top,
    GripStyle = ToolStripGripStyle.Hidden
};
quickAccessToolbar.Items.Add(new ToolStripButton("Save"));
quickAccessToolbar.Items.Add(new ToolStripButton("Undo"));
quickAccessToolbar.Items.Add(new ToolStripButton("Redo"));

var mainToolbar = new KryptonToolStrip
{
    Dock = DockStyle.Top,
    ImageScalingSize = new Size(32, 32)
};
// Add larger buttons for main commands

Controls.Add(mainToolbar);
Controls.Add(quickAccessToolbar);
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** 
  - Krypton.Toolkit core
  - ToolStripManager configuration

---

## Migration from Standard ToolStrip

### Simple Migration

**Before:**
```csharp
var toolStrip = new ToolStrip();
```

**After:**
```csharp
var toolStrip = new KryptonToolStrip();
```

That's it! Everything else remains the same.

---

### Designer Migration

1. Open form in Designer
2. Select ToolStrip control
3. Open Properties window
4. Change type from `ToolStrip` to `KryptonToolStrip`
5. Designer regenerates InitializeComponent code

---

## Comparison with Alternatives

### vs ToolStrip

**KryptonToolStrip:**
- ✅ Automatic Krypton theming
- ✅ Matches application appearance
- ✅ No additional code
- ✅ Drop-in replacement

**Standard ToolStrip:**
- ❌ Plain Windows theme
- ❌ Doesn't match Krypton controls
- ❌ Requires manual renderer setup

---

### vs KryptonRibbon

**KryptonToolStrip:**
- ✅ Simple and lightweight
- ✅ Compact vertical space
- ✅ Traditional toolbar UX
- ❌ Limited organization

**KryptonRibbon:**
- ✅ Rich organization (tabs, groups)
- ✅ Contextual tabs
- ✅ Large button support
- ❌ Takes significant vertical space
- ❌ More complex to configure

---

## See Also

- [KryptonRibbon](KryptonRibbon.md) - Full ribbon control
- [KryptonContextMenu](KryptonContextMenu.md) - Context menus
- [ToolStripRenderer](../Rendering/ToolStripRenderer.md) - Krypton renderer
- [ToolStripManager](https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.toolstripmanager) - Microsoft documentation

---

## Remarks

### When to Use

**Use KryptonToolStrip when:**
- You need a simple toolbar
- Migrating from standard ToolStrip
- Want automatic Krypton theming
- Space is at a premium

**Use KryptonRibbon when:**
- You have many commands to organize
- Need contextual command groups
- Building Office-style interface
- Vertical space is available

---

### Best Practices

1. **Icon Size:** Use consistent icon sizes (16x16 or 32x32)
2. **Tooltips:** Always provide helpful tooltips
3. **Grouping:** Use separators to group related commands
4. **Overflow:** Mark less important items as can-overflow
5. **Context:** Enable/disable buttons based on application state