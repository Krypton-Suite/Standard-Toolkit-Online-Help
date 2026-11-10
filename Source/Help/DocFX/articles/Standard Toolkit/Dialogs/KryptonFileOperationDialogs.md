# Krypton file-operation dialogs

`Krypton.Dialogs` replaces Explorer's progress, name-conflict, and delete windows for copy, move, rename, and delete that an application starts itself. Explorer and every other process keep the Windows dialogs. There is no shell hook.

The assembly is not published on its own. It is packed into [Krypton.Standard.Toolkit](https://www.nuget.org/packages/Krypton.Standard.Toolkit). Toolkit must not reference it.

## Architecture

```
App
  KryptonFileOperation          queue, preflight, events
    KryptonFileConflictDialog
    KryptonDeleteConfirmationDialog
    KryptonPermanentDeleteDialog
    VisualFileOperationProgressForm     UI thread
      OperationsProgressDialog           IOperationsProgressDialog, worker STA
    FileOperationRunner                  IFileOperation, worker STA
```

`Perform` must be called on an STA thread, normally the WinForms UI thread. It throws `InvalidOperationException` otherwise. The progress form is created on that thread and its handle exists before the worker starts. `IFileOperation` is created on a dedicated STA thread named `KryptonFileOperation`, so `PerformOperations` does not block the message pump. Progress snapshots are posted with `BeginInvoke`. `GetOperationStatus` only reads a volatile flag.

The shell calls `StartProgressDialog` when it wants the window. Fast batches can finish before the window is worth looking at. `FOF_SILENT` is not set, because that suppresses the progress dialog. `FOF_NOERRORUI` is set, so per-item failures come through the `Error` event and the progress window instead of a shell message box. Elevation still uses the Windows UAC prompt (`FOFX_SHOWELEVATIONPROMPT`).

## Why prompts run before the shell call

`IFileOperationProgressSink.PreCopyItem` cannot skip one file. Any failure cancels the whole batch. `FOF_NOCONFIRMATION` answers Yes to every shell prompt, and `FOF_WANTNUKEWARNING` still forces the permanent-delete warning even when confirmation is off.

`KryptonFileOperation` therefore shows the conflict and delete dialogs first and queues only the chosen items. `PerformOperations` then uses `FOF_NOCONFIRMATION | FOF_NOCONFIRMMKDIR | FOF_NOERRORUI`. Recycle also sets `FOF_ALLOWUNDO | FOFX_RECYCLEONDELETE`. Permanent delete omits both `FOF_ALLOWUNDO` and `FOF_WANTNUKEWARNING`.

A batch that mixes recycle with permanent delete runs as two passes. The undoable pass goes first. Cancel on that pass does not run the permanent pass.

Name collisions inside a folder that was queued as one item are not preflighted. Those follow `FOF_NOCONFIRMATION`.

## Public API

```csharp
public sealed class KryptonFileOperation : IDisposable
{
    public KryptonFileOperationStrings Strings { get; }
    public IWin32Window? Owner { get; set; }
    public bool ShowBanners { get; set; } // default true

    public event EventHandler<KryptonFileDeleteConfirmEventArgs>? ConfirmDelete;
    public event EventHandler<KryptonFileDeleteConfirmEventArgs>? ConfirmPermanentDelete;
    public event EventHandler<KryptonFileConflictEventArgs>? FileConflict;
    public event EventHandler<KryptonFileOperationErrorEventArgs>? Error;

    public void QueueCopy(string sourcePath, string destinationDirectory, string? newName = null);
    public void QueueMove(string sourcePath, string destinationDirectory, string? newName = null);
    public void QueueRename(string path, string newName);
    public void QueueDelete(string path, bool recycle);

    public bool Copy(string sourcePath, string destinationDirectory, string? newName = null);
    public bool Move(string sourcePath, string destinationDirectory, string? newName = null);
    public bool Rename(string path, string newName);
    public bool Delete(string path, bool recycle);

    public bool Perform();
}
```

A null or empty `newName` keeps the source name. The convenience methods queue one item and then call `Perform`, which also runs anything already queued. `Perform` returns false when the user cancels or any item reports an error. It returns true when every item is skipped or the shell finishes the batch.

`KryptonFileOperation` and the confirmation dialogs are `[ToolboxItem(false)]`. The speed graph lives in Utilities and is `[ToolboxItem(true)]`.

### Preflight

- Copy, move, or rename onto an existing name shows `KryptonFileConflictDialog`: Replace, Skip, Keep both, or Cancel, plus "do this for the remaining conflicts".
- Skip does not queue the item. Replace queues the original name. Keep both queues `Name (2).ext`, then `(3)`, and so on, skipping names that already exist or were reserved earlier in the same `Perform`.
- A missing source reports `Error` and continues with the rest of the batch.
- The same path as both source and destination reports `Error` and does not queue.
- `QueueDelete(..., recycle: true)` asks once for the whole recycle batch, then queues those items.
- `QueueDelete(..., recycle: false)` asks once with `KryptonPermanentDeleteDialog`.
- Cancel at any prompt returns before `PerformOperations`.

### Replacing a prompt

Set `Handled` on `ConfirmDelete`, `ConfirmPermanentDelete`, or `FileConflict` to skip the stock dialog.

- Delete: `Handled` plus `Confirmed` continues. `Handled` plus `Cancel` stops the batch.
- Conflict: `Handled` plus `Choice` (`Replace`, `Skip`, `KeepBoth`, `Cancel`). `ApplyToRemaining` reuses that choice for later collisions in the same `Perform`.

`Error` is informational. `FOF_NOERRORUI` is set, so the shell will not show its own error UI. The progress window shows `KryptonFileOperationErrorEventArgs.Message`.

### Strings

`KryptonFileOperationStrings` holds the dialog text (`Copying`, `Moving`, `Deleting`, `Recycling`, `Renaming`, `CopyingAndMoving`, button labels, and the conflict and delete sentences). `IsDefault` and `Reset` match the other Krypton string stores. The text is not on `KryptonManager.Strings`, because Toolkit does not reference this assembly.

### Progress window

One window, titled from the shell verb (`Copying`, `Moving`, `Deleting`, `Renaming`, `Copying and moving` for a cross-volume move). Each dialog can show a Windows-style top banner (status icon + bold main instruction) and a bottom `PanelAlternate` button bar. Set `KryptonFileOperation.ShowBanners` (default `true`) or pass `showBanner` to the standalone dialog `Show` methods. When banners are off, the instruction text moves into the body. Progress shows the current item, from, to, a `KryptonProgressBar` (or speed graph when expanded), item and byte counts, speed, and time remaining. Preflight and indeterminate mode use a marquee and "Calculating…". Conflict uses a warning icon with the conflict intro in the banner; recycle uses a question icon and permanent delete a warning icon.

**More details / Fewer details** swaps the progress indicator: collapsed shows the `KryptonProgressBar`; expanded hides the bar and shows a theme-aware [`KryptonTransferSpeedGraph`](Source/Krypton Components/Krypton.Toolkit.Utilities/Components/Krypton Transfer Speed Graph/Controls Toolkit/KryptonTransferSpeedGraph.cs) from `Krypton.Toolkit.Utilities` in the same slot. Samples are pushed only while expanded and while progress is determinate. Collapse restores the bar and keeps the sample window so re-expand still shows recent history. The hosted instance uses `Values.Capacity = 60` for a denser short window. Chart colours come from the current global palette (back, border, fill, text), not from Explorer's fixed dark/green look.

`KryptonTransferSpeedGraph` is a public Toolbox control in Utilities (`[ToolboxItem(true)]`), not in `Krypton.Dialogs`. Apps can host it on their own forms. Call `AddSample(bytesPerSecond)`, `Clear()`, `Pause()` / `Resume()` (or `Values.Paused`), and set behaviour under expandable `Values` (`Capacity`, `Paused`, `ShowSpeedLabel`, `SpeedLabelFormat`). While paused, `AddSample` is ignored and the chart stays frozen. The progress dialog Pause / Resume button drives the graph the same way. Appearance uses the usual `StateCommon` / `StateNormal` / `StateDisabled` triple (panel back, control border, label content). Series fill prefers `State*.Back.Color2` when set; otherwise it uses the standalone-button checked colour from the active palette.

Pause is shown only when the shell passes `OPPROGDLG_ENABLEPAUSE`. Cancel is always available. Closing the window is treated as Cancel while the operation is running. `GetOperationStatus` returns running, paused, or cancelled from those buttons. `PauseTimer`, `ResumeTimer`, and `ResetTimer` freeze or restart the estimate.

### Standalone dialogs

The three prompts can be shown without an operation:

- `KryptonFileConflictDialog.Show(owner, source, destination, strings, out applyToRemaining, showBanner = true)` returns `KryptonFileConflictChoice`.
- `KryptonDeleteConfirmationDialog.Show(owner, paths, strings, showBanner = true)` returns `DialogResult`.
- `KryptonPermanentDeleteDialog.Show(owner, paths, strings, showBanner = true)` returns `DialogResult`.

Pass null `strings` to use the factory text. Pass `showBanner: false` to hide the icon banner (same as `KryptonFileOperation.ShowBanners = false`).

## Usage

```csharp
using (var operation = new KryptonFileOperation { Owner = this /*, ShowBanners = false */ })
{
    operation.FileConflict += (sender, args) =>
    {
        args.Handled = true;
        args.Choice = KryptonFileConflictChoice.KeepBoth;
        args.ApplyToRemaining = true;
    };

    operation.QueueCopy(sourceFile, destinationDirectory);
    operation.QueueDelete(oldFile, recycle: true);
    if (!operation.Perform())
    {
        // Cancelled, or Error was raised for a failed item.
    }
}
```

## Edge cases

- Call `Perform` on the UI STA thread. A background thread, including an MTA worker, throws `InvalidOperationException`.
- Do not call `Perform` again on the same instance until it returns. Queue methods throw `InvalidOperationException` while a batch is running.
- Dispose sets the progress status to cancelled and drops the queue. It does not abort a `Perform` that is already inside `PerformOperations` except by that status, which the shell reads on its next `GetOperationStatus`.
- UAC is the Windows elevation prompt. These dialogs do not replace it.
- The COM interfaces (`IFileOperation`, `IOperationsProgressDialog`, `IFileOperationProgressSink`, `IShellItem`) stay internal to `Krypton.Dialogs`.
