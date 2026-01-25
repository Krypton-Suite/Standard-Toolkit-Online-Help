# KryptonPrintPreviewControl

## Overview

`KryptonPrintPreviewControl` is a Windows Forms control that provides a themed print preview display for `PrintDocument` objects. It wraps the standard .NET `PrintPreviewControl` and applies Krypton theming to create a visually consistent preview experience that matches your application's theme.

This control provides:
- Full Krypton palette theming integration
- All standard `PrintPreviewControl` functionality
- Customizable appearance through palette states
- Anti-aliasing support for improved rendering
- Multiple page layout options (columns and rows)
- Seamless integration with the Krypton Toolkit theming system

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
- **Visual Consistency**: Matches the appearance of other Krypton controls

### Architecture Features

- **Composition Pattern**: Wraps standard `PrintPreviewControl` with Krypton theming
- **View Manager**: Uses Krypton's view manager system for rendering
- **Read-Only Controls Collection**: Prevents external modification of child controls
- **Design Mode Support**: Proper hit testing in Visual Studio designer

## API Reference

### Constructors

#### `KryptonPrintPreviewControl()`

Initializes a new instance of the `KryptonPrintPreviewControl` class.

**Example:**
```csharp
var previewControl = new KryptonPrintPreviewControl();
```

**Initialization Details:**
- Creates an internal `PrintPreviewControl` instance
- Sets up Krypton theming infrastructure with palette states
- Initializes with default panel style (`PanelAlternate`)
- Configures view manager for themed rendering
- Control is not selectable (only the child `PrintPreviewControl` is)
- Sets `AutoZoom` to `false` on the internal control

**Notes:**
- The control uses a composition pattern, wrapping the standard control
- The wrapper control itself cannot receive focus (only the child can)
- All theming is handled through the Krypton view manager system

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
- The document's `PrintPage` event is used to generate preview pages

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
previewControl.Columns = 3; // Show 3 pages side by side
```

**Common Values:**
- `1`: Single column (default)
- `2`: Two columns
- `3`: Three columns

**Common Combinations:**
- `Columns = 1, Rows = 1`: Single page view
- `Columns = 2, Rows = 1`: Two pages side by side
- `Columns = 3, Rows = 1`: Three pages side by side
- `Columns = 2, Rows = 2`: Four pages in a 2x2 grid
- `Columns = 3, Rows = 2`: Six pages in a 2x3 grid

**Notes:**
- Combined with `Rows` to determine total pages shown
- Changing this property triggers a layout recalculation
- More columns = smaller individual page size

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

**Common Combinations:**
- `Rows = 1, Columns = 1`: Single page view
- `Rows = 1, Columns = 2`: Two pages side by side
- `Rows = 2, Columns = 2`: Four pages in a 2x2 grid
- `Rows = 2, Columns = 3`: Six pages in a 2x3 grid

**Notes:**
- Combined with `Columns` to determine total pages shown
- Changing this property triggers a layout recalculation
- More rows = smaller individual page size

---

#### `Zoom` (double)

Gets or sets the zoom level of the pages.

- **Type**: `double`
- **Default Value**: `0.3` (30%)
- **Category**: Behavior
- **Description**: The zoom level of the pages.

**Example:**
```csharp
previewControl.Zoom = 1.0;  // 100% zoom (actual size)
previewControl.Zoom = 0.5;  // 50% zoom (half size)
previewControl.Zoom = 2.0;  // 200% zoom (double size)
previewControl.Zoom = 0.25; // 25% zoom (quarter size)
```

**Valid Range:**
- Typically `0.25` (25%) to `5.0` (500%)
- Exact range depends on the underlying `PrintPreviewControl`
- Values outside the valid range are clamped

**Common Zoom Levels:**
- `0.25`: 25% - See many pages at once
- `0.5`: 50% - Standard overview
- `0.75`: 75% - Slightly zoomed
- `1.0`: 100% - Actual size (WYSIWYG)
- `1.5`: 150% - Zoomed in
- `2.0`: 200% - Highly zoomed

**Notes:**
- `1.0` represents 100% (actual size)
- Values less than `1.0` zoom out, greater than `1.0` zoom in
- Setting `AutoZoom` to `true` overrides this value
- Changing zoom triggers a full repaint

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
previewControl.AutoZoom = false; // Use manual zoom level
```

