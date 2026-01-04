# Krypton Bug Reporting Dialog - API Reference

## Namespace

```
Krypton.Utilities
```

## Classes

### KryptonBugReportingDialog

Static class providing the main API for displaying bug reporting dialogs.

**Assembly:** `Krypton.Utilities.dll`

#### Methods

##### Show(Exception?, BugReportEmailConfig)

```csharp
public static DialogResult Show(Exception? exception, BugReportEmailConfig emailConfig)
```

Displays the bug reporting dialog with an optional exception.

**Parameters:**
- `exception` (`Exception?`): Optional exception to include in the bug report
- `emailConfig` (`BugReportEmailConfig`): Email configuration (required, cannot be null)

**Returns:** `DialogResult.OK` if sent successfully; `DialogResult.Cancel` otherwise

**Exceptions:**
- `ArgumentNullException`: Thrown when `emailConfig` is null

**Remarks:**
If an exception is provided, its details will be pre-populated in the bug description field.

---

##### Show(BugReportEmailConfig)

```csharp
public static DialogResult Show(BugReportEmailConfig emailConfig)
```

Displays the bug reporting dialog without an exception.

**Parameters:**
- `emailConfig` (`BugReportEmailConfig`): Email configuration (required, cannot be null)

**Returns:** `DialogResult.OK` if sent successfully; `DialogResult.Cancel` otherwise

**Exceptions:**
- `ArgumentNullException`: Thrown when `emailConfig` is null

---

### BugReportEmailConfig

Configuration class for SMTP email settings.

**Assembly:** `Krypton.Utilities.dll`

#### Constructor

##### BugReportEmailConfig()

```csharp
public BugReportEmailConfig()
```

Initializes a new instance with default values:
- `SmtpPort`: 587
- `UseSsl`: true
- All string properties: `string.Empty`

#### Properties

##### SmtpServer

```csharp
public string SmtpServer { get; set; }
```

Gets or sets the SMTP server address.

**Type:** `string`

**Default:** `string.Empty`

**Remarks:**
Example: "smtp.gmail.com", "smtp-mail.outlook.com"

---

##### SmtpPort

```csharp
public int SmtpPort { get; set; }
```

Gets or sets the SMTP server port.

**Type:** `int`

**Default:** `587`

**Remarks:**
Common ports: 25 (standard), 465 (SSL), 587 (TLS)

---

##### UseSsl

```csharp
public bool UseSsl { get; set; }
```

Gets or sets a value indicating whether to use SSL/TLS encryption.

**Type:** `bool`

**Default:** `true`

**Remarks:**
Set to `true` for ports 465 and 587. Set to `false` for port 25 (if supported).

---

##### FromEmail

```csharp
public string FromEmail { get; set; }
```

Gets or sets the sender email address.

**Type:** `string`

**Default:** `string.Empty`

**Remarks:**
This will appear as the "From" address in the email.

---

##### ToEmail

```csharp
public string ToEmail { get; set; }
```

Gets or sets the recipient email address where bug reports are sent.

**Type:** `string`

**Default:** `string.Empty`

**Remarks:**
This is the email address that will receive bug reports.

---

##### Username

```csharp
public string Username { get; set; }
```

Gets or sets the SMTP username for authentication.

**Type:** `string`

**Default:** `string.Empty`

**Remarks:**
Required if the SMTP server requires authentication. Often the same as `FromEmail`.

---

##### Password

```csharp
public string Password { get; set; }
```

Gets or sets the SMTP password for authentication.

**Type:** `string`

**Default:** `string.Empty`

**Remarks:**
Required if the SMTP server requires authentication. For Gmail, use an App Password.

---

##### RequiresAuthentication

```csharp
public bool RequiresAuthentication { get; }
```

Gets a value indicating whether SMTP authentication is required.

**Type:** `bool` (read-only)

**Returns:** `true` if `Username` is not null or empty; otherwise, `false`

**Remarks:**
This is a computed property based on whether `Username` is set.

---

### BugReportEmailService

Service class for sending bug report emails.

**Assembly:** `Krypton.Utilities.dll`

#### Constructor

##### BugReportEmailService()

```csharp
public BugReportEmailService()
```

Initializes a new instance of the `BugReportEmailService` class.

#### Methods

##### SendBugReport(BugReportEmailConfig, string, string, List<string>?)

```csharp
public bool SendBugReport(
    BugReportEmailConfig config, 
    string subject, 
    string body, 
    List<string>? attachments = null)
```

Sends a bug report email.

**Parameters:**
- `config` (`BugReportEmailConfig`): Email configuration (required, cannot be null)
- `subject` (`string`): Email subject line
- `body` (`string`): Email body content
- `attachments` (`List<string>?`): Optional list of file paths to attach

**Returns:** `true` if the email was sent successfully; otherwise, `false`

