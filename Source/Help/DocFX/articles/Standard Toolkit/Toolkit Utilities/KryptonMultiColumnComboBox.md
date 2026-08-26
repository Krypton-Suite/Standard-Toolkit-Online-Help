# KryptonMultiColumnComboBox

## Overview

`KryptonMultiColumnComboBox` is a ComboBox-style editor whose drop-down shows multiple columns in a themed `KryptonDataGridView`. It implements [issue #4237](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4237).

The closed editor stays a standard Krypton input (ButtonSpecs, rounded corners, `InputControlStyle`, palette). Columns appear only in the drop-down. The control lives in `Krypton.Toolkit.Utilities` and is consumed via the `Krypton.Standard.Toolkit` NuGet package.

Package: `Krypton.Toolkit.Utilities`.

## Architecture

The control specializes the existing combo-user-control stack rather than owner-drawing `KryptonComboBox` (which wraps the native WinForms combo and cannot host a real grid).

```
KryptonMultiColumnComboBox  : KryptonComboBoxUserControl : KryptonTextBox
        |
        +-- Drop button ButtonSpec (inherited)
        +-- extra ButtonSpecs (inherited)
        |
        +-- DropContent = KryptonMultiColumnComboBoxDropDown
                : KryptonDataGridView
                : IKryptonDropDownUserControl
                : IKryptonDropDownFilterable
                        |
                        hosted by KryptonDropDownHostForm
```

The same host is used by `KryptonTreeComboBox` and `KryptonCheckedListComboBox`. The grid is assigned directly as `DropContent` (not wrapped in an extra `UserControl`) so painting inside the popup stays reliable.

On commit, the drop-down raises `IKryptonDropDownUserControl.CommitValue`. The host writes `DisplayText` into the editor, stores the logical value, and closes the popup unless `KeepOpen` is set.

## Public API

### `KryptonMultiColumnComboBox`

| Member | Role |
| --- | --- |
| `DataSource` | List, `BindingSource`, `DataTable`, or other `IListSource`. |
| `DisplayMember` | Property shown in the editor and used for type-ahead filtering. Empty uses the first visible cell. |
| `ValueMember` | Property used as `SelectedValue`. Empty uses the bound item. |
| `DisplayFormat` | Optional `string.Format` pattern applied to the display value (for example `{0}`). |
| `Columns` | Designer-serializable column definitions. When non-empty, `AutoGenerateColumns` becomes `false`. |
| `AutoGenerateColumns` | When `true` and `Columns` is empty, the grid generates columns from the data source. |
| `ColumnHeadersVisible` | Show or hide drop-down headers. Header clicks never commit. |
| `AutoSizeColumnsMode` | Forwarded to the grid. `Columns.Width` applies when this is `None`. |
| `CommitOnRowClick` | Left-click on a data row commits (default `true`). |
| `SelectedIndex` / `SelectedItem` / `SelectedRow` / `SelectedValue` | Combo-style selection. `SelectedValue` is settable and is the lookup binding property. |
| `Grid` | Hosted `KryptonDataGridView`. Do not reparent. |
| `ReadOnlyEditor` | Default `true` (DropDownList). Set `false` with `AutoOpenOnType` for filter-as-you-type. |
| `AutoOpenOnType` / `MinFilterLength` | Inherited filter pipeline; the drop-down implements `IKryptonDropDownFilterable`. |
| `SelectedIndexChanged` | Fired after a commit or programmatic selection change. |
| `ValueCommitted` | Inherited; raised for every drop-down commit. |

`DropContent` is hidden; the grid drop-down is fixed.

`[LookupBindingProperties(DataSource, DisplayMember, ValueMember, SelectedValue)]` enables combo-style lookup data binding.

### `KryptonMultiColumnComboBoxColumn`

| Property | Role |
| --- | --- |
| `Name` | `DataGridViewColumn.Name`. |
| `HeaderText` | Header caption. Empty uses `DataPropertyName`. |
| `DataPropertyName` | Bound property or data-column name. |
| `Width` | Pixel width when auto-size is `None`. |
| `Visible` | Hide a bound column from the drop-down. |
| `Alignment` | Cell alignment. |
| `Format` | Cell format string (for example `N0`, `C2`). |

## Usage

```csharp
var combo = new KryptonMultiColumnComboBox
{
    DisplayMember = nameof(Country.Name),
    ValueMember = nameof(Country.Code),
    DropDownWidth = 420
};
combo.Columns.Add(new KryptonMultiColumnComboBoxColumn(nameof(Country.Code), "Code", 60));
combo.Columns.Add(new KryptonMultiColumnComboBoxColumn(nameof(Country.Name), "Country", 180));
combo.Columns.Add(new KryptonMultiColumnComboBoxColumn(nameof(Country.Currency), "Currency", 80));
combo.DataSource = countries;
combo.SelectedValue = "UK";
```

Auto-generated columns:

```csharp
combo.AutoGenerateColumns = true;
combo.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
combo.DisplayMember = "Name";
combo.ValueMember = "Id";
combo.DataSource = productsTable;
```

Filter-as-you-type:

```csharp
combo.ReadOnlyEditor = false;
combo.AutoOpenOnType = true;
combo.MinFilterLength = 1;
combo.CueHint.CueHintText = "Start typing…";
```

Extra ButtonSpecs are the inherited `KryptonTextBox.ButtonSpecs` collection (the drop arrow is already present).

## Keyboard and mouse

- F4 toggles the drop-down; Alt+Down opens; Alt+Up / Escape close (host).
- Enter on a data row commits; Escape cancels.
- Left-click on a data row commits when `CommitOnRowClick` is `true`.
- Column headers, row headers, and scrollbars do not commit.
- While `AutoOpenOnType` keeps focus in the editor, Up/Down move the highlight and Enter commits.

## Edge cases

- **Empty `DataSource`.** The drop-down shows no rows. `SelectedIndex` is `-1`. Setting `SelectedValue` is remembered and applied when binding completes.
- **ValueMember type mismatch.** Selection compares with `Equals`, then `Convert.ChangeType` to the row value’s type (so `int` 1 matches `long` 1 when conversion succeeds).
- **Header click.** `RowIndex < 0` is ignored.
- **Filter hides the current row.** The grid clears `CurrentCell` before hiding rows so `DataGridView` does not throw. Non-matching rows stay in the data source (`row.Visible = false`) so `SelectedValue` still maps to the same objects.
- **DisplayMember is not a visible column.** Allowed. The editor and filter still use that property.
- **Unbound rows.** With no `DataSource`, you can add rows on `Grid.Rows` after defining `Columns`. There is no string `Items` collection.

## Designer

Smart tags expose data members, auto-generate, headers, commit-on-click, drop-down size/alignment, read-only editor, open-on-type, `InputControlStyle`, and `PaletteMode`. `Columns` is edited with the standard collection editor.
