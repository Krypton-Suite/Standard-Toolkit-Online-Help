# CommandLinkTextValues

## Overview

`CommandLinkTextValues` is a specialized values class that provides heading and description text properties for `KryptonCommandLinkButton` controls. It extends `CaptionValues` to support the two-line text layout characteristic of Windows command link buttons.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `Storage` → `CaptionValues` → `CommandLinkTextValues`

## Key Features

### Dual Text Support
- Primary heading text (large, bold)
- Secondary description text (smaller, explanatory)
- Independent font control for each
- Independent alignment control for each

### Default Styling
- Automatic default values
- Default arrow icon from Windows shell
- DPI-aware icon scaling
- Configurable default image usage

### Integration
- Seamless integration with `KryptonCommandLinkButton`
- Palette-aware rendering
- Automatic paint invalidation

---

## Constructor

### CommandLinkTextValues(NeedPaintHandler, GetDpiFactor)

Initializes a new instance with paint notification support.

```csharp
public CommandLinkTextValues(NeedPaintHandler needPaint, GetDpiFactor getDpiFactor)
```

**Parameters:**
- `needPaint` - Delegate for notifying paint requests
- `getDpiFactor` - Delegate for retrieving DPI scaling factor

**Default Values:**
- `Heading` = "Krypton Command Link Button"
- `Description` = "Krypton Command Link Button \"Note Text\""
- `HeadingFont` = `null` (uses control default)
- `DescriptionFont` = `null` (uses control default)
- `HeadingTextHAlignment` = `PaletteRelativeAlign.Near`
- `HeadingTextVAlignment` = `PaletteRelativeAlign.Center`
- `DescriptionTextHAlignment` = `PaletteRelativeAlign.Near`
- `DescriptionTextVAlignment` = `PaletteRelativeAlign.Far`
- `UseDefaultImage` = `true`

---

## Properties

### Text Properties

#### Heading
Gets or sets the primary heading text.

```csharp
[Category("CommandLink")]
[Description("The heading text for the command link button.")]
[Localizable(true)]
public string Heading { get; set; }
```

**Default:** `"Krypton Command Link Button"`

**Inherited from:** `CaptionValues`

**Example:**
```csharp
commandLinkButton.CommandLinkTextValues.Heading = "Create a new document";
```

---

#### Description
Gets or sets the secondary description text.

```csharp
[Category("CommandLink")]
[Description("The description text for the command link button.")]
[DefaultValue("Krypton Command Link Button \"Note Text\"")]
public override string Description { get; set; }
```

**Default:** `"Krypton Command Link Button \"Note Text\""`

**Example:**
```csharp
commandLinkButton.CommandLinkTextValues.Description = "Start with a blank document or choose from a template";
```

---

### Font Properties

#### HeadingFont
Gets or sets the font for the heading text.

```csharp
[Category("CommandLink")]
[Description("The heading text font for the command link button.")]
[DefaultValue(null)]
public Font? HeadingFont { get; set; }
```

