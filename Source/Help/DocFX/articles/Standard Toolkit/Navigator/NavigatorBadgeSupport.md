# KryptonNavigator Badge Support

## Overview

`KryptonNavigator` now supports tab-level badges through `KryptonPage`.

This feature allows you to display notification indicators (numeric or text) directly on navigator tabs in all modes that render pages via navigator tab/check button visuals (for example bar tabs and outlook pages). The implementation reuses the existing badge rendering system in `Krypton.Toolkit`, so behavior is consistent with badge-enabled toolkit controls.

---

## Goals

- Expose a simple per-page badge API for developers.
- Reuse existing badge infrastructure (`BadgeValues`, `ViewDrawBadge`) rather than creating navigator-specific badge primitives.
- Preserve designer serialization patterns already used across the toolkit.
- Ensure badge mapping follows page-to-tab remapping in dynamic navigator scenarios.

---

## Public API

## `KryptonPage`

Badge configuration is now available directly on each page:

- `BadgeValues BadgeValues { get; }`

### Property metadata

The property is exposed in the designer as:

- Category: `Visuals`
- Description: `Badge values`
- Serialization visibility: `DesignerSerializationVisibility.Content`

### Serialization helpers

`KryptonPage` includes:

- `private bool ShouldSerializeBadgeValues()`
- `private void ResetBadgeValues()`

This matches the existing serialization model used by other value-storage properties in the toolkit.

---

## Badge object model

Badges on navigator tabs use the existing toolkit value model:

- `BadgeValues`
  - `BadgeBorderValues`
  - `BadgeColorValues`
  - `BadgeContentValues`
  - `BadgeOverflowValues`

Commonly used `BadgeContentValues` members:

- `Visible`
- `Text`
- `BadgeImage`
- `Animation`
- `Position`
- `Shape`
- `MaximumBadgeValue` (overflow threshold)

Commonly used `BadgeOverflowValues` member:

- `OverflowText` (for example `"+"` to produce `99+`)

Because navigator uses the shared badge system, all established badge capabilities (text, images, overflow, animation, shape, positioning, border, and colors) apply to navigator tabs without additional navigator-specific API.

---

## Internal architecture

## Data flow

1. You configure `page.BadgeValues`.
2. Navigator tab draw elements map the current page badge to the underlying `ViewDrawButton`.
3. `ViewDrawButton` hosts a `ViewDrawBadge`.
4. `ViewDrawBadge` renders using the configured values and invalidates when values change.

## Integration points

### 1) `KryptonPage` stores badge values

`KryptonPage` creates badge storage in its constructor:

- `_badgeValues = new BadgeValues(NeedPaintDelegate);`

Using `NeedPaintDelegate` ensures badge changes trigger visual updates through the normal Krypton paint pipeline.

### 2) Navigator tab visuals map page -> badge source

`ViewDrawNavCheckButtonBase` now calls an internal badge mapping helper when:

- the view is constructed
- the represented `Page` changes

This keeps badge rendering in sync even when view instances are reused or remapped to different pages.

### 3) `ViewDrawButton.SetBadgeValues(...)` supports rebinding

`ViewDrawButton` now handles source changes safely:

- Detects unchanged source and returns early.
- Recreates the hosted `ViewDrawBadge` when badge source/control changes.
- Disposes old badge visual to avoid stale references and leaks.
- Ensures badge enabled-state alignment with the parent button.

This is critical for navigator scenarios where a draw element may point at a different page over time.

---

## Supported navigator scenarios

Badge rendering is available anywhere navigator pages are represented by check/tab button draw elements that inherit through the existing `ViewDrawButton` path.

Typical covered scenarios include:

- Standard bar tabs (`BarTabGroup`, related tab-based modes)
- Outlook style page selectors (`OutlookFull`, `OutlookMini` via shared check-button visual model)
- Workspace-hosted navigator pages (`KryptonWorkspaceCell`) when navigator tab visuals are used

If a mode does not render page headers/tabs/check-buttons, badges are not visible by design because there is no tab visual target.

---

## Usage examples

## Basic numeric badge

```csharp
KryptonPage page = new KryptonPage();
page.Text = "Inbox";

page.BadgeValues.BadgeContentValues.Text = "3";
page.BadgeValues.BadgeContentValues.Visible = true;
```

## Overflow behavior (for example `99+`)

```csharp
page.BadgeValues.BadgeContentValues.Text = "120";
page.BadgeValues.BadgeContentValues.MaximumBadgeValue = 99;
page.BadgeValues.BadgeOverflowValues.OverflowText = "+";
page.BadgeValues.BadgeContentValues.Visible = true;
```

## Hide badge

```csharp
page.BadgeValues.BadgeContentValues.Visible = false;
```

## Image badge

```csharp
page.BadgeValues.BadgeContentValues.BadgeImage = myImage;
page.BadgeValues.BadgeContentValues.Visible = true;
```

---

## Behavior notes

- Badge visibility is controlled by `BadgeContentValues.Visible` and content availability.
- If `Text` is empty and `BadgeImage` is null, badge rendering is suppressed.
- Overflow conversion happens only for numeric text when `MaximumBadgeValue > 0`.
- Badge invalidation is tied to `NeedPaint`, so property changes repaint without manual refresh calls.
- Badge position is relative to the tab/check-button client rectangle using badge position settings.

---

## Designer usage

In WinForms designer:

1. Select a `KryptonPage`.
2. Expand `BadgeValues`.
3. Configure:
   - `BadgeContentValues.Text`
   - `BadgeContentValues.Visible`
   - Optional color/border/shape/overflow settings.

Values serialize into designer-generated code using normal content serialization patterns.

---

## Manual verification checklist

Use this checklist when validating badge behavior:

- Badge appears when `Visible = true` and text/image is set.
- Badge hides when `Visible = false`.
- Numeric overflow displays threshold format (for example `99+`).
- Badge updates immediately when text changes at runtime.
- Badges remain correct when:
  - selecting different pages
  - switching navigator mode
  - using overflow-capable page arrangements
  - reusing/remapping page views (dynamic navigator/workspace scenarios)

---

## Performance and lifecycle

- Badge visuals are lightweight and only created when badge mapping is configured.
- Rebinding logic disposes old badge visuals before replacing them.
- `ViewDrawButton` now explicitly disposes hosted badge visuals in `Dispose(bool)`.

This avoids retained badge visuals across remapped page-tab relationships.

---

## Compatibility notes

- Feature is additive and non-breaking.
- Existing navigator pages continue to render unchanged unless badge values are configured.
- Existing toolkit badge behavior remains unchanged; navigator simply consumes the same primitives.

---

## Troubleshooting

## Badge not showing

Check:

- `page.BadgeValues.BadgeContentValues.Visible == true`
- Either `Text` is non-empty or `BadgeImage` is assigned
- The current navigator mode actually renders tabs/check-buttons

## Overflow not applied

Check:

- `MaximumBadgeValue > 0`
- `Text` contains a parseable integer value

## Badge appears stale after dynamic page operations

This should be addressed by the rebinding logic in `ViewDrawButton.SetBadgeValues(...)`. If observed, verify that the page assignment path triggers `ViewDrawNavCheckButtonBase.Page` updates.
