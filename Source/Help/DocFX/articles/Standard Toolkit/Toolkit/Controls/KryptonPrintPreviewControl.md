# KryptonPrintPreviewControl

## Overview

`KryptonPrintPreviewControl` is a Windows Forms control that provides a themed print preview display for `PrintDocument` objects. It wraps the standard .NET `PrintPreviewControl` and applies Krypton theming to create a visually consistent preview experience that matches your application's theme.

This control provides:
- Full Krypton palette theming integration
- All standard `PrintPreviewControl` functionality
- Customizable appearance through palette states
- Anti-aliasing support for improved rendering
- Multiple page layout options (columns and rows)

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Hierarchy

```
Control
└── VisualControlBase
    └── KryptonPrintPreviewControl
```

## Features

### Core Features

- **Themed Preview**: Displays print documents with full Krypton theming
- **Standard Functionality**: Inherits all features from `PrintPreviewControl`
- **Multiple Page Layouts**: Display 1, 2, 3, 4, or 6 pages simultaneously
- **Zoom Control**: Adjustable zoom levels with auto-zoom support
- **Anti-Aliasing**: Configurable anti-aliasing for smoother rendering
- **Page Navigation**: Navigate through document pages

### Theming Features

- **Palette Integration**: Full integration with Krypton palette system
- **State Management**: Normal and disabled states with customizable appearance
- **Style Customization**: Configurable panel background style
- **Dynamic Updates**: Responds to palette changes automatically

## API Reference

### Constructors

#### `KryptonPrintPreviewControl()`

Initializes a new instance of the `KryptonPrintPreviewControl` class.

**Example:**
```csharp
var previewControl = new KryptonPrintPreviewControl();
```

**Notes:**
- Creates an internal `PrintPreviewControl` instance
- Sets up Krypton theming infrastructure
- Initializes with default panel style (`PanelAlternate`)
- Control is not selectable (only the child `PrintPreviewControl` is)

---

### Properties

#### `Document` (PrintDocument?)

Gets or sets the `PrintDocument` to preview.

- **Type**: `PrintDocument?`
- **Default Value**: `null`
- **Category**: Behavior
- **Description**: The PrintDocument to preview.

**Example:**
```csharp
var document = new KryptonPrintDocument();
previewControl.Document = document;
```

**Notes:**
- Can be any `PrintDocument`, including `KryptonPrintDocument`
- Setting to `null` clears the preview
- Changes are reflected immediately

---

#### `Columns` (int)

Gets or sets the number of pages displayed horizontally across the page.

- **Type**: `int`
- **Default Value**: `1`
- **Category**: Behavior
- **Description**: The number of pages displayed horizontally across the page.

**Example:**
```csharp
previewControl.Columns = 2; // Show 2 pages side by side
```

**Common Values:**
- `1`: Single column (default)
- `2`: Two columns
- `3`: Three columns

**Notes:**
- Combined with `Rows` to determine total pages shown
- Typical combinations: 1x1, 1x2, 1x3, 2x2, 2x3

---

#### `Rows` (int)

Gets or sets the number of pages displayed vertically down the page.

- **Type**: `int`
- **Default Value**: `1`
- **Category**: Behavior
- **Description**: The number of pages displayed vertically down the page.

**Example:**
```csharp
previewControl.Rows = 2; // Show 2 rows of pages
```

**Common Values:**
- `1`: Single row (default)
- `2`: Two rows

**Notes:**
- Combined with `Columns` to determine total pages shown
- Typical combinations: 1x1, 1x2, 1x3, 2x2, 2x3

---

#### `Zoom` (double)

Gets or sets the zoom level of the pages.

- **Type**: `double`
- **Default Value**: `0.3` (30%)
- **Category**: Behavior
- **Description**: The zoom level of the pages.

**Example:**
```csharp
previewControl.Zoom = 1.0;  // 100% zoom
previewControl.Zoom = 0.5; // 50% zoom
previewControl.Zoom = 2.0; // 200% zoom
```

