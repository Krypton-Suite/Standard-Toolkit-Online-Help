# Krypton Toolkit Localization and String Management Guide

## Overview

The Krypton Toolkit provides a comprehensive localization system that allows all user-facing strings to be customized and translated into different languages. This system is built around the `KryptonManager.Strings` property, which provides centralized access to all localizable strings used throughout the toolkit.

**Key Features:**
- Centralized string management through `KryptonGlobalToolkitStrings`
- Over 30 string categories covering all toolkit components
- Full designer support with `[Localizable(true)]` attributes
- Runtime string customization
- Default values with reset capabilities
- Integration with .NET's localization infrastructure

## Architecture

### Core Components

```
KryptonManager
    ↓
KryptonManager.Strings (Static Property)
    ↓
KryptonGlobalToolkitStrings
    ↓
Individual String Categories (e.g., GeneralToolkitStrings, CustomToolkitStrings, etc.)
```

### Key Classes

1. **KryptonManager**: The main entry point providing access to global settings
2. **KryptonGlobalToolkitStrings**: The container for all string categories
3. **Individual String Classes**: Specialized classes for different component types

## String Categories

The toolkit organizes strings into the following categories:

### General Strings

#### GeneralToolkitStrings
Common strings used across multiple components:
- `OK` - OK button text (default: "O&K")
- `Cancel` - Cancel button text (default: "Cance&l")
- `Yes` - Yes button text (default: "&Yes")
- `No` - No button text (default: "N&o")
- `Abort` - Abort button text (default: "A&bort")
- `Retry` - Retry button text (default: "Ret&ry")
- `Ignore` - Ignore button text (default: "I&gnore")
- `Close` - Close button text (default: "Clo&se")
- `Today` - Today button text (default: "&Today")
- `Help` - Help button text (default: "H&elp")
- `Continue` - Continue button text (default: "Co&ntinue")
- `TryAgain` - Try Again button text (default: "Try Aga&in")

**Access:** `KryptonManager.Strings.GeneralStrings`

#### CustomToolkitStrings
Custom strings for specialized scenarios:
- `Apply` - Apply button text
- `Back` - Back button text
- `Collapse` - Collapse action text
- `Expand` - Expand action text
- `Exit` - Exit button text
- `Finish` - Finish button text
- `Next` - Next button text
- `Previous` - Previous button text
- `Cut` - Cut action text
- `Copy` - Copy action text
- `Paste` - Paste action text
- `SelectAll` - Select All action text
- `ClearClipboard` - Clear Clipboard action text
- `YesToAll` - Yes to All button text
- `NoToAll` - No to All button text
- `OkToAll` - OK to All button text
- `Reset` - Reset button text
- `SystemInformation` - System Information text
- `CurrentTheme` - Current Theme text
- `DoNotShowAgain` - Do not show again text

**Access:** `KryptonManager.Strings.CustomStrings`

#### SystemMenuStrings
Strings for Windows system menu items:
- Minimize, Maximize, Restore, Close, etc.

**Access:** `KryptonManager.Strings.SystemMenuStrings`

### Component-Specific Strings

#### GeneralRibbonStrings
Strings specific to Krypton Ribbon components.

**Access:** `KryptonManager.Strings.RibbonStrings`

#### IntegratedToolBarStrings
Strings for integrated toolbar components.

**Access:** `KryptonManager.Strings.ToolBarStrings`

#### KryptonAboutBoxStrings
Strings used in the KryptonAboutBox component.

**Access:** `KryptonManager.Strings.AboutBoxStrings`

#### KryptonToastNotificationStrings
Strings for toast notification components.

**Access:** `KryptonManager.Strings.ToastNotificationStrings`

#### KryptonScrollBarStrings
Strings for scroll bar components.

**Access:** `KryptonManager.Strings.ScrollBarStrings`

#### KryptonOutlookGridStrings
Strings specific to Outlook-style grid components.

**Access:** `KryptonManager.Strings.OutlookGridStrings`

### Style and Converter Strings

These categories provide localized names for various style enumerations used in the toolkit:

