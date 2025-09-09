# KryptonButton

The `KryptonButton` class is a themed button control that combines standard button functionality with the styling features of the Krypton Toolkit.

## Overview

`KryptonButton` provides a fully themed button control that supports multiple visual states, custom styling, and integration with the Krypton theming system. It inherits from `KryptonDropButton` but removes the dropdown functionality to provide a standard button experience.

## Namespace

```csharp
Krypton.Toolkit
```

## Inheritance

```csharp
public class KryptonButton : KryptonDropButton
```

## Key Features

- **Themed Appearance**: Automatically adapts to the current Krypton theme
- **Multiple States**: Supports normal, disabled, hot, pressed, and focus states
- **Custom Styling**: Full control over colors, fonts, and borders
- **Mnemonic Support**: Built-in support for keyboard mnemonics
- **Accessibility**: Full accessibility support with screen readers
- **Design-Time Support**: Complete Visual Studio designer integration

## Properties

### Text and Content
```csharp
[DefaultProperty("Text")]
public string Text { get; set; }
```

Gets or sets the text displayed on the button.

### Orientation
```csharp
[Browsable(true)]
[Localizable(true)]
[DefaultValue(VisualOrientation.Top)]
public virtual VisualOrientation Orientation { get; set; }
```

Gets and sets the visual orientation of the control. This affects how the button content is displayed.

**Default Value**: `VisualOrientation.Top`

### ShowSplitOption
```csharp
[Category("Visuals")]
[DefaultValue(false)]
[Description("Displays the split/dropdown option.")]
public bool ShowSplitOption { get; set; }
```

Gets or sets a value indicating whether to show the split/dropdown option. When `true`, the button displays a dropdown arrow.

**Default Value**: `false`

### ButtonStyle
```csharp
[Category("Appearance")]
[Description("Defines the button style.")]
[DefaultValue(ButtonStyle.Standalone)]
public ButtonStyle ButtonStyle { get; set; }
```

Gets and sets the button style that defines the visual appearance and behavior.

**Available Styles**:
- `Standalone` - Standard button appearance
- `Alternate` - Alternative button style
- `LowProfile` - Low profile button style
- `ButtonSpec` - Button specification style
- `CalendarDay` - Calendar day button style
- `CalendarDay` - Calendar day button style
- `Cluster` - Cluster button style
- `Gallery` - Gallery button style
- `NavigatorStack` - Navigator stack button style
- `NavigatorOverflow` - Navigator overflow button style
- `NavigatorMini` - Navigator mini button style
- `Form` - Form button style
- `FormClose` - Form close button style
- `InputControl` - Input control button style

### DialogResult
```csharp
[Category("Behavior")]
[Description("The dialog result produced in a modal form by clicking the button.")]
[DefaultValue(DialogResult.None)]
public DialogResult DialogResult { get; set; }
```

Gets or sets the dialog result that is returned to the parent form when the button is clicked.

**Default Value**: `DialogResult.None`

### UseMnemonic
```csharp
[Category("Behavior")]
[Description("If true, the first character preceded by an ampersand will be used as the mnemonic key.")]
[DefaultValue(true)]
public bool UseMnemonic { get; set; }
```

Gets or sets a value indicating whether the first character preceded by an ampersand will be used as the mnemonic key.

**Default Value**: `true`

### IsDefault
```csharp
[Category("Behavior")]
[Description("Gets or sets a value indicating whether the button control is the default button.")]
[DefaultValue(false)]
public bool IsDefault { get; set; }
```

Gets or sets a value indicating whether the button control is the default button.

**Default Value**: `false`

## State Properties

### StateCommon
```csharp
[Category("Visuals")]
[Description("Overrides for defining common button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect StateCommon { get; }
```

Gets access to the common state appearance that other states can override.

### StateDisabled
```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateDisabled { get; }
```

Gets access to the disabled state appearance.

### StateNormal
```csharp
[Category("Visuals")]
[Description("Overrides for defining normal button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateNormal { get; }
```

