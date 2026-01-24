# Detachable Ribbon

## Overview

The Detachable Ribbon feature allows `KryptonRibbon` controls to be dynamically moved from their parent form into a floating window, providing users with the flexibility to reposition the ribbon interface according to their workflow preferences. This feature is particularly useful in scenarios where screen real estate is limited or when users want to customize their workspace layout.

### Key Benefits

- **Flexible Workspace Layout**: Users can detach the ribbon to free up vertical space on the main form
- **Multi-Monitor Support**: Detached ribbons can be moved to secondary monitors
- **Customizable UI**: Provides a foundation for advanced UI customization features
- **Seamless Integration**: Automatically handles form integration state changes
- **Event-Driven Architecture**: Comprehensive event system for monitoring state changes

---

## API Reference

### Properties

#### `AllowDetach`

**Type**: `bool`  
**Default**: `false`  
**Category**: `Behavior`  
**Access**: Read/Write

Enables or disables the ability to detach the ribbon into a floating window.

```csharp
// Enable detach functionality
kryptonRibbon.AllowDetach = true;

// Disable detach functionality
kryptonRibbon.AllowDetach = false;
```

**Behavior**:
- When set to `false` while the ribbon is detached, the ribbon will automatically reattach to its original parent
- This property must be `true` before calling `Detach()`

**Design Considerations**:
- Set this property at design time or during form initialization
- Consider user preferences and application requirements before enabling

---

#### `IsDetached`

**Type**: `bool`  
**Default**: `false`  
**Category**: `Runtime`  
**Access**: Read-Only

Indicates whether the ribbon is currently detached and hosted in a floating window.

---

#### `FloatingWindowText`

**Type**: `string`  
**Default**: `"Ribbon"` (or localized string from `KryptonManager.Strings.MiscellaneousStrings.RibbonFloatingWindowText`)  
**Category**: `Appearance`  
**Access**: Read/Write  
**Localizable**: `true`

Gets or sets the text displayed in the floating window's title bar.

```csharp
// Set custom text for the floating window
kryptonRibbon.FloatingWindowText = "My Application Ribbon";

// Use localized string
kryptonRibbon.FloatingWindowText = KryptonManager.Strings.MiscellaneousStrings.RibbonFloatingWindowText;
```

**Usage Notes**:
- This property is used when the ribbon is detached into a floating window
- The text appears in the floating window's title bar
- Defaults to "Ribbon" if not set
- Can be localized for multi-language support

---

#### `SavePreferencesOnStateChange`

**Type**: `bool`  
**Default**: `true`  
**Category**: `Behavior`  
**Access**: Read/Write

Gets or sets a value indicating whether preferences are automatically saved when the detached state changes.

```csharp
// Enable automatic preference saving (default)
kryptonRibbon.SavePreferencesOnStateChange = true;

// Disable automatic preference saving
kryptonRibbon.SavePreferencesOnStateChange = false;
```

**Usage Notes**:
- When `true`, preferences are automatically saved when the ribbon is detached or reattached
- When `true`, preferences are also saved when the floating window position changes
- Set to `false` if you want to manually control when preferences are saved
- Preferences are saved via the `DetachPreferencesChanged` event

```csharp
// Check if ribbon is detached
if (kryptonRibbon.IsDetached)
{
    // Ribbon is in floating window
    Console.WriteLine("Ribbon is currently detached");
}
else
{
    // Ribbon is attached to parent form
    Console.WriteLine("Ribbon is attached to form");
}
```

**Usage Notes**:
- This property is automatically maintained by the ribbon control
- Use this property to update UI elements that depend on ribbon state
- Always check this property before calling `Reattach()` to avoid unnecessary operations

---

### Methods

#### `Detach()`

**Signature**: `public bool Detach()`

Detaches the ribbon from its current parent and moves it into a floating window.

**Returns**: `true` if the ribbon was successfully detached; otherwise, `false`

**Preconditions**:
- `AllowDetach` must be `true`
- Ribbon must have a valid parent control
- Ribbon must not already be detached
- Parent must be contained within a `Form` instance

