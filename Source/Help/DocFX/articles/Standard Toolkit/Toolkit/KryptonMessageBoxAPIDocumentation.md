# KryptonMessageBox API Documentation

## Table of Contents
1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [Method Overloads](#method-overloads)
4. [Enumerations](#enumerations)
5. [Advanced Features](#advanced-features)
6. [Customization](#customization)
7. [Best Practices](#best-practices)
8. [Migration from MessageBox](#migration-from-messagebox)
9. [Examples](#examples)
10. [Troubleshooting](#troubleshooting)

## Overview

The `KryptonMessageBox` is a themed replacement for the standard Windows Forms `MessageBox` that provides a consistent look and feel with the Krypton Toolkit Suite. It offers enhanced functionality while maintaining API compatibility with the standard MessageBox.

**Namespace:** `Krypton.Toolkit`  
**Type:** `public static class KryptonMessageBox`  
**Location:** `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonMessageBox.cs`

### Key Features

- **Theme Integration**: Automatically follows the current Krypton theme
- **Enhanced Functionality**: Additional options not available in standard MessageBox
- **API Compatibility**: Drop-in replacement for MessageBox.Show()
- **RTL Support**: Built-in right-to-left language support
- **Customizable**: Extensive customization options
- **Help Integration**: Built-in help button support
- **Copy Functionality**: Optional Ctrl+C copy support

### Advantages Over Standard MessageBox

1. **Consistent Theming**: Matches your application's Krypton theme
2. **Enhanced Options**: More control over appearance and behavior
3. **Better Integration**: Seamlessly integrates with Krypton controls
4. **Modern Appearance**: Professional, modern look and feel
5. **Accessibility**: Better accessibility features

## Basic Usage

### Simple Message Box

The simplest way to display a message box:

```csharp
// Basic message box
KryptonMessageBox.Show("Hello, World!");

// With caption
KryptonMessageBox.Show("Hello, World!", "Greeting");
```

### With Buttons and Icons

```csharp
// Message box with buttons and icon
var result = KryptonMessageBox.Show(
    "Do you want to save changes?", 
    "Save Document", 
    KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Question
);

if (result == DialogResult.Yes)
{
    // Save changes
}
```

### With Owner Window

```csharp
// Message box with owner window
var result = KryptonMessageBox.Show(
    this, // Owner window
    "Are you sure you want to exit?", 
    "Exit Application", 
    KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Warning
);
```

## Method Overloads

The `KryptonMessageBox.Show()` method provides multiple overloads to accommodate different scenarios:

### 1. Basic Overloads

```csharp
// Text only
public static DialogResult Show(string text)

// Text and caption
public static DialogResult Show(string text, string caption)

// Text, caption, and buttons
public static DialogResult Show(string text, string caption, KryptonMessageBoxButtons buttons)

// Text, caption, buttons, and icon
public static DialogResult Show(string text, string caption, KryptonMessageBoxButtons buttons, KryptonMessageBoxIcon icon)
```

### 2. Advanced Overloads

```csharp
// With default button
public static DialogResult Show(string text, string caption, KryptonMessageBoxButtons buttons, 
    KryptonMessageBoxIcon icon, KryptonMessageBoxDefaultButton defaultButton)

// With options
public static DialogResult Show(string text, string caption, KryptonMessageBoxButtons buttons, 
    KryptonMessageBoxIcon icon, KryptonMessageBoxDefaultButton defaultButton, MessageBoxOptions options)

// With help information
public static DialogResult Show(string text, string caption, KryptonMessageBoxButtons buttons, 
    KryptonMessageBoxIcon icon, KryptonMessageBoxDefaultButton defaultButton, MessageBoxOptions options, 
    HelpInfo helpInfo)
```

### 3. Owner Window Overloads

All overloads also support an owner window parameter:

```csharp
// With owner window
public static DialogResult Show(IWin32Window owner, string text)
public static DialogResult Show(IWin32Window owner, string text, string caption)
// ... and so on for all overloads
```

### 4. Enhanced Parameters

All overloads support additional parameters:

```csharp
// Enhanced parameters available in all overloads
bool? showCtrlCopy = null,        // Show Ctrl+C copy functionality
bool? showCloseButton = null      // Show close button
```

## Enumerations

### KryptonMessageBoxButtons

Defines the buttons to display in the message box:

```csharp
public enum KryptonMessageBoxButtons
{
    OK = 0,                    // OK button only
    OKCancel = 1,              // OK and Cancel buttons
    AbortRetryIgnore = 2,      // Abort, Retry, and Ignore buttons
    YesNoCancel = 3,           // Yes, No, and Cancel buttons
    YesNo = 4,                 // Yes and No buttons
    RetryCancel = 5            // Retry and Cancel buttons
}
```

**Usage:**
```csharp
// Different button combinations
KryptonMessageBox.Show("Save changes?", "Save", KryptonMessageBoxButtons.YesNo);
KryptonMessageBox.Show("Error occurred", "Error", KryptonMessageBoxButtons.OK);
KryptonMessageBox.Show("Retry operation?", "Retry", KryptonMessageBoxButtons.RetryCancel);
```

### KryptonMessageBoxIcon

Defines the icon to display in the message box:

```csharp
public enum KryptonMessageBoxIcon
{
    None = 0,                  // No icon
    Error = 16,               // Error icon (red X)
    Question = 32,            // Question icon (question mark)
    Warning = 48,             // Warning icon (yellow triangle)
    Information = 64          // Information icon (blue i)
}
```

**Usage:**
```csharp
// Different icon types
KryptonMessageBox.Show("File saved successfully", "Success", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
KryptonMessageBox.Show("File not found", "Error", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Error);
KryptonMessageBox.Show("Are you sure?", "Confirm", KryptonMessageBoxButtons.YesNo, KryptonMessageBoxIcon.Question);
```

### KryptonMessageBoxDefaultButton

Defines which button is the default:

```csharp
public enum KryptonMessageBoxDefaultButton
{
    Button1 = 0,              // First button (default)
    Button2 = 256,            // Second button
    Button3 = 512             // Third button
}
```

**Usage:**
```csharp
// Set default button
KryptonMessageBox.Show("Delete file?", "Delete", KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Warning, KryptonMessageBoxDefaultButton.Button2); // No is default
```

## Advanced Features

### Copy Functionality

Enable Ctrl+C copy functionality to allow users to copy the message text:

```csharp
// Enable copy functionality
KryptonMessageBox.Show("Error details here", "Error", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Error, showCtrlCopy: true);

// Copy functionality is automatically enabled for Error and Warning icons
KryptonMessageBox.Show("Warning message", "Warning", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Warning); // Copy automatically enabled
```

### Close Button Control

Control whether the close button (X) is displayed:

```csharp
// Hide close button
KryptonMessageBox.Show("Important message", "Important", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Information, showCloseButton: false);

// Show close button (default)
KryptonMessageBox.Show("Regular message", "Info", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Information, showCloseButton: true);
```

### Help Integration

Add help functionality to message boxes:

```csharp
// Create help information
var helpInfo = new HelpInfo("https://example.com/help", "MessageBoxHelp");

// Show message box with help
KryptonMessageBox.Show("Need help?", "Help Available", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Question, KryptonMessageBoxDefaultButton.Button1, 
    MessageBoxOptions.None, helpInfo);
```

### RTL Support

Support for right-to-left languages:

```csharp
// RTL support
KryptonMessageBox.Show("Arabic text here", "Title", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Information, KryptonMessageBoxDefaultButton.Button1, 
    MessageBoxOptions.RtlReading);
```

## Customization

### Theme Integration

KryptonMessageBox automatically follows the current Krypton theme:

```csharp
// Set theme before showing message box
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
KryptonMessageBox.Show("Themed message box", "Theme Demo");

// Switch theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
KryptonMessageBox.Show("Different theme", "Theme Demo");
```

### Custom Styling

While KryptonMessageBox follows the global theme, you can customize individual message boxes:

```csharp
// Custom message box with specific settings
var result = KryptonMessageBox.Show(
    "Custom styled message", 
    "Custom Title", 
    KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Question,
    KryptonMessageBoxDefaultButton.Button2,
    MessageBoxOptions.None,
    showCtrlCopy: true,
    showCloseButton: false
);
```

### String Localization

Use localized strings for message boxes:

```csharp
// Use localized strings
var message = KryptonLanguageManager.Strings.GeneralStrings.SaveConfirmation;
var title = KryptonLanguageManager.Strings.GeneralStrings.SaveTitle;
var result = KryptonMessageBox.Show(message, title, KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Question);
```

## Best Practices

### 1. Use Appropriate Icons

Choose the right icon for your message type:

```csharp
// Good - appropriate icon usage
KryptonMessageBox.Show("File saved successfully", "Success", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
KryptonMessageBox.Show("File not found", "Error", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Error);
KryptonMessageBox.Show("Are you sure?", "Confirm", KryptonMessageBoxButtons.YesNo, KryptonMessageBoxIcon.Question);
KryptonMessageBox.Show("Disk space low", "Warning", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Warning);

// Avoid - inappropriate icon usage
KryptonMessageBox.Show("Error occurred", "Error", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information); // Should use Error icon
```

### 2. Provide Clear Messages

Write clear, concise messages:

```csharp
// Good - clear and specific
KryptonMessageBox.Show("The file 'document.docx' has been saved successfully.", "File Saved", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);

// Avoid - vague messages
KryptonMessageBox.Show("Done", "Status", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
```

### 3. Use Appropriate Button Combinations

Choose the right buttons for the situation:

```csharp
// Good - appropriate button choices
KryptonMessageBox.Show("Save changes before closing?", "Save", KryptonMessageBoxButtons.YesNoCancel);
KryptonMessageBox.Show("Operation failed. Retry?", "Error", KryptonMessageBoxButtons.RetryCancel);
KryptonMessageBox.Show("File deleted successfully", "Deleted", KryptonMessageBoxButtons.OK);

// Avoid - inappropriate button choices
KryptonMessageBox.Show("Save changes?", "Save", KryptonMessageBoxButtons.AbortRetryIgnore); // Too many options
```

### 4. Set Appropriate Default Buttons

Choose the safest default button:

```csharp
// Good - safe defaults
KryptonMessageBox.Show("Delete file?", "Delete", KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Warning, KryptonMessageBoxDefaultButton.Button2); // No is default

KryptonMessageBox.Show("Save changes?", "Save", KryptonMessageBoxButtons.YesNoCancel, 
    KryptonMessageBoxIcon.Question, KryptonMessageBoxDefaultButton.Button1); // Yes is default

// Avoid - dangerous defaults
KryptonMessageBox.Show("Delete all files?", "Delete", KryptonMessageBoxButtons.YesNo, 
    KryptonMessageBoxIcon.Warning, KryptonMessageBoxDefaultButton.Button1); // Yes is default - dangerous!
```

### 5. Handle Results Properly

Always handle the dialog result:

```csharp
// Good - proper result handling
var result = KryptonMessageBox.Show("Save changes?", "Save", KryptonMessageBoxButtons.YesNoCancel, KryptonMessageBoxIcon.Question);

switch (result)
{
    case DialogResult.Yes:
        SaveDocument();
        break;
    case DialogResult.No:
        // Don't save
        break;
    case DialogResult.Cancel:
        // Cancel operation
        return;
}

// Avoid - ignoring results
KryptonMessageBox.Show("Save changes?", "Save", KryptonMessageBoxButtons.YesNo, KryptonMessageBoxIcon.Question);
// What happens next? User choice is ignored!
```

## Migration from MessageBox

### Simple Migration

For basic usage, KryptonMessageBox is a drop-in replacement:

```csharp
// Before (standard MessageBox)
MessageBox.Show("Hello, World!");
MessageBox.Show("Hello, World!", "Title");
MessageBox.Show("Save changes?", "Save", MessageBoxButtons.YesNo, MessageBoxIcon.Question);

// After (KryptonMessageBox)
KryptonMessageBox.Show("Hello, World!");
KryptonMessageBox.Show("Hello, World!", "Title");
KryptonMessageBox.Show("Save changes?", "Save", KryptonMessageBoxButtons.YesNo, KryptonMessageBoxIcon.Question);
```

### Migration Script

Here's a simple migration script to help convert existing MessageBox calls:

```csharp
public static class MessageBoxMigrationHelper
{
    public static void MigrateMessageBoxCalls()
    {
        // Find and replace patterns:
        // MessageBox.Show -> KryptonMessageBox.Show
        // MessageBoxButtons -> KryptonMessageBoxButtons
        // MessageBoxIcon -> KryptonMessageBoxIcon
        // MessageBoxDefaultButton -> KryptonMessageBoxDefaultButton
        
        // Example conversions:
        ConvertMessageBox("MessageBox.Show(\"text\");", "KryptonMessageBox.Show(\"text\");");
        ConvertMessageBox("MessageBox.Show(\"text\", \"title\");", "KryptonMessageBox.Show(\"text\", \"title\");");
        ConvertMessageBox("MessageBox.Show(\"text\", \"title\", MessageBoxButtons.YesNo);", 
            "KryptonMessageBox.Show(\"text\", \"title\", KryptonMessageBoxButtons.YesNo);");
    }
    
    private static void ConvertMessageBox(string oldPattern, string newPattern)
    {
        // Implementation would depend on your specific migration needs
        Console.WriteLine($"Convert: {oldPattern} -> {newPattern}");
    }
}
```

### Enhanced Migration

Take advantage of KryptonMessageBox's enhanced features:

```csharp
// Before (standard MessageBox)
var result = MessageBox.Show("Error occurred", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);

// After (enhanced KryptonMessageBox)
var result = KryptonMessageBox.Show("Error occurred", "Error", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Error, showCtrlCopy: true); // Enable copy functionality
```

## Examples

### Common Scenarios

#### 1. Confirmation Dialogs

```csharp
public static class ConfirmationDialogs
{
    public static bool ConfirmSave()
    {
        var result = KryptonMessageBox.Show(
            "Do you want to save changes to this document?", 
            "Save Document", 
            KryptonMessageBoxButtons.YesNoCancel, 
            KryptonMessageBoxIcon.Question,
            KryptonMessageBoxDefaultButton.Button1
        );
        
        return result == DialogResult.Yes;
    }
    
    public static bool ConfirmDelete()
    {
        var result = KryptonMessageBox.Show(
            "Are you sure you want to delete this item? This action cannot be undone.", 
            "Delete Item", 
            KryptonMessageBoxButtons.YesNo, 
            KryptonMessageBoxIcon.Warning,
            KryptonMessageBoxDefaultButton.Button2 // No is default
        );
        
        return result == DialogResult.Yes;
    }
    
    public static bool ConfirmExit()
    {
        var result = KryptonMessageBox.Show(
            "Are you sure you want to exit the application?", 
            "Exit Application", 
            KryptonMessageBoxButtons.YesNo, 
            KryptonMessageBoxIcon.Question,
            KryptonMessageBoxDefaultButton.Button2 // No is default
        );
        
        return result == DialogResult.Yes;
    }
}
```

#### 2. Error Handling

```csharp
public static class ErrorDialogs
{
    public static void ShowError(string message, string title = "Error")
    {
        KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Error,
            showCtrlCopy: true // Enable copy for error messages
        );
    }
    
    public static void ShowError(Exception ex, string context = "")
    {
        var message = string.IsNullOrEmpty(context) 
            ? ex.Message 
            : $"{context}: {ex.Message}";
            
        KryptonMessageBox.Show(
            message, 
            "Error", 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Error,
            showCtrlCopy: true
        );
    }
    
    public static DialogResult ShowRetryError(string message, string title = "Error")
    {
        return KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.RetryCancel, 
            KryptonMessageBoxIcon.Error,
            KryptonMessageBoxDefaultButton.Button1, // Retry is default
            showCtrlCopy: true
        );
    }
}
```

#### 3. Information Dialogs

```csharp
public static class InformationDialogs
{
    public static void ShowInfo(string message, string title = "Information")
    {
        KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Information
        );
    }
    
    public static void ShowSuccess(string message, string title = "Success")
    {
        KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Information
        );
    }
    
    public static void ShowWarning(string message, string title = "Warning")
    {
        KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Warning,
            showCtrlCopy: true // Enable copy for warnings
        );
    }
}
```

#### 4. Custom Message Boxes

```csharp
public static class CustomMessageBoxes
{
    public static void ShowAbout()
    {
        var aboutText = "My Application v1.0\n\n" +
                       "A sample application built with Krypton Toolkit Suite.\n\n" +
                       "Copyright © 2025 My Company";
                       
        KryptonMessageBox.Show(
            aboutText, 
            "About", 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Information
        );
    }
    
    public static bool ShowLicenseAgreement()
    {
        var licenseText = "Do you agree to the terms of the license agreement?\n\n" +
                         "By clicking 'Yes', you agree to be bound by the terms and conditions.";
                         
        var result = KryptonMessageBox.Show(
            licenseText, 
            "License Agreement", 
            KryptonMessageBoxButtons.YesNo, 
            KryptonMessageBoxIcon.Question,
            KryptonMessageBoxDefaultButton.Button2 // No is default
        );
        
        return result == DialogResult.Yes;
    }
    
    public static void ShowHelp(string helpText, string title = "Help")
    {
        var helpInfo = new HelpInfo("https://example.com/help", "MessageBoxHelp");
        
        KryptonMessageBox.Show(
            helpText, 
            title, 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Information,
            KryptonMessageBoxDefaultButton.Button1,
            MessageBoxOptions.None,
            helpInfo
        );
    }
}
```

#### 5. Localized Message Boxes

```csharp
public static class LocalizedMessageBoxes
{
    public static bool ConfirmSave()
    {
        var message = KryptonLanguageManager.Strings.GeneralStrings.SaveConfirmation;
        var title = KryptonLanguageManager.Strings.GeneralStrings.SaveTitle;
        
        var result = KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.YesNoCancel, 
            KryptonMessageBoxIcon.Question
        );
        
        return result == DialogResult.Yes;
    }
    
    public static void ShowError(string errorKey)
    {
        var message = KryptonLanguageManager.Strings.ErrorStrings.GetString(errorKey);
        var title = KryptonLanguageManager.Strings.ErrorStrings.ErrorTitle;
        
        KryptonMessageBox.Show(
            message, 
            title, 
            KryptonMessageBoxButtons.OK, 
            KryptonMessageBoxIcon.Error,
            showCtrlCopy: true
        );
    }
}
```

## Troubleshooting

### Common Issues

#### 1. Message Box Not Themed

**Problem**: Message box appears with standard Windows styling instead of Krypton theme.

**Solution**: Ensure KryptonManager is properly initialized:

```csharp
// Fix: Initialize KryptonManager first
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
KryptonMessageBox.Show("Themed message");
```

#### 2. Copy Functionality Not Working

**Problem**: Ctrl+C doesn't copy the message text.

**Solution**: Enable copy functionality explicitly:

```csharp
// Fix: Enable copy functionality
KryptonMessageBox.Show("Error message", "Error", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Error, showCtrlCopy: true);
```

#### 3. Help Button Not Appearing

**Problem**: Help button doesn't show even when HelpInfo is provided.

**Solution**: Ensure HelpInfo is properly constructed:

```csharp
// Fix: Proper HelpInfo construction
var helpInfo = new HelpInfo("https://example.com/help", "HelpTopic");
KryptonMessageBox.Show("Message", "Title", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Information, KryptonMessageBoxDefaultButton.Button1, 
    MessageBoxOptions.None, helpInfo);
```

#### 4. RTL Text Not Displaying Correctly

**Problem**: Right-to-left text appears incorrectly.

**Solution**: Use MessageBoxOptions.RtlReading:

```csharp
// Fix: Enable RTL reading
KryptonMessageBox.Show("Arabic text", "Title", KryptonMessageBoxButtons.OK, 
    KryptonMessageBoxIcon.Information, KryptonMessageBoxDefaultButton.Button1, 
    MessageBoxOptions.RtlReading);
```

### Debugging Tips

#### 1. Check Current Theme

```csharp
public static void DebugCurrentTheme()
{
    Console.WriteLine($"Current Theme: {KryptonManager.GlobalPaletteMode}");
    Console.WriteLine($"Theme Applied: {KryptonManager.GlobalPaletteMode != PaletteMode.Custom}");
}
```

#### 2. Test Different Overloads

```csharp
public static void TestMessageBoxOverloads()
{
    // Test basic overload
    KryptonMessageBox.Show("Basic test");
    
    // Test with buttons
    KryptonMessageBox.Show("Button test", "Test", KryptonMessageBoxButtons.YesNo);
    
    // Test with icon
    KryptonMessageBox.Show("Icon test", "Test", KryptonMessageBoxButtons.OK, KryptonMessageBoxIcon.Information);
    
    // Test with all options
    KryptonMessageBox.Show("Full test", "Test", KryptonMessageBoxButtons.YesNo, 
        KryptonMessageBoxIcon.Question, KryptonMessageBoxDefaultButton.Button1, 
        MessageBoxOptions.None, showCtrlCopy: true, showCloseButton: true);
}
```

#### 3. Validate Parameters

```csharp
public static bool ValidateMessageBoxParameters(string text, string caption, 
    KryptonMessageBoxButtons buttons, KryptonMessageBoxIcon icon)
{
    try
    {
        // Validate text
        if (string.IsNullOrEmpty(text))
        {
            Console.WriteLine("Error: Text cannot be null or empty");
            return false;
        }
        
        // Validate button and icon combination
        if (buttons == KryptonMessageBoxButtons.AbortRetryIgnore && icon == KryptonMessageBoxIcon.Question)
        {
            Console.WriteLine("Warning: AbortRetryIgnore with Question icon may be confusing");
        }
        
        return true;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Validation error: {ex.Message}");
        return false;
    }
}
```

This comprehensive documentation provides developers with complete information about using the KryptonMessageBox API effectively in their Krypton Toolkit Suite applications.
