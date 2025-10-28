# CaptionValues

## Overview

`CaptionValues` provides storage for caption text and images used in group boxes, panels, and other controls that display a heading with an optional description. It serves as the base class for more specialized caption value classes like `CommandLinkTextValues`.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `Storage` → `HeaderValuesBase` → `CaptionValues`

## Key Features

### Caption Storage
- Primary heading text
- Optional description text
- Optional caption image
- Automatic paint invalidation

### Base Class
- Provides foundation for specialized caption classes
- Consistent interface for caption management
- Localizable text properties

### Integration
- Used by `KryptonGroupBox`
- Used by `KryptonHeaderGroup`
- Extended by `CommandLinkTextValues`

---

## Constructor

### CaptionValues(NeedPaintHandler, GetDpiFactor)

Initializes a new instance of the CaptionValues class.

```csharp
public CaptionValues(NeedPaintHandler needPaint, GetDpiFactor getDpiFactor)
```

**Parameters:**
- `needPaint` - Delegate for notifying paint requests
- `getDpiFactor` - Delegate for retrieving DPI scaling factor

**Default Values:**
- `Heading` = `"Caption"`
- `Description` = `""`
- `Image` = `null`

---

## Properties

### Heading
Gets or sets the caption heading text.

```csharp
[Category("Visuals")]
[Description("Caption heading text.")]
[Localizable(true)]
public string Heading { get; set; }
```

**Default:** `"Caption"`

**Inherited from:** `HeaderValuesBase`

**Remarks:**
- Primary text displayed in the caption
- Supports mnemonics (e.g., "&File")
- Automatically triggers repaint when changed

**Example:**
```csharp
kryptonGroupBox1.CaptionValues.Heading = "Customer Information";
```

---

### Description
Gets or sets the caption description text.

```csharp
[DefaultValue("")]
public override string Description { get; set; }
```

**Default:** `""` (empty string)

**Remarks:**
- Secondary descriptive text
- Optional - can be empty
- Typically displayed below or alongside heading

**Example:**
```csharp
kryptonGroupBox1.CaptionValues.Heading = "Settings";
kryptonGroupBox1.CaptionValues.Description = "Configure application preferences";
```

---

### Image
Gets or sets the caption image.

```csharp
[Category("Visuals")]
[Description("Caption image.")]
[Localizable(true)]
public Image? Image { get; set; }
```

**Default:** `null`

**Inherited from:** `HeaderValuesBase`

**Remarks:**
- Optional icon/image displayed with caption
- Typically 16x16 or 32x32 pixels
- Should be DPI-aware for high-DPI displays

**Example:**
```csharp
kryptonGroupBox1.CaptionValues.Image = Properties.Resources.SettingsIcon;
```

---

### IsDefault
Gets whether all values are in their default state.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public override bool IsDefault { get; }
```

**Returns:** `true` if all properties have default values; otherwise `false`.

**Remarks:**
- Used by designer for serialization decisions
- Checks heading, description, and image

---

## Methods

### GetHeadingDefault()
Gets the default heading value.

```csharp
protected override string GetHeadingDefault()
```

**Returns:** `"Caption"`

**Remarks:**
- Can be overridden in derived classes
- Used for reset operations

---

### GetDescriptionDefault()
Gets the default description value.

```csharp
protected override string GetDescriptionDefault()
```

**Returns:** `""` (empty string)

**Remarks:**
- Can be overridden in derived classes
- Used for reset operations

---

### GetImageDefault()
Gets the default image value.

```csharp
protected override Image? GetImageDefault()
```

**Returns:** `null`

**Remarks:**
- Can be overridden in derived classes
- Used for reset operations

---

## Usage Examples

### Basic Caption

```csharp
var groupBox = new KryptonGroupBox();

groupBox.CaptionValues.Heading = "User Details";
groupBox.CaptionValues.Description = "Enter your personal information";
```

---

### Caption with Image

```csharp
var groupBox = new KryptonGroupBox();

groupBox.CaptionValues.Heading = "Security Settings";
groupBox.CaptionValues.Description = "Configure security options";
groupBox.CaptionValues.Image = Properties.Resources.LockIcon;
```

---

### Localizable Captions

```csharp
// In design time or code
groupBox1.CaptionValues.Heading = Resources.SettingsHeading;
groupBox1.CaptionValues.Description = Resources.SettingsDescription;

