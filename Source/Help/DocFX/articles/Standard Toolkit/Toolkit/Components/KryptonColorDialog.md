# KryptonColorDialog

## Overview

The `KryptonColorDialog` class provides a Krypton-themed wrapper around the standard Windows color selection dialog. It inherits from `System.Windows.Forms.ColorDialog` and enhances it with Krypton styling, custom icons, titles, high-DPI support, and an optional alpha (transparency) slider for color selection with alpha channel support.

## Class Hierarchy

```
System.Object
└── System.ComponentModel.Component
    └── System.Windows.Forms.CommonDialog
        └── System.Windows.Forms.ColorDialog
            └── Krypton.Toolkit.KryptonColorDialog
```

## Constructor and Initialization

```csharp
public KryptonColorDialog()
```

The constructor initializes all the enhanced components:
- **CommonDialogHandler**: Manages Krypton theming and window behavior
- **Alpha Components**: Creates alpha slider, label, and preview panel for transparency support
- **Timer**: Handles real-time alpha value updates
- **Default Icon**: Uses `DialogImageResources.Colour_V10`

## Key Properties

### Title Property

```csharp
public string Title { get; set; }
```

- **Purpose**: Sets the caption text shown in the dialog's title bar
- **Category**: Appearance
- **Default Value**: Empty string (uses system default)
- **Designer Visible**: Yes

**Usage Example:**
```csharp
var dialog = new KryptonColorDialog
{
    Title = "Choose Document Foreground Color"
};
```

### Icon Property

```csharp
public Icon Icon { get; set; }
```

- **Purpose**: Sets a custom icon displayed in the dialog's title bar
- **Category**: Appearance
- **Default Value**: `DialogImageResources.Colour_V10`
- **Designer Visible**: Yes

**Usage Example:**
```csharp
var dialog = new KryptonColorDialog
{
    Icon = MyAppIcon  // Custom application icon
};
```

### ShowIcon Property

```csharp
[DefaultValue(false)]
public bool ShowIcon { get; set; }
```

- **Purpose**: Controls whether the dialog displays an icon in the title bar
- **Category**: Appearance
- **Default Value**: `false`

**Usage Example:**
```csharp
var dialog = new KryptonColorDialog
{
    ShowIcon = true,
    Icon = myCustomIcon
};
```

### ShowAlphaSlider Property

```csharp
[DefaultValue(false)]
public bool ShowAlphaSlider { get; set; }
```

- **Purpose**: Enables the alpha (transparency) slider for selecting colors with alpha channel
- **Category**: Behavior
- **Default Value**: `false`
- **Side Effects**: Automatically enables `AllowFullOpen` and `FullOpen` when set to `true`

**Important Notes:**
- When enabled, forces the dialog into full-open mode
- Adds a vertical alpha slider with real-time preview
- Updates the `Color` property to include alpha values
- Displays alpha values as tooltips and labels

**Usage Example:**
```csharp
var dialog = new KryptonColorDialog
{
    ShowAlphaSlider = true,
    Color = Color.FromArgb(128, Color.Red)  // Semi-transparent red
};
```

### Color Property (Enhanced)

```csharp
public new Color Color { get; set; }
```

- **Purpose**: Gets or sets the selected color, with alpha channel support when `ShowAlphaSlider` is enabled
- **Category**: Data
- **Returns**: Full color including alpha when alpha slider is active
- **Side Effects**: Updates alpha slider value when color is set programmatically

**Alpha-Aware Behavior:**
```csharp
dialog.ShowAlphaSlider = true;
dialog.Color = Color.FromArgb(180, Color.Blue);

// Later...
Color selectedColor = dialog.Color;  
// Returns: Color with alpha = 180

dialog.ShowAlphaSlider = false;
dialog.Color = Color.Red;
// Returns: Color with alpha = 255 (opaque)
```

## Standard ColorDialog Properties

The dialog inherits all standard `ColorDialog` properties with full compatibility:

- **AllowFullOpen**: Controls access to advanced color options
- **AnyColor**: Allows selection of custom colors beyond palette
- **Color**: The selected color (enhanced with alpha support)
- **CustomColors**: Array of available custom colors
- **FullOpen**: Whether advanced options panel is initially open
- **SolidColorOnly**: Restricts selection to solid colors only

## Display Behavior and Layout

### Compact Mode (FullOpen = false)
- Displays basic color palette
- Customizable window title and icon
- Optimized layout size (automatically calculated)
- Alpha slider available if enabled

### Full Open Mode (FullOpen = true)
- Shows advanced color selection controls
- RGB editing fields
- Custom color definition area
- Alpha slider integrated seamlessly (when enabled)

### Alpha Slider Integration
When `ShowAlphaSlider` is enabled:
- **Vertical Slider**: Positioned to right of RGB fields
- **Range**: 0-255 (fully transparent to fully opaque)
- **Real-time Preview**: Updates color preview panel
- **Tooltips**: Shows current alpha value
- **Labels**: Displays alpha value numerically

## Advanced Features

### Alpha Channel Management

```csharp
public void SelectColorWithTransparency()
{
    var dialog = new KryptonColorDialog
    {
        ShowAlphaSlider = true,
        AllowFullOpen = true,  // Automatically set by ShowAlphaSlider
        Color = Color.FromArgb(200, Color.Green),
        Title = "Select With Transparency"
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        Color selectedColor = dialog.Color;
        int alpha = selectedColor.A;  // Alpha channel value
        Color baseColor = Color.FromArgb(red: 255, green: 128, blue: 64);
        // Use selectedColor.A as alpha value
    }
}
```

### Theme Integration

The dialog automatically applies Krypton theming through:
- **CommonDialogHandler**: Provides window management and styling
- **DPI Scaling**: Automatic scaling for high-DPI displays
- **Palette Support**: Respects global Krypton palette settings
- **Consistent Appearance**: Matches other Krypton dialogs

### Custom Icon Workflow

```csharp
public class ColorSelectionService
{
    private static readonly Icon AppIcon = LoadApplicationIcon();

    public Color ShowColorDialog(string title, Color defaultColor, bool withAlpha = false)
    {
        using var dialog = new KryptonColorDialog
        {
            Title = title,
            Icon = AppIcon,
            ShowIcon = true,
            ShowAlphaSlider = withAlpha,
            Color = defaultColor
        };

        return dialog.ShowDialog() == DialogResult.OK ? dialog.Color : defaultColor;
    }

    public Color SelectTextColor() => ShowColorDialog("Text Color", Color.Black, false);
    public Color SelectBackgroundColor() => ShowColorDialog("Background", Color.White, true);
}
```

## Performance Considerations

- **Lazy Alpha Components**: Alpha slider created only when needed
- **Timer Management**: Alpha update timer disabled when not in use
- **Memory Cleanup**: Proper disposal patterns for embedded controls
- **DPI Handling**: Automatic scaling prevents layout issues

## Usage Patterns

### Basic Color Selection

```csharp
private Color GetUserColorChoice()
{
    var dialog = new KryptonColorDialog
    {
        Title = "Choose Primary Color"
    };

    return dialog.ShowDialog() == DialogResult.OK ? dialog.Color : Color.Black;
}
```

### Advanced Color Selection with Alpha

```csharp
private void ConfigureButtonBackground()
{
    var dialog = new KryptonColorDialog
    {
        Title = "Button Background (support transparency)",
        ShowAlphaSlider = true,
        AllowFullOpen = true,
        AnyColor = true
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        myButton.BackColor = dialog.Color;
        // Color includes alpha: rgba(red, green, blue, alpha)
    }
}
```

### Theme-Aware Color Selection