**Behavior:**
- When `true`: The control automatically calculates zoom to fit all pages within the control's bounds
- When `false`: Uses the value specified in the `Zoom` property

**Notes:**
- When `true`, the `Zoom` property is ignored
- Control automatically calculates zoom to fit all pages
- Useful for ensuring all pages are visible without scrolling
- Changing this property triggers a layout recalculation

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
previewControl.StartPage = 5;  // Start at page 6 (0-based)
```

**Page Numbering:**
- Zero-based index (0 = first page, 1 = second page, etc.)
- Must be within valid page range (0 to page count - 1)
- Values outside range are clamped

**Notes:**
- Zero-based index (0 = first page)
- Raises `StartPageChanged` event when changed
- Must be within valid page range
- Used for navigating through multi-page documents

---

#### `UseAntiAlias` (bool)

Gets or sets a value indicating whether anti-aliasing is used when rendering the page.

- **Type**: `bool`
- **Default Value**: `true`
- **Category**: Behavior
- **Description**: Indicates whether anti-aliasing is used when rendering the page.

**Example:**
```csharp
previewControl.UseAntiAlias = true;  // Smooth rendering (default)
previewControl.UseAntiAlias = false; // Faster rendering, may appear jagged
```

**Performance Impact:**
- `true`: Better visual quality, may be slower on complex documents
- `false`: Faster rendering, text and graphics may appear jagged

**Notes:**
- Anti-aliasing improves visual quality but may impact performance
- Recommended for high-quality previews
- May be slower on complex documents with many graphics
- Changing this property triggers a repaint

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
previewControl.PanelBackStyle = PaletteBackStyle.PanelCustom1;
```

**Common Values:**
- `PaletteBackStyle.PanelClient`: Standard client panel style
- `PaletteBackStyle.PanelAlternate`: Alternate panel style (default)
- `PaletteBackStyle.PanelCustom1`: Custom panel style 1
- `PaletteBackStyle.PanelCustom2`: Custom panel style 2
- `PaletteBackStyle.PanelCustom3`: Custom panel style 3

**Notes:**
- Affects the background appearance of the control
- Changing this property triggers a repaint
- Uses the palette's definition for the selected style
- Can be customized through palette states

---

#### `StateCommon` (PaletteBack)

Gets access to the common print preview control appearance that other states can override.

- **Type**: `PaletteBack`
- **Category**: Visuals
- **Description**: Overrides for defining common print preview control appearance that other states can override.
- **DesignerSerializationVisibility**: Content

**Example:**
```csharp
// Set common background color
previewControl.StateCommon.Back.Color1 = Color.White;
previewControl.StateCommon.Back.Color2 = Color.LightGray;

// Set common background style
previewControl.StateCommon.Back.Style = PaletteBackStyle.PanelClient;
```

**Available Properties:**
- `Color1`, `Color2`: Background colors
- `ColorStyle`: Color drawing style
- `Image`: Background image
- `ImageStyle`: Image drawing style
- `GradientStyle`: Gradient style
- And more...

**Notes:**
- Use this to set common appearance properties
- Other states inherit from this unless overridden
- Changes trigger a repaint
- Provides a base for all states

---

#### `StateDisabled` (PaletteBack)

Gets access to the disabled print preview control appearance.

- **Type**: `PaletteBack`
- **Category**: Visuals
- **Description**: Overrides for defining disabled print preview control appearance.
- **DesignerSerializationVisibility**: Content

