# KryptonExceptionDialog - Quick Start Guide

**V110+:** Use **`using Krypton.Utilities;`**. Canonical copy: **[Utilities/KryptonExceptionDialogQuickStart.md](../../Utilities/KryptonExceptionDialogQuickStart.md)**.

## Overview

`KryptonExceptionDialog` is a static utility class that displays exception information in a user-friendly dialog with searchable tree views, copy-to-clipboard functionality, and optional bug reporting integration.

**Namespace (V110+):** `Krypton.Utilities`  
**Type:** `public static class`

---

## Quick Start

### Basic Usage

```csharp
using Krypton.Utilities;

try
{
    // Your application code
    ProcessData();
}
catch (Exception ex)
{
    // Display exception dialog
    KryptonExceptionDialog.Show(ex);
}
```

That's it! The dialog will display with:

- ✅ Exception tree view (left panel)
- ✅ Detailed exception information (right panel)
- ✅ Copy button (to clipboard)
- ✅ Search box (to filter exception tree)
- ✅ Default yellow highlight color

---

## Common Scenarios

### 1. Simple Error Display

```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex);
}
```

### 2. Custom Highlight Color

```csharp
catch (Exception ex)
{
    // Use red for critical errors
    KryptonExceptionDialog.Show(ex, Color.Red);
}
```

### 3. Hide Search Box (Simplified UI)

```csharp
catch (Exception ex)
{
    // Hide search, keep copy button
    KryptonExceptionDialog.Show(ex, showCopyButton: true, showSearchBox: false);
}
```

### 4. Minimal Dialog (No Search, No Copy)

```csharp
catch (Exception ex)
{
    // Simplest possible dialog
    KryptonExceptionDialog.Show(ex, showCopyButton: false, showSearchBox: false);
}
```

### 5. With Bug Reporting

```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex,
        bugReportCallback: exception =>
        {
            // Your bug reporting logic here
            BugTracker.Report(exception);
            
            // Or show bug reporting dialog
            KryptonBugReportingDialog.Show(exception, emailConfig);
        });
}
```

### 6. Full Customization

```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex,
        highlightColor: Color.Orange,      // Custom highlight
        showCopyButton: true,               // Show copy button
        showSearchBox: true,                 // Show search box
        bugReportCallback: ReportBug);       // Bug reporting callback
}

private void ReportBug(Exception ex)
{
    // Your bug reporting implementation
}
```

---

## API Reference at a Glance

### Method Overloads

| Method | Parameters | Use Case |
| --- | --- | --- |
| `Show(Exception)` | `exception` | Basic usage, all defaults |
| `Show(Exception, Color?)` | `exception`, `highlightColor` | Custom highlight color |
| `Show(Exception, bool?, bool?)` | `exception`, `showCopyButton`, `showSearchBox` | Control feature visibility |
| `Show(Exception, Color?, bool?, bool?)` | All above | Full UI customization |
| `Show(Exception, Color?, bool?, bool?, Action<Exception>?)` | All above + `bugReportCallback` | Complete with bug reporting |

### Parameter Defaults

- **`highlightColor`**: `null` → `Color.LightYellow`
- **`showCopyButton`**: `null` → `true` (visible)
- **`showSearchBox`**: `null` → `true` (visible)
- **`bugReportCallback`**: `null` → No bug report button

---

## Key Features

### 🔍 Searchable Exception Tree

- Navigate exception hierarchy visually
- Search filters tree in real-time
- Highlights matching nodes
- Shows match count

### 📋 Copy to Clipboard

- One-click copy of formatted exception details
- Includes type, message, stack trace, inner exception
- Ready for bug reports or logs

### 🐛 Bug Reporting Integration

- Optional callback when "Report Bug" button clicked
- Passes exception instance to your handler
- Integrate with bug tracking systems

### 🎨 Visual Customization

- Custom highlight colors
- Responsive layout (adapts to screen size)
- Inherits Krypton theme/palette

### 🌐 Localization

All strings customizable via `KryptonManager.Strings.ExceptionDialogStrings`

---

## Exception Tree Structure

The dialog displays exceptions hierarchically:

```text
ExceptionType: Message
├── Stack Trace
│   ├── at Namespace.Class.Method() in File.cs:line 42
│   ├── at Namespace.Class.Method() in File.cs:line 35
│   └── ...
├── Inner Exception (if present)
│   └── [Recursive structure]
└── Data (if present)
    └── Key: Value pairs
```

**Selecting nodes** updates the details panel with specific information.

---

## Integration Examples

### Global Exception Handler

```csharp
// In Program.cs or Main()
Application.ThreadException += (sender, e) =>
{
    KryptonExceptionDialog.Show(e.Exception);
};

Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
AppDomain.CurrentDomain.UnhandledException += (sender, e) =>
{
    if (e.ExceptionObject is Exception ex)
    {
        KryptonExceptionDialog.Show(ex);
    }
};
```

### Background Worker Error Handling

