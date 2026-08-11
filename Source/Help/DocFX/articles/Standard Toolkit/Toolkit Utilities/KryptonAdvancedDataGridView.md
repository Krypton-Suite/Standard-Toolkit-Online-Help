# KryptonAdvancedDataGridView

This document describes **KryptonAdvancedDataGridView**, a WinForms grid control in **Krypton.Toolkit.Utilities** that extends **Krypton.Toolkit**’s `KryptonDataGridView` with Excel-style per-column filtering, multi-column sort composition, optional search UI integration, and localization.

**Primary type:** `Krypton.Toolkit.Utilities.KryptonAdvancedDataGridView`  
**Source:** `Source/Krypton Components/Krypton.Toolkit.Utilities/Components/KryptonAdvancedDataGridView/Controls Toolkit/KryptonAdvancedDataGridView.cs`

---

## 1. Purpose and positioning

| Aspect | Detail |
| ------ | ------ |
| **Base class** | `KryptonDataGridView` → `System.Windows.Forms.DataGridView` |
| **Assembly** | `Krypton.Toolkit.Utilities` (project reference to `Krypton.Toolkit`) |
| **Designer** | `[DesignerCategory("code")]` — typical WinForms usage: drop on form or compose in code |
| **Column headers** | Every column added at runtime gets a custom header cell (`KryptonColumnHeaderCell`, **internal**) with a filter/sort drop-down button |

The control is intended for **data-bound** scenarios where you can apply **ADO.NET–style filter and sort expressions** to the underlying list. It does not replace server-side querying; it composes `Filter` / `Sort` strings and applies them to compatible data sources.

---

## 2. End-user features (what the control provides)

### 2.1 Column header UI

- **Filter glyph** on each column header. Columns whose `ValueType` is `Bitmap` omit the drop-down by default; set **`FilterAndSortOnBitmapColumns`** to `true` to show it.
- **Sort** via the header menu: ascending / descending, plus clear sort.
- **Filter** via:
  - **Checklist filter** — tree of distinct values (with text search, select all, blanks, true/false for booleans, etc.).
  - **Custom filter** — expression builder (backed by `VisualCustomFilterForm` and type-specific operators).
  - **Clear filter** for the column.
- **Header icons** reflect state: unfiltered, filtered only, sorted only, filtered + sorted, and “loaded” preset (saved filters) where applicable.

### 2.2 Multi-column logic

- **Filters** on multiple columns are combined with **`AND`**, in the **order the user applied** them (tracked internally as a filter order list).
- **Sort** on multiple columns is combined with **comma-separated** expressions (multi-sort order is tracked similarly).

### 2.3 Performance and checklist tuning

Large distinct-value lists can be expensive. The implementation (via the internal `MenuStrip`) supports:

- **Maximum checklist nodes** (global or per column).
- **Deferred text filtering** in the checklist search box (threshold node count + delay in milliseconds).
- **Optional “remove nodes on search”** behavior for the checklist text filter.

### 2.4 Optional “NOT IN” checklist semantics

`SetMenuStripFilterNotInLogic(bool)` toggles logic used for checklist filtering when enabled (applied to all filterable header cells).

### 2.5 Search toolbar (separate control)

`KryptonAdvancedDataGridViewSearchToolBar` is a `ToolStrip` that raises a **`Search`** event. Host code typically calls `FindCell` on the grid to locate the next match. This is optional and not required for filtering/sorting.

---

## 3. Data binding requirements (critical)

The grid applies filter and sort by updating the **data source**, not by hiding rows only in the grid.

### 3.1 Sort (`SortString`)

When sort changes, the control sets the **first matching** property:

1. **`BindingSource.Sort`** — if `DataSource` is a `BindingSource`.
2. **`DataView.Sort`** — if `DataSource` is a `DataView`.
3. **`DataTable.DefaultView.Sort`** — if `DataSource` is a `DataTable` (and `DefaultView` is not null).

For other list types (for example `IList` / `IBindingList` without a `BindingSource` wrapper), sort is **not** applied automatically; use a **`BindingSource`** or handle **`SortStringChanged`** yourself.

### 3.2 Filter (`FilterString`)

When filter changes, the control applies the composed filter string to the **first matching** type:

1. **`BindingSource`** → `Filter` property  
2. **`DataView`** → `RowFilter`  
3. **`DataTable`** → `DefaultView.RowFilter` (when `DefaultView` is not null)

**Implications:**

