# KryptonMenuStrip

`KryptonMenuStrip` is the Krypton equivalent of WinForms `MenuStrip`. It subclasses `MenuStrip`, uses `ToolStripManager` rendering (`KryptonManager.GlobalApplyToolstrips`), and keeps fonts aligned with the active palette via `ToolStripFontSyncHelper`.

It is **not** hosted inside the `KryptonForm` caption. The caption is a painted view (`KryptonFormTitleBar` + `ButtonSpec`s). Use the optional bind below if you want the strip’s items to appear there.

For a native (non-`ToolStrip`) bar in the client area, see `KryptonMenuBar` (#4242) and `KryptonForm.MenuBar`.

## Toolbox

Drop **KryptonMenuStrip** from the Krypton Toolkit toolbox group onto a `KryptonForm` (or any form). Visual Studio uses the standard `MenuStripDesigner` (Insert Standard Items, item collection editor, `MainMenuStrip` wiring).

Prefer `KryptonToolStripMenuItem` for new items so per-item palette overrides match `KryptonContextMenuItem`. Insert Standard Items still creates native `ToolStripMenuItem` instances.

Related toolbox types: `KryptonToolStrip`, `KryptonStatusStrip`, `KryptonToolStripContainer`, `KryptonMenuBar`, `KryptonFormTitleBar`.

## Fonts and themes

- Palette `MenuStripFont` / `ToolStripFont` / `StatusStripFont` are rebuilt from `PaletteBase.BaseFont` in `DefineFonts()`.
- Theme colour changes do not by themselves change family or size; changing `BaseFont` or a palette that uses a different base font does.
- `KryptonManager` calls `ToolStripFontSync.RefreshAllOpenForms()` on global palette change, including `Form.MainMenuStrip` when the strip is not in `Controls`.
- Native `MenuStrip` / `ToolStrip` / `StatusStrip` / `ContextMenuStrip` on open forms are updated the same way when `GlobalApplyToolstrips` is true.

## Title bar (caption) integration

`KryptonFormTitleBar` can optionally **show** a `KryptonMenuStrip` (or `MenuStrip`) in the caption. It does not parent the strip into non-client chrome.

Assign the strip to `KryptonFormTitleBar.MenuStrip`:

```csharp
var strip = new KryptonMenuStrip();
// Designer: Insert Standard Items, or build ToolStripMenuItem trees in code.
form.Controls.Add(strip);
form.MainMenuStrip = strip; // optional; set automatically if empty when HideSourceMenuStrip is true
form.TitleBar = new KryptonFormTitleBar
{
    HideSourceMenuStrip = true, // default: hide the client strip
    MenuStrip = strip
};
```

Designer: on the `KryptonFormTitleBar` component, set **MenuStrip** to the strip on the form (smart-tag **MenuStrip** / **Hide Source MenuStrip**).

### Behaviour

| Piece | What happens |
|---|---|
| Caption buttons | One `ButtonSpecAny` per top-level `ToolStripMenuItem` (separators and combo/text hosts are skipped) |
| Drop-downs | Nested items become a `KryptonContextMenu` on that spec |
| Clicks | Forwarded to the original `ToolStripMenuItem` (`PerformClick`) so existing handlers still run |
| Shortcuts | Stay on the `MenuStrip`. Keep it as `MainMenuStrip` (hidden is fine). Caption copies of `ShortcutKeys` are for display only |
| Serialization | The `MenuStrip` **reference** is serialized. Generated caption specs are **not** (`DesignerSerializationVisibility.Hidden`) |
| Live updates | Top-level `ItemAdded` / `ItemRemoved` rebuild the caption buttons |

`HideSourceMenuStrip` (default `true`) hides the strip so only the caption menus show. If `Form.MainMenuStrip` is empty, the title bar assigns the strip there so Ctrl+N and similar keep working.

Do **not** also call `KryptonFormTitleBar.InsertStandardItems()` for the same File/Edit/Tools/Help tree, or you will get two sets of caption menus.

### One-shot copy

If you want designer-serialized `ButtonSpecs` instead of a live bind:

```csharp
titleBar.ImportFrom(kryptonMenuStrip1); // copies into ButtonSpecs, optionally hides the strip
// or
ButtonSpecAny[] specs = kryptonMenuStrip1.CreateTitleBarButtonSpecs(showDropArrow: false);
```

`ImportFrom` does not keep the strip in sync afterwards. Prefer `MenuStrip` for an ongoing integration.

### What is not mapped

- `ToolStripComboBox`, `ToolStripTextBox`, `ToolStripProgressBar`, and other non-menu hosts
- Top-level separators
- MDI merge lists (those stay on `KryptonMenuStrip` / `MainMenuStrip`)

## Validation

- **TestForm:** `KryptonFormTitleBarDemo` (StartScreen: “Title Bar Menu”). **Bind MenuStrip** / **Unbind MenuStrip**; File → New logs via the original item; Ctrl+N while bound.
- **TestForm:** `KryptonMenuBarDemo` for native `KryptonMenuBar` vs `KryptonMenuStrip` vs `MenuStrip` (not caption bind).