**Valid Range:**
- Typically `0.25` (25%) to `5.0` (500%)
- Values depend on the underlying `PrintPreviewControl`

**Notes:**
- `1.0` represents 100% (actual size)
- Values less than `1.0` zoom out, greater than `1.0` zoom in
- Setting `AutoZoom` to `true` overrides this value

---

#### `AutoZoom` (bool)

Gets or sets a value indicating whether the control automatically resizes to fit its contents.

- **Type**: `bool`
- **Default Value**: `false`
- **Category**: Behavior
- **Description**: Indicates whether the control automatically resizes to fit its contents.

**Example:**
```csharp
previewControl.AutoZoom = true; // Automatically fit pages to control size
```

**Notes:**
- When `true`, the `Zoom` property is ignored
- Control automatically calculates zoom to fit all pages
- Useful for ensuring all pages are visible

---

#### `StartPage` (int)

Gets or sets the starting page number.

- **Type**: `int`
- **Default Value**: `0`
- **Category**: Behavior
- **Description**: The starting page number.

**Example:**
```csharp
previewControl.StartPage = 0; // Start at first page
previewControl.StartPage = 5; // Start at page 6 (0-based)
```

**Notes:**
- Zero-based index (0 = first page)
- Raises `StartPageChanged` event when changed
- Must be within valid page range

---

#### `UseAntiAlias` (bool)

Gets or sets a value indicating whether anti-aliasing is used when rendering the page.

- **Type**: `bool`
- **Default Value**: `true`
- **Category**: Behavior
- **Description**: Indicates whether anti-aliasing is used when rendering the page.

**Example:**
```csharp
previewControl.UseAntiAlias = true; // Smooth rendering
previewControl.UseAntiAlias = false; // Faster rendering, may appear jagged
```

**Notes:**
- Anti-aliasing improves visual quality but may impact performance
- Recommended for high-quality previews
- May be slower on complex documents

---

#### `PanelBackStyle` (PaletteBackStyle)

Gets and sets the panel style.

- **Type**: `PaletteBackStyle`
- **Default Value**: `PaletteBackStyle.PanelAlternate`
- **Category**: Visuals
- **Description**: Panel style.

**Example:**
```csharp
previewControl.PanelBackStyle = PaletteBackStyle.PanelClient;
previewControl.PanelBackStyle = PaletteBackStyle.PanelAlternate;
```

**Common Values:**
- `PaletteBackStyle.PanelClient`
- `PaletteBackStyle.PanelAlternate`
- `PaletteBackStyle.PanelCustom1`
- `PaletteBackStyle.PanelCustom2`
- `PaletteBackStyle.PanelCustom3`

**Notes:**
- Affects the background appearance of the control
- Changing this property triggers a repaint

---

#### `StateCommon` (PaletteBack)

Gets access to the common print preview control appearance that other states can override.

- **Type**: `PaletteBack`
- **Category**: Visuals
- **Description**: Overrides for defining common print preview control appearance that other states can override.
- **DesignerSerializationVisibility**: Content

**Example:**
```csharp
previewControl.StateCommon.Back.Color1 = Color.LightGray;
```

**Notes:**
- Use this to set common appearance properties
- Other states inherit from this unless overridden
- Changes trigger a repaint

---

#### `StateDisabled` (PaletteBack)

Gets access to the disabled print preview control appearance.

- **Type**: `PaletteBack`
- **Category**: Visuals
- **Description**: Overrides for defining disabled print preview control appearance.
- **DesignerSerializationVisibility**: Content

**Example:**
```csharp
previewControl.StateDisabled.Back.Color1 = Color.Gray;
```

**Notes:**
- Applied when `Enabled` is `false`
- Inherits from `StateCommon` unless overridden
- Changes trigger a repaint

---

#### `StateNormal` (PaletteBack)

Gets access to the normal print preview control appearance.

- **Type**: `PaletteBack`
- **Category**: Visuals
- **Description**: Overrides for defining normal print preview control appearance.
- **DesignerSerializationVisibility**: Content

