# Krypton Dialog Providers Developer Guide

## Overview

Issue [#1231](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1231) introduced a provider model for `KryptonOpenFileDialog`, `KryptonSaveFileDialog`, and `KryptonFolderBrowserDialog`.

The existing implementation still supports the native shell-wrapper path, but the dialog wrappers can now switch to a fully managed Krypton-backed implementation through `KryptonDialogProviderMode`. This gives applications an escape hatch on machines where the native shell dialog path flickers or performs poorly.

## Architecture

The provider model keeps the public dialog components as the stable API surface:

- `KryptonOpenFileDialog`
- `KryptonSaveFileDialog`
- `KryptonFolderBrowserDialog`

Each wrapper now builds an internal `KryptonDialogOptions` instance, passes it to a provider selected by `ShellDialogWrapper.ProviderMode`, and applies the returned `KryptonDialogResult` back onto the wrapper state.

Core types:

- `Source/Krypton Components/Krypton.Toolkit/Dialogs/KryptonDialogProviders.cs`
  - `KryptonDialogProviderMode`
  - `KryptonDialogOptions`
  - `KryptonDialogResult`
  - `KryptonDialogProviderContext`
  - `IKryptonDialogProvider`
  - `NativeKryptonDialogProvider`
  - `CustomKryptonDialogProvider`
- `Source/Krypton Components/Krypton.Toolkit/Controls Visuals/VisualCustomFileDialogForm.cs`
  - Managed MVP dialog host used by the custom provider (`VisualCustomFileDialogForm.Designer.cs` holds the WinForms layout; address navigation uses `KryptonBreadCrumb`)

The native path still uses the existing shell-dialog hook stack:

- `ShellDialogWrapper`
- `CommonDialogHandler`
- `FileSaveDialogWrapper`
- `ShellBrowserDialogTFM`

That behavior is now wrapped by `NativeKryptonDialogProvider` rather than being the only implementation.

## Public API

The new public surface is a single property on `ShellDialogWrapper`:

```csharp
public KryptonDialogProviderMode ProviderMode { get; set; }
```

Values:

- `KryptonDialogProviderMode.Native`
  - Default behavior. Uses the existing native shell wrapper pipeline.
- `KryptonDialogProviderMode.Custom`
  - Uses the managed Krypton implementation.

Because the wrapper components remain the public entry point, existing code can switch implementations without changing call sites or designer usage patterns.

## Usage

### Open dialog

```csharp
using var dialog = new KryptonOpenFileDialog
{
    ProviderMode = KryptonDialogProviderMode.Custom,
    Title = "Open project file",
    InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
    Filter = "Project Files (*.kproj)|*.kproj|All Files (*.*)|*.*"
};

if (dialog.ShowDialog() == DialogResult.OK)
{
    string fileName = dialog.FileName;
}
```

### Save dialog

```csharp
using var dialog = new KryptonSaveFileDialog
{
    ProviderMode = KryptonDialogProviderMode.Custom,
    FileName = "output.txt",
    Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*",
    AddExtension = true,
    DefaultExt = "txt"
};
```

### Folder dialog

```csharp
using var dialog = new KryptonFolderBrowserDialog
{
    ProviderMode = KryptonDialogProviderMode.Custom,
    Title = "Select working folder",
    SelectedPath = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments)
};
```

## Custom Provider MVP Scope

The managed dialog intentionally ships as an MVP rather than an Explorer clone.

Included:

- Left navigation for common places and ready drives
- Main file list with directory navigation
- Path textbox with manual navigation
- Open/save/folder modes
- File name textbox
- Filter selection
- Overwrite and create prompts for save scenarios
- `FileOk` event participation for open/save wrappers

Deferred:

- Full shell namespace browsing
- Explorer breadcrumb bar
- Thumbnails and shell metadata columns
- Virtual folders
- Native custom places parity
- Managed multi-select parity

## State Flow

1. Consumer code configures a wrapper component.
2. `ShellDialogWrapper.ShowDialog()` builds `KryptonDialogOptions`.
3. The provider factory selects either the native or custom provider.
4. The provider returns `KryptonDialogResult`.
5. The wrapper applies that result back to its existing properties so callers keep using the same API.

For open/save dialogs, `FileDialogWrapper` now owns the `FileOk` event relay so both providers can participate in the same validation step.

## Notes For Maintainers

- Keep `ProviderMode` defaulted to `Native` unless the project intentionally changes its compatibility stance.
- Preserve the wrapper components as the canonical public API surface; new provider behavior should stay behind them.
- If custom-dialog parity grows, prefer adding to `KryptonDialogOptions` / `KryptonDialogResult` instead of reaching back into wrapper-specific implementation details.
- Avoid leaking `CommonDialogHandler` assumptions into the custom path; the managed provider should stay independent of native HWND interception.
