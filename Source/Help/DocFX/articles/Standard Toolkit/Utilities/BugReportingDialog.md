# Krypton Bug Reporting Dialog

## Overview

The `KryptonBugReportingDialog` is a comprehensive bug reporting tool that extends the `KryptonExceptionDialog` functionality, allowing users to report bugs directly to developers via email. It provides a user-friendly interface for collecting bug information, including exception details, descriptions, reproduction steps, and attachments (screenshots and files).

## Features

- **Configurable Email Integration**: Full SMTP support with configurable server settings
- **Exception Details Collection**: Automatically captures and includes exception information
- **User Input Fields**: 
  - Email address (with validation)
  - Bug description (pre-populated with exception details when available)
  - Steps to reproduce
- **Attachment Support**:
  - Screenshot capture functionality
  - File attachment support (multiple files)
  - **Thumbnail Display**: Visual thumbnails for screenshots and videos (128x128 pixels)
  - Support for image files (JPG, PNG, GIF, BMP, TIFF, ICO, WEBP)
  - Support for video files (MP4, AVI, MOV, WMV, FLV, MKV, WEBM, M4V, 3GP)
  - File icons displayed for other file types
- **Integration with Exception Dialog**: Seamless integration with `KryptonExceptionDialog` via callback pattern
- **Localizable Strings**: All UI strings can be customized through `KryptonBugReportingDialogStrings`
- **Success/Error Handling**: User-friendly acknowledgment dialogs

## Namespace

All bug reporting components are located in the `Krypton.Utilities` namespace:

```csharp
using Krypton.Utilities;
```

## API Reference

### KryptonBugReportingDialog

The main public API class for displaying the bug reporting dialog.

#### Methods

##### `Show(Exception? exception, BugReportEmailConfig emailConfig)`

Displays the bug reporting dialog with an optional exception.

**Parameters:**
- `exception` (`Exception?`): Optional exception to include in the bug report. If provided, exception details will be pre-populated in the bug description field.
- `emailConfig` (`BugReportEmailConfig`): Required email configuration for sending the bug report.

**Returns:** `DialogResult.OK` if the bug report was sent successfully; otherwise, `DialogResult.Cancel`.

**Throws:** `ArgumentNullException` if `emailConfig` is null.

**Example:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.example.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "app@example.com",
    ToEmail = "bugs@example.com"
};

