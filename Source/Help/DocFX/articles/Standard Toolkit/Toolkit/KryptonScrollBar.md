# KryptonScrollBar

## Overview

The `KryptonScrollBar` class provides a custom scrollbar control with Krypton theming. It inherits from `Control` and offers enhanced visual styling, smooth animations, context menu support, and comprehensive keyboard/mouse interaction while maintaining compatibility with standard scrollbar patterns.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── Krypton.Toolkit.KryptonScrollBar
```

## Constructor and Initialization

```csharp
public KryptonScrollBar()
```

The constructor initializes enhanced features:
- **Custom Rendering**: Optimized double buffering and custom paint handling
- **Context Menu**: Built-in context menu with scroll actions
- **Animation Timer**: Smooth thumb movement and button interactions
- **Palette Integration**: Automatic Krypton theme detection and application
- **Default Values**: Standard scrollbar range (0-100), step values, and sizing

## Key Properties

### Orientation Property

```csharp
[DefaultValue(ScrollBarOrientation.Vertical)]
public ScrollBarOrientation Orientation { get; set; }
```

- **Purpose**: Controls scrollbar orientation (horizontal or vertical)
- **Category**: Layout
- **Available Values**:
  - `Vertical`: Standard vertical scrollbar (default)
  - `Horizontal`: Horizontal scrollbar
- **Effect**: Automatically adjusts context menu text and layout

### Range and Value Properties

```csharp
[DefaultValue(0)]
public int Minimum { get; set; }

[DefaultValue(100)]
public int Maximum { get; set; }

[DefaultValue(0)]
public int Value { get; set; }

[DefaultValue(1)]
public int SmallChange { get; set; }

[DefaultValue(10)]
public int LargeChange { get; set; }
```

**Range Management:**
- **Validation**: Automatic bounds checking and adjustment
- **Value Constraints**: Ensures Value stays within Minimum-Maximum range
- **Step Control**: Defines increment amounts for different scroll actions

### Visual Properties

```csharp
[DefaultValue(typeof(Color), "Color.FromARGB(93, 140, 201)")]
public Color BorderColor { get; set; }

[DefaultValue(typeof(Color), "Color.Gray")]
public Color DisabledBorderColor { get; set; }

[DefaultValue(1)]
public double Opacity { get; set; }
```

- **BorderColor**: Color of the scrollbar border when enabled
- **DisabledBorderColor**: Color of the scrollbar border when disabled
- **Opacity**: Context menu opacity (0-1 range)

### ScrollBarWidth Property

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public int ScrollBarWidth
{
    get => Width; 
    set => Width = value;
}
```

- **Purpose**: Controls the width of the scrollbar
- **Category**: Layout
- **Usage**: Designer-friendly property for width control

## Events

### Scroll Event

```csharp
[Category("Behavior")]
[Description("Is raised, when the scrollbar was scrolled.")]
public event ScrollEventHandler? Scroll;
```

- **Purpose**: Fired when the scrollbar value changes
- **Type**: `ScrollEventHandler`
- **Usage**: Handle scroll position changes and update content

## Advanced Usage Patterns

### Basic Scrollbar Setup

```csharp
public void SetupBasicScrollbar()
{
    var scrollBar = new KryptonScrollBar
    {
        Orientation = ScrollBarOrientation.Vertical,
        Minimum = 0,
        Maximum = 1000,
        Value = 0,
        SmallChange = 10,
        LargeChange = 100,
        Width = 20,
        Height = 200
    };

    scrollBar.Scroll += OnScrollBarScroll;
    Controls.Add(scrollBar);
}

private void OnScrollBarScroll(object? sender, ScrollEventArgs e)
{
    // Update content based on scroll position
    UpdateContentPosition(e.NewValue);
}
```

### Content Scrolling Integration

