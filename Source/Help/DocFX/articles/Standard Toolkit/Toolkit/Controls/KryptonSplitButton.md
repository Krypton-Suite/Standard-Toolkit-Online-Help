# KryptonSplitButton

## Overview

`KryptonSplitButton` is a `KryptonDropButton` that is **always** a split: the button body raises `Click` (and executes `KryptonCommand`), and the chevron raises `DropDown` then shows `KryptonContextMenu` or `ContextMenuStrip`.

It lives in `Krypton.Toolkit`. Rendering, palettes, and menu positioning are unchanged from `KryptonDropButton`.

## Why a dedicated type

Split behaviour already existed in two other places:

| Type | Default | Typical use |
|------|---------|-------------|
| `KryptonButton` | No chevron | Push button. `ShowSplitOption = true` is the legacy opt-in. |
| `KryptonDropButton` | Chevron + splitter | Split by default. `Splitter = false` makes the whole button a drop-down. |
| `KryptonSplitButton` | Always split | Toolbox type for “Save + menu” (WinForms `SplitButton` / `ToolStripSplitButton`). |

`ShowSplitOption` is kept for compatibility. Prefer `KryptonSplitButton` for new UI.

`Krypton.Toolkit.Utilities` `KryptonMiniToolbarSplitButton` is a mini-toolbar item, not this control.

## Architecture

```
VisualSimpleBase
  └── KryptonDropButton          // Splitter optional; mnemonic opens menu when Splitter is true
        ├── KryptonButton        // DropDown/Splitter off; ShowSplitOption re-enables both
        │     └── KryptonCheckButton
        └── KryptonSplitButton   // Splitter locked on; mnemonic fires Click
```

`KryptonSplitButton` is a **sibling** of `KryptonButton`, not a subclass. `KryptonDropButton` used to special-case `this is KryptonButton` for click routing and `WM_CONTEXTMENU`. Those are now virtuals:

- `OpensDropDownOnNonSplitterClick` — `true` on drop-down; `false` on `KryptonButton`
- `SuppressSystemContextMenu` — `true` on drop-down / split; `false` on `KryptonButton`
- `MnemonicPerformsDropDown` — follows `Splitter` on drop-down; `false` on `KryptonSplitButton`

`Splitter` is `virtual`. The split-button override always returns `true` and ignores `false`.

Accessibility: `KryptonSplitButtonAccessibleObject` advertises `AccessibleRole.SplitButton`. Default action is still **Press** (`PerformClick`).

Designer: reuses `KryptonDropButtonDesigner`. The smart tag omits `Splitter` when the component is a `KryptonSplitButton`.

## Public API

```csharp
public class KryptonSplitButton : KryptonDropButton
{
    public KryptonSplitButton();

    // Always true. Hidden. Setting false is ignored.
    public override bool Splitter { get; set; }
}
```

Inherited (the ones that matter for consumers):

- `Click` / `PerformClick()` — button body
- `DropDown` / `PerformDropDown()` — chevron
- `KryptonContextMenu`, `ContextMenuStrip`
- `DropDownPosition`, `DropDownOrientation`
- `KryptonCommand` — executed from `OnClick` (body), not from the chevron
- `Values`, palettes, `ButtonStyle`, badges, pulsing border

There is no `ShowSplitOption` on this type. There is no WinForms-style `DefaultItem` (last menu item becomes the caption) in v1.

## Usage

```csharp
var save = new KryptonSplitButton
{
    Values = { Text = "&Save" },
    KryptonContextMenu = menu // items: Save, Save As, Save All
};
save.Click += (_, _) => SaveDocument();
```

Designer: drop **KryptonSplitButton** from the Toolbox, assign `KryptonContextMenu`, handle `Click`.

Mnemonic (`&Save` / Alt+S) fires `Click`, not the menu. That differs from `KryptonDropButton` with `Splitter = true`, where the mnemonic opens the drop-down.

## Edge cases

- Casting to `KryptonDropButton` and setting `Splitter = false` still leaves the splitter on (virtual override).
- `KryptonButton.ShowSplitOption` is unchanged, including mnemonic → drop-down when the splitter is on.
- Do not change `KryptonDropButton.Splitter` default (`true`); that would be breaking.
- Right-click system context menu is suppressed (same as `KryptonDropButton`). Attach `KryptonContextMenu` for the chevron.
- `net472` / C# 7.3 only.
