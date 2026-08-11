# Bug reporting dialogs

## Overview

The utilities assembly provides two bug-reporting paths:

| API | Channel |
| --- | --- |
| **`KryptonBugReportingDialog`** | E-mail or file-based reports |
| **`KryptonGitHubIssueReportDialog`** | GitHub Issues API — see [dedicated guide](KryptonGitHubIssueReportDialog.md) |

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`

Both integrate with [KryptonExceptionDialog](../Toolkit/Components/KryptonExceptionDialog.md).

## KryptonBugReportingDialog

Collects exception details and optional user feedback for e-mail or file export.

```csharp
using Krypton.Toolkit.Utilities;

var emailConfig = new BugReportEmailConfig
{
    ToAddress = "support@example.com",
    Subject = "Application error report"
};

KryptonBugReportingDialog.Show(exception, emailConfig);
```

Configure `BugReportEmailConfig` with recipient, subject, and SMTP or MAPI settings supported by your build.

`BugReportingHelper.ShowExceptionWithBugReporting` wraps exception display + bug report in one call.

## KryptonGitHubIssueReportDialog

Creates GitHub issues from encrypted shipped configuration. Users enter title and description only.

```csharp
KryptonGitHubIssueReportDialog.Show(this, secretKey, initialDescription: exception.ToString());
```

See **[KryptonGitHubIssueReportDialog.md](KryptonGitHubIssueReportDialog.md)** for encrypted config setup, security notes, and overload reference.

## See also

- [KryptonGitHubIssueReportDialog](KryptonGitHubIssueReportDialog.md)
- [KryptonExceptionDialog](../Toolkit/Components/KryptonExceptionDialog.md)
- [KryptonExceptionDialog Quick Start](../Toolkit/Components/KryptonExceptionDialogQuickStart.md)
- [Exception handling overview](../Toolkit/Components/ExceptionHandling.md)