**Example:**
```csharp
previewControl.StateNormal.Back.Color1 = Color.White;
```

**Notes:**
- Applied when `Enabled` is `true`
- Inherits from `StateCommon` unless overridden
- Changes trigger a repaint

---

#### `PrintPreviewControl` (PrintPreviewControl)

Gets access to the contained `PrintPreviewControl` instance.

- **Type**: `PrintPreviewControl`
- **Browsable**: `false`
- **EditorBrowsable**: Always
- **DesignerSerializationVisibility**: Hidden

**Example:**
```csharp
var baseControl = previewControl.PrintPreviewControl;
// Access standard PrintPreviewControl members if needed
```

**Notes:**
- Provides direct access to the underlying .NET control
- Use for advanced scenarios requiring standard control features
- Most functionality is exposed through wrapper properties

---

#### `TabStop` (bool)

Gets and sets if the control is in the tab chain.

- **Type**: `bool`
- **DesignerSerializationVisibility**: Visible

**Example:**
```csharp
previewControl.TabStop = true; // Control can receive focus via Tab key
```

**Notes:**
- Actually controls the tab stop of the internal `PrintPreviewControl`
- The wrapper control itself is not selectable

---

#### `BackColor` (Color) - Hidden

Gets or sets the background color for the control.

- **Type**: `Color`
- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Background color comes from the palette system
- Setting this property has no effect

---

#### `ForeColor` (Color) - Hidden

Gets or sets the foreground color for the control.

- **Type**: `Color`
- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Foreground color comes from the palette system
- Setting this property has no effect

---

#### `BackgroundImage` (Image?) - Hidden

Gets or sets the background image displayed in the control.

- **Type**: `Image?`
- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Background images come from the palette system
- Setting this property has no effect

---

#### `BackgroundImageLayout` (ImageLayout) - Hidden

Gets or sets the background image layout.

- **Type**: `ImageLayout`
- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Layout comes from the palette system
- Setting this property has no effect

### Events

#### `StartPageChanged`

Occurs when the starting page changes.

- **Type**: `EventHandler?`
- **Category**: Property Changed
- **Description**: Occurs when the starting page changes.

**Example:**
```csharp
previewControl.StartPageChanged += (sender, e) =>
{
    var control = (KryptonPrintPreviewControl)sender;
    UpdatePageLabel(control.StartPage);
};
```

**Notes:**
- Raised when `StartPage` property changes
- Useful for updating UI elements that display current page

---

#### `BackColorChanged` - Hidden

Occurs when the value of the BackColor property changes.

- **Type**: `EventHandler?`
- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

---

#### `BackgroundImageChanged` - Hidden

Occurs when the value of the BackgroundImage property changes.

- **Type**: `EventHandler?`
- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

---

#### `BackgroundImageLayoutChanged` - Hidden

Occurs when the value of the BackgroundImageLayout property changes.

- **Type**: `EventHandler?`
- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

---

#### `ForeColorChanged` - Hidden

Occurs when the value of the ForeColor property changes.

- **Type**: `EventHandler?`
- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

## Usage Examples

### Basic Usage

```csharp
using Krypton.Toolkit;
using System.Drawing.Printing;

// Create a print document
var document = new KryptonPrintDocument();
document.DocumentName = "My Document";

// Set up print event handlers
document.PrintPage += (sender, e) =>
{
    e.Graphics.DrawString("Hello, World!", 
        new Font("Arial", 12), 
        Brushes.Black, 
        new PointF(100, 100));
    e.HasMorePages = false;
};

// Create and configure preview control
var previewControl = new KryptonPrintPreviewControl
{
    Document = document,
    Dock = DockStyle.Fill,
    Zoom = 0.5,  // 50% zoom
    Columns = 1,
    Rows = 1,
    UseAntiAlias = true
};

// Add to form
this.Controls.Add(previewControl);
```

### Custom Form with Preview Control

