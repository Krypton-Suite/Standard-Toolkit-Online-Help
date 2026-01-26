# KryptonPrintDocument

## Overview

`KryptonPrintDocument` extends the standard .NET `PrintDocument` class to provide full integration with the Krypton Toolkit theming system. It enables printing with palette-based colors, fonts, and styles, ensuring that printed output matches the visual appearance of your Krypton-themed application.

This class provides:
- Palette-aware color retrieval for text, backgrounds, and borders
- Themed font support
- Helper methods for drawing themed content
- Automatic palette change handling
- Integration with the global Krypton palette system

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Hierarchy

```
PrintDocument
└── KryptonPrintDocument
```

## Features

### Core Features

- **Palette Integration**: Full integration with Krypton palette system
- **Themed Colors**: Retrieve text, background, and border colors from the current palette
- **Themed Fonts**: Access fonts defined in the palette
- **Helper Methods**: Convenient methods for drawing themed content
- **Global Palette Support**: Automatically responds to global palette changes
- **Custom Palette Support**: Can use custom palettes or specific palette modes

### Printing Features

- **Standard PrintDocument**: Inherits all standard `PrintDocument` functionality
- **PrintPage Event**: Supports standard `PrintPage` event handling
- **Document Properties**: Standard document name, printer settings, etc.
- **Themed Drawing**: Helper methods for drawing with palette colors

## API Reference

### Constructors

#### `KryptonPrintDocument()`

Initializes a new instance of the `KryptonPrintDocument` class.

**Example:**
```csharp
var document = new KryptonPrintDocument();
```

**Notes:**
- Automatically subscribes to global palette changes
- Sets palette to global default (`PaletteMode.Global`)
- Initializes with default text and background styles

---

### Properties

#### `PaletteMode` (PaletteMode)

Gets or sets the palette mode to be applied.

- **Type**: `PaletteMode`
- **Default Value**: `PaletteMode.Global`
- **Category**: Visuals
- **Description**: Palette applied to printing.

**Valid Values:**
- `PaletteMode.Global`: Uses the current global palette
- `PaletteMode.ProfessionalSystem`: Professional system palette
- `PaletteMode.ProfessionalOffice2003`: Office 2003 palette
- `PaletteMode.Office2007Blue`: Office 2007 Blue palette
- `PaletteMode.Office2007Silver`: Office 2007 Silver palette
- `PaletteMode.Office2007White`: Office 2007 White palette
- `PaletteMode.Office2007Black`: Office 2007 Black palette
- `PaletteMode.Office2010Blue`: Office 2010 Blue palette
- `PaletteMode.Office2010Silver`: Office 2010 Silver palette
- `PaletteMode.Office2010White`: Office 2010 White palette
- `PaletteMode.Office2010Black`: Office 2010 Black palette
- `PaletteMode.Office2013White`: Office 2013 White palette
- `PaletteMode.Office2013LightGray`: Office 2013 Light Gray palette
- `PaletteMode.Office2013DarkGray`: Office 2013 Dark Gray palette
- `PaletteMode.Microsoft365DarkGray`: Microsoft 365 Dark Gray palette
- `PaletteMode.Microsoft365Black`: Microsoft 365 Black palette
- `PaletteMode.Microsoft365Blue`: Microsoft 365 Blue palette
- `PaletteMode.Microsoft365White`: Microsoft 365 White palette
- `PaletteMode.SparkleBlue`: Sparkle Blue palette
- `PaletteMode.SparkleOrange`: Sparkle Orange palette
- `PaletteMode.SparklePurple`: Sparkle Purple palette
- `PaletteMode.Custom`: Uses a custom palette (set via `Palette` property)

**Example:**
```csharp
document.PaletteMode = PaletteMode.Office365Blue;
```

**Notes:**
- Setting to `PaletteMode.Custom` requires setting the `Palette` property
- Changing this property raises the `PaletteChanged` event
- Resets `Palette` to `null` when changed from `Custom`

---

#### `Palette` (PaletteBase?)

Gets and sets the custom palette implementation.

- **Type**: `PaletteBase?`
- **Default Value**: `null`
- **Category**: Visuals
- **Description**: Custom palette applied to printing.

**Example:**
```csharp
var customPalette = new PaletteCustom();
document.Palette = customPalette;
document.PaletteMode = PaletteMode.Custom;
```

