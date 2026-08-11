# Async Form and Dialog Methods

## Overview

Windows Forms added asynchronous form APIs in .NET 9 (`Form.ShowAsync`, `Form.ShowDialogAsync`) and made them stable in .NET 10. `KryptonForm` / `VisualForm` inherit those methods on `net9.0-windows` and newer. This guide covers the **Krypton wrappers** that expose matching `*Async` entry points for static/instance dialog helpers that previously only called synchronous `ShowDialog()`.

**Package ownership:** `Krypton.Toolkit` (core dialogs) and `Krypton.Toolkit.Utilities` (Extended message box, foldable dialog, AboutBox, exception / checksum / GitHub / toast / OAuth2 helpers).

## Architecture

```
Consumer async method
        │
        ▼
Krypton* .ShowAsync / ShowDialogAsync   (#if NET9_0_OR_GREATER)
        │
        ▼
underlying Form.ShowDialogAsync / ShowAsync   (Form-hosted / custom shell)
   or nested-modal ShowDialog wrapped as Task  (native shell / CommonDialog)
        │
        ▼
Task completes when the dialog is closed or disposed
```

Sync overloads remain unchanged on all TFMs. Async overloads are compiled only for `NET9_0_OR_GREATER`.

On .NET 9 the WinForms APIs are experimental (`WFO5002`); Krypton projects suppress that diagnostic when calling into WinForms. On .NET 10+ the APIs are stable. Consumer apps targeting net9 that call `Form.ShowAsync` directly may still need `<NoWarn>WFO5002</NoWarn>`.

## Public API (Toolkit)

| Type | Async surface |
|------|----------------|
| `KryptonForm` / `VisualForm` | Inherited `ShowAsync` / `ShowDialogAsync` |
| `KryptonMessageBox` | `ShowAsync(...)` mirroring sync `Show` overloads |
| `KryptonTaskDialog` | `ShowAsync(owner)`, `ShowDialogAsync(owner)` |
| `KryptonInputBox` | `ShowAsync(KryptonInputBoxData)` |
| `KryptonPrintPreviewDialog` | `ShowDialogAsync()` / `ShowDialogAsync(owner)` — Form-based |
| `KryptonColorDialog` / `KryptonFontDialog` / `KryptonPrintDialog` | `ShowDialogAsync()` / `ShowDialogAsync(owner)` — nested-modal ComDlg wrappers |
| `KryptonSplashScreen` | `ShowAsync(KryptonSplashScreenData)` (modal data path) |
| `KryptonMultilineStringEditor` | `ShowAsync(...)` mirroring sync `Show` |
| `KryptonThemeBrowser` | `ShowAsync(...)` |
| `KryptonStringCollectionEditor` | `ShowAsync(...)` / `ShowDialogAsync(...)` |
| `KryptonExceptionDialog` (internal) | `ShowAsync(...)` — use Utilities for public API |
| `KryptonPoweredByButton` | `ShowBinaryInformationAsync(...)` (click path remains sync) |
| `KryptonGitHubIssueReportDialog` | `ShowAsync(...)` |
| `ShellDialogWrapper` | `ShowDialogAsync()` / `ShowDialogAsync(owner)` — see Shell notes |
| `KryptonFormFadeController` | Timer-based fade; `ShowDialog` (all TFMs) + `ShowDialogAsync` (net9+) |

## Public API (Utilities)

| Type | Async surface |
|------|----------------|
| `KryptonMessageBoxExtended` | Prefer **`ShowAsync(KryptonMessageBoxExtendedData)`**; other overloads exist but can be ambiguous |
| `KryptonFoldableDialog` | `ShowAsync(...)` mirroring sync `Show` |
| `KryptonAboutBox` | `ShowAsync(...)` mirroring sync `Show` |
| `KryptonExceptionDialog` | **Public** `ShowAsync(...)` (preferred over Toolkit internal) |
| `KryptonComputeFileCheckSum` / `KryptonVerifyFileCheckSum` | `ShowAsync(...)` |
| `KryptonGitHubIssueReportDialog` | `ShowAsync(...)` |
| `KryptonBugReportingDialog` | `ShowAsync(...)` |
| `KryptonOAuth2Login` | Existing `ShowAsync` now uses Form `ShowDialogAsync` / `ShowAsync` on net9+ |
| `KryptonToast` | Basic + user-input `Show*Async` / `ShowNotificationAsync` / `ShowNotificationWithProgressBarAsync` (LTR/RTL × with/without progress bar) |

## Shell / CommonDialog notes

| Surface | Behaviour |
|---------|-----------|
| Shell **Custom** | Real `Form.ShowDialogAsync` on `VisualCustomFileDialogForm` |
| Shell **Native** | Awaitable wrapper around nested-modal `ShowDialog` — UI thread blocked until closed |
| Color / Font / Print | Same nested-modal pattern (`Task.FromResult(ShowDialog(...))`); WinForms `CommonDialog` has no native async API |
| PrintPreview | Form-hosted — real `ShowDialogAsync` |

## Fade controller

`KryptonFormFadeController` uses a WinForms `Timer` (~10 ms) for opacity steps (no `Thread.Sleep`):

- **All TFMs:** `ShowDialog` starts the fade timer, then calls sync `Form.ShowDialog` so ticks run inside the nested modal pump.
- **net9+:** `ShowDialogAsync` starts the same timer and awaits `Form.ShowDialogAsync`.
- Modeless `FadeIn` / `FadeOut` / `FadeOutAndClose` / `ModernFadeForm*` share the timer engine.
- `FadeValues` / `VisualForm` integration remains disabled until re-enabled separately.

## Intentionally unchanged

| Area | Reason |
|------|--------|
| Toolkit `KryptonExceptionDialog` publicity | Stays **internal** to avoid short-name collision with Utilities; public consumers use Utilities. |

## Consumer guidance

1. **Await on the UI thread.** Call `await` from a WinForms event handler (or other UI-context code). Prefer default `ConfigureAwait(true)`.
2. **Always prefer Extended data overload.** Several `KryptonMessageBoxExtended.Show` / `ShowAsync` overloads differ only by optional parameters and are ambiguous. Default sample:

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
4. **Dispose after await.** Message-box style helpers dispose the temporary form when `ShowDialogAsync` completes.
5. **Owner nullability.** When `owner` may be null, wrappers call parameterless `ShowDialogAsync()`.
6. **Native shell / Color / Font / Print:** `ShowDialogAsync` is convenient for `async` call sites but does not free the UI thread.

## Usage

```csharp
#if NET9_0_OR_GREATER
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
#endif
```
