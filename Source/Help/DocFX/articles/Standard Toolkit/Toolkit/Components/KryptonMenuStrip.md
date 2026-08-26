# KryptonMenuStrip

`KryptonMenuStrip` is the Krypton equivalent of WinForms `MenuStrip`. It subclasses `MenuStrip`, uses `ToolStripManager` rendering (`KryptonManager.GlobalApplyToolstrips`), and keeps fonts aligned with the active palette via `ToolStripFontSyncHelper`.

## Toolbox

Drop **KryptonMenuStrip** from the Krypton Toolkit toolbox group onto a `KryptonForm` (or any form). Visual Studio uses the standard `MenuStripDesigner` (Insert Standard Items, item collection editor, `MainMenuStrip` wiring).

Prefer `KryptonToolStripMenuItem` for new items so per-item palette overrides match `KryptonContextMenuItem`. Insert Standard Items still creates native `ToolStripMenuItem` instances.

Related toolbox types: `KryptonToolStrip`, `KryptonStatusStrip`, `KryptonToolStripContainer`.

## Fonts and themes

- Palette `MenuStripFont` / `ToolStripFont` / `StatusStripFont` are rebuilt from `PaletteBase.BaseFont` in `DefineFonts()`.
- Theme colour changes do not by themselves change family or size; changing `BaseFont` or a palette that uses a different base font does.
- `KryptonManager` calls `ToolStripFontSync.RefreshAllOpenForms()` on global palette change, including `Form.MainMenuStrip` when the strip is not in `Controls`.
- Native `MenuStrip` / `ToolStrip` / `StatusStrip` / `ContextMenuStrip` on open forms are updated the same way when `GlobalApplyToolstrips` is true.
