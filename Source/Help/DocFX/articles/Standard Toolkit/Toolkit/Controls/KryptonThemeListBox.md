# KryptonThemeListBox

## Overview

`KryptonThemeListBox` is a specialized `KryptonListBox` that automatically populates with available Krypton themes and handles theme switching. It provides a simple, drop-in solution for adding theme selection to your application with minimal code.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → ... → `ListBox` → `KryptonListBox` → `KryptonThemeListBox`  
**Implements:** `IKryptonThemeSelectorBase`

## Key Features

### Automatic Theme Management
- Auto-populates with all available Krypton themes
- Handles theme switching automatically
- Synchronizes with global palette changes
- No manual theme list management required

### Seamless Integration
- Responds to external theme changes
- Updates selection when theme changes programmatically
- Coordinates with ThemeChangeCoordinator
- Prevents circular update loops

### Built-in Themes
- Professional System themes
- Office 2003, 2007, 2010, 2013 themes
- Office 365 variants
- Sparkle themes
- Custom theme support

---

## Constructor

### KryptonThemeListBox()

Initializes a new instance with all available themes.

```csharp
public KryptonThemeListBox()
```

**Initialization:**
- Populates Items with all available themes
- Sets initial selection based on current global palette
- Attaches to global palette change events

---

## Properties

### DefaultPalette
Gets or sets the default palette mode.

```csharp
[Category("Visuals")]
[Description("The default palette mode.")]
[DefaultValue(PaletteMode.Global)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public PaletteMode DefaultPalette { get; set; }
```

**Default:** `PaletteMode.Global`

**Remarks:**
- Sets the initial theme when control is first created
- Automatically selects corresponding item in list

**Example:**
```csharp
kryptonThemeListBox1.DefaultPalette = PaletteMode.Office2010Blue;
```

---

### KryptonCustomPalette
Gets or sets the custom assigned palette.

```csharp
[Category("Visuals")]
[Description("The custom assigned palette mode.")]
[DefaultValue(null)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
[Obsolete("Deprecated and will be removed in V110. Set a global custom palette through 'ThemeManager.ApplyTheme(...)'.")]
public KryptonCustomPaletteBase? KryptonCustomPalette { get; set; }
```

**Remarks:**
- Deprecated - use ThemeManager.ApplyTheme() instead
- Will be removed in version 110
- Provided for backward compatibility only

---

### Hidden Properties

The following base properties are hidden as they're managed automatically:

#### Items
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new ListBox.ObjectCollection Items { get; }
```

**Remarks:**
- Automatically populated with theme names
- Should not be modified manually
- Read-only at design time

---

#### SelectedIndex
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new int SelectedIndex { get; set; }
```

**Remarks:**
- Managed automatically by theme selection
- Reflects current active theme

---

#### Text
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public override string Text { get; set; }
```

---

#### FormatString
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new string FormatString { get; set; }
```

---

## Methods

### ResetDefaultPalette()
Resets the DefaultPalette property to its default value.

```csharp
public void ResetDefaultPalette()
```

**Example:**
```csharp
kryptonThemeListBox1.ResetDefaultPalette(); // Sets to PaletteMode.Global
```

---

### ShouldSerializeDefaultPalette()
Determines whether the DefaultPalette property should be serialized.

```csharp
private bool ShouldSerializeDefaultPalette()
```

---

## Events

### SelectedIndexChanged
Occurs when the selected theme changes.

```csharp
protected override void OnSelectedIndexChanged(EventArgs e)
```

**Remarks:**
- Automatically applies the selected theme
- Updates global palette
- Prevents circular updates from external theme changes

**Example:**
```csharp
kryptonThemeListBox1.SelectedIndexChanged += (s, e) =>
{
    string themeName = kryptonThemeListBox1.SelectedItem?.ToString() ?? "Unknown";
    statusLabel.Text = $"Theme changed to: {themeName}";
};
```

---

## Usage Examples

### Basic Theme Selector

