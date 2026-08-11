# KryptonFoldableDialog Developer Guide

## Overview

`KryptonFoldableDialog` is a message-box style dialog with a collapsible ("foldable")
details region, modelled on the Visual Studio *Just-In-Time* debugger dialog. It presents
an icon, a bold heading (main instruction), a descriptive message, and a set of action
buttons. When details text is supplied, an expander control folds an additional details
region in and out, growing or shrinking the dialog to match.

* **Problem solved:** a themed, palette-aware dialog for scenarios where a short summary
  should be shown by default but full detail (a stack trace, diagnostic dump, log excerpt,
  terms text, etc.) must be available on demand — without a separate window.
* **Scope:** a single modal dialog exposed through a static `Show` API plus a data object.
* **Owning package:** `Krypton.Toolkit.Utilities` (assembly `Krypton.Toolkit.Utilities`,
  shipped in the `Krypton.Standard.Toolkit` NuGet package).

## Architecture

The feature follows the same split used by other `Krypton.Toolkit.Utilities` dialogs
(for example `KryptonAboutBox` / `VisualAboutBoxForm` and
`KryptonExceptionDialog` / `VisualExceptionDialogForm`):

| Type | Role |
| --- | --- |
| `KryptonFoldableDialog` (public, static) | Public entry point. Provides `Show` overloads and forwards to the visual form. |
| `KryptonFoldableDialogData` (public) | Plain data object describing the dialog content and behaviour. |
| `VisualFoldableDialogForm` (internal, `KryptonForm`) | The visual host that renders the dialog, maps the icon, builds the button strip, and performs the fold/resize logic. |

Control tree of `VisualFoldableDialogForm`:

```
KryptonForm (FixedDialog, no min/max box)
├─ kpnlMain (KryptonPanel, Dock = Fill)
│  ├─ kpnlDetails (KryptonPanel, Dock = Fill)      // foldable region, hidden when collapsed
│  │  └─ krtbDetails (KryptonRichTextBox, read-only)
│  └─ tlpHeader (TableLayoutPanel, Dock = Top, AutoSize)
│     ├─ pbxIcon (PictureBox, RowSpan = 2)
│     ├─ kwlHeading (KryptonWrapLabel, TitleControl)
│     └─ kwlMessage (KryptonWrapLabel, NormalControl)
└─ kpnlButtons (KryptonPanel, Dock = Bottom)
   ├─ kbrdEdge (KryptonBorderEdge, Dock = Top)
   └─ tlpButtons (TableLayoutPanel)
      ├─ kbtnExpander (KryptonButton, LowProfile, left-aligned)
      └─ kbtnButton1 / kbtnButton2 / kbtnButton3 (right-aligned action buttons)
```

### Sizing / fold behaviour

* The header (`tlpHeader`) is auto-sized; the two `KryptonWrapLabel`s wrap within the fixed
  form width and report their height back to the layout.
* On `OnLoad`, `PerformLayout()` runs so the header height is final, then
  `ApplyExpandState` computes the client height as
  `tlpHeader.Height + kpnlButtons.Height + (expanded ? DETAILS_REGION_HEIGHT : 0)`.
* `DETAILS_REGION_HEIGHT` (180 logical px) is scaled for DPI via
  `Control.LogicalToDeviceUnits`.
* Clicking the expander toggles `kpnlDetails.Visible` and re-applies the state, so the
  form grows/shrinks in place.

### Buttons

`VisualFoldableDialogForm` maps `KryptonMessageBoxButtons` to an ordered list of
`(caption, DialogResult)` pairs using the localised captions from
`KryptonManager.Strings.GeneralStrings`. `KryptonButton` implements `IButtonControl`
(via `KryptonDropButton`), so each button's `DialogResult` is assigned directly and the
form closes automatically on click:

* `AcceptButton` is set from `DefaultButton` (clamped to the visible set).
* `CancelButton` is the first `Cancel`, then `No`, otherwise the last button, so
  <kbd>Esc</kbd> / the close box can always dismiss the dialog.

### Icon

`SetupIcon` reuses the `ExtendedKryptonMessageBoxIcon` enum and the icon bitmaps in
`Krypton.Toolkit.Utilities.Properties.Resources` (Windows 11 variants when
`OSUtilities.IsAtLeastWindowsEleven`), matching `KryptonMessageBoxExtended`. The
associated `SystemSound` is played in `OnShown`. Note that several `System*` enum members
share the same underlying value (for example `SystemHand`, `SystemStop`, and `SystemError`
all equal `MessageBoxIcon.Hand`); the switch therefore lists only distinct values.

## Public API

### `KryptonFoldableDialog`