```csharp
public partial class PreviewForm : KryptonForm
{
    private KryptonPrintPreviewControl _previewControl;
    private KryptonPrintDocument _document;

    public PreviewForm(KryptonPrintDocument document)
    {
        InitializeComponent();
        
        _document = document;
        
        // Create preview control
        _previewControl = new KryptonPrintPreviewControl
        {
            Document = _document,
            Dock = DockStyle.Fill,
            Zoom = 1.0,
            Columns = 1,
            Rows = 1,
            UseAntiAlias = true,
            PanelBackStyle = PaletteBackStyle.PanelClient
        };
        
        // Add to form
        Controls.Add(_previewControl);
        
        // Set up toolbar for zoom and navigation
        SetupToolbar();
    }
    
    private void SetupToolbar()
    {
        // Add zoom buttons, page navigation, etc.
        // ... toolbar setup code
    }
}
```

### Multiple Page Layout

```csharp
// Show 2 pages side by side
previewControl.Columns = 2;
previewControl.Rows = 1;

// Show 4 pages in a 2x2 grid
previewControl.Columns = 2;
previewControl.Rows = 2;

// Show 6 pages in a 2x3 grid
previewControl.Columns = 3;
previewControl.Rows = 2;
```

### Zoom Control

```csharp
// Set specific zoom level
previewControl.Zoom = 0.25; // 25% - see more pages
previewControl.Zoom = 0.5;  // 50% - standard view
previewControl.Zoom = 1.0;  // 100% - actual size
previewControl.Zoom = 2.0;  // 200% - zoomed in

// Enable auto-zoom to fit
previewControl.AutoZoom = true;
// Now Zoom property is ignored, pages fit to control size
```

### Custom Appearance

```csharp
// Customize appearance through palette states
previewControl.PanelBackStyle = PaletteBackStyle.PanelAlternate;

// Customize common state
previewControl.StateCommon.Back.Color1 = Color.White;
previewControl.StateCommon.Back.Color2 = Color.LightGray;

// Customize normal state
previewControl.StateNormal.Back.Color1 = Color.White;

// Customize disabled state
previewControl.StateDisabled.Back.Color1 = Color.Gray;
previewControl.StateDisabled.Back.Color2 = Color.DarkGray;
```

### Page Navigation

```csharp
// Navigate to specific page
previewControl.StartPage = 0;  // First page
previewControl.StartPage = 5;  // Sixth page (0-based)

// Handle page changes
previewControl.StartPageChanged += (sender, e) =>
{
    var control = (KryptonPrintPreviewControl)sender;
    statusLabel.Text = $"Page {control.StartPage + 1}";
};
```

### Integration with KryptonPrintPreviewDialog

```csharp
// The dialog uses this control internally
var dialog = new KryptonPrintPreviewDialog
{
    Document = document
};

// Access the control after showing dialog
dialog.ShowDialog();

// Access control (may be null if dialog not shown)
var control = dialog.PrintPreviewControl;
if (control != null)
{
    control.Zoom = 1.0;
    control.Columns = 2;
}
```

### Dynamic Document Updates

```csharp
// Update document and refresh preview
var newDocument = new KryptonPrintDocument();
newDocument.PrintPage += NewDocument_PrintPage;

previewControl.Document = newDocument;
// Preview updates automatically

// Clear preview
previewControl.Document = null;
```

### Responding to Palette Changes

```csharp
// Control automatically responds to palette changes
KryptonManager.GlobalPaletteMode = PaletteMode.Office365Blue;
// Control appearance updates automatically

// Or customize per control
previewControl.PanelBackStyle = PaletteBackStyle.PanelCustom1;
```

## Integration with Krypton Toolkit

### Palette Integration

`KryptonPrintPreviewControl` fully integrates with the Krypton theming system:

- **Automatic Theming**: Uses the current global palette by default
- **Visual Consistency**: Matches the appearance of other Krypton controls
- **Dynamic Updates**: Responds to global palette changes automatically
- **State Management**: Supports normal and disabled states

### Related Components

