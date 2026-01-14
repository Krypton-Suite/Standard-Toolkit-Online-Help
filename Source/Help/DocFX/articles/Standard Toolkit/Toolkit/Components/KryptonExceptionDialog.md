# KryptonExceptionDialog API Documentation

## Overview

`KryptonExceptionDialog` is a static utility class that provides a user-friendly, feature-rich dialog for displaying exception information in Krypton Toolkit applications. It serves as the public interface to the internal `VisualExceptionDialogForm` class, offering multiple overloaded methods to display exceptions with various customization options.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`  
**Class Type:** `public static class`  
**Designer Category:** `code` (not available in Visual Studio Toolbox)

---

## Table of Contents

1. [Architecture](#architecture)
2. [API Reference](#api-reference)
3. [Features](#features)
4. [Usage Examples](#usage-examples)
5. [Customization Options](#customization-options)
6. [UI Components](#ui-components)
7. [Exception Tree Structure](#exception-tree-structure)
8. [Localization](#localization)
9. [Best Practices](#best-practices)
10. [Implementation Details](#implementation-details)

---

## Architecture

### Class Hierarchy

```
KryptonExceptionDialog (static facade)
    └── VisualExceptionDialogForm (internal implementation)
            └── KryptonForm
```

### Design Pattern

`KryptonExceptionDialog` follows the **Facade Pattern**, providing a simplified static interface that delegates to the internal `VisualExceptionDialogForm` class. This design:

- Hides implementation complexity from consumers
- Provides a clean, discoverable API
- Maintains separation between public API and internal implementation
- Ensures proper resource disposal through `using` statements

### Key Components

1. **KryptonExceptionDialog** - Public static API
2. **VisualExceptionDialogForm** - Internal form implementation
3. **InternalSearchableExceptionTreeView** - Searchable tree view for exception hierarchy
4. **InternalExceptionTreeView** - Tree view that displays exception structure

---

## API Reference

### Public Methods

#### `Show(Exception exception)`

Displays the specified exception using default settings.

**Signature:**
```csharp
public static void Show(Exception exception)
```

**Parameters:**
- `exception` (`Exception`) - The exception to display. Cannot be `null`.

**Remarks:**
- Uses default highlight color (`Color.LightYellow`)
- Copy button is visible by default
- Search box is visible by default
- No bug reporting callback

**Example:**
```csharp
try
{
    // Some operation that may throw
    ProcessData();
}
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex);
}
```

---

#### `Show(Exception exception, Color? highlightColor)`

Displays the exception with a custom highlight color.

**Signature:**
```csharp
public static void Show(Exception exception, Color? highlightColor)
```

**Parameters:**
- `exception` (`Exception`) - The exception to display. Cannot be `null`.
- `highlightColor` (`Color?`) - Optional color for highlighting search results and UI elements. If `null`, defaults to `Color.LightYellow`.

**Remarks:**
- Allows visual customization of the dialog
- Highlight color affects search result highlighting and UI accent colors
- Copy button and search box use default visibility

**Example:**
```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex, Color.Orange);
}
```

---

#### `Show(Exception exception, bool? showCopyButton, bool? showSearchBox)`

Displays the exception with control over copy button and search box visibility.

**Signature:**
```csharp
public static void Show(Exception exception, bool? showCopyButton, bool? showSearchBox)
```

**Parameters:**
- `exception` (`Exception`) - The exception to display. Cannot be `null`.
- `showCopyButton` (`bool?`) - Controls copy button visibility:
  - `true` - Show copy button
  - `false` - Hide copy button
  - `null` - Use default (visible)
- `showSearchBox` (`bool?`) - Controls search box visibility:
  - `true` - Show search features
  - `false` - Hide search features
  - `null` - Use default (visible)

**Remarks:**
- Useful for simplified error dialogs where search/copy features aren't needed
- When search box is hidden, the tree view remains visible but search filtering is disabled
- Copy button enables users to copy exception details to clipboard

**Example:**
```csharp
catch (Exception ex)
{
    // Show only copy button, hide search
    KryptonExceptionDialog.Show(ex, showCopyButton: true, showSearchBox: false);
}
```

---

#### `Show(Exception exception, Color? highlightColor, bool? showCopyButton, bool? showSearchBox)`

Displays the exception with full UI customization options.

**Signature:**
```csharp
public static void Show(Exception exception, Color? highlightColor, bool? showCopyButton, bool? showSearchBox)
```

**Parameters:**
- `exception` (`Exception`) - The exception to display. Cannot be `null`.
- `highlightColor` (`Color?`) - Optional highlight color. Defaults to `Color.LightYellow` if `null`.
- `showCopyButton` (`bool?`) - Optional copy button visibility. Defaults to `true` if `null`.
- `showSearchBox` (`bool?`) - Optional search box visibility. Defaults to `true` if `null`.

**Remarks:**
- Most flexible overload without bug reporting
- Combines visual customization with feature toggles
- All parameters are optional (nullable), allowing partial customization

**Example:**
```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex, 
        highlightColor: Color.Red, 
        showCopyButton: true, 
        showSearchBox: true);
}
```

---

#### `Show(Exception exception, Color? highlightColor, bool? showCopyButton, bool? showSearchBox, Action<Exception>? bugReportCallback)`

Displays the exception with all customization options including bug reporting.

**Signature:**
```csharp
public static void Show(Exception exception, Color? highlightColor, bool? showCopyButton, bool? showSearchBox, Action<Exception>? bugReportCallback)
```

**Parameters:**
- `exception` (`Exception`) - The exception to display. Cannot be `null`.
- `highlightColor` (`Color?`) - Optional highlight color. Defaults to `Color.LightYellow` if `null`.
- `showCopyButton` (`bool?`) - Optional copy button visibility. Defaults to `true` if `null`.
- `showSearchBox` (`bool?`) - Optional search box visibility. Defaults to `true` if `null`.
- `bugReportCallback` (`Action<Exception>?`) - Optional callback invoked when "Report Bug" button is clicked. If provided, enables the bug reporting button.

**Remarks:**
- Most comprehensive overload with all features
- Bug report callback receives the exception instance
- When callback is provided, a "Report Bug" button appears in the dialog
- Useful for integrating with bug tracking systems or user feedback mechanisms

**Example:**
```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex, 
        highlightColor: Color.Red,
        showCopyButton: true,
        showSearchBox: true,
        bugReportCallback: exception => 
        {
            // Integrate with bug tracking system
            BugTracker.ReportBug(exception);
            
            // Or show bug reporting dialog
            KryptonBugReportingDialog.Show(exception, emailConfig);
        });
}
```

---

### Private Methods

#### `ShowCore(Exception exception, Color? highlightColor, bool? showCopyButton, bool? showSearchBox, Action<Exception>? bugReportCallback)`

Internal implementation method that delegates to `VisualExceptionDialogForm`.

**Signature:**
```csharp
private static void ShowCore(Exception exception, Color? highlightColor, bool? showCopyButton, bool? showSearchBox, Action<Exception>? bugReportCallback)
```

**Implementation:**
All public `Show` methods delegate to this core method, which in turn calls `VisualExceptionDialogForm.Show()`.

---

## Features

### 1. Exception Tree View

The dialog displays exceptions in a hierarchical tree structure:

- **Root Node:** Exception type and message (e.g., "ArgumentException: Value cannot be null")
- **Stack Trace Node:** Expandable node containing all stack frames with:
  - Method name and declaring type
  - File name (if available)
  - Line number (if available)
- **Inner Exception Node:** Recursively displays nested exceptions
- **Data Node:** Displays exception.Data dictionary entries (if present)

### 2. Search Functionality

When enabled, provides real-time filtering of exception tree:

- **Case-insensitive search** across all tree nodes
- **Highlighting** of matching nodes with configurable color
- **Match count** display showing number of results found
- **Auto-selection** of first matching node
- **Clear button** to reset search

### 3. Copy to Clipboard

- Copies formatted exception details to clipboard
- Includes exception type, message, stack trace, and inner exception
- Button enabled/disabled based on content availability
- Formatted text suitable for bug reports or logs

### 4. Bug Reporting Integration

- Optional callback mechanism for bug reporting
- "Report Bug" button appears when callback is provided
- Passes exception instance to callback for processing
- Enables integration with bug tracking systems

### 5. Visual Customization

- **Highlight Color:** Customizable color for search results and UI accents
- **Responsive Layout:** Adapts to different screen sizes
- **Krypton Theming:** Inherits current Krypton palette and theme

### 6. Localization Support

All UI strings are localizable through `KryptonManager.Strings.ExceptionDialogStrings`:

- Window title
- Section headers
- Button labels
- Search box placeholder text
- Result messages

---

## Usage Examples

### Basic Usage

```csharp
try
{
    // Application code
    ProcessUserInput(userInput);
}
catch (Exception ex)
{
    // Simple exception display
    KryptonExceptionDialog.Show(ex);
}
```

### Custom Highlight Color

```csharp
catch (Exception ex)
{
    // Use red highlight for critical errors
    KryptonExceptionDialog.Show(ex, Color.Red);
}
```

### Minimal Dialog (No Search/Copy)

```csharp
catch (Exception ex)
{
    // Simplified dialog for end users
    KryptonExceptionDialog.Show(ex, 
        showCopyButton: false, 
        showSearchBox: false);
}
```

### With Bug Reporting

```csharp
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex,
        highlightColor: Color.Orange,
        bugReportCallback: exception =>
        {
            // Show bug reporting dialog
            var emailConfig = new EmailConfiguration
            {
                To = "support@example.com",
                Subject = "Application Error Report"
            };
            
            KryptonBugReportingDialog.Show(exception, emailConfig);
        });
}
```

### Integration with Exception Handler

```csharp
// In Application.ThreadException handler
private void Application_ThreadException(object sender, ThreadExceptionEventArgs e)
{
    KryptonExceptionDialog.Show(e.Exception, 
        highlightColor: Color.Red,
        showCopyButton: true,
        showSearchBox: true,
        bugReportCallback: ex => LogToErrorTrackingService(ex));
}