Gets access to the normal state appearance.

### StateTracking
```csharp
[Category("Visuals")]
[Description("Overrides for defining hot tracking button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateTracking { get; }
```

Gets access to the hot tracking state appearance.

### StatePressed
```csharp
[Category("Visuals")]
[Description("Overrides for defining pressed button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StatePressed { get; }
```

Gets access to the pressed state appearance.

### OverrideDefault
```csharp
[Category("Visuals")]
[Description("Overrides for defining default button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect OverrideDefault { get; }
```

Gets access to the default state appearance overrides.

### OverrideFocus
```csharp
[Category("Visuals")]
[Description("Overrides for defining focus button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect OverrideFocus { get; }
```

Gets access to the focus state appearance overrides.

## Events

### Click
```csharp
[Category("Action")]
[Description("Occurs when the button is clicked.")]
public event EventHandler Click;
```

Occurs when the button is clicked.

### KryptonCommandChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the KryptonCommand property changes.")]
public event EventHandler KryptonCommandChanged;
```

Occurs when the value of the KryptonCommand property changes.

## Methods

### PerformClick()
```csharp
public void PerformClick()
```

Generates a Click event for the button, simulating a user click.

### NotifyDefault(bool value)
```csharp
public void NotifyDefault(bool value)
```

Notifies the button whether it is the default button so that it can adjust its appearance accordingly.

## Usage Examples

### Basic Button Setup
```csharp
// Create a basic themed button
KryptonButton button = new KryptonButton();
button.Text = "Click Me";
button.Size = new Size(100, 30);
button.Click += (sender, e) => MessageBox.Show("Button clicked!");
```

### Custom Styling
```csharp
// Create a button with custom styling
KryptonButton customButton = new KryptonButton();
customButton.Text = "Custom Button";
customButton.ButtonStyle = ButtonStyle.Standalone;

// Customize the normal state
customButton.StateNormal.Back.Color1 = Color.LightBlue;
customButton.StateNormal.Content.ShortText.Color1 = Color.DarkBlue;
customButton.StateNormal.Border.Color1 = Color.Blue;

// Customize the hot state
customButton.StateTracking.Back.Color1 = Color.LightCyan;
customButton.StateTracking.Content.ShortText.Color1 = Color.DarkCyan;
```

### Default Button Setup
```csharp
// Create a default button
KryptonButton defaultButton = new KryptonButton();
defaultButton.Text = "OK";
defaultButton.DialogResult = DialogResult.OK;
defaultButton.IsDefault = true;
```

### Mnemonic Support
```csharp
// Create a button with mnemonic support
KryptonButton mnemonicButton = new KryptonButton();
mnemonicButton.Text = "&Save"; // Alt+S will trigger the button
mnemonicButton.UseMnemonic = true;
```

### Theme Integration
```csharp
// The button automatically uses the global theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// All KryptonButton instances will automatically update their appearance
```

## Design-Time Support

The `KryptonButton` control includes comprehensive design-time support:

- **Toolbox Integration**: Available in the Visual Studio toolbox
- **Property Grid**: Full property grid support with categorized properties
- **Smart Tags**: Quick access to common properties and actions
- **Designer Serialization**: Proper serialization of all properties
- **Default Property**: Text property is marked as the default property

## Accessibility

The control provides full accessibility support:

- **Screen Reader Support**: Properly announces button text and state
- **Keyboard Navigation**: Supports Tab key navigation
- **Mnemonic Support**: Alt+key combinations for quick access
- **Focus Indicators**: Visual focus indicators for keyboard users

## Performance Considerations

- The control is optimized for performance with minimal overhead
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Rendering is hardware-accelerated where possible

## Related Components

- `KryptonDropButton` - Base class with dropdown functionality
- `KryptonCommandLinkButton` - Command link style button
- `KryptonColorButton` - Color selection button
- `KryptonManager` - Global theme management
- `PaletteTriple` - Palette state management