var result = KryptonBugReportingDialog.Show(exception, emailConfig);
if (result == DialogResult.OK)
{
    // Bug report sent successfully
}
```

##### `Show(BugReportEmailConfig emailConfig)`

Displays the bug reporting dialog without an exception.

**Parameters:**
- `emailConfig` (`BugReportEmailConfig`): Required email configuration for sending the bug report.

**Returns:** `DialogResult.OK` if the bug report was sent successfully; otherwise, `DialogResult.Cancel`.

**Example:**
```csharp
var emailConfig = new BugReportEmailConfig { /* ... */ };
KryptonBugReportingDialog.Show(emailConfig);
```

### BugReportEmailConfig

Configuration class for SMTP email settings.

#### Properties

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `SmtpServer` | `string` | SMTP server address (e.g., "smtp.gmail.com") | `string.Empty` |
| `SmtpPort` | `int` | SMTP server port (commonly 25, 465, or 587) | `587` |
| `UseSsl` | `bool` | Whether to use SSL/TLS encryption | `true` |
| `FromEmail` | `string` | Sender email address | `string.Empty` |
| `ToEmail` | `string` | Recipient email address (where bug reports are sent) | `string.Empty` |
| `Username` | `string` | SMTP username for authentication (optional) | `string.Empty` |
| `Password` | `string` | SMTP password for authentication (optional) | `string.Empty` |
| `RequiresAuthentication` | `bool` | Read-only property indicating if authentication is required (true if Username is set) | Computed |

#### Example Configuration

```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.gmail.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "myapp@gmail.com",
    ToEmail = "bugs@mycompany.com",
    Username = "myapp@gmail.com",
    Password = "your-app-password"
};
```

**Note:** For Gmail and other providers, you may need to use an "App Password" instead of your regular password if two-factor authentication is enabled.

### BugReportEmailService

Service class for sending bug report emails. Typically used internally by the dialog, but can be used directly if needed.

#### Methods

##### `SendBugReport(BugReportEmailConfig config, string subject, string body, List<string>? attachments = null)`

Sends a bug report email.

**Parameters:**
- `config` (`BugReportEmailConfig`): Email configuration
- `subject` (`string`): Email subject line
- `body` (`string`): Email body content
- `attachments` (`List<string>?`): Optional list of file paths to attach

**Returns:** `true` if the email was sent successfully; otherwise, `false`.

**Throws:**
- `ArgumentNullException` if `config` is null
- `InvalidOperationException` if SMTP server or recipient email is not configured

**Example:**
```csharp
var service = new BugReportEmailService();
var success = service.SendBugReport(
    emailConfig,
    "Bug Report - Application Error",
    "Detailed bug description...",
    new List<string> { @"C:\screenshot.png", @"C:\log.txt" }
);
```

### BugReportingHelper

Helper class for integrating bug reporting with exception dialogs.

#### Methods

##### `ShowExceptionWithBugReporting(Exception exception, BugReportEmailConfig emailConfig, Color? highlightColor = null, bool? showCopyButton = null, bool? showSearchBox = null)`

Shows an exception dialog with integrated bug reporting capability.

**Parameters:**
- `exception` (`Exception`): The exception to display
- `emailConfig` (`BugReportEmailConfig`): Email configuration for bug reporting
- `highlightColor` (`Color?`): Optional highlight color for the exception dialog
- `showCopyButton` (`bool?`): Optional flag to show the copy button
- `showSearchBox` (`bool?`): Optional flag to show the search box

**Example:**
```csharp
try
{
    // Your application code
}
catch (Exception ex)
{
    BugReportingHelper.ShowExceptionWithBugReporting(ex, emailConfig);
}
```

### KryptonBugReportingDialogStrings

Localizable string resources for the bug reporting dialog.

#### Properties

All properties are localizable and can be customized:

- `WindowTitle`: Dialog window title (default: "Report Bug")
- `EmailAddress`: Email address label (default: "Email Address:")
- `BugDescription`: Bug description label (default: "Bug Description:")
- `StepsToReproduce`: Steps to reproduce label (default: "Steps to Reproduce:")
- `Attachments`: Attachments label (default: "Attachments:")
- `AddScreenshot`: Add screenshot button text (default: "Add Screenshot")
- `AddFile`: Add file button text (default: "Add File")
- `Remove`: Remove button text (default: "Remove")
- `Send`: Send button text (default: "Send Report")
- `Cancel`: Cancel button text (default: "Cancel")
- `Sending`: Sending status text (default: "Sending...")
- `SuccessTitle`: Success dialog title (default: "Report Sent")
- `SuccessMessage`: Success dialog message (default: "Your bug report has been sent successfully. Thank you for your feedback!")
- `ErrorTitle`: Error dialog title (default: "Error Sending Report")
- `ErrorMessage`: Error dialog message (default: "An error occurred while sending the bug report. Please try again later.")
- `InvalidEmail`: Invalid email error message (default: "Please enter a valid email address.")
- `RequiredFields`: Required fields error message (default: "Please fill in all required fields.")

## Integration with KryptonExceptionDialog

The bug reporting dialog can be integrated with `KryptonExceptionDialog` using a callback pattern.

### Method 1: Using BugReportingHelper (Recommended)

```csharp
try
{
    // Your application code
}
catch (Exception ex)
{
    var emailConfig = LoadEmailConfig(); // Load from config file
    BugReportingHelper.ShowExceptionWithBugReporting(ex, emailConfig);
}
```

### Method 2: Direct Integration

```csharp
try
{
    // Your application code
}
catch (Exception ex)
{
    var emailConfig = new BugReportEmailConfig { /* ... */ };
    
    Krypton.Toolkit.KryptonExceptionDialog.Show(
        ex, 
        highlightColor: null,
        showCopyButton: true,
        showSearchBox: true,
        bugReportCallback: exception => 
        {
            KryptonBugReportingDialog.Show(exception, emailConfig);
        }
    );
}
```

### Method 3: Standalone Bug Reporting

```csharp
// Show bug reporting dialog without an exception
var emailConfig = new BugReportEmailConfig { /* ... */ };
KryptonBugReportingDialog.Show(emailConfig);

