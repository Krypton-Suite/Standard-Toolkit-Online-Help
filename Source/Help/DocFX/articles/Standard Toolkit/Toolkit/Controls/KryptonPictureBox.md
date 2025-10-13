# KryptonPictureBox

## Overview

The `KryptonPictureBox` class provides a Krypton-themed wrapper around the standard Windows PictureBox control. It inherits from `System.Windows.Forms.PictureBox` and enhances it with integrated tooltip support, consistent theming, DPI-aware scaling, and improved visual integration with Krypton Toolkit applications.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── System.Windows.Forms.PictureBox
                └── Krypton.Toolkit.KryptonPictureBox
```

## Constructor and Initialization

```csharp
public KryptonPictureBox()
```

The constructor initializes enhanced features:
- **Transparent Background**: Sets `BackColor = Color.Transparent`
- **ToolTip Support**: Creates `ToolTipManager` with DPI-aware scaling
- **Event Handling**: Sets up mouse event handlers for tooltip functionality

## Key Properties

### ToolTipValues Property

```csharp
[Category("ToolTip")]
[Description("Control ToolTip Text")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public ToolTipValues ToolTipValues { get; set; }
```

- **Purpose**: Provides access to tooltip text, styling, and behavior
- **Category**: ToolTip
- **Type**: `ToolTipValues` - Rich tooltip configuration object
- • **Designer Visible**: Yes (expandable in property grid)

**ToolTipValues Features:**
- **Text Configuration**: Heading, description, and footnotes
- **Style Options**: Normal, SuperTip, and non-focusable variants
- **Shadow Effects**: Configurable drop shadows
- **Enable/Disable**: Toggle tooltip display
- **DPI Aware**: Automatic scaling based on current DPI

**Usage Example:**
```csharp
pictureBox.ToolTipValues.Heading = "Image Information";
pictureBox.ToolTipValues.Description = "Resolution: 1920x1080\nFormat: JPEG\nSize: 2.3 MB";
pictureBox.ToolTipValues.EnableToolTips = true;
```

### ToolTipManager Property

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ToolTipManager ToolTipManager { get; }
```

- **Purpose**: Provides direct access to the underlying tooltip management system
- **Availability**: Runtime only (not visible in designer)
- **Use Cases**: Advanced tooltip customization or integration with custom tooltip systems

### BackColor Property (Hidden)

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new Color BackColor { get => base.BackColor; set => base.BackColor = value; }
```

- **Purpose**: Forces transparent background for consistent theming
- **Default Value**: `Color.Transparent`
- **Designer Visibility**: Hidden (prevents accidental modification)
- **Rationale**: Ensures proper background integration with parent controls

## ToolTip Configuration

### Basic ToolTip Setup

```csharp
public void SetupImagePreview()
{
    var pictureBox = new KryptonPictureBox
    {
        SizeMode = PictureBoxSizeMode.Zoom,
        Image = LoadSampleImage()
    };

    // Configure tooltip
    pictureBox.ToolTipValues.Heading = "Image Preview";
    pictureBox.ToolTipValues.Description = GetImageDetails();
    pictureBox.ToolTipValues.EnableToolTips = true;
    pictureBox.ToolTipValues.ToolTipStyle = LabelStyle.SuperTip;
    
    Controls.Add(pictureBox);
}

private string GetImageDetails()
{
    var image = pictureBox.Image;
    if (image != null)
    {
        return $"Size: {image.Width}x{image.Height}\n" +
               $"Format: {GetImageFormat(image)}\n" +
               $"DPI: {GetHorizontalDpi(image):F1}x{GetVerticalDpi(image):F1}";
    }
    return "No image loaded";
}
```

### Advanced ToolTip Customization

```csharp
public void SetupDetailedToolTip()
{
    pictureBox.ToolTipValues.Heading = "Photo Details";
    pictureBox.ToolTipValues.Description = """
        Resolution: 3840x2160 (4K UHD)
        Color Depth: 24-bit RGB
        JPEG Quality: 95%
        File Size: 8.7 MB
        Date Taken: March 15, 2024
        Camera: EXIF data available
        """;
    pictureBox.ToolTipValues.Footnote = "Click to view in full resolution";
    
    // Advanced styling
    pictureBox.ToolTipValues.ToolTipStyle = LabelStyle.SuperTip;
    pictureBox.ToolTipValues.ToolTipShadow = true;
}
```

### Dynamic ToolTip Updates

```csharp
public class DynamicImageGallery : Form
{
    private Dictionary<KryptonPictureBox, ImageMetadata> imageMetadata = new();

    public void LoadImage(KryptonPictureBox pictureBox, Image image, string filePath)
    {
        pictureBox.Image = image;
        
        // Calculate metadata
        var metadata = new ImageMetadata
        {
            FilePath = filePath,
            Width = image.Width,
            Height = image.Height,
            FileSize = new FileInfo(filePath).Length,
            CreatedDate = File.GetCreationTime(filePath)
        };

        imageMetadata[pictureBox] = metadata;
        
        // Update tooltip dynamically
        UpdateToolTip(pictureBox, metadata);
        
        // Setup dynamic updates
        pictureBox.ImageChanged += (s, e) => RefreshToolTip(s as KryptonPictureBox);
    }

    private void UpdateToolTip(KryptonPictureBox pictureBox, ImageMetadata metadata)
    {
        pictureBox.ToolTipValues.Heading = Path.GetFileName(metadata.FilePath);
        pictureBox.ToolTipValues.Description = string.Format("""
            Resolution: {0}x{1}
            File Size: {2:N0} bytes ({3:F1} MB)
            Created: {4:yyyy-MM-dd HH:mm}
            Format: {5}
            """, 
            metadata.Width, metadata.Height, 
            metadata.FileSize, metadata.FileSize / 1024.0 / 1024.0,
            metadata.CreatedDate, 
            Path.GetExtension(metadata.FilePath).ToUpper());
    }
}
```

## Event Integration

### Mouse Event Enhancement

The control automatically handles mouse events for tooltip management:

- **MouseEnter**: Initiates tooltip display process
- **MouseMove**: Updates tooltip position and delay timing
- **MouseDown/MouseUp**: Manages tooltip state during interactions
- **MouseLeave**: Cancels tooltip display

**Custom Mouse Handling:**
```csharp
public class InteractiveImageControl : KryptonPictureBox
{
    public event EventHandler<ImageClickEventArgs> ImageClicked;

    protected override void OnMouseClick(MouseEventArgs e)
    {
        base.OnMouseClick(e);
        
        if (Image != null)
        {
            var imageCoordinates = PointToImageCoordinates(e.Location);
            OnImageClicked(new ImageClickEventArgs(imageCoordinates, e.Button));
        }
    }

    protected virtual void OnImageClicked(ImageClickEventArgs e)
    {
        ImageClicked?.Invoke(this, e);
    }

    private Point PointToImageCoordinates(Point screenPoint)
    {
        // Convert screen coordinates to image coordinates based on SizeMode
        // Implementation depends on SizeMode (Normal, StretchImage, Zoom, etc.)
        return CalculateImagePoint(screenPoint);
    }
}
```

## Advanced Usage Patterns

### Image Gallery Implementation

```csharp
public class ImageGallery : UserControl
{
    private readonly FlowLayoutPanel flowPanel = new FlowLayoutPanel
    {
        Dock = DockStyle.Fill,
        AutoScroll = true,
        WrapContents = true
    };

    public void AddImage(string imagePath)
    {
        var thumbnailBox = new KryptonPictureBox
        {
            Size = new Size(150, 150),
            SizeMode = PictureBoxSizeMode.Zoom,
            BorderStyle = BorderStyle.FixedSingle,
            Margin = new Padding(5),
            Image = LoadThumbnail(imagePath)
        };

        // Setup tooltip with image metadata
        SetupThumbnailToolTip(thumbnailBox, imagePath);
        
        // Add click handler
        thumbnailBox.Click += (s, e) => OnThumbnailClick(imagePath);
        
        flowPanel.Controls.Add(thumbnailBox);
    }

    private void SetupThumbnailToolTip(KryptonPictureBox pictureBox, string imagePath)
    {
        var imageInfo = new FileInfo(imagePath);
        var image = Image.FromFile(imagePath);
        
        pictureBox.ToolTipValues.Heading = Path.GetFileName(imagePath);
        pictureBox.ToolTipValues.Description = $"""
            Resolution: {image.Width}x{image.Height}
            Size: {FormatFileSize(imageInfo.Length)}
            Modified: {imageInfo.LastWriteTime:yyyy-MM-dd HH:mm}
            """;
        pictureBox.ToolTipValues.EnableToolTips = true;
        
        image.Dispose(); // Clean up temporary image
    }
}
```

### Dynamic Image Loading

```csharp
public class LazyImageLoader : KryptonPictureBox
{
    private string? pendingImagePath;

    public string? ImagePath
    {
        get => pendingImagePath;
        set
        {
            pendingImagePath = value;
            if (value != null)
            {
                LoadImageAsync(value);
            }
        }
    }

    private async void LoadImageAsync(string imagePath)
    {
        // Show loading state
        ToolTipValues.Heading = "Loading...";
        ToolTipValues.Description = "Please wait while image loads";
        ToolTipValues.EnableToolTips = true;

        try
        {
            // Load image on background thread
            var image = await Task.Run(() => Image.FromFile(imagePath));
            
            // Update UI on main thread
            this.Invoke(() =>
            {
                Image = image;
                UpdateToolTipWithImageInfo(imagePath, image);
            });
        }
        catch (Exception ex)
        {
            this.Invoke(() =>
            {
                ToolTipValues.Heading = "Error";
                ToolTipValues.Description = $"Failed to load image: {ex.Message}";
            });
        }
    }

    private void UpdateToolTipWithImageInfo(string imagePath, Image image)
    {
        ToolTipValues.Heading = Path.GetFileName(imagePath);
        ToolTipValues.Description = $"""
            Resolution: {image.Width}x{image.Height}
            Format: {image.PixelFormat}
            Physical Size: {image.HorizontalResolution:F1}x{image.VerticalResolution:F1} DPI
            """;
    }
}
```

### Image Metadata Display

```csharp
public class MetadataToolTipHandler
{
    public static void AttachMetadataToolTip(KryptonPictureBox pictureBox)
    {
        // Attach to image changes
        pictureBox.ImageChanged += OnImageChanged;
        
        // Store original image path if available
        if (pictureBox.Tag is string imagePath)
        {
            SetupFileMetadataToolTip(pictureBox, imagePath);
        }
    }

    private static void OnImageChanged(object? sender, EventArgs e)
    {
        if (sender is KryptonPictureBox pictureBox)
        {
            RefreshMetatadataToolTip(pictureBox);
        }
    }

    private static void SetupFileMetadataToolTip(KryptonPictureBox pictureBox, string filePath)
    {
        try
        {
            var image = Image.FromFile(filePath);
            var fileInfo = new FileInfo(filePath);
            
            pictureBox.ToolTipValues.Heading = Path.GetFileName(filePath);
            pictureBox.ToolTipValues.Description = $"""
                File: {fileInfo.Name}
                Path: {fileInfo.DirectoryName}
                Resolution: {image.Width}x{image.Height}
                File Size: {FormatBytes(fileInfo.Length)}
                Created: {fileInfo.CreationTime:yyyy-MM-dd HH:mm}
                Modified: {fileInfo.LastWriteTime:yyyy-MM-dd HH:mm}
                """;

            image.Dispose();
        }
        catch (Exception)
        {
            // Handle errors gracefully
            pictureBox.ToolTipValues.Description = "Metadata unavailable";
        }
    }

    private static string FormatBytes(long bytes)
    {
        string[] suffixes = { "B", "KB", "MB", "GB" };
        double size = bytes;
        int suffixIndex = 0;
        
        while (size >= 1024 && suffixIndex < suffixes.Length - 1)
        {
            size /= 1024;
            suffixIndex++;
        }
        
        return $"{size:F1} {suffixes[suffixIndex]}";
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with `PictureBox` bitmap representation
- **Property Window**: ToolTip properties expandable in designer
- **Custom Editors**: Rich tooltip text editing capabilities
- **Serialization**: ToolTip settings saved to designer files

### Property Categories

- **ToolTip**: All tooltip-related properties (`ToolTipValues`)
- **Appearance**: Image display properties (inherited from `PictureBox`)
- **Behavior**: Control behavior properties (inherited from `PictureBox`)
- **Layout**: Size and positioning properties (inherited from `PictureBox`)

## Performance Considerations

- **Image Memory**: Large images consume significant memory; consider thumbnail generation
- **ToolTip Performance**: ToolTip rendering is optimized for Responsive performance
- **DPI Scaling**: Automatic tooltip scale calculation prevents layout issues
- **Image Disposal**: Proper image disposal prevents memory leaks

## Common Issues and Solutions

### ToolTip Not Displaying

**Issue**: ToolTip not appearing despite being enabled  
**Solution**: Check form focus and ensure control is visible:

```csharp
pictureBox.ToolTipValues.EnableToolTips = true;
// Ensure form has focus
FindForm()?.Focus();
```

### Large Image Memory Usage

**Issue**: High memory consumption with large images  
**Solution**: Scale images before loading or generate thumbnails:

```csharp
public static Image CreateThumbnail(string imagePath, int maxWidth, int maxHeight)
{
    using var originalImage = Image.FromFile(imagePath);
    return originalImage.GetThumbnailImage(maxWidth, maxHeight, null, IntPtr.Zero);
}
```

### DPI Scaling Issues

**Issue**: Tooltip appears incorrectly sized on high-DPI displays  
**Solution**: Automatic DPI scaling is handled internally; ensure proper DPI awareness:

```csharp
// Ensure DPI awareness in application
[STAThread]
static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    Application.Run(new MainForm());
}
```

### Background Transparency Problems

**Issue**: Control shows unwanted background color  
**Solution**: Background transparency is enforced; override `OnPaintBackground` for custom backgrounds:

```csharp
protected override void OnPaintBackground(PaintEventArgs e)
{
    if (Image == null && Parent != null)
    {
        // Use parent's background
        var rect = RectangleToScreen(ClientRectangle);
        var parentRect = Parent.RectangleToScreen(Parent.ClientRectangle);
        rect.Intersect(parentRect);
        
        if (!rect.IsEmpty)
        {
            ControlPaint.DrawReversibleFrame(rect, Parent.BackColor, FrameStyle.Dashed);
        }
    }
    else
    {
        base.OnPaintBackground(e);
    }
}
```

## Migration from Standard PictureBox

### Direct Replacement

```csharp
// Old code
PictureBox pictureBox = new PictureBox();

// New code
KryptonPictureBox pictureBox = new KryptonPictureBox();
```

### Enhanced Features

```csharp
// Standard PictureBox (basic)
var standardPictureBox = new PictureBox();

// KryptonPictureBox (enhanced)
var kryptonPictureBox = new KryptonPictureBox
{
    SizeMode = PictureBoxSizeMode.Zoom,
    ToolTipValues = new ToolTipValues
    {
        Heading = "Image Preview",
        Description = "Click for full size",
        EnableToolTips = true
    }
};
```

## Real-World Integration Examples

### Photo Viewer Application

```csharp
public partial class PhotoViewerForm : Form
{
    private KryptonPictureBox pictureBox;

    public PhotoViewerForm()
    {
        InitializeComponent();
        InitializePictureBox();
    }

    private void InitializePictureBox()
    {
        pictureBox = new KryptonPictureBox
        {
            Dock = DockStyle.Fill,
            SizeMode = PictureBoxSizeMode.Zoom,
            BackColor = Color.Transparent
        };

        // Setup metadata tooltip
        pictureBox.ToolTipValues.ToolTipStyle = LabelStyle.SuperTip;
        pictureBox.ToolTipValues.ToolTipShadow = true;
        
        Controls.Add(pictureBox);
    }

    public void LoadImage(string imagePath)
    {
        try
        {
            var image = Image.FromFile(imagePath);
            pictureBox.Image = image;
            
            // Update tooltip with image info
            UpdateImageToolTip(imagePath, image);
            
            Text = $"Photo Viewer - {Path.GetFileName(imagePath)}";
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error loading image: {ex.Message}", "Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void UpdateImageToolTip(string path, Image image)
    {
        var fileInfo = new FileInfo(path);
        var exifData = ExtractExifData(image);

        pictureBox.ToolTipValues.Heading = Path.GetFileName(path);
        pictureBox.ToolTipValues.Description = $"""
            Resolution: {image.Width}x{image.Height}
            File Size: {fileInfo.Length:N0} bytes
            Created: {fileInfo.CreationTime:yyyy-MM-dd HH:mm}
            Modified: {fileInfo.LastWriteTime:yyyy-MM-dd HH:mm}
            {exifData}
            """;
    }
}
```

### Drag-and-Drop Image Handler

```csharp
public class DragDropImageHandler : KryptonPictureBox
{
    public event EventHandler<ImageDroppedEventArgs>? ImageDropped;

    public DragDropImageHandler()
    {
        InitializeDragAndDrop();
    }

    private void InitializeDragAndDrop()
    {
        AllowDrop = true;
        
        DragEnter += OnDragEnter;
        DragDrop += OnDragDrop;

        // Default tooltip
        ToolTipValues.Heading = "Image Drop Zone";
        ToolTipValues.Description = "Drag and drop image files here";
        ToolTipValues.EnableToolTips = true;
    }

    private void OnDragEnter(object? sender, DragEventArgs e)
    {
        e.Effect = e.Data!.GetDataPresent(DataFormats.FileDrop) 
            ? DragDropEffects.Copy 
            : DragDropEffects.None;
    }

    private void OnDragDrop(object? sender, DragEventArgs e)
    {
        var files = (string[])e.Data!.GetData(DataFormats.FileDrop)!;
        
        foreach (string file in files)
        {
            if (IsImageFile(file))
            {
                OnImageDropped(file);
                break; // Handle first image file only
            }
        }
    }

    private void OnImageDropped(string filePath)
    {
        ImageDropped?.Invoke(this, new ImageDroppedEventArgs(filePath));
        
        // Update tooltip
        ToolTipValues.Heading = Path.GetFileName(filePath);
        ToolTipValues.Description = $"Loaded: {filePath}";
    }
}

public class ImageDroppedEventArgs : EventArgs
{
    public string FilePath { get; }
    
    public ImageDroppedEventArgs(string filePath)
    {
        FilePath = filePath;
    }
}
```