- **ButtonStyleStrings**: Button style names
- **PaletteButtonStyleStrings**: Palette button style names
- **PaletteBackStyleStrings**: Background style names
- **PaletteBorderStyleStrings**: Border style names
- **PaletteContentStyleStrings**: Content style names
- **HeaderStyleStrings**: Header style names
- **LabelStyleStrings**: Label style names
- **TabStyleStrings**: Tab style names
- **SeparatorStyleStrings**: Separator style names
- **GridStyleStrings**: Grid style names
- **DataGridViewStyleStrings**: DataGridView style names
- **InputControlStyleStrings**: Input control style names
- **PaletteModeStrings**: Palette mode names
- **PaletteTextTrimStrings**: Text trimming style names
- **PaletteImageStyleStrings**: Image style names
- **PaletteImageEffectStrings**: Image effect names
- **ToastNotificationIconStrings**: Toast notification icon names

### Color Strings

#### GlobalColorStrings
Localized names for colors used throughout the toolkit.

**Access:** `KryptonManager.Strings.ColorStrings`

## Using the Localization System

### Accessing Strings in Code

#### Basic Access Pattern

```csharp
// Access general strings
string okText = KryptonManager.Strings.GeneralStrings.OK;
string cancelText = KryptonManager.Strings.GeneralStrings.Cancel;

// Access custom strings
string applyText = KryptonManager.Strings.CustomStrings.Apply;
string copyText = KryptonManager.Strings.CustomStrings.Copy;

// Access component-specific strings
string ribbonText = KryptonManager.Strings.RibbonStrings.SomeProperty;
```

#### Using Static Properties

All string categories are accessible through static properties on `KryptonGlobalToolkitStrings`:

```csharp
// Direct static access
string ok = KryptonGlobalToolkitStrings.GeneralToolkitStrings.OK;
string cancel = KryptonGlobalToolkitStrings.GeneralToolkitStrings.Cancel;
```

### Customizing Strings at Runtime

#### Changing Individual Strings

```csharp
// Customize button text for a specific language
KryptonManager.Strings.GeneralStrings.OK = "Aceptar";
KryptonManager.Strings.GeneralStrings.Cancel = "Cancelar";
KryptonManager.Strings.GeneralStrings.Yes = "Sí";
KryptonManager.Strings.GeneralStrings.No = "No";
```

#### Changing Multiple Strings

```csharp
// Spanish localization example
public void ApplySpanishLocalization()
{
    var strings = KryptonManager.Strings;
    
    // General buttons
    strings.GeneralStrings.OK = "Aceptar";
    strings.GeneralStrings.Cancel = "Cancelar";
    strings.GeneralStrings.Yes = "Sí";
    strings.GeneralStrings.No = "No";
    strings.GeneralStrings.Close = "Cerrar";
    strings.GeneralStrings.Help = "Ayuda";
    
    // Custom actions
    strings.CustomStrings.Apply = "Aplicar";
    strings.CustomStrings.Copy = "Copiar";
    strings.CustomStrings.Paste = "Pegar";
    strings.CustomStrings.Cut = "Cortar";
    strings.CustomStrings.SelectAll = "Seleccionar todo";
    strings.CustomStrings.Reset = "Restablecer";
}
```

#### Resetting to Defaults

```csharp
// Reset all strings in a category to their default English values
KryptonManager.Strings.GeneralStrings.Reset();
KryptonManager.Strings.CustomStrings.ResetValues();

// Reset all toolkit strings
KryptonManager.Strings.Reset();
```

### Designer Support

The localization system integrates with Visual Studio's designer for form-based localization:

1. **Select a Form or UserControl** in the designer
2. **Set the `Localizable` property** to `true` in the Properties window
3. **Change the `Language` property** to your target language
4. **Add a KryptonManager** component to your form
5. **Expand the `ToolkitStrings` property** in the Properties window
6. **Expand individual string categories** and modify the strings
7. **The changes are stored** in language-specific resource files (e.g., `Form1.es-ES.resx`)

## Implementation Patterns

### Application Startup Localization

