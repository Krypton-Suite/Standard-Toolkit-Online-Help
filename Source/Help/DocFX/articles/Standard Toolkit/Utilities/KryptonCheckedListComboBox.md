# KryptonCheckedListComboBox

End-to-end reference for the **checked multi-select combo** control introduced for [GitHub #3445](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3445). For a short overview, see [Krypton Checked List ComboBox Guide](KryptonCheckedListComboBoxGuide.md).

---

## Table of contents

1. [Overview](#1-overview)
2. [Namespace, assembly, and NuGet](#2-namespace-assembly-and-nuget)
3. [Architecture](#3-architecture)
4. [When to use which control](#4-when-to-use-which-control)
5. [Default behavior and construction](#5-default-behavior-and-construction)
6. [API reference — `KryptonCheckedListComboBox`](#6-api-reference--kryptoncheckedlistcombobox)
7. [Inherited API — `KryptonComboBoxUserControl`](#7-inherited-api--kryptoncomboboxusercontrol)
8. [Drop-down implementation details](#8-drop-down-implementation-details)
9. [Data binding](#9-data-binding)
10. [Events and commit flow](#10-events-and-commit-flow)
11. [Selection model: `Text`, `SelectedValue`, `CheckedItems`, `CheckedItemList`](#11-selection-model-text-selectedvalue-checkeditems-checkeditemlist)
12. [Designer experience](#12-designer-experience)
13. [Code examples](#13-code-examples)
14. [Troubleshooting](#14-troubleshooting)
15. [Related types and issues](#15-related-types-and-issues)

---

## 1. Overview

**`KryptonCheckedListComboBox`** is a **combo-style** control: a Krypton-styled **read-only text editor** shows a **summary** of the current selection; a **popup** hosts a **`KryptonCheckedListBox`** where the user checks or unchecks multiple items. It is **not** an extension of **`KryptonComboBox`** (which wraps the native single-select `ComboBox`).

The control is built on **`KryptonComboBoxUserControl`** ([issue #3443](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3443)), which provides the editor, drop button, keyboard shortcuts, and **`VisualKryptonDropDownPopup`** integration.

---

## 2. Namespace, assembly, and NuGet

| Item | Value |
|------|--------|
| **CLR type** | `Krypton.Toolkit.Utilities.KryptonCheckedListComboBox` |
| **Assembly** | `Krypton.Toolkit.Utilities.dll` |
| **Distribution** | **Krypton.Standard.Toolkit** (aggregate package). The control is **not** defined in `Krypton.Toolkit.dll` alone. |

Toolbox: use the **Utilities**-related toolbox items after installing the suite package; the bitmap reuses the **`KryptonCheckedListBox`** toolbox icon for visual consistency.

---

## 3. Architecture

```
KryptonCheckedListComboBox  :  KryptonComboBoxUserControl  :  KryptonTextBox
        │                              │
        │                    Drop button, F4 / Alt+Arrow, popup host
        │
        └──► DropContent (fixed) = KryptonCheckedListComboBoxDropDown  :  KryptonCheckedListBox
                      │                        implements IKryptonDropDownUserControl
                      └──► CommitValue / RequestClose  →  VisualKryptonDropDownPopup
```

- **Editor:** `ReadOnlyEditor = true` by default (selection only through the list; mimics `ComboBoxStyle.DropDownList` conceptually).
- **Drop content:** Internal type **`KryptonCheckedListComboBoxDropDown`** (`sealed`, not for public subclassing). **`CheckedListBox`** property exposes it as **`KryptonCheckedListBox`** for advanced scenarios (e.g. **`RefreshBoundItems()`**).
- **Sizing:** Drop-down implements **`IKryptonDropDownUserControl.GetPreferredDropSize`** and returns the popup’s proposed size, so **`DropDownWidth`** / **`DropDownHeight`** define the popup unless the contract overrides them (this implementation passes the proposed size through).

---

## 4. When to use which control

| Scenario | Recommended control |
|----------|---------------------|
| Single value from a flat list; editable or drop-down list; data grid columns | **`Krypton.ComboBox.KryptonComboBox`** |
| Multiple independent check states; summary in the closed field; tags, feature flags, multi-category filters | **`KryptonCheckedListComboBox`** |
| Arbitrary custom UI in the popup (tree, grid picker, filter list) | **`KryptonComboBoxUserControl`** with your own **`DropContent`** |
| Hierarchical / tree selection ([issue #3444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3444)) | **`KryptonTreeComboBox`** |

---

## 5. Default behavior and construction

On construction, the control:

- Sets **`ReadOnlyEditor`** to **`true`**.
- Sets **`DropDownResizable`** to **`true`** (user can resize the popup when a grip is shown per popup implementation).
- Sets **`DropDownWidth`** / **`DropDownHeight`** to **260** × **200**.
- Creates **`KryptonCheckedListComboBoxDropDown`**, assigns it to **`DropContent`**, and wires **`ValueCommitted`**.
- Calls **`SyncDropDownBindingContext()`** so the inner list uses the host’s **`BindingContext`**.

**Designer / metadata:**

- **DefaultEvent:** `ItemCheck`
- **DefaultProperty:** `Items`
- **DefaultBindingProperty (base):** `Text` (from `KryptonComboBoxUserControl` / editor)
- **`[LookupBindingProperties(DataSource, DisplayMember, ValueMember, SelectedValue)]`** for WinForms lookup-binding scenarios (see [§11](#11-selection-model-text-selectedvalue-checkeditems-checkeditemlist)).

**Hidden / unsupported on this type:**

- **`DropContent`** — hidden; must remain the internal checked list.
- **`AutoOpenOnType`** — hidden; filter-as-you-type is **not** supported for this drop-down.

---

## 6. API reference — `KryptonCheckedListComboBox`

### 6.1 Events

| Member | Description |
|--------|-------------|
| **`ItemCheck`** | `ItemCheckEventHandler?` — Raised when a check state is **about** to change; forwarded from the inner **`KryptonCheckedListBox.ItemCheck`**. Use to cancel or adjust via **`ItemCheckEventArgs`**. |
| **`CheckedItemsChanged`** | `EventHandler?` — Raised when the **editor summary** path updates and fires **`OnCheckedItemsChanged`** (e.g. after **`RefreshCheckedSummary()`**, or when the popup commits and the host handles **`ValueCommitted`**). **Not** raised when only **`DataSource` / `DisplayMember` / format** metadata changes the text without a check change (see **`UpdateSummaryTextAfterListMetadataChange`**). |

### 6.2 Data properties (forwarded to inner `KryptonCheckedListBox`)

| Property | Notes |
|----------|--------|
| **`DataSource`** | `object?` — List or **`IListSource`**. Setting triggers summary refresh logic (see [§9](#9-data-binding)). |
| **`DisplayMember`** | `string` — **Required** for bound lists to populate items (with handle + binding; see [§9](#9-data-binding)). |
| **`ValueMember`** | `string` — When set, **`CheckedItemList`** resolves value-member values for checked rows. |
| **`FormatString`** | `string` — Used when **`FormattingEnabled`** is true. |
| **`FormattingEnabled`** | `bool` — Aligns with list formatting; summary uses **`GetItemText`**. |
| **`Items`** | `ListBox.ObjectCollection` — Unbound / designer string list. **Do not mix** casually with a live **`DataSource`** (standard WinForms list-control rules apply). |

### 6.3 Selection and list surface

| Property | Notes |
|----------|--------|
| **`CheckedItems`** | `KryptonCheckedListBox.CheckedItemCollection` — Checked row objects (includes indeterminate semantics of the inner control). |
| **`CheckedIndices`** | `KryptonCheckedListBox.CheckedIndexCollection` |
| **`CheckedItemList`** | `List<object>` — Per checked row: **value member** value if **`ValueMember`** is set and resolvable; else the item object. Same contract as **`KryptonCheckedListBox.CheckedItemList`**. |
| **`CheckedListBox`** | `KryptonCheckedListBox` — The actual drop-down control. **Do not reparent.** Use for **`RefreshBoundItems()`**, **`SelectionMode`**, or other **`KryptonCheckedListBox`** APIs when needed. |

### 6.4 Editor summary and interaction

| Property | Default | Description |
|----------|---------|--------------|
| **`ValueSeparator`** | `", "` | Joins display strings for checked items in the editor. |
| **`EmptySelectionText`** | `""` | Shown when no items are checked (via **`FormatCheckedItemsDisplay`**). |
| **`CloseDropDownOnEnter`** | `true` | When **`true`**, **Enter** in the drop-down commits and **closes** the popup; when **`false`**, Enter still commits via **`PublishSelection`** but **`KeepOpen`** keeps the popup open (see drop-down **`KeyDown`**). |
| **`CheckOnClick`** | `true` | Forwarded to inner list — click toggles check state. |

### 6.5 Methods

| Method | Description |
|--------|-------------|
| **`GetItemChecked(int index)`** | Whether the row is checked. |
| **`SetItemChecked(int index, bool)`** | Sets checked state. **Throws `ArgumentOutOfRangeException`** if **`index`** is invalid for **`Items.Count`**. Safe only after bound items exist (see [§9](#9-data-binding)). |
| **`GetItemCheckState(int index)`** | Full **`CheckState`**. |
| **`SetItemCheckState(int index, CheckState)`** | Sets tri-state when supported by inner logic. |
| **`ClearChecked()`** | Unchecks all. |
| **`GetCheckedValues()`** | **`object[]`** — copy of checked **item** objects (same objects as in **`CheckedItems`** enumeration order). |
| **`FormatCheckedItemsDisplay()`** | Builds the summary string using **`GetItemText`** for each checked item (respects **`DisplayMember`** / formatting). |
| **`RefreshCheckedSummary()`** | If popup is open: **`PublishSelection(keepDropDownOpen: true)`**; else sets **`Text`** from **`FormatCheckedItemsDisplay()`** and raises **`CheckedItemsChanged`**. |

### 6.6 Protected / internal (for maintainers)

| Member | Description |
|--------|-------------|
| **`OnCheckedItemsChanged(EventArgs)`** | Extensibility hook for **`CheckedItemsChanged`**. |
| **`OnBindingContextChanged`** | Assigns **`CheckedListBox.BindingContext = BindingContext`**. Includes a null-guard for **`_dropDown`** during ctor ordering. **`BuildCheckedValue()`** (`internal`) | Builds **`object[]`** passed as **`KryptonDropDownCommitEventArgs.Value`** on commit. |

---

## 7. Inherited API — `KryptonComboBoxUserControl`

These members are commonly used alongside the checked-list API. Full documentation is on **`KryptonComboBoxUserControl`** in source / IntelliSense.

**Behavior / layout:**

- **`DropDownAlign`**, **`DropDownWidth`**, **`DropDownHeight`**, **`MinDropDownSize`**, **`MaxDropDownSize`**, **`DropDownResizable`**
- **`ShowDropDown()`**, **`CloseDropDown()`**, **`IsDroppedDown`**
- **`ReadOnlyEditor`** — already **`true`** for **`KryptonCheckedListComboBox`**

**Committed value:**

- **`SelectedValue`** (`get`) — Set by the popup pipeline to **`e.Value`** from **`KryptonDropDownCommitEventArgs`**. For this control that is **`object[]`** from **`BuildCheckedValue()`**.

**Events:**

- **`DropDownOpening`** (`CancelEventArgs` via **`KryptonDropDownOpeningEventArgs`**)
- **`DropDownOpened`**, **`DropDownClosed`**
- **`ValueCommitted`** (`KryptonDropDownCommitEventArgs`) — fires whenever the drop-down calls **`PublishSelection`** (including **`KeepOpen = true`**); host updates **`SelectedValue`** and **`Text`** when **`DisplayText`** is non-null

**Customization:**

- **`DropButton`** — **`ButtonSpecAny`** for glyph / tooltip tweaks

**Keyboard (editor, when focused):**

- **F4** — toggle popup
- **Alt+Down** — open  
- **Alt+Up** — close  
- **Escape** — close when open  

**Base type:** **`KryptonTextBox`** — palette, **`InputControlStyle`**, **`ButtonSpecs`**, cue hints, etc., apply to the editor.

---

## 8. Drop-down implementation details

Internal class **`KryptonCheckedListComboBoxDropDown`**:

- Implements **`IKryptonDropDownUserControl`** — **`OnDropDownOpening` / `OnDropDownOpened`** refresh layout, palette, and focus the list.
- **`PublishSelection(bool keepDropDownOpen)`** creates **`KryptonDropDownCommitEventArgs(BuildCheckedValue(), FormatCheckedItemsDisplay()) { KeepOpen = keepDropDownOpen }`** and raises **`CommitValue`**.
- After each **`ItemCheck`**, **`SchedulePublishAfterItemCheckApplied`** **`BeginInvoke`s** **`PublishSelection(true)`** so the check state is applied before the UI reads checked indices (WinForms **`ItemCheck`** timing).
- **Escape** in the list → **`RequestClose`** → popup closes.
- **Enter** in the list → if **`CloseDropDownOnEnter`** is **`true`**, **`PublishSelection(false)`** runs (commits with **`KeepOpen = false`** and closes the popup). If **`CloseDropDownOnEnter`** is **`false`**, this handler does **not** run on Enter; relying on **`ItemCheck`** / live **`PublishSelection(true)`** still updates **`Text`** and **`SelectedValue`**, while the user typically closes via **Escape** or click-outside.

---

## 9. Data binding

The inner **`KryptonCheckedListBox`** loads bound rows in **`RefreshItems()`** when **all** of the following hold:

1. **`IsHandleCreated`** is **`true`**
2. **`DataSource`** is non-null
3. **`DisplayMember`** is non-white-space

The list uses **`BindingContext[_dataSource]`** as **`CurrencyManager`** and adds **full row objects** to **`Items`** (not just display strings). Therefore:

- **In `Form` / `UserControl` constructors**, **`Items.Count`** is often **0** until **`Load`** / first show. **Do not** call **`SetItemChecked`** until items exist.
- After the handle exists, **`OnHandleCreated`** calls **`RefreshItems()`**. You can also call **`CheckedListBox.RefreshBoundItems()`** to force a refresh.
- The host’s **`BindingContext`** is copied to the drop-down in **`OnBindingContextChanged`** so **`BindingSource`** on the form works as expected.

**Recommended pattern for initial checked state (bound list):**

```csharp
private void Form1_Load(object sender, EventArgs e)
{
    if (kryptonCheckedListComboBox1.Items.Count == 0)
    {
        kryptonCheckedListComboBox1.CheckedListBox.RefreshBoundItems();
    }
    // Now safe to use indices:
    kryptonCheckedListComboBox1.SetItemChecked(0, true);
    kryptonCheckedListComboBox1.RefreshCheckedSummary();
}
```

See **`TestForm`** — **`KryptonCheckedListComboBoxDemo`** — for a working sample.

---

## 10. Events and commit flow

Typical sequence when the user checks an item (popup open):

1. Inner list raises **`ItemCheck`** → forwarded to **`KryptonCheckedListComboBox.ItemCheck`**.
2. Inner list schedules **`PublishSelection(true)`** → **`CommitValue`** → popup raises **`ValueCommitted`** with **`KeepOpen = true`** → host sets **`SelectedValue`** and **`Text`**.
3. **`KryptonCheckedListComboBox`** subscribes to **`ValueCommitted`** and raises **`CheckedItemsChanged`**.

When **`KeepOpen`** is **`false`**, the popup closes after commit (**`VisualKryptonDropDownPopup`**).

---

## 11. Selection model: `Text`, `SelectedValue`, `CheckedItems`, `CheckedItemList`

| Output | Meaning |
|--------|--------|
| **`Text`** | Human-readable summary in the editor; joined with **`ValueSeparator`**; **`EmptySelectionText`** if none checked. |
| **`GetCheckedValues()`** / **`SelectedValue`** (after commit) | **`object[]`** of the **bound row objects** (or added items) for checked rows — **not** raw value-member scalars. |
| **`CheckedItemList`** | **`List<object>`** of **value-member** values when **`ValueMember`** is set; otherwise same as item objects. |
| **`CheckedItems`** | Live collection of checked **item** references. |

**Lookup binding:** The type is attributed with **`LookupBindingProperties`**. The fourth parameter **`SelectedValue`** reflects the **last committed** payload (**`object[]`**). For scalar lists in business objects, often you map **`CheckedItemList`** in code rather than simple two-way binding.

---

## 12. Designer experience

- **Designer:** **`KryptonCheckedListComboBoxDesigner`** with smart-tag **Data** group: **`DataSource`**, **`DisplayMember`**, **`ValueMember`**, **`EmptySelectionText`**, plus **DropDown**, **List** (`ValueSeparator`), and **Visuals** ( **`InputControlStyle`**, **`PaletteMode`** ).
- **Property grid:** Data editors match **`KryptonCheckedListBox`** (field pickers, format string editor, list string collection for **`Items`**).

---

## 13. Code examples

### 13.1 Unbound items

```csharp
var combo = new KryptonCheckedListComboBox();
combo.Items.AddRange(new object[] { "Alpha", "Beta", "Gamma" });
combo.SetItemChecked(0, true);
combo.SetItemChecked(2, true);
combo.RefreshCheckedSummary();
```

### 13.2 Bound list with value members

```csharp
var bs = new BindingSource { DataSource = listOfRowObjects };
combo.DisplayMember = nameof(Row.Name);
combo.ValueMember = nameof(Row.Id);
combo.DataSource = bs;
// After Load or RefreshBoundItems:
combo.SetItemChecked(0, true);
List<object> ids = combo.CheckedItemList;
```

### 13.3 Subscribe to changes

```csharp
combo.CheckedItemsChanged += (_, _) =>
{
    // SelectedValue reflects the object[] payload from the last PublishSelection / commit.
    if (combo.SelectedValue is object[] committed)
    {
        // ...
    }
    string summary = combo.Text;
};
combo.ItemCheck += (s, e) =>
{
    // e.Index, e.CurrentValue, e.NewValue
};
```

---

## 14. Troubleshooting

| Symptom | Likely cause | Mitigation |
|---------|----------------|------------|
| **`ArgumentOutOfRangeException`** on **`SetItemChecked`** | Bound **`Items`** not populated yet (no handle or empty **`DisplayMember`**) | Defer to **`Load`**, call **`RefreshBoundItems()`**, verify **`DisplayMember`**. |
| Summary shows type names instead of fields | Using raw **`ToString`** instead of display pipeline | Use **`FormatCheckedItemsDisplay`** / **`RefreshCheckedSummary`**; set **`DisplayMember`** / **`FormattingEnabled`**. |
| **`CheckedItemsChanged`** not firing on metadata-only change | By design: **`UpdateSummaryTextAfterListMetadataChange`** updates **`Text`** without raising **`CheckedItemsChanged`** | Subscribe to **`TextChanged`** if needed, or call **`RefreshCheckedSummary`** after programmatic check changes. |
| Popup does not open at design time | **`ShowDropDown`** returns early when **`DesignMode`** is true | Expected; verify at run time. |

---

## 15. Related types and issues

| Type / link | Role |
|-------------|------|
| **`KryptonComboBoxUserControl`** | Popup host ([issue #3443](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3443)) |
| **`IKryptonDropDownUserControl`** | Contract for drop content |
| **`KryptonDropDownCommitEventArgs`** | **`Value`**, **`DisplayText`**, **`KeepOpen`** |
| **`KryptonDropDownOpeningEventArgs`** | **`Cancel`**, **`DropContent`** |
| **`KryptonCheckedListBox`** | Inner list implementation and binding rules |
| **`VisualKryptonDropDownPopup`** | Popup window, **`ValueCommitted`**, resize grip |
| [issue #3445](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3445) | Feature request (checked combo) |
| **`KryptonTreeComboBox`** | Tree variant ([issue #3444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3444)) |
