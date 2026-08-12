# Ribbon ShowTabHeaders / Toolbar Mode

## Overview

Issue [#331](https://github.com/Krypton-Suite/Standard-Toolkit/issues/331) asks for a first-class replacement for the old reflection-based “NoTabRibbon” workaround: use a ribbon as a **toolbar** by hiding the tab strip while keeping the selected tab’s groups.

Owned by **`Krypton.Ribbon`**.

## Architecture

Ribbon chrome is stacked in `_ribbonDocker`:

1. `GroupsArea` (Fill) — groups for `SelectedTab`
2. Minimize bar / QAT-below / notification bar (Bottom)
3. `TabsArea` (Top) — app button/tab, **tab strip**, button specs
4. `CaptionArea` (Top) — non-integrated caption / QAT-above / contexts

`ShowTabHeaders` does **not** remove children from the docker (that approach in PR #2501 also tore out `CaptionArea` and hit an init-order bug where `_showTabs` defaulted to `false` before `CreateViewManager` ran).

Instead, `ViewLayoutRibbonTabsArea.ApplyTabHeaderVisibility` toggles:

- `_tabsViewport.Visible` (primary — collapses preferred height; the scroll-port hosts the real tab control)
- `LayoutTabs.Visible`
- Left/right tab separators

App button/tab and ButtonSpecs stay in `TabsArea`. `CaptionArea` visibility remains controlled by `ViewDrawRibbonCaptionArea.UpdateVisible()`.

```
KryptonRibbon.ShowTabHeaders
        │
        ▼
ApplyTabHeaderVisibility()
        │
        ▼
ViewLayoutRibbonTabsArea
  ├─ LayoutAppButton / LayoutAppTab   (unchanged)
  ├─ tabsDocker
  │    ├─ _tabsViewport / LayoutTabs  ◄── hidden when false
  │    └─ ButtonSpecs                 (unchanged)
  └─ separators around tabs           ◄── hidden when false
```

## Public API

### `KryptonRibbon.ShowTabHeaders`

| | |
|---|---|
| Type | `bool` |
| Default | `true` (field initializer **and** `AssignDefaultFields`) |
| Category | Values |
| Effect | Hides/shows the tab strip; groups of `SelectedTab` remain |

Also: `ResetShowTabHeaders()`.

### `KryptonRibbonToolbar`

Subclass of `KryptonRibbon` that sets `ShowTabHeaders = false` after the base constructor. Re-declares `ShowTabHeaders` with `[DefaultValue(false)]` so the designer serializes correctly (base default is `true`).

Toolbox bitmap: `ToolboxBitmaps.KryptonRibbonToolbar.bmp`.

## Designer support

- Verbs: **Hide Tab Headers** / **Show Tab Headers** (`KryptonRibbonDesigner`)
- Smart tag: **Show Tab Headers** (`KryptonRibbonActionList`)

Both use designer transactions for undo/redo.

## Usage

```csharp
// Property on a normal ribbon
ribbon.ShowTabHeaders = false;
ribbon.SelectedTab = ribbon.RibbonTabs[0]; // keep a valid selection

// Or drop in the toolbox control
var toolbar = new KryptonRibbonToolbar();
toolbar.RibbonTabs.Add(singleTab);
```

For a leaner band, combine with existing properties:

```csharp
ribbon.ShowTabHeaders = false;
ribbon.RibbonFileAppButton.AppButtonVisible = false;
ribbon.QATLocation = QATLocation.Hidden;
ribbon.ShowMinimizeButton = false;
```

## Edge cases

| Scenario | Behavior |
|----------|----------|
| Multiple tabs, headers hidden | Groups of `SelectedTab` only; no header UI to switch (programmatic `SelectedTab` still works) |
| Mouse wheel over groups | Does **not** change tabs when headers are hidden |
| Key tips | Tab-header key tips omitted when headers are hidden |
| Contexts | Context titles still follow caption/integration rules; not removed by this property |
| Minimized mode | Still requires a valid `SelectedTab` for the minimized popup |
| Design time | Property is live (WYSIWYG); use Add Tab verb / property grid when headers are off |