```csharp
using Krypton.Toolkit;
using System;
using System.Globalization;
using System.Windows.Forms;

namespace MyApplication
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            
            // Apply localization based on current culture
            ApplyLocalization(CultureInfo.CurrentUICulture);
            
            Application.Run(new MainForm());
        }
        
        static void ApplyLocalization(CultureInfo culture)
        {
            switch (culture.TwoLetterISOLanguageName)
            {
                case "es":
                    ApplySpanishStrings();
                    break;
                case "fr":
                    ApplyFrenchStrings();
                    break;
                case "de":
                    ApplyGermanStrings();
                    break;
                // Add more languages as needed
                default:
                    // English is the default
                    break;
            }
        }
        
        static void ApplySpanishStrings()
        {
            var strings = KryptonManager.Strings;
            strings.GeneralStrings.OK = "Aceptar";
            strings.GeneralStrings.Cancel = "Cancelar";
            strings.GeneralStrings.Yes = "Sí";
            strings.GeneralStrings.No = "No";
            strings.CustomStrings.Apply = "Aplicar";
            // Add more strings as needed
        }
        
        static void ApplyFrenchStrings()
        {
            var strings = KryptonManager.Strings;
            strings.GeneralStrings.OK = "OK";
            strings.GeneralStrings.Cancel = "Annuler";
            strings.GeneralStrings.Yes = "Oui";
            strings.GeneralStrings.No = "Non";
            strings.CustomStrings.Apply = "Appliquer";
            // Add more strings as needed
        }
        
        static void ApplyGermanStrings()
        {
            var strings = KryptonManager.Strings;
            strings.GeneralStrings.OK = "OK";
            strings.GeneralStrings.Cancel = "Abbrechen";
            strings.GeneralStrings.Yes = "Ja";
            strings.GeneralStrings.No = "Nein";
            strings.CustomStrings.Apply = "Anwenden";
            // Add more strings as needed
        }
    }
}
```

### Resource-Based Localization

For larger applications, consider using resource files:

```csharp
using System.Resources;
using System.Globalization;

public class LocalizationManager
{
    private ResourceManager _resourceManager;
    
    public LocalizationManager()
    {
        _resourceManager = new ResourceManager("MyApplication.Resources.Strings", 
                                              typeof(LocalizationManager).Assembly);
    }
    
    public void ApplyLocalization(CultureInfo culture)
    {
        var strings = KryptonManager.Strings;
        
        // Load strings from resources
        strings.GeneralStrings.OK = GetString("OK", culture);
        strings.GeneralStrings.Cancel = GetString("Cancel", culture);
        strings.GeneralStrings.Yes = GetString("Yes", culture);
        strings.GeneralStrings.No = GetString("No", culture);
        strings.CustomStrings.Apply = GetString("Apply", culture);
        strings.CustomStrings.Copy = GetString("Copy", culture);
        strings.CustomStrings.Paste = GetString("Paste", culture);
        // Load more strings as needed
    }
    
    private string GetString(string key, CultureInfo culture)
    {
        return _resourceManager.GetString(key, culture) ?? key;
    }
}

// Usage in Program.cs
static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    
    var localization = new LocalizationManager();
    localization.ApplyLocalization(CultureInfo.CurrentUICulture);
    
    Application.Run(new MainForm());
}
```

### Dynamic Language Switching

```csharp
public class LanguageSwitcher
{
    public event EventHandler LanguageChanged;
    
    public void SetLanguage(string languageCode)
    {
        switch (languageCode.ToLower())
        {
            case "en":
                KryptonManager.Strings.Reset(); // Reset to English defaults
                break;
            case "es":
                ApplySpanishLocalization();
                break;
            case "fr":
                ApplyFrenchLocalization();
                break;
            case "de":
                ApplyGermanLocalization();
                break;
        }
        
        // Notify subscribers that language has changed
        LanguageChanged?.Invoke(this, EventArgs.Empty);
    }
    
    private void ApplySpanishLocalization()
    {
        // Implementation as shown above
    }
    
    // Other language implementations...
}

// Usage in forms
public partial class MainForm : KryptonForm
{
    private LanguageSwitcher _languageSwitcher;
    
    public MainForm()
    {
        InitializeComponent();
        
        _languageSwitcher = new LanguageSwitcher();
        _languageSwitcher.LanguageChanged += OnLanguageChanged;
    }
    
    private void OnLanguageChanged(object sender, EventArgs e)
    {
        // Refresh UI to reflect new strings
        RefreshUI();
    }
    
    private void languageComboBox_SelectedIndexChanged(object sender, EventArgs e)
    {
        string selectedLanguage = languageComboBox.SelectedItem.ToString();
        _languageSwitcher.SetLanguage(selectedLanguage);
    }
}
```