**Example:**
```csharp
// Customize disabled state appearance
previewControl.StateDisabled.Back.Color1 = Color.Gray;
previewControl.StateDisabled.Back.Color2 = Color.DarkGray;
```

**When Applied:**
- Used when `Enabled` property is `false`
- Inherits from `StateCommon` unless overridden
- Provides visual feedback that control is disabled

**Notes:**
- Applied when `Enabled` is `false`
- Inherits from `StateCommon` unless overridden
- Changes trigger a repaint
- Typically uses muted colors to indicate disabled state

---

#### `StateNormal` (PaletteBack)

Gets access to the normal print preview control appearance.

- **Type**: `PaletteBack`
- **Category**: Visuals
- **Description**: Overrides for defining normal print preview control appearance.
- **DesignerSerializationVisibility**: Content

**Example:**
```csharp
// Customize normal state appearance
previewControl.StateNormal.Back.Color1 = Color.White;
previewControl.StateNormal.Back.Color2 = Color.LightBlue;
```

**When Applied:**
- Used when `Enabled` property is `true`
- Inherits from `StateCommon` unless overridden
- Default state for the control

**Notes:**
- Applied when `Enabled` is `true`
- Inherits from `StateCommon` unless overridden
- Changes trigger a repaint
- This is the default active state

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
baseControl.StartPage = 0;
```

**Use Cases:**
- Access to standard `PrintPreviewControl` features not exposed by wrapper
- Advanced scenarios requiring direct control access
- Compatibility with code expecting the standard control

**Notes:**
- Provides direct access to the underlying .NET control
- Use for advanced scenarios requiring standard control features
- Most functionality is exposed through wrapper properties
- The internal control is automatically managed

---

#### `TabStop` (bool)

Gets and sets if the control is in the tab chain.

- **Type**: `bool`
- **DesignerSerializationVisibility**: Visible

**Example:**
```csharp
previewControl.TabStop = true;  // Control can receive focus via Tab key
previewControl.TabStop = false; // Control skipped in tab navigation
```

**Notes:**
- Actually controls the tab stop of the internal `PrintPreviewControl`
- The wrapper control itself is not selectable
- Setting this affects keyboard navigation

---

#### Hidden Properties

The following properties are hidden from the property grid but exist for compatibility:

##### `BackColor` (Color) - Hidden

Gets or sets the background color for the control.

- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Background color comes from the palette system
- Setting this property has no effect
- Use `StateCommon.Back.Color1` or `StateNormal.Back.Color1` instead

##### `ForeColor` (Color) - Hidden

Gets or sets the foreground color for the control.

- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Foreground color comes from the palette system
- Setting this property has no effect

##### `BackgroundImage` (Image?) - Hidden

Gets or sets the background image displayed in the control.

- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Background images come from the palette system
- Setting this property has no effect
- Use `StateCommon.Back.Image` instead

##### `BackgroundImageLayout` (ImageLayout) - Hidden

Gets or sets the background image layout.

- **Browsable**: `false`
- **EditorBrowsable**: Never
- **DesignerSerializationVisibility**: Hidden

**Notes:**
- Hidden from property grid (use palette instead)
- Layout comes from the palette system
- Setting this property has no effect
- Use `StateCommon.Back.ImageStyle` instead

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
    UpdateNavigationButtons(control.StartPage);
};
```

**Use Cases:**
- Update UI elements that display current page number
- Enable/disable navigation buttons
- Update status bar information
- Track user navigation through document

**Notes:**
- Raised when `StartPage` property changes
- Useful for updating UI elements that display current page
- Event is forwarded from the internal `PrintPreviewControl`

---

#### Hidden Events

The following events are hidden but exist for compatibility:

##### `BackColorChanged` - Hidden

Occurs when the value of the BackColor property changes.

- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code
- Use `PaletteChanged` event from `VisualControlBase` instead

##### `BackgroundImageChanged` - Hidden

Occurs when the value of the BackgroundImage property changes.

- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

##### `BackgroundImageLayoutChanged` - Hidden

Occurs when the value of the BackgroundImageLayout property changes.

- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

##### `ForeColorChanged` - Hidden

Occurs when the value of the ForeColor property changes.

- **Browsable**: `false`
- **EditorBrowsable**: Never

**Notes:**
- Hidden event (use palette change events instead)
- Not typically used in application code

### Protected Methods

#### `OnEnabledChanged(EventArgs e)`

Raises the EnabledChanged event and updates the control's appearance.

**Parameters:**
- `e`: An EventArgs that contains the event data.

**Behavior:**
- Updates palette states based on enabled state
- Updates the internal control's enabled state
- Updates background color to match new state
- Triggers a repaint

**Notes:**
- Called automatically when `Enabled` property changes
- Switches between `StateNormal` and `StateDisabled`
- Updates the internal `PrintPreviewControl` enabled state

#### `OnPaletteChanged(EventArgs e)`

Raises the PaletteChanged event and updates the control's appearance.

**Parameters:**
- `e`: An EventArgs containing the event data.

**Behavior:**
- Updates the palette redirector
- Updates background color from new palette
- Calls base class implementation

**Notes:**
- Called automatically when palette changes
- Ensures control appearance matches current palette
- Updates internal control background color

#### `CreateControlsInstance()`

Creates a new instance of the control collection.

**Returns:**
- `ControlCollection`: A `KryptonReadOnlyControls` instance.

**Notes:**
- Returns a read-only controls collection
- Prevents external code from modifying child controls
- Only the internal `PrintPreviewControl` is allowed

#### `OnLayout(LayoutEventArgs levent)`

Handles layout events and positions the internal control.

**Parameters:**
- `levent`: A LayoutEventArgs that contains the event data.

**Behavior:**
- Calculates fill rectangle from view manager
- Positions internal `PrintPreviewControl` to fill available space
- Only performs layout if control is initialized

