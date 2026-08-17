# Krypton Radial Menu

## Overview

Radial menus live in `Krypton.Toolkit.Utilities` (issue [#4172](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4172)). There are two host models that share the same item types, Values, painter, and interaction core:

| Type | Role |
|------|------|
| `KryptonRadialMenu` | Designer `Component` (like `KryptonContextMenu`) — popup via `Show` / `ShowPopup` / `Close` |
| `KryptonRadialMenuControl` | Form-hosted `Control` — always visible Syncfusion-style surface |

Consumers obtain both via the `Krypton.Standard.Toolkit` NuGet package (`Krypton.Toolkit.Utilities` assembly).

## Architecture

```text
KryptonRadialMenu (Component)          KryptonRadialMenuControl (Control)
        │                                         │
        └──────────┬──────────────────────────────┘
                   ▼
         RadialMenuInteractionCore
                   │
         RadialMenuPainter / RadialLayoutEngine
                   │
         Items + KryptonRadialMenuValues
```

Shared public item types: `KryptonRadialMenuItem`, `SliderItem`, `ColorPaletteItem`, `FontListItem`, `TextItem`, `CalendarItem`.

Popup-only: `VisualRadialMenuPopup`, PreferRadial / `KryptonRadialMenuPresenter`, context-menu `ImportFrom` / live sync, open/close animation, circular shadow.

Hosted-only: optional hub (`UseHub`), float-out while dragging (`AllowMove` past the parent → borderless `VisualRadialMenuFloatForm`).

## KryptonRadialMenu (popup Component)

```csharp
var menu = new KryptonRadialMenu();
menu.Items.Add(new KryptonRadialMenuItem("Save", (_, _) => Save()));
menu.Show(this);
menu.Show(this, clientPoint);
menu.ShowPopup(this, screenPt, animated: true);
menu.Close();
```

Key properties: `MenuRadius`, `InnerRadius`, `Glyph`, `DisplayStyle`, `ItemImageSize`, `OuterRingThickness` (default **10**), `ShowOuterRingOnLeaves` (default **true**), `ShowShadow` / `StateShadow###`, outer-ring `State###`, `StartAngle`, `MaxVisibleItems`, `AnimationStyle`, `AllowMove`.

Pointer model:

- Outer-ring band opens children / editors and shows `SubMenuGlyph` (default `›`) with contrasting ink on the rim.
- When `ShowOuterRingOnLeaves` is `false`, leaf slices omit the rim arc; the outer band on those slices hits as sector body.
- Sector body on parents raises `ItemClick` only; leaf body click still activates.
- Keyboard Enter still opens children / editors.
- Slice fills stop at the inner edge of the outer ring so thick rings do not cover sector content; outer-ring tracking uses a distinct accent when palette border colours are too similar.

PreferRadial:

```csharp
KryptonRadialMenuPresenter.PreferRadialContextMenus = true;
contextMenu.Show(this, pt); // radial via AlternativeShow
```

Bridge (popup Component only): `ImportFrom` / `FromContextMenu` with optional live sync. Outer-ring `State###` (`PaletteBorder`) colour the rim.

## KryptonRadialMenuControl (hosted Control)

```csharp
var control = new KryptonRadialMenuControl
{
    MenuRadius = 120,
    Dock = DockStyle.Fill
};
control.Items.Add(new KryptonRadialMenuItem("Bold", (_, _) => ToggleBold()));
control.ItemClick += (_, e) => { /* … */ };
Controls.Add(control);
```

- Always visible by default; optional `UseHub` shows a centre hub — press to expand, centre / Esc / AutoClose collapses. Caption via `HubText` (default `+`) or `Glyph` image (image wins when set).
- Optional `AllowMove` — drag the hub (collapsed) or centre (expanded) to reposition; short click still expands/activates. Docked controls undock on the first drag. Dragging outside the parent floats in a borderless top-level window (`IsFloating` / `Float` / `DockBack` / `FloatingChanged`); dropping back over the original parent docks again.
- Same `OuterRingThickness`, outer-ring hit model, and editor rings as the popup.
- Effective radius = `Min(MenuRadius, available client radius)` so resize does not clip badly.
- Designer: collection editor + action list (Menu Radius / Inner Radius / Display Style / Edit Items).

```csharp
control.UseHub = true;          // start collapsed
control.HubText = "Menu";       // or control.Glyph = myImage;
control.OuterRingThickness = 10;
control.Expand();               // or press the hub
control.Collapse();             // or root centre / Esc
control.ExpandedChanged += ...;
```
