# KryptonForm

The `KryptonForm` class is a themed form control that provides custom window chrome using Krypton styling, replacing the standard Windows form appearance.

## Overview

`KryptonForm` is a specialized form control that draws its own window chrome using the Krypton palette system. It provides a fully themed window experience with custom title bar, borders, and window controls while maintaining full Windows form functionality.

## Namespace

```csharp
Krypton.Toolkit
```

## Inheritance

```csharp
public class KryptonForm : VisualForm, IContentValues
```

## Key Features

- **Custom Window Chrome**: Complete control over window appearance
- **Themed Title Bar**: Customizable title bar with Krypton styling
- **Button Specifications**: Configurable window control buttons (minimize, maximize, close)
- **Header Styles**: Multiple header style options
- **Form State Management**: Proper handling of window states
- **Drop Shadow**: Optional drop shadow effects
- **Administrator Mode**: Special handling for elevated applications
- **Status Strip Integration**: Automatic status strip merging
- **Accessibility**: Full accessibility support

## Properties

### Window Appearance

#### HeaderStyle
```csharp
[Category("Appearance")]
[Description("Gets and sets the header style.")]
[DefaultValue(HeaderStyle.Primary)]
public HeaderStyle HeaderStyle { get; set; }
```

Gets and sets the header style for the form.

**Default Value**: `HeaderStyle.Primary`

#### FormTitleAlign
```csharp
[Category("Appearance")]
[Description("Gets and sets the form title alignment.")]
[DefaultValue(PaletteRelativeAlign.Center)]
public PaletteRelativeAlign FormTitleAlign { get; set; }
```

Gets and sets the alignment of the form title text.

**Default Value**: `PaletteRelativeAlign.Center`

#### TextExtra
```csharp
[Category("Appearance")]
[Description("Gets and sets the extra text to be displayed in the title bar.")]
[DefaultValue("")]
public string TextExtra { get; set; }
```

Gets and sets extra text to be displayed in the title bar alongside the main text.

**Default Value**: `""`

#### AllowFormChrome
```csharp
[Category("Behavior")]
[Description("Gets and sets if the form chrome is allowed.")]
[DefaultValue(true)]
public bool AllowFormChrome { get; set; }
```

Gets and sets whether the form chrome is allowed to be drawn.

**Default Value**: `true`

#### AllowStatusStripMerge
```csharp
[Category("Behavior")]
[Description("Gets and sets if the status strip can be merged.")]
[DefaultValue(true)]
public bool AllowStatusStripMerge { get; set; }
```

Gets and sets whether the status strip can be merged with the form.

**Default Value**: `true`

### Button Specifications

#### ButtonSpecs
```csharp
[Category("Visuals")]
[Description("Collection of button specifications.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public FormButtonSpecCollection ButtonSpecs { get; }
```

Gets access to the collection of button specifications for the form.

#### FixedButtonSpecs
```csharp
[Category("Visuals")]
[Description("Collection of fixed button specifications.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public FormFixedButtonSpecCollection FixedButtonSpecs { get; }
```

Gets access to the collection of fixed button specifications for the form.

### State Properties

#### StateCommon
```csharp
[Category("Visuals")]
[Description("Overrides for defining common form appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteFormRedirect StateCommon { get; }
```

Gets access to the common state appearance that other states can override.

#### StateDisabled
```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled form appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteFormStates StateDisabled { get; }
```

Gets access to the disabled state appearance.

#### StateNormal
```csharp
[Category("Visuals")]
[Description("Overrides for defining normal form appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteFormStates StateNormal { get; }
```

Gets access to the normal state appearance.

#### StateActive
```csharp
[Category("Visuals")]
[Description("Overrides for defining active form appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteFormStates StateActive { get; }
```

Gets access to the active state appearance.

### Palette Properties

#### PaletteMode
```csharp
[Category("Visuals")]
[Description("Gets and sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }
```

Gets and sets the palette mode for the form.

**Default Value**: `PaletteMode.Global`

#### Palette
```csharp
[Category("Visuals")]
[Description("Gets and sets the custom palette.")]
[DefaultValue(null)]
public IPalette Palette { get; set; }
```