**Postconditions**:
- Ribbon is removed from original parent
- Ribbon is added to a new `VisualRibbonFloatingWindow`
- Original state (parent, location, size, dock) is preserved
- Form integration is disabled (via `PreventIntegration`)
- `RibbonDetached` event is raised

**Example**:
```csharp
// Enable detach and detach the ribbon
kryptonRibbon.AllowDetach = true;

if (kryptonRibbon.Detach())
{
    MessageBox.Show("Ribbon successfully detached!");
}
else
{
    MessageBox.Show("Failed to detach ribbon. Check AllowDetach property.");
}
```

**Error Handling**:
- Returns `false` if any precondition fails
- Automatically attempts to restore state if an error occurs during detachment
- Throws no exceptions; all errors are handled gracefully

**State Preservation**:
The following properties are automatically preserved and restored during reattachment:
- Original parent control reference
- Original `Location` (Point)
- Original `Size` (Size)
- Original `Dock` style (DockStyle)

---

#### `Reattach()`

**Signature**: `public bool Reattach()`

Reattaches the ribbon to its original parent, closing the floating window.

**Returns**: `true` if the ribbon was successfully reattached; otherwise, `false`

**Preconditions**:
- Ribbon must currently be detached (`IsDetached == true`)
- Original parent must still be valid
- Floating window must exist and be accessible

**Postconditions**:
- Ribbon is removed from floating window
- Ribbon is added back to original parent
- Original state (location, size, dock) is restored
- Form integration is re-enabled
- Floating window is closed and disposed
- `RibbonReattached` event is raised

**Example**:
```csharp
if (kryptonRibbon.IsDetached)
{
    if (kryptonRibbon.Reattach())
    {
        MessageBox.Show("Ribbon successfully reattached!");
    }
    else
    {
        MessageBox.Show("Failed to reattach ribbon.");
    }
}
```

**Error Handling**:
- Returns `false` if ribbon is not currently detached
- Returns `false` if original parent is no longer valid
- All errors are handled gracefully without exceptions

**Automatic Reattachment**:
The ribbon automatically reattaches when:
- The floating window is closed by the user
- The floating window's title bar is double-clicked
- The floating window is disposed
- `AllowDetach` is set to `false` while detached

**User Interaction**:
- **Double-Click Title Bar**: Double-clicking the floating window's title bar reattaches the ribbon
- **Double-Click Caption Area**: When attached, double-clicking the ribbon's caption area detaches it (if `AllowDetach` is enabled)

---

#### `SaveDetachPreferences()`

**Signature**: `public void SaveDetachPreferences()`

Saves the current detach preferences (detached state and window position).

**Remarks**:
- This method raises the `DetachPreferencesChanged` event, allowing applications to persist the preferences using their preferred storage mechanism (Settings, Registry, file, etc.)
- Automatically called when `SavePreferencesOnStateChange` is `true` and the state changes
- Can be called manually to save preferences at any time

**Example**:
```csharp
// Manually save preferences
kryptonRibbon.SaveDetachPreferences();
```

---

#### `LoadDetachPreferences()`

**Signature**: `public bool LoadDetachPreferences(bool isDetached, Point? floatingWindowPosition = null)`

Loads and restores the detach preferences (detached state and window position).

**Parameters**:
- `isDetached`: The saved detached state
- `floatingWindowPosition`: The saved floating window position, or `null` if not saved

**Returns**: `true` if preferences were successfully loaded; otherwise `false`

**Remarks**:
- Call this method during form initialization to restore the previous state
- If `isDetached` is `true`, the ribbon will be detached after the form is loaded
- If `floatingWindowPosition` is provided, the floating window will be positioned at that location
- The position is automatically validated to ensure it's on a visible screen (multi-monitor support)

**Example**:
```csharp
// Load saved preferences
bool wasDetached = Properties.Settings.Default.RibbonDetached;
Point? savedPosition = null;

if (Properties.Settings.Default.RibbonFloatingX != 0 || 
    Properties.Settings.Default.RibbonFloatingY != 0)
{
    savedPosition = new Point(
        Properties.Settings.Default.RibbonFloatingX,
        Properties.Settings.Default.RibbonFloatingY);
}

kryptonRibbon.LoadDetachPreferences(wasDetached, savedPosition);
```