**Notes:**
- Setting a custom palette automatically sets `PaletteMode` to `Custom`
- Setting to `null` reverts to `PaletteMode.Global`
- Changing this property raises the `PaletteChanged` event

---

#### `UsePaletteColors` (bool)

Gets or sets a value indicating whether to use palette colors when printing.

- **Type**: `bool`
- **Default Value**: `true`
- **Category**: Behavior
- **Description**: Indicates whether to use palette colors when printing.

**Example:**
```csharp
document.UsePaletteColors = true; // Use themed colors
document.UsePaletteColors = false; // Use default colors (Black/White)
```

**Notes:**
- When `false`, color methods return default colors (Black for text, White for background)
- Useful for printing documents that should always use standard colors
- Does not affect standard `PrintDocument` functionality

---

#### `TextStyle` (PaletteContentStyle)

Gets or sets the text style used for retrieving text colors from the palette.

- **Type**: `PaletteContentStyle`
- **Default Value**: `PaletteContentStyle.LabelNormalPanel`
- **Category**: Visuals
- **Description**: Text style used for retrieving text colors from the palette.

**Common Values:**
- `PaletteContentStyle.LabelNormalPanel`
- `PaletteContentStyle.LabelBoldPanel`
- `PaletteContentStyle.LabelItalicPanel`
- `PaletteContentStyle.LabelTitlePanel`
- `PaletteContentStyle.LabelSecondaryPanel`
- And many more...

**Example:**
```csharp
document.TextStyle = PaletteContentStyle.LabelBoldPanel;
```

**Notes:**
- Affects the color and font returned by `GetTextColor()` and `GetFont()`
- Choose a style that matches your document's text appearance needs

---

#### `BackgroundStyle` (PaletteBackStyle)

Gets or sets the background style used for retrieving background colors from the palette.

- **Type**: `PaletteBackStyle`
- **Default Value**: `PaletteBackStyle.PanelClient`
- **Category**: Visuals
- **Description**: Background style used for retrieving background colors from the palette.

**Common Values:**
- `PaletteBackStyle.PanelClient`
- `PaletteBackStyle.PanelAlternate`
- `PaletteBackStyle.PanelCustom1`
- `PaletteBackStyle.PanelCustom2`
- `PaletteBackStyle.PanelCustom3`
- And many more...

**Example:**
```csharp
document.BackgroundStyle = PaletteBackStyle.PanelAlternate;
```

**Notes:**
- Affects the color returned by `GetBackgroundColor()`
- Choose a style that matches your document's background appearance needs

### Events

#### `PaletteChanged`

Occurs when the palette changes.

- **Type**: `EventHandler?`
- **Category**: Property Changed
- **Description**: Occurs when the value of the Palette property is changed.

**Example:**
```csharp
document.PaletteChanged += (sender, e) =>
{
    // Palette has changed, update print preview if needed
    RefreshPreview();
};
```

**Notes:**
- Raised when `PaletteMode` or `Palette` property changes
- Also raised when global palette changes (if using `PaletteMode.Global`)

### Themed Printing Helper Methods

#### `GetTextColor(PaletteState state = PaletteState.Normal)`

Gets the text color from the current palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Returns:**
- `Color`: The text color from the palette, or `Color.Black` if palette is not available or `UsePaletteColors` is `false`.

**Example:**
```csharp
var textColor = document.GetTextColor();
var disabledColor = document.GetTextColor(PaletteState.Disabled);
```

**Notes:**
- Returns `Color.Black` if `UsePaletteColors` is `false`
- Returns `Color.Black` if palette is `null`
- Uses `TextStyle` property to determine which color to retrieve

---

#### `GetBackgroundColor(PaletteState state = PaletteState.Normal)`

Gets the background color from the current palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Returns:**
- `Color`: The background color from the palette, or `Color.White` if palette is not available or `UsePaletteColors` is `false`.

**Example:**
```csharp
var backColor = document.GetBackgroundColor();
var pressedColor = document.GetBackgroundColor(PaletteState.Pressed);
```

**Notes:**
- Returns `Color.White` if `UsePaletteColors` is `false`
- Returns `Color.White` if palette is `null`
- Uses `BackgroundStyle` property to determine which color to retrieve

