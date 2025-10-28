# CommandLinkImageValues

## Overview

`CommandLinkImageValues` provides specialized image storage for `KryptonCommandLinkButton` controls, with built-in support for displaying the Windows UAC (User Account Control) shield icon. It implements the `IContentValues` interface to integrate with the Krypton rendering system.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `Storage` → `CommandLinkImageValues`  
**Implements:** `IContentValues`

## Key Features

### UAC Shield Support
- Automatic UAC shield icon display
- Configurable icon sizes (16px to 256px)
- System icon extraction and scaling
- DPI-aware rendering

### Image Management
- Custom image support
- Transparency key configuration
- Automatic paint invalidation
- State-based image retrieval

### Integration
- Designed for `KryptonCommandLinkButton`
- Implements `IContentValues` interface
- Seamless Krypton rendering integration

---

## Constructor

### CommandLinkImageValues(NeedPaintHandler)

Initializes a new instance of the CommandLinkImageValues class.

```csharp
public CommandLinkImageValues(NeedPaintHandler needPaint)
```

**Parameters:**
- `needPaint` - Delegate for notifying paint requests

**Default Values:**
- `DisplayUACShield` = `false`
- `UACShieldIconSize` = `IconSize.Small` (32x32)
- `ImageTransparentColor` = `GlobalStaticValues.EMPTY_COLOR`
- `Image` = `null`

---

## Properties

### DisplayUACShield
Gets or sets whether to display the UAC shield icon.

```csharp
[DefaultValue(false)]
[Description("Display the UAC Shield image.")]
public bool DisplayUACShield { get; set; }
```

**Default:** `false`

**Remarks:**
- When `true`, automatically loads and displays the Windows UAC shield icon
- When `false`, the image is set to `null` (unless a custom image is set)
- The shield icon is extracted from the Windows system icons
- Icon size is determined by `UACShieldIconSize` property

**Example:**
```csharp
commandLinkButton.UACShieldIcon.DisplayUACShield = true;
// Automatically shows Windows UAC shield icon
```

---

### UACShieldIconSize
Gets or sets the UAC shield icon size.

```csharp
[DefaultValue(IconSize.Small)]
[Description("UAC Shield icon size")]
public IconSize UACShieldIconSize { get; set; }
```

**Default:** `IconSize.Small` (32x32 pixels)

**Available Sizes:**
- `IconSize.ExtraSmall` - 16x16 pixels
- `IconSize.Small` - 32x32 pixels
- `IconSize.Medium` - 64x64 pixels
- `IconSize.Large` - 128x128 pixels
- `IconSize.ExtraLarge` - 256x256 pixels

**Remarks:**
- Only applies when `DisplayUACShield = true`
- Icon is automatically scaled to specified size
- Larger sizes provide better quality on high-DPI displays

**Example:**
```csharp
commandLinkButton.UACShieldIcon.DisplayUACShield = true;
commandLinkButton.UACShieldIcon.UACShieldIconSize = IconSize.Medium; // 64x64
```

---

### Image
Gets the command link image.

```csharp
[Category("Visuals")]
[Description("The image.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public Image? Image { get; }
```

**Remarks:**
- Read-only property
- Automatically set when `DisplayUACShield = true`
- Contains the UAC shield icon or custom image
- `null` when no image is displayed

**Example:**
```csharp
// Check if image is set
if (commandLinkButton.UACShieldIcon.Image != null)
{
    pictureBox.Image = commandLinkButton.UACShieldIcon.Image;
}
```

---

### ImageTransparentColor
Gets or sets the image transparent color.

```csharp
[Category("Visuals")]
[Description("Image transparent color.")]
[RefreshProperties(RefreshProperties.All)]
[KryptonDefaultColor]
public Color ImageTransparentColor { get; set; }
```

**Default:** `GlobalStaticValues.EMPTY_COLOR` (no transparency)

**Remarks:**
- Color to treat as transparent in the image
- Typically `Color.Magenta` for legacy images
- Modern PNG images with alpha channel don't need this
- UAC shield icon already has proper transparency

**Example:**
```csharp
// For legacy bitmap images
commandLinkButton.UACShieldIcon.ImageTransparentColor = Color.Magenta;
```

---

