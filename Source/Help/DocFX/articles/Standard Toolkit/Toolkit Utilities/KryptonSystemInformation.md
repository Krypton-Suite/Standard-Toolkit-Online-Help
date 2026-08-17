# Krypton System Information

## Overview

Issue [#3176](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3176) adds a Krypton-themed replacement for launching Windows System Information (`MSInfo32.exe`) from `KryptonAboutBox`. The feature lives in `Krypton.Toolkit.Utilities` and can also be shown standalone.

It copies the **msinfo32 UX** (left category tree, right details grid) and a broad set of categories. It does **not** read or write Microsoft’s proprietary `.nfo` format. Export is UTF-8 text. Print uses a standard print preview of the visible rows.

## Architecture

- **Public API:** `KryptonSystemInformation` (`Show` returns the `Form`, `ShowDialog`, `ShowAsync`) and `KryptonSystemInformationData`.
- **Strings:** `KryptonSystemInformation.Strings` (`KryptonSystemInformationStrings.Current`) — localisable independently of `KryptonManager.Strings` (Utilities cannot extend Toolkit string bags without a circular reference).
- **UI:** `VisualSystemInformationForm` — tree + virtual-mode grid, Find / Find next (F3, tree names) / Copy / Save / Print / Refresh, **All processes** on Loaded Modules, optional **Windows System Information...**.
- **Catalog:** `SystemInformationCatalog` expands Hardware / Components / Software folders only (not `ExpandAll`).
- **Collect:** `SystemInformationCollector` dispatches to branch providers.
- **WMI:** `SystemInformationWmi` reuses one `ManagementScope` (`root\cimv2`), caches query results until Refresh, 20-second timeout, hardware lists capped at 750 rows. Conflicts and Problem Devices share the same PnP WQL cache key.

Queries run on a worker thread when a **leaf** node is selected. Folder nodes show a “select a category” prompt.

```
KryptonAboutBox / KryptonSystemInformation
        -> VisualSystemInformationForm
                -> SystemInformationCatalog (tree)
                -> SystemInformationCollector (lazy)
                        -> reused WMI scope + managed APIs
```

## Public API

```csharp
KryptonSystemInformation.Strings.WindowTitle = "System Information";
var form = KryptonSystemInformation.Show(owner);
form.FormClosed += (_, __) => { /* re-enable a trigger button */ };

KryptonSystemInformation.ShowDialog(owner, new KryptonSystemInformationData
{
    InitialCategoryId = SystemInformationCategoryId.SystemSummary,
    ShowWindowsSystemInformation = true,
    EnumerateAllProcessModules = false,
    UseRtlLayout = KryptonUseRTLLayout.No
});
await KryptonSystemInformation.ShowAsync(owner);
```

## Performance notes

- System Summary runs independent WMI classes in parallel, then merges Item/Value rows.
- Running Tasks uses `Process.GetProcesses()` (not `Win32_Process`).
- Loaded Modules defaults to the **current process**. Check **All processes** (or `EnumerateAllProcessModules`) for a full walk.
- The grid is `VirtualMode`; Find filters an index list instead of hiding `DataGridViewRow`s.
- Save all runs off the UI thread from a cache snapshot.
- IRQ / I/O / DMA / device memory lists use `HardwareResourceRowLimit` (750).

## Data sources

| Area | Typical sources |
| --- | --- |
| System Summary | `Environment`, `RuntimeInformation`, parallel `Win32_OperatingSystem` / `ComputerSystem` / `Processor` / `BIOS` / `TimeZone` / `PageFileUsage` |
| Hardware Resources | `Win32_PnPEntity` (shared problem-device query), DMA, I/O, IRQ, memory |
| Components | Sound, video, input, modem, network adapters, **network configuration** (`Win32_NetworkAdapterConfiguration`), ports, disk / `DriveInfo`, printers, USB |
| Software | Drivers, environment variables, `Process` tasks/modules, services, startup, OLE (capped 500), WER registry |

## About Box

`KryptonAboutBoxUtilities.LaunchSystemInformation(owner, trigger)` shows the viewer and disables `trigger` until `FormClosed`. The About Box System Information button is passed as `trigger`.
