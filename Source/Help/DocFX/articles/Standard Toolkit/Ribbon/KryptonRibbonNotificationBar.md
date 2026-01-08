# Ribbon Notification Bar

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [API Reference](#api-reference)
4. [Properties](#properties)
5. [Events](#events)
6. [Notification Types](#notification-types)
7. [Using KryptonCommand](#using-kryptoncommand)
8. [Advanced Features](#advanced-features)
9. [Best Practices](#best-practices)
10. [Code Examples](#code-examples)
11. [Troubleshooting](#troubleshooting)

---

## Overview

The **Ribbon Notification Bar** is a feature-rich component that displays contextual notifications, alerts, and messages directly within the Krypton Ribbon control. It provides a modern, Office-style notification system that can be customized with different types, colors, icons, and interactive buttons.

### Key Features

- **Multiple Notification Types**: Information, Warning, Error, Success, and Custom
- **Flexible Content**: Support for title, text, and custom icons
- **Interactive Buttons**: Action buttons with text, images, or KryptonCommand objects
- **Auto-Dismiss**: Configurable automatic dismissal timer
- **Custom Styling**: Full control over colors, padding, and height
- **Event Handling**: Comprehensive event system for button clicks
- **DPI Awareness**: Automatic scaling for high-DPI displays

### Architecture

The notification bar consists of three main components:

1. **`KryptonRibbonNotificationBarData`**: Data model that holds all notification properties
2. **`ViewDrawRibbonNotificationBar`**: View component responsible for rendering
3. **`KryptonRibbon`**: Main ribbon control that hosts the notification bar

---

## Quick Start

### Basic Usage

```csharp
using Krypton.Ribbon;
using Krypton.Toolkit;

// Access the notification bar through the ribbon
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
kryptonRibbon.NotificationBar.Text = "This is an informational message.";
kryptonRibbon.NotificationBar.Visible = true;
```

### With Action Buttons

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Warning;
kryptonRibbon.NotificationBar.Text = "Updates are available.";
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Update now", "Later" };
kryptonRibbon.NotificationBar.Visible = true;
```

### Handling Button Clicks

```csharp
kryptonRibbon.NotificationBarButtonClick += (sender, e) =>
{
    if (e.ActionButtonIndex == -1)
    {
        // Close button was clicked
        MessageBox.Show("Notification closed");
    }
    else
    {
        // Action button was clicked
        string buttonText = kryptonRibbon.NotificationBar.ActionButtonTexts?[e.ActionButtonIndex] ?? "Unknown";
        MessageBox.Show($"Button '{buttonText}' clicked");
    }
};
```

---

## API Reference

### KryptonRibbon.NotificationBar Property

**Type**: `KryptonRibbonNotificationBarData`  
**Access**: Read-only  
**Description**: Provides access to the notification bar data model.

```csharp
public KryptonRibbonNotificationBarData NotificationBar { get; }
```

### KryptonRibbon.NotificationBarButtonClick Event

**Type**: `EventHandler<RibbonNotificationBarEventArgs>`  
**Description**: Raised when any button (action or close) in the notification bar is clicked.

```csharp
public event EventHandler<RibbonNotificationBarEventArgs>? NotificationBarButtonClick;
```

---

## Properties

### KryptonRibbonNotificationBarData Properties

#### Visibility and Type

##### `Visible` (bool)
- **Default**: `false`
- **Category**: Appearance
- **Description**: Determines whether the notification bar is visible.
- **Usage**: Set to `true` to show the notification bar.

```csharp
kryptonRibbon.NotificationBar.Visible = true;
```

##### `Type` (RibbonNotificationBarType)
- **Default**: `RibbonNotificationBarType.Information`
- **Category**: Appearance
- **Description**: The type of notification bar, which determines default colors.
- **Values**: `Information`, `Warning`, `Error`, `Success`, `Custom`

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Warning;
```

#### Content Properties

##### `Text` (string)
- **Default**: `""`
- **Category**: Appearance
- **Localizable**: Yes
- **Description**: The main text message displayed in the notification bar.
- **Usage**: This is the primary message shown to the user.

```csharp
kryptonRibbon.NotificationBar.Text = "Your document has been saved successfully.";
```

##### `Title` (string)
- **Default**: `""`
- **Category**: Appearance
- **Localizable**: Yes
- **Description**: The title text displayed before the main text (e.g., "UPDATES AVAILABLE").
- **Usage**: Optional title that appears before the main message text.

```csharp
kryptonRibbon.NotificationBar.Title = "UPDATES AVAILABLE";
kryptonRibbon.NotificationBar.Text = "Updates for Office are ready to be applied.";
```

##### `Icon` (Image?)
- **Default**: `null`
- **Category**: Appearance
- **Description**: The icon image displayed in the notification bar.
- **Usage**: Custom icon image. If not set, default icons are used based on the notification type.

```csharp
kryptonRibbon.NotificationBar.Icon = SystemIcons.Information.ToBitmap();
```

##### `ShowIcon` (bool)
- **Default**: `true`
- **Category**: Appearance
- **Description**: Determines whether to show the icon.
- **Usage**: Set to `false` to hide the icon completely.

```csharp
kryptonRibbon.NotificationBar.ShowIcon = true;
```

#### Button Properties

##### `ShowCloseButton` (bool)
- **Default**: `true`
- **Category**: Appearance
- **Description**: Determines whether to show the close button (X).
- **Usage**: Set to `false` to hide the close button.

```csharp
kryptonRibbon.NotificationBar.ShowCloseButton = true;
```

##### `ShowActionButtons` (bool)
- **Default**: `true`
- **Category**: Appearance
- **Description**: Determines whether to show action buttons.
- **Usage**: Set to `false` to hide all action buttons.

```csharp
kryptonRibbon.NotificationBar.ShowActionButtons = true;
```

##### `ActionButtonTexts` (string[])
- **Default**: `new[] { "Update now" }`
- **Category**: Appearance
- **Localizable**: Yes
- **Description**: The array of action button texts.
- **Usage**: Provides button text when not using `ActionButtonCommands`.
- **Note**: Ignored if `ActionButtonCommands` is set.

```csharp
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "OK", "Cancel", "Retry" };
```

##### `ActionButtonImages` (Image[]?)
- **Default**: `null`
- **Category**: Appearance
- **Description**: The array of action button images (optional).
- **Usage**: Optional images for action buttons. Must match the length of `ActionButtonTexts`.
- **Note**: Ignored if `ActionButtonCommands` is set.

```csharp
kryptonRibbon.NotificationBar.ActionButtonImages = new Image[] 
{ 
    SystemIcons.Question.ToBitmap(), 
    SystemIcons.Error.ToBitmap() 
};
```

##### `ActionButtonCommands` (IKryptonCommand[]?)
- **Default**: `null`
- **Category**: Behavior
- **Description**: The array of KryptonCommand objects for action buttons. If provided, these will be used instead of `ActionButtonTexts`.
- **Usage**: Provides full command support with Execute events, images, and enabled states.
- **Note**: Takes precedence over `ActionButtonTexts` when set.

```csharp
var command1 = new KryptonCommand { Text = "OK", ImageSmall = myIcon };
command1.Execute += (s, e) => { /* Handle click */ };
kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { command1 };
```

#### Custom Styling Properties

##### `CustomBackColor` (Color)
- **Default**: `Color.FromArgb(255, 242, 204)`
- **Category**: Appearance
- **Description**: The custom background color (used when Type is Custom).
- **Usage**: Only applies when `Type` is set to `RibbonNotificationBarType.Custom`.

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Custom;
kryptonRibbon.NotificationBar.CustomBackColor = Color.FromArgb(240, 248, 255);
```

##### `CustomForeColor` (Color)
- **Default**: `Color.Black`
- **Category**: Appearance
- **Description**: The custom foreground color (used when Type is Custom).
- **Usage**: Only applies when `Type` is set to `RibbonNotificationBarType.Custom`.

```csharp
kryptonRibbon.NotificationBar.CustomForeColor = Color.FromArgb(25, 25, 112);
```

##### `CustomBorderColor` (Color)
- **Default**: `Color.FromArgb(255, 192, 0)`
- **Category**: Appearance
- **Description**: The custom border color (used when Type is Custom).
- **Usage**: Only applies when `Type` is set to `RibbonNotificationBarType.Custom`.

```csharp
kryptonRibbon.NotificationBar.CustomBorderColor = Color.FromArgb(70, 130, 180);
```

#### Layout Properties

##### `Padding` (Padding)
- **Default**: `new Padding(12, 8, 12, 8)`
- **Category**: Layout
- **Description**: The padding around the notification bar content.
- **Usage**: Controls spacing around the notification bar content.

```csharp
kryptonRibbon.NotificationBar.Padding = new Padding(16, 10, 16, 10);
```

##### `Height` (int)
- **Default**: `0` (auto-calculate)
- **Category**: Layout
- **Description**: The height of the notification bar (0 = auto-calculate based on content).
- **Usage**: Set to a specific pixel value to fix the height, or 0 for automatic sizing.

```csharp
kryptonRibbon.NotificationBar.Height = 60; // Fixed height
kryptonRibbon.NotificationBar.Height = 0;  // Auto-calculate
```

#### Behavior Properties

##### `AutoDismissSeconds` (int)
- **Default**: `0` (never auto-dismiss)
- **Category**: Behavior
- **Description**: The number of seconds before the notification bar automatically dismisses (0 = never).
- **Usage**: Set to a positive value to enable auto-dismiss functionality.

```csharp
kryptonRibbon.NotificationBar.AutoDismissSeconds = 5; // Auto-dismiss after 5 seconds
kryptonRibbon.NotificationBar.AutoDismissSeconds = 0;  // Never auto-dismiss
```

---

## Events

### NotificationBarButtonClick Event

**Type**: `EventHandler<RibbonNotificationBarEventArgs>`  
**Raised When**: Any button (action or close) in the notification bar is clicked.

#### RibbonNotificationBarEventArgs

```csharp
public class RibbonNotificationBarEventArgs : EventArgs
{
    /// <summary>
    /// Gets the index of the action button that was clicked, 
    /// or -1 if the close button was clicked.
    /// </summary>
    public int ActionButtonIndex { get; }
}
```

#### Event Handler Example

```csharp
kryptonRibbon.NotificationBarButtonClick += OnNotificationBarButtonClick;

private void OnNotificationBarButtonClick(object? sender, RibbonNotificationBarEventArgs e)
{
    if (e.ActionButtonIndex == -1)
    {
        // Close button was clicked
        MessageBox.Show("Notification closed");
    }
    else
    {
        // Action button was clicked
        // Check if using KryptonCommand or ActionButtonTexts
        string buttonText;
        if (kryptonRibbon.NotificationBar.ActionButtonCommands != null && 
            e.ActionButtonIndex < kryptonRibbon.NotificationBar.ActionButtonCommands.Length)
        {
            var command = kryptonRibbon.NotificationBar.ActionButtonCommands[e.ActionButtonIndex];
            buttonText = command?.Text ?? "Unknown";
        }
        else
        {
            buttonText = kryptonRibbon.NotificationBar.ActionButtonTexts?[e.ActionButtonIndex] ?? "Unknown";
        }
        
        MessageBox.Show($"Button '{buttonText}' (index {e.ActionButtonIndex}) was clicked.");
    }
}
```

#### PropertyChanged Event

The `KryptonRibbonNotificationBarData` class implements `INotifyPropertyChanged`, so you can subscribe to property changes:

```csharp
kryptonRibbon.NotificationBar.PropertyChanged += (sender, e) =>
{
    if (e.PropertyName == nameof(KryptonRibbonNotificationBarData.Visible))
    {
        // Handle visibility change
    }
};
```

---

## Notification Types

### RibbonNotificationBarType Enum

```csharp
public enum RibbonNotificationBarType
{
    Information,  // Blue theme - for general information
    Warning,      // Yellow/Orange theme - for warnings
    Error,        // Red theme - for errors
    Success,      // Green theme - for success messages
    Custom        // Custom colors - use CustomBackColor, CustomForeColor, CustomBorderColor
}
```

### Default Colors

Each notification type has predefined colors:

| Type | Background Color | Border Color |
|------|----------------|--------------|
| **Information** | `#D9ECFF` (217, 236, 255) | `#5B9BD5` (91, 155, 213) |
| **Warning** | `#FFF2CC` (255, 242, 204) | `#FFC000` (255, 192, 0) |
| **Error** | `#FFCCCC` (255, 204, 204) | `#C00000` (192, 0, 0) |
| **Success** | `#CCFFCC` (204, 255, 204) | `#00C000` (0, 192, 0) |
| **Custom** | User-defined | User-defined |

### Usage Examples

#### Information Notification

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
kryptonRibbon.NotificationBar.Text = "New features are available in this update.";
kryptonRibbon.NotificationBar.Visible = true;
```

#### Warning Notification

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Warning;
kryptonRibbon.NotificationBar.Title = "UPDATES AVAILABLE";
kryptonRibbon.NotificationBar.Text = "Updates are ready but blocked by running applications.";
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Update now" };
kryptonRibbon.NotificationBar.Visible = true;
```

#### Error Notification

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Error;
kryptonRibbon.NotificationBar.Text = "Failed to save document. Please try again.";
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Retry", "Cancel" };
kryptonRibbon.NotificationBar.Visible = true;
```

#### Success Notification

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
kryptonRibbon.NotificationBar.Text = "Document saved successfully!";
kryptonRibbon.NotificationBar.AutoDismissSeconds = 3;
kryptonRibbon.NotificationBar.Visible = true;
```

#### Custom Notification

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Custom;
kryptonRibbon.NotificationBar.CustomBackColor = Color.FromArgb(240, 248, 255); // Alice Blue
kryptonRibbon.NotificationBar.CustomForeColor = Color.FromArgb(25, 25, 112);   // Midnight Blue
kryptonRibbon.NotificationBar.CustomBorderColor = Color.FromArgb(70, 130, 180); // Steel Blue
kryptonRibbon.NotificationBar.Text = "Custom-styled notification with brand colors.";
kryptonRibbon.NotificationBar.Visible = true;
```

---

## Using KryptonCommand

The notification bar supports using `KryptonCommand` objects for action buttons, providing enhanced functionality including Execute events, images, and enabled states.

### Benefits of KryptonCommand

- **Execute Events**: Each command can have its own Execute event handler
- **Images**: Commands support `ImageSmall` and `ImageLarge` properties
- **Enabled State**: Commands can be dynamically enabled/disabled
- **Reusability**: Commands can be shared across multiple UI elements
- **Command Pattern**: Follows the standard Krypton command pattern

### Basic Usage

```csharp
// Create commands
var okCommand = new KryptonCommand
{
    Text = "OK",
    ImageSmall = SystemIcons.Information.ToBitmap()
};
okCommand.Execute += (s, e) =>
{
    MessageBox.Show("OK button clicked!");
    kryptonRibbon.NotificationBar.Visible = false;
};

var cancelCommand = new KryptonCommand
{
    Text = "Cancel",
    ImageSmall = SystemIcons.Error.ToBitmap()
};
cancelCommand.Execute += (s, e) =>
{
    kryptonRibbon.NotificationBar.Visible = false;
};

// Assign commands to notification bar
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
kryptonRibbon.NotificationBar.Text = "Please confirm your action.";
kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { okCommand, cancelCommand };
kryptonRibbon.NotificationBar.Visible = true;
```

### Advanced Usage with Multiple Commands

```csharp
// Create commands with different behaviors
var retryCommand = new KryptonCommand
{
    Text = "Retry",
    ImageSmall = SystemIcons.Shield.ToBitmap(),
    Enabled = true
};
retryCommand.Execute += (s, e) =>
{
    // Attempt to save again
    if (SaveDocument())
    {
        kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
        kryptonRibbon.NotificationBar.Text = "Document saved successfully!";
        kryptonRibbon.NotificationBar.ActionButtonCommands = null;
        kryptonRibbon.NotificationBar.AutoDismissSeconds = 3;
    }
};

var saveAsCommand = new KryptonCommand
{
    Text = "Save As",
    ImageSmall = SystemIcons.Application.ToBitmap(),
    Enabled = true
};
saveAsCommand.Execute += (s, e) =>
{
    // Open save dialog
    if (SaveDocumentAs())
    {
        kryptonRibbon.NotificationBar.Visible = false;
    }
};

var discardCommand = new KryptonCommand
{
    Text = "Discard",
    ImageSmall = SystemIcons.Error.ToBitmap(),
    Enabled = true
};
discardCommand.Execute += (s, e) =>
{
    var result = MessageBox.Show(
        "Are you sure you want to discard changes?",
        "Confirm Discard",
        MessageBoxButtons.YesNo,
        MessageBoxIcon.Warning);
    
    if (result == DialogResult.Yes)
    {
        kryptonRibbon.NotificationBar.Visible = false;
    }
};

// Show error notification with commands
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Error;
kryptonRibbon.NotificationBar.Text = "Failed to save document. What would you like to do?";
kryptonRibbon.NotificationBar.ActionButtonCommands = new[] 
{ 
    retryCommand, 
    saveAsCommand, 
    discardCommand 
};
kryptonRibbon.NotificationBar.Visible = true;
```

### Event Handling with KryptonCommand

When using `KryptonCommand`, both events fire:

1. **`KryptonCommand.Execute`**: Fires when the command's Execute event is triggered
2. **`NotificationBarButtonClick`**: Fires when any button is clicked

```csharp
var command = new KryptonCommand { Text = "OK" };

// Command Execute event
command.Execute += (s, e) =>
{
    MessageBox.Show("Command.Execute event fired");
};

// Notification bar button click event
kryptonRibbon.NotificationBarButtonClick += (sender, e) =>
{
    if (e.ActionButtonIndex == 0)
    {
        MessageBox.Show("NotificationBarButtonClick event fired");
    }
};

kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { command };
kryptonRibbon.NotificationBar.Visible = true;
```

**Note**: Both events fire when a button is clicked. The `KryptonCommand.Execute` event fires first, followed by `NotificationBarButtonClick`.

### Priority: ActionButtonCommands vs ActionButtonTexts

If `ActionButtonCommands` is set (not null and has elements), it takes precedence over `ActionButtonTexts`. The `ActionButtonTexts` property is ignored in this case.

```csharp
// This will use ActionButtonCommands, ActionButtonTexts is ignored
kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { command1, command2 };
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "OK", "Cancel" }; // Ignored
```

---

## Advanced Features

### Auto-Dismiss Timer

The notification bar supports automatic dismissal after a specified number of seconds.

```csharp
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
kryptonRibbon.NotificationBar.Text = "Operation completed successfully!";
kryptonRibbon.NotificationBar.ShowActionButtons = false;
kryptonRibbon.NotificationBar.AutoDismissSeconds = 5; // Auto-dismiss after 5 seconds
kryptonRibbon.NotificationBar.Visible = true;
```

**Important Notes**:
- The auto-dismiss timer stops if any button is clicked
- Setting `AutoDismissSeconds` to `0` disables auto-dismiss
- The timer is automatically cleaned up when the notification bar is hidden

### Dynamic Content Updates

You can update the notification bar content while it's visible:

```csharp
// Show initial notification
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
kryptonRibbon.NotificationBar.Text = "Processing...";
kryptonRibbon.NotificationBar.ShowActionButtons = false;
kryptonRibbon.NotificationBar.Visible = true;

// Update content dynamically
var timer = new Timer { Interval = 1000 };
int progress = 0;
timer.Tick += (s, e) =>
{
    progress += 10;
    if (progress <= 100)
    {
        kryptonRibbon.NotificationBar.Text = $"Processing... {progress}%";
    }
    else
    {
        timer.Stop();
        timer.Dispose();
        kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
        kryptonRibbon.NotificationBar.Text = "Processing complete!";
        kryptonRibbon.NotificationBar.AutoDismissSeconds = 3;
    }
};
timer.Start();
```

### Notification Queue

You can implement a notification queue system:

```csharp
private Queue<string> _notificationQueue = new Queue<string>();

private void ShowNextNotification()
{
    if (_notificationQueue.Count == 0)
    {
        return;
    }

    string message = _notificationQueue.Dequeue();
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
    kryptonRibbon.NotificationBar.Text = message;
    kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Next", "Dismiss" };
    kryptonRibbon.NotificationBar.Visible = true;
}

// Handle button clicks
kryptonRibbon.NotificationBarButtonClick += (sender, e) =>
{
    if (e.ActionButtonIndex == 0 && 
        kryptonRibbon.NotificationBar.ActionButtonTexts?[0] == "Next")
    {
        ShowNextNotification();
    }
    else
    {
        _notificationQueue.Clear();
    }
};

// Queue notifications
_notificationQueue.Enqueue("First notification");
_notificationQueue.Enqueue("Second notification");
_notificationQueue.Enqueue("Third notification");
ShowNextNotification();
```

### Custom Height and Padding

Control the notification bar's dimensions:

```csharp
// Fixed height
kryptonRibbon.NotificationBar.Height = 60;

// Custom padding
kryptonRibbon.NotificationBar.Padding = new Padding(20, 12, 20, 12);

// Auto-calculate height
kryptonRibbon.NotificationBar.Height = 0;
```

### Hiding Icon or Buttons

```csharp
// Hide icon
kryptonRibbon.NotificationBar.ShowIcon = false;

// Hide close button
kryptonRibbon.NotificationBar.ShowCloseButton = false;

// Hide action buttons
kryptonRibbon.NotificationBar.ShowActionButtons = false;

// Notification without any buttons (auto-dismiss recommended)
kryptonRibbon.NotificationBar.ShowActionButtons = false;
kryptonRibbon.NotificationBar.ShowCloseButton = false;
kryptonRibbon.NotificationBar.AutoDismissSeconds = 5;
```

---

## Best Practices

### 1. Choose Appropriate Notification Types

- **Information**: General information, tips, non-critical updates
- **Warning**: Important notices that require attention but aren't errors
- **Error**: Critical errors that need immediate attention
- **Success**: Confirmation of successful operations
- **Custom**: Brand-specific styling or special use cases

### 2. Keep Messages Concise

```csharp
// Good: Clear and concise
kryptonRibbon.NotificationBar.Text = "Document saved successfully.";

// Bad: Too verbose
kryptonRibbon.NotificationBar.Text = "Your document has been saved successfully to the location you specified. The file is now available for future editing and sharing.";
```

### 3. Use Titles for Important Notifications

```csharp
// Good: Title provides context
kryptonRibbon.NotificationBar.Title = "UPDATES AVAILABLE";
kryptonRibbon.NotificationBar.Text = "Updates are ready to be applied.";

// Less clear: No title
kryptonRibbon.NotificationBar.Text = "Updates are ready to be applied.";
```

### 4. Provide Action Buttons for User Decisions

```csharp
// Good: User can take action
kryptonRibbon.NotificationBar.Text = "Failed to save document.";
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Retry", "Cancel" };

// Less helpful: No action options
kryptonRibbon.NotificationBar.Text = "Failed to save document.";
kryptonRibbon.NotificationBar.ShowActionButtons = false;
```

### 5. Use Auto-Dismiss for Non-Critical Messages

```csharp
// Good: Success messages can auto-dismiss
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
kryptonRibbon.NotificationBar.Text = "Operation completed.";
kryptonRibbon.NotificationBar.AutoDismissSeconds = 3;

// Important: Critical errors should not auto-dismiss
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Error;
kryptonRibbon.NotificationBar.Text = "Critical error occurred!";
kryptonRibbon.NotificationBar.AutoDismissSeconds = 0; // Never auto-dismiss
```

### 6. Use KryptonCommand for Complex Interactions

```csharp
// Good: Commands provide better separation of concerns
var command = new KryptonCommand { Text = "Retry" };
command.Execute += HandleRetry;
kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { command };

// Less flexible: Direct text-based buttons
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Retry" };
kryptonRibbon.NotificationBarButtonClick += (s, e) => { /* Handle in one place */ };
```

### 7. Clean Up Resources

```csharp
// Good: Unsubscribe from events when done
private void Cleanup()
{
    kryptonRibbon.NotificationBarButtonClick -= OnNotificationBarButtonClick;
    
    // Dispose KryptonCommand objects if created
    if (kryptonRibbon.NotificationBar.ActionButtonCommands != null)
    {
        foreach (var command in kryptonRibbon.NotificationBar.ActionButtonCommands)
        {
            if (command is IDisposable disposable)
            {
                disposable.Dispose();
            }
        }
    }
}
```

### 8. Handle Button Clicks Properly

```csharp
kryptonRibbon.NotificationBarButtonClick += (sender, e) =>
{
    if (e.ActionButtonIndex == -1)
    {
        // Close button - notification is already hidden
        return;
    }
    
    // Action button clicked
    // Check which approach is being used
    if (kryptonRibbon.NotificationBar.ActionButtonCommands != null)
    {
        // Using KryptonCommand - Execute event already fired
        var command = kryptonRibbon.NotificationBar.ActionButtonCommands[e.ActionButtonIndex];
        // Additional handling if needed
    }
    else
    {
        // Using ActionButtonTexts - handle here
        string buttonText = kryptonRibbon.NotificationBar.ActionButtonTexts?[e.ActionButtonIndex] ?? "Unknown";
        HandleButtonClick(buttonText, e.ActionButtonIndex);
    }
};
```

### 9. Localize All User-Facing Text

```csharp
// Good: Use localized strings
kryptonRibbon.NotificationBar.Text = Resources.NotificationSaveSuccess;
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] 
{ 
    Resources.ButtonOK, 
    Resources.ButtonCancel 
};

// Bad: Hard-coded strings
kryptonRibbon.NotificationBar.Text = "Document saved successfully.";
kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "OK", "Cancel" };
```

### 10. Test Auto-Dismiss Behavior

```csharp
// Test that auto-dismiss works correctly
kryptonRibbon.NotificationBar.AutoDismissSeconds = 2;
kryptonRibbon.NotificationBar.Visible = true;

// Verify it dismisses after 2 seconds
// Verify timer stops if button is clicked
```

---

## Code Examples

### Example 1: Basic Information Notification

```csharp
private void ShowBasicInformation()
{
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
    kryptonRibbon.NotificationBar.Text = "This is an informational notification.";
    kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "OK" };
    kryptonRibbon.NotificationBar.Visible = true;
}
```

### Example 2: Warning with Title and Actions

```csharp
private void ShowUpdateWarning()
{
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Warning;
    kryptonRibbon.NotificationBar.Title = "UPDATES AVAILABLE";
    kryptonRibbon.NotificationBar.Text = "Updates for Office are ready to be applied, but are blocked by one or more apps.";
    kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Update now" };
    kryptonRibbon.NotificationBar.Icon = SystemIcons.Warning.ToBitmap();
    kryptonRibbon.NotificationBar.Visible = true;
}
```

### Example 3: Error with Multiple Actions

```csharp
private void ShowSaveError()
{
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Error;
    kryptonRibbon.NotificationBar.Text = "Failed to save document. What would you like to do?";
    kryptonRibbon.NotificationBar.ActionButtonTexts = new[] { "Retry", "Save As", "Discard" };
    kryptonRibbon.NotificationBar.Icon = SystemIcons.Error.ToBitmap();
    kryptonRibbon.NotificationBar.Visible = true;
}

private void HandleSaveErrorButtonClick(object? sender, RibbonNotificationBarEventArgs e)
{
    switch (e.ActionButtonIndex)
    {
        case 0: // Retry
            RetrySave();
            break;
        case 1: // Save As
            SaveDocumentAs();
            break;
        case 2: // Discard
            DiscardChanges();
            break;
    }
}
```

### Example 4: Success with Auto-Dismiss

```csharp
private void ShowSuccessMessage()
{
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
    kryptonRibbon.NotificationBar.Text = "Document saved successfully!";
    kryptonRibbon.NotificationBar.ShowActionButtons = false;
    kryptonRibbon.NotificationBar.AutoDismissSeconds = 3;
    kryptonRibbon.NotificationBar.Visible = true;
}
```

### Example 5: Custom Styled Notification

```csharp
private void ShowCustomNotification()
{
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Custom;
    kryptonRibbon.NotificationBar.CustomBackColor = Color.FromArgb(240, 248, 255); // Alice Blue
    kryptonRibbon.NotificationBar.CustomForeColor = Color.FromArgb(25, 25, 112);       // Midnight Blue
    kryptonRibbon.NotificationBar.CustomBorderColor = Color.FromArgb(70, 130, 180);  // Steel Blue
    kryptonRibbon.NotificationBar.Text = "This is a custom-styled notification with brand colors.";
    kryptonRibbon.NotificationBar.Visible = true;
}
```

### Example 6: Using KryptonCommand

```csharp
private void ShowNotificationWithCommands()
{
    // Create commands
    var learnMoreCommand = new KryptonCommand
    {
        Text = "Learn more",
        ImageSmall = SystemIcons.Question.ToBitmap()
    };
    learnMoreCommand.Execute += (s, e) =>
    {
        MessageBox.Show("Learn more clicked!");
        OpenHelpDocumentation();
    };

    var dismissCommand = new KryptonCommand
    {
        Text = "Dismiss",
        ImageSmall = SystemIcons.Application.ToBitmap()
    };
    dismissCommand.Execute += (s, e) =>
    {
        kryptonRibbon.NotificationBar.Visible = false;
    };

    // Show notification
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
    kryptonRibbon.NotificationBar.Title = "NEW FEATURES";
    kryptonRibbon.NotificationBar.Text = "Check out the latest features in this update!";
    kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { learnMoreCommand, dismissCommand };
    kryptonRibbon.NotificationBar.Visible = true;
}
```

### Example 7: Progress Notification

```csharp
private void ShowProgressNotification()
{
    int progress = 0;
    
    kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Information;
    kryptonRibbon.NotificationBar.Text = "Processing... 0%";
    kryptonRibbon.NotificationBar.ShowActionButtons = false;
    kryptonRibbon.NotificationBar.AutoDismissSeconds = 0;
    kryptonRibbon.NotificationBar.Visible = true;

    var timer = new Timer { Interval = 200 };
    timer.Tick += (s, e) =>
    {
        progress += 5;
        if (progress <= 100)
        {
            kryptonRibbon.NotificationBar.Text = $"Processing... {progress}%";
        }
        else
        {
            timer.Stop();
            timer.Dispose();
            kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Success;
            kryptonRibbon.NotificationBar.Text = "Processing complete!";
            kryptonRibbon.NotificationBar.AutoDismissSeconds = 3;
        }
    };
    timer.Start();
}
```

### Example 8: Complete Event Handling

```csharp
public partial class MainForm : KryptonForm
{
    public MainForm()
    {
        InitializeComponent();
        SetupNotificationBar();
    }

    private void SetupNotificationBar()
    {
        // Subscribe to button click events
        kryptonRibbon.NotificationBarButtonClick += OnNotificationBarButtonClick;
        
        // Subscribe to property changes
        kryptonRibbon.NotificationBar.PropertyChanged += OnNotificationBarPropertyChanged;
    }

    private void OnNotificationBarButtonClick(object? sender, RibbonNotificationBarEventArgs e)
    {
        if (e.ActionButtonIndex == -1)
        {
            // Close button clicked
            LogNotificationAction("Close button clicked");
            return;
        }

        // Action button clicked
        string buttonText = GetButtonText(e.ActionButtonIndex);
        LogNotificationAction($"Action button '{buttonText}' (index {e.ActionButtonIndex}) clicked");
        
        // Handle based on button index
        HandleActionButtonClick(e.ActionButtonIndex);
    }

    private void OnNotificationBarPropertyChanged(object? sender, PropertyChangedEventArgs e)
    {
        switch (e.PropertyName)
        {
            case nameof(KryptonRibbonNotificationBarData.Visible):
                if (kryptonRibbon.NotificationBar.Visible)
                {
                    LogNotificationAction("Notification bar shown");
                }
                else
                {
                    LogNotificationAction("Notification bar hidden");
                }
                break;
        }
    }

    private string GetButtonText(int index)
    {
        if (kryptonRibbon.NotificationBar.ActionButtonCommands != null && 
            index < kryptonRibbon.NotificationBar.ActionButtonCommands.Length)
        {
            return kryptonRibbon.NotificationBar.ActionButtonCommands[index]?.Text ?? "Unknown";
        }
        
        if (kryptonRibbon.NotificationBar.ActionButtonTexts != null && 
            index < kryptonRibbon.NotificationBar.ActionButtonTexts.Length)
        {
            return kryptonRibbon.NotificationBar.ActionButtonTexts[index];
        }
        
        return "Unknown";
    }

    private void HandleActionButtonClick(int index)
    {
        // Implement your button click handling logic
    }

    private void LogNotificationAction(string message)
    {
        // Log notification actions for debugging
        System.Diagnostics.Debug.WriteLine($"[NotificationBar] {message}");
    }
}
```

---

## Troubleshooting

### Issue: Notification Bar Not Visible

**Problem**: Setting `Visible = true` doesn't show the notification bar.

**Solutions**:
1. Ensure the `Text` property is not empty
2. Check that the ribbon control is properly initialized
3. Verify the ribbon is visible and has sufficient space
4. Check for exceptions in the event handlers

```csharp
// Debug visibility
if (!kryptonRibbon.NotificationBar.Visible)
{
    Debug.WriteLine($"Text: '{kryptonRibbon.NotificationBar.Text}'");
    Debug.WriteLine($"Type: {kryptonRibbon.NotificationBar.Type}");
}
```

### Issue: Buttons Not Clickable

**Problem**: Action buttons or close button don't respond to clicks.

**Solutions**:
1. Ensure buttons are enabled (when using `KryptonCommand`, check `Enabled` property)
2. Verify event handlers are properly subscribed
3. Check for overlapping controls
4. Ensure the notification bar is not behind other controls

```csharp
// Debug button state
if (kryptonRibbon.NotificationBar.ActionButtonCommands != null)
{
    foreach (var cmd in kryptonRibbon.NotificationBar.ActionButtonCommands)
    {
        Debug.WriteLine($"Command '{cmd.Text}' Enabled: {cmd.Enabled}");
    }
}
```

### Issue: Auto-Dismiss Not Working

**Problem**: Notification bar doesn't auto-dismiss after specified seconds.

**Solutions**:
1. Verify `AutoDismissSeconds` is set to a positive value
2. Check that the timer isn't being stopped prematurely
3. Ensure the notification bar remains visible (not hidden by other code)
4. Check for exceptions in event handlers that might prevent dismissal

```csharp
// Debug auto-dismiss
Debug.WriteLine($"AutoDismissSeconds: {kryptonRibbon.NotificationBar.AutoDismissSeconds}");
```

### Issue: KryptonCommand Execute Event Not Firing

**Problem**: `KryptonCommand.Execute` event doesn't fire when button is clicked.

**Solutions**:
1. Verify `ActionButtonCommands` is set (not null)
2. Ensure `ActionButtonTexts` is not set (it takes precedence)
3. Check that the command's `Enabled` property is `true`
4. Verify the event handler is properly subscribed

```csharp
// Debug command setup
var command = new KryptonCommand { Text = "Test", Enabled = true };
command.Execute += (s, e) => { Debug.WriteLine("Execute fired!"); };
kryptonRibbon.NotificationBar.ActionButtonCommands = new[] { command };
kryptonRibbon.NotificationBar.ActionButtonTexts = null; // Important!
```

### Issue: Custom Colors Not Applied

**Problem**: Custom colors don't appear when using `Custom` type.

**Solutions**:
1. Ensure `Type` is set to `RibbonNotificationBarType.Custom`
2. Verify custom color properties are set after setting the type
3. Check that colors are valid (not `Color.Empty`)

```csharp
// Correct order
kryptonRibbon.NotificationBar.Type = RibbonNotificationBarType.Custom;
kryptonRibbon.NotificationBar.CustomBackColor = Color.FromArgb(240, 248, 255);
kryptonRibbon.NotificationBar.CustomForeColor = Color.FromArgb(25, 25, 112);
kryptonRibbon.NotificationBar.CustomBorderColor = Color.FromArgb(70, 130, 180);
```

### Issue: Text Not Displaying

**Problem**: Notification bar is visible but text doesn't appear.

**Solutions**:
1. Verify `Text` property is not empty or null
2. Check that foreground color contrasts with background
3. Ensure text is not being clipped (check `Padding` and `Height`)
4. Verify the notification bar has sufficient width

```csharp
// Debug text display
Debug.WriteLine($"Text: '{kryptonRibbon.NotificationBar.Text}'");
Debug.WriteLine($"Title: '{kryptonRibbon.NotificationBar.Title}'");
Debug.WriteLine($"ShowIcon: {kryptonRibbon.NotificationBar.ShowIcon}");
```

### Issue: Memory Leaks with KryptonCommand

**Problem**: Memory leaks when using `KryptonCommand` objects.

**Solutions**:
1. Unsubscribe from `Execute` events when done
2. Dispose `KryptonCommand` objects if they implement `IDisposable`
3. Clear `ActionButtonCommands` when hiding notification
4. Avoid keeping references to commands longer than needed

```csharp
// Clean up commands
private void CleanupCommands()
{
    if (kryptonRibbon.NotificationBar.ActionButtonCommands != null)
    {
        foreach (var command in kryptonRibbon.NotificationBar.ActionButtonCommands)
        {
            // Unsubscribe from events
            command.Execute -= OnCommandExecute;
            
            // Dispose if needed
            if (command is IDisposable disposable)
            {
                disposable.Dispose();
            }
        }
        kryptonRibbon.NotificationBar.ActionButtonCommands = null;
    }
}
```

---

## Summary

The Ribbon Notification Bar is a powerful and flexible component for displaying contextual notifications in Krypton Ribbon applications. Key takeaways:

- **Easy to Use**: Simple API with intuitive properties
- **Highly Customizable**: Support for custom colors, icons, and layouts
- **Event-Driven**: Comprehensive event system for user interactions
- **Command Support**: Full integration with `KryptonCommand` pattern
- **Auto-Dismiss**: Built-in timer support for automatic dismissal
- **DPI Aware**: Automatic scaling for high-DPI displays