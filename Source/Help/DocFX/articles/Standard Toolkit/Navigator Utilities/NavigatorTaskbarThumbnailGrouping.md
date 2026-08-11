# Navigator Taskbar Thumbnails & Snap Groups

## Overview

Windows taskbar integration for navigator pages and multi-window Snap Groups lives in two layers:

| Layer | Package | Issue | What it does |
|-------|---------|-------|--------------|
| Per-page (and TabGroup) thumbnails | `Krypton.Navigator.Utilities` | [#882](https://github.com/Krypton-Suite/Standard-Toolkit/issues/882), [#4129](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4129) | Registers hidden proxy HWNDs with `ITaskbarList3.RegisterTab` so the host’s taskbar flyout shows one thumbnail per page, plus optional composite **Group \| …** entries for caption tab groups |
| OS Snap Groups | `Krypton.Toolkit` / `Krypton.Docking` | [#4129](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4129) | Eligibility only — Windows creates Snap Group previews when ≥2 **taskbar-visible** windows are snapped together |

These are different shell features. TabGroup composites use `RegisterTab`. Real Snap Groups are owned by Explorer and cannot be synthesised for pages inside a single form.

## Architecture (navigator thumbnails)

```
KryptonNavigatorTaskbarThumbnails
        │
        ▼
NavigatorTaskbarThumbnailManager
        │
        ▼
NavigatorTaskbarHostCoordinator  (one per ShowInTaskbar host)
        │  ordered slots: [Group A] [A1] [A2] [ungrouped] …
        ▼
NavigatorTaskbarThumbnailProxy / NavigatorTaskbarGroupThumbnailProxy
        │  DWM iconic bitmaps + ITaskbarList3/4
        ▼
Host Form taskbar button flyout
```

## Usage — page thumbnails (#882)

1. Add `KryptonNavigatorTaskbarThumbnails` to the form.
2. Set `Navigator` to the `KryptonNavigator`.
3. Leave `Enabled` true.
4. Clear `KryptonPageFlags.AllowTaskbarThumbnail` on pages that should not appear (wizard steps, etc.).

```csharp
taskbarThumbnails.Navigator = kryptonNavigator;
taskbarThumbnails.Enabled = true;
```

## Usage — TabGroup composites (#4129)

Requires a `KryptonNavigatorFormIntegrator` that owns the same navigator and has `AllowTabGroups` true. Catalog membership is `KryptonPage.TabGroupId` → `FormIntegrator.TabGroups`.

```csharp
taskbarThumbnails.FormIntegrator = integrator;
taskbarThumbnails.ShowTabGroupThumbnails = true;
```

Flyout order (Explorer-like):

`Group | Work` → member pages → ungrouped pages …

- Clicking a group thumbnail activates the first visible member (or brings the host forward if the selected page is already in the group).
- Group thumbnails never close members from the flyout X.
- `MaxThumbnails` counts **group slots + page slots**.
- Customise collages via `QueryTabGroupThumbnail`.

## Usage — Windows 11 Snap Groups (#4129)

Snap Groups appear automatically when the user snaps ≥2 windows that each have a taskbar button. Apps only stay eligible.

### Peer `KryptonForm` windows

- `ShowInTaskbar = true`
- `Owner = null` (do not own peer document windows)
- Avoid `FormBorderStyle.*ToolWindow`
- Set one process AppUserModelID **before first UI** (e.g. `JumpList.AppId` or `SetCurrentProcessExplicitAppUserModelID`)

### Docking floats (opt-in)

By default `KryptonFloatingWindow` uses `ShowInTaskbar = false` and is owned by the main form — excluded from Snap Groups.

```csharp
KryptonDockingFloating floating = dockingManager.ManageFloating("Floating", this);
floating.ShowFloatingWindowsInTaskbar = true; // new floats only
```

Keep the same process AUMID as the main form. Expect extra taskbar buttons when floats are visible.

### OS setting

Settings → System → Multitasking → Snap windows → **Show my snapped windows when I hover over taskbar apps, in Task View, and when I press Alt+Tab**.

## TestForm demos

- `Feature882NavigatorTaskbarThumbnailsDemo` — pages, merge, close modes, and **Tab group composites** checkbox.
- `Feature4129SnapGroupsDemo` — peer window + optional floats in taskbar.

## Key types

| Type | Role |
|------|------|
| `KryptonNavigatorTaskbarThumbnails` | Public opt-in component |
| `KryptonPageFlags.AllowTaskbarThumbnail` | Per-page include/exclude |
| `QueryTaskbarThumbnailEventArgs` | Custom page bitmap |
| `QueryTaskbarTabGroupThumbnailEventArgs` | Custom group collage |
| `KryptonDockingFloating.ShowFloatingWindowsInTaskbar` | Opt-in float taskbar buttons |
| `JumpListValues.AppId` | Process AUMID |

## Out of scope

- Fabricating OS Snap Groups for in-process pages (use TabGroup composites instead).
- Changing the default float `ShowInTaskbar` behaviour.
- Per-window AUMID helpers beyond process-level `AppId`.