---

### Events

#### `RibbonDetached`

**Type**: `EventHandler`  
**Category**: `Action`

Raised when the ribbon is successfully detached into a floating window.

**Event Arguments**: `EventArgs` (empty)

**Usage**:
```csharp
kryptonRibbon.RibbonDetached += OnRibbonDetached;

private void OnRibbonDetached(object? sender, EventArgs e)
{
    // Update UI to reflect detached state
    UpdateRibbonStateUI();
    
    // Log the action
    Logger.Info("Ribbon detached by user");
    
    // Save user preference
    SaveUserPreference("RibbonDetached", true);
}
```

**When to Use**:
- Update UI elements that depend on ribbon state
- Save user preferences
- Log user actions
- Update menu items or toolbar buttons
- Trigger other UI updates

**Best Practices**:
- Keep event handlers lightweight
- Avoid blocking operations
- Use for UI updates and preference saving
- Consider using async operations for I/O

---

#### `RibbonReattached`

**Type**: `EventHandler`  
**Category**: `Action`

Raised when the ribbon is successfully reattached to its original parent.

**Event Arguments**: `EventArgs` (empty)

**Usage**:
```csharp
kryptonRibbon.RibbonReattached += OnRibbonReattached;

private void OnRibbonReattached(object? sender, EventArgs e)
{
    // Update UI to reflect attached state
    UpdateRibbonStateUI();
    
    // Log the action
    Logger.Info("Ribbon reattached by user");
    
    // Save user preference
    SaveUserPreference("RibbonDetached", false);
    
    // Ensure form layout is correct
    PerformLayout();
}
```

**When to Use**:
- Update UI elements that depend on ribbon state
- Save user preferences
- Log user actions
- Perform layout updates
- Restore form state

**Best Practices**:
- Perform layout updates after reattachment
- Save user preferences for persistence
- Update any dependent UI elements
- Consider form focus management

---

#### `DetachPreferencesChanged`

**Type**: `EventHandler<DetachPreferencesEventArgs>`  
**Category**: `Action`

Occurs when preferences should be saved (detached state and window position).

**Event Arguments**: `DetachPreferencesEventArgs`

**Usage**:
```csharp
kryptonRibbon.DetachPreferencesChanged += OnDetachPreferencesChanged;

private void OnDetachPreferencesChanged(object? sender, DetachPreferencesEventArgs e)
{
    // Save to Settings
    Properties.Settings.Default.RibbonDetached = e.IsDetached;
    if (e.FloatingWindowPosition.HasValue)
    {
        Properties.Settings.Default.RibbonFloatingX = e.FloatingWindowPosition.Value.X;
        Properties.Settings.Default.RibbonFloatingY = e.FloatingWindowPosition.Value.Y;
    }
    Properties.Settings.Default.Save();
}
```

**When to Use**:
- Persist user preferences across application sessions
- Save detached state and window position
- Implement custom storage mechanisms (Registry, file, database, etc.)

**Best Practices**:
- Handle this event to save preferences to your preferred storage mechanism
- The event is automatically raised when state changes if `SavePreferencesOnStateChange` is `true`
- You can also call `SaveDetachPreferences()` manually to trigger this event

**Event Arguments**:
- `IsDetached`: Indicates whether the ribbon is currently detached
- `FloatingWindowPosition`: The saved position of the floating window, or `null` if not saved

---

## VisualRibbonFloatingWindow Class

### Overview

`VisualRibbonFloatingWindow` is a specialized form class that hosts detached ribbons. It extends `KryptonForm` and provides a floating window specifically designed for ribbon controls.

### Properties

#### `Ribbon`

**Type**: `KryptonRibbon?`  
**Access**: Read-Only

Gets access to the contained ribbon control.

```csharp
if (floatingWindow.Ribbon != null)
{
    // Access ribbon properties
    var tabCount = floatingWindow.Ribbon.RibbonTabs.Count;
}
```

### Events

#### `WindowClosing`

**Type**: `EventHandler`  
**Category**: `Action`

Occurs when the floating window is closing, allowing the ribbon to be reattached before the window is disposed.

