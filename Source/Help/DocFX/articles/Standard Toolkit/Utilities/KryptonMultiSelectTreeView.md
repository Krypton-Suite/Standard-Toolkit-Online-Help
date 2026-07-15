# KryptonMultiSelectTreeView

**Assembly:** `Krypton.Toolkit.Utilities`  
**Namespace:** `Krypton.Toolkit.Utilities`  
**Type:** `KryptonMultiSelectTreeView`  
**Base type:** `Krypton.Toolkit.KryptonTreeView`  
**Introduced:** V110

---

## Overview

`KryptonMultiSelectTreeView` is a Krypton-styled tree view that adds **ListView-style extended selection** to hierarchical data. WinForms `TreeView` is single-select at the operating-system level; this control maintains its own multi-selection model and paints additional selected rows using Krypton theming (`StateMultiSelect`, `StateCheckedMultiSelect`).

Use it when you need:

- Multiple highlighted nodes at once
- Ctrl+click toggle, Shift+click range, and rubber-band drag selection
- Optional check-box selection synchronized with the selection set
- A first-class `SelectedNodes` collection and change notification

The control ships in **`Krypton.Toolkit.Utilities`** (same NuGet surface as `KryptonTreeComboBox`, `KryptonFileSystemTreeView`, `KryptonCircularProgressBar`, and other utility controls).

---

## Quick start

### Toolbox

1. Add a reference to `Krypton.Toolkit.Utilities`.
2. Drop **KryptonMultiSelectTreeView** from the toolbox (bitmap shared with `KryptonTreeView`).
3. Populate `Nodes` as with any tree view.
4. Handle `SelectedNodesChanged` to react to selection updates.

### Minimal code

```csharp
using Krypton.Toolkit.Utilities;

var tree = new KryptonMultiSelectTreeView
{
    Dock = DockStyle.Fill,
    CheckBoxes = true,
    FullRowSelect = true
};

tree.Nodes.Add(new TreeNode("Parent"));
tree.Nodes[0].Nodes.Add(new TreeNode("Child A"));
tree.Nodes[0].Nodes.Add(new TreeNode("Child B"));
tree.Nodes[0].Expand();

tree.SelectedNodesChanged += (_, _) =>
{
  Console.WriteLine($"Selected: {tree.SelectedNodes.Count} node(s)");
};

---

## Architecture

### Inheritance

```
VisualControlBase
    └── KryptonTreeView          ← Krypton styling, owner-draw, palettes
            └── KryptonMultiSelectTreeView   ← multi-selection model
```

`KryptonMultiSelectTreeView` hosts the same internal `TreeView` as `KryptonTreeView` (exposed via the `TreeView` property). Mouse input for rubber-banding is wired to that inner control; rubber-band overlay painting is done on the outer `KryptonMultiSelectTreeView` because Krypton replaces the inner tree’s `WmPaint` path.

### Dual selection model

| Concept | API | Role |
|--------|-----|------|
| **Focus node** | `SelectedNode` (inherited) | Single native tree selection; keyboard focus and primary node |
| **Multi-selection** | `SelectedNodes` | All nodes in the current extended selection set |

- Only **one** node has native `SelectedNode` / focus at a time.
- **Many** nodes can appear selected via `SelectedNodes` and `IsNodeMultiSelected` painting.
- Programmatic focus changes use `_suppressSelectionHandling` so they do not re-enter selection logic.

### Core `KryptonTreeView` hook

`KryptonTreeView` exposes:

```csharp
protected virtual bool IsNodeMultiSelected(TreeNode node) => false;
```

`KryptonMultiSelectTreeView` overrides this to return `_selectedNodeSet.Contains(node)`. The owner-draw path treats such nodes as selected for row highlight, selected images, and multi-select palette overrides—without requiring each node to be the native `SelectedNode`.

---

## Features

### 1. Plain click

- Replaces the selection with the clicked node.
- Sets the **selection anchor** (used by subsequent Shift+click).
- Updates `SelectedNodes`, check boxes (when enabled), and raises `SelectedNodesChanged`.

When `EnableRubberBandSelection` is `true`, plain clicks are **deferred to mouse-up** so a small movement can start a rubber-band drag instead of immediately changing selection.

### 2. Ctrl+click (toggle)

- Adds or removes the clicked node from `SelectedNodes` without clearing the rest.
- Sets focus to the clicked node.
- Updates the selection anchor to the clicked node (standard modifier-click semantics).

Handled immediately in `BeforeSelect` (not deferred to rubber-band logic).

### 3. Shift+click (range)

- Selects the **inclusive** range of **visible** nodes between:
  - the **selection anchor**, resolved in order from:
    1. Last plain-click anchor (`_selectionAnchor`)
    2. `SelectedNode`
    3. First entry in `SelectedNodes`
  - and the clicked node.
- Range order follows WinForms flat display order: `Nodes[0]` then `TreeNode.NextVisibleNode` (same order as on screen for expanded nodes).
- Replaces the current selection (does not merge with unrelated prior selections).
- **Does not** move the anchor on Shift+click (anchor stays at the node from the last plain click), matching Explorer/ListView behaviour.

**Example** (all parents expanded):

```
Parent 1
  Child 1.1
  Child 1.2
