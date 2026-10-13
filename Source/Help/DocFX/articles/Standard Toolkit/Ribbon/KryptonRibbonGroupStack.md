# KryptonRibbonGroupStack

`KryptonRibbonGroupStack` is a top-level ribbon group container in `Krypton.Ribbon`. It holds any number of the same child items as `KryptonRibbonGroupLines`, arranged inside the ribbon’s three-line group height. `KryptonRibbonGroupTriple` stays limited to three items. `KryptonRibbonGroupLines` stays a width-balanced row layout.

## Layout

`StackLayout` (`RibbonGroupStackLayout`) chooses the arrangement.

| Value | Large container | Medium and small container |
|-------|-----------------|----------------------------|
| `Columns` (default) | Columns of at most three. Children are medium (one line high). | Columns of at most three. Children are small. |
| `Adaptive` | One horizontal row of large (full-height) children. The row grows with the item count. | Columns of at most three. |

Items fill a column top to bottom, then the next column. A column’s width is its widest child. One pixel separates columns. Height is only the rows that are used, so one or two items stay as short as a short triple. `ItemAlignment` places a narrower child inside its column (`Near`, `Center`, `Far`), including right-to-left.

`MaximumSize` and `MinimumSize` still feed the ribbon’s shrink solutions, the same way they do on a triple.

## Child items

The `Items` collection accepts buttons, color buttons, check boxes, radio buttons, labels, custom controls, text boxes, masked text boxes, rich text boxes, combo boxes, theme combo boxes, numeric up-downs, domain up-downs, date-time pickers, track bars, and clusters. There is no count cap.

## Designer

Add Stack is on the group designer verb list, the group context menu, and the design-time New menu. A new stack is seeded with six buttons so the two-column layout is visible. The stack’s own designer can add the same children as a lines container, including a cluster and a theme combo box.
