# Krypton Exception Handling Documentation

This directory contains comprehensive documentation for the Krypton Toolkit exception handling features.

## Documentation Files

### 1. [KryptonExceptionDialog](KryptonExceptionDialog.md)
**Full API Reference Documentation** - Comprehensive, in-depth documentation covering:
- Complete API reference for all classes and methods
- Detailed feature descriptions
- Architecture and component hierarchy
- Extensive usage examples
- Localization guide
- Design considerations and best practices
- Technical details and performance considerations
- Troubleshooting guide
- Common scenarios and patterns

**Recommended for:**
- Understanding the complete API surface
- Advanced customization scenarios
- Integration planning
- Architecture reviews
- Reference during development

### 2. [KryptonExceptionDialog QuickStart](KryptonExceptionDialogQuickStart.md)
**Quick Start Guide** - Get up and running in 5 minutes:
- Basic usage examples
- Common patterns
- Quick reference tables
- Essential tips and best practices
- Troubleshooting basics

**Recommended for:**
- First-time users
- Quick implementation
- Code snippets and examples
- Common scenario lookup

## Components Overview

### KryptonExceptionDialog
Static API for displaying rich exception details in a modal dialog.

```csharp
KryptonExceptionDialog.Show(exception, showCopyButton: true, showSearchBox: true);
```

### KryptonExceptionHandler
High-level exception handling utilities with automatic caller context capture.

```csharp
KryptonExceptionHandler.CaptureException(exception, title: "Error", showStackTrace: true);
```

### VisualExceptionDialogForm
Internal form implementation (not for direct use).

### Supporting Components
- `InternalSearchableExceptionTreeView` - Searchable tree view control
- `InternalExceptionTreeView` - Exception parsing and display
- `KryptonExceptionDialogStrings` - Localization strings

## Quick Examples

### Basic Exception Display
```csharp
try
{
    ProcessData();
}
catch (Exception ex)
{
    KryptonExceptionDialog.Show(ex, true, true);
}
```

### With Auto-Context Capture
```csharp
try
{
    ProcessData();
}
catch (Exception ex)
{
    KryptonExceptionHandler.CaptureException(ex, title: "Processing Failed");
}
```

### Log and Display
```csharp
try
{
    CriticalOperation();
}
catch (Exception ex)
{
    KryptonExceptionHandler.PrintStackTrace(ex, "error.log");
    KryptonExceptionDialog.Show(ex, true, true);
}
```

## Key Features

- ✅ **Hierarchical Exception Tree** - Navigate exception chains visually
- ✅ **Real-time Search** - Find specific exceptions or stack frames quickly
- ✅ **Rich Details Panel** - Formatted exception type, message, and stack trace
- ✅ **Clipboard Support** - Copy formatted details for reporting
- ✅ **Theme Integration** - Automatically matches Krypton theme
- ✅ **Full Localization** - All strings customizable
- ✅ **Auto-Context Capture** - Automatically captures caller info (file, line, method)
- ✅ **File Logging** - Save exception details to log files

## When to Use

### ✅ Recommended
- Development and debugging
- Admin/diagnostic interfaces
- Technical support tools
- Applications where detailed error info is valuable
- Logging and error reporting systems

### ❌ Not Recommended
- Production user-facing errors (too technical)
- Expected validation errors
- Recoverable errors that don't need investigation
- Mobile or touch-first applications

## Navigation

- **[Start Here: Quick Start Guide →](KryptonExceptionDialogQuickStart.md)**
- **[Full API Reference →](KryptonExceptionDialog.md)**

## Support

For issues, questions, or feature requests:
- [GitHub Issues](https://github.com/Krypton-Suite/Standard-Toolkit/issues)
- [GitHub Discussions](https://github.com/Krypton-Suite/Standard-Toolkit/discussions)