Parent 2
  Child 2.1
  Child 2.2
```

Click **Child 1.1**, then Shift+click **Child 2.1** → selects:  
`Child 1.1`, `Child 1.2`, `Parent 2`, `Child 2.1` (inclusive).

### 4. Rubber-band drag

- Enabled when `EnableRubberBandSelection` is `true` (default).
- Plain left-button down starts a pending drag; moving more than **4 pixels** begins rubber-band mode.
- A semi-transparent dotted rectangle is drawn on the outer control during drag.
- On mouse-up, every **visible** node whose bounds intersect the band is selected.
- Hold **Ctrl** during release to **extend** the existing selection instead of replacing it.
- Ctrl/Shift held on mouse-down **bypass** rubber-band deferral so modifier clicks work immediately.

Clicks on **plus/minus** or **state image** (check-box glyph) areas do not start rubber-banding.

### 5. Check-box selection

When `CheckBoxes = true` and `SyncCheckBoxesToSelection = true` (defaults):

| User action | Effect |
|-------------|--------|
| Check a node | Adds it to `SelectedNodes` (extends selection) |
| Uncheck a node | Removes it from `SelectedNodes` |
| Change selection via click/drag/range | Updates **all** nodes’ `Checked` to match membership in `SelectedNodes` |

Sync runs inside `TreeView.BeginUpdate` / `EndUpdate` over **all** nodes in the tree (including collapsed branches). Programmatic `Checked` changes do not recurse into `AfterCheck` while `_syncingCheckState` is set.

### 6. Inherited `KryptonTreeView` behaviour

All standard tree features remain available unless they conflict with the multi-selection model:

- Krypton palettes and themes (`StateNormal`, `StateMultiSelect`, etc.)
- `ImageList`, `StateImageList`, `KryptonTreeNode`, `FullRowSelect`, `ShowLines`, `ShowPlusMinus`
- Expand/collapse, drag-and-drop (`ItemDrag`), label edit, sorting
- `BeginUpdate` / `EndUpdate`, `Nodes`, `TopNode`, hit-testing

**Not used:** base `KryptonTreeView.MultiSelect` (checkbox-on-click toggle). The derived type hides that property; selection is managed exclusively by `KryptonMultiSelectTreeView`.

---

## API reference

### Type metadata

| Attribute | Value |
|-----------|--------|
| `[ToolboxItem(true)]` | Yes |
| `[DefaultEvent]` | `SelectedNodesChanged` |
| `[DefaultProperty]` | `Nodes` |
| `[Designer]` | `KryptonMultiSelectTreeViewDesigner` |

---

### New properties

#### `SelectedNodes`

```csharp
[Browsable(false)]
public ReadOnlyCollection<TreeNode> SelectedNodes { get; }
```

- Read-only view of the current multi-selection.
- Order: visible flat order first, then any selected nodes not currently visible (e.g. under collapsed parents).
- Empty when nothing is selected.
- Do not assume the underlying list is mutable; use `SetSelectedNodes`, `ClearSelectedNodes`, or user input to change selection.

---

#### `EnableRubberBandSelection`

```csharp
[Category("Behavior")]
[DefaultValue(true)]
public bool EnableRubberBandSelection { get; set; }
```

- `true`: plain clicks defer to mouse-up; drag starts rubber-band selection.
- `false`: plain clicks follow normal `BeforeSelect` path immediately (no drag rectangle).

---

#### `SyncCheckBoxesToSelection`

```csharp
[Category("Behavior")]
[DefaultValue(true)]
public bool SyncCheckBoxesToSelection { get; set; }
```

- `true`: `Checked` ↔ `SelectedNodes` stay aligned (see [Check-box selection](#5-check-box-selection)).
- `false`: check boxes and `SelectedNodes` are independent; `AfterCheck` does not update `SelectedNodes`.

Requires `CheckBoxes = true` for any check-box UI.

---

#### `MultiSelect` (hidden)

```csharp
[Browsable(false)]
public new bool MultiSelect { get; set; }  // getter always false; setter ignored
```

Shadows `KryptonTreeView.MultiSelect`. The legacy checkbox-toggle-on-click behaviour is **not** active on this control.

---

### New methods

#### `SetSelectedNodes`

```csharp
public void SetSelectedNodes(IEnumerable<TreeNode> nodes)
```

Replaces the entire selection with `nodes`. Throws `ArgumentNullException` if `nodes` is null. Does not change focus unless you also set `SelectedNode`.

---

#### `ClearSelectedNodes`

```csharp
public void ClearSelectedNodes()
```

Clears `SelectedNodes` and syncs check boxes. Native `SelectedNode` is unchanged unless it was removed from the set implicitly (clearing does not auto-clear `SelectedNode`).

---

#### `SelectAllVisibleNodes`

```csharp
public void SelectAllVisibleNodes()
```

Selects every node visible in the current expansion state (depth-first, expanded children only). Does not select nodes hidden inside collapsed parents.

---

### New events

#### `SelectedNodesChanged`

```csharp
[Category("Behavior")]
public event EventHandler? SelectedNodesChanged;
```

Raised after the selection set changes and check-box sync completes. **Not** raised when `ApplySelection` detects an identical set but still runs check-box sync on the early-return path—only focus may update in that case without a raised event.

Override `OnSelectedNodesChanged(EventArgs e)` to extend behaviour in derived types.

---

### Protected members (extensibility)

| Member | Purpose |
|--------|---------|
| `IsNodeMultiSelected(TreeNode node)` | Returns whether `node` is in `_selectedNodeSet`; drives Krypton multi-highlight painting |
| `OnPaint(PaintEventArgs? e)` | Draws rubber-band overlay when active |
| `OnSelectedNodesChanged(EventArgs e)` | Raises `SelectedNodesChanged` |

---

### Important inherited members

| Member | Notes |
|--------|--------|
| `Nodes` | Root `TreeNodeCollection` |
| `SelectedNode` | Single focus node; updated by `FocusSelectedNode` during multi-select operations |
| `CheckBoxes` | Enable check-box UI and optional sync |
| `FullRowSelect` | Default `true` in constructor; recommended for rubber-band and range selection |
| `TreeView` | Inner `TreeView`; avoid reparenting |
| `AfterSelect`, `BeforeSelect`, `NodeMouseClick`, `AfterCheck`, … | Standard tree events; selection logic also hooks `BeforeSelect` / `AfterCheck` |
| `StateMultiSelect`, `StateCheckedMultiSelect` | Palette triples for multi-selected row appearance |
| `PerformNeedPaint`, `Invalidate` | Triggered after selection changes |

See `KryptonTreeView` XML documentation for the full inherited API.

---

## Selection anchor

The **anchor** is internal (`_selectionAnchor`) but drives Shift+click behaviour:

- Set on **plain** left-click (not Ctrl/Shift).
- **Preserved** on Shift+click range operations.
- Updated on Ctrl+click to the toggled node.
- Rubber-band with Ctrl extend may set anchor to the last hit node on completion.

If you set selection only via `SetSelectedNodes` without updating focus, resolve order for Shift+click still uses `SelectedNode` or the first `SelectedNodes` entry as fallback.

---

## Programmatic selection patterns

### Replace selection

```csharp
var nodes = new[] { tree.Nodes[0], tree.Nodes[0].Nodes[1] };
tree.SetSelectedNodes(nodes);
tree.SelectedNode = nodes[^1]; // optional explicit focus
```

### Add to selection without clearing

There is no public `AddToSelection` API; use Ctrl+click semantics internally or pass a union:

```csharp
var merged = tree.SelectedNodes.Concat(new[] { extraNode }).Distinct();
tree.SetSelectedNodes(merged);
```

### Clear everything

```csharp
tree.ClearSelectedNodes();
tree.SelectedNode = null;
```

### Select all expanded nodes

```csharp
tree.SelectAllVisibleNodes();
```

### React to changes

```csharp
tree.SelectedNodesChanged += (_, _) =>
{
    foreach (TreeNode node in tree.SelectedNodes)
    {
        // ...
    }
};
```

---

## Theming and visual states

Multi-selected nodes (in `SelectedNodes` but not native `SelectedNode`) are painted using:

- `StateMultiSelect` / `StateCheckedMultiSelect` palette overrides
- `_overrideMultiSelect.Apply` when the node is multi-selected only (no native focus)

Customize these on the control instance or via the applied Krypton palette, same as other `KryptonTreeView` node states.

The native focus node uses standard selected + focused styling. Additional selected rows use multi-select styling without the focus ring unless they also have focus.

---

## Designer

`KryptonMultiSelectTreeViewDesigner` is a thin `ControlDesigner` with `AutoResizeHandles = true`. Behaviour and appearance in the Visual Studio designer follow `KryptonTreeView`; `SelectedNodes` is hidden from the property grid (`Browsable(false)`).

---

## Implementation notes (contributors)

### Internal helpers (`TreeViewMultiSelectHelper`)

| Helper | Purpose |
|--------|---------|
| `GetFlatVisibleNodes(TreeView)` | Flat list via `Nodes[0]` + `NextVisibleNode` |
| `GetInclusiveVisibleRange(anchor, end)` | Inclusive Shift+click range |
| `EnumerateVisibleNodes` | Depth-first expanded traversal |
| `EnumerateAllNodes` | Full tree traversal (check-box sync) |
| `GetNodeBounds` | `TVM_GETITEMRECT` (64-bit safe) with layout fallback |
| `NormalizeRectangle` | Rubber-band rectangle |

### Input routing summary

```
MouseDown (plain)     → rubber-band pending (if enabled)
BeforeSelect          → cancelled while pending; Ctrl/Shift handled here when not pending
MouseUp (plain)       → deferred click selection
MouseMove + drag      → rubber-band active, overlay painted
MouseUp (band)        → hit-test visible nodes in rectangle
```

### Pruning

`PruneInvalidNodes` removes entries whose `TreeView` is null (e.g. after node removal) before applying new selection.

---

## Limitations and edge cases

| Scenario | Behaviour |
|----------|-----------|
| Shift+click with no prior anchor | Selects only the clicked node (same as plain click) |
| Nodes under collapsed parents | Not in visible range or rubber-band hits until expanded |
| `SelectAllVisibleNodes` | Only expanded/visible nodes; not the entire tree |
| `SelectedNode` vs `SelectedNodes` | May diverge when only programmatic APIs are used; user input keeps them aligned |
| Right-click | Does not change multi-selection by default (standard tree context) |
| `KryptonTreeView.MultiSelect` | Disabled; do not enable via reflection |
| Check boxes with `SyncCheckBoxesToSelection = false` | Manual check state does not affect `SelectedNodes` |

---

## Comparison: `KryptonTreeView.MultiSelect` vs `KryptonMultiSelectTreeView`

| | `KryptonTreeView.MultiSelect` | `KryptonMultiSelectTreeView` |
|--|-------------------------------|------------------------------|
| Selection model | Toggles `Checked` on click | `SelectedNodes` collection |
| Ctrl / Shift / drag | No | Yes |
| `SelectedNodes` API | No (`CheckedNodes` only) | Yes |
| Row highlight | Via checked state | Via `IsNodeMultiSelected` painting |
| Use case | Simple multi check-list in a tree | Full extended selection UX |

---

## File locations

```
Source/Krypton Components/Krypton.Toolkit.Utilities/Components/KryptonMultiSelectTreeView/
├── Controls Toolkit/
│   └── KryptonMultiSelectTreeView.cs
├── General/
│   └── TreeViewMultiSelectHelper.cs
└── Designers/Designers/
    └── KryptonMultiSelectTreeViewDesigner.cs

Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/
└── KryptonTreeView.cs                    ← IsNodeMultiSelected hook
```
