# Krypton snap-layout overlay

Palette-drawn maximize-button layout menu for `KryptonForm` (issue #4579). Owner: `Krypton.Toolkit`.

## Overview

Windows 11 draws its snap-layout flyout when a custom title bar returns hit-test `HTMAXBUTTON` (`9`, the same value as `HTZOOM`). That flyout cannot be recolored. [#1190](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1190) turned the hit-test on so the shell menu appeared. `KryptonManager.SnapLayoutValues.Mode` chooses that Windows menu or a palette-drawn menu. The Windows menu stays the default. On a dropped `KryptonManager`, expand `SnapLayout` and edit the same object as `KryptonManager.SnapLayoutValues`.

| Mode | Behaviour |
| ------ | ----------- |
| `System` | Shell menu (default global). Forms that `Inherit` keep `HTMAXBUTTON`. |
| `Toolkit` | Palette menu; snaps this form; optional Groups, Assist, preview ghost, custom cards. |
| `None` | Maximize / restore only (`HTBORDER` on the maximize button). |
| `Inherit` | Form follows `SnapLayoutValues.Mode` (form default). |

The palette menu can show icons of other taskbar applications. It does not move those windows. Win+Z still opens the shell menu. There is no private shell COM hook. Native taskbar Snap Groups eligibility is separate (`Feature4129SnapGroupsDemo`).

## Architecture

```
KryptonManager.SnapLayoutValues.Mode  (designer: SnapLayout.Mode)
    System  (default) -> forms that Inherit keep HTMAXBUTTON (shell menu)
    Toolkit           -> hover timer (~400 ms) -> VisualSnapLayoutPopup
                          -> zone click -> ApplyToolkitSnap (+ Register)
                          -> optional Assist for remaining zones
                          -> group zone click -> restore live members
    None              -> HTBORDER (maximize click only)

KryptonForm.SnapLayouts
    Inherit (default) -> manager value
    Toolkit / System / None -> that form only
```

| Type | Role |
| ------ | ------ |
| `KryptonSnapLayoutMode` | `Toolkit`, `System`, `None`, `Inherit`. |
| `SnapLayoutValues` | Sole app-wide store (`ExpandableObjectConverter`). `KryptonManager.SnapLayout` is the same object in the property grid. `ModeChanged` fires when `Mode` changes. `Inherit` stored on the manager is coerced to `System`. |
| `KryptonSnapLayoutZone` / `KryptonSnapLayoutCard` | Public. Zone = work-area fractions `0..1`. Card = one or more zones. |
| `KryptonSnapLayoutCardCollection` | `SnapLayoutValues.CustomLayouts`. Empty by default. |
| `KryptonSnapLayoutCatalog` | Builtin cards (halves, stacks, quarters; on a wide work area thirds and 25/50/25) plus custom. Drops a card when any zone is smaller than `MinimumSize`. Mirrors for right-to-left. Custom cards are not gated on the ~1100px width rule. |
| `KryptonSnapLayoutTaskbar` | Decorative icons of visible taskbar windows (index 0 = this form). Prefer group-member icons when a live Snap Group owns the card. |
| `KryptonSnapGroupRegistry` | Process-wide weak-ref membership. Key = monitor work-area origin + ordered zone fractions (not popup card index). Group when two or more live forms share the key. |
| `KryptonSnapLayoutPersistence` | Internal XML export/import for custom cards + `IncludeBuiltinLayouts`. |
| `VisualSnapLayoutPopup` | Internal `VisualPopup`. `PanelAlternate` chrome, cards, preview, group caption, zone hit-testing. |
| `VisualSnapLayoutAssistPopup` | Peer picker for remaining zones after a multi-zone toolkit snap. |
| `KryptonForm` | Hover timers, hit-test switch, `ApplyToolkitSnap`, register/unregister, Assist host, restore glyph, caption-drag unsnap. |
| `ButtonSpecFormWindowMax` | While a toolkit snap is active and `WindowState` is `Normal`, click restores saved bounds instead of maximizing. |

`Toolkit` and `None` hit-test the maximize button as `HTBORDER` with non-client-as-normal so the button still clicks and Windows 11 does not open its menu. MDI children and the designer keep `HTMAXBUTTON`. The popup shows only for a top-level sizable form with `MaximizeBox`, outside design mode.

## Public API

```csharp
public enum KryptonSnapLayoutMode
{
    Toolkit = 0,
    System = 1,
    None = 2,
    Inherit = 3
}

KryptonManager.SnapLayoutValues.Mode = KryptonSnapLayoutMode.Toolkit;
form.SnapLayouts = KryptonSnapLayoutMode.Inherit; // default: follow manager
```

`SnapLayoutValues` is the only store. A fresh manager leaves `SnapLayout` unmodified. The menu reads values when it opens.

### Settings

| Property | Default | Effect |
| ---------- | --------- | -------- |
| `Mode` | `System` | Menu for forms that inherit. |
| `CornerRounding` | `8` | Menu corner radius in pixels. Zero is square. Region and drop shadow use this radius. |
| `CardSize` | `Size.Empty` | Preferred card size. Empty sizes to the work area and wraps rows. A positive size is used until the row no longer fits. |
| `ShowIcon` | `true` | Draw application icons in zones. |
| `ShowPreview` | `true` | While the pointer is over a zone, show where this form will snap. |
| `ShowPreviewGhost` | `false` | Opt-in. When `ShowPreview` is on, stretch a cached `PrintWindow` of this form into the hot zone instead of the palette fill and icon. Still uses `PreviewOpacity` and the palette border. |
| `PreviewOpacity` | `0.45` | Preview opacity `0..1`. Zero hides the preview. Clamped. |
| `ShowShadow` | `true` | Draw the menu drop shadow. |
| `ShadowColor` | `Color.Empty` | Shadow colour; empty draws as black. |
| `ShadowOpacity` | `0.18` | Shadow strength `0..1`. Clamped. |
| `ShadowOffset` | `3` | Drop in pixels (down/right). Clamped `0..32`. |
| `ShadowBlur` | `0` | Halo outside the menu. Zero is drop only. Clamped `0..32`. |
| `IncludeBuiltinLayouts` | `true` | Keep standard cards. `false` shows only custom cards. |
| `CustomLayouts` | empty | Cards appended after builtins. Designer `Content` + collection editors. |
| `RememberGroups` | `true` | In-process Snap Groups of peer `KryptonForm`s; restore from the menu. |
| `ShowAssist` | `true` | After snapping into one zone of a multi-zone card, offer other open `KryptonForm`s for remaining zones. |

### Persistence (custom cards)

| Method | Behaviour |
| -------- | ----------- |
| `ExportCustomLayouts()` | Versioned XML for current `CustomLayouts` + `IncludeBuiltinLayouts`. |
| `ImportCustomLayouts(string? xml)` | Replace collection. Null/whitespace clears cards and resets `IncludeBuiltinLayouts` to `true`. |
| `SaveCustomLayoutsToFile(string path)` | UTF-8 write of the export. |
| `LoadCustomLayoutsFromFile(string path)` | Read file, then import. |

Unsupported `version` throws. Invalid zones are skipped; cards with no valid zones are skipped. Import builds a new list then replaces so a failure does not leave a half-cleared collection.

```xml
<?xml version="1.0" encoding="utf-8"?>
<KryptonSnapCustomLayouts version="1">
  <IncludeBuiltinLayouts>true</IncludeBuiltinLayouts>
  <Card>
    <Zone X="0" Y="0" Width="0.7" Height="1" />
    <Zone X="0.7" Y="0" Width="0.3" Height="1" />
  </Card>
</KryptonSnapCustomLayouts>
```

Designer `Content` serialization can bake cards into `InitializeComponent` as compiled defaults. Runtime `Add` without Export/Save does not survive process restart.

## Snap behaviour

`Toolkit` remembers pre-snap bounds (`RestoreBounds` when maximized, otherwise `Bounds`). A later zone keeps that original rectangle. The maximize glyph switches to restore while the snap is active and `WindowState` is `Normal`. Dragging the caption restores that size under the pointer before the move loop. A later user move or resize, or maximizing, clears the snap flag and unregisters group membership.

Preview fill/border use tracking `ContextMenuItemHighlight`. With `ShowPreviewGhost`, fill and centered icon are replaced by the stretched owner capture (cached for the popup lifetime). Ghost cannot appear when `ShowPreview` is false or `PreviewOpacity` is 0.

Idle zone tiles use `ButtonStandalone`; the hot zone uses `ContextMenuItemHighlight`. Popup background is `PanelAlternate` with a `ControlClient` border. The drop shadow is a separate window; colour is painted solid and opacity is the window opacity (magenta colour key does not tint it).

## Snap Groups (own process)

1. Successful toolkit snap calls `KryptonSnapGroupRegistry.Register` when `RememberGroups` is true.
2. `Unregister` on caption unsnap, maximize that clears snap state, or dispose.
3. A group exists when **two or more** live forms share the card fingerprint and monitor key.
4. Menu prefers group-member icons for that card and shows `Group | {title} and …` while the card is hot.
5. Clicking a zone that belongs to the group restores every live member to the current work area. The form that opened the menu activates last when it is in the group.

Foreign HWNDs are never moved.

## Assist

After snapping into one zone of a multi-zone card (when `ShowAssist` is true):

1. Collect other visible top-level `KryptonForm`s that fit a remaining zone (`MinimumSize`).
2. Skip owned tool windows (`Owner != null` and `ShowInTaskbar == false`).
3. Show `VisualSnapLayoutAssistPopup` one remaining zone at a time; Escape dismisses.
4. Each Assist placement registers membership so the group can restore later.

## Usage

```csharp
SnapLayoutValues snap = KryptonManager.SnapLayoutValues;
snap.Mode = KryptonSnapLayoutMode.Toolkit;

form.SnapLayouts = KryptonSnapLayoutMode.Inherit;

snap.ShowPreview = true;
snap.ShowPreviewGhost = false;
snap.PreviewOpacity = 0.45f;
snap.ShowIcon = true;
snap.CornerRounding = 8f;
snap.CardSize = Size.Empty;
snap.ShowShadow = true;
snap.ShadowColor = Color.Empty; // black
snap.ShadowOpacity = 0.18f;
snap.ShadowOffset = 3;
snap.ShadowBlur = 0;
snap.RememberGroups = true;
snap.ShowAssist = true;
snap.IncludeBuiltinLayouts = true;

snap.CustomLayouts.Add(new KryptonSnapLayoutCard(
    new KryptonSnapLayoutZone(0f, 0f, 0.7f, 1f),
    new KryptonSnapLayoutZone(0.7f, 0f, 0.3f, 1f)));

string xml = snap.ExportCustomLayouts();
snap.SaveCustomLayoutsToFile(@"C:\Temp\layouts.xml");
snap.CustomLayouts.Clear();
snap.LoadCustomLayoutsFromFile(@"C:\Temp\layouts.xml");
// or: snap.ImportCustomLayouts(xml);
```

In the designer, drop a `KryptonManager`, expand `SnapLayout`, edit `CustomLayouts` / `Zones` (fractions `0..1`). A zone left at zero is not shown. Shadow, Groups, Assist, and preview ghost settings are on the same object.

`KryptonSnapLayoutZone` rejects edges outside `0..1`, a non-positive size, and a zone that extends past the work area (`ArgumentOutOfRangeException`). A fraction of a pixel of float error is allowed so mirrored thirds still construct. Add cards on the UI thread. The menu copies `CustomLayouts` when it opens.

## Edge cases

- Shell menu until `Mode` or a form’s `SnapLayouts` is `Toolkit`.
- Other applications are never moved; taskbar icons in empty zones are decorative.
- `ShowPreview` false or `PreviewOpacity` 0 hides colour and ghost preview.
- `ShowPreviewGhost` false keeps the palette fill and icon preview.
- `ShowShadow` false or `ShadowOpacity` 0 hides the drop shadow; `ShadowBlur` 0 is drop only.
- `RememberGroups` / `ShowAssist` false restores single-form menu behaviour.
- Win+Z unchanged.
- Fixed borders and forms without `MaximizeBox` do not show the toolkit menu.
- MDI children keep the previous hit-test and do not show the toolkit menu.
- Right-to-left mirrors builtin and custom zones.
- `IncludeBuiltinLayouts` false with an empty or unfit custom list means the toolkit menu does not open.
- Custom cards appear on a narrow work area; the wide-monitor gate applies only to builtin thirds / 25/50/25.
- Each custom card is labelled Custom; builtins have no label.
