# Dialog DPI and content sizing

Toolkit dialogs size themselves from their content and the monitor that will show them. A designer `ClientSize` is a 96 DPI starting point. It is not the size the user sees when the text is long or the display is scaled.

`KryptonMessageBox` already measured its text and buttons. This note covers the shared helper and the dialogs that now use it.

## Owner

`Krypton.Toolkit` owns `KryptonDialogLayout`. `Krypton.Toolkit.Utilities` calls the same helper for the about box, bug report, foldable dialog, checksum dialogs, theme builder, log viewer, palette editor, OAuth login, splash manager, Font Awesome picker, and toasts.

## What the helper does

`KryptonDialogLayout` (internal) is the only place that turns a fixed border into a resizable one and that clamps a window to the working area.

| Method | Use it for |
|--------|------------|
| `FitWrappedPrompt` | A wrap label inside an auto-sized table (input box). |
| `FitClientToText` | Docked text. The form grows; the label fills the client. |
| `EnableResizable` | Tool dialogs. Fixed borders become sizable, `MaximumSize` is cleared, and the design window size becomes `MinimumSize` when none was set. |
| `ClampToWorkingArea` | Keep the window inside the owner monitor after a DPI change. |

`EnableResizable` does not multiply a size WinForms has already scaled. `AutoScaleMode.Font` still scales the designer layout. The helper then shrinks the window if that scaled size is larger than the working area. Prompts pass `useContentFractions: true` (two-thirds of the width, 95% of the height), matching the message box. Tool windows use the full working area.

`FitWrappedPrompt` measures the label twice. The table often narrows the label after the first measure, which adds a wrap line, and the palette font is only final after the form is shown. The input box therefore calls it from both `OnLoad` and `OnShown`. The second pass sets the label `MinimumSize` height from `TextRenderer` at the client width so a later layout cannot clip the last line.

Per-monitor awareness still depends on the host process (`Application.SetHighDpiMode(HighDpiMode.PerMonitorV2)` or the application manifest). The helper reads the DPI WinForms reports for the owner window.

## Which dialogs

Left as they were:

- `KryptonMessageBox`, the RTL message box, and both extended message boxes (`UpdateSizing`).
- `VisualCustomFileDialogForm` (its own `ScaleSize` and `DpiChanged` path).
- `KryptonTaskDialog` (already sized from its elements).

Content-sized, border stays fixed:

- `VisualInputBoxForm` and `VisualInputBoxRtlAwareForm`
- `ModalWaitDialog`
- `VisualInformationBoxForm` is measured, then made resizable so a clamped message can still be enlarged

Resizable, with the detail surface scrolling or docking:

- Exception dialogs (Toolkit and Utilities), bug report, both GitHub issue reports
- Splash, theme browser and its RTL twin, changelog, print preview, conversion, toolkit binary information
- Designer editors, including the ones that used to lock `MaximumSize` to the client size
- About box, foldable dialog, checksum dialogs, custom theme builder, log viewer, palette collection editor, OAuth login, Font Awesome picker
- Toasts, from `VisualToastBaseForm` (close-box chrome is sizable; borderless toasts stay borderless)

Shell open, save, folder, colour, font, and print dialogs still use the native client size. When that size is missing, the 900×600 fallback is scaled from 96 DPI. `AutoScaleMode.None` does not follow a later DPI change, so the wrapper applies `DpiChangedEventArgs.SuggestedRectangle` and clamps.

## Validation

- TestForm: `KryptonDialogExamples` (Start screen, "Krypton Dialog tests"). Use **Long input prompt** and **Exception dialog**.
- `Scripts/UnitTests/UnitTest-DialogDpiLayout.ps1` (`include`).

Standard-Toolkit-Demos was not updated in the same change when that clone was already on another feature branch with local edits. Add the long-prompt case to the existing input-box example on a new `alpha-…` branch from `alpha` once that tree is free.
