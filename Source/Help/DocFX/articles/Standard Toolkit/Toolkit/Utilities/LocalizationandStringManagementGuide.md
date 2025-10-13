# Localization and String Management Guide

## Table of Contents
1. [Overview](#overview)
2. [String Management Architecture](#string-management-architecture)
3. [KryptonLanguageManager](#kryptonlanguagemanager)
4. [String Collections](#string-collections)
5. [Localization Implementation](#localization-implementation)
6. [Custom String Management](#custom-string-management)
7. [Best Practices](#best-practices)
8. [Migration from KryptonManager.Strings](#migration-from-kryptonmanagerstrings)

## Overview

The Krypton Toolkit Suite provides comprehensive localization and string management capabilities to support international applications. The system has evolved from the legacy `KryptonManager.Strings` approach to a more robust `KryptonLanguageManager` system that better supports translations and multi-language applications.

### Key Features

- **Centralized String Management**: All UI strings are managed through dedicated string collection classes
- **Localization Support**: Built-in support for multiple languages and cultures
- **Designer Integration**: String properties are visible and editable in the Visual Studio designer
- **Type Safety**: Strongly-typed string properties prevent runtime errors
- **Extensibility**: Easy to add custom string collections for application-specific needs

## String Management Architecture

### Core Components

```
KryptonLanguageManager (New System)
    ↓
String Collection Classes
    ↓
Individual String Properties
    ↓
UI Controls
```

### Legacy vs New System

**Legacy System (Deprecated):**
```csharp
// OLD - Deprecated
KryptonManager.Strings.GeneralStrings.OK
```

**New System (Recommended):**
```csharp
// NEW - Current approach
KryptonLanguageManager.Strings.GeneralStrings.OK
```

## KryptonLanguageManager

The `KryptonLanguageManager` is the central hub for all string management in the Krypton Toolkit Suite.

### Basic Usage

```csharp
using Krypton.Toolkit;

// Access general strings
string okText = KryptonLanguageManager.Strings.GeneralStrings.OK;
string cancelText = KryptonLanguageManager.Strings.GeneralStrings.Cancel;

// Access message box strings
string errorTitle = KryptonLanguageManager.Strings.MessageBoxStrings.ErrorTitle;
string warningTitle = KryptonLanguageManager.Strings.MessageBoxStrings.WarningTitle;
```

### Initialization

```csharp
// In your application startup (e.g., Program.cs)
public static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    
    // Initialize KryptonManager first
    KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
    
    // Language manager is automatically initialized
    // No explicit initialization required
    
    Application.Run(new MainForm());
}
```

## String Collections

The Krypton Toolkit Suite organizes strings into logical collections based on functionality.

### GeneralToolkitStrings

Contains common UI strings used throughout the toolkit.

```csharp
public class GeneralToolkitStrings
{
    // Button text
    public string OK { get; set; } = "O&K";
    public string Cancel { get; set; } = "Cance&l";
    public string Yes { get; set; } = "&Yes";
    public string No { get; set; } = "N&o";
    public string Abort { get; set; } = "A&bort";
    public string Retry { get; set; } = "Ret&ry";
    public string Ignore { get; set; } = "I&gnore";
    public string Close { get; set; } = "Clo&se";
    
    // Clipboard operations
    public string Cut { get; set; } = "Cu&t";
    public string Copy { get; set; } = "&Copy";
    public string Paste { get; set; } = "&Paste";
    public string SelectAll { get; set; } = "Select &All";
    
    // Other common strings
    public string Today { get; set; } = "&Today";
    public string Help { get; set; } = "H&elp";
    public string Administrator { get; set; } = "Administrator";
}
```

### MessageBoxStrings

Contains strings specific to message box dialogs.

```csharp
public class MessageBoxStrings
{
    public string ErrorTitle { get; set; } = "Error";
    public string WarningTitle { get; set; } = "Warning";
    public string InformationTitle { get; set; } = "Information";
    public string QuestionTitle { get; set; } = "Question";
    public string ConfirmationTitle { get; set; } = "Confirmation";
}
```

### ExceptionDialogStrings

Contains strings for the exception dialog system.

```csharp
public class ExceptionDialogStrings
{
    public string WindowTitle { get; set; } = "Exception Details";
    public string ExceptionDetailsHeader { get; set; } = "Exception Details";
    public string ExceptionOutlineHeader { get; set; } = "Exception Outline";
    public string Type { get; set; } = "Type";
    public string Message { get; set; } = "Message";
    public string StackTrace { get; set; } = "Stack Trace";
    public string InnerException { get; set; } = "Inner Exception";
    public string None { get; set; } = "None";
    public string SearchBoxCueText { get; set; } = "Search exception details...";
}
```

### CustomToolkitStrings

For application-specific strings.

```csharp
public class CustomToolkitStrings
{
    // Add your custom strings here
    public string CustomButtonText { get; set; } = "Custom Button";
    public string CustomMessage { get; set; } = "Custom Message";
}
```

## Localization Implementation

### Setting Up Localization

1. **Create Resource Files**: Create `.resx` files for each language you want to support.

2. **Configure Culture**: Set the application culture in your startup code.

```csharp
// Set specific culture
Thread.CurrentThread.CurrentCulture = new CultureInfo("fr-FR");
Thread.CurrentThread.CurrentUICulture = new CultureInfo("fr-FR");

// Or use system culture
Thread.CurrentThread.CurrentCulture = CultureInfo.CurrentCulture;
Thread.CurrentThread.CurrentUICulture = CultureInfo.CurrentUICulture;
```

3. **Load Localized Strings**: The system automatically loads strings based on the current culture.

### Example Localization Setup

```csharp
public partial class MainForm : KryptonForm
{
    public MainForm()
    {
        InitializeComponent();
        LoadLocalizedStrings();
    }
    
    private void LoadLocalizedStrings()
    {
        // Set form title
        Text = KryptonLanguageManager.Strings.GeneralStrings.ApplicationTitle;
        
        // Set button text
        okButton.Text = KryptonLanguageManager.Strings.GeneralStrings.OK;
        cancelButton.Text = KryptonLanguageManager.Strings.GeneralStrings.Cancel;
        
        // Set menu text
        fileMenu.Text = KryptonLanguageManager.Strings.GeneralStrings.File;
        editMenu.Text = KryptonLanguageManager.Strings.GeneralStrings.Edit;
    }
}
```

### Resource File Structure

**Strings.resx (Default/English):**
```xml
<?xml version="1.0" encoding="utf-8"?>
<root>
  <data name="OK" xml:space="preserve">
    <value>O&amp;K</value>
  </data>
  <data name="Cancel" xml:space="preserve">
    <value>Cance&amp;l</value>
  </data>
</root>
```

**Strings.fr-FR.resx (French):**
```xml
<?xml version="1.0" encoding="utf-8"?>
<root>
  <data name="OK" xml:space="preserve">
    <value>O&amp;K</value>
  </data>
  <data name="Cancel" xml:space="preserve">
    <value>Annule&amp;r</value>
  </data>
</root>
```

## Custom String Management

### Creating Custom String Collections

1. **Define Your String Class**:

```csharp
public class MyApplicationStrings : GlobalId
{
    private const string DEFAULT_SAVE = "&Save";
    private const string DEFAULT_LOAD = "&Load";
    private const string DEFAULT_EXIT = "E&xit";
    
    public string Save { get; set; } = DEFAULT_SAVE;
    public string Load { get; set; } = DEFAULT_LOAD;
    public string Exit { get; set; } = DEFAULT_EXIT;
    
    public bool IsDefault => Save.Equals(DEFAULT_SAVE) && 
                            Load.Equals(DEFAULT_LOAD) && 
                            Exit.Equals(DEFAULT_EXIT);
    
    public void Reset()
    {
        Save = DEFAULT_SAVE;
        Load = DEFAULT_LOAD;
        Exit = DEFAULT_EXIT;
    }
}
```

2. **Register with Language Manager**:

```csharp
public static class MyLanguageManager
{
    public static MyApplicationStrings ApplicationStrings { get; } = new MyApplicationStrings();
    
    public static void LoadCustomStrings()
    {
        // Load from resource files or configuration
        ApplicationStrings.Save = Properties.Resources.SaveButtonText;
        ApplicationStrings.Load = Properties.Resources.LoadButtonText;
        ApplicationStrings.Exit = Properties.Resources.ExitButtonText;
    }
}
```

3. **Use in Your Application**:

```csharp
public partial class MyForm : KryptonForm
{
    public MyForm()
    {
        InitializeComponent();
        LoadCustomStrings();
    }
    
    private void LoadCustomStrings()
    {
        saveButton.Text = MyLanguageManager.ApplicationStrings.Save;
        loadButton.Text = MyLanguageManager.ApplicationStrings.Load;
        exitButton.Text = MyLanguageManager.ApplicationStrings.Exit;
    }
}
```

### Dynamic String Loading

```csharp
public class DynamicStringManager
{
    private static readonly Dictionary<string, string> _strings = new();
    
    public static void LoadStringsFromFile(string filePath)
    {
        var json = File.ReadAllText(filePath);
        var stringData = JsonSerializer.Deserialize<Dictionary<string, string>>(json);
        
        if (stringData != null)
        {
            foreach (var kvp in stringData)
            {
                _strings[kvp.Key] = kvp.Value;
            }
        }
    }
    
    public static string GetString(string key, string defaultValue = "")
    {
        return _strings.TryGetValue(key, out var value) ? value : defaultValue;
    }
}
```

## Best Practices

### 1. Use Accelerator Keys

Always include accelerator keys (underlined letters) for accessibility:

```csharp
public string OK { get; set; } = "O&K";        // Alt+K
public string Cancel { get; set; } = "Cance&l"; // Alt+L
public string Save { get; set; } = "&Save";     // Alt+S
```

### 2. Consistent Naming

Use consistent naming conventions for string properties:

```csharp
// Good
public string SaveButtonText { get; set; }
public string LoadButtonText { get; set; }
public string ExitButtonText { get; set; }

// Avoid
public string Save { get; set; }
public string LoadFile { get; set; }
public string Quit { get; set; }
```

### 3. Default Values

Always provide meaningful default values:

```csharp
public class MyStrings : GlobalId
{
    private const string DEFAULT_SAVE = "&Save";
    private const string DEFAULT_CANCEL = "Cance&l";
    
    public string Save { get; set; } = DEFAULT_SAVE;
    public string Cancel { get; set; } = DEFAULT_CANCEL;
    
    public bool IsDefault => Save.Equals(DEFAULT_SAVE) && Cancel.Equals(DEFAULT_CANCEL);
}
```

### 4. Resource File Organization

Organize resource files by functionality:

```
Resources/
├── Strings.resx (Default)
├── Strings.fr-FR.resx (French)
├── Strings.de-DE.resx (German)
├── MessageBoxStrings.resx
├── MessageBoxStrings.fr-FR.resx
├── ExceptionStrings.resx
└── ExceptionStrings.fr-FR.resx
```

### 5. Error Handling

Always handle missing strings gracefully:

```csharp
public static string GetLocalizedString(string key, string defaultValue = "")
{
    try
    {
        return KryptonLanguageManager.Strings.GeneralStrings.GetType()
            .GetProperty(key)?.GetValue(KryptonLanguageManager.Strings.GeneralStrings) as string 
            ?? defaultValue;
    }
    catch
    {
        return defaultValue;
    }
}
```

## Migration from KryptonManager.Strings

### Step-by-Step Migration

1. **Identify Usage**: Find all instances of `KryptonManager.Strings` in your code.

```csharp
// Find these patterns
KryptonManager.Strings.GeneralStrings.OK
KryptonManager.Strings.MessageBoxStrings.ErrorTitle
```

2. **Replace with New System**:

```csharp
// Replace with
KryptonLanguageManager.Strings.GeneralStrings.OK
KryptonLanguageManager.Strings.MessageBoxStrings.ErrorTitle
```

3. **Update Designer Files**: If you have designer-generated code using the old system, update it manually or regenerate.

4. **Test Thoroughly**: Ensure all strings display correctly after migration.

### Migration Script Example

```csharp
public static class StringMigrationHelper
{
    public static void MigrateStrings()
    {
        // This is a conceptual example - actual implementation would depend on your specific needs
        var oldStrings = GetOldStringValues();
        var newStrings = KryptonLanguageManager.Strings.GeneralStrings;
        
        // Map old values to new properties
        if (oldStrings.ContainsKey("OK"))
            newStrings.OK = oldStrings["OK"];
            
        if (oldStrings.ContainsKey("Cancel"))
            newStrings.Cancel = oldStrings["Cancel"];
    }
    
    private static Dictionary<string, string> GetOldStringValues()
    {
        // Implementation to get old string values
        return new Dictionary<string, string>();
    }
}
```

### Common Migration Issues

1. **Missing Properties**: Some properties might not exist in the new system.
   - **Solution**: Check the new string collection classes for available properties.

2. **Different Property Names**: Property names might have changed.
   - **Solution**: Use Find & Replace with careful review.

3. **Designer Serialization**: Designer files might still reference old properties.
   - **Solution**: Update designer files manually or regenerate forms.

## Advanced Topics

### Custom Localization Providers

```csharp
public interface ILocalizationProvider
{
    string GetString(string key, string defaultValue = "");
    void LoadStrings(string cultureName);
    bool IsStringAvailable(string key);
}

public class DatabaseLocalizationProvider : ILocalizationProvider
{
    private readonly Dictionary<string, string> _strings = new();
    
    public string GetString(string key, string defaultValue = "")
    {
        return _strings.TryGetValue(key, out var value) ? value : defaultValue;
    }
    
    public void LoadStrings(string cultureName)
    {
        // Load strings from database
        var strings = Database.GetStrings(cultureName);
        foreach (var str in strings)
        {
            _strings[str.Key] = str.Value;
        }
    }
    
    public bool IsStringAvailable(string key)
    {
        return _strings.ContainsKey(key);
    }
}
```

### Runtime Language Switching

```csharp
public static class LanguageSwitcher
{
    public static event EventHandler? LanguageChanged;
    
    public static void SwitchLanguage(string cultureName)
    {
        var culture = new CultureInfo(cultureName);
        Thread.CurrentThread.CurrentCulture = culture;
        Thread.CurrentThread.CurrentUICulture = culture;
        
        // Reload strings
        KryptonLanguageManager.ReloadStrings();
        
        // Notify subscribers
        LanguageChanged?.Invoke(null, EventArgs.Empty);
    }
}

// Usage
public partial class MainForm : KryptonForm
{
    public MainForm()
    {
        InitializeComponent();
        LanguageSwitcher.LanguageChanged += OnLanguageChanged;
    }
    
    private void OnLanguageChanged(object? sender, EventArgs e)
    {
        // Reload all strings in the form
        LoadLocalizedStrings();
    }
}
```

This comprehensive guide covers all aspects of localization and string management in the Krypton Toolkit Suite, providing developers with the knowledge needed to implement robust, internationalized applications.