```csharp
public class ThemedColorSelector
{
    public Color ShowDialog(IPalette palette, string title)
    {
        var dialog = new KryptonColorDialog
        {
            Title = title,
            Icon = palette.GetThemedIcon()  // Assuming palette provides themed icons
        };

        return dialog.ShowDialog() == DialogResult.OK ? dialog.Color : Color.Empty;
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: All properties properly categorized and exposed
- **Icon Selection**: Type editor for icon selection
- **Serialization**: Design-time settings saved to designer files

### Property Categories

- **Data**: Core color selection properties (`Color`, `CustomColors`)
- **Behavior**: Control behavior (`ShowAlphaSlider`, `AllowFullOpen`)
- **Appearance**: Visual customization (`Title`, `Icon`, `ShowIcon`)

## Common Issues and Solutions

### Alpha Slider Not Appearing

**Issue**: Alpha slider not visible despite enabling `ShowAlphaSlider`  
**Solution**: Ensure `AllowFullOpen` or `FullOpen` is enabled (automatically handled)

### Custom Colors Not Persisting

**Issue**: Custom colors lost between dialog instances  
**Solution**: Store `CustomColors` array and restore between uses:

```csharp
private static int[] _savedCustomColors = new int[16];

var dialog = new KryptonColorDialog
{
    CustomColors = _savedCustomColors  // Restore previous custom colors
};

if (dialog.ShowDialog() == DialogResult.OK)
{
    _savedCustomColors = dialog.CustomColors;  // Save current state
}
```

### DPI Scaling Issues

**Issue**: Dialog appears incorrectly scaled on high-DPI displays  
**Solution**: Automatic handling by `CommonDialogHandler`, no additional code needed

### Performance with Alpha Animations

**Issue**: Dialog slows down with continuous alpha slider updates  
**Solution**: Timer-based updates are optimized; alpha slider provides immediate feedback

## Migration from Standard ColorDialog

### Direct Replacement

```csharp
// Old code
using ColorDialog = System.Windows.Forms.ColorDialog;
var dialog = new ColorDialog();

// New code  
var dialog = new KryptonColorDialog();
```

### Enhanced Features

```csharp
// Standard ColorDialog (limited)
var standardDialog = new ColorDialog();

// KryptonColorDialog (enhanced)
var kryptonDialog = new KryptonColorDialog
{
    Title = "Enhanced Color Selection",
    Icon = applicationIcon,
    ShowIcon = true,
    ShowAlphaSlider = true  // Alpha channel support!
};
```

## Real-World Integration Examples

### Color Palette Editor

```csharp
public class PaletteEditor : Form
{
    public PaletteEditor()
    {
        InitializeComponent();
    }

    private void EditColor(Control targetControl)
    {
        var dialog = new KryptonColorDialog
        {
            Title = $"Edit {targetControl.Name} Color",
            ShowAlphaSlider = SupportsTransparency(targetControl),
            Color = targetControl.BackColor,
            AllowFullOpen = true,
            AnyColor = true
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            targetControl.BackColor = dialog.Color;
            targetControl.Invalidate(); // Refresh display
        }
    }

    private static bool SupportsTransparency(Control control) => 
        control.SupportsTransparency() || control is Panel;
}
```

### Multi-Step Color Workflow

```csharp
public class DocumentStyler
{
    public DocumentStyle ConfigureStyling()
    {
        var style = new DocumentStyle();

        // Step 1: Main text color
        var textDialog = new KryptonColorDialog
        {
            Title = "Step 1: Main Text Color",
            Color = Color.Black
        };
        if (textDialog.ShowDialog() == DialogResult.OK)
            style.TextColor = textDialog.Color;

        // Step 2: Background with transparency option
        var bgDialog = new KryptonColorDialog
        {
            Title = "Step 2: Background Color",
            ShowAlphaSlider = true,
            Color = Color.FromArgb(240, Color.White) // Semi-transparent white
        };
        if (bgDialog.ShowDialog() == DialogResult.OK)
            style.BackgroundColor = bgDialog.Color;

        // Step 3: Accent color
        var accentDialog = new KryptonColorDialog
        {
            Title = "Step 3: Accent Color",
            ShowIcon = true,
            Icon = SystemIcons.Information,
            Color = Color.Blue
        };
        if (accentDialog.ShowDialog() == DialogResult.OK)
            style.AccentColor = accentDialog.Color;

        return style;
    }
}
```