// Or with an exception
var exception = new InvalidOperationException("Something went wrong");
KryptonBugReportingDialog.Show(exception, emailConfig);
```

## Email Configuration

### Common SMTP Settings

#### Gmail
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.gmail.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@gmail.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@gmail.com",
    Password = "your-app-password" // Use App Password, not regular password
};
```

#### Outlook/Hotmail
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp-mail.outlook.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@outlook.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@outlook.com",
    Password = "your-password"
};
```

#### Office 365
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.office365.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@yourcompany.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@yourcompany.com",
    Password = "your-password"
};
```

#### Custom SMTP Server
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "mail.yourcompany.com",
    SmtpPort = 25, // or 465 for SSL, 587 for TLS
    UseSsl = false, // Set to true if using SSL/TLS
    FromEmail = "noreply@yourcompany.com",
    ToEmail = "bugs@yourcompany.com"
    // Username and Password only needed if authentication is required
};
```

### Loading Configuration from App.config

```csharp
private static BugReportEmailConfig LoadEmailConfig()
{
    return new BugReportEmailConfig
    {
        SmtpServer = ConfigurationManager.AppSettings["BugReportSmtpServer"] ?? "smtp.example.com",
        SmtpPort = int.Parse(ConfigurationManager.AppSettings["BugReportSmtpPort"] ?? "587"),
        UseSsl = bool.Parse(ConfigurationManager.AppSettings["BugReportUseSsl"] ?? "true"),
        FromEmail = ConfigurationManager.AppSettings["BugReportFromEmail"] ?? string.Empty,
        ToEmail = ConfigurationManager.AppSettings["BugReportToEmail"] ?? string.Empty,
        Username = ConfigurationManager.AppSettings["BugReportUsername"] ?? string.Empty,
        Password = ConfigurationManager.AppSettings["BugReportPassword"] ?? string.Empty
    };
}
```

**App.config example:**
```xml
<appSettings>
  <add key="BugReportSmtpServer" value="smtp.example.com" />
  <add key="BugReportSmtpPort" value="587" />
  <add key="BugReportUseSsl" value="true" />
  <add key="BugReportFromEmail" value="app@example.com" />
  <add key="BugReportToEmail" value="bugs@example.com" />
  <add key="BugReportUsername" value="app@example.com" />
  <add key="BugReportPassword" value="your-password" />
</appSettings>
```

## Usage Examples

### Example 1: Basic Exception Handling with Bug Reporting

```csharp
using Krypton.Utilities;
using Krypton.Toolkit;

public class MyApplication
{
    private static BugReportEmailConfig _emailConfig;