```csharp
public class ScrollableContent : UserControl
{
    private KryptonScrollBar verticalScrollBar;
    private KryptonScrollBar horizontalScrollBar;
    private Panel contentPanel;
    private int contentWidth = 2000;
    private int contentHeight = 1500;

    public ScrollableContent()
    {
        InitializeScrollbars();
        SetupContent();
    }

    private void InitializeScrollbars()
    {
        // Vertical scrollbar
        verticalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Vertical,
            Dock = DockStyle.Right,
            Width = 20,
            Minimum = 0,
            Maximum = contentHeight - Height,
            SmallChange = 10,
            LargeChange = Height / 2
        };

        // Horizontal scrollbar
        horizontalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Horizontal,
            Dock = DockStyle.Bottom,
            Height = 20,
            Minimum = 0,
            Maximum = contentWidth - Width,
            SmallChange = 10,
            LargeChange = Width / 2
        };

        verticalScrollBar.Scroll += OnVerticalScroll;
        horizontalScrollBar.Scroll += OnHorizontalScroll;

        Controls.Add(verticalScrollBar);
        Controls.Add(horizontalScrollBar);
    }

    private void OnVerticalScroll(object? sender, ScrollEventArgs e)
    {
        contentPanel.Top = -e.NewValue;
    }

    private void OnHorizontalScroll(object? sender, ScrollEventArgs e)
    {
        contentPanel.Left = -e.NewValue;
    }

    private void SetupContent()
    {
        contentPanel = new Panel
        {
            Size = new Size(contentWidth, contentHeight),
            BackColor = Color.LightBlue
        };

        Controls.Add(contentPanel);
        contentPanel.BringToFront();
    }
}
```

### Custom Scrollbar with Smooth Scrolling

```csharp
public class SmoothScrollBar : KryptonScrollBar
{
    private Timer smoothTimer;
    private float targetValue;
    private float currentValue;
    private float smoothStep = 0.1f;

    public SmoothScrollBar()
    {
        smoothTimer = new Timer { Interval = 16 }; // ~60 FPS
        smoothTimer.Tick += OnSmoothTimerTick;
    }

    public void SmoothScrollTo(int value)
    {
        targetValue = value;
        if (!smoothTimer.Enabled)
        {
            smoothTimer.Start();
        }
    }

    private void OnSmoothTimerTick(object? sender, EventArgs e)
    {
        float difference = targetValue - currentValue;
        
        if (Math.Abs(difference) < 0.5f)
        {
            currentValue = targetValue;
            smoothTimer.Stop();
        }
        else
        {
            currentValue += difference * smoothStep;
        }

        // Update the actual scrollbar value
        Value = (int)Math.Round(currentValue);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            smoothTimer?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```

### Scrollbar with Custom Context Menu

```csharp
public class EnhancedScrollBar : KryptonScrollBar
{
    private ContextMenuStrip customContextMenu;

    public EnhancedScrollBar()
    {
        CreateCustomContextMenu();
    }

    private void CreateCustomContextMenu()
    {
        customContextMenu = new ContextMenuStrip();

        // Add custom menu items
        var scrollToTopItem = new ToolStripMenuItem("Scroll to Top");
        scrollToTopItem.Click += (s, e) => Value = Minimum;

        var scrollToBottomItem = new ToolStripMenuItem("Scroll to Bottom");
        scrollToBottomItem.Click += (s, e) => Value = Maximum;

        var scrollToMiddleItem = new ToolStripMenuItem("Scroll to Middle");
        scrollToMiddleItem.Click += (s, e) => Value = (Minimum + Maximum) / 2;

        customContextMenu.Items.AddRange(new ToolStripItem[]
        {
            scrollToTopItem,
            scrollToBottomItem,
            scrollToMiddleItem,
            new ToolStripSeparator(),
            new ToolStripMenuItem("Properties...", null, OnPropertiesClick)
        });
    }

    private void OnPropertiesClick(object? sender, EventArgs e)
    {
        // Show custom properties dialog
        using var dialog = new ScrollBarPropertiesDialog(this);
        dialog.ShowDialog();
    }

    protected override void OnMouseDown(MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Right)
        {
            customContextMenu.Show(this, e.Location);
            return;
        }
        base.OnMouseDown(e);
    }
}
```

## Integration Patterns

### ListBox with Custom Scrollbar

```csharp
public class CustomListBox : UserControl
{
    private ListBox listBox;
    private KryptonScrollBar scrollBar;

    public CustomListBox()
    {
        InitializeComponents();
        SetupScrolling();
    }

    private void InitializeComponents()
    {
        listBox = new ListBox
        {
            Dock = DockStyle.Fill,
            BorderStyle = BorderStyle.None,
            ScrollAlwaysVisible = false
        };

        scrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Vertical,
            Dock = DockStyle.Right,
            Width = 20
        };

        Controls.Add(listBox);
        Controls.Add(scrollBar);
    }

    private void SetupScrolling()
    {
        listBox.Items.AddRange(Enumerable.Range(1, 100).Select(i => $"Item {i}").ToArray());
        
        scrollBar.Minimum = 0;
        scrollBar.Maximum = listBox.Items.Count - 1;
        scrollBar.LargeChange = listBox.VisibleItemCount;
        scrollBar.SmallChange = 1;

        scrollBar.Scroll += OnScrollBarScroll;
        listBox.SelectedIndexChanged += OnListBoxSelectionChanged;
    }

    private void OnScrollBarScroll(object? sender, ScrollEventArgs e)
    {
        if (listBox.SelectedIndex != e.NewValue)
        {
            listBox.SelectedIndex = e.NewValue;
            listBox.TopIndex = e.NewValue;
        }
    }

    private void OnListBoxSelectionChanged(object? sender, EventArgs e)
    {
        if (scrollBar.Value != listBox.SelectedIndex)
        {
            scrollBar.Value = listBox.SelectedIndex;
        }
    }
}
```

