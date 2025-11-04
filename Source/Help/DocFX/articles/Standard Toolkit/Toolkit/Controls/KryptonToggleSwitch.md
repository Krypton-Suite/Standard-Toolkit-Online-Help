# KryptonToggleSwitch

## Overview

`KryptonToggleSwitch` is a modern toggle switch control with smooth animations, gradient effects, and full Krypton palette integration. It provides an iOS/Android-style toggle switch that fits seamlessly into the Krypton design system with extensive customization options.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `KryptonToggleSwitch`  
**Implements:** `IContentValues`

## Key Features

### Modern Toggle Interface
- Smooth animated transitions
- Draggable knob support
- iOS/Android-style appearance
- Keyboard navigation support

### Visual Effects
- Gradient knob rendering
- Emboss shadow effects
- Customizable corner rounding
- On/Off text labels

### Palette Integration
- Full Krypton theme support
- State-based styling (Normal, Tracking, Pressed, Disabled)
- Theme color extraction
- Custom color overrides

### Animation
- Smooth knob sliding animation
- Gradient color transitions
- Configurable animation speed
- High-quality rendering (anti-aliasing)

---

## Constructor

### KryptonToggleSwitch()

Initializes a new instance of the KryptonToggleSwitch class.

```csharp
public KryptonToggleSwitch()
```

**Default Settings:**
- `Checked` = `false`
- `Size` = `90 x 28` (adjusts based on padding)
- Double buffered rendering enabled
- Transparent background
- Tab stop enabled
- Default animation interval: 15ms

---

## Properties

### Core Properties

#### Checked
Gets or sets whether the toggle switch is in the ON position.

```csharp
[Category("Behavior")]
[Description("Indicates whether the toggle switch is checked.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool Checked { get; set; }
```

**Default:** `false`

**Example:**
```csharp
kryptonToggleSwitch1.Checked = true; // Turn ON
kryptonToggleSwitch1.Checked = false; // Turn OFF

// Toggle
kryptonToggleSwitch1.Checked = !kryptonToggleSwitch1.Checked;
```

---

### Appearance States

#### StateCommon
Gets access to common appearance settings that other states can override.

```csharp
[Category("Visuals")]
[Description("Defines the common appearance settings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect StateCommon { get; }
```

**Example:**
```csharp
kryptonToggleSwitch1.StateCommon.Back.Color1 = Color.LightGray;
kryptonToggleSwitch1.StateCommon.Border.Width = 2;
kryptonToggleSwitch1.StateCommon.Border.Rounding = 15;
```

---

#### StateNormal
Gets access to normal state appearance settings.

```csharp
[Category("Visuals")]
[Description("Defines the normal appearance settings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateNormal { get; }
```

---

#### StateTracking
Gets access to tracking (hover) state appearance settings.

```csharp
[Category("Visuals")]
[Description("Defines the tracking appearance settings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateTracking { get; }
```

**Remarks:**
- Applied when mouse hovers over the control

---

#### StatePressed
Gets access to pressed state appearance settings.

```csharp
[Category("Visuals")]
[Description("Defines the pressed appearance settings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StatePressed { get; }
```

---

#### StateDisabled
Gets access to disabled state appearance settings.

```csharp
[Category("Visuals")]
[Description("Defines the disabled appearance settings.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateDisabled { get; }
```

---

### Toggle Switch Customization

#### ToggleSwitchValues
Gets or sets the toggle switch visual customization options.

```csharp
[Category("Visuals")]
[Description("Visual customization options for the toggle switch.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ToggleSwitchValues ToggleSwitchValues { get; set; }
```

**Properties Available in ToggleSwitchValues:**

##### OnColor / OffColor
Sets the color for ON and OFF states when not using theme colors.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.OnColor = Color.Green;
kryptonToggleSwitch1.ToggleSwitchValues.OffColor = Color.Red;
```

##### UseThemeColors
Determines whether to use colors from the current theme.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.UseThemeColors = true;
```

##### EnableKnobGradient
Enables gradient rendering on the knob.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.EnableKnobGradient = true;
```

##### GradientDirection
Sets the gradient direction when gradient is enabled.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.GradientDirection = LinearGradientMode.Vertical;
```

