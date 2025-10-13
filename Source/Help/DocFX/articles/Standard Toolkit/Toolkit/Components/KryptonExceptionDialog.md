# KryptonExceptionDialog API Reference

## Overview

The `KryptonExceptionDialog` provides a sophisticated, user-friendly visual interface for displaying exception details in Windows Forms applications using the Krypton Toolkit. It offers developers a modern alternative to traditional exception message boxes, with advanced features like hierarchical exception browsing, searchable stack traces, and formatted exception details.

## Key Features

- **Hierarchical Exception Tree**: Navigate through exception chains, inner exceptions, stack traces, and exception data
- **Interactive Search**: Real-time search functionality to quickly locate specific exceptions or stack frames
- **Rich Details Panel**: Formatted display of exception type, message, stack trace, and inner exceptions
- **Clipboard Support**: Copy exception details to clipboard for debugging or logging
- **Theme Integration**: Automatically adopts the current Krypton theme
- **Localization Support**: All UI strings are fully localizable via `KryptonManager.Strings.ExceptionDialogStrings`
- **Responsive Layout**: Automatically adjusts dimensions based on screen resolution

---

## Architecture

### Component Hierarchy

```
KryptonExceptionDialog (Public API)
    └── VisualExceptionDialogForm (Internal Form)
        ├── InternalSearchableExceptionTreeView (Tree View with Search)
        │   └── InternalExceptionTreeView (Exception Tree Renderer)
        └── RichTextBox (Details Display)
```

### Related Classes

- **KryptonExceptionDialog**: Static public API for displaying exception dialogs
- **KryptonExceptionHandler**: High-level exception handling utilities with context capture
- **ExceptionHandler**: Internal exception handling implementation (marked as internal)
- **VisualExceptionDialogForm**: The actual dialog form implementation
- **InternalSearchableExceptionTreeView**: Custom control providing searchable tree view
- **InternalExceptionTreeView**: Custom tree view that parses and displays exception hierarchies
- **KryptonExceptionDialogStrings**: Localization strings for all dialog text

---

## Public API

### KryptonExceptionDialog Class

**Namespace**: `Krypton.Toolkit`

#### Methods

##### Show Method

```csharp
public static void Show(Exception exception, bool? showCopyButton, bool? showSearchBox)
```

Displays an exception dialog with the specified exception details.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `exception` | `Exception` | The exception to display. Cannot be null. |
| `showCopyButton` | `bool?` | Controls the visibility of the "Copy" button. If `null`, defaults to `true`. |
| `showSearchBox` | `bool?` | Controls the visibility of the search functionality. If `null`, defaults to `true`. |

**Behavior:**
- Displays a modal dialog showing the exception hierarchy
- Automatically expands all tree nodes
- Adjusts form dimensions based on screen resolution (900×650 for 1080p, 1108×687 for higher resolutions)
- Dialog is always centered on screen

---

### KryptonExceptionHandler Class

**Namespace**: `Krypton.Toolkit`

This class provides higher-level exception handling utilities with automatic caller information capture.

#### Methods

##### CaptureException Method

```csharp
public static void CaptureException(
    Exception exception,
    string title = "Exception Caught",
    [CallerFilePath] string callerFilePath = "",
    [CallerLineNumber] int lineNumber = 0,
    [CallerMemberName] string callerMethod = "",
    bool showStackTrace = false,
    bool? useExceptionDialog = true)
```

Captures and displays an exception with automatic caller context information.

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `exception` | `Exception` | *required* | The exception to handle |
| `title` | `string` | `"Exception Caught"` | Dialog title text |
| `callerFilePath` | `string` | *auto-captured* | Automatically captured via `[CallerFilePath]` |
| `lineNumber` | `int` | *auto-captured* | Automatically captured via `[CallerLineNumber]` |
| `callerMethod` | `string` | *auto-captured* | Automatically captured via `[CallerMemberName]` |
| `showStackTrace` | `bool` | `false` | Whether to include stack trace in message box fallback |
| `useExceptionDialog` | `bool?` | `true` | If `true`, uses `KryptonExceptionDialog`; if `false`, uses `KryptonMessageBox` |

