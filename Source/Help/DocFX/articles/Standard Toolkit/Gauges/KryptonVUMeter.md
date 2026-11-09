# Krypton VU meter

`KryptonVuMeter` is a display control in `Krypton.Gauges` (issue #4655). It paints one meter. A stereo pair is two controls. `Krypton.Gauges` is not its own NuGet package. `Krypton.Gauges.dll` is included in the `Krypton.Standard.Toolkit` package.

The control does not take keyboard or mouse input. The painted indicator eases toward the target level (about 300 ms by default). That ease is not an IEC 60268 certification.

## Types

| Type | Role |
| ------ | ------ |
| `KryptonVuMeter` | Toolbox control. `Value` is the bindable target and stays in step with `Values.Value`. |
| `VuMeterValues` | Style, range, target, capture settings, and peak hold. |
| `StateCommon`, `StateNormal`, `StateDisabled` | Palette colours for the face, ticks, needle, peak, and segments. |
| `VuMeterStyle` | `Analog` (default) or `Segments`. |
| `VuMeterInputMode` | `Manual` (default) or `Capture`. |
| `VuMeterChannel` | `Left` (default), `Right`, or `Mix`. Used only while capturing. |

Namespace: `Krypton.Gauges`.

## Scale

The default range is -20 to +3 VU. A new control rests at -20, which is the left stop (segments off). Marks inside the range use classic spacing, tighter toward +3:

-20, -10, -7, -5, -3, -2, -1, 0, +1, +2, +3

0 and above is the red zone. `Minimum` and `Maximum` can narrow the scale. Marks outside that range are omitted. The analog face ignores `Orientation`. Segments use `VisualOrientation`: `Left` and `Right` are a horizontal row, `Top` and `Bottom` are a vertical column (`Bottom` grows upward).

## Setting the level

```csharp
var meter = new KryptonVuMeter();
meter.Values.Value = -6;
meter.Values.PeakHold = true;
```

`Value` on the control is `[DefaultBindingProperty]` and is not written into the designer file. Edit `Values` in the property grid. While `InputMode` is `Capture`, assignments are ignored.

`DisplayedValue` is the eased level currently painted. `ValueChanged` fires when the target changes, not on every animation frame.

## Capture

`InputMode = VuMeterInputMode.Capture` opens the default recording device (console role) with shared-mode WASAPI. There is no extra audio package.

- Capture starts when the handle exists and the mode is `Capture`. It does not start in the designer.
- It stops when the mode returns to `Manual`, the handle is destroyed, or the control is disposed.
- `Channel` selects left, right, or a mix of every channel.
- `CalibrationOffsetDb` defaults to -18, so 0 VU is about -18 dBFS. This is a digital alignment, not a studio calibration.
- `CaptureFailed` fires when the device cannot be opened (no endpoint, or Windows microphone privacy). The meter keeps the last level and the mode returns to `Manual`.

```csharp
meter.CaptureFailed += (sender, e) => status.Text = e.Message;
meter.Values.InputMode = VuMeterInputMode.Capture;
meter.Values.Channel = VuMeterChannel.Mix;
```

Two meters can capture the same device in shared mode. The TestForm demo captures on the analog meter and copies `ValueChanged` onto the segmented meter so only one client is opened.

## Appearance

Colours come from the palette. `StateCommon` is the shared set. `StateNormal` is used while the control is enabled, and `StateDisabled` while it is disabled. Leave a colour empty to inherit. A fresh drop inherits everything, so the property grid is not modified.

| Property | Default palette source |
| ---------- | ------------------------ |
| `Face.Color1` | Input control background |
| `Face.Color2` | Input control border |
| `Tick.Color1`, `Needle.Color1`, `SegmentLow.Color1` | Control label text |
| `Peak.Color1` | Checked dock header |
| `SegmentHigh.Color1` | Pressed link |
| `SegmentOff.Color1` | Standalone button background |

`StateCommon.Back` is the background behind the face. `PanelBackStyle` selects that background.

```csharp
meter.StateNormal.Needle.Color1 = Color.Firebrick;
meter.StateNormal.SegmentHigh.Color1 = Color.Firebrick;
meter.StateNormal.SegmentLow.Color1 = Color.SeaGreen;
```

Peak hold draws a second needle, or lights the peak segment, then lets it fall after `PeakHoldMilliseconds` (default 1500) over `PeakDecayMilliseconds` (default 2000).
