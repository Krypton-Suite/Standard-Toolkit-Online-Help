# KryptonThemeComboBox

## Overview

The `KryptonThemeComboBox` class provides a Krypton-themed ComboBox control that allows users to select from available Krypton themes. It inherits from `KryptonComboBox` and implements `IKryptonThemeSelectorBase` to provide theme selection functionality with automatic synchronization with the global palette system.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── System.Windows.Forms.ComboBox
                └── Krypton.Toolkit.KryptonComboBox
                    └── Krypton.Toolkit.KryptonThemeComboBox
```

## Constructor and Initialization

```csharp
public KryptonThemeComboBox()
```

The constructor initializes enhanced features:
- **KryptonManager Integration**: Creates local KryptonManager instance for theme management
- **Theme Population**: Automatically populates with available themes using `CommonHelperThemeSelectors.GetThemesArray()`
- **Initial Selection**: Sets initial selected index based on current global palette
- **Event Handling**: Sets up global palette change event handling
- **Synchronization**: Maintains synchronization between local and global palette changes

## Key Properties

### KryptonCustomPalette Property

```csharp
[Obsolete("Deprecated and will be removed in V110. Set a global custom palette through 'ThemeManager.ApplyTheme(...)'.")]
public KryptonCustomPaletteBase? KryptonCustomPalette { get; set; }
```

- **Purpose**: Custom palette assignment (deprecated)
- **Category**: Visuals
- **Status**: Obsolete - will be removed in V110
- **Alternative**: Use `ThemeManager.ApplyTheme(...)` for global custom palettes
- **Default Value**: null

### DefaultPalette Property

```csharp
[DefaultValue(PaletteMode.Global)]
public PaletteMode DefaultPalette { get; set; }
```

- **Purpose**: Sets the default palette mode for the control
- **Category**: Visuals
- **Default Value**: `PaletteMode.Global`
- **Effect**: Updates selected index when changed
- **Usage**: Controls which palette is selected by default

### Hidden Properties

The following properties are hidden from the designer but remain accessible:

```csharp
[Browsable(false)]
public override string Text { get; set; }

[Browsable(false)]
public new string FormatString { get; set; }

[Browsable(false)]
public new ListBox.ObjectCollection Items { get; }

[Browsable(false)]
public new int SelectedIndex { get; set; }
```

## Advanced Usage Patterns

### Basic Theme Selection

```csharp
public void SetupBasicThemeComboBox()
{
    var themeComboBox = new KryptonThemeComboBox
    {
        Dock = DockStyle.Fill,
        DropDownStyle = ComboBoxStyle.DropDownList
    };

    // Handle theme selection
    themeComboBox.SelectedIndexChanged += OnThemeSelectionChanged;

    Controls.Add(themeComboBox);
}

