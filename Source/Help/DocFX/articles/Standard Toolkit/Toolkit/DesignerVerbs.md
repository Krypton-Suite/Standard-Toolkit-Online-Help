# Designer Verbs

Local maintainer notes for WinForms designer verbs (`ComponentDesigner.Verbs`) versus smart tags (`DesignerActionList`). Do not include this file in pull requests.

## Two surfaces

| Surface | API | Where it appears |
|---|---|---|
| Smart tag | `DesignerActionList` | Glyph panel on the selected component |
| Designer verb | `ComponentDesigner.Verbs` | Bottom of the component **context menu** |

Commands belong on verbs. Properties belong on smart tags. `KryptonDesignerActionItem` wraps a `DesignerVerb` for the smart tag only (`IncludeAsDesignerVerb` is `false`). Do not flip that flag on designers that also override `Verbs` — the same command would appear twice.

Newer Utilities lists that do **not** override `Verbs` may pass `includeAsDesignerVerb: true` on `DesignerActionMethodItem` (radial menu, enhanced context menu). That is the other valid pattern; pick one per designer.

## When to add a verb

Add a verb when the action **does something** (add/remove a child, insert a template, import/export, open a collection editor) and native WinForms has a similar command, or the command is hard to discover from the property grid.

Skip verbs for property toggles (`Checked`, palette mode, styles, orientation). Those stay as smart-tag property items.

## How to implement

Copy `KryptonNavigatorDesigner` / `KryptonMenuBarDesigner`:

1. Cache `DesignerVerb` instances in a `DesignerVerbCollection` (do not rebuild on every get).
2. Mutating verbs use `IDesignerHost.CreateTransaction` and `IDesignerHost.CreateComponent`.
3. Notify `IComponentChangeService` so the designer serializes.
4. Enable/disable with `UpdateVerbStatus` on `ComponentChanged` when state matters. `DesignerVerb.Text` is read-only in current TFMs — use a fixed label (or a pair of enabled/disabled verbs), not a rewritten caption.
5. Share the handler between the designer and the action list (static methods on the designer, or a small `*DesignerActions` helper). Do not duplicate import/export dialogs.

`KryptonDesignerCollectionActions.EditProperty` opens a collection `UITypeEditor` from a verb (used by **Edit Items...** on `KryptonContextMenu`).

## Inventory (issue #979)

| Component | Verbs |
|---|---|
| `KryptonManager` | Reset theme, designer editor settings, translation import/export/template/merge/culture |
| `KryptonCustomPaletteBase` | Reset, populate, import/export, upgrade, convert (already present) |
| `KryptonNavigator` | Add / Remove / Clear Pages (already present) |
| `KryptonRibbon` | Helpers, tabs, QAT, tab headers (already present) |
| `KryptonMenuBar` / `KryptonFormTitleBar` | Insert Standard Items (already present) |
| `KryptonContextMenu` | Insert Standard Items, Edit Items... |
| `KryptonHeader` | Add ButtonSpec |
| `KryptonHeaderGroup` | Toggle primary/secondary header, Add ButtonSpec |
| `KryptonWorkspace` / sequence | Add Cell, Add Sequence |
| `KryptonDataGridView` | Native WinForms `DataGridViewDesigner` (Add Column, Edit Columns). `DataGridViewDesigner` is not publicly inheritable — do not replace it with `KryptonDataGridViewDesigner`. |
