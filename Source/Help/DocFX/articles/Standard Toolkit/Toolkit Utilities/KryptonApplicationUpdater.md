# Krypton Application Updater

`KryptonApplicationUpdater` lives in `Krypton.Toolkit.Utilities`. It checks for a newer `System.Version`, asks or applies according to severity, and verifies the file before an installer starts or a zip is extracted. The running process cannot replace its own files, so a zip is applied by an embedded net472 helper after this process exits.

## Architecture

`KryptonApplicationUpdater` is a toolbox component. It does not contact the network from its constructor. The schedule starts only after the component is sited, and only when `Mode` is not `Manual` and the site is not the designer.

```text
CheckNow / timer
  -> IKryptonUpdateProvider
  -> newer System.Version?
  -> skip or postpone gate
  -> Notify prompt, or Automatic download when severity is at or below the threshold
  -> download (resume a partial file, or start again)
  -> SHA-256 of the whole file (and Authenticode when a thumbprint is set)
  -> installer process, or the embedded helper
```

| Type | Role |
| ------ | ------ |
| `KryptonApplicationUpdater` | Schedule, prompt, download, verify, apply |
| `IKryptonUpdateProvider` | Returns a `KryptonUpdateCatalog` |
| `KryptonJsonManifestUpdateProvider` | One JSON object or `{ "packages": [ ... ] }` |
| `KryptonGitHubReleaseUpdateProvider` | Latest GitHub release |
| `KryptonUpdateStateStore` | Last check, postpone, and skip, one file per entry assembly |
| `Krypton.Toolkit.Utilities.UpdateHelper` | net472 exe embedded in the utilities assembly. It is not copied to the consumer output and it is not packed |
| `KryptonTransferProgressPanel` | Toolbox composite used when progress display is `TransferSpeedGraph` (speed + optional progress chart) |
| `KryptonTransferDualGraph` | Optional single-chart dual series via panel `ChartLayout.DualSeries` (not selected by the updater) |

JSON on `net472` uses `JavaScriptSerializer`. `net8.0-windows` and later use `System.Text.Json`.

## Public API

Designer properties use `[DefaultValue]` so a fresh drop stays unbold. `Strings` is a `GlobalId` storage object and `IsDefault` is true until a string changes.

| Property | Default | Meaning |
| ---------- | --------- | --------- |
| `FeedKind` | `JsonManifest` | `JsonManifest` or `GitHubReleases`. Ignored when `Provider` is set |
| `FeedUrl` | empty | HTTPS manifest, or a local file path |
| `GitHubOwner`, `GitHubRepository`, `GitHubAssetName` | empty | Latest-release lookup. `GitHubAssetName` selects one asset when the release has no `krypton-update.json` |
| `GitHubDefaultSeverity` | `Recommended` | Used when the release itself is mapped to a package |
| `CurrentVersion` | empty | Empty uses the entry assembly version |
| `Mode` | `Notify` | `Manual` runs only from `CheckNow`. `Notify` asks. `Automatic` downloads without a prompt when the severity is at or below `AutomaticApplyMaximumSeverity` |
| `CheckOnStartup` | true | One check after the component is sited, still subject to `CheckInterval` |
| `CheckInterval` | 1 day | Scheduled checks skip when the last successful check is still inside this interval |
| `AutomaticApplyMaximumSeverity` | `Recommended` | Highest severity `Automatic` applies without a prompt |
| `AllowPostpone` | true | Shows Remind me later. The manifest can still hide it |
| `PostponeInterval` | 1 day | Initial remind-later date, and the span used by `Postpone(package)` |
| `ExitApplicationOnApply` | true | Zip apply exits this process so the helper can replace files |
| `InstallDirectory` | empty | Empty uses the application base directory |
| `RestartCommand` | empty | Empty restarts the current process after a zip apply that exits |
| `ProgressDisplay` | `ProgressBar` | Primary download chrome: `ProgressBar` or `TransferSpeedGraph`. A package `progressDisplay` value overrides this when set |

`Provider` (`IKryptonUpdateProvider`) and `GitHubToken` are hidden from the designer and are not serialized. `StateFilePath` is hidden. Empty stores state at `%LocalAppData%\Krypton Toolkit\Updates\<entry assembly>.state`.

Severities, low to high: `Optional`, `Recommended`, `Important`, `Critical`. Omit `allowPostpone` or `allowSkip` and a critical package hides that action. Set the flag true to offer it.

Events the host can cancel: `Checking`, `UpdateAvailable`, `DownloadProgress`, `Applying`. `Failed`, `Completed`, `Postponed`, and `Skipped` are notifications. Cancel `UpdateAvailable` to show your own UI, then call `DownloadAsync` and `ApplyAsync`.

Methods: `CheckNow` (fire-and-forget), `CheckNowAsync` (ignores the interval and an active postpone), `CheckAsync` (scheduled gates, including `Manual` which returns `Idle`), `ShowReleaseNotesAsync`, `DownloadAsync`, `ApplyAsync`, `Postpone`, `Postpone(package, duration)`, `Skip`. `CheckNow` stays quiet for a skipped version until a newer version exists. `Postpone(package)` still uses `PostponeInterval`. The remind-later dialog calls `Postpone(package, duration)` with the time until the chosen date.

