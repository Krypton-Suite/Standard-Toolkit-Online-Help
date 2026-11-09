# KryptonSVGPictureBox

`KryptonSVGPictureBox` is a toolbox control that rasterizes static SVG markup. It lives in `Krypton.Drawing`, which is not published as its own NuGet package. Consumers get it from `Krypton.Standard.Toolkit`.

## Overview

Issue [#4657](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4657). The control accepts SVG text, a file, or a stream, and draws a cached bitmap. `Krypton.Toolkit` does not reference `Krypton.Drawing`. `Krypton.Standard.Toolkit` project-references it with `PrivateAssets=All` and packs the assembly.

Drawing uses Windows Direct2D (`ID2D1SvgDocument`). That API arrived in Windows 10 version 1703 (build 15063). Every target framework compiles that path, including `net472`, `net48`, and `net481`. The package does not ship Svg.Skia, SkiaSharp, HarfBuzzSharp, ExCSS, or their native binaries.

Supported on Windows 10 and higher only. On Windows 7, 8, 8.1, and on Windows 10 builds before 1703, `SvgError` is set and nothing is painted. For Windows 7, 8, and 8.1 support, see [Extended Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit).

The Direct2D device is created once, on the UI thread, the first time markup is parsed. Availability is the `ID2D1DeviceContext5.CreateSvgDocument` probe, not `Environment.OSVersion`. The parameterless constructor does not parse SVG and does not create the device.

## Architecture

```
KryptonSVGPictureBox
        |
        v
KryptonSvgDocuments.TryOpen
        |
        +---- KryptonSvgIntrinsicSize    viewBox, else absolute width/height
        +---- KryptonSvgDirect2D         one process-wide ID2D1DeviceContext5
                 d3d11.dll     D3D11CreateDevice (hardware, then WARP), BGRA support
                 d2d1.dll      ID2D1Factory1.CreateDevice, then ID2D1Device5.CreateDeviceContext
                 shlwapi.dll   SHCreateMemStream for the SVG bytes
        |
        v
Krypton.Drawing  ---- ProjectReference ---- Krypton.Toolkit
        |
        +---- packed into Krypton.Standard.Toolkit
                 lib/{tfm}/     Krypton.Drawing.dll
```

`Krypton.Drawing` is `IsPackable=false` and signed with `StrongKrypton.snk`. It also references `Krypton.Interop` (`PrivateAssets=all`) because Toolkit does not flow that reference (issue #3908). P/Invoke stays in `Krypton.Drawing`. There is no SharpDX or Vortice package.

`SetDpi(96, 96)` makes one DIP one bitmap pixel. The control chooses the pixel size. `CreateSvgDocument` uses that size as the viewport, so Stretch, Zoom, Normal, CenterImage, and AutoSize stay in `KryptonSVGPictureBox`.

Readback is a Direct2D target bitmap, copied into a `CPU_READ | CANNOT_DRAW` bitmap, then mapped into a `Format32bppPArgb` `Bitmap`. Direct2D output is premultiplied. A 1x1 CPU-readable bitmap is the capability probe. If that probe fails, later opens report that Direct2D SVG is not available.

COM objects for each document are released after the parse check and after each draw. The shared device context lives for the process.

## Public API

Namespace `Krypton.Drawing`. The control derives from `Control`, not `PictureBox`, so the designer does not serialize a raster `Image` in place of the markup.

| Member | Default | Behavior |
|--------|---------|----------|
| `Svg` | `""` | Markup. Empty clears the picture. Invalid markup is kept, the picture is cleared, and `SvgError` is set. The setter does not throw. |
| `SizeMode` | `PictureBoxSizeMode.Normal` | `Normal` and `CenterImage` use the intrinsic size. `StretchImage` fills the client area. `Zoom` fits and keeps the aspect ratio. `AutoSize` sets the client size to the intrinsic size. |
| `LoadFromFile(string)` | | Reads the file as UTF-8 text and assigns `Svg`. |
| `Load(Stream)` | | Reads UTF-8 text and leaves the stream open. |
| `SvgError` | `null` | Last parse failure, or `null` when the markup is empty or valid. Hidden from the designer. |
| `ToolTipValues` | default storage | Same Krypton tooltip popup as `KryptonPictureBox`. |

A bad document paints nothing. The picture is static. This version does not play SMIL animation.

Intrinsic size comes from the root `viewBox`, otherwise from absolute `width` and `height` (`px`, `in` = 96, `cm`, `mm`, `pt`, `pc`). Percentages are rejected. Missing or non-positive bounds set `SvgError` to "The SVG document has no drawable bounds." A failed `CreateSvgDocument` sets "The SVG document could not be parsed." A failed draw sets "The SVG document could not be drawn." When Direct2D SVG is missing, the message is "Direct2D SVG is not available on this version of Windows."

The document is parsed when `Svg` changes and drawn again when the client size, DPI, or `SizeMode` changes. The raster pixel size is the logical draw size times `DeviceDpi / 96`, and each edge is capped at 8192. Pixels are copied into a cached `Format32bppPArgb` bitmap and that bitmap is drawn in `OnPaint`. The document and the bitmap are released when `Svg` changes and in `Dispose`.

There is no `Krypton.Drawing.Design` project and no `Microsoft.WinForms.Designer.SDK` reference. `Svg` and `SizeMode` are stock string and enum properties. A parameterless construct does not show designer **Modified** storage.

## Usage

```csharp
var picture = new Krypton.Drawing.KryptonSVGPictureBox
{
    Dock = DockStyle.Fill,
    SizeMode = PictureBoxSizeMode.Zoom,
    Svg = "<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 120 60\"><rect width=\"120\" height=\"60\" fill=\"#1b3a4b\"/></svg>"
};
picture.ToolTipValues.EnableToolTips = true;
picture.ToolTipValues.Heading = "Diagram";
picture.LoadFromFile(@"C:\art\mark.svg");
```

Reference `Krypton.Standard.Toolkit` (or project-reference `Krypton.Drawing` plus `Krypton.Toolkit` in this repo). The aggregate package copies `Krypton.Drawing.dll` into `lib/{tfm}/` for every target framework. Modern Windows folders use `lib/net10.0-windows7.0` and `lib/net11.0-windows7.0`. There is no Skia `native\win-*` folder.

On net4x the package still includes `System.Memory`, `System.Buffers`, `System.Runtime.CompilerServices.Unsafe`, and `System.Numerics.Vectors` when those files are in the shared output. Preserialized resources need that closure, and `SuppressDependenciesWhenPacking` does not flow the dependency group.

## Edge cases

- Invalid markup sets `SvgError` and paints nothing. It does not throw from the setter or from `OnPaint`.
- Windows 7, 8, 8.1, and Windows 10 before version 1703 set `SvgError` and paint nothing. `net472`, `net48`, and `net481` still compile the Direct2D path, because those TFMs also run on Windows 10 and later.
- `AutoSize` assigns `ClientSize`. A `Dock = Fill` parent overwrites that size. Undock the control when the intrinsic size should stick.
- DPI uses `DeviceDpi / 96`. The bitmap is in physical pixels and is drawn into the logical rectangle so the Graphics DPI transform stays 1:1.