**Usage**:
```csharp
floatingWindow.WindowClosing += (sender, e) =>
{
    // Ribbon will automatically reattach
    // Perform any additional cleanup here
};
```

**Note**: The ribbon automatically reattaches when this event is raised. You typically don't need to handle this event unless you need custom cleanup logic.

---

#### `TitleBarDoubleClick`

**Type**: `EventHandler`  
**Category**: `Action`

Occurs when the floating window's title bar is double-clicked, allowing the ribbon to be reattached.

**Usage**:
```csharp
floatingWindow.TitleBarDoubleClick += (sender, e) =>
{
    // Ribbon will automatically reattach
    // This provides a convenient way to reattach via double-click
};
```

**Note**: The ribbon automatically reattaches when this event is raised. This provides a user-friendly way to reattach the ribbon by double-clicking the title bar, similar to standard Windows behavior.

### Window Characteristics

- **Form Border**: `FixedToolWindow` - Provides a fixed-size tool window appearance
- **Show in Taskbar**: `false` - Window does not appear in taskbar
- **Minimize/Maximize**: Disabled - Window cannot be minimized or maximized
- **Owner**: Set to the original form - Minimizing owner also minimizes floating window
- **Title**: Uses `FloatingWindowText` property (defaults to "Ribbon" or localized string)
- **Double-Click Title Bar**: Automatically reattaches the ribbon

### Window Sizing

The floating window automatically sizes itself to fit the ribbon:
- Minimum width: 400 pixels
- Height: Ribbon height + caption bar height
- Width: Ribbon width (if > 400px) or 400px minimum

---

## Implementation Details

### State Management

The detachable ribbons feature maintains comprehensive state information:

#### Preserved State

When detaching, the following state is preserved:
```csharp
_originalParent    // Control reference
_originalLocation  // Point
_originalSize      // Size
_originalDock      // DockStyle
```

#### Form Integration

The ribbon's form integration is automatically managed:
- **When Detached**: `CaptionArea.PreventIntegration = true`
- **When Reattached**: `CaptionArea.PreventIntegration = false`

This ensures the ribbon displays correctly in both attached and detached states.

### Lifecycle Management

#### Detachment Process

1. Validate preconditions (`AllowDetach`, parent exists, not already detached)
2. Store original state (parent, location, size, dock)
3. Create `VisualRibbonFloatingWindow` instance
4. Hook up `WindowClosing` and `TitleBarDoubleClick` events
5. Set `PreventIntegration = true` on caption area
6. Remove ribbon from original parent
7. Add ribbon to floating window
8. Set ribbon dock style to `Top`
9. Show floating window
10. Raise `RibbonDetached` event

#### Reattachment Process

1. Validate preconditions (is detached, floating window exists, original parent valid)
2. Remove ribbon from floating window
3. Unhook `WindowClosing` and `TitleBarDoubleClick` events
4. Close and dispose floating window
5. Restore original state (dock, location, size)
6. Set `PreventIntegration = false` on caption area
7. Add ribbon back to original parent
8. Clear stored state
9. Raise `RibbonReattached` event

### Disposal Handling

The ribbon control properly handles disposal:

```csharp
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // Clean up floating window if detached
        if (_floatingWindow != null && !_floatingWindow.IsDisposed)
        {
            _floatingWindow.WindowClosing -= OnFloatingWindowClosing;
            _floatingWindow.Close();
            _floatingWindow.Dispose();
            _floatingWindow = null;
        }
        // ... other disposal code
    }
    base.Dispose(disposing);
}
```

**Important**: The ribbon is never disposed when in a floating window. It is always reattached or the floating window is cleaned up during ribbon disposal.

---

## Usage Examples

### Basic Usage