private void LogToErrorTrackingService(Exception ex)
{
    // Send to Sentry, Application Insights, etc.
    ErrorTrackingService.LogException(ex);
}
```

### Conditional Feature Display

```csharp
catch (Exception ex)
{
    // Show search for developers, hide for end users
    bool isDeveloperMode = ConfigurationManager.AppSettings["DeveloperMode"] == "true";
    
    KryptonExceptionDialog.Show(ex,
        showCopyButton: true,
        showSearchBox: isDeveloperMode);
}
```

---

## Customization Options

### Parameter Defaults

| Parameter | Default Value | Notes |
|-----------|--------------|-------|
| `highlightColor` | `Color.LightYellow` | Applied when `null` is passed |
| `showCopyButton` | `true` | Visible when `null` is passed |
| `showSearchBox` | `true` | Visible when `null` is passed |
| `bugReportCallback` | `null` | No bug report button when `null` |

### Visual Customization

The dialog automatically adapts to:

- **Screen Size:** Adjusts dimensions for 1080x720 and larger screens
- **Krypton Theme:** Inherits current palette settings
- **Font:** Uses Consolas for exception tree view (monospace for readability)

### Behavior Customization

- **Dialog Mode:** Always modal (`ShowDialog()`)
- **Form Style:** Fixed border, no maximize/minimize
- **Start Position:** Center screen
- **Taskbar:** Hidden (modal dialog)

---

## UI Components

### Layout Structure

```
┌─────────────────────────────────────────────────────────┐
│              Exception Caught                            │
├──────────────┬──────────┬───────────────────────────────┤
│              │          │                               │
│ Exception    │          │  Exception Details            │
│ Outline      │          │                               │
│              │          │                               │
│ [Search...]  │          │  [Rich Text Box]              │
│              │          │                               │
│ [Tree View]  │          │                               │
│              │          │                               │
│              │          │                               │
├──────────────┴──────────┴───────────────────────────────┤
│ [Copy] [Report Bug]                    [OK]             │
└─────────────────────────────────────────────────────────┘
```

### Component Details

1. **Exception Outline Panel** (Left)
   - `InternalSearchableExceptionTreeView` control
   - Search box (when enabled)
   - Tree view with exception hierarchy
   - Search results label

2. **Exception Details Panel** (Right)
   - `KryptonRichTextBox` for formatted exception text
   - Read-only text display
   - Updates based on tree node selection

3. **Action Buttons** (Bottom)
   - **Copy Button:** Copies details to clipboard
   - **Report Bug Button:** Visible when callback provided
   - **OK Button:** Closes dialog

### Control Properties

- **Form:** `KryptonForm` with fixed border style
- **Panels:** `KryptonPanel` with alternate back style
- **Labels:** `KryptonWrapLabel` with title control style
- **Buttons:** `KryptonButton` with standard styling
- **Tree View:** `InternalSearchableExceptionTreeView` (custom control)
- **Rich Text Box:** `KryptonRichTextBox` in read-only mode

---

## Exception Tree Structure

### Node Hierarchy

```
Root Exception Node
├── Stack Trace
│   ├── Frame 1: at Namespace.Class.Method() in File.cs:line 42
│   ├── Frame 2: at Namespace.Class.Method() in File.cs:line 35
│   └── ...
├── Inner Exception (if present)
│   ├── Stack Trace
│   │   └── ...
│   └── Inner Exception (recursive)
└── Data (if present)
    ├── Key1: Value1
    └── Key2: Value2
