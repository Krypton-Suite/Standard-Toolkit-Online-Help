# KryptonPrintPreviewDialog

## Overview

`KryptonPrintPreviewDialog` is a component that provides a themed print preview dialog box for Windows Forms applications. It wraps a `KryptonPrintPreviewControl` within a `KryptonForm` to deliver a fully integrated print preview experience with Krypton theming support.

This class extends the standard .NET `PrintPreviewDialog` functionality by providing:
- Full Krypton palette theming integration
- Consistent visual appearance with other Krypton controls
- Anti-aliasing support for improved rendering quality
- Customizable window properties (icon, text, window state)

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Hierarchy

```
Component
└── KryptonPrintPreviewDialog
```

## Features

### Core Features

- **Themed Print Preview**: Displays print documents with full Krypton theming support
- **Modal Dialog**: Provides a modal dialog interface for print preview
- **Anti-Aliasing**: Configurable anti-aliasing for improved print preview rendering
- **Customizable Appearance**: Supports custom icons, window titles, and window states
- **Document Management**: Seamless integration with `KryptonPrintDocument`

### Integration Features

- **KryptonForm Integration**: Uses `VisualPrintPreviewForm` (internal `KryptonForm`) for consistent theming
- **Control Access**: Provides access to underlying `KryptonPrintPreviewControl` and `PrintPreviewControl` for advanced scenarios
- **Resource Management**: Proper disposal pattern implementation

## API Reference

### Constructors

#### `KryptonPrintPreviewDialog()`

Initializes a new instance of the `KryptonPrintPreviewDialog` class.

**Example:**
```csharp
var previewDialog = new KryptonPrintPreviewDialog();
```

### Properties

#### `Document` (KryptonPrintDocument?)

Gets or sets the `KryptonPrintDocument` to preview.

- **Type**: `KryptonPrintDocument?`
- **Default Value**: `null`
- **Category**: Behavior
- **Description**: The PrintDocument to preview.

**Example:**
```csharp
var document = new KryptonPrintDocument();
previewDialog.Document = document;
```

**Notes:**
- Must be set before calling `ShowDialog()`
- Setting this property updates the preview form if it's already created
- Throws `ArgumentNullException` if `null` when showing the dialog

---

#### `PrintPreviewControl` (KryptonPrintPreviewControl?)

Gets the `KryptonPrintPreviewControl` contained in this dialog.

- **Type**: `KryptonPrintPreviewControl?`
- **Browsable**: `false`
- **DesignerSerializationVisibility**: Hidden
- **Returns**: The themed print preview control, or `null` if the dialog hasn't been shown yet

**Example:**
```csharp
var control = previewDialog.PrintPreviewControl;
if (control != null)
{
    control.Zoom = 1.0;
    control.Columns = 2;
}
```

**Notes:**
- Returns `null` until `ShowDialog()` is called
- Use this property to access advanced preview control features

---

#### `PrintPreviewControlBase` (PrintPreviewControl?)

Gets the underlying standard `PrintPreviewControl` for compatibility.

- **Type**: `PrintPreviewControl?`
- **Browsable**: `false`
- **DesignerSerializationVisibility**: Hidden
- **Returns**: The base .NET `PrintPreviewControl`, or `null` if the dialog hasn't been shown yet

**Example:**
```csharp
var baseControl = previewDialog.PrintPreviewControlBase;
if (baseControl != null)
{
    // Access standard PrintPreviewControl members
    baseControl.StartPage = 0;
}
```

**Notes:**
- Provided for compatibility with code expecting the standard control
- Returns `null` until `ShowDialog()` is called

---

#### `UseAntiAlias` (bool)

Gets or sets a value indicating whether printing uses anti-aliasing.

- **Type**: `bool`
- **Default Value**: `true`
- **Category**: Behavior
- **Description**: Indicates whether printing uses anti-aliasing.

**Example:**
```csharp
previewDialog.UseAntiAlias = true; // Enable smooth rendering
```

**Notes:**
- Anti-aliasing improves visual quality but may impact performance
- Setting this property updates the preview form if it's already created

---

#### `Icon` (Icon?)

Gets or sets the icon for the form.

- **Type**: `Icon?`
- **Default Value**: `null`
- **Category**: Appearance
- **Description**: The icon for the form.

**Example:**
```csharp
previewDialog.Icon = SystemIcons.Application;
```