```csharp
// Simply add the control - it's ready to use!
var themeSelector = new KryptonThemeListBox
{
    Dock = DockStyle.Left,
    Width = 200
};

this.Controls.Add(themeSelector);

// Theme changes automatically when user selects an item
```

---

### With Default Theme

```csharp
var themeSelector = new KryptonThemeListBox
{
    DefaultPalette = PaletteMode.Office2010Blue,
    Location = new Point(10, 10),
    Size = new Size(180, 300)
};

// Control will start with Office 2010 Blue selected
this.Controls.Add(themeSelector);
```

---

### Theme Selector Panel

```csharp
var panel = new KryptonPanel
{
    Dock = DockStyle.Left,
    Width = 200
};

var label = new KryptonLabel
{
    Text = "Select Theme:",
    Location = new Point(10, 10),
    AutoSize = true
};

var themeSelector = new KryptonThemeListBox
{
    Location = new Point(10, 35),
    Size = new Size(180, 400)
};

panel.Controls.Add(label);
panel.Controls.Add(themeSelector);
this.Controls.Add(panel);
```

---

### Remember User's Theme Choice

```csharp
public partial class MainForm : Form
{
    private void MainForm_Load(object sender, EventArgs e)
    {
        // Load saved theme preference
        string savedTheme = Properties.Settings.Default.SelectedTheme;
        
        if (!string.IsNullOrEmpty(savedTheme))
        {
            for (int i = 0; i < kryptonThemeListBox1.Items.Count; i++)
            {
                if (kryptonThemeListBox1.Items[i].ToString() == savedTheme)
                {
                    kryptonThemeListBox1.SelectedIndex = i;
                    break;
                }
            }
        }
    }
    
    private void kryptonThemeListBox1_SelectedIndexChanged(object sender, EventArgs e)
    {
        // Save theme preference
        string selectedTheme = kryptonThemeListBox1.SelectedItem?.ToString() ?? string.Empty;
        Properties.Settings.Default.SelectedTheme = selectedTheme;
        Properties.Settings.Default.Save();
    }
}
```

---

### Settings Dialog Integration

```csharp
public class SettingsDialog : KryptonForm
{
    private KryptonThemeListBox themeSelector;
    private KryptonButton okButton;
    private KryptonButton cancelButton;
    
    public SettingsDialog()
    {
        InitializeComponent();
        
        themeSelector = new KryptonThemeListBox
        {
            Location = new Point(20, 50),
            Size = new Size(200, 300)
        };
        
        var label = new KryptonLabel
        {
            Text = "Application Theme:",
            Location = new Point(20, 20),
            AutoSize = true
        };
        
        okButton = new KryptonButton
        {
            Text = "OK",
            Location = new Point(20, 370),
            DialogResult = DialogResult.OK
        };
        
        cancelButton = new KryptonButton
        {
            Text = "Cancel",
            Location = new Point(120, 370),
            DialogResult = DialogResult.Cancel
        };
        
        Controls.AddRange(new Control[] { label, themeSelector, okButton, cancelButton });
        
        AcceptButton = okButton;
        CancelButton = cancelButton;
    }
}

// Usage:
using (var dialog = new SettingsDialog())
{
    if (dialog.ShowDialog() == DialogResult.OK)
    {
        // Theme already applied by themeSelector
    }
}
```

---

### Live Preview

