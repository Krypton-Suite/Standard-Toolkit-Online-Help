# KryptonButton ElevatedClick

`KryptonButton.ElevatedClick` is the click path for a command that will require elevation. While a handler is attached, the UAC shield stays visible so the button cannot look like an ordinary command. When the process is not already an administrator, the button starts the target executable with the RunAs verb. A content image stays in place and the shield is drawn on top of it. With no content image, the shield is the button image.

Owner: `Krypton.Toolkit`. Issue [#4648](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4648).

## Architecture

`KryptonButton` stores the event and raises it from `OnClick` before `KryptonDropButton.OnClick`. Before the event, when the process is not already an administrator, `OnClick` starts `ElevatedProcessPath` (or `Application.ExecutablePath` when that property is empty) with `UseShellExecute = true` and `Verb = "runas"`. A `Win32Exception`, including the user dismissing the UAC prompt (native error 1223), skips both `ElevatedClick` and `Click`. An already-elevated process does not start a second copy. The base `OnClick` still assigns `DialogResult`, raises `Click`, and runs `KryptonCommand` when the launch succeeds or is skipped because the process is already an administrator.

The first subscriber calls `ButtonValues.LockUacShieldForElevation`, which sets `UseAsUACElevationButton` and paints the shield through the existing imageres / fallback path. `AssignUacShieldImage` chooses the slot. A content image that is not the shield bitmap this method just wrote stays in `Image`, and the shield is assigned to `OverlayImage` (`Position` `BottomRight`, `ScaleMode` `Percentage`, the existing 0.5 factor). With no content image the shield is written to `Image`, because `RenderStandard` paints `GetOverlayImage` only when the content image is drawn.

A private lock flag (not part of `IsDefault`) makes `UseAsUACElevationButton = false` a no-op and rejects changes to `OverlayImage.Image` through `OverlayImageValues.RejectImageChange`. `Image` can still be set: a new content image moves the shield onto the overlay, and clearing `Image` moves the shield back onto `Image` so it stays visible. Shield refreshes (`UACShieldIconSize`, `IconSelectionStrategy`, and the internal assign) set `_applyingUacShield` so they bypass that reject hook.

The last unsubscribe calls `UnlockUacShieldForElevation`. That clears the lock only. The shield stays until code sets `UseAsUACElevationButton` to false. Turning the flag off clears the overlay only when this code placed the shield there. A previous user overlay is not restored. A content image is kept.

`KryptonCheckButton`, `KryptonPoweredByButton`, and `KryptonAlternateCommandLinkButton` inherit the event because they call `base.OnClick`. `KryptonDropButton`, `KryptonSplitButton`, and `KryptonColorButton` do not.

## Public API

```csharp
public event EventHandler? ElevatedClick;
public string ElevatedProcessPath { get; set; }
protected virtual void OnElevatedClick(EventArgs e);
```

`Click` remains the default event. `ElevatedClick` is category Action. `ElevatedProcessPath` is category Behavior, defaults to empty, and is not serialized until set (`ShouldSerializeElevatedProcessPath` is true when the string is non-empty; null is stored as empty). Empty means `Application.ExecutablePath`.

The handler does not call `Process.Start`. The button does that with `UseShellExecute = true` and verb `runas`.

While any `ElevatedClick` handler is attached:

- `Values.UseAsUACElevationButton` stays `true`. Assigning `false` is ignored.
- `Values.Image` can change. A content image keeps the shield on `Values.OverlayImage`. Clearing `Image`, or `ResetImage()` when the factory image is null, moves the shield back onto `Image`.
- `Values.OverlayImage.Image` cannot replace or clear the shield.
- `Values.UACShieldIconSize` can still change the shield size.

Showing the shield makes `Values` not default, the same as `UseAsUACElevationButton`. A fresh button with no image and no subscriber stays unmodified in the property grid.

## Usage

```csharp
var restart = new KryptonButton
{
    Text = "Restart as administrator"
};
restart.ElevatedClick += (sender, args) =>
{
    // The button already started this process with Verb = "runas"
    // when the current principal was not Administrator.
};
```

Set `ElevatedProcessPath` to launch a different executable. Assign `Values.Image` before the handler when the shield should overlay that picture. The handler is attached before the form is shown. `InitializeComponent` wires events after property sets, so a designer value of `UseAsUACElevationButton = false` is overridden when the form runs.

## Edge cases

- Design time does not attach the form's handler to the design-surface instance, so a new button stays unmodified in the property grid until the event is used at run time.
- `Click`, dialog result, and `KryptonCommand` still run after `ElevatedClick` when RunAs succeeds or the process is already an administrator. Dismissing the UAC prompt raises neither event.
- The original process still runs the handler after a successful RunAs launch. Do not repeat the privileged work there; the new process is the elevated one.
- Removing the last handler does not hide the shield. The content image stays. An overlay placed for the shield is removed only when `UseAsUACElevationButton` is set to false, and a previous user overlay is not put back.
- The lock is not serialized. A fresh toolbox button with no subscriber is not **Modified**.

## Validation

`TestForm` `ButtonsTest` (Start Screen: **Buttons Test**). The Elevated Click button has a content image so the shield is a bottom-right overlay. The existing Normal UAC Button has no content image and keeps the shield as its image. A click logs `ElevatedClick (already Administrator)` or `ElevatedClick (RunAs launch requested)`, then `Click`. An empty `ElevatedProcessPath` restarts TestForm when the process is not already an administrator. Dismissing the UAC prompt leaves the log unchanged. Hiding the shield still logs `Hide ignored: shield still shown.`

`Scripts/UnitTests/Invoke-ElevatedClickScreenshot.ps1` hosts the overlay against `Krypton.Toolkit` and writes `Documents/PR/4648-elevated-click-demo.png`. It does not click the button, so it does not open the UAC consent dialog.

Consumer example: append the same scenario to `KryptonButton Examples` in [Standard-Toolkit-Demos](https://github.com/Krypton-Suite/Standard-Toolkit-Demos) on a branch from `alpha`. Do not replace `Form1`. The local Demos clone was left unchanged because it is on `alpha-4550-caption-textbox` with unrelated uncommitted work.