**Default:** `null` (uses control's default heading font)

**Remarks:**
- When `null`, uses the default font for command link headings
- Typically larger and bolder than description font

**Example:**
```csharp
commandLinkButton.CommandLinkTextValues.HeadingFont = new Font("Segoe UI", 14F, FontStyle.Bold);
```

---

#### DescriptionFont
Gets or sets the font for the description text.

```csharp
[Category("CommandLink")]
[Description("The description text font for the command link button.")]
[DefaultValue(null)]
public Font? DescriptionFont { get; set; }
```

**Default:** `null` (uses control's default description font)

**Remarks:**
- When `null`, uses the default font for command link descriptions
- Typically smaller than heading font

**Example:**
```csharp
commandLinkButton.CommandLinkTextValues.DescriptionFont = new Font("Segoe UI", 9F, FontStyle.Regular);
```

---

### Alignment Properties

#### HeadingTextHAlignment
Gets or sets the horizontal alignment for heading text.

```csharp
[Category("CommandLink")]
[Description("The heading text horizontal alignment for the command link button.")]
[DefaultValue(PaletteRelativeAlign.Near)]
public PaletteRelativeAlign HeadingTextHAlignment { get; set; }
```

**Default:** `PaletteRelativeAlign.Near` (left-aligned)

**Available Values:**
- `Near` - Left-aligned (default)
- `Center` - Centered
- `Far` - Right-aligned
- `Inherit` - Inherit from parent

**Example:**
```csharp
commandLinkButton.CommandLinkTextValues.HeadingTextHAlignment = PaletteRelativeAlign.Center;
```

---

#### HeadingTextVAlignment
Gets or sets the vertical alignment for heading text.

```csharp
[Category("CommandLink")]
[Description("The heading text vertical alignment for the command link button.")]
[DefaultValue(PaletteRelativeAlign.Center)]
public PaletteRelativeAlign HeadingTextVAlignment { get; set; }
```

**Default:** `PaletteRelativeAlign.Center` (vertically centered)

---

#### DescriptionTextHAlignment
Gets or sets the horizontal alignment for description text.

```csharp
[Category("CommandLink")]
[Description("The description text horizontal alignment for the command link button.")]
[DefaultValue(PaletteRelativeAlign.Near)]
public PaletteRelativeAlign DescriptionTextHAlignment { get; set; }
```

**Default:** `PaletteRelativeAlign.Near` (left-aligned)

---

#### DescriptionTextVAlignment
Gets or sets the vertical alignment for description text.

```csharp
[Category("CommandLink")]
[Description("The description text vertical alignment for the command link button.")]
[DefaultValue(PaletteRelativeAlign.Far)]
public PaletteRelativeAlign DescriptionTextVAlignment { get; set; }
```

**Default:** `PaletteRelativeAlign.Far` (bottom-aligned)

**Remarks:**
- `Far` positions description below the heading
- Creates the typical command link two-line layout

---

### Image Properties

#### UseDefaultImage
Gets or sets whether to use the default command link arrow icon.

```csharp
[DefaultValue(true)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
[Description("Use the default image or not.")]
public bool UseDefaultImage { get; set; }
```

**Default:** `true`

**Remarks:**
- When `true`, displays the default Windows command link arrow icon
- Icon is extracted from shell32.dll (icon index 16805)
- Automatically scaled to 32x32 with DPI awareness
- Set to `false` to use custom images or no image

**Example:**
```csharp
// Use default arrow icon
commandLinkButton.CommandLinkTextValues.UseDefaultImage = true;

// Use custom icon
commandLinkButton.CommandLinkTextValues.UseDefaultImage = false;
commandLinkButton.UACShieldIcon.Image = myCustomIcon;
```

---

#### Image
Gets or sets the command link image.

```csharp
[Localizable(true)]
public Image? Image { get; set; }
```

**Inherited from:** `CaptionValues`

**Remarks:**
- Automatically set when `UseDefaultImage = true`
- Set directly when using custom images

---

### State Properties

#### IsDefault
Gets whether all values are in their default state.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public override bool IsDefault { get; }
```

**Returns:** `true` if all properties have default values; otherwise `false`.

**Remarks:**
- Used by the designer to determine if serialization is needed
- Checks all font, alignment, and text properties

---

## Methods

### ResetText()
Resets all text and font properties to their default values.

```csharp
public void ResetText()
```

**Resets:**
- `Heading` to default heading
- `Description` to default description
- `HeadingFont` to `null`
- `DescriptionFont` to `null`

**Example:**
```csharp
commandLinkButton.CommandLinkTextValues.ResetText();
```

---

### ResetDescription()
Resets the description text to its default value.

```csharp
public new void ResetDescription()
```

---

### ResetHeadingFont()
Resets the heading font to its default value.

```csharp
public void ResetHeadingFont()
```

---

### ResetDescriptionFont()
Resets the description font to its default value.

```csharp
public void ResetDescriptionFont()
```

---

### ResetHeadingTextHAlignment()
Resets the heading horizontal alignment to its default value.

```csharp
public void ResetHeadingTextHAlignment()
```

---

### ResetHeadingTextVAlignment()
Resets the heading vertical alignment to its default value.

```csharp
public void ResetHeadingTextVAlignment()
```

---

### ResetDescriptionTextHAlignment()
Resets the description horizontal alignment to its default value.

```csharp
public void ResetDescriptionTextHAlignment()
```

---

### ResetDescriptionTextVAlignment()
Resets the description vertical alignment to its default value.

```csharp
public void ResetDescriptionTextVAlignment()
```

---

### ResetUseDefaultImage()
Resets the UseDefaultImage property to its default value.

```csharp
public void ResetUseDefaultImage()
```

---

### Serialization Methods

Each property has corresponding serialization helper methods:

```csharp
public bool ShouldSerializeDescription()
public bool ShouldSerializeHeadingFont()
public bool ShouldSerializeDescriptionFont()
public bool ShouldSerializeHeadingTextHAlignment()
public bool ShouldSerializeHeadingTextVAlignment()
public bool ShouldSerializeDescriptionTextHAlignment()
public bool ShouldSerializeDescriptionTextVAlignment()
public bool ShouldSerializeUseDefaultImage()
```

**Remarks:**
- Used by the designer/serializer
- Returns `true` if the property should be serialized
- Returns `false` if the property has its default value

---

## Usage Examples

### Basic Usage

```csharp
var commandLink = new KryptonCommandLinkButton();

// Set text values
commandLink.CommandLinkTextValues.Heading = "Open File";
commandLink.CommandLinkTextValues.Description = "Browse for and open an existing file";
```

---

### Custom Fonts

```csharp
var commandLink = new KryptonCommandLinkButton();

// Customize fonts
commandLink.CommandLinkTextValues.HeadingFont = new Font("Segoe UI", 14F, FontStyle.Bold);
commandLink.CommandLinkTextValues.DescriptionFont = new Font("Segoe UI", 9F, FontStyle.Regular);

commandLink.CommandLinkTextValues.Heading = "Custom Styled Button";
commandLink.CommandLinkTextValues.Description = "With custom fonts for heading and description";
```

---

### Custom Alignment

```csharp
var commandLink = new KryptonCommandLinkButton();

// Center-align both texts
commandLink.CommandLinkTextValues.HeadingTextHAlignment = PaletteRelativeAlign.Center;
commandLink.CommandLinkTextValues.DescriptionTextHAlignment = PaletteRelativeAlign.Center;

commandLink.CommandLinkTextValues.Heading = "Centered Heading";
commandLink.CommandLinkTextValues.Description = "Centered description text";
```

---

### No Default Icon

```csharp
var commandLink = new KryptonCommandLinkButton();

// Disable default icon
commandLink.CommandLinkTextValues.UseDefaultImage = false;

// Optionally set custom icon
commandLink.UACShieldIcon.Image = SystemIcons.Information.ToBitmap();

commandLink.CommandLinkTextValues.Heading = "Information";
commandLink.CommandLinkTextValues.Description = "View important information about this feature";
```

---

### Multiline Description

```csharp
var commandLink = new KryptonCommandLinkButton
{
    Size = new Size(400, 90) // Taller to accommodate multiple lines
};

commandLink.CommandLinkTextValues.Heading = "Advanced Options";
commandLink.CommandLinkTextValues.Description = 
    "Configure advanced settings including network preferences, " +
    "security options, and system integration features.";
```

---

### Localized Text

```csharp
public class LocalizedCommandLink : KryptonCommandLinkButton
{
    public LocalizedCommandLink()
    {
        // Set localized defaults
        CommandLinkTextValues.Heading = Resources.DefaultHeading;
        CommandLinkTextValues.Description = Resources.DefaultDescription;
    }
    
    public void SetLocalizedText(string headingKey, string descriptionKey)
    {
        CommandLinkTextValues.Heading = Resources.ResourceManager.GetString(headingKey);
        CommandLinkTextValues.Description = Resources.ResourceManager.GetString(descriptionKey);
    }
}

// Usage:
var button = new LocalizedCommandLink();
button.SetLocalizedText("CreateDocument_Heading", "CreateDocument_Description");
```

---

### Dynamic Text Updates

```csharp
private void UpdateCommandLinkState()
{
    bool hasUnsavedChanges = CheckForUnsavedChanges();
    
    if (hasUnsavedChanges)
    {
        saveButton.CommandLinkTextValues.Heading = "Save Changes";
        saveButton.CommandLinkTextValues.Description = 
            "You have unsaved changes. Save them before continuing.";
        saveButton.Enabled = true;
    }
    else
    {
        saveButton.CommandLinkTextValues.Heading = "No Changes to Save";
        saveButton.CommandLinkTextValues.Description = 
            "All changes have been saved.";
        saveButton.Enabled = false;
    }
}
```

---

### Reset to Defaults

```csharp
private void ResetCommandLink()
{
    // Reset all text properties to defaults
    commandLinkButton.CommandLinkTextValues.ResetText();
    
    // Or reset individual properties
    commandLinkButton.CommandLinkTextValues.ResetHeadingFont();
    commandLinkButton.CommandLinkTextValues.ResetDescriptionFont();
    commandLinkButton.CommandLinkTextValues.ResetUseDefaultImage();
}
```

---

### DPI-Aware Styling

```csharp
public class DpiAwareCommandLink : KryptonCommandLinkButton
{
    protected override void OnDpiChangedAfterParent(EventArgs e)
    {
        base.OnDpiChangedAfterParent(e);
        
        // Adjust fonts based on new DPI
        float scaleFactor = DeviceDpi / 96f;
        
        if (CommandLinkTextValues.HeadingFont != null)
        {
            var newSize = CommandLinkTextValues.HeadingFont.Size * scaleFactor;
            CommandLinkTextValues.HeadingFont = new Font(
                CommandLinkTextValues.HeadingFont.FontFamily,
                newSize,
                CommandLinkTextValues.HeadingFont.Style);
        }
        
        // Default image is automatically DPI-aware
    }
}
```

---

### Builder Pattern

```csharp
public static class CommandLinkBuilder
{
    public static KryptonCommandLinkButton Create(
        string heading,
        string description,
        EventHandler clickHandler = null,
        bool useDefaultIcon = true)
    {
        var button = new KryptonCommandLinkButton();
        
        button.CommandLinkTextValues.Heading = heading;
        button.CommandLinkTextValues.Description = description;
        button.CommandLinkTextValues.UseDefaultImage = useDefaultIcon;
        
        if (clickHandler != null)
        {
            button.Click += clickHandler;
        }
        
        return button;
    }
}

// Usage:
var button = CommandLinkBuilder.Create(
    "Export Data",
    "Export the current data to a CSV file",
    (s, e) => ExportToCsv(),
    useDefaultIcon: true);
```

---

## Design Considerations

### Text Guidelines

**Heading:**
- Keep it short (1-5 words)
- Use action verbs
- Capitalize first word only (sentence case)
- No ending punctuation

**Description:**
- Complete sentences with punctuation
- 1-2 sentences maximum
- Explain what happens or when to choose
- Don't just restate the heading

**Examples:**

✅ **Good:**
```csharp
Heading: "Create a new project"
Description: "Start with a blank project and add your own files."
```

❌ **Bad:**
```csharp
Heading: "New Project"  // Too terse
Description: "Create a new project."  // Just restates heading
```

---

### Font Sizing

**Recommended Sizes:**
- Heading: 12-14pt (typically Segoe UI Bold)
- Description: 9-11pt (typically Segoe UI Regular)
- Ratio: Heading should be ~1.3-1.5x description size

**DPI Considerations:**
- Fonts scale automatically with system DPI
- Default image scales automatically
- Custom images may need manual scaling

---

### Alignment Best Practices

**Standard Layout:**
```csharp
HeadingTextHAlignment = Near;      // Left
HeadingTextVAlignment = Center;    // Vertically centered
DescriptionTextHAlignment = Near;  // Left (same as heading)
DescriptionTextVAlignment = Far;   // Below heading
```

**Center Layout:**
```csharp
// Both centered - good for single-column dialogs
HeadingTextHAlignment = Center;
DescriptionTextHAlignment = Center;
```

**Right-to-Left Languages:**
```csharp
// Automatically handled when RightToLeft = Yes
// Near becomes right-aligned
// Far becomes left-aligned
```

---

### Performance

**Invalidation:**
- Property changes automatically trigger paint requests
- Multiple changes should be batched when possible

```csharp
// Less efficient - multiple repaints
button.CommandLinkTextValues.Heading = "New Heading";
button.CommandLinkTextValues.Description = "New Description";
button.CommandLinkTextValues.HeadingFont = newFont;

// More efficient - suspend layout
button.SuspendLayout();
button.CommandLinkTextValues.Heading = "New Heading";
button.CommandLinkTextValues.Description = "New Description";
button.CommandLinkTextValues.HeadingFont = newFont;
button.ResumeLayout();
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** Krypton.Toolkit core components

---

## See Also

- [KryptonCommandLinkButton](KryptonCommandLinkButton.md) - Parent control
- [CaptionValues](CaptionValues.md) - Base class
- [CommandLinkImageValues](CommandLinkImageValues.md) - Image values for command links
- [PaletteRelativeAlign](../Enumerations/PaletteRelativeAlign.md) - Alignment enumeration