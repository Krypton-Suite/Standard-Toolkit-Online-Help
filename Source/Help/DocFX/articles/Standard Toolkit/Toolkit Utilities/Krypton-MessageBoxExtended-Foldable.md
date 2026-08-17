# KryptonMessageBoxExtended foldable details

Package: `Krypton.Toolkit.Utilities`.

## Overview

`KryptonMessageBoxExtended` can show a collapsible details region, matching `KryptonFoldableDialog`: an expander with ▼ / ▲ glyphs and localizable Show/Hide Details captions. The expander is **opt-in** and hidden when there is no details text (unless the footer is a checkbox).

## Public API

Preferred surface is `KryptonMessageBoxExtendedData` plus `Show` / `ShowAsync`.

| Property | Role |
|---|---|
| `DetailsText` | Details body. Non-empty shows the expander (FoldableDialog-style alias for `MoreDetailsMessageText`) |
| `Expanded` | Start expanded (alias for `MoreDetailsExpanded`) |
| `ExpandButtonText` | Caption while expanded (Hide Details) |
| `CollapseButtonText` | Caption while collapsed (Show Details) |
| `FooterContentType` | `Text`, `CheckBox`, or `RichTextBox`. `null` + details text uses `RichTextBox` |
| `FooterRichTextBoxHeight` | Details height. `null` uses 180 (same as FoldableDialog) |
| `ShowMoreDetailsOption` | Explicit opt-in; also set automatically when `DetailsText` is non-empty |
| `MoreDetailsButtonText` | Single caption for both states when expand/collapse strings are empty |

Existing `Show(..., footerText, footerExpanded, footerContentType, footerRichTextBoxHeight)` overloads still work.

## Usage

```csharp
var result = KryptonMessageBoxExtended.Show(new KryptonMessageBoxExtendedData
{
    Caption = "Error",
    MessageText = "The operation failed.",
    Icon = ExtendedKryptonMessageBoxIcon.Error,
    Buttons = ExtendedMessageBoxButtons.OK,
    DetailsText = exception.ToString(),
    Expanded = false
});
```

Custom expander captions (same defaults as `KryptonManager.Strings.FoldableDialogStrings`):

```csharp
data.ExpandButtonText = KryptonManager.Strings.FoldableDialogStrings.ExpandText;
data.CollapseButtonText = KryptonManager.Strings.FoldableDialogStrings.CollapseText;
```

## Behaviour

- Collapsed: toggle only. Expanded: details content plus toggle; the form is re-sized via `UpdateSizing`.
- Glyphs and default strings are shared with `KryptonFoldableDialog`.
- Do not also enable `VisualForm.FadeValues.FadingEnabled` on the same instance if you use `UseFade`.

## Validation

TestForm demo: `MessageBoxExtendedFoldableDemo` (registered as **Message Box Extended - Foldable Footer**).

1. Show with footer text — expander visible; expand/collapse resizes the dialog.
2. JIT preset — data path with `DetailsText` / `Expanded`.
3. Compare with **Foldable Dialog** (`FoldableDialogDemo`) for caption and glyph parity.
