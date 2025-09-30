# Krypton Ribbon "No Tab" Designer Feature

## Overview

This document describes the implementation of the "No Tab" designer feature for the Krypton Ribbon control, addressing [GitHub Issue #331](https://github.com/Krypton-Suite/Standard-Toolkit/issues/331) and the related [Issue #99](https://github.com/ComponentFactory/Krypton/issues/99#issuecomment-914968988).

## Feature Description

The "No Tab" designer feature allows developers to easily toggle between having ribbon tabs selected and having no tab selected in the Visual Studio designer. This is particularly useful for creating ribbon interfaces that function as toolbars without visible tab headers.

## Implementation Details

### Files Modified

- `Source/Krypton Components/Krypton.Ribbon/Designers/Designers/KryptonRibbonDesigner.cs`

### Key Changes

#### 1. New Designer Verbs

Two new designer verbs have been added to the `KryptonRibbonDesigner` class:

- **"Clear Tab Selection"** - Clears the selected tab, setting `SelectedTab` to `null`
- **"Select First Tab"** - Sets the first available tab as selected

#### 2. Dynamic Verb Management

The verbs are dynamically enabled/disabled based on the current state:

- When `SelectedTab == null`: "Clear Tab Selection" is disabled, "Select First Tab" is enabled (if tabs exist)
- When `SelectedTab != null`: "Clear Tab Selection" is enabled, "Select First Tab" is disabled

#### 3. Transaction Support

Both verbs use designer transactions to ensure proper undo/redo support:

```csharp
DesignerTransaction transaction = _designerHost.CreateTransaction(@"KryptonRibbon SetNoTab");
```

## Usage

### In Visual Studio Designer

1. Add a `KryptonRibbon` control to your form
2. Add one or more `KryptonRibbonTab` controls to the ribbon
3. Right-click on the ribbon control in the designer
4. Select either:
   - **"Clear Tab Selection"** to clear the selected tab (toolbar mode)
   - **"Select First Tab"** to select the first available tab

### Programmatically

You can also set the no-tab state programmatically:

```csharp
// Set no tab (toolbar mode)
kryptonRibbon1.SelectedTab = null;

// Set first tab
if (kryptonRibbon1.RibbonTabs.Count > 0)
{
    kryptonRibbon1.SelectedTab = kryptonRibbon1.RibbonTabs[0];
}
```

## Technical Implementation

### Designer Verb Registration

```csharp
private DesignerVerb _noTabVerb;
private DesignerVerb _setTabVerb;

// In Verbs property
_noTabVerb = new DesignerVerb(@"Clear Tab Selection", OnNoTab);
_setTabVerb = new DesignerVerb(@"Select First Tab", OnSetTab);
_verbs.AddRange(new[] { _toggleHelpersVerb, _addTabVerb, _clearTabsVerb, _noTabVerb, _setTabVerb });
```

### Verb Status Updates

```csharp
private void UpdateVerbStatus()
{
    if (_verbs.Count != 0 && _ribbon is not null)
    {
        _clearTabsVerb.Enabled = _ribbon.RibbonTabs.Count > 0;
        
        // Update the No Tab / Set Tab verbs based on current state
        if (_ribbon.SelectedTab == null)
        {
            _noTabVerb.Enabled = false;
            _setTabVerb.Enabled = _ribbon.RibbonTabs.Count > 0;
        }
        else
        {
            _noTabVerb.Enabled = true;
            _setTabVerb.Enabled = false;
        }
    }
}
```

### Event Handlers

#### OnNoTab Method
```csharp
private void OnNoTab(object? sender, EventArgs e)
{
    // Use a transaction to support undo/redo actions
    DesignerTransaction transaction = _designerHost!.CreateTransaction(@"KryptonRibbon SetNoTab");
    
    try
    {
        // Get access to the SelectedTab property
        MemberDescriptor? propertySelectedTab = TypeDescriptor.GetProperties(_ribbon)[@"SelectedTab"];
        
        RaiseComponentChanging(propertySelectedTab);
        
        // Clear the selected tab to enable "no tab" mode
        _ribbon.SelectedTab = null;
        
        RaiseComponentChanged(propertySelectedTab, null, null);
    }
    finally
    {
        transaction?.Commit();
        UpdateVerbStatus();
    }
}
```

#### OnSetTab Method
```csharp
private void OnSetTab(object? sender, EventArgs e)
{
    // Use a transaction to support undo/redo actions
    DesignerTransaction transaction = _designerHost!.CreateTransaction(@"KryptonRibbon SetTab");
    
    try
    {
        // Get access to the SelectedTab property
        MemberDescriptor? propertySelectedTab = TypeDescriptor.GetProperties(_ribbon)[@"SelectedTab"];
        
        RaiseComponentChanging(propertySelectedTab);
        
        // Set to first available tab
        if (_ribbon.RibbonTabs.Count > 0)
        {
            _ribbon.SelectedTab = _ribbon.RibbonTabs[0];
        }
        
        RaiseComponentChanged(propertySelectedTab, null, null);
    }
    finally
    {
        transaction?.Commit();
        UpdateVerbStatus();
    }
}
```

## Use Cases

### 1. Toolbar Mode
When you want to use the ribbon as a toolbar without visible tab headers:

```csharp
// Set no tab to create a toolbar-like interface
kryptonRibbon1.SelectedTab = null;
```

### 2. Dynamic Tab Management
For applications that need to dynamically show/hide tabs:

```csharp
// Hide all tabs (toolbar mode)
kryptonRibbon1.SelectedTab = null;

// Show tabs when needed
if (kryptonRibbon1.RibbonTabs.Count > 0)
{
    kryptonRibbon1.SelectedTab = kryptonRibbon1.RibbonTabs[0];
}
```

### 3. Context-Sensitive Ribbons
For ribbons that change behavior based on application state:

```csharp
private void SwitchToToolbarMode()
{
    kryptonRibbon1.SelectedTab = null;
    // Ribbon now functions as a toolbar
}

private void SwitchToTabMode()
{
    if (kryptonRibbon1.RibbonTabs.Count > 0)
    {
        kryptonRibbon1.SelectedTab = kryptonRibbon1.RibbonTabs[0];
    }
}
```

## Benefits

1. **Designer Integration**: Easy toggling between tab and no-tab modes in Visual Studio designer
2. **Visual Feedback**: Verbs are dynamically enabled/disabled based on current state
3. **Undo/Redo Support**: All changes are wrapped in designer transactions
4. **Consistency**: Follows existing designer verb patterns in the codebase
5. **Flexibility**: Supports both designer and programmatic usage

## Related Issues

- [GitHub Issue #331](https://github.com/Krypton-Suite/Standard-Toolkit/issues/331) - Original feature request
- [GitHub Issue #99](https://github.com/ComponentFactory/Krypton/issues/99#issuecomment-914968988) - Related discussion about removing ribbon header

## Future Enhancements

Potential future enhancements could include:

1. **Context Menu Integration**: Add the verbs to the ribbon's context menu
2. **Keyboard Shortcuts**: Add keyboard shortcuts for quick toggling
3. **Visual Indicators**: Add visual indicators in the designer to show no-tab state
4. **Bulk Operations**: Allow setting no-tab state for multiple ribbons at once

## Compatibility

This feature is compatible with:
- .NET Framework 4.7.2 and later
- .NET 8.0 Windows and later
- Visual Studio 2022 and later
- All existing Krypton Ribbon functionality

## Conclusion

The "No Tab" designer feature successfully addresses the user requests in GitHub issues #331 and #99, providing a clean and intuitive way to toggle between tab and toolbar modes in the Krypton Ribbon control. The implementation follows established patterns in the codebase and provides full designer integration with proper transaction support.