    static MyApplication()
    {
        _emailConfig = new BugReportEmailConfig
        {
            SmtpServer = "smtp.example.com",
            SmtpPort = 587,
            UseSsl = true,
            FromEmail = "app@example.com",
            ToEmail = "bugs@example.com",
            Username = "app@example.com",
            Password = "password"
        };
    }

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);

        Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
        Application.ThreadException += Application_ThreadException;
        AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;

        Application.Run(new MainForm());
    }

    private static void Application_ThreadException(object sender, ThreadExceptionEventArgs e)
    {
        BugReportingHelper.ShowExceptionWithBugReporting(e.Exception, _emailConfig);
    }

    private static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
    {
        if (e.ExceptionObject is Exception ex)
        {
            BugReportingHelper.ShowExceptionWithBugReporting(ex, _emailConfig);
        }
    }
}
```

### Example 2: Try-Catch Block Integration

```csharp
public void ProcessData()
{
    try
    {
        // Your code that might throw an exception
        ProcessFile("data.txt");
    }
    catch (Exception ex)
    {
        // Show exception dialog with bug reporting option
        var emailConfig = GetEmailConfig();
        BugReportingHelper.ShowExceptionWithBugReporting(
            ex, 
            emailConfig,
            highlightColor: Color.Red,
            showCopyButton: true,
            showSearchBox: true
        );
    }
}
```

### Example 3: Manual Bug Report Submission

```csharp
private void ReportBugButton_Click(object sender, EventArgs e)
{
    var emailConfig = new BugReportEmailConfig
    {
        SmtpServer = "smtp.example.com",
        SmtpPort = 587,
        UseSsl = true,
        FromEmail = "app@example.com",
        ToEmail = "bugs@example.com"
    };

    var result = KryptonBugReportingDialog.Show(emailConfig);
    if (result == DialogResult.OK)
    {
        MessageBox.Show("Thank you for reporting the bug!");
    }
}
```

### Example 4: Custom Email Body Formatting

While the dialog automatically formats the email body, you can use `BugReportEmailService` directly for custom formatting:

```csharp
var service = new BugReportEmailService();
var emailConfig = GetEmailConfig();

var subject = $"Bug Report - {Application.ProductName} v{Application.ProductVersion}";
var body = $@"
Application: {Application.ProductName}
Version: {Application.ProductVersion}
Date: {DateTime.Now:yyyy-MM-dd HH:mm:ss}
User: {Environment.UserName}
OS: {Environment.OSVersion}

Bug Description:
{userDescription}

Steps to Reproduce:
{stepsToReproduce}
";

var attachments = new List<string> { screenshotPath, logFilePath };
var success = service.SendBugReport(emailConfig, subject, body, attachments);
```

## Email Body Format

The bug reporting dialog automatically formats the email body as follows:

```
Bug Report
==========

Reported by: user@example.com
Date: 2025-01-15 14:30:00

Bug Description:
----------------
[User-provided description]

Steps to Reproduce:
-------------------
[User-provided steps]

Exception Details:
-----------------
Exception Type: InvalidOperationException
Message: [Exception message]
Stack Trace:
[Full stack trace]

Inner Exception:
[Inner exception details if present]