// Resources.resx:
// SettingsHeading: "Settings" (English), "Einstellungen" (German)
// SettingsDescription: "Configure options" (English), "Optionen konfigurieren" (German)
```

---

### Dynamic Caption Updates

```csharp
private void UpdateCaption(string section)
{
    switch (section)
    {
        case "Personal":
            groupBox.CaptionValues.Heading = "Personal Information";
            groupBox.CaptionValues.Description = "Name, email, and contact details";
            groupBox.CaptionValues.Image = Resources.UserIcon;
            break;
            
        case "Preferences":
            groupBox.CaptionValues.Heading = "Preferences";
            groupBox.CaptionValues.Description = "Application settings and options";
            groupBox.CaptionValues.Image = Resources.SettingsIcon;
            break;
            
        case "Security":
            groupBox.CaptionValues.Heading = "Security";
            groupBox.CaptionValues.Description = "Password and privacy settings";
            groupBox.CaptionValues.Image = Resources.LockIcon;
            break;
    }
}
```

---

### Mnemonic Support

```csharp
var groupBox1 = new KryptonGroupBox();
groupBox1.CaptionValues.Heading = "&Personal";

var groupBox2 = new KryptonGroupBox();
groupBox2.CaptionValues.Heading = "&Security";

// Alt+P focuses first control in groupBox1
// Alt+S focuses first control in groupBox2
```

---

### Caption Builder Helper

```csharp
public static class CaptionBuilder
{
    public static void SetCaption(
        CaptionValues caption,
        string heading,
        string description = "",
        Image icon = null)
    {
        caption.Heading = heading;
        caption.Description = description;
        caption.Image = icon;
    }
}

// Usage:
CaptionBuilder.SetCaption(
    groupBox.CaptionValues,
    "Database Settings",
    "Configure database connection parameters",
    Resources.DatabaseIcon);
```

---

### Multi-Language Captions

```csharp
public class LocalizedCaptions
{
    private CultureInfo currentCulture;
    private Dictionary<string, (string heading, string description)> captions;
    
    public LocalizedCaptions()
    {
        currentCulture = CultureInfo.CurrentUICulture;
        LoadCaptions();
    }
    
    private void LoadCaptions()
    {
        captions = new Dictionary<string, (string, string)>
        {
            ["en-US"] = ("Settings", "Configure application options"),
            ["es-ES"] = ("Configuración", "Configurar opciones de aplicación"),
            ["fr-FR"] = ("Paramètres", "Configurer les options de l'application"),
            ["de-DE"] = ("Einstellungen", "Anwendungsoptionen konfigurieren")
        };
    }
    
    public void ApplyCaption(CaptionValues caption, string key)
    {
        var culture = currentCulture.Name;
        if (captions.ContainsKey(culture))
        {
            var (heading, description) = captions[culture];
            caption.Heading = heading;
            caption.Description = description;
        }
    }
}
```

---

### Validation Feedback in Captions

```csharp
private void UpdateCaptionForValidation(bool isValid)
{
    if (isValid)
    {
        groupBox.CaptionValues.Heading = "Personal Information";
        groupBox.CaptionValues.Description = "All fields are valid";
        groupBox.CaptionValues.Image = Resources.CheckIcon;
    }
    else
    {
        groupBox.CaptionValues.Heading = "Personal Information (Invalid)";
        groupBox.CaptionValues.Description = "Please correct the errors below";
        groupBox.CaptionValues.Image = Resources.ErrorIcon;
    }
}
```

---

### Wizard Step Captions

```csharp
public class WizardStep
{
    private KryptonPanel panel;
    
    public WizardStep(string heading, string description, Image icon = null)
    {
        panel = new KryptonPanel();
        
        // If the panel has caption values, set them
        // (This is illustrative - actual implementation depends on control)
        SetCaption(heading, description, icon);
    }
    
    private void SetCaption(string heading, string description, Image icon)
    {
        // Set up header
        var headerGroup = new KryptonHeaderGroup { Dock = DockStyle.Top };
        headerGroup.CaptionValues.Heading = heading;
        headerGroup.CaptionValues.Description = description;
        headerGroup.CaptionValues.Image = icon;
        
        panel.Controls.Add(headerGroup);
    }
}

// Usage:
var step1 = new WizardStep(
    "Welcome",
    "This wizard will guide you through the setup process",
    Resources.WelcomeIcon);

var step2 = new WizardStep(
    "Configuration",
    "Select your preferred options",
    Resources.ConfigIcon);
```

---

### Status-Based Captions

```csharp
public enum ProcessStatus
{
    NotStarted,
    InProgress,
    Completed,
    Error
}

private void UpdateStatusCaption(ProcessStatus status)
{
    var (heading, description, icon) = status switch
    {
        ProcessStatus.NotStarted => (
            "Ready to Start",
            "Click the button below to begin",
            Resources.InfoIcon),
            
        ProcessStatus.InProgress => (
            "Processing...",
            "Please wait while the operation completes",
            Resources.SpinnerIcon),
            
        ProcessStatus.Completed => (
            "Completed Successfully",
            "All operations finished without errors",
            Resources.SuccessIcon),
            
        ProcessStatus.Error => (
            "Error Occurred",
            "An error prevented completion",
            Resources.ErrorIcon),
            
        _ => ("Unknown", "", null)
    };
    
    groupBox.CaptionValues.Heading = heading;
    groupBox.CaptionValues.Description = description;
    groupBox.CaptionValues.Image = icon;
}
```

---

### Collapsible Section Captions

```csharp
public class CollapsibleSection
{
    private KryptonHeaderGroup headerGroup;
    private bool isExpanded = true;
    