### DataGridView with Custom Scrollbars

```csharp
public class CustomDataGridView : UserControl
{
    private DataGridView dataGridView;
    private KryptonScrollBar verticalScrollBar;
    private KryptonScrollBar horizontalScrollBar;

    public CustomDataGridView()
    {
        InitializeComponents();
        SetupDataGridView();
    }

    private void InitializeComponents()
    {
        dataGridView = new DataGridView
        {
            Dock = DockStyle.Fill,
            ScrollBars = ScrollBars.None, // Disable built-in scrollbars
            RowHeadersVisible = false,
            ColumnHeadersVisible = true
        };

        verticalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Vertical,
            Dock = DockStyle.Right,
            Width = 20
        };

        horizontalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Horizontal,
            Dock = DockStyle.Bottom,
            Height = 20
        };

        Controls.Add(dataGridView);
        Controls.Add(verticalScrollBar);
        Controls.Add(horizontalScrollBar);
    }

    private void SetupDataGridView()
    {
        // Add sample data
        dataGridView.Columns.Add("Name", "Name");
        dataGridView.Columns.Add("Age", "Age");
        dataGridView.Columns.Add("City", "City");

        for (int i = 0; i < 100; i++)
        {
            dataGridView.Rows.Add($"Person {i}", 20 + i, $"City {i % 10}");
        }

        // Setup scrollbars
        UpdateScrollBars();
        
        verticalScrollBar.Scroll += OnVerticalScroll;
        horizontalScrollBar.Scroll += OnHorizontalScroll;
        
        dataGridView.Scroll += OnDataGridViewScroll;
        dataGridView.Resize += OnDataGridViewResize;
    }

    private void UpdateScrollBars()
    {
        // Vertical scrollbar
        verticalScrollBar.Minimum = 0;
        verticalScrollBar.Maximum = Math.Max(0, dataGridView.Rows.Count - dataGridView.DisplayedRowCount(false));
        verticalScrollBar.LargeChange = dataGridView.DisplayedRowCount(false);
        verticalScrollBar.SmallChange = 1;

        // Horizontal scrollbar
        horizontalScrollBar.Minimum = 0;
        horizontalScrollBar.Maximum = Math.Max(0, dataGridView.Columns.GetColumnsWidth(DataGridViewElementStates.Visible) - dataGridView.ClientSize.Width);
        horizontalScrollBar.LargeChange = dataGridView.ClientSize.Width / 2;
        horizontalScrollBar.SmallChange = 20;
    }

    private void OnVerticalScroll(object? sender, ScrollEventArgs e)
    {
        if (dataGridView.FirstDisplayedScrollingRowIndex != e.NewValue)
        {
            dataGridView.FirstDisplayedScrollingRowIndex = e.NewValue;
        }
    }

    private void OnHorizontalScroll(object? sender, ScrollEventArgs e)
    {
        if (dataGridView.HorizontalScrollingOffset != e.NewValue)
        {
            dataGridView.HorizontalScrollingOffset = e.NewValue;
        }
    }

    private void OnDataGridViewScroll(object? sender, ScrollEventArgs e)
    {
        if (e.ScrollOrientation == ScrollOrientation.VerticalScroll)
        {
            verticalScrollBar.Value = dataGridView.FirstDisplayedScrollingRowIndex;
        }
        else if (e.ScrollOrientation == ScrollOrientation.HorizontalScroll)
        {
            horizontalScrollBar.Value = dataGridView.HorizontalScrollingOffset;
        }
    }

    private void OnDataGridViewResize(object? sender, EventArgs e)
    {
        UpdateScrollBars();
    }
}
```

## Performance Considerations