##### ShowText
Determines whether to show ON/OFF text labels.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.ShowText = true;
```

##### OnlyShowColorOnKnob
When true, only the knob shows color; background remains theme-colored.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.OnlyShowColorOnKnob = true;
```

##### EnableEmbossEffect
Enables a shadow/emboss effect for depth.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.EnableEmbossEffect = true;
```

##### CornerRadius
Sets the corner rounding radius.

```csharp
kryptonToggleSwitch1.ToggleSwitchValues.CornerRadius = 20;
```

---

### Hidden Properties

The following base Control properties are hidden as they're not applicable:

- `BackColor` - Use palette settings instead
- `ForeColor` - Use palette settings instead
- `Font` - Use palette settings instead
- `Text` - ON/OFF text is shown internally
- `BackgroundImage` - Not supported
- `RightToLeft` - Hidden but functional

---

## Methods

### ResetToggleSwitchValues()
Resets the ToggleSwitchValues property to default values.

```csharp
public void ResetToggleSwitchValues()
```

**Example:**
```csharp
kryptonToggleSwitch1.ResetToggleSwitchValues(); // Reset all customizations
```

---

## Events

### CheckedChanged
Occurs when the value of the Checked property changes.

```csharp
[Description("Occurs when the value of the Checked property changes.")]
public event EventHandler CheckedChanged
```

**Example:**
```csharp
kryptonToggleSwitch1.CheckedChanged += (s, e) =>
{
    if (kryptonToggleSwitch1.Checked)
    {
        StartService();
    }
    else
    {
        StopService();
    }
};
```

---

## Usage Examples

### Basic Toggle Switch

```csharp
var toggle = new KryptonToggleSwitch
{
    Location = new Point(20, 20),
    Size = new Size(90, 30)
};

toggle.CheckedChanged += (s, e) =>
{
    label1.Text = toggle.Checked ? "ON" : "OFF";
};

this.Controls.Add(toggle);
```

---

### Custom Colors

```csharp
var toggle = new KryptonToggleSwitch
{
    Location = new Point(20, 20)
};

// Use custom colors instead of theme colors
toggle.ToggleSwitchValues.UseThemeColors = false;
toggle.ToggleSwitchValues.OnColor = Color.LimeGreen;
toggle.ToggleSwitchValues.OffColor = Color.Crimson;
toggle.ToggleSwitchValues.EnableKnobGradient = false;
toggle.ToggleSwitchValues.ShowText = true;
```

---

### Gradient Knob

```csharp
var toggle = new KryptonToggleSwitch();

// Enable gradient effect
toggle.ToggleSwitchValues.EnableKnobGradient = true;
toggle.ToggleSwitchValues.GradientDirection = LinearGradientMode.Vertical;
toggle.ToggleSwitchValues.UseThemeColors = true; // Use theme colors for gradient
```

---

### Embossed Toggle

```csharp
var toggle = new KryptonToggleSwitch
{
    Size = new Size(100, 35)
};

// Add depth with emboss effect
toggle.ToggleSwitchValues.EnableEmbossEffect = true;
toggle.ToggleSwitchValues.CornerRadius = 17;

// Custom background
toggle.StateNormal.Back.Color1 = Color.WhiteSmoke;
toggle.StateNormal.Border.Color1 = Color.Gray;
toggle.StateNormal.Border.Width = 1;
```

---

### Settings Toggle Bank

```csharp
public class SettingsPanel : KryptonPanel
{
    public SettingsPanel()
    {
        CreateToggle("Enable Notifications", 20, (sender, e) => 
        {
            if (sender is KryptonToggleSwitch toggle)
                EnableNotifications(toggle.Checked);
        });
        
        CreateToggle("Auto-Save", 60, (sender, e) => 
        {
            if (sender is KryptonToggleSwitch toggle)
                EnableAutoSave(toggle.Checked);
        });
        
        CreateToggle("Dark Mode", 100, (sender, e) => 
        {
            if (sender is KryptonToggleSwitch toggle)
                ApplyDarkMode(toggle.Checked);
        });
    }
    
    private void CreateToggle(string labelText, int y, EventHandler handler)
    {
        var label = new KryptonLabel
        {
            Text = labelText,
            Location = new Point(20, y + 5),
            AutoSize = true
        };
        
        var toggle = new KryptonToggleSwitch
        {
            Location = new Point(200, y)
        };
        
        toggle.CheckedChanged += handler;
        
        Controls.Add(label);
        Controls.Add(toggle);
    }
}
```

---

### Binding to Properties

```csharp
public class Settings
{
    public bool NotificationsEnabled { get; set; }
}