---

#### `GetBorderColor(PaletteState state = PaletteState.Normal)`

Gets the border color from the current palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Returns:**
- `Color`: The border color from the palette, or `Color.Black` if palette is not available or `UsePaletteColors` is `false`.

**Example:**
```csharp
var borderColor = document.GetBorderColor();
```

**Notes:**
- Returns `Color.Black` if `UsePaletteColors` is `false`
- Returns `Color.Black` if palette is `null`
- Uses `PaletteBorderStyle.ControlClient` for border style

---

#### `GetFont(PaletteState state = PaletteState.Normal)`

Gets the font from the current palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Returns:**
- `Font`: The font from the palette, or a default font (`Arial`, 12pt) if palette is not available or `UsePaletteColors` is `false`.

**Example:**
```csharp
var font = document.GetFont();
var boldFont = new Font(document.GetFont(), FontStyle.Bold);
```

**Notes:**
- Returns `new Font("Arial", 12)` if `UsePaletteColors` is `false`
- Returns `new Font("Arial", 12)` if palette is `null`
- Uses `TextStyle` property to determine which font to retrieve
- Caller is responsible for disposing the returned font if needed

---

#### `DrawThemedText(Graphics graphics, string text, Font? font, Rectangle bounds, StringFormat? format = null, PaletteState state = PaletteState.Normal)`

Draws text using palette colors.

**Parameters:**
- `graphics` (`Graphics`): The Graphics object to draw on
- `text` (`string`): The text to draw
- `font` (`Font?`): The font to use (if `null`, uses palette font)
- `bounds` (`Rectangle`): The bounding rectangle for the text
- `format` (`StringFormat?`): The StringFormat to use. Default: `StringFormat.GenericDefault`
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Example:**
```csharp
document.DrawThemedText(e.Graphics, "Hello, World!", null, 
    new Rectangle(100, 100, 200, 50));
```

**Notes:**
- Does nothing if `graphics` is `null` or `text` is null/empty
- Uses palette font if `font` parameter is `null`
- Creates and disposes a `SolidBrush` internally

---

#### `DrawThemedRectangle(Graphics graphics, Rectangle bounds, PaletteState state = PaletteState.Normal)`

Draws a rectangle with themed background and border.

**Parameters:**
- `graphics` (`Graphics`): The Graphics object to draw on
- `bounds` (`Rectangle`): The bounding rectangle
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Example:**
```csharp
document.DrawThemedRectangle(e.Graphics, 
    new Rectangle(50, 50, 500, 700));
```

**Notes:**
- Does nothing if `graphics` is `null`
- Fills the rectangle with background color, then draws border
- Creates and disposes brushes/pens internally

---

#### `DrawThemedLine(Graphics graphics, int x1, int y1, int x2, int y2, PaletteState state = PaletteState.Normal)`

Draws a line using the border color from the palette.

**Parameters:**
- `graphics` (`Graphics`): The Graphics object to draw on
- `x1` (`int`): The x-coordinate of the first point
- `y1` (`int`): The y-coordinate of the first point
- `x2` (`int`): The x-coordinate of the second point
- `y2` (`int`): The y-coordinate of the second point
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Example:**
```csharp
document.DrawThemedLine(e.Graphics, 100, 200, 500, 200);
```

**Notes:**
- Does nothing if `graphics` is `null`
- Creates and disposes a `Pen` internally

---

#### `GetTextBrush(PaletteState state = PaletteState.Normal)`

Gets a `SolidBrush` with the text color from the palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Returns:**
- `Brush`: A `SolidBrush` with the palette text color.

**Example:**
```csharp
using (var brush = document.GetTextBrush())
{
    e.Graphics.DrawString("Text", font, brush, point);
}
```

**Notes:**
- **Important**: Caller is responsible for disposing the returned brush
- Use within a `using` statement for proper resource management

---

#### `GetBackgroundBrush(PaletteState state = PaletteState.Normal)`

