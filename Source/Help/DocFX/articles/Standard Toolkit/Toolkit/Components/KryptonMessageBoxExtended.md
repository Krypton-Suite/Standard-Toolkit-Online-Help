# KryptonMessageBoxExtended

## Overview

`KryptonMessageBoxExtended` is a static API in **`Krypton.Toolkit.Utilities`** that extends [KryptonMessageBox](KryptonMessageBox.md) with additional buttons, icons, timeouts, countdown buttons, rich footer content, custom checkbox text, and layout options.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Type:** Static class (`ToolboxItem(false)`)

## Comparison with KryptonMessageBox

| Feature | `KryptonMessageBox` | `KryptonMessageBoxExtended` |
| --- | --- | --- |
| Standard buttons/icons | Yes | Yes (+ extended sets) |
| Timeout auto-close | Limited | `useTimeOut`, `timeOut`, `timerResult` |
| Countdown on a button | No | `countdownButton`, `countdownButtonSeconds` |
| Footer area | Basic | Text, link, or custom footer types |
| Message alignment | Default | `messageTextAlignment`, text box alignment |
| Extra buttons | No | `ExtendedMessageBoxButtons` |

## Basic usage

```csharp
using Krypton.Toolkit.Utilities;

DialogResult result = KryptonMessageBoxExtended.Show(
    "Save changes before closing?",
    "Confirm",
    ExtendedMessageBoxButtons.YesNoCancel,
    ExtendedKryptonMessageBoxIcon.Question);
```

## Timeout example

```csharp
DialogResult result = KryptonMessageBoxExtended.Show(
    messageText: "Session expires soon.",
    caption: "Warning",
    buttons: ExtendedMessageBoxButtons.OK,
    icon: ExtendedKryptonMessageBoxIcon.Warning,
    useTimeOut: true,
    timeOut: 30,
    timerResult: DialogResult.OK);
```

## Countdown button

Use with [KryptonCountdownButton](../../Toolkit Utilities/KryptonCountdownButton.md) semantics on dialog buttons:

```csharp
KryptonMessageBoxExtended.Show(
    "Delete this item?",
    "Confirm",
    ExtendedMessageBoxButtons.YesNo,
    ExtendedKryptonMessageBoxIcon.Warning,
    countdownButton: ExtendedKryptonMessageBoxCountdownButton.Button1,
    countdownButtonSeconds: 10,
    countdownButtonDialogResult: DialogResult.Yes);
```

Additional overloads support owner window, custom icons, checkbox text, footer links, and `ShowCore` parameters for advanced scenarios — see source `KryptonMessageBoxExtended.cs`.

## See also

- [KryptonMessageBox](KryptonMessageBox.md)
- [KryptonMessageBox API Documentation](KryptonMessageBoxAPIDocumentation.md)
- [Krypton Toolkit Utilities index](../../Toolkit Utilities/KryptonToolkitUtilitiesIndex.md)