```csharp
private PaletteMode _originalTheme;

private void ShowThemePreview()
{
    var previewForm = new KryptonForm
    {
        Text = "Theme Preview",
        Size = new Size(800, 600)
    };
    
    var themeSelector = new KryptonThemeListBox
    {
        Dock = DockStyle.Left,
        Width = 200
    };
    
    var previewPanel = new KryptonPanel
    {
        Dock = DockStyle.Fill
    };
    
    // Add sample controls to preview panel
    previewPanel.Controls.Add(new KryptonButton { Text = "Sample Button", Location = new Point(20, 20) });
    previewPanel.Controls.Add(new KryptonTextBox { Location = new Point(20, 60), Width = 200 });
    previewPanel.Controls.Add(new KryptonCheckBox { Text = "Sample Checkbox", Location = new Point(20, 100) });
    
    previewForm.Controls.Add(previewPanel);
    previewForm.Controls.Add(themeSelector);
    
    // Store original theme
    _originalTheme = KryptonManager.CurrentGlobalPaletteMode;
    
    previewForm.FormClosing += (s, e) =>
    {
        // Restore if cancelled
        if (previewForm.DialogResult != DialogResult.OK)
        {
            KryptonManager.CurrentGlobalPaletteMode = _originalTheme;
        }
    };
    
    previewForm.ShowDialog();
}
```

---

### Multi-Form Theme Synchronization

```csharp
// Theme selector in one form automatically updates all open forms
public class ThemeManagerForm : KryptonForm
{
    public ThemeManagerForm()
    {
        var themeSelector = new KryptonThemeListBox
        {
            Dock = DockStyle.Fill
        };
        
        themeSelector.SelectedIndexChanged += (s, e) =>
        {
            // All forms using the global palette will update automatically
            string theme = themeSelector.SelectedItem?.ToString() ?? "None";
            
            // Optionally notify other forms
            foreach (Form form in Application.OpenForms)
            {
                if (form is IThemeAware themeAware)
                {
                    themeAware.OnThemeChanged(theme);
                }
            }
        };
        
        Controls.Add(themeSelector);
    }
}
```

---

### Filtered Theme List

```csharp
// While Items is hidden, you can still access it programmatically
public class CustomThemeSelector : KryptonThemeListBox
{
    public CustomThemeSelector()
    {
        // Remove themes you don't want to show
        // Note: This requires accessing the internal Items collection
    }
    
    protected override void OnHandleCreated(EventArgs e)
    {
        base.OnHandleCreated(e);
        
        // Filter out old themes
        var itemsToRemove = new List<object>();
        foreach (var item in Items)
        {
            string itemText = item.ToString() ?? string.Empty;
            if (itemText.Contains("2003") || itemText.Contains("2007"))
            {
                itemsToRemove.Add(item);
            }
        }
        
        foreach (var item in itemsToRemove)
        {
            Items.Remove(item);
        }
    }
}
```

---

## Design Considerations

### Automatic Updates

The control automatically handles:
1. **Initial Population:** Themes are loaded on construction
2. **External Changes:** Selection updates when theme changes from code
3. **User Selection:** Theme applies when user selects an item
4. **Circular Prevention:** Prevents update loops using internal flags

---

### Update Flow

```
User Selection → SelectedIndexChanged → Apply Theme → Global Palette Changed
                                                      ↓
                                                   Update Selection (suppressed)
```

External Change → Global Palette Changed → Update Selection → (no theme apply)

---

### Performance Considerations

1. **Theme Changes:** Applied immediately - may cause brief UI updates across all forms
2. **Synchronization:** Uses BeginInvoke for thread-safe updates during theme coordination
3. **Handle Creation:** Defers event attachment until handle is created

---

## Common Scenarios

### Settings Panel

```csharp
public class SettingsPanel : UserControl
{
    private KryptonThemeListBox themeSelector;
    
    public SettingsPanel()
    {
        var groupBox = new KryptonGroupBox
        {
            Dock = DockStyle.Fill,
            Text = "Appearance"
        };
        
        themeSelector = new KryptonThemeListBox
        {
            Dock = DockStyle.Fill
        };
        
        groupBox.Panel.Controls.Add(themeSelector);
        Controls.Add(groupBox);
    }
}
```

---

### Toolbar Theme Switcher