Gets a `SolidBrush` with the background color from the palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`

**Returns:**
- `Brush`: A `SolidBrush` with the palette background color.

**Example:**
```csharp
using (var brush = document.GetBackgroundBrush())
{
    e.Graphics.FillRectangle(brush, bounds);
}
```

**Notes:**
- **Important**: Caller is responsible for disposing the returned brush
- Use within a `using` statement for proper resource management

---

#### `GetBorderPen(PaletteState state = PaletteState.Normal, float width = 1.0f)`

Gets a `Pen` with the border color from the palette.

**Parameters:**
- `state` (`PaletteState`): The palette state to use. Default: `PaletteState.Normal`
- `width` (`float`): The pen width. Default: `1.0f`

**Returns:**
- `Pen`: A `Pen` with the palette border color.

**Example:**
```csharp
using (var pen = document.GetBorderPen(state: PaletteState.Normal, width: 2.0f))
{
    e.Graphics.DrawRectangle(pen, bounds);
}
```

**Notes:**
- **Important**: Caller is responsible for disposing the returned pen
- Use within a `using` statement for proper resource management

## Usage Examples

### Basic Themed Printing

```csharp
using Krypton.Toolkit;
using System.Drawing;
using System.Drawing.Printing;

var document = new KryptonPrintDocument
{
    DocumentName = "Themed Report",
    PaletteMode = PaletteMode.Office365Blue
};

document.PrintPage += (sender, e) =>
{
    var doc = (KryptonPrintDocument)sender;
    
    // Get themed colors
    var textColor = doc.GetTextColor();
    var backColor = doc.GetBackgroundColor();
    var font = doc.GetFont();
    
    // Fill background
    using (var brush = new SolidBrush(backColor))
    {
        e.Graphics.FillRectangle(brush, e.MarginBounds);
    }
    
    // Draw text
    using (var brush = new SolidBrush(textColor))
    {
        e.Graphics.DrawString("Themed Document", font, brush, 
            e.MarginBounds.X, e.MarginBounds.Y);
    }
    
    e.HasMorePages = false;
};

document.Print();
```

### Using Helper Methods

```csharp
document.PrintPage += (sender, e) =>
{
    var doc = (KryptonPrintDocument)sender;
    
    // Draw themed rectangle (background + border)
    doc.DrawThemedRectangle(e.Graphics, e.MarginBounds);
    
    // Draw themed text
    var textBounds = new Rectangle(
        e.MarginBounds.X + 50,
        e.MarginBounds.Y + 50,
        e.MarginBounds.Width - 100,
        100);
    
    doc.DrawThemedText(e.Graphics, "Document Title", 
        new Font("Arial", 18, FontStyle.Bold), 
        textBounds);
    
    // Draw themed line separator
    doc.DrawThemedLine(e.Graphics,
        e.MarginBounds.X,
        e.MarginBounds.Y + 150,
        e.MarginBounds.Right,
        e.MarginBounds.Y + 150);
    
    e.HasMorePages = false;
};
```

### Custom Palette Usage

```csharp
// Create custom palette
var customPalette = new PaletteCustom();

// Configure document with custom palette
var document = new KryptonPrintDocument
{
    Palette = customPalette,
    PaletteMode = PaletteMode.Custom,
    TextStyle = PaletteContentStyle.LabelBoldPanel,
    BackgroundStyle = PaletteBackStyle.PanelAlternate
};

document.PrintPage += (sender, e) =>
{
    // Use themed colors from custom palette
    var doc = (KryptonPrintDocument)sender;
    // ... printing logic
};
```

### Responding to Palette Changes

```csharp
var document = new KryptonPrintDocument();

document.PaletteChanged += (sender, e) =>
{
    // Update preview or refresh document when palette changes
    if (previewControl != null)
    {
        previewControl.Invalidate();
    }
};

// Later, when user changes theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2013DarkGray;
// PaletteChanged event will fire automatically
```

### Multi-Page Document with Themed Colors

```csharp
int currentPage = 0;
const int totalPages = 5;

var document = new KryptonPrintDocument
{
    DocumentName = "Multi-Page Report",
    PaletteMode = PaletteMode.Microsoft365Blue
};