// Bind toggle to property
var settings = new Settings();
var toggle = new KryptonToggleSwitch();

// Set initial state
toggle.Checked = settings.NotificationsEnabled;

// Update property when toggled
toggle.CheckedChanged += (s, e) =>
{
    settings.NotificationsEnabled = toggle.Checked;
    SaveSettings(settings);
};
```

---

### Master/Detail Toggles

```csharp
var masterToggle = new KryptonToggleSwitch
{
    Location = new Point(20, 20)
};

var detailToggle1 = new KryptonToggleSwitch
{
    Location = new Point(40, 60),
    Enabled = false
};

var detailToggle2 = new KryptonToggleSwitch
{
    Location = new Point(40, 100),
    Enabled = false
};

// Master controls details
masterToggle.CheckedChanged += (s, e) =>
{
    bool enabled = masterToggle.Checked;
    detailToggle1.Enabled = enabled;
    detailToggle2.Enabled = enabled;
    
    if (!enabled)
    {
        detailToggle1.Checked = false;
        detailToggle2.Checked = false;
    }
};
```

---

### Confirmation Dialog

```csharp
private void ShowToggleConfirmation(KryptonToggleSwitch toggle)
{
    toggle.CheckedChanged += (s, e) =>
    {
        if (toggle.Checked)
        {
            var result = MessageBox.Show(
                "Are you sure you want to enable this feature?",
                "Confirm",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            
            if (result == DialogResult.No)
            {
                // Revert without triggering event again
                toggle.CheckedChanged -= null; // Temporarily unhook
                toggle.Checked = false;
                // Re-hook event
            }
        }
    };
}
```

---

### Themed Toggle

```csharp
// Toggle that automatically matches the current theme
var themedToggle = new KryptonToggleSwitch();

// Use theme colors for everything
themedToggle.ToggleSwitchValues.UseThemeColors = true;
themedToggle.ToggleSwitchValues.EnableKnobGradient = true;
themedToggle.ToggleSwitchValues.ShowText = true;

// Background matches control backgrounds
themedToggle.StateNormal.Back.Color1 = Color.Transparent;
```

---

### Animated State Indicator

```csharp
public class StatusIndicator : UserControl
{
    private KryptonToggleSwitch toggle;
    private KryptonLabel statusLabel;
    private Timer blinkTimer;
    
    public StatusIndicator()
    {
        toggle = new KryptonToggleSwitch
        {
            Location = new Point(10, 10),
            Enabled = false // Read-only indicator
        };
        
        statusLabel = new KryptonLabel
        {
            Location = new Point(110, 15),
            AutoSize = true
        };
        
        blinkTimer = new Timer { Interval = 500 };
        blinkTimer.Tick += (s, e) =>
        {
            statusLabel.Visible = !statusLabel.Visible;
        };
        
        Controls.Add(toggle);
        Controls.Add(statusLabel);
    }
    
    public void SetStatus(bool active, string message)
    {
        toggle.Checked = active;
        statusLabel.Text = message;
        
        if (active)
        {
            statusLabel.StateCommon.ShortText.Color1 = Color.Green;
            blinkTimer.Stop();
            statusLabel.Visible = true;
        }
        else
        {
            statusLabel.StateCommon.ShortText.Color1 = Color.Red;
            blinkTimer.Start();
        }
    }
}
```

---

### Keyboard Navigation

```csharp
// Toggle responds to keyboard input
var toggle = new KryptonToggleSwitch
{
    TabStop = true,
    TabIndex = 0
};

// Supported keys:
// - Space, Enter: Toggle
// - Left/Right: Toggle
// - Home: Set to OFF
// - End: Set to ON
// - Tab: Navigate to next control
// - +/-: Toggle
// - PageUp/PageDown: Toggle
```

---

## Design Considerations

### Animation System

The control uses a timer-based animation system:

1. **Smooth Transitions:** Lerp interpolation for smooth motion
2. **Frame Rate:** 15ms interval (~66 FPS)
3. **Gradient Animation:** Color interpolation during state changes
4. **Performance:** Optimized invalidation regions

---

### Rendering Pipeline

```
OnPaint
  ├─ Set graphics quality (AntiAlias, HighQuality)
  ├─ Determine current state (Normal/Tracking/Pressed/Disabled)
  ├─ Draw emboss effect (if enabled)
  ├─ Draw background with rounded corners
  ├─ Draw border
  ├─ Draw knob (solid or gradient)
  └─ Draw ON/OFF text (if enabled)
```

---

### State Resolution

The control determines its visual state in this order:

1. **Disabled** - Control is disabled
2. **Pressed** - Mouse button down (currently not used for toggle)
3. **Tracking** - Mouse hovering over control
4. **Normal** - Default state

---

### Performance Tips

1. **Reduce Repaints:** Animation only invalidates knob region
2. **Graphics Quality:** High-quality rendering uses more CPU
3. **Emboss Effect:** Adds slight overhead when enabled
4. **Gradient Rendering:** More expensive than solid colors

---

## Common Scenarios

### Enable/Disable Features

```csharp
private void SetupFeatureToggles()
{
    var autoSaveToggle = new KryptonToggleSwitch();
    autoSaveToggle.CheckedChanged += (s, e) =>
    {
        autoSaveTimer.Enabled = autoSaveToggle.Checked;
    };
    
    var spellCheckToggle = new KryptonToggleSwitch();
    spellCheckToggle.CheckedChanged += (s, e) =>
    {
        textEditor.SpellCheck = spellCheckToggle.Checked;
    };
}
```

---

### Wizard Navigation

```csharp
public class WizardPage
{
    private KryptonToggleSwitch agreeToggle;
    private KryptonButton nextButton;
    
    public WizardPage()
    {
        agreeToggle = new KryptonToggleSwitch();
        nextButton = new KryptonButton { Enabled = false };
        
        agreeToggle.CheckedChanged += (s, e) =>
        {
            nextButton.Enabled = agreeToggle.Checked;
        };
    }
}
```

---

### Dashboard Controls

```csharp
public class DashboardPanel : KryptonPanel
{
    public DashboardPanel()
    {
        // System controls
        AddToggle("System Power", 0, SystemPowerToggled);
        AddToggle("WiFi", 50, WiFiToggled);
        AddToggle("Bluetooth", 100, BluetoothToggled);
        AddToggle("Airplane Mode", 150, AirplaneModeToggled);
    }
    
    private void AddToggle(string text, int y, EventHandler handler)
    {
        var panel = new KryptonPanel
        {
            Location = new Point(0, y),
            Size = new Size(Width, 40)
        };
        
        var label = new KryptonLabel
        {
            Text = text,
            Location = new Point(10, 10),
            AutoSize = true
        };
        
        var toggle = new KryptonToggleSwitch
        {
            Location = new Point(Width - 110, 5)
        };
        
        toggle.CheckedChanged += handler;
        
        panel.Controls.Add(label);
        panel.Controls.Add(toggle);
        Controls.Add(panel);
    }
}
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** Krypton.Toolkit core components
- **Rendering:** Requires GDI+ (System.Drawing)

---

## Known Limitations

1. **Drag Support:** Knob drag code present but toggle-on-click overrides it
2. **IContentValues:** Interface implemented but methods throw NotImplementedException
3. **Text Customization:** ON/OFF text uses KryptonManager strings (not customizable per control)
4. **Size Constraints:** Minimum size enforced (50x20) but may clip content if too small

---

## Comparison with Alternatives

### vs CheckBox

**KryptonToggleSwitch:**
- ✅ Modern appearance
- ✅ Animated transitions
- ✅ Clear ON/OFF indication
- ❌ Takes more space

**KryptonCheckBox:**
- ✅ Traditional and familiar
- ✅ Compact
- ✅ Three-state support
- ❌ Less visually distinctive

---

### vs RadioButton

Use **ToggleSwitch** for:
- Single ON/OFF options
- Feature enable/disable
- Binary choices with clear states

Use **RadioButton** for:
- Multiple mutually exclusive options
- Selection from a set of choices

---

## See Also

- [KryptonCheckBox](KryptonCheckBox.md) - Traditional checkbox control
- [KryptonRadioButton](KryptonRadioButton.md) - Radio button control
- [PaletteTriple](../Palette/PaletteTriple.md) - Triple palette settings
- [ToggleSwitchValues](../Values/ToggleSwitchValues.md) - Customization values class