    public CollapsibleSection(string heading, string description)
    {
        headerGroup = new KryptonHeaderGroup();
        headerGroup.CaptionValues.Heading = heading;
        headerGroup.CaptionValues.Description = description;
        
        UpdateIcon();
        
        headerGroup.Click += (s, e) => Toggle();
    }
    
    private void Toggle()
    {
        isExpanded = !isExpanded;
        headerGroup.Panel.Visible = isExpanded;
        UpdateIcon();
    }
    
    private void UpdateIcon()
    {
        headerGroup.CaptionValues.Image = isExpanded
            ? Resources.CollapseIcon
            : Resources.ExpandIcon;
    }
}
```

---

## Design Considerations

### Text Guidelines

**Heading:**
- Keep it short and descriptive
- Use title case or sentence case consistently
- Consider mnemonics for keyboard accessibility
- Typically 1-5 words

**Description:**
- Optional clarifying text
- Complete sentences with punctuation
- Explain the purpose or contents
- Keep under 100 characters when possible

**Examples:**

✅ **Good:**
```csharp
Heading: "Network Settings"
Description: "Configure network connections and proxy settings"
```

❌ **Bad:**
```csharp
Heading: "Network"  // Too terse
Description: "Network settings"  // Redundant with heading
```

---

### Image Guidelines

**Size:**
- Standard: 16x16 or 32x32 pixels
- Match the size used throughout your application
- Consider DPI scaling for high-resolution displays

**Style:**
- Use consistent icon style across application
- Match the theme and color scheme
- Ensure good contrast with background

**Format:**
- PNG with transparency preferred
- Consider providing multiple sizes
- Use vector icons when possible (scale better)

---

### Inheritance Hierarchy

```
Storage
  └─ HeaderValuesBase
      └─ CaptionValues
          └─ CommandLinkTextValues (specialized)
```

**Derived Classes Can:**
- Override default values
- Add specialized properties
- Customize behavior

**Example:**
```csharp
public class CustomCaptionValues : CaptionValues
{
    public CustomCaptionValues(NeedPaintHandler needPaint, GetDpiFactor dpi)
        : base(needPaint, dpi)
    {
    }
    
    protected override string GetHeadingDefault() => "Custom Default";
    
    protected override string GetDescriptionDefault() => "Custom description";
}
```

---

### Performance

**Paint Invalidation:**
- Property changes automatically trigger repaints
- Use `SuspendLayout`/`ResumeLayout` for multiple changes

```csharp
// Less efficient - multiple repaints
groupBox.CaptionValues.Heading = "New Heading";
groupBox.CaptionValues.Description = "New Description";
groupBox.CaptionValues.Image = newIcon;

// More efficient - single repaint
groupBox.SuspendLayout();
groupBox.CaptionValues.Heading = "New Heading";
groupBox.CaptionValues.Description = "New Description";
groupBox.CaptionValues.Image = newIcon;
groupBox.ResumeLayout();
```

---

### Localization

**Resource Files:**
```xml
<!-- Resources.resx -->
<data name="SettingsCaption_Heading" xml:space="preserve">
  <value>Settings</value>
</data>
<data name="SettingsCaption_Description" xml:space="preserve">
  <value>Configure application preferences</value>
</data>

<!-- Resources.de.resx -->
<data name="SettingsCaption_Heading" xml:space="preserve">
  <value>Einstellungen</value>
</data>
<data name="SettingsCaption_Description" xml:space="preserve">
  <value>Anwendungseinstellungen konfigurieren</value>
</data>
```

**Usage:**
```csharp
groupBox.CaptionValues.Heading = Resources.SettingsCaption_Heading;
groupBox.CaptionValues.Description = Resources.SettingsCaption_Description;
```

---

## Controls Using CaptionValues

### KryptonGroupBox
```csharp
kryptonGroupBox1.CaptionValues.Heading = "Group Title";
```

### KryptonHeaderGroup
```csharp
kryptonHeaderGroup1.ValuesPrimary.Heading = "Primary Header";
kryptonHeaderGroup1.ValuesSecondary.Heading = "Secondary Header";
```

### Custom Controls
```csharp
public class CustomPanel : KryptonPanel
{
    public CaptionValues CaptionValues { get; }
    
    public CustomPanel()
    {
        CaptionValues = new CaptionValues(OnNeedPaint, GetDpiFactor);
    }
}
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** Krypton.Toolkit core components

---

## See Also

- [CommandLinkTextValues](CommandLinkTextValues.md) - Derived class
- [KryptonGroupBox](KryptonGroupBox.md) - Control using CaptionValues
- [KryptonHeaderGroup](KryptonHeaderGroup.md) - Control using CaptionValues