```csharp
private void BackgroundWorker_RunWorkerCompleted(object sender, RunWorkerCompletedEventArgs e)
{
    if (e.Error != null)
    {
        if (InvokeRequired)
        {
            Invoke(new Action(() => KryptonExceptionDialog.Show(e.Error)));
        }
        else
        {
            KryptonExceptionDialog.Show(e.Error);
        }
    }
}
```

### Conditional Features Based on Mode

```csharp
catch (Exception ex)
{
    bool isDeveloperMode = Debugger.IsAttached || 
                          ConfigurationManager.AppSettings["DeveloperMode"] == "true";
    
    KryptonExceptionDialog.Show(ex,
        showSearchBox: isDeveloperMode,  // Hide search for end users
        showCopyButton: true,            // Always allow copying
        bugReportCallback: isDeveloperMode ? null : ReportBug);
}
```

### With Logging Integration

```csharp
catch (Exception ex)
{
    // Log first
    Logger.Error(ex, "Error processing request");
    
    // Then show dialog
    KryptonExceptionDialog.Show(ex,
        bugReportCallback: exception => Logger.ReportBug(exception));
}
```

---

## UI Layout

```text
┌─────────────────────────────────────────────────────┐
│           Exception Caught                           │
├──────────────┬──────────┬───────────────────────────┤
│              │          │                           │
│ Exception    │          │  Exception Details        │
│ Outline      │          │                           │
│              │          │                           │
│ [Search...]  │          │  [Formatted Exception]    │
│              │          │                           │
│ [Tree View]  │          │                           │
│              │          │                           │
├──────────────┴──────────┴───────────────────────────┤
│ [Copy] [Report Bug]                  [OK]           │
└─────────────────────────────────────────────────────┘
```

**Left Panel:** Searchable exception tree  
**Right Panel:** Detailed exception information  
**Bottom:** Action buttons (Copy, Report Bug, OK)

---

## Tips & Best Practices

### ✅ Do

- Use for user-facing error dialogs
- Provide bug reporting callback for production apps
- Customize highlight color to match your app's error severity
- Hide search box for end users (keep for developers)
- Always log exceptions before showing dialog

### ❌ Don't

- Use for exceptions you handle programmatically
- Show dialog in tight loops or performance-critical code
- Forget to handle thread safety (use `Invoke` if needed)
- Override default behavior unless necessary

---

## Customization

### Change Highlight Color

```csharp
KryptonExceptionDialog.Show(ex, Color.Red);        // Red for critical
KryptonExceptionDialog.Show(ex, Color.Orange);     // Orange for warnings
KryptonExceptionDialog.Show(ex, Color.LightBlue); // Blue for info
```

### Localize Strings

```csharp
// Customize dialog strings
KryptonManager.Strings.ExceptionDialogStrings.WindowTitle = "Application Error";
KryptonManager.Strings.ExceptionDialogStrings.ExceptionDetailsHeader = "Error Information";
```

### Conditional Features

```csharp
bool showAdvancedFeatures = User.IsDeveloper;

KryptonExceptionDialog.Show(ex,
    showSearchBox: showAdvancedFeatures,
    showCopyButton: true);
```

---

## Related Documentation

- **[Full API documentation](KryptonExceptionDialog.md)** — comprehensive reference (this folder)
- **KryptonBugReportingDialog** - Integrated bug reporting dialog
- **KryptonManager** - String localization and theming

---

## Common Questions

### Q: Can I customize the dialog appearance?

**A:** Yes! The dialog inherits your Krypton theme/palette. You can also customize the highlight color and control feature visibility.

### Q: Is the dialog modal?

**A:** Yes, it uses `ShowDialog()` and blocks the UI thread until dismissed.

### Q: Can I use it in background threads?

**A:** You must marshal to the UI thread first using `Invoke()` or `BeginInvoke()`.

### Q: Does it handle nested exceptions?

**A:** Yes! Inner exceptions are displayed recursively in the tree view.

### Q: Can I disable the search feature?

**A:** Yes, pass `showSearchBox: false` to hide search functionality.

### Q: How do I integrate bug reporting?

**A:** Provide a callback function that receives the exception:

```csharp
KryptonExceptionDialog.Show(ex, bugReportCallback: exception => {
    // Your bug reporting code
});
```

---

## Next Steps

1. **Try the basic example** - Start with `KryptonExceptionDialog.Show(ex)`
2. **Customize for your needs** - Add highlight color or hide features
3. **Integrate bug reporting** - Add callback for production apps
4. **Read full documentation** — see [KryptonExceptionDialog.md](KryptonExceptionDialog.md) for complete details

---

## Summary

`KryptonExceptionDialog` makes exception handling user-friendly:

```csharp
// Simple
KryptonExceptionDialog.Show(ex);

// Customized
KryptonExceptionDialog.Show(ex, Color.Red, true, true, ReportBug);

// Minimal
KryptonExceptionDialog.Show(ex, showCopyButton: false, showSearchBox: false);
```

**That's all you need to get started!** 🚀
