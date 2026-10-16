# KryptonForm caption text box

A `KryptonTextBox` can sit in the `KryptonForm` caption. `KryptonSearchBox` uses the same slot because it derives from `KryptonTextBox` and lives in `Krypton.Toolkit.Utilities`. `Krypton.Toolkit` does not reference Utilities.

The caption is non-client chrome. `WM_NCCALCSIZE` keeps it outside the client area, so a normal child cannot be moved into the title bar. Title-bar `ButtonSpec` views are not windows: they have no caret, no keyboard focus, and no IME. The editor is a real control, parented to a borderless owned window that is positioned over a reserved caption slot.

## API

These members are on `KryptonForm`, category Visuals.

| Member | Type | Default | Behavior |
|--------|------|---------|----------|
| `CaptionControl` | `Control?` | `null` | Shortcut control. Assigning it does not remove the other caption controls. A `Form` is rejected. |
| `CaptionTextBox` | `KryptonTextBox?` | `null` | Shortcut when that control is a `KryptonTextBox`. Setting `null` removes that text box only. |
| `CaptionTextBoxEdge` | `FormCaptionTextBoxEdge` | `Right` | Edge of the shortcut control only. |
| `AddCaptionControl` | method |  | Adds a control on its own edge. Adding the same control again updates that edge. |
| `SetCaptionControlEdge` | method |  | Moves one caption control. |
| `RemoveCaptionControl` | method |  | Removes one control and restores its previous parent. |
| `TryGetCaptionControlEdge` | method |  | Reads one control's edge. |

The designer writes `CaptionTextBox` when the control is a `KryptonTextBox`, and `CaptionControl` otherwise.

Width, cue text, palette, and button specs stay on the control. The host clamps the height to the caption content height and does not grow `RealWindowBorders`. `FormBorderStyle.None` and a hidden caption leave the control as a normal child. The designer does not reparent the control; hosting starts at runtime.

`FormCaptionTextBoxEdge` is in `Krypton.Toolkit`.

## Hosting

`KryptonForm.CaptionTextBox.cs` owns the feature.

1. Each hosted control has its own `FormCaptionTextBoxEdge` and its own owned window. `PrepareCaptionTextBoxSlot` inserts a `ViewLayoutSeparator` per left or right control. Heading layout reverses children, and each separator is inserted at index 0 in add order, so the earlier control on that edge sits nearer the window edge and a later one sits nearer the title. `Center` controls share one centred group in `FillRectangle`. The fill (title, icon, ribbon tabs) is laid out again on the near side of that group. The separator preferred height is 1; `ViewDecoratorFixedSize` keeps the caption height unchanged.
2. After caption layout, `SyncCaptionTextBoxHost` maps the slot through `GetWindowRect` and moves the host with `SetWindowPos` (`SWP_NOACTIVATE`, `SWP_NOZORDER`, `SWP_NOOWNERZORDER`). Window coordinates are physical pixels, so the host is not positioned with `Form.SetBounds`.
3. The host is an internal borderless `Form`: `ShowInTaskbar` is false, `WS_EX_NOACTIVATE` and `WS_EX_TOOLWINDOW` are set, and `WM_MOUSEACTIVATE` returns `MA_NOACTIVATE`. A click focuses the editor without deactivating the owner, so the caption stays active while the editor contains focus and the owner or the host is the active form.
4. `WindowChromeHitTest` returns `HTBORDER` for the slot, below the top resize band, so a gap around the editor does not start a caption drag. Double-click maximize and caption drag still work outside the slot.
5. The host is owned by `MdiParent` when the form is an MDI child, and it is hidden unless that child is active. A minimized or hidden form hides the host. If the form is top-most, the host is top-most as well.
6. Tab from the editor activates the owner and moves focus with `SelectNextControl`.

Palette mode is whatever the control already uses. `WM_NCCALCSIZE` is unchanged.

## Usage

```csharp
var search = new KryptonSearchBox
{
    Width = 220
};
search.CueHint.CueHintText = "Search";
kryptonForm.CaptionTextBoxEdge = FormCaptionTextBoxEdge.Right;
kryptonForm.CaptionTextBox = search;

var button = new KryptonButton { Text = "Caption", AutoSize = true };
kryptonForm.AddCaptionControl(button, FormCaptionTextBoxEdge.Left);
```

`KryptonSearchBox` suggestion popups use `PointToScreen` and `SW_SHOWNOACTIVATE`, so they still open under the caption editor.

Changing `Width` or `Height` while the control is in the caption updates the reserved slot on the next layout. The placed width is the control width plus an 8-pixel horizontal gap, clamped to the caption. The placed height is the control height clamped to the caption, with a 2-pixel vertical gap.

## Edge cases

- Custom chrome must be applied (`UseThemeFormChromeBorderWidth` on both the public allow flag and the form chrome). Before the handle exists, the control stays a child of its original parent.
- An integrated ribbon (Office 2024 or otherwise) lays out around the same slot. The slot does not replace ribbon context tabs or the quick-access toolbar.
- Right-to-left layout mirrors the dock with the rest of the caption.
- Disposing the form restores the editor when it had a previous parent. An editor created only for the caption is disposed with the host.
