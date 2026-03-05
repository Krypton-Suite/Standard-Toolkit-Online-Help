# KryptonFormTitleBar

## Table of Contents

1. [Overview](#overview)
2. [Architecture & Design](#architecture--design)
3. [Quick Start](#quick-start)
4. [API Reference — KryptonFormTitleBar](#api-reference--kryptonformtitlebar)
5. [API Reference — KryptonForm.TitleBar](#api-reference--kryptonformtitlebar-1)
6. [API Reference — ButtonSpecAny](#api-reference--buttonspecany)
7. [Design-Time Usage](#design-time-usage)
8. [Runtime Usage](#runtime-usage)
9. [ButtonSpec Properties In Depth](#buttonspec-properties-in-depth)
10. [KryptonCommand Integration](#kryptoncommand-integration)
11. [RTL (Right-to-Left) Support](#rtl-right-to-left-support)
12. [Theming & Palette Integration](#theming--palette-integration)
13. [Interaction with KryptonRibbon](#interaction-with-kryptonribbon)
14. [Lifecycle & Resource Management](#lifecycle--resource-management)
15. [Internal Architecture](#internal-architecture)
16. [Limitations & Known Constraints](#limitations--known-constraints)
17. [Best Practices](#best-practices)
18. [Troubleshooting](#troubleshooting)
19. [Related Components](#related-components)

---

## Overview

`KryptonFormTitleBar` is a non-visual `Component` that embeds a toolbar of `ButtonSpecAny` items directly inside the `KryptonForm` title bar (caption area), to the left of the form title text. It provides a DevExpress ToolbarForm-style experience where quick-action buttons, toggles, or drop-down triggers live in the chrome itself rather than consuming client area space.

### What it looks like

```
┌─────────────────────────────────────────────────────────────────────┐
│ [Icon]        My Application    [⬡][★][⚙][File▼][Edit▼]  [─][□][✕] │  ← title bar
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│                    Form client area                                 │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
                             ↑ ButtonSpecs live here (right of icon and title)
```

In **LTR** layout the button specs appear to the right of the form icon and title text, before the min/max/close buttons.  
In **RTL** layout they mirror to the left of the title text — identical to how the Ribbon QAT behaves.

### Key Features

- **Zero client area impact** — buttons live in the non-client caption area
- **Full `ButtonSpecAny` feature set** — icons, text, tooltips, checked states, drop-downs, `KryptonCommand` binding, context menus
- **Full palette/theme integration** — rendering inherits the active Krypton palette automatically; no manual colour management needed
- **RTL support** — Left/Right docking flips automatically when `RightToLeftLayout` is enabled
- **Designer support** — drag-and-drop onto a form in Visual Studio, full property grid, smart-tag support, and "Insert Standard Items" (MenuStrip-style)
- **Safe lifecycle** — attach/detach at any time; disposing either the component or the form cleans up correctly

### Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── Krypton.Toolkit.KryptonFormTitleBar
```

### Location

| Item | Namespace / Assembly |
|---|---|
| `KryptonFormTitleBar` | `Krypton.Toolkit` / `Krypton.Toolkit.dll` |
| `KryptonForm.TitleBar` property | `Krypton.Toolkit` / `Krypton.Toolkit.dll` |

---

## Architecture & Design

### Injection Mechanism

`KryptonFormTitleBar` uses the same view-injection mechanism that `KryptonRibbon` uses to integrate its Quick Access Toolbar and application button into the form chrome.

`KryptonForm` owns a private `ViewDrawDocker` called `_drawHeading` that represents the entire caption area. When a `KryptonFormTitleBar` is assigned to `KryptonForm.TitleBar`, the form:

1. Creates a `ViewDrawDocker` (`_titleBarDocker`) styled with the active header palette.
2. Creates a `ButtonSpecManagerDraw` (`_titleBarButtonManager`) that manages the `ButtonSpecAny` items from `KryptonFormTitleBar.ButtonSpecs` inside that docker.
3. Calls `InjectViewElement(_titleBarDocker, ViewDockStyle.Right)`, adding the docker to the **right** docking edge of `_drawHeading` — so the menu/buttons appear to the right of the form icon and title.

This means all rendering, hit-testing, mouse tracking, tooltip display, and palette change propagation work through exactly the same infrastructure as the rest of the form chrome.

### Caption Layout Order (LTR)

```
_drawHeading (ViewDrawDocker)
  ├─ [Fill]  _drawContent (form icon + title text)
  ├─ [Right] _titleBarDocker  ← injected by KryptonFormTitleBar (to the right of the icon)
  │             └─ ButtonSpecAny buttons (managed by _titleBarButtonManager)
  └─ [Right] min / max / close buttons (managed by _buttonManager)
```

### Hit-Testing

Because `_titleBarDocker` is a child of `_drawHeading`, the existing `WindowChromeHitTest` logic handles it correctly:

- A click on a button spec view returns a `ButtonController`-driven response through `WindowChromeLeftMouseDown` → `ViewManager.Root.ViewFromPoint`.
- A click on empty title space falls through to `mouseView == _drawHeading` and returns `HT_CAPTION`, keeping the window draggable.
- The min/max/close button rectangles are checked first and are never obscured.

No custom `CustomCaptionArea` rectangle is needed or set.

---

## Quick Start

### Design Time

1. Open a `KryptonForm` in the Visual Studio designer.
2. Open the Toolbox. Under **Krypton Toolkit**, locate **KryptonFormTitleBar** and drag it onto the form. It appears in the component tray.
3. Select the form itself. In the **Properties** window, find the **TitleBar** property (under **Visuals**) and select the `KryptonFormTitleBar` component from the drop-down.
4. Select the `KryptonFormTitleBar` component in the tray. In **Properties**, click the `...` button on **ButtonSpecs** to open the collection editor.
5. Add one or more `ButtonSpecAny` items. Set `Image`, `ToolTipTitle`, and `Type = Generic` for each.
6. Run the project — the buttons appear in the title bar.

### Runtime (C#)

```csharp
var titleBar = new KryptonFormTitleBar();

// Home button
var homeSpec = new ButtonSpecAny
{
    Image           = Properties.Resources.HomeIcon16,
    ToolTipTitle    = "Home",
    ToolTipBody     = "Navigate to the start page",
    Type            = PaletteButtonSpecStyle.Generic,
    Enabled         = ButtonEnabled.True
};
homeSpec.Click += (s, e) => NavigateHome();

// Settings button (toggle/checked)
var settingsSpec = new ButtonSpecAny
{
    Image   = Properties.Resources.SettingsIcon16,
    ToolTipTitle = "Settings",
    Type    = PaletteButtonSpecStyle.Generic,
    Checked = ButtonCheckState.Unchecked   // makes it a toggle
};
settingsSpec.Click += (s, e) => ToggleSettingsPanel();

titleBar.ButtonSpecs.AddRange([homeSpec, settingsSpec]);

// Attach to the form — this is all that is needed
this.TitleBar = titleBar;
```

### Runtime (VB.NET)

```vb
Dim titleBar As New KryptonFormTitleBar()

Dim homeSpec As New ButtonSpecAny With {
    .Image        = My.Resources.HomeIcon16,
    .ToolTipTitle = "Home",
    .Type         = PaletteButtonSpecStyle.Generic
}
AddHandler homeSpec.Click, AddressOf OnHomClicked

titleBar.ButtonSpecs.Add(homeSpec)
Me.TitleBar = titleBar
```

---

## API Reference — KryptonFormTitleBar

### Class Declaration

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(KryptonFormTitleBar), "ToolboxBitmaps.KryptonFormTitleBar.bmp")]
[DefaultEvent(nameof(ButtonSpecs))]
[DefaultProperty(nameof(ButtonSpecs))]
[Designer(typeof(KryptonFormTitleBarDesigner))]
[DesignerCategory("code")]
[Description("Hosts button-spec items inside the KryptonForm title bar.")]
public class KryptonFormTitleBar : Component
```

### Properties

#### `ButtonSpecs`

```csharp
[Category("Visuals")]
[Description("Collection of button specifications shown in the title bar.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public FormTitleBarButtonSpecCollection ButtonSpecs { get; }
```

The ordered collection of `ButtonSpecAny` items to render in the title bar. Items are rendered **left-to-right** in the order they appear in the collection (LTR layout). The collection is read-only as a property (you cannot replace it), but items can be added, removed, and reordered freely at any time.

Mutations to this collection at runtime trigger an immediate repaint and re-layout of the title bar. There is no need to call any refresh method manually.

**Type:** `KryptonFormTitleBar.FormTitleBarButtonSpecCollection` (a `ButtonSpecCollection<ButtonSpecAny>`)

---

#### `OwnerForm`

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonForm? OwnerForm { get; }
```

Returns the `KryptonForm` that this component is currently attached to, or `null` if not attached. This property is set automatically by `KryptonForm` when the `TitleBar` property is assigned; do not set it directly.

---

### Methods

#### `InsertStandardItems()`

```csharp
public void InsertStandardItems()
```

Inserts a standard set of button specifications into the title bar, similar to the WinForms MenuStrip **Insert Standard Items** option. Adds:

**Top-level menu dropdowns** (File, Edit, Tools, Help) — text buttons with drop-down arrows; each opens a `KryptonContextMenu`:

| Menu | Sub-items |
|------|-----------|
| **File** | New, Open, Save, Save As, Save All, —, Print, Print Preview, —, Exit |
| **Edit** | Undo, Redo, —, Cut, Copy, Paste, —, Select All |
| **Tools** | Customize, Options |
| **Help** | Contents, Index, —, About |

**Flat icon buttons** — quick-access toolbar buttons using palette images: New, Open, Save, Save As, Save All, Cut, Copy, Paste, Undo, Redo, Page Setup, Print Preview, Print, Quick Print.

**Usage:**

```csharp
// At runtime
myTitleBar.InsertStandardItems();

// Wire up actions — e.g. on menu items
var fileMenu = (KryptonContextMenu)myTitleBar.ButtonSpecs[0].KryptonContextMenu!;
// ... locate menu items and subscribe to Click
```

At design time, use the **Insert Standard Items** verb (right-click on the component) or the smart-tag action to insert the same set.

---

### Nested Types

#### `FormTitleBarButtonSpecCollection`

```csharp
public class FormTitleBarButtonSpecCollection : ButtonSpecCollection<ButtonSpecAny>
```

Strongly-typed collection of `ButtonSpecAny` items. Inherits all standard collection behaviour from `ButtonSpecCollection<T>`, including:

| Member | Description |
|---|---|
| `Add(ButtonSpecAny)` | Appends a button spec. Triggers title bar refresh. |
| `AddRange(IEnumerable<ButtonSpecAny>)` | Appends multiple specs. Each triggers a refresh. |
| `Insert(int, ButtonSpecAny)` | Inserts at a specific index. |
| `Remove(ButtonSpecAny)` | Removes the specified spec. |
| `RemoveAt(int)` | Removes by index. |
| `Clear()` | Removes all specs. |
| `Count` | Number of specs in the collection. |
| `this[int]` | Gets a spec by index. |
| `this[string]` | Gets a spec by `UniqueName` or `Text`. |
| `Inserted` event | Fires after a spec is added. |
| `Removed` event | Fires after a spec is removed. |

---

### Methods

| Method | Description |
|---|---|
| `InsertStandardItems()` | Adds top-level menus (File, Edit, Tools, Help) and flat icon buttons (New, Open, Save, etc.). See [Insert Standard Items](#insert-standard-items) above. |
| `Dispose()` | *(inherited)* Disposes the component, detaching it from any owning form first. |

### Dispose Behaviour

When `Dispose()` is called on a `KryptonFormTitleBar` that is attached to a form, the form's `TitleBar` property is automatically set to `null`, which triggers `DetachTitleBar` and cleans up the injected view elements. This means you do not need to detach the component manually before disposing it.

---

## API Reference — KryptonForm.TitleBar

### Property

```csharp
[Category("Visuals")]
[Description("Title bar component that hosts button-spec items in the form caption area.")]
[DefaultValue(null)]
public KryptonFormTitleBar? TitleBar { get; set; }
```

Gets or sets the `KryptonFormTitleBar` component that injects button-spec items into the form's caption area.

**Setting a new value:**

1. If a previous `KryptonFormTitleBar` was assigned, `DetachTitleBar` is called on it first.
2. The new component is stored.
3. `AttachTitleBar` is called on the new component, injecting the view and constructing the button manager.

**Setting to `null`:**  
Detaches and cleans up the current title bar component (if any). The form reverts to its standard caption layout.

**Changing the component at runtime** (replacing one with another) is fully supported. Detach and attach happen atomically in the setter.

---

## API Reference — ButtonSpecAny

Each item in `KryptonFormTitleBar.ButtonSpecs` is a `ButtonSpecAny`. All properties can be set at design time via the collection editor, or at runtime.

### Visual Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `Image` | `Image?` | `null` | The icon shown on the button. 16×16 px recommended for title bar sizing. |
| `Text` | `string` | `""` | Text label shown alongside or instead of the image. |
| `ExtraText` | `string` | `""` | Secondary text shown below the main text. |
| `ImageTransparentColor` | `Color` | `Empty` | Pixels of this colour in `Image` are rendered transparent. |
| `Style` | `PaletteButtonStyle` | `Inherit` | Overrides the palette button style (e.g. `Standalone`, `ButtonSpec`, `Inherit`). |
| `Orientation` | `PaletteButtonOrientation` | `Inherit` | Rotates the button content. |
| `ColorMap` | `Color` | `Empty` | Remaps a single source colour in the image to match a palette colour. |

### Behaviour Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `Type` | `PaletteButtonSpecStyle` | `Generic` | Determines whether the palette supplies a default image/style. `Generic` means the spec is fully custom. Other values (`Close`, `Pin`, `FormMin`, etc.) inherit defaults from the palette. |
| `Visible` | `bool` | `true` | When `false` the button is hidden and takes no space. |
| `Enabled` | `ButtonEnabled` | `Container` | `True` forces enabled; `False` forces disabled; `Container` follows the form's enabled state. |
| `Checked` | `ButtonCheckState` | `NotCheckButton` | `NotCheckButton` = normal push button. `Unchecked` / `Checked` = toggle button. Clicking a toggle button automatically inverts `Checked`. |
| `ShowDrop` | `bool` | `false` | Shows a drop-down arrow glyph on the button. Use with `ContextMenuStrip` or `KryptonContextMenu`. |
| `Edge` | `PaletteRelativeEdgeAlign` | `Inherit` | Which edge the button docks to within the title bar docker. |

### Context Menu Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `ContextMenuStrip` | `ContextMenuStrip?` | `null` | Standard WinForms context menu shown on click when `ShowDrop = true`. |
| `KryptonContextMenu` | `KryptonContextMenu?` | `null` | Krypton-styled context menu shown on click. Takes precedence over `ContextMenuStrip`. |

### Tooltip Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `ToolTipTitle` | `string` | `""` | Bold heading text in the tooltip. |
| `ToolTipBody` | `string` | `""` | Body text in the tooltip. |
| `ToolTipImage` | `Image?` | `null` | Image shown inside the tooltip. |
| `ToolTipStyle` | `LabelStyle` | `ToolTip` | Visual style of the tooltip popup. |
| `ToolTipImageTransparentColor` | `Color` | `Empty` | Transparent colour for the tooltip image. |

### Image State Properties

The `ImageStates` property (`CheckButtonImageStates`) provides separate images for each visual state:

| Sub-property | Description |
|---|---|
| `ImageNormal` | Image when the button is in its default state. |
| `ImageDisabled` | Image when the button is disabled. |
| `ImageTracking` | Image when the mouse is hovering over the button. |
| `ImagePressed` | Image when the button is being clicked. |
| `ImageCheckedNormal` | Image when the button is checked (toggle mode). |
| `ImageCheckedTracking` | Image when checked and mouse is hovering. |
| `ImageCheckedPressed` | Image when checked and being clicked. |

If per-state images are not set, the single `Image` property is used for all states.

### Events

| Event | Signature | Description |
|---|---|---|
| `Click` | `EventHandler?` | Fires when the button is clicked. The sender is the `ButtonSpecAny` instance. |
| `ButtonSpecPropertyChanged` | `PropertyChangedEventHandler?` | Fires when any property of the spec changes. |

### Unique Name

```csharp
public string UniqueName { get; set; }
```

A string identifier assigned automatically at construction (using an internal counter). You can override it to provide a stable identity for serialisation or lookup via `ButtonSpecs["myName"]`.

---

## Design-Time Usage

### Adding KryptonFormTitleBar to a Form

1. Drag **KryptonFormTitleBar** from the Toolbox onto the form. The component appears in the component tray (below the form surface).
2. Select the **form** and find the `TitleBar` property in the **Properties** window (under **Visuals**). Set it to the `KryptonFormTitleBar` you just added.
3. Select the **KryptonFormTitleBar** in the tray and expand `ButtonSpecs` in **Properties**, or click the smart-tag (▶) and choose **Button Specs**.
4. The **Collection Editor** opens. Click **Add** to add a `ButtonSpecAny`. Configure its properties on the right.

### Insert Standard Items

Like the WinForms MenuStrip, `KryptonFormTitleBar` supports **Insert Standard Items** to quickly populate the title bar with preconfigured buttons:

**From the designer:**
- **Right-click** the `KryptonFormTitleBar` in the component tray → **Insert Standard Items**
- Or click the **smart-tag** (▶) → **Insert Standard Items** (under Actions)

This adds the full standard set: four top-level menu dropdowns (File, Edit, Tools, Help) and fourteen flat icon buttons (New, Open, Save, Cut, Copy, Paste, etc.). You can then remove or reconfigure any items as needed, and wire `Click` events on individual specs or on the menu items within each dropdown.

### Smart-Tag (▶ Action List)

Clicking the smart-tag arrow on `KryptonFormTitleBar` in the component tray opens a panel with:

| Action | Description |
|---|---|
| **Insert Standard Items** | Adds File, Edit, Tools, Help (menus) plus New, Open, Save, Cut, Copy, Paste, Print, etc. (icons). |
| **Button Specs** | Opens the Collection Editor for `ButtonSpecs`. |

### Serialisation

The `ButtonSpecs` collection is marked `DesignerSerializationVisibility.Content`, so Visual Studio serialises each `ButtonSpecAny` it contains into `InitializeComponent()`. The `KryptonFormTitleBar` component itself is serialised as a field (e.g. `this.kryptonFormTitleBar1`), and the form's `TitleBar` assignment is emitted as a property assignment.

### Designer Cleanup

When you delete a `KryptonFormTitleBar` from the component tray, `KryptonFormTitleBarDesigner.OnComponentRemoving` automatically removes and destroys all child `ButtonSpecAny` components from the designer container, preventing orphan components in `InitializeComponent()`.

---

## Runtime Usage

### Insert Standard Items at Runtime

```csharp
// Add the full standard set (menus + toolbar icons)
this.TitleBar!.InsertStandardItems();
```

This is equivalent to the designer's Insert Standard Items verb. After insertion, wire `Click` events on the specs or on the `KryptonContextMenuItem` instances within each dropdown's `KryptonContextMenu`.

### Adding and Removing Buttons Dynamically

```csharp
// Add a button
var spec = new ButtonSpecAny { Image = MyIcons.Save, ToolTipTitle = "Save", Type = PaletteButtonSpecStyle.Generic };
spec.Click += OnSaveClicked;
this.TitleBar!.ButtonSpecs.Add(spec);

// Remove by reference
this.TitleBar!.ButtonSpecs.Remove(spec);

// Remove by index
this.TitleBar!.ButtonSpecs.RemoveAt(0);

// Clear all
this.TitleBar!.ButtonSpecs.Clear();
```

Each mutation triggers an immediate title bar repaint. No additional calls are needed.

### Toggling Button Visibility

```csharp
// Hide a button without removing it
myButtonSpec.Visible = false;

// Show it again
myButtonSpec.Visible = true;
```

### Enabling / Disabling Buttons

```csharp
// Force disabled regardless of form state
myButtonSpec.Enabled = ButtonEnabled.False;

// Force enabled
myButtonSpec.Enabled = ButtonEnabled.True;

// Follow the form's enabled state (default)
myButtonSpec.Enabled = ButtonEnabled.Container;
```

### Toggle Buttons (Checked State)

```csharp
// Make it a toggle button
myButtonSpec.Checked = ButtonCheckState.Unchecked;

// Listen for state changes
myButtonSpec.Click += (s, e) =>
{
    var spec = (ButtonSpecAny)s!;
    bool isNowChecked = spec.Checked == ButtonCheckState.Checked;
    UpdateFeatureState(isNowChecked);
};
```

### Drop-Down Buttons

```csharp
var menuSpec = new ButtonSpecAny
{
    Image    = MyIcons.Menu,
    ShowDrop = true,
    Type     = PaletteButtonSpecStyle.Generic
};

// Attach a KryptonContextMenu
var ctxMenu = new KryptonContextMenu();
ctxMenu.Items.Add(new KryptonContextMenuItems
{
    Items = { new KryptonContextMenuItem("Option 1"), new KryptonContextMenuItem("Option 2") }
});
menuSpec.KryptonContextMenu = ctxMenu;

this.TitleBar!.ButtonSpecs.Add(menuSpec);
```

### Attaching and Detaching at Runtime

```csharp
// Attach
this.TitleBar = myTitleBar;

// Detach (revert to standard caption)
this.TitleBar = null;

// Replace with a different title bar
this.TitleBar = anotherTitleBar;
```

### Checking Whether a TitleBar Is Active

```csharp
if (this.TitleBar != null)
{
    // A title bar component is currently active
}

// Or through the component itself:
bool isAttached = myTitleBar.OwnerForm != null;
```

---

## ButtonSpec Properties In Depth

### `Type` — `PaletteButtonSpecStyle`

The `Type` property determines where the button spec's **default image and style** come from. When `Type = Generic` (the default), the spec is entirely custom and the `Image` property must be set explicitly.

Other useful values for title bar buttons:

| Value | Palette default behaviour |
|---|---|
| `Generic` | No palette defaults. You control everything. **Recommended for title bar use.** |
| `Close` | Palette supplies a close-glyph image. |
| `FormMin` | Palette supplies a minimise-glyph image. |
| `FormMax` | Palette supplies a maximise-glyph image. |
| `FormRestore` | Palette supplies a restore-glyph image. |
| `Pin` | Palette supplies a pin/unpin image. |
| `PinVertical` | Palette supplies a vertical pin image. |
| `RibbonMinimize` | Palette supplies a ribbon-minimise image. |

### `Edge` — `PaletteRelativeEdgeAlign`

Controls which edge of the title bar docker each button is anchored to.

| Value | Effect |
|---|---|
| `Inherit` | Uses the palette default (typically `Near` = left in LTR). |
| `Near` | Left side of the docker (after form icon in LTR). |
| `Far` | Right side of the docker (just before title text in LTR). |

### `Style` — `PaletteButtonStyle`

Controls the visual rendering style.

| Value | Description |
|---|---|
| `Inherit` | Inherits from the palette (default, recommended). |
| `Standalone` | Rendered as a standalone button with full border/background. |
| `ButtonSpec` | Rendered in the ButtonSpec style (flat, minimal chrome). Most appropriate for title bar use. |
| `Low` | Low-profile rendering. |
| `Custom1/2/3` | Custom palette-defined styles. |

---

## KryptonCommand Integration

`ButtonSpecAny.KryptonCommand` allows a button spec to be driven by a `KryptonCommand`, which provides a single source of truth for the button's `Image`, `Text`, `Enabled` state, and `Checked` state.

```csharp
var saveCommand = new KryptonCommand
{
    Text       = "Save",
    ImageSmall = Properties.Resources.SaveIcon16,
    Enabled    = true
};
saveCommand.Execute += (s, e) => SaveDocument();

var saveSpec = new ButtonSpecAny
{
    Type           = PaletteButtonSpecStyle.Generic,
    KryptonCommand = saveCommand
};

this.TitleBar!.ButtonSpecs.Add(saveSpec);

// Later: disable via the command — spec updates automatically
saveCommand.Enabled = false;
```

**Synchronisation behaviour:**

| Command property change | Effect on ButtonSpec |
|---|---|
| `Enabled = false` | `ButtonSpecAny.Enabled` → `ButtonEnabled.False` |
| `Enabled = true` | `ButtonSpecAny.Enabled` → `ButtonEnabled.True` |
| `Checked = true` | `ButtonSpecAny.Checked` → `ButtonCheckState.Checked` |
| `Checked = false` | `ButtonSpecAny.Checked` → `ButtonCheckState.Unchecked` |

The `ImageSmall`, `Text`, and `ExtraText` are read from the command when the button is painted.

---

## RTL (Right-to-Left) Support

### Automatic Behaviour

RTL support is entirely automatic. When `KryptonForm.RightToLeft = RightToLeft.Yes` and `KryptonForm.RightToLeftLayout = true`:

1. `ViewDrawDocker.CalculateDock()` flips all `ViewDockStyle.Left` → `ViewDockStyle.Right` at layout time. The title bar docker physically moves to the right side of the caption.
2. The `ButtonSpecManagerDraw` managing the button specs inside the docker also respects RTL, so button order within the docker is mirrored.
3. When `RightToLeftLayout` changes at runtime, `KryptonForm.OnRightToLeftLayoutChanged` calls `_titleBarButtonManager.RecreateButtons()` in addition to the standard `_buttonManager.RecreateButtons()`, ensuring the title bar buttons reposition correctly.

### Caption Layout — RTL

```
_drawHeading (LTR):  [Icon][Title text fill][TitleBarButtons][Min][Max][Close]
_drawHeading (RTL):  [Close][Max][Min][TitleBarButtons][Title text fill][Icon]
```

No developer action is required to support RTL.

### `RightToLeft` vs `RightToLeftLayout`

| Property | Affects | Notes |
|---|---|---|
| `RightToLeft = Yes` | Text direction (bidi), child control layout | Does **not** mirror the caption chrome |
| `RightToLeftLayout = true` | Caption chrome mirroring, button order | This is what controls title bar button placement |

Both properties must match for full RTL UX. Setting `RightToLeftLayout = true` without `RightToLeft = Yes` mirrors the chrome but leaves text LTR (unusual but valid for certain locales).

---

## Theming & Palette Integration

### Automatic Palette Inheritance

The `ViewDrawDocker` created by `AttachTitleBar` is constructed with:

```csharp
new ViewDrawDocker(
    StateActive.Header.Back,
    StateActive.Header.Border,
    StateActive.Header,
    PaletteMetricBool.None,
    PaletteMetricPadding.None,
    VisualOrientation.Top)
```

This means:
- The docker's **background** uses `StateActive.Header.Back` — the same back palette as the title bar heading itself.
- The docker's **border** uses `StateActive.Header.Border`.
- Button specs inside it use `StateCommon.Header` as their metric provider.
- Spacing metrics (`HeaderButtonEdgeInsetForm`, `HeaderButtonPaddingForm`) match the existing form button specs.

The result: title bar buttons **automatically match** the rest of the form chrome across all built-in palettes (Office 2007–2019, Microsoft 365, SparkleBlue, Material, Visual Studio, etc.) without any additional configuration.

### Active vs Inactive State

When the form loses focus, `VisualForm.OnWM_NCACTIVATE` updates the `WindowActive` flag, which causes a repaint using `StateInactive.Header` palette settings. The title bar buttons reflect the inactive style automatically because they participate in the same paint pass.

### Changing the Palette at Runtime

```csharp
// Switch the global palette — title bar buttons update instantly
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Black;

// Or change the form-level palette
this.PaletteMode = PaletteMode.SparkleBlue;
```

No additional action is needed.

---

## Interaction with KryptonRibbon

A `KryptonRibbon` at `Location = Point.Empty` on a `KryptonForm` also injects view elements into the caption via `InjectViewElement`. The title bar toolbar and the ribbon can coexist, but **not simultaneously**. The ribbon's injection takes over the `ViewDockStyle.Fill` slot (replacing the title text with ribbon context tabs), while the title bar toolbar occupies `ViewDockStyle.Right` (to the right of the form icon and title).

In practice, a form with both a `KryptonRibbon` and a `KryptonFormTitleBar` will show:

```
[Icon] [TitleBarButtons] [Ribbon QAT][AppButton][Context tabs] [Min][Max][Close]
```

This is valid and tested. The button specs from both the ribbon QAT and the title bar toolbar are independent.

**Do not** attach a `KryptonFormTitleBar` to a form that uses `KryptonRibbon` if the ribbon is in integrated mode, as the `ViewDockStyle.Left` slots will stack and may produce unexpected spacing. In that scenario, use the ribbon's own QAT (`ribbon.QuickAccessToolbarButtons`) instead.

---

## Lifecycle & Resource Management

### Attachment

`KryptonForm.TitleBar = myTitleBar` triggers:

1. `titleBar.SetOwnerForm(this)` — stores back-reference.
2. `_titleBarDocker` (`ViewDrawDocker`) created and configured.
3. `_titleBarButtonManager` (`ButtonSpecManagerDraw`) created; manages button specs inside `_titleBarDocker`.
4. `_titleBarButtonManager.ToolTipManager` set to the form's shared `ToolTipManager`.
5. `InjectViewElement(_titleBarDocker, ViewDockStyle.Right)` — docker added to `_drawHeading` (right of icon and title).
6. Event subscriptions: `ButtonSpecInserted`, `ButtonSpecRemoved` on `titleBar`.
7. `RecreateMinMaxCloseButtons()` + `PerformNeedPaint(true)`.

### Detachment

`KryptonForm.TitleBar = null` (or assigning a different component) triggers:

1. Event unsubscriptions.
2. `RevokeViewElement(_titleBarDocker, ViewDockStyle.Left)` — docker removed from `_drawHeading`.
3. `_titleBarButtonManager.Destruct()` — all button views removed and disposed.
4. `_titleBarDocker.Dispose()`.
5. `titleBar.SetOwnerForm(null)` — clears back-reference.
6. `RecreateMinMaxCloseButtons()` + `PerformNeedPaint(true)`.

### Form Disposal

When the `KryptonForm` is disposed:

1. `_titleBarButtonManager?.Destruct()` is called.
2. `_titleBarDocker?.Dispose()` is called.
3. The `KryptonFormTitleBar` component itself is **not** disposed by the form — it is a separate component and follows its own designer lifetime.

### Component Disposal

When `KryptonFormTitleBar.Dispose()` is called:

1. If `_ownerForm != null`, `_ownerForm.TitleBar = null` is called, which triggers the full detach sequence above.
2. Base `Component.Dispose()` runs.

### Summary Matrix

| Scenario | What happens |
|---|---|
| Form disposed | Docker and button manager cleaned up. TitleBar component itself survives. |
| `TitleBar = null` | Full detach. Form reverts to standard caption. |
| `TitleBar = newComponent` | Old component detached, new component attached atomically. |
| Component `.Dispose()` called | Auto-detaches from form, then disposes. |
| Component removed in designer | Designer cleans up all child `ButtonSpecAny` components. |

---

## Internal Architecture

This section is for contributors and maintainers.

### Key Private Members on KryptonForm

| Field | Type | Purpose |
|---|---|---|
| `_titleBar` | `KryptonFormTitleBar?` | The currently assigned title bar component. |
| `_titleBarDocker` | `ViewDrawDocker?` | The view element injected into `_drawHeading`. |
| `_titleBarButtonManager` | `ButtonSpecManagerDraw?` | Manages the `ButtonSpecAny` items inside `_titleBarDocker`. |

### `AttachTitleBar` (private)

```csharp
private void AttachTitleBar(KryptonFormTitleBar titleBar)
```

Creates `_titleBarDocker` and `_titleBarButtonManager`, injects the docker, hooks events.

### `DetachTitleBar` (private)

```csharp
private void DetachTitleBar(KryptonFormTitleBar titleBar)
```

Unhooks events, revokes the docker, destructs and nulls the button manager and docker.

### `OnTitleBarButtonSpecChanged` (private)

```csharp
private void OnTitleBarButtonSpecChanged(object? sender, ButtonSpecEventArgs e)
```

Called when a spec is added or removed from `ButtonSpecs`. Refreshes the button manager and triggers a repaint.

### `OnRightToLeftLayoutChanged` (override)

```csharp
protected override void OnRightToLeftLayoutChanged(EventArgs e)
```

Extended to call `_titleBarButtonManager?.RecreateButtons()` alongside the existing `_buttonManager?.RecreateButtons()` call.

### Internal Events on KryptonFormTitleBar

| Event | Visibility | Purpose |
|---|---|---|
| `ButtonSpecInserted` | `internal` | Forwarded from `ButtonSpecs.Inserted`. Consumed by `KryptonForm`. |
| `ButtonSpecRemoved` | `internal` | Forwarded from `ButtonSpecs.Removed`. Consumed by `KryptonForm`. |

These are `internal` to prevent external consumers from depending on implementation details.

### `SetOwnerForm` (internal)

```csharp
internal void SetOwnerForm(KryptonForm? form)
```

Set by `KryptonForm.AttachTitleBar` and `DetachTitleBar`. Not intended for external use.

---

## Limitations & Known Constraints

### No Arbitrary Control Hosting

`KryptonFormTitleBar` supports `ButtonSpecAny` items only. It does **not** support embedding arbitrary WinForms controls (e.g. a `KryptonComboBox` or `KryptonTextBox`) in the title bar. This is because all caption rendering is done in the non-client area via custom chrome — standard WinForms controls (which are child `HWND` windows) cannot be parented to a non-client region.

If a combo box or text input in the title bar is required, the standard approach is to use `FormBorderStyle.None` and build a custom "fake" title bar as a panel inside the client area (as referenced in the original feature request).

### Title Bar Height is Fixed by the Active Palette

The height of the title bar is governed by `RealWindowBorders.Top`, which is calculated from the active palette's border metrics. The button spec images scale within whatever height the palette provides. If the buttons appear clipped, switch to a palette with a taller caption (e.g. Material at 44 px) or use smaller images (16×16 is safe for all palettes).

### ButtonSpec Collection Mutations are Not Batched

Each `Add` or `Remove` call on `ButtonSpecs` immediately triggers a full `RecreateMinMaxCloseButtons()` + `PerformNeedPaint(true)`. If adding many specs at startup, prefer `AddRange(...)` over individual `Add` calls to minimise redundant repaints (though `AddRange` still fires one event per item internally).

### One TitleBar Per Form

A `KryptonFormTitleBar` instance can only be attached to one `KryptonForm` at a time. Assigning the same instance to a second form without detaching from the first will silently replace the first form's attachment (because the second assignment calls `DetachTitleBar` only if `_titleBar == value` is false).

### Designer Limitation — No Live Preview

Due to the non-client area rendering, button spec changes made in the designer collection editor are not visually previewed in the designer surface. Run the project to see the result.

---

## Best Practices

**Use 16×16 images.** The title bar height across all palettes safely accommodates 16×16 icons. Larger images may be clipped on palettes with narrow captions.

**Set `ToolTipTitle` on every spec.** Users hovering over title bar buttons benefit significantly from tooltips, as there may not be room for text labels.

**Use `KryptonCommand` for menu-driven actions.** If the same action appears in both the title bar and a menu/toolbar, binding both to a `KryptonCommand` ensures consistent enabled/checked state without manual synchronisation.

**Keep `Type = Generic`.** Using predefined types (e.g. `Close`, `FormMin`) inherits palette images that may not match your intent. `Generic` gives full control.

**Do not set `CustomCaptionArea` manually when using `KryptonFormTitleBar`.** The `CustomCaptionArea` property is intended for the Ribbon integration. Setting it while a `KryptonFormTitleBar` is active may interfere with hit-testing.

**Handle disposal explicitly in long-lived applications.** If `KryptonFormTitleBar` is created at runtime (not via the designer), call `titleBar.Dispose()` when the form closes, or ensure it is added to a `Container` so it is disposed automatically.

---

## Troubleshooting

### Buttons do not appear

- Ensure `KryptonForm.TitleBar` is assigned (not `null`).
- Ensure at least one `ButtonSpecAny` is in `KryptonFormTitleBar.ButtonSpecs` and `Visible = true`.
- Ensure `AllowFormChrome = true` on the `KryptonForm` (default). If `false`, the custom chrome is disabled and the non-client area is OS-rendered.
- Ensure the form is not using `FormBorderStyle.None` (no caption area exists).

### Buttons are clipped or overlapping the form icon

- The active palette's caption height may be too small for the image size. Use 16×16 images, or switch to a palette with a taller caption (e.g. `PaletteMode.MaterialDark`).
- If the form icon is unexpectedly large, check `KryptonForm.ShowIcon` and `AllowIconDisplay`.

### Click events are not firing

- Ensure `Enabled` is not `ButtonEnabled.False` and the form is not disabled.
- Ensure the button spec is not obscured by another view element (check for z-order issues if using both `KryptonRibbon` and `KryptonFormTitleBar`).

### RTL buttons are in the wrong position

- Confirm **both** `RightToLeft = RightToLeft.Yes` and `RightToLeftLayout = true` are set on the form.
- `RightToLeft` alone does not mirror the chrome layout.

### Tooltip does not appear

- Ensure `ToolTipTitle` (or `ToolTipBody`) is non-empty.
- Ensure `AllowButtonSpecToolTips = true` on the `KryptonForm`.

### Designer: Removing KryptonFormTitleBar leaves orphan ButtonSpecAny components

- This should not happen in normal use because `KryptonFormTitleBarDesigner` handles component removal. If it does occur, open `InitializeComponent()` manually and remove any stray `ButtonSpecAny` instantiations.

### Memory leak warning after hot-reload

- Hot-reload in .NET may reinitialise `InitializeComponent()` without disposing the previous title bar. If this is a concern, explicitly null `this.TitleBar` before hot-reload and re-assign after.