```

### Node Selection Behavior

- **Root Node:** Displays full exception details (type, message, stack trace, inner exception)
- **Stack Trace Node:** Shows "More details" message (select child frames for specific details)
- **Stack Frame Nodes:** Displays frame-specific information
- **Inner Exception Node:** Shows "More details" message (select child nodes for inner exception details)
- **Data Nodes:** Displays key-value pairs

### Exception Details Format

When an exception node is selected, the details panel displays:

```
Type: ExceptionTypeName
Message: Exception message text

StackTrace:
at Namespace.Class.Method() in File.cs:line 42
at Namespace.Class.Method() in File.cs:line 35
...

InnerException:
Inner exception message or "None"
```

---

## Localization

### String Resources

All UI strings are accessed through `KryptonManager.Strings.ExceptionDialogStrings`:

| Property | Default Value | Usage |
|----------|--------------|-------|
| `WindowTitle` | "Exception Caught" | Dialog window title |
| `ExceptionOutlineHeader` | "Exception Outline" | Left panel header |
| `ExceptionDetailsHeader` | "Exception Details" | Right panel header |
| `Type` | "Type" | Exception type label |
| `Message` | "Message" | Exception message label |
| `StackTrace` | "Stack Trace" | Stack trace section label |
| `InnerException` | "Inner Exception" | Inner exception label |
| `None` | "None" | Used when no inner exception |
| `Data` | "Data" | Exception data section label |
| `MoreDetails` | "Please select another node to view more details." | Placeholder text |
| `SearchBoxCueText` | "Search..." | Search box placeholder |
| `TypeToSearch` | "Type to search..." | Search prompt |
| `NoMatchesFound` | "No matches found." | No search results message |
| `Result` | "result" | Singular result text |
| `ResultsAppendage` | "s" | Plural suffix |
| `ResultsFoundAppendage` | "found" | Results found text |

### Localization Example

```csharp
// Customize strings for your application
KryptonManager.Strings.ExceptionDialogStrings.WindowTitle = "Application Error";
KryptonManager.Strings.ExceptionDialogStrings.ExceptionDetailsHeader = "Error Information";
```

---

## Best Practices

### 1. Exception Handling

```csharp
// ✅ Good: Catch specific exceptions when possible
try
{
    ProcessFile(filePath);
}
catch (FileNotFoundException ex)
{
    KryptonExceptionDialog.Show(ex, Color.Orange);
}
catch (UnauthorizedAccessException ex)
{
    KryptonExceptionDialog.Show(ex, Color.Red);
}
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex);
}
```

### 2. User Experience

```csharp
// ✅ Good: Provide context-aware dialogs
bool isDevelopmentMode = Debugger.IsAttached;