- **Double Buffering**: Eliminates flicker during scrolling
- **Optimized Rendering**: Efficient graphics operations for smooth animation
- **Memory Management**: Proper disposal of timers and graphics resources
- **Theme Integration**: Lightweight palette switching without full repaints

## Common Issues and Solutions

### Scrollbar Not Responding

**Issue**: Scrollbar doesn't respond to mouse clicks  
**Solution**: Ensure proper event handling and focus:

```csharp
scrollBar.Focus();
scrollBar.TabStop = true;
scrollBar.Enabled = true;
```

### Smooth Scrolling Issues

**Issue**: Jerky or choppy scrolling animation  
**Solution**: Adjust timer interval and animation step:

```csharp
animationTimer.Interval = 16; // 60 FPS
float smoothStep = 0.1f; // Adjust for smoothness
```

### Context Menu Not Showing

**Issue**: Right-click context menu doesn't appear  
**Solution**: Ensure proper mouse event handling:

```csharp
protected override void OnMouseDown(MouseEventArgs e)
{
    if (e.Button == MouseButtons.Right)
    {
        contextMenu.Show(this, e.Location);
        return;
    }
    base.OnMouseDown(e);
}
```

## Design-Time Integration

### Visual Studio Designer

- **Designer**: Custom `KryptonScrollBarDesigner` provides enhanced design-time experience
- **Toolbox**: Available with specialized bitmap representation
- **Property Window**: Comprehensive visual state configuration
- **Default Events**: Scroll event configured as default

### Property Categories

- **Behavior**: Core functionality (`Minimum`, `Maximum`, `Value`, `SmallChange`, `LargeChange`)
- **Layout**: Orientation and sizing (`Orientation`, `ScrollBarWidth`)
- **Appearance**: Visual properties (`BorderColor`, `DisabledBorderColor`, `Opacity`)

## Migration from Standard ScrollBar

### Direct Replacement

```csharp
// Old code
VScrollBar scrollBar = new VScrollBar();

// New code
KryptonScrollBar scrollBar = new KryptonScrollBar
{
    Orientation = ScrollBarOrientation.Vertical
};
```

### Enhanced Features

```csharp
// Standard ScrollBar (basic)
var standardSb = new VScrollBar();

// KryptonScrollBar (enhanced)
var kryptonSb = new KryptonScrollBar
{
    Orientation = ScrollBarOrientation.Vertical,
    BorderColor = Color.FromArgb(93, 140, 201),
    DisabledBorderColor = Color.Gray,
    Opacity = 1.0,
    // Built-in context menu and smooth animations
};
```

## Real-World Integration Examples

### Custom Text Editor with Scrollbars

```csharp
public class CustomTextEditor : UserControl
{
    private RichTextBox textBox;
    private KryptonScrollBar verticalScrollBar;
    private KryptonScrollBar horizontalScrollBar;

    public CustomTextEditor()
    {
        InitializeComponents();
        SetupScrolling();
    }

    private void InitializeComponents()
    {
        textBox = new RichTextBox
        {
            Dock = DockStyle.Fill,
            BorderStyle = BorderStyle.None,
            ScrollBars = RichTextBoxScrollBars.None
        };

        verticalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Vertical,
            Dock = DockStyle.Right,
            Width = 20
        };

        horizontalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Horizontal,
            Dock = DockStyle.Bottom,
            Height = 20
        };

        Controls.Add(textBox);
        Controls.Add(verticalScrollBar);
        Controls.Add(horizontalScrollBar);
    }

    private void SetupScrolling()
    {
        // Load sample text
        textBox.Text = GenerateSampleText();

        // Setup scrollbars
        UpdateScrollBars();

        // Event handlers
        verticalScrollBar.Scroll += OnVerticalScroll;
        horizontalScrollBar.Scroll += OnHorizontalScroll;
        textBox.TextChanged += OnTextChanged;
        textBox.VScroll += OnTextBoxVScroll;
        textBox.HScroll += OnTextBoxHScroll;
    }

    private void UpdateScrollBars()
    {
        // Calculate content dimensions
        int contentHeight = textBox.GetLineFromCharIndex(textBox.Text.Length) * textBox.Font.Height;
        int contentWidth = (int)textBox.CreateGraphics().MeasureString(textBox.Text, textBox.Font).Width;

        // Vertical scrollbar
        verticalScrollBar.Minimum = 0;
        verticalScrollBar.Maximum = Math.Max(0, contentHeight - textBox.ClientSize.Height);
        verticalScrollBar.LargeChange = textBox.ClientSize.Height / 2;
        verticalScrollBar.SmallChange = textBox.Font.Height;

        // Horizontal scrollbar
        horizontalScrollBar.Minimum = 0;
        horizontalScrollBar.Maximum = Math.Max(0, contentWidth - textBox.ClientSize.Width);
        horizontalScrollBar.LargeChange = textBox.ClientSize.Width / 2;
        horizontalScrollBar.SmallChange = 20;
    }

    private void OnVerticalScroll(object? sender, ScrollEventArgs e)
    {
        textBox.SelectionStart = textBox.GetCharIndexFromPosition(new Point(0, e.NewValue));
        textBox.ScrollToCaret();
    }

    private void OnHorizontalScroll(object? sender, ScrollEventArgs e)
    {
        // Horizontal scrolling implementation
        textBox.SelectionStart = textBox.GetCharIndexFromPosition(new Point(e.NewValue, 0));
        textBox.ScrollToCaret();
    }

    private void OnTextChanged(object? sender, EventArgs e)
    {
        UpdateScrollBars();
    }

    private void OnTextBoxVScroll(object? sender, EventArgs e)
    {
        verticalScrollBar.Value = textBox.SelectionStart;
    }

    private void OnTextBoxHScroll(object? sender, EventArgs e)
    {
        horizontalScrollBar.Value = textBox.SelectionStart;
    }

    private string GenerateSampleText()
    {
        var sb = new StringBuilder();
        for (int i = 0; i < 100; i++)
        {
            sb.AppendLine($"This is line {i + 1} of sample text for testing the scrollbar functionality.");
        }
        return sb.ToString();
    }
}
```