### IsDefault
Gets whether all values are in their default state.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public override bool IsDefault { get; }
```

**Returns:** `true` if all properties have default values; otherwise `false`.

**Remarks:**
- Used by the designer for serialization decisions
- Checks all properties including display state, image, transparency, and size

---

## Methods

### GetImage(PaletteState)
Gets the image for the specified palette state.

```csharp
public Image? GetImage(PaletteState state)
```

**Parameters:**
- `state` - Palette state (Normal, Tracking, Pressed, etc.)

**Returns:** The current image, or `null` if no image is set.

**Remarks:**
- Implements `IContentValues.GetImage()`
- State parameter is currently ignored (same image for all states)
- Could be extended to provide state-specific images

**Example:**
```csharp
IContentValues contentValues = commandLinkButton.UACShieldIcon;
Image icon = contentValues.GetImage(PaletteState.Normal);
```

---

### GetImageTransparentColor(PaletteState)
Gets the image transparent color for the specified palette state.

```csharp
public Color GetImageTransparentColor(PaletteState state)
```

**Parameters:**
- `state` - Palette state

**Returns:** The transparent color, or `EMPTY_COLOR` if none is set.

**Remarks:**
- Implements `IContentValues.GetImageTransparentColor()`
- State parameter is currently ignored

---

### GetShortText()
Gets the short text content.

```csharp
public string GetShortText()
```

**Returns:** Empty string (images don't have text).

**Remarks:**
- Implements `IContentValues.GetShortText()`
- Always returns empty string for image values

---

### GetLongText()
Gets the long text content.

```csharp
public string GetLongText()
```

**Returns:** Empty string (images don't have text).

**Remarks:**
- Implements `IContentValues.GetLongText()`
- Always returns empty string for image values

---

### Reset Methods

#### ResetDisplayUACShield()
Resets the DisplayUACShield property to its default value.

```csharp
private void ResetDisplayUACShield()
```

---

#### ResetImageTransparentColor()
Resets the ImageTransparentColor property to its default value.

```csharp
private void ResetImageTransparentColor()
```

---

#### ResetUACShieldIconSize()
Resets the UACShieldIconSize property to its default value.

```csharp
private void ResetUACShieldIconSize()
```

---

## Usage Examples

### Display UAC Shield (Default Size)

```csharp
var commandLink = new KryptonCommandLinkButton();
commandLink.CommandLinkTextValues.Heading = "Install System-Wide";
commandLink.CommandLinkTextValues.Description = "Requires administrator privileges";

// Show UAC shield
commandLink.UACShieldIcon.DisplayUACShield = true;
```

---

### UAC Shield with Custom Size

```csharp
var commandLink = new KryptonCommandLinkButton();
commandLink.CommandLinkTextValues.Heading = "Modify System Settings";
commandLink.CommandLinkTextValues.Description = "This action requires elevation";

// Show larger shield icon
commandLink.UACShieldIcon.DisplayUACShield = true;
commandLink.UACShieldIcon.UACShieldIconSize = IconSize.Large; // 128x128
```

---

### Administrative Actions List

```csharp
public class AdminActionsPanel : KryptonPanel
{
    public AdminActionsPanel()
    {
        CreateAdminButton(
            "Install Service",
            "Install and start the background service",
            20);
        
        CreateAdminButton(
            "Modify Registry",
            "Change system-wide registry settings",
            100);
        
        CreateAdminButton(
            "Update Drivers",
            "Install updated device drivers",
            180);
    }
    
    private void CreateAdminButton(string heading, string description, int y)
    {
        var button = new KryptonCommandLinkButton
        {
            Location = new Point(20, y),
            Size = new Size(400, 70)
        };
        
        button.CommandLinkTextValues.Heading = heading;
        button.CommandLinkTextValues.Description = description;
        
        // All admin actions show UAC shield
        button.UACShieldIcon.DisplayUACShield = true;
        
        Controls.Add(button);
    }
}
```

---

### Conditional UAC Shield

```csharp
private void UpdateButtonElevation(KryptonCommandLinkButton button, bool requiresElevation)
{
    button.UACShieldIcon.DisplayUACShield = requiresElevation;
    
    if (requiresElevation)
    {
        button.CommandLinkTextValues.Description += " (Requires administrator)";
    }
}

// Usage:
bool needsAdmin = !IsUserAdministrator();
UpdateButtonElevation(installButton, needsAdmin);
```

---

### Elevation Check with Shield

```csharp
public class ElevatedCommandLink : KryptonCommandLinkButton
{
    public ElevatedCommandLink()
    {
        // Check if running as administrator
        bool isElevated = new WindowsPrincipal(WindowsIdentity.GetCurrent())
            .IsInRole(WindowsBuiltInRole.Administrator);
        
        if (!isElevated)
        {
            // Show shield if not elevated
            UACShieldIcon.DisplayUACShield = true;
            
            // Modify click behavior to request elevation
            Click += RequestElevation;
        }
    }
    