**Notes:**
- Called automatically during layout
- Positions the internal control within themed border
- Respects the themed border and padding

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
        
        // Handle page changes
        _previewControl.StartPageChanged += PreviewControl_StartPageChanged;
        
        // Add to form
        Controls.Add(_previewControl);
        
        // Set up toolbar for zoom and navigation
        SetupToolbar();
    }
    
    private void PreviewControl_StartPageChanged(object? sender, EventArgs e)
    {
        var control = (KryptonPrintPreviewControl)sender!;
        UpdatePageLabel(control.StartPage);
    }
    
    private void SetupToolbar()
    {
        // Add zoom buttons, page navigation, etc.
        // ... toolbar setup code
    }
    
    private void UpdatePageLabel(int startPage)
    {
        // Update UI with current page number
        pageLabel.Text = $"Page {startPage + 1}";
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

// Show single page (default)
previewControl.Columns = 1;
previewControl.Rows = 1;
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

// Disable auto-zoom to use manual zoom
previewControl.AutoZoom = false;
previewControl.Zoom = 1.0; // Now uses manual zoom
```

### Custom Appearance

```csharp
// Customize appearance through palette states
previewControl.PanelBackStyle = PaletteBackStyle.PanelAlternate;

// Customize common state
previewControl.StateCommon.Back.Color1 = Color.White;
previewControl.StateCommon.Back.Color2 = Color.LightGray;
previewControl.StateCommon.Back.GradientStyle = PaletteGradientStyle.Linear;

// Customize normal state
previewControl.StateNormal.Back.Color1 = Color.White;
previewControl.StateNormal.Back.Color2 = Color.LightBlue;

// Customize disabled state
previewControl.StateDisabled.Back.Color1 = Color.Gray;
previewControl.StateDisabled.Back.Color2 = Color.DarkGray;
```

### Page Navigation

```csharp
// Navigate to specific page
previewControl.StartPage = 0;  // First page
previewControl.StartPage = 5;   // Sixth page (0-based)

// Handle page changes
previewControl.StartPageChanged += (sender, e) =>
{
    var control = (KryptonPrintPreviewControl)sender!;
    statusLabel.Text = $"Page {control.StartPage + 1}";
    
    // Enable/disable navigation buttons
    btnFirstPage.Enabled = control.StartPage > 0;
    btnPreviousPage.Enabled = control.StartPage > 0;
    // ... more navigation logic
};
```

### Integration with KryptonPrintPreviewDialog

```csharp
// The dialog uses this control internally
var dialog = new KryptonPrintPreviewDialog
{
    Document = document
};

// Show dialog
dialog.ShowDialog();

// Access the control after showing dialog (if needed)
var control = dialog.PrintPreviewControl;
if (control != null)
{
    control.Zoom = 1.0;
    control.Columns = 2;
    control.Rows = 1;
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

// Update existing document
if (previewControl.Document is KryptonPrintDocument kryptonDoc)
{
    kryptonDoc.PaletteMode = PaletteMode.Office365Blue;
    // Preview may need to be refreshed
    previewControl.Invalidate();
}
```

### Responding to Palette Changes

```csharp
// Control automatically responds to palette changes
KryptonManager.GlobalPaletteMode = PaletteMode.Office365Blue;
// Control appearance updates automatically

// Or customize per control through palette states
previewControl.PanelBackStyle = PaletteBackStyle.PanelCustom1;
previewControl.StateNormal.Back.Color1 = Color.CustomColor;
```

### Advanced: Accessing Internal Control

```csharp
// Access the underlying PrintPreviewControl for advanced scenarios
var baseControl = previewControl.PrintPreviewControl;

// Use standard PrintPreviewControl features if needed
// (Most features are already exposed through wrapper properties)
```

## Integration with Krypton Toolkit

### Palette Integration

`KryptonPrintPreviewControl` fully integrates with the Krypton theming system:

- **Automatic Theming**: Uses the current global palette by default
- **Visual Consistency**: Matches the appearance of other Krypton controls
- **Dynamic Updates**: Responds to global palette changes automatically
- **State Management**: Supports normal and disabled states
- **Style Customization**: Configurable through palette styles

### Related Components

- **`KryptonPrintDocument`**: The document class used for printing with palette support
- **`KryptonPrintPreviewDialog`**: Dialog component that contains this control
- **`VisualPrintPreviewForm`**: Internal form class that uses this control
- **`PrintPreviewControl`**: The underlying .NET control that provides preview functionality
- **`KryptonPrintDialog`**: Standard print dialog that works with print documents

### Architecture

The control uses a composition pattern with Krypton's view manager system:

```
KryptonPrintPreviewControl (wrapper)
├── VisualControlBase (base class)
│   ├── Palette integration
│   ├── View manager
│   └── Theming infrastructure
├── InternalPrintPreviewControl (internal PrintPreviewControl)
│   └── Standard .NET preview functionality
└── ViewManager (Krypton rendering)
    └── ViewDrawDocker (themed border/background)
        └── ViewLayoutFill (content area)
            └── InternalPrintPreviewControl
```

**Key Components:**

1. **ViewManager**: Manages the rendering of themed elements
2. **ViewDrawDocker**: Provides themed border and background
3. **ViewLayoutFill**: Manages the fill area for the preview control
4. **InternalPrintPreviewControl**: The actual preview control
5. **Palette States**: Normal and disabled states for appearance

## Design-Time Support

### Toolbox Integration

- **Toolbox Item**: `true` - Can be added from toolbox
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
- Proper hit testing in design mode (internal control is transparent to designer)

## Thread Safety

This class is **not thread-safe**. All operations should be performed on the UI thread.

**Important:**
- All property access must be on the UI thread
- Event handlers are called on the UI thread
- Document printing operations should be on the UI thread
- Use `Invoke` or `BeginInvoke` if accessing from other threads

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

**Notes:**
- Disposes the internal `PrintPreviewControl`
- Unsubscribes from events
- Releases resources properly
- Follows standard .NET disposal pattern

## Performance Considerations

- **Rendering**: Anti-aliasing improves quality but may impact performance
- **Large Documents**: Complex documents with many pages may render slowly
- **Zoom Changes**: Changing zoom triggers a full repaint
- **Layout Changes**: Changing `Columns` or `Rows` triggers a full repaint
- **Memory**: Caches rendered pages internally
- **Palette Updates**: Palette changes trigger repaints but are optimized

**Optimization Tips:**
- Disable anti-aliasing for better performance on slower systems
- Use appropriate zoom levels (don't zoom too high unnecessarily)
- Consider page count when choosing columns/rows layout
- Cache document if previewing multiple times

## Best Practices

1. **Set Document First**: Set the `Document` property before configuring other properties
2. **Use Appropriate Zoom**: Start with `AutoZoom = true` or a reasonable zoom level
3. **Disable Anti-Aliasing if Needed**: Disable for better performance on slower systems
4. **Handle Page Changes**: Subscribe to `StartPageChanged` for navigation UI
5. **Use Palette States**: Customize appearance through palette states rather than direct color properties
6. **Dispose Properly**: Let the form dispose the control, or dispose manually if creating dynamically
7. **UI Thread Only**: Always access properties and methods from the UI thread
8. **Document Lifecycle**: Ensure the document is properly configured before setting it

## Limitations

1. **Standard Control Wrapper**: Wraps standard `PrintPreviewControl`; some limitations may apply
2. **Page Count**: Does not expose direct page count (must be determined from document)
3. **Printing**: Does not handle printing directly (use `KryptonPrintDialog` or document's `Print()` method)
4. **Custom Rendering**: Limited ability to customize the page rendering (handled by `PrintPreviewControl`)
5. **Focus Management**: The wrapper control cannot receive focus (only the internal control can)
6. **Child Controls**: Cannot add child controls (uses read-only controls collection)

## Internal Implementation Details

### InternalPrintPreviewControl

The control uses an internal class that extends `PrintPreviewControl`:

**Purpose**: Wraps the standard control with Krypton-specific behavior

**Key Features:**
- **Hit Testing**: Handles hit testing in design mode (returns `HT.TRANSPARENT`)
- **AutoZoom**: Initialized with `AutoZoom = false` (controlled by wrapper)
- **Reference**: Maintains reference to parent `KryptonPrintPreviewControl`

**Design Mode Behavior:**
- In design mode, hit testing returns transparent
- Allows designer to select the wrapper control instead
- Prevents designer from selecting the internal control directly

### View Manager System

Uses Krypton's view manager system for rendering:

**Components:**
- **ViewDrawDocker**: Provides themed border and background
- **ViewLayoutFill**: Manages the fill area for the preview control
- **ViewLayoutDocker**: Arranges inner elements
- **Palette States**: Applies appropriate palette state based on `Enabled` property

**Rendering Flow:**
1. View manager calculates layout
2. `ViewDrawDocker` draws themed border and background
3. `ViewLayoutFill` calculates fill rectangle
4. Internal control is positioned within fill rectangle
5. Internal control renders preview pages

### Palette State Management

The control manages appearance through palette states:

**States:**
- **Common**: Base appearance for all states
- **Normal**: Applied when `Enabled = true`
- **Disabled**: Applied when `Enabled = false`

**State Switching:**
- Automatically switches states when `Enabled` changes
- Updates internal control background color
- Triggers repaint when state changes

### Background Color Synchronization

The control synchronizes the internal control's background color with the palette:

**Method**: `UpdatePreviewControlBackColor()`

**Behavior:**
- Retrieves background color from current palette state
- Updates internal `PrintPreviewControl.BackColor`
- Called when palette changes or enabled state changes
- Ensures visual consistency