## Best Practices

### 1. Initialize Early

Set localized strings during application startup, before any forms are displayed:

```csharp
static void Main()
{
    // Set localization FIRST
    ApplyLocalization(CultureInfo.CurrentUICulture);
    
    // Then initialize the application
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    Application.Run(new MainForm());
}
```

### 2. Preserve Accelerator Keys

When translating strings, preserve the `&` accelerator key indicators:

```csharp
// Good - maintains accelerator key
strings.GeneralStrings.OK = "&Aceptar"; // Alt+A

// Bad - loses accelerator key
strings.GeneralStrings.OK = "Aceptar"; // No keyboard shortcut
```

### 3. Use Consistent Terminology

Maintain consistency across your translations:

```csharp
// Create a translation dictionary or constants class
public static class SpanishStrings
{
    public const string OK = "Aceptar";
    public const string Cancel = "Cancelar";
    public const string Apply = "Aplicar";
    // etc.
}

// Use consistently throughout your application
strings.GeneralStrings.OK = SpanishStrings.OK;
strings.CustomStrings.Apply = SpanishStrings.Apply;
```

### 4. Test All Languages

Create automated tests to verify translations:

```csharp
[TestClass]
public class LocalizationTests
{
    [TestMethod]
    public void TestSpanishLocalization()
    {
        ApplySpanishStrings();
        
        Assert.AreEqual("Aceptar", KryptonManager.Strings.GeneralStrings.OK);
        Assert.AreEqual("Cancelar", KryptonManager.Strings.GeneralStrings.Cancel);
        // Test more strings...
        
        // Cleanup
        KryptonManager.Strings.Reset();
    }
}
```

### 5. Handle Missing Translations

Provide fallbacks for missing translations:

```csharp
public string GetLocalizedString(string key, CultureInfo culture)
{
    string translation = _resourceManager.GetString(key, culture);
    
    if (string.IsNullOrEmpty(translation))
    {
        // Fall back to English
        translation = _resourceManager.GetString(key, CultureInfo.InvariantCulture);
    }
    
    return translation ?? key; // Return key if still not found
}
```

### 6. Document Custom Strings

When using custom strings, document their purpose:

```csharp
// Custom string for specific business logic
// Used in: OrderProcessingDialog, ShippingConfirmationForm
strings.CustomStrings.Apply = "Process Order";
```

## Common Scenarios

### Scenario 1: Multi-Language Application

```csharp
public class MultiLanguageApp
{
    private Dictionary<string, Action> _languageAppliers;
    
    public MultiLanguageApp()
    {
        _languageAppliers = new Dictionary<string, Action>
        {
            { "en-US", () => KryptonManager.Strings.Reset() },
            { "es-ES", ApplySpanishStrings },
            { "fr-FR", ApplyFrenchStrings },
            { "de-DE", ApplyGermanStrings },
            { "ja-JP", ApplyJapaneseStrings }
        };
    }
    
    public void SetLanguage(string cultureName)
    {
        if (_languageAppliers.TryGetValue(cultureName, out Action applier))
        {
            applier();
            Thread.CurrentThread.CurrentUICulture = new CultureInfo(cultureName);
        }
    }
    
    // Language-specific methods...
}
```

### Scenario 2: User Preference Storage

```csharp
public class UserSettings
{
    public string PreferredLanguage { get; set; } = "en-US";
    
    public void Save()
    {
        Properties.Settings.Default.Language = PreferredLanguage;
        Properties.Settings.Default.Save();
    }
    
    public void Load()
    {
        PreferredLanguage = Properties.Settings.Default.Language;
    }
}

// In Program.cs
static void Main()
{
    var userSettings = new UserSettings();
    userSettings.Load();
    
    ApplyLocalization(new CultureInfo(userSettings.PreferredLanguage));
    
    Application.Run(new MainForm());
}
```

### Scenario 3: Right-to-Left (RTL) Language Support

```csharp
public void ApplyRTLLanguage(CultureInfo culture)
{
    // Apply string translations
    ApplyLocalization(culture);
    
    // Set RTL layout for the application
    if (culture.TextInfo.IsRightToLeft)
    {
        Application.CurrentCulture = culture;
        Form.DefaultRightToLeft = RightToLeft.Yes;
    }
}
```