**Behavior:**
- When `useExceptionDialog` is `true` (default), displays the rich exception dialog
- When `useExceptionDialog` is `false`, displays a traditional message box with caller information
- Automatically captures caller file path, line number, and method name for debugging

##### PrintStackTrace Method

```csharp
public static void PrintStackTrace(Exception exception, string fileName)
```

Writes the complete exception information and stack trace to a file.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `exception` | `Exception` | The exception to log |
| `fileName` | `string` | The file path where the exception will be written |

**Behavior:**
- Creates the file if it doesn't exist
- Writes both `exception.ToString()` and `exception.StackTrace`
- If file writing fails, captures that exception using `CaptureException`

##### PrintExceptionStackTrace Method

```csharp
public static void PrintExceptionStackTrace(Exception exception, string fileName)
```

Writes only the stack trace portion of an exception to a file.

**Parameters:**

| Parameter | Type | Description |
|-----------|------|-------------|
| `exception` | `Exception` | The exception whose stack trace to log |
| `fileName` | `string` | The file path where the stack trace will be written |

**Behavior:**
- Similar to `PrintStackTrace` but writes only `exception.StackTrace`
- Creates the file if it doesn't exist
- If file writing fails, captures that exception using `CaptureException`

---

## Usage Examples

### Example 1: Basic Exception Display

```csharp
try
{
    // Some operation that might throw
    int result = 10 / int.Parse("0");
}
catch (Exception ex)
{
    // Display exception with full features
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### Example 2: Simplified Display (No Search or Copy)

```csharp
try
{
    // Some operation that might throw
    ProcessData();
}
catch (Exception ex)
{
    // Display exception without search box or copy button
    KryptonExceptionDialog.Show(ex, false, false);
}
```

### Example 3: Using KryptonExceptionHandler with Context

```csharp
private void ProcessUserInput(string input)
{
    try
    {
        // Process input
        var result = ComplexOperation(input);
    }
    catch (Exception ex)
    {
        // Automatically captures file, line number, and method name
        KryptonExceptionHandler.CaptureException(
            ex, 
            title: "Data Processing Error",
            showStackTrace: true
        );
    }
}
```

### Example 4: Logging Exception to File

```csharp
try
{
    // Critical operation
    PerformCriticalTask();
}
catch (Exception ex)
{
    // Log to file for later analysis
    string logPath = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "MyApp", "Logs", $"error_{DateTime.Now:yyyyMMdd_HHmmss}.log"
    );
    
    KryptonExceptionHandler.PrintStackTrace(ex, logPath);
    
    // Also show to user
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### Example 5: Global Exception Handler

```csharp
static class Program
{
    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        
        // Set up global exception handlers
        Application.ThreadException += (sender, e) =>
        {
            KryptonExceptionHandler.CaptureException(
                e.Exception,
                title: "Unhandled Thread Exception"
            );
        };
        
        AppDomain.CurrentDomain.UnhandledException += (sender, e) =>
        {
            if (e.ExceptionObject is Exception ex)
            {
                KryptonExceptionHandler.CaptureException(
                    ex,
                    title: "Unhandled Application Exception"
                );
            }
        };
        
        Application.Run(new MainForm());
    }
}
```

### Example 6: Using MessageBox Fallback

```csharp
try
{
    // Some operation
    ValidateConfiguration();
}
catch (Exception ex)
{
    // Use traditional message box instead of exception dialog
    KryptonExceptionHandler.CaptureException(
        ex,
        title: "Configuration Error",
        showStackTrace: true,
        useExceptionDialog: false  // Uses KryptonMessageBox instead
    );
}
```

---

## Dialog Features

### Exception Tree View

The left panel displays a hierarchical tree structure with the following elements:

1. **Root Exception Node**: Shows `ExceptionType: Message`
   - Displays the primary exception type and message
   - Tagged with the actual `Exception` object for details retrieval

2. **Stack Trace Node**: Expandable node showing each stack frame
   - Each frame shows: `at Namespace.Class.Method in FilePath:line LineNumber`
   - Parsed from `StackTrace` object with file names and line numbers when available
   - Useful for identifying the exact location where the exception occurred

3. **Inner Exception Node**: Recursively displays inner exceptions
   - Creates a nested tree for exception chains
   - Each inner exception follows the same structure as the root