The update prompt is the short decision: current version, new version, severity, Update now, Release notes, and Remind later. Release notes opens `VisualApplicationUpdateNotesForm` and leaves the prompt open. That window is read-only. `ShowReleaseNotesAsync` opens the same window directly. When a newer package exists it also offers Update now and Remind later, and it does not apply automatically. When nothing is newer, the title is "Release notes", the heading is "You are up to date.", and the list is every feed package with Close only. A feed failure raises `Failed` and shows the message in that window. Notes are newest first (version, severity, released UTC, text). `SelectAllNewerThan` is the list; `SelectNewerThan` remains the package that is downloaded. GitHub without a multi-package `krypton-update.json` still returns one release.

Remind later opens a small dialog with a `KryptonDateTimePicker`. The date runs from tomorrow through `maximumPostponeDays` (365 when the manifest omits it) and starts `PostponeInterval` whole days from today, at least one day ahead and never past that limit. Scheduled checks stay quiet until the start of that local date. `Postpone(package, duration)` is clamped to the same limit. When skip is also allowed, Skip this version is on this dialog and still ignores that version until a newer one exists. Cancel returns to the window that opened the dialog. Scheduled checks and Check now are unchanged: a postpone hides that version until the stored time, and Check now still ignores an active postpone.

A critical package hides Remind later unless the manifest sets `allowPostpone` to true, and hides Skip this version unless it sets `allowSkip` to true. Either value false hides that action for any severity. When postpone is hidden and skip is allowed, Skip this version is on the prompt. Otherwise it stays on the remind-later dialog. The component `AllowPostpone` property can still hide Remind later. `Postpone` does nothing when postpone is blocked. `Skip` does nothing when skip is blocked.

`allowResume` false hides Resume. `allowRetry` false hides Restart. Omit either and that button stays available. A local file still has no Resume, because it is copied in one pass. When both are false, the progress window offers Close only.

## Feed contract

The newest `System.Version` newer than the current version wins. A leading `v` is stripped. Prerelease labels are not ordered.

```json
{
  "version": "2.1.0",
  "severity": "important",
  "packageKind": "installer",
  "packageUrl": "https://example.com/setup-2.1.0.exe",
  "sha256": "<64 hex chars>",
  "certificateThumbprint": "<optional>",
  "releaseNotes": "text",
  "installerArguments": "/quiet",
  "releasedUtc": "2026-11-03T00:00:00Z",
  "maximumPostponeDays": 14,
  "allowPostpone": false,
  "allowSkip": true,
  "allowResume": true,
  "allowRetry": false,
  "progressDisplay": "transferSpeedGraph",
  "banner": {
    "text": "Security update — install now",
    "backColor": "#8B0000",
    "backColor2": "#FF4500",
    "foreColor": "#FFFFFF",
    "imageUrl": "https://example.com/icon.png"
  },
  "pulse": {
    "enable": true,
    "color": "#FF4500",
    "style": "All",
    "speed": 1.5
  }
}
```

`maximumPostponeDays`, `allowPostpone`, `allowSkip`, `allowResume`, `allowRetry`, and `progressDisplay` are optional. On a `{ "packages": [ ... ] }` file they may sit on the root, and a package value replaces the root value. Omit `maximumPostponeDays` for 365. Omit `allowPostpone` or `allowSkip` and a critical package cannot use that action, while every other severity can. `true` allows it, including on a critical package. `false` blocks it. Omit `allowResume` or `allowRetry` and Resume or Restart stays available. `allowRetry` false hides Restart. Omit `progressDisplay` to use `KryptonApplicationUpdater.ProgressDisplay`. Values are `progressBar` and `transferSpeedGraph` (case-insensitive).

### Banner and pulse

Optional nested `banner` and `pulse` objects. On a packages file they may sit on the root; a package object replaces the whole root object (no field-level merge). Omit an object to leave that feature off.

| Object | Windows | Behaviour |
|--------|---------|-----------|
| `banner` | Prompt, notes | Top strip when `text` and/or `imageUrl` is set. Colours are `#RRGGBB` or `#AARRGGBB`. `backColor` alone is a solid fill; set `backColor2` for a left-to-right linear gradient. `imageUrl` is https or a local path (http is rejected). A failed image load hides the icon and keeps the text. |
| `pulse` | Prompt, notes, progress | Form chrome via `KryptonForm.PulsingBorderValues`. `enable` defaults to false when the object is present without it. `style` is `All` (default) or `Bottom`. `speed` defaults to 1. Show-when is always `Always` and animate is always on (not in JSON). |

Public types: `KryptonUpdateBanner` and `KryptonUpdatePulse` on `KryptonUpdatePackage`. Helpers: `KryptonUpdatePresentation.ApplyBanner`, `ApplyPulse`, and `LoadBannerImageAsync`.

`packageKind` is `installer` or `archive`. A local `packageUrl` is accepted so an offline manifest can point at a local file. Remote feed and package addresses must be `https`. Redirects are followed only while the next address is still `https`.