#### Example 1: Simple Detach/Reattach

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;

    public MainForm()
    {
        InitializeComponent();
        
        // Create and configure ribbon
        _ribbon = new KryptonRibbon
        {
            Dock = DockStyle.Top,
            AllowDetach = true  // Enable detach functionality
        };
        
        // Add ribbon tabs, groups, etc.
        InitializeRibbon();
        
        Controls.Add(_ribbon);
    }

    private void DetachRibbon()
    {
        if (_ribbon.Detach())
        {
            MessageBox.Show("Ribbon detached successfully!");
        }
    }

    private void ReattachRibbon()
    {
        if (_ribbon.Reattach())
        {
            MessageBox.Show("Ribbon reattached successfully!");
        }
    }
}
```

---

### Advanced Usage

#### Example 2: Context Menu Integration

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;
    private ToolStripMenuItem _detachMenuItem;
    private ToolStripMenuItem _reattachMenuItem;

    public MainForm()
    {
        InitializeComponent();
        InitializeRibbon();
        CreateContextMenu();
    }

    private void CreateContextMenu()
    {
        var contextMenu = new ContextMenuStrip();
        
        _detachMenuItem = new ToolStripMenuItem("Detach Ribbon")
        {
            Enabled = !_ribbon.IsDetached
        };
        _detachMenuItem.Click += (s, e) => _ribbon.Detach();
        
        _reattachMenuItem = new ToolStripMenuItem("Reattach Ribbon")
        {
            Enabled = _ribbon.IsDetached
        };
        _reattachMenuItem.Click += (s, e) => _ribbon.Reattach();
        
        contextMenu.Items.Add(_detachMenuItem);
        contextMenu.Items.Add(_reattachMenuItem);
        
        // Attach to ribbon or form
        _ribbon.ContextMenuStrip = contextMenu;
        
        // Update menu when state changes
        _ribbon.RibbonDetached += (s, e) => UpdateContextMenu();
        _ribbon.RibbonReattached += (s, e) => UpdateContextMenu();
    }

    private void UpdateContextMenu()
    {
        _detachMenuItem.Enabled = !_ribbon.IsDetached;
        _reattachMenuItem.Enabled = _ribbon.IsDetached;
    }
}
```

---

#### Example 3: User Preference Persistence

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;
    private const string PREF_RIBBON_DETACHED = "RibbonDetached";

    public MainForm()
    {
        InitializeComponent();
        InitializeRibbon();
        LoadUserPreferences();
        HookEvents();
    }

    private void LoadUserPreferences()
    {
        // Load saved preference
        bool wasDetached = Properties.Settings.Default.RibbonDetached;
        
        _ribbon.AllowDetach = true;
        
        // Restore previous state
        if (wasDetached)
        {
            // Small delay to ensure form is fully loaded
            BeginInvoke(new Action(() => _ribbon.Detach()));
        }
    }

    private void HookEvents()
    {
        _ribbon.RibbonDetached += (s, e) =>
        {
            Properties.Settings.Default.RibbonDetached = true;
            Properties.Settings.Default.Save();
        };

        _ribbon.RibbonReattached += (s, e) =>
        {
            Properties.Settings.Default.RibbonDetached = false;
            Properties.Settings.Default.Save();
        };
    }
}
```

---

#### Example 4: Multi-Form Application

```csharp
public class RibbonManager
{
    private KryptonRibbon _sharedRibbon;
    private Form _mainForm;

    public RibbonManager(KryptonRibbon ribbon, Form mainForm)
    {
        _sharedRibbon = ribbon;
        _mainForm = mainForm;
        
        _sharedRibbon.AllowDetach = true;
        _sharedRibbon.RibbonDetached += OnRibbonDetached;
        _sharedRibbon.RibbonReattached += OnRibbonReattached;
    }

    private void OnRibbonDetached(object? sender, EventArgs e)
    {
        // Notify all forms that ribbon is detached
        NotifyForms("RibbonDetached");
        
        // Update main form layout
        _mainForm.PerformLayout();
    }

    private void OnRibbonReattached(object? sender, EventArgs e)
    {
        // Notify all forms that ribbon is reattached
        NotifyForms("RibbonReattached");
        
        // Update main form layout
        _mainForm.PerformLayout();
    }

    private void NotifyForms(string eventName)
    {
        foreach (Form form in Application.OpenForms)
        {
            if (form is IFormWithRibbon formWithRibbon)
            {
                formWithRibbon.OnRibbonStateChanged(eventName);
            }
        }
    }

