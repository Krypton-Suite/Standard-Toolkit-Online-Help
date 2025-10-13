# GlobalStaticValues Reference

## Table of Contents
1. [Overview](#overview)
2. [Core Constants](#core-constants)
3. [Exception Handling Constants](#exception-handling-constants)
4. [UI and Theme Constants](#ui-and-theme-constants)
5. [File and Path Constants](#file-and-path-constants)
6. [Color Constants](#color-constants)
7. [Image Arrays](#image-arrays)
8. [Utility Methods](#utility-methods)
9. [Usage Examples](#usage-examples)
10. [Best Practices](#best-practices)

## Overview

The `GlobalStaticValues` class provides a centralized collection of static values, constants, and utility methods used throughout the Krypton Toolkit Suite. This class serves as a single source of truth for default values, configuration constants, and shared resources.

**Namespace:** `Krypton.Toolkit`  
**Access Level:** `public` (with some `internal` members)  
**Location:** `Source/Krypton Components/Krypton.Toolkit/General/GlobalStaticValues.cs`

### Key Features

- **Centralized Configuration**: All default values in one location
- **Type Safety**: Strongly-typed constants prevent runtime errors
- **Performance**: Static values provide optimal performance
- **Maintainability**: Easy to update values across the entire toolkit
- **Extensibility**: Easy to add new constants as needed

## Core Constants

### Exception Handling Constants

```csharp
// Exception handling behavior
internal const bool DEFAULT_USE_STACK_TRACE = true;
internal const bool DEFAULT_USE_EXCEPTION_MESSAGE = true;
internal const bool DEFAULT_USE_INNER_EXCEPTION = true;
```

**Usage:**
```csharp
// In exception handling code
if (GlobalStaticValues.DEFAULT_USE_STACK_TRACE)
{
    // Include stack trace in exception details
    messageBuilder.Append($"Stacktrace:\r\n{exception.StackTrace}\r\n");
}
```

### Animation and Timing Constants

```csharp
// Toggle switch animation speed (milliseconds)
internal const int DEFAULT_TOGGLE_SWITCH_ANIMATION_SPEED = 10;

// Countdown timer settings
internal const int DEFAULT_COUNTDOWN_INTERVAL = 1000;  // 1 second
internal const int DEFAULT_COUNTDOWN_VALUE = 60;       // 60 seconds
```

**Usage:**
```csharp
// For toggle switch animations
timer.Interval = GlobalStaticValues.DEFAULT_TOGGLE_SWITCH_ANIMATION_SPEED;

// For countdown timers
countdownTimer.Interval = GlobalStaticValues.DEFAULT_COUNTDOWN_INTERVAL;
countdownValue = GlobalStaticValues.DEFAULT_COUNTDOWN_VALUE;
```

### Padding and Spacing Constants

```csharp
// Global button padding
public const int GLOBAL_BUTTON_PADDING = 10;

// Default padding for various controls
internal const int DEFAULT_PADDING = 10;
```

**Usage:**
```csharp
// Apply consistent padding
button.Padding = new Padding(GlobalStaticValues.GLOBAL_BUTTON_PADDING);
panel.Padding = new Padding(GlobalStaticValues.DEFAULT_PADDING);
```

## UI and Theme Constants

### Theme Configuration

```csharp
// Default theme settings
public const int GLOBAL_DEFAULT_THEME_INDEX = (int)PaletteMode.Microsoft365Blue;
public const PaletteMode GLOBAL_DEFAULT_PALETTE_MODE = PaletteMode.Microsoft365Blue;

// Current supported palette version
public const int CURRENT_SUPPORTED_PALETTE_VERSION = 20;
```

**Usage:**
```csharp
// Set default theme
KryptonManager.GlobalPaletteMode = GlobalStaticValues.GLOBAL_DEFAULT_PALETTE_MODE;

// Check palette version compatibility
if (paletteVersion < GlobalStaticValues.CURRENT_SUPPORTED_PALETTE_VERSION)
{
    // Handle older palette version
}
```

### Corner Rounding Constants

```csharp
// Material theme corner rounding
public const float DEFAULT_MATERIAL_THEME_CORNER_ROUNDING_VALUE = -1f;

// Default control corner rounding
public const float DEFAULT_PRIMARY_CORNER_ROUNDING_VALUE = -1f;

// Ribbon tab background gradient
public const float DEFAULT_RAFTING_RIBBON_TAB_BACKGROUND_GRADIENT = 90F;
```

**Usage:**
```csharp
// Apply corner rounding
button.CornerRoundingRadius = GlobalStaticValues.DEFAULT_PRIMARY_CORNER_ROUNDING_VALUE;

// Set gradient angle
ribbonTab.BackgroundGradientAngle = GlobalStaticValues.DEFAULT_RAFTING_RIBBON_TAB_BACKGROUND_GRADIENT;
```

### UAC Shield Configuration

```csharp
// UAC shield icon settings
public static UACShieldIconSize DEFAULT_UAC_SHIELD_ICON_SIZE = UACShieldIconSize.ExtraSmall;
public static Size DEFAULT_UAC_SHIELD_ICON_CUSTOM_SIZE = new Size(16, 16);
```

**Usage:**
```csharp
// Configure UAC shield
uacButton.ShieldIconSize = GlobalStaticValues.DEFAULT_UAC_SHIELD_ICON_SIZE;
uacButton.ShieldIconCustomSize = GlobalStaticValues.DEFAULT_UAC_SHIELD_ICON_CUSTOM_SIZE;
```

## File and Path Constants

### DLL File Names

```csharp
// Version reporting file names
internal static string DEFAULT_DOCKING_FILE = @"Krypton.Docking.dll";
internal static string DEFAULT_NAVIGATOR_FILE = @"Krypton.Navigator.dll";
internal static string DEFAULT_RIBBON_FILE = @"Krypton.Ribbon.dll";
internal static string DEFAULT_TOOLKIT_FILE = @"Krypton.Toolkit.dll";
internal static string DEFAULT_WORKSPACE_FILE = @"Krypton.Workspace.dll";
```

**Usage:**
```csharp
// Get version information
var toolkitVersion = FileVersionInfo.GetVersionInfo(GlobalStaticValues.DEFAULT_TOOLKIT_FILE);
var ribbonVersion = FileVersionInfo.GetVersionInfo(GlobalStaticValues.DEFAULT_RIBBON_FILE);
```

### URL Constants

```csharp
// Emoji list URLs
public const string DEFAULT_LATEST_EMOJI_LIST_URL = @"https://unicode.org/Public/emoji/latest/emoji-test.txt";
public const string DEFAULT_PUBLIC_EMOJI_LIST_URL = @"https://unicode.org/Public/draft/emoji/emoji-test.txt";
```

**Usage:**
```csharp
// Load emoji data
var emojiUrl = GlobalStaticValues.DEFAULT_LATEST_EMOJI_LIST_URL;
var emojiData = await httpClient.GetStringAsync(emojiUrl);
```

### Message Constants

```csharp
// Common messages
internal const string DEFAULT_NOT_IMPLEMENTED_YET_MESSAGE = 
    "This feature has not been currently implemented yet.\nPlease check back again soon!";
internal static string DEFAULT_EMPTY_STRING = string.Empty;
```

**Usage:**
```csharp
// Show not implemented message
MessageBox.Show(GlobalStaticValues.DEFAULT_NOT_IMPLEMENTED_YET_MESSAGE);

// Use empty string constant
var emptyValue = GlobalStaticValues.DEFAULT_EMPTY_STRING;
```

## Color Constants

### System Colors

```csharp
// Common color values
public static readonly Color EMPTY_COLOR = Color.Empty;
public static readonly Color TRANSPARENCY_KEY_COLOR = Color.Magenta;
public static readonly Color TAB_ROW_GRADIENT_FIRST_COLOR = Color.Transparent;
public static readonly Color DEFAULT_HIGHLIGHT_DEBUGGING_COLOR = Color.Red;
```

### Ribbon Colors

```csharp
// Ribbon application button colors
public static readonly Color DEFAULT_RIBBON_FILE_APP_TAB_BOTTOM_COLOR = Color.FromArgb(31, 72, 161);
public static readonly Color DEFAULT_RIBBON_FILE_APP_TAB_TOP_COLOR = Color.FromArgb(84, 158, 243);
public static readonly Color DEFAULT_RIBBON_FILE_APP_TAB_TEXT_COLOR = Color.White;
```

**Usage:**
```csharp
// Apply ribbon colors
ribbonAppButton.BottomColor = GlobalStaticValues.DEFAULT_RIBBON_FILE_APP_TAB_BOTTOM_COLOR;
ribbonAppButton.TopColor = GlobalStaticValues.DEFAULT_RIBBON_FILE_APP_TAB_TOP_COLOR;
ribbonAppButton.TextColor = GlobalStaticValues.DEFAULT_RIBBON_FILE_APP_TAB_TEXT_COLOR;

// Use debugging color
debugHighlight.BackColor = GlobalStaticValues.DEFAULT_HIGHLIGHT_DEBUGGING_COLOR;
```

## Image Arrays

The `GlobalStaticValues` class provides pre-configured image arrays for different toolbar themes.

### Generic Toolbar Images

```csharp
public static Image[] GenericToolBarImages =
[
    GenericToolbarImageResources.GenericNewDocument,
    GenericToolbarImageResources.GenericOpenFolder,
    GenericToolbarImageResources.GenericSave,
    GenericToolbarImageResources.GenericSaveAs,
    GenericToolbarImageResources.GenericSaveAll,
    GenericToolbarImageResources.GenericCut,
    GenericToolbarImageResources.GenericCopy,
    GenericToolbarImageResources.GenericPaste,
    GenericToolbarImageResources.GenericUndo,
    GenericToolbarImageResources.GenericRedo,
    GenericToolbarImageResources.GenericPrintSetup,
    GenericToolbarImageResources.GenericPrintPreview,
    GenericToolbarImageResources.GenericPrint,
    GenericToolbarImageResources.GenericQuickPrint
];
```

### Theme-Specific Toolbar Images

```csharp
// Microsoft 365 theme
public static Image[] Microsoft365ToolBarImages = [...];

// Office 2003 theme
public static Image[] Office2003ToolBarImages = [...];

// Office 2007 theme
public static Image[] Office2007ToolBarImages = [...];

// Office 2010 theme
public static Image[] Office2010ToolBarImages = [...];

// Office 2013 theme
public static Image[] Office2013ToolBarImages = [...];

// Office 2016 theme
public static Image[] Office2016ToolBarImages = [...];

// Office 2019 theme
public static Image[] Office2019ToolBarImages = [...];

// System theme
public static Image[] SystemToolBarImages = [...];

// Visual Studio theme
public static Image[] VisualStudioToolBarImages = [...];
```

**Usage:**
```csharp
// Apply toolbar images based on theme
Image[] toolbarImages = KryptonManager.GlobalPaletteMode switch
{
    PaletteMode.Microsoft365Blue => GlobalStaticValues.Microsoft365ToolBarImages,
    PaletteMode.Office2007Blue => GlobalStaticValues.Office2007ToolBarImages,
    PaletteMode.Office2010Blue => GlobalStaticValues.Office2010ToolBarImages,
    PaletteMode.SparkleBlue => GlobalStaticValues.SystemToolBarImages,
    _ => GlobalStaticValues.GenericToolBarImages
};

// Apply images to toolbar buttons
for (int i = 0; i < toolbarButtons.Length && i < toolbarImages.Length; i++)
{
    toolbarButtons[i].Image = toolbarImages[i];
}
```

## Utility Methods

### Null Check Helpers

```csharp
/// <summary>
/// Helper method that returns a generic message when a variable is null.
/// </summary>
/// <param name="variableName">Name of the variable to be inserted into the text.</param>
/// <returns>The message.</returns>
public static string VariableCannotBeNull(string variableName) => 
    $"Variable {variableName} cannot be null.";

/// <summary>
/// Helper method that returns a generic message when a property is null.
/// </summary>
/// <param name="propertyName">Name of the property to be inserted into the text.</param>
/// <returns>The message.</returns>
public static string PropertyCannotBeNull(string propertyName) => 
    $"Property {propertyName} cannot be null.";

/// <summary>
/// Helper method that returns a generic message when a parameter is null.
/// </summary>
/// <param name="parameterName">Name of the parameter to be inserted into the text.</param>
/// <returns>The message.</returns>
public static string ParameterCannotBeNull(string parameterName) => 
    $"Parameter {parameterName} cannot be null.";
```

**Usage:**
```csharp
// Validate parameters
if (parameter == null)
    throw new ArgumentNullException(nameof(parameter), 
        GlobalStaticValues.ParameterCannotBeNull(nameof(parameter)));

// Validate properties
if (someProperty == null)
    throw new InvalidOperationException(
        GlobalStaticValues.PropertyCannotBeNull(nameof(someProperty)));
```

### Special Properties

```csharp
/// <summary> 
/// KryptonMessageBoxes that use the KRichtTextBox need another color for the text.
/// Set the text colour to the one a non-input control uses.
/// </summary>
public static Color KryptonMessageBoxRichTextBoxTextColor 
{
    get => KryptonManager.CurrentGlobalPalette.GetContentLongTextColor1(
        PaletteContentStyle.LabelNormalPanel, PaletteState.Normal);
}
```

**Usage:**
```csharp
// Apply correct text color for rich text boxes in message boxes
richTextBox.ForeColor = GlobalStaticValues.KryptonMessageBoxRichTextBoxTextColor;
```

## Usage Examples

### Complete Theme Configuration

```csharp
public static class ThemeConfigurator
{
    public static void ApplyDefaultTheme()
    {
        // Set default palette mode
        KryptonManager.GlobalPaletteMode = GlobalStaticValues.GLOBAL_DEFAULT_PALETTE_MODE;
        
        // Configure corner rounding
        var cornerRadius = GlobalStaticValues.DEFAULT_PRIMARY_CORNER_ROUNDING_VALUE;
        
        // Apply to all buttons
        ApplyCornerRoundingToButtons(cornerRadius);
        
        // Configure UAC shield
        ConfigureUACShields();
    }
    
    private static void ApplyCornerRoundingToButtons(float radius)
    {
        foreach (var button in GetAllButtons())
        {
            button.CornerRoundingRadius = radius;
        }
    }
    
    private static void ConfigureUACShields()
    {
        foreach (var uacButton in GetAllUACButtons())
        {
            uacButton.ShieldIconSize = GlobalStaticValues.DEFAULT_UAC_SHIELD_ICON_SIZE;
            uacButton.ShieldIconCustomSize = GlobalStaticValues.DEFAULT_UAC_SHIELD_ICON_CUSTOM_SIZE;
        }
    }
}
```

### Exception Handling Configuration

```csharp
public static class ExceptionConfigurator
{
    public static void ConfigureExceptionHandling()
    {
        // Configure exception handling behavior
        var useStackTrace = GlobalStaticValues.DEFAULT_USE_STACK_TRACE;
        var useExceptionMessage = GlobalStaticValues.DEFAULT_USE_EXCEPTION_MESSAGE;
        var useInnerException = GlobalStaticValues.DEFAULT_USE_INNER_EXCEPTION;
        
        // Apply to exception handler
        ExceptionHandler.Configure(
            showStackTrace: useStackTrace,
            showExceptionMessage: useExceptionMessage,
            showInnerException: useInnerException
        );
    }
}
```

### Toolbar Image Management

```csharp
public static class ToolbarImageManager
{
    public static void ApplyThemeImages(KryptonToolbar toolbar)
    {
        var images = GetImagesForCurrentTheme();
        
        for (int i = 0; i < toolbar.Buttons.Count && i < images.Length; i++)
        {
            toolbar.Buttons[i].Image = images[i];
        }
    }
    
    private static Image[] GetImagesForCurrentTheme()
    {
        return KryptonManager.GlobalPaletteMode switch
        {
            PaletteMode.Microsoft365Blue => GlobalStaticValues.Microsoft365ToolBarImages,
            PaletteMode.Office2007Blue => GlobalStaticValues.Office2007ToolBarImages,
            PaletteMode.Office2010Blue => GlobalStaticValues.Office2010ToolBarImages,
            PaletteMode.Office2013Blue => GlobalStaticValues.Office2013ToolBarImages,
            PaletteMode.Office2016Blue => GlobalStaticValues.Office2016ToolBarImages,
            PaletteMode.Office2019Blue => GlobalStaticValues.Office2019ToolBarImages,
            PaletteMode.SparkleBlue => GlobalStaticValues.SystemToolBarImages,
            PaletteMode.VisualStudio2010Blue => GlobalStaticValues.VisualStudioToolBarImages,
            _ => GlobalStaticValues.GenericToolBarImages
        };
    }
}
```

## Best Practices

### 1. Use Constants Instead of Magic Numbers

```csharp
// Good
button.Padding = new Padding(GlobalStaticValues.GLOBAL_BUTTON_PADDING);

// Avoid
button.Padding = new Padding(10);
```

### 2. Check Constants Before Using

```csharp
// Good - validate before use
if (GlobalStaticValues.CURRENT_SUPPORTED_PALETTE_VERSION > paletteVersion)
{
    // Handle compatibility
}

// Avoid - assume values
if (paletteVersion < 20) // Magic number
{
    // Handle compatibility
}
```

### 3. Use Type-Safe Constants

```csharp
// Good - type-safe enum
var shieldSize = GlobalStaticValues.DEFAULT_UAC_SHIELD_ICON_SIZE;

// Avoid - magic numbers
var shieldSize = UACShieldIconSize.ExtraSmall; // Hard-coded
```

### 4. Group Related Constants

```csharp
// Good - related constants together
public static class RibbonConstants
{
    public static readonly Color DEFAULT_RIBBON_FILE_APP_TAB_BOTTOM_COLOR = Color.FromArgb(31, 72, 161);
    public static readonly Color DEFAULT_RIBBON_FILE_APP_TAB_TOP_COLOR = Color.FromArgb(84, 158, 243);
    public static readonly Color DEFAULT_RIBBON_FILE_APP_TAB_TEXT_COLOR = Color.White;
}
```

### 5. Document Custom Constants

```csharp
/// <summary>
/// Custom application constants that extend GlobalStaticValues
/// </summary>
public static class CustomApplicationConstants
{
    /// <summary>
    /// Default timeout for network operations (milliseconds)
    /// </summary>
    public const int DEFAULT_NETWORK_TIMEOUT = 30000;
    
    /// <summary>
    /// Maximum number of retry attempts for failed operations
    /// </summary>
    public const int MAX_RETRY_ATTEMPTS = 3;
}
```

### 6. Use Constants in Configuration

```csharp
public class ApplicationConfiguration
{
    public void LoadDefaults()
    {
        // Use GlobalStaticValues for default configuration
        ThemeMode = GlobalStaticValues.GLOBAL_DEFAULT_PALETTE_MODE;
        ButtonPadding = GlobalStaticValues.GLOBAL_BUTTON_PADDING;
        CornerRounding = GlobalStaticValues.DEFAULT_PRIMARY_CORNER_ROUNDING_VALUE;
        UACShieldSize = GlobalStaticValues.DEFAULT_UAC_SHIELD_ICON_SIZE;
    }
}
```

This comprehensive reference provides developers with complete information about all constants, values, and utility methods available in the `GlobalStaticValues` class, enabling them to build consistent and maintainable applications using the Krypton Toolkit Suite.
