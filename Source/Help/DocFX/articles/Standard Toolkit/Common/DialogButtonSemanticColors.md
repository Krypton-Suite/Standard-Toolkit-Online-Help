# Dialog Button Semantic Colours

## Overview

Issue [#4165](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4165) adds **optional** semantic colours for dialog action buttons (accept / cancel / help / neutral), inspired by macOS red cancel chrome and extended with colour-blind-friendly presets.

Packages:

- `Krypton.Toolkit` — core types, `KryptonMessageBox`, `KryptonTaskDialog`, `KryptonManager.DialogButtonColors`
- `Krypton.Toolkit.Utilities` — `KryptonMessageBoxExtended`, `KryptonFoldableDialog`

Default behaviour is unchanged: buttons keep themed `Standalone` chrome until options (or the manager default) are supplied.

## Architecture

Call sites pass `KryptonDialogButtonColorOptions` (or rely on `KryptonManager.DialogButtonColors`). After dialog buttons receive their `DialogResult`, `KryptonDialogButtonAppearance.Apply` maps the result to a role, resolves preset colours plus overrides, and paints `StateCommon`, tracking/pressed, and `OverrideDefault`.

```text
Show API / data bag  -->  KryptonDialogButtonColorOptions
KryptonManager.DialogButtonColors  -.->  (fallback when call-site is null)
                         |
                         v
            KryptonDialogButtonAppearance.Apply
                         |
                         v
            Role (Accept / Cancel / Help / Neutral) --> palette fills
```

Help buttons do not set `DialogResult`; dialogs apply `KryptonDialogButtonRole.Help` explicitly after configuring the Help button.
## Public API

### `KryptonDialogButtonColorScheme`

| Value | Purpose |
|-------|---------|
| `None` | Off (themed chrome) |
| `Standard` | macOS-inspired green accept / red cancel / blue help |
| `Deuteranopia` | Blue accept / orange cancel / purple help |
| `Protanopia` | Blue accept / brown cancel / magenta help |
| `HighContrast` | Strong HC fills (lime / yellow / cyan / white) |
| `Custom` | Overrides only |

### `KryptonDialogButtonColorOptions`

- `Scheme`
- Optional overrides: `AcceptBackColor` / `AcceptBorderColor` / `AcceptTextColor`, and matching Cancel / Help / Neutral properties
- `IsActive` — true when scheme is not `None` or any override is set
- Static factories: `Standard`, `Deuteranopia`, `Protanopia`, `HighContrast`, `CreateCustom()`

### `KryptonDialogButtonAppearance`

- `GetEffectiveOptions(callSite)` — call-site if provided, else manager default
- `GetRole(DialogResult)` — Accept: OK/Yes/Continue; Cancel: Cancel/No/Abort; else Neutral (not Help)
- `Apply(button, DialogResult, …)` / `Apply(button, KryptonDialogButtonRole, …)` — use the role overload for Help
- `TryResolveColors` / palette-triple `Apply` overloads

### `KryptonManager.DialogButtonColors`

Application-wide default used when a dialog call does not pass options.

## Usage

### MessageBox

```csharp
KryptonMessageBox.Show(
    this,
    "Save changes?",
    "Confirm",
    KryptonMessageBoxButtons.YesNoCancel,
    KryptonMessageBoxIcon.Question,
    KryptonDialogButtonColorOptions.Standard);
```

### TaskDialog

```csharp
taskDialog.FooterBar.CommonButtons.ButtonColors =
    KryptonDialogButtonColorOptions.Deuteranopia;
```

### MessageBoxExtended / FoldableDialog

```csharp
data.ButtonColors = new KryptonDialogButtonColorOptions
{
    Scheme = KryptonDialogButtonColorScheme.Standard,
    CancelBackColor = Color.FromArgb(200, 40, 40)
};
```

### App-wide default

```csharp
KryptonManager.DialogButtonColors = KryptonDialogButtonColorOptions.Standard;
```

## Accessibility

- Localized button **text** remains the primary cue; colour is reinforcement only.
- Prefer Deuteranopia / Protanopia / HighContrast when targeting colour-vision deficiency or HC environments.
- Help / Copy / Action buttons map to Neutral (Standard leaves them themed unless Neutral overrides are set).

## Validation

TestForm demo: **4165 Dialog Button Colours** (`DialogButtonColorsDemo`), registered in `StartScreen.AddButtons()`.

```text
dotnet run --project ".\Source\Krypton Components\TestForm\TestForm.csproj" -c Debug
```