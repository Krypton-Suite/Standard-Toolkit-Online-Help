# Krypton Scrollbars

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [API Reference](#api-reference)
4. [Integration Guide](#integration-guide)
5. [Usage Examples](#usage-examples)
6. [Configuration](#configuration)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Overview

The Krypton Scrollbars feature provides a unified solution for replacing native Windows scrollbars with Krypton-themed scrollbars across all scrollable controls in the Krypton Toolkit. This feature ensures visual consistency with the Krypton design system while maintaining full functionality of native scrolling.

### Key Features

- **Unified Theming**: All scrollbars match the current Krypton palette and theme
- **Multiple Integration Modes**: Supports different control types with appropriate integration strategies
- **Global Configuration**: Centralized control via `KryptonManager` for application-wide settings
- **Per-Control Override**: Individual controls can override global settings when needed
- **Automatic Management**: Handles scrollbar creation, positioning, and synchronization automatically
- **Native Scrollbar Hiding**: Automatically hides native scrollbars when Krypton scrollbars are enabled

### Supported Controls

The following controls support Krypton scrollbars:

- `KryptonTextBox` - Text input with native scrollbars
- `KryptonRichTextBox` - Rich text editing with native scrollbars
- `KryptonPropertyGrid` - Property browser with native scrollbars
- `KryptonListBox` - List selection with native scrollbars
- `KryptonListView` - List view with native scrollbars
- `KryptonTreeView` - Tree view with native scrollbars
- `KryptonPanel` - Container with AutoScroll support
- `KryptonGroup` - Group container with AutoScroll support
- `KryptonGroupBox` - Group box container with AutoScroll support
- `KryptonHeaderGroup` - Header group container with AutoScroll support

---

## Architecture

### Core Components

#### KryptonScrollbarManager

The `KryptonScrollbarManager` class is the central component that manages Krypton scrollbars for individual controls. It handles:

- Scrollbar creation and lifecycle management
- Positioning and sizing of scrollbars
- Synchronization with native scroll positions
- Event handling and scroll position updates
- Native scrollbar hiding

**Location**: `Krypton.Toolkit.KryptonScrollbarManager`

#### Integration Modes

The manager supports three distinct integration modes:

##### 1. Container Mode (`ScrollbarManagerMode.Container`)

Used for container controls like `Panel`, `GroupBox`, and `HeaderGroup` that use `AutoScroll`.

**Characteristics**:
- Manages scrolling of child controls within the container
- Tracks child control positions and calculates scroll extents
- Disables native `AutoScroll` and provides manual scrolling
- Stores original child control positions for scroll offset calculation

**Use Cases**:
- `KryptonPanel` with multiple child controls
- `KryptonGroup` with scrollable content
- `KryptonGroupBox` with overflow content

##### 2. Native Wrapper Mode (`ScrollbarManagerMode.NativeWrapper`)

Used for controls with native scrollbars like `TextBox`, `RichTextBox`, `ListBox`, etc.

**Characteristics**:
- Wraps native scrollbar functionality
- Hides native scrollbars via window styles or control properties
- Synchronizes with native scroll positions using Win32 API
- Provides periodic synchronization via timer (50ms interval)
- Maintains scroll position parity with native control

**Use Cases**:
- `KryptonTextBox` with `ScrollBars` property
- `KryptonRichTextBox` with `ScrollBars` property
- `KryptonListBox`, `KryptonListView`, `KryptonTreeView`
- `KryptonPropertyGrid`

##### 3. Custom Mode (`ScrollbarManagerMode.Custom`)

Reserved for future use or custom implementations where the control manages its own scrolling logic.

**Characteristics**:
- No automatic scrollbar management
- Control is responsible for scrollbar creation and management
- Useful for specialized scrolling requirements

### Global Configuration

The `KryptonManager` class provides global settings that affect all controls:

```csharp
// Global static property
KryptonManager.UseKryptonScrollbars = true;

// Instance property (for designer support)
kryptonManager1.GlobalUseKryptonScrollbars = true;
```

**Behavior**:
- When set globally, all supported controls use Krypton scrollbars by default
- Individual controls can override the global setting
- Controls that haven't explicitly set the property inherit the global value
- Changing the global value affects all controls using the default

---

## API Reference

### KryptonScrollbarManager Class

#### Constructors

```csharp
// Default constructor
public KryptonScrollbarManager()

// Constructor with target control
public KryptonScrollbarManager(Control targetControl, ScrollbarManagerMode mode = ScrollbarManagerMode.Container)
```

**Parameters**:
- `targetControl`: The control to attach scrollbars to
- `mode`: The integration mode (Container, NativeWrapper, or Custom)

#### Properties

##### Enabled

```csharp
public bool Enabled { get; set; }
```

Gets or sets whether the scrollbar manager is enabled. When disabled, scrollbars are hidden but not disposed.

**Default**: `true`

##### HorizontalScrollBar

```csharp
public KryptonHScrollBar? HorizontalScrollBar { get; }
```

Gets the horizontal scrollbar instance, if created. Returns `null` if no horizontal scrollbar exists.

##### VerticalScrollBar

```csharp
public KryptonVScrollBar? VerticalScrollBar { get; }
```

Gets the vertical scrollbar instance, if created. Returns `null` if no vertical scrollbar exists.

##### Mode

```csharp
public ScrollbarManagerMode Mode { get; set; }
```

Gets or sets the integration mode. Changing the mode will detach and reattach with the new mode.

**Default**: `ScrollbarManagerMode.Container`

##### TargetControl

```csharp
public Control? TargetControl { get; }
```

Gets the target control this manager is attached to. Returns `null` if not attached.

#### Methods

##### Attach

```csharp
public void Attach(Control targetControl, ScrollbarManagerMode mode = ScrollbarManagerMode.Container)
```

Attaches the manager to a control. If already attached to a different control, detaches first.

**Parameters**:
- `targetControl`: The control to attach to (must not be null)
- `mode`: The integration mode to use

**Exceptions**:
- `ArgumentNullException`: Thrown if `targetControl` is null

##### Detach

```csharp
public void Detach()
```

Detaches the manager from the current control. Restores original scrollbar settings and disposes scrollbars.

##### UpdateScrollbars

```csharp
public void UpdateScrollbars()
```

Forces an update of scrollbars based on current content and visibility requirements. Called automatically on resize and layout events.

#### Events

##### ScrollbarsChanged

```csharp
public event EventHandler? ScrollbarsChanged;
```

Occurs when scrollbars are created, removed, or visibility changes. Useful for UI updates or logging.

#### IDisposable

The manager implements `IDisposable` and should be disposed when no longer needed:

```csharp
public void Dispose()
```

### ScrollbarManagerMode Enumeration

```csharp
public enum ScrollbarManagerMode
{
    Container,      // For controls with AutoScroll (Panel, GroupBox, etc.)
    NativeWrapper,  // For controls with native scrollbars (TextBox, ListBox, etc.)
    Custom          // For custom scrolling implementations
}
```

### Control Integration Properties

Each supported control exposes the following properties:

#### UseKryptonScrollbars

```csharp
public bool UseKryptonScrollbars { get; set; }
```

Gets or sets whether to use Krypton-themed scrollbars. If not explicitly set, uses the global value from `KryptonManager.UseKryptonScrollbars`.

**Default**: Inherits from `KryptonManager.UseKryptonScrollbars` (default: `false`)

**Designer Support**:
- `ShouldSerializeUseKryptonScrollbars()`: Returns `true` only if explicitly set
- `ResetUseKryptonScrollbars()`: Resets to use global value

#### ScrollbarManager

```csharp
public KryptonScrollbarManager? ScrollbarManager { get; }
```

Gets access to the scrollbar manager when `UseKryptonScrollbars` is enabled. Returns `null` if not enabled or manager not created.

**Note**: This property is `Browsable(false)` and not shown in the designer.

### KryptonManager Global Properties

#### UseKryptonScrollbars (Static)

```csharp
public static bool UseKryptonScrollbars { get; set; }
```

Gets or sets the global flag that decides if scrollable controls should use Krypton-themed scrollbars instead of native scrollbars.

**Default**: `false`

#### GlobalUseKryptonScrollbars (Instance)

```csharp
public bool GlobalUseKryptonScrollbars { get; set; }
```

Instance property wrapper for designer support. Maps to the static `UseKryptonScrollbars` property.

---

## Integration Guide

### Enabling Krypton Scrollbars Globally

To enable Krypton scrollbars for all supported controls in your application:

```csharp
// In your application startup code
KryptonManager.UseKryptonScrollbars = true;
```

Or via the designer:
1. Add a `KryptonManager` component to your form
2. Set `GlobalUseKryptonScrollbars` to `true` in the Properties window

### Enabling for Individual Controls

To enable Krypton scrollbars for a specific control:

```csharp
// For a TextBox
kryptonTextBox1.UseKryptonScrollbars = true;

// For a Panel
kryptonPanel1.UseKryptonScrollbars = true;
```

### Programmatic Control

For advanced scenarios, you can access the scrollbar manager directly:

```csharp
if (kryptonTextBox1.UseKryptonScrollbars)
{
    var manager = kryptonTextBox1.ScrollbarManager;
    if (manager != null)
    {
        // Access scrollbars
        var hScroll = manager.HorizontalScrollBar;
        var vScroll = manager.VerticalScrollBar;
        
        // Subscribe to changes
        manager.ScrollbarsChanged += (s, e) => 
        {
            // Handle scrollbar visibility changes
        };
        
        // Update manually if needed
        manager.UpdateScrollbars();
    }
}
```

### Manual Manager Creation

For custom scenarios, you can create and manage a `KryptonScrollbarManager` manually:

```csharp
// Create manager
var manager = new KryptonScrollbarManager(myControl, ScrollbarManagerMode.Container)
{
    Enabled = true
};

// Attach to control (if not done in constructor)
manager.Attach(myControl, ScrollbarManagerMode.Container);

// Later, detach and dispose
manager.Detach();
manager.Dispose();
```

---

## Usage Examples

### Example 1: Basic TextBox with Krypton Scrollbars

```csharp
// Create TextBox
var textBox = new KryptonTextBox
{
    Multiline = true,
    WordWrap = false,
    ScrollBars = ScrollBars.Both,
    UseKryptonScrollbars = true  // Enable Krypton scrollbars
};

// Add to form
this.Controls.Add(textBox);
```

### Example 2: Panel with Scrollable Content

```csharp
// Create Panel
var panel = new KryptonPanel
{
    AutoScroll = true,  // Will be disabled by manager
    UseKryptonScrollbars = true
};

// Add scrollable content
for (int i = 0; i < 20; i++)
{
    var label = new KryptonLabel
    {
        Text = $"Item {i}",
        Location = new Point(10, i * 30 + 10),
        Size = new Size(200, 25)
    };
    panel.Controls.Add(label);
}

this.Controls.Add(panel);
```

### Example 3: Global Enable with Per-Control Override

```csharp
// Enable globally
KryptonManager.UseKryptonScrollbars = true;

// Most controls will use Krypton scrollbars
var textBox1 = new KryptonTextBox { Multiline = true };
var textBox2 = new KryptonTextBox { Multiline = true };

// Override for specific control
textBox2.UseKryptonScrollbars = false;  // Uses native scrollbars

// Reset to global
textBox2.ResetUseKryptonScrollbars();  // Now uses Krypton scrollbars again
```

### Example 4: Monitoring Scrollbar Changes

```csharp
var textBox = new KryptonTextBox
{
    Multiline = true,
    UseKryptonScrollbars = true
};

// Subscribe to scrollbar changes
if (textBox.ScrollbarManager != null)
{
    textBox.ScrollbarManager.ScrollbarsChanged += (s, e) =>
    {
        var manager = (KryptonScrollbarManager)s;
        bool hasHScroll = manager.HorizontalScrollBar?.Visible ?? false;
        bool hasVScroll = manager.VerticalScrollBar?.Visible ?? false;
        
        Console.WriteLine($"H-Scroll: {hasHScroll}, V-Scroll: {hasVScroll}");
    };
}
```

### Example 5: Dynamic Content Updates

```csharp
var panel = new KryptonPanel
{
    UseKryptonScrollbars = true
};

// Add content dynamically
void AddContent()
{
    var label = new KryptonLabel
    {
        Text = $"New Item {panel.Controls.Count}",
        Location = new Point(10, panel.Controls.Count * 30 + 10)
    };
    panel.Controls.Add(label);
    
    // Update scrollbars after content change
    panel.ScrollbarManager?.UpdateScrollbars();
}
```

---

## Configuration

### Default Behavior

- **Global Setting**: `KryptonManager.UseKryptonScrollbars = false`
- **Per-Control**: Inherits global value unless explicitly set
- **Integration Mode**: 
  - Container controls: `Container` mode
  - Native scrollbar controls: `NativeWrapper` mode

### Synchronization Settings

For `NativeWrapper` mode, the manager uses:
- **Sync Timer Interval**: 50ms (hardcoded, not configurable)
- **Scroll Position Sync**: Automatic via Win32 API calls
- **Native Scrollbar Hiding**: Automatic based on control type

### Scrollbar Sizing

Scrollbars use system metrics:
- **Vertical Scrollbar Width**: `SystemInformation.VerticalScrollBarWidth`
- **Horizontal Scrollbar Height**: `SystemInformation.HorizontalScrollBarHeight`

These values are automatically used for positioning and sizing.

---

## Troubleshooting

### Issue: Native Scrollbars Still Visible

**Symptoms**: Both native and Krypton scrollbars are visible simultaneously.

**Causes**:
1. `HideNativeScrollbars()` method not working for the control type
2. Control doesn't support scrollbar hiding via properties
3. Handle not created when hiding is attempted

**Solutions**:
- Ensure the control's handle is created before enabling scrollbars
- For `RichTextBox`, ensure `ScrollBars` property is set correctly
- For `TextBox`, ensure `ScrollBars` property is set correctly
- Check if the control type is supported in `HideNativeScrollbars()`

### Issue: Scrollbars Not Appearing

**Symptoms**: Krypton scrollbars don't appear even when enabled.

**Causes**:
1. Content doesn't require scrolling
2. Manager not properly initialized
3. Control handle not created
4. Manager disabled

**Solutions**:
- Verify content extends beyond control bounds
- Check `ScrollbarManager` property is not null
- Ensure control handle is created (check `IsHandleCreated`)
- Verify `Enabled` property is `true` on the manager
- Call `UpdateScrollbars()` manually if needed

### Issue: Scrollbars Clipped or Positioned Incorrectly

**Symptoms**: Scrollbars are cut off or positioned outside visible area.

**Causes**:
1. Client area calculation issues
2. Padding/borders not accounted for
3. Anchor styles conflicting with manual positioning

**Solutions**:
- The `PositionScrollbars()` method includes bounds checking
- For native wrapper mode, anchors are not used (manual positioning)
- For container mode, anchors are used for automatic resizing
- Check control's `ClientRectangle` vs `ClientSize`

### Issue: Scroll Position Not Syncing

**Symptoms**: Krypton scrollbar position doesn't match native scroll position.

**Causes**:
1. Sync timer not running
2. Native scroll position changed externally
3. `_suppressScrollEvents` flag preventing updates

**Solutions**:
- Verify manager is in `NativeWrapper` mode
- Check sync timer is started (automatic in `NativeWrapper` mode)
- Ensure `UpdateNativeWrapperScrollbars()` is being called
- Check for exceptions in scroll position sync code

### Issue: Performance Problems

**Symptoms**: UI lag or high CPU usage with scrollbars enabled.

**Causes**:
1. Sync timer running too frequently
2. Too many layout updates
3. Scrollbar updates on every resize/layout

**Solutions**:
- Sync timer interval is 50ms (fixed)
- Layout updates are throttled with `_isUpdating` flag
- Consider disabling scrollbars for controls with frequent updates
- Profile to identify specific bottleneck

### Issue: Scrollbars Not Themed Correctly

**Symptoms**: Scrollbars don't match current Krypton theme.

**Causes**:
1. Scrollbars use default Krypton styling
2. Theme changed after scrollbars created
3. Palette not applied correctly

**Solutions**:
- Scrollbars automatically use current global palette
- Recreate scrollbars after theme change (detach/reattach)
- Verify `KryptonManager.GlobalPaletteMode` is set correctly

---

## Best Practices

### 1. Enable Globally, Override Locally

```csharp
// Best: Enable globally for consistency
KryptonManager.UseKryptonScrollbars = true;

// Override only when necessary
specificControl.UseKryptonScrollbars = false;
```

### 2. Initialize Before Adding Content

```csharp
// Good: Set property before adding content
panel.UseKryptonScrollbars = true;
panel.Controls.Add(content);

// Better: Set before control is shown
panel.UseKryptonScrollbars = true;
// ... add content ...
this.Controls.Add(panel);
```

### 3. Handle Lifecycle Properly

```csharp
// The manager is automatically disposed when:
// 1. Control is disposed
// 2. UseKryptonScrollbars is set to false
// 3. Manager.Detach() is called

// Manual cleanup only needed for manually created managers
var manager = new KryptonScrollbarManager(control);
// ... use manager ...
manager.Dispose();  // Required for manual creation
```

### 4. Update After Dynamic Content Changes

```csharp
// When adding/removing content dynamically
panel.Controls.Add(newControl);

// Update scrollbars to reflect new content
panel.ScrollbarManager?.UpdateScrollbars();
```

### 5. Check Manager Availability

```csharp
// Always check if manager exists before accessing
if (control.UseKryptonScrollbars && control.ScrollbarManager != null)
{
    var scrollbar = control.ScrollbarManager.HorizontalScrollBar;
    // Use scrollbar safely
}
```

### 6. Use Appropriate Mode

```csharp
// Container controls should use Container mode
var manager = new KryptonScrollbarManager(panel, ScrollbarManagerMode.Container);

// Native scrollbar controls should use NativeWrapper mode
var manager = new KryptonScrollbarManager(textBox, ScrollbarManagerMode.NativeWrapper);
```

### 7. Monitor for Changes

```csharp
// Subscribe to scrollbar changes for UI updates
manager.ScrollbarsChanged += (s, e) =>
{
    // Update UI based on scrollbar visibility
    UpdateLayout();
};
```

### 8. Test with Different Content Sizes

```csharp
// Test with:
// - Content smaller than control (no scrollbars)
// - Content requiring horizontal scrollbar only
// - Content requiring vertical scrollbar only
// - Content requiring both scrollbars
// - Very large content (stress test)
```

---

## Implementation Details

### Scrollbar Positioning Algorithm

The `PositionScrollbars()` method ensures scrollbars are positioned within bounds:

```csharp
// Horizontal scrollbar
int hScrollY = clientRect.Bottom - scrollbarHeight;
int hScrollWidth = clientRect.Width - (verticalScrollbarVisible ? scrollbarWidth : 0);
hScrollY = Math.Max(clientRect.Top, Math.Min(hScrollY, clientRect.Bottom - 1));
hScrollWidth = Math.Max(0, Math.Min(hScrollWidth, clientRect.Width));

// Vertical scrollbar
int vScrollX = clientRect.Right - scrollbarWidth;
int vScrollHeight = clientRect.Height - (horizontalScrollbarVisible ? scrollbarHeight : 0);
vScrollX = Math.Max(clientRect.Left, Math.Min(vScrollX, clientRect.Right - 1));
vScrollHeight = Math.Max(0, Math.Min(vScrollHeight, clientRect.Height));
```

### Native Scrollbar Hiding

Different strategies for different control types:

```csharp
// RichTextBox: Use ScrollBars property
richTextBox.ScrollBars = RichTextBoxScrollBars.None;

// TextBox: Use ScrollBars property
textBox.ScrollBars = ScrollBars.None;

// Other controls: Use window styles
uint style = PI.GetWindowLong(handle, PI.GWL_.STYLE);
style &= ~(uint)PI.WS_.HSCROLL;
style &= ~(uint)PI.WS_.VSCROLL;
PI.SetWindowLong(handle, PI.GWL_.STYLE, style);
```

### Scroll Position Synchronization

For `NativeWrapper` mode, positions are synchronized using Win32 API:

```csharp
// Get native scroll position
PI.GetScrollInfo(handle, PI.SB_.HORZ, ref hScrollInfo);
PI.GetScrollInfo(handle, PI.SB_.VERT, ref vScrollInfo);

// Set Krypton scrollbar position
horizontalScrollBar.Value = hScrollInfo.nPos;
verticalScrollBar.Value = vScrollInfo.nPos;

// Sync back when user scrolls Krypton scrollbar
PI.SetScrollPos(handle, scrollBar, value, true);
PI.SendMessage(handle, WM_.HSCROLL, ...);
```