```csharp
public static DialogResult Show(KryptonFoldableDialogData data);

public static DialogResult Show(string? heading, string? text, string? detailsText, string? caption,
    KryptonMessageBoxButtons buttons = KryptonMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None);

public static DialogResult Show(IWin32Window? owner, string? heading, string? text, string? detailsText, string? caption,
    KryptonMessageBoxButtons buttons = KryptonMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None);
```

`Show(KryptonFoldableDialogData)` throws `ArgumentNullException` when `data` is `null`.

### `KryptonFoldableDialogData`

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `Caption` | `string?` | `null` | Window title. |
| `Heading` | `string?` | `null` | Bold main instruction. Hidden when empty. |
| `Text` | `string?` | `null` | Descriptive message. Hidden when empty. |
| `DetailsText` | `string?` | `null` | Foldable content. When empty, the expander and details region are hidden. |
| `Icon` | `ExtendedKryptonMessageBoxIcon` | `None` | Icon shown beside the heading. |
| `CustomIcon` | `Image?` | `null` | Used when `Icon == Custom`. |
| `Buttons` | `KryptonMessageBoxButtons` | `OK` | Action button set. |
| `DefaultButton` | `KryptonMessageBoxDefaultButton` | `Button1` | Default (focused / accept) button. |
| `Expanded` | `bool` | `false` | Whether details are expanded on open. |
| `ExpandButtonText` | `string?` | `"Show details"` | Expander caption while collapsed. |
| `CollapseButtonText` | `string?` | `"Hide details"` | Expander caption while expanded. |
| `Owner` | `IWin32Window?` | `null` | Owning window; used for modal ownership and centering. |

## Usage

Minimal (details folded away by default):

```csharp
using Krypton.Toolkit.Utilities;

var result = KryptonFoldableDialog.Show(
    heading: "An unhandled exception has occurred.",
    text: "Click Continue to ignore the error, or Quit to close the application.",
    detailsText: exception.ToString(),
    caption: "My Application",
    buttons: KryptonMessageBoxButtons.OKCancel,
    icon: ExtendedKryptonMessageBoxIcon.Error);
```

Full control via the data object:

```csharp
var data = new KryptonFoldableDialogData
{
    Owner = this,
    Caption = "Visual Studio Just-In-Time Debugger",
    Heading = "An exception 'System.InvalidOperationException' has occurred in MyApp.exe.",
    Text = "Do you want to debug using the selected debugger?",
    DetailsText = exception.ToString(),
    Icon = ExtendedKryptonMessageBoxIcon.Error,
    Buttons = KryptonMessageBoxButtons.YesNo,
    DefaultButton = KryptonMessageBoxDefaultButton.Button2,
    Expanded = true,
    ExpandButtonText = "Show details",
    CollapseButtonText = "Hide details"
};

DialogResult result = KryptonFoldableDialog.Show(data);
```

## Configuration / persistence

The dialog is transient and has no persisted settings. All content and behaviour is
supplied per call through `KryptonFoldableDialogData`. Because captions are taken from
`KryptonManager.Strings.GeneralStrings`, the standard button text is localised through the
existing Krypton string customisation mechanism; the heading, message, details, and
expander captions are supplied by the caller and can be localised there.

## Edge cases

* **No details text** — the expander and the details region are hidden; the dialog behaves
  as a compact, themed message box.
* **`Expanded = true` with no details** — ignored; the dialog opens collapsed because there
  is nothing to fold.
* **Default button out of range** — if `DefaultButton` targets a button that is not present
  for the chosen `Buttons` set, it falls back to the first button.
* **Colliding icon values** — `System*` icon members that share an underlying
  `MessageBoxIcon` value resolve to the same bitmap (by design).
* **Threading** — like all WinForms dialogs, call `Show` on the UI thread.
* **TFM** — the code targets `net472` and up; `LogicalToDeviceUnits` provides per-monitor
  DPI-aware sizing of the details region.

## Validation

Exercise the feature through the **Foldable Dialog** entry on the TestForm
`StartScreen` (`FoldableDialogDemo`):

* Edit the caption, heading, message, and folded details.
* Choose any `ExtendedKryptonMessageBoxIcon`, `KryptonMessageBoxButtons` set, and default
  button, and toggle the initial expanded state, then click **Show Dialog**.
* Click **Show JIT-style Preset** to reproduce the Visual Studio Just-In-Time debugger
  layout (error icon, Yes/No, details expanded).
* Switch the global palette/theme to confirm the dialog, expander, and details region are
  palette-aware.

Run the demo:

```
dotnet run --project ".\Source\Krypton Components\TestForm\TestForm.csproj" -c Debug
```