private void OnThemeSelectionChanged(object? sender, EventArgs e)
{
    if (sender is KryptonThemeComboBox comboBox)
    {
        // Theme selection is automatically handled by the control
        // The global palette will be updated automatically
        Console.WriteLine($"Selected theme: {comboBox.SelectedItem}");
    }
}
```

### Settings Dialog Integration

```csharp
public class SettingsDialog : Form
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonLabel themeLabel;

    public SettingsDialog()
    {
        InitializeComponent();
        SetupThemeSelection();
    }

    private void SetupThemeSelection()
    {
        // Theme label
        themeLabel = new KryptonLabel
        {
            Text = "Application Theme:",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        // Theme combo box
        themeComboBox = new KryptonThemeComboBox
        {
            Dock = DockStyle.Fill,
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        // Add to layout
        var themeLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 1,
            Dock = DockStyle.Fill
        };

        themeLayout.Controls.Add(themeLabel, 0, 0);
        themeLayout.Controls.Add(themeComboBox, 1, 0);

        Controls.Add(themeLayout);
    }
}
```

### Advanced Theme Management

```csharp
public class AdvancedThemeManager
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonButton applyButton;
    private KryptonButton resetButton;
    private PaletteMode originalTheme;

    public AdvancedThemeManager()
    {
        InitializeComponents();
        SetupEventHandling();
    }

    private void InitializeComponents()
    {
        themeComboBox = new KryptonThemeComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        applyButton = new KryptonButton
        {
            Text = "Apply Theme",
            Enabled = false
        };

        resetButton = new KryptonButton
        {
            Text = "Reset to Default"
        };

        // Store original theme
        originalTheme = KryptonManager.CurrentGlobalPaletteMode;
    }

    private void SetupEventHandling()
    {
        themeComboBox.SelectedIndexChanged += OnThemeSelectionChanged;
        applyButton.Click += OnApplyButtonClick;
        resetButton.Click += OnResetButtonClick;
    }

    private void OnThemeSelectionChanged(object? sender, EventArgs e)
    {
        // Enable apply button when theme changes
        applyButton.Enabled = true;
    }

    private void OnApplyButtonClick(object? sender, EventArgs e)
    {
        // Theme is already applied automatically by KryptonThemeComboBox
        // This is just for user feedback
        MessageBox.Show("Theme applied successfully!", "Theme Changed", 
            MessageBoxButtons.OK, MessageBoxIcon.Information);
        
        applyButton.Enabled = false;
    }

    private void OnResetButtonClick(object? sender, EventArgs e)
    {
        // Reset to original theme
        KryptonManager.GlobalPaletteMode = originalTheme;
        applyButton.Enabled = false;
    }
}
```

### Theme Preview System

```csharp
public class ThemePreviewManager
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonPanel previewPanel;
    private Timer previewTimer;

    public ThemePreviewManager()
    {
        InitializeComponents();
        SetupPreviewSystem();
    }

    private void InitializeComponents()
    {
        themeComboBox = new KryptonThemeComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        previewPanel = new KryptonPanel
        {
            Size = new Size(200, 100),
            PanelBackStyle = PaletteBackStyle.PanelClient
        };

        // Add sample controls to preview panel
        var sampleButton = new KryptonButton
        {
            Text = "Sample Button",
            Location = new Point(10, 10)
        };

        var sampleLabel = new KryptonLabel
        {
            Text = "Sample Label",
            Location = new Point(10, 40)
        };

        previewPanel.Controls.Add(sampleButton);
        previewPanel.Controls.Add(sampleLabel);
    }

    private void SetupPreviewSystem()
    {
        // Setup preview timer for delayed preview
        previewTimer = new Timer { Interval = 500 }; // 500ms delay
        previewTimer.Tick += OnPreviewTimerTick;

        themeComboBox.SelectedIndexChanged += OnThemeSelectionChanged;
    }

    private void OnThemeSelectionChanged(object? sender, EventArgs e)
    {
        // Start preview timer
        previewTimer.Stop();
        previewTimer.Start();
    }

    private void OnPreviewTimerTick(object? sender, EventArgs e)
    {
        previewTimer.Stop();
        
        // Update preview panel with selected theme
        UpdatePreviewPanel();
    }

    private void UpdatePreviewPanel()
    {
        // The preview panel will automatically update with the new theme
        // since it uses the global palette system
        previewPanel.Invalidate();
    }
}
```

## Integration Patterns

### Main Form Theme Selector

```csharp
public partial class MainForm : Form
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonStatusStrip statusStrip;

    public MainForm()
    {
        InitializeComponent();
        SetupThemeSelector();
    }

    private void SetupThemeSelector()
    {
        // Create theme combo box
        themeComboBox = new KryptonThemeComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList,
            Width = 150
        };

        // Add to status strip
        statusStrip = new KryptonStatusStrip();
        statusStrip.Items.Add(new ToolStripSeparator());
        statusStrip.Items.Add(new ToolStripLabel("Theme:"));
        statusStrip.Items.Add(new ToolStripControlHost(themeComboBox));

        Controls.Add(statusStrip);
    }
}
```

### Configuration Panel Integration

```csharp
public class ConfigurationPanel : UserControl
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonHeaderGroup appearanceGroup;

    public ConfigurationPanel()
    {
        InitializeComponent();
        SetupAppearanceSection();
    }

    private void SetupAppearanceSection()
    {
        // Appearance group
        appearanceGroup = new KryptonHeaderGroup
        {
            Dock = DockStyle.Fill,
            HeaderStylePrimary = HeaderStyle.Panel
        };
        appearanceGroup.HeaderPrimary.Content.ShortText = "Appearance";

        // Theme selection
        var themeLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 1,
            Dock = DockStyle.Fill
        };

        var themeLabel = new KryptonLabel
        {
            Text = "Theme:",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        themeComboBox = new KryptonThemeComboBox
        {
            Dock = DockStyle.Fill,
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        themeLayout.Controls.Add(themeLabel, 0, 0);
        themeLayout.Controls.Add(themeComboBox, 1, 0);

        appearanceGroup.Panel.Controls.Add(themeLayout);
        Controls.Add(appearanceGroup);
    }
}
```

### Dynamic Theme Switching

```csharp
public class DynamicThemeSwitcher : UserControl
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonButton applyButton;
    private KryptonButton previewButton;
    private Form previewForm;

    public DynamicThemeSwitcher()
    {
        InitializeComponent();
        SetupThemeSwitcher();
    }

    private void SetupThemeSwitcher()
    {
        themeComboBox = new KryptonThemeComboBox
        {
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        applyButton = new KryptonButton
        {
            Text = "Apply Theme"
        };

        previewButton = new KryptonButton
        {
            Text = "Preview Theme"
        };

        // Event handlers
        applyButton.Click += OnApplyButtonClick;
        previewButton.Click += OnPreviewButtonClick;

        // Layout
        var layout = new KryptonTableLayoutPanel
        {
            ColumnCount = 3,
            RowCount = 1,
            Dock = DockStyle.Fill
        };

        layout.Controls.Add(themeComboBox, 0, 0);
        layout.Controls.Add(previewButton, 1, 0);
        layout.Controls.Add(applyButton, 2, 0);

        Controls.Add(layout);
    }

    private void OnApplyButtonClick(object? sender, EventArgs e)
    {
        // Theme is automatically applied by KryptonThemeComboBox
        MessageBox.Show("Theme applied to all open windows!", "Theme Applied", 
            MessageBoxButtons.OK, MessageBoxIcon.Information);
    }

    private void OnPreviewButtonClick(object? sender, EventArgs e)
    {
        ShowThemePreview();
    }

    private void ShowThemePreview()
    {
        if (previewForm == null || previewForm.IsDisposed)
        {
            previewForm = new Form
            {
                Text = "Theme Preview",
                Size = new Size(400, 300),
                StartPosition = FormStartPosition.CenterParent
            };

            // Add sample controls to preview form
            var samplePanel = new KryptonPanel
            {
                Dock = DockStyle.Fill,
                PanelBackStyle = PaletteBackStyle.PanelClient
            };

            var sampleButton = new KryptonButton
            {
                Text = "Sample Button",
                Location = new Point(50, 50)
            };

            var sampleLabel = new KryptonLabel
            {
                Text = "Sample Label",
                Location = new Point(50, 100)
            };

            samplePanel.Controls.Add(sampleButton);
            samplePanel.Controls.Add(sampleLabel);
            previewForm.Controls.Add(samplePanel);
        }

        previewForm.ShowDialog(this);
    }
}
```

## Performance Considerations

- **Theme Synchronization**: Efficient synchronization with global palette changes
- **Event Handling**: Optimized event handling to prevent unnecessary updates
- **Memory Management**: Proper disposal of local KryptonManager instance
- **Theme Loading**: Efficient theme array loading and population

## Common Issues and Solutions

### Theme Not Updating

**Issue**: Selected theme not applying to the application  
**Solution**: Ensure proper event handling and synchronization:

```csharp
themeComboBox.SelectedIndexChanged += (sender, e) =>
{
    // Theme is automatically applied by the control
    // No additional code needed
};
```

### Custom Palette Issues

**Issue**: Custom palette not working with deprecated property  
**Solution**: Use the new ThemeManager approach:

```csharp
// Old way (deprecated)
// themeComboBox.KryptonCustomPalette = customPalette;

