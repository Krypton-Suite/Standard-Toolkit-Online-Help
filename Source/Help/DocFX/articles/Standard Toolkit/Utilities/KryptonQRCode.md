# KryptonQRCode

## Overview

`KryptonQRCode` displays a QR code generated natively from UTF-8 text without external QR libraries. It inherits `KryptonPanel` for palette-aware backgrounds and optional centre logo rendering.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Default property:** `Content`  
**Implements:** [#3305](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3305)

## Key properties

| Property | Description |
| --- | --- |
| `Content` | Text or data to encode (UTF-8) |
| `ErrorCorrectionLevel` | `L`, `M`, `Q`, or `H` |
| `ModuleSize` | Pixel size per QR module |
| `DarkColor` / `LightColor` | Module colours (`Color.Empty` = palette defaults) |
| `ShowBorder` | Quiet-zone border around modules |
| `CenterImage` | Optional logo overlay |
| `CenterImageRelativeSize` | Logo size relative to code (default 0.22) |
| `CenterImageUsePaletteColors` | Remap logo through palette rules |

Centre-image palette integration: `CenterImagePaletteStyle`, `CenterImageColorMap`, `CenterImageColorTo`, `CenterImageTransparentColor`, `CenterImageEffect`.

## Usage

```csharp
using Krypton.Toolkit.Utilities;

var qr = new KryptonQRCode
{
    Content = "https://example.com",
    ErrorCorrectionLevel = QRErrorCorrectionLevel.M,
    ModuleSize = 4,
    Dock = DockStyle.Fill
};
```

## See also

- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
- `TestForm` QR code scenarios