    private void RequestElevation(object sender, EventArgs e)
    {
        if (UACShieldIcon.DisplayUACShield)
        {
            // Restart process with elevation request
            var startInfo = new ProcessStartInfo
            {
                FileName = Application.ExecutablePath,
                Verb = "runas", // Request elevation
                UseShellExecute = true
            };
            
            try
            {
                Process.Start(startInfo);
                Application.Exit();
            }
            catch (Win32Exception)
            {
                // User cancelled UAC prompt
                MessageBox.Show("Administrator privileges required.");
            }
        }
    }
}
```

---

### Different Sizes for Different Actions

```csharp
public enum ElevationLevel
{
    None,
    Standard,
    High,
    Critical
}

private void SetElevationIcon(
    KryptonCommandLinkButton button,
    ElevationLevel level)
{
    switch (level)
    {
        case ElevationLevel.None:
            button.UACShieldIcon.DisplayUACShield = false;
            break;
            
        case ElevationLevel.Standard:
            button.UACShieldIcon.DisplayUACShield = true;
            button.UACShieldIcon.UACShieldIconSize = IconSize.Small;
            break;
            
        case ElevationLevel.High:
            button.UACShieldIcon.DisplayUACShield = true;
            button.UACShieldIcon.UACShieldIconSize = IconSize.Medium;
            break;
            
        case ElevationLevel.Critical:
            button.UACShieldIcon.DisplayUACShield = true;
            button.UACShieldIcon.UACShieldIconSize = IconSize.Large;
            // Also change colors for critical
            button.StateNormal.Back.Color1 = Color.DarkRed;
            break;
    }
}
```

---

### Installation Wizard with UAC

```csharp
public class InstallationWizard : KryptonForm
{
    private KryptonCommandLinkButton standardInstall;
    private KryptonCommandLinkButton customInstall;
    
    public InstallationWizard()
    {
        standardInstall = new KryptonCommandLinkButton();
        standardInstall.CommandLinkTextValues.Heading = "Standard Installation";
        standardInstall.CommandLinkTextValues.Description = 
            "Install for current user only (no elevation required)";
        standardInstall.UACShieldIcon.DisplayUACShield = false;
        
        customInstall = new KryptonCommandLinkButton();
        customInstall.CommandLinkTextValues.Heading = "System-Wide Installation";
        customInstall.CommandLinkTextValues.Description = 
            "Install for all users (requires administrator privileges)";
        customInstall.UACShieldIcon.DisplayUACShield = true;
        customInstall.UACShieldIcon.UACShieldIconSize = IconSize.Small;
    }
}
```

---

### Custom Icon Fallback

```csharp
public class SmartCommandLink : KryptonCommandLinkButton
{
    public void SetAdminAction(bool requiresAdmin, Image customIcon = null)
    {
        if (requiresAdmin)
        {
            // Try to show UAC shield
            UACShieldIcon.DisplayUACShield = true;
            
            if (UACShieldIcon.Image == null && customIcon != null)
            {
                // Fallback to custom icon if UAC shield unavailable
                // (In practice, UAC shield should always be available on Windows)
                UACShieldIcon.DisplayUACShield = false;
                // Would need to set custom image through internal field
            }
        }
        else
        {
            UACShieldIcon.DisplayUACShield = false;
        }
    }
}
```

---

### DPI-Aware Shield Icons

```csharp
public class DpiAwareCommandLink : KryptonCommandLinkButton
{
    protected override void OnDpiChangedAfterParent(EventArgs e)
    {
        base.OnDpiChangedAfterParent(e);
        
        if (UACShieldIcon.DisplayUACShield)
        {
            // Adjust icon size based on DPI
            float scaleFactor = DeviceDpi / 96f;
            
            var newSize = scaleFactor switch
            {
                <= 1.0f => IconSize.ExtraSmall,  // 96 DPI - 16px
                <= 1.5f => IconSize.Small,       // 144 DPI - 32px
                <= 2.0f => IconSize.Medium,      // 192 DPI - 64px
                <= 2.5f => IconSize.Large,       // 240 DPI - 128px
                _ => IconSize.ExtraLarge         // 288+ DPI - 256px
            };
            
            UACShieldIcon.UACShieldIconSize = newSize;
        }
    }
}
```

---

### Settings Dialog with Mixed Permissions

```csharp
public class SettingsDialog : KryptonForm
{
    public SettingsDialog()
    {
        // User-level settings (no shield)
        var userSettingsButton = CreateSettingButton(
            "User Preferences",
            "Change your personal settings",
            false);
        
        // System-level settings (with shield)
        var systemSettingsButton = CreateSettingButton(
            "System Settings",
            "Change settings for all users",
            true);
        
        // Network settings (with shield)
        var networkButton = CreateSettingButton(
            "Network Configuration",
            "Configure network adapters and protocols",
            true);
    }
    
