# Krypton Radial Menu

## Overview

`KryptonRadialMenu` is a OneNote-style radial popup menu in the `Krypton.Toolkit.Utilities` assembly (issue [#4172](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4172)). It is a designer `Component` (same role as `KryptonContextMenu`), not a form-hosted control and not tied to BarManager/Ribbon.

Consumers obtain it via the `Krypton.Standard.Toolkit` NuGet package (`Krypton.Toolkit.Utilities` assembly). There is no standalone Utilities NuGet package.

## Architecture

| Type | Role |
|------|------|
| `KryptonRadialMenu` | Public component: `Show` / `ShowPopup` / `Close`, lifecycle events, appearance proxies, outer-ring / shadow `State###`, context-menu import / live sync |
| `KryptonRadialMenuPresenter` | Opt-in PreferRadial helper; registers `KryptonContextMenu.AlternativeShow` when enabled |
| `KryptonRadialMenuItemCollection` | Restricted collection of radial item types |
| `KryptonRadialMenuItem` | Command sector with optional nested `Items` and `KryptonCommand` |
| `KryptonRadialMenuSliderItem` | Arc slider editor when activated |
| `KryptonRadialMenuColorPaletteItem` | Colour swatch ring (`ColorScheme` aligned with context-menu colour columns) |
| `KryptonRadialMenuFontListItem` | Scrollable font-family ring |
| `KryptonRadialMenuTextItem` | In-ring text editor (confirm / Esc cancel) |
| `KryptonRadialMenuCalendarItem` | Month / day editor (wheel changes month) |
| `VisualRadialMenuPopup` | Internal `VisualPopup` host: circular `Region`, shadow paths, keyboard, a11y, paging |
| `KryptonRadialMenuContextMenuBridge` | Projects supported `KryptonContextMenuItemBase` types into radial items |
| `RadialLayoutEngine` / `RadialMenuPainter` | Equal-angle annular sectors, hit-test (`OuterRing` vs body), GDI+ painting |

```text
KryptonContextMenu.Show
        │
        ├─ AlternativeShow hook (Utilities Presenter when PreferRadial)
        │         └─ KryptonRadialMenu (live-synced projection)
        │
        └─ null hook → VisualContextMenu (linear)
```

## Public API

### Showing and closing

```csharp
var menu = new KryptonRadialMenu();
menu.Items.Add(new KryptonRadialMenuItem("Save", (_, _) => Save()));
menu.Items.Add(new KryptonRadialMenuTextItem { Label = "Note", Text = "Hello" });
menu.Show(this);                    // centred on mouse
menu.Show(this, clientPoint);       // centred on control client point (converted to screen)
menu.ShowPopup(this, screenPt, animated: true);
menu.Close();                       // reverse close animation when AnimationStyle != None
```

### Appearance / behaviour

Proxied on `KryptonRadialMenu` / `Values` unless noted:

- `MenuRadius` / `InnerRadius` — outer and centre radii
- `Glyph` — centre image at the root level
- `MenuColor` / `SubMenuHoverColor` — accents (empty uses defaults)
- `DisplayStyle` — `Text`, `Image`, `ImageAboveText`, `TextAboveImage`
- `ItemImageSize` — sector icon size in pixels (default `24`); DPI-scaled in the popup when available
- Per-item `Image` / `ImageTransparentColor`; `KryptonRadialMenuItem` also resolves `KryptonCommand.ImageSmall` / `ImageLarge` when `Image` is unset
- `ShowShadow` — circular `VisualPopupShadow` (default `true`; applied when the popup is created)
- `ShadowOpacity` — form opacity for the shadow (default `0.18`)
- `ShowCheckedGlyph` — draws a ✓ (and marker) on checked sectors (default `true`)
- `StartAngle` — first sector angle in degrees (default `-90` = top)
- `MaxVisibleItems` — `0` unlimited; otherwise page window with prev/next affordances
- `HitPadding` — extra annular hit padding for touch (default `4`)
- `SubMenuGlyph` — Unicode character on the outer-ring arc for items that open a child/editor (default `›`); size scales with `OuterRingThickness`
- `OuterRingThickness` — outer-ring stroke / hit-band width (`0` hides the stroke)
- `AnimationStyle` / `AnimationDuration` — `None`, `FadeScale`, `Sweep` (default), `Spiral`, `Pop`; also plays on navigate and reverse close
- `PaletteMode` / `LocalCustomPalette` — resolved for painting and State### redirects
- `AllowMove` — drag the centre button to reposition; shadow tracks the popup; a click without dragging still backs/closes
- Per-item `ToolTipValues` / `ToolTipText` — Krypton `VisualPopupToolTip` on hover (`EnableToolTips` required)

#### Outer-ring `State###` (`PaletteBorder`)

- `StateCommon` / `StateNormal` / `StateTracking` / `StatePressed` / `StateDisabled`
- Per-sector ring arcs use these colours; thickness remains `OuterRingThickness`

#### Prefixed shadow `StateShadow###` (`PaletteBack`)

- `StateShadowCommon` / `StateShadowNormal` / `StateShadowTracking` / `StateShadowPressed` / `StateShadowDisabled`
- `Color1` tints the three-layer shadow ramp (default common colour black)
- Mapping while open: disabled → pressed (mouse down / drag) → tracking (pointer over) → normal

### Outer ring vs sector body

Pointer interaction is split:

- **Outer-ring band** (glyph arc) — only pointer path that opens a nested submenu or editor ring (`HasChildren`)
- **Sector body** on a parent/editor — raises `ItemClick` but does **not** drill in
- **Leaf** sector body — `PerformClick` / AutoClose as before
- **Keyboard Enter/Space** — still opens children/editors (ring is the pointer/touch affordance)

RTL hosts (`RightToLeft.Yes`) mirror start angle / sweep.

### Events

- `Opening` / `Opened` / `Closing` / `Closed`
- `ItemClick` — any activated item
- `CenterButtonClick` — root centre click (before close)
- Per-item: `Click`, `ValueChanged`, `SelectedColorChanged`, `SelectedFontChanged`, `TextChanged`, `SelectedDateChanged`

### Interaction model

1. Equal-angle sectors for visible items; centre button closes at root or navigates back (clearer back chevron when nested).
2. Parent / editor items open a child or editor ring only via the outer-ring band (or keyboard Enter).
3. Slider / colour / font / text / calendar items open an editor ring; centre returns to the previous ring.
4. Outside click, Alt, or Escape dismisses via `VisualPopupManager` (with close animation when enabled).
5. Keyboard: Left/Right/Up/Down move focus; Home/End jump; Enter/Space activate; Back backs out; Escape backs nested/editor levels, then dismisses at root.
6. Accessibility: custom `AccessibleObject` exposes sectors (and editor cells) as menu items.

## Context-menu bridge

```csharp
var radial = KryptonRadialMenu.FromContextMenu(existingContextMenu, liveSync: true);
// or
radial.ImportFrom(existingContextMenu, liveSync: true);
radial.RefreshFromContextMenu();
```

Import builds **copies / projections** for display. Live dual-hosting of the same item instance in both UIs is not supported.

Live sync:

1. **Collection** — root `Items` changes re-import the projection.
2. **Property** — `PropertyChanged` on bridged `Tag` sources updates common twins (`Text` / `Enabled` / `Visible` / `Checked` / `Image`) without a full rebuild when possible.

### PreferRadial soft hook

```csharp
KryptonRadialMenuPresenter.PreferRadialContextMenus = true;
contextMenu.Show(this, pt); // radial via KryptonContextMenu.AlternativeShow
// or explicitly:
KryptonRadialMenuPresenter.Show(contextMenu, this, clientPoint);
```

When PreferRadial is `true`, Utilities registers a soft hook on `KryptonContextMenu.AlternativeShow` so normal `Show` call sites present a live-synced radial projection. There is **no** Toolkit → Utilities project reference.

### Mapping table

| Source | Radial result |
|--------|----------------|
| `KryptonContextMenuItems` | Children flattened into the current level |
| `KryptonContextMenuItem` | `KryptonRadialMenuItem` (click invokes `source.PerformClick`) |
| `KryptonContextMenuLinkLabel` | `KryptonRadialMenuItem` (`PerformClick`) |
| `KryptonContextMenuCheckBox` / `CheckButton` / `RadioButton` | Checked-style `KryptonRadialMenuItem` |
| `KryptonContextMenuColorColumns` | `KryptonRadialMenuColorPaletteItem` |
| `KryptonContextMenuImageSelect` | Parent item with per-image children setting `SelectedIndex` |
| `KryptonContextMenuComboBox` | Parent item with children for each entry (`SelectedIndex`) |
| `KryptonContextMenuTextBox` | `KryptonRadialMenuTextItem` (commit pushes text back to source) |
| `KryptonContextMenuProgressBar` | Disabled display sector (`Value/Maximum`) |
| `KryptonContextMenuMonthCalendar` | `KryptonRadialMenuCalendarItem` (commit pushes selection back) |
| `Heading`, `Separator` | Skipped |

## Validation

TestForm demo: **Radial Menu (#4172)** (`RadialMenuDemo`), registered in `StartScreen.AddButtons()`.

Manual steps:

1. Open the demo; leave **Native radial items** selected.
2. Right-click — open Edit / Note / editors via the **outer ring**; body click on a parent does not drill; Bold body still toggles.
3. Exercise DisplayStyle / ItemImageSize / Show shadow / Checked glyph / Animation; drag centre with AllowMove and confirm shadow follows.
4. Arrow keys + Enter; Esc backs out then dismisses (close animation).
5. Switch to **Imported from KryptonContextMenu** — TextBox/MonthCalendar project to text/calendar items; separators absent.
6. Enable **PreferRadialContextMenus** and use a normal context-menu `Show` path.

Unit-test helpers: `Scripts/UnitTests/UnitTest-RadialMenu.ps1` (CI include), `Start-RadialMenuDemoHost.ps1`, `Invoke-RadialMenuScreenshot.ps1`.

Manual theme check: exercise under a few `PaletteMode` values; a full theme-matrix GIF farm is out of scope.

## Edge cases

- Empty `Items` still shows a centre-only popup that closes on centre click.
- Bridged command items do not copy `KryptonCommand` onto the radial item (avoids double execute); they call `PerformClick` on the source.
- Font list shows up to eight families at a time; mouse wheel scrolls the list.
- Circular `Region` clips the popup; shadow uses three concentric ellipse paths when `ShowShadow` is true and tracks location changes.
- `ShowShadow` is read when the popup is constructed — change it before the next `Show`.
- Packaging remains the `Krypton.Standard.Toolkit` NuGet package (no standalone Utilities package).
