# Touchscreen Support Feature

## Overview

The Touchscreen Support feature provides a global mechanism to automatically scale Krypton controls to make them more suitable for touch interaction. When enabled, all Krypton controls are scaled by a configurable factor (default 1.25, representing a 25% size increase) to improve usability on touchscreen devices. **Both control sizes and text fonts are scaled**, ensuring that text remains readable and proportional to the larger controls.

This feature was introduced to address the growing prevalence of touchscreen devices, where standard-sized controls can be difficult to interact with using touch input.

## Table of Contents

- [Quick Start](#quick-start)
- [API Reference](#api-reference)
- [Usage Examples](#usage-examples)
- [Implementation Details](#implementation-details)
- [Best Practices](#best-practices)
- [Known Limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)

---

## Quick Start

### Enable Touchscreen Support

```csharp
// Enable with default 25% scaling (1.25x)
KryptonManager.GlobalTouchscreenSupport = true;
```

### Customize Scale Factor

```csharp
// Enable with custom 50% scaling (1.5x)
KryptonManager.GlobalTouchscreenSupport = true;
KryptonManager.GlobalTouchscreenScaleFactor = 1.5f;
```

### Using the TouchscreenSettings API (Recommended)

```csharp
// All touchscreen settings grouped together (designer-friendly)
KryptonManager.TouchscreenSettings.Enabled = true;
KryptonManager.TouchscreenSettings.ControlScaleFactor = 1.5f;
KryptonManager.TouchscreenSettings.FontScalingEnabled = true;
KryptonManager.TouchscreenSettings.FontScaleFactor = 1.25f;
```

### Disable Touchscreen Support

```csharp
// Disable to return controls to normal size
KryptonManager.GlobalTouchscreenSupport = false;
// Or using the new API:
KryptonManager.TouchscreenSettings.Enabled = false;
```

---

## API Reference

### KryptonManager Class

#### Static Properties

##### `UseTouchscreenSupport` (static)

Gets or sets the global flag that determines if touchscreen support is enabled.

**Type:** `bool`  
**Default:** `false`  

```csharp
public static bool UseTouchscreenSupport { get; set; }
```

**Remarks:**
- When set to `true`, all Krypton controls will be scaled according to the `TouchscreenScaleFactorValue`
- When set to `false`, controls return to their normal size
- Changing this value fires the `GlobalTouchscreenSupportChanged` event
- All controls automatically refresh when this value changes

**Example:**
```csharp
KryptonManager.UseTouchscreenSupport = true;
```

---

##### `TouchscreenScaleFactorValue` (static)

Gets or sets the global scale factor applied to controls when touchscreen support is enabled.

**Type:** `float`  
**Default:** `1.25f` (25% larger)  

```csharp
public static float TouchscreenScaleFactorValue { get; set; }
```

**Remarks:**
- Must be greater than 0
- A value of `1.25` means controls will be 25% larger
- A value of `1.5` means controls will be 50% larger
- A value of `1.0` means no scaling (same as disabled)
- Changing this value fires the `GlobalTouchscreenSupportChanged` event (only if touchscreen support is enabled)
- Uses epsilon comparison (0.001f) to avoid unnecessary updates

**Throws:**
- `ArgumentOutOfRangeException` if value is less than or equal to 0

**Example:**
```csharp
KryptonManager.TouchscreenScaleFactorValue = 1.5f; // 50% larger
```

---

##### `TouchscreenScaleFactor` (static, read-only)

Gets the effective touchscreen scale factor based on the current settings.

**Type:** `float`  
**Returns:** The configured scale factor when touchscreen support is enabled, otherwise `1.0f`

```csharp
public static float TouchscreenScaleFactor { get; }
```

**Remarks:**
- Returns `TouchscreenScaleFactorValue` when `UseTouchscreenSupport` is `true`
- Returns `1.0f` when `UseTouchscreenSupport` is `false`
- This is the value used internally by the layout system

**Example:**
```csharp
float currentScale = KryptonManager.TouchscreenScaleFactor;
// Returns 1.25 if enabled, 1.0 if disabled
```

---

#### Instance Properties (Designer Support)

##### `GlobalTouchscreenSupport`

Gets or sets a value indicating if touchscreen support is enabled, making controls larger based on the scale factor.

**Type:** `bool`  
**Default:** `false`  
**Category:** `Visuals`

```csharp
[Category(@"Visuals")]
[Description(@"Should touchscreen support be enabled, making controls larger for easier touch interaction.")]
[DefaultValue(false)]
public bool GlobalTouchscreenSupport { get; set; }
```

**Remarks:**
- This property wraps the static `UseTouchscreenSupport` property
- Provided for designer support and instance-based configuration

**Example:**
```csharp
// Via instance (designer-friendly)
kryptonManager1.GlobalTouchscreenSupport = true;

// Via static (programmatic)
KryptonManager.UseTouchscreenSupport = true;
```

---

##### `GlobalTouchscreenScaleFactor`

Gets or sets the scale factor applied to controls when touchscreen support is enabled.

**Type:** `float`  
**Default:** `1.25f`  
**Category:** `Visuals`

```csharp
[Category(@"Visuals")]
[Description(@"The scale factor applied to controls when touchscreen support is enabled. Default is 1.25 (25% larger).")]
[DefaultValue(1.25f)]
public float GlobalTouchscreenScaleFactor { get; set; }
```

**Remarks:**
- This property wraps the static `TouchscreenScaleFactorValue` property
- Provided for designer support and instance-based configuration
- Must be greater than 0

**Throws:**
- `ArgumentOutOfRangeException` if value is less than or equal to 0

**Example:**
```csharp
// Via instance (designer-friendly)
kryptonManager1.GlobalTouchscreenScaleFactor = 1.5f;

// Via static (programmatic)
KryptonManager.TouchscreenScaleFactorValue = 1.5f;
```

---

##### `GlobalTouchscreenFontScaling`

Gets or sets a value indicating if font scaling is enabled when touchscreen support is active.

**Type:** `bool`  
**Default:** `true`  
**Category:** `Visuals`

```csharp
[Category(@"Visuals")]
[Description(@"Should font scaling be enabled when touchscreen support is active.")]
[DefaultValue(true)]
public bool GlobalTouchscreenFontScaling { get; set; }
```

**Remarks:**
- This property wraps the static `UseTouchscreenFontScaling` property
- When enabled, fonts are scaled by the `GlobalTouchscreenFontScaleFactor` value
- Font scaling is independent of control scaling and can be disabled separately

**Example:**
```csharp
// Enable font scaling (default)
KryptonManager.GlobalTouchscreenFontScaling = true;

// Disable font scaling (only controls scale, not text)
KryptonManager.GlobalTouchscreenFontScaling = false;
```

---

##### `GlobalTouchscreenFontScaleFactor`

Gets or sets the scale factor applied to fonts when touchscreen support and font scaling are enabled.

**Type:** `float`  
**Default:** `1.25f`  
**Category:** `Visuals`

```csharp
[Category(@"Visuals")]
[Description(@"The scale factor applied to fonts when touchscreen support and font scaling are enabled. Default is 1.25 (25% larger).")]
[DefaultValue(1.25f)]
public float GlobalTouchscreenFontScaleFactor { get; set; }
```

**Remarks:**
- This property wraps the static `TouchscreenFontScaleFactorValue` property
- Must be greater than 0
- Can be set independently from control scaling

**Throws:**
- `ArgumentOutOfRangeException` if value is less than or equal to 0

**Example:**
```csharp
// Scale fonts by 30% (1.3x)
KryptonManager.GlobalTouchscreenFontScaleFactor = 1.3f;
```

---

##### `TouchscreenSettings`

Gets the touchscreen settings object that groups all touchscreen-related properties.

**Type:** `KryptonTouchscreenSettings`  
**Category:** `Visuals`

```csharp
[Category(@"Visuals")]
[Description(@"Touchscreen support settings.")]
[MergableProperty(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTouchscreenSettings TouchscreenSettings { get; }
```

**Remarks:**
- This property provides a convenient way to access all touchscreen settings in one place
- Appears as an expandable property in the Visual Studio designer
- All properties in this object map to the corresponding static properties in `KryptonManager`

**Example:**
```csharp
// Configure all touchscreen settings via the grouped API
KryptonManager.TouchscreenSettings.Enabled = true;
KryptonManager.TouchscreenSettings.ControlScaleFactor = 1.5f;
KryptonManager.TouchscreenSettings.FontScalingEnabled = true;
KryptonManager.TouchscreenSettings.FontScaleFactor = 1.3f;
```

---

#### Static Properties (Font Scaling)

##### `UseTouchscreenFontScaling` (static)

Gets or sets the global flag that determines if font scaling is enabled when touchscreen support is active.

**Type:** `bool`  
**Default:** `true`  

```csharp
public static bool UseTouchscreenFontScaling { get; set; }
```

**Remarks:**
- When set to `true`, fonts are scaled by `TouchscreenFontScaleFactorValue` when touchscreen support is enabled
- When set to `false`, fonts are not scaled even if touchscreen support is enabled
- Changing this value fires the `GlobalTouchscreenSupportChanged` event
- All controls automatically refresh when this value changes

**Example:**
```csharp
KryptonManager.UseTouchscreenFontScaling = true;
```

---

##### `TouchscreenFontScaleFactorValue` (static)

Gets or sets the global scale factor applied to fonts when touchscreen support and font scaling are enabled.

**Type:** `float`  
**Default:** `1.25f` (25% larger)  

```csharp
public static float TouchscreenFontScaleFactorValue { get; set; }
```

**Remarks:**
- Must be greater than 0
- A value of `1.25` means fonts will be 25% larger
- A value of `1.5` means fonts will be 50% larger
- A value of `1.0` means no font scaling
- Changing this value fires the `GlobalTouchscreenSupportChanged` event (only if touchscreen support and font scaling are enabled)
- Uses epsilon comparison (0.001f) to avoid unnecessary updates

**Throws:**
- `ArgumentOutOfRangeException` if value is less than or equal to 0

**Example:**
```csharp
KryptonManager.TouchscreenFontScaleFactorValue = 1.3f; // 30% larger fonts
```

---

##### `TouchscreenFontScaleFactor` (static, read-only)

Gets the effective font scale factor based on the current settings.

**Type:** `float`  
**Returns:** The configured font scale factor when touchscreen support and font scaling are enabled, otherwise `1.0f`

```csharp
public static float TouchscreenFontScaleFactor { get; }
```

**Remarks:**
- Returns `TouchscreenFontScaleFactorValue` when both `UseTouchscreenSupport` and `UseTouchscreenFontScaling` are `true`
- Returns `1.0f` when either touchscreen support or font scaling is disabled
- This is the value used internally by the font scaling system

**Example:**
```csharp
float currentFontScale = KryptonManager.TouchscreenFontScaleFactor;
// Returns 1.25 if both enabled, 1.0 if either disabled
```

---

#### Static Events

##### `GlobalTouchscreenSupportChanged`

Occurs when the touchscreen support setting or scale factor changes.

**Type:** `EventHandler`  
**Category:** `Property Changed`

```csharp
[Category(@"Property Changed")]
[Description(@"Occurs when the value of the GlobalTouchscreenSupport or GlobalTouchscreenScaleFactor property is changed.")]
public static event EventHandler? GlobalTouchscreenSupportChanged;
```

**Remarks:**
- Fires when `UseTouchscreenSupport` changes
- Fires when `TouchscreenScaleFactorValue` changes (only if touchscreen support is enabled)
- Fires when `UseTouchscreenFontScaling` changes
- Fires when `TouchscreenFontScaleFactorValue` changes (only if touchscreen support and font scaling are enabled)
- All Krypton controls automatically subscribe to this event
- Controls automatically refresh their layout when this event fires

**Example:**
```csharp
KryptonManager.GlobalTouchscreenSupportChanged += (sender, e) =>
{
    Console.WriteLine("Touchscreen support settings changed");
    // All controls have already refreshed automatically
};
```

---

### KryptonTouchscreenSettings Class

The `KryptonTouchscreenSettings` class provides a convenient way to access all touchscreen-related settings as a single expandable object in the Visual Studio designer.

#### Properties

##### `Enabled`

Gets or sets a value indicating if touchscreen support is enabled.

**Type:** `bool`  
**Default:** `false`

Maps to: `KryptonManager.UseTouchscreenSupport`

---

##### `ControlScaleFactor`

Gets or sets the scale factor applied to controls when touchscreen support is enabled.

**Type:** `float`  
**Default:** `1.25f`  
**Must be:** Greater than 0

Maps to: `KryptonManager.TouchscreenScaleFactorValue`

---

##### `FontScalingEnabled`

Gets or sets a value indicating if font scaling is enabled when touchscreen support is active.

**Type:** `bool`  
**Default:** `true`

Maps to: `KryptonManager.UseTouchscreenFontScaling`

---

##### `FontScaleFactor`

Gets or sets the scale factor applied to fonts when touchscreen support and font scaling are enabled.

**Type:** `float`  
**Default:** `1.25f`  
**Must be:** Greater than 0

Maps to: `KryptonManager.TouchscreenFontScaleFactorValue`

---

#### Methods

##### `Reset()`

Resets all touchscreen settings to their default values.

```csharp
public void Reset()
```

---

##### `IsDefault`

Gets a value indicating whether all settings are at their default values.

**Type:** `bool`

---

## Usage Examples

### Example 1: Basic Enable/Disable

```csharp
using Krypton.Toolkit;

public class MainForm : KryptonForm
{
    private void EnableTouchscreenMode()
    {
        // Enable touchscreen support with default 25% scaling
        KryptonManager.GlobalTouchscreenSupport = true;
        // All controls on all forms will now be 25% larger
    }

    private void DisableTouchscreenMode()
    {
        // Disable touchscreen support
        KryptonManager.GlobalTouchscreenSupport = false;
        // All controls return to normal size
    }
}
```

---

### Example 2: Custom Scale Factor

```csharp
using Krypton.Toolkit;

public class TouchscreenApp
{
    public void ConfigureForTablet()
    {
        // Enable with 50% larger controls for tablet devices
        KryptonManager.GlobalTouchscreenSupport = true;
        KryptonManager.GlobalTouchscreenScaleFactor = 1.5f;
    }

    public void ConfigureForPhone()
    {
        // Enable with 75% larger controls for phone devices
        KryptonManager.GlobalTouchscreenSupport = true;
        KryptonManager.GlobalTouchscreenScaleFactor = 1.75f;
    }

    public void ConfigureForDesktop()
    {
        // Disable for traditional desktop
        KryptonManager.GlobalTouchscreenSupport = false;
    }
}
```

---

### Example 3: Runtime Toggle (Using TouchscreenSettings API)

```csharp
using Krypton.Toolkit;
using System.Windows.Forms;

public class SettingsForm : KryptonForm
{
    private KryptonCheckBox chkTouchscreenMode;
    private KryptonTrackBar trackControlScale;
    private KryptonCheckBox chkFontScaling;
    private KryptonTrackBar trackFontScale;

    public SettingsForm()
    {
        InitializeComponent();
        
        // Initialize UI from TouchscreenSettings
        chkTouchscreenMode.Checked = KryptonManager.TouchscreenSettings.Enabled;
        trackControlScale.Value = (int)(KryptonManager.TouchscreenSettings.ControlScaleFactor * 100);
        chkFontScaling.Checked = KryptonManager.TouchscreenSettings.FontScalingEnabled;
        trackFontScale.Value = (int)(KryptonManager.TouchscreenSettings.FontScaleFactor * 100);
        trackFontScale.Enabled = chkFontScaling.Checked;
        
        // Wire up events
        chkTouchscreenMode.CheckedChanged += ChkTouchscreenMode_CheckedChanged;
        trackControlScale.ValueChanged += TrackControlScale_ValueChanged;
        chkFontScaling.CheckedChanged += ChkFontScaling_CheckedChanged;
        trackFontScale.ValueChanged += TrackFontScale_ValueChanged;
    }

    private void ChkTouchscreenMode_CheckedChanged(object sender, EventArgs e)
    {
        // Toggle touchscreen support
        KryptonManager.TouchscreenSettings.Enabled = chkTouchscreenMode.Checked;
        // Controls automatically refresh
    }

    private void TrackControlScale_ValueChanged(object sender, EventArgs e)
    {
        // Update control scale factor (convert from percentage to factor)
        float scaleFactor = 1.0f + (trackControlScale.Value / 100f);
        KryptonManager.TouchscreenSettings.ControlScaleFactor = scaleFactor;
        // Controls automatically refresh
    }

    private void ChkFontScaling_CheckedChanged(object sender, EventArgs e)
    {
        KryptonManager.TouchscreenSettings.FontScalingEnabled = chkFontScaling.Checked;
        trackFontScale.Enabled = chkFontScaling.Checked;
        // Controls automatically refresh
    }

    private void TrackFontScale_ValueChanged(object sender, EventArgs e)
    {
        // Update font scale factor (convert from percentage to factor)
        float fontScaleFactor = 1.0f + (trackFontScale.Value / 100f);
        KryptonManager.TouchscreenSettings.FontScaleFactor = fontScaleFactor;
        // Controls automatically refresh
    }
}
```

---

### Example 4: Designer Configuration

1. Add a `KryptonManager` component to your form from the toolbox
2. Select the `KryptonManager` component
3. In the Properties window, expand the `TouchscreenSettings` property
4. Set the following sub-properties:
   - `Enabled` = `True`
   - `ControlScaleFactor` = `1.25` (or your desired value)
   - `FontScalingEnabled` = `True` (default)
   - `FontScaleFactor` = `1.25` (or your desired value)
5. All controls on the form will automatically use touchscreen scaling

**Alternative:** You can also use the individual properties:
- `GlobalTouchscreenSupport` = `True`
- `GlobalTouchscreenScaleFactor` = `1.25`
- `GlobalTouchscreenFontScaling` = `True`
- `GlobalTouchscreenFontScaleFactor` = `1.25`

---

### Example 5: Conditional Enable Based on Device

```csharp
using Krypton.Toolkit;
using System.Windows.Forms;

public class AppInitializer
{
    public static void InitializeTouchscreenSupport()
    {
        // Detect if running on a touchscreen device
        bool hasTouchscreen = SystemInformation.TabletPC;
        
        if (hasTouchscreen)
        {
            // Enable touchscreen support
            KryptonManager.GlobalTouchscreenSupport = true;
            
            // Adjust scale factor based on screen DPI
            float dpiScale = GetDpiScale();
            if (dpiScale > 1.5f)
            {
                // High DPI - use smaller scale factor
                KryptonManager.GlobalTouchscreenScaleFactor = 1.25f;
            }
            else
            {
                // Normal DPI - use larger scale factor
                KryptonManager.GlobalTouchscreenScaleFactor = 1.5f;
            }
        }
        else
        {
            // Traditional desktop - disable
            KryptonManager.GlobalTouchscreenSupport = false;
        }
    }

    private static float GetDpiScale()
    {
        using (Graphics g = Graphics.FromHwnd(IntPtr.Zero))
        {
            return g.DpiX / 96f; // 96 is standard DPI
        }
    }
}
```

---

### Example 6: Event Monitoring

```csharp
using Krypton.Toolkit;

public class TouchscreenMonitor
{
    public TouchscreenMonitor()
    {
        // Subscribe to changes
        KryptonManager.GlobalTouchscreenSupportChanged += OnTouchscreenSupportChanged;
    }

    private void OnTouchscreenSupportChanged(object? sender, EventArgs e)
    {
        bool isEnabled = KryptonManager.UseTouchscreenSupport;
        float scaleFactor = KryptonManager.TouchscreenScaleFactor;
        
        Console.WriteLine($"Touchscreen support changed:");
        Console.WriteLine($"  Enabled: {isEnabled}");
        Console.WriteLine($"  Scale Factor: {scaleFactor}");
        Console.WriteLine($"  Effective Size: {(scaleFactor * 100 - 100):F1}% larger");
        
        // All controls have already refreshed automatically
        // You can perform additional actions here if needed
    }

    public void Dispose()
    {
        KryptonManager.GlobalTouchscreenSupportChanged -= OnTouchscreenSupportChanged;
    }
}
```

---

## Implementation Details

### How It Works

1. **Global Setting**: The touchscreen support is controlled by static properties in `KryptonManager`, making it a global setting that affects all Krypton controls application-wide.

2. **Size Calculation**: When a control needs to determine its preferred size, it calls `ViewManager.GetPreferredSize()`. This method:
   - Calculates the preferred size based on the control's content and layout
   - If touchscreen support is enabled, multiplies the width and height by the scale factor
   - Returns the scaled size

3. **Font Scaling**: When a control retrieves a font from the palette system, `PaletteRedirect` intercepts the font retrieval:
   - If touchscreen support and font scaling are both enabled, creates a new font with the size multiplied by the font scale factor
   - Preserves the font family, style, and unit
   - Returns the scaled font to the control
   - Font scaling can be enabled/disabled independently from control scaling

4. **Automatic Refresh**: When touchscreen settings change:
   - The `GlobalTouchscreenSupportChanged` event fires
   - All controls that inherit from `VisualControlBase` automatically subscribe to this event
   - Each control calls `OnNeedPaint()` with layout required
   - Controls recalculate their sizes and refresh their display

### Code Flow

```
User sets GlobalTouchscreenSupport = true
    ↓
UseTouchscreenSupport setter fires
    ↓
OnGlobalTouchscreenSupportChanged() called
    ↓
GlobalTouchscreenSupportChanged event fires
    ↓
All VisualControlBase controls receive event
    ↓
Each control calls OnGlobalTouchscreenSupportChanged()
    ↓
OnNeedPaint() called with NeedLayoutEventArgs(true)
    ↓
Control layout recalculated
    ↓
ViewManager.GetPreferredSize() called
    ↓
Scaling applied if UseTouchscreenSupport is true
    ↓
Control displays at new size
```

### Performance Considerations

- **Scaling Calculation**: The scaling is applied during layout calculation, which is already a necessary operation. The additional overhead is minimal (a single multiplication per dimension).

- **Event Handling**: Controls automatically subscribe to the change event, but the event only fires when settings actually change, not on every layout.

- **Memory**: No additional memory is required - the scaling is applied on-the-fly during size calculations.

---

## Best Practices

### 1. Set Scale Factors Before Enabling

If you're customizing the scale factors, set them before enabling touchscreen support to avoid extra refreshes:

```csharp
// Good: Set scale factors first, then enable
KryptonManager.TouchscreenSettings.ControlScaleFactor = 1.5f;
KryptonManager.TouchscreenSettings.FontScaleFactor = 1.3f;
KryptonManager.TouchscreenSettings.Enabled = true; // Only one refresh

// Less efficient: Enable first, then change scales
KryptonManager.TouchscreenSettings.Enabled = true; // First refresh
KryptonManager.TouchscreenSettings.ControlScaleFactor = 1.5f; // Second refresh
KryptonManager.TouchscreenSettings.FontScaleFactor = 1.3f; // Third refresh
```

### 2. Independent Control and Font Scaling

Control scaling and font scaling are independent. You can:
- Scale controls but not fonts (useful if fonts are already large enough)
- Scale fonts differently than controls (useful for fine-tuning readability)
- Disable font scaling entirely while keeping control scaling

```csharp
// Scale controls but not fonts
KryptonManager.TouchscreenSettings.Enabled = true;
KryptonManager.TouchscreenSettings.FontScalingEnabled = false;

// Different scale factors for controls and fonts
KryptonManager.TouchscreenSettings.ControlScaleFactor = 1.5f; // 50% larger controls
KryptonManager.TouchscreenSettings.FontScaleFactor = 1.2f; // 20% larger fonts
```

### 3. Use Appropriate Scale Factors

- **1.25 (25% larger)**: Good default for most touchscreen devices
- **1.5 (50% larger)**: Better for smaller screens or users with dexterity issues
- **1.75 (75% larger)**: For very small screens or accessibility needs
- **2.0 (100% larger)**: Extreme cases only, may cause layout issues

### 4. Test Layout at Different Scale Factors

Some layouts may break at extreme scale factors. Test your application with different scale factors to ensure:
- Controls don't overlap
- Forms fit on screen
- Text remains readable
- Scrollbars appear when needed

### 5. Consider DPI Scaling

Windows DPI scaling and touchscreen scaling are independent:
- DPI scaling affects the entire application
- Touchscreen scaling only affects Krypton controls
- Both can be active simultaneously

Consider the combined effect when setting scale factors.

### 6. Disable for Non-Touch Devices

If your application runs on both touch and non-touch devices, detect the device type and only enable touchscreen support when appropriate:

```csharp
if (SystemInformation.TabletPC || HasTouchInput())
{
    KryptonManager.GlobalTouchscreenSupport = true;
}
```

### 7. User Preference Storage

Store the user's touchscreen preferences in application settings:

```csharp
// Save
Properties.Settings.Default.TouchscreenEnabled = KryptonManager.TouchscreenSettings.Enabled;
Properties.Settings.Default.TouchscreenControlScale = KryptonManager.TouchscreenSettings.ControlScaleFactor;
Properties.Settings.Default.TouchscreenFontScaling = KryptonManager.TouchscreenSettings.FontScalingEnabled;
Properties.Settings.Default.TouchscreenFontScale = KryptonManager.TouchscreenSettings.FontScaleFactor;
Properties.Settings.Default.Save();

// Load
KryptonManager.TouchscreenSettings.ControlScaleFactor = Properties.Settings.Default.TouchscreenControlScale;
KryptonManager.TouchscreenSettings.FontScaleFactor = Properties.Settings.Default.TouchscreenFontScale;
KryptonManager.TouchscreenSettings.FontScalingEnabled = Properties.Settings.Default.TouchscreenFontScaling;
KryptonManager.TouchscreenSettings.Enabled = Properties.Settings.Default.TouchscreenEnabled;
```

---

## Advanced Components Support

The touchscreen support feature works seamlessly with all advanced Krypton components:

### KryptonNavigator

The `KryptonNavigator` control inherits from `VisualSimple`, which uses `ViewManager.GetPreferredSize()`. This means:

- All navigator modes (Bar, Tabs, CheckButtons, Outlook, etc.) scale automatically
- Tab buttons, page headers, and navigation buttons all scale
- The entire navigator control scales proportionally

**Example:**
```csharp
KryptonManager.GlobalTouchscreenSupport = true;
// Navigator tabs and buttons will be 25% larger automatically
```

### KryptonRibbon

The `KryptonRibbon` control inherits from `VisualSimple`, so it automatically scales:

- Ribbon tabs scale larger
- Ribbon groups scale larger
- Ribbon buttons (large and small) scale proportionally
- Quick Access Toolbar buttons scale
- Application button scales

**Note:** Ribbon is typically docked to the top of a form. When scaled, it will take more vertical space, so ensure your form has adequate height.

**Example:**
```csharp
KryptonManager.GlobalTouchscreenSupport = true;
KryptonManager.GlobalTouchscreenScaleFactor = 1.5f;
// Ribbon will be 50% larger, making it easier to touch
```

### KryptonWorkspace

The `KryptonWorkspace` control inherits from `VisualContainerControl`, so it scales automatically:

- Workspace cells scale larger
- Cell tabs scale larger
- Splitter bars scale (making them easier to grab)
- All content within workspace cells scales

**Example:**
```csharp
KryptonManager.GlobalTouchscreenSupport = true;
// Workspace cells and their tabs will scale automatically
```

### KryptonWorkspaceCell

`KryptonWorkspaceCell` inherits from `KryptonNavigator`, so it automatically benefits from touchscreen scaling:

- Cell tabs scale larger
- Navigation buttons scale larger
- All content within cells scales

### KryptonDockingManager

Docking panels and controls scale automatically:

- Docking panels scale larger
- Auto-hide slide panels scale larger
- Floating windows scale larger
- Docking separators scale (making them easier to grab)

**Note:** `KryptonDockingManager` itself is a component (not a control), so it doesn't have a size. However, all docking-related controls scale automatically.

**Example:**
```csharp
KryptonManager.GlobalTouchscreenSupport = true;
// All docking panels and controls will scale automatically
```

### How It Works

All these components inherit from base classes that use `ViewManager.GetPreferredSize()`:

- `KryptonNavigator` → `VisualSimple` → `VisualControlBase` → Uses `ViewManager`
- `KryptonRibbon` → `VisualSimple` → `VisualControlBase` → Uses `ViewManager`
- `KryptonWorkspace` → `VisualContainerControl` → `VisualContainerControlBase` → Uses `ViewManager`
- `KryptonWorkspaceCell` → `KryptonNavigator` → Uses `ViewManager`

Since the scaling is applied in `ViewManager.GetPreferredSize()`, all these components automatically benefit from touchscreen support without any additional code.

---

## Known Limitations

### 1. Only Affects Preferred Size

The scaling only affects the control's preferred size calculation. If a control has:
- Fixed `Size` or `Width`/`Height` properties set
- `Dock` or `Anchor` properties that constrain size
- Parent container size constraints

The scaling may not be fully effective. Controls should use `AutoSize` or allow natural sizing for best results.

### 2. Non-Krypton Controls

This feature only affects Krypton controls. Standard Windows Forms controls are not scaled. If your form mixes Krypton and standard controls, they may appear mismatched in size.

### 3. Advanced Components Support

The following advanced Krypton components **DO** support touchscreen scaling because they inherit from `VisualControlBase`:

- **KryptonNavigator**: All navigator modes (Bar, Tabs, CheckButtons, etc.) scale automatically
- **KryptonRibbon**: Ribbon tabs, groups, and buttons scale automatically
- **KryptonWorkspace**: Workspace cells and their content scale automatically
- **KryptonWorkspaceCell**: Inherits from `KryptonNavigator`, so it scales automatically
- **KryptonDockingManager**: Docking panels and controls scale automatically (docking manager itself is a component, not a control)

All of these components use `ViewManager.GetPreferredSize()` internally, so they automatically benefit from touchscreen scaling without any additional code.

### 4. Minimum/Maximum Size Constraints

Controls with `MinimumSize` or `MaximumSize` set may not scale as expected if the scaled size exceeds these constraints.

### 5. Custom Controls

Custom controls that don't inherit from `VisualControlBase` won't automatically receive touchscreen scaling. They would need to manually implement scaling in their `GetPreferredSize()` method.

### 6. Form Size

Forms themselves are not automatically resized. If controls grow larger, you may need to:
- Increase form size
- Enable scrolling
- Use layout panels that handle overflow

### 7. Image Scaling

Images within controls are not automatically scaled. Only the control's overall size is affected. If controls contain images, they may appear relatively smaller when controls are scaled up.

---

## Troubleshooting

### Controls Not Scaling

**Problem:** Controls don't appear larger when touchscreen support is enabled.

**Solutions:**
1. Verify `KryptonManager.UseTouchscreenSupport` is `true`
2. Check that controls inherit from `VisualControlBase`
3. Ensure controls don't have fixed `Size` properties
4. Verify controls use `AutoSize` or allow natural sizing
5. Check for `MinimumSize`/`MaximumSize` constraints

### Controls Don't Return to Normal Size

**Problem:** Controls remain large after disabling touchscreen support.

**Solutions:**
1. Verify `KryptonManager.UseTouchscreenSupport` is `false`
2. Force a layout refresh: `form.PerformLayout()` or `control.Invalidate()`
3. Check if controls have cached sizes that need clearing

### Layout Issues at High Scale Factors

**Problem:** Controls overlap or forms don't fit on screen at high scale factors.

**Solutions:**
1. Reduce the scale factor (try 1.25 instead of 1.5 or higher)
2. Increase form size
3. Use scrollable containers
4. Review layout constraints and anchors
5. Consider responsive layout techniques

### Performance Issues

**Problem:** Application feels sluggish with touchscreen support enabled.

**Solutions:**
1. Verify you're not changing scale factor frequently
2. Check for excessive layout calculations
3. Profile to identify bottlenecks
4. Consider caching calculated sizes if implementing custom controls

### Event Not Firing

**Problem:** `GlobalTouchscreenSupportChanged` event doesn't fire.

**Solutions:**
1. Verify you're subscribing to the static event: `KryptonManager.GlobalTouchscreenSupportChanged`
2. Check that the value is actually changing (not setting to the same value)
3. Ensure you're not disposing the subscriber before the event fires

---

## Related Documentation

- [KryptonManager API Reference](../Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonManager.cs)
- [ViewManager Implementation](../Source/Krypton Components/Krypton.Toolkit/View Base/ViewManager.cs)
- [VisualControlBase Implementation](../Source/Krypton Components/Krypton.Toolkit/Controls Visuals/VisualControlBase.cs)
- [Palette Mechanics](../Documents/palette-mechanics-intro.md)

---

## Version History

- **Version 110**: Initial implementation of touchscreen support feature
  - Added `GlobalTouchscreenSupport` property
  - Added `GlobalTouchscreenScaleFactor` property
  - Added `GlobalTouchscreenSupportChanged` event
  - Automatic control refresh on setting changes
  - Added font scaling support
    - Added `GlobalTouchscreenFontScaling` property
    - Added `GlobalTouchscreenFontScaleFactor` property
    - Added `UseTouchscreenFontScaling` static property
    - Added `TouchscreenFontScaleFactorValue` static property
    - Added `TouchscreenFontScaleFactor` static read-only property
  - Added `KryptonTouchscreenSettings` class
    - Groups all touchscreen settings into an expandable object
    - Provides `Enabled`, `ControlScaleFactor`, `FontScalingEnabled`, and `FontScaleFactor` properties
    - Designer-friendly with `ExpandableObjectConverter`

---

## Feedback and Contributions

For issues, feature requests, or contributions related to touchscreen support, please visit:
- GitHub Issues: https://github.com/Krypton-Suite/Standard-Toolkit/issues
- Feature Request: https://github.com/Krypton-Suite/Standard-Toolkit/issues/1760