KryptonExceptionDialog.Show(ex,
    showSearchBox: isDevelopmentMode,  // Hide search for end users
    showCopyButton: true,               // Always allow copying
    bugReportCallback: isDevelopmentMode ? null : ReportBug);
```

### 3. Error Logging Integration

```csharp
catch (Exception ex)
{
    // Log first, then show dialog
    Logger.Error(ex, "Error processing user request");
    
    KryptonExceptionDialog.Show(ex,
        bugReportCallback: exception => Logger.ReportBug(exception));
}
```

### 4. Thread Safety

```csharp
// ✅ Good: Use UI thread for dialog display
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

### 5. Performance Considerations

- Dialog is modal and blocks UI thread (by design)
- Exception tree population is synchronous
- Large stack traces may impact initial display time
- Consider async logging for background operations

---

## Implementation Details

### Internal Architecture

#### VisualExceptionDialogForm

The internal form class (`VisualExceptionDialogForm`) handles:

1. **Initialization:**
   - Sets up UI components
   - Configures visibility based on parameters
   - Populates exception tree
   - Applies highlight color

2. **Exception Processing:**
   - Calls `InternalSearchableExceptionTreeView.Populate()`
   - Creates tree structure recursively
   - Stores original nodes for search filtering

3. **Event Handling:**
   - Tree node selection updates details panel
   - Copy button copies to clipboard
   - Bug report button invokes callback
   - Search filtering updates tree view