SHA-256 is required. The compare is constant-time and always covers the whole file, including a file that was resumed. When `certificateThumbprint` is set, the downloaded file must be Authenticode-signed and the thumbprint must match. A mismatch deletes the file.

## Download

The progress window keeps one temp file for the attempt. The first transfer and Restart replace that file. Resume, when the file already has bytes, sends `Range: bytes=<length>-`.

- `206` appends. The bar counts the bytes already on disk plus the new bytes. The total comes from `Content-Range` when the server sends it.
- `200`, `416`, or a gzip, deflate, or brotli range response replaces the file. The status line says the download is starting again. A compressed range would not line up with the bytes already saved.
- A dropped connection or Cancel keeps the partial file. The window stays open. Resume is shown when a partial remote file remains and `allowResume` is not false. Restart is shown when `allowRetry` is not false. A local file has no range request, so Resume stays hidden. A hash or thumbprint failure has already deleted the file, so Resume stays hidden.
- Close leaves the update. Close after Cancel is `Cancelled`. Close after a failure raises `Failed` once. `Failed` is not raised while Resume or Restart is still available.

`DownloadAsync` is still one shot: it deletes its own temp file on failure and does not offer Resume or Restart. `Strings` includes `Resume`, `Restart`, `DownloadInterrupted`, and `DownloadRestarting`.

### Progress chrome

The progress window binds `package.ProgressDisplay ?? updater.ProgressDisplay`:

| Mode | UI |
|------|----|
| `ProgressBar` (default) | Continuous percent when the total length is known; marquee when it is not |
| `TransferSpeedGraph` | Hosts public `KryptonTransferProgressPanel`: scrolling speed chart plus an optional progress chart (`SetProgress` / `AddSample`). Size and ETA stay in Details |

The panel default `ChartLayout` is `SideBySide` (separate speed and progress columns). `DualSeries` paints both series on one `KryptonTransferDualGraph` chart; the updater does not switch to that layout (no extra `KryptonUpdateProgressDisplay` value). Speed colours use `PaletteElement.TransferSpeedGraph` / `SchemeBaseColors.TransferSpeedGraph*`; progress colours use `TransferProgressGraph`. The progress form sets graph capacity to 60 samples. `ProgressSampleMode` defaults to `Auto` (percent when total is known, otherwise bytes).

Details starts folded. The Details button lives on the docked button strip with Cancel (and Resume / Restart / Close in recovery). Opening Details expands a panel **below** that strip and grows the form by the same height. The panel shows the file name, bytes received and total, speed, and time remaining. Speed is the change since the previous progress sample (and drives `AddSample` in graph mode). An unknown length or a zero rate shows Unknown. Resume keeps counting bytes already on disk. Details stays available after the transfer stops.

GitHub: `GET https://api.github.com/repos/{owner}/{repo}/releases/latest` with a User-Agent. An asset named `krypton-update.json` uses the schema above. A `packageUrl` that is not `https` and not a local path is treated as an asset name on that release. Without that manifest, the provider maps the tag, the body, and one asset (`GitHubAssetName`, otherwise the single `.exe`, `.msi`, or `.zip`). The hash comes from the manifest, otherwise the asset `digest` (`sha256:`). If neither exists, the check fails and nothing is applied.

## Apply

`installer`: `.msi` starts through `msiexec /i`. Anything else starts directly, with `installerArguments` when the manifest set them.

`archive`: the component writes a job file, extracts the embedded helper, and starts it. When `ExitApplicationOnApply` is true the helper waits for this process, rejects zip entries that escape `InstallDirectory` (zip-slip), extracts, and starts `RestartCommand`. When it is false, the helper does not wait and does not restart, and the component waits for the helper to finish. The TestForm demo sets `ExitApplicationOnApply` to false and points `InstallDirectory` at a temp folder.

## Manifest editor

`Source/TestHarnesses/UpdateManifestEditor` is a maintainer WinForms app for the JSON file above. It is registered in the suite solution under Testing and is not packed. It does not reference `Krypton.Toolkit.Utilities`; the parser there stays internal.

One window lists packages. The selected row edits version (`System.Version`; a leading `v` is stripped when the file is written), severity, package kind, the local package file, the published package URL, SHA-256, an optional Authenticode thumbprint, installer arguments, release notes, released UTC, maximum postpone days, postpone, skip, resume, and retry (default, allow, or block), plus optional banner text / back / back 2 / fore / image URL and pulse enable / colour / style / speed. Retry controls the Restart button. Banner back 2 is the gradient end colour.

The package file is used only to hash the bytes and, when the file is Authenticode-signed, to read the certificate thumbprint. Browsing a `.zip` selects `archive`; any other file selects `installer`. The combo can override that. Browsing fills `packageUrl` with the local path only when that box is still empty. A published feed should replace the path with `https`. A remote value must be `https`. A local path is allowed.

Save writes one JSON object when the list has one package, and `{ "packages": [ ... ] }` when it has more. Empty optional fields are omitted. Open accepts either shape. The save dialog defaults to `krypton-update.json`. Copy places the same JSON on the clipboard. Save is blocked until every package has a parseable version, a package URL, and a 64-character hex SHA-256.
