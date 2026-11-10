# Timeline

## KryptonTimeline

Step list: label, icon, optional box, and a connector through the icon centres. The first item has no leading segment and the last has no trailing segment.

| Member | Behaviour |
| -------- | ----------- |
| `Orientation` | `Horizontal` (default) or `Vertical`. |
| `Layout` | `Alternate` (text on both sides), `Compact` (content on one side), `SnapIcon` (icon toward the start of the item). The property hides `Control.Layout`. |
| `Items` | `KryptonTimelineItem`: `StartText`, `EndText`, `Image`, `StartUseBox`, `EndUseBox`, `Style`, `Tag`. A fresh control has an empty collection. |
| `SelectedItem` / `SelectedIndex` | `-1` when nothing is selected. |
| `ItemClick` | Raised for a click and when the keyboard moves the selection. |
| Palette | `StateCommon`, `StateDisabled`, `StateNormal`, `StateTracking`, `StatePressed`. |

Arrow keys move the selection (left/right and up/down). Home and End jump to the ends. Drag an item to reorder the steps when `AllowMove` is true (the default).

`Style` is per item (`TimelineItemStyle`). `Normal` is the palette fill. `Hatched` draws a forward-diagonal hatch. `Completed` adds a stripe and a check. `Delayed` adds a stripe, a backward-diagonal hatch, and a dashed outline. `Cancelled` adds a muted hatch and a line through the item. The same values apply to date-timeline items, on both Chart bars and Vis boxes.

`ItemStyles` is a `TimelineItemStyleValues` storage on both controls. It uses `ExpandableObjectConverter`, so the property grid expands Hatched, Completed, Delayed, and Cancelled. Each of those is a `TimelineItemStyleColors` with `Stripe`, `Hatch`, and `Mark`. An empty colour keeps the built-in colour for that role (or draws nothing when the style has no built-in for it). Setting `Mark` on Hatched draws an outline in that colour. `Normal` has no overlay colours. A fresh control leaves every colour empty, so `ItemStyles` stays unmodified in the designer.

## KryptonDateTimeline

Horizontal date chart.

| Member | Behaviour |
| -------- | ----------- |
| `Items` | `KryptonDateTimelineItem`: `Start`, `Finish`, `Caption`, `Details`, `Image`, `Row`, `Style`, `Tag`. `IsMilestone` is true when only one date is set, or when `Finish` is not later than `Start`. |
| `ItemStyles` | Same expandable colour set as `KryptonTimeline.ItemStyles`. |
| `Style` | `Chart` (default) draws bars and diamonds on `Item.Row` under a top scale. `Vis` stacks boxes above a bottom axis. A single date is a box with a stem to a dot on the axis. A span is a range box. Overlapping items move into extra lanes. `Row` is not used for `Vis` placement. |
| `ShowTodayIndicator` | Default `true`. Draws a marker when today is inside the visible range. |
| `AutoRange` | Default `true`. The visible range is the union of item dates plus a small pad. |
| `VisibleStart` / `VisibleFinish` | Assigning either value, or zooming or panning, sets `AutoRange` to `false`. |
| `SelectedItem` / `SelectedIndex` / `ItemClick` | Same selection model as the step timeline. |

Ctrl+wheel zooms the visible range around the cursor. Dragging empty space pans. Dragging an item moves its start and finish by the same amount, so a milestone stays a milestone and a bar keeps its length. Chart style also sets `Row` from the pointer's vertical position. Vis style keeps the row and stacks again after the move. The drag turns `AutoRange` off so the scale does not jump under the pointer. Set `AllowMove` to false to leave items fixed. There is no drag-resize, dependency line, print/export, or Gantt grid in this version. In `Chart` style, rows come from `Item.Row` (0-based) until a drag changes one.

Header ticks are chosen from the visible span: hours, days, months, or years, with one major row and one minor row.

## Designer

Each control has a `ControlDesigner` and an action list. The step timeline exposes orientation, layout, palette mode, and Edit Items. The date timeline exposes style, the today indicator, auto range, palette mode, and Edit Items. Collection editors are public types on the runtime assembly so `[Editor(typeof(...))]` works on every TFM.

A parameterless construct does not seed items. `ShouldSerializeItems` is true only when `Count > 0`, so a fresh drop stays unmodified in the property grid.

## Accessibility

`CreateAccessibilityInstance` returns a list accessible object. Each item is a list item whose name is the step text, or the date-item caption (falling back to the anchor date).