## Troubleshooting

### Issue: Strings Not Updating in UI

**Cause:** Strings are cached when controls are created.

**Solution:** Recreate controls or refresh the UI after changing strings:

```csharp
private void ApplyNewLanguage()
{
    // Change strings
    KryptonManager.Strings.GeneralStrings.OK = "新しい値";
    
    // Refresh UI
    this.Controls.Clear();
    InitializeComponent(); // Recreate controls
    
    // Or manually update specific controls
    okButton.Text = KryptonManager.Strings.GeneralStrings.OK;
}
```

### Issue: Designer Changes Not Persisting

**Cause:** Form's `Localizable` property not set to `true`.

**Solution:** Enable localization in the form designer:
1. Select the form in the designer
2. Set `Localizable` property to `true`
3. Make changes to string properties

### Issue: Accelerator Keys Conflict

**Cause:** Multiple controls with the same accelerator key.

**Solution:** Choose different letters for accelerators in each language:

```csharp
// English
OK = "&OK"        // Alt+O
Cancel = "&Cancel" // Alt+C

// Spanish - avoid conflicts
OK = "&Aceptar"   // Alt+A (not Alt+O)
Cancel = "Ca&ncelar" // Alt+N (not Alt+C)
```

## Advanced Topics

### Custom String Categories

If you need additional string categories for your application:

```csharp
public class MyCustomStrings : GlobalId
{
    private const string DEFAULT_GREETING = "Hello";
    private const string DEFAULT_FAREWELL = "Goodbye";
    
    public string Greeting { get; set; } = DEFAULT_GREETING;
    public string Farewell { get; set; } = DEFAULT_FAREWELL;
    
    public bool IsDefault => Greeting.Equals(DEFAULT_GREETING) && 
                            Farewell.Equals(DEFAULT_FAREWELL);
    
    public void Reset()
    {
        Greeting = DEFAULT_GREETING;
        Farewell = DEFAULT_FAREWELL;
    }
}

// Usage
public static class MyAppStrings
{
    public static MyCustomStrings Custom { get; } = new MyCustomStrings();
}
```

### Integration with Third-Party Localization Tools

```csharp
// Export strings to JSON for translation
public class StringExporter
{
    public void ExportToJson(string filePath)
    {
        var strings = new
        {
            General = new
            {
                OK = KryptonManager.Strings.GeneralStrings.OK,
                Cancel = KryptonManager.Strings.GeneralStrings.Cancel,
                // Export more strings...
            },
            Custom = new
            {
                Apply = KryptonManager.Strings.CustomStrings.Apply,
                Copy = KryptonManager.Strings.CustomStrings.Copy,
                // Export more strings...
            }
        };
        
        string json = JsonSerializer.Serialize(strings, new JsonSerializerOptions 
        { 
            WriteIndented = true 
        });
        
        File.WriteAllText(filePath, json);
    }
}
```

## Related Components

### KryptonManager

The `KryptonManager` component provides additional global settings beyond strings:
- **GlobalPalette**: Theme and color scheme management
- **ApplyToolstrips**: Apply palette colors to toolstrips
- **Images**: Global image storage for the toolkit

### String Storage Classes

All string categories inherit from `GlobalId` and implement:
- **IsDefault Property**: Check if all strings are at default values
- **Reset Method**: Reset all strings to their default English values
- **ToString Method**: Returns "Modified" if any strings have been changed

## Summary

The Krypton Toolkit's localization system provides:

✅ Centralized string management through `KryptonManager.Strings`  
✅ Over 30 string categories for comprehensive coverage  
✅ Designer support for form-based localization  
✅ Runtime customization capabilities  
✅ Easy integration with .NET localization infrastructure  
✅ Reset capabilities to restore default values

By following this guide and the best practices outlined, you can create fully localized applications using the Krypton Toolkit that support multiple languages and cultures.

## See Also

- [ExceptionHandler API Documentation](ExceptionHandlerAPIDocumentation.md)
- [.NET Globalization Documentation](https://docs.microsoft.com/en-us/dotnet/standard/globalization-localization/)

