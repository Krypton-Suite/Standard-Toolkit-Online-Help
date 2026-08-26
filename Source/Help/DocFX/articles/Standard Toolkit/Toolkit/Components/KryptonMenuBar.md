# KryptonMenuBar

## Overview

`KryptonMenuBar` is a native (non-`ToolStrip`) horizontal menu bar in `Krypton.Toolkit`. It is the follow-up to [`KryptonMenuStrip`](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1110) requested in [#4242](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4242).

- **Problem:** `KryptonMenuStrip` still paints through `ToolStripManager`, so fonts, colours, and item types cannot fully match `KryptonContextMenu`.
- **Scope:** Top-level `KryptonContextMenuItem` / `KryptonContextMenuSeparator` laid out horizontally; click, Alt, and mnemonic open nested `item.Items` as a `KryptonContextMenu` popup.
- **Not in v1:** MDI merging, `ToolStripItem` hosts, floatable panels (`KryptonFloatableMenuStrip` stays on `KryptonMenuStrip`).

`KryptonMenuStrip` remains the WinForms `MenuStrip` equivalent (Toolbox designer Insert Standard Items for ToolStrip items, `MainMenuStrip`, MDI merge). To show that strip in the **caption**, assign it to `KryptonFormTitleBar.MenuStrip` (see `Documents/Development/KryptonMenuStrip.md`); that is not `KryptonMenuBar`.

## Architecture

```
KryptonForm.MenuBar  (assignment only; ProcessCmdKey)
        |
KryptonMenuBar : VisualSimpleBase
  ViewDrawDocker          (MenuStrip ColorTable background; ColorAlign Local)
    ViewLayoutStack       (horizontal)
      ViewDrawMenuBarItem + MenuBarItemController
      ViewDrawMenuBarSeparator
        |
        click / hover-switch / mnemonic
        |
  KryptonContextMenu.ShowCollection(item.Items)
    VisualContextMenu popup
```

Key types:

| Type | Role |
|------|------|
| `KryptonMenuBar` | Host control (`VisualSimpleBase`, `Dock = Top` by default) |
| `KryptonMenuBarItemCollection` | Restricted to `KryptonContextMenuItem` and `KryptonContextMenuSeparator` |
| `ViewDrawMenuBarItem` | Low-profile button view for a top-level item |
| `ViewDrawMenuBarSeparator` | Vertical separator |
| `MenuBarItemController` | `ClickOnDown` + `BecomesFixed`; hover-switch while open |
| `KryptonStandardMenuFactory` | Shared File / Edit / Tools / Help trees (also used by `KryptonFormTitleBar`) |
| `KryptonContextMenu.ShowCollection` | Internal: show an existing `KryptonContextMenuCollection` by reference |

Drop-downs **do not** move designer-owned nodes onto a temporary menu. `ShowCollection` passes `item.Items` into `VisualContextMenu` the same way submenus do.

## Public API

### `KryptonMenuBar`

- `Items` — `KryptonMenuBarItemCollection` (`DesignerSerializationVisibility.Content`)
- `UseMnemonic` — default `true`
- `InsertStandardItems()` — File, Edit, Tools, Help via `KryptonStandardMenuFactory.CreateStandardMenuBarItems()`
- Palette: inherited `PaletteMode` / `LocalCustomPalette`; `StateCommon` / `StateDisabled` / `StateNormal` / `StateTracking` / `StatePressed` (item chrome, `ButtonLowProfile`); `StateBarBackground` (MenuStrip ColorTable inherit; `ColorAlign` / `ImageAlign` must be `Local` for `RenderStandard.DrawBack`)
- Toolbox: `[ToolboxItem(true)]`, `ToolboxBitmaps.KryptonMenuBar.bmp`

### `KryptonForm.MenuBar`

Assignment-only (`[DefaultValue(null)]`). Does **not** dock or reparent. Coexists with `MainMenuStrip`.

`KryptonForm.ProcessCmdKey` calls `KryptonMenuBar.ProcessBarCmdKey` first so shortcuts (`Items.ProcessShortcut`) and Alt/F10 menu-mode work while the bar is non-selectable.

Mnemonics (`ProcessMnemonic`) work whenever the bar is a child of the form, even without `MenuBar` assignment.

### Designer

- Collection editor: only Item + Separator at the top level; nested `item.Items` keep the full context-menu editor
- Designer verb / action list: **Insert Standard Items**
- Default drop: `Dock = Top`

## Usage

```csharp
var bar = new KryptonMenuBar();
bar.InsertStandardItems();
form.Controls.Add(bar);
form.MenuBar = bar; // shortcuts + Alt activation

foreach (KryptonContextMenuItemBase item in bar.Items)
{
    if (item is KryptonContextMenuItem file && file.Text.Contains("File"))
    {
        // Nested drop-down is file.Items (usually one KryptonContextMenuItems group)
    }
}
```

Wire `KryptonContextMenuItem.Click` or `KryptonCommand` on nested items. Top-level items with an empty `Items` collection fire `PerformClick()` instead of opening a popup.

## Keyboard

| Input | Behaviour |
|-------|-----------|
| Alt / F10 | Toggle menu mode (first item highlighted) when assigned to `KryptonForm.MenuBar` |
| Alt+letter | `ProcessMnemonic` opens the matching top-level drop-down |
| Left / Right | Menu mode: move highlight. Root popup (stack depth 1): switch adjacent top-level item |
| Down / Enter / Space | Open highlighted item |
| Escape | Close root popup and keep menu mode, or leave menu mode |
| Shortcuts | `Items.ProcessShortcut` from `KryptonForm.ProcessCmdKey` |

Nested submenus keep existing context-menu Left-dismiss / Right-open behaviour when popup stack depth is greater than 1.

## Edge cases

- **Ownership:** Never add the same `KryptonContextMenuItem` instance to both a bar and a standalone `KryptonContextMenu.Items` collection; collections assume exclusive parentage.
- **C# / TFM:** New files stay within the Toolkit `LangVersion` and `net472` surface.
- **Coexistence:** Setting both `MenuBar` and `MainMenuStrip` is allowed; shortcuts on the native bar are processed first.
- **Hover-switch:** While a drop-down is showing, moving the mouse to another top-level item closes the current popup and opens the new one (`BecomesFixed` is cleared on `Closed`).

## Validation

- **TestForm:** `KryptonMenuBarDemo` (StartScreen: “KryptonMenuBar (#4242)”). Side-by-side `KryptonMenuBar` / `KryptonMenuStrip` / `MenuStrip`; Insert Standard Items; theme combo; Ctrl+N; Alt/mnemonic; hover-switch.
- **Demos:** `KryptonMenuBar Examples` on branch `alpha-4242-krypton-menu-bar` in [Standard-Toolkit-Demos](https://github.com/Krypton-Suite/Standard-Toolkit-Demos).
