# Taskbar Thumbnail Toolbar Buttons

This document describes the **Taskbar Thumbnail Toolbar Buttons** feature in the Krypton Toolkit: how to add interactive buttons (e.g. Play, Pause, Next) to the Windows 7+ taskbar thumbnail preview that appears when the user hovers over your application’s taskbar button. It covers APIs, usage patterns, icon requirements, limitations, and integration with `KryptonForm` / `VisualForm`.

---

## 1. Overview

### What It Is

Windows 7 and later expose **thumbnail toolbars** via the `ITaskbarList3` COM interface. A thumbnail toolbar is a strip of small buttons shown **below** the live thumbnail preview when the user hovers over a taskbar button. Applications like Windows Media Player use them for play, pause, next, and similar quick actions.

The Krypton Toolkit wraps this functionality so you can:

- Define up to **7 buttons** per form (icon, tooltip, enabled/disabled/hidden).
- Add, update, or clear buttons at runtime.
- Handle **clicks** via a `ThumbnailButtonClick` event that receives the button ID.

Buttons are **per-window**: each top-level `KryptonForm` (or other `VisualForm`-based form) that appears in the taskbar can have its own set of thumbnail toolbar buttons.

### Use Cases

- **Media players**: Play, Pause, Next, Previous, Stop.
- **Download/transfer**: Pause, Cancel, Open folder.
- **Communications**: Mute, Hold, End call.
- **Editors**: Quick actions (e.g. Save, Undo) without switching to the window.

---

## 2. Requirements

| Requirement | Details |
|-------------|---------|
| **Operating system** | Windows 7 or later (6.1+). The feature is no-op on older OS versions. |
| **Form type** | `KryptonForm` or any form derived from `VisualForm` (e.g. `KryptonForm`). |
| **Taskbar visibility** | The form’s `ShowInTaskbar` must be `true`. Thumbnail buttons are not applied when `ShowInTaskbar` is `false`. |
| **TaskbarButtonCreated** | The implementation **registers and handles** the `"TaskbarButtonCreated"` window message before calling `ITaskbarList3`. You do not need to do this yourself; it is done inside `VisualForm`. |

The toolkit defers applying thumbnail buttons until **after** the taskbar has created the button for the window and sent `TaskbarButtonCreated`. Button updates (e.g. from `Apply()` or `Add`/`Remove`/`Clear`) are applied once that message has been received.

---

## 3. API Reference

### 3.1. `ThumbnailButtonItem`

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`

Represents a single button in the thumbnail toolbar.

| Member | Type | Description |
|--------|------|-------------|
| `Id` | `uint` | Application-defined button ID. Must be **unique** within the toolbar. This value is passed to `ThumbnailButtonClick` when the button is clicked. **Note:** Uses `uint` for native API compatibility; non–CLS-compliant. |
| `Icon` | `Icon?` | Icon displayed on the button. Should be **32-bit** (e.g. `Format32bppArgb`) and **SM_CXICON × SM_CYICON** size (typically **32×32**). See [Icon requirements](#5-icon-requirements). |
| `Tooltip` | `string` | Tooltip shown when the user hovers over the button. Maximum **259 characters**; longer strings are truncated. |
| `Enabled` | `bool` | Whether the button is enabled. Default `true`. |
| `Hidden` | `bool` | Whether the button is hidden. Default `false`. |

**Example:**

```csharp
var btn = new ThumbnailButtonItem
{
    Id = 1,
    Icon = myIcon,
    Tooltip = "Play",
    Enabled = true,
    Hidden = false
};
```

---

### 3.2. `TaskbarThumbnailButtonValues`

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`

Storage for thumbnail toolbar button definitions. Holds a list of `ThumbnailButtonItem` and notifies the form to update the taskbar when the list changes.

| Member | Type | Description |
|--------|------|-------------|
| `Buttons` | `List<ThumbnailButtonItem>` | The list of buttons. Maximum **7**. Edit this list, then call `Apply()` to push changes to the taskbar. |
| `Add(ThumbnailButtonItem item)` | `void` | Appends a button. No-op if already at 7 buttons. Triggers an update. |
| `Remove(uint id)` | `void` | Removes the button with the given `Id`. No-op if not found. Triggers an update. **Note:** Non–CLS-compliant due to `uint`. |
| `Clear()` | `void` | Removes all buttons and updates the taskbar. |
| `Apply()` | `void` | Notifies that button definitions have changed (e.g. after editing `Buttons` directly). Call after batch changes to refresh the taskbar once. |
| `ResetButtons()` | `void` | Same as `Clear()`. |
| `CopyFrom(TaskbarThumbnailButtonValues source)` | `void` | Replaces this instance’s buttons with copies of `source`’s buttons. |
| `IsDefault` | `bool` | `true` when there are no buttons. |

**Designer:** `TaskbarThumbnailButtonValues` is `ExpandableObjectConverter`; `Buttons` is serialized as content.

