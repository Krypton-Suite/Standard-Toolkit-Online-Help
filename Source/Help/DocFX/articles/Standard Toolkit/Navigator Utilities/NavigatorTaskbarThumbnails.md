# Navigator Taskbar Thumbnails

## Overview

Issue [#882](https://github.com/Krypton-Suite/Standard-Toolkit/issues/882): opt-in Windows taskbar **tabbed thumbnails** (IE-style flyout) for `KryptonNavigator` pages, provided by **`Krypton.Navigator.Utilities`**.

When a `KryptonNavigatorTaskbarThumbnails` component is attached to a navigator and enabled, each eligible page appears as its own preview in the host form’s taskbar flyout. Clicking a thumbnail selects that page and restores the host.

Package: download **`Krypton.Standard.Toolkit`** — types live in assembly `Krypton.Navigator.Utilities`. The Utilities project itself is not separately packable.

## Architecture

```text
KryptonNavigatorTaskbarThumbnails (1..N on a form)
        │  Navigator + Enabled / IncludeHiddenPages / …
        ▼
NavigatorTaskbarThumbnailManager (per-component adapter)
        │
        ▼
NavigatorTaskbarHostCoordinator (one per ShowInTaskbar host Form)
        ├── single NativeWindow for TaskbarButtonCreated
        ├── ITaskbarList3 (+ ITaskbarList4.SetTabProperties)
        ├── merged tab catalog (navigator, page) → proxy HWND
        └── host overlay / progress / thumb-bar from selected page
        │
        ▼
NavigatorTaskbarThumbnailProxy (off-screen WS_VISIBLE Form per page)
        │  RegisterTab / SetTabOrder / SetTabActive / SetTabProperties
        ▼
DWM iconic bitmaps (WM_DWMSENDICONICTHUMBNAIL / LIVEPREVIEW)
```

`KryptonPage` is a child control, so it cannot be registered with `ITaskbarList3::RegisterTab` directly. Each page gets a small hidden, owned, off-screen proxy window that remains `WS_VISIBLE` so thumbnail clicks deliver activation. DWM asks that proxy for bitmaps via iconic messages.

Multiple enabled components on the **same taskbar-visible host** merge their eligible pages into **one** flyout (shared tab order and active tab).

## Public API

### `KryptonNavigatorTaskbarThumbnails`

| Member | Default | Meaning |
|--------|---------|---------|
| `Navigator` | `null` | Navigator whose pages are registered |
| `Enabled` | `true` | Master switch for registration |
| `IncludeHiddenPages` | `false` | Include pages with `LastVisibleSet == false` |
| `AllowCloseFromThumbnail` | `true` | Thumbnail close (X) runs `PerformCloseAction` |
| `ActiveTabUsesAppPreview` | `true` | Active tab uses host window for thumbnail/Peek (`STPF_*WHENACTIVE`) |
| `MaxThumbnails` | `0` | Per-component cap on registered pages; `0` = unlimited |
| `UseSelectedPageOverlay` | `false` | Drive host overlay icon via `QueryOverlay` |
| `UseSelectedPageProgress` | `false` | Drive host progress via `QueryProgress` |
| `UseSelectedPageThumbnailButtons` | `false` | Drive host thumb-bar via `QueryThumbnailButtons` |
| `RefreshThumbnails()` | | Force re-sync of registration |

Events:

| Event | Purpose |
|-------|---------|
| `QueryThumbnail` | Optional custom page thumbnail / live-preview bitmap |
| `QueryOverlay` | Host overlay icon for the selected page |
| `QueryProgress` | Host progress for the selected page |
| `QueryThumbnailButtons` | Up to 7 host thumbnail toolbar buttons |

Overlay, progress, and thumbnail toolbar buttons are **group-level Shell features** on the host HWND. “Tied to selected page” means the coordinator updates the host from the currently active merged page — not per-tab Shell UI.

Designer: dropping the component auto-assigns the first `KryptonNavigator` on the root form. Smart-tag exposes the main behavior properties.

### `KryptonPageFlags.AllowTaskbarThumbnail` (`0x0800`)

Defined on `KryptonPage` in **`Krypton.Navigator`**. Included in `KryptonPageFlags.All` (on by default). Clear it for wizard steps that must not appear:

```csharp
wizardPage.ClearFlags(KryptonPageFlags.AllowTaskbarThumbnail);
```

Editable at design time via the page Flags dialog and the page smart-tag (“Allow Taskbar Thumbnail”).

## Usage

```csharp
using Krypton.Navigator.Utilities;

var taskbarThumbnails = new KryptonNavigatorTaskbarThumbnails(components)
{
    Navigator = navigator,
    Enabled = true,
    ActiveTabUsesAppPreview = true
};

taskbarThumbnails.QueryThumbnail += (s, e) =>
{
    // Optional: e.Thumbnail = RenderPreview(e.Page, e.Size);
    // Ownership of e.Thumbnail stays with the handler; the component clones it.
};

// Exclude a wizard page
page.ClearFlags(KryptonPageFlags.AllowTaskbarThumbnail);
```

### Multi-navigator merge

Attach one component per navigator. If both share the same `ShowInTaskbar` host form, their eligible pages merge into one taskbar group (component attach order, then each navigator’s `Pages` order).

### Host shell status (selected page)

```csharp
taskbarThumbnails.UseSelectedPageOverlay = true;
taskbarThumbnails.UseSelectedPageProgress = true;
taskbarThumbnails.QueryOverlay += (s, e) =>
{
    e.Icon = statusIcon;          // ownership remains with handler
    e.Description = e.Page.Text;
};
taskbarThumbnails.QueryProgress += (s, e) =>
{
    e.State = TaskbarProgressState.Normal;
    e.Completed = 40;
    e.Total = 100;
};
```

## Snapshots and refresh

- Prefer `QueryThumbnail` when provided.
- Otherwise capture via `PrintWindow` (fallback `DrawToBitmap`), `Format32bppArgb`.
- Snapshots are taken when a page loses selection, on idle after sync/insert, and (debounced ~200 ms) when the selected page paints/invalidates.
- Never-visited / inactive pages are forced into a capturable size when possible; otherwise a placeholder with caption/image is used.

## Edge cases

- **Design mode** — no registration.
- **Windows 7+** — requires taskbar tab APIs; Peek flags use `ITaskbarList4` when available.
- **Taskbar host** — coordinator walks `FindForm()` / `Owner` until a form with `ShowInTaskbar` is found. If none (typical float window), pages are unregistered rather than bound to a non-taskbar HWND.
- **Docking float / redock** — floated pages leave the merged catalog; redocking back onto the host re-registers them (driven by parent/visible/page events; no hard Docking project reference).
- **Close from thumbnail** — always routes through `PerformCloseAction`. `AllowCloseFromThumbnail == false` and `CloseButtonAction.None` keep the proxy alive (`WM_CLOSE` is swallowed). Unregister only when the page is removed or becomes ineligible.
- **Win11 click / Peek** — proxy handles `WM_ACTIVATE` / `OnActivated` with deferred page select + host restore; active tab Peek uses the host frame when `ActiveTabUsesAppPreview` is true.

## Validation

TestForm demo: **`Feature882NavigatorTaskbarThumbnailsDemo`** (registered on `StartScreen`).

Manual Win11 checks:

1. Hover taskbar — never-visited pages show real/forced snapshots, not empty placeholders.
2. Edit selected page content — thumbnail refreshes after debounce.
3. Click thumbnail — correct page/navigator selected; host restored.
4. Peek active tab — host-frame preview when `ActiveTabUsesAppPreview` is on.
5. Thumbnail X — respects remove / hide / cancel / deny.
6. Enable second navigator — merged flyout, one active tab.
7. Selected-page overlay/progress/thumb buttons update the host taskbar button.
