# Ribbon QAT ButtonSpec Styles

This document provides comprehensive technical documentation for the Ribbon Quick Access Toolbar (QAT) ButtonSpec styles feature, including API reference, usage patterns, and implementation details.

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [API Reference](#api-reference)
4. [PaletteButtonSpecStyle Enum](#palettebuttonspecstyle-enum)
5. [Insert Standard Items](#insert-standard-items)
6. [Usage Examples](#usage-examples)
7. [Custom Implementers](#custom-implementers)
8. [Backward Compatibility](#backward-compatibility)
9. [Internal Implementation](#internal-implementation)

---

## Overview

Ribbon QAT buttons can now use the same themed ButtonSpec styles as form title bars and integrated toolbars. Instead of always providing a custom `Image`, you can assign a semantic `Type` (e.g. `New`, `Open`, `Save`) so the palette supplies:

- **Icons** — theme-appropriate images for each style
- **Color mapping** — icons adapt to the ribbon foreground color
- **Tooltips** — default tooltip titles from the palette when not overridden

This aligns QAT behavior with `KryptonFormTitleBar` ButtonSpecs and the integrated toolbar.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  KryptonRibbon.QATButtons (KryptonRibbonQATButtonCollection)    │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │  KryptonRibbonQATButton                                     ││
│  │  - Type: PaletteButtonSpecStyle (Generic | New | Open | …)  ││
│  │  - Image, Text, ToolTipTitle (optional overrides)           ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  ViewDrawRibbonQATButton (IContentValues)                       │
│  - If Type != Generic: palette.GetButtonSpecImage(type, state)  │
│  - If Type == Generic: QATButton.GetImage()                     │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  QATButtonToContent (IPaletteContent)                           │
│  - GetContentImageColorMap: palette color map when typed        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  QATButtonToolTipToContent                                      │
│  - GetShortText: palette tooltip title when typed & not set     │
└─────────────────────────────────────────────────────────────────┘
```

---

## API Reference

### KryptonRibbonQATButton

| Member | Type | Description |
|--------|------|-------------|
| **Type** | `PaletteButtonSpecStyle` | Button spec style for themed icons. Default: `Generic`. When non-Generic, palette provides icon, color map, and default tooltip. |
| **Image** | `Image?` | Custom image. Used only when `Type == Generic`. Must be 16×16 or smaller. |
| **Text** | `string` | Display text (used in customize menu, key tips). Default: `"QAT Button"`. |
| **ToolTipTitle** | `string` | Tooltip title. When `Type != Generic` and empty, palette tooltip title is used. |
| **ToolTipBody** | `string` | Tooltip body text. |
| **Visible** | `bool` | Whether the button is visible. Default: `true`. |
| **Enabled** | `bool` | Whether the button is enabled. Default: `true`. |
| **ShortcutKeys** | `Keys` | Keyboard shortcut. Default: `Keys.None`. |
| **KryptonCommand** | `KryptonCommand?` | Optional command; overrides Text, ImageSmall, Enabled when set. |
| **Click** | `event EventHandler?` | Raised when the button is clicked. |

**Designer serialization:**

- `Type` is serialized only when not `Generic` (`ShouldSerializeType()`).
- `ResetType()` resets to `Generic`.

---

### IQuickAccessToolbarButton

All QAT button sources must implement this interface. The following member was added for ButtonSpec styles:

| Member | Return Type | Description |
|--------|-------------|-------------|
| **GetButtonSpecType()** | `PaletteButtonSpecStyle` | Returns the button spec style. `Generic` means use custom image/tooltip. |

Existing members remain: `GetImage()`, `GetText()`, `GetEnabled()`, `GetVisible()`, `GetToolTipTitle()`, `GetToolTipBody()`, `GetShortcutKeys()`, etc.

---

### KryptonRibbon

| Member | Type | Description |
|--------|------|-------------|
| **QATButtons** | `KryptonRibbonQATButtonCollection` | Collection of QAT buttons. |
| **InsertStandardQATItems()** | `void` | Clears `QATButtons` and adds a standard set (New, Open, Save, Cut, Copy, Paste, etc.). |

**Internal (designer use):**

| Member | Return Type | Description |
|--------|-------------|-------------|
| **CreateStandardQATButtons()** | `KryptonRibbonQATButton[]` | Creates template buttons for the standard set. Uses `KryptonManager.Strings.ToolBarStrings` for text. |

---

### KryptonRibbonDesigner

| Verb | Description |
|------|-------------|
| **Insert Standard Items** | Clears existing QAT buttons and inserts the standard set. Wrapped in a designer transaction for undo/redo. |

---

## PaletteButtonSpecStyle Enum

Defined in `Krypton.Toolkit` (`PaletteDefinitions.cs`). Styles suitable for QAT toolbar buttons:

### File operations

| Value | Description |
|-------|-------------|
| `New` | New document/file |
| `Open` | Open file |
| `Save` | Save |
| `SaveAs` | Save as |
| `SaveAll` | Save all documents |

### Edit operations

| Value | Description |
|-------|-------------|
| `Cut` | Cut |
| `Copy` | Copy |
| `Paste` | Paste |
| `Undo` | Undo |
| `Redo` | Redo |
| `SelectAll` | Select all |
| `SelectNone` | Select none |

### Print operations

| Value | Description |
|-------|-------------|
| `PageSetup` | Page setup |
| `PrintPreview` | Print preview |
| `Print` | Print |
| `QuickPrint` | Quick print |

### Navigation / UI

| Value | Description |
|-------|-------------|
| `Previous` | Previous |
| `Next` | Next |
| `ArrowLeft` | Left arrow |
| `ArrowRight` | Right arrow |
| `ArrowUp` | Up arrow |
| `ArrowDown` | Down arrow |
| `DropDown` | Drop-down indicator |
| `Close` | Close |
| `Context` | Context menu |

### Form / ribbon

| Value | Description |
|-------|-------------|
| `FormClose` | Form close |
| `FormMin` | Form minimize |
| `FormMax` | Form maximize |
| `FormRestore` | Form restore |
| `FormHelp` | Form help |
| `RibbonMinimize` | Ribbon minimize |
| `RibbonExpand` | Ribbon expand |
| `Generic` | Generic; use custom `Image`. |

`Generic` is the default for `KryptonRibbonQATButton.Type`. All other values use palette-provided icons and tooltips unless overridden.

---

## Insert Standard Items

### Designer

1. Select the `KryptonRibbon` in the designer.
2. Open the designer actions (smart tag) or right-click context menu.
3. Choose **Insert Standard Items**.

This replaces all QAT buttons with the standard set: New, Open, Save, Save As, Save All, Cut, Copy, Paste, Undo, Redo, Page Setup, Print Preview, Print, Quick Print. Each button has `Type` and `Text` set from `KryptonManager.Strings.ToolBarStrings`.

### Runtime

```csharp
kryptonRibbon.InsertStandardQATItems();
```

Same result as the designer verb: clears `QATButtons` and adds the standard set.

---

## Usage Examples

### Typed QAT button (code)

```csharp
var saveButton = new KryptonRibbonQATButton
{
    Type = PaletteButtonSpecStyle.Save,
    Text = "Save"
};
saveButton.Click += (s, e) => SaveDocument();
kryptonRibbon.QATButtons.Add(saveButton);
```

### Typed QAT button (designer)

Set `Type` to `Save` (or another style) in the Properties window. The palette supplies icon and default tooltip.

### Custom image with Generic

```csharp
var customButton = new KryptonRibbonQATButton
{
    Type = PaletteButtonSpecStyle.Generic,
    Image = my16x16Icon,
    Text = "Custom Action"
};
kryptonRibbon.QATButtons.Add(customButton);
```

### Override tooltip for typed button

```csharp
var saveButton = new KryptonRibbonQATButton
{
    Type = PaletteButtonSpecStyle.Save,
    Text = "Save",
    ToolTipTitle = "Save the current document (Ctrl+S)"
};
```

### Use KryptonCommand

```csharp
var saveCommand = new KryptonCommand
{
    Text = "Save",
    ImageSmall = myIcon,
    ShortcutKeys = Keys.Control | Keys.S
};
var saveButton = new KryptonRibbonQATButton
{
    Type = PaletteButtonSpecStyle.Save,
    KryptonCommand = saveCommand
};
```

When `KryptonCommand` is set, `Text` and `ImageSmall` from the command are used. With `Type != Generic`, the palette still provides the main icon unless you explicitly set a custom image.

---

## Custom Implementers

If you implement `IQuickAccessToolbarButton` yourself:

1. Implement `GetButtonSpecType()` and return the appropriate `PaletteButtonSpecStyle`.
2. For backward compatibility, return `PaletteButtonSpecStyle.Generic` if you do not support typed styles.
3. When `GetButtonSpecType() != Generic`, `GetImage()` is only used as a fallback if the palette returns `null`.

Example:

```csharp
public PaletteButtonSpecStyle GetButtonSpecType() => PaletteButtonSpecStyle.Generic;
```

---

## Backward Compatibility

- **Existing QAT buttons:** Default `Type` is `Generic`. Behavior matches pre-feature: custom or default image, explicit tooltips.
- **Binary compatibility:** Adding `GetButtonSpecType()` to `IQuickAccessToolbarButton` is a breaking change for custom implementers. They must add the method (e.g. returning `Generic`).

---

## Internal Implementation

### Image resolution

In `ViewDrawRibbonQATButton.GetImage(PaletteState state)`:

- `Type != Generic`: `_ribbon.GetRedirector().GetButtonSpecImage(type, state)`
- `Type == Generic`: `QATButton.GetImage()` (custom image or default)

### Color mapping

- `QATButtonToContent.GetContentImageColorMap()` returns `GetButtonSpecColorMap(type)` when `Type != Generic`.
- `ViewDrawRibbonQATButton.GetImageTransparentColor()` returns `GetButtonSpecImageTransparentColor(type)` when typed.

### Tooltip

- `QATButtonToolTipToContent.GetShortText()`: if `Type != Generic` and `GetToolTipTitle()` is empty, uses `GetButtonSpecToolTipTitle(type)` from the palette.

### Cache invalidation

- `ViewDrawRibbonQATButton` subscribes to `QATButton.PropertyChanged` and clears the cached image when any property changes.
