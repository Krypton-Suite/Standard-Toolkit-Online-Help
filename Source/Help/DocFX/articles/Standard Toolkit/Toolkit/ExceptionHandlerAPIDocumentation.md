# ExceptionHandler API Documentation

## Overview

The `ExceptionHandler` class is a comprehensive exception management system within the Krypton Toolkit Suite. It provides centralized exception handling capabilities with multiple display options, logging functionality, and integration with the Krypton UI framework.

**Namespace:** `Krypton.Toolkit`  
**Access Level:** `internal` (for internal toolkit use)  
**Public API:** `KryptonExceptionHandler` (public wrapper)

## Architecture

The exception handling system consists of several interconnected components:

```
ExceptionHandler (internal)
    ↓
KryptonExceptionHandler (public API)
    ↓
KryptonExceptionDialog (UI wrapper)
    ↓
VisualExceptionDialogForm (actual form)
```

## Core Classes

### 1. ExceptionHandler (Internal)

The core exception handling class that provides the fundamental exception management functionality.

**Location:** `Source/Krypton Components/Krypton.Toolkit/Tooling/ExceptionHandler.cs`

#### Constructor
```csharp
public ExceptionHandler()
```
Creates a new instance of the ExceptionHandler class.

#### Methods

##### CaptureException
```csharp
public static void CaptureException(
    Exception exception, 
    string title = "Exception Caught",
    [CallerFilePath] string callerFilePath = "",
    [CallerLineNumber] int lineNumber = 0,
    [CallerMemberName] string callerMethod = "", 
    bool showStackTrace = false, 
    bool? useExceptionDialog = true,
    bool? showExceptionDialogCopyButton = false, 
    bool? showExceptionDialogSearchBox = false)
```

**Purpose:** Captures and displays exceptions with comprehensive debugging information.

**Parameters:**
- `exception` (Exception): The exception to capture and display
- `title` (string): Title for the exception dialog (default: "Exception Caught")
- `callerFilePath` (string): Automatically populated with the calling file path using `[CallerFilePath]`
- `lineNumber` (int): Automatically populated with the calling line number using `[CallerLineNumber]`
- `callerMethod` (string): Automatically populated with the calling method name using `[CallerMemberName]`
- `showStackTrace` (bool): Whether to include stack trace in the message (default: false)
- `useExceptionDialog` (bool?): Whether to use the advanced KryptonExceptionDialog (default: true)
- `showExceptionDialogCopyButton` (bool?): Whether to show copy button in the dialog (default: false)
- `showExceptionDialogSearchBox` (bool?): Whether to show search functionality in the dialog (default: false)

**Behavior:**
- If `useExceptionDialog` is true (default), displays the exception using `KryptonExceptionDialog.Show()`
- If `useExceptionDialog` is false, displays a simple message box with formatted exception details
- Automatically captures caller information using C# compiler attributes
- Provides fallback error handling for any exceptions during the capture process

**Example Usage:**
```csharp
try
{
    // Some operation that might throw an exception
    ProcessData();
}
catch (Exception ex)
{
    ExceptionHandler.CaptureException(ex, "Data Processing Error", showStackTrace: true);
}
```

##### PrintStackTrace
```csharp
public static void PrintStackTrace(Exception exception, string fileName)
```

**Purpose:** Writes exception details and stack trace to a file.

**Parameters:**
- `exception` (Exception): The exception to log
- `fileName` (string): Path to the file where the exception details will be written

**Behavior:**
- Creates the file if it doesn't exist
- Writes both `exception.ToString()` and `exception.StackTrace` to the file
- Properly disposes of file resources
- If file operations fail, calls `CaptureException` with stack trace enabled

**Example Usage:**
```csharp
try
{
    // Some operation
}
catch (Exception ex)
{
    ExceptionHandler.PrintStackTrace(ex, @"C:\Logs\error.log");
}
```

##### PrintExceptionStackTrace
```csharp
public static void PrintExceptionStackTrace(Exception exception, string fileName)
```

