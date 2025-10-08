# KryptonPoweredByButton

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Class Hierarchy](#class-hierarchy)
4. [API Reference](#api-reference)
   - [KryptonPoweredByButton](#kryptonpoweredbybutton)
   - [PoweredByButtonValues](#poweredbybuttonvalues)
   - [ToolkitSupportType Enumeration](#toolkitsupporttype-enumeration)
5. [Usage Examples](#usage-examples)
6. [Designer Support](#designer-support)
7. [Behavior and Events](#behavior-and-events)
8. [Best Practices](#best-practices)
9. [Related Components](#related-components)

---

## Overview

The `KryptonPoweredByButton` is a specialized button control that provides a standardized way to display Krypton Toolkit branding in your applications. It extends `KryptonButton` and automatically displays version information about the Krypton Toolkit components when clicked.

### Purpose

- Display "Powered by Krypton" branding in applications
- Provide users with toolkit version information
- Show which support type (Stable, Canary, Nightly, LTS) is being used
- Optional access to changelog and readme documentation

### Namespace

```csharp
Krypton.Toolkit
```

### Assembly

Krypton.Toolkit.dll

---

## Features

### Core Features

1. **Pre-configured Branding**: Automatically displays "Powered By Krypton" text and appropriate logo
2. **Version Information Dialog**: Shows detailed version information for all Krypton Toolkit components when clicked
3. **Support Type Selection**: Displays different branding based on toolkit support type (Stable, Canary, Nightly, LTS)
4. **Optional Documentation Links**: Can show buttons linking to changelog and readme
5. **Designer Integration**: Full Visual Studio Designer support with custom property editors
6. **Automatic Icon Selection**: Icons automatically update based on selected support type

### Visual Features

- Default size: 153 x 25 pixels
- Branded with Krypton logo image
- Supports all `KryptonButton` styling features
- Automatic icon switching based on support type

---

## Class Hierarchy

```
System.Object
  └─ System.ComponentModel.Component
      └─ System.Windows.Forms.Control
          └─ Krypton.Toolkit.VisualControl
              └─ Krypton.Toolkit.KryptonButton
                  └─ Krypton.Toolkit.KryptonPoweredByButton
```

---

## API Reference

### KryptonPoweredByButton

#### Class Declaration

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(KryptonButton), "ToolboxBitmaps.KryptonButton.bmp")]
[DesignerCategory(@"code")]
[Description(@"A button that displays the Krypton Toolkit branding and provides information about the toolkit version.")]
[Designer(typeof(KryptonButtonDesigner))]
public class KryptonPoweredByButton : KryptonButton
```

#### Constructor

```csharp
public KryptonPoweredByButton()
```

**Description**: Initializes a new instance of the `KryptonPoweredByButton` class with default settings.

**Default Values**:
- Text: "Powered By Krypton" (localized)
- Image: Krypton Stable button icon
- Size: 153 x 25 pixels

**Example**:
```csharp
var poweredByButton = new KryptonPoweredByButton();
Controls.Add(poweredByButton);
```

#### Properties

##### ButtonValues

```csharp
[Category(@"Visuals")]
[Description(@"Gets or sets the values for the Powered By button.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PoweredByButtonValues ButtonValues { get; set; }
```

**Description**: Gets or sets the configuration values for the powered by button, including support type and optional features.

**Returns**: `PoweredByButtonValues` - The button configuration values.

**Remarks**:
- Automatically instantiated if accessed before being set
- Raises property changed events when modified
- Controls icon display and dialog features

**Example**:
```csharp
poweredByButton.ButtonValues.ToolkitSupportType = ToolkitSupportType.Canary;
poweredByButton.ButtonValues.ShowChangeLogButton = true;
poweredByButton.ButtonValues.ShowReadmeButton = true;
```

##### Text (Override)

```csharp
[AllowNull]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public override string Text { get; set; }
```

**Description**: Gets or sets the text displayed on the button. This property is hidden from the designer.

**Default Value**: "Powered By Krypton" (localized)

**Remarks**: 
- Hidden from designer to prevent user modification
- Text is managed internally by the control
- Value is localized through `KryptonManager.Strings`

#### Methods

##### ShouldSerializeButtonValues

```csharp
private bool ShouldSerializeButtonValues()
```

**Description**: Determines whether the `ButtonValues` property should be serialized by the designer.

**Returns**: `bool` - `true` if the `ButtonValues` have been modified from default; otherwise, `false`.

**Remarks**: Used by the Windows Forms Designer serialization system.

##### ResetButtonValues

```csharp
public void ResetButtonValues()
```

**Description**: Resets the `ButtonValues` property to its default state.

**Remarks**: 
- Resets support type to `Stable`
- Hides changelog and readme buttons
- Can be called from designer or code

**Example**:
```csharp
poweredByButton.ResetButtonValues();
```

#### Events

##### Click (Shadowed)

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public new event EventHandler Click
```

**Description**: Occurs when the button is clicked. This event is hidden from the designer and IntelliSense.

**Remarks**:
- Shadowed to discourage external handlers
- Internal click behavior shows version information dialog
- External handlers can still be added but are not recommended
- The base click event is still raised after showing the dialog

**Warning**: Adding custom click handlers may interfere with the built-in version information display.

#### Protected Methods

##### OnClick

```csharp
protected override void OnClick(EventArgs e)
```

**Description**: Raises the Click event and displays the toolkit version information dialog.

**Parameters**:
- `e` (`EventArgs`): An EventArgs that contains the event data.

**Behavior**:
1. Creates and displays `VisualToolkitBinaryInformationForm`
2. Passes support type, changelog visibility, and readme visibility to the form
3. Shows the form as a modal dialog
4. Calls base implementation to raise Click event

---

### PoweredByButtonValues

#### Class Declaration

```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public class PoweredByButtonValues : GlobalId, INotifyPropertyChanged
```

**Description**: Encapsulates configuration settings for the `KryptonPoweredByButton` control.

#### Constructor

```csharp
public PoweredByButtonValues(KryptonPoweredByButton poweredByButton)
```

**Parameters**:
- `poweredByButton` (`KryptonPoweredByButton`): The parent button control.

**Description**: Initializes a new instance with a reference to the parent button and resets to default values.

#### Properties

##### ShowChangeLogButton

```csharp
[Category("Visuals")]
[Description("Gets or sets a value indicating whether to show the change log button.")]
[DefaultValue(false)]
[Browsable(true)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public bool ShowChangeLogButton { get; set; }
```

**Description**: Gets or sets whether the changelog button is displayed in the version information dialog.

**Default Value**: `false`

**Remarks**: When `true`, the version dialog will display a button that opens the appropriate changelog URL based on the `ToolkitSupportType`.

**Changelog URLs by Type**:
- **Stable**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/Documents/Changelog/Changelog.md`
- **Canary**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/canary/Documents/Changelog/Changelog.md`
- **Nightly**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/alpha/Documents/Changelog/Changelog.md`
- **LongTermSupport**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/V85-LTS/Documents/Help/Changelog.md`

##### ShowReadmeButton

```csharp
[Category("Visuals")]
[Description("Gets or sets a value indicating whether to show the readme button.")]
[DefaultValue(false)]
[Browsable(true)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public bool ShowReadmeButton { get; set; }
```

**Description**: Gets or sets whether the readme button is displayed in the version information dialog.

**Default Value**: `false`

**Remarks**: When `true`, the version dialog will display a button that opens the appropriate readme URL based on the `ToolkitSupportType`.

**Readme URLs by Type**:
- **Stable**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/README.md`
- **Canary**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/canary/README.md`
- **Nightly**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/alpha/README.md`
- **LongTermSupport**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/V85-LTS/README.md`

##### ToolkitSupportType

```csharp
[Category("Visuals")]
[Description("Gets or sets the type of the toolkit.")]
[DefaultValue(ToolkitSupportType.Stable)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public ToolkitSupportType ToolkitSupportType { get; set; }
```

**Description**: Gets or sets the support type, which determines the icon displayed and the documentation URLs.

**Default Value**: `ToolkitSupportType.Stable`

**Remarks**: 
- Automatically updates the button icon when changed
- Affects the dialog title and icon
- Determines which documentation URLs are used

**Icon Mapping**:
- **Canary**: `ButtonImageResources.Krypton_Canary_Button`
- **Nightly**: `ButtonImageResources.Krypton_Nightly_Button`
- **LongTermSupport**: `ButtonImageResources.Krypton_Long_Term_Stable_Button`
- **Stable**: `ButtonImageResources.Krypton_Stable_Button`

##### IsDefault

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool IsDefault { get; }
```

**Description**: Gets a value indicating whether all properties are at their default values.

**Returns**: `bool` - `true` if all properties are default; otherwise, `false`.

**Default Condition**:
- `ShowChangeLogButton == false`
- `ShowReadmeButton == false`
- `ToolkitSupportType == ToolkitSupportType.Stable`

#### Methods

##### Reset

```csharp
public void Reset()
```

**Description**: Resets all properties to their default values.

**Behavior**:
- Sets `ShowChangeLogButton` to `false`
- Sets `ShowReadmeButton` to `false`
- Sets `ToolkitSupportType` to `Stable`

##### ToString

```csharp
public override string ToString()
```

**Description**: Returns a string representation of the current state.

**Returns**: 
- `"Modified"` if any properties differ from defaults
- Empty string if all properties are at default values

#### Events

##### PropertyChanged

```csharp
public event PropertyChangedEventHandler? PropertyChanged
```

**Description**: Occurs when a property value changes.

**Remarks**: Implements `INotifyPropertyChanged` interface for data binding support.

---

### ToolkitSupportType Enumeration

#### Enumeration Declaration

```csharp
public enum ToolkitSupportType
```

**Description**: Specifies the support type and release channel of the Krypton Toolkit being used.

#### Members

##### Canary

```csharp
Canary = 0
```

**Description**: The canary version is the latest development version, which may contain new features and bug fixes that are not yet available in the stable version.

**Characteristics**:
- Bleeding-edge features
- Highest risk of instability
- Most frequent updates
- Used for early testing

##### Nightly

```csharp
Nightly = 1
```

**Description**: The nightly version is a pre-release version that is built every night and may contain new features and bug fixes that are not yet available in the stable version.

**Characteristics**:
- Daily builds
- Pre-release quality
- Contains recent changes
- Suitable for testing environments

##### Stable

```csharp
Stable = 2
```

**Description**: The stable version is a tested and stable version that is suitable for production use.

**Characteristics**:
- Production-ready
- Thoroughly tested
- Recommended for most applications
- Regular update cycle

##### LongTermSupport

```csharp
LongTermSupport = 3
```

**Description**: The long-term support version is a version that is supported for an extended period of time, typically with security updates and critical bug fixes.

**Characteristics**:
- Extended support period
- Security updates and critical fixes
- Minimal feature changes
- Ideal for enterprise applications

---

## Usage Examples

### Basic Usage

#### Example 1: Simple Implementation

```csharp
using Krypton.Toolkit;

public partial class MainForm : KryptonForm
{
    public MainForm()
    {
        InitializeComponent();
        
        // Create and configure the button
        var poweredByButton = new KryptonPoweredByButton
        {
            Location = new Point(10, 10)
        };
        
        Controls.Add(poweredByButton);
    }
}
```

#### Example 2: Configuration with Properties

```csharp
var poweredByButton = new KryptonPoweredByButton
{
    Location = new Point(10, 10)
};

// Configure the button values
poweredByButton.ButtonValues.ToolkitSupportType = ToolkitSupportType.Stable;
poweredByButton.ButtonValues.ShowChangeLogButton = true;
poweredByButton.ButtonValues.ShowReadmeButton = true;

Controls.Add(poweredByButton);
```

#### Example 3: Canary Build with Documentation Links

```csharp
var poweredByButton = new KryptonPoweredByButton();

// Configure for canary builds
poweredByButton.ButtonValues.ToolkitSupportType = ToolkitSupportType.Canary;
poweredByButton.ButtonValues.ShowChangeLogButton = true;
poweredByButton.ButtonValues.ShowReadmeButton = false;

// Position in about dialog or status bar
poweredByButton.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
poweredByButton.Location = new Point(
    ClientSize.Width - poweredByButton.Width - 10,
    ClientSize.Height - poweredByButton.Height - 10
);

Controls.Add(poweredByButton);
```

### Advanced Usage

#### Example 4: Dynamic Support Type Based on Build Configuration

```csharp
public partial class AboutDialog : KryptonForm
{
    private KryptonPoweredByButton _poweredByButton;
    
    public AboutDialog()
    {
        InitializeComponent();
        
        _poweredByButton = new KryptonPoweredByButton
        {
            Location = new Point(10, 200)
        };
        
        // Determine support type from your build configuration
        ToolkitSupportType supportType = DetermineSupportType();
        
        _poweredByButton.ButtonValues.ToolkitSupportType = supportType;
        _poweredByButton.ButtonValues.ShowChangeLogButton = true;
        _poweredByButton.ButtonValues.ShowReadmeButton = true;
        
        Controls.Add(_poweredByButton);
    }
    
    private ToolkitSupportType DetermineSupportType()
    {
        #if DEBUG
            return ToolkitSupportType.Nightly;
        #elif CANARY
            return ToolkitSupportType.Canary;
        #elif LTS
            return ToolkitSupportType.LongTermSupport;
        #else
            return ToolkitSupportType.Stable;
        #endif
    }
}
```

#### Example 5: Customizing Visual Appearance

```csharp
var poweredByButton = new KryptonPoweredByButton();

// The button inherits all KryptonButton styling capabilities
poweredByButton.StateCommon.Back.Color1 = Color.White;
poweredByButton.StateCommon.Back.Color2 = Color.LightBlue;
poweredByButton.StateCommon.Border.DrawBorders = PaletteDrawBorders.All;
poweredByButton.StateCommon.Border.Rounding = 5;

// Configure support type and features
poweredByButton.ButtonValues.ToolkitSupportType = ToolkitSupportType.Stable;
poweredByButton.ButtonValues.ShowChangeLogButton = true;

Controls.Add(poweredByButton);
```

#### Example 6: Handling Property Changes

```csharp
var poweredByButton = new KryptonPoweredByButton();

// Subscribe to property changes
poweredByButton.ButtonValues.PropertyChanged += (sender, e) =>
{
    Console.WriteLine($"Property changed: {e.PropertyName}");
    
    // Perform custom actions based on property changes
    if (e.PropertyName == nameof(PoweredByButtonValues.ToolkitSupportType))
    {
        UpdateApplicationTheme(poweredByButton.ButtonValues.ToolkitSupportType);
    }
};

Controls.Add(poweredByButton);
```

#### Example 7: Programmatically Resetting Configuration

```csharp
var poweredByButton = new KryptonPoweredByButton();

// Make some changes
poweredByButton.ButtonValues.ToolkitSupportType = ToolkitSupportType.Canary;
poweredByButton.ButtonValues.ShowChangeLogButton = true;
poweredByButton.ButtonValues.ShowReadmeButton = true;

// Later, reset to defaults
poweredByButton.ResetButtonValues();

// Now the button is back to Stable with no documentation buttons
Debug.Assert(poweredByButton.ButtonValues.IsDefault);
```

#### Example 8: Placement in Status Strip

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonPoweredByButton _poweredByButton;
    
    public MainForm()
    {
        InitializeComponent();
        
        _poweredByButton = new KryptonPoweredByButton
        {
            // Make it smaller for status bar
            Size = new Size(120, 20)
        };
        
        _poweredByButton.ButtonValues.ToolkitSupportType = ToolkitSupportType.Stable;
        _poweredByButton.ButtonValues.ShowChangeLogButton = false;
        _poweredByButton.ButtonValues.ShowReadmeButton = false;
        
        // Position in bottom-right corner
        _poweredByButton.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
        _poweredByButton.Location = new Point(
            ClientSize.Width - _poweredByButton.Width - 5,
            ClientSize.Height - _poweredByButton.Height - 5
        );
        
        Controls.Add(_poweredByButton);
        
        // Update position when form resizes
        Resize += (s, e) => UpdatePoweredByButtonPosition();
    }
    
    private void UpdatePoweredByButtonPosition()
    {
        _poweredByButton.Location = new Point(
            ClientSize.Width - _poweredByButton.Width - 5,
            ClientSize.Height - _poweredByButton.Height - 5
        );
    }
}
```

---

## Designer Support

### Using in Visual Studio Designer

1. **Adding the Control**:
   - Open the Visual Studio Toolbox
   - Locate `KryptonPoweredByButton` under the Krypton Toolkit section
   - Drag and drop onto your form

2. **Configuring Properties**:
   - Select the button in the designer
   - In the Properties window, expand the `ButtonValues` property
   - Set `ToolkitSupportType` to desired value
   - Toggle `ShowChangeLogButton` and `ShowReadmeButton` as needed

3. **Designer Serialization**:
   - Only non-default values are serialized
   - Use `ResetButtonValues()` method or right-click property in designer and select "Reset"

### Properties Visible in Designer

| Property Category | Property Name | Type | Default Value |
|------------------|---------------|------|---------------|
| Visuals | ButtonValues.ToolkitSupportType | ToolkitSupportType | Stable |
| Visuals | ButtonValues.ShowChangeLogButton | bool | false |
| Visuals | ButtonValues.ShowReadmeButton | bool | false |

### Hidden Properties

The following properties are intentionally hidden from the designer:

- `Text` - Managed internally by the control
- `Click` event - Marked as EditorBrowsable(Never)
- `ButtonValues` - Property itself is hidden; sub-properties are visible

---

## Behavior and Events

### Click Behavior

When the button is clicked, the following sequence occurs:

1. **Dialog Creation**: A new `VisualToolkitBinaryInformationForm` is instantiated
2. **Configuration**: The dialog is configured with:
   - `ToolkitSupportType` - Determines icon and title
   - `ShowChangeLogButton` - Controls changelog button visibility
   - `ShowReadmeButton` - Controls readme button visibility
3. **Display**: The dialog is shown modally using `ShowDialog()`
4. **Information Display**: The dialog displays:
   - Toolkit icon based on support type
   - File version information for all Krypton Toolkit components:
     - Krypton.Docking
     - Krypton.Navigator
     - Krypton.Ribbon
     - Krypton.Toolkit
     - Krypton.Workspace
   - Optional documentation buttons
5. **Base Event**: After the dialog is closed, the base `Click` event is raised

### Version Information Dialog

The dialog displays the following information:

#### Header
- Toolkit logo (varies by support type)
- Title: "Toolkit Information: [Support Type]"

#### Version Information
- **Krypton Docking**: File version or "File not found"
- **Krypton Navigator**: File version or "File not found"
- **Krypton Ribbon**: File version or "File not found"
- **Krypton Toolkit**: File version or "File not found"
- **Krypton Workspace**: File version or "File not found"

#### Optional Buttons
- **Changelog**: Opens appropriate changelog URL in default browser
- **Readme**: Opens appropriate readme URL in default browser
- **OK**: Closes the dialog

### File Version Detection

The control automatically detects installed Krypton Toolkit component versions by:

1. Examining the application's base directory (`AppDomain.CurrentDomain.BaseDirectory`)
2. Looking for Krypton DLL files
3. Reading file version information using `FileVersionInfo`
4. Displaying version or "File not found" message

---

## Best Practices

### When to Use

✅ **Recommended Uses**:
- About dialog boxes
- Application status bars
- Help or support forms
- Splash screens
- Settings/preferences dialogs
- Application footer areas

❌ **Not Recommended**:
- Repeated placement on multiple forms
- Primary navigation elements
- Critical user workflows
- Forms where branding is inappropriate

### Configuration Guidelines

#### 1. Support Type Selection

Choose the support type that matches your application's Krypton Toolkit installation:

```csharp
// For production applications
button.ButtonValues.ToolkitSupportType = ToolkitSupportType.Stable;

// For development/testing
button.ButtonValues.ToolkitSupportType = ToolkitSupportType.Nightly;

// For bleeding-edge features
button.ButtonValues.ToolkitSupportType = ToolkitSupportType.Canary;

// For enterprise applications with LTS
button.ButtonValues.ToolkitSupportType = ToolkitSupportType.LongTermSupport;
```

#### 2. Documentation Links

Enable documentation links for:
- Developer-facing applications
- Beta/testing distributions
- Open-source projects
- When users might need support information

Disable documentation links for:
- End-user production applications
- Embedded/simplified UIs
- Kiosk or limited-access applications

```csharp
// Developer or beta distribution
button.ButtonValues.ShowChangeLogButton = true;
button.ButtonValues.ShowReadmeButton = true;

// End-user production application
button.ButtonValues.ShowChangeLogButton = false;
button.ButtonValues.ShowReadmeButton = false;
```

#### 3. Sizing and Placement

**Default Size** (153 x 25):
```csharp
var button = new KryptonPoweredByButton();
// Size is 153 x 25 by default
```

**Compact Size** (for status bars):
```csharp
var button = new KryptonPoweredByButton
{
    Size = new Size(120, 20)
};
```

**Placement Strategies**:

Bottom-right corner (recommended):
```csharp
button.Anchor = AnchorStyles.Bottom | AnchorStyles.Right;
button.Location = new Point(
    ClientSize.Width - button.Width - 10,
    ClientSize.Height - button.Height - 10
);
```

About dialog center-bottom:
```csharp
button.Location = new Point(
    (ClientSize.Width - button.Width) / 2,
    ClientSize.Height - button.Height - 20
);
```

#### 4. Avoiding Common Mistakes

**Don't override the Click event**:
```csharp
// ❌ BAD: This interferes with built-in functionality
button.Click += MyCustomHandler;

// ✅ GOOD: Let the button handle its own click behavior
// If you need custom behavior, create a separate button
```

**Don't modify the Text property**:
```csharp
// ❌ BAD: Text is managed by the control
button.Text = "My Custom Text";

// ✅ GOOD: Use the default localized text
// Text is set automatically from KryptonManager.Strings
```

**Do check IsDefault before serializing**:
```csharp
// ✅ GOOD: Only serialize if modified
if (!button.ButtonValues.IsDefault)
{
    // Serialize button values
}
```

#### 5. Localization Support

The button text is automatically localized through `KryptonManager.Strings`:

```csharp
// Text is set automatically from:
KryptonManager.Strings.MiscellaneousStrings.PoweredByText + " Krypton"

// Dialog button text is also localized:
// - ChangeLogText
// - ReadmeText
```

To customize localization, modify the `KryptonManager.Strings` before creating the button.

#### 6. Accessibility Considerations

```csharp
var button = new KryptonPoweredByButton();

// Set accessible name
button.AccessibleName = "Powered by Krypton Toolkit Information";

// Set accessible description
button.AccessibleDescription = "Click to view Krypton Toolkit version information";

// Set accessible role (inherited from Button)
button.AccessibleRole = AccessibleRole.PushButton;
```

#### 7. Theme Integration

The button automatically respects the current Krypton palette:

```csharp
// Button will automatically update when palette changes
KryptonManager.GlobalPaletteMode = PaletteModeManager.Office365Blue;

// Button styling respects current theme
var button = new KryptonPoweredByButton();
// No additional theme configuration needed
```

#### 8. Performance Considerations

- The button is lightweight and has minimal performance impact
- Version detection occurs only when the dialog is shown (on click)
- File version information is cached per dialog instance
- Multiple buttons can be safely added to different forms

---

## Related Components

### VisualToolkitBinaryInformationForm

**Internal class** that displays the version information dialog.

**Features**:
- Displays all Krypton component versions
- Shows appropriate icon and title for support type
- Optional changelog and readme buttons
- Automatic version detection from application directory

**Usage**: Automatically created and displayed by `KryptonPoweredByButton.OnClick()`.

### KryptonButton (Base Class)

The `KryptonPoweredByButton` inherits all features from `KryptonButton`:

- Full palette support
- State-based styling (Normal, Tracking, Pressed, Disabled)
- Content alignment options
- Border and background customization
- Image and text positioning
- Focus and keyboard navigation

**Example of inherited functionality**:
```csharp
var button = new KryptonPoweredByButton();

// All KryptonButton properties are available
button.StateCommon.Back.Color1 = Color.LightBlue;
button.StateCommon.Back.Color2 = Color.White;
button.StateCommon.Border.Rounding = 5;
button.StateTracking.Back.Color1 = Color.Blue;
```

### ButtonImageResources

**Internal class** that provides embedded button images:

- `Krypton_Stable_Button`
- `Krypton_Canary_Button`
- `Krypton_Nightly_Button`
- `Krypton_Long_Term_Stable_Button`

These images are automatically selected based on `ToolkitSupportType`.

### ToolkitLogoResources

**Internal class** that provides 48x48 pixel logos used in the version dialog:

- `Krypton_48_x_48_Stable`
- `Krypton_48_x_48_Canary`
- `Krypton_48_x_48_Nightly`
- `Krypton_48_x_48_LTS`

### KryptonManager.Strings

Provides localized strings used by the button:

```csharp
// Used by KryptonPoweredByButton
KryptonManager.Strings.MiscellaneousStrings.PoweredByText

// Used by VisualToolkitBinaryInformationForm
KryptonManager.Strings.MiscellaneousStrings.ToolkitInformationText
KryptonManager.Strings.MiscellaneousStrings.CanaryText
KryptonManager.Strings.MiscellaneousStrings.NightlyText
KryptonManager.Strings.MiscellaneousStrings.StableText
KryptonManager.Strings.MiscellaneousStrings.LongTermStableText
KryptonManager.Strings.MiscellaneousStrings.ChangeLogText
KryptonManager.Strings.MiscellaneousStrings.ReadmeText
KryptonManager.Strings.MiscellaneousStrings.FileNotFoundText
```

---

## Appendix

### Component File Locations

| Component | File Path |
|-----------|-----------|
| KryptonPoweredByButton | `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonPoweredByButton.cs` |
| PoweredByButtonValues | `Source/Krypton Components/Krypton.Toolkit/Values/PoweredByButtonValues.cs` |
| VisualToolkitBinaryInformationForm | `Source/Krypton Components/Krypton.Toolkit/Controls Visuals/VisualToolkitBinaryInformationForm.cs` |
| ToolkitSupportType | `Source/Krypton Components/Krypton.Toolkit/General/Definitions.cs` |
| ButtonImageResources | `Source/Krypton Components/Krypton.Toolkit/ResourceFiles/Buttons/ButtonImageResources.Designer.cs` |