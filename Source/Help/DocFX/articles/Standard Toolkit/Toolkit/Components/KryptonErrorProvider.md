# KryptonErrorProvider

## Overview

`KryptonErrorProvider` is a Krypton-themed wrapper for the standard WinForms `ErrorProvider` component. It provides form validation error indication with full Krypton palette integration and Krypton-specific enums for blink style and icon alignment.

## Key Features

- **Krypton Theming**: Integrates with the Krypton palette system
- **Krypton-Specific Enums**: `KryptonErrorBlinkStyle` and `KryptonErrorIconAlignment` for better type safety
- **Extender Provider**: Implements `IExtenderProvider` to add error properties to controls
- **Icon Customization**: Uses system error icon with palette integration
- **Border Color Changing**: Automatically changes Krypton control border colors based on icon type (error/warning/information)
- **Standard ErrorProvider API**: Maintains full compatibility with standard `ErrorProvider` functionality

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
public class KryptonErrorProvider : Component, IExtenderProvider
```

## Properties

### Palette Properties

#### `PaletteMode`
```csharp
[Category("Visuals")]
[Description("Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }
```

Gets or sets the palette mode. See `KryptonToolStripContainer` documentation for available palette modes.

#### `Palette`
```csharp
[Category("Visuals")]
[Description("Sets the custom palette to be used.")]
[DefaultValue(null)]
public PaletteBase? Palette { get; set; }
```

Gets or sets a custom palette implementation.

### Error Provider Properties

#### `BlinkStyle`
```csharp
[Category("Appearance")]
[Description("Determines when the error icon flashes.")]
[DefaultValue(KryptonErrorBlinkStyle.BlinkIfDifferentError)]
public KryptonErrorBlinkStyle BlinkStyle { get; set; }
```

Gets or sets when the error icon flashes. Valid values:
- `KryptonErrorBlinkStyle.BlinkIfDifferentError` (default) - Blinks only when the error string changes
- `KryptonErrorBlinkStyle.AlwaysBlink` - Always blinks when an error is set
- `KryptonErrorBlinkStyle.NeverBlink` - Never blinks

#### `IconAlignment`
```csharp
[Category("Appearance")]
[Description("Gets or sets the location where the error icon is placed.")]
[DefaultValue(KryptonErrorIconAlignment.MiddleRight)]
public KryptonErrorIconAlignment IconAlignment { get; set; }
```

Gets or sets the default location where the error icon is placed relative to the control. Valid values:
- `KryptonErrorIconAlignment.TopLeft`
- `KryptonErrorIconAlignment.TopRight`
- `KryptonErrorIconAlignment.MiddleLeft`
- `KryptonErrorIconAlignment.MiddleRight` (default)
- `KryptonErrorIconAlignment.BottomLeft`
- `KryptonErrorIconAlignment.BottomRight`

#### `IconPadding`
```csharp
[Category("Appearance")]
[Description("Gets or sets the amount of extra space to leave between the specified control and the error icon.")]
[DefaultValue(0)]
public int IconPadding { get; set; }
```

Gets or sets the default amount of extra space (in pixels) to leave between the specified control and the error icon.

#### `Icon`
```csharp
[Category("Appearance")]
[Description("Gets or sets the Icon that is displayed next to a control when an error description string has been set.")]
[DefaultValue(null)]
public Icon? Icon { get; set; }
```

Gets or sets the `Icon` that is displayed next to a control when an error description string has been set. If `null`, uses the system error icon.

#### `ContainerControl`
```csharp
[Category("Behavior")]
[Description("Gets or sets the parent control for this ErrorProvider.")]
[DefaultValue(null)]
public ContainerControl? ContainerControl { get; set; }
```

Gets or sets the parent control for this `ErrorProvider`. The error provider must be associated with a container control to function.

#### `ChangeBorderColor`
```csharp
[Category("Behavior")]
[Description("Indicates whether the border color of Krypton controls should be changed based on the icon type (red for error, yellow for warning, blue for information).")]
[DefaultValue(true)]
public bool ChangeBorderColor { get; set; }
```

Gets or sets a value indicating whether the border color of Krypton controls should be changed based on the icon type. When enabled, Krypton controls will have their border color automatically changed to:
- Red for error icons (`SystemIcons.Error` or `SystemIcons.Hand`)
- Yellow/Orange for warning icons (`SystemIcons.Warning` or `SystemIcons.Exclamation`)
- Blue for information icons (`SystemIcons.Information` or `SystemIcons.Asterisk`)

The border color is automatically cleared when the error is removed. This feature only works with Krypton controls that support the `StateCommon.Border.Color1` property.

### Access to Underlying Component

#### `ErrorProvider`
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ErrorProvider? ErrorProvider { get; }
```

Gets access to the underlying `ErrorProvider` component for advanced scenarios.

## Constructors

### `KryptonErrorProvider()`
```csharp
public KryptonErrorProvider()
```

Initializes a new instance of the `KryptonErrorProvider` class with default settings.

### `KryptonErrorProvider(IContainer container)`
```csharp
public KryptonErrorProvider(IContainer container)
```

Initializes a new instance of the `KryptonErrorProvider` class and adds it to the specified container.

**Parameters:**
- `container` - The `IContainer` that contains this component

## Methods

### `SetError`
```csharp
public void SetError(Control control, string value)
```

Sets the error description string for the specified control. If `ChangeBorderColor` is enabled, this will also update the control's border color based on the icon type.

**Parameters:**
- `control` - The control to set the error description string for
- `value` - The error description string, or an empty string to clear the error

**Example:**
```csharp
errorProvider.SetError(textBox1, "This field is required");
```

### `SetError` (with alignment)
```csharp
public void SetError(Control control, string value, KryptonErrorIconAlignment alignment)
```

Sets the error description string for the specified control at the specified icon alignment location. This is a convenience method that combines `SetError` and `SetIconAlignment` in a single call.

**Parameters:**
- `control` - The control to set the error description string for
- `value` - The error description string, or an empty string to clear the error
- `alignment` - The alignment of the error icon relative to the control

**Example:**
```csharp
errorProvider.SetError(textBox1, "This field is required", KryptonErrorIconAlignment.TopRight);
```

### `GetError`
```csharp
public string GetError(Control control)
```

Returns the current error description string for the specified control.

**Parameters:**
- `control` - The control to get the error description string for

**Returns:** The error description string for the control, or an empty string if no error is set.

### `SetIconAlignment`
```csharp
public void SetIconAlignment(Control control, KryptonErrorIconAlignment value)
```

Sets the location where the error icon is placed relative to the control.

**Parameters:**
- `control` - The control to set the icon alignment for
- `value` - One of the `KryptonErrorIconAlignment` values

### `GetIconAlignment`
```csharp
public KryptonErrorIconAlignment GetIconAlignment(Control control)
```

Gets the location where the error icon is placed relative to the control.

**Parameters:**
- `control` - The control to get the icon alignment for

**Returns:** One of the `KryptonErrorIconAlignment` values.

### `SetIconPadding`
```csharp
public void SetIconPadding(Control control, int padding)
```

Sets the amount of extra space to leave between the specified control and the error icon.

**Parameters:**
- `control` - The control to set the icon padding for
- `padding` - The number of pixels to add between the control and the error icon

### `GetIconPadding`
```csharp
public int GetIconPadding(Control control)
```

Gets the amount of extra space to leave between the specified control and the error icon.

**Parameters:**
- `control` - The control to get the icon padding for

**Returns:** The number of pixels between the control and the error icon.

### `Clear`
```csharp
public void Clear()
```

Clears all errors associated with this component. If `ChangeBorderColor` is enabled, this will also clear all border color changes on controls within the `ContainerControl`.

### `GetChangeBorderColorOnError`
```csharp
public bool GetChangeBorderColorOnError(Control control)
```

Gets a value indicating whether the border color should be changed for the specified control when an error is set. This is an extender property that can be set per control.

**Parameters:**
- `control` - The control to check

**Returns:** `true` if border color should be changed; otherwise, `false`. Returns the global `ChangeBorderColor` value if no control-specific override is set.

### `SetChangeBorderColorOnError`
```csharp
public void SetChangeBorderColorOnError(Control control, bool value)
```

Sets a value indicating whether the border color should be changed for the specified control when an error is set. This allows you to override the global `ChangeBorderColor` setting for individual controls.

**Parameters:**
- `control` - The control to set the value for
- `value` - `true` to change border color; otherwise, `false`

**Example:**
```csharp
// Disable border color changing for a specific control
errorProvider.SetChangeBorderColorOnError(textBox1, false);
```

### `CanExtend`
```csharp
public bool CanExtend(object extendee)
```

Determines if this extender can provide its extender properties to the specified object.

**Parameters:**
- `extendee` - The object to receive the extender properties

**Returns:** `true` if this object can provide extender properties to the specified object; otherwise, `false`.

## Events

`KryptonErrorProvider` inherits standard `Component` events but does not define custom events. The error icon display is handled automatically by the underlying `ErrorProvider`.

## Enumerations

### `KryptonErrorBlinkStyle`

```csharp
public enum KryptonErrorBlinkStyle
{
    BlinkIfDifferentError,  // Blinks only when error string changes
    AlwaysBlink,            // Always blinks when error is set
    NeverBlink              // Never blinks
}
```

### `KryptonErrorIconAlignment`

```csharp
public enum KryptonErrorIconAlignment
{
    TopLeft,
    TopRight,
    MiddleLeft,
    MiddleRight,
    BottomLeft,
    BottomRight
}
```

## Usage Examples

### Basic Form Validation

```csharp
public partial class MyForm : KryptonForm
{
    private KryptonErrorProvider errorProvider;

    public MyForm()
    {
        InitializeComponent();
        
        // Create error provider
        errorProvider = new KryptonErrorProvider
        {
            ContainerControl = this,
            BlinkStyle = KryptonErrorBlinkStyle.BlinkIfDifferentError,
            IconAlignment = KryptonErrorIconAlignment.MiddleRight
        };
    }

    private void ValidateForm()
    {
        // Clear all errors
        errorProvider.Clear();

        // Validate required fields
        if (string.IsNullOrEmpty(textBoxName.Text))
        {
            errorProvider.SetError(textBoxName, "Name is required");
        }

        if (string.IsNullOrEmpty(textBoxEmail.Text))
        {
            errorProvider.SetError(textBoxEmail, "Email is required");
        }
        else if (!IsValidEmail(textBoxEmail.Text))
        {
            errorProvider.SetError(textBoxEmail, "Invalid email format");
        }
    }

    private void buttonSave_Click(object sender, EventArgs e)
    {
        ValidateForm();
        // ... save logic
    }
}
```

### Custom Icon Alignment per Control

```csharp
// Set different icon alignment for different controls
errorProvider.SetIconAlignment(textBox1, KryptonErrorIconAlignment.TopRight);
errorProvider.SetIconAlignment(textBox2, KryptonErrorIconAlignment.BottomLeft);

// Set custom padding
errorProvider.SetIconPadding(textBox1, 5);
```

### Real-Time Validation

```csharp
private void textBoxEmail_Validating(object sender, CancelEventArgs e)
{
    var textBox = sender as TextBox;
    if (textBox != null)
    {
        if (string.IsNullOrEmpty(textBox.Text))
        {
            errorProvider.SetError(textBox, "Email is required");
            e.Cancel = true;
        }
        else if (!IsValidEmail(textBox.Text))
        {
            errorProvider.SetError(textBox, "Invalid email format");
            e.Cancel = true;
        }
        else
        {
            errorProvider.SetError(textBox, string.Empty);
        }
    }
}

private void textBoxEmail_Validated(object sender, EventArgs e)
{
    var textBox = sender as TextBox;
    if (textBox != null)
    {
        errorProvider.SetError(textBox, string.Empty);
    }
}
```

### Custom Icon

```csharp
// Use a custom icon instead of the system error icon
errorProvider.Icon = MyCustomErrorIcon;
```

### Blink Style Configuration

```csharp
// Never blink (less distracting)
errorProvider.BlinkStyle = KryptonErrorBlinkStyle.NeverBlink;

// Always blink (more attention-grabbing)
errorProvider.BlinkStyle = KryptonErrorBlinkStyle.AlwaysBlink;

// Blink only when error changes (default, balanced)
errorProvider.BlinkStyle = KryptonErrorBlinkStyle.BlinkIfDifferentError;
```

### Border Color Changing

```csharp
// Enable border color changing (default)
errorProvider.ChangeBorderColor = true;

// Disable border color changing globally
errorProvider.ChangeBorderColor = false;

// Disable border color changing for a specific control
errorProvider.SetChangeBorderColorOnError(textBox1, false);

// Use different icon types for different border colors
errorProvider.Icon = SystemIcons.Warning; // Yellow border
errorProvider.SetError(textBox1, "This is a warning");

errorProvider.Icon = SystemIcons.Information; // Blue border
errorProvider.SetError(textBox2, "This is informational");
```

## Best Practices

1. **Set ContainerControl**: Always set the `ContainerControl` property to the form or container that contains the controls you want to validate.

2. **Clear Errors**: Clear all errors before re-validating to avoid stale error messages.

3. **Use Validating/Validated Events**: For real-time validation, use the `Validating` and `Validated` events of controls.

4. **Consistent Icon Alignment**: Use consistent icon alignment across your form for a professional look.

5. **Appropriate Blink Style**: Use `NeverBlink` for less distracting validation, or `BlinkIfDifferentError` for a balanced approach.

6. **Icon Padding**: Adjust icon padding if controls are close together or if you need more visual separation.

7. **Disposal**: The component properly disposes of resources. Ensure it's disposed when the form is disposed.

8. **Border Color Changing**: The border color feature only works with Krypton controls. Standard WinForms controls will not have their borders changed. Use `ChangeBorderColorOnError` to disable this feature for specific controls if needed.

## Integration with Data Binding

```csharp
// Works with data binding validation
private void bindingSource_CurrentItemChanged(object sender, EventArgs e)
{
    // Validate bound controls
    ValidateForm();
}
```

## Technical Details

### Extender Provider Pattern

`KryptonErrorProvider` implements `IExtenderProvider`, which allows it to add properties to other controls at design time. The properties added are:
- `Error` - The error description string (via `GetError`/`SetError`)
- `ChangeBorderColorOnError` - Whether to change border color for this control (via `GetChangeBorderColorOnError`/`SetChangeBorderColorOnError`)
- `IconAlignmentOnErrorProvider` - Icon alignment for this control (via `GetIconAlignment`/`SetIconAlignment`)
- `IconPaddingOnErrorProvider` - Icon padding for this control (via `GetIconPadding`/`SetIconPadding`)

### Icon Management

The control uses `SystemIcons.Error` by default, which provides a system-consistent error icon. The icon is managed internally and disposed when the component is disposed. The component properly handles `SystemIcons` shared instances and will not dispose them.

### Border Color Management

When `ChangeBorderColor` is enabled (default), the component automatically changes the border color of Krypton controls based on the icon type:
- **Error icons** (`SystemIcons.Error`, `SystemIcons.Hand`): Red border (`Color.FromArgb(220, 53, 69)`)
- **Warning icons** (`SystemIcons.Warning`, `SystemIcons.Exclamation`): Yellow/Orange border (`Color.FromArgb(255, 193, 7)`)
- **Information icons** (`SystemIcons.Information`, `SystemIcons.Asterisk`): Blue border (`Color.FromArgb(0, 123, 255)`)

Border colors are automatically cleared when errors are removed. This feature uses reflection to access the `StateCommon.Border.Color1` property on Krypton controls, so it only works with controls that support this property structure.

You can control border color changing globally via the `ChangeBorderColor` property, or per-control via the `ChangeBorderColorOnError` extender property.

### Palette Integration

While the error icon itself uses the system icon, the component integrates with the Krypton palette system for consistency. The component listens to global palette changes and updates accordingly when using `PaletteMode.Global`.

## See Also

- `KryptonHelpProvider` - For providing help to controls
- `KryptonToolTip` - For displaying tooltips
- `IExtenderProvider` - Interface for extender providers
- Standard WinForms validation patterns