**Purpose:** Writes only the stack trace portion of an exception to a file.

**Parameters:**
- `exception` (Exception): The exception whose stack trace to log
- `fileName` (string): Path to the file where the stack trace will be written

**Behavior:**
- Similar to `PrintStackTrace` but only writes `exception.StackTrace`
- Useful when you only need the call stack without the full exception details
- Includes proper error handling and resource disposal

### 2. KryptonExceptionHandler (Public API)

A public wrapper that provides access to the internal ExceptionHandler functionality.

**Location:** `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonExceptionHandler.cs`

#### Methods

##### CaptureException
```csharp
public static void CaptureException(Exception exception,
    string title = "Exception Caught",
    [CallerFilePath] string callerFilePath = "",
    [CallerLineNumber] int lineNumber = 0,
    [CallerMemberName] string callerMethod = "",
    bool showStackTrace = false, 
    bool? useExceptionDialog = true)
```

**Purpose:** Public interface to the internal exception capture functionality.

**Note:** This method has fewer parameters than the internal version, focusing on the most commonly used options.

##### PrintStackTrace
```csharp
public static void PrintStackTrace(Exception exception, string fileName)
```

**Purpose:** Public interface to the internal stack trace printing functionality.

##### PrintExceptionStackTrace
```csharp
public static void PrintExceptionStackTrace(Exception exception, string fileName)
```

**Purpose:** Public interface to the internal exception stack trace printing functionality.

### 3. KryptonExceptionDialog (UI Component)

A static class that provides access to the advanced exception dialog UI.

**Location:** `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonExceptionDialog.cs`

#### Methods

##### Show
```csharp
public static void Show(Exception exception, bool? showCopyButton, bool? showSearchBox)
```

**Purpose:** Displays an exception using the advanced VisualExceptionDialogForm.

**Parameters:**
- `exception` (Exception): The exception to display
- `showCopyButton` (bool?): Whether to show the copy button (default: true)
- `showSearchBox` (bool?): Whether to show the search functionality (default: true)

### 4. VisualExceptionDialogForm (UI Implementation)

The actual Windows Forms dialog that displays exception information in a user-friendly format.

**Location:** `Source/Krypton Components/Krypton.Toolkit/Controls Visuals/VisualExceptionDialogForm.cs`

#### Features
- **Tree View Display:** Shows exception hierarchy with inner exceptions
- **Search Functionality:** Allows searching through exception details
- **Copy to Clipboard:** One-click copying of exception details
- **Formatted Display:** Clean, readable presentation of exception information
- **Responsive Design:** Adapts to different screen sizes
- **Localized Strings:** Uses KryptonManager.Strings for internationalization

#### Key Properties
- `_showCopyButton` (bool?): Controls copy button visibility
- `_showSearchBox` (bool?): Controls search functionality visibility
- `_exception` (Exception?): The exception being displayed
- `_originalNodes` (List<TreeNode>): Backup of original tree nodes for search functionality

## Configuration and Dependencies

### GlobalStaticValues Integration

The ExceptionHandler integrates with `GlobalStaticValues` for default configuration:

```csharp
internal const bool DEFAULT_USE_STACK_TRACE = true;
internal const bool DEFAULT_USE_EXCEPTION_MESSAGE = true;
internal const bool DEFAULT_USE_INNER_EXCEPTION = true;
```

### String Localization

The exception dialog supports localization through `KryptonManager.Strings.ExceptionDialogStrings`:

- `WindowTitle`: Dialog window title
- `ExceptionDetailsHeader`: Header for exception details section
- `ExceptionOutlineHeader`: Header for exception outline section
- `Type`: Label for exception type
- `Message`: Label for exception message
- `StackTrace`: Label for stack trace section
- `InnerException`: Label for inner exception section
- `None`: Text displayed when no inner exception exists
- `SearchBoxCueText`: Placeholder text for search box

## Usage Patterns

### Basic Exception Handling
```csharp
try
{
    // Risky operation
    PerformOperation();
}
catch (Exception ex)
{
    KryptonExceptionHandler.CaptureException(ex);
}
```

### Advanced Exception Handling with Custom Title
```csharp
try
{
    // Operation
}
catch (InvalidOperationException ex)
{
    KryptonExceptionHandler.CaptureException(ex, "Invalid Operation Detected", showStackTrace: true);
}
```

### File-Based Exception Logging
```csharp
try
{
    // Operation
}
catch (Exception ex)
{
    // Log to file
    KryptonExceptionHandler.PrintStackTrace(ex, @"C:\Logs\ApplicationErrors.log");
    
    // Also show to user
    KryptonExceptionHandler.CaptureException(ex, "Application Error");
}
```

### Custom Exception Dialog Configuration
```csharp
try
{
    // Operation
}
catch (Exception ex)
{
    // Use internal handler for full control
    ExceptionHandler.CaptureException(
        ex, 
        "Custom Error Title",
        showStackTrace: true,
        useExceptionDialog: true,
        showExceptionDialogCopyButton: true,
        showExceptionDialogSearchBox: true
    );
}
```

## Error Handling and Resilience

The ExceptionHandler includes comprehensive error handling:

1. **File Operations:** All file writing operations are wrapped in try-catch blocks
2. **Resource Management:** Proper disposal of file streams and writers
3. **Fallback Mechanisms:** If the primary exception handling fails, it falls back to basic error reporting
4. **Recursive Protection:** Prevents infinite loops when exception handling itself throws exceptions

## Integration Points

### With KryptonMessageBox
When `useExceptionDialog` is false, the ExceptionHandler uses `KryptonMessageBox.Show()` to display exception information in a simple message box format.

### With KryptonManager
The exception dialog integrates with the KryptonManager for:
- String localization
- Theme management
- Global configuration

### With GlobalStaticValues
Uses global constants for default behavior configuration.

## Best Practices

### When to Use Each Method

1. **Use `CaptureException`** for user-facing error handling where you want to display the exception
2. **Use `PrintStackTrace`** for comprehensive logging that includes full exception details
3. **Use `PrintExceptionStackTrace`** for lightweight logging that only needs the call stack
4. **Use `KryptonExceptionDialog.Show`** directly when you need fine-grained control over the dialog appearance

### Performance Considerations

- The exception dialog is modal and blocks the UI thread
- File operations are synchronous and may cause brief delays
- Consider using async patterns for file logging in high-performance scenarios

### Security Considerations

- Exception details may contain sensitive information
- File logging should use secure paths and proper permissions
- Consider sanitizing exception messages before logging in production environments

## Troubleshooting

### Common Issues

1. **File Access Denied:** Ensure the application has write permissions to the log file directory
2. **Dialog Not Appearing:** Check that the UI thread is not blocked
3. **Missing Caller Information:** Ensure you're calling from C# code (not reflection or dynamic code)

### Debugging Tips

- Use `showStackTrace: true` to get detailed call stack information
- Check the `GlobalStaticValues.DEFAULT_USE_STACK_TRACE` setting
- Verify that `KryptonManager` is properly initialized for localized strings

## Future Enhancements

Potential areas for future development:

1. **Async Support:** Add async versions of file logging methods
2. **Custom Formatters:** Allow custom exception formatting
3. **Remote Logging:** Support for sending exceptions to remote logging services
4. **Performance Metrics:** Add timing and performance tracking for exception handling
5. **Exception Filtering:** Add filtering capabilities to exclude certain exception types

## Related Documentation

- [KryptonMessageBox API Documentation](KryptonMessageBox-API-Documentation.md)
- [KryptonManager Configuration Guide](KryptonManager-Configuration-Guide.md)
- [GlobalStaticValues Reference](GlobalStaticValues-Reference.md)
- [Localization and String Management](Localization-Guide.md)