4. **Resource Management:**
   - Uses `using` statement for automatic disposal
   - Properly disposes form and controls

#### InternalSearchableExceptionTreeView

Custom control that extends search functionality:

- **Search Algorithm:** Case-insensitive string matching
- **Tree Filtering:** Recursively filters nodes while preserving hierarchy
- **Highlighting:** Applies highlight color to matching nodes
- **Node Cloning:** Maintains original tree for search reset

#### InternalExceptionTreeView

Core tree view for exception display:

- **Font:** Consolas 8.25pt (monospace)
- **Node Creation:** Recursive for nested exceptions
- **Stack Trace Parsing:** Extracts file names and line numbers
- **Data Display:** Shows exception.Data dictionary

### Default Values

```csharp
// Parameter defaults in VisualExceptionDialogForm constructor
_showCopyButton = showCopyButton ?? false;      // Note: Defaults to false internally
_showSearchBox = showSearchBox ?? false;        // Note: Defaults to false internally
_highlightColor = highlightColor ?? Color.LightYellow;
```

**Note:** While internal defaults are `false`, the public API defaults to `true` when `null` is passed, as seen in `SetupUI()`:

```csharp
kbtnCopy.Visible = _showCopyButton ?? true;
isbSearchArea.ShowSearchFeatures = _showSearchBox ?? true;
```

### Screen Size Adaptation

The dialog adjusts dimensions based on screen size:

```csharp
if (GeneralToolkitUtilities.GetCurrentScreenSize() == new Point(1080, 720))
{
    GeneralToolkitUtilities.AdjustFormDimensions(this, 900, 650);
}
else
{
    GeneralToolkitUtilities.AdjustFormDimensions(this, 1108, 687);
}
```

### Exception Formatting

Exception details are formatted as:

```
Type: {ExceptionType}
Message: {Message}

StackTrace:
{StackTrace}

InnerException:
{InnerExceptionMessage or "None"}
```

---

## Related Classes

- **VisualExceptionDialogForm** - Internal form implementation
- **InternalSearchableExceptionTreeView** - Searchable tree view control
- **InternalExceptionTreeView** - Exception tree view control
- **KryptonBugReportingDialog** - Integrated bug reporting dialog
- **KryptonManager.Strings.ExceptionDialogStrings** - Localization strings

---

## Version Information

- **License:** BSD 3-Clause License
- **Modifications:** Peter Wagner (aka Wagnerp), Simon Coghlan (aka Smurf-IV), Giduac, et al. 2025 - 2026
- **Target Framework:** .NET Framework 4.7.2+ and .NET 8.0+ (Windows)

---

## See Also

- [Krypton Toolkit Documentation](https://github.com/Krypton-Suite/Standard-Toolkit)
- [Exception Handling Best Practices](https://docs.microsoft.com/dotnet/standard/exceptions/)
- [KryptonBugReportingDialog Documentation](./krypton-bug-reporting-dialog-api.md) (if available)

---

## Summary

`KryptonExceptionDialog` provides a comprehensive, user-friendly solution for displaying exceptions in Krypton Toolkit applications. With features like searchable tree views, clipboard integration, bug reporting callbacks, and full localization support, it offers both developers and end users a powerful tool for understanding and reporting application errors.

The static API design makes it easy to integrate into existing exception handling code, while the extensive customization options allow developers to tailor the dialog to their application's specific needs.
