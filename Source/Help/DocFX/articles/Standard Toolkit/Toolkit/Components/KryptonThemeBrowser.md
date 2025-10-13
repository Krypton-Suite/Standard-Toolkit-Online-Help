# KryptonThemeBrowser

## Overview

The `KryptonThemeBrowser` class provides a static utility for displaying theme selection dialogs. It offers a centralized way to show theme browser dialogs with customizable data and layout options, enabling users to preview and select from available Krypton themes.

## Class Hierarchy

```
System.Object
└── Krypton.Toolkit.KryptonThemeBrowser
```

## Key Methods

### Show Method

```csharp
public static void Show(KryptonThemeBrowserData themeBrowserData, RightToLeftLayout? rightToLeftLayout = RightToLeftLayout.LeftToRight)
```

- **Purpose**: Displays a theme browser dialog with the specified data and layout
- **Parameters**:
  - `themeBrowserData`: Configuration data for the theme browser
  - `rightToLeftLayout`: Optional RTL layout support (defaults to LeftToRight)
- **Usage**: Main entry point for showing theme selection dialogs

### ShowCore Method

```csharp
private static void ShowCore(KryptonThemeBrowserData themeBrowserData, RightToLeftLayout? layout)
```

- **Purpose**: Internal implementation of the theme browser display logic
- **Parameters**:
  - `themeBrowserData`: Configuration data for the theme browser
  - `layout`: RTL layout configuration
- **Implementation**: Handles the actual dialog creation and display

## Advanced Usage Patterns

### Basic Theme Browser

```csharp
public void ShowBasicThemeBrowser()
{
    var themeData = new KryptonThemeBrowserData
    {
        Title = "Select Theme",
        Description = "Choose a theme for your application",
        // Add theme configuration
    };

    KryptonThemeBrowser.Show(themeData);
}
```

### Advanced Theme Browser with Custom Data

```csharp
public class ThemeManager
{
    public void ShowAdvancedThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Application Theme Selection",
            Description = "Select a theme that best suits your preferences",
            // Add custom theme data
        };

        // Show with RTL support if needed
        RightToLeftLayout layout = IsRightToLeftLanguage() 
            ? RightToLeftLayout.Yes 
            : RightToLeftLayout.No;

        KryptonThemeBrowser.Show(themeData, layout);
    }

    private bool IsRightToLeftLanguage()
    {
        return CultureInfo.CurrentUICulture.TextInfo.IsRightToLeft;
    }
}
```

### Theme Browser with Callback

```csharp
public class ApplicationThemeManager
{
    public void ShowThemeBrowserWithCallback()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Choose Application Theme",
            Description = "Select a theme for the application interface",
            // Configure theme data
        };

        // Show theme browser
        KryptonThemeBrowser.Show(themeData);

        // Handle theme selection result
        HandleThemeSelection();
    }

    private void HandleThemeSelection()
    {
        // Process the selected theme
        var selectedTheme = GetSelectedTheme();
        if (selectedTheme != null)
        {
            ApplyTheme(selectedTheme);
            SaveThemePreference(selectedTheme);
        }
    }

    private object GetSelectedTheme()
    {
        // Implementation to get the selected theme
        return null;
    }

    private void ApplyTheme(object theme)
    {
        // Apply the selected theme to the application
    }

    private void SaveThemePreference(object theme)
    {
        // Save the theme preference for future use
    }
}
```

### Multi-Language Theme Browser

```csharp
public class LocalizedThemeManager
{
    public void ShowLocalizedThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = GetLocalizedString("ThemeBrowserTitle"),
            Description = GetLocalizedString("ThemeBrowserDescription"),
            // Add localized theme data
        };

        // Determine RTL layout based on current culture
        RightToLeftLayout layout = DetermineRightToLeftLayout();

        KryptonThemeBrowser.Show(themeData, layout);
    }

    private string GetLocalizedString(string key)
    {
        // Implementation to get localized strings
        return key; // Placeholder
    }

    private RightToLeftLayout DetermineRightToLeftLayout()
    {
        var culture = CultureInfo.CurrentUICulture;
        
        // Check if the current culture is RTL
        if (culture.TextInfo.IsRightToLeft)
        {
            return RightToLeftLayout.Yes;
        }

        // Check specific RTL languages
        var rtlLanguages = new[] { "ar", "he", "fa", "ur" };
        if (rtlLanguages.Contains(culture.TwoLetterISOLanguageName))
        {
            return RightToLeftLayout.Yes;
        }

        return RightToLeftLayout.No;
    }
}
```

## Integration Patterns

### Settings Dialog Integration

```csharp
public class SettingsDialog : Form
{
    private KryptonButton themeButton;

    public SettingsDialog()
    {
        InitializeComponent();
        SetupThemeButton();
    }

    private void SetupThemeButton()
    {
        themeButton = new KryptonButton
        {
            Text = "Change Theme",
            Dock = DockStyle.Fill
        };

        themeButton.Click += ThemeButton_Click;
    }

    private void ThemeButton_Click(object? sender, EventArgs e)
    {
        ShowThemeBrowser();
    }

    private void ShowThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Application Theme",
            Description = "Select a theme for the application interface",
            // Configure theme data
        };

        KryptonThemeBrowser.Show(themeData);
    }
}
```

### Application Startup Theme Selection

```csharp
public class ApplicationStartup
{
    public static void ShowStartupThemeSelection()
    {
        // Check if this is the first run
        if (IsFirstRun())
        {
            ShowWelcomeThemeBrowser();
        }
        else
        {
            // Load saved theme preference
            LoadSavedTheme();
        }
    }

    private static bool IsFirstRun()
    {
        // Implementation to check if this is the first run
        return true; // Placeholder
    }

    private static void ShowWelcomeThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Welcome - Choose Your Theme",
            Description = "Select a theme to personalize your application experience",
            // Add welcome-specific theme data
        };

        KryptonThemeBrowser.Show(themeData);
    }

    private static void LoadSavedTheme()
    {
        // Implementation to load saved theme preference
    }
}
```

### Dynamic Theme Switching

```csharp
public class DynamicThemeManager
{
    public void ShowThemeSwitcher()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Switch Theme",
            Description = "Change the application theme instantly",
            // Configure theme data for dynamic switching
        };

        // Show theme browser
        KryptonThemeBrowser.Show(themeData);

        // Apply theme changes immediately
        ApplyThemeChanges();
    }

    private void ApplyThemeChanges()
    {
        // Implementation to apply theme changes
        // This might involve updating the global palette
        // and refreshing all forms
    }
}
```

## Performance Considerations

- **Static Methods**: Efficient static method calls without instance creation
- **Memory Management**: Minimal memory footprint for utility class
- **Dialog Lifecycle**: Proper dialog creation and disposal
- **Theme Loading**: Optimized theme data loading and processing

## Common Issues and Solutions

### Theme Browser Not Showing

**Issue**: Theme browser dialog not appearing  
**Solution**: Ensure proper theme data configuration:

```csharp
var themeData = new KryptonThemeBrowserData
{
    Title = "Theme Selection",
    Description = "Choose a theme",
    // Ensure all required properties are set
};

KryptonThemeBrowser.Show(themeData);
```

### RTL Layout Issues

**Issue**: Right-to-left layout not working correctly  
**Solution**: Properly configure RTL layout:

```csharp
RightToLeftLayout layout = CultureInfo.CurrentUICulture.TextInfo.IsRightToLeft 
    ? RightToLeftLayout.Yes 
    : RightToLeftLayout.No;

KryptonThemeBrowser.Show(themeData, layout);
```

### Theme Data Configuration

**Issue**: Theme browser showing incorrect or missing data  
**Solution**: Ensure proper theme data setup:

```csharp
var themeData = new KryptonThemeBrowserData
{
    Title = "Select Theme",
    Description = "Choose your preferred theme",
    // Add all necessary theme configuration
    // Ensure themes are properly loaded and configured
};
```

## Design-Time Integration

### Visual Studio Designer

- **Static Class**: Not available in toolbox (static utility class)
- **Method Access**: Accessible through code only
- **Configuration**: Theme data configuration through code

### Usage Patterns

- **Settings Dialogs**: Integration with application settings
- **Startup Wizards**: First-run theme selection
- **Dynamic Switching**: Runtime theme changes
- **Localization**: Multi-language theme selection

## Migration and Compatibility

### Theme System Integration

```csharp
public class LegacyThemeManager
{
    public void MigrateToKryptonThemeBrowser()
    {
        // Old theme selection method
        // var oldThemeDialog = new OldThemeDialog();
        // oldThemeDialog.ShowDialog();

        // New Krypton theme browser
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Theme Selection",
            Description = "Choose your preferred theme",
            // Migrate old theme data to new format
        };

        KryptonThemeBrowser.Show(themeData);
    }
}
```

### Backward Compatibility

```csharp
public class CompatibleThemeManager
{
    public void ShowThemeBrowser(bool useLegacy = false)
    {
        if (useLegacy)
        {
            ShowLegacyThemeDialog();
        }
        else
        {
            ShowKryptonThemeBrowser();
        }
    }

    private void ShowLegacyThemeDialog()
    {
        // Legacy theme dialog implementation
    }

    private void ShowKryptonThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Theme Selection",
            Description = "Choose your preferred theme",
        };

        KryptonThemeBrowser.Show(themeData);
    }
}
```

## Real-World Integration Examples

### Application Settings Integration

```csharp
public partial class ApplicationSettingsForm : Form
{
    private KryptonButton themeButton;
    private KryptonLabel currentThemeLabel;

    public ApplicationSettingsForm()
    {
        InitializeComponent();
        SetupThemeSection();
    }

    private void SetupThemeSection()
    {
        // Current theme label
        currentThemeLabel = new KryptonLabel
        {
            Text = $"Current Theme: {GetCurrentThemeName()}",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        // Theme button
        themeButton = new KryptonButton
        {
            Text = "Change Theme...",
            Dock = DockStyle.Fill
        };

        themeButton.Click += ThemeButton_Click;

        // Add to layout
        var themeLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 1,
            Dock = DockStyle.Fill
        };

        themeLayout.Controls.Add(currentThemeLabel, 0, 0);
        themeLayout.Controls.Add(themeButton, 1, 0);

        Controls.Add(themeLayout);
    }

    private void ThemeButton_Click(object? sender, EventArgs e)
    {
        ShowThemeBrowser();
    }

    private void ShowThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Application Theme",
            Description = "Select a theme for the application interface. Changes will be applied immediately.",
            // Configure theme data
        };

        KryptonThemeBrowser.Show(themeData);

        // Update current theme label
        currentThemeLabel.Text = $"Current Theme: {GetCurrentThemeName()}";
    }

    private string GetCurrentThemeName()
    {
        // Implementation to get current theme name
        return "Default Theme";
    }
}
```

### Welcome Wizard Integration

```csharp
public class WelcomeWizard : Form
{
    private int currentStep = 0;
    private readonly List<WizardStep> steps;

    public WelcomeWizard()
    {
        InitializeComponent();
        steps = CreateWizardSteps();
        ShowCurrentStep();
    }

    private List<WizardStep> CreateWizardSteps()
    {
        return new List<WizardStep>
        {
            new WizardStep("Welcome", "Welcome to the application setup wizard."),
            new WizardStep("Theme Selection", "Choose your preferred theme."),
            new WizardStep("Configuration", "Configure basic settings."),
            new WizardStep("Complete", "Setup is complete!")
        };
    }

    private void ShowCurrentStep()
    {
        var step = steps[currentStep];
        
        switch (currentStep)
        {
            case 1: // Theme selection step
                ShowThemeSelectionStep();
                break;
            default:
                ShowDefaultStep(step);
                break;
        }
    }

    private void ShowThemeSelectionStep()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Choose Your Theme",
            Description = "Select a theme that best suits your preferences. You can change this later in settings.",
            // Configure theme data for welcome wizard
        };

        KryptonThemeBrowser.Show(themeData);
    }

    private void ShowDefaultStep(WizardStep step)
    {
        // Implementation for other wizard steps
    }
}

public class WizardStep
{
    public string Title { get; set; }
    public string Description { get; set; }

    public WizardStep(string title, string description)
    {
        Title = title;
        Description = description;
    }
}
```

### Dynamic Theme Switcher

```csharp
public class DynamicThemeSwitcher : UserControl
{
    private KryptonButton switchThemeButton;
    private KryptonLabel currentThemeLabel;
    private Timer themeUpdateTimer;

    public DynamicThemeSwitcher()
    {
        InitializeComponent();
        SetupThemeSwitcher();
    }

    private void SetupThemeSwitcher()
    {
        // Current theme label
        currentThemeLabel = new KryptonLabel
        {
            Text = $"Current: {GetCurrentThemeName()}",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        // Switch theme button
        switchThemeButton = new KryptonButton
        {
            Text = "Switch Theme",
            Dock = DockStyle.Fill
        };

        switchThemeButton.Click += SwitchThemeButton_Click;

        // Add to layout
        var layout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 1,
            Dock = DockStyle.Fill
        };

        layout.Controls.Add(currentThemeLabel, 0, 0);
        layout.Controls.Add(switchThemeButton, 1, 0);

        Controls.Add(layout);

        // Setup timer for theme updates
        themeUpdateTimer = new Timer { Interval = 1000 };
        themeUpdateTimer.Tick += OnThemeUpdateTimer;
        themeUpdateTimer.Start();
    }

    private void SwitchThemeButton_Click(object? sender, EventArgs e)
    {
        ShowThemeBrowser();
    }

    private void ShowThemeBrowser()
    {
        var themeData = new KryptonThemeBrowserData
        {
            Title = "Switch Theme",
            Description = "Change the application theme. The new theme will be applied immediately to all open windows.",
            // Configure theme data for dynamic switching
        };

        KryptonThemeBrowser.Show(themeData);
    }

    private void OnThemeUpdateTimer(object? sender, EventArgs e)
    {
        // Update current theme label
        currentThemeLabel.Text = $"Current: {GetCurrentThemeName()}";
    }

    private string GetCurrentThemeName()
    {
        // Implementation to get current theme name
        return "Default Theme";
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            themeUpdateTimer?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```