// New way
ThemeManager.ApplyTheme(customPalette);
```

### Selection Not Synchronized

**Issue**: ComboBox selection not synchronized with global palette  
**Solution**: Ensure proper initialization and event handling:

```csharp
// The control automatically synchronizes with global palette changes
// Make sure the control is properly initialized
var themeComboBox = new KryptonThemeComboBox();
```

## Design-Time Integration

### Visual Studio Designer

- **Designer**: Uses `KryptonStubDesigner` for design-time support
- **Toolbox**: Available with custom bitmap representation
- **Property Window**: Theme-specific properties available
- **Theme Population**: Automatically populated with available themes

### Property Categories

- **Visuals**: Theme-related properties (`KryptonCustomPalette`, `DefaultPalette`)
- **Behavior**: Standard ComboBox behavior properties
- **Layout**: Standard layout properties

## Migration and Compatibility

### From Standard ComboBox

```csharp
// Old way
ComboBox themeComboBox = new ComboBox();
// Manual theme population and handling

// New way
KryptonThemeComboBox themeComboBox = new KryptonThemeComboBox();
// Automatic theme population and synchronization
```

### From Deprecated Custom Palette

```csharp
// Old way (deprecated)
themeComboBox.KryptonCustomPalette = customPalette;

// New way
ThemeManager.ApplyTheme(customPalette);
// Then use the theme combo box normally
```

## Real-World Integration Examples

### Application Settings Form

```csharp
public partial class ApplicationSettingsForm : Form
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonButton okButton;
    private KryptonButton cancelButton;

    public ApplicationSettingsForm()
    {
        InitializeComponent();
        SetupThemeSettings();
    }

    private void SetupThemeSettings()
    {
        // Theme selection section
        var themeGroup = new KryptonHeaderGroup
        {
            Dock = DockStyle.Fill,
            HeaderStylePrimary = HeaderStyle.Panel
        };
        themeGroup.HeaderPrimary.Content.ShortText = "Theme Settings";

        var themeLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 2,
            Dock = DockStyle.Fill,
            Padding = new Padding(10)
        };

        // Theme label
        var themeLabel = new KryptonLabel
        {
            Text = "Application Theme:",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        // Theme combo box
        themeComboBox = new KryptonThemeComboBox
        {
            Dock = DockStyle.Fill,
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        // Description label
        var descriptionLabel = new KryptonLabel
        {
            Text = "Select a theme for the application interface. Changes will be applied immediately.",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        // Add to layout
        themeLayout.Controls.Add(themeLabel, 0, 0);
        themeLayout.Controls.Add(themeComboBox, 1, 0);
        themeLayout.Controls.Add(descriptionLabel, 0, 1);
        themeLayout.SetColumnSpan(descriptionLabel, 2);

        themeGroup.Panel.Controls.Add(themeLayout);

        // Buttons
        okButton = new KryptonButton
        {
            Text = "OK",
            DialogResult = DialogResult.OK
        };

        cancelButton = new KryptonButton
        {
            Text = "Cancel",
            DialogResult = DialogResult.Cancel
        };

        // Main layout
        var mainLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 1,
            RowCount = 2,
            Dock = DockStyle.Fill
        };

        mainLayout.RowStyles.Add(new RowStyle(SizeType.Percent, 100F));
        mainLayout.RowStyles.Add(new RowStyle(SizeType.Absolute, 40F));

        mainLayout.Controls.Add(themeGroup, 0, 0);
        
        var buttonLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 1,
            Dock = DockStyle.Fill
        };

        buttonLayout.Controls.Add(okButton, 0, 0);
        buttonLayout.Controls.Add(cancelButton, 1, 0);

        mainLayout.Controls.Add(buttonLayout, 0, 1);

        Controls.Add(mainLayout);
    }
}
```

### Welcome Wizard Theme Selection

```csharp
public class WelcomeWizardThemeStep : UserControl
{
    private KryptonThemeComboBox themeComboBox;
    private KryptonLabel descriptionLabel;
    private KryptonPanel previewPanel;