4. **Data Node**: Shows custom data attached to the exception
   - Only appears if `Exception.Data` dictionary has entries
   - Displays key-value pairs: `Key: Value`

### Search Functionality

When the search box is visible (controlled by `showSearchBox` parameter):

- **Real-time Filtering**: Tree updates as you type
- **Match Highlighting**: Matching nodes are highlighted in **bold** with yellow background
- **Result Count**: Shows count of matches (e.g., "3 results found")
- **Tree Pruning**: Non-matching nodes are hidden; parent nodes remain visible if children match
- **Clear Button**: Quickly clear the search and restore full tree
- **Case-insensitive**: Search is not case-sensitive

### Details Panel

The right panel displays formatted exception information:

```
Type: ArgumentOutOfRangeException
Message: Index was out of range...

Stack Trace:
[Formatted stack trace]

Inner Exception:
[Inner exception message or "None"]
```

When clicking on "Stack Trace" or "Inner Exception" parent nodes, the details panel shows:
```
Please select another node to view more details.
```

### Copy Button

When visible (controlled by `showCopyButton` parameter):

- **Enabled State**: Only enabled when exception details text is present
- **Functionality**: Copies the entire formatted exception details to clipboard
- **Use Cases**: 
  - Pasting into bug reports
  - Sharing exception details with support teams
  - Logging to external systems

---

## Localization

All user-facing strings are accessible via `KryptonManager.Strings.ExceptionDialogStrings` and can be customized or localized.

### Available Localization Properties

```csharp
public class KryptonExceptionDialogStrings : GlobalId
{
    public string WindowTitle { get; set; }                    // Default: "Exception Caught"
    public string ExceptionDetailsHeader { get; set; }         // Default: "Exception Details"
    public string ExceptionOutlineHeader { get; set; }         // Default: "Exception Outline"
    public string MoreDetails { get; set; }                    // Default: "Please select another node..."
    public string Type { get; set; }                           // Default: "Type"
    public string InnerException { get; set; }                 // Default: "Inner Exception"
    public string Message { get; set; }                        // Default: "Message"
    public string StackTrace { get; set; }                     // Default: "Stack Trace"
    public string None { get; set; }                           // Default: "None"
    public string Data { get; set; }                           // Default: "Data"
    public string Line { get; set; }                           // Default: "Line"
    public string SearchBoxCueText { get; set; }               // Default: "Search..."
    public string NoResultsFound { get; set; }                 // Default: "No results found"
    public string Result { get; set; }                         // Default: "result"
    public string ResultsAppendage { get; set; }               // Default: "s"
    public string ResultsFoundAppendage { get; set; }          // Default: "found"
    public string NoMatchesFound { get; set; }                 // Default: "No matches found."
    public string TypeToSearch { get; set; }                   // Default: "Type to search..."
}
```

### Localization Example

```csharp
// Application startup - set Spanish localization
KryptonManager.Strings.ExceptionDialogStrings.WindowTitle = "Excepción Capturada";
KryptonManager.Strings.ExceptionDialogStrings.ExceptionDetailsHeader = "Detalles de la Excepción";
KryptonManager.Strings.ExceptionDialogStrings.ExceptionOutlineHeader = "Esquema de la Excepción";
KryptonManager.Strings.ExceptionDialogStrings.Type = "Tipo";
KryptonManager.Strings.ExceptionDialogStrings.Message = "Mensaje";
KryptonManager.Strings.ExceptionDialogStrings.StackTrace = "Rastreo de Pila";
KryptonManager.Strings.ExceptionDialogStrings.InnerException = "Excepción Interna";
KryptonManager.Strings.ExceptionDialogStrings.SearchBoxCueText = "Buscar...";
// ... additional strings as needed

// Now all exception dialogs will use Spanish text
```

---

## Design Considerations

### When to Use KryptonExceptionDialog

**✅ Recommended Use Cases:**
- Development and debugging scenarios
- Applications with detailed logging requirements
- Technical support tools where full exception details are valuable
- Admin interfaces or diagnostic tools
- Applications where users may need to report detailed error information

