# Dialog Overlay Images (#4162)

## Overview

Optional macOS-style badge overlays for dialog icons, using shared Toolkit types:

- `KryptonOverlayImage` — options (defaults: BottomRight, Percentage 0.5)
- `GraphicsExtensions.ComposeOverlayImage` / `TryComposeOverlay`

Surfaces:

| Dialog | Assembly | API |
|--------|----------|-----|
| `KryptonMessageBoxExtended` | Utilities | `KryptonMessageBoxExtendedData.OverlayImage`; `Show(..., overlayImage, overlayImagePosition)` |
| `KryptonMessageBox` | Toolkit | `Show(..., overlayImage, overlayImagePosition)` on fullest overloads; `ShowCore` |
| `KryptonTaskDialog` heading | Toolkit | `Heading.OverlayImage` |
| `KryptonAboutBox` | Utilities | `KryptonAboutBoxData.MainImageOverlay` |

Control overlays (`OverlayImageValues`) still default to **TopRight**; dialog badges default to **BottomRight**.

## Usage

### MessageBox Extended

```csharp
var data = new KryptonMessageBoxExtendedData
{
    MessageText = "Save complete.",
    Icon = ExtendedKryptonMessageBoxIcon.Application,
    ApplicationPath = Application.ExecutablePath,
    OverlayImage = new KryptonOverlayImage(badgeImage)
};
KryptonMessageBoxExtended.Show(data);
```

### Core MessageBox

```csharp
KryptonMessageBox.Show(owner, text, caption, buttons, displayHelpButton: false,
    icon, defaultButton, options,
    overlayImage: badgeImage,
    overlayImagePosition: OverlayImagePosition.BottomRight);
```

### TaskDialog heading

```csharp
dialog.Heading.IconType = KryptonTaskDialogIconType.Shield;
dialog.Heading.OverlayImage = new KryptonOverlayImage(badgeImage);
```

### AboutBox

```csharp
var data = new KryptonAboutBoxData
{
    MainImage = appLogo,
    MainImageOverlay = new KryptonOverlayImage(badgeImage),
    // ...
};
KryptonAboutBox.Show(data);
```

## Show overload disambiguation (Extended)

`KryptonMessageBoxExtended` has owner `Show` overloads that differ by `bool displayHelpButton` vs `string helpFilePath` after `options`. Named-only calls with `customImageIcon` / `overlayImage` can be ambiguous. Prefer:

- the `KryptonMessageBoxExtendedData` path, or
- a positional `false` (displayHelpButton) immediately after `options`.

## Validation

TestForm: **4162 MessageBox Extended Overlay Image** (`MessageBoxExtendedOverlayImageDemo`).
