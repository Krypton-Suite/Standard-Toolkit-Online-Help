# KryptonTaskDialog Technical Architecture

## Table of Contents
1. [Overview](#overview)
2. [Class Hierarchy](#class-hierarchy)
3. [Design Patterns](#design-patterns)
4. [Component Details](#component-details)
5. [Layout System](#layout-system)
6. [Event Flow](#event-flow)
7. [Theme Integration](#theme-integration)
8. [Memory Management](#memory-management)
9. [Extending the Component](#extending-the-component)

---

## Overview

`KryptonTaskDialog` implements a composable dialog system using a vertical layout of independent elements. The architecture emphasizes:

- **Separation of Concerns**: Each element is self-contained
- **Late Binding**: Layout is calculated just before display
- **Theme Integration**: Automatic synchronization with Krypton themes
- **Form Reusability**: Single instance can be shown multiple times
- **Lazy Layout**: Elements only calculate size when visible or requested

### Key Architectural Decisions

1. **Element-Based Composition**: Rather than a monolithic dialog, functionality is split into independent, reusable elements
2. **TableLayoutPanel Stacking**: Elements are stacked vertically in a `TableLayoutPanel` with `AutoSize` rows
3. **Dirty Layout Tracking**: Elements track when layout is "dirty" and defer calculations until needed
4. **Form Hiding vs. Disposal**: Forms are hidden rather than disposed to enable reuse

---

## Class Hierarchy

### Core Classes

```
KryptonTaskDialog
├── Implements: IDisposable
├── Contains: KryptonTaskDialogKryptonForm
├── Contains: TableLayoutPanel (main layout)
├── Contains: List<KryptonTaskDialogElementBase> (all elements)
├── Contains: KryptonTaskDialogDefaults (configuration)
└── Contains: KryptonTaskDialogFormProperties (form access)

KryptonTaskDialogKryptonForm : KryptonForm
├── Override: ProcessCmdKey (Alt+F4 handling)
└── Override: OnFormClosing (hide instead of close)

KryptonTaskDialogFormProperties
├── Contains: FormInstance (form properties wrapper)
└── Contains: GlobalInstance (global element settings)

KryptonTaskDialogElementBase (abstract)
├── Implements: IKryptonTaskDialogElementBase
├── Implements: IKryptonTaskDialogElementEventSizeChanged
├── Implements: IDisposable
├── Contains: KryptonTaskDialogKryptonPanel
├── Virtual: PerformLayout()
├── Virtual: OnSizeChanged()
└── Virtual: OnPalettePaint()
```

### Element Hierarchy

All elements derive from `KryptonTaskDialogElementBase`:

```
KryptonTaskDialogElementBase (abstract)
│
├── KryptonTaskDialogElementHeading
│   ├── Implements: IKryptonTaskDialogElementIconType
│   ├── Implements: IKryptonTaskDialogElementTextAlignmentHorizontal
│   ├── Implements: IKryptonTaskDialogElementForeColor
│   └── Implements: IKryptonTaskDialogElementText
│
├── KryptonTaskDialogElementContent
│   ├── Implements: IKryptonTaskDialogElementContent
│   ├── Implements: IKryptonTaskDialogElementForeColor
│   └── Contains: ContentImageStorage (nested class)
│
├── KryptonTaskDialogElementFooterBar
│   ├── Implements: IKryptonTaskDialogElementForeColor
│   ├── Implements: IKryptonTaskDialogElementRoundedCorners
│   ├── Contains: CommonButtonProperties (nested class)
│   └── Contains: FooterProperties (nested class)
│
├── KryptonTaskDialogElementCommandLinkButtons
│   ├── Implements: IKryptonTaskDialogElementRoundedCorners
│   ├── Implements: IKryptonTaskDialogElementFlowDirection
│   └── Contains: ButtonsCollectionEditor (nested class)
│
├── KryptonTaskDialogElementSingleLineControlBase (abstract)
│   ├── Contains: TableLayoutPanel (for simple controls)
│   │
│   ├── KryptonTaskDialogElementCheckBox
│   │   └── Implements: IKryptonTaskDialogElementText
│   │
│   ├── KryptonTaskDialogElementComboBox
│   │   ├── Implements: IKryptonTaskDialogElementDescription
│   │   └── Implements: IKryptonTaskDialogElementRoundedCorners
│   │
│   ├── KryptonTaskDialogElementHyperLink
│   │   ├── Implements: IKryptonTaskDialogElementDescription
│   │   └── Implements: IKryptonTaskDialogElementUrl
│   │
│   ├── KryptonTaskDialogElementProgresBar
│   │   ├── Implements: IKryptonTaskDialogElementDescription
│   │   └── Implements: IKryptonTaskDialogElementRoundedCorners
│   │
│   └── KryptonTaskDialogElementFreeWheeler1
│       └── Implements: IKryptonTaskDialogElementHeight
│
├── KryptonTaskDialogElementRichTextBox
│   ├── Implements: IKryptonTaskDialogElementText
│   ├── Implements: IKryptonTaskDialogElementHeight
│   └── Implements: IKryptonTaskDialogElementRoundedCorners
│
└── KryptonTaskDialogElementFreeWheeler2
    └── Implements: IKryptonTaskDialogElementHeight
```

---

## Design Patterns

### 1. Composite Pattern

Elements are composed into a tree structure where the dialog is the composite and elements are leaves.

```csharp
// Composite
KryptonTaskDialog
    // Leaves
    - Heading
    - Content
    - FooterBar
    // etc.
```

### 2. Template Method Pattern

`KryptonTaskDialogElementBase` provides template methods that derived classes override:

```csharp
public abstract class KryptonTaskDialogElementBase
{
    // Template method
    internal virtual void PerformLayout()
    {
        // Base implementation
    }
    
    // Template method
    protected virtual void OnSizeChanged(bool performLayout = false)
    {
        // Base implementation with notification
        SizeChanged?.Invoke();
    }
}

// Derived class overrides
public class KryptonTaskDialogElementContent : KryptonTaskDialogElementBase
{
    internal override void PerformLayout()
    {
        base.PerformLayout();
        OnSizeChanged(true);
    }
}
```

### 3. Observer Pattern

Elements notify the dialog of changes through events:

```csharp
// In KryptonTaskDialogElementBase
public event Action VisibleChanged;
public event Action SizeChanged;

// In KryptonTaskDialog constructor
element.VisibleChanged += UpdateFormSizing;
if (element is IKryptonTaskDialogElementEventSizeChanged e)
{
    e.SizeChanged += UpdateFormSizing;
}
```

### 4. Lazy Initialization / Dirty Flag Pattern

Layout calculations are deferred until needed:

```csharp
// Mark dirty
LayoutDirty = true;

// Calculate only when needed
protected override void OnSizeChanged(bool performLayout = false)
{
    if (LayoutDirty && (Visible || performLayout))
    {
        // Perform expensive calculations
        LayoutDirty = false;
    }
}
```

### 5. Interface Segregation

Elements implement only the interfaces they need:

```csharp
// Element with text
interface IKryptonTaskDialogElementText
{
    string Text { get; set; }
}

// Element with icon
interface IKryptonTaskDialogElementIconType
{
    KryptonTaskDialogIconType IconType { get; set; }
}

// Element implements what it needs
public class KryptonTaskDialogElementHeading : 
    KryptonTaskDialogElementBase,
    IKryptonTaskDialogElementIconType,
    IKryptonTaskDialogElementText
{
    // Implementation
}
```

### 6. Builder Pattern

Dialog is constructed by setting properties rather than passing constructor parameters:

```csharp
// Builder pattern usage
var dialog = new KryptonTaskDialog();
dialog.Dialog.Form.Text = "Title";
dialog.Heading.Text = "Message";
dialog.Heading.IconType = KryptonTaskDialogIconType.ShieldInformation;
dialog.ShowDialog();
```

---

## Component Details

### KryptonTaskDialog

**Responsibilities:**
- Orchestrate all elements
- Manage form lifecycle
- Calculate total dialog height
- Handle form positioning
- Coordinate theme changes

**Key Fields:**
```csharp
private KryptonTaskDialogKryptonForm _form;
private TableLayoutPanel _tableLayoutPanel;
private List<KryptonTaskDialogElementBase> _elements;
private Rectangle _clientRectangle;
private KryptonTaskDialogDefaults _taskDialogDefaults;
private KryptonPanel _fillerPanel;  // Border compensation
```

**Key Methods:**
```csharp
private void SetupForm()
private void SetupTableLayoutPanel()
private void SetupElements()
private void AddElement(KryptonTaskDialogElementBase element)
private int GetVisibleElementsHeight()
private void UpdateFormSizing()
private void UpdateFormPosition(IWin32Window? owner)
```

### KryptonTaskDialogElementBase

**Responsibilities:**
- Manage element visibility
- Provide background color control
- Track layout state
- Integrate with themes
- Notify of changes

**Key Fields:**
```csharp
private KryptonTaskDialogKryptonPanel _panel;  // Host panel
private bool _panelVisible;                     // Visibility state
private KryptonTaskDialogDefaults _taskDialogDefaults;
internal PaletteBase Palette;                   // Current theme
internal bool LayoutDirty;                      // Needs layout
```

**Key Virtual Methods:**
```csharp
internal virtual void PerformLayout()
    // Called before dialog is shown to ensure layout is current
    
protected virtual void OnSizeChanged(bool performLayout = false)
    // Called when element size changes
    // performLayout forces calculation even when not visible
    
protected virtual void OnPalettePaint(object? sender, PaletteLayoutEventArgs e)
    // Called when theme repaints
    
protected virtual void OnGlobalPaletteChanged(object? sender, EventArgs e)
    // Called when theme changes
```

### KryptonTaskDialogKryptonPanel

**Responsibilities:**
- Host element controls
- Draw separator lines
- React to theme changes
- Provide themed background

**Key Features:**
- Derives from `KryptonPanel`
- Overrides `OnPaint` to draw separator
- Calculates separator colors based on background
- Subscribes to theme changes

**Separator Algorithm:**
```csharp
private (Color, Color) GetSeparatorColors()
{
    // Get background color
    Color tmp = StateCommon.Color1 != Color.Empty
        ? StateCommon.Color1
        : _palette.GetBackColor1(PaletteBackStyle.PanelClient, PaletteState.Normal);
    
    // Calculate darker/lighter colors based on luminosity
    if (tmp.R > 205 && tmp.G > 205 && tmp.B > 205)
    {
        // Light background - darken
        color1 = Color.FromArgb(tmp.R - 75, tmp.G - 75, tmp.B - 75);
        color2 = Color.White;
    }
    else if (tmp.R < 50 && tmp.G < 50 && tmp.B < 50)
    {
        // Dark background - lighten
        color2 = ControlPaint.Light(tmp);
        color1 = ControlPaint.Light(Color.LightSlateGray);
    }
    // ... more cases
    
    return (color1, color2);
}
```

### KryptonTaskDialogKryptonForm

**Responsibilities:**
- Provide specialized form behavior
- Handle Alt+F4 interception
- Hide instead of close for reusability

**Key Overrides:**
```csharp
protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
{
    // Intercept Alt+F4 when IgnoreAltF4 is true
    return IgnoreAltF4 && keyData == KEYS_ALT_F4;
}

protected override void OnFormClosing(FormClosingEventArgs e)
{
    // Hide instead of close when user closes
    if (Visible && e.CloseReason == CloseReason.UserClosing)
    {
        e.Cancel = true;
        Hide();
    }
}
```

### KryptonTaskDialogIconController

**Responsibilities:**
- Load icons from resources
- Resize icons to requested size
- Cache resized icons
- Manage icon disposal

**Cache Structure:**
```csharp
// Key: IconType + Size
public class ImageItem : IEquatable<ImageItem>
{
    public KryptonTaskDialogIconType IconType { get; }
    public int Size { get; }
}

// Cache: Dictionary<ImageItem, Image>
private Dictionary<ImageItem, Image> _imageCache;
```

**Icon Loading:**
```csharp
public Image GetImage(KryptonTaskDialogIconType icontype, int size)
{
    ImageItem imageItem = new(icontype, size);
    
    // Check cache
    if (_imageCache.TryGetValue(imageItem, out Image? image))
        return image;
    
    // Load from resources
    Image newImage = GetImageInternal(in imageItem);
    
    // Resize if needed
    if (newImage.Size.Width != size || newImage.Size.Height != size)
    {
        newImage = new Bitmap(newImage, size, size);
        _imageCache.Add(imageItem, newImage);
    }
    
    return newImage;
}
```

---

## Layout System

### Vertical Stacking

Elements are stacked vertically using `TableLayoutPanel`:

```
┌────────────────────────────────┐
│ Filler Panel (border fix)      │ ← Top border compensation
├────────────────────────────────┤
│ Heading Element                │ ← AutoSize row
├────────────────────────────────┤
│ Content Element                │ ← AutoSize row
├────────────────────────────────┤
│ Expander Element               │ ← AutoSize row
├────────────────────────────────┤
│ RichTextBox Element            │ ← AutoSize row
├────────────────────────────────┤
│ ... more elements ...          │
├────────────────────────────────┤
│ Footer Bar Element             │ ← AutoSize row
├────────────────────────────────┤
│ Filler Panel (border fix)      │ ← Bottom border compensation
└────────────────────────────────┘
```

### Layout Configuration

```csharp
_tableLayoutPanel.AutoSize = true;
_tableLayoutPanel.AutoSizeMode = AutoSizeMode.GrowAndShrink;
_tableLayoutPanel.Dock = DockStyle.Top;

// Single column, 100% width
_tableLayoutPanel.ColumnCount = 1;
_tableLayoutPanel.ColumnStyles.Add(new ColumnStyle(SizeType.Percent, 100F));

// Rows added per element
_tableLayoutPanel.RowCount += 1;
_tableLayoutPanel.RowStyles.Add(new RowStyle(SizeType.AutoSize));
```

### Element Layout

Each element contains a panel that hosts its controls:

```
Element
└── KryptonTaskDialogKryptonPanel (Panel property)
    ├── Padding: PanelPadding1 (10, 10, 10, 10)
    └── Controls: (element-specific)
```

### Height Calculation

Dialog height is sum of visible element heights:

```csharp
private int GetVisibleElementsHeight()
{
    return _elements.Sum(element => 
    {
        // Force update if needed
        if (element.LayoutDirty)
        {
            element.PerformLayout();
        }
        
        // Height automatically returns zero when not visible
        return element.Height;
    });
}

private void UpdateFormSizing()
{
    _form.ClientSize = new Size(
        _taskDialogDefaults.ClientWidth, 
        GetVisibleElementsHeight() + _fillerPanelOffset
    );
}
```

### Border Compensation

Windows forms have border rendering issues where internal panels can slide under borders. This is compensated with filler panels:

```csharp
// Top filler (6 pixels)
_fillerPanel = new KryptonPanel()
{
    Height = _fillerPanelOffset,
    Dock = DockStyle.Top
};

// Added to dialog height
_form.ClientSize = new Size(
    width, 
    height + _fillerPanelOffset  // Compensate
);
```

---

## Event Flow

### Dialog Creation

```
1. new KryptonTaskDialog()
   ├── Create KryptonTaskDialogDefaults
   ├── Create KryptonTaskDialogKryptonForm
   ├── Create all elements (in display order)
   │   └── Each element:
   │       ├── Create KryptonTaskDialogKryptonPanel
   │       ├── Create internal controls
   │       ├── Subscribe to palette changes
   │       └── Mark LayoutDirty = true
   ├── Add elements to list
   └── SetupForm()
       ├── SetupTableLayoutPanel()
       └── SetupElements()
           └── For each element:
               ├── Add to TableLayoutPanel
               ├── Wire VisibleChanged event
               └── Wire SizeChanged event (if applicable)
```

### Showing Dialog

```
1. ShowDialog() or Show()
   ├── UpdateFormSizing()
   │   └── GetVisibleElementsHeight()
   │       └── For each element:
   │           ├── if (LayoutDirty) PerformLayout()
   │           └── return Height
   ├── UpdateFormPosition(owner)
   │   └── Calculate position based on StartPosition
   └── _form.ShowDialog() or _form.Show()
```

### Element Visibility Change

```
1. element.Visible = true
   ├── _panelVisible = true
   ├── _panel.Visible = true
   └── OnVisibleChanged()
       └── VisibleChanged?.Invoke()
           └── KryptonTaskDialog.UpdateFormSizing()
               └── Recalculate form height
```

### Element Size Change

```
1. element.Text = "New text"
   ├── Update internal control
   ├── LayoutDirty = true
   └── OnSizeChanged()
       └── if (LayoutDirty && Visible)
           ├── Calculate new height
           ├── Panel.Height = newHeight
           ├── SizeChanged?.Invoke()
           │   └── KryptonTaskDialog.UpdateFormSizing()
           └── LayoutDirty = false
```

### Theme Change

```
1. KryptonManager.CurrentGlobalPalette changed
   └── KryptonManager.GlobalPaletteChanged event fires
       └── For each element:
           ├── OnGlobalPaletteChanged()
           │   ├── Detach from old palette
           │   ├── Update Palette reference
           │   └── Attach to new palette
           └── Palette.PalettePaint event fires
               └── OnPalettePaint()
                   ├── LayoutDirty = true
                   └── if (Visible) OnSizeChanged()
```

---

## Theme Integration

### Palette Connection

Each element maintains a connection to the active palette:

```csharp
public abstract class KryptonTaskDialogElementBase
{
    internal PaletteBase Palette { get; private set; }
    
    protected KryptonTaskDialogElementBase(KryptonTaskDialogDefaults taskDialogDefaults)
    {
        // Initial palette
        Palette = KryptonManager.CurrentGlobalPalette;
        
        // Subscribe to global palette changes
        KryptonManager.GlobalPaletteChanged += OnGlobalPaletteChanged;
        
        // Subscribe to current palette paint events
        Palette.PalettePaint += OnPalettePaint;
    }
    
    protected virtual void OnGlobalPaletteChanged(object? sender, EventArgs e)
    {
        // Detach from old palette
        if (Palette is not null)
        {
            Palette.PalettePaint -= OnPalettePaint;
        }
        
        // Attach to new palette
        Palette = KryptonManager.CurrentGlobalPalette;
        if (Palette is not null)
        {
            Palette.PalettePaint += OnPalettePaint;
        }
    }
}
```

### Color Queries

Elements query palette for theme colors:

```csharp
// Get background color from theme
Color backColor = Palette.GetBackColor1(
    PaletteBackStyle.PanelClient, 
    PaletteState.Normal
);

// Get text color from theme
Color textColor = Palette.GetContentShortTextColor1(
    PaletteContentStyle.LabelNormalControl, 
    PaletteState.Normal
);

// Get font from theme
Font font = Palette.GetContentShortTextFont(
    PaletteContentStyle.LabelNormalControl, 
    PaletteState.Normal
);
```

### Theme Override

Users can override theme colors:

```csharp
// Override element background
element.BackColor1 = Color.LightBlue;  // Sets Panel.StateCommon.Color1
element.BackColor2 = Color.White;      // Sets Panel.StateCommon.Color2

// Check for override in element
Color backColor = Panel.StateCommon.Color1 != Color.Empty
    ? Panel.StateCommon.Color1  // User override
    : Palette.GetBackColor1(PaletteBackStyle.PanelClient, PaletteState.Normal);  // Theme
```

---

## Memory Management

### Disposal Pattern

`KryptonTaskDialog` implements `IDisposable`:

```csharp
protected virtual void Dispose(bool disposing)
{
    if (!_disposed && disposing)
    {
        // Dispose all elements
        _elements.ForEach(x => 
        {
            // Unwire events
            x.VisibleChanged -= UpdateFormSizing;
            
            if (x is IKryptonTaskDialogElementEventSizeChanged e)
            {
                e.SizeChanged -= UpdateFormSizing;
            }
            
            // Dispose element
            x.Dispose();
        });
        
        // Dispose form
        _form.Close();
        _form.Dispose();
        
        _disposed = true;
    }
}

public void Dispose()
{
    Dispose(disposing: true);
    GC.SuppressFinalize(this);
}
```

### Element Disposal

Each element disposes its resources:

```csharp
protected virtual void Dispose(bool disposing)
{
    if (!_disposed && disposing)
    {
        // Unwire global events
        KryptonManager.GlobalPaletteChanged -= OnGlobalPaletteChanged;
        
        // Unwire palette events
        if (Palette is not null)
        {
            Palette.PalettePaint -= OnPalettePaint;
            Palette = null!;
        }
        
        // Element-specific cleanup
        // (e.g., dispose icon controllers, context menus, etc.)
        
        _disposed = true;
    }
}
```

### Event Unwiring

Critical to prevent memory leaks:

```csharp
// In element constructor
KryptonManager.GlobalPaletteChanged += OnGlobalPaletteChanged;
Palette.PalettePaint += OnPalettePaint;

// In element Dispose
KryptonManager.GlobalPaletteChanged -= OnGlobalPaletteChanged;
Palette.PalettePaint -= OnPalettePaint;
```

---

## Extending the Component

### Creating a Custom Element

1. **Derive from KryptonTaskDialogElementBase**:

```csharp
public class KryptonTaskDialogElementCustom : KryptonTaskDialogElementBase
{
    private KryptonButton _button;
    
    public KryptonTaskDialogElementCustom(KryptonTaskDialogDefaults taskDialogDefaults) 
        : base(taskDialogDefaults)
    {
        _button = new KryptonButton();
        _button.Text = "Click Me";
        _button.Click += OnButtonClick;
        
        Panel.Controls.Add(_button);
        Panel.Height = 50;
    }
    
    private void OnButtonClick(object? sender, EventArgs e)
    {
        // Handle click
    }
    
    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _button.Click -= OnButtonClick;
        }
        base.Dispose(disposing);
    }
}
```

2. **Implement Relevant Interfaces**:

```csharp
public class KryptonTaskDialogElementCustom : 
    KryptonTaskDialogElementBase,
    IKryptonTaskDialogElementText
{
    public string Text 
    { 
        get => _button.Text;
        set => _button.Text = value;
    }
}
```

3. **Override Layout Methods if Needed**:

```csharp
protected override void OnSizeChanged(bool performLayout = false)
{
    if (LayoutDirty && (Visible || performLayout))
    {
        // Calculate size
        Panel.Height = _button.Height + Defaults.PanelTop + Defaults.PanelBottom;
        
        base.OnSizeChanged(performLayout);
        LayoutDirty = false;
    }
}

internal override void PerformLayout()
{
    base.PerformLayout();
    OnSizeChanged(true);
}
```

4. **Add to KryptonTaskDialog**:

```csharp
public class KryptonTaskDialog : IDisposable
{
    public KryptonTaskDialogElementCustom CustomElement { get; }
    
    public KryptonTaskDialog(int dialogWidth = 0)
    {
        // ... existing code ...
        
        CustomElement = new KryptonTaskDialogElementCustom(_taskDialogDefaults);
        _elements.Add(CustomElement);
        
        // ... existing code ...
    }
}
```

### Implementing a Custom Interface

Create interfaces for common features:

```csharp
public interface IKryptonTaskDialogElementCustomFeature
{
    /// <summary>
    /// Gets or sets the custom value.
    /// </summary>
    int CustomValue { get; set; }
}

// Use in element
public class KryptonTaskDialogElementCustom : 
    KryptonTaskDialogElementBase,
    IKryptonTaskDialogElementCustomFeature
{
    public int CustomValue { get; set; }
}
```

### Using Property Changed Notifications

For complex properties, use property changed notifications:

```csharp
public class CustomProperties
{
    public event Action<CustomPropertyType> PropertyChanged;
    
    public string Value
    {
        get => field;
        set
        {
            if (field != value)
            {
                field = value;
                PropertyChanged?.Invoke(CustomPropertyType.Value);
            }
        }
    }
}

// In element
CustomProperties.PropertyChanged += OnCustomPropertyChanged;

private void OnCustomPropertyChanged(CustomPropertyType property)
{
    if (property == CustomPropertyType.Value)
    {
        // React to change
        LayoutDirty = true;
        OnSizeChanged();
    }
}
```

---

## Performance Considerations

### Layout Deferral

Expensive layout calculations are deferred:

```csharp
// When property changes
LayoutDirty = true;
OnSizeChanged();  // Will skip if not visible

// Layout happens only when:
// 1. Element becomes visible
// 2. Dialog is about to be shown (PerformLayout called)
```

### Icon Caching

Icons are cached after first load and resize:

```csharp
// First request: Load and resize
Image icon = _iconController.GetImage(KryptonTaskDialogIconType.ShieldInformation, 48);

// Subsequent requests: Return cached
Image icon = _iconController.GetImage(KryptonTaskDialogIconType.ShieldInformation, 48);
```

### Event Batching

Multiple property changes don't trigger multiple layouts:

```csharp
// Multiple changes
element.Text = "New text";        // LayoutDirty = true
element.ForeColor = Color.Red;    // No additional layout
element.BackColor1 = Color.Blue;  // No additional layout

// Single layout before display
dialog.ShowDialog();  // PerformLayout() called once
```

### Form Reuse

Reusing form instances avoids repeated creation overhead:

```csharp
// Efficient: Single creation
using (var dialog = new KryptonTaskDialog())
{
    for (int i = 0; i < 100; i++)
    {
        dialog.Content.Text = $"Item {i}";
        dialog.ShowDialog();  // Reuses same form
    }
}
```

---

## Conclusion

The `KryptonTaskDialog` architecture provides:

- **Modularity**: Elements are independent and reusable
- **Efficiency**: Lazy layout calculation and icon caching
- **Flexibility**: Interface-based feature extension
- **Maintainability**: Clear separation of concerns
- **Theme Integration**: Automatic synchronization with Krypton themes
- **Reusability**: Forms can be shown multiple times

This design allows for easy extension and maintenance while providing excellent performance and user experience.