**Exceptions:**
- `ArgumentNullException`: Thrown when `config` is null
- `InvalidOperationException`: Thrown when `SmtpServer` or `ToEmail` is not configured

**Remarks:**
- Only existing files will be attached (non-existent paths are skipped)
- Email body is sent as plain text (not HTML)
- All exceptions during sending are caught and return `false`

---

### BugReportingHelper

Helper class for integrating bug reporting with exception dialogs.

**Assembly:** `Krypton.Utilities.dll`

#### Methods

##### ShowExceptionWithBugReporting(Exception, BugReportEmailConfig, Color?, bool?, bool?)

```csharp
public static void ShowExceptionWithBugReporting(
    Exception exception, 
    BugReportEmailConfig emailConfig, 
    Color? highlightColor = null, 
    bool? showCopyButton = null, 
    bool? showSearchBox = null)
```

Shows an exception dialog with integrated bug reporting capability.

**Parameters:**
- `exception` (`Exception`): The exception to display (required)
- `emailConfig` (`BugReportEmailConfig`): Email configuration for bug reporting (required)
- `highlightColor` (`Color?`): Optional highlight color for the exception dialog
- `showCopyButton` (`bool?`): Optional flag to show the copy button in exception dialog
- `showSearchBox` (`bool?`): Optional flag to show the search box in exception dialog

**Remarks:**
This method displays `KryptonExceptionDialog` with a "Report Bug" button. When clicked, it opens `KryptonBugReportingDialog` with the exception pre-populated.

---

### KryptonBugReportingDialogStrings

Localizable string resources for the bug reporting dialog.

**Assembly:** `Krypton.Utilities.dll`

#### Constructor

##### KryptonBugReportingDialogStrings()

```csharp
public KryptonBugReportingDialogStrings()
```

Initializes a new instance with default English strings.

#### Properties

All properties are of type `string` and are localizable:

- `WindowTitle`: Dialog window title
- `EmailAddress`: Email address label text
- `BugDescription`: Bug description label text
- `StepsToReproduce`: Steps to reproduce label text
- `Attachments`: Attachments label text
- `AddScreenshot`: Add screenshot button text
- `AddFile`: Add file button text
- `Remove`: Remove button text
- `Send`: Send button text
- `Cancel`: Cancel button text
- `Sending`: Sending status text
- `SuccessTitle`: Success dialog title
- `SuccessMessage`: Success dialog message
- `ErrorTitle`: Error dialog title
- `ErrorMessage`: Error dialog message
- `InvalidEmail`: Invalid email error message
- `RequiredFields`: Required fields error message

#### Methods

##### Reset()

```csharp
public void Reset()
```

Resets all string properties to their default values.

##### IsDefault

```csharp
public bool IsDefault { get; }
```

Gets a value indicating if all strings are at their default values.

**Type:** `bool` (read-only)

---

## Integration with KryptonExceptionDialog

### Extended Method Signature

The `KryptonExceptionDialog.Show()` method has been extended with an optional callback parameter:

```csharp
public static void Show(
    Exception exception, 
    Color? highlightColor, 
    bool? showCopyButton, 
    bool? showSearchBox, 
    Action<Exception>? bugReportCallback)
```

**Parameters:**
- `bugReportCallback` (`Action<Exception>?`): Optional callback invoked when "Report Bug" button is clicked

**Remarks:**
When `bugReportCallback` is provided, a "Report Bug" button appears in the exception dialog. Clicking it invokes the callback with the exception as a parameter.

---

## Type Aliases

For convenience, the following types are used:

- `DialogResult`: `System.Windows.Forms.DialogResult`
- `Exception`: `System.Exception`
- `Color`: `System.Drawing.Color`
- `List<T>`: `System.Collections.Generic.List<T>`

---

## Dependencies

### Required Assemblies

- `Krypton.Toolkit.dll`
- `System.Windows.Forms.dll`
- `System.Drawing.dll`
- `System.Net.dll`

### Required Namespaces

- `System`
- `System.Collections.Generic`
- `System.Drawing`
- `System.IO`
- `System.Net`
- `System.Net.Mail`
- `System.Windows.Forms`
- `Krypton.Toolkit`

---

## Thread Safety

- **KryptonBugReportingDialog**: Thread-safe (static methods)
- **BugReportEmailConfig**: Not thread-safe (instance class)
- **BugReportEmailService**: Not thread-safe (instance class, but can be used from multiple threads if instances are not shared)
- **BugReportingHelper**: Thread-safe (static methods)

**Note:** UI operations (dialog display) must be performed on the UI thread.

---

## See Also

- [Full Documentation](BugReportingDialog.md)
- [Quick Reference](BugReportingDialog-QuickReference.md)
- [KryptonExceptionDialog API](../API/KryptonExceptionDialog.md)

