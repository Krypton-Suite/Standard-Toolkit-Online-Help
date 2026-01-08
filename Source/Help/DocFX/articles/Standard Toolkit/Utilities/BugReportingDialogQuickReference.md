# Krypton Bug Reporting Dialog - Quick Reference

## Quick Start

```csharp
using Krypton.Utilities;

// 1. Configure email settings
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.example.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "app@example.com",
    ToEmail = "bugs@example.com",
    Username = "app@example.com",
    Password = "password"
};

// 2. Show bug reporting dialog
KryptonBugReportingDialog.Show(exception, emailConfig);

// OR integrate with exception dialog
BugReportingHelper.ShowExceptionWithBugReporting(exception, emailConfig);
```

## Common Patterns

### Pattern 1: Global Exception Handler

```csharp
Application.ThreadException += (s, e) => 
    BugReportingHelper.ShowExceptionWithBugReporting(e.Exception, emailConfig);
```

### Pattern 2: Try-Catch Block

```csharp
try { /* code */ }
catch (Exception ex) 
{ 
    BugReportingHelper.ShowExceptionWithBugReporting(ex, emailConfig); 
}
```

### Pattern 3: Manual Bug Report

```csharp
KryptonBugReportingDialog.Show(emailConfig);
```

## API Summary

| Class/Method | Purpose |
|--------------|---------|
| `KryptonBugReportingDialog.Show()` | Display bug reporting dialog |
| `BugReportEmailConfig` | Email configuration |
| `BugReportEmailService` | Send emails programmatically |
| `BugReportingHelper.ShowExceptionWithBugReporting()` | Integrated exception + bug reporting |

## Features

- Visual thumbnail display for screenshots and videos
- Support for image formats: JPG, PNG, GIF, BMP, TIFF, ICO, WEBP
- Support for video formats: MP4, AVI, MOV, WMV, FLV, MKV, WEBM, M4V, 3GP
- File icons for other file types

## Email Configuration Properties

| Property | Type | Required | Default |
|----------|------|----------|---------|
| `SmtpServer` | string | Yes | - |
| `SmtpPort` | int | Yes | 587 |
| `UseSsl` | bool | No | true |
| `FromEmail` | string | Yes | - |
| `ToEmail` | string | Yes | - |
| `Username` | string | No* | - |
| `Password` | string | No* | - |

*Required if SMTP server requires authentication

## Common SMTP Settings

| Provider | Server | Port | SSL |
|----------|--------|------|-----|
| Gmail | smtp.gmail.com | 587 | Yes |
| Outlook | smtp-mail.outlook.com | 587 | Yes |
| Office 365 | smtp.office365.com | 587 | Yes |

## Return Values

- `DialogResult.OK`: Bug report sent successfully
- `DialogResult.Cancel`: User cancelled or error occurred

## See Full Documentation

For complete documentation, see [BugReportingDialog.md](BugReportingDialog.md)

