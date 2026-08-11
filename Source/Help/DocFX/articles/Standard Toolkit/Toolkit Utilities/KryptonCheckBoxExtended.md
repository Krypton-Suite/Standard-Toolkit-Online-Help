# KryptonCheckBoxExtended

**Assembly:** `Krypton.Toolkit.Utilities`  
**Namespace:** `Krypton.Toolkit.Utilities`  
**Toolbox name:** Krypton CheckBox Extended  
**Introduced:** V110 (Utilities)

---

## Table of contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [When to use](#when-to-use)
4. [Architecture](#architecture)
5. [Layout model](#layout-model)
6. [Property groups](#property-groups)
7. [API reference — `KryptonCheckBoxExtended`](#api-reference--kryptoncheckboxextended)
8. [API reference — `CheckBoxExtendedTextValues`](#api-reference--checkboxextendedtextvalues)
9. [API reference — `CheckBoxExtendedLayoutValues`](#api-reference--checkboxextendedlayoutvalues)
10. [API reference — `CheckBoxExtendedSubtextLinkValues`](#api-reference--checkboxextendedsubtextlinkvalues)
11. [Inherited palette and image APIs](#inherited-palette-and-image-apis)
12. [Subtext links](#subtext-links)
13. [Accessibility](#accessibility)
14. [KryptonCommand integration](#kryptoncommand-integration)
15. [Designer support](#designer-support)
16. [Word wrap implementation](#word-wrap-implementation)
17. [Code examples](#code-examples)
18. [Behaviour notes and limitations](#behaviour-notes-and-limitations)
19. [Source layout (contributors)](#source-layout-contributors)
20. [Related controls](#related-controls)

---

## Overview

`KryptonCheckBoxExtended` is a Krypton-styled check box control for scenarios where the label is too long for a single line. It provides:

- **Word-wrapped main text** (short text) that grows vertically with available width
- **Optional subtext** (long text) below the main label, with its own font and colour
- **Configurable spacing** between glyph, main text, and subtext
- **Optional hyperlink regions** within the subtext
- **Full check-box semantics** — checked / three-state, mnemonics, keyboard, `KryptonCommand`, palette overrides
- **Accessibility** — screen readers receive main text as the name and subtext as the description

The control lives in **Utilities** so the core `KryptonCheckBox` in `Krypton.Toolkit` remains unchanged. The design is informed by [dahall/groupcontrols `CheckBoxEx`](https://github.com/dahall/groupcontrols/blob/master/GroupControls/CheckBoxEx.cs).

---

## Requirements

| Requirement | Detail |
|-------------|--------|
| **Package** | `Krypton.Standard.Toolkit` (or a build that includes `Krypton.Toolkit.Utilities`) |
| **Reference** | `Krypton.Toolkit.Utilities.dll` (pulls in `Krypton.Toolkit`) |
| **Platform** | Windows WinForms (`net472`+ and modern `-windows` TFMs supported by the suite) |
| **Designer** | Visual Studio WinForms designer; control appears in the toolbox under Utilities |

Add the control to the toolbox by referencing the Utilities assembly, or drop it from an existing Krypton-enabled project that already references Utilities.

---

## When to use

| Use `KryptonCheckBoxExtended` | Use `KryptonCheckBox` |
|------------------------------|----------------------|
| Agreement / consent text that wraps over multiple lines | Short, single-line labels |
| Secondary explanatory subtext under the main label | No subtext needed |
| Subtext contains a “read more” / terms link | Simple check + label only |
| Auto-sized height based on wrapped content | Fixed 25px-style height is enough |

`KryptonCheckBoxExtended` is **not** a drop-in replacement: layout is vertical and auto-sized by default (`DefaultSize` is 300×60). Existing forms that assume a compact single-line checkbox should keep `KryptonCheckBox`.

---

## Architecture

The control follows the standard Krypton **view-manager** pattern used by `KryptonCheckBox`:

```
KryptonCheckBoxExtended (VisualSimpleBase, IContentValues)
├── ViewManager
│   └── ViewLayoutDocker (_layoutDocker)
│       ├── ViewLayoutDocker (_layoutCheckBoxGlyph)  ← checkbox column
│       │   ├── ViewDrawCheckBox                     ← glyph (top-aligned)
│       │   └── ViewLayoutFill
│       ├── ViewLayoutSeparator (_textGapSeparator)  ← optional TextGap
│       └── ViewDrawCheckBoxExtendedContent          ← wrapped text + subtext
├── CheckBoxController                               ← mouse / keyboard / Space
└── SubtextLinkPresenter (child LinkLabel)           ← link overlay when LinkArea set
```

**Key types**

| Type | Visibility | Role |
|------|------------|------|
| `KryptonCheckBoxExtended` | public | Control surface, events, value groups |
| `CheckBoxExtendedTextValues` | public | Text, subtext, subtext font/colour, images |
| `CheckBoxExtendedLayoutValues` | public | `SubtextSeparatorHeight`, `TextGap` |
| `CheckBoxExtendedSubtextLinkValues` | public | `LinkArea`, `LinkColor` |
| `ViewDrawCheckBoxExtendedContent` | internal | Word-wrap measure, layout, paint |
| `SubtextLinkPresenter` | internal | `KryptonLinkWrapLabel` for link hit-testing |
| `KryptonCheckBoxExtendedAccessibleObject` | internal | UI Automation / MSAA |
| `KryptonCheckBoxExtendedDesigner` | internal | Design surface |
| `KryptonCheckBoxExtendedActionList` | internal | Smart-tag tasks |

---

## Layout model

At runtime the client area is arranged left-to-right (LTR, check on left) as:

```
┌──┬─┬──────────────────────────────────────┐
│☐ │ │  Main text wraps across multiple     │
│  │g│  lines according to control width.   │
│  │a│                                      │
│  │p│  Subtext appears below with optional │
│  │ │  link styling on a character range.  │
└──┴─┴──────────────────────────────────────┘
 ↑   ↑
 │   └── TextGap (LayoutValues.TextGap, default 0)
 └────── Checkbox glyph (top-aligned in column)
```

**Spacing sources**

| Gap | Source | Default |
|-----|--------|---------|
| Glyph → text block | Palette `GetBorderContentPadding` (label style, typically 3px) + `LayoutValues.TextGap` | 3px + 0 |
| Main text → subtext | `LayoutValues.SubtextSeparatorHeight` | 5px |

`CheckPosition`, `Orientation`, and `RightToLeft` reposition the glyph column using the same rules as `KryptonCheckBox` (`UpdateForOrientation`).

**Auto-size**

- `AutoSize = true` and `AutoSizeMode = GrowAndShrink` by default
- Height grows with wrapped main text + separator + subtext
- Anchor left/right on a parent panel to demonstrate wrapping at different widths (see TestForm demo)

---

## Property groups

Designer properties are grouped into **expandable** nodes (`ExpandableObjectConverter`):

### `Values` (`CheckBoxExtendedTextValues`)

Main label content: `Text`, `Subtext`, `SubtextFont`, `SubtextForeColor`, plus inherited `LabelValues` members (`Image`, `OverlayImage`, etc.).

### `LayoutValues` (`CheckBoxExtendedLayoutValues`)

- `SubtextSeparatorHeight` — vertical gap between main and sub text (pixels)
- `TextGap` — extra gap between glyph column and text block (pixels)

### `SubtextLinkValues` (`CheckBoxExtendedSubtextLinkValues`)

- `LinkArea` — `System.Windows.Forms.LinkArea` (start index + length in **subtext** string)
- `LinkColor` — link foreground; empty uses `SystemColors.HotTrack`

### Top-level shortcuts

| Property | Maps to | Notes |
|----------|---------|-------|
| `Text` | `Values.Text` | `DefaultProperty`; supports multiline editor |
| `Checked` / `CheckState` | — | `DefaultBindingProperty` is `CheckState` |

Subtext is set via **`Values.Subtext`** (there is no separate top-level `Subtext` property on the control).

---

## API reference — `KryptonCheckBoxExtended`

**Base type:** `Krypton.Toolkit.VisualSimpleBase`  
**Interfaces:** `Krypton.Toolkit.IContentValues`  
**Default event:** `CheckedChanged`  
**Default property:** `Text`  
**Default binding property:** `CheckState`

### Constructor

```csharp
public KryptonCheckBoxExtended()
```

Initialises palette state, view tree, wrap defaults (`MultiLine`, `Trim = Word` on short/long text), `AutoSize = true`, and child link presenter.

### Events

| Event | Category | Description |
|-------|----------|-------------|
| `CheckedChanged` | Misc | `Checked` became true or false |
| `CheckStateChanged` | Misc | `CheckState` changed (includes indeterminate) |
| `KryptonCommandChanged` | Property Changed | `KryptonCommand` reference or bound command state changed |
| `SubtextLinkClicked` | Action | User clicked a character range defined by `SubtextLinkValues.LinkArea` |

Standard `Click` is inherited; checkbox toggle logic runs in `OnClick` when `AutoCheck` is true.

`DoubleClick`, `MouseDoubleClick`, and `ImeModeChanged` are hidden from the designer (same pattern as `KryptonCheckBox`).

### Content and layout properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Text` | `string` | (see Values) | Main label; multiline editor in designer |
| `Values` | `CheckBoxExtendedTextValues` | — | Expandable text/subtext/image group |
| `LayoutValues` | `CheckBoxExtendedLayoutValues` | — | Expandable spacing group |
| `SubtextLinkValues` | `CheckBoxExtendedSubtextLinkValues` | — | Expandable link group |

### Check state and behaviour

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Checked` | `bool` | `false` | Two-state shortcut; bindable |
| `CheckState` | `CheckState` | `Unchecked` | Full three-state value; bindable |
| `ThreeState` | `bool` | `false` | Enables indeterminate cycle |
| `AutoCheck` | `bool` | `true` | Click/Space toggles state |
| `UseMnemonic` | `bool` | `true` | `&` prefix in **main** text only |
| `KryptonCommand` | `KryptonCommand?` | `null` | Binds text, extra text, image, enabled, check state |

### Visual and palette properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `LabelStyle` | `LabelStyle` | `NormalPanel` | Drives palette content style |
| `Orientation` | `VisualOrientation` | `Top` | Text flow orientation |
| `CheckPosition` | `VisualOrientation` | `Left` | Glyph placement |
| `Images` | `CheckBoxImages` | — | Checkbox glyph image overrides |
| `StateCommon` | `PaletteContent` | — | Base label/checkbox content palette |
| `StateNormal` | `PaletteContent` | — | Normal state overrides |
| `StateDisabled` | `PaletteContent` | — | Disabled state overrides |
| `OverrideFocus` | `PaletteContent` | — | Focus override |

Inherited from `VisualSimpleBase`: `PaletteMode`, `Palette`, `Redirector`, global palette change handling.

### Sizing

| Property | Default | Notes |
|----------|---------|-------|
| `AutoSize` | `true` | Visible in designer |
| `AutoSizeMode` | `GrowAndShrink` | Hidden; always grow/shrink |
| `Padding` | — | Hidden; not used |
| `DefaultSize` | 300×60 | Design-time default |

### Methods

| Method | Description |
|--------|-------------|
| `ResetText()` | Resets `Values.Text` and subtext to defaults |
| `SetFixedState(focus, enabled, tracking, pressed)` | Pins preview/design palette state (designer and gallery use) |

### `IContentValues` mapping

| Method | Source when no command | Source with `KryptonCommand` |
|--------|------------------------|------------------------------|
| `GetShortText()` | `Values.Text` | `KryptonCommand.Text` |
| `GetLongText()` | `Values.Subtext` | `KryptonCommand.ExtraText` |
| `GetImage()` | `Values.Image` | `KryptonCommand.ImageSmall` |

---

## API reference — `CheckBoxExtendedTextValues`

**Base type:** `Krypton.Toolkit.LabelValues`  
**Converter:** `ExpandableObjectConverter`

### Properties (extended)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Text` | `string` | `"Krypton CheckBox Extended"` | Main label (short text) |
| `Subtext` | `string` | `""` | Secondary text; maps to `ExtraText` / long text |
| `SubtextFont` | `Font?` | `null` | Subtext font; `null` uses palette long-text font |
| `SubtextForeColor` | `Color` | `Empty` | Subtext colour; empty uses palette |

### Inherited from `LabelValues`

| Property | Description |
|----------|-------------|
| `Image` | Optional image in content (see limitations) |
| `ImageTransparentColor` | Image transparency key |
| `ExtraText` | Underlying storage for subtext; prefer `Subtext` |
| `OverlayImage` | Overlay image settings |

### Methods

| Method | Description |
|--------|-------------|
| `ResetText()` | Resets both `Text` and `Subtext` |
| `ResetSubtext()` | Clears subtext only |
| `ResetSubtextFont()` | Clears custom subtext font |
| `ResetSubtextForeColor()` | Clears custom subtext colour |

### Events

| Event | Description |
|-------|-------------|
| `TextChanged` | `Text` or `ExtraText` / `Subtext` changed |

---

## API reference — `CheckBoxExtendedLayoutValues`

**Base type:** `Krypton.Toolkit.Storage`

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `SubtextSeparatorHeight` | `int` | `5` | Pixels between bottom of main text and top of subtext |
| `TextGap` | `int` | `0` | Extra pixels between glyph column and text (≥ 0) |

Changing either property triggers layout recalculation and repaint on the owning control.

---

## API reference — `CheckBoxExtendedSubtextLinkValues`

**Base type:** `Krypton.Toolkit.Storage`

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `LinkArea` | `LinkArea` | `0, 0` | Character range in **subtext** that behaves as a hyperlink; length `0` disables links |
| `LinkColor` | `Color` | `Empty` | Link colour; empty uses `SystemColors.HotTrack` |

When `LinkArea.Length > 0` and subtext is non-empty, subtext painting is delegated to `SubtextLinkPresenter` (a child `KryptonLinkWrapLabel` aligned to the subtext rectangle).

---

## Inherited palette and image APIs

`KryptonCheckBoxExtended` exposes the same palette override surface as `KryptonCheckBox`:

- Adjust fonts and colours via `StateCommon.ShortText` / `StateCommon.LongText`
- On construction, wrap-friendly defaults are applied:

```csharp
shortText.MultiLine = InheritBool.True;
shortText.Trim = PaletteTextTrim.Word;
longText.MultiLine = InheritBool.True;
longText.Trim = PaletteTextTrim.Word;
```

`SubtextFont` and `SubtextForeColor` on `Values` are copied into `StateCommon.LongText` and the custom drawer when set.

**Checkbox glyph images** use `Images` (`CheckBoxImages`) and `ViewDrawCheckBox` — same as `KryptonCheckBox`.

**Label images** (`Values.Image`) are exposed through `IContentValues` but are **not** laid out by `ViewDrawCheckBoxExtendedContent` (text-only drawer). Prefer text-only content unless future work adds image layout.

---

## Subtext links

### Configuring a link

`LinkArea` uses **zero-based character indices** into the subtext string, identical to `LinkLabel.LinkArea`:

```csharp
// Subtext: "Please read the full agreement before continuing."
//           012345678901234567890123456789012345678901234
//                     1         2         3         4
// Link "full agreement" starting at index 18, length 14:
checkBox.SubtextLinkValues.LinkArea = new LinkArea(18, 14);
checkBox.SubtextLinkValues.LinkColor = Color.CornflowerBlue; // optional
```

### Click behaviour

| User action | Result |
|-------------|--------|
| Click link region in subtext | `SubtextLinkClicked` fires; **checkbox does not toggle** |
| Click subtext outside link | Checkbox toggles (if `AutoCheck`) |
| Click main text or glyph | Checkbox toggles |
| Keyboard mnemonic on main text | Focus + toggle (if `UseMnemonic` and `AutoCheck`) |
| Space when focused | Toggle via `CheckBoxController` |

The hand cursor appears when the pointer is over the link region (`OnMouseMove` / `ContainsLinkPoint`).

### Event handler

```csharp
checkBox.SubtextLinkClicked += (sender, e) =>
{
  // e.Link is the LinkLabel.Link instance
  // e.Link.LinkData is user data if assigned
  Process.Start("https://example.com/terms");
};
```

---

## Accessibility

`KryptonCheckBoxExtendedAccessibleObject` provides:

| UIA / MSAA | Value |
|------------|-------|
| **Name** | `AccessibleName` if set; else main `Text` with `&` stripped |
| **Description** | `AccessibleDescription` if set; else `Values.Subtext` |
| **Role** | `CheckButton` (or `AccessibleRole` if overridden) |
| **State** | Focused, Checked, Invisible, Unavailable as appropriate |
| **Default action** | `"Check"` — invokes `PerformAccessibilityClick()` |

Screen readers therefore announce the main agreement line as the control name and the explanatory subtext as the description, which suits consent/checkbox patterns.

---

## KryptonCommand integration

Assign a `KryptonCommand` with `CheckState` support:

```csharp
var command = new KryptonCommand
{
    Text = "Enable feature",
    ExtraText = "May increase battery usage.",
    CheckState = CheckState.Unchecked,
    Enabled = true
};
checkBox.KryptonCommand = command;
```

When a command is attached:

- `Text` / `Subtext` display comes from `KryptonCommand.Text` / `ExtraText`
- `Enabled` and `CheckState` sync from the command
- `PerformExecute()` runs on click after toggle

Property changes on the command (`Text`, `ExtraText`, `ImageSmall`, `Enabled`, `CheckState`) trigger repaint.

---

## Designer support

| Feature | Detail |
|---------|--------|
| **Toolbox** | `KryptonCheckBoxExtended`; bitmap borrowed from `KryptonCheckBox` |
| **Smart tags** | Text, Subtext, Subtext font/colour, subtext spacing, text gap, checked state, orientation, label style, palette |
| **Serialisation** | `Values`, `LayoutValues`, `SubtextLinkValues` as content properties |
| **Multiline editor** | `Text` and `Values.Subtext` |

**TestForm demo:** `CheckBoxExtendedDemo` — Start Screen → **CheckBox Extended**, or Main form button **CheckBox Extended**.

---

## Word wrap implementation

Standard Krypton `ViewDrawContent` measures single-line text and ellipsizes overflow. `KryptonCheckBoxExtended` therefore uses **`ViewDrawCheckBoxExtendedContent`**, which:

1. Calls `TextRenderer.MeasureText` / `DrawText` with `TextFormatFlags.WordBreak | TextFormatFlags.TextBoxControl`
2. Lays out short text (main) and long text (subtext) in separate rectangles
3. Applies palette `GetBorderContentPadding` so glyph-to-text spacing matches `KryptonCheckBox`
4. Skips painting subtext when a link presenter is active (`SkipSubtextDrawing`)

This is why `StateCommon.ShortText.MultiLine = True` alone on a normal checkbox is insufficient for true word wrap at the view level.

---

## Code examples

### Basic agreement checkbox

```csharp
var agree = new KryptonCheckBoxExtended
{
    AutoSize = true,
    Anchor = AnchorStyles.Top | AnchorStyles.Left | AnchorStyles.Right,
    Text = "I agree to the terms and conditions governing use of this product.",
    Width = 400
};
agree.Values.Subtext = "Please review the terms before continuing.";
agree.Values.SubtextFont = new Font(agree.Font.FontFamily, agree.Font.SizeInPoints - 1f);
agree.CheckedChanged += (_, _) => ApplyButton.Enabled = agree.Checked;
```

### Spacing tuning

```csharp
agree.LayoutValues.TextGap = 2;                    // extra space after glyph
agree.LayoutValues.SubtextSeparatorHeight = 8;   // more space before subtext
```

### Subtext with link

```csharp
agree.Values.Subtext = "Please read the full agreement before continuing.";
agree.SubtextLinkValues.LinkArea = new LinkArea(18, 14);
agree.SubtextLinkClicked += (_, e) => ShowTermsDialog();
```

### Three-state

```csharp
var option = new KryptonCheckBoxExtended
{
    ThreeState = true,
    CheckState = CheckState.Indeterminate,
    Text = "Include optional diagnostics"
};
```

### Data binding

```csharp
bindingSource.DataSource = viewModel;
checkBox.DataBindings.Add(nameof(KryptonCheckBoxExtended.CheckState),
    bindingSource, nameof(ViewModel.AcceptanceState), true, DataSourceUpdateMode.OnPropertyChanged);
```

---

## Behaviour notes and limitations

| Topic | Detail |
|-------|--------|
| **Label images** | `Values.Image` is not rendered in the custom text drawer; only the checkbox glyph uses `Images` |
| **Link + wrap** | Link hit-testing uses `LinkLabel` character mapping; complex multi-line links depend on presenter layout matching wrapped subtext |
| **RTL** | Glyph docking honours `RightToLeft`; verify visually for your palette and `CheckPosition` |
| **Transparency** | `EvalTransparentPaint()` returns `true`; parent background shows through |
| **Focus cues** | Focus rectangle drawn around text area when system focus cues are enabled |
| **Child control** | `SubtextLinkPresenter` is a child `KryptonLinkWrapLabel`; visible only when links are active |
| **No breaking changes** | `KryptonCheckBox` in `Krypton.Toolkit` is untouched |

---

## Source layout (contributors)

```
Source/Krypton Components/Krypton.Toolkit.Utilities/Components/KryptonCheckBoxExtended/
├── Controls Toolkit/
│   └── KryptonCheckBoxExtended.cs          Control, events, view wiring
├── Values/
│   ├── CheckBoxExtendedTextValues.cs       Text / subtext content
│   ├── CheckBoxExtendedLayoutValues.cs     Spacing
│   └── CheckBoxExtendedSubtextLinkValues.cs Links
├── View Draw/
│   └── ViewDrawCheckBoxExtendedContent.cs  Word-wrap layout and paint
├── General/
│   ├── SubtextLinkPresenter.cs             Link overlay
│   └── KryptonCheckBoxExtendedAccessibleObject.cs
└── Designers/
    ├── Designers/KryptonCheckBoxExtendedDesigner.cs
    └── Action Lists/KryptonCheckBoxExtendedActionList.cs

Source/Krypton Components/TestForm/
├── CheckBoxExtendedDemo.cs
└── CheckBoxExtendedDemo.Designer.cs
```

New `.cs` files under Utilities are picked up automatically by the project SDK; no `.csproj` edit is required.

---

## Related controls

| Control | Relationship |
|---------|--------------|
| `KryptonCheckBox` | Base single-line checkbox; same glyph controller and palette model |
| `KryptonLinkWrapLabel` | Subtext link presenter base; word-wrapped link label |
| `KryptonCommandLinkButton` | Similar “main + secondary text” pattern in Utilities |
| `KryptonCheckBox` (issue #3833) | Original feature request target; extended variant chosen to avoid breaking base control |