Gets and sets the custom palette for the form.

**Default Value**: `null`

## Events

### PaletteChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the palette changes.")]
public event EventHandler PaletteChanged;
```

Occurs when the palette changes.

### ButtonSpecClick
```csharp
[Category("Action")]
[Description("Occurs when a button specification is clicked.")]
public event EventHandler<ButtonSpecClickEventArgs> ButtonSpecClick;
```

Occurs when a button specification is clicked.

## Methods

### SetPalette(IPalette palette)
```csharp
public void SetPalette(IPalette palette)
```

Sets the custom palette for the form.

### GetPalette()
```csharp
public IPalette GetPalette()
```

Gets the current palette for the form.

### PerformClose()
```csharp
public void PerformClose()
```

Performs the close action for the form.

### PerformMinimize()
```csharp
public void PerformMinimize()
```

Performs the minimize action for the form.

### PerformMaximize()
```csharp
public void PerformMaximize()
```

Performs the maximize action for the form.

### PerformRestore()
```csharp
public void PerformRestore()
```

Performs the restore action for the form.

## Usage Examples

### Basic Form Setup
```csharp
// Create a basic themed form
KryptonForm form = new KryptonForm();
form.Text = "My Themed Application";
form.Size = new Size(800, 600);
form.StartPosition = FormStartPosition.CenterScreen;
form.Show();
```

### Custom Header Style
```csharp
// Create a form with custom header style
KryptonForm form = new KryptonForm();
form.HeaderStyle = HeaderStyle.Secondary;
form.Text = "Secondary Header Style";
form.TextExtra = " - Additional Info";
```

### Custom Button Specifications
```csharp
// Create a form with custom button specifications
KryptonForm form = new KryptonForm();

// Add a custom button to the title bar
ButtonSpecAny customButton = new ButtonSpecAny();
customButton.Type = PaletteButtonSpecStyle.PendantClose;
customButton.Text = "Custom";
customButton.Click += (sender, e) => MessageBox.Show("Custom button clicked!");
form.ButtonSpecs.Add(customButton);
```

### Custom Styling
```csharp
// Create a form with custom styling
KryptonForm form = new KryptonForm();

// Customize the normal state
form.StateNormal.Header.Back.Color1 = Color.White;
form.StateNormal.Header.Border.Color1 = Color.Gray;
form.StateNormal.Header.Content.ShortText.Color1 = Color.Black;

// Customize the active state
form.StateActive.Header.Back.Color1 = Color.LightBlue;
form.StateActive.Header.Border.Color1 = Color.Blue;
```

### Palette Integration
```csharp
// The form automatically uses the global theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// Or set a custom palette
form.PaletteMode = PaletteMode.Custom;
form.Palette = new CustomPalette();
```

### Administrator Mode Detection
```csharp
// The form automatically detects administrator mode
// and adjusts appearance accordingly
KryptonForm form = new KryptonForm();
// The form will automatically show administrator indicators
// when running with elevated privileges
```

## Design-Time Support

The `KryptonForm` control includes comprehensive design-time support:

- **Designer Integration**: Full Visual Studio designer support
- **Property Grid**: Complete property grid integration
- **Smart Tags**: Quick access to common properties
- **Designer Serialization**: Proper serialization of all properties
- **Toolbox Integration**: Available in the Visual Studio toolbox

## Accessibility

The control provides full accessibility support:

- **Screen Reader Support**: Properly announces form state and content
- **Keyboard Navigation**: Full keyboard navigation support
- **Focus Management**: Proper focus handling and indicators
- **Window Controls**: Accessible window control buttons

## Performance Considerations

- The form is optimized for performance with efficient rendering
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Window state changes are handled efficiently

## Related Components

- `KryptonManager` - Global theme management
- `ButtonSpecAny` - Button specification for custom buttons
- `ButtonSpecFormFixed` - Fixed button specification for form controls
- `PaletteFormStates` - Form state management
- `HeaderStyle` - Header style enumeration
- `PaletteRelativeAlign` - Relative alignment enumeration