---

### 3.3. `ThumbnailButtonClickEventArgs`

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`

Event data for thumbnail toolbar button clicks.

| Member | Type | Description |
|--------|------|-------------|
| `ButtonId` | `uint` | The `Id` of the button that was clicked. **Note:** Non–CLS-compliant. |

---

### 3.4. Form-Level API (`VisualForm` / `KryptonForm`)

| Member | Type | Description |
|--------|------|-------------|
| `ShellValues` | `WindowsShellValues` | Shell-related values (overlay icon, **thumbnail buttons**, jump list, etc.). |
| `ShellValues.ThumbnailButtonValues` | `TaskbarThumbnailButtonValues` | The thumbnail toolbar button storage for this form. |
| `ThumbnailButtonClick` | `event EventHandler<ThumbnailButtonClickEventArgs>` | Raised when the user clicks a thumbnail toolbar button. |

**Example:**

```csharp
// Access storage
var tbv = ShellValues.ThumbnailButtonValues;

// Subscribe to clicks
ThumbnailButtonClick += (s, e) =>
{
    switch (e.ButtonId)
    {
        case 1: DoPlay(); break;
        case 2: DoPause(); break;
        // ...
    }
};
```

---

### 3.5. `WindowsShellValues`

**Namespace:** `Krypton.Toolkit`  
**Assembly:** `Krypton.Toolkit`

Aggregates overlay icon, thumbnail buttons, and related shell settings. Exposed as `ShellValues` on `VisualForm`.

| Member | Type | Description |
|--------|------|-------------|
| `ThumbnailButtonValues` | `TaskbarThumbnailButtonValues` | Thumbnail toolbar buttons. |
| `OverlayIconValues` | `TaskbarOverlayIconValues` | Taskbar overlay icon (separate feature). |
| `ResetThumbnailButtonValues()` | `void` | Resets thumbnail buttons to default (empty). |

---

## 4. Features and Behaviour

### 4.1. Adding Buttons

- Use `Add(item)` for single additions, or add to `Buttons` and then call `Apply()` for batch updates.
- **Important:** The Windows API allows **one** `ThumbBarAddButtons` call per window. Subsequent changes use `ThumbBarUpdateButtons`. The toolkit manages this internally. To avoid multiple “first add” attempts, **batch** your buttons: fill `Buttons`, then call `Apply()` once.

**Recommended pattern:**

```csharp
var tbv = ShellValues.ThumbnailButtonValues;
tbv.Clear();
tbv.Buttons.Add(new ThumbnailButtonItem { Id = 1, Icon = icon1, Tooltip = "Play", Enabled = true });
tbv.Buttons.Add(new ThumbnailButtonItem { Id = 2, Icon = icon2, Tooltip = "Pause", Enabled = true });
// ... up to 7 total
tbv.Apply();
```

### 4.2. Updating Buttons

- Change an existing `ThumbnailButtonItem`’s `Icon`, `Tooltip`, `Enabled`, or `Hidden`, then call `Apply()`.
- The toolkit uses `ThumbBarUpdateButtons` for updates. You cannot remove a button at the native level; you can only **hide** it (`Hidden = true`) or **disable** it (`Enabled = false`).

### 4.3. Clearing Buttons

- Call `Clear()`. The managed list is cleared and the taskbar is updated. The native toolbar may still show previously added buttons as hidden; the toolkit reflects “no buttons” by not sending further updates for that set.

### 4.4. Button Limit and Order

- **Maximum 7 buttons** per window. `Add` ignores new items when the list is full.
- Buttons are shown in **list order** (index 0 = leftmost).

### 4.5. Tooltip Length

- Tooltips are truncated to **259 characters** before being sent to the native API.

---

## 5. Icon Requirements

The Windows thumbnail toolbar expects **32-bit** icons at **SM_CXICON × SM_CYICON** (typically **32×32** on standard DPI). Otherwise, buttons may not appear or may look wrong.

**Recommendations:**

1. Use **32×32** pixel icons (or `GetSystemMetrics(SM_CXICON)` / `SM_CYICON` if you need DPI-aware sizing).
2. Use **`PixelFormat.Format32bppArgb`** when creating bitmaps, then create an `Icon` (e.g. via `Icon.FromHandle(bitmap.GetHicon())`). Keep the `Icon` (or underlying bitmap) alive for the lifetime of the button.
3. Prefer **simple, high-contrast** shapes so buttons remain readable at small size.

**Example: creating a suitable icon**

```csharp
using System.Drawing.Imaging;