    public void DetachRibbon() => _sharedRibbon.Detach();
    public void ReattachRibbon() => _sharedRibbon.Reattach();
    public bool IsRibbonDetached => _sharedRibbon.IsDetached;
}

public interface IFormWithRibbon
{
    void OnRibbonStateChanged(string eventName);
}
```

---

#### Example 5: Conditional Detach Based on Screen Size

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;

    public MainForm()
    {
        InitializeComponent();
        InitializeRibbon();
        CheckScreenSize();
    }

    private void CheckScreenSize()
    {
        // Get primary screen working area
        var screen = Screen.PrimaryScreen;
        var workingArea = screen.WorkingArea;
        
        // If screen height is less than 768px, suggest detaching ribbon
        if (workingArea.Height < 768)
        {
            var result = MessageBox.Show(
                "Your screen height is limited. Would you like to detach the ribbon to save space?",
                "Optimize Layout",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            
            if (result == DialogResult.Yes)
            {
                _ribbon.AllowDetach = true;
                _ribbon.Detach();
            }
        }
    }
}
```

---

## Best Practices

### 1. Enable Detach at Design Time

Set `AllowDetach = true` in the designer or during form initialization:

```csharp
// Good: Set during initialization
public MainForm()
{
    InitializeComponent();
    kryptonRibbon1.AllowDetach = true;
}

// Avoid: Setting dynamically based on user actions (unless necessary)
private void SomeEventHandler(object sender, EventArgs e)
{
    kryptonRibbon1.AllowDetach = true;  // Not recommended
}
```

### 2. Check State Before Operations

Always verify the ribbon state before performing operations:

```csharp
// Good: Check state first
if (kryptonRibbon1.IsDetached)
{
    kryptonRibbon1.Reattach();
}

// Avoid: Assuming state
kryptonRibbon1.Reattach();  // May fail if not detached
```

### 3. Handle Events for UI Updates

Use events to keep UI synchronized with ribbon state:

```csharp
// Good: Update UI via events
kryptonRibbon1.RibbonDetached += (s, e) => UpdateUI();
kryptonRibbon1.RibbonReattached += (s, e) => UpdateUI();

// Avoid: Polling state
private void Timer_Tick(object sender, EventArgs e)
{
    if (kryptonRibbon1.IsDetached)  // Not recommended
    {
        UpdateUI();
    }
}
```

### 4. Save User Preferences

Persist user's detach preference:

```csharp
// Good: Save preference
kryptonRibbon1.RibbonDetached += (s, e) =>
{
    Properties.Settings.Default.RibbonDetached = true;
    Properties.Settings.Default.Save();
};
```

### 5. Perform Layout After Reattachment

Update form layout after reattachment:

```csharp
kryptonRibbon1.RibbonReattached += (s, e) =>
{
    PerformLayout();
    Invalidate();
};
```

### 6. Handle Multiple Ribbons

If your application has multiple ribbons, manage them independently:

```csharp
private void DetachAllRibbons()
{
    foreach (var ribbon in GetAllRibbons())
    {
        if (ribbon.AllowDetach && !ribbon.IsDetached)
        {
            ribbon.Detach();
        }
    }
}
```

---

## Known Limitations and Considerations

### 1. Single Detach Instance

- Only one floating window can exist per ribbon instance
- Attempting to detach an already-detached ribbon will return `false`

### 2. Parent Form Requirement

- The ribbon must be parented to a control that is ultimately contained within a `Form`
- Detaching from a `UserControl` without a form parent will fail

### 3. Form Integration

- When detached, form integration is automatically disabled
- The ribbon will not integrate with the form's caption area when detached
- Integration is automatically restored upon reattachment

### 4. Docking Behavior

- Detached ribbons are always docked to the top of the floating window
- Original dock style is preserved and restored upon reattachment

### 5. Window Management

- Floating windows do not appear in the taskbar
- Floating windows are owned by the original form
- Minimizing the owner form also minimizes the floating window

### 6. State Persistence

