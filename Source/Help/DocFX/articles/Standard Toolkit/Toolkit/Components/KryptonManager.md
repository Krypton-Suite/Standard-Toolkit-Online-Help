# KryptonManager

## Overview

The `KryptonManager` class is the central component that manages global settings affecting all Krypton controls in your application. It provides a unified way to control themes, palettes, fonts, toolstrip rendering, and other global behaviors across the entire application. 

**Important**: The global settings affect all controls and not just those on the same form as the KryptonManager instance. This means that when you change a global setting, it will impact every Krypton control throughout your entire application, ensuring consistent theming and behavior across all forms and dialogs.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── Krypton.Toolkit.KryptonManager
```

## Constructor and Initialization

### Default Constructor

```csharp
public KryptonManager()
```

- **Purpose**: Creates a new instance of KryptonManager
- **Usage**: Basic instantiation for programmatic use

### Container Constructor

```csharp
public KryptonManager([DisallowNull] IContainer container)
```

- **Purpose**: Creates a new instance and adds it to the specified container
- **Parameters**:
  - `container`: Container that owns the component
- **Exception**: `ArgumentNullException` if container is null
- **Usage**: Design-time usage with proper component lifecycle management

### Static Constructor

```csharp
static KryptonManager()
```

- **Purpose**: Initializes static state and event handlers
- **Features**:
  - Registers for system color changes
  - Updates toolstrip manager with default settings
  - Sets up global event handling

## Key Properties

### GlobalPaletteMode Property

```csharp
[Category("GlobalPalette"), DefaultValue(PaletteMode.Microsoft365Blue)]
public PaletteMode GlobalPaletteMode { get; set; }
```

- **Purpose**: Controls the global theme/palette used by all Krypton controls
- **Category**: GlobalPalette
- **Default Value**: `PaletteMode.Microsoft365Blue`
- **Effect**: Changing this property updates all Krypton controls in the application
- **Available Values**: All built-in palette modes plus Custom and Global

**GlobalPaletteMode** - Each individual *Krypton* control will by default inherit its display values from the global palette that is specified by the *KryptonManager*. This makes it easy to change the global palette and have all *Krypton* controls update their appearance in one step.

*GlobalPaletteMode* is an enumeration that specifies which palette to use as the global palette. You can either choose one of the built-in palettes such as the *Professional - Office 2003* or specify use of a custom palette.

**Supported Palette Modes:**
- **Professional**: `ProfessionalSystem`, `ProfessionalOffice2003`
- **Office 2007**: `Office2007Blue`, `Office2007Silver`, `Office2007White`, `Office2007Black` (with Dark/Light mode variants)
- **Office 2010**: `Office2010Blue`, `Office2010Silver`, `Office2010White`, `Office2010Black` (with Dark/Light mode variants)
- **Office 2013**: `Office2013White`
- **Sparkle**: `SparkleBlue`, `SparkleOrange`, `SparklePurple` (with Dark/Light mode variants)
- **Microsoft 365**: `Microsoft365Blue`, `Microsoft365Silver`, `Microsoft365White`, `Microsoft365Black` (with Dark/Light mode variants)
- **Visual Studio**: `VisualStudio2010Render2007`, `VisualStudio2010Render2010`, `VisualStudio2010Render2013`, `VisualStudio2010Render365`
- **Material**: `MaterialLight`, `MaterialDark`, `MaterialLightRipple`, `MaterialDarkRipple`
- **Special**: `Custom`, `Global`

### GlobalCustomPalette Property

```csharp
[Category("GlobalPalette"), DefaultValue(null)]
public KryptonCustomPaletteBase? GlobalCustomPalette { get; set; }
```

- **Purpose**: Assigns a custom palette to be used globally
- **Category**: GlobalPalette
- **Default Value**: null
- **Effect**: When set, automatically changes `GlobalPaletteMode` to `Custom`
- **Usage**: For applications requiring custom color schemes and styling

**GlobalCustomPalette** - If you have loaded a custom palette into a [KryptonCustomPaletteBase](KryptonCustomPaletteBase.md) control, then you will need to assign it to the *GlobalCustomPalette* property. When this property is set to use a *KryptonCustomPaletteBase*, the *GlobalPaletteMode* will automatically be set to *Custom*. 

If the *GlobalCustomPalette* is subsequently reset back to its default value, then the *GlobalPaletteMode* will automatically be set to its default value, which is *Microsoft 365 - Blue*.

*GlobalCustomPalette* should be used when you need to use a *KryptonPalette* instance instead of one of the built-in palettes. Once you assign a reference to this property the *GlobalPaletteMode* will automatically be changed to the *Custom* enumeration value.

**Note**: You are not allowed circular references in the use of palettes. So if you define the global palette to be a *KryptonPalette* and then try to make the base palette of the *KryptonPalette* the *Global* value then it will cause an error. Whenever you alter the global palette or the base palette of a *KryptonPalette* it will check the inheritance chain to ensure no circular dependency is created.

### BaseFont Property

```csharp
[Category("GlobalPalette"), AllowNull]
public Font BaseFont { get; set; }
```

- **Purpose**: Controls the global font used throughout the toolkit
- **Category**: GlobalPalette
- **Default Value**: Segoe UI, 9pt
- **Effect**: Changes the font used by all Krypton controls
- **Usage**: Customize font name, size, and styling globally

**BaseFont** controls the global font used within the toolkit. Changing this property will change the font used by controls. By default, it is set to *Segoe UI, 9pt*. From here, you can customize the *Font Name*, *Size*, styling etc.

### GlobalApplyToolstrips Property

```csharp
[Category("Visuals"), DefaultValue(true)]
public bool GlobalApplyToolstrips { get; set; }
```

- **Purpose**: Controls whether palette colors are applied to toolstrips
- **Category**: Visuals
- **Default Value**: true
- **Effect**: When true, automatically updates ToolStripManager.Renderer
- **Usage**: Ensure consistent theming across toolstrips and menus

**GlobalApplyToolstrips** - In order to ensure your entire application looks consistent the *KryptonManager* will create and assign a tool strip renderer to your application. Whenever you change the global palette or the palette has a tool strip related value changed the tool strip renderer is updated to reflect this. If you prefer to turn off this feature so that you control the tool strip rendering manually then you just need to assign *False* to the *GlobalApplyToolstrips* property.

### GlobalUseThemeFormChromeBorderWidth Property

```csharp
[Category("Visuals"), DefaultValue(true)]
public bool GlobalUseThemeFormChromeBorderWidth { get; set; }
```

- **Purpose**: Controls whether KryptonForm instances use theme-based chrome border width
- **Category**: Visuals
- **Default Value**: true
- **Effect**: Overrides individual form chrome settings
- **Usage**: Global control over form appearance consistency

**GlobalUseThemeFormChromeBorderWidth** - When your *Form* derives from the *KryptonForm* base class the caption and border areas will be custom painted if the associated *Form* palette indicates it would like custom chrome. For example the *Office 2007* builtin palettes all request that the form be custom drawn to achieve a consistent look and feel to that of *Microsoft Office 2007* applications. If you would like to prevent any of your *KryptonForm* derived windows from having custom chrome then set this property to *False*. This setting overrides any requirement by a palette or *KryptonForm* to have custom chrome.

### UseKryptonFileDialogs Property

```csharp
[Category("Visuals"), DefaultValue(true)]
public bool UseKryptonFileDialogs { get; set; }
```

- **Purpose**: Controls whether Krypton file dialogs are used for internal operations
- **Category**: Visuals
- **Default Value**: true
- **Effect**: Affects dialogs like CustomPalette import
- **Usage**: Ensure consistent dialog theming

### ShowAdministratorSuffix Property

```csharp
[Category("Visuals"), DefaultValue(true)]
public bool ShowAdministratorSuffix { get; set; }
```

- **Purpose**: Controls whether administrator suffix is shown in KryptonForm title bars
- **Category**: Visuals
- **Default Value**: true
- **Effect**: Shows "(Administrator)" when running with elevated privileges
- **Usage**: Visual indication of elevated permissions

### ToolkitStrings Property

```csharp
[Category("Data"), Localizable(true)]
public KryptonGlobalToolkitStrings ToolkitStrings { get; }
```

- **Purpose**: Collection of global toolkit strings that can be localized
- **Category**: Data
- **Localizable**: true
- **Effect**: Controls text displayed in message boxes, dialogs, and other UI elements
- **Usage**: Multi-language support and custom text customization

**ToolkitStrings** - The *KryptonMessageBox* has buttons that use the string values from this section. If you would like to alter the strings displayed on those buttons then you can do so by altering the values in this area. If you have set the *Localization* property on your *Form* to *True* then these values will be stored on a per-language setting allowing your message box to have different display strings per language you choose to define. The *ToolkitStrings* also contains strings used throughout the toolkit that you can customize. You will note that sub-sections are labelled accordingly to which sections of the toolkit they will affect.

### ToolkitColors Property

```csharp
[Category("Data")]
public KryptonColorStorage ToolkitColors { get; }
```

- **Purpose**: Collection of global toolkit colors
- **Category**: Data
- **Effect**: Provides access to color storage for custom theming
- **Usage**: Advanced color customization and theming

## Static Properties

### Strings Property

```csharp
public static KryptonGlobalToolkitStrings Strings { get; }
```

- **Purpose**: Global access to toolkit strings
- **Type**: Static property
- **Usage**: Access strings from anywhere in the application

### Images Property

```csharp
public static KryptonImageStorage Images { get; }
```

- **Purpose**: Global access to toolkit images
- **Type**: Static property
- **Usage**: Access images for toolbars, dialogs, and other UI elements

**ToolkitImages** - The *ToolkitImages* property is where you can define your own images that are used throughout the toolkit. The [KryptonIntegratedToolBar](KryptonIntegratedToolBarManager.md) uses these set of images to display on toolbars, as well as the [KryptonAboutBox](KryptonAboutBox.md).

### Colors Property

```csharp
public static KryptonColorStorage Colors { get; }
```

- **Purpose**: Global access to toolkit colors
- **Type**: Static property
- **Usage**: Access color storage for theming

### CurrentGlobalPaletteMode Property

```csharp
public static PaletteMode CurrentGlobalPaletteMode { get; private set; }
```

- **Purpose**: Gets the currently active global palette mode
- **Type**: Static property
- **Usage**: Check current theme state

### CurrentGlobalPalette Property

```csharp
public static PaletteBase CurrentGlobalPalette { get; private set; }
```

- **Purpose**: Gets the currently active global palette instance
- **Type**: Static property
- **Usage**: Access current palette for advanced operations

## Key Methods

### GetPaletteForMode Method

```csharp
public static PaletteBase GetPaletteForMode(PaletteMode mode)
```

- **Purpose**: Gets the palette instance for a specific mode
- **Parameters**:
  - `mode`: The palette mode to retrieve
- **Returns**: `PaletteBase` instance for the specified mode
- **Exception**: `ArgumentOutOfRangeException` for invalid modes
- **Usage**: Access specific palette instances programmatically

### GetModeForPalette Method

```csharp
public static PaletteMode GetModeForPalette(PaletteBase? palette)
```

- **Purpose**: Determines the palette mode for a given palette instance
- **Parameters**:
  - `palette`: The palette instance to analyze
- **Returns**: `PaletteMode` corresponding to the palette
- **Usage**: Identify the mode of a custom palette

### GetRendererForMode Method

```csharp
public static IRenderer GetRendererForMode(RendererMode mode)
```

- **Purpose**: Gets the renderer instance for a specific mode
- **Parameters**:
  - `mode`: The renderer mode to retrieve
- **Returns**: `IRenderer` instance for the specified mode
- **Exception**: `ArgumentOutOfRangeException` for invalid modes
- **Usage**: Access specific renderer instances

### Reset Method

```csharp
public void Reset()
```

- **Purpose**: Resets all KryptonManager properties to their default values
- **Effect**: Restores default theme, font, and other settings
- **Usage**: Restore application to default state

## Events

### GlobalPaletteChanged Event

```csharp
[Category("Property Changed")]
public static event EventHandler? GlobalPaletteChanged;
```

- **Purpose**: Fired when the global palette changes
- **Category**: Property Changed
- **Usage**: React to theme changes across the application

### GlobalUseThemeFormChromeBorderWidthChanged Event

```csharp
[Category("Property Changed")]
public static event EventHandler? GlobalUseThemeFormChromeBorderWidthChanged;
```

- **Purpose**: Fired when the form chrome border width setting changes
- **Category**: Property Changed
- **Usage**: React to form chrome setting changes

## Advanced Usage Patterns

### Basic Theme Management

```csharp
public class ThemeManager
{
    public void SetApplicationTheme(PaletteMode theme)
    {
        KryptonManager.GlobalPaletteMode = theme;
    }