**❌ Not Recommended For:**
- Production user-facing errors (use simpler, user-friendly messages)
- Expected validation errors (use specific validation messages)
- Recoverable errors that don't require detailed exception information
- Mobile or touch-first applications (too complex for small screens)

### Best Practices

1. **Production vs. Development**
   ```csharp
   #if DEBUG
       KryptonExceptionDialog.Show(ex, true, true);
   #else
       KryptonMessageBox.Show(
           "An unexpected error occurred. Please contact support.",
           "Error", 
           KryptonMessageBoxButtons.OK, 
           KryptonMessageBoxIcon.Error
       );
       // Log the full exception internally
       LogException(ex);
   #endif
   ```

2. **Always Log Exceptions**
   ```csharp
   catch (Exception ex)
   {
       // Log first
       Logger.Error(ex, "Failed to process user request");
       
       // Then display
       KryptonExceptionDialog.Show(ex, true, true);
   }
   ```

3. **Wrap in Try-Catch for Critical Operations**
   ```csharp
   try
   {
       CriticalOperation();
   }
   catch (Exception ex)
   {
       try
       {
           // Attempt to log
           KryptonExceptionHandler.PrintStackTrace(ex, logPath);
       }
       catch
       {
           // If logging fails, at least show the dialog
           KryptonExceptionDialog.Show(ex, true, true);
       }
   }
   ```

4. **Use Appropriate Titles and Context**
   ```csharp
   catch (Exception ex)
   {
       KryptonExceptionHandler.CaptureException(
           ex,
           title: "Database Connection Failed",  // Specific, meaningful title
           showStackTrace: true
       );
   }
   ```

5. **Consider User Technical Level**
   ```csharp
   if (AppSettings.UserMode == UserMode.Advanced)
   {
       KryptonExceptionDialog.Show(ex, true, true);
   }
   else
   {
       KryptonMessageBox.Show(
           "Unable to save your changes. Please try again.",
           "Save Error",
           KryptonMessageBoxButtons.OK,
           KryptonMessageBoxIcon.Warning
       );
   }
   ```

---

## Technical Details

### Dialog Dimensions

The dialog automatically adjusts its size based on screen resolution:

- **1080p (1920×1080)**: 900×650 pixels
- **Higher resolutions**: 1108×687 pixels

This is handled automatically by `GeneralToolkitUtilities.GetCurrentScreenSize()` and `GeneralToolkitUtilities.AdjustFormDimensions()`.

### Form Properties

- **StartPosition**: `CenterScreen` - Always centered on the screen
- **FormBorderStyle**: `Fixed3D` - Non-resizable with 3D border
- **MaximizeBox**: `false` - Cannot be maximized
- **MinimizeBox**: `false` - Cannot be minimized
- **ShowInTaskbar**: `false` - Doesn't appear in the Windows taskbar
- **ShowIcon**: `false` - No icon displayed in title bar

### Tree View Font

The exception tree view uses **Consolas 8.25pt** for optimal code/stack trace readability.

### Performance Considerations

- **Tree Cloning**: The search functionality clones tree nodes for filtering. For extremely deep exception chains (100+ levels), there may be a brief delay during search.
- **Automatic Expansion**: All tree nodes are expanded by default, which may impact performance for exceptions with very large stack traces.
- **Thread Safety**: The dialog is designed for UI thread use only. Do not call from background threads without `Invoke`.

### Thread Safety Example

```csharp
// From background thread
Task.Run(() =>
{
    try
    {
        // Background work
        ProcessLargeDataset();
    }
    catch (Exception ex)
    {
        // Marshal to UI thread
        if (mainForm.InvokeRequired)
        {
            mainForm.Invoke(() => 
                KryptonExceptionDialog.Show(ex, true, true)
            );
        }
        else
        {
            KryptonExceptionDialog.Show(ex, true, true);
        }
    }
});
```

---

## Comparison with Alternatives

### KryptonExceptionDialog vs. KryptonMessageBox

| Feature | KryptonExceptionDialog | KryptonMessageBox |
|---------|----------------------|-------------------|
| Purpose | Detailed exception inspection | General messaging |
| Stack Trace | Hierarchical, searchable tree | Text only (if shown) |
| Inner Exceptions | Full nested tree | Not displayed |
| Search | Yes | No |
| Clipboard | Formatted exception copy | Basic Ctrl+C support |
| User-Friendliness | Technical/developer-focused | User-friendly |
| Size | Large (900×650+) | Compact, auto-sized |
| Best For | Debugging, diagnostics | User notifications |

