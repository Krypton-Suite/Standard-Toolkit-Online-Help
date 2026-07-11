# KryptonCountdownButton

## Overview

`KryptonCountdownButton` extends `KryptonButton` and appends a live countdown to the button text (for example `Submit (30s)`), decrementing each second until zero.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Inheritance:** `KryptonButton` → `KryptonCountdownButton`

## Key properties

| Property | Description |
| --- | --- |
| `CountdownButtonValues.CountdownDuration` | Initial countdown in seconds |
| `CountdownButtonValues.CountdownInterval` | Timer tick interval (ms) |
| `CountdownButtonValues.CountdownSuffix` | Suffix format appended to button text |
| `IsCountdownRunning` | Whether the countdown timer is active |

`StartCountdown()` disables the button until the countdown completes and raises `CountdownFinished`.

## Usage

```csharp
using Krypton.Toolkit.Utilities;

var btn = new KryptonCountdownButton
{
    Text = "Resend code"
};
btn.CountdownButtonValues.CountdownDuration = 30;
btn.StartCountdown();
```

## See also

- [KryptonButton](../Toolkit/Controls/KryptonButton.md)
- [KryptonMessageBoxExtended](../Toolkit/Components/KryptonMessageBoxExtended.md) — countdown on dialog buttons
