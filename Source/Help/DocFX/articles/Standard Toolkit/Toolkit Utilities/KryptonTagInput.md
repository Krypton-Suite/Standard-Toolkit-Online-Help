# KryptonTagInputControl

## Overview

`KryptonTagInputControl` is a wrap-capable tag editor in `Krypton.Toolkit.Utilities`. Tags appear as themed `KryptonHeader` chips with an optional close button spec; a trailing `KryptonTextBox` accepts new values. It lives in the Utilities assembly (the `Krypton.Standard.Toolkit` NuGet package), not in core `Krypton.Toolkit`.

## Architecture

- **Host:** `KryptonTagInputControl` derives from `KryptonPanel` so the surface follows the current palette (`PanelClient`).
- **Layout:** An inner `FlowLayoutPanel` wraps chips and keeps the editor last.
- **Chips:** Internal `KryptonTagChip` (`KryptonHeader`, `HeaderStyle.Secondary`) plus a `ButtonSpecAny` close glyph (`PaletteButtonSpecStyle.Close`).
- **Values:** `KryptonTagInputValues` (`Storage`) holds behaviour and appearance so a fresh Toolbox drop does not show **Modified**.
- **Collection:** `KryptonTagCollection` raises add/remove through the owner so `Tags.Add` and `AddTag` share validation.

```
KryptonTagInputControl : KryptonPanel
  FlowLayoutPanel (dock fill, wrap)
    KryptonTagChip... (one per tag)
    KryptonTextBox (always last)
```

## Public API

### Control

| Member | Role |
|--------|------|
| `Tags` | `KryptonTagCollection` of current tag strings |
| `Suggestions` | `AutoCompleteStringCollection` for the editor |
| `Values` | `KryptonTagInputValues` |
| `ReadOnly` | Hides the editor and disables chip close buttons |
| `AddTag` / `RemoveTag` / `ClearTags` | Programmatic collection changes |
| `SetSuggestions` | Replace the suggestion list |
| `SetCategoryColor` / `TryGetCategoryColor` / `RemoveCategoryColor` / `ClearCategoryColors` | Per-tag fill overrides |

### Events

- `TagAdding` (`KryptonTagCancelEventArgs`) — set `Cancel` to reject
- `TagAdded` / `TagRemoved` (`KryptonTagEventArgs`)
- `TagsChanged`

### Values

Defaults (all `IsDefault`): `CueHintText` empty, `InputWidth` 120, `MaxTags` 0 (unlimited), `ChipRounding` 6, `AllowDuplicates` false, `CaseSensitive` false, `AllowCustomTags` true, `CommitOnEnter` true, `CommitOnComma` true, `RemoveLastOnBackspace` true, `ShowRemoveButton` true, `EnableSuggestions` true, `ClearOnEscape` true.

Tab is **not** a commit key so focus navigation is preserved.

## Usage

```csharp
var tags = new KryptonTagInputControl
{
    Dock = DockStyle.Top,
    Height = 72
};
tags.Values.CueHintText = "Add a tag";
tags.SetSuggestions(new[] { "Bug", "Feature", "Security" });
tags.SetCategoryColor("Bug", Color.IndianRed);
tags.TagAdded += (_, e) => { /* persist e.Tag */ };
form.Controls.Add(tags);
```

Designer: drop from the Toolbox (`Krypton Tag Input`), edit `Tags` / `Suggestions` / `Values` in the property grid. Smart tags expose read-only, duplicates, max tags, cue hint, suggestions, and remove buttons.

## Edge cases

- Empty or whitespace input is ignored.
- `AllowCustomTags = false` accepts only suggestion matches (using `CaseSensitive`).
- `MaxTags` hides the editor when the limit is reached.
- Category colours use case-insensitive names; chip text contrast switches to white or black from luminance.
- `net472` does not use `List<T>.Contains(item, comparer)`; matching is `string.Equals` with `StringComparison`.