```csharp
// Create a compact dropdown version
public class ThemeToolbarButton : ToolStripDropDownButton
{
    private KryptonThemeListBox themeList;
    private ToolStripControlHost host;
    
    public ThemeToolbarButton()
    {
        Text = "Theme";
        
        themeList = new KryptonThemeListBox
        {
            BorderStyle = BorderStyle.None,
            IntegralHeight = true
        };
        
        host = new ToolStripControlHost(themeList)
        {
            AutoSize = false,
            Size = new Size(180, 300)
        };
        
        DropDownItems.Add(host);
        
        themeList.SelectedIndexChanged += (s, e) =>
        {
            Text = $"Theme: {themeList.SelectedItem}";
            HideDropDown();
        };
    }
}
```

---

### Startup Theme Selection

```csharp
public class SplashScreen : Form
{
    private KryptonThemeListBox themeSelector;
    
    public SplashScreen()
    {
        // Show theme selector on first run
        if (IsFirstRun())
        {
            ShowThemeSelection();
        }
    }
    
    private void ShowThemeSelection()
    {
        var label = new Label
        {
            Text = "Choose your preferred theme:",
            Dock = DockStyle.Top,
            Height = 30,
            TextAlign = ContentAlignment.MiddleCenter
        };
        
        themeSelector = new KryptonThemeListBox
        {
            Dock = DockStyle.Fill,
            DefaultPalette = PaletteMode.Office365Blue
        };
        
        var button = new Button
        {
            Text = "Continue",
            Dock = DockStyle.Bottom,
            Height = 40
        };
        
        button.Click += (s, e) =>
        {
            SaveSelectedTheme();
            Close();
        };
        
        Controls.Add(themeSelector);
        Controls.Add(label);
        Controls.Add(button);
    }
}
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** 
  - Krypton.Toolkit core components
  - CommonHelperThemeSelectors utility class
  - ThemeChangeCoordinator

---

## Comparison with Alternatives

### vs Manual ListBox Population

**KryptonThemeListBox:**
- ✅ Auto-populates themes
- ✅ Handles theme switching
- ✅ Synchronizes with external changes
- ✅ No code required

**Manual ListBox:**
- ❌ Must populate manually
- ❌ Must write switch/apply logic
- ❌ Must handle external sync
- ❌ Requires maintenance

---

### vs KryptonThemeComboBox

**ListBox:**
- ✅ Shows all themes at once
- ✅ Better for settings dialogs
- ✅ Easier theme browsing
- ❌ Takes more space

**ComboBox:**
- ✅ Compact dropdown
- ✅ Better for toolbars
- ✅ Saves space
- ❌ Requires clicking to see options

---

## Known Limitations

1. **Items Collection:** Hidden at design time - can't customize theme list via designer
2. **Custom Themes:** KryptonCustomPalette property is deprecated
3. **Theme Names:** Uses internal theme name strings - no localization support
4. **Order:** Themes appear in fixed order - can't reorder without subclassing

---

## Migration Notes

### From v100 to v110+

The `KryptonCustomPalette` property is deprecated:

**Old Code:**
```csharp
var customPalette = new KryptonPalette();
kryptonThemeListBox1.KryptonCustomPalette = customPalette;
```

**New Code:**
```csharp
ThemeManager.ApplyTheme("MyCustomTheme", customPalette);
// KryptonThemeListBox will automatically include the new theme
```

---

## See Also

- [KryptonThemeComboBox](KryptonThemeComboBox.md) - Dropdown variant
- [ThemeManager](../Core/ThemeManager.md) - Theme management system
- [PaletteMode Enumeration](../Enumerations/PaletteMode.md) - Available palette modes
- [IKryptonThemeSelectorBase](../Interfaces/IKryptonThemeSelectorBase.md) - Theme selector interface

---

## Remarks

### When to Use

**Use KryptonThemeListBox when:**
- Creating settings/preferences dialogs
- Building theme selection screens
- Allowing users to preview themes
- You have vertical space available

**Use alternatives when:**
- Space is limited (use KryptonThemeComboBox)
- Theme selection is rarely changed (use menu)
- You need custom theme filtering (subclass or use manual ListBox)