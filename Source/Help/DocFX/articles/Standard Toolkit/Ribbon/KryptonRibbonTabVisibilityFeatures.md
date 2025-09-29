# Krypton Ribbon Tab Visibility Features

## Overview

This document describes the implementation of comprehensive tab visibility features for the Krypton Ribbon control, addressing [GitHub Issue #331](https://github.com/Krypton-Suite/Standard-Toolkit/issues/331) and the related [Issue #99](https://github.com/ComponentFactory/Krypton/issues/99#issuecomment-914968988).

## Feature Description

The Krypton Ribbon now supports two complementary features for creating flexible ribbon interfaces:

1. **"No Tab" Mode**: Allows setting `SelectedTab` to `null`, creating a ribbon with tabs but no active tab selected
2. **"Hide Tabs" Mode**: Completely hides the tab area, creating a clean toolbar-like interface

## Implementation Details

### Files Modified

- `Source/Krypton Components/Krypton.Ribbon/Controls Ribbon/KryptonRibbon.cs`
- `Source/Krypton Components/Krypton.Ribbon/Designers/Designers/KryptonRibbonDesigner.cs`

### Key Changes

#### 1. New Properties

**ShowTabs Property**:
```csharp
/// <summary>
/// Gets and sets a value indicating if ribbon tabs are visible.
/// </summary>
[Category(@"Values")]
[Description(@"Determines if ribbon tabs are visible.")]
[DefaultValue(true)]
public bool ShowTabs { get; set; }
```

**SelectedTab Property Enhancement**:
- Modified to allow setting `SelectedTab` to `null` for "no tab" mode
- Changed validation logic from `(value != null)` to `(value == null) ||` to permit null values

#### 2. New Designer Verbs

Four new designer verbs have been added to the `KryptonRibbonDesigner` class:

- **"Clear Tab Selection"** - Clears the selected tab, enabling toolbar mode
- **"Select First Tab"** - Sets the first available tab as selected
- **"Hide Tab Headers"** - Hides the ribbon tab headers completely
- **"Show Tab Headers"** - Shows the ribbon tab headers

#### 3. Dynamic Verb Management

Verbs are automatically enabled/disabled based on current ribbon state:

- **No Tab Mode**: "Clear Tab Selection" disabled, "Select First Tab" enabled
- **Tab Selected**: "Clear Tab Selection" enabled, "Select First Tab" disabled
- **Tab Headers Visible**: "Hide Tab Headers" enabled, "Show Tab Headers" disabled
- **Tab Headers Hidden**: "Hide Tab Headers" disabled, "Show Tab Headers" enabled

#### 4. View Layout Management

The `UpdateTabVisibility()` method dynamically adds or removes both the `TabsArea` and `CaptionArea` from the `_ribbonDocker` based on the `ShowTabs` property:

```csharp
private void UpdateTabVisibility()
{
    if (_ribbonDocker == null || TabsArea == null || CaptionArea == null)
    {
        return;
    }

    if (_showTabs)
    {
        // Add tabs area if not already present
        if (!_ribbonDocker.Contains(TabsArea))
        {
            _ribbonDocker.Add(TabsArea, ViewDockStyle.Top);
        }
        
        // Add caption area if not already present
        if (!_ribbonDocker.Contains(CaptionArea))
        {
            _ribbonDocker.Add(CaptionArea, ViewDockStyle.Top);
        }
    }
    else
    {
        // Remove tabs area if present
        if (_ribbonDocker.Contains(TabsArea))
        {
            _ribbonDocker.Remove(TabsArea);
        }
        
        // Remove caption area if present
        if (_ribbonDocker.Contains(CaptionArea))
        {
            _ribbonDocker.Remove(CaptionArea);
        }
    }
}
```

## Usage Examples

### Designer Usage

1. **Right-click on a KryptonRibbon control** in the Visual Studio designer
2. **Select from the context menu**:
   - "Clear Tab Selection" - Creates a ribbon with tabs but no active selection
   - "Hide Tab Headers" - Completely hides the tab headers for a toolbar-like appearance
   - "Select First Tab" - Restores tab selection (when in no-tab mode)
   - "Show Tab Headers" - Restores tab header visibility (when headers are hidden)

### Programmatic Usage

```csharp
// Hide tabs completely for toolbar-like interface
ribbon.ShowTabs = false;

// Set no tab selected (tabs still visible)
ribbon.SelectedTab = null;

// Restore normal ribbon behavior
ribbon.ShowTabs = true;
ribbon.SelectedTab = ribbon.RibbonTabs[0];
```

## Visual Comparison

### Normal Ribbon (ShowTabs = true, SelectedTab = Tab1)
```
┌─────────────────────────────────────┐
│ [Home] [Insert] [View] [Design]     │ ← Tab Headers
├─────────────────────────────────────┤
│ [Paste] [Cut] [Copy] [Format]       │ ← Ribbon Groups
│ Clipboard Group                     │
└─────────────────────────────────────┘
```

### No Tab Mode (ShowTabs = true, SelectedTab = null)
```
┌─────────────────────────────────────┐
│ [Home] [Insert] [View] [Design]     │ ← Tab Headers (visible but none selected)
├─────────────────────────────────────┤
│ (No content - no tab selected)      │ ← No groups displayed
└─────────────────────────────────────┘
```

### Hidden Tab Headers Mode (ShowTabs = false)
```
┌─────────────────────────────────────┐
│ [Paste] [Cut] [Copy] [Format]       │ ← Ribbon Groups (directly visible)
│ Clipboard Group                     │
└─────────────────────────────────────┘
```

## Benefits

1. **Flexible UI Design**: Developers can choose between full ribbon, no-tab ribbon, or toolbar-like interfaces
2. **Designer Integration**: Easy toggling between modes in Visual Studio designer
3. **Undo/Redo Support**: All changes support designer transactions for undo/redo functionality
4. **Runtime Flexibility**: Properties can be changed programmatically at runtime
5. **Clean Implementation**: Uses existing view layout system without reflection hacks

## Technical Notes

- **Backward Compatibility**: All existing functionality is preserved
- **Performance**: Minimal overhead, only affects view layout when properties change
- **Designer Support**: Full integration with Visual Studio designer including property grid
- **Transaction Support**: All designer verbs use proper transactions for undo/redo

## Use Cases

### 1. Toolbar Mode
When you want to use the ribbon as a toolbar without visible tab headers:

```csharp
// Hide tabs completely for toolbar-like interface
ribbon.ShowTabs = false;
```

### 2. Dynamic Tab Management
For applications that need to dynamically show/hide tabs:

```csharp
// Hide all tabs (toolbar mode)
ribbon.ShowTabs = false;

// Show tabs when needed
ribbon.ShowTabs = true;
if (ribbon.RibbonTabs.Count > 0)
{
    ribbon.SelectedTab = ribbon.RibbonTabs[0];
}
```

### 3. Context-Sensitive Ribbons
For ribbons that change behavior based on application state:

```csharp
private void SwitchToToolbarMode()
{
    ribbon.ShowTabs = false;
    // Ribbon now functions as a toolbar
}

private void SwitchToTabMode()
{
    ribbon.ShowTabs = true;
    if (ribbon.RibbonTabs.Count > 0)
    {
        ribbon.SelectedTab = ribbon.RibbonTabs[0];
    }
}
```

## Edge Cases and Robustness

The implementation handles several edge cases to ensure robust behavior:

### 1. Tab Validation
The `ValidateSelectedTab()` method respects the `ShowTabs` property:
- **When `ShowTabs = false`**: Allows `SelectedTab` to remain `null` (toolbar mode)
- **When `ShowTabs = true`**: Automatically selects a valid tab if none is selected

### 2. Focus Management
The `OnGotFocus()` method handles focus appropriately:
- **Toolbar Mode**: Focuses on groups area or QAT instead of trying to focus hidden tabs
- **Normal Mode**: Focuses on selected tab or first available tab

### 3. Keyboard Navigation
The `RibbonTabController` already handles keyboard navigation correctly:
- **When `SelectedTab = null`**: Converts Tab/Shift+Tab to Right/Left arrow keys
- **Toolbar Mode**: Navigation works through groups and QAT elements

### 4. Contextual Tabs
Both regular tabs and contextual tab headers are properly hidden when `ShowTabs = false`.

## Related Issues

- [GitHub Issue #331](https://github.com/Krypton-Suite/Standard-Toolkit/issues/331) - Original "No Tab in a ribbon Solution" request
- [GitHub Issue #99](https://github.com/ComponentFactory/Krypton/issues/99#issuecomment-914968988) - Related ribbon header removal request

## Future Enhancements

Potential future improvements could include:
- Animation support for tab show/hide transitions
- Additional layout options for hidden tab mode
- Custom styling options for toolbar mode
- Context menu integration for runtime switching

## Compatibility

This feature is compatible with:
- .NET Framework 4.7.2 and later
- .NET 8.0 Windows and later
- Visual Studio 2022 and later
- All existing Krypton Ribbon functionality

## Conclusion

The tab visibility features successfully address the user requests in GitHub issues #331 and #99, providing comprehensive control over ribbon tab visibility and selection. The implementation follows established patterns in the codebase and provides full designer integration with proper transaction support, enabling developers to create flexible ribbon interfaces that can function as both traditional ribbons and modern toolbars.
