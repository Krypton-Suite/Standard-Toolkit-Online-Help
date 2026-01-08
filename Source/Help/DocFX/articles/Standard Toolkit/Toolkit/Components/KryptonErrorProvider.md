# KryptonErrorProvider

## Overview

`KryptonErrorProvider` is a Krypton-themed wrapper for the standard WinForms `ErrorProvider` component. It provides form validation error indication with full Krypton palette integration, Krypton-specific enums for blink style and icon alignment, automatic border color changing for Krypton controls, and custom Krypton-themed tooltips.

## Key Features

- **Krypton Theming**: Full integration with the Krypton palette system
- **Krypton-Specific Enums**: `KryptonErrorBlinkStyle` and `KryptonErrorIconAlignment` for better type safety
- **Extender Provider**: Implements `IExtenderProvider` to add error properties to controls at design time
- **Icon Customization**: Customizable icon size and icon selection with automatic resizing
- **Border Color Changing**: Automatically changes Krypton control border colors based on icon type (error/warning/information)
- **Krypton Tooltips**: Uses Krypton-themed tooltips instead of standard Windows tooltips for error messages
- **Standard ErrorProvider API**: Maintains full compatibility with standard `ErrorProvider` functionality

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
public class KryptonErrorProvider : Component, IExtenderProvider
```

## Constructors

### `KryptonErrorProvider()`
```csharp
public KryptonErrorProvider()
```

Initializes a new instance of the `KryptonErrorProvider` class with default settings:
- `BlinkStyle`: `KryptonErrorBlinkStyle.BlinkIfDifferentError`
- `IconAlignment`: `KryptonErrorIconAlignment.MiddleRight`
- `IconPadding`: `0`
- `IconSize`: `16x16` pixels
- `PaletteMode`: `PaletteMode.Global`
- `ChangeBorderColor`: `true`
- Default icon: `SystemIcons.Error`

### `KryptonErrorProvider(IContainer container)`
```csharp
public KryptonErrorProvider(IContainer container)
```

Initializes a new instance of the `KryptonErrorProvider` class and adds it to the specified container.

**Parameters:**
- `container` - The `IContainer` that contains this component

## Properties

### Palette Properties

#### `PaletteMode`
```csharp
[Category("Visuals")]
[Description("Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }
```

Gets or sets the palette mode. See `KryptonToolStripContainer` documentation for available palette modes. When changed, the icon and tooltip system are updated to reflect the new palette.

#### `Palette`
```csharp
[Category("Visuals")]
[Description("Sets the custom palette to be used.")]
[DefaultValue(null)]
public PaletteBase? Palette { get; set; }
```

Gets or sets a custom palette implementation. Setting this property automatically sets `PaletteMode` to `PaletteMode.Custom`. Setting to `null` resets to `PaletteMode.Global`.

### Error Provider Properties

#### `BlinkStyle`
```csharp
[Category("Behavior")]
[Description("Indicates when the error icon blinks.")]
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
[Description("Indicates the alignment of the error icon relative to the control.")]
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

**Note:** This property sets the default alignment. Use `SetIconAlignment` to set alignment per control.

#### `IconPadding`
```csharp
[Category("Appearance")]
[Description("The amount of extra space to leave between the icon and the control.")]
[DefaultValue(0)]
public int IconPadding { get; set; }
```

Gets or sets the default amount of extra space (in pixels) to leave between the specified control and the error icon.

**Note:** This property sets the default padding. Use `SetIconPadding` to set padding per control.

#### `IconSize`
```csharp
[Category("Appearance")]
[Description("The size of the error icon in pixels (width and height).")]
[DefaultValue(typeof(Size), "16, 16")]
public Size IconSize { get; set; }
```

Gets or sets the size of the error icon in pixels. The icon will be automatically resized to match this size. Default is `16x16` pixels.

**Note:** Changing this property will recreate the resized icon if an icon is currently set.

#### `Icon`
```csharp
[Category("Appearance")]
[Description("The Icon to display next to a control when an error description string has been set.")]
[DefaultValue(null)]
public Icon? Icon { get; set; }
```

Gets or sets the `Icon` that is displayed next to a control when an error description string has been set. If `null`, uses `SystemIcons.Error` by default.

The icon will be automatically resized to match `IconSize` if it doesn't already match. The component properly handles `SystemIcons` shared instances and will not dispose them.

**Supported Icon Types:**
- Error icons: `SystemIcons.Error`, `SystemIcons.Hand` → Red border color
- Warning icons: `SystemIcons.Warning`, `SystemIcons.Exclamation` → Yellow/Orange border color
- Information icons: `SystemIcons.Information`, `SystemIcons.Asterisk` → Blue border color

#### `ChangeBorderColor`
```csharp
[Category("Behavior")]
[Description("Indicates whether the border color of Krypton controls should be changed based on the icon type (red for error, yellow for warning, blue for information).")]
[DefaultValue(true)]
public bool ChangeBorderColor { get; set; }
```

Gets or sets a value indicating whether the border color of Krypton controls should be changed based on the icon type. When enabled, Krypton controls will have their border color automatically changed to:
- **Red** (`Color.FromArgb(220, 53, 69)`) for error icons (`SystemIcons.Error` or `SystemIcons.Hand`)
- **Yellow/Orange** (`Color.FromArgb(255, 193, 7)`) for warning icons (`SystemIcons.Warning` or `SystemIcons.Exclamation`)
- **Blue** (`Color.FromArgb(0, 123, 255)`) for information icons (`SystemIcons.Information` or `SystemIcons.Asterisk`)

The border color is automatically cleared when the error is removed. This feature only works with Krypton controls that support the `StateCommon.Border.Color1` property.

#### `ContainerControl`
```csharp
[Category("Behavior")]
[Description("The ContainerControl that this ErrorProvider is bound to.")]
[DefaultValue(null)]
public ContainerControl? ContainerControl { get; set; }
```

Gets or sets the parent control for this `ErrorProvider`. The error provider must be associated with a container control to function. This property also enables mouse tracking for Krypton tooltips.

**Important:** Setting this property hooks into the container's mouse events for tooltip display. The events are automatically unhooked when the property is changed or the component is disposed.

#### `ToolTipValues`
```csharp
[Category("Appearance")]
[Description("Tooltip appearance and behavior settings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public ToolTipValues ToolTipValues { get; }
```

Gets the tooltip values that control the appearance and behavior of Krypton-themed tooltips displayed when hovering over error icons.

**ToolTipValues Properties:**
- `ShowIntervalDelay` (default: 500ms) - Delay before showing tooltip
- `CloseIntervalDelay` (default: 5000ms) - Delay before auto-closing tooltip
- `ToolTipStyle` (default: `LabelStyle.SuperTip`) - Visual style of the tooltip
- `ToolTipShadow` (default: `true`) - Whether to show shadow on tooltip
- `ToolTipPosition` - Position and orientation settings
- `Heading` - Tooltip heading text (inherited from `HeaderValues`)
- `Description` - Tooltip description text (inherited from `HeaderValues`)
- `Image` - Tooltip image (inherited from `HeaderValues`)

**Note:** The error message text is automatically used as the tooltip content. The `Heading`, `Description`, and `Image` properties are not used for error tooltips.

### Access to Underlying Component

#### `ErrorProvider`
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ErrorProvider? ErrorProvider { get; }
```

Gets access to the underlying `ErrorProvider` component for advanced scenarios. Note that the standard tooltip is disabled (set to a space character) to allow Krypton tooltips to be displayed instead.

## Methods

### `SetError`
```csharp
public void SetError(Control control, string value)
```

Sets the error description string for the specified control. If `ChangeBorderColor` is enabled, this will also update the control's border color based on the icon type. The error message is stored separately and displayed in a Krypton tooltip when hovering over the error icon.

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
[ExtenderProvidedProperty]
[Category("Validation")]
[Description("Gets or sets the error description string for this control.")]
[DefaultValue("")]
[Localizable(true)]
public string GetError(Control control)
```

Returns the current error description string for the specified control. This is an extender property that can be accessed at design time.

**Parameters:**
- `control` - The control to get the error description string for

**Returns:** The error description string for the control, or an empty string if no error is set.

**Note:** This method returns the actual error message stored internally, not the tooltip text set on the underlying `ErrorProvider` (which is set to a space character to disable standard tooltips).

### `SetIconAlignment`
```csharp
public void SetIconAlignment(Control control, KryptonErrorIconAlignment alignment)
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

**Returns:** One of the `KryptonErrorIconAlignment` values. Returns `MiddleRight` if the underlying `ErrorProvider` is not available.

### `SetIconPadding`
```csharp
public void SetIconPadding(Control control, int value)
```

Sets the amount of extra space to leave between the specified control and the error icon.

**Parameters:**
- `control` - The control to set the icon padding for
- `value` - The number of pixels to add between the control and the error icon

### `GetIconPadding`
```csharp
public int GetIconPadding(Control control)
```

Gets the amount of extra space to leave between the specified control and the error icon.

**Parameters:**
- `control` - The control to get the icon padding for

**Returns:** The number of pixels between the control and the error icon. Returns `0` if the underlying `ErrorProvider` is not available.

### `GetChangeBorderColorOnError`
```csharp
[ExtenderProvidedProperty]
[Category("Validation")]
[Description("Gets or sets a value indicating whether the border color of this control should be changed when an error is set.")]
[DefaultValue(true)]
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

### `Clear`
```csharp
public void Clear()
```

Clears all errors associated with this component. If `ChangeBorderColor` is enabled, this will also clear all border color changes on controls within the `ContainerControl`. Also clears all control-specific border color settings and error messages.

### `CanExtend`
```csharp
public bool CanExtend(object extendee)
```

Determines if this extender can provide its extender properties to the specified object.

**Parameters:**
- `extendee` - The object to receive the extender properties

**Returns:** `true` if this object can provide extender properties to the specified object; otherwise, `false`.

## Events

`KryptonErrorProvider` inherits standard `Component` events but does not define custom events. The error icon display is handled automatically by the underlying `ErrorProvider`, and tooltips are managed internally through mouse tracking on the `ContainerControl`.

## Enumerations

### `KryptonErrorBlinkStyle`

```csharp
public enum KryptonErrorBlinkStyle
{
    /// <summary>
    /// Blink only if the error icon is already displayed, but a new
    /// error string is set for the control.  If the icon did not blink
    /// in this case, the user might not know that there is a new error.
    /// </summary>
    BlinkIfDifferentError = ErrorBlinkStyle.BlinkIfDifferentError,
    
    /// <summary>
    /// Blink the error icon when the error is first displayed, or when
    /// a new error description string is set for the control and the
    /// error icon is already displayed.
    /// </summary>
    AlwaysBlink = ErrorBlinkStyle.AlwaysBlink,
    
    /// <summary>
    /// Never blink the error icon.
    /// </summary>
    NeverBlink = ErrorBlinkStyle.NeverBlink
}
```

### `KryptonErrorIconAlignment`

```csharp
public enum KryptonErrorIconAlignment
{
    /// <summary>
    /// The icon appears aligned with the top of the control, and to the
    /// left of the control.
    /// </summary>
    TopLeft,
    
    /// <summary>
    /// The icon appears aligned with the top of the control, and to the
    /// right of the control.
    /// </summary>
    TopRight,
    
    /// <summary>
    /// The icon appears aligned with the middle of the control, and the
    /// left of the control.
    /// </summary>
    MiddleLeft,
    
    /// <summary>
    /// The icon appears aligned with the middle of the control, and the
    /// right of the control.
    /// </summary>
    MiddleRight,
    
    /// <summary>
    /// The icon appears aligned with the bottom of the control, and to the
    /// left of the control.
    /// </summary>
    BottomLeft,
    
    /// <summary>
    /// The icon appears aligned with the bottom of the control, and to the
    /// right of the control.
    /// </summary>
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
            IconAlignment = KryptonErrorIconAlignment.MiddleRight,
            IconSize = new Size(20, 20) // Larger icon
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

### Custom Icon and Icon Size

```csharp
// Use a custom icon
errorProvider.Icon = MyCustomErrorIcon;

// Set custom icon size (will be automatically resized)
errorProvider.IconSize = new Size(24, 24);

// Use different icon types for different border colors
errorProvider.Icon = SystemIcons.Warning; // Yellow border
errorProvider.SetError(textBox1, "This is a warning");

errorProvider.Icon = SystemIcons.Information; // Blue border
errorProvider.SetError(textBox2, "This is informational");
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

### Blink Style Configuration

```csharp
// Never blink (less distracting)
errorProvider.BlinkStyle = KryptonErrorBlinkStyle.NeverBlink;

// Always blink (more attention-grabbing)
errorProvider.BlinkStyle = KryptonErrorBlinkStyle.AlwaysBlink;

// Blink only when error changes (default, balanced)
errorProvider.BlinkStyle = KryptonErrorBlinkStyle.BlinkIfDifferentError;
```

### Customizing Tooltips

```csharp
// Configure tooltip appearance
errorProvider.ToolTipValues.ToolTipStyle = LabelStyle.SuperTip;
errorProvider.ToolTipValues.ToolTipShadow = true;
errorProvider.ToolTipValues.ShowIntervalDelay = 750; // Show after 750ms
errorProvider.ToolTipValues.CloseIntervalDelay = 10000; // Auto-close after 10 seconds
```

### SetError with Alignment

```csharp
// Set error and alignment in one call
errorProvider.SetError(textBox1, "Invalid input", KryptonErrorIconAlignment.TopRight);
```

## Best Practices

1. **Set ContainerControl**: Always set the `ContainerControl` property to the form or container that contains the controls you want to validate. This is required for tooltip functionality.

2. **Clear Errors**: Clear all errors before re-validating to avoid stale error messages.

3. **Use Validating/Validated Events**: For real-time validation, use the `Validating` and `Validated` events of controls.

4. **Consistent Icon Alignment**: Use consistent icon alignment across your form for a professional look.

5. **Appropriate Blink Style**: Use `NeverBlink` for less distracting validation, or `BlinkIfDifferentError` for a balanced approach.

6. **Icon Padding**: Adjust icon padding if controls are close together or if you need more visual separation.

7. **Icon Size**: Consider your application's DPI settings when setting icon size. The default 16x16 works well for standard DPI.

8. **Border Color Changing**: The border color feature only works with Krypton controls. Standard WinForms controls will not have their borders changed. Use `ChangeBorderColorOnError` to disable this feature for specific controls if needed.

9. **Tooltip Configuration**: Adjust `ShowIntervalDelay` and `CloseIntervalDelay` based on your application's needs. Longer delays may be better for users who need more time to read error messages.

10. **Disposal**: The component properly disposes of resources, including icons, timers, and event handlers. Ensure it's disposed when the form is disposed.

11. **Icon Management**: The component automatically handles icon resizing and disposal. Custom icons will be disposed when replaced or when the component is disposed. SystemIcons instances are never disposed.

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

The control uses `SystemIcons.Error` by default, which provides a system-consistent error icon. Icons are automatically resized to match `IconSize` if they don't already match. The component properly handles `SystemIcons` shared instances and will not dispose them. Custom icons are cloned when resized to ensure proper ownership.

**Icon Resizing:**
- If the icon size matches `IconSize`, the original icon is used directly
- If the icon size differs, a resized version is created using `GraphicsExtensions.ScaleImage`
- The resized icon is cloned to create an owned copy that can be safely disposed
- If resizing fails, the original icon is used as a fallback

### Border Color Management

When `ChangeBorderColor` is enabled (default), the component automatically changes the border color of Krypton controls based on the icon type:
- **Error icons** (`SystemIcons.Error`, `SystemIcons.Hand`): Red border (`Color.FromArgb(220, 53, 69)`)
- **Warning icons** (`SystemIcons.Warning`, `SystemIcons.Exclamation`): Yellow/Orange border (`Color.FromArgb(255, 193, 7)`)
- **Information icons** (`SystemIcons.Information`, `SystemIcons.Asterisk`): Blue border (`Color.FromArgb(0, 123, 255)`)

Border colors are automatically cleared when errors are removed. This feature uses reflection to access the `StateCommon.Border.Color1` property on Krypton controls, so it only works with controls that support this property structure.

You can control border color changing globally via the `ChangeBorderColor` property, or per-control via the `ChangeBorderColorOnError` extender property.

### Tooltip System

`KryptonErrorProvider` uses a custom tooltip system that displays Krypton-themed tooltips instead of standard Windows tooltips:

1. **Standard Tooltip Disabled**: The underlying `ErrorProvider`'s tooltip is set to a space character to disable standard tooltips
2. **Error Message Storage**: Error messages are stored separately in an internal dictionary (`_errorMessages`)
3. **Mouse Tracking**: The component hooks into `ContainerControl` mouse events to detect when the mouse hovers over error icons
4. **Icon Bounds Calculation**: Icon bounds are calculated based on control position, icon alignment, padding, and icon size
5. **Tooltip Display**: When hovering over an error icon, a Krypton tooltip is displayed after the `ShowIntervalDelay` period
6. **Tooltip Styling**: Tooltips use the `ToolTipValues` settings for appearance and behavior

**Tooltip Features:**
- Automatic positioning relative to error icon
- Krypton palette integration
- Configurable show/close delays
- Configurable visual style and shadow
- Automatic cleanup when mouse leaves

### Palette Integration

The component integrates with the Krypton palette system for consistency:
- Listens to `KryptonManager.GlobalPaletteChanged` events
- Updates icon and tooltip system when palette changes (if using `PaletteMode.Global`)
- Supports custom palettes via `PaletteMode.Custom`
- Tooltips use palette-based rendering for consistent theming

### Error Message Storage

Error messages are stored in an internal dictionary (`_errorMessages`) separate from the underlying `ErrorProvider`. This allows:
- Retrieval of actual error messages via `GetError`
- Display in Krypton tooltips
- Proper cleanup when errors are cleared
- Border color management based on error presence

The underlying `ErrorProvider` is set to a space character to disable standard tooltips while still displaying the error icon.

### Resource Management

The component properly manages resources:
- Icons are disposed when replaced or when the component is disposed
- SystemIcons instances are never disposed (checked via reference equality)
- Resized icons are properly cloned and disposed
- Timers are stopped and disposed
- Event handlers are unhooked
- Tooltip popups are disposed