- **`KryptonPrintDocument`**: The document class used for printing
- **`KryptonPrintPreviewDialog`**: Dialog that contains this control
- **`VisualPrintPreviewForm`**: Internal form class that uses this control
- **`PrintPreviewControl`**: The underlying .NET control

### Architecture

The control uses a composition pattern:

```
KryptonPrintPreviewControl (wrapper)
└── InternalPrintPreviewControl (internal PrintPreviewControl)
    └── ViewManager (Krypton rendering)
        └── ViewDrawDocker (themed border/background)
            └── ViewLayoutFill (content area)
```

## Design-Time Support

### Toolbox Integration

- **Toolbox Item**: `true`
- **Toolbox Bitmap**: `ToolboxBitmaps.KryptonPrintPreview.bmp`
- **Default Event**: `StartPageChanged`
- **Default Property**: `Document`
- **Designer Category**: Code

### Property Grid Support

All properties are visible in the Visual Studio property grid with appropriate categories:
- **Behavior**: `Document`, `Columns`, `Rows`, `Zoom`, `AutoZoom`, `StartPage`, `UseAntiAlias`, `TabStop`
- **Visuals**: `PanelBackStyle`, `StateCommon`, `StateDisabled`, `StateNormal`

### Designer Support

- Can be added to forms via toolbox
- Properties can be set in property grid
- Events can be wired in designer
- Supports standard WinForms designer features

## Thread Safety

This class is **not thread-safe**. All operations should be performed on the UI thread.

## Disposal Pattern

The class implements proper disposal:

```csharp
protected override void Dispose(bool isDisposing)
{
    if (!_disposed)
    {
        if (isDisposing)
        {
            _previewControl?.Dispose();
        }
        _disposed = true;
    }
}
```

**Best Practice**: The control is disposed automatically when its parent form is disposed. For manual disposal:

```csharp
previewControl.Dispose();
```

## Performance Considerations

- **Rendering**: Anti-aliasing improves quality but may impact performance
- **Large Documents**: Complex documents with many pages may render slowly
- **Zoom Changes**: Changing zoom triggers a full repaint
- **Layout Changes**: Changing `Columns` or `Rows` triggers a full repaint
- **Memory**: Caches rendered pages internally

## Best Practices

1. **Set Document First**: Set the `Document` property before configuring other properties
2. **Use Appropriate Zoom**: Start with `AutoZoom = true` or a reasonable zoom level
3. **Disable Anti-Aliasing if Needed**: Disable for better performance on slower systems
4. **Handle Page Changes**: Subscribe to `StartPageChanged` for navigation UI
5. **Use Palette States**: Customize appearance through palette states rather than direct color properties

## Limitations

1. **Standard Control Wrapper**: Wraps standard `PrintPreviewControl`; some limitations may apply
2. **Page Count**: Does not expose direct page count (must be determined from document)
3. **Printing**: Does not handle printing directly (use `KryptonPrintDialog` or document's `Print()` method)
4. **Custom Rendering**: Limited ability to customize the page rendering (handled by `PrintPreviewControl`)

## Internal Implementation Details

### InternalPrintPreviewControl

The control uses an internal class that extends `PrintPreviewControl`:

- **Purpose**: Wraps the standard control with Krypton-specific behavior
- **Hit Testing**: Handles hit testing in design mode
- **AutoZoom**: Initialized with `AutoZoom = false` (controlled by wrapper)

### View Manager

Uses Krypton's view manager system for rendering:

- **ViewDrawDocker**: Provides themed border and background
- **ViewLayoutFill**: Manages the fill area for the preview control
- **Palette States**: Applies appropriate palette state based on `Enabled` property

## See Also

- [`KryptonPrintPreviewDialog`](../Components/KryptonPrintPreviewDialog.md) - Dialog component using this control
- [`KryptonPrintDocument`](KryptonPrintDocument.md) - Document class for themed printing
- [`KryptonPrintDialog`](../Components/KryptonPrintDialog.md) - Print dialog component