- Filter expressions must be valid for the target type (see [DataView.RowFilter syntax](https://learn.microsoft.com/dotnet/api/system.data.dataview.rowfilter)).
- Column names in expressions use the bound field: internally, per-column fragments are formatted with **`DataGridViewColumn.DataPropertyName`** (see `BuildFilterString` / `BuildSortString` in the source).

### 3.3 Canceling data-source updates

`SortStringChanged` and `FilterStringChanged` expose event args with **`Cancel`**. If a handler sets `Cancel = true`, the control **skips** assigning `Sort` / `Filter` / `RowFilter` for that update. You can use this to drive custom data loading or veto invalid states.

### 3.4 Event ordering vs. data source

Properties (not serialized by the designer):

- **`SortStringChangedInvokeBeforeDatasourceUpdate`** (default `true`)  
- **`FilterStringChangedInvokeBeforeDatasourceUpdate`** (default `true`)  

When `true`, the event runs **before** the data source is updated; when `false`, the event runs **after**. Adjust if handlers need to see the old vs. new binding state.

---

## 4. Public API — `KryptonAdvancedDataGridView`

### 4.1 Nested event argument types

| Type | Members | Use |
| ---- | ------- | --- |
| **`SortEventArgs`** | `SortString`, `Cancel` | Raised when composed sort changes |
| **`FilterEventArgs`** | `FilterString`, `Cancel` | Raised when composed filter changes |

### 4.2 Events

| Event | Signature | Notes |
| ----- | --------- | ----- |
| **`SortStringChanged`** | `EventHandler<SortEventArgs>` | Fired when aggregate sort string changes |
| **`FilterStringChanged`** | `EventHandler<FilterEventArgs>` | Fired when aggregate filter string changes |

### 4.3 Properties

| Member | Notes |
| ------ | ----- |
| **`SortString`** | Read-only to consumers (private setter). Composed sort expression (e.g. for `BindingSource.Sort`). Hidden from designer serialization. |
| **`FilterString`** | Same pattern; composed filter expression. |
| **`FilterAndSortEnabled`** | Master switch for new/changed columns defaulting to filter+sort enabled; also used when enabling columns. Hidden from designer serialization. |
| **`FilterAndSortOnBitmapColumns`** | When `true`, draws the header filter/sort control on `Bitmap` columns (default `false`). Hidden from designer serialization. |
| **`SortStringChangedInvokeBeforeDatasourceUpdate`** | Controls event timing relative to applying sort to the data source. |
| **`FilterStringChangedInvokeBeforeDatasourceUpdate`** | Same for filter. |

### 4.4 Static localization

| Member | Description |
| ------ | ----------- |
| **`Translations`** | `Dictionary<string, string>` — keys are `nameof(TranslationKey.…)` entries; values are English defaults. Used by header menus and custom filter UI. |
| **`SetTranslations(IDictionary<string, string>?)`** | Merge overrides into existing keys (unknown keys ignored). |
| **`GetTranslations()`** | Returns the live dictionary. |
| **`LoadTranslationsFromFile(string filename)`** | Loads JSON object map of string→string; merges with known keys; fills missing keys from defaults. Uses `JavaScriptSerializer` on **.NET Framework** and `System.Text.Json` on **modern .NET**. |

**Translation keys** are enumerated in **`TranslationKey`** (`General/Definitions.cs`), including filter/sort menu text, operator labels, checklist labels, and **search toolbar** strings (keys prefixed with `ADGVSTB…`).

### 4.5 Filter / sort control (column-scoped and global)

| Method | Purpose |
| ------ | ------- |
| **`EnableFilterAndSort(DataGridViewColumn)`** / **`DisableFilterAndSort(DataGridViewColumn)`** / **`SetFilterAndSortEnabled(column, enabled)`** | Turn per-column header features on/off; may clear grid filter when disabling active column. |
| **`SetSortEnabled(column, enabled)`** | Enable/disable sort UI for a column. |
| **`SetFilterEnabled(column, enabled)`** | Enable/disable filtering for a column. |
| **`SetFilterDateAndTimeEnabled(column, enabled)`** | Toggle date/time specific filter behavior (menu side). |
| **`SetFilterChecklistEnabled` / `Enable` / `Disable`** | Checklist section on/off. |
| **`SetFilterCustomEnabled` / `Enable` / `Disable`** | Custom filter entry on/off. |
| **`SetFilterChecklistNodesMax(column, max)`** / **`SetFilterChecklistNodesMax(max)`** | Cap checklist size (all columns). |
| **`EnabledFilterChecklistNodesMax` (column/global)** | Enable or disable the max-node cap behavior. |
| **`SetFilterChecklistTextFilterTextChangedDelayNodes`** (column/global) | Node count threshold before text-change debouncing applies. |
| **`SetFilterChecklistTextFilterTextChangedDelayMs`** (column/global) | Debounce interval. |
| **`SetFilterChecklistTextFilterTextChangedDelayDisabled`** (column/global) | Disable debouncing behavior. |
| **`SetChecklistTextFilterRemoveNodesOnSearchMode`** | Checklist search removes non-matching nodes mode. |
| **`SetTextFilterRemoveNodesOnSearch` / `GetTextFilterRemoveNodesOnSearch`** | Broader text-filter node behavior for a column. |
| **`SetMenuStripFilterNotInLogic(bool)`** | NOT IN style checklist logic for all columns. |
| **`CleanFilter(column)` / `CleanFilter(column, fireEvent)`** | Clear one column’s filter; optionally raise aggregate filter event. |
| **`CleanFilter()` / `CleanFilter(bool fireEvent)`** | Clear all column filters. |
| **`CleanSort(column)` / `CleanSort(column, fireEvent)`** | Clear one column’s sort. |
| **`CleanSort()` / `CleanSort(bool fireEvent)`** | Clear all sorts. |
| **`CleanFilterAndSort()`** | Full reset of loaded mode, order lists, filter and sort. |
| **`LoadFilterAndSort(string? filter, string? sorting)`** | Apply preset filter/sort strings; puts header cells in **loaded** mode until user changes state. |
| **`SortAscending(column)` / `SortDescending(column)`** | Programmatic sort from code. |
| **`TriggerSortStringChanged()`** / **`TriggerFilterStringChanged()`** | Re-run event + data-source application for current strings. |

### 4.6 Find / menu

| Method | Purpose |
| ------ | ------- |
| **`FindCell(valueToFind, columnName, rowIndex, columnIndex, isWholeWordSearch, isCaseSensitive)`** | Returns next `DataGridViewCell` matching text in formatted display value; `columnName` null searches all visible columns. |
| **`ShowMenuStrip(DataGridViewColumn)`** | Programmatically open the column’s filter/sort drop-down. |

### 4.7 Misc

| Method | Purpose |
| ------ | ------- |
| **`SetDoubleBuffered()`** | Sets `DoubleBuffered = true` to reduce flicker. |

---

## 5. Lifecycle and internal behavior (integration notes)

### 5.1 Column add/remove

- **`OnColumnAdded`**: Forces `SortMode = Programmatic`, replaces header with `KryptonColumnHeaderCell`, wires **SortChanged**, **FilterChanged**, **FilterPopup**, adjusts `MinimumWidth` / `ColumnHeadersHeight`.
- **`OnColumnRemoved`**: Unsubscribes events, cleans menu state; may **defer disposal** of `MenuStrip` for data-bound columns until handle destroyed or data source changes (avoids leaks during rebinding).

### 5.2 Rows and cell edits

- **`OnRowsAdded` / `OnRowsRemoved`**: Clears internal **`_filteredColumns`** cache when row index is valid (distinct values for filters may need refresh).
- **`OnCellValueChanged`**: Removes that column from **`_filteredColumns`** so checklist refresh behavior can update.

### 5.3 Cleanup

- **`OnHandleDestroyed`**: Unhooks all header cell handlers and disposes any queued menu strips.

---

## 6. Companion types

### 6.1 `KryptonAdvancedDataGridViewSearchToolBar`

- **Inherits:** `System.Windows.Forms.ToolStrip`
- **Event:** `Search` — `AdvancedDataGridViewSearchToolBarSearchEventHandler`
- **Event args:** `AdvancedDataGridViewSearchToolBarSearchEventArgs`  
  - `ValueToSearch`, `ColumnToSearch`, `CaseSensitive`, `WholeWord`, `FromBegin`
- **`SetColumns(DataGridViewColumnCollection)`** — populates the column combo; item 0 is “all columns” (localized).
- **Translations:** separate static `Translations` / `SetTranslations` / `LoadTranslationsFromFile` (same JSON pattern as the grid).
- **Close button:** designer constant `BUTTON_CLOSE_ENABLED = false` removes the close item in the constructor; toolbar uses `ToolStripRenderMode.ManagerRenderMode`.

### 6.2 `FilterType` (in `Krypton.Toolkit.Utilities`)

Public enum in **`General/Definitions.cs`** describes **value categories** for filter logic (`DateTime`, `String`, `Integer`, etc.). This is **not** the same as the internal **`MenuStrip.FilterType`** (`None`, `Custom`, `CheckList`, `Loaded`), which describes **which filter mode** is active on a column.

### 6.3 Internal implementation (not public API)

| Type | Role |
| ---- | ---- |
| **`KryptonColumnHeaderCell`** | Header painting, filter button hit-test, forwards to `MenuStrip`. |
| **`MenuStrip`** (`ContextMenuStrip`) | Sort/filter UI, checklist, custom filter launch, expression building. |
| **`VisualCustomFilterForm`** | Custom filter dialog. |
| **`TreeNodeItemSelector`** | Checklist node model. |
| **`ColumnHeaderCellEventArgs`** | Internal; carries `MenuStrip` + `Column` for header events. |

---

## 7. Typical usage patterns

### 7.1 Minimal data-bound setup

```csharp
var grid = new KryptonAdvancedDataGridView();
grid.SetDoubleBuffered();

var table = new DataTable();
// ... columns and rows ...

var bs = new BindingSource { DataSource = table };
grid.DataSource = bs;
```

Use **`BindingSource`** if you need **`SortString`** applied automatically.

### 7.2 Handling sort/filter changes

```csharp
grid.SortStringChanged += (s, e) =>
{
    if (ShouldVeto(e.SortString))
        e.Cancel = true;
};

grid.FilterStringChanged += (s, e) =>
{
    Debug.WriteLine(e.FilterString);
};
```

### 7.3 Saving and restoring layout

Persist **`FilterString`** and **`SortString`** (and any UX state your app needs). Restore with:

```csharp
grid.LoadFilterAndSort(savedFilter, savedSort);
```

Use **`CleanFilterAndSort()`** to reset before applying a new preset or clearing user state.

### 7.4 Search toolbar + find

```csharp
var toolBar = new KryptonAdvancedDataGridViewSearchToolBar();
toolBar.SetColumns(grid.Columns);

DataGridViewCell? lastMatch = null;

toolBar.Search += (s, e) =>
{
    int row = lastMatch?.RowIndex ?? 0;
    int col = lastMatch?.ColumnIndex ?? 0;
    var found = grid.FindCell(
        e.ValueToSearch,
        e.ColumnToSearch?.Name,
        row,
        col,
        e.WholeWord,
        e.CaseSensitive);

    if (found != null)
    {
        grid.ClearSelection();
        grid.CurrentCell = found;
        found.Selected = true;
        lastMatch = found;
    }
};
```

Adjust indices for **“find next”** vs **“search from beginning”** using `FromBegin` on the event args.

---

## 8. Localization checklist

1. Copy keys from `KryptonAdvancedDataGridView.Translations` (and search toolbar keys if used).  
2. Provide a JSON map: `{ "KryptonAdvancedDataGridViewSortTextAscending": "..." }`.  
3. Call **`SetTranslations(LoadTranslationsFromFile("path"))`** or merge with **`SetTranslations`** at startup.  
4. For the search toolbar, also update **`KryptonAdvancedDataGridViewSearchToolBar.Translations`** (or load a combined JSON that contains both sets of keys).

---

## 9. Limitations and caveats

- **Sort** is auto-applied for **`BindingSource`**, **`DataView`**, and **`DataTable`** (via `DefaultView`) only. Other `DataSource` types still require a wrapper or a **`SortStringChanged`** handler.  
- **Filter and sort expressions** use **ADO.NET DataView** syntax and **`DataGridViewColumn.DataPropertyName`** in composed fragments — that is by design, not a bug.  
- **Unbound** columns or unusual **`ValueType`** / **`DataPropertyName`** setups may still need **`EnableFilterAndSort`**, **`SetFilterEnabled`**, or **`SetSortEnabled`** so expressions match your underlying data.  
- **`FilterAndSortOnBitmapColumns`** can enable the header UI on image columns; filtering/sorting by image values remains limited by what the data layer can express.  
- Internal header/menu types remain **non-public** to keep the API surface small; extend via public members, **`SortStringChanged`** / **`FilterStringChanged`**, and **`SetTranslations`**, or fork if you need deep customization.

---

*This guide matches the implementation in the Krypton Standard-Toolkit repository as of the branch that introduced `KryptonAdvancedDataGridView`. For behavioral details always refer to the source files cited above.*
