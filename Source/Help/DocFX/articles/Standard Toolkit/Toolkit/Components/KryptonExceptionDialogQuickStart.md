# KryptonExceptionDialog - Quick Start Guide

## 5-Minute Getting Started

### Installation

`KryptonExceptionDialog` is included in the Krypton.Toolkit package. No additional installation required.

**Namespace:** `Krypton.Toolkit`

---

## Basic Usage

### Simple Exception Display

```csharp
try
{
    // Your code that might throw an exception
    int result = 10 / int.Parse("0");
}
catch (Exception ex)
{
    // Show exception dialog with all features
    KryptonExceptionDialog.Show(ex, showCopyButton: true, showSearchBox: true);
}
```

### Using Default Values

```csharp
catch (Exception ex)
{
    // Null parameters use defaults (both true)
    KryptonExceptionDialog.Show(ex, null, null);
}
```

---

## Common Scenarios

### Development/Debug Mode

```csharp
catch (Exception ex)
{
    #if DEBUG
        // Full details in debug mode
        KryptonExceptionDialog.Show(ex, true, true);
    #else
        // User-friendly message in release
        KryptonMessageBox.Show(
            "An error occurred. Please contact support.",
            "Error",
            KryptonMessageBoxButtons.OK,
            KryptonMessageBoxIcon.Error
        );
        
        // Log the exception internally
        LogException(ex);
    #endif
}
```

### Global Exception Handler

```csharp
static class Program
{
    [STAThread]
    static void Main()
    {
        Application.ThreadException += (sender, e) =>
        {
            KryptonExceptionDialog.Show(e.Exception, true, true);
        };
        
        Application.Run(new MainForm());
    }
}
```

### With Auto-Context Capture

```csharp
using Krypton.Toolkit;

try
{
    ProcessData();
}
catch (Exception ex)
{
    // Automatically captures file name, line number, and method name
    KryptonExceptionHandler.CaptureException(
        ex,
        title: "Data Processing Failed",
        showStackTrace: true,
        useExceptionDialog: true
    );
}
```

---

## Key Features at a Glance

| Feature | Description | Parameter |
|---------|-------------|-----------|
| **Exception Tree** | Navigate exception hierarchy | Always visible |
| **Search** | Search exceptions and stack traces | `showSearchBox` |
| **Copy to Clipboard** | Copy formatted exception details | `showCopyButton` |
| **Stack Traces** | View complete call stack with line numbers | Always visible |
| **Inner Exceptions** | Drill down into exception chains | Always visible |
| **Exception Data** | View custom exception data | Always visible if present |
| **Theming** | Matches current Krypton theme | Automatic |

---

## Method Signatures

### KryptonExceptionDialog

```csharp
// Simple API
KryptonExceptionDialog.Show(
    Exception exception,      // Required: the exception to display
    bool? showCopyButton,    // Optional: show copy button (default: true)
    bool? showSearchBox      // Optional: show search box (default: true)
);
```

### KryptonExceptionHandler

```csharp
// Advanced API with auto-context capture
KryptonExceptionHandler.CaptureException(
    Exception exception,                  // Required
    string title = "Exception Caught",   // Optional
    [CallerFilePath] string callerFilePath = "",     // Auto-captured
    [CallerLineNumber] int lineNumber = 0,           // Auto-captured
    [CallerMemberName] string callerMethod = "",     // Auto-captured
    bool showStackTrace = false,                     // Optional
    bool? useExceptionDialog = true                  // Optional
);

// Log to file
KryptonExceptionHandler.PrintStackTrace(
    Exception exception,
    string fileName
);
```

---

## Dialog Controls

### What Users See

**Left Panel (Exception Tree):**
- Root exception with type and message
- Stack Trace node (expandable)
  - Each stack frame with file/line info
- Inner Exception node (if present)
  - Recursive exception chain
- Data node (if custom data present)
  - Key-value pairs

**Right Panel (Details):**
- Type: Exception type name
- Message: Exception message
- Stack Trace: Formatted call stack
- Inner Exception: Inner exception info or "None"

**Bottom:**
- Copy button (copies all details to clipboard)
- OK button (closes dialog)

### Search Functionality

When search is enabled:
1. Type in the search box at the top of the tree panel
2. Tree automatically filters to matching nodes
3. Matches are highlighted in **bold** with yellow background
4. Result count displayed (e.g., "3 results found")
5. Click the X button to clear search

---

## Common Patterns

### Pattern 1: Try-Catch-Display

```csharp
try
{
    DoWork();
}
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### Pattern 2: Try-Catch-Log-Display

```csharp
try
{
    DoWork();
}
catch (Exception ex)
{
    Logger.Error(ex, "Failed to do work");
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### Pattern 3: Try-Catch-Save-Display

```csharp
try
{
    DoWork();
}
catch (Exception ex)
{
    string logFile = $"error_{DateTime.Now:yyyyMMdd_HHmmss}.log";
    KryptonExceptionHandler.PrintStackTrace(ex, logFile);
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### Pattern 4: Conditional Display

```csharp
try
{
    DoWork();
}
catch (Exception ex)
{
    if (AppSettings.ShowDetailedErrors)
    {
        KryptonExceptionDialog.Show(ex, true, true);
    }
    else
    {
        KryptonMessageBox.Show("An error occurred.", "Error");
    }
}
```

---

## Customization

### Localization

All strings are customizable via `KryptonManager.Strings.ExceptionDialogStrings`:

```csharp
// Set at application startup
KryptonManager.Strings.ExceptionDialogStrings.WindowTitle = "Error Details";
KryptonManager.Strings.ExceptionDialogStrings.SearchBoxCueText = "Type to search...";
KryptonManager.Strings.ExceptionDialogStrings.StackTrace = "Call Stack";
// ... etc
```

### Hide Features

```csharp
// No search or copy features
KryptonExceptionDialog.Show(ex, showCopyButton: false, showSearchBox: false);

// Just the tree and details
```

---

## Best Practices

### ✅ DO

- Use in development/debug builds
- Use in admin/diagnostic tools
- Log exceptions before showing dialog
- Use meaningful exception messages
- Provide context with `KryptonExceptionHandler.CaptureException`

### ❌ DON'T

- Show to end users in production (too technical)
- Use for validation errors (use specific messages)
- Call from background threads without `Invoke`
- Display for expected/recoverable errors
- Forget to log exceptions before showing

---

## Thread Safety

Always invoke from the UI thread:

```csharp
Task.Run(() =>
{
    try
    {
        BackgroundWork();
    }
    catch (Exception ex)
    {
        // Marshal to UI thread
        if (mainForm.InvokeRequired)
        {
            mainForm.Invoke(() => KryptonExceptionDialog.Show(ex, true, true));
        }
        else
        {
            KryptonExceptionDialog.Show(ex, true, true);
        }
    }
});
```

---

## Troubleshooting

### Dialog doesn't appear
- Check if exception is null
- Verify you're on the UI thread
- Check if application is in interactive mode

### Copy button is disabled
- Click on an exception node in the tree (not "Stack Trace" or "Inner Exception" parent nodes)
- Details panel must have text

### Search not working
- Ensure `showSearchBox` is `true` or `null`
- Try clicking in the search box

---

## More Information

For comprehensive API documentation, see:
- [KryptonExceptionDialog Full API Reference](KryptonExceptionDialog.md)

For related components:
- KryptonMessageBox
- KryptonForm
- Exception Handling Best Practices

