# DateTimePicker / MonthCalendar views

## Overview

`KryptonDateTimePicker` does not wrap the Win32 `DateTimePicker`. Its drop-down is a themed `KryptonContextMenuMonthCalendar`. Win32 messages such as `DTM_GETMONTHCAL` and `MCM_SETCURRENTVIEW` therefore have no effect.

`CalendarView` adds themed month and year grids so consumers can pick “MMMM yyyy” (or year only) without leaving Krypton palettes.

Owned by `Krypton.Toolkit`. Ribbon and DataGridView date-time hosts forward the same property.

## Public API

```csharp
public enum MonthCalendarView
{
    Days,    // day grid (default)
    Months,  // 12 months of one year
    Years    // 12 years of a decade
}
```

Properties:

- `KryptonDateTimePicker.CalendarView`
- `KryptonMonthCalendar.CalendarView`
- `KryptonContextMenuMonthCalendar.CalendarView`
- `KryptonRibbonGroupDateTimePicker.CalendarView`
- `KryptonDataGridViewDateTimePickerColumn.CalendarView` / cell

## Usage

```csharp
kryptonDateTimePicker.Format = DateTimePickerFormat.Custom;
kryptonDateTimePicker.CustomFormat = "MMMM yyyy";
kryptonDateTimePicker.CalendarView = MonthCalendarView.Months;
```

Year-only:

```csharp
kryptonDateTimePicker.CustomFormat = "yyyy";
kryptonDateTimePicker.CalendarView = MonthCalendarView.Years;
```

`CustomFormat` only changes the edit text. `CalendarView` changes the drop-down.

## Behaviour

- **Days**: existing day grid. Header click drills up to months, then years. Cell click in a drilled-up view returns toward days unless `CalendarView` is Months or Years (those views cannot drill below their setting).
- **Months**: drop-down opens on a 4×3 month grid. Clicking a month commits the selection (keeps the previous day-of-month when valid) and closes a context-menu calendar. Header click opens years.
- **Years**: drop-down opens on a 4×3 year grid. Clicking a year commits (keeps previous month and day when valid).
- Prev/next buttons step by month, year, or decade according to the displayed view. Those changes slide; header drill-up zooms out and cell drill-down zooms in (~200ms, ease-out).
- Week numbers and the Today footer apply to the day grid only.

## Architecture

`ViewLayoutMonths` holds `DisplayView` (may be higher than `CalendarView` after header drill-up). `ViewDrawMonth` hides the day-name/day grid and shows `ViewDrawMonthYearCells` when not in `Days`. `MonthCalendarController` uses the same hit-testing path; range-drag applies only in `Days`.
