# KryptonHelpProvider

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Getting Started](#getting-started)
4. [API Reference](#api-reference)
5. [Tooltip Functionality](#tooltip-functionality)
6. [Usage Examples](#usage-examples)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Overview

`KryptonHelpProvider` is a Krypton-themed wrapper around the standard Windows Forms `HelpProvider` component that provides enhanced help functionality for controls in your application. It extends the standard help provider with:

- **Krypton-styled tooltips** - Display help strings as beautifully styled tooltips when hovering over controls
- **Palette support** - Integrates with the Krypton palette system for consistent theming
- **Dual help modes** - Supports both pop-up help strings and HTML help files
- **Event handling** - Customizable help request handling

### Key Benefits

- **Consistent UI** - Help tooltips match your application's Krypton theme
- **Better UX** - Users can see help text on hover without pressing F1
- **Flexible** - Works with both simple help strings and complex HTML help systems
- **Easy Integration** - Drop-in replacement for standard `HelpProvider`

---

## Features

### Core Features

1. **Help String Management**
   - Set and retrieve help strings for individual controls
   - Enable/disable help for specific controls
   - Support for both pop-up help and HTML help files

2. **Krypton Tooltips**
   - Styled tooltips that match your application theme
   - Configurable appearance (style, shadow, delays)
   - Automatic display on mouse hover
   - Respects palette changes at runtime

3. **HTML Help Support**
   - Support for compiled HTML help files (.chm)
   - Help keywords and navigation types
   - Table of contents, index, and find navigation

4. **Palette Integration**
   - Supports all Krypton palette modes
   - Custom palette support
   - Automatic theme updates

5. **Event Handling**
   - `HelpRequested` event for custom help handling
   - Can override default help behavior

---

## Getting Started

### Basic Setup

1. **Add to Form**
   ```csharp
   // Drag KryptonHelpProvider from toolbox onto your form
   // Or create programmatically:
   var helpProvider = new KryptonHelpProvider();
   ```

2. **Set Container Control** (Required for tooltips)
   ```csharp
   helpProvider.ContainerControl = this; // 'this' is your form
   ```

3. **Enable Tooltips**
   ```csharp
   helpProvider.ToolTipValues.EnableToolTips = true;
   ```

4. **Configure Help for Controls**
   ```csharp
   helpProvider.SetShowHelp(myTextBox, true);
   helpProvider.SetHelpString(myTextBox, "Enter your name here");
   ```

### Complete Example

```csharp
public partial class MyForm : KryptonForm
{
    private KryptonHelpProvider helpProvider;
    
    public MyForm()
    {
        InitializeComponent();
        InitializeHelp();
    }
    
    private void InitializeHelp()
    {
        // Create help provider
        helpProvider = new KryptonHelpProvider();
        
        // Set container control for tooltip functionality
        helpProvider.ContainerControl = this;
        
        // Configure tooltip appearance
        helpProvider.ToolTipValues.EnableToolTips = true;
        helpProvider.ToolTipValues.ToolTipStyle = LabelStyle.ToolTip;
        helpProvider.ToolTipValues.ToolTipShadow = true;
        helpProvider.ToolTipValues.ShowIntervalDelay = 500;
        helpProvider.ToolTipValues.CloseIntervalDelay = 5000;
        
        // Set help strings for controls
        helpProvider.SetShowHelp(textBoxName, true);
        helpProvider.SetHelpString(textBoxName, "Enter your full name");
        
        helpProvider.SetShowHelp(textBoxEmail, true);
        helpProvider.SetHelpString(textBoxEmail, "Enter a valid email address");
        
        // Optional: Handle help requests
        helpProvider.HelpRequested += HelpProvider_HelpRequested;
    }
    
    private void HelpProvider_HelpRequested(object? sender, HelpEventArgs e)
    {
        // Custom help handling
        Control? control = ActiveControl;
        if (control != null)
        {
            string? helpString = helpProvider.GetHelpString(control);
            if (!string.IsNullOrEmpty(helpString))
            {
                KryptonMessageBox.Show(this, helpString, "Help", 
                    KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
                e.Handled = true;
            }
        }
    }
}
```

---

## API Reference

### Properties

#### `PaletteMode`
- **Type**: `PaletteMode`
- **Default**: `PaletteMode.Global`
- **Category**: Visuals
- **Description**: Gets or sets the palette mode used for tooltip rendering.

```csharp
helpProvider.PaletteMode = PaletteMode.Office2010Blue;
```

**Available Modes**:
- `Global` - Uses the global palette from `KryptonManager`
- `ProfessionalSystem` - System-based professional appearance
- `ProfessionalOffice2003` - Office 2003 style
- `Office2007Blue`, `Office2007Silver`, `Office2007White`, `Office2007Black` - Office 2007 variants
- `Office2010Blue`, `Office2010Silver`, `Office2010White`, `Office2010Black` - Office 2010 variants
- `Office2013White` - Office 2013 style
- `SparkleBlue`, `SparkleOrange`, `SparklePurple` - Sparkle variants
- `Microsoft365Blue`, `Microsoft365Silver`, `Microsoft365White`, `Microsoft365Black` - Microsoft 365 variants
- `Custom` - Use a custom palette

#### `Palette`
- **Type**: `PaletteBase?`
- **Default**: `null`
- **Category**: Visuals
- **Description**: Gets or sets a custom palette. Only available when `PaletteMode` is set to `Custom`.

```csharp
helpProvider.PaletteMode = PaletteMode.Custom;
helpProvider.Palette = myCustomPalette;
```

#### `HelpNamespace`
- **Type**: `string`
- **Default**: `""` (empty string)
- **Category**: Behavior
- **Description**: Gets or sets the name of the Help file associated with this object. When empty, pop-up help strings are used. When set to a file path (e.g., `.chm` file), HTML help is used.

```csharp
// Use pop-up help strings
helpProvider.HelpNamespace = string.Empty;

// Use HTML help file
helpProvider.HelpNamespace = @"C:\Help\MyApp.chm";
```

#### `ContainerControl`
- **Type**: `ContainerControl?`
- **Default**: `null`
- **Category**: Behavior
- **Description**: Gets or sets the container control that this HelpProvider is attached to. **Required for tooltip functionality**. Typically set to your form instance.

```csharp
helpProvider.ContainerControl = this; // 'this' is your form
```

#### `ToolTipValues`
- **Type**: `ToolTipValues`
- **Category**: Appearance
- **Description**: Gets the tooltip values object for customizing tooltip appearance and behavior.

**ToolTipValues Properties**:
- `EnableToolTips` (bool) - Enable or disable tooltip display
- `ToolTipStyle` (LabelStyle) - Style of the tooltip (e.g., `LabelStyle.ToolTip`, `LabelStyle.SuperTip`)
- `ToolTipShadow` (bool) - Whether to show shadow on tooltip
- `ShowIntervalDelay` (int) - Milliseconds to wait before showing tooltip (default: 500)
- `CloseIntervalDelay` (int) - Milliseconds before auto-closing tooltip (default: 5000)
- `ToolTipPosition` (PopupPositionValues) - Position and orientation settings

```csharp
helpProvider.ToolTipValues.EnableToolTips = true;
helpProvider.ToolTipValues.ToolTipStyle = LabelStyle.SuperTip;
helpProvider.ToolTipValues.ToolTipShadow = true;
helpProvider.ToolTipValues.ShowIntervalDelay = 750;
helpProvider.ToolTipValues.CloseIntervalDelay = 10000;
```

#### `HelpProvider`
- **Type**: `HelpProvider?`
- **Browsable**: `false`
- **Description**: Gets the underlying Windows Forms `HelpProvider` instance. Useful for advanced scenarios requiring direct access to the base provider.

---

### Methods

#### `SetShowHelp(Control ctl, bool value)`
Specifies whether Help is displayed for the specified control.

**Parameters**:
- `ctl` (Control) - The control for which Help is turned on or off
- `value` (bool) - `true` to enable help, `false` to disable

**Example**:
```csharp
helpProvider.SetShowHelp(textBox1, true);
```

#### `GetShowHelp(Control ctl)`
Returns a value indicating whether Help is displayed for the specified control.

**Parameters**:
- `ctl` (Control) - The control to check

**Returns**: `true` if help is enabled, otherwise `false`

**Example**:
```csharp
bool hasHelp = helpProvider.GetShowHelp(textBox1);
```

#### `SetHelpString(Control ctl, string? helpString)`
Specifies the Help string associated with the specified control. This string is displayed as a tooltip when hovering over the control (if tooltips are enabled) and when F1 is pressed.

**Parameters**:
- `ctl` (Control) - The control to associate the help string with
- `helpString` (string?) - The help string to display. Use `null` or empty string to remove help.

**Example**:
```csharp
helpProvider.SetHelpString(textBox1, "Enter your name in this field");
helpProvider.SetHelpString(textBox1, null); // Remove help
```

#### `GetHelpString(Control ctl)`
Returns the Help string for the specified control.

**Parameters**:
- `ctl` (Control) - The control to retrieve the help string from

**Returns**: The help string, or `null` if not set

**Example**:
```csharp
string? helpText = helpProvider.GetHelpString(textBox1);
```

#### `SetHelpKeyword(Control ctl, string? keyword)`
Specifies a Help keyword for the specified control. Used with HTML help files to navigate to specific topics.

**Parameters**:
- `ctl` (Control) - The control to associate the keyword with
- `keyword` (string?) - The help keyword (topic ID) in the HTML help file

**Example**:
```csharp
helpProvider.HelpNamespace = @"C:\Help\MyApp.chm";
helpProvider.SetHelpKeyword(button1, "button_help_topic");
```

#### `GetHelpKeyword(Control ctl)`
Returns the current Help keyword for the specified control.

**Parameters**:
- `ctl` (Control) - The control to retrieve the keyword from

**Returns**: The help keyword, or `null` if not set

#### `SetHelpNavigator(Control ctl, HelpNavigator navigator)`
Specifies the Help command to use when the user invokes Help for the specified control.

**Parameters**:
- `ctl` (Control) - The control for which to set the help command
- `navigator` (HelpNavigator) - One of the `HelpNavigator` values

**HelpNavigator Values**:
- `TableOfContents` - Show table of contents
- `Index` - Show index
- `Find` - Show find dialog
- `Topic` - Show specific topic (requires keyword)
- `KeywordIndex` - Show keyword index
- `AssociateIndex` - Show associate index

**Example**:
```csharp
helpProvider.SetHelpNavigator(button1, HelpNavigator.Topic);
```

#### `GetHelpNavigator(Control ctl)`
Returns the current Help navigation type for the specified control.

**Parameters**:
- `ctl` (Control) - The control to retrieve the navigator from

**Returns**: The `HelpNavigator` value (default: `TableOfContents`)

---

### Events

#### `HelpRequested`
Occurs when the user requests help for a control (typically by pressing F1).

**Event Handler Signature**:
```csharp
void HelpRequested(object? sender, HelpEventArgs e)
```

**Parameters**:
- `sender` - The `KryptonHelpProvider` instance
- `e` - `HelpEventArgs` containing event data

**Example**:
```csharp
helpProvider.HelpRequested += (sender, e) =>
{
    Control? control = ActiveControl;
    if (control != null)
    {
        string? helpString = helpProvider.GetHelpString(control);
        if (!string.IsNullOrEmpty(helpString))
        {
            // Show custom help dialog
            KryptonMessageBox.Show(this, helpString, "Help", 
                KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
            
            // Mark as handled to prevent default behavior
            e.Handled = true;
        }
    }
};
```

**Note**: Set `e.Handled = true` to prevent the default help behavior.

---

## Tooltip Functionality

### Overview

`KryptonHelpProvider` can display help strings as styled tooltips when users hover over controls. This provides immediate context-sensitive help without requiring the F1 key.

### Requirements

1. **ContainerControl must be set** - The tooltip system requires a container control to track mouse movement
2. **EnableToolTips must be true** - Tooltips are disabled by default
3. **Help must be enabled for the control** - Use `SetShowHelp(control, true)`
4. **Help string must be set** - Use `SetHelpString(control, "help text")`

### How It Works

1. **Mouse Tracking**: The component tracks mouse movement over the container control
2. **Control Detection**: When the mouse hovers over a control, it checks if help is enabled
3. **Timer Delay**: After a configurable delay (`ShowIntervalDelay`), the tooltip appears
4. **Display**: A styled Krypton tooltip is shown at the mouse location
5. **Auto-Hide**: The tooltip hides when the mouse leaves the control or after `CloseIntervalDelay`

### Tooltip Configuration

```csharp
// Enable tooltips
helpProvider.ToolTipValues.EnableToolTips = true;

// Set tooltip style
helpProvider.ToolTipValues.ToolTipStyle = LabelStyle.ToolTip; // or LabelStyle.SuperTip

// Enable shadow
helpProvider.ToolTipValues.ToolTipShadow = true;

// Configure delays (in milliseconds)
helpProvider.ToolTipValues.ShowIntervalDelay = 500;    // Wait 500ms before showing
helpProvider.ToolTipValues.CloseIntervalDelay = 5000;  // Auto-close after 5 seconds

// Configure position (optional)
helpProvider.ToolTipValues.ToolTipPosition.PlacementMode = PlacementMode.Bottom;
helpProvider.ToolTipValues.ToolTipPosition.HorizontalOffset = 10;
helpProvider.ToolTipValues.ToolTipPosition.VerticalOffset = 10;
```

### Tooltip vs F1 Help

- **Tooltips**: Display automatically on hover (if enabled)
- **F1 Help**: Displays when F1 is pressed or Help button is clicked
- **Both can work together**: Tooltips provide quick reference, F1 provides detailed help

---

## Usage Examples

### Example 1: Basic Help Strings

```csharp
public partial class LoginForm : KryptonForm
{
    private KryptonHelpProvider helpProvider;
    
    public LoginForm()
    {
        InitializeComponent();
        
        helpProvider = new KryptonHelpProvider();
        helpProvider.ContainerControl = this;
        helpProvider.ToolTipValues.EnableToolTips = true;
        
        // Set help for username field
        helpProvider.SetShowHelp(textBoxUsername, true);
        helpProvider.SetHelpString(textBoxUsername, 
            "Enter your username or email address");
        
        // Set help for password field
        helpProvider.SetShowHelp(textBoxPassword, true);
        helpProvider.SetHelpString(textBoxPassword, 
            "Enter your password. Passwords are case-sensitive.");
        
        // Set help for remember me checkbox
        helpProvider.SetShowHelp(checkBoxRememberMe, true);
        helpProvider.SetHelpString(checkBoxRememberMe, 
            "Check this box to save your login credentials");
    }
}
```

### Example 2: HTML Help File Integration

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonHelpProvider helpProvider;
    
    public MainForm()
    {
        InitializeComponent();
        
        helpProvider = new KryptonHelpProvider();
        
        // Set HTML help file
        string helpFile = Path.Combine(Application.StartupPath, "Help", "MyApp.chm");
        if (File.Exists(helpFile))
        {
            helpProvider.HelpNamespace = helpFile;
        }
        
        // Set help keywords for controls
        helpProvider.SetShowHelp(buttonSave, true);
        helpProvider.SetHelpKeyword(buttonSave, "save_file");
        helpProvider.SetHelpNavigator(buttonSave, HelpNavigator.Topic);
        
        helpProvider.SetShowHelp(buttonPrint, true);
        helpProvider.SetHelpKeyword(buttonPrint, "print_document");
        helpProvider.SetHelpNavigator(buttonPrint, HelpNavigator.Topic);
        
        // Set up table of contents button
        helpProvider.SetShowHelp(buttonHelp, true);
        helpProvider.SetHelpNavigator(buttonHelp, HelpNavigator.TableOfContents);
    }
}
```

### Example 3: Custom Help Handling

```csharp
public partial class DataEntryForm : KryptonForm
{
    private KryptonHelpProvider helpProvider;
    
    public DataEntryForm()
    {
        InitializeComponent();
        
        helpProvider = new KryptonHelpProvider();
        helpProvider.ContainerControl = this;
        helpProvider.ToolTipValues.EnableToolTips = true;
        
        // Set help strings
        helpProvider.SetShowHelp(textBoxEmail, true);
        helpProvider.SetHelpString(textBoxEmail, "Enter a valid email address");
        
        // Handle help requests with custom logic
        helpProvider.HelpRequested += HelpProvider_HelpRequested;
    }
    
    private void HelpProvider_HelpRequested(object? sender, HelpEventArgs e)
    {
        Control? control = ActiveControl;
        
        if (control == textBoxEmail)
        {
            // Show enhanced help for email field
            string helpText = "Email Address Requirements:\n\n" +
                            "• Must contain @ symbol\n" +
                            "• Must have valid domain\n" +
                            "• Example: user@example.com";
            
            KryptonMessageBox.Show(this, helpText, "Email Help", 
                KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
            
            e.Handled = true; // Prevent default behavior
        }
        else if (control != null)
        {
            // Use default help string for other controls
            string? helpString = helpProvider.GetHelpString(control);
            if (!string.IsNullOrEmpty(helpString))
            {
                KryptonMessageBox.Show(this, helpString, $"Help: {control.Name}", 
                    KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
                e.Handled = true;
            }
        }
    }
}
```

### Example 4: Dynamic Help Updates

```csharp
public partial class DynamicForm : KryptonForm
{
    private KryptonHelpProvider helpProvider;
    
    public DynamicForm()
    {
        InitializeComponent();
        
        helpProvider = new KryptonHelpProvider();
        helpProvider.ContainerControl = this;
        helpProvider.ToolTipValues.EnableToolTips = true;
        
        // Update help based on control state
        textBoxAge.Validating += TextBoxAge_Validating;
    }
    
    private void TextBoxAge_Validating(object? sender, CancelEventArgs e)
    {
        if (int.TryParse(textBoxAge.Text, out int age))
        {
            if (age < 18)
            {
                helpProvider.SetHelpString(textBoxAge, 
                    "You must be at least 18 years old to register");
            }
            else if (age > 120)
            {
                helpProvider.SetHelpString(textBoxAge, 
                    "Please enter a valid age");
            }
            else
            {
                helpProvider.SetHelpString(textBoxAge, 
                    "Enter your age (must be between 18 and 120)");
            }
        }
        else
        {
            helpProvider.SetHelpString(textBoxAge, 
                "Please enter a valid number for your age");
        }
    }
}
```

### Example 5: Palette Customization

```csharp
public partial class ThemedForm : KryptonForm
{
    private KryptonHelpProvider helpProvider;
    
    public ThemedForm()
    {
        InitializeComponent();
        
        helpProvider = new KryptonHelpProvider();
        helpProvider.ContainerControl = this;
        helpProvider.ToolTipValues.EnableToolTips = true;
        
        // Use Office 2010 Blue theme
        helpProvider.PaletteMode = PaletteMode.Office2010Blue;
        
        // Or use a custom palette
        // helpProvider.PaletteMode = PaletteMode.Custom;
        // helpProvider.Palette = myCustomPalette;
        
        // Set help strings
        helpProvider.SetShowHelp(textBox1, true);
        helpProvider.SetHelpString(textBox1, "This tooltip will use the selected theme");
    }
    
    // Change theme at runtime
    private void ChangeTheme(PaletteMode mode)
    {
        helpProvider.PaletteMode = mode;
        // Tooltips will automatically update to use the new theme
    }
}
```

---

## Best Practices

### 1. Always Set ContainerControl

For tooltip functionality to work, you **must** set the `ContainerControl` property:

```csharp
// ✅ Good
helpProvider.ContainerControl = this;

// ❌ Bad - tooltips won't work
// helpProvider.ContainerControl is null
```

### 2. Enable Tooltips Explicitly

Tooltips are disabled by default. Always enable them if you want hover help:

```csharp
helpProvider.ToolTipValues.EnableToolTips = true;
```

### 3. Use Descriptive Help Strings

Write clear, concise help text that explains what the control does:

```csharp
// ✅ Good
helpProvider.SetHelpString(textBoxEmail, 
    "Enter your email address. This will be used for account verification.");

// ❌ Bad - too vague
helpProvider.SetHelpString(textBoxEmail, "Email");
```

### 4. Set Help Before Setting ContainerControl

If you're setting help strings programmatically, set them before setting `ContainerControl` to avoid unnecessary tooltip system updates:

```csharp
// ✅ Good
helpProvider.SetShowHelp(textBox1, true);
helpProvider.SetHelpString(textBox1, "Help text");
helpProvider.ContainerControl = this; // Set last

// Less efficient
helpProvider.ContainerControl = this;
helpProvider.SetHelpString(textBox1, "Help text"); // Triggers update
```

### 5. Handle HelpRequested for Custom Behavior

Use the `HelpRequested` event for custom help dialogs or enhanced help:

```csharp
helpProvider.HelpRequested += (sender, e) =>
{
    // Custom help logic
    e.Handled = true; // Don't forget to mark as handled!
};
```

### 6. Clean Up Resources

If creating `KryptonHelpProvider` programmatically, ensure proper disposal:

```csharp
private KryptonHelpProvider? helpProvider;

protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        helpProvider?.Dispose();
    }
    base.Dispose(disposing);
}
```

### 7. Use Appropriate Tooltip Delays

Adjust delays based on your application's needs:

```csharp
// Quick response for expert users
helpProvider.ToolTipValues.ShowIntervalDelay = 300;

// Slower for beginners (more forgiving)
helpProvider.ToolTipValues.ShowIntervalDelay = 1000;
```

### 8. Consider Help File vs Help Strings

- **Help Strings**: Best for simple, contextual help
- **HTML Help Files**: Best for comprehensive documentation with multiple topics

```csharp
// Simple help - use strings
helpProvider.HelpNamespace = string.Empty;
helpProvider.SetHelpString(control, "Simple help text");

// Complex help - use HTML file
helpProvider.HelpNamespace = @"C:\Help\MyApp.chm";
helpProvider.SetHelpKeyword(control, "topic_id");
```

---

## Troubleshooting

### Tooltips Not Showing

**Problem**: Tooltips don't appear when hovering over controls.

**Solutions**:
1. Check that `ContainerControl` is set:
   ```csharp
   if (helpProvider.ContainerControl == null)
   {
       helpProvider.ContainerControl = this;
   }
   ```

2. Verify tooltips are enabled:
   ```csharp
   if (!helpProvider.ToolTipValues.EnableToolTips)
   {
       helpProvider.ToolTipValues.EnableToolTips = true;
   }
   ```

3. Ensure help is enabled for the control:
   ```csharp
   if (!helpProvider.GetShowHelp(control))
   {
       helpProvider.SetShowHelp(control, true);
   }
   ```

4. Verify help string is set:
   ```csharp
   string? helpString = helpProvider.GetHelpString(control);
   if (string.IsNullOrEmpty(helpString))
   {
       helpProvider.SetHelpString(control, "Help text here");
   }
   ```

### Tooltips Show Wrong Theme

**Problem**: Tooltips don't match the application theme.

**Solution**: Ensure `PaletteMode` matches your form's palette:

```csharp
// Match form's palette mode
helpProvider.PaletteMode = kryptonManager1.GlobalPaletteMode;
```

### F1 Help Not Working

**Problem**: Pressing F1 doesn't show help.

**Solutions**:
1. Ensure help is enabled for the control:
   ```csharp
   helpProvider.SetShowHelp(control, true);
   ```

2. Set a help string or keyword:
   ```csharp
   helpProvider.SetHelpString(control, "Help text");
   // OR for HTML help:
   helpProvider.SetHelpKeyword(control, "topic_id");
   ```

3. Check if `HelpRequested` event is handling it:
   ```csharp
   // If e.Handled = true, default behavior is prevented
   helpProvider.HelpRequested += (sender, e) =>
   {
       // Your custom logic
       // e.Handled = true; // Remove this if you want default behavior
   };
   ```

### HTML Help File Not Opening

**Problem**: HTML help file doesn't open when F1 is pressed.

**Solutions**:
1. Verify file path is correct:
   ```csharp
   if (File.Exists(helpProvider.HelpNamespace))
   {
       // File exists
   }
   ```

2. Ensure `HelpNamespace` is set:
   ```csharp
   helpProvider.HelpNamespace = @"C:\Help\MyApp.chm";
   ```

3. Check help keyword is set (if using Topic navigation):
   ```csharp
   helpProvider.SetHelpKeyword(control, "valid_topic_id");
   helpProvider.SetHelpNavigator(control, HelpNavigator.Topic);
   ```

### Performance Issues

**Problem**: Application feels sluggish when tooltips are enabled.

**Solutions**:
1. Increase `ShowIntervalDelay` to reduce tooltip frequency:
   ```csharp
   helpProvider.ToolTipValues.ShowIntervalDelay = 1000; // Wait 1 second
   ```

2. Disable tooltips for controls that don't need them:
   ```csharp
   helpProvider.SetShowHelp(control, false);
   ```

3. Only set `ContainerControl` when needed:
   ```csharp
   // Don't set if tooltips aren't needed
   if (enableTooltips)
   {
       helpProvider.ContainerControl = this;
   }
   ```

---

## Advanced Topics

### Custom Tooltip Content

While `KryptonHelpProvider` uses help strings for tooltips, you can extend functionality by handling the `HelpRequested` event and creating custom tooltip content:

```csharp
helpProvider.HelpRequested += (sender, e) =>
{
    Control? control = ActiveControl;
    if (control != null)
    {
        // Create custom tooltip with additional information
        var customTooltip = new VisualPopupToolTip(
            redirector,
            customContent, // Your custom IContentValues
            renderer,
            PaletteBackStyle.ControlToolTip,
            PaletteBorderStyle.ControlToolTip,
            contentStyle,
            true);
        
        customTooltip.ShowCalculatingSize(control.PointToScreen(Point.Empty));
        e.Handled = true;
    }
};
```

### Multiple Help Providers

You can use multiple `KryptonHelpProvider` instances for different purposes:

```csharp
// Quick help provider (tooltips only)
var quickHelp = new KryptonHelpProvider();
quickHelp.ContainerControl = this;
quickHelp.ToolTipValues.EnableToolTips = true;
quickHelp.SetHelpString(control, "Quick tip");

// Detailed help provider (HTML help)
var detailedHelp = new KryptonHelpProvider();
detailedHelp.HelpNamespace = @"C:\Help\Detailed.chm";
detailedHelp.SetHelpKeyword(control, "detailed_topic");
```

### Integration with Validation

Combine with `KryptonErrorProvider` for comprehensive user assistance:

```csharp
private KryptonHelpProvider helpProvider;
private KryptonErrorProvider errorProvider;

private void InitializeProviders()
{
    helpProvider = new KryptonHelpProvider();
    helpProvider.ContainerControl = this;
    helpProvider.ToolTipValues.EnableToolTips = true;
    
    errorProvider = new KryptonErrorProvider();
    errorProvider.ContainerControl = this;
    
    // Set help for validation
    helpProvider.SetShowHelp(textBoxEmail, true);
    helpProvider.SetHelpString(textBoxEmail, 
        "Enter a valid email address. Example: user@example.com");
}

private void ValidateEmail()
{
    if (!IsValidEmail(textBoxEmail.Text))
    {
        errorProvider.SetError(textBoxEmail, "Invalid email format");
        // Help string provides guidance, error provides feedback
    }
    else
    {
        errorProvider.SetError(textBoxEmail, string.Empty);
    }
}
```

---

## Summary

`KryptonHelpProvider` provides a powerful, theme-aware help system for your Krypton applications. Key takeaways:

- **Easy to use**: Simple API for setting help strings
- **Theme integration**: Tooltips match your application's Krypton theme
- **Flexible**: Supports both simple help strings and HTML help files
- **User-friendly**: Tooltips provide immediate help on hover
- **Customizable**: Full control over appearance and behavior

For more information, see the [Krypton Toolkit Online Help](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/).

---

## Related Components

- `KryptonErrorProvider` - Provides error indication with styled tooltips
- `KryptonToolTip` - Standalone tooltip component
- `KryptonMessageBox` - For displaying help dialogs

---

**Version**: 1.0  
**Last Updated**: 2026  
**Krypton Toolkit Version**: 100.00+

