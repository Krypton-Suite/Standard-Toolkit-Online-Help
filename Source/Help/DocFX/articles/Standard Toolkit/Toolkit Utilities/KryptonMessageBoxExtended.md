# KryptonMessageBoxExtended Foldable Footer

## Overview

`KryptonMessageBoxExtended` (in the `Krypton.Toolkit.Utilities` assembly) supports an **optional expandable
("foldable") footer**: a collapsible region below the message body and above/around the buttons that reveals
extra content on demand. It is the message-box equivalent of the collapsible details region in
[`KryptonFoldableDialog`](KryptonFoldableDialog.md), and is intended for scenarios such as
"Show details" stack traces, opt-in "Do not show again" style check boxes, or long secondary explanations that
should not clutter the initial dialog.

The footer is **off by default** and fully backwards compatible: existing `Show(...)` calls are unaffected.
It can be enabled in two ways:

- **Per-call parameters** on the parameterised `Show(...)` overloads (`footerText`, `footerExpanded`,
  `footerContentType`, `footerRichTextBoxHeight`).
- **Data model** via `Show(KryptonMessageBoxExtendedData)` using the `ShowMoreDetailsOption`,
  `MoreDetailsMessageText`, and `MoreDetailsButtonText` properties.

## Architecture

| Type | Role |
| --- | --- |
| `KryptonMessageBoxExtended` (`Controls Toolkit`) | Public static entry point. `Show(...)` overloads forward the footer parameters to `ShowCore`. |
| `VisualMessageBoxExtendedForm` (`Controls Visuals`) | Standard (LTR) host form. Owns the footer panel, toggle button and the three content controls. |
| `VisualRTLMessageBoxExtendedForm` (`Controls Visuals`) | Right-to-left host form (used when `MessageBoxOptions.RightAlign`/`RtlReading` is set). Mirrors the footer behaviour. |
| `ExtendedKryptonMessageBoxFooterContentType` (`General/Definitions.cs`) | Selects the footer content control: `Text`, `CheckBox`, or `RichTextBox`. |
| `KryptonManager.Strings.FoldableDialogStrings` (`Krypton.Toolkit`) | Localizable source of the `Show Details` / `Hide Details` toggle captions, shared with `KryptonFoldableDialog`. |

### Layout

The footer lives inside the message-content `TableLayoutPanel` as a column-spanning `KryptonPanel`
(`_panelFooter`, `PanelAlternate` back style) with a top `KryptonBorderEdge` separator. The panel hosts:

- `_footerToggleButton` - a `LowProfile` `KryptonButton` that expands/collapses the region.
- `_footerWrapLabel` - shown for `ExtendedKryptonMessageBoxFooterContentType.Text`.
- `_footerCheckBox` - shown for `ExtendedKryptonMessageBoxFooterContentType.CheckBox`.
- `_footerRichTextBox` - shown for `ExtendedKryptonMessageBoxFooterContentType.RichTextBox`.

### Control flow

1. `Show(...)` → `ShowCore(...)` constructs the visual form, forwarding `footerText`, `footerExpanded`,
   `footerContentType`, and `footerRichTextBoxHeight`.
2. The form constructor calls `SetupFooter(...)`, which decides whether the footer is shown
   (`showFooter = !string.IsNullOrEmpty(footerText) || contentType == CheckBox`), configures the relevant
   content control, then calls `UpdateFooterExpandedState(...)` for the initial state.
3. `UpdateFooterExpandedState(expanded, contentType)` toggles content visibility, sets the toggle caption
   (glyph + shared strings), computes the footer height, and re-runs `UpdateSizing(...)` so the whole message
   box grows/shrinks to fit.
4. `FooterToggleButton_Click` flips the current expanded state and re-invokes `UpdateFooterExpandedState`.

## Public API

The feature is exposed through the two footer-aware `Show` overloads (LTR owner and non-owner), plus the
`footer*` parameters threaded through `ShowCore`:

```csharp
public static DialogResult Show(
    IWin32Window owner,
    string messageText,
    string caption = "",
    ExtendedMessageBoxButtons buttons = ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon icon = ExtendedKryptonMessageBoxIcon.None,
    bool showCloseButton = true,
    string? footerText = null,
    bool footerExpanded = false,
    ExtendedKryptonMessageBoxFooterContentType footerContentType = ExtendedKryptonMessageBoxFooterContentType.Text,
    int? footerRichTextBoxHeight = null,
    bool? showCtrlCopy = null,
    Font? messageBoxTypeface = null);
```

