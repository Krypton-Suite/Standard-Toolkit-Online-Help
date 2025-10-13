# KryptonFontDialog

## Overview

The `KryptonFontDialog` class provides a Krypton-themed wrapper around the standard Windows font selection dialog. It inherits from `System.Windows.Forms.FontDialog` and enhances it with Krypton styling, custom icons, titles, high-DPI support, and optional extended color selection capabilities for font styling.

## Class Hierarchy

```
System.Object
└── System.ComponentModel.Component
    └── System.Windows.Forms.CommonDialog
        └── System.Windows.Forms.FontDialog
            └── Krypton.Toolkit.KryptonFontDialog
```

## Constructor and Initialization

```csharp
public KryptonFontDialog()
```

The constructor initializes the enhanced features:
- **CommonDialogHandler**: Manages Krypton theming and window behavior
- **Default Icon**: Uses `DialogImageResources.font`
- **Default Icon Display**: `ShowIcon = false`
- **Click Callback**: Handles dialog-specific button interactions

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
var dialog = new KryptonFontDialog
{
    Title = "Choose Document Font"
};
```

### Icon Property

```csharp
public Icon Icon { get; set; }
```

- **Purpose**: Sets a custom icon displayed in the dialog's title bar
- **Category**: Appearance
- **Default Value**: `DialogImageResources.font`
- **Designer Visible**: Yes

**Usage Example:**
```csharp
var dialog = new KryptonFontDialog
{
    Icon = MyApplicationIcon,
    ShowIcon = true
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

### DisplayExtendedColorsButton Property

```csharp
public bool DisplayExtendedColorsButton { get; set; }
```

- **Purpose**: Shows an enhanced color selection interface instead of the basic color dropdown
- **Category**: Appearance
- **Default Value**: `false`
- **Side Effects**: Automatically enables `ShowColor` when set to `true`

**Enhanced Color Selection:**
When enabled, replaces the standard color combobox with:
- **KryptonColorButton**: Full-featured color selection
- **Scheme Support**: Office themes and basic 16-color schemes
- **Enhanced UX**: Better visual feedback and color preview
- **Custom Color Support**: Selection beyond basic palette

**Usage Example:**
```csharp
var dialog = new KryptonFontDialog
{
    DisplayExtendedColorsButton = true,
    ShowColor = true,  // Automatically enabled
    Title = "Font & Color Selection"
};
```

### DisplayIsPrinterFontDescription Property

```csharp
public bool DisplayIsPrinterFontDescription { get; set; }
```

**Purpose**: Shows informational text about printer compatibility
- **Category**: Behavior
- **Implementation**: Uses internal Win32 dialog options
- **Use Case**: Warns users when selected fonts may not print correctly

**Internal Implementation:**
- Accesses private `GetOption` and `SetOption` methods via reflection
- Controls bit 0x02 in internal dialog options
- Provides printer compatibility warnings

**Usage Example:**
```csharp
var dialog = new KryptonFontDialog
{
    DisplayIsPrinterFontDescription = true,
    Title = "Font Selection (Printer Compatible)"
};
```

## Standard FontDialog Properties

The dialog inherits all standard `FontDialog` properties with full compatibility:

- **AllowSimulations**: Allows font simulation options
- **AllowVectorFonts**: Permits vector font selection
- **AllowVerticalFonts**: Enables vertical font selection
- **Color**: Font color selection
- **FixedPitchOnly**: Restricts to fixed-width fonts only
- **Font**: Selected font object
- **MaxSize**: Maximum font size allowed
- **MinSize**: Minimum font size allowed
- **ScriptsOnly**: Restricts to specific script subsets
- **ShowApply**: Shows Apply button
- **ShowColor**: Enables color selection
- **ShowEffects**: Displays strikethrough and underline options
- **ShowHelp**: Shows Help button

## Enhanced Features

### Custom Color Button Integration

When `DisplayExtendedColorsButton` is enabled:

```csharp
public void ConfigureRichTextFont()
{
    var dialog = new KryptonFontDialog
    {
        Title = "Rich Text Font Selection",
        DisplayExtendedColorsButton = true,
        ShowEffects = true,
        AllowVectorFonts = true,
        MaxSize = 24,
        MinSize = 8
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        RichTextBox richTextBox = GetActiveRichTextBox();
        richTextBox.SelectionFont = dialog.Font;
        richTextBox.SelectionColor = dialog.Color;
    }
}
```

### Theme Integration

The dialog automatically applies Krypton theming:
- **CommonDialogHandler**: Provides consistent window styling
- **DPI Scaling**: Automatic scaling for high-DPI displays  
- **Palette Awareness**: Respects global Krypton palette settings
- **Consistent UI**: Matches other Krypton-themed dialogs

### Native Integration

Special considerations for font dialog behavior:
- **Limited Embedding**: Avoids breaking modal loops
- **Control Substitution**: Seamlessly replaces color combobox
- **Event Handling**: Proper message routing and button states
- **Print Awareness**: Printer compatibility information

## Advanced Usage Patterns

### Font Family Management

```csharp
public class FontManager
{
    private Font _defaultFont = new Font("Segoe UI", 12F);
    private Color _defaultColor = Color.Black;

    public FontInfo SelectFont(FontInfo currentFont)
    {
        var dialog = new KryptonFontDialog
        {
            Title = "Font Configuration",
            ShowIcon = true,
            Icon = SystemIcons.Information,
            DisplayExtendedColorsButton = true,
            Font = currentFont?.Font ?? _defaultFont,
            Color = currentFont?.Color ?? _defaultColor,
            ShowEffects = true,
            AllowVectorFonts = true
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            return new FontInfo
            {
                Font = dialog.Font,
                Color = dialog.Color,
                IsPrinterCompatible = IsPrinterFont(dialog.Font)
            };
        }

        return currentFont;
    }

    private static bool IsPrinterFont(Font font)
    {
        // Check if font has printer-compatible alternatives
        return !font.GdiVerticalFont && !font.GdiCharSet.Equals(1);
    }
}
```

### Document Formatting Application

```csharp
public class DocumentFormatter
{
    public void ApplyFontToSelection()
    {
        var currentSelection = GetSelectedTextProperties();
        
        var dialog = new KryptonFontDialog
        {
            Title = "Font Properties",
            DisplayExtendedColorsButton = true,
            Font = currentSelection.Font,
            Color = currentSelection.Color,
            ShowEffects = true,
            ShowApply = true,  // Allows preview without closing dialog
            AllowVectorFonts = true
        };

        // Handle Apply button for live preview
        dialog.Apply += (sender, e) => 
        {
            PreviewFontChange(dialog.Font, dialog.Color);
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            ApplyFontChange(dialog.Font, dialog.Color);
        }
    }

    private void PreviewFontChange(Font font, Color color)
    {
        // Temporarily apply changes for preview
        SetSelectionProperties(font, color);
    }

    private void ApplyFontChange(Font font, Color color)
    {
        // Apply final changes
        SetSelectionProperties(font, color);
        SaveDocument();
    }
}
```

### Multi-Language Font Selection

```csharp
public class LocalizationFontSelector
{
    public FontInfo SelectLocalizedFont(LanguageInfo language)
    {
        var dialog = new KryptonFontDialog
        {
            Title = $"Font for {language.DisplayName}",
            DisplayIsPrinterFontDescription = true,
            DisplayExtendedColorsButton = true,
            ScriptsOnly = GetScriptCode(language),
            AllowVectorFonts = language.SupportsVectorFonts,
            MinSize = language.MinimumFontSize,
            MaxSize = language.MaximumFontSize
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            return new FontInfo
            {
                Font = dialog.Font,
                Color = dialog.Color,
                Language = language,
                SupportsUnicode = CheckUnicodeSupport(dialog.Font)
            };
        }

        return null;
    }

    private UInt32 GetScriptCode(LanguageInfo language)
    {
        return language.ScriptCode switch
        {
            "Latin" => 0x0001,      // ANSI_CHARSET
            "Arabic" => 0x0002,     // SYMBOL_CHARSET  
            "Cyrillic" => 0x0004,   // SHIFTJIS_CHARSET
            "Chinese" => 0x0005,     // HANGEUL_CHARSET
            _ => 0x0000             // DEFAULT_CHARSET
        };
    };
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: All properties properly categorized and exposed
- **Custom Editors**: Specialized editors for font and color properties
- **Serialization**: Design-time settings saved to designer files

### Property Categories

- **Data**: Core font selection properties (`Font`, `Color`)
- **Behavior**: Control behavior (`ShowColor`, `ShowEffects`, `ShowApply`)
- **Appearance**: Visual customization (`Title`, `Icon`, `ShowIcon`, `DisplayExtendedColorsButton`)

## Performance Considerations

- **Lazy Color Button**: Enhanced color button created only when needed
- **Memory Management**: Proper cleanup of embedded controls
- **Event Handling**: Optimized message routing for responsive UI
- **DPI Scaling**: Automatic scaling prevents layout issues

## Common Issues and Solutions

### Color Button Not Appearing

**Issue**: Extended color button not visible despite enabling `DisplayExtendedColorsButton`  
**Solution**: Ensures `ShowColor` is enabled (automatically handled by setter)

### Font Compatibility Warnings

**Issue**: Printer compatibility information not showing  
**Solution**: Enable `DisplayIsPrinterFontDescription` and ensure printer fonts are available

### Performance with Many Fonts

**Issue**: Slow font enumeration on systems with many fonts  
**Solution**: Font dialog handles this internally; consider caching common fonts

### Theme Inconsistencies

**Issue**: Dialog doesn't match application theme  
**Solution**: Ensure global Krypton palette is properly initialized

## Migration from Standard FontDialog

### Direct Replacement

```csharp
// Old code
using FontDialog = System.Windows.Forms.FontDialog;
var dialog = new FontDialog();

// New code
var dialog = new KryptonFontDialog();
```

### Enhanced Features

```csharp
// Standard FontDialog (basic)
var standardDialog = new FontDialog();

// KryptonFontDialog (enhanced)
var kryptonDialog = new KryptonFontDialog
{
    Title = "Enhanced Font Selection",
    Icon = applicationIcon,
    ShowIcon = true,
    DisplayExtendedColorsButton = true,  // Enhanced color selection
    DisplayIsPrinterFontDescription = true  // Printer compatibility info
};
```

## Real-World Integration Examples

### Text Editor Font Panel

```csharp
public partial class TextEditorForm : Form
{
    private void ShowFontDialog()
    {
        var dialog = new KryptonFontDialog
        {
            Title = "Font Settings",
            Font = textEditor.SelectionFont ?? textEditor.Font,
            Color = textEditor.SelectionColor,
            DisplayExtendedColorsButton = true,
            ShowEffects = true,
            ShowApply = true
        };

        // Live preview on Apply
        dialog.Apply += (sender, e) =>
        {
            PreviewFont(dialog.Font, dialog.Color);
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            ApplyFont(dialog.Font, dialog.Color);
        }
    }

    private void PreviewFont(Font font, Color color)
    {
        textEditor.SelectionFont = font;
        textEditor.SelectionColor = color;
        
        // Highlight preview
        var oldBackColor = textEditor.SelectionBackColor;
        textEditor.SelectionBackColor = Color.LightYellow;
        
        // Restore after short delay
        var timer = new System.Windows.Forms.Timer { Interval = 2000 };
        timer.Tick += (s, e) =>
        {
            textEditor.SelectionBackColor = oldBackColor;
            timer.Stop();
            timer.Dispose();
        };
        timer.Start();
    }
}
```

### Document Template Designer

```csharp
public class DocumentTemplateDesigner : Form
{
    public void ConfigureStyles()
    {
        var styles = new[]
        {
            ("Heading", FontStyle.Bold),
            ("Subheading", FontStyle.Regular),
            ("Body", FontStyle.Regular),
            ("Caption", FontStyle.Italic)
        };

        foreach (var (styleName, defaultStyle) in styles)
        {
            ConfigureStyle(styleName, defaultStyle);
        }
    }

    private void ConfigureStyle(string styleName, FontStyle defaultStyle)
    {
        var dialog = new KryptonFontDialog
        {
            Title = $"Configure {styleName} Style",
            Style = defaultStyle,
            DisplayIsPrinterFontDescription = true,
            DisplayExtendedColorsButton = true,
            ShowIcon = true,
            Icon = GetStyleIcon(styleName)
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            UpdateStyleTemplate(styleName, dialog.Font, dialog.Color);
        }
    }
}
```