    private KryptonCommandLinkButton CreateSettingButton(
        string heading,
        string description,
        bool requiresElevation)
    {
        var button = new KryptonCommandLinkButton();
        button.CommandLinkTextValues.Heading = heading;
        button.CommandLinkTextValues.Description = description;
        button.UACShieldIcon.DisplayUACShield = requiresElevation;
        
        if (requiresElevation)
        {
            button.Click += (s, e) => ShowElevatedSettings(heading);
        }
        else
        {
            button.Click += (s, e) => ShowUserSettings(heading);
        }
        
        return button;
    }
    
    private void ShowElevatedSettings(string category)
    {
        // Check if already elevated
        if (!IsElevated())
        {
            MessageBox.Show(
                "This operation requires administrator privileges.\r\n" +
                "The application will restart with elevated permissions.",
                "Elevation Required",
                MessageBoxButtons.OK,
                MessageBoxIcon.Shield);
            
            RestartElevated();
        }
        else
        {
            // Show settings
        }
    }
}
```

---

## Design Considerations

### UAC Shield Usage Guidelines

**Use UAC Shield When:**
- Installing system-wide software or services
- Modifying system settings or registry
- Accessing protected system directories
- Changing settings for all users
- Installing drivers or kernel components

**Don't Use UAC Shield When:**
- Action only affects current user
- No privileged operations required
- Action is informational/read-only
- User already running as administrator

---

### Icon Size Selection

**Size Guidelines:**
- **ExtraSmall (16px):** Very compact, inline actions
- **Small (32px):** Standard size, most command links (default)
- **Medium (64px):** Prominent actions, large buttons
- **Large (128px):** Critical admin actions, warnings
- **ExtraLarge (256px):** Touch interfaces, accessibility

**Recommendations:**
```csharp
// Standard command link button
iconSize = IconSize.Small;      // 32x32 - balanced

// Large command link (80px+ tall)
iconSize = IconSize.Medium;     // 64x64 - proportional

// Critical system action
iconSize = IconSize.Large;      // 128x128 - prominent

// Touch-optimized UI
iconSize = IconSize.ExtraLarge; // 256x256 - finger-friendly
```

---

### Performance Considerations

**Icon Caching:**
- Shield icon is loaded and scaled on-demand
- Consider caching if creating many buttons
- Image is automatically disposed when control disposes

**Scaling:**
- System uses high-quality scaling (bicubic interpolation)
- Larger source (SystemIcons.Shield) scales down better than up
- For best quality, use closest matching size

---

### Platform Compatibility

**Windows Version Support:**
- UAC introduced in Windows Vista
- Shield icon available on Vista and later
- Graceful degradation on older systems (no icon)
- Modern Windows versions (7+) fully supported

---

### Transparency and Rendering

**UAC Shield:**
- Has built-in alpha channel transparency
- `ImageTransparentColor` not needed
- Renders correctly on any background

**Custom Images:**
- Use PNG with alpha channel for transparency
- Or set `ImageTransparentColor` for legacy bitmaps
- Ensure proper contrast with button background

---

## Related Classes

### IContentValues Interface
Implemented by `CommandLinkImageValues` to provide image content:
```csharp
Image? GetImage(PaletteState state);
Color GetImageTransparentColor(PaletteState state);
string GetShortText();
string GetLongText();
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Windows Version:** Vista+ (for UAC shield icon)
- **Dependencies:** 
  - System.Drawing (for Image, SystemIcons)
  - Krypton.Toolkit core components

---

## See Also

- [KryptonCommandLinkButton](../Toolkit/KryptonCommandLinkButton.md) - Parent control
- [CommandLinkTextValues](../Toolkit/CommandLinkTextValues.md) - Text values for command links
- [IContentValues](../Interfaces/IContentValues.md) - Content values interface
- [IconSize](../Enumerations/IconSize.md) - Icon size enumeration
- [Storage](Storage.md) - Base storage class

---

## Remarks

### UAC and User Experience

The UAC shield icon is a Windows standard that users recognize immediately. When used correctly:
- ✅ Sets proper expectations for privilege requirements
- ✅ Reduces surprise UAC prompts
- ✅ Improves perceived application reliability
- ✅ Follows Windows UX guidelines

**Best Practice:**
Always show the shield icon *before* the user clicks, not after. This allows them to make an informed decision about whether to proceed with an action that requires elevation.