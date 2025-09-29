# KryptonManager Configuration Guide

## Table of Contents
1. [Overview](#overview)
2. [Getting Started](#getting-started)
3. [Core Properties](#core-properties)
4. [Theme Management](#theme-management)
5. [Global Settings](#global-settings)
6. [String Management](#string-management)
7. [Advanced Configuration](#advanced-configuration)
8. [Events and Notifications](#events-and-notifications)
9. [Best Practices](#best-practices)
10. [Troubleshooting](#troubleshooting)

## Overview

The `KryptonManager` is the central configuration hub for the entire Krypton Toolkit Suite. It provides global settings that affect all Krypton controls throughout your application, including theme management, string localization, and global behavior settings.

**Namespace:** `Krypton.Toolkit`  
**Type:** `public sealed class KryptonManager : Component`  
**Location:** `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonManager.cs`

### Key Features

- **Global Theme Management**: Control the appearance of all Krypton controls
- **String Localization**: Manage localized strings across the application
- **Global Settings**: Configure behavior that affects all controls
- **Designer Integration**: Full Visual Studio designer support
- **Event System**: Subscribe to global changes and updates
- **Performance Optimization**: Singleton pattern for efficient resource usage

## Getting Started

### Basic Setup

The simplest way to configure KryptonManager is through code in your application startup:

```csharp
// In Program.cs or Main form constructor
public static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    
    // Configure KryptonManager
    KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
    KryptonManager.GlobalApplyToolstrips = true;
    KryptonManager.GlobalUseThemeFormChromeBorderWidth = true;
    
    Application.Run(new MainForm());
}
```

### Designer Setup

You can also configure KryptonManager through the Visual Studio designer:

1. **Add KryptonManager to Form**: Drag `KryptonManager` from the toolbox to your form
2. **Configure Properties**: Use the Properties window to set global settings
3. **Apply to Controls**: All Krypton controls will automatically inherit the settings

```csharp
// Designer-generated code
private void InitializeComponent()
{
    this.kryptonManager = new KryptonManager();
    this.kryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
    this.kryptonManager.GlobalApplyToolstrips = true;
    // ... other settings
}
```

## Core Properties

### GlobalPaletteMode

The most important property that controls the overall theme of your application.

```csharp
/// <summary>
/// Gets or sets the global palette used for drawing.
/// </summary>
[Category(@"GlobalPalette")]
[Description(@"Easy Set for the theme palette")]
[DefaultValue(PaletteMode.Microsoft365Blue)]
public PaletteMode GlobalPaletteMode
{
    get => CurrentGlobalPaletteMode;
    set
    {
        if (value != CurrentGlobalPaletteMode)
        {
            if (value != PaletteMode.Custom)
            {
                SetPalette(GetPaletteForMode(value));
            }
            CurrentGlobalPaletteMode = value;
            
            if (_baseFont != null)
            {
                CurrentGlobalPalette.BaseFont = _baseFont;
            }
            
            if (value != PaletteMode.Custom)
            {
                OnGlobalPaletteChanged(EventArgs.Empty);
            }
        }
    }
}
```

**Available Themes:**
```csharp
// Office Themes
PaletteMode.Office2007Blue
PaletteMode.Office2007Silver
PaletteMode.Office2007White
PaletteMode.Office2007Black
PaletteMode.Office2010Blue
PaletteMode.Office2010Silver
PaletteMode.Office2010White
PaletteMode.Office2010Black
PaletteMode.Office2013DarkGray
PaletteMode.Office2013LightGray
PaletteMode.Office2013White

// Microsoft 365 Themes
PaletteMode.Microsoft365Blue
PaletteMode.Microsoft365DarkGray
PaletteMode.Microsoft365Black

// Sparkle Themes
PaletteMode.SparkleBlue
PaletteMode.SparkleOrange
PaletteMode.SparklePurple

// Professional Themes
PaletteMode.ProfessionalOffice2003
PaletteMode.ProfessionalSystem

// Visual Studio Themes
PaletteMode.VisualStudio2010Blue

// Custom Theme
PaletteMode.Custom
```

**Usage Examples:**
```csharp
// Set Microsoft 365 Blue theme
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;

// Set Office 2010 Blue theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// Set custom theme
KryptonManager.GlobalPaletteMode = PaletteMode.Custom;
KryptonManager.GlobalCustomPalette = myCustomPalette;
```

### GlobalCustomPalette

When using `PaletteMode.Custom`, this property allows you to specify a custom palette.

```csharp
/// <summary>
/// Gets and sets the global custom applied to drawing.
/// </summary>
[Category(@"GlobalPalette")]
[Description(@"Global custom palette applied to drawing.")]
[DefaultValue(null)]
public KryptonCustomPaletteBase? GlobalCustomPalette
{
    get => CurrentGlobalPalette as KryptonCustomPaletteBase;
    set
    {
        if (value != CurrentGlobalPalette)
        {
            SetPalette(value);
            CurrentGlobalPaletteMode = PaletteMode.Custom;
            
            if (_baseFont != null)
            {
                CurrentGlobalPalette.BaseFont = _baseFont;
            }
            
            OnGlobalPaletteChanged(EventArgs.Empty);
        }
    }
}
```

**Usage:**
```csharp
// Create and apply custom palette
var customPalette = new KryptonCustomPaletteBase();
customPalette.ButtonStyles.ButtonCommon.StateCommon.Back.Color1 = Color.Red;
customPalette.ButtonStyles.ButtonCommon.StateCommon.Back.Color2 = Color.DarkRed;

KryptonManager.GlobalPaletteMode = PaletteMode.Custom;
KryptonManager.GlobalCustomPalette = customPalette;
```

## Theme Management

### Theme Switching

KryptonManager provides several ways to switch themes dynamically:

```csharp
public static class ThemeManager
{
    public static void SwitchToOffice2010()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
    }
    
    public static void SwitchToMicrosoft365()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
    }
    
    public static void SwitchToDarkMode()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Black;
    }
    
    public static void ApplyCustomTheme(KryptonCustomPaletteBase customPalette)
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Custom;
        KryptonManager.GlobalCustomPalette = customPalette;
    }
}
```

### Theme Persistence

Save and restore theme preferences:

```csharp
public static class ThemePersistence
{
    private const string ThemeKey = "GlobalPaletteMode";
    
    public static void SaveTheme()
    {
        var themeMode = KryptonManager.GlobalPaletteMode;
        Properties.Settings.Default.GlobalPaletteMode = themeMode.ToString();
        Properties.Settings.Default.Save();
    }
    
    public static void LoadTheme()
    {
        var themeString = Properties.Settings.Default.GlobalPaletteMode;
        if (Enum.TryParse<PaletteMode>(themeString, out var themeMode))
        {
            KryptonManager.GlobalPaletteMode = themeMode;
        }
    }
}
```

### Theme-Based Configuration

Configure different settings based on the current theme:

```csharp
public static class ThemeConfiguration
{
    public static void ApplyThemeSettings()
    {
        var currentTheme = KryptonManager.GlobalPaletteMode;
        
        switch (currentTheme)
        {
            case PaletteMode.Microsoft365Blue:
                ApplyMicrosoft365Settings();
                break;
            case PaletteMode.Office2010Blue:
                ApplyOffice2010Settings();
                break;
            case PaletteMode.Office2013DarkGray:
                ApplyOffice2013Settings();
                break;
            default:
                ApplyDefaultSettings();
                break;
        }
    }
    
    private static void ApplyMicrosoft365Settings()
    {
        // Microsoft 365 specific settings
        KryptonManager.GlobalUseThemeFormChromeBorderWidth = true;
        KryptonManager.GlobalApplyToolstrips = true;
    }
    
    private static void ApplyOffice2010Settings()
    {
        // Office 2010 specific settings
        KryptonManager.GlobalUseThemeFormChromeBorderWidth = false;
        KryptonManager.GlobalApplyToolstrips = true;
    }
}
```

## Global Settings

### GlobalApplyToolstrips

Controls whether Krypton styling is applied to standard Windows Forms ToolStrip controls.

```csharp
/// <summary>
/// Gets and sets the global apply toolstrips setting.
/// </summary>
[Category(@"Global")]
[Description(@"Global apply toolstrips setting.")]
[DefaultValue(true)]
public bool GlobalApplyToolstrips
{
    get => _globalApplyToolstrips;
    set
    {
        if (value != _globalApplyToolstrips)
        {
            _globalApplyToolstrips = value;
            UpdateToolStripManager();
            OnGlobalApplyToolstripsChanged(EventArgs.Empty);
        }
    }
}
```

**Usage:**
```csharp
// Apply Krypton styling to ToolStrips
KryptonManager.GlobalApplyToolstrips = true;

// Use standard Windows ToolStrip styling
KryptonManager.GlobalApplyToolstrips = false;
```

### GlobalUseThemeFormChromeBorderWidth

Controls whether forms use themed border widths.

```csharp
/// <summary>
/// Gets and sets the global use theme form chrome border width setting.
/// </summary>
[Category(@"Global")]
[Description(@"Global use theme form chrome border width setting.")]
[DefaultValue(true)]
public bool GlobalUseThemeFormChromeBorderWidth
{
    get => _globalUseThemeFormChromeBorderWidth;
    set
    {
        if (value != _globalUseThemeFormChromeBorderWidth)
        {
            _globalUseThemeFormChromeBorderWidth = value;
            OnGlobalUseThemeFormChromeBorderWidthChanged(EventArgs.Empty);
        }
    }
}
```

### ShowAdministratorSuffix

Controls whether administrator suffix is shown in form titles.

```csharp
/// <summary>
/// Gets and sets the show administrator suffix setting.
/// </summary>
[Category(@"Global")]
[Description(@"Show administrator suffix setting.")]
[DefaultValue(true)]
public bool ShowAdministratorSuffix
{
    get => _globalShowAdministratorSuffix;
    set
    {
        if (value != _globalShowAdministratorSuffix)
        {
            _globalShowAdministratorSuffix = value;
            OnShowAdministratorSuffixChanged(EventArgs.Empty);
        }
    }
}
```

### UseKryptonFileDialogs

Controls whether Krypton-styled file dialogs are used.

```csharp
/// <summary>
/// Gets and sets the use Krypton file dialogs setting.
/// </summary>
[Category(@"Global")]
[Description(@"Use Krypton file dialogs setting.")]
[DefaultValue(true)]
public bool UseKryptonFileDialogs
{
    get => _globalUseKryptonFileDialogs;
    set
    {
        if (value != _globalUseKryptonFileDialogs)
        {
            _globalUseKryptonFileDialogs = value;
            OnUseKryptonFileDialogsChanged(EventArgs.Empty);
        }
    }
}
```

## String Management

### ToolkitStrings

The `ToolkitStrings` property provides access to all localized strings in the application.

```csharp
/// <summary>
/// Gets the toolkit strings.
/// </summary>
[Category(@"Visuals")]
[Description(@"Collection of toolkit strings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
[Localizable(true)]
public ToolkitStringValues ToolkitStrings => _toolkitStrings;
```

**Usage:**
```csharp
// Access general strings
var okText = KryptonManager.ToolkitStrings.GeneralStrings.OK;
var cancelText = KryptonManager.ToolkitStrings.GeneralStrings.Cancel;

// Access message box strings
var errorTitle = KryptonManager.ToolkitStrings.MessageBoxStrings.ErrorTitle;

// Access custom strings
var customText = KryptonManager.ToolkitStrings.CustomToolkitStrings.CustomButtonText;
```

### String Customization

Customize strings for your application:

```csharp
public static class StringCustomizer
{
    public static void CustomizeStrings()
    {
        // Customize general strings
        KryptonManager.ToolkitStrings.GeneralStrings.OK = "&Accept";
        KryptonManager.ToolkitStrings.GeneralStrings.Cancel = "&Decline";
        
        // Customize message box strings
        KryptonManager.ToolkitStrings.MessageBoxStrings.ErrorTitle = "Application Error";
        KryptonManager.ToolkitStrings.MessageBoxStrings.WarningTitle = "Warning";
        
        // Customize custom strings
        KryptonManager.ToolkitStrings.CustomToolkitStrings.CustomButtonText = "My Custom Button";
    }
    
    public static void ResetToStrings()
    {
        // Reset all strings to default values
        KryptonManager.ToolkitStrings.GeneralStrings.Reset();
        KryptonManager.ToolkitStrings.MessageBoxStrings.Reset();
        KryptonManager.ToolkitStrings.CustomToolkitStrings.Reset();
    }
}
```

## Advanced Configuration

### BaseFont Management

Control the base font used throughout the application:

```csharp
/// <summary>
/// Gets and sets the base font.
/// </summary>
[Category(@"Visuals")]
[Description(@"Base font for the application.")]
[DefaultValue(null)]
public Font? BaseFont
{
    get => _baseFont;
    set
    {
        if (value != _baseFont)
        {
            _baseFont = value;
            if (CurrentGlobalPalette != null)
            {
                CurrentGlobalPalette.BaseFont = _baseFont;
            }
            OnBaseFontChanged(EventArgs.Empty);
        }
    }
}
```

**Usage:**
```csharp
// Set custom base font
KryptonManager.BaseFont = new Font("Segoe UI", 10f, FontStyle.Regular);

// Reset to default
KryptonManager.BaseFont = null;
```

### ToolkitColors

Configure custom colors for the toolkit:

```csharp
/// <summary>
/// Gets the toolkit colors.
/// </summary>
[Category(@"Visuals")]
[Description(@"Collection of toolkit colors.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public ToolkitColorValues ToolkitColors => _toolkitColors;
```

**Usage:**
```csharp
// Customize colors
KryptonManager.ToolkitColors.PrimaryColors.PrimaryColor1 = Color.Red;
KryptonManager.ToolkitColors.PrimaryColors.PrimaryColor2 = Color.DarkRed;

// Apply color scheme
KryptonManager.ToolkitColors.ApplyColorScheme(ColorScheme.Red);
```

### Complete Configuration Example

```csharp
public static class CompleteConfiguration
{
    public static void ConfigureApplication()
    {
        // Set theme
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        
        // Configure global settings
        KryptonManager.GlobalApplyToolstrips = true;
        KryptonManager.GlobalUseThemeFormChromeBorderWidth = true;
        KryptonManager.ShowAdministratorSuffix = true;
        KryptonManager.UseKryptonFileDialogs = true;
        
        // Set base font
        KryptonManager.BaseFont = new Font("Segoe UI", 9f, FontStyle.Regular);
        
        // Customize strings
        CustomizeStrings();
        
        // Configure colors
        ConfigureColors();
        
        // Subscribe to events
        SubscribeToEvents();
    }
    
    private static void CustomizeStrings()
    {
        KryptonManager.ToolkitStrings.GeneralStrings.OK = "&Accept";
        KryptonManager.ToolkitStrings.GeneralStrings.Cancel = "&Decline";
        KryptonManager.ToolkitStrings.MessageBoxStrings.ErrorTitle = "Application Error";
    }
    
    private static void ConfigureColors()
    {
        KryptonManager.ToolkitColors.PrimaryColors.PrimaryColor1 = Color.FromArgb(0, 120, 212);
        KryptonManager.ToolkitColors.PrimaryColors.PrimaryColor2 = Color.FromArgb(0, 90, 158);
    }
    
    private static void SubscribeToEvents()
    {
        KryptonManager.GlobalPaletteChanged += OnGlobalPaletteChanged;
        KryptonManager.GlobalApplyToolstripsChanged += OnGlobalApplyToolstripsChanged;
    }
    
    private static void OnGlobalPaletteChanged(object? sender, EventArgs e)
    {
        // Handle theme change
        Console.WriteLine("Theme changed to: " + KryptonManager.GlobalPaletteMode);
    }
    
    private static void OnGlobalApplyToolstripsChanged(object? sender, EventArgs e)
    {
        // Handle toolstrip setting change
        Console.WriteLine("ToolStrip setting changed: " + KryptonManager.GlobalApplyToolstrips);
    }
}
```

## Events and Notifications

### Available Events

KryptonManager provides several events to monitor configuration changes:

```csharp
// Theme and palette events
public static event EventHandler? GlobalPaletteChanged;
public static event EventHandler? GlobalCustomPaletteChanged;

// Global setting events
public static event EventHandler? GlobalApplyToolstripsChanged;
public static event EventHandler? GlobalUseThemeFormChromeBorderWidthChanged;
public static event EventHandler? ShowAdministratorSuffixChanged;
public static event EventHandler? UseKryptonFileDialogsChanged;

// Visual events
public static event EventHandler? BaseFontChanged;
public static event EventHandler? ToolkitColorsChanged;
public static event EventHandler? ToolkitStringsChanged;
```

### Event Handling Examples

```csharp
public partial class MainForm : KryptonForm
{
    public MainForm()
    {
        InitializeComponent();
        SubscribeToKryptonEvents();
    }
    
    private void SubscribeToKryptonEvents()
    {
        // Subscribe to theme changes
        KryptonManager.GlobalPaletteChanged += OnThemeChanged;
        
        // Subscribe to setting changes
        KryptonManager.GlobalApplyToolstripsChanged += OnToolStripSettingChanged;
        KryptonManager.GlobalUseThemeFormChromeBorderWidthChanged += OnBorderWidthSettingChanged;
        
        // Subscribe to font changes
        KryptonManager.BaseFontChanged += OnFontChanged;
    }
    
    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // Update UI elements that depend on theme
        UpdateThemeDependentControls();
        
        // Log theme change
        LogThemeChange(KryptonManager.GlobalPaletteMode);
    }
    
    private void OnToolStripSettingChanged(object? sender, EventArgs e)
    {
        // Refresh toolstrips when setting changes
        RefreshToolStrips();
    }
    
    private void OnBorderWidthSettingChanged(object? sender, EventArgs e)
    {
        // Update form borders
        UpdateFormBorders();
    }
    
    private void OnFontChanged(object? sender, EventArgs e)
    {
        // Update font-dependent controls
        UpdateFontDependentControls();
    }
    
    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            // Unsubscribe from events
            KryptonManager.GlobalPaletteChanged -= OnThemeChanged;
            KryptonManager.GlobalApplyToolstripsChanged -= OnToolStripSettingChanged;
            KryptonManager.GlobalUseThemeFormChromeBorderWidthChanged -= OnBorderWidthSettingChanged;
            KryptonManager.BaseFontChanged -= OnFontChanged;
        }
        base.Dispose(disposing);
    }
}
```

## Best Practices

### 1. Initialize Early

Always initialize KryptonManager before creating any Krypton controls:

```csharp
// Good - Initialize before creating forms
public static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    
    // Initialize KryptonManager first
    KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
    
    Application.Run(new MainForm());
}

// Avoid - Initialize after creating forms
public static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    
    var form = new MainForm(); // Controls created with default settings
    KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue; // Too late
    Application.Run(form);
}
```

### 2. Use Consistent Themes

Choose a theme and stick with it throughout your application:

```csharp
// Good - Consistent theme
public static class ApplicationTheme
{
    public static void Apply()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        // All controls will use the same theme
    }
}

// Avoid - Mixed themes
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
// Some controls might override with different themes
```

### 3. Handle Theme Changes Gracefully

Always handle theme changes to maintain UI consistency:

```csharp
public static class ThemeChangeHandler
{
    public static void HandleThemeChange()
    {
        KryptonManager.GlobalPaletteChanged += (sender, e) =>
        {
            // Update all forms
            foreach (Form form in Application.OpenForms)
            {
                if (form is KryptonForm kryptonForm)
                {
                    kryptonForm.Refresh();
                }
            }
            
            // Update custom controls
            UpdateCustomControls();
        };
    }
    
    private static void UpdateCustomControls()
    {
        // Update any custom controls that depend on theme
    }
}
```

### 4. Save Configuration

Save user preferences for theme and settings:

```csharp
public static class ConfigurationManager
{
    public static void SaveConfiguration()
    {
        var settings = Properties.Settings.Default;
        settings.GlobalPaletteMode = KryptonManager.GlobalPaletteMode.ToString();
        settings.GlobalApplyToolstrips = KryptonManager.GlobalApplyToolstrips;
        settings.GlobalUseThemeFormChromeBorderWidth = KryptonManager.GlobalUseThemeFormChromeBorderWidth;
        settings.Save();
    }
    
    public static void LoadConfiguration()
    {
        var settings = Properties.Settings.Default;
        
        if (Enum.TryParse<PaletteMode>(settings.GlobalPaletteMode, out var paletteMode))
        {
            KryptonManager.GlobalPaletteMode = paletteMode;
        }
        
        KryptonManager.GlobalApplyToolstrips = settings.GlobalApplyToolstrips;
        KryptonManager.GlobalUseThemeFormChromeBorderWidth = settings.GlobalUseThemeFormChromeBorderWidth;
    }
}
```

### 5. Use Designer When Appropriate

For simple applications, use the designer for configuration:

```csharp
// Designer approach - Good for simple apps
private void InitializeComponent()
{
    this.kryptonManager = new KryptonManager();
    this.kryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
    this.kryptonManager.GlobalApplyToolstrips = true;
    // ... other settings
}
```

### 6. Programmatic Configuration for Complex Apps

For complex applications with dynamic requirements, use programmatic configuration:

```csharp
// Programmatic approach - Good for complex apps
public static class DynamicConfiguration
{
    public static void ConfigureBasedOnEnvironment()
    {
        var environment = Environment.GetEnvironmentVariable("APP_ENVIRONMENT");
        
        switch (environment)
        {
            case "Development":
                ConfigureDevelopmentSettings();
                break;
            case "Production":
                ConfigureProductionSettings();
                break;
            default:
                ConfigureDefaultSettings();
                break;
        }
    }
    
    private static void ConfigureDevelopmentSettings()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        KryptonManager.GlobalApplyToolstrips = true;
    }
    
    private static void ConfigureProductionSettings()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
        KryptonManager.GlobalApplyToolstrips = false;
    }
}
```

## Troubleshooting

### Common Issues

#### 1. Controls Not Following Theme

**Problem**: Controls appear with default Windows styling instead of Krypton theme.

**Solution**: Ensure KryptonManager is initialized before creating controls:

```csharp
// Fix: Initialize before creating forms
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
var form = new MainForm();
```

#### 2. Theme Changes Not Applied

**Problem**: Changing `GlobalPaletteMode` doesn't update existing controls.

**Solution**: Refresh controls after theme changes:

```csharp
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
foreach (Form form in Application.OpenForms)
{
    form.Refresh();
}
```

#### 3. Custom Palette Not Working

**Problem**: Custom palette doesn't apply correctly.

**Solution**: Ensure proper sequence:

```csharp
// Correct sequence
KryptonManager.GlobalPaletteMode = PaletteMode.Custom;
KryptonManager.GlobalCustomPalette = myCustomPalette;
```

#### 4. String Customization Not Persisting

**Problem**: Custom strings revert to defaults.

**Solution**: Ensure strings are set after KryptonManager initialization:

```csharp
// Correct order
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
KryptonManager.ToolkitStrings.GeneralStrings.OK = "Custom OK";
```

### Debugging Tips

#### 1. Check Current Settings

```csharp
public static void DebugCurrentSettings()
{
    Console.WriteLine($"Current Theme: {KryptonManager.GlobalPaletteMode}");
    Console.WriteLine($"Apply ToolStrips: {KryptonManager.GlobalApplyToolstrips}");
    Console.WriteLine($"Use Theme Border Width: {KryptonManager.GlobalUseThemeFormChromeBorderWidth}");
    Console.WriteLine($"Base Font: {KryptonManager.BaseFont?.Name}");
}
```

#### 2. Monitor Events

```csharp
public static void MonitorKryptonEvents()
{
    KryptonManager.GlobalPaletteChanged += (s, e) => 
        Console.WriteLine($"Theme changed to: {KryptonManager.GlobalPaletteMode}");
    
    KryptonManager.GlobalApplyToolstripsChanged += (s, e) => 
        Console.WriteLine($"ToolStrip setting: {KryptonManager.GlobalApplyToolstrips}");
}
```

#### 3. Validate Configuration

```csharp
public static bool ValidateConfiguration()
{
    try
    {
        // Test theme setting
        var originalTheme = KryptonManager.GlobalPaletteMode;
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        KryptonManager.GlobalPaletteMode = originalTheme;
        
        // Test string access
        var okText = KryptonManager.ToolkitStrings.GeneralStrings.OK;
        
        return true;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Configuration validation failed: {ex.Message}");
        return false;
    }
}
```

This comprehensive guide provides developers with complete information about configuring and using the KryptonManager to create consistent, professional-looking applications with the Krypton Toolkit Suite.
