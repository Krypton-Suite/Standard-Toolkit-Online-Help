# KryptonCheckedListComboBox — Guide

Short overview for **[issue #3445](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3445)** (checked multi-select combo).

**Full developer reference (APIs, architecture, binding, events, troubleshooting):** **[KryptonCheckedListComboBox.md](KryptonCheckedListComboBox.md)**

---

- **Type:** `Krypton.Toolkit.Utilities.KryptonCheckedListComboBox`
- **Assembly:** `Krypton.Toolkit.Utilities.dll` (delivered via the **Krypton.Standard.Toolkit** NuGet package, not the core `Krypton.Toolkit`-only package layout).
- **Host:** Built on **`KryptonComboBoxUserControl`**: a read-only editor plus a Krypton-styled popup. The drop-down content is a **`KryptonCheckedListBox`**, not the native WinForms `ComboBox` list.

## KryptonComboBox vs KryptonCheckedListComboBox

| Use case | Control |
|----------|---------|
| Single selection from a flat list; editable or drop-down list style; grid columns; familiar `ComboBox` behavior | **`KryptonComboBox`** |
| Multi-select with check boxes; summary text in the closed field; pick many tags, flags, or categories | **`KryptonCheckedListComboBox`** |

The native **`ComboBox`** inside **`KryptonComboBox`** is not designed for per-row check boxes or independent multi-select. **`KryptonCheckedListComboBox`** implements the usual WinForms pattern: combo-like chrome + separate popup hosting a **`CheckedListBox`**-style control (`KryptonCheckedListBox`), with Krypton theming.

## Filling the list

**Option A — static items**

- Use the **`Items`** collection (same idea as other list controls).

**Option B — data binding**

- Set **`DataSource`**, **`DisplayMember`**, and optionally **`ValueMember`** on **`KryptonCheckedListComboBox`** (they are forwarded to the inner **`KryptonCheckedListBox`**).
- Ensure **`BindingContext`** flows from the form; the control syncs its binding context to the drop-down list.

**Bound `Items` timing:** The inner list loads bound rows when its **window handle exists** and **`DisplayMember`** is set (see **`KryptonCheckedListBox.RefreshItems`**). In **`Form`/`UserControl` constructors**, **`Items.Count`** may still be **0**. Defer **`SetItemChecked` / `RefreshCheckedSummary`** until **`Load`**/**`Shown`** (or call **`CheckedListBox.RefreshBoundItems()`** after the handle exists) before using indices.

Additional formatting options (**`FormattingEnabled`**, **`FormatString`**) match **`KryptonCheckedListBox`** and affect how the summary line is built (via **`GetItemText`**).

## Reading the selection

- **`CheckedItems` / `CheckedIndices` / `GetItemChecked`** — same semantics as **`KryptonCheckedListBox`**.
- **`CheckedItemList`** — when **`ValueMember`** is set, each entry is the value-member value for a checked row; otherwise the underlying item objects.
- **`GetCheckedValues()`** — array of checked **items** as bound/display objects (parallel to **`CheckedItems`**).
- **`KryptonComboBoxUserControl.SelectedValue`** — updated when the popup commits; for this control it is typically an **`object[]`** of the checked items (**`BuildCheckedValue()`**). Prefer **`CheckedItemList`** when you need value-member primitives.
- **`Text`** — read-only summary in the editor (separator from **`ValueSeparator`**; **`EmptySelectionText`** when nothing is checked). Usually you should **`RefreshCheckedSummary()`** after programmatic check changes.

## Designer

Open the smart tag and use the **Data** section for **`DataSource`**, **`DisplayMember`**, **`ValueMember`**, and **`EmptySelectionText`**. Other sections cover drop-down geometry, **`ValueSeparator`**, and visuals.

## Try it in the repo

Open **`TestForm`** and launch **KryptonCheckedListComboBox** from the start screen (**`KryptonCheckedListComboBoxDemo`**): plain **`Items`**, custom separator **`EmptySelectionText`**, and a **`BindingSource`** row demonstrating **`CheckedItemList`** (initial checks applied on **`Load`** because bound items populate after handles exist).

## See also

- **`KryptonComboBoxUserControl`** — host for arbitrary drop-down **`Control`** ([issue #3443](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3443)).
- **`KryptonTreeComboBox`** — tree-style grouped combo ([issue #3444](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3444)).
- Changelog: V110 nightly section in **`Documents/Changelog/Changelog.md`**.
