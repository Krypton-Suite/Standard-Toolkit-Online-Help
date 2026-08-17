# VisualForm / KryptonForm fade in/out (`FadeValues`)

Package: `Krypton.Toolkit`.

## Overview

`VisualForm` (and therefore `KryptonForm`) can fade in when shown and fade out when closing. Fading is **opt-in** and **off by default**, so existing forms are unchanged. Settings live on `VisualForm.FadeValues` next to `ShadowValues` / `BlurValues` and serialize in the designer.

This replaces the old `Thread.Sleep` opacity loops (see TestForm `FadeFormTest`) and the commented `VisualForm.FadeValues` stub. Opacity is stepped with a WinForms `Timer` (10 ms) so the UI message pump stays alive.

## Architecture

```
VisualForm.FadeValues           (designer-serializable settings)
    -> VisualForm.OnShown       (auto fade-in when FadingEnabled && FadeIn)
    -> VisualForm.OnFormClosing (cancel close, fade-out, then Close)
    -> FadeIn / FadeOut / FadeOutAndClose (manual, ignore FadingEnabled)
KryptonForm.SetVisibleCore      (skips borderless opacity snap when auto fade-in is active)
```

Speed presets map through internal `KryptonFormFadeSpeed` units: each tick adds or subtracts `units / 1000` from `Form.Opacity`. `Normal` (50) is about 0.2 s; `Slowest` (1) is about 10 s; `Fastest` (100) is about 0.1 s.

`KryptonFormFadeController` remains the internal helper used by async dialog wrappers. Native form fading does **not** call `Show()` from the fade engine (the form is already visible).

## Public API

### `VisualForm.FadeValues`

| Property | Default | Role |
|---|---|---|
| `FadingEnabled` | `false` | Automatic fade-in on show and fade-out on close |
| `FadeIn` | `true` | Used when `FadingEnabled` is true |
| `FadeOut` | `true` | Used when `FadingEnabled` is true |
| `FadeSpeed` | `Normal` | `FadeSpeedChoice` preset |
| `CustomFadeSpeed` | `50` | Used only when `FadeSpeed == Custom`. Typical range 1–100 |

### Methods and events

- `FadeIn()` — fade from the current opacity to the target (usually 1, or the designer `Opacity` if it was set before show).
- `FadeOut()` — fade to transparent; does **not** close.
- `FadeOutAndClose()` — fade to transparent, then close.
- `FadeInCompleted` / `FadeOutCompleted`.

Manual methods work even when `FadingEnabled` is `false`.

## Usage

Designer: expand **FadeValues** on a `KryptonForm` and set `FadingEnabled` to `true`.

```csharp
var form = new KryptonForm();
form.FadeValues.FadingEnabled = true;
form.FadeValues.FadeSpeed = FadeSpeedChoice.Slow;
form.Show();
```

```csharp
// One-shot animation without enabling automatic fading
form.FadeValues.FadeSpeed = FadeSpeedChoice.Fast;
form.FadeIn();
```

## Edge cases

- **Default off** — no behavior change for existing `KryptonForm` subclasses.
- **Designer** — `DesignMode` skips auto fade so the designer surface does not animate.
- **Close reasons** — `WindowsShutDown`, `TaskManagerClosing`, and `ApplicationExitCall` skip fade-out so the process can exit.
- **User cancel** — `FormClosing` handlers run first. If they set `e.Cancel`, fade-out does not start.
- **Borderless first show** — the Windows 11 borderless opacity snap is skipped when a native fade-in is active so the two do not fight.
- **Target opacity** — fade-in restores the `Opacity` captured before the form is shown (not always 1.0).
- **Message boxes** — `KryptonMessageBoxExtended` `UseFade` is a separate Utilities path. Do not also set `FadeValues.FadingEnabled` on the same instance.
- **Toasts** — `VisualToastBaseForm` inherits `KryptonForm` and can use `FadeValues` if a toast host opts in.

## Validation

TestForm demo: `FadeFormTest`, registered as **KryptonForm FadeValues**.

1. Open the demo — the form fades in.
2. **Fade Out** then **Fade In** — opacity animates without closing.
3. Edit `FadeValues.FadeSpeed` in the property grid and fade again.
4. **Open faded child** — a second `KryptonForm` with `FadingEnabled` fades in; close it to fade out.
5. Close the demo (title-bar close or **Fade Out and Close**) — fade-out then close.
6. Set `FadingEnabled` to `false` in the grid, reopen — no automatic fade.
