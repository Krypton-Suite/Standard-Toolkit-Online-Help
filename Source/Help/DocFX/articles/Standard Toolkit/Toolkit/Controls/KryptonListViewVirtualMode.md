# KryptonListView Virtual Mode

## Overview

`KryptonListView` is a themed wrapper around WinForms `ListView`. Virtual mode was previously commented out, so large-list consumers could not drive the control the same way as native `ListView`. Issue [#3847](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3847) exposes the native virtual-mode surface on the wrapper.

Package: `Krypton.Toolkit`.

## Architecture

`KryptonListView` hosts an inner `InternalListView` (`System.Windows.Forms.ListView`). Virtual-mode properties and events pass through to that inner control:

- `VirtualMode` / `VirtualListSize` read and write `_listView`.
- `RetrieveVirtualItem`, `CacheVirtualItems`, `SearchForVirtualItem`, and `VirtualItemsSelectionRangeChanged` are subscribed on `_listView` and raised again with `KryptonListView` as sender.
- After `RetrieveVirtualItem` returns a non-null `e.Item`, `SetItemState` applies palette colours and font (same path as non-virtual selection changes).
- `UpdateStateAndPalettes` does **not** enumerate `Items` when `VirtualMode` is true. Enumeration would fire `RetrieveVirtualItem` for every row. Visible items are invalidated so the next retrieve reapplies palette colours.

```
Consumer  --VirtualMode/VirtualListSize-->  KryptonListView  -->  InternalListView
Consumer  <--RetrieveVirtualItem/Cache...--  KryptonListView  <--  InternalListView
```

## Public API

### Properties

| Member | Default | Notes |
|--------|---------|--------|
| `bool VirtualMode` | `false` | Same constraints as native `ListView`. |
| `int VirtualListSize` | `0` | Must be >= 0. Set after `RetrieveVirtualItem` is handled. |

### Events

| Event | Required | Purpose |
|-------|----------|---------|
| `RetrieveVirtualItem` | Yes when `VirtualListSize` > 0 | Supply `e.Item` for `e.ItemIndex`. |
| `CacheVirtualItems` | No | Prefetch backing data for `StartIndex`–`EndIndex`. |
| `SearchForVirtualItem` | For `FindItemWithText` / type-ahead | Set `e.Index` or `-1`. |
| `VirtualItemsSelectionRangeChanged` | No | Multi-select range changes in virtual mode. |

## Usage

```csharp
kryptonListView.View = View.Details;
kryptonListView.FullRowSelect = true;
kryptonListView.RetrieveVirtualItem += (sender, e) =>
{
    e.Item = CreateItem(e.ItemIndex); // never leave Item null
};
kryptonListView.VirtualMode = true;
kryptonListView.VirtualListSize = data.Count;
```

Enable order: handle `RetrieveVirtualItem`, set `VirtualMode = true` while `Items` is empty, then set `VirtualListSize`.

After the backing store changes, update `VirtualListSize` and call `Refresh` or `RedrawItems`.

## Native constraints (unchanged)

These are WinForms `ListView` rules, not Krypton-specific:

- `VirtualMode` cannot be turned on while `Items`, `CheckedItems`, or `SelectedItems` contain items.
- `CheckBoxes` and `LabelEdit` are not supported.
- Sorting and groups have limited or no support.
- Leaving `RetrieveVirtualItem` unhandled (or `e.Item` null) throws when the control paints a virtual row.

## Edge cases

- **Theme changes:** palette colours are applied in `OnRetrieveVirtualItem` after the consumer sets `e.Item`. Do not walk `Items` in virtual mode.
- **Details headers:** the inner `SysHeader32` is subclassed and painted with `PaletteBackStyle.GridHeaderColumnList` (same family as DataGridView list headers). Items remain native.
- **Krypton scrollbars:** overlay bars keep `WS_VSCROLL` on the inner `ListView` (hiding only the native thumb) and send `LVM_SCROLL` in pixels. Removing `WS_VSCROLL` prevents virtual-mode scrolling.
- **Sender:** events use the `KryptonListView` instance, not the inner `ListView`.
- **Designer:** `VirtualMode` can be true at design time while `VirtualListSize` stays 0. Wire `RetrieveVirtualItem` at runtime before raising the size.
- **C# / TFM:** pass-through API; `net472` and C# 7.3 compatible.