**Notes:**
- If `null`, the form uses the default icon
- Setting this property updates the preview form if it's already created

---

#### `Text` (string)

Gets or sets the text associated with this control (window title).

- **Type**: `string`
- **Default Value**: `"Print Preview"`
- **Category**: Appearance
- **Localizable**: `true`
- **Description**: The text associated with this control.

**Example:**
```csharp
previewDialog.Text = "Document Preview - My Application";
```

**Notes:**
- This becomes the window title bar text
- Setting this property updates the preview form if it's already created
- Supports localization

---

#### `WindowState` (FormWindowState)

Gets or sets the form's window state.

- **Type**: `FormWindowState`
- **Default Value**: `FormWindowState.Normal`
- **Category**: Window Style
- **Description**: The form's window state.

**Example:**
```csharp
previewDialog.WindowState = FormWindowState.Maximized;
```

**Valid Values:**
- `FormWindowState.Normal`: Normal window size
- `FormWindowState.Minimized`: Minimized window
- `FormWindowState.Maximized`: Maximized window

**Notes:**
- Applied when the dialog is shown
- Useful for restoring previous window state

### Methods

#### `ShowDialog()`

Runs a print preview dialog box.

**Returns:**
- `DialogResult`: One of the `DialogResult` values indicating how the dialog was closed.

**Example:**
```csharp
var result = previewDialog.ShowDialog();
if (result == DialogResult.OK)
{
    // User closed the dialog (though this dialog doesn't return OK)
}
```

**Notes:**
- Creates a new `VisualPrintPreviewForm` instance each time it's called
- Disposes any previously created preview form
- Throws `ArgumentNullException` if `Document` is `null`

---

#### `ShowDialog(IWin32Window? owner)`

Runs a print preview dialog box with the specified owner.

**Parameters:**
- `owner` (`IWin32Window?`): Any object that implements `IWin32Window` that represents the top-level window that will own the modal dialog box.

**Returns:**
- `DialogResult`: One of the `DialogResult` values indicating how the dialog was closed.

**Example:**
```csharp
var result = previewDialog.ShowDialog(this); // 'this' is a Form
```

**Notes:**
- The owner window is disabled while the dialog is shown
- Passing `null` is equivalent to calling `ShowDialog()` without parameters
- The dialog is modal, blocking execution until closed

---

#### `Dispose()`

Releases all resources used by the `KryptonPrintPreviewDialog`.

**Example:**
```csharp
previewDialog.Dispose();
```

**Notes:**
- Implements `IDisposable`
- Disposes the internal preview form
- Call this when finished with the component

---

#### `Dispose(bool isDisposing)` (protected)

Releases the unmanaged resources used by the component and optionally releases the managed resources.

**Parameters:**
- `isDisposing` (`bool`): `true` to release both managed and unmanaged resources; `false` to release only unmanaged resources.

**Notes:**
- Protected method following standard disposal pattern
- Called by public `Dispose()` and finalizer

## Usage Examples

### Basic Usage

```csharp
using Krypton.Toolkit;

// Create a print document
var document = new KryptonPrintDocument();
document.DocumentName = "My Document";

// Set up print event handlers
document.PrintPage += (sender, e) =>
{
    // Your printing logic here
    e.Graphics.DrawString("Hello, World!", 
        new Font("Arial", 12), 
        Brushes.Black, 
        new PointF(100, 100));
    e.HasMorePages = false;
};

// Create and show preview dialog
var previewDialog = new KryptonPrintPreviewDialog
{
    Document = document,
    Text = "Preview - My Document",
    UseAntiAlias = true
};

previewDialog.ShowDialog();
```

### Advanced Usage with Custom Settings

```csharp
// Create document with palette theming
var document = new KryptonPrintDocument
{
    PaletteMode = PaletteMode.Office365Blue,
    UsePaletteColors = true,
    TextStyle = PaletteContentStyle.LabelNormalPanel
};

// Configure preview dialog
var previewDialog = new KryptonPrintPreviewDialog
{
    Document = document,
    Text = "Document Preview",
    Icon = myApplicationIcon,
    WindowState = FormWindowState.Maximized,
    UseAntiAlias = true
};

// Show dialog with owner
var result = previewDialog.ShowDialog(this);

// Access control after showing (if needed)
if (previewDialog.PrintPreviewControl != null)
{
    var control = previewDialog.PrintPreviewControl;
    control.Zoom = 1.0;
    control.Columns = 2;
    control.Rows = 1;
}
```

