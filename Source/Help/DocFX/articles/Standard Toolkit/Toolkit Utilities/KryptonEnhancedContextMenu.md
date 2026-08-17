# Krypton Enhanced Context Menu

## Overview

Issue [#3862](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3862) adds an Office 2007+-style shortcut menu without replacing `KryptonContextMenu`.

The Office model is not a new item renderer. It is:

1. **Paired Mini Toolbar** — a compact formatting strip drawn immediately above (or below) the shortcut menu.
2. **Command persistence** — clicking a Mini Toolbar command dismisses the menu list but **keeps the Mini Toolbar** so several formatting clicks can happen without reopening.
3. **Selection Mini Toolbar** — on text selection, the same bar appears near the selection, faded until the mouse approaches, using a non-activating layered window.
4. **Richer menus** — in-menu **galleries** with hover live-preview, plus compact font/size combos on the Mini Toolbar.

**Packages**

- `Krypton.Toolkit` — `KryptonContextMenuGallery` (and related item/range types).
- `Krypton.Toolkit.Utilities` — `KryptonEnhancedContextMenu`, `KryptonMiniToolbar`, Mini Toolbar item types, and the visual popups.

Do not hook `KryptonContextMenu.AlternativeShow`. That remains the radial-menu presenter. Enhanced menus are opt-in per component and show their own popup.

## Architecture

```
App / TestForm
  ├─ KryptonEnhancedContextMenu  (Utilities component)
  │    ├─ KryptonMiniToolbar
  │    ├─ KryptonContextMenu     (owned or assigned)
  │    ├─ VisualMiniToolbarPopup   (separate window, stacked first)
  │    └─ VisualEnhancedContextMenu (menu-only VisualPopup)
  ├─ KryptonMiniToolbar.Attach(Control)
  │    └─ VisualMiniToolbarPopup     (selection fade; not a modal VisualPopupManager menu)
  └─ KryptonContextMenu.Items
       └─ KryptonContextMenuGallery  (Toolkit item; TrackingImage live preview)
```

**Paired right-click** shows **two** `VisualPopup` windows with a configurable pixel gap (`MiniToolbarGap`, default 2), left-aligned like Office: `VisualMiniToolbarPopup` (own chrome) stacked first, then `VisualEnhancedContextMenu` (menu columns only) as the current tracked popup. Clicking the Mini Toolbar dismisses the menu popup but can leave the bar (`KeepMiniToolbarAfterCommand`). Clicking a menu item, Esc, or click-outside dismisses both. In-menu gallery tiles stretch to the menu width so captions stay readable.

**Selection fade** uses a **separate** `VisualMiniToolbarPopup`: `WS_EX_NOACTIVATE` + `WS_EX_LAYERED`, opacity ramped by mouse distance, dismissed on selection collapse or click-away. Same `KryptonMiniToolbar` item model; different host. It is not pushed onto `VisualPopupManager` as a modal menu.

Palette chrome uses `PaletteBackStyle.ContextMenuOuter` and hosted Mini Toolbar controls inherit `PaletteMode` / `LocalCustomPalette` from `KryptonMiniToolbar`, so the leftover bar tracks the active Krypton theme (including `GlobalPaletteChanged`). There are no new `PaletteMode` values.

## Public API

### `KryptonEnhancedContextMenu` (`Krypton.Toolkit.Utilities`)

Component that owns or references a `KryptonContextMenu` plus a `KryptonMiniToolbar`. `Show(...)` overloads mirror `KryptonContextMenu.Show`. Events `Opening` / `Opened` / `Closing` / `Closed` forward from the paired popup.

| Member | Default | Meaning |
| --- | --- | --- |
| `MiniToolbar` | owned instance | Compact strip shown with the menu. **Settable** — assign a tray `KryptonMiniToolbar`, or edit the owned `Items` in the designer. |
| `Menu` | owned `KryptonContextMenu` | **Settable** — assign an existing menu, or configure `Menu.Items` in the designer (Content serialization). |
| `ShowMiniToolbar` | `true` | Hide the strip and show a normal stacked menu. |
| `MiniToolbarPosition` | `Auto` | `Above` / `Below` / `Auto` (below when the anchor is near the top of the screen). |
| `MiniToolbarGap` | `2` | Pixel gap between the Mini Toolbar and the paired menu (`0` or more). |
| `KeepMiniToolbarAfterCommand` | `true` | Mini Toolbar click dismisses the list but keeps the bar. |
| `Enabled` | `true` | `Show` returns `false` when disabled. |
| `IsShowing` | — | Paired popup is visible. |

`Show` closes any already-open paired popup before opening at the new screen location. It does **not** call `KryptonContextMenu.Show`, so `AlternativeShow` / radial presenters are not invoked.

### `KryptonMiniToolbar` (`Krypton.Toolkit.Utilities`)

| Member | Meaning |
| --- | --- |
| `Items` | Horizontal Mini Toolbar items. |
| `Show(Rectangle screenAnchor)` | Tracked opaque popup (standalone). |
| `Hide()` | Dismiss the standalone / selection popup. |
| `Attach(Control)` / `Detach()` | Selection fade on `TextBoxBase`, `KryptonTextBox`, or `KryptonRichTextBox`. |
| `IdleOpacity` | Idle layered alpha (0–255, default 40). |
| `ApproachDistance` | Mouse distance in pixels at which opacity reaches 255 (default 80). |
| `PaletteMode` / `LocalCustomPalette` / `StateCommon` | Chrome redirect. |
| `ItemClick` | Raised when any hosted item is activated. |

Buttons bind to `KryptonCommand` so Bold / Italic / Colour can be shared with ribbon and menu items.

### Mini Toolbar item types

All derive from `KryptonMiniToolbarItemBase` (`Visible`, `Enabled`, `Image`, `Text`, `ToolTipText`, `Tag`, `Click`).

- `KryptonMiniToolbarButton` — `Push` or `Check`; optional `KryptonCommand`.
- `KryptonMiniToolbarSplitButton` — body click plus drop-down `KryptonContextMenu` (for example colour columns).
- `KryptonMiniToolbarComboBox` — compact font family / size list (`Width` default 108, `Items`, `SelectedIndexChanged`).
- `KryptonMiniToolbarSeparator` — vertical edge.
- `KryptonMiniToolbarGallery` — one-row `ImageList` gallery with `TrackingImage` and `MaxVisibleItems`.

### `KryptonContextMenuGallery` (`Krypton.Toolkit`)

`KryptonContextMenuItemBase` modelled on `KryptonContextMenuImageSelect`: grid, `SelectedIndex`, `AutoClose`, plus optional captions, heading `Ranges`, and a **More…** drop (`MoreItems` / `MoreText`, default from `KryptonManager.Strings.ContextMenuStrings.GalleryMore`).

When `Items` is empty, cells are synthesised from `ImageList` (`ImageIndexStart` / `ImageIndexEnd`, `LineItems`). Live preview is the existing `TrackingImage` (`ImageSelectEventArgs`) — the host applies formatting on hover and reverts when `ImageIndex` is `-1`.

Do **not** put `KryptonGallery` (Ribbon) into Toolkit. Utilities may host ribbon galleries inside a Mini Toolbar item because Utilities already references Ribbon; the compact Mini Toolbar gallery in this feature uses `ImageList` instead.

Designer: gallery is in `KryptonContextMenuCollection` / item collection `RestrictTypes` and collection editors.

## Usage

```csharp
var menu = new KryptonEnhancedContextMenu();
menu.MiniToolbar.Items.Add(new KryptonMiniToolbarButton
{
    ButtonType = KryptonMiniToolbarButtonType.Check,
    KryptonCommand = cmdBold,
    ToolTipText = "Bold"
});
menu.Menu.Items.Add(new KryptonContextMenuHeading("Clipboard"));
var items = new KryptonContextMenuItems();
items.Items.Add(new KryptonContextMenuItem("Cut") { KryptonCommand = cmdCut });
menu.Menu.Items.Add(items);

var gallery = new KryptonContextMenuGallery { ShowItemText = true, LineItems = 5 };
gallery.Items.Add(new KryptonContextMenuGalleryItem("Heading") { Image = headingImage });
gallery.TrackingImage += (_, e) =>
{
    if (e.ImageIndex < 0) { RevertPreview(); return; }
    ApplyPreview(e.ImageIndex);
};
menu.Menu.Items.Add(gallery);

menu.Show(this, Control.MousePosition);
menu.MiniToolbar.Attach(kryptonRichTextBox1); // selection fade
```

Typical pattern: share `KryptonCommand` instances between Mini Toolbar buttons, context-menu items, and ribbon buttons. Handle formatting in `KryptonCommand.Execute` (and `TrackingImage` for preview).

Use a **second** `KryptonMiniToolbar` for `Attach` if the same instance is also hosted in a paired popup — the two hosts would otherwise fight over a single popup field.

## Configuration / persistence

The Mini Toolbar and paired menu are **designer- and runtime-configurable**. Office 2007 did not offer QAT-style end-user customisation of the Mini Toolbar; this API is for the application developer.

**Visual Studio designer**

- Drop `KryptonEnhancedContextMenu` or `KryptonMiniToolbar` on a form.
- Smart-tag / action list: **Edit Mini Toolbar Items...**, **Edit Menu Items...**, plus `ShowMiniToolbar`, `KeepMiniToolbarAfterCommand`, `MiniToolbarPosition`, `IdleOpacity`, `ApproachDistance`, `ShowShadow`.
- Property grid: expand `MiniToolbar` / `Menu` (`DesignerSerializationVisibility.Content`). Combo box items use `KryptonDesignerStringCollectionEditor`.
- Hide a command at runtime or in the designer with `KryptonMiniToolbarItemBase.Visible`.
- Assign `MiniToolbar` or `Menu` to a separate tray component to share configuration.

**Runtime**

```csharp
menu.ShowMiniToolbar = true;
menu.MiniToolbarPosition = KryptonMiniToolbarPosition.Above;
menu.KeepMiniToolbarAfterCommand = true;
menu.MiniToolbar.IdleOpacity = 40;
menu.MiniToolbar.ApproachDistance = 80;
menu.MiniToolbar.Items[0].Visible = false;
```

- Localisation: `KryptonContextMenuStrings.GalleryMore`.
- No XML persistence schema. Theme follows `PaletteMode.Global` unless overridden.

## Edge cases

- **RTL** — Mini Toolbar flow follows the host `RightToLeft`; `Auto` position still prefers above unless the anchor is near the top of the working area.
- **DPI** — padding comes from existing context-menu palette metrics.
- **Keyboard** — Menu key / Shift+F10 should call `Show(..., keyboardActivated: true)`. Esc closes the paired popup (or the leftover Mini Toolbar after a command).
- **Focus** — paired popup is activating (current `VisualPopup` style). Selection popup is non-activating so typing continues in the editor.
- **Radial collision** — if both features are on the form, `KryptonEnhancedContextMenu.Show` bypasses `AlternativeShow`.
- **TFMs** — C# 7.3-compatible public surface; `net472` and later Windows TFMs.
- **Binary compatibility** — additive types and optional properties only. `KryptonContextMenu.VisualContextMenu` is `protected internal` so Utilities can compose views; `InternalsVisibleTo` is granted to `Krypton.Toolkit.Utilities`.
