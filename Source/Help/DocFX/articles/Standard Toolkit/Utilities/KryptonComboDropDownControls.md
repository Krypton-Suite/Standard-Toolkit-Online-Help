# Combo drop-down controls

## Overview

The combo drop-down stack in **`Krypton.Toolkit.Utilities`** provides ComboBox-style editors whose popup hosts arbitrary content instead of a flat item list. The family implements [#3443](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3443), [#3444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3444), and [#3445](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3445).

**Assembly:** `Krypton.Toolkit.Utilities` (included in `Krypton.Standard.Toolkit` NuGet package)  
**Namespace:** `Krypton.Toolkit.Utilities`

| Control | Purpose |
| --- | --- |
| [KryptonComboBoxUserControl](#kryptoncomboboxusercontrol) | Generic host — drop-down shows any `Control` / `UserControl` |
| [KryptonTreeComboBox](#kryptontreecombobox) | Hierarchical picker built on `KryptonTreeView` |
| [KryptonCheckedListComboBox](#kryptoncheckedlistcombobox) | Multi-select with check boxes |

For standard single-select list combo boxes, continue using [KryptonComboBox](../Toolkit/Controls/KryptonComboBox.md) in `Krypton.Toolkit`.

## Architecture

```text
KryptonTextBox
└── KryptonComboBoxUserControl          ← base host (drop button, popup, events)
    ├── KryptonTreeComboBox             ← fixed tree drop-down
    └── KryptonCheckedListComboBox      ← fixed checked-list drop-down

KryptonDropDownHostForm                 ← internal themed popup (optional resize grip)
IKryptonDropDownUserControl             ← optional drop-content contract
IKryptonDropDownFilterable              ← optional filter-as-you-type contract
```

### Popup lifecycle

1. User clicks the drop button, presses **F4**, or **Alt+Down** (or types when `AutoOpenOnType` is enabled).
2. `DropDownOpening` fires; set `Cancel` on `KryptonDropDownOpeningEventArgs` to suppress the popup.
3. `KryptonDropDownHostForm` shows `DropContent` anchored to the editor.
4. Drop content raises `CommitValue` (via `IKryptonDropDownUserControl`) or the user dismisses the popup.
5. `ValueCommitted`, then `DropDownClosed` fire on the host.

## Contracts

### IKryptonDropDownUserControl

Optional interface for custom `UserControl` drop content:

| Member | Role |
| --- | --- |
| `GetPreferredDropSize` | Sizing before show; return `Size.Empty` to use host `DropDownWidth` / `DropDownHeight` |
| `OnDropDownOpening` / `Opened` / `Closing` / `Closed` | Lifecycle hooks |
| `CommitValue` event | Raise with `KryptonDropDownCommitEventArgs` when user confirms a value |
| `RequestClose` event | Close without commit (for example Escape inside the user control) |

### IKryptonDropDownFilterable

Optional filter-as-you-type support when `AutoOpenOnType` is `true`:

| Member | Role |
| --- | --- |
| `ApplyFilter(text)` | Filter list; return `false` when no matches (host may close popup) |
| `NavigateSelection(direction)` | Handle Up/Down arrows (+1 / −1) |
| `CommitSelection()` | Handle Enter; should raise `CommitValue` when valid |

## KryptonComboBoxUserControl

**Inheritance:** `KryptonTextBox` → `KryptonComboBoxUserControl`

### Key properties

| Property | Description |
| --- | --- |
| `DropContent` | `Control` shown in the popup (designer: `KryptonDropContentEditor`) |
| `SelectedValue` | Last committed value object |
| `DropDownWidth` / `DropDownHeight` | Default popup size (200×200) |
| `MinDropDownSize` / `MaxDropDownSize` | Resize constraints when `DropDownResizable` is true |
| `DropDownResizable` | Bottom-right resize grip on popup |
| `DropDownAlign` | `LeftRightAlignment` for popup anchor |
| `ReadOnlyEditor` | When true, editor text is read-only (specialized combos default to true) |
| `AutoOpenOnType` | Open popup while typing without stealing focus |
| `MinFilterLength` | Minimum editor length before auto-open filter runs |

### Key events

- `DropDownOpening`, `DropDownOpened`, `DropDownClosed`
- `ValueCommitted` (`KryptonDropDownCommitEventArgs`)

### Designer

- `KryptonComboBoxUserControlDesigner` smart tags: alignment, size, resizable, read-only editor, palette
- `KryptonDropContentEditor` picks an existing on-form control or creates a new `UserControl`-derived type

### Minimal custom drop-down

```csharp
using Krypton.Toolkit.Utilities;

public partial class CityPickerDropDown : UserControl, IKryptonDropDownUserControl
{
    public event EventHandler<KryptonDropDownCommitEventArgs>? CommitValue;
    public event EventHandler? RequestClose;

    public Size GetPreferredDropSize(Size proposedSize) => new Size(280, 200);

    public void OnDropDownOpening(object owner) { /* refresh list */ }
    public void OnDropDownOpened(object owner) { }
    public void OnDropDownClosing(object owner, ref bool cancel) { }
    public void OnDropDownClosed(object owner) { }

    private void OnCityPicked(string city)
    {
        CommitValue?.Invoke(this, new KryptonDropDownCommitEventArgs(city, city));
    }
}

// On the form:
var host = new KryptonComboBoxUserControl
{
    DropContent = cityPickerDropDown,
    DropDownWidth = 280,
    DropDownHeight = 200
};
host.ValueCommitted += (_, e) => host.Text = e.DisplayText ?? e.Value?.ToString();
```

## KryptonTreeComboBox

**Inheritance:** `KryptonComboBoxUserControl` → `KryptonTreeComboBox`  
**Issues:** [#3444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3444)

### Key properties

| Property | Description |
| --- | --- |
| `Nodes` | Root `TreeNode` collection (inner `KryptonTreeView`) |
| `SelectedNode` | Committed tree selection |
| `DisplayMode` | `LeafText`, `FullPath`, or `Breadcrumb` editor formatting |
| `SelectMode` | `LeafOnly`, `AnyNode`, etc. |
| `PathSeparator` / `BreadcrumbSeparator` | Path display separators |
| `CommitOnNodeClick` | Commit immediately when a node is clicked |

### Events

- `SelectedNodeChanged` — after commit from drop-down
- `AfterSelect` — forwards inner tree `AfterSelect` while popup is open

```csharp
var treeCombo = new KryptonTreeComboBox();
treeCombo.Nodes.Add(new TreeNode("Europe") {
    Nodes = { new TreeNode("France"), new TreeNode("Germany") }
});
treeCombo.DisplayMode = KryptonTreeComboBoxDisplayMode.Breadcrumb;
```

## KryptonCheckedListComboBox

**Inheritance:** `KryptonComboBoxUserControl` → `KryptonCheckedListComboBox`  
**Issues:** [#3445](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3445)

Multi-select combo; editor shows a comma-separated summary of checked display text.

### Key properties

| Property | Description |
| --- | --- |
| `Items` / `DataSource` / `DisplayMember` / `ValueMember` | Same binding model as `KryptonCheckedListBox` |
| `CheckedItemList` | `List<object>` of checked value-member objects |
| `ValueSeparator` | Editor summary separator (default `", "`) |
| `EmptySelectionText` | Shown when nothing is checked |
| `CloseDropDownOnEnter` | Close popup on Enter (default true) |

### Events

- `CheckedItemsChanged` — editor summary updated
- `ItemCheck` — forwards inner `KryptonCheckedListBox.ItemCheck`

### Getting checked values

```csharp
// Display text in editor (automatic)
string summary = checkedListCombo.Text;

// Typed value-member results
List<object> values = checkedListCombo.CheckedItemList;

// Committed array via SelectedValue after ValueCommitted
object?[]? committed = checkedListCombo.SelectedValue as object[];
```

The drop-down stays open while toggling checks; click outside or press Enter (when enabled) to close.

## TestForm demos

| Form | Scenario |
| --- | --- |
| `KryptonComboBoxUserControlDemo` | Tree picker, grid picker, plain UserControl, filter-as-you-type city picker |
| Checked-list / tree combo tests | See `TestForm/StartScreen.cs` entries |

## Troubleshooting

**Popup does not open**

- Verify `DropContent` is assigned and not disposed
- Handle `DropDownOpening` — ensure `Cancel` is not set unintentionally
- For designer-created `DropContent`, confirm the control is sited on the form

**Commit does not update editor text**

- Handle `ValueCommitted` or ensure drop content raises `CommitValue` with `DisplayText`
- Specialized combos (`KryptonTreeComboBox`, `KryptonCheckedListComboBox`) handle this internally

**Filter-as-you-type closes immediately**

- `ApplyFilter` returned `false` (no matches); increase data or lower `MinFilterLength`
- Drop content must implement `IKryptonDropDownFilterable`

**Resize grip not shown**

- Set `DropDownResizable = true` on the host

**Type not in toolbox**

- Reference `Krypton.Standard.Toolkit`; controls live in `Krypton.Toolkit.Utilities.dll`

## See also

- [KryptonComboBox](../Toolkit/Controls/KryptonComboBox.md) — standard list combo box
- [KryptonCheckedListBox](../Toolkit/Controls/KryptonCheckedListBox.md) — inner list for checked combo
- [KryptonTreeView](../Toolkit/Controls/KryptonTreeView.md) — inner tree for tree combo
- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
- [Controls index](../Toolkit/Controls.md)
