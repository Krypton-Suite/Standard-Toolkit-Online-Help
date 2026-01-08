# Ribbon Backstage View

## Table of Contents

- [Overview](#overview)
- [Key Goals](#key-goals)
- [Behavior and Fallback Rules](#behavior-and-fallback-rules)
- [Public API Reference](#public-api-reference)
  - [Ribbon configuration (`RibbonFileAppTab`)](#ribbon-configuration-ribbonfileapptab)
  - [Backstage view control (`KryptonBackstageView`)](#backstage-view-control-kryptonbackstageview)
  - [Backstage page (`KryptonBackstagePage`)](#backstage-page-kryptonbackstagepage)
  - [Backstage command (`KryptonBackstageCommand`)](#backstage-command-kryptonbackstagecommand)
  - [Ribbon lifecycle events (`KryptonRibbon`)](#ribbon-lifecycle-events-kryptonribbon)
  - [Programmatic close (`KryptonRibbon.CloseBackstageView()`)](#programmatic-close-kryptonribbonclosebackstageview)
- [How To: Manage Backstage Items (Pages and Commands)](#how-to-manage-backstage-items-pages-and-commands)
  - [Runtime management](#runtime-management)
  - [Designer management (recommended)](#designer-management-recommended)
- [Designer Support](#designer-support)
  - [Designer verbs](#designer-verbs)
  - [Collection editor](#collection-editor)
  - [Design-time page editing](#design-time-page-editing)
- [Usage Examples](#usage-examples)
  - [Basic setup (runtime)](#basic-setup-runtime)
  - [Designer-first setup (recommended)](#designer-first-setup-recommended)
  - [Handling open/close events](#handling-openclose-events)
  - [Using navigation images and item sizes](#using-navigation-images-and-item-sizes)
  - [Using command items](#using-command-items)
  - [Configuring overlay coverage](#configuring-overlay-coverage)
- [Creating Backstage Pages](#creating-backstage-pages)
  - [See also: [Creating Backstage Pages - In-Depth Guide](Ribbon-BackstageView-CreatingPages.md)](#see-also-creating-backstage-pages---in-depth-guide)
- [New Features](#new-features)
- [Implementation Notes (for contributors)](#implementation-notes-for-contributors)
- [Known Limitations and Future Enhancements](#known-limitations-and-future-enhancements)
- [Files and Key Types](#files-and-key-types)

---

## Overview

This feature adds an optional **Office 2010-style Backstage View** to `KryptonRibbon` when using the **File tab** (Office 2010+ ribbon shapes).

It is designed to:

- Behave like Office: **selecting/clicking “File” shows a full-screen-ish Backstage surface**
- Provide a **designer-friendly “items” model**: pages can be added/removed/reordered in the Visual Studio designer
- Preserve backwards compatibility and expected behavior by keeping the **existing app menu popup** as the default fallback

---

## Key Goals

- **Default fallback remains the app menu popup**
  - No app code changes required unless you opt in.
- **First-class Backstage model**
  - `KryptonBackstageView` + `KryptonBackstagePage` + `Pages` collection.
- **Visual Studio designer support**
  - Add/remove/clear pages via designer verbs, edit page contents via designer.
- **Low-level escape hatch remains**
  - Backstage still hosts a `Control` (via `BackstageContent`) so advanced apps can provide custom content if needed.

---

## Behavior and Fallback Rules

### Behavior matrix

| Ribbon shape | User action | Backstage enabled & configured? | Result |
|---|---:|---:|---|
| `Office2007` | Click orb | N/A | App menu **popup** (existing behavior) |
| `Office2010+` | Click File tab | Yes (see below) | Backstage **overlay** |
| `Office2010+` | Click File tab | No | App menu **popup** (fallback/default) |

### “Enabled & configured” definition

Backstage is only used when:

- `kryptonRibbon.RibbonShape != PaletteRibbonShape.Office2007`
- `kryptonRibbon.RibbonFileAppTab.UseBackstageView == true`
- and either of the following supplies content:
  - `kryptonRibbon.RibbonFileAppTab.BackstageView != null` (**recommended**)
  - or `kryptonRibbon.RibbonFileAppTab.BackstageContent != null` (advanced)

If any requirement is not met, Krypton falls back to the existing `VisualPopupAppMenu`.

### Toggle behavior

- Clicking File **opens** Backstage.
- Clicking File again **closes** Backstage.
- Pressing **ESC** inside Backstage requests close.

---

## Public API Reference

### Ribbon configuration (`RibbonFileAppTab`)

#### `bool UseBackstageView`

- **Default**: `false`
- **Meaning**: opt-in switch; if enabled and content is provided, File tab toggles Backstage instead of the popup.

#### `Control? BackstageContent`

- **Default**: `null`
- **Meaning**: advanced “host any control” entry point.
- **Notes**:
  - The control is temporarily re-parented into the overlay while Backstage is open.
  - This property is not designer-serialized by default.

#### `KryptonBackstageView? BackstageView`

- **Default**: `null`
- **Meaning**: designer-friendly wrapper around `BackstageContent`.
- **Recommended**: use this for long-term maintainability + consistent UX + designer support.

---

### Backstage view control (`KryptonBackstageView`)

`KryptonBackstageView` is a composite control providing:

- **Left navigation** (custom-drawn list) listing pages, commands, and the Close button
- **Right content host** showing the selected page
- **Office-like styling** with support for images and large/small item sizes

Key API:

#### `KryptonBackstagePageCollection Pages`

- Collection of pages (your "items").
- Supports add/remove/reorder and is designer-serialized.

#### `KryptonBackstageCommandCollection Commands`

- Collection of command-only items (no associated page).
- Commands execute actions when clicked without showing a page.
- Supports add/remove/reorder.

#### `KryptonBackstagePage? SelectedPage`

- Currently selected/visible page.

#### `int NavigationWidth`

- Width of the left navigation panel.

#### `BackstageOverlayMode OverlayMode`

- Determines overlay coverage area.
- **Values**:
  - `FullClient`: Overlay covers the entire form client area (default)
  - `BelowRibbon`: Overlay covers only the area below the ribbon
- **Default**: `FullClient`

#### `event EventHandler SelectedPageChanged`

- Fired when selection changes.

#### `event CancelEventHandler CloseRequested`

- Occurs when the Close button in the navigation list is clicked.
- Allows developers to cancel the application close or perform custom actions (e.g., save data, show confirmation dialog).
- Set `e.Cancel = true` to prevent the application from closing.

#### `BackstageColors Colors`

- Expandable property group for customizing Backstage View colors.
- **Properties**:
  - `Color? NavigationBackgroundColor`: Custom background color for the left navigation panel. If `null`, defaults to the theme's `PanelAlternate` color.
  - `Color? ContentBackgroundColor`: Custom background color for the right content area. If `null`, defaults to the theme's `PanelClient` color.
  - `Color? SelectedItemHighlightColor`: Custom highlight color for selected navigation items. If `null`, defaults to the theme's tracking color (retrieved via `SchemeTrackingColors.MenuItemSelectedBegin`), which automatically adapts to Office 2010, Office 2013, Microsoft 365, and other themes.
- **Usage**: Expand the `Colors` property in the designer to customize individual colors, or set them to `null` to use theme defaults.

---

### Backstage page (`KryptonBackstagePage`)

`KryptonBackstagePage` is a `KryptonPanel` used as a page container. Since it inherits from `KryptonPanel`, it supports all standard panel properties and can host any Windows Forms controls.

Key API:

#### `string Text`

- Display text shown in the navigation list for this page.
- Inherited from `Control.Text`.

#### `Image? Image`

- Image shown in the navigation list alongside the text.
- Images are automatically scaled to fit (16px for Small items, 32px for Large items).
- Optional; can be set to provide visual identification in the navigation list.

#### `BackstageItemSize ItemSize`

- Size of this item in the navigation list.
- **Values**:
  - `Small`: Compact display (40px height, 16px image)
  - `Large`: Office-like prominent display (60px height, 32px image, larger font)
- **Default**: `Small`

#### `bool VisibleInNavigation`

- If `false`, the page remains in the collection but is not listed in the navigation.
- Useful for programmatically accessible pages that shouldn't appear in the navigation list.
- Default: `true`

#### `event EventHandler NavigationPropertyChanged`

- Raised when `Text`, `Image`, `ItemSize`, or `VisibleInNavigation` changes (used to refresh navigation).

#### Inherited from `KryptonPanel`

Since `KryptonBackstagePage` inherits from `KryptonPanel`, you have access to all panel properties:
- `PanelBackStyle`: Control the background style of the page
- `Dock`: Page docking (automatically set to `Fill` by the view)
- `Padding`, `Margin`: Control spacing
- All standard `Control` properties: `BackColor`, `ForeColor`, `Font`, `Enabled`, `Visible`, etc.

**See also**: [Creating Backstage Pages - In-Depth Guide](KryptonRibbonBackstageViewCreatingPages.md) for comprehensive examples and best practices.

---

### Backstage command (`KryptonBackstageCommand`)

`KryptonBackstageCommand` represents a command-only item in the navigation list that executes an action when clicked, without showing a page.

Key API:

#### `string Text`

- Display text shown in the navigation list for this command.

#### `Image? Image`

- Image shown in the navigation list alongside the text.
- Images are automatically scaled to fit (16px for Small items, 32px for Large items).
- Optional; can be set to provide visual identification.

#### `BackstageItemSize ItemSize`

- Size of this item in the navigation list.
- **Values**:
  - `Small`: Compact display (40px height, 16px image)
  - `Large`: Office-like prominent display (60px height, 32px image, larger font)
- **Default**: `Small`

#### `bool VisibleInNavigation`

- If `false`, the command remains in the collection but is not listed in the navigation.
- Default: `true`

#### `event EventHandler Click`

- Occurs when the command is clicked.
- Use this event to execute the command's action.

#### `event EventHandler NavigationPropertyChanged`

- Raised when `Text`, `Image`, `ItemSize`, or `VisibleInNavigation` changes (used to refresh navigation).

#### `void PerformClick()`

- Programmatically triggers the command's `Click` event.

**Usage Example**:
```csharp
var exitCommand = new KryptonBackstageCommand("Exit")
{
    Image = Properties.Resources.ExitIcon,
    ItemSize = BackstageItemSize.Small
};
exitCommand.Click += (s, e) => Application.Exit();
backstage.Commands.Add(exitCommand);
```

---

### Ribbon lifecycle events (`KryptonRibbon`)

Backstage overlay lifecycle events:

- `CancelEventHandler BackstageOpening`
- `EventHandler BackstageOpened`
- `CancelEventHandler BackstageClosing`
- `EventHandler BackstageClosed`

Use these to:

- prevent opening/closing (`CancelEventArgs.Cancel = true`)
- coordinate app state, telemetry, and focus

---

### Programmatic close (`KryptonRibbon.CloseBackstageView()`)

`CloseBackstageView()` closes the overlay if open (no-op if not open). Closing can be canceled via `BackstageClosing`.

---

## How To: Manage Backstage Items (Pages and Commands)

The Backstage View supports two types of navigation items:

1. **Pages** (`KryptonBackstagePage`): Navigate to a page with content
2. **Commands** (`KryptonBackstageCommand`): Execute an action without showing a page

### Runtime management

#### Managing Pages

```csharp
var backstage = new KryptonBackstageView();

var page = new KryptonBackstagePage 
{ 
    Text = "Save",
    Image = Properties.Resources.SaveIcon,
    ItemSize = BackstageItemSize.Large
};
backstage.Pages.Add(page);

backstage.Pages.Remove(page);
```

#### Managing Commands

```csharp
var command = new KryptonBackstageCommand("Exit")
{
    Image = Properties.Resources.ExitIcon,
    ItemSize = BackstageItemSize.Small
};
command.Click += (s, e) => Application.Exit();
backstage.Commands.Add(command);

backstage.Commands.Remove(command);
```

### Designer management (recommended)

1. Drag a `KryptonBackstageView` onto your form.
2. Right-click it and use verbs:
   - **Add Page**
   - **Remove Page**
   - **Clear Pages**
3. Select a page in the designer and design its contents like a normal panel.
4. Assign it to the ribbon:
   - `kryptonRibbon.RibbonFileAppTab.UseBackstageView = true`
   - `kryptonRibbon.RibbonFileAppTab.BackstageView = kryptonBackstageView1`

---

## Designer Support

### Designer verbs

The `KryptonBackstageView` designer provides verbs similar to `KryptonNavigator`:

- **Add Page**: creates and inserts a new `KryptonBackstagePage`
- **Remove Page**: removes the selected page
- **Clear Pages**: removes all pages

### Collection editor

The `Pages` property is marked with a collection editor, enabling:

- Add/remove pages
- Reorder pages
- Edit page properties

### Design-time page editing

Pages are exposed as designable child controls; you can:

- select a `KryptonBackstagePage` in the Document Outline
- add controls to it using the normal designer
- keep page docking/visibility managed by the view at runtime

---

## Usage Examples

### Basic setup (runtime)

```csharp
var backstage = new KryptonBackstageView { Dock = DockStyle.Fill };

// Add pages with images and sizes
backstage.Pages.Add(new KryptonBackstagePage 
{ 
    Text = "Info",
    Image = Properties.Resources.InfoIcon,
    ItemSize = BackstageItemSize.Large
});
backstage.Pages.Add(new KryptonBackstagePage 
{ 
    Text = "Save",
    Image = Properties.Resources.SaveIcon,
    ItemSize = BackstageItemSize.Small
});

// Add commands
var exitCommand = new KryptonBackstageCommand("Exit")
{
    Image = Properties.Resources.ExitIcon,
    ItemSize = BackstageItemSize.Small
};
exitCommand.Click += (s, e) => Application.Exit();
backstage.Commands.Add(exitCommand);

// Configure overlay mode
backstage.OverlayMode = BackstageOverlayMode.FullClient;

kryptonRibbon.RibbonFileAppTab.UseBackstageView = true;
kryptonRibbon.RibbonFileAppTab.BackstageView = backstage;
```

### Designer-first setup (recommended)

```csharp
// kryptonBackstageView1 created in designer, pages added via designer verbs
kryptonRibbon.RibbonFileAppTab.UseBackstageView = true;
kryptonRibbon.RibbonFileAppTab.BackstageView = kryptonBackstageView1;
```

### Handling open/close events

```csharp
kryptonRibbon.BackstageOpening += (_, e) =>
{
    // e.Cancel = true; // optionally block opening
};

kryptonRibbon.BackstageClosing += (_, e) =>
{
    // e.Cancel = true; // optionally block closing
};
```

### Customizing colors

```csharp
// Customize navigation and content background colors
backstage.Colors.NavigationBackgroundColor = Color.FromArgb(45, 45, 48);
backstage.Colors.ContentBackgroundColor = Color.White;

// Customize selected item highlight color
backstage.Colors.SelectedItemHighlightColor = Color.FromArgb(68, 114, 196);

// Reset to theme defaults (set to null)
backstage.Colors.NavigationBackgroundColor = null;
backstage.Colors.ContentBackgroundColor = null;
backstage.Colors.SelectedItemHighlightColor = null;
```

**Note**: When color properties are `null`, the Backstage View automatically uses theme-appropriate defaults:
- Navigation background: `PanelAlternate` palette color
- Content background: `PanelClient` palette color
- Selected item highlight: Theme's tracking color (`SchemeTrackingColors.MenuItemSelectedBegin`), which automatically adapts to Office 2010, Office 2013, Microsoft 365, and other themes

### Handling Close button click

The Backstage View includes a permanent "Close" button at the bottom of the navigation list that closes the application. You can intercept this action using the `CloseRequested` event:

```csharp
backstage.CloseRequested += (sender, e) =>
{
    // Show a confirmation dialog
    var result = MessageBox.Show(
        "Are you sure you want to exit?",
        "Confirm Exit",
        MessageBoxButtons.YesNo,
        MessageBoxIcon.Question);

    if (result == DialogResult.No)
    {
        // Cancel the close
        e.Cancel = true;
    }
    else
    {
        // Allow the close to proceed
        // Optionally save data here before the application closes
        SaveUserData();
    }
};
```

**Note**: If `e.Cancel` is set to `true`, the application will not close and the Backstage View will remain open. The Close button selection will be cleared and the previously selected page will be restored.

### Using navigation images and item sizes

Pages and commands support images and can be displayed in Small or Large size:

```csharp
// Create a page with image and large size
var infoPage = new KryptonBackstagePage
{
    Text = "Information",
    Image = Properties.Resources.InfoIcon,
    ItemSize = BackstageItemSize.Large  // More prominent display
};
backstage.Pages.Add(infoPage);

// Create a small command with image
var optionsCommand = new KryptonBackstageCommand("Options")
{
    Image = Properties.Resources.OptionsIcon,
    ItemSize = BackstageItemSize.Small  // Compact display
};
optionsCommand.Click += (s, e) => ShowOptionsDialog();
backstage.Commands.Add(optionsCommand);
```

**Item Size Details**:
- **Small**: 40px height, 16px image, standard font size (default)
- **Large**: 60px height, 32px image, 10% larger font size

### Using command items

Command items allow you to add actions to the navigation list without creating pages:

```csharp
// Add an Exit command
var exitCommand = new KryptonBackstageCommand("Exit")
{
    Image = Properties.Resources.ExitIcon,
    ItemSize = BackstageItemSize.Small
};
exitCommand.Click += (s, e) =>
{
    if (MessageBox.Show("Exit application?", "Confirm", MessageBoxButtons.YesNo) == DialogResult.Yes)
    {
        Application.Exit();
    }
};
backstage.Commands.Add(exitCommand);

// Add a Print command
var printCommand = new KryptonBackstageCommand("Print")
{
    Image = Properties.Resources.PrintIcon,
    ItemSize = BackstageItemSize.Large  // Make it prominent
};
printCommand.Click += (s, e) => PrintDocument();
backstage.Commands.Add(printCommand);
```

**Note**: Commands appear in the navigation list between pages and the Close button. When clicked, they execute their `Click` event handler and do not change the selected page.

### Configuring overlay coverage

You can control whether the Backstage overlay covers the entire form or only the area below the ribbon:

```csharp
// Full client area (default)
backstage.OverlayMode = BackstageOverlayMode.FullClient;

// Below ribbon only
backstage.OverlayMode = BackstageOverlayMode.BelowRibbon;
```

**Overlay Modes**:
- **FullClient**: The overlay covers the entire form's client area (default behavior)
- **BelowRibbon**: The overlay covers only the area below the ribbon, leaving the ribbon visible

**Use Cases**:
- `FullClient`: Traditional Office-style Backstage that covers everything
- `BelowRibbon`: When you want users to still see and access the ribbon while in Backstage

---

## Creating Backstage Pages

For comprehensive guidance on creating and designing Backstage pages, see the [Creating Backstage Pages - In-Depth Guide](KryptonRibbonBackstageViewCreatingPages.md).

This guide covers:
- Understanding `KryptonBackstagePage` as a `KryptonPanel`
- Designing pages in the Visual Studio designer
- Common page layouts and patterns
- Adding controls and organizing content
- Using Krypton controls within pages
- Best practices and examples

---

## Implementation Notes (for contributors)

High-level architecture:

- File tab click path is intercepted to call `KryptonRibbon.TryToggleBackstageView()`.
- If it returns `false`, code falls back to `VisualPopupAppMenu`.
- The overlay is implemented by `BackstageOverlayForm` (a `KryptonForm` configured as a borderless overlay).
- The overlay hosts a single `Control` (typically `KryptonBackstageView`) via temporary re-parenting and restores it on close.

Important design patterns reused from `Krypton.Navigator`:

- `TypedCollection<T>` pattern for `Pages`
- Designer verbs pattern (Add/Remove/Clear)
- Collection editor pattern

---

## New Features

The Backstage View now includes three major enhancements:

### 1. Navigation Visuals with Images and Office-like Styling

- **Image Support**: Pages and commands can display images in the navigation list
- **Item Sizes**: Support for Small (40px) and Large (60px) item sizes
- **Automatic Scaling**: Images are automatically scaled to fit (16px for Small, 32px for Large)
- **Enhanced Typography**: Large items use a 10% larger font size for better visibility

**Example**:
```csharp
var page = new KryptonBackstagePage
{
    Text = "Information",
    Image = Properties.Resources.InfoIcon,
    ItemSize = BackstageItemSize.Large  // Prominent display
};
```

### 2. Command Items

- **Action-Only Items**: Commands execute actions without showing a page
- **Click Events**: Handle command execution via the `Click` event
- **Full Feature Parity**: Commands support images, item sizes, and visibility control just like pages

**Example**:
```csharp
var exitCommand = new KryptonBackstageCommand("Exit")
{
    Image = Properties.Resources.ExitIcon,
    ItemSize = BackstageItemSize.Small
};
exitCommand.Click += (s, e) => Application.Exit();
backstage.Commands.Add(exitCommand);
```

### 3. Overlay Coverage Modes

- **FullClient Mode**: Overlay covers the entire form client area (default, traditional Office-style)
- **BelowRibbon Mode**: Overlay covers only the area below the ribbon, keeping the ribbon visible

**Example**:
```csharp
// Traditional full-screen overlay
backstage.OverlayMode = BackstageOverlayMode.FullClient;

// Keep ribbon visible
backstage.OverlayMode = BackstageOverlayMode.BelowRibbon;
```

---

## Known Limitations and Future Enhancements

All previously planned enhancements have been implemented:
- ✅ **Navigation visuals**: Owner-draw navigation with image support and Office-like styling (large/small item sizes)
- ✅ **Command items**: Command-only items (no page) for actions like Exit/Options
- ✅ **Overlay coverage**: Support for both full client area and "below ribbon only" overlay modes

**Current Status**: The Backstage View feature is feature-complete with all planned enhancements implemented.