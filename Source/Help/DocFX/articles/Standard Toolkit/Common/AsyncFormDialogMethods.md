# Async Form and Dialog Methods

## Overview

Windows Forms added asynchronous form APIs in .NET 9 (`Form.ShowAsync`, `Form.ShowDialogAsync`) and made them stable in .NET 10. Krypton exposes matching `*Async` entry points on **all supported TFMs** (including `net472`).

On .NET 9+, wrappers call the real WinForms APIs via internal `KryptonFormAsync`. On earlier TFMs, the same public methods degrade to synchronous `ShowDialog` / `Show` (modal wrapped as `Task.FromResult`; modeless via `FormClosed` + `TaskCompletionSource`). Consumers write one `await` call site regardless of TFM.

**Package ownership:** `Krypton.Toolkit` (core dialogs) and `Krypton.Toolkit.Utilities` (Extended message box, foldable dialog, AboutBox, exception / checksum / GitHub / toast / OAuth2 helpers).

Library continuations use **`ConfigureAwait(false)`**. Callers that touch UI after `await` should resume on the UI context (WinForms event handlers usually already do).

## Architecture

```
Consumer await ShowAsync / ShowDialogAsync   (all TFMs)
        │
        ▼
Krypton* wrapper
        │
        ▼
KryptonFormAsync.ShowDialogAsync / ShowAsync
        │
        ├── NET9+ : Form.ShowDialogAsync / Form.ShowAsync
        └── earlier: sync ShowDialog / Show + Task complete
```

Sync overloads remain unchanged on all TFMs. Async overloads are always compiled; only the Form call inside `KryptonFormAsync` is TFM-specific.

On .NET 9 the WinForms APIs are experimental (`WFO5002`); Krypton projects suppress that diagnostic. Consumer apps targeting net9 that call `Form.ShowAsync` directly may still need `<NoWarn>WFO5002</NoWarn>`.

## Public API (Toolkit)

| Type | Async surface |
|------|----------------|
| `KryptonForm` / `VisualForm` | Inherited Form async on net9+ only |
| `KryptonMessageBox` | `ShowAsync(...)` mirroring sync `Show` — **all TFMs** |
| `KryptonTaskDialog` | `ShowAsync(owner)`, `ShowDialogAsync(owner)` |
| `KryptonInputBox` | `ShowAsync(KryptonInputBoxData)` |
| `KryptonPrintPreviewDialog` | `ShowDialogAsync()` / `ShowDialogAsync(owner)` — Form-hosted |
| `KryptonColorDialog` / `KryptonFontDialog` / `KryptonPrintDialog` | `ShowDialogAsync()` / `ShowDialogAsync(owner)` — nested-modal ComDlg |
| `KryptonSplashScreen` | `ShowAsync(KryptonSplashScreenData)` (modal data path) |
| `KryptonMultilineStringEditor` | `ShowAsync(...)` mirroring sync `Show` |
| `KryptonThemeBrowser` | `ShowAsync(...)` |
| `KryptonStringCollectionEditor` | `ShowAsync(...)` / `ShowDialogAsync(...)` |
| `KryptonExceptionDialog` (internal) | `ShowAsync(...)` — use Utilities for public API |
| `KryptonPoweredByButton` | `ShowBinaryInformationAsync(...)` (click path remains sync) |
| `KryptonGitHubIssueReportDialog` | `ShowAsync(...)` |
| `ShellDialogWrapper` | `ShowDialogAsync()` / `ShowDialogAsync(owner)` |
| `KryptonFormFadeController` | Timer-based fade; `ShowDialog` / `ShowDialogAsync` on **all TFMs** |

## Public API (Utilities)