### Integration with Print Workflow

```csharp
private void PrintPreviewButton_Click(object sender, EventArgs e)
{
    using var document = new KryptonPrintDocument
    {
        DocumentName = "Report",
        PaletteMode = KryptonManager.CurrentGlobalPaletteMode
    };

    document.PrintPage += Document_PrintPage;

    using var previewDialog = new KryptonPrintPreviewDialog
    {
        Document = document,
        Text = $"Preview - {document.DocumentName}",
        UseAntiAlias = true
    };

    previewDialog.ShowDialog(this);
}

private void Document_PrintPage(object sender, PrintPageEventArgs e)
{
    // Print page content using themed colors
    var doc = (KryptonPrintDocument)sender;
    
    var textColor = doc.GetTextColor();
    var backColor = doc.GetBackgroundColor();
    
    using (var brush = new SolidBrush(backColor))
    {
        e.Graphics.FillRectangle(brush, e.MarginBounds);
    }
    
    using (var brush = new SolidBrush(textColor))
    {
        e.Graphics.DrawString("Page Content", 
            doc.GetFont(), 
            brush, 
            e.MarginBounds);
    }
    
    e.HasMorePages = false;
}
```

## Integration with Krypton Toolkit

### Palette Integration

`KryptonPrintPreviewDialog` integrates seamlessly with the Krypton theming system:

- **Automatic Theming**: The dialog uses the current global palette by default
- **Visual Consistency**: Matches the appearance of other Krypton controls in your application
- **Dynamic Updates**: Responds to global palette changes

### Related Components

- **`KryptonPrintDocument`**: The document class used for printing with palette support
- **`KryptonPrintPreviewControl`**: The control embedded within the dialog
- **`KryptonPrintDialog`**: The print dialog used by the preview form's print button
- **`VisualPrintPreviewForm`**: The internal form class (not directly accessible)

## Design-Time Support

### Toolbox Integration

- **Toolbox Item**: `true`
- **Toolbox Bitmap**: `ToolboxBitmaps.KryptonPrintDialog.png`
- **Default Property**: `Document`
- **Designer Category**: Code

### Property Grid Support

All properties are visible in the Visual Studio property grid with appropriate categories:
- **Behavior**: `Document`, `UseAntiAlias`
- **Appearance**: `Icon`, `Text`
- **Window Style**: `WindowState`

## Thread Safety

This class is **not thread-safe**. All operations should be performed on the UI thread.

## Disposal Pattern

The class implements the standard disposal pattern:

```csharp
~KryptonPrintPreviewDialog() => Dispose(false);

public new void Dispose()
{
    Dispose(true);
    GC.SuppressFinalize(this);
}
```

**Best Practice**: Always dispose the component when finished, especially if creating multiple instances:

```csharp
using (var previewDialog = new KryptonPrintPreviewDialog())
{
    previewDialog.Document = document;
    previewDialog.ShowDialog();
}
```

## Error Handling

### Common Exceptions

**`ArgumentNullException`**
- **When**: `Document` is `null` when calling `ShowDialog()`
- **Message**: "Document must be set before showing the dialog."
- **Solution**: Ensure `Document` is set before showing the dialog

**Example:**
```csharp
try
{
    previewDialog.ShowDialog();
}
catch (ArgumentNullException ex)
{
    MessageBox.Show($"Error: {ex.Message}");
}
```

## Performance Considerations

- **Form Creation**: A new form is created each time `ShowDialog()` is called
- **Disposal**: Previous forms are disposed automatically
- **Anti-Aliasing**: Enabling anti-aliasing may impact rendering performance on slower systems
- **Memory**: The dialog holds references to the document and preview form

## Limitations

1. **Modal Only**: The dialog is always modal; there's no non-modal version
2. **Single Document**: Each dialog instance is tied to one document
3. **Form Recreation**: The preview form is recreated on each `ShowDialog()` call
4. **No Custom Toolbar**: The toolbar is fixed and cannot be customized externally

## See Also

- [`KryptonPrintDocument`](../Controls/KryptonPrintDocument.md) - Document class for themed printing
- [`KryptonPrintPreviewControl`](../Controls/KryptonPrintPreviewControl.md) - The preview control component
- [`KryptonPrintDialog`](KryptonPrintDialog.md) - The print dialog component