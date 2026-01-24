# Detachable Ribbons - API Quick Reference

## Quick Start

```csharp
// Enable detach functionality
kryptonRibbon.AllowDetach = true;

// Detach the ribbon
kryptonRibbon.Detach();

// Reattach the ribbon
kryptonRibbon.Reattach();

// Check state
bool isDetached = kryptonRibbon.IsDetached;
```

---

## API Summary

### Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `AllowDetach` | `bool` | `false` | Enables/disables detach functionality |
| `IsDetached` | `bool` | `false` | Read-only: indicates if ribbon is currently detached |
| `FloatingWindowText` | `string` | `"Ribbon"` | Text displayed in the floating window title bar |
| `SavePreferencesOnStateChange` | `bool` | `true` | Automatically save preferences when state changes |
| `ButtonSpecs` | `RibbonButtonSpecAnyCollection` | - | Collection of custom buttons to display next to expand/collapse button |

### Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `Detach()` | `bool` | Detaches ribbon into floating window |
| `Reattach()` | `bool` | Reattaches ribbon to original parent |
| `SaveDetachPreferences()` | `void` | Saves current detach preferences (raises event) |
| `LoadDetachPreferences(bool, Point?)` | `bool` | Loads and restores saved preferences |

### Events

| Event | Type | Description |
|-------|------|-------------|
| `RibbonDetached` | `EventHandler` | Raised when ribbon is detached |
| `RibbonReattached` | `EventHandler` | Raised when ribbon is reattached |
| `DetachPreferencesChanged` | `EventHandler<DetachPreferencesEventArgs>` | Raised when preferences should be saved |

---

## Method Details

### `Detach()`

**Returns**: `true` if successful, `false` otherwise

**Preconditions**:
- `AllowDetach == true`
- Ribbon has a parent
- Ribbon is not already detached
- Parent is in a Form

**What it does**:
1. Stores original state (parent, location, size, dock)
2. Creates floating window
3. Moves ribbon to floating window
4. Disables form integration
5. Raises `RibbonDetached` event

### `Reattach()`

**Returns**: `true` if successful, `false` otherwise

**Preconditions**:
- `IsDetached == true`
- Original parent still exists

**What it does**:
1. Removes ribbon from floating window
2. Restores original state
3. Re-enables form integration
4. Closes floating window
5. Raises `RibbonReattached` event

---

## Common Patterns

### Pattern 1: Basic Detach/Reattach

```csharp
kryptonRibbon.AllowDetach = true;
kryptonRibbon.Detach();
// ... later ...
kryptonRibbon.Reattach();
```

### Pattern 2: Event-Driven UI Updates

```csharp
kryptonRibbon.RibbonDetached += (s, e) => UpdateUI();
kryptonRibbon.RibbonReattached += (s, e) => UpdateUI();
```

### Pattern 3: Preference Persistence (Recommended)

```csharp
// Hook up preference saving
kryptonRibbon.DetachPreferencesChanged += (s, e) =>
{
    Properties.Settings.Default.RibbonDetached = e.IsDetached;
    if (e.FloatingWindowPosition.HasValue)
    {
        Properties.Settings.Default.RibbonFloatingX = e.FloatingWindowPosition.Value.X;
        Properties.Settings.Default.RibbonFloatingY = e.FloatingWindowPosition.Value.Y;
    }
    Properties.Settings.Default.Save();
};

// Load saved preferences on startup
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

### Pattern 4: Conditional Detach

```csharp
if (kryptonRibbon.AllowDetach && !kryptonRibbon.IsDetached)
{
    kryptonRibbon.Detach();
}
```

### Pattern 5: Safe Reattach

```csharp
if (kryptonRibbon.IsDetached)
{
    kryptonRibbon.Reattach();
}
```

### Pattern 6: Adding Custom Buttons to Ribbon

```csharp
// Add a custom button next to expand/collapse button
var customButton = new ButtonSpecAny
{
    Text = "Detach",
    ToolTipTitle = "Detach Ribbon",
    ToolTipBody = "Move ribbon to floating window",
    UniqueName = "DetachButton",
    Edge = PaletteRelativeEdgeAlign.Far  // Right side
};
customButton.Click += (s, e) => kryptonRibbon.Detach();
kryptonRibbon.ButtonSpecs.Add(customButton);
```

---

## Error Handling

### Detach Fails

```csharp
if (!kryptonRibbon.Detach())
{
    // Check common causes:
    if (!kryptonRibbon.AllowDetach)
        // Enable AllowDetach first
    else if (kryptonRibbon.IsDetached)
        // Already detached
    else if (kryptonRibbon.Parent == null)
        // Ribbon has no parent
}
```

### Reattach Fails

```csharp
if (!kryptonRibbon.Reattach())
{
    // Check common causes:
    if (!kryptonRibbon.IsDetached)
        // Not currently detached
    // Original parent may have been disposed
}
```

---

## State Management

### Preserved State

When detached, the following is preserved:
- Original parent control
- Original location (Point)
- Original size (Size)
- Original dock style (DockStyle)

### Automatic Behavior

- Floating window closes → Ribbon reattaches automatically
- `AllowDetach = false` while detached → Ribbon reattaches automatically
- Form integration disabled when detached, re-enabled when reattached

---

## VisualRibbonFloatingWindow

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Ribbon` | `KryptonRibbon?` | Read-only: access to hosted ribbon |
| `InternalPanel` | `KryptonPanel` | Access to the internal panel for hosting controls |

### Events

| Event | Type | Description |
|-------|------|-------------|
| `WindowClosing` | `EventHandler` | Raised when window is closing |
| `TitleBarDoubleClick` | `EventHandler` | Raised when title bar is double-clicked (reattaches ribbon) |

### Window Characteristics

- Border: `FixedToolWindow`
- Taskbar: Not shown
- Minimize/Maximize: Disabled
- Owner: Original form
- Title: Uses `FloatingWindowText` property (defaults to "Ribbon")
- Double-Click Title Bar: Automatically reattaches ribbon

---

## DetachPreferencesEventArgs

### Properties

| Property | Type | Description |
|----------|------|-------------|
| `IsDetached` | `bool` | Indicates whether the ribbon is currently detached |
| `FloatingWindowPosition` | `Point?` | The saved position of the floating window, or null if not saved |

### Usage

```csharp
private void OnDetachPreferencesChanged(object? sender, DetachPreferencesEventArgs e)
{
    // Save detached state
    Properties.Settings.Default.RibbonDetached = e.IsDetached;
    
    // Save position if available
    if (e.FloatingWindowPosition.HasValue)
    {
        Properties.Settings.Default.RibbonFloatingX = e.FloatingWindowPosition.Value.X;
        Properties.Settings.Default.RibbonFloatingY = e.FloatingWindowPosition.Value.Y;
    }
    
    Properties.Settings.Default.Save();
}
```

---

## Best Practices Checklist

- [ ] Set `AllowDetach` at design time or during initialization
- [ ] Check `IsDetached` before calling `Reattach()`
- [ ] Use events for UI updates, not polling
- [ ] **Handle `DetachPreferencesChanged` event to save preferences**
- [ ] **Call `LoadDetachPreferences()` on application startup**
- [ ] Perform layout updates after reattachment
- [ ] Handle errors gracefully
- [ ] Test with multiple monitors
- [ ] Consider screen size when enabling feature

---

## See Also

- [Full Documentation](KryptonDetachableRibbon.md) - Comprehensive guide
- [KryptonRibbon Class](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/) - Main ribbon documentation
