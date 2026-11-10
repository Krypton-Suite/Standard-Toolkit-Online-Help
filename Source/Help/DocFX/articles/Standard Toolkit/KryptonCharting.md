# Krypton.Charting

`Krypton.Charting` is a signed WinForms library for timeline controls. It is not its own NuGet package. `Krypton.Standard.Toolkit` packs `Krypton.Charting.dll` (and the modern-TFM designer assembly) beside the other suite binaries.

## Packages

| Project | Role |
| --------- | ------ |
| `Krypton.Charting` | Runtime controls. References `Krypton.Toolkit` and `Krypton.Interop` (`PrivateAssets=all`). |
| `Krypton.Charting.Design` | Out-of-process designers for modern Windows TFMs. Sources live under `Krypton.Charting\Designers` and are linked here. |
| `Krypton.Standard.Toolkit` | Packs the runtime DLL into `lib\{tfm}\` and `Krypton.Charting.Design.dll` into `lib\{tfm}\Design\WinForms\Server\` for non-net4 TFMs. |

`[Designer]` uses `KryptonWinFormsDesignerSdk.AssemblyName`, which is `Krypton.Charting` on .NET Framework and `Krypton.Charting.Design` otherwise. Designers stay `internal`.

* [Krypton Timeline](Charting/KryptonTimeline.md)