| Type | Async surface |
|------|----------------|
| `KryptonMessageBoxExtended` | Prefer **`ShowAsync(KryptonMessageBoxExtendedData)`** |
| `KryptonFoldableDialog` | `ShowAsync(...)` mirroring sync `Show` |
| `KryptonAboutBox` | `ShowAsync(...)` mirroring sync `Show` |
| `KryptonExceptionDialog` | **Public** `ShowAsync(...)` (preferred over Toolkit internal) |
| `KryptonComputeFileCheckSum` / `KryptonVerifyFileCheckSum` | `ShowAsync(...)` |
| `KryptonGitHubIssueReportDialog` | `ShowAsync(...)` |
| `KryptonBugReportingDialog` | `ShowAsync(...)` |
| `KryptonOAuth2Login` | `ShowAsync` uses `KryptonFormAsync` (Form async on net9+; sync degrade earlier) |
| `KryptonToast` | Basic + user-input `Show*Async` / `ShowNotificationAsync` / `ShowNotificationWithProgressBarAsync` (LTR/RTL × with/without progress bar) |

## Shell / CommonDialog / degrade notes

| Surface | .NET 9+ | Earlier TFMs |
|---------|---------|--------------|
| Form-hosted dialogs | Real `ShowDialogAsync` | Sync `ShowDialog` under await |
| Shell **Custom** | Form async on `VisualCustomFileDialogForm` | Sync degrade |
| Shell **Native** / Color / Font / Print | Nested-modal `Task.FromResult(ShowDialog)` | Same |
| PrintPreview | Form-hosted async | Sync degrade |

## Fade controller

`KryptonFormFadeController` uses a WinForms `Timer` (~10 ms) for opacity steps (no `Thread.Sleep`):

- `ShowDialog` / `ShowDialogAsync` available on all TFMs; modal path uses `KryptonFormAsync`.
- Modeless `FadeIn` / `FadeOut` / `FadeOutAndClose` / `ModernFadeForm*` share the timer engine.
- `FadeValues` / `VisualForm` integration remains disabled until re-enabled separately.

## Intentionally unchanged

| Area | Reason |
|------|--------|
| Toolkit `KryptonExceptionDialog` publicity | Stays **internal** to avoid short-name collision with Utilities; public consumers use Utilities. |

## Consumer guidance

1. **Call from UI context when you need UI after await.** Library code uses `ConfigureAwait(false)`.
2. **Always prefer Extended data overload** to avoid ambiguous optional-parameter overloads:

```csharp
await KryptonMessageBoxExtended.ShowAsync(new KryptonMessageBoxExtendedData
{
    Owner = this,
    MessageText = "Save changes?",
    Caption = "Confirm",
    Buttons = ExtendedMessageBoxButtons.YesNo,
    Icon = ExtendedKryptonMessageBoxIcon.Question
});
```

3. **Public exception dialogs:** use `Krypton.Toolkit.Utilities.KryptonExceptionDialog`, not the Toolkit internal type.
4. **Dispose after await.** Message-box style helpers dispose the temporary form when the dialog completes.
5. **Owner nullability.** When `owner` may be null, wrappers use the parameterless / null-owner helper path.
6. **Native shell / Color / Font / Print:** `ShowDialogAsync` is convenient for `async` call sites but does not free the UI thread.
7. **Pre-.NET 9:** awaitable APIs are present but modal paths still block via sync `ShowDialog` under the helper.

## Usage

```csharp
DialogResult result = await KryptonMessageBox.ShowAsync(
    this,
    "Save changes?",
    "Confirm",
    KryptonMessageBoxButtons.YesNo,
    KryptonMessageBoxIcon.Question);

await KryptonMessageBoxExtended.ShowAsync(new KryptonMessageBoxExtendedData
{
    Owner = this,
    MessageText = "…",
    Caption = "…",
    Buttons = ExtendedMessageBoxButtons.OKCancel,
    Icon = ExtendedKryptonMessageBoxIcon.Information
});

using var ofd = new KryptonOpenFileDialog { ProviderMode = KryptonDialogProviderMode.Custom };
DialogResult fileResult = await ofd.ShowDialogAsync(this);

using var color = new KryptonColorDialog();
DialogResult colorResult = await color.ShowDialogAsync(this); // nested-modal

object input = await KryptonToast.ShowNotificationAsync(new KryptonUserInputToastData
{
    ToastHost = this,
    NotificationTitle = "Name",
    NotificationContent = "Enter a value:",
    NotificationInputAreaType = KryptonToastInputAreaType.TextBox,
    CountDownSeconds = 60
});
```