    public void SetCustomTheme(KryptonCustomPaletteBase customPalette)
    {
        KryptonManager.GlobalCustomPalette = customPalette;
    }

    public void ResetToDefault()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        KryptonManager.GlobalCustomPalette = null;
    }
}
```

### Dynamic Theme Switching

```csharp
public class DynamicThemeManager
{
    private readonly List<PaletteMode> availableThemes;
    private int currentThemeIndex;

    public DynamicThemeManager()
    {
        availableThemes = new List<PaletteMode>
        {
            PaletteMode.Microsoft365Blue,
            PaletteMode.Microsoft365Silver,
            PaletteMode.Microsoft365White,
            PaletteMode.Microsoft365Black,
            PaletteMode.Office2007Blue,
            PaletteMode.Office2010Blue,
            PaletteMode.SparkleBlue,
            PaletteMode.MaterialLight,
            PaletteMode.MaterialDark
        };
        
        currentThemeIndex = 0;
        
        // Subscribe to theme changes
        KryptonManager.GlobalPaletteChanged += OnThemeChanged;
    }

    public void NextTheme()
    {
        currentThemeIndex = (currentThemeIndex + 1) % availableThemes.Count;
        KryptonManager.GlobalPaletteMode = availableThemes[currentThemeIndex];
    }