### Image Viewer with Zoom and Scroll

```csharp
public class ImageViewer : UserControl
{
    private PictureBox pictureBox;
    private KryptonScrollBar horizontalScrollBar;
    private KryptonScrollBar verticalScrollBar;
    private float zoomFactor = 1.0f;

    public ImageViewer()
    {
        InitializeComponents();
        SetupScrolling();
    }

    private void InitializeComponents()
    {
        pictureBox = new PictureBox
        {
            Dock = DockStyle.Fill,
            SizeMode = PictureBoxSizeMode.AutoSize
        };

        horizontalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Horizontal,
            Dock = DockStyle.Bottom,
            Height = 20
        };

        verticalScrollBar = new KryptonScrollBar
        {
            Orientation = ScrollBarOrientation.Vertical,
            Dock = DockStyle.Right,
            Width = 20
        };

        Controls.Add(pictureBox);
        Controls.Add(horizontalScrollBar);
        Controls.Add(verticalScrollBar);
    }

    private void SetupScrolling()
    {
        horizontalScrollBar.Scroll += OnHorizontalScroll;
        verticalScrollBar.Scroll += OnVerticalScroll;
        pictureBox.SizeChanged += OnPictureBoxSizeChanged;
    }

    public void LoadImage(string imagePath)
    {
        pictureBox.Image = Image.FromFile(imagePath);
        UpdateScrollBars();
    }

    public void SetZoom(float zoom)
    {
        zoomFactor = zoom;
        if (pictureBox.Image != null)
        {
            pictureBox.Size = new Size(
                (int)(pictureBox.Image.Width * zoomFactor),
                (int)(pictureBox.Image.Height * zoomFactor)
            );
            UpdateScrollBars();
        }
    }

    private void UpdateScrollBars()
    {
        if (pictureBox.Image == null) return;

        // Horizontal scrollbar
        horizontalScrollBar.Minimum = 0;
        horizontalScrollBar.Maximum = Math.Max(0, pictureBox.Width - ClientSize.Width + verticalScrollBar.Width);
        horizontalScrollBar.LargeChange = ClientSize.Width / 2;
        horizontalScrollBar.SmallChange = 20;

        // Vertical scrollbar
        verticalScrollBar.Minimum = 0;
        verticalScrollBar.Maximum = Math.Max(0, pictureBox.Height - ClientSize.Height + horizontalScrollBar.Height);
        verticalScrollBar.LargeChange = ClientSize.Height / 2;
        verticalScrollBar.SmallChange = 20;
    }

    private void OnHorizontalScroll(object? sender, ScrollEventArgs e)
    {
        pictureBox.Left = -e.NewValue;
    }

    private void OnVerticalScroll(object? sender, ScrollEventArgs e)
    {
        pictureBox.Top = -e.NewValue;
    }

    private void OnPictureBoxSizeChanged(object? sender, EventArgs e)
    {
        UpdateScrollBars();
    }
}
```