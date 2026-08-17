# KryptonMessageBoxExtended fade, timeout, and auto-close

Issue [#4188](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4188). Package: `Krypton.Toolkit.Utilities`.

## Overview

`KryptonMessageBoxExtended` can fade in and out, show remaining time in the caption, and dismiss itself when that timer reaches zero. The preferred surface is `KryptonMessageBoxExtendedData` plus `Show` / `ShowAsync`. Existing `Show(..., useTimeOut, timeOut, timeOutInterval, timerResult)` overloads keep working and now apply `timerResult` instead of closing with `DialogResult.None`.

## Architecture

LTR (`VisualMessageBoxExtendedForm`) and RTL (`VisualRTLMessageBoxExtendedForm`) share `MessageBoxExtendedLifetimeController`. The controller uses WinForms `Timer` instances so ticks run inside the nested `ShowDialog` message pump (the same approach as `KryptonFormFadeController` in Toolkit, which Utilities cannot call because that type is internal).

```
Show / ShowAsync
    -> VisualMessageBoxExtendedForm or VisualRTLMessageBoxExtendedForm
        -> MessageBoxExtendedLifetimeController
            -> fade timer (Form.Opacity)
            -> timeout timer (caption + AutoClose)
```

Do not also set `VisualForm.FadeValues.FadingEnabled` on the same message-box instance; extended `UseFade` is independent. Native form fading is documented in `KryptonForm-FadeValues.md`.

## Public API

Configure on `KryptonMessageBoxExtendedData`:

| Property | Default | Role |
|---|---|---|
| `UseFade` | `false` | Fade in on show and out on close |
| `FadeSpeed` | `Normal` | `FadeSpeedChoice` preset |
| `CustomFadeSpeed` | `null` | Used only when `FadeSpeed == Custom` |
| `UseTimeOut` | `false` | Show remaining seconds in the caption |
| `TimeOut` | `60` | Duration in seconds (`<= 0` treated as 60) |
| `TimeOutInterval` | `1000` | Tick interval in milliseconds |
| `AutoClose` | `null` | `null` means auto-close when `UseTimeOut` is true; `true` silent timer; `false` display-only countdown |
| `TimeOutResult` | `None` | Result when `TimeOutAction == Close`. `None` falls back to the default button result (typically OK) |
| `TimeOutAction` | `Close` | `Close` or `ButtonOne`–`ButtonFour` (`PerformClick` on that button) |

`Show(data)` and `ShowAsync(data)` pick these up automatically.

Existing `Show` overloads: `useTimeOut: true` enables the caption countdown **and** auto-close with `timerResult` (fade stays off on that path).

## Combinations

- `UseTimeOut` only: caption countdown; auto-close at zero.
- `UseTimeOut` + `AutoClose = false`: display-only countdown; the user must dismiss.
- `UseTimeOut = false` + `AutoClose = true`: silent timer then dismiss.
- `TimeOutAction = ButtonTwo`: auto-close by clicking the second visible button.
- `UseFade`: fade in from opacity 0; fade out before the dialog actually closes (user click, timeout, or countdown-button finish).

## Timeout versus countdown button

`ExtendedKryptonMessageBoxCountdownButton` is a separate per-button countdown. Message-box action buttons (`MessageButton`) inherit `KryptonCountdownButton`, so duration, interval, text format, suffix, `EnableButtonAtZero`, `StartCountdown` / `CancelCountdown`, and `CountdownFinished` are the public countdown-button APIs. Form-level timeout is caption + optional auto-close. If both are enabled, the first completion wins; the other timer is stopped. Passing `countdownButtonDialogResult` remains the existing per-button auto-close path.

## Fade and modal dialogs

Opacity is stepped every 10 ms. Fade-in starts from `Shown`. `FormClosing` is cancelled until fade-out completes so `ShowDialog` still returns the original `DialogResult`. Do not use `Thread.Sleep` to animate.

The data-struct path always hosts `VisualMessageBoxExtendedForm` (it can set `RightToLeftLayout`). `MessageBoxOptions.RtlReading` / `RightAlign` on the `Show` overloads host `VisualRTLMessageBoxExtendedForm`, which uses the same lifetime controller.
