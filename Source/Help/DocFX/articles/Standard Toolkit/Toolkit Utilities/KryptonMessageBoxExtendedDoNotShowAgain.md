# KryptonMessageBoxExtended — Do not show again

## Overview

Optional checkbox on `KryptonMessageBoxExtended` so the user can choose not to see a given prompt again. Owned by `Krypton.Toolkit.Utilities`. Off by default.

The toolkit does **not** write application settings. With a `DoNotShowAgainKey`, suppression lasts for the **current process**. Persist across restarts by storing the `out bool` yourself (user settings, registry, and so on).

## Public API

On `KryptonMessageBoxExtendedData`:

| Member | Role |
| --- | --- |
| `ShowDoNotShowAgainOption` | Show the checkbox. Default `false`. |
| `CheckBoxText` | Optional caption. When empty, `KryptonManager.Strings.CustomStrings.DoNotShowAgain` (`&Do not show again`) is used. |
| `IsCheckBoxChecked` / `CheckBoxCheckState` / `UseCheckBoxThreeState` | Initial checkbox state (existing optional-checkbox fields). |
| `DoNotShowAgainKey` | Caller-defined id. When set and the user checks the box, later `Show` / `ShowAsync` calls with the same key skip the dialog and return the stored `DialogResult`. |

On `KryptonMessageBoxExtended`:

```csharp
DialogResult Show(KryptonMessageBoxExtendedData data, bool showCloseButton = true);
DialogResult Show(KryptonMessageBoxExtendedData data, out bool doNotShowAgain, bool showCloseButton = true);
Task<DialogResult> ShowAsync(KryptonMessageBoxExtendedData data, bool showCloseButton = true);
void ResetDoNotShowAgain(string? key = null);
bool IsDoNotShowAgainSet(string? key);
```

A non-empty `CheckBoxText` still shows the checkbox without `ShowDoNotShowAgainOption`. In that case the toolkit does **not** auto-suppress (the caption might mean something else).

## Usage

### Read the choice (persist it yourself)

```csharp
var data = new KryptonMessageBoxExtendedData
{
    Caption = "Tip",
    MessageText = "You can pin this panel.",
    Buttons = ExtendedMessageBoxButtons.OK,
    Icon = ExtendedKryptonMessageBoxIcon.Information,
    ShowDoNotShowAgainOption = true
};

DialogResult result = KryptonMessageBoxExtended.Show(data, out bool doNotShowAgain);
if (doNotShowAgain)
{
    // Save to settings; skip this Show next time.
}
```

### Process-lifetime key

```csharp
var data = new KryptonMessageBoxExtendedData
{
    Caption = "Welcome",
    MessageText = "First-run notes…",
    Buttons = ExtendedMessageBoxButtons.OK,
    ShowDoNotShowAgainOption = true,
    DoNotShowAgainKey = "welcome-notes"
};

DialogResult result = KryptonMessageBoxExtended.Show(data);
// Later Show with the same key is skipped until:
KryptonMessageBoxExtended.ResetDoNotShowAgain("welcome-notes");
```

`ShowAsync(data)` honours the same key.

## Edge cases

- Empty key: checkbox is shown; nothing is remembered. Use `out bool`.
- Three-state: `UseCheckBoxThreeState` still works; suppression uses `Checked` (`true` only when `CheckState.Checked`).
- RTL data path uses `VisualMessageBoxExtendedForm` with `RightToLeftLayout`. Positional `ShowCoreWithBoolResult` / `ShowCoreWithCheckStateResult` still host the checkbox on LTR and RTL forms (see TestForm `Bug3842MessageBoxExtendedRtlRoutingDemo`).

## Validation

TestForm: **4188 MessageBox Extended Fade / Timeout** (`MessageBoxExtendedLifetimeDemo`).

1. Tick **Do not show again**, Show, tick the dialog checkbox, dismiss.
2. Show again — dialog skipped; result label reports the stored `DialogResult`.
3. **Reset Do not show again** — Show displays the dialog again.