    public void PreviousTheme()
    {
        currentThemeIndex = (currentThemeIndex - 1 + availableThemes.Count) % availableThemes.Count;
        KryptonManager.GlobalPaletteMode = availableThemes[currentThemeIndex];
    }

    public void SetTheme(PaletteMode theme)
    {
        if (availableThemes.Contains(theme))
        {
            currentThemeIndex = availableThemes.IndexOf(theme);
            KryptonManager.GlobalPaletteMode = theme;
        }
    }

    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // React to theme changes
        Console.WriteLine($"Theme changed to: {KryptonManager.CurrentGlobalPaletteMode}");
    }
}
```

### Custom Palette Management

```csharp
public class CustomPaletteManager
{
    private KryptonCustomPaletteBase? currentCustomPalette;

    public void LoadCustomPalette(string paletteFile)
    {
        try
        {
            var customPalette = new KryptonCustomPaletteBase();
            customPalette.Import(paletteFile);
            
            KryptonManager.GlobalCustomPalette = customPalette;
            currentCustomPalette = customPalette;
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to load palette: {ex.Message}", "Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    public void SaveCustomPalette(string paletteFile)
    {
        if (currentCustomPalette != null)
        {
            try
            {
                currentCustomPalette.Export(paletteFile);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Failed to save palette: {ex.Message}", "Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }
    }

    public void CreateCustomPalette()
    {
        var customPalette = new KryptonCustomPaletteBase();
        
        // Customize colors
        customPalette.ColorTable.ButtonSelectedGradientBegin = Color.LightBlue;
        customPalette.ColorTable.ButtonSelectedGradientEnd = Color.DarkBlue;
        customPalette.ColorTable.ButtonPressedGradientBegin = Color.DarkBlue;
        customPalette.ColorTable.ButtonPressedGradientEnd = Color.LightBlue;
        
        // Apply the custom palette
        KryptonManager.GlobalCustomPalette = customPalette;
        currentCustomPalette = customPalette;
    }
}
```

### Font Management

```csharp
public class FontManager
{
    public void SetGlobalFont(string fontFamily, float size, FontStyle style = FontStyle.Regular)
    {
        var font = new Font(fontFamily, size, style);
        KryptonManager.BaseFont = font;
    }

    public void SetGlobalFont(Font font)
    {
        KryptonManager.BaseFont = font;
    }

    public void ResetGlobalFont()
    {
        KryptonManager.BaseFont = null; // Resets to default
    }

    public Font GetCurrentFont()
    {
        return KryptonManager.BaseFont;
    }
}
```

### Localization Management

```csharp
public class LocalizationManager
{
    public void SetLanguage(string languageCode)
    {
        // Set culture
        var culture = new CultureInfo(languageCode);
        Thread.CurrentThread.CurrentCulture = culture;
        Thread.CurrentThread.CurrentUICulture = culture;

        // Update toolkit strings
        UpdateToolkitStrings(languageCode);
    }

    private void UpdateToolkitStrings(string languageCode)
    {
        switch (languageCode)
        {
            case "en-US":
                KryptonManager.Strings.CommonStrings.Ok = "OK";
                KryptonManager.Strings.CommonStrings.Cancel = "Cancel";
                KryptonManager.Strings.CommonStrings.Yes = "Yes";
                KryptonManager.Strings.CommonStrings.No = "No";
                break;
            case "es-ES":
                KryptonManager.Strings.CommonStrings.Ok = "Aceptar";
                KryptonManager.Strings.CommonStrings.Cancel = "Cancelar";
                KryptonManager.Strings.CommonStrings.Yes = "Sí";
                KryptonManager.Strings.CommonStrings.No = "No";
                break;
            case "fr-FR":
                KryptonManager.Strings.CommonStrings.Ok = "OK";
                KryptonManager.Strings.CommonStrings.Cancel = "Annuler";
                KryptonManager.Strings.CommonStrings.Yes = "Oui";
                KryptonManager.Strings.CommonStrings.No = "Non";
                break;
        }
    }
}
```

## Integration Patterns

### Application Startup Configuration

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonManager kryptonManager;

    public MainForm()
    {
        InitializeComponent();
        SetupKryptonManager();
        ConfigureApplication();
    }

    private void SetupKryptonManager()
    {
        kryptonManager = new KryptonManager();
        Components.Add(kryptonManager);
    }

    private void ConfigureApplication()
    {
        // Set initial theme
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        
        // Configure global settings
        KryptonManager.GlobalApplyToolstrips = true;
        KryptonManager.GlobalUseThemeFormChromeBorderWidth = true;
        KryptonManager.UseKryptonFileDialogs = true;
        KryptonManager.ShowAdministratorSuffix = true;
        
        // Set custom font if needed
        KryptonManager.BaseFont = new Font("Segoe UI", 10f);
        
        // Subscribe to events
        KryptonManager.GlobalPaletteChanged += OnGlobalPaletteChanged;
    }

    private void OnGlobalPaletteChanged(object? sender, EventArgs e)
    {
        // React to theme changes
        UpdateApplicationForTheme();
    }

    private void UpdateApplicationForTheme()
    {
        // Update application-specific elements based on theme
        var currentTheme = KryptonManager.CurrentGlobalPaletteMode;
        
        switch (currentTheme)
        {
            case PaletteMode.MaterialDark:
            case PaletteMode.Microsoft365BlackDarkMode:
                // Configure for dark theme
                ConfigureDarkTheme();
                break;
            case PaletteMode.MaterialLight:
            case PaletteMode.Microsoft365White:
                // Configure for light theme
                ConfigureLightTheme();
                break;
        }
    }

    private void ConfigureDarkTheme()
    {
        // Dark theme specific configuration
    }

    private void ConfigureLightTheme()
    {
        // Light theme specific configuration
    }
}
```

### Settings-Based Theme Management

```csharp
public class ApplicationSettings
{
    public PaletteMode Theme { get; set; } = PaletteMode.Microsoft365Blue;
    public string FontFamily { get; set; } = "Segoe UI";
    public float FontSize { get; set; } = 9f;
    public bool ApplyToolstrips { get; set; } = true;
    public bool UseThemeFormChrome { get; set; } = true;
    public bool ShowAdministratorSuffix { get; set; } = true;
    public bool UseKryptonFileDialogs { get; set; } = true;
}

public class SettingsManager
{
    private readonly string settingsFile = "appsettings.json";

    public void LoadSettings()
    {
        try
        {
            if (File.Exists(settingsFile))
            {
                var json = File.ReadAllText(settingsFile);
                var settings = JsonSerializer.Deserialize<ApplicationSettings>(json);
                
                if (settings != null)
                {
                    ApplySettings(settings);
                }
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to load settings: {ex.Message}", "Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    public void SaveSettings()
    {
        try
        {
            var settings = new ApplicationSettings
            {
                Theme = KryptonManager.CurrentGlobalPaletteMode,
                FontFamily = KryptonManager.BaseFont.FontFamily.Name,
                FontSize = KryptonManager.BaseFont.Size,
                ApplyToolstrips = KryptonManager.GlobalApplyToolstrips,
                UseThemeFormChrome = KryptonManager.GlobalUseThemeFormChromeBorderWidth,
                ShowAdministratorSuffix = KryptonManager.ShowAdministratorSuffix,
                UseKryptonFileDialogs = KryptonManager.UseKryptonFileDialogs
            };

            var json = JsonSerializer.Serialize(settings, new JsonSerializerOptions { WriteIndented = true });
            File.WriteAllText(settingsFile, json);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to save settings: {ex.Message}", "Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    private void ApplySettings(ApplicationSettings settings)
    {
        KryptonManager.GlobalPaletteMode = settings.Theme;
        KryptonManager.BaseFont = new Font(settings.FontFamily, settings.FontSize);
        KryptonManager.GlobalApplyToolstrips = settings.ApplyToolstrips;
        KryptonManager.GlobalUseThemeFormChromeBorderWidth = settings.UseThemeFormChrome;
        KryptonManager.ShowAdministratorSuffix = settings.ShowAdministratorSuffix;
        KryptonManager.UseKryptonFileDialogs = settings.UseKryptonFileDialogs;
    }
}
```

### Multi-Form Theme Synchronization

```csharp
public class FormThemeManager
{
    private static readonly List<KryptonForm> registeredForms = new List<KryptonForm>();

    public static void RegisterForm(KryptonForm form)
    {
        if (!registeredForms.Contains(form))
        {
            registeredForms.Add(form);
            form.FormClosed += OnFormClosed;
        }
    }

    public static void UnregisterForm(KryptonForm form)
    {
        registeredForms.Remove(form);
        form.FormClosed -= OnFormClosed;
    }

    public static void ApplyThemeToAllForms(PaletteMode theme)
    {
        KryptonManager.GlobalPaletteMode = theme;
        
        // Force refresh of all registered forms
        foreach (var form in registeredForms)
        {
            if (!form.IsDisposed)
            {
                form.Invalidate();
                form.Refresh();
            }
        }
    }

    private static void OnFormClosed(object? sender, FormClosedEventArgs e)
    {
        if (sender is KryptonForm form)
        {
            UnregisterForm(form);
        }
    }
}
```

## Performance Considerations

- **Static Properties**: Efficient access to global state without instance creation
- **Palette Caching**: Built-in palettes are cached and reused
- **Event Management**: Efficient event handling for theme changes
- **Memory Management**: Proper cleanup of palette instances and event handlers

## Common Issues and Solutions

### Theme Not Applying

**Issue**: Theme changes not affecting all controls  
**Solution**: Ensure proper event handling and form refresh:

```csharp
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    // Force refresh of all forms
    foreach (Form form in Application.OpenForms)
    {
        form.Invalidate();
        form.Refresh();
    }
};
```

### Custom Palette Not Working

**Issue**: Custom palette not being applied  
**Solution**: Ensure proper palette assignment:

```csharp
var customPalette = new KryptonCustomPaletteBase();
// Configure custom palette
KryptonManager.GlobalCustomPalette = customPalette;
// This automatically sets GlobalPaletteMode to Custom
```

### Font Not Updating

**Issue**: Font changes not affecting all controls  
**Solution**: Ensure proper font assignment and control refresh:

```csharp
KryptonManager.BaseFont = new Font("Arial", 12f);
// Force refresh of all controls
Application.DoEvents();
```

### Toolstrip Not Themed

**Issue**: Toolstrips not using Krypton theming  
**Solution**: Ensure GlobalApplyToolstrips is enabled:

```csharp
KryptonManager.GlobalApplyToolstrips = true;
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox**: Available with custom bitmap representation
- **Property Window**: All properties available for configuration
- **Designer Support**: Full design-time support with custom designer
- **Default Property**: `GlobalPaletteMode` is the default property

### Property Categories

- **GlobalPalette**: Theme and palette-related properties
- **Visuals**: Visual appearance and behavior properties
- **Data**: Strings, colors, and other data properties
- **Property Changed**: Event properties

## Migration and Compatibility

### From Manual Theme Management

```csharp
// Old way (manual theme management)
// foreach (Control control in this.Controls)
// {
//     if (control is KryptonControl kryptonControl)
//     {
//         kryptonControl.PaletteMode = PaletteMode.Office2007Blue;
//     }
// }

// New way (global theme management)
KryptonManager.GlobalPaletteMode = PaletteMode.Office2007Blue;
```

### From Custom Theme Systems

```csharp
// Old way (custom theme system)
// CustomThemeManager.SetTheme("Blue");

// New way (KryptonManager)
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
```

## Real-World Integration Examples

### Enterprise Application Theme Management

```csharp
public class EnterpriseThemeManager
{
    private readonly Dictionary<string, PaletteMode> companyThemes;
    private readonly Dictionary<string, KryptonCustomPaletteBase> customThemes;

    public EnterpriseThemeManager()
    {
        companyThemes = new Dictionary<string, PaletteMode>
        {
            ["Corporate Blue"] = PaletteMode.Microsoft365Blue,
            ["Corporate Silver"] = PaletteMode.Microsoft365Silver,
            ["Corporate White"] = PaletteMode.Microsoft365White,
            ["Corporate Black"] = PaletteMode.Microsoft365Black,
            ["Legacy Office"] = PaletteMode.Office2007Blue,
            ["Modern Office"] = PaletteMode.Office2010Blue,
            ["Creative"] = PaletteMode.SparkleBlue,
            ["Material Light"] = PaletteMode.MaterialLight,
            ["Material Dark"] = PaletteMode.MaterialDark
        };

        customThemes = new Dictionary<string, KryptonCustomPaletteBase>();
        LoadCustomThemes();
    }

    public void ApplyCompanyTheme(string themeName)
    {
        if (companyThemes.TryGetValue(themeName, out var paletteMode))
        {
            KryptonManager.GlobalPaletteMode = paletteMode;
        }
        else if (customThemes.TryGetValue(themeName, out var customPalette))
        {
            KryptonManager.GlobalCustomPalette = customPalette;
        }
        else
        {
            throw new ArgumentException($"Theme '{themeName}' not found", nameof(themeName));
        }
    }

    public string[] GetAvailableThemes()
    {
        var themes = new List<string>();
        themes.AddRange(companyThemes.Keys);
        themes.AddRange(customThemes.Keys);
        return themes.ToArray();
    }

    public void CreateCustomTheme(string themeName, Color primaryColor, Color secondaryColor)
    {
        var customPalette = new KryptonCustomPaletteBase();
        
        // Configure colors based on company branding
        customPalette.ColorTable.ButtonSelectedGradientBegin = primaryColor;
        customPalette.ColorTable.ButtonSelectedGradientEnd = secondaryColor;
        customPalette.ColorTable.ButtonPressedGradientBegin = secondaryColor;
        customPalette.ColorTable.ButtonPressedGradientEnd = primaryColor;
        
        customThemes[themeName] = customPalette;
        SaveCustomThemes();
    }

    private void LoadCustomThemes()
    {
        // Implementation to load custom themes from storage
    }

    private void SaveCustomThemes()
    {
        // Implementation to save custom themes to storage
    }
}
```

### Multi-Tenant Application Theme Management

```csharp
public class MultiTenantThemeManager
{
    private readonly Dictionary<string, TenantThemeSettings> tenantThemes;
    private string currentTenant;

    public MultiTenantThemeManager()
    {
        tenantThemes = new Dictionary<string, TenantThemeSettings>();
        LoadTenantThemes();
    }

    public void SetTenant(string tenantId)
    {
        currentTenant = tenantId;
        
        if (tenantThemes.TryGetValue(tenantId, out var settings))
        {
            ApplyTenantTheme(settings);
        }
        else
        {
            // Apply default theme for new tenant
            ApplyDefaultTheme();
        }
    }

    public void UpdateTenantTheme(string tenantId, TenantThemeSettings settings)
    {
        tenantThemes[tenantId] = settings;
        
        if (tenantId == currentTenant)
        {
            ApplyTenantTheme(settings);
        }
        
        SaveTenantThemes();
    }

    private void ApplyTenantTheme(TenantThemeSettings settings)
    {
        if (settings.UseCustomPalette && settings.CustomPalette != null)
        {
            KryptonManager.GlobalCustomPalette = settings.CustomPalette;
        }
        else
        {
            KryptonManager.GlobalPaletteMode = settings.PaletteMode;
        }

        if (settings.CustomFont != null)
        {
            KryptonManager.BaseFont = settings.CustomFont;
        }

        // Apply tenant-specific strings
        ApplyTenantStrings(settings);
    }

    private void ApplyDefaultTheme()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        KryptonManager.BaseFont = new Font("Segoe UI", 9f);
    }

    private void ApplyTenantStrings(TenantThemeSettings settings)
    {
        if (settings.CustomStrings != null)
        {
            foreach (var kvp in settings.CustomStrings)
            {
                // Apply custom strings based on tenant requirements
                // Implementation depends on specific string properties
            }
        }
    }

    private void LoadTenantThemes()
    {
        // Implementation to load tenant themes from storage
    }

    private void SaveTenantThemes()
    {
        // Implementation to save tenant themes to storage
    }
}

public class TenantThemeSettings
{
    public PaletteMode PaletteMode { get; set; } = PaletteMode.Microsoft365Blue;
    public bool UseCustomPalette { get; set; } = false;
    public KryptonCustomPaletteBase? CustomPalette { get; set; }
    public Font? CustomFont { get; set; }
    public Dictionary<string, string>? CustomStrings { get; set; }
}
```

### Accessibility Theme Management

```csharp
public class AccessibilityThemeManager
{
    public void ApplyHighContrastTheme()
    {
        var highContrastPalette = new KryptonCustomPaletteBase();
        
        // Configure high contrast colors
        highContrastPalette.ColorTable.ButtonSelectedGradientBegin = Color.White;
        highContrastPalette.ColorTable.ButtonSelectedGradientEnd = Color.Black;
        highContrastPalette.ColorTable.ButtonPressedGradientBegin = Color.Black;
        highContrastPalette.ColorTable.ButtonPressedGradientEnd = Color.White;
        highContrastPalette.ColorTable.ButtonCheckedGradientBegin = Color.Yellow;
        highContrastPalette.ColorTable.ButtonCheckedGradientEnd = Color.Orange;
        
        KryptonManager.GlobalCustomPalette = highContrastPalette;
        
        // Use larger font for better readability
        KryptonManager.BaseFont = new Font("Segoe UI", 12f, FontStyle.Bold);
    }

    public void ApplyLargeFontTheme()
    {
        // Keep current theme but increase font size
        KryptonManager.BaseFont = new Font("Segoe UI", 14f);
    }

    public void ApplyColorBlindFriendlyTheme()
    {
        var colorBlindPalette = new KryptonCustomPaletteBase();
        
        // Use colors that are distinguishable for colorblind users
        colorBlindPalette.ColorTable.ButtonSelectedGradientBegin = Color.LightBlue;
        colorBlindPalette.ColorTable.ButtonSelectedGradientEnd = Color.DarkBlue;
        colorBlindPalette.ColorTable.ButtonPressedGradientBegin = Color.DarkBlue;
        colorBlindPalette.ColorTable.ButtonPressedGradientEnd = Color.LightBlue;
        
        KryptonManager.GlobalCustomPalette = colorBlindPalette;
    }

    public void ResetToDefaultTheme()
    {
        KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
        KryptonManager.BaseFont = new Font("Segoe UI", 9f);
    }
}
```