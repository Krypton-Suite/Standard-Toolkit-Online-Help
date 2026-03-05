# KryptonMessageBoxExtended

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [API Reference](#api-reference)
4. [Enumerations](#enumerations)
5. [Usage Examples](#usage-examples)
6. [Advanced Features](#advanced-features)
7. [Best Practices](#best-practices)
8. [Technical Details](#technical-details)

---

## Overview

`KryptonMessageBoxExtended` is a comprehensive, feature-rich message box implementation that extends the standard Windows Forms `MessageBox` functionality. It provides a modern, customizable UI with extensive configuration options for displaying messages, buttons, icons, and interactive elements.

### Key Characteristics

- **Static Class**: All methods are static, accessed directly via `KryptonMessageBoxExtended.Show()`
- **Modal Dialogs**: All message boxes are displayed modally
- **Krypton Theming**: Fully integrated with Krypton Suite theming system
- **RTL Support**: Automatic support for Right-to-Left languages
- **Extensible**: Supports custom buttons, icons, colors, fonts, and more

---

## Features

### Core Features

- **Multiple Button Configurations**: Standard button sets (OK, OKCancel, YesNo, etc.) plus custom button configurations
- **Rich Icon Support**: System icons, custom icons, application icons, UAC shield, Windows logo
- **Text Alignment**: Flexible text alignment options for both message text and text boxes
- **Timeout Support**: Automatic dialog closure with configurable timeout intervals
- **Help Integration**: Built-in help button support with custom help file navigation
- **Link Support**: Embedded hyperlinks with clickable areas and custom launch actions
- **Footer Support**: Expandable/collapsible footer with text, checkbox, or rich text box content
- **Copy to Clipboard**: Built-in Ctrl+C support for copying message content
- **Custom Styling**: Custom fonts, colors, button text, and dialog results

### Advanced Features

- **Message Container Types**: Normal text, RichTextBox, or HyperLink containers
- **Custom Button Text**: Override default button labels with custom text
- **Custom Dialog Results**: Map buttons to custom `DialogResult` values
- **Color Customization**: Custom message text colors and button text colors
- **Application Path Integration**: Display application icons using file paths
- **Windows Explorer Integration**: Launch file explorer and select files
- **Process Launch**: Execute external processes via `ProcessStartInfo`
- **Owner Window Support**: Specify parent window for proper modal behavior
- **MessageBoxOptions**: Support for RTL reading, right alignment, and service notifications

---

## API Reference

### Public Methods

All public methods return `DialogResult` indicating which button was clicked.

#### Basic Show Methods

##### `Show(string message, string caption, ExtendedMessageBoxButtons buttons, ExtendedKryptonMessageBoxIcon icon, bool? showCtrlCopy = null)`

**Description**: Displays a basic message box with minimal configuration.

**Parameters**:
- `message` (string): The message text to display
- `caption` (string): The window title/caption
- `buttons` (ExtendedMessageBoxButtons): Button configuration
- `icon` (ExtendedKryptonMessageBoxIcon): Icon to display
- `showCtrlCopy` (bool?, optional): Enable Ctrl+C copy functionality

**Returns**: `DialogResult` - The button clicked by the user

**Example**:
```csharp
var result = KryptonMessageBoxExtended.Show(
    "Operation completed successfully!",
    "Success",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information
);
```

---

##### `Show(string messageText, string caption, ExtendedMessageBoxButtons buttons, ExtendedKryptonMessageBoxIcon icon, bool? showCtrlCopy = null, ContentAlignment? messageTextAlignment = null, HorizontalAlignment? messageTextBoxAlignment = null, bool? useTimeOut = false, int? timeOut = 60, int? timeOutInterval = 1000, DialogResult? timerResult = DialogResult.None)`

**Description**: Displays a message box with text alignment and timeout support.

**Additional Parameters**:
- `messageTextAlignment` (ContentAlignment?, optional): Alignment for message text (TopLeft, TopCenter, TopRight, MiddleLeft, MiddleCenter, MiddleRight, BottomLeft, BottomCenter, BottomRight)
- `messageTextBoxAlignment` (HorizontalAlignment?, optional): Horizontal alignment for text box (Left, Center, Right)
- `useTimeOut` (bool?, optional): Enable automatic timeout (default: false)
- `timeOut` (int?, optional): Timeout duration in seconds (default: 60)
- `timeOutInterval` (int?, optional): Timer interval in milliseconds (default: 1000)
- `timerResult` (DialogResult?, optional): Result to return when timeout occurs (default: None)

**Example**:
```csharp
var result = KryptonMessageBoxExtended.Show(
    "This message will auto-close in 10 seconds",
    "Timeout Example",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Warning,
    showCtrlCopy: true,
    messageTextAlignment: ContentAlignment.MiddleCenter,
    useTimeOut: true,
    timeOut: 10,
    timerResult: DialogResult.OK
);
```

---

##### `Show(string messageText, string caption, ExtendedMessageBoxButtons buttons, ExtendedKryptonMessageBoxIcon icon, bool? showCtrlCopy = null, string? applicationPath = null, ExtendedKryptonMessageBoxMessageContainerType? messageContainerType = ExtendedKryptonMessageBoxMessageContainerType.Normal, KryptonCommand? linkLabelCommand = null, LinkArea? contentLinkArea = null, ProcessStartInfo? linkLaunchArgument = null, bool? openInExplorer = null, ContentAlignment? messageTextAlignment = null, PaletteRelativeAlign? richTextBoxTextAlignment = null, HorizontalAlignment? messageTextBoxAlignment = null, bool? useTimeOut = false, int? timeOut = 60, int? timeOutInterval = 1000, DialogResult? timerResult = DialogResult.None)`

**Description**: Displays a message box with link support and message container options.

**Additional Parameters**:
- `applicationPath` (string?, optional): Path to application executable (for Application icon type)
- `messageContainerType` (ExtendedKryptonMessageBoxMessageContainerType?, optional): Container type (Normal, RichTextBox, HyperLink)
- `linkLabelCommand` (KryptonCommand?, optional): Command to execute when link is clicked
- `contentLinkArea` (LinkArea?, optional): Area within text that acts as a clickable link
- `linkLaunchArgument` (ProcessStartInfo?, optional): Process to launch when link is clicked
- `openInExplorer` (bool?, optional): Launch Windows Explorer and select file when link clicked
- `richTextBoxTextAlignment` (PaletteRelativeAlign?, optional): Alignment for RichTextBox content

**Example**:
```csharp
var linkArea = new LinkArea(10, 20); // Characters 10-30 are clickable
var result = KryptonMessageBoxExtended.Show(
    "Visit our website at www.example.com for more information",
    "Information",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    messageContainerType: ExtendedKryptonMessageBoxMessageContainerType.HyperLink,
    contentLinkArea: linkArea,
    linkLaunchArgument: new ProcessStartInfo("https://www.example.com")
);
```

---

#### Advanced Show Methods

##### `Show(string messageText, string caption = "", ExtendedMessageBoxButtons buttons = ExtendedMessageBoxButtons.OK, ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None, KryptonMessageBoxDefaultButton defaultButton = KryptonMessageBoxDefaultButton.Button1, MessageBoxOptions options = 0, bool displayHelpButton = false, bool? showCtrlCopy = null, Font? messageBoxTypeface = null, Image? customImageIcon = null, string? applicationPath = null, ExtendedKryptonMessageBoxMessageContainerType? messageContainerType = ExtendedKryptonMessageBoxMessageContainerType.Normal, KryptonCommand? linkLabelCommand = null, LinkArea? contentLinkArea = null, ProcessStartInfo? linkLaunchArgument = null, bool? openInExplorer = null, ContentAlignment? messageTextAlignment = ContentAlignment.MiddleLeft, PaletteRelativeAlign? richTextBoxTextAlignment = null, HorizontalAlignment? messageTextBoxAlignment = null, bool? useTimeOut = false, int? timeOut = 60, int? timeOutInterval = 1000, DialogResult? timerResult = DialogResult.None)`

**Description**: Full-featured overload with all customization options.

**Additional Parameters**:
- `defaultButton` (KryptonMessageBoxDefaultButton): Which button is the default (Button1, Button2, Button3, Button4)
- `options` (MessageBoxOptions): Display options (RightAlign, RtlReading, ServiceNotification, DefaultDesktopOnly)
- `displayHelpButton` (bool): Show help button
- `messageBoxTypeface` (Font?, optional): Custom font for message text
- `customImageIcon` (Image?, optional): Custom icon image

**Example**:
```csharp
var customFont = new Font("Segoe UI", 12, FontStyle.Bold);
var customIcon = Image.FromFile("custom-icon.png");

var result = KryptonMessageBoxExtended.Show(
    "This is a fully customized message box",
    "Custom Dialog",
    ExtendedMessageBoxButtons.YesNoCancel,
    ExtendedKryptonMessageBoxIcon.Custom,
    defaultButton: KryptonMessageBoxDefaultButton.Button2,
    displayHelpButton: true,
    messageBoxTypeface: customFont,
    customImageIcon: customIcon,
    messageTextAlignment: ContentAlignment.TopCenter
);
```

---

##### `Show(IWin32Window owner, ...)` Overloads

**Description**: All Show methods have owner window variants that accept an `IWin32Window` parameter as the first argument.

**Parameters**:
- `owner` (IWin32Window): Parent window for modal dialog

**Example**:
```csharp
var result = KryptonMessageBoxExtended.Show(
    this, // Owner window
    "This dialog is owned by the parent form",
    "Owned Dialog",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information
);
```

---

#### Help-Enabled Show Methods

##### `Show(string messageText, string caption = "", ExtendedMessageBoxButtons buttons = ExtendedMessageBoxButtons.OK, ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None, KryptonMessageBoxDefaultButton defaultButton = KryptonMessageBoxDefaultButton.Button1, MessageBoxOptions options = 0, string helpFilePath = "", HelpNavigator navigator = 0, object? param = null, ...)`

**Description**: Message box with integrated help system support.

**Additional Parameters**:
- `helpFilePath` (string): Path to help file (.chm)
- `navigator` (HelpNavigator): Help navigation type (Topic, TableOfContents, Index, Find, etc.)
- `param` (object?, optional): Additional parameter for help navigation

**Example**:
```csharp
var result = KryptonMessageBoxExtended.Show(
    "Click Help for more information",
    "Help Example",
    ExtendedMessageBoxButtons.OKCancel,
    ExtendedKryptonMessageBoxIcon.Question,
    helpFilePath: "help.chm",
    navigator: HelpNavigator.Topic,
    param: "topic-id-123"
);
```

---

#### Fully Customized Show Method

##### `Show(IWin32Window owner, string messageText, string caption = "", ExtendedMessageBoxButtons buttons = ExtendedMessageBoxButtons.OK, ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None, KryptonMessageBoxDefaultButton defaultButton = KryptonMessageBoxDefaultButton.Button1, MessageBoxOptions options = 0, string helpFilePath = "", HelpNavigator navigator = 0, object? param = null, bool displayHelpButton = false, bool? showCtrlCopy = null, Font? messageBoxTypeface = null, Image? customImageIcon = null, bool? showHelpButton = null, Color? messageTextColor = null, Color[]? buttonTextColors = null, DialogResult? buttonOneCustomDialogResult = null, DialogResult? buttonTwoCustomDialogResult = null, DialogResult? buttonThreeCustomDialogResult = null, DialogResult? buttonFourDialogResult = null, string? buttonOneCustomText = null, string? buttonTwoCustomText = null, string? buttonThreeCustomText = null, string? buttonFourCustomText = null, string? applicationPath = null, ExtendedKryptonMessageBoxMessageContainerType? messageContainerType = ExtendedKryptonMessageBoxMessageContainerType.Normal, KryptonCommand? linkLabelCommand = null, LinkArea? contentLinkArea = null, ProcessStartInfo? linkLaunchArgument = null, bool? openInExplorer = null, ContentAlignment? messageTextAlignment = null, PaletteRelativeAlign? richTextBoxTextAlignment = null, HorizontalAlignment? messageTextBoxAlignment = null, bool? useTimeOut = false, int? timeOut = 60, int? timeOutInterval = 1000, DialogResult? timerResult = DialogResult.None)`

**Description**: Maximum customization overload with custom button text, colors, and dialog results.

**Additional Parameters**:
- `messageTextColor` (Color?, optional): Custom color for message text
- `buttonTextColors` (Color[]?, optional): Array of colors for button text (up to 4 buttons)
- `buttonOneCustomDialogResult` through `buttonFourDialogResult` (DialogResult?, optional): Custom dialog results for each button
- `buttonOneCustomText` through `buttonFourCustomText` (string?, optional): Custom text for each button

**Example**:
```csharp
var result = KryptonMessageBoxExtended.Show(
    this,
    "Customize everything!",
    "Maximum Customization",
    ExtendedMessageBoxButtons.Custom,
    ExtendedKryptonMessageBoxIcon.Custom,
    messageTextColor: Color.DarkBlue,
    buttonTextColors: new[] { Color.Green, Color.Red, Color.Orange },
    buttonOneCustomText: "Save",
    buttonOneCustomDialogResult: DialogResult.Yes,
    buttonTwoCustomText: "Discard",
    buttonTwoCustomDialogResult: DialogResult.No,
    buttonThreeCustomText: "Cancel",
    buttonThreeCustomDialogResult: DialogResult.Cancel
);
```

---

#### Footer-Enabled Show Methods

##### `Show(string messageText, string caption = "", ExtendedMessageBoxButtons buttons = ExtendedMessageBoxButtons.OK, ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None, string? footerText = null, bool footerExpanded = false, ExtendedKryptonMessageBoxFooterContentType footerContentType = ExtendedKryptonMessageBoxFooterContentType.Text, int? footerRichTextBoxHeight = null, bool? showCtrlCopy = null, Font? messageBoxTypeface = null)`

**Description**: Message box with expandable/collapsible footer section.

**Parameters**:
- `footerText` (string?, optional): Text to display in footer
- `footerExpanded` (bool): Whether footer starts expanded (default: false)
- `footerContentType` (ExtendedKryptonMessageBoxFooterContentType): Footer content type (Text, CheckBox, RichTextBox)
- `footerRichTextBoxHeight` (int?, optional): Height for RichTextBox footer (when footerContentType is RichTextBox)

**Example**:
```csharp
var result = KryptonMessageBoxExtended.Show(
    "Main message text here",
    "Footer Example",
    ExtendedMessageBoxButtons.OKCancel,
    ExtendedKryptonMessageBoxIcon.Information,
    footerText: "Additional details can be shown in the expandable footer",
    footerExpanded: true,
    footerContentType: ExtendedKryptonMessageBoxFooterContentType.Text
);
```

---

## Enumerations

### ExtendedMessageBoxButtons

Specifies the button configuration for the message box.

**Values**:
- `OK` - Single OK button
- `OKCancel` - OK and Cancel buttons
- `AbortRetryIgnore` - Abort, Retry, and Ignore buttons
- `YesNoCancel` - Yes, No, and Cancel buttons
- `YesNo` - Yes and No buttons
- `RetryCancel` - Retry and Cancel buttons
- `Custom` - Custom button configuration (requires custom button parameters)

---

### ExtendedKryptonMessageBoxIcon

Specifies the icon to display in the message box.

**Values**:
- `Custom` - Use custom icon image
- `None` - No icon
- `Hand` - Hand icon (error/stop)
- `SystemHand` - System hand icon
- `Question` - Question mark icon
- `SystemQuestion` - System question icon
- `Exclamation` - Exclamation icon (warning)
- `SystemExclamation` - System exclamation icon
- `Asterisk` - Asterisk icon (information)
- `SystemAsterisk` - System asterisk icon
- `Shield` - UAC shield icon
- `WindowsLogo` - Windows logo icon
- `Application` - Application icon (requires `applicationPath` parameter)
- `SystemApplication` - System application icon

---

### ExtendedKryptonMessageBoxMessageContainerType

Specifies the type of container for the message text.

**Values**:
- `Normal` - Standard text label (default)
- `RichTextBox` - Rich text box with formatting support
- `HyperLink` - Link label with clickable areas

---

### ExtendedKryptonMessageBoxFooterContentType

Specifies the content type for the footer section.

**Values**:
- `Text` - Plain text using KryptonWrapLabel (default)
- `CheckBox` - Checkbox control
- `RichTextBox` - Rich text box with formatting

---

### KryptonMessageBoxDefaultButton

Specifies which button is the default (receives focus and responds to Enter key).

**Values**:
- `Button1` - First button (default)
- `Button2` - Second button
- `Button3` - Third button
- `Button4` - Fourth button

---

## Usage Examples

### Basic Usage

```csharp
// Simple information message
var result = KryptonMessageBoxExtended.Show(
    "Operation completed successfully!",
    "Success",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information
);

if (result == DialogResult.OK)
{
    // Handle OK click
}
```

---

### Confirmation Dialog

```csharp
var result = KryptonMessageBoxExtended.Show(
    "Are you sure you want to delete this item?",
    "Confirm Delete",
    ExtendedMessageBoxButtons.YesNo,
    ExtendedKryptonMessageBoxIcon.Question,
    defaultButton: KryptonMessageBoxDefaultButton.Button2 // No button is default
);

if (result == DialogResult.Yes)
{
    // Delete item
}
```

---

### Error Message with Custom Colors

```csharp
var result = KryptonMessageBoxExtended.Show(
    this,
    "An error occurred while processing your request.",
    "Error",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Error,
    messageTextColor: Color.Red,
    buttonTextColors: new[] { Color.White }
);
```

---

### Message with Timeout

```csharp
var result = KryptonMessageBoxExtended.Show(
    "This message will automatically close in 5 seconds",
    "Auto-Close",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Warning,
    useTimeOut: true,
    timeOut: 5,
    timerResult: DialogResult.OK
);
```

---

### Message with Hyperlink

```csharp
var linkArea = new LinkArea(25, 11); // "example.com" is clickable
var processInfo = new ProcessStartInfo
{
    FileName = "https://www.example.com",
    UseShellExecute = true
};

var result = KryptonMessageBoxExtended.Show(
    "Visit our website at www.example.com for support",
    "Support",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    messageContainerType: ExtendedKryptonMessageBoxMessageContainerType.HyperLink,
    contentLinkArea: linkArea,
    linkLaunchArgument: processInfo
);
```

---

### Message with Footer

```csharp
var result = KryptonMessageBoxExtended.Show(
    "Your changes have been saved successfully.",
    "Save Complete",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    footerText: "File saved to: C:\\Documents\\MyFile.txt\nTimestamp: " + DateTime.Now,
    footerExpanded: false,
    footerContentType: ExtendedKryptonMessageBoxFooterContentType.Text
);
```

---

### Custom Buttons with Custom Text

```csharp
var result = KryptonMessageBoxExtended.Show(
    this,
    "How would you like to proceed?",
    "Custom Actions",
    ExtendedMessageBoxButtons.Custom,
    ExtendedKryptonMessageBoxIcon.Question,
    buttonOneCustomText: "Save & Close",
    buttonOneCustomDialogResult: DialogResult.Yes,
    buttonTwoCustomText: "Save & Continue",
    buttonTwoCustomDialogResult: DialogResult.Retry,
    buttonThreeCustomText: "Cancel",
    buttonThreeCustomDialogResult: DialogResult.Cancel
);

switch (result)
{
    case DialogResult.Yes:
        // Save and close
        break;
    case DialogResult.Retry:
        // Save and continue
        break;
    case DialogResult.Cancel:
        // Cancel operation
        break;
}
```

---

### RTL Language Support

```csharp
var result = KryptonMessageBoxExtended.Show(
    "مرحبا بك في التطبيق",
    "ترحيب",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    options: MessageBoxOptions.RtlReading
);
```

---

### Application Icon

```csharp
var result = KryptonMessageBoxExtended.Show(
    "This message box displays your application icon",
    "Application Icon",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Application,
    applicationPath: Application.ExecutablePath
);
```

---

## Advanced Features

### Custom Fonts

```csharp
var customFont = new Font("Comic Sans MS", 14, FontStyle.Bold | FontStyle.Italic);

var result = KryptonMessageBoxExtended.Show(
    "This message uses a custom font",
    "Custom Font",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    messageBoxTypeface: customFont
);
```

---

### Rich Text Box Container

```csharp
var result = KryptonMessageBoxExtended.Show(
    "This is <b>bold</b> and this is <i>italic</i> text",
    "Rich Text",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    messageContainerType: ExtendedKryptonMessageBoxMessageContainerType.RichTextBox,
    richTextBoxTextAlignment: PaletteRelativeAlign.Center
);
```

---

### Help Integration

```csharp
var result = KryptonMessageBoxExtended.Show(
    "Click Help for more information about this feature",
    "Help Example",
    ExtendedMessageBoxButtons.OKCancel,
    ExtendedKryptonMessageBoxIcon.Question,
    displayHelpButton: true,
    helpFilePath: "Help.chm",
    navigator: HelpNavigator.Topic,
    param: "feature-overview"
);
```

---

### Windows Explorer Integration

```csharp
var result = KryptonMessageBoxExtended.Show(
    "Click the link to open the file location",
    "File Location",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    messageContainerType: ExtendedKryptonMessageBoxMessageContainerType.HyperLink,
    contentLinkArea: new LinkArea(10, 15),
    linkLaunchArgument: new ProcessStartInfo { FileName = "C:\\MyFolder\\MyFile.txt" },
    openInExplorer: true
);
```

---

## Best Practices

### 1. Always Specify an Owner Window

```csharp
// Good - specifies owner
var result = KryptonMessageBoxExtended.Show(
    this, // Owner window
    "Message",
    "Title",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information
);

// Avoid - no owner (may appear behind other windows)
var result = KryptonMessageBoxExtended.Show(
    "Message",
    "Title",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information
);
```

---

### 2. Use Appropriate Icons

- **Information**: Use `Information` or `Asterisk` for informational messages
- **Warning**: Use `Exclamation` or `Warning` for warnings
- **Error**: Use `Hand` or `Error` for errors
- **Question**: Use `Question` for questions requiring user input

---

### 3. Set Appropriate Default Buttons

```csharp
// For destructive actions, make Cancel the default
var result = KryptonMessageBoxExtended.Show(
    "Delete this item?",
    "Confirm",
    ExtendedMessageBoxButtons.YesNoCancel,
    ExtendedKryptonMessageBoxIcon.Question,
    defaultButton: KryptonMessageBoxDefaultButton.Button3 // Cancel
);
```

---

### 4. Handle All Possible Dialog Results

```csharp
var result = KryptonMessageBoxExtended.Show(
    "Save changes?",
    "Confirm",
    ExtendedMessageBoxButtons.YesNoCancel,
    ExtendedKryptonMessageBoxIcon.Question
);

switch (result)
{
    case DialogResult.Yes:
        SaveChanges();
        break;
    case DialogResult.No:
        DiscardChanges();
        break;
    case DialogResult.Cancel:
        // User cancelled, do nothing
        break;
    default:
        // Handle unexpected result
        break;
}
```

---

### 5. Use Timeout for Non-Critical Messages

```csharp
// Auto-close informational messages
var result = KryptonMessageBoxExtended.Show(
    "Operation completed",
    "Success",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    useTimeOut: true,
    timeOut: 3 // 3 seconds
);
```

---

### 6. Provide Meaningful Captions

```csharp
// Good - descriptive caption
KryptonMessageBoxExtended.Show(
    "File saved successfully",
    "Save Operation", // Clear context
    ...
);

// Avoid - generic caption
KryptonMessageBoxExtended.Show(
    "File saved successfully",
    "Message", // Too generic
    ...
);
```

---

## Technical Details

### Thread Safety

- All `Show` methods are thread-safe and can be called from any thread
- The message box will be displayed on the UI thread automatically
- For service applications, use `MessageBoxOptions.ServiceNotification` or `MessageBoxOptions.DefaultDesktopOnly`

### Modal Behavior

- All message boxes are modal dialogs
- Execution is blocked until the user closes the dialog
- The owner window (if specified) is disabled while the dialog is open

### RTL Support

- Automatic RTL support when `MessageBoxOptions.RtlReading` is specified
- Uses `VisualRTLMessageBoxExtendedForm` internally for RTL layouts
- Supports Hebrew, Arabic, and other RTL languages

### Validation

The `ValidateOptions` method performs several checks:

1. **Non-Interactive Process**: Throws `InvalidOperationException` if trying to show a dialog from a non-interactive process without service notification options
2. **Service Owner Conflict**: Throws `ArgumentException` if owner is specified with service notification options
3. **Service Help Conflict**: Throws `ArgumentException` if help is specified with service notification options

---

## See Also

- `KryptonMessageBox` - Standard Krypton message box (simpler API)
- `KryptonInformationBox` - Information-only message box
- `KryptonTaskDialog` - Task dialog implementation