# Column and Row Styles editor

Themed editor for `KryptonTableLayoutPanel` column and row styles. It opens from the property grid on `ColumnStyles` and `RowStyles` and edits the live panel. The inherited `TableLayoutPanelDesigner` stays in place, so the column and row glyphs and the smart-tag layout commands are unchanged.

## Overview

`ColumnStyles` and `RowStyles` are not virtual, and the stock `StyleCollectionEditor` is what Visual Studio shows today. Replacing `TableLayoutPanelDesigner` would drop those glyphs: on modern target frameworks the design assembly aliases `ControlDesigner` to the WinForms Designer SDK base, and `TableLayoutPanelDesigner` derives from the in-process designer.

The editor is therefore attached with a `TypeDescriptionProvider` on `KryptonTableLayoutPanel`. The property grid asks the wrapped property for a `UITypeEditor` and gets `KryptonDesignerTableLayoutStyleEditor`. The smart-tag item **Edit Rows and Columns** is created inside `TableLayoutPanelDesigner` and still opens the stock dialog.

## Architecture

| Type | Role |
|------|------|
| `VisualTableLayoutStyleEditorForm` | Internal `KryptonForm`. Member grid, Size Type radios (Absolute, Percent, AutoSize), and Add / Delete / Insert. |
| `KryptonTableLayoutStyleEdit` | Reads and writes styles, shifts child cells on insert and delete, and restores a snapshot. |
| `KryptonDesignerTableLayoutStyleEditor` | `UITypeEditor`. Modal edit of the live panel. Notifies the designer on OK. |
| `KryptonTableLayoutPanelDescriptionProvider` | Replaces the `ColumnStyles` and `RowStyles` descriptors so both expose this editor. |

The dialog captures column styles, row styles, and each child's column, row, and spans when it opens. OK leaves the live panel as edited. Cancel writes that snapshot back. The property grid is told about the change only on OK, through `IComponentChangeService`, for `ColumnCount`, `RowCount`, `ColumnStyles`, and `RowStyles`.

Add and Insert create an Absolute style of size 20, which is the stock editor's new-style size. Insert grows the count first, then shifts children whose start is at or after the new index and grows a span that covers that index. Delete shifts children first (a later start moves back, a span that covers the index shrinks), then writes the smaller count and clamps any cell that would sit outside the grid.

## Public API

`KryptonDesignerTableLayoutStyleEditor` is the property-grid editor. `GetEditStyle` is modal when the instance is a `TableLayoutPanel`. `EditValue` opens on Columns unless the property name is `RowStyles`.

`ShowDialog` is the runtime entry used by TestForm. It does not notify a designer. Cancel still restores the panel, because that restore lives on the form.

```csharp
DialogResult result = KryptonDesignerTableLayoutStyleEditor.ShowDialog(
    owner,
    table,
    editColumns: true);
```

`KryptonTableLayoutPanelDescriptionProvider` is public because `TypeDescriptionProviderAttribute` requires a public type with a public parameterless constructor. Its constructor chains to the provider already registered for `KryptonTableLayoutPanel`. That call does not recurse: the attribute is not associated until the constructor returns.

## Usage

Drop a `KryptonTableLayoutPanel` on a form. In the property grid, open `ColumnStyles` or `RowStyles`. The dialog matches the stock Column and Row Styles layout. Show chooses Columns or Rows. The grid lists Member, Size Type, and Value. The Size Type group offers Absolute (pixels), Percent (`%`), and AutoSize. Only the numeric box for the selected type is enabled. Add, Delete, and Insert sit under the grid. Percent is the percent number, not a fraction.

OK commits the live grid. Cancel puts the styles, counts, and cell positions back.

## Edge cases

- The table designer is not replaced. Glyphs, in-place column and row resizing, and the smart-tag stock dialog all remain.
- A new style is Absolute 20. Changing the size type writes that style immediately, because the dialog edits the live panel.
- Insert and delete keep a control in the same visual cell when the strip is added or removed beside it. A span that covers the edited index grows or shrinks with that strip. A control that sat on a deleted strip is clamped into the remaining grid.
- Closing the dialog by any result other than OK restores the snapshot once.
- The dialog does not switch to DPI autoscaling on load. Font autoscaling is set in the constructor; `KryptonDesignerEditorDpi.ApplyOnShown` only adjusts the shown window.