Attachments:
-----------
screenshot.png
log.txt
```

## Attachment Handling

### Screenshots

The dialog includes a "Add Screenshot" button that captures the entire primary screen. Screenshots are:
- Saved as PNG files in the system temp directory
- Automatically attached to the email
- Automatically cleaned up after the dialog is closed (if sending fails or is cancelled)
- Displayed as thumbnails in the attachments panel

### File Attachments

Users can attach multiple files using the "Add File" button:
- Files are validated to ensure they exist before attachment
- Multiple files can be selected in a single operation
- Files are displayed as thumbnails in a visual grid layout
- Each attachment shows:
  - A 128x128 pixel thumbnail (for images and videos)
  - The filename (truncated if too long)
  - A remove button (×) overlay for easy deletion
- Files can be removed from the list before sending

### Thumbnail Display

The bug reporting dialog displays visual thumbnails for attachments:

**Supported Image Formats:**
- JPG/JPEG, PNG, GIF, BMP, TIFF, ICO, WEBP

**Supported Video Formats:**
- MP4, AVI, MOV, WMV, FLV, MKV, WEBM, M4V, 3GP

**Other File Types:**
- Displays the Windows file icon as a thumbnail

**Thumbnail Features:**
- Thumbnails are automatically generated when files are added
- Thumbnails are cached to improve performance
- Image thumbnails are scaled maintaining aspect ratio
- Video thumbnails show the file icon (actual video frame extraction requires additional COM interfaces)
- Thumbnails are displayed in a scrollable horizontal flow layout
- Each thumbnail panel includes hover effects for better user experience

### Attachment Limitations

- File size limits depend on your SMTP server configuration
- Large attachments may cause email sending to fail or timeout
- Consider compressing large files or using alternative delivery methods for very large attachments

## Error Handling

The bug reporting dialog handles various error scenarios:

1. **Invalid Email Address**: Validates email format before allowing submission
2. **Missing Required Fields**: Prompts user to fill in required fields
3. **SMTP Configuration Errors**: Shows error message if email configuration is invalid
4. **Network Errors**: Catches and displays network-related errors during email sending
5. **Attachment Errors**: Handles missing or inaccessible attachment files gracefully

## Best Practices

### 1. Store Configuration Securely

Avoid hardcoding email credentials. Use secure configuration storage:

```csharp
// Use Windows Credential Manager or encrypted config
var emailConfig = LoadEmailConfigFromSecureStorage();
```

### 2. Handle Email Failures Gracefully

```csharp
var result = KryptonBugReportingDialog.Show(exception, emailConfig);
if (result == DialogResult.OK)
{
    // Success - user has been notified
}
else
{
    // User cancelled or error occurred
    // Consider providing alternative reporting method (e.g., save to file)
}
```

### 3. Provide Fallback Options

If email sending fails, consider providing alternative reporting methods:

```csharp
try
{
    var result = KryptonBugReportingDialog.Show(exception, emailConfig);
    if (result != DialogResult.OK)
    {
        // Offer to save bug report to file
        SaveBugReportToFile(exception);
    }
}
catch (Exception ex)
{
    // Log error and provide manual reporting instructions
    LogError(ex);
    ShowManualReportingInstructions();
}
```

### 4. Localization

Customize strings for different languages:

```csharp
// Strings are accessed through KryptonBugReportingDialogStrings
// You can create localized versions by setting the properties
// Note: Currently strings are static, but the structure supports future localization
```

### 5. Testing Email Configuration

Test your email configuration before deploying:

```csharp
private bool TestEmailConfiguration(BugReportEmailConfig config)
{
    try
    {
        var service = new BugReportEmailService();
        return service.SendBugReport(
            config,
            "Test Email",
            "This is a test email to verify SMTP configuration.",
            null
        );
    }
    catch
    {
        return false;
    }
}
```

## Troubleshooting

### Email Not Sending

1. **Check SMTP Settings**: Verify server address, port, and SSL settings
2. **Verify Credentials**: Ensure username and password are correct
3. **Check Firewall**: Ensure SMTP port is not blocked
4. **Test Connection**: Use a simple SMTP test tool to verify connectivity
5. **Check Logs**: Review application logs for detailed error messages

### Common SMTP Ports

- **25**: Standard SMTP (often blocked by ISPs)
- **465**: SMTP over SSL (legacy)
- **587**: SMTP with STARTTLS (recommended)

### Gmail-Specific Issues

- Use an "App Password" instead of your regular password
- Enable "Less secure app access" (not recommended) or use OAuth2
- Ensure 2FA is properly configured

## Requirements

- **.NET Framework**: 4.7.2 or later
- **.NET**: 8.0 or later
- **Dependencies**: 
  - `Krypton.Toolkit` (referenced by `Krypton.Utilities`)
  - `System.Net.Mail` (included in .NET Framework/.NET)

## See Also

- [KryptonExceptionDialog Documentation](ExceptionDialog.md)
- [Krypton.Utilities Namespace Reference](../API/Krypton.Utilities.md)
- [Email Configuration Best Practices](EmailConfiguration.md)

