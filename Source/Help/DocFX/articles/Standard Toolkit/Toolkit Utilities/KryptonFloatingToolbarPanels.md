# Floating toolbar panel hosts

## Overview

Panel host types extend `ToolStripPanel` to support the float/dock infrastructure used by `KryptonFloatableToolStrip` and `KryptonFloatableMenuStrip`. They expose an **active docking rectangle** (`ActiveRectangle` / `ActiveArea`) that defines the valid drop zone when re-docking a floated toolbar.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`

| Type | Purpose |
| --- | --- |
| `KryptonToolStripPanelExtended` | Dock zones for floatable **tool strips** |
| `KryptonMenuStripPanelExtended` | Dock zones for floatable **menu strips** |
| `KryptonFloatablePanelHost` | Combined host linking one floatable strip + optional menu strip |

For floatable strip behaviour (tear-off, preview overlay, animation), see [KryptonFloatingToolbars](KryptonFloatingToolbars.md).

## KryptonToolStripPanelExtended

Standard dock panel for `KryptonFloatableToolStrip` instances.

### Key members

| Member | Description |
| --- | --- |
| `ActiveRectangle` | Current valid docking bounds (minimum 23 px on the docked edge) |
| `Orientation` | `Horizontal` or `Vertical` — sets added `ToolStrip.LayoutStyle` |

### Designer integration

`KryptonFloatableToolStrip.KryptonToolStripPanelExtendedList` holds registered dock panels. Use the **ToolStrip Panel Collection** editor on the floatable strip to add panels from the form.

```csharp
var topPanel = new KryptonToolStripPanelExtended
{
    Dock = DockStyle.Top,
    Name = "toolStripPanelTop"
};

var floatableStrip = new KryptonFloatableToolStrip();
floatableStrip.KryptonToolStripPanelExtendedList.Add(topPanel);
topPanel.Controls.Add(floatableStrip);
```

`KryptonFloatableToolStrip.Dock(KryptonToolStripPanelExtended? targetPanel)` re-docks to a specific panel when floating ends.

## KryptonMenuStripPanelExtended

Dock panel for `KryptonFloatableMenuStrip`.

| Member | Description |
| --- | --- |
| `ActiveRectangle` | Valid docking bounds |
| `KryptonFloatableMenuStrip` | Associated floatable menu strip reference |

```csharp
var menuPanel = new KryptonMenuStripPanelExtended { Dock = DockStyle.Top };
var menuStrip = new KryptonFloatableMenuStrip();
menuPanel.KryptonFloatableMenuStrip = menuStrip;
menuPanel.Controls.Add(menuStrip);
```

## KryptonFloatablePanelHost

General-purpose `ToolStripPanel` that wires layout for either a floatable menu strip or tool strip:

| Member | Description |
| --- | --- |
| `ActiveArea` | Valid docking bounds |
| `KryptonFloatableMenuStrip` | Optional menu strip reference |
| `KryptonFloatableToolStrip` | Optional tool strip reference |

On `OnControlAdded`, sets `LayoutStyle` on added `MenuStrip` / `ToolStrip` based on panel `Orientation`.

Use when a single host panel should coordinate one floatable chrome element without the extended-list collection model.

## Layout notes

- When the panel client size is smaller than 23 px on the docked axis, `ActiveRectangle` / `ActiveArea` is expanded so docking targets remain usable.
- Dock edge (`Top`, `Bottom`, `Left`, `Right`) adjusts rectangle offset for bottom/left/right docked panels.
- Floatable strips show `ShowDockingPreview` overlays against these rectangles during drag-back.

## Form layout pattern

```text
Form
├── KryptonToolStripPanelExtended (Dock Top)     ← dock zones
├── KryptonToolStripPanelExtended (Dock Left)
├── KryptonMenuStripPanelExtended (Dock Top)   ← optional menu zone
└── Client area
```

Register all panels on each `KryptonFloatableToolStrip` via `KryptonToolStripPanelExtendedList` so the strip knows valid dock targets when dragged from a floated window.

## See also

- [KryptonFloatingToolbars](KryptonFloatingToolbars.md) — `KryptonFloatableToolStrip`, `KryptonFloatableMenuStrip`
- [KryptonToolStrip](../Toolkit/Controls/KryptonToolStrip.md)
- [KryptonMenuStrip](../Toolkit/Controls/KryptonMenuStrip.md)
- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
