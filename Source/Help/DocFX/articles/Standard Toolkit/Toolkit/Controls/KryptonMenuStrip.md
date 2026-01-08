# KryptonMenuStrip Developer Documentation

## Overview

`KryptonMenuStrip` is a Krypton-themed wrapper around the standard Windows Forms `MenuStrip` control. It provides seamless integration with the Krypton palette system, enabling dynamic theming, consistent visual styling, and automatic font management based on the active palette.

## Table of Contents

1. [Class Hierarchy](#class-hierarchy)
2. [Key Features](#key-features)
3. [Architecture](#architecture)
4. [API Reference](#api-reference)
5. [Palette System Integration](#palette-system-integration)
6. [Visual States](#visual-states)
7. [Font Management](#font-management)
8. [Event Handling](#event-handling)
9. [Usage Examples](#usage-examples)
10. [Best Practices](#best-practices)
11. [Implementation Details](#implementation-details)

---

## Class Hierarchy

```
System.Windows.Forms.Control
  └── System.Windows.Forms.ToolStrip
      └── System.Windows.Forms.MenuStrip
          └── Krypton.Toolkit.KryptonMenuStrip
```

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`  
**Inherits From:** `System.Windows.Forms.MenuStrip`

---

## Key Features

### 1. **Krypton Palette Integration**
   - Automatic theme synchronization with the global Krypton palette
   - Support for built-in palette modes (Office 2007, Office 2013, Microsoft 365, etc.)
   - Custom palette support for application-specific theming
   - Dynamic palette switching at runtime

### 2. **Automatic Font Management**
   - Font automatically synchronized with palette's `ToolStripFont`
   - Responds to global palette `BaseFont` changes
   - Updates when palette changes occur

### 3. **Visual State Customization**
   - Per-state appearance overrides (Common, Disabled, Normal)
   - Background color, gradient, and image support
   - Inheritance-based styling system

### 4. **Professional Rendering**
   - Uses `ToolStripRenderMode.ManagerRenderMode` for Krypton renderer integration
   - Consistent appearance with other Krypton controls
   - Theme-aware color table integration

### 5. **Event-Driven Updates**
   - Automatic repainting on palette changes
   - Layout updates when visual properties change
   - Global palette change notifications

---

## Architecture

### Core Components

#### 1. **Palette Management**
The control maintains references to:
- `_palette`: The active palette instance (can be global or custom)
- `_hookedPalette`: The palette currently subscribed to for paint events
- `_hookedGlobalPalette`: The global palette subscribed to for BaseFont changes
- `_paletteMode`: The current palette mode (Global, Custom, or specific theme)

#### 2. **Visual State Storage**
Three `PaletteBack` instances provide state-specific styling:
- `_stateCommon`: Base appearance inherited by all states
- `_stateDisabled`: Appearance when the control is disabled
- `_stateNormal`: Appearance in the normal (enabled) state

#### 3. **Inheritance Chain**
- `PaletteBackInheritMenuStrip`: Bridges palette ColorTable to PaletteBack interface
- Retrieves colors from `KryptonColorTable.MenuStripGradientBegin/End`
- Provides inheritance chain for state-specific overrides

### Data Flow

```
KryptonManager (Global Palette)
    ↓
PaletteBase (Theme-specific palette)
    ↓
KryptonColorTable (MenuStrip colors)
    ↓
PaletteBackInheritMenuStrip (Adapter)
    ↓
PaletteBack (_stateCommon, _stateDisabled, _stateNormal)
    ↓
KryptonMenuStrip (Visual rendering)
```

---

## API Reference

### Constructors

#### `KryptonMenuStrip()`

Initializes a new instance of the `KryptonMenuStrip` class.

**Behavior:**
- Sets `RenderMode` to `ToolStripRenderMode.ManagerRenderMode`
- Initializes palette mode to `PaletteMode.Global`
- Creates visual state storage instances
- Hooks into global palette change events
- Sets initial font from palette

**Example:**
```csharp
var menuStrip = new KryptonMenuStrip();
```

---

### Properties

#### `PaletteMode` (PaletteMode)

Gets or sets the palette mode used for rendering.

**Category:** `Visuals`  
**Default Value:** `PaletteMode.Global`  
**Description:** Sets the palette mode.

**Values:**
- `PaletteMode.Global`: Uses the current global palette from `KryptonManager`
- `PaletteMode.Custom`: Uses a custom palette (requires `Palette` property to be set)
- Other values: Uses built-in theme palettes (e.g., `PaletteMode.Office2007Blue`, `PaletteMode.Microsoft365Blue`)

**Behavior:**
- When set to a built-in mode, automatically retrieves the corresponding palette
- When set to `PaletteMode.Custom`, does nothing until `Palette` is assigned
- Triggers palette event re-hooking, inheritance updates, appearance refresh, and font update

**Example:**
```csharp
// Use Office 2007 Blue theme
menuStrip.PaletteMode = PaletteMode.Office2007Blue;

// Use Microsoft 365 theme
menuStrip.PaletteMode = PaletteMode.Microsoft365Blue;

// Use custom palette
menuStrip.PaletteMode = PaletteMode.Custom;
menuStrip.Palette = myCustomPalette;
```

**Serialization:**
- Only serialized if not equal to `PaletteMode.Global`
- Can be reset using `ResetPaletteMode()` method

---

#### `Palette` (PaletteBase?)

Gets or sets the custom palette implementation.

**Category:** `Visuals`  
**Default Value:** `null`  
**Description:** Sets the custom palette to be used.

**Behavior:**
- Returns `null` unless `PaletteMode` is `PaletteMode.Custom`
- When set to a non-null value:
  - Sets `_palette` to the provided value
  - Changes `PaletteMode` to `PaletteMode.Custom`
  - Updates hooks, inheritance, appearance, and font
- When set to `null`:
  - Reverts to `PaletteMode.Global`
  - Uses `KryptonManager.CurrentGlobalPalette`

**Example:**
```csharp
// Create and assign custom palette
var customPalette = new KryptonCustomPaletteBase();
customPalette.BasePalette = KryptonManager.GetPaletteForMode(PaletteMode.Office2013White);
// ... customize palette properties ...
menuStrip.Palette = customPalette;
menuStrip.PaletteMode = PaletteMode.Custom;

// Revert to global palette
menuStrip.Palette = null; // Automatically switches to Global mode
```

**Serialization:**
- Only serialized when `PaletteMode == PaletteMode.Custom && _palette != null`
- Can be reset using `ResetPalette()` method

---

#### `StateCommon` (PaletteBack)

Gets access to the common menu strip appearance that other states can override.

**Category:** `Visuals`  
**Description:** Overrides for defining common menu strip appearance that other states can override.  
**Designer Serialization:** Content (expanded in designer)

**Properties Available:**
- `Draw` (InheritBool): Whether to draw the background
- `GraphicsHint` (PaletteGraphicsHint): Graphics rendering hint
- `Color1` (Color): First background color (gradient start)
- `Color2` (Color): Second background color (gradient end)
- `ColorStyle` (PaletteColorStyle): Color drawing style
- `ColorAlign` (PaletteRectangleAlign): Color alignment
- `ColorAngle` (float): Gradient angle
- `Image` (Image): Background image
- `ImageStyle` (PaletteImageStyle): Image drawing style
- `ImageAlign` (PaletteRectangleAlign): Image alignment

**Example:**
```csharp
// Override common background to use a solid color
menuStrip.StateCommon.Color1 = Color.FromArgb(240, 240, 240);
menuStrip.StateCommon.Color2 = Color.FromArgb(240, 240, 240);
menuStrip.StateCommon.ColorStyle = PaletteColorStyle.Solid;
```

**Serialization:**
- Only serialized if not in default state (`!IsDefault`)

---

#### `StateDisabled` (PaletteBack)

Gets access to the disabled menu strip appearance.

**Category:** `Visuals`  
**Description:** Overrides for defining disabled menu strip appearance.  
**Designer Serialization:** Content (expanded in designer)

**Inheritance:**
- Inherits from `StateCommon`
- Only properties explicitly set override the common state

**Example:**
```csharp
// Customize disabled state appearance
menuStrip.StateDisabled.Color1 = Color.FromArgb(220, 220, 220);
menuStrip.StateDisabled.Color2 = Color.FromArgb(220, 220, 220);
menuStrip.StateDisabled.ColorStyle = PaletteColorStyle.Solid;
```

**Serialization:**
- Only serialized if not in default state (`!IsDefault`)

---

#### `StateNormal` (PaletteBack)

Gets access to the normal menu strip appearance.

**Category:** `Visuals`  
**Description:** Overrides for defining normal menu strip appearance.  
**Designer Serialization:** Content (expanded in designer)

**Inheritance:**
- Inherits from `StateCommon`
- Only properties explicitly set override the common state

**Example:**
```csharp
// Customize normal state appearance
menuStrip.StateNormal.Color1 = Color.FromArgb(250, 250, 250);
menuStrip.StateNormal.Color2 = Color.FromArgb(230, 230, 230);
menuStrip.StateNormal.ColorStyle = PaletteColorStyle.Linear;
menuStrip.StateNormal.ColorAngle = 90f; // Vertical gradient
```

**Serialization:**
- Only serialized if not in default state (`!IsDefault`)

---

### Methods

#### `Dispose(bool disposing)`

Cleans up resources used by the control.

**Parameters:**
- `disposing` (bool): `true` if managed resources should be disposed; otherwise, `false`.

**Behavior:**
- Unhooks from `KryptonManager.GlobalPaletteChanged` event
- Unhooks from palette `PalettePaintInternal` events
- Unhooks from global palette `PalettePaintInternal` events
- Calls base `Dispose(disposing)`

**Note:** Always call `Dispose()` when finished with the control to prevent memory leaks from event subscriptions.

---

#### `OnRendererChanged(EventArgs e)`

Raises the `RendererChanged` event.

**Parameters:**
- `e` (EventArgs): Event data

**Behavior:**
- Calls base implementation
- Invalidates the control to trigger repaint

**Override:** Override this method to perform custom actions when the renderer changes.

---

### Events

The control inherits all standard `MenuStrip` events. Additionally, it responds to:

- **KryptonManager.GlobalPaletteChanged**: Automatically subscribed; updates control when global palette changes
- **Palette.PalettePaintInternal**: Automatically subscribed; updates font and appearance when palette changes

---

## Palette System Integration

### How Palette Selection Works

1. **Global Mode (Default)**
   ```csharp
   menuStrip.PaletteMode = PaletteMode.Global;
   // Uses KryptonManager.CurrentGlobalPalette
   ```

2. **Built-in Theme Mode**
   ```csharp
   menuStrip.PaletteMode = PaletteMode.Office2007Blue;
   // Uses KryptonManager.GetPaletteForMode(PaletteMode.Office2007Blue)
   ```

3. **Custom Mode**
   ```csharp
   menuStrip.PaletteMode = PaletteMode.Custom;
   menuStrip.Palette = myCustomPalette;
   // Uses the assigned custom palette
   ```

### Palette Change Propagation

When a palette change occurs:

1. **Global Palette Changed**
   - `OnGlobalPaletteChanged` is invoked
   - If using Global mode: Updates palette reference, re-hooks events, updates inheritance/appearance/font
   - If using other modes: Still updates font (BaseFont changes affect all controls)

2. **Palette Paint Event**
   - `OnPalettePaint` or `OnGlobalPalettePaint` is invoked
   - Calls `UpdateFont()` to synchronize font with palette

3. **Palette Mode Changed**
   - Retrieves new palette via `KryptonManager.GetPaletteForMode()`
   - Re-hooks palette events
   - Updates inheritance chain
   - Refreshes appearance
   - Updates font

### Color Table Integration

The control uses `PaletteBackInheritMenuStrip` to bridge the palette's `ColorTable` to the `PaletteBack` system:

- `MenuStripGradientBegin` → `Color1`
- `MenuStripGradientEnd` → `Color2`
- Colors are retrieved from `palette.ColorTable.MenuStripGradientBegin/End`

This allows the control to use theme-specific colors while maintaining the flexibility of the `PaletteBack` override system.

---

## Visual States

### State Hierarchy

```
StateCommon (base)
    ├── StateDisabled (inherits from Common)
    └── StateNormal (inherits from Common)
```

### State Resolution

When rendering, the control determines which state to use:

1. **Disabled State**: Used when `Enabled == false`
   - Inherits from `StateCommon`
   - Can override any `StateCommon` property

2. **Normal State**: Used when `Enabled == true`
   - Inherits from `StateCommon`
   - Can override any `StateCommon` property

### Inheritance Behavior

Properties in `PaletteBack` use an inheritance model:

- **Inherit**: Uses value from parent state (or palette default)
- **Explicit Value**: Overrides parent state

Example inheritance chain:
```
Palette ColorTable (default)
    ↓
StateCommon (can override)
    ↓
StateNormal/StateDisabled (can override)
```

---

## Font Management

### Automatic Font Synchronization

The control automatically synchronizes its `Font` property with the palette's `ToolStripFont`:

1. **Initial Setup**
   - Constructor calls `UpdateFont()` after palette initialization
   - Font is set from `palette.ColorTable.ToolStripFont`

2. **Palette Changes**
   - `OnPalettePaint`: Updates font when palette paint events occur
   - `OnGlobalPalettePaint`: Updates font when global palette BaseFont changes
   - `OnGlobalPaletteChanged`: Updates font when global palette instance changes

3. **Palette Mode Changes**
   - `PaletteMode` setter calls `UpdateFont()` after switching palettes
   - `Palette` setter calls `UpdateFont()` after assigning custom palette

### Font Update Implementation

```csharp
private void UpdateFont()
{
    if (!IsDisposed)
    {
        try
        {
            var currentPalette = _palette ?? KryptonManager.CurrentGlobalPalette;
            if (currentPalette != null)
            {
                var colorTable = currentPalette.ColorTable;
                var toolStripFont = colorTable.ToolStripFont;
                if (Font != toolStripFont)
                {
                    Font = toolStripFont;
                }
            }
        }
        catch
        {
            // Ignore errors accessing ColorTable (may not be initialized yet)
        }
    }
}
```

**Key Points:**
- Uses try-catch to handle cases where ColorTable may not be initialized
- Only updates Font if it differs from palette font (prevents unnecessary updates)
- Checks `IsDisposed` to avoid operations on disposed controls

### Font Source

The font comes from the palette's `ColorTable.ToolStripFont` property, which typically:
- Defaults to `SystemInformation.MenuFont`
- Can be customized in custom palettes
- Updates when palette `BaseFont` changes

---

## Event Handling

### Internal Event Subscriptions

The control subscribes to several events for automatic updates:

#### 1. **KryptonManager.GlobalPaletteChanged**
- **Subscribed:** In constructor
- **Unsubscribed:** In `Dispose(bool disposing)`
- **Handler:** `OnGlobalPaletteChanged`
- **Purpose:** React to global palette changes

#### 2. **Palette.PalettePaintInternal**
- **Subscribed:** Via `HookPaletteEvents()` when palette changes
- **Unsubscribed:** Via `HookPaletteEvents()` when switching palettes
- **Handler:** `OnPalettePaint`
- **Purpose:** React to palette paint events (e.g., BaseFont changes)

#### 3. **GlobalPalette.PalettePaintInternal**
- **Subscribed:** Via `HookGlobalPaletteEvents()` in constructor
- **Unsubscribed:** In `Dispose(bool disposing)`
- **Handler:** `OnGlobalPalettePaint`
- **Purpose:** React to global palette BaseFont changes even when not using Global mode

### Event Handler Behavior

#### `OnGlobalPaletteChanged(object? sender, EventArgs e)`

```csharp
private void OnGlobalPaletteChanged(object? sender, EventArgs e)
{
    // Re-hook global palette events in case the global palette instance changed
    HookGlobalPaletteEvents();

    // Only update if we're using the global palette
    if (_paletteMode == PaletteMode.Global)
    {
        _palette = KryptonManager.CurrentGlobalPalette;
        HookPaletteEvents();
        UpdateInherit();
        UpdateAppearance();
        UpdateFont();
    }
    else
    {
        // Even if not using global palette, BaseFont changes might affect us
        UpdateFont();
    }
}
```

**Behavior:**
- Always re-hooks global palette events (instance may have changed)
- If using Global mode: Full update (palette, hooks, inheritance, appearance, font)
- If using other modes: Only updates font (BaseFont changes are global)

#### `OnPalettePaint(object? sender, PaletteLayoutEventArgs e)`

```csharp
private void OnPalettePaint(object? sender, PaletteLayoutEventArgs e)
{
    if (!IsDisposed)
    {
        UpdateFont();
    }
}
```

**Behavior:**
- Updates font when palette paint events occur
- Checks `IsDisposed` before updating

#### `OnGlobalPalettePaint(object? sender, PaletteLayoutEventArgs e)`

```csharp
private void OnGlobalPalettePaint(object? sender, PaletteLayoutEventArgs e)
{
    if (!IsDisposed)
    {
        UpdateFont();
    }
}
```

**Behavior:**
- Updates font when global palette BaseFont changes
- Ensures font stays synchronized even when not using Global mode

---

## Usage Examples

### Example 1: Basic Usage

```csharp
using Krypton.Toolkit;

// Create menu strip
var menuStrip = new KryptonMenuStrip();
menuStrip.Dock = DockStyle.Top;

// Add menu items
var fileMenu = new ToolStripMenuItem("File");
fileMenu.DropDownItems.Add(new ToolStripMenuItem("New"));
fileMenu.DropDownItems.Add(new ToolStripMenuItem("Open"));
menuStrip.Items.Add(fileMenu);

var editMenu = new ToolStripMenuItem("Edit");
editMenu.DropDownItems.Add(new ToolStripMenuItem("Cut"));
editMenu.DropDownItems.Add(new ToolStripMenuItem("Copy"));
menuStrip.Items.Add(editMenu);

// Add to form
this.Controls.Add(menuStrip);
```

### Example 2: Using a Specific Theme

```csharp
// Use Office 2007 Blue theme
menuStrip.PaletteMode = PaletteMode.Office2007Blue;

// Or use Microsoft 365 theme
menuStrip.PaletteMode = PaletteMode.Microsoft365Blue;
```

### Example 3: Custom Palette

```csharp
// Create custom palette
var customPalette = new KryptonCustomPaletteBase();
customPalette.BasePalette = KryptonManager.GetPaletteForMode(PaletteMode.Office2013White);

// Customize menu strip colors in the palette
customPalette.ColorTable.MenuStripGradientBegin = Color.FromArgb(240, 240, 240);
customPalette.ColorTable.MenuStripGradientEnd = Color.FromArgb(220, 220, 220);

// Apply to menu strip
menuStrip.PaletteMode = PaletteMode.Custom;
menuStrip.Palette = customPalette;
```

### Example 4: Per-Control Visual Overrides

```csharp
// Override common background
menuStrip.StateCommon.Color1 = Color.FromArgb(250, 250, 250);
menuStrip.StateCommon.Color2 = Color.FromArgb(230, 230, 230);
menuStrip.StateCommon.ColorStyle = PaletteColorStyle.Linear;
menuStrip.StateCommon.ColorAngle = 90f; // Vertical gradient

// Override disabled state
menuStrip.StateDisabled.Color1 = Color.FromArgb(240, 240, 240);
menuStrip.StateDisabled.Color2 = Color.FromArgb(240, 240, 240);
menuStrip.StateDisabled.ColorStyle = PaletteColorStyle.Solid;
```

### Example 5: Responding to Global Palette Changes

```csharp
// The control automatically responds to global palette changes
// No additional code needed - it's handled internally

// However, you can listen to KryptonManager events if needed
KryptonManager.GlobalPaletteChanged += (sender, e) =>
{
    // Your custom logic here
    // Note: KryptonMenuStrip already handles this internally
};
```

### Example 6: Designer Usage

In the Visual Studio designer:

1. Drag `KryptonMenuStrip` from toolbox onto form
2. Set `PaletteMode` property in Properties window
3. Expand `StateCommon`, `StateDisabled`, or `StateNormal` to customize appearance
4. Add menu items using the designer

---

## Best Practices

### 1. **Palette Mode Selection**

- **Use Global Mode** when you want all controls to follow the global theme
- **Use Built-in Themes** when you want a specific control to use a different theme
- **Use Custom Mode** when you need fine-grained control over a specific control's appearance

### 2. **Font Management**

- **Don't manually set Font property** - let the control manage it automatically
- If you need custom fonts, customize the palette's `BaseFont` or `ColorTable.ToolStripFont`
- The control will automatically sync with palette font changes

### 3. **Visual State Overrides**

- **Use StateCommon** for changes that apply to all states
- **Use StateNormal/StateDisabled** only when you need state-specific differences
- Prefer palette customization over per-control overrides for consistency

### 4. **Disposal**

- Always call `Dispose()` when removing the control
- The control properly unsubscribes from events in `Dispose()`
- Prevents memory leaks from event subscriptions

### 5. **Thread Safety**

- All operations should be performed on the UI thread
- Palette changes are thread-safe, but UI updates must be on the UI thread

### 6. **Performance**

- Avoid frequent palette mode changes
- Use state overrides sparingly (they add to the inheritance chain)
- Prefer palette-level customization for application-wide changes

---

## Implementation Details

### Render Mode

The control uses `ToolStripRenderMode.ManagerRenderMode`, which:
- Uses the renderer specified by `KryptonManager`
- Integrates with Krypton's professional renderer system
- Provides theme-aware rendering via `KryptonColorTable`

### Palette Event Hooking Strategy

The control uses a dual-hooking strategy:

1. **Palette-Specific Hooks** (`_hookedPalette`)
   - Hooks into the active palette (global or custom)
   - Updates when `PaletteMode` or `Palette` changes
   - Used for general palette paint events

2. **Global Palette Hooks** (`_hookedGlobalPalette`)
   - Always hooks into `KryptonManager.CurrentGlobalPalette`
   - Updates when global palette instance changes
   - Used specifically for BaseFont change detection
   - Ensures font updates even when not using Global mode

### Inheritance Chain Construction

```csharp
// In constructor:
_inherit = new PaletteBackInheritMenuStrip(_palette);
_stateCommon = new PaletteBack(_inherit, OnNeedPaint);
_stateDisabled = new PaletteBack(_stateCommon, OnNeedPaint);
_stateNormal = new PaletteBack(_stateCommon, OnNeedPaint);
```

**Chain:**
```
PaletteBase.ColorTable
    ↓
PaletteBackInheritMenuStrip (_inherit)
    ↓
PaletteBack (_stateCommon)
    ↓
PaletteBack (_stateDisabled / _stateNormal)
```

### NeedPaint Event Handling

The `OnNeedPaint` handler:
- Checks if control is disposed
- Performs layout if `NeedLayout` is true
- Invalidates the control to trigger repaint

This ensures the control updates when palette properties change.

### Error Handling

The `UpdateFont()` method uses try-catch to handle:
- `ColorTable` not being initialized yet
- Palette access errors during initialization
- Prevents exceptions from breaking control initialization

---

## Related Classes

### Dependencies

- **PaletteBase**: Base palette interface
- **PaletteBack**: Background appearance storage
- **PaletteBackInheritMenuStrip**: MenuStrip-specific palette adapter
- **KryptonManager**: Global palette management
- **KryptonColorTable**: Color table for ToolStrip rendering

### Similar Controls

- **KryptonToolStrip**: Themed ToolStrip control
- **KryptonStatusStrip**: Themed StatusStrip control
- Both use similar palette integration patterns

---

## Version History

This documentation applies to the current implementation. Key implementation details:

- Uses `ToolStripRenderMode.ManagerRenderMode` for Krypton rendering
- Dual palette event hooking (palette-specific + global)
- Automatic font synchronization with palette
- State-based appearance inheritance
- Proper event cleanup in `Dispose()`

---

## Troubleshooting

### Font Not Updating

**Problem:** Font doesn't change when palette BaseFont changes.

**Solutions:**
- Ensure control is not disposed
- Check that palette events are properly hooked
- Verify `ColorTable.ToolStripFont` is accessible

### Appearance Not Updating

**Problem:** Visual appearance doesn't change when palette changes.

**Solutions:**
- Call `Invalidate()` if making manual changes
- Ensure `PaletteMode` or `Palette` is set correctly
- Check that state overrides aren't blocking palette values

### Memory Leaks

**Problem:** Control causes memory leaks.

**Solutions:**
- Always call `Dispose()` when removing control
- Ensure form properly disposes child controls
- Check for circular references in event handlers