document.PrintPage += (sender, e) =>
{
    var doc = (KryptonPrintDocument)sender;
    
    // Fill page background
    using (var brush = doc.GetBackgroundBrush())
    {
        e.Graphics.FillRectangle(brush, e.MarginBounds);
    }
    
    // Draw page header
    using (var brush = doc.GetTextBrush())
    using (var font = new Font(doc.GetFont(), FontStyle.Bold))
    {
        e.Graphics.DrawString($"Page {currentPage + 1} of {totalPages}", 
            font, brush, e.MarginBounds.X, e.MarginBounds.Y);
    }
    
    // Draw page content
    var contentY = e.MarginBounds.Y + 50;
    using (var brush = doc.GetTextBrush())
    {
        e.Graphics.DrawString($"This is page {currentPage + 1}", 
            doc.GetFont(), brush, 
            e.MarginBounds.X, contentY);
    }
    
    currentPage++;
    e.HasMorePages = currentPage < totalPages;
};

document.Print();
```

### Disabling Palette Colors

```csharp
// Print with standard colors regardless of palette
var document = new KryptonPrintDocument
{
    UsePaletteColors = false  // Always use Black/White
};

document.PrintPage += (sender, e) =>
{
    // GetTextColor() will return Color.Black
    // GetBackgroundColor() will return Color.White
    var textColor = document.GetTextColor(); // Always Black
    // ... printing logic
};
```

## Integration with Krypton Toolkit

### Global Palette Integration

`KryptonPrintDocument` automatically integrates with the global Krypton palette:

- **Default Behavior**: Uses `PaletteMode.Global` by default
- **Automatic Updates**: Subscribes to `KryptonManager.GlobalPaletteChanged` event
- **Dynamic Theming**: Changes when global palette changes (if using `PaletteMode.Global`)

### Related Components

- **`KryptonPrintPreviewDialog`**: Uses `KryptonPrintDocument` for preview
- **`KryptonPrintPreviewControl`**: Displays `KryptonPrintDocument` in preview
- **`KryptonPrintDialog`**: Standard print dialog that works with `KryptonPrintDocument`

## Design-Time Support

### Toolbox Integration

- **Toolbox Item**: `true`
- **Toolbox Bitmap**: `ToolboxBitmaps.KryptonPrintDocument.bmp`
- **Default Property**: `DocumentName`
- **Designer Category**: Code

### Property Grid Support

All properties are visible in the Visual Studio property grid with appropriate categories:
- **Behavior**: `UsePaletteColors`
- **Visuals**: `PaletteMode`, `Palette`, `TextStyle`, `BackgroundStyle`

## Thread Safety

This class is **not thread-safe**. All operations should be performed on the UI thread, especially when handling the `PrintPage` event.

## Disposal Pattern

The class properly unsubscribes from global palette changes:

```csharp
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        KryptonManager.GlobalPaletteChanged -= OnGlobalPaletteChanged;
    }
    base.Dispose(disposing);
}
```

**Best Practice**: Always dispose the document when finished:

```csharp
using (var document = new KryptonPrintDocument())
{
    // Use document
    document.Print();
}
```

## Performance Considerations

- **Color Retrieval**: Palette color retrieval is fast but involves method calls
- **Font Creation**: `GetFont()` creates a new `Font` instance each time (consider caching)
- **Brush/Pen Creation**: Helper methods create new brushes/pens; dispose them properly
- **Global Palette Subscription**: Minimal overhead; unsubscribes on disposal

## Best Practices

1. **Dispose Resources**: Always dispose brushes, pens, and fonts returned by helper methods
2. **Cache Fonts**: If using the same font multiple times, cache the result of `GetFont()`
3. **Use Helper Methods**: Prefer `DrawThemedText()` and `DrawThemedRectangle()` for simpler code
4. **Handle Palette Changes**: Subscribe to `PaletteChanged` if you need to refresh previews
5. **Choose Appropriate Styles**: Select `TextStyle` and `BackgroundStyle` that match your document design

## Limitations

1. **Font Disposal**: `GetFont()` returns a new font each time; caller must dispose if needed
2. **Brush/Pen Disposal**: `GetTextBrush()`, `GetBackgroundBrush()`, and `GetBorderPen()` require disposal
3. **State Support**: Some palette states may not be fully supported for printing scenarios
4. **Color Fallbacks**: Always falls back to default colors if palette is unavailable

## See Also

- [`KryptonPrintPreviewDialog`](../Components/KryptonPrintPreviewDialog.md) - Preview dialog component
- [`KryptonPrintPreviewControl`](KryptonPrintPreviewControl.md) - Preview control component
- [`KryptonPrintDialog`](../Components/KryptonPrintDialog.md) - Print dialog component