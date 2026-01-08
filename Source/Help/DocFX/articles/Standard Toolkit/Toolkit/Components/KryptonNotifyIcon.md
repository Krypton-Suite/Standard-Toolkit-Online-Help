# KryptonNotifyIcon Developer Documentation

## Overview

`KryptonNotifyIcon` is a Krypton-themed wrapper for the standard WinForms `NotifyIcon` component. It provides system tray icon functionality with full Krypton palette integration and exposes all standard `NotifyIcon` properties and events.

## Key Features

- **System Tray Integration**: Displays an icon in the Windows notification area (system tray)
- **Krypton Theming**: Integrates with the Krypton palette system
- **Balloon Tips**: Support for balloon tooltips with various icon types
- **Context Menu Support**: Can display context menus when the icon is clicked
- **Full Event Support**: All standard `NotifyIcon` events are exposed
- **Icon Management**: Automatic icon disposal and management

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
public class KryptonNotifyIcon : Component
```

## Properties

### Palette Properties

#### `PaletteMode`
```csharp
[Category("Visuals")]
[Description("Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
public PaletteMode PaletteMode { get; set; }
```

Gets or sets the palette mode. See `KryptonToolStripContainer` documentation for available palette modes.

#### `Palette`
```csharp
[Category("Visuals")]
[Description("Sets the custom palette to be used.")]
[DefaultValue(null)]
public PaletteBase? Palette { get; set; }
```

Gets or sets a custom palette implementation.

### NotifyIcon Properties

#### `Icon`
```csharp
[Category("Appearance")]
[Description("The icon to display in the notification area.")]
[DefaultValue(null)]
public Icon? Icon { get; set; }
```

Gets or sets the icon displayed in the notification area. The icon is automatically disposed when the component is disposed.

#### `Text`
```csharp
[Category("Appearance")]
[Description("The ToolTip text displayed when the mouse pointer rests on a notification area icon.")]
[DefaultValue("")]
[Localizable(true)]
public string Text { get; set; }
```

Gets or sets the ToolTip text displayed when the mouse pointer rests on the notification area icon.

#### `Visible`
```csharp
[Category("Behavior")]
[Description("Indicates whether the icon is visible in the notification area.")]
[DefaultValue(false)]
public bool Visible { get; set; }
```

Gets or sets a value indicating whether the icon is visible in the notification area.

#### `BalloonTipText`
```csharp
[Category("Appearance")]
[Description("The text to display on the BalloonTip.")]
[DefaultValue("")]
[Localizable(true)]
public string BalloonTipText { get; set; }
```

Gets or sets the text to display on the BalloonTip associated with the NotifyIcon.

#### `BalloonTipTitle`
```csharp
[Category("Appearance")]
[Description("The title to display on the BalloonTip.")]
[DefaultValue("")]
[Localizable(true)]
public string BalloonTipTitle { get; set; }
```

Gets or sets the title to display on the BalloonTip.

#### `BalloonTipIcon`
```csharp
[Category("Appearance")]
[Description("The icon to display on the BalloonTip.")]
[DefaultValue(ToolTipIcon.None)]
public ToolTipIcon BalloonTipIcon { get; set; }
```

Gets or sets the icon to display on the BalloonTip. Valid values:
- `ToolTipIcon.None` - No icon
- `ToolTipIcon.Info` - Information icon
- `ToolTipIcon.Warning` - Warning icon
- `ToolTipIcon.Error` - Error icon

#### `ContextMenuStrip`
```csharp
[Category("Behavior")]
[Description("The context menu to display when the icon is right-clicked.")]
[DefaultValue(null)]
public ContextMenuStrip? ContextMenuStrip { get; set; }
```

Gets or sets the context menu to display when the icon is right-clicked.

## Methods

### `ShowBalloonTip`
```csharp
public void ShowBalloonTip(int timeout)
```

Displays a balloon tip in the taskbar for the specified time period.

**Parameters:**
- `timeout` - The time period, in milliseconds, the balloon tip should display

**Example:**
```csharp
notifyIcon.ShowBalloonTip(5000);
```

### `ShowBalloonTip`
```csharp
public void ShowBalloonTip(int timeout, string tipTitle, string tipText, ToolTipIcon tipIcon)
```

Displays a balloon tip with the specified title, text, and icon in the taskbar for the specified time period.

**Parameters:**
- `timeout` - The time period, in milliseconds, the balloon tip should display
- `tipTitle` - The title to display on the balloon tip
- `tipText` - The text to display on the balloon tip
- `tipIcon` - One of the `ToolTipIcon` values that specifies the icon to display

**Example:**
```csharp
notifyIcon.ShowBalloonTip(5000, "Update Available", "A new version is ready to install.", ToolTipIcon.Info);
```

## Events

### `Click`
```csharp
[Category("Action")]
[Description("Occurs when the user clicks the icon in the notification area.")]
public event EventHandler? Click;
```

Occurs when the user clicks the icon in the notification area.

### `DoubleClick`
```csharp
[Category("Action")]
[Description("Occurs when the user double-clicks the icon in the notification area.")]
public event EventHandler? DoubleClick;
```

Occurs when the user double-clicks the icon in the notification area.

### `MouseClick`
```csharp
[Category("Action")]
[Description("Occurs when the user clicks a mouse button while the pointer is over the icon.")]
public event MouseEventHandler? MouseClick;
```

Occurs when the user clicks a mouse button while the pointer is over the icon in the notification area.

### `MouseDoubleClick`
```csharp
[Category("Action")]
[Description("Occurs when the user double-clicks the icon with the mouse.")]
public event MouseEventHandler? MouseDoubleClick;
```

Occurs when the user double-clicks the icon in the notification area with the mouse.

### `MouseMove`
```csharp
[Category("Action")]
[Description("Occurs when the user moves the mouse over the icon.")]
public event MouseEventHandler? MouseMove;
```

Occurs when the user moves the mouse over the icon in the notification area.

### `MouseDown`
```csharp
[Category("Action")]
[Description("Occurs when the user presses a mouse button while the pointer is over the icon.")]
public event MouseEventHandler? MouseDown;
```

Occurs when the user presses a mouse button while the pointer is over the icon in the notification area.

### `MouseUp`
```csharp
[Category("Action")]
[Description("Occurs when the user releases a mouse button while the pointer is over the icon.")]
public event MouseEventHandler? MouseUp;
```

Occurs when the user releases a mouse button while the pointer is over the icon in the notification area.

### `BalloonTipClicked`
```csharp
[Category("Action")]
[Description("Occurs when the BalloonTip is clicked.")]
public event EventHandler? BalloonTipClicked;
```

Occurs when the BalloonTip is clicked.

### `BalloonTipClosed`
```csharp
[Category("Action")]
[Description("Occurs when the BalloonTip is closed by the user.")]
public event EventHandler? BalloonTipClosed;
```

Occurs when the BalloonTip is closed by the user.

### `BalloonTipShown`
```csharp
[Category("Action")]
[Description("Occurs when the BalloonTip is displayed on the screen.")]
public event EventHandler? BalloonTipShown;
```

Occurs when the BalloonTip is displayed on the screen.

## Usage Examples

### Basic System Tray Icon

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonNotifyIcon notifyIcon;

    public MainForm()
    {
        InitializeComponent();
        
        // Create notify icon
        notifyIcon = new KryptonNotifyIcon
        {
            Icon = SystemIcons.Application,
            Text = "My Application",
            Visible = true
        };

        // Handle click events
        notifyIcon.Click += NotifyIcon_Click;
        notifyIcon.DoubleClick += NotifyIcon_DoubleClick;
    }

    private void NotifyIcon_Click(object? sender, EventArgs e)
    {
        // Show form if minimized
        if (WindowState == FormWindowState.Minimized)
        {
            WindowState = FormWindowState.Normal;
            Show();
            Activate();
        }
    }

    private void NotifyIcon_DoubleClick(object? sender, EventArgs e)
    {
        // Toggle visibility
        if (Visible)
        {
            Hide();
        }
        else
        {
            Show();
            WindowState = FormWindowState.Normal;
            Activate();
        }
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        // Hide to tray instead of closing
        if (e.CloseReason == CloseReason.UserClosing)
        {
            e.Cancel = true;
            Hide();
            notifyIcon.ShowBalloonTip(2000, "Application", "Application minimized to tray.", ToolTipIcon.Info);
        }
        else
        {
            notifyIcon?.Dispose();
        }
        
        base.OnFormClosing(e);
    }
}
```

### Context Menu

```csharp
// Create context menu
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Show", OnShow));
contextMenu.Items.Add(new KryptonContextMenuItem("Settings", OnSettings));
contextMenu.Items.Add(new KryptonContextMenuSeparator());
contextMenu.Items.Add(new KryptonContextMenuItem("Exit", OnExit));

notifyIcon.ContextMenuStrip = contextMenu;
```

### Balloon Tips

```csharp
// Show notification
notifyIcon.BalloonTipTitle = "Update Available";
notifyIcon.BalloonTipText = "A new version of the application is available.";
notifyIcon.BalloonTipIcon = ToolTipIcon.Info;
notifyIcon.ShowBalloonTip(5000);

// Handle balloon tip events
notifyIcon.BalloonTipClicked += (s, e) =>
{
    // Open update dialog
    ShowUpdateDialog();
};

notifyIcon.BalloonTipClosed += (s, e) =>
{
    // Cleanup if needed
};
```

### Application Minimize to Tray

```csharp
private void MainForm_Resize(object sender, EventArgs e)
{
    if (WindowState == FormWindowState.Minimized)
    {
        Hide();
        notifyIcon.Visible = true;
        notifyIcon.ShowBalloonTip(2000, "Application", "Application minimized to tray.", ToolTipIcon.Info);
    }
}

private void NotifyIcon_DoubleClick(object? sender, EventArgs e)
{
    Show();
    WindowState = FormWindowState.Normal;
    Activate();
}
```

## Best Practices

1. **Icon Disposal**: The component automatically disposes of the icon. Ensure the component is properly disposed when the application exits.

2. **Visibility Management**: Always set `Visible = false` before disposing to ensure the icon is removed from the system tray.

3. **Balloon Tips**: Use balloon tips sparingly and with appropriate timeouts. Too many notifications can annoy users.

4. **Context Menus**: Provide a context menu for right-click functionality. Include options like Show, Settings, and Exit.

5. **Minimize to Tray**: When implementing minimize-to-tray, ensure the form can be restored via the notify icon.

6. **Icon Size**: Use 16x16 or 32x32 pixel icons for best results in the system tray.

7. **Text Length**: Keep the `Text` property (tooltip) short and descriptive.

## Technical Details

### Icon Management

The component manages icon disposal automatically. When you set a new icon, the previous icon is disposed. When the component is disposed, the current icon is also disposed.

### System Tray Behavior

- The icon appears in the Windows notification area (system tray)
- Windows may hide the icon if the notification area is full
- Users can configure icon visibility through Windows settings
- The icon is automatically removed when the component is disposed (if `Visible` is properly managed)

### Palette Integration

While the system tray icon itself uses standard Windows rendering, the component integrates with the Krypton palette system for consistency. This allows for future enhancements and ensures the component follows Krypton patterns.

## See Also

- `KryptonContextMenu` - For context menus
- `KryptonToolTip` - For tooltips
- Standard WinForms `NotifyIcon` documentation