    public WelcomeWizardThemeStep()
    {
        InitializeComponent();
        SetupThemeSelectionStep();
    }

    private void SetupThemeSelectionStep()
    {
        // Description
        descriptionLabel = new KryptonLabel
        {
            Text = "Choose a theme that best suits your preferences. You can change this later in settings.",
            Dock = DockStyle.Top,
            LabelStyle = LabelStyle.TitlePanel,
            TextAlign = ContentAlignment.MiddleCenter
        };

        // Theme selection
        var themeLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 2,
            RowCount = 1,
            Dock = DockStyle.Top
        };

        var themeLabel = new KryptonLabel
        {
            Text = "Theme:",
            Dock = DockStyle.Fill,
            LabelStyle = LabelStyle.NormalControl
        };

        themeComboBox = new KryptonThemeComboBox
        {
            Dock = DockStyle.Fill,
            DropDownStyle = ComboBoxStyle.DropDownList
        };

        themeLayout.Controls.Add(themeLabel, 0, 0);
        themeLayout.Controls.Add(themeComboBox, 1, 0);

        // Preview panel
        previewPanel = new KryptonPanel
        {
            Dock = DockStyle.Fill,
            PanelBackStyle = PaletteBackStyle.PanelClient
        };

        // Add sample controls to preview
        var sampleButton = new KryptonButton
        {
            Text = "Sample Button",
            Location = new Point(50, 50)
        };

        var sampleLabel = new KryptonLabel
        {
            Text = "Sample Label",
            Location = new Point(50, 100)
        };

        previewPanel.Controls.Add(sampleButton);
        previewPanel.Controls.Add(sampleLabel);

        // Main layout
        var mainLayout = new KryptonTableLayoutPanel
        {
            ColumnCount = 1,
            RowCount = 3,
            Dock = DockStyle.Fill
        };

        mainLayout.Controls.Add(descriptionLabel, 0, 0);
        mainLayout.Controls.Add(themeLayout, 0, 1);
        mainLayout.Controls.Add(previewPanel, 0, 2);

        Controls.Add(mainLayout);
    }
}
```