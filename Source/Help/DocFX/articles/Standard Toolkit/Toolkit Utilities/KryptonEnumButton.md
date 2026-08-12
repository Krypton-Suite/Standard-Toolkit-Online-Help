# KryptonEnumButton

## Overview

`KryptonEnumButton` is a themed button that represents a single value of an enumeration and
**cycles through the enumeration's values each time it is clicked**. It is intended as a compact
alternative to a long list of radio buttons when the user only needs to toggle between the members
of an `enum` (issue [#3838](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3838)).

- **Package / assembly:** `Krypton.Toolkit.Utilities` (`Krypton.Toolkit.Utilities.csproj`).
- **Namespace:** `Krypton.Toolkit.Utilities`.
- **Base type:** `Krypton.Toolkit.KryptonButton` (so it inherits all button theming, palettes,
  `ButtonStyle`, `Values`, pulsing border, etc.).
- **NuGet:** consumers install the `Krypton.Standard.Toolkit` package to get the utilities assembly.

The button text is derived from the current enum member — the `DescriptionAttribute` text when
present (and `UseDescriptionAttribute` is `true`), otherwise the field name (optionally humanised).

Two controls ship as part of this feature:

- **`KryptonEnumButton`** — a standard `KryptonButton` showing a single text line per value.
- **`KryptonEnumCommandLinkButton`** — a `KryptonCommandLinkButton` (Vista/7-style command link)
  showing a bold heading plus a descriptive sub-text per value. See
  [Command-link variant](#command-link-variant-kryptonenumcommandlinkbutton).

Both controls share the same cycling semantics, ordering/filtering, keyboard and mouse-wheel
support, events, and strongly-typed helpers, because both delegate to a common engine.

## Architecture

Neither control can share a base class (`KryptonEnumButton` extends `KryptonButton`, whereas
`KryptonEnumCommandLinkButton` extends `KryptonCommandLinkButton` → `VisualSimpleBase`), so the shared
behaviour lives in composed helper types rather than a common base:

```
KryptonButton (Krypton.Toolkit)                 KryptonCommandLinkButton (Krypton.Toolkit.Utilities)
  └── KryptonEnumButton                            └── KryptonEnumCommandLinkButton
        │                                                 │
        └───────────────┬─────────────────────────────────┘
                        │ owns (composition)
                        ▼
        EnumButtonValueCycler   ── enum type, active value list, selected index, clamp / wrap maths
        EnumButtonTextHelper    ── description lookup + PascalCase humanisation (static)
        EnumButtonSortOrder     ── Declaration | Value | Alphabetical
```

### `EnumButtonValueCycler` (the engine)

`EnumButtonValueCycler` is an internal, UI-agnostic class that owns everything about *which* value is
selected and *how* cycling moves between values. It knows nothing about display text, images, or
events — the host control resolves presentation and raises events. This keeps the two controls
behaviourally identical while rendering differently.

Responsibilities:

- Holds the `EnumType` and reflects its public static fields
  (`Type.GetFields(BindingFlags.Public | BindingFlags.Static)`) in **declaration order**. Declaration
  order is used deliberately: `Enum.GetValues` collapses duplicate underlying values, whereas
  reflecting the fields gives one predictable cycle entry per declared member and lets each member
  carry its own `DescriptionAttribute`.
- Builds the **active** list = declared members minus `ExcludedValues`, re-ordered per `SortOrder`.
- Owns `SelectedIndex`, `Clamp`, `GetCycleTargetIndex(direction)` (peek without committing), and
  `CommitIndex`.
- Preserves the currently selected value across `SortOrder` / `ExcludedValues` changes where possible.

### Selection, text, and images

Each host control drives presentation from the engine:

- `KryptonEnumButton` writes the resolved text to `base.Text` (which `KryptonButton` maps onto
  `Values.Text`) and, when an `ImageProvider` is set, writes `Values.Image`.
- `KryptonEnumCommandLinkButton` writes `CommandLinkTextValues.Heading` /
  `.Description`, and (with an `ImageProvider`) `CommandLinkTextValues.Image`.

The public `Text` property on `KryptonEnumButton` is overridden to be hidden and non-serialized
(`[Browsable(false)]`, `[EditorBrowsable(Never)]`, `[DesignerSerializationVisibility(Hidden)]`,
`[AllowNull]`) because the text is fully driven by the enum selection.

### The change pipeline

All selection changes (click, cycle, keyboard, wheel, `SelectedIndex` / `SelectedValue` setters) flow
through a single private `TryChangeTo(index)` method that:

1. Clamps the requested index and returns early if unchanged.
2. Raises the cancelable `SelectedValueChanging` event; aborts if a handler sets `Cancel = true`.
3. Commits the index in the engine.
4. Updates the presentation (text/heading/description/image).
5. Raises `SelectedValueChanged` and `EnumValueChanged`.

`OnClick` cycles to the next value **before** calling `base.OnClick`, so any handler attached to the
standard `Click` event observes the newly selected value.

## Public API

### Properties

| Member | Type | Default | Description |
| --- | --- | --- | --- |
| `EnumType` | `Type?` | `null` | The enum type to cycle through. Throws `ArgumentException` if the type is not an enum. Switching between two different enum types resets the selection to the first value. Has a design-time drop-down editor (see [Design-time enum picker](#design-time-enum-picker)). |
| `SelectedIndex` | `int` | `0` | Zero-based index of the current value (within the active list). Clamped to the valid range. |
| `SelectedValue` | `object?` | `null` | The current boxed enum value; set to any value that belongs to `EnumType` to select it. `[Bindable(true)]` for data binding; hidden from the designer. |
| `SelectedDisplayText` | `string` | `""` | The text currently shown on the button. Read-only. |
| `WrapAround` | `bool` | `true` | When `true`, cycling past the last value returns to the first (and vice versa); otherwise the selection clamps at the ends. |
| `UseDescriptionAttribute` | `bool` | `true` | When `true`, `DescriptionAttribute` text is used (falling back to the field name); when `false`, the field name is always used. |
| `HumanizeNames` | `bool` | `false` | When `true`, PascalCase / snake_case field names are shown with spaces (e.g. `ExtraLarge` → `Extra Large`) when no description is used. |
| `SortOrder` | `EnumButtonSortOrder` | `Declaration` | The cycle order: `Declaration`, `Value` (underlying numeric), or `Alphabetical` (member name). |
| `ExcludedValues` | `IReadOnlyList<object>?` | `null` | Values removed from the cycle. Assign in code; not serialized. |
| `ReverseOnRightClick` | `bool` | `false` | When `true`, a right-click cycles to the previous value. |
| `AllowKeyboardCycling` | `bool` | `true` | When `true`, Left/Up cycle previous and Right/Down cycle next while the button has focus. |
| `AllowMouseWheelCycling` | `bool` | `true` | When `true`, the mouse wheel cycles the value (wheel up = previous, wheel down = next). |
| `ImageProvider` | `Func<object, Image?>?` | `null` | Optional callback that supplies the button image per value (code-only, not serialized). |
| `Text` | `string` | derived | Overridden, hidden, and not serialized — the text is derived from the selection. |

### Methods

| Member | Description |
| --- | --- |
| `void CycleNext()` | Advance to the next value (wrap or clamp per `WrapAround`). |
| `void CyclePrevious()` | Move to the previous value (wrap or clamp per `WrapAround`). |
| `void SetEnumType<TEnum>()` | Strongly-typed helper for `EnumType = typeof(TEnum)`. |
| `void SetSelectedValue<TEnum>(TEnum value)` | Assigns `EnumType` (if needed) and selects `value`. |
| `TEnum GetSelectedValue<TEnum>()` | Returns the current value cast to `TEnum` (or `default`). |

### Events

| Event | Args | Description |
| --- | --- | --- |
| `SelectedValueChanging` | `KryptonEnumButtonValueChangingEventArgs` | Raised **before** the value changes. Set `Cancel = true` to veto. Carries `CurrentValue`, `ProposedValue`, and `ProposedDisplayText`. |
| `SelectedValueChanged` | `EventArgs` | Raised whenever the selected value changes (click, cycle, keyboard, wheel, or programmatic set). Also drives data binding. |
| `EnumValueChanged` | `KryptonEnumButtonValueChangedEventArgs` | Same trigger as `SelectedValueChanged`, but carries the new `Value` (object) and `DisplayText`. |
| `Click` (inherited) | `EventArgs` | Still raised on every click, after the value has been cycled. |

`KryptonEnumButtonValueChangedEventArgs` exposes `object? Value` and `string DisplayText`.
`KryptonEnumButtonValueChangingEventArgs` derives from `CancelEventArgs` and exposes `CurrentValue`,
`ProposedValue`, and `ProposedDisplayText`.

## Usage

### In code (primary pattern)

```csharp
using Krypton.Toolkit.Utilities;

var button = new KryptonEnumButton
{
    EnumType = typeof(DayOfWeek)   // shows "Sunday", cycles to "Monday", ...
};

button.EnumValueChanged += (s, e) =>
{
    var day = (DayOfWeek)e.Value!;
    Console.WriteLine($"Now: {day} ({e.DisplayText})");
};
```

### With `DescriptionAttribute` and humanised names

```csharp
public enum PizzaSize
{
    [Description("Small (9\")")]  Small,
    [Description("Medium (11\")")] Medium,
    [Description("Large (13\")")]  Large,
    ExtraLarge                     // no description
}

button.EnumType = typeof(PizzaSize);      // "Small (9")" ... then "ExtraLarge"
button.UseDescriptionAttribute = false;   // now shows field names
button.HumanizeNames = true;              // "ExtraLarge" -> "Extra Large"
```

### Ordering and filtering

```csharp
button.SortOrder = EnumButtonSortOrder.Alphabetical;   // cycle by member name
button.ExcludedValues = new object[] { PizzaSize.ExtraLarge };  // drop a value from the cycle
```

### Vetoing a change

```csharp
button.SelectedValueChanging += (s, e) =>
{
    if (e.ProposedValue is PizzaSize.ExtraLarge && !UserHasPremium)
    {
        e.Cancel = true;   // keep the current value
    }
};
```

### Per-value images

```csharp
var icons = new Dictionary<TrafficLight, Image> { /* ... */ };
button.ImageProvider = value => icons[(TrafficLight)value];
```

### Data binding

`SelectedValue` is `[Bindable(true)]` and raises `SelectedValueChanged`, so it participates in
standard WinForms binding:

```csharp
label.DataBindings.Add("Text", button, "SelectedValue", true, DataSourceUpdateMode.Never);
```

### Keyboard and mouse wheel

While the button has focus, the arrow keys cycle the value (Left/Up = previous, Right/Down = next)
and the mouse wheel cycles it (up = previous, down = next). Disable via `AllowKeyboardCycling` /
`AllowMouseWheelCycling`.

### Strongly-typed helpers and programmatic cycling

```csharp
button.SetSelectedValue(PizzaSize.Large);        // assigns EnumType + selects Large
PizzaSize current = button.GetSelectedValue<PizzaSize>();

button.WrapAround = false;   // stop at the ends instead of looping
button.CycleNext();
button.CyclePrevious();
```

## Design-time enum picker

Because there is no built-in property-grid editor for a `Type`, the `EnumType` property carries an
`[Editor(typeof(EnumTypeEditor), typeof(UITypeEditor))]` attribute. `EnumTypeEditor` is a drop-down
`UITypeEditor` that uses the design host's `ITypeDiscoveryService` to list every publicly-visible
enumeration available in the current project, so the type can be chosen directly in the property grid
(a `(none)` entry clears it). Assigning in code (in the form constructor after `InitializeComponent`)
remains fully supported.

Each control also has a designer (`KryptonEnumButtonDesigner` /
`KryptonEnumCommandLinkButtonDesigner`) providing a smart-tag action list for the common behaviour
toggles (wrap, reverse-on-right-click, sort order, keyboard/wheel cycling, description/humanise text,
palette). The command-link designer deliberately derives from `ControlDesigner` (not
`KryptonCommandLinkButtonDesigner`) so it does **not** offer Heading/Description/Image text editing,
which are enum-driven at runtime.

## Accessibility

Each control returns a dedicated accessible object (`KryptonEnumButtonAccessibleObject` /
`KryptonEnumCommandLinkButtonAccessibleObject`, both built on the shared
`UtilitiesActionControlAccessibleObject<T>`). They report:

- **Name / Value** — the current display text (heading for the command link).
- **Description** — the current value's description, or `"Cycles through <EnumName> values"`.
- **Role** — `PushButton`, with a `"Cycle"` default action that performs a click.

## Configuration / persistence

Neither control has XML/`Storage` state of its own. For designer scenarios:

- `EnumType` serializes as `typeof(X)` (default `null`, so it is only written when assigned).
- `SelectedIndex` serializes as an `int` (default `0`).
- The behaviour flags (`WrapAround`, `UseDescriptionAttribute`, `HumanizeNames`, `SortOrder`,
  `ReverseOnRightClick`, `AllowKeyboardCycling`, `AllowMouseWheelCycling`) serialize as their
  non-default values.
- `ExcludedValues` and the provider callbacks (`ImageProvider`, `HeadingProvider`,
  `DescriptionProvider`) are code-only and not serialized.
- `Text` (and the command-link heading/description) are derived and not serialized.
- WinForms serializes properties alphabetically, so `EnumType` is written before `SelectedIndex`;
  the engine keeps a designer-written `SelectedIndex` on the first (from-`null`) `EnumType`
  assignment rather than forcing a reset.

## Command-link variant: KryptonEnumCommandLinkButton

`KryptonEnumCommandLinkButton` provides the same enum-cycling behaviour but renders as a
`KryptonCommandLinkButton` (bold heading + smaller description sub-text, optional UAC shield icon).

- **Base type:** `Krypton.Toolkit.Utilities.KryptonCommandLinkButton` (which extends
  `VisualSimpleBase`, not `KryptonButton`), so it inherits the command-link layout, `StateCommon`
  palette states, `ButtonStyle`, `KryptonCommand`, `DialogResult`, and `UACShieldIcon`.
- **Text mapping (per value):**
  - **Heading** ← the enum field name (humanised when `HumanizeNames` is `true`), or
    `HeadingProvider(value)` when set.
  - **Description** ← the value's `DescriptionAttribute` text (when `UseDescriptionAttribute` is
    `true`), or `DescriptionProvider(value)` when set, otherwise blank.
- A single enum decorated with `[Description]` therefore fills **both** command-link lines with no
  extra work — the member name becomes the heading and its description becomes the sub-text.

It exposes the same members as `KryptonEnumButton` (including `HumanizeNames`, `SortOrder`,
`ExcludedValues`, `AllowKeyboardCycling`, `AllowMouseWheelCycling`, `ImageProvider`, and the
`SelectedValueChanging` / `SelectedValueChanged` / `EnumValueChanged` events), plus:

| Member | Type | Description |
| --- | --- | --- |
| `SelectedHeadingText` | `string` | The heading currently shown for the selected value. |
| `SelectedDescriptionText` | `string` | The description currently shown for the selected value. |
| `HeadingProvider` | `Func<object, string>?` | Optional callback for custom heading text (code-only, not serialized). |
| `DescriptionProvider` | `Func<object, string>?` | Optional callback for custom description text (code-only, not serialized). |

`EnumValueChanged.DisplayText` (and `SelectedValueChanging.ProposedDisplayText`) carry the **heading**
for this control. Its `ImageProvider` sets `CommandLinkTextValues.Image` and disables the default
command-link image so a per-value icon can be shown.

```csharp
public enum BackupMode
{
    [Description("Backs up your files automatically on a schedule.")] Automatic,
    [Description("You choose exactly what and when to back up.")]     Manual,
    [Description("No backups are taken. You are on your own!")]       Disabled
}

var link = new KryptonEnumCommandLinkButton { EnumType = typeof(BackupMode) };
// Heading:    "Automatic"
// Description: "Backs up your files automatically on a schedule."
// after a click -> "Manual" / "You choose exactly what and when to back up."
```

## Edge cases

- **No `EnumType`:** the value list is empty, `SelectedValue` is `null`, clicks/keys/wheel do not
  cycle, and the existing `Text` (or command-link heading/description defaults) is left untouched.
- **Non-enum type:** assigning a non-enum `Type` throws `ArgumentException`.
- **Duplicate underlying values / `[Flags]` enums:** each declared member is a separate cycle entry
  (reflection over fields, not `Enum.GetValues`).
- **Excluding the current value:** if `ExcludedValues` removes the currently selected value, the
  selection falls back to the first remaining value.
- **Design mode:** clicking, keyboard, and wheel do not cycle while hosted in the WinForms designer;
  `KryptonEnumButton` shows a `(KryptonEnumButton)` placeholder when no `EnumType` is assigned.
- **`net472` compatibility:** the controls use only APIs available on `net472` (`Array.Empty<T>`,
  `CustomAttributeExtensions.GetCustomAttribute<T>`, the `struct, Enum` generic constraint,
  `ITypeDiscoveryService`).