- Original state (location, size, dock) is preserved in memory only during the session
- **Preference persistence is available** via `DetachPreferencesChanged` event and `LoadDetachPreferences()` method
- Use `SaveDetachPreferences()` or handle `DetachPreferencesChanged` event to save state across sessions
- Window position is automatically tracked and can be saved/restored
- Multi-monitor position validation is built-in when using `LoadDetachPreferences()`

### 7. Multiple Monitors

- Floating windows can be moved to secondary monitors
- **Window position is automatically tracked** and can be saved via `DetachPreferencesChanged` event
- **Position validation for multi-monitor setups is built-in** when using `LoadDetachPreferences()` method
- The `RestoreFloatingWindowPosition()` method ensures windows are positioned on visible screens

### 8. Design Time

- Detach functionality is not available at design time
- `AllowDetach` can be set in the designer, but `Detach()` must be called at runtime

### 9. Custom Buttons

- Custom buttons can be added next to the expand/collapse button using the `ButtonSpecs` collection
- Buttons are added to the ribbon's tabs area and appear automatically
- Use `ButtonSpecAny` with `Edge = PaletteRelativeEdgeAlign.Far` to place buttons on the right side
- Buttons can toggle visibility based on ribbon state (attached/detached)

---

## Troubleshooting

### Ribbon Won't Detach

**Problem**: `Detach()` returns `false`

**Possible Causes**:
1. `AllowDetach` is `false`
   - **Solution**: Set `kryptonRibbon.AllowDetach = true`

2. Ribbon is already detached
   - **Solution**: Check `IsDetached` property before calling `Detach()`

3. Ribbon has no parent
   - **Solution**: Ensure ribbon is added to a parent control before detaching

4. Parent is not in a Form
   - **Solution**: Ensure the ribbon's parent hierarchy includes a `Form`

### Ribbon Won't Reattach

**Problem**: `Reattach()` returns `false`

**Possible Causes**:
1. Ribbon is not currently detached
   - **Solution**: Check `IsDetached` property

2. Original parent was disposed
   - **Solution**: Ensure original parent still exists

3. Floating window was manually disposed
   - **Solution**: Let the ribbon manage the floating window lifecycle

### Floating Window Appears Incorrectly Sized

**Problem**: Floating window is too small or too large

**Possible Causes**:
1. Ribbon size not calculated correctly
   - **Solution**: Ensure ribbon has been laid out before detaching

2. DPI scaling issues
   - **Solution**: Check DPI awareness settings

**Workaround**:
```csharp
// Force layout before detaching
kryptonRibbon.PerformLayout();
kryptonRibbon.Detach();
```

### Form Integration Issues After Reattachment

**Problem**: Ribbon doesn't integrate with form caption after reattachment

**Possible Causes**:
1. Form integration was manually disabled
   - **Solution**: The feature automatically manages integration; avoid manual changes

2. Form is not a `KryptonForm`
   - **Solution**: Ensure parent form is a `KryptonForm` for integration to work

---

## Performance Considerations

### Memory

- Floating windows are lightweight and consume minimal memory
- Ribbon state is stored in simple value types (Point, Size, DockStyle)
- No significant memory overhead for detached ribbons

### CPU

- Detach/reattach operations are O(1) complexity
- No performance impact during normal ribbon operation
- Layout operations may trigger during state changes

### Recommendations

- Avoid frequent detach/reattach operations
- Cache user preferences to avoid repeated operations
- Perform layout updates asynchronously if needed

---

## Migration Guide

### Upgrading Existing Applications

If you're adding detachable ribbons to an existing application:

1. **Enable the Feature**:
   ```csharp
   kryptonRibbon.AllowDetach = true;
   ```

2. **Handle Events** (Optional):
   ```csharp
   kryptonRibbon.RibbonDetached += OnRibbonDetached;
   kryptonRibbon.RibbonReattached += OnRibbonReattached;
   ```

3. **Add UI Controls** (Optional):
   - Add buttons or menu items to trigger detach/reattach
   - Update UI based on ribbon state

4. **Save Preferences** (Recommended):
   - Save detach state in user settings
   - Restore state on application startup

## See Also

- [Detachable Ribbon API Reference](KryptonDetachableRibbonAPIReference.md)
- [Detachable Ribbon Examples](KryptonDetachableRibbonExamples.md)