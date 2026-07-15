# Krypton floating toolbars

## Overview

Floating toolbar types extend `KryptonToolStrip` and `KryptonMenuStrip` so users can tear off toolbars into separate themed windows and dock them back with visual preview.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`

| Type | Purpose |
| --- | --- |
| `KryptonFloatableToolStrip` | Floatable `KryptonToolStrip` |
| `KryptonFloatableMenuStrip` | Floatable `KryptonMenuStrip` |
| `KryptonFloatablePanelHost` | Host panel for float/dock infrastructure |
| `KryptonToolStripPanelExtended` | Extended `ToolStripPanel` with active docking rectangle |
| `KryptonMenuStripPanelExtended` | Extended panel for menu-strip docking |

## Key features

- Drag handle to float toolbar into its own window
- `FloatingStateChanged` event when float/dock state changes
- Optional docking preview overlay (`ShowDockingPreview`, preview colours)
- `EnableAnimation` / `AnimationDuration` for float transitions
- `FloatingWindowStyle` for window chrome options

## Usage

```csharp
using Krypton.Toolkit.Utilities;

var toolStrip = new KryptonFloatableToolStrip
{
    Dock = DockStyle.Top,
    ShowDockingPreview = true
};
toolStrip.FloatingStateChanged += (_, e) =>
{
    // React to float/dock changes
};
```

Place floatable strips on [panel hosts](KryptonFloatingToolbarPanels.md) (`KryptonToolStripPanelExtended`, `KryptonMenuStripPanelExtended`, or `KryptonFloatablePanelHost`) for full dock-zone support.

## See also

- [Floating toolbar panel hosts](KryptonFloatingToolbarPanels.md) — `KryptonToolStripPanelExtended`, `KryptonMenuStripPanelExtended`, `KryptonFloatablePanelHost`
- [KryptonToolStrip](../Toolkit/Controls/KryptonToolStrip.md)
- [KryptonMenuStrip](../Toolkit/Controls/KryptonMenuStrip.md)
- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
