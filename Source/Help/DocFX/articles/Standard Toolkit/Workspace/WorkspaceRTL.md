# Krypton Workspace RTL

## Overview

Issue [#2383](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2383) adds **logical** right-to-left packing for `KryptonWorkspace` horizontal sequences. Nested navigator chrome already follows `Control.RightToLeft` via `KryptonWorkspaceCell : KryptonNavigator`. This work mirrors **cell tiling**, **separator drag**, and **left/right drop insert** without GDI-mirroring cell contents and without rewriting XML.

Package: `Krypton.Workspace`. Docking document areas (`KryptonSpace` : `KryptonWorkspace`) inherit the behaviour. Form-edge docking chrome is out of scope.

## Architecture

Workspace layout is a tree of `KryptonWorkspaceSequence` / `KryptonWorkspaceCell`. `Children` order is the source of truth for persistence, designers, and `KryptonDocumentGroupHelper`.

RTL is a **view transform** applied only when packing a **horizontal** sequence:

1. Star allocation (passes 1–4 of `LayoutSequenceNonMaximized`) still walks collection order.
2. Pass #5 places items from `client.Right` when both RTL flags are set (`WorkspaceRtlLayout.NextItem`).
3. Vertical sequences still pack top-to-bottom.

```
Form.RightToLeft + Form.RightToLeftLayout
        |
        v
KryptonWorkspace.RightToLeftLayout  (copied; no WS_EX_LAYOUTRTL)
        |
        v
CommonHelper.IsRightToLeftLayout(workspace)
        |
        +-- Horizontal pack from the right
        +-- Negate vertical-separator mouse delta
        +-- Swap Left/Right drop insert mapping
```

Do **not** set `WS_EX_LAYOUTRTL` on the workspace. That would GDI-mirror nested cells (the class of bugs tracked by [#2103](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2103)).

## Public API

### `KryptonWorkspace.RightToLeftLayout`

`bool`, default `false`. Named to match WinForms `Form.RightToLeftLayout`, not the Toolkit `RightToLeftLayout` enum.

Packing requires **both**:

- `RightToLeft == RightToLeft.Yes` (usually inherited from the form)
- `RightToLeftLayout == true` (copied from the parent `Form` on parent/handle change)

Setting only `RightToLeft` (text direction) does **not** reverse columns.

### Drop and helpers

- Physical left/right **hot rects** are unchanged. `DragTargetWorkspaceEdge` / `DragTargetWorkspaceCellEdge` swap Left/Right **insert** mapping when the gate is on, so a drop on the physical left still appears on the visual left.
- `KryptonDocumentGroupHelper.SplitActiveCell` / `MovePageToNewCell` still insert **after** in `Children` order. Under RTL that collection-after cell is visually to the left of a horizontal split.

## Usage

On a `KryptonForm` (or any `Form`):

```csharp
form.RightToLeft = RightToLeft.Yes;
form.RightToLeftLayout = true;
```

The hosted `KryptonWorkspace` copies the layout flag and packs horizontal sequences from the right. Vertical stacks stay top-to-bottom. `SaveLayoutToArray` / `LoadLayoutFromArray` keep the same `Children` order.

## Edge cases

- **Maximized cell:** still fills the client; RTL packing does not apply while maximized.
- **Nested horizontal sequences:** each horizontal sequence packs from the right of **its** allocated rect.
- **Separator drag:** before/after remain collection neighbours; the X delta is negated so dragging toward the visual-right panel shrinks it (`KryptonSplitContainer` RTL).
- **Docking:** document-area workspaces inherit this. Auto-hide / docked windows on the form edges are a separate Docking RTL topic.