const int size = 32;
var bmp = new Bitmap(size, size, PixelFormat.Format32bppArgb);
using (var g = Graphics.FromImage(bmp))
{
    g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;
    using (var brush = new SolidBrush(Color.DodgerBlue))
    {
        // e.g. play triangle
        var pts = new[] { new Point(10, 8), new Point(10, 24), new Point(24, 16) };
        g.FillPolygon(brush, pts);
    }
}
Icon icon = Icon.FromHandle(bmp.GetHicon());
// Keep 'icon' (or 'bmp') alive while the button is in use.
```

You can also use **system icons** (e.g. `SystemIcons.Application`, `SystemIcons.Information`) for quick tests, as long as they meet the size/format expectations.

---

## 6. Code Examples

### 6.1. Minimal Setup (Load)

```csharp
public partial class MyForm : KryptonForm
{
    private const uint IdPlay = 1, IdPause = 2;

    private void MyForm_Load(object sender, EventArgs e)
    {
        ShowInTaskbar = true;
        Icon = SystemIcons.Application;

        var tbv = ShellValues.ThumbnailButtonValues;
        tbv.Clear();
        tbv.Buttons.Add(new ThumbnailButtonItem
        {
            Id = IdPlay,
            Icon = CreatePlayIcon(),
            Tooltip = "Play",
            Enabled = true
        });
        tbv.Buttons.Add(new ThumbnailButtonItem
        {
            Id = IdPause,
            Icon = CreatePauseIcon(),
            Tooltip = "Pause",
            Enabled = false
        });
        tbv.Apply();

        ThumbnailButtonClick += OnThumbnailButtonClick;
    }

    private void OnThumbnailButtonClick(object? s, ThumbnailButtonClickEventArgs e)
    {
        if (e.ButtonId == IdPlay) { Play(); return; }
        if (e.ButtonId == IdPause) { Pause(); return; }
    }
}
```

### 6.2. Updating State (e.g. Play ↔ Pause)

```csharp
private void UpdateThumbnailState(bool isPlaying)
{
    var tbv = ShellValues.ThumbnailButtonValues;
    var play = tbv.Buttons.FirstOrDefault(b => b.Id == IdPlay);
    var pause = tbv.Buttons.FirstOrDefault(b => b.Id == IdPause);
    if (play != null) play.Enabled = !isPlaying;
    if (pause != null) pause.Enabled = isPlaying;
    tbv.Apply();
}
```

### 6.3. Clearing Buttons

```csharp
ShellValues.ThumbnailButtonValues.Clear();
```

---

## 7. Limitations and Pitfalls

| Limitation | Description |
|------------|-------------|
| **Windows 7+** | No effect on Windows Vista or earlier. |
| **ShowInTaskbar** | Buttons are only applied when `ShowInTaskbar` is `true`. |
| **No real “remove”** | The native API does not support removing buttons. Use `Hidden = true` or `Clear()`; the toolkit clears its list, but the shell may keep reserved space. |
| **7 buttons max** | More than 7 buttons are ignored. |
| **Icon size/format** | Wrong size or format can prevent buttons from showing. Prefer 32×32, 32bpp. |
| **Per-window** | Each taskbar-represented window has its own toolbar. Child/owned windows typically do not. |
| **Grouped taskbar** | When multiple app windows are grouped, each thumbnail has its own toolbar. Ensure you configure buttons on the correct form. |
| **Design mode** | Thumbnail logic is skipped in design mode. |

---

## 8. Internal Behaviour (Summary)

- **TaskbarButtonCreated:** The form registers `"TaskbarButtonCreated"` and handles it in `WndProc`. Thumbnail updates are deferred until this message is received.
- **ThumbBarAddButtons / ThumbBarUpdateButtons:** The first update uses `ThumbBarAddButtons`; later updates use `ThumbBarUpdateButtons`. The toolkit uses manual marshalling for `THUMBBUTTON` arrays to avoid COM typelib/SAFEARRAY issues.
- **WM_COMMAND + THBN_CLICKED:** Button clicks arrive as `WM_COMMAND` with `HIWORD(wParam) == THBN_CLICKED`; `LOWORD(wParam)` is the button ID. The toolkit raises `ThumbnailButtonClick` with that ID.
- **Handle lifecycle:** On handle destroy, internal state (`_thumbButtonsAdded`, `_taskbarButtonCreated`) is reset so that a recreated handle gets correct behaviour.

---

## 9. Related Features

- **Overlay icon:** `ShellValues.OverlayIconValues` — small overlay on the taskbar icon (e.g. notification badge).
- **Jump list:** `ShellValues.JumpList` — custom jump list items and categories.
- **Progress / state:** Other `ITaskbarList3` features (e.g. progress bar, overlay) can be used alongside thumbnail buttons; they are separate configurations.

---

## 10. Demo and References

- **Windows docs:** [ITaskbarList3::ThumbBarAddButtons](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist3-thumbbaraddbuttons), [ITaskbarList3::ThumbBarUpdateButtons](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nf-shobjidl_core-itaskbarlist3-thumbbarupdatebuttons), [THUMBBUTTON](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/ns-shobjidl_core-thumbbutton).