### KryptonExceptionDialog vs. Standard Exception.ToString()

| Feature | KryptonExceptionDialog | Exception.ToString() |
|---------|----------------------|-------------------|
| Presentation | Visual, interactive tree | Plain text |
| Navigation | Click nodes to explore | Manual text search |
| Search | Real-time filtering | Manual Ctrl+F in viewer |
| Formatting | Syntax-highlighted sections | None |
| User Experience | Guided exploration | Raw data dump |

---

## Common Scenarios

### Scenario 1: Aggregate Exceptions

```csharp
try
{
    Parallel.ForEach(items, item => 
    {
        // Might throw multiple exceptions
        ProcessItem(item);
    });
}
catch (AggregateException agEx)
{
    // AggregateException contains multiple inner exceptions
    // The tree view will show all of them hierarchically
    KryptonExceptionDialog.Show(agEx, true, true);
}
```

### Scenario 2: Custom Exception Data

```csharp
try
{
    var ex = new InvalidOperationException("Failed to process order");
    ex.Data["OrderId"] = 12345;
    ex.Data["CustomerId"] = 67890;
    ex.Data["Timestamp"] = DateTime.Now;
    throw ex;
}
catch (Exception ex)
{
    // The "Data" node will show all custom key-value pairs
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### Scenario 3: Exception in Async/Await

```csharp
private async void btnProcess_Click(object sender, EventArgs e)
{
    try
    {
        await ProcessDataAsync();
    }
    catch (Exception ex)
    {
        // Stack trace will show async state machine details
        KryptonExceptionDialog.Show(ex, true, true);
    }
}
```

---

## Troubleshooting

### Issue: Dialog doesn't appear

**Possible Causes:**
- Called from a background thread without `Invoke`
- Exception parameter is `null`
- Application is in a non-interactive state

**Solution:**
```csharp
if (exception == null)
{
    throw new ArgumentNullException(nameof(exception));
}

if (InvokeRequired)
{
    Invoke(() => KryptonExceptionDialog.Show(exception, true, true));
}
else
{
    KryptonExceptionDialog.Show(exception, true, true);
}
```

### Issue: Search not working

**Possible Causes:**
- `showSearchBox` parameter set to `false`
- Search control not initialized properly

**Solution:**
Ensure `showSearchBox` is set to `true` or `null`:
```csharp
KryptonExceptionDialog.Show(ex, true, true);  // ✅ Search enabled
KryptonExceptionDialog.Show(ex, true, null);  // ✅ Search enabled (default)
KryptonExceptionDialog.Show(ex, true, false); // ❌ Search disabled
```

### Issue: Copy button disabled

**Cause:** No exception details are currently displayed in the details panel.

**Solution:** Click on an exception node in the tree (not on "Stack Trace" or "Inner Exception" parent nodes).

### Issue: Text appears in wrong language

**Cause:** Localization strings not set or set incorrectly.

**Solution:** Set localization strings at application startup:
```csharp
// In Main() or Form_Load
KryptonManager.Strings.ExceptionDialogStrings.Reset(); // Reset to defaults
// Or set custom values
KryptonManager.Strings.ExceptionDialogStrings.WindowTitle = "Your Title";
```

---

## Version History

This component was introduced in **Krypton Toolkit v100** (2024-2025) as part of enhanced exception handling capabilities.

### Related Features Added in v100
- `KryptonExceptionDialog` (public API)
- `KryptonExceptionHandler` (utility wrapper)
- `InternalSearchableExceptionTreeView` (searchable tree control)
- `InternalExceptionTreeView` (exception parsing and rendering)
- `KryptonExceptionDialogStrings` (localization support)

---

## See Also

### Related Classes
- `System.Exception`
- `System.Diagnostics.StackTrace`
- `KryptonMessageBox`
- `KryptonForm`
- `KryptonTreeView`

### Related Patterns
- Exception Handling Best Practices
- Logging Strategies
- User Error Communication
- Diagnostic Tool Design