# ExceptionHandler Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Basic Usage](#basic-usage)
3. [Advanced Configuration](#advanced-configuration)
4. [UI Integration](#ui-integration)
5. [File Logging](#file-logging)
6. [Error Handling Patterns](#error-handling-patterns)
7. [Customization](#customization)
8. [Performance Considerations](#performance-considerations)
9. [Testing and Debugging](#testing-and-debugging)
10. [Common Scenarios](#common-scenarios)
11. [API Documentation](#api-documentation)

## Getting Started

### Prerequisites

Before using the ExceptionHandler, ensure you have:

1. **Krypton Toolkit Suite** properly installed and referenced
2. **KryptonManager** initialized in your application
3. **Proper permissions** for file logging (if using file-based logging)

### Basic Setup

Add the necessary using statement to your code:

```csharp
using Krypton.Toolkit;
```

### Initialization

The ExceptionHandler doesn't require explicit initialization. It's a static class that works out of the box. However, ensure KryptonManager is initialized for proper localization:

```csharp
// In your application startup (e.g., Program.cs or Main form constructor)
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
```

## Basic Usage

### Simple Exception Handling

The most basic usage involves wrapping risky operations in try-catch blocks:

```csharp
try
{
    // Your potentially risky code here
    ProcessUserData();
    SaveToDatabase();
}
catch (Exception ex)
{
    // Let the ExceptionHandler take care of displaying the error
    KryptonExceptionHandler.CaptureException(ex);
}
```

### With Custom Error Messages

Provide more context to users by customizing the error title:

```csharp
try
{
    LoadConfigurationFile();
}
catch (FileNotFoundException ex)
{
    KryptonExceptionHandler.CaptureException(ex, "Configuration File Not Found");
}
catch (UnauthorizedAccessException ex)
{
    KryptonExceptionHandler.CaptureException(ex, "Access Denied to Configuration File");
}
catch (Exception ex)
{
    KryptonExceptionHandler.CaptureException(ex, "Unexpected Configuration Error");
}
```

### Including Stack Traces

For debugging purposes, include the full stack trace:

```csharp
try
{
    PerformComplexCalculation();
}
catch (Exception ex)
{
    KryptonExceptionHandler.CaptureException(ex, "Calculation Error", showStackTrace: true);
}
```

## Advanced Configuration

### Using the Internal ExceptionHandler

For maximum control, use the internal ExceptionHandler directly:

```csharp
try
{
    // Your code
}
catch (Exception ex)
{
    ExceptionHandler.CaptureException(
        ex,
        title: "Custom Error Title",
        showStackTrace: true,
        useExceptionDialog: true,
        showExceptionDialogCopyButton: true,
        showExceptionDialogSearchBox: true
    );
}
```

### Parameter Breakdown

- **`title`**: Custom title for the error dialog
- **`showStackTrace`**: Include full stack trace in the message
- **`useExceptionDialog`**: Use advanced dialog (true) or simple message box (false)
- **`showExceptionDialogCopyButton`**: Show copy button in advanced dialog
- **`showExceptionDialogSearchBox`**: Show search functionality in advanced dialog

### Automatic Caller Information

The ExceptionHandler automatically captures caller information using C# compiler attributes:

```csharp
public void ProcessData()
{
    try
    {
        // Some operation
    }
    catch (Exception ex)
    {
        // Automatically captures:
        // - File path: "C:\MyApp\DataProcessor.cs"
        // - Line number: 42
        // - Method name: "ProcessData"
        ExceptionHandler.CaptureException(ex);
    }
}
```

## UI Integration

### Exception Dialog Features

The advanced exception dialog (`KryptonExceptionDialog`) provides:

1. **Tree View Display**: Hierarchical view of exceptions and inner exceptions
2. **Search Functionality**: Search through exception details
3. **Copy to Clipboard**: One-click copying of exception information
4. **Formatted Display**: Clean, readable presentation
5. **Responsive Design**: Adapts to different screen sizes

### Dialog Customization

```csharp
try
{
    // Your code
}
catch (Exception ex)
{
    // Show advanced dialog with all features
    KryptonExceptionDialog.Show(ex, showCopyButton: true, showSearchBox: true);
}
```

### Simple Message Box Mode

For simpler applications or when you prefer basic error display:

```csharp
try
{
    // Your code
}
catch (Exception ex)
{
    // Use simple message box instead of advanced dialog
    ExceptionHandler.CaptureException(ex, useExceptionDialog: false);
}
```

## File Logging

### Basic File Logging

Log exceptions to files for later analysis:

```csharp
try
{
    ProcessBatchData();
}
catch (Exception ex)
{
    // Log to file
    KryptonExceptionHandler.PrintStackTrace(ex, @"C:\Logs\BatchProcessing.log");
    
    // Also show to user
    KryptonExceptionHandler.CaptureException(ex, "Batch Processing Error");
}
```

### Stack Trace Only Logging

For lightweight logging that only captures the call stack:

```csharp
try
{
    ValidateUserInput();
}
catch (Exception ex)
{
    // Log only the stack trace
    KryptonExceptionHandler.PrintExceptionStackTrace(ex, @"C:\Logs\ValidationErrors.log");
}
```

### Log File Management

Implement proper log file management:

```csharp
public class LogManager
{
    private static readonly string LogDirectory = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "MyApplication",
        "Logs"
    );
    
    private static string GetLogFileName(string operation)
    {
        var timestamp = DateTime.Now.ToString("yyyy-MM-dd");
        return Path.Combine(LogDirectory, $"{operation}_{timestamp}.log");
    }
    
    public static void LogException(Exception ex, string operation)
    {
        try
        {
            // Ensure log directory exists
            Directory.CreateDirectory(LogDirectory);
            
            // Log the exception
            var logFile = GetLogFileName(operation);
            KryptonExceptionHandler.PrintStackTrace(ex, logFile);
            
            // Also show to user
            KryptonExceptionHandler.CaptureException(ex, $"{operation} Error");
        }
        catch (Exception logEx)
        {
            // Fallback if logging fails
            KryptonExceptionHandler.CaptureException(logEx, "Logging Error");
        }
    }
}
```

## Error Handling Patterns

### Pattern 1: Fail-Safe with User Notification

```csharp
public bool TryProcessData(string data)
{
    try
    {
        ProcessData(data);
        return true;
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Data Processing Failed");
        return false;
    }
}
```

### Pattern 2: Retry with Exception Handling

```csharp
public void ProcessWithRetry(string data, int maxRetries = 3)
{
    for (int attempt = 1; attempt <= maxRetries; attempt++)
    {
        try
        {
            ProcessData(data);
            return; // Success
        }
        catch (Exception ex)
        {
            if (attempt == maxRetries)
            {
                // Final attempt failed
                KryptonExceptionHandler.CaptureException(
                    ex, 
                    $"Data Processing Failed After {maxRetries} Attempts",
                    showStackTrace: true
                );
                throw; // Re-throw if needed
            }
            else
            {
                // Log retry attempt
                KryptonExceptionHandler.PrintStackTrace(ex, 
                    $@"C:\Logs\RetryAttempt_{attempt}.log");
                
                // Wait before retry
                Thread.Sleep(1000 * attempt);
            }
        }
    }
}
```

### Pattern 3: Specific Exception Handling

```csharp
public void HandleSpecificExceptions()
{
    try
    {
        PerformOperation();
    }
    catch (ArgumentNullException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Invalid Parameter");
    }
    catch (FileNotFoundException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Required File Not Found");
    }
    catch (UnauthorizedAccessException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Access Denied");
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Unexpected Error");
    }
}
```

### Pattern 4: Background Task Exception Handling

```csharp
public async Task ProcessDataAsync()
{
    try
    {
        await Task.Run(() => ProcessData());
    }
    catch (Exception ex)
    {
        // Log the exception
        KryptonExceptionHandler.PrintStackTrace(ex, @"C:\Logs\AsyncErrors.log");
        
        // Show user-friendly message
        KryptonExceptionHandler.CaptureException(ex, "Background Processing Error");
    }
}
```

## Customization

### Custom Exception Dialog Behavior

```csharp
public static class CustomExceptionHandler
{
    public static void ShowCustomException(Exception ex, string context)
    {
        // Custom title based on context
        string title = $"Error in {context}";
        
        // Always show stack trace for debugging
        bool showStackTrace = Debugger.IsAttached;
        
        // Use advanced dialog with all features
        ExceptionHandler.CaptureException(
            ex,
            title: title,
            showStackTrace: showStackTrace,
            useExceptionDialog: true,
            showExceptionDialogCopyButton: true,
            showExceptionDialogSearchBox: true
        );
    }
}
```

### Environment-Specific Configuration

```csharp
public static class EnvironmentAwareExceptionHandler
{
    public static void HandleException(Exception ex, string operation)
    {
        bool isDebugMode = Debugger.IsAttached;
        bool isProduction = !isDebugMode;
        
        if (isProduction)
        {
            // Production: Log to file, show simple message
            KryptonExceptionHandler.PrintStackTrace(ex, GetLogFilePath(operation));
            KryptonExceptionHandler.CaptureException(ex, "An error occurred", useExceptionDialog: false);
        }
        else
        {
            // Development: Show detailed dialog with stack trace
            ExceptionHandler.CaptureException(
                ex,
                title: $"Development Error in {operation}",
                showStackTrace: true,
                useExceptionDialog: true,
                showExceptionDialogCopyButton: true,
                showExceptionDialogSearchBox: true
            );
        }
    }
    
    private static string GetLogFilePath(string operation)
    {
        var logDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "MyApp", "Logs");
        Directory.CreateDirectory(logDir);
        return Path.Combine(logDir, $"{operation}_{DateTime.Now:yyyy-MM-dd}.log");
    }
}
```

## Performance Considerations

### Async Exception Handling

For non-blocking exception handling:

```csharp
public async Task ProcessDataAsync()
{
    try
    {
        await ProcessData();
    }
    catch (Exception ex)
    {
        // Log asynchronously to avoid blocking UI
        _ = Task.Run(() => 
        {
            KryptonExceptionHandler.PrintStackTrace(ex, @"C:\Logs\AsyncErrors.log");
        });
        
        // Show exception dialog on UI thread
        await Task.Run(() => 
        {
            KryptonExceptionHandler.CaptureException(ex, "Async Processing Error");
        });
    }
}
```

### Exception Handling in Loops

```csharp
public void ProcessMultipleItems(List<string> items)
{
    var errors = new List<Exception>();
    
    foreach (var item in items)
    {
        try
        {
            ProcessItem(item);
        }
        catch (Exception ex)
        {
            errors.Add(ex);
            
            // Log individual error
            KryptonExceptionHandler.PrintStackTrace(ex, 
                $@"C:\Logs\ItemError_{item.GetHashCode()}.log");
        }
    }
    
    // Show summary if there were errors
    if (errors.Count > 0)
    {
        var summaryEx = new AggregateException("Multiple items failed to process", errors);
        KryptonExceptionHandler.CaptureException(summaryEx, 
            $"Processing Complete - {errors.Count} Errors");
    }
}
```

## Testing and Debugging

### Unit Testing Exception Handling

```csharp
[Test]
public void TestExceptionHandling()
{
    // Arrange
    var testException = new InvalidOperationException("Test exception");
    var logFile = Path.GetTempFileName();
    
    try
    {
        // Act
        KryptonExceptionHandler.PrintStackTrace(testException, logFile);
        
        // Assert
        Assert.IsTrue(File.Exists(logFile));
        var logContent = File.ReadAllText(logFile);
        Assert.IsTrue(logContent.Contains("Test exception"));
        Assert.IsTrue(logContent.Contains("InvalidOperationException"));
    }
    finally
    {
        // Cleanup
        if (File.Exists(logFile))
            File.Delete(logFile);
    }
}
```

### Debugging Exception Flow

```csharp
public void DebugExceptionHandling()
{
    try
    {
        // Your code
    }
    catch (Exception ex)
    {
        // Add debug information
        Debug.WriteLine($"Exception caught: {ex.GetType().Name}");
        Debug.WriteLine($"Message: {ex.Message}");
        Debug.WriteLine($"Stack trace: {ex.StackTrace}");
        
        // Use ExceptionHandler
        ExceptionHandler.CaptureException(ex, "Debug Exception", showStackTrace: true);
    }
}
```

### Conditional Exception Handling

```csharp
public void ConditionalExceptionHandling()
{
    try
    {
        ProcessData();
    }
    catch (Exception ex)
    {
        // Only show dialog in debug mode
        if (Debugger.IsAttached)
        {
            ExceptionHandler.CaptureException(ex, "Debug Exception", showStackTrace: true);
        }
        else
        {
            // In production, just log
            KryptonExceptionHandler.PrintStackTrace(ex, @"C:\Logs\ProductionErrors.log");
        }
    }
}
```

## Common Scenarios

### Scenario 1: Database Connection Errors

```csharp
public void ConnectToDatabase()
{
    try
    {
        using var connection = new SqlConnection(connectionString);
        connection.Open();
        // Database operations
    }
    catch (SqlException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Database Connection Failed");
    }
    catch (InvalidOperationException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Database Operation Invalid");
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Unexpected Database Error");
    }
}
```

### Scenario 2: File Operations

```csharp
public void ProcessFile(string filePath)
{
    try
    {
        if (!File.Exists(filePath))
            throw new FileNotFoundException($"File not found: {filePath}");
            
        var content = File.ReadAllText(filePath);
        ProcessContent(content);
    }
    catch (FileNotFoundException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "File Not Found");
    }
    catch (UnauthorizedAccessException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Access Denied to File");
    }
    catch (IOException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "File I/O Error");
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "File Processing Error");
    }
}
```

### Scenario 3: Network Operations

```csharp
public async Task DownloadDataAsync(string url)
{
    try
    {
        using var client = new HttpClient();
        var response = await client.GetAsync(url);
        response.EnsureSuccessStatusCode();
        var content = await response.Content.ReadAsStringAsync();
        ProcessDownloadedData(content);
    }
    catch (HttpRequestException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Network Request Failed");
    }
    catch (TaskCanceledException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Download Timeout");
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Download Error");
    }
}
```

### Scenario 4: User Input Validation

```csharp
public void ValidateUserInput(string input)
{
    try
    {
        if (string.IsNullOrWhiteSpace(input))
            throw new ArgumentException("Input cannot be empty");
            
        if (input.Length > 100)
            throw new ArgumentException("Input too long");
            
        ProcessInput(input);
    }
    catch (ArgumentException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Invalid Input");
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Input Processing Error");
    }
}
```

### Scenario 5: Configuration Loading

```csharp
public void LoadConfiguration()
{
    try
    {
        var configPath = Path.Combine(Application.StartupPath, "config.json");
        
        if (!File.Exists(configPath))
            throw new FileNotFoundException("Configuration file not found");
            
        var json = File.ReadAllText(configPath);
        var config = JsonSerializer.Deserialize<AppConfig>(json);
        
        ApplyConfiguration(config);
    }
    catch (FileNotFoundException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Configuration File Missing");
    }
    catch (JsonException ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Invalid Configuration Format");
    }
    catch (Exception ex)
    {
        KryptonExceptionHandler.CaptureException(ex, "Configuration Loading Error");
    }
}
```

## API Documentation

For API documentation, see [here](ExceptionHandlerAPIDocumentation.md).

## Best Practices Summary

1. **Always provide meaningful error titles** to help users understand what went wrong
2. **Use specific exception types** when possible for better error handling
3. **Log exceptions to files** for debugging and analysis
4. **Show stack traces only in debug mode** to avoid confusing end users
5. **Use the advanced dialog** for development and debugging
6. **Use simple message boxes** for production user-facing errors
7. **Implement proper cleanup** in finally blocks
8. **Consider async patterns** for non-blocking exception handling
9. **Test your exception handling** to ensure it works as expected
10. **Document your error handling strategy** for team consistency

This guide provides comprehensive coverage of how to effectively use the ExceptionHandler feature in your Krypton Toolkit applications. Choose the patterns and approaches that best fit your application's needs and requirements.