| Parameter | Behaviour |
| --- | --- |
| `footerText` | The content for the footer. For `Text`/`RichTextBox` it is the body; for `CheckBox` it is the check-box caption. If empty and the type is not `CheckBox`, the footer is hidden. |
| `footerExpanded` | When `true`, the footer starts expanded; otherwise collapsed. |
| `footerContentType` | `Text` (wrap label), `CheckBox`, or `RichTextBox`. |
| `footerRichTextBoxHeight` | Fixed height in pixels for the rich-text content (only used when the type is `RichTextBox`; ignored otherwise). |

### Toggle caption

The toggle button caption combines a triangle glyph with the shared, localizable strings so it matches
`KryptonFoldableDialog`:

- Collapsed: `▼  {KryptonManager.Strings.FoldableDialogStrings.CollapseText}` (default `&Show Details`).
- Expanded: `▲  {KryptonManager.Strings.FoldableDialogStrings.ExpandText}` (default `H&ide Details`).

Override `KryptonManager.Strings.FoldableDialogStrings.CollapseText` / `ExpandText` to localize both the
message-box footer and the foldable dialog at once.

### Data model (`KryptonMessageBoxExtendedData`)

`Show(KryptonMessageBoxExtendedData data, bool showCloseButton = true)` configures the message box (and its
footer) from a data object. The footer is driven by the following properties:

| Property | Behaviour |
| --- | --- |
| `ShowMoreDetailsOption` | Master switch. When `true` (and `MoreDetailsMessageText` is non-empty) the footer is shown as a `RichTextBox`. |
| `MoreDetailsMessageText` | The details body rendered in the footer's rich-text control. |
| `MoreDetailsExpanded` | When `true` the details region starts expanded; otherwise it starts collapsed. |
| `MoreDetailsButtonText` | Optional custom toggle caption. When set it is used for both states (with the ▼/▲ glyph); when empty the shared `FoldableDialogStrings` captions are used. |

This path routes through the standard `VisualMessageBoxExtendedForm` (RTL is handled in-form via
`RightToLeftLayout` from `KryptonMessageBoxExtendedData.Options`).

## Usage

```csharp
// A stack-trace style "Show details" footer.
KryptonMessageBoxExtended.Show(
    this,
    "An unhandled exception has occurred in your application.",
    "Krypton Message Box Extended",
    ExtendedMessageBoxButtons.OKCancel,
    ExtendedKryptonMessageBoxIcon.Error,
    footerText: exception.ToString(),
    footerContentType: ExtendedKryptonMessageBoxFooterContentType.RichTextBox,
    footerRichTextBoxHeight: 160);
```

```csharp
// A collapsible check-box footer, expanded by default.
KryptonMessageBoxExtended.Show(
    "Update installed successfully.",
    "Setup",
    ExtendedMessageBoxButtons.OK,
    ExtendedKryptonMessageBoxIcon.Information,
    footerText: "Do not remind me again",
    footerExpanded: true,
    footerContentType: ExtendedKryptonMessageBoxFooterContentType.CheckBox);
```

```csharp
// Data-model path with a custom "more details" toggle caption.
var data = new KryptonMessageBoxExtendedData
{
    Owner = this,
    Caption = "Visual Studio Just-In-Time Debugger",
    MessageText = "An exception 'System.InvalidOperationException' has occurred in MyApp.exe.",
    Buttons = ExtendedMessageBoxButtons.YesNo,
    Icon = ExtendedKryptonMessageBoxIcon.Error,
    ShowMoreDetailsOption = true,
    MoreDetailsExpanded = false,
    MoreDetailsButtonText = "Stack trace",
    MoreDetailsMessageText = exception.ToString()
};

KryptonMessageBoxExtended.Show(data);
```

## Edge cases

- **RTL**: When `MessageBoxOptions.RightAlign`/`RtlReading` route to `VisualRTLMessageBoxExtendedForm`, the same
  footer behaviour and captions apply; the current footer `Show` overloads do not set RTL options, so RTL is
  reached through the fuller `Show`/`ShowCore` paths.
- **Sizing**: `UpdateFooterExpandedState` measures text content with `Graphics.MeasureString`, enforces a
  minimum expanded height, and calls `UpdateSizing` so the message box re-computes its client size each toggle.
- **`net472`**: No new language features are used; the feature is compatible with all supported target
  frameworks.
- **Backwards compatibility**: All footer parameters are optional with non-footer defaults; existing callers
  and serialized designer state are unaffected.
