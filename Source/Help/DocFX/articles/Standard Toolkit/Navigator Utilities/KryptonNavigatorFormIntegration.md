# KryptonNavigator Form Integration

Browser and Windows Explorer-style apps place document tabs in (or next to) the window caption while still offering minimize, maximize/restore, and close. This feature addresses [issue #925](https://github.com/Krypton-Suite/Standard-Toolkit/issues/925) and the related form button specs work in [issue #927](https://github.com/Krypton-Suite/Standard-Toolkit/issues/927).

It also covers **browser-style tab groups**, **IDE-style document groups** (`KryptonDocumentGroupHelper` / `KryptonWorkspace`), and **multi-strip caption** mode.

## Overview

| Piece | Assembly | Role |
|-------|----------|------|
| `KryptonNavigator.Owner` / `ControlKryptonFormFeatures` | `Krypton.Navigator` | Bind a form and choose who owns caption buttons |
| `Button.FormMinimizeButton` / `FormMaximizeButton` / `FormCloseButton` | `Krypton.Navigator` | Fixed specs that send `SendSysCommand` to `Owner` |
| `KryptonPage.TabGroupId` | `Krypton.Navigator` | Browser-style group membership (empty = ungrouped) |
| `KryptonNavigatorFormIntegrator` | `Krypton.Navigator.Utilities` | Turnkey wiring of form + navigator / workspace modes |
| `NavigatorTabGroup` / `NavigatorTabGroupCollection` | `Krypton.Navigator.Utilities` | Group catalog (title, color, collapsed) |
| `NavigatorTabGroupAppearance` | `Krypton.Navigator.Utilities` | Wash / accent / underline / border options for group chrome |
| `NavigatorTabGroupBarAccent` | `Krypton.Navigator.Utilities` | Light colored borders on normal bar tabs |
| `NavigatorTabGroupLayoutSerializer` | `Krypton.Navigator.Utilities` | Direct `KNFI` / `NTG` XML helpers |
| `ViewLayoutNavigatorCaptionTabs` | `Krypton.Navigator.Utilities` (internal) | Tab strip injected into form caption |
| `ViewLayoutCaptionDocumentGroups` | `Krypton.Navigator.Utilities` (internal) | One caption strip per workspace cell |
| `KryptonDocumentGroupHelper` | `Krypton.Workspace` | IDE-style split / move / close-empty helpers |
| `KryptonForm.CustomCaptionAreas` | `Krypton.Toolkit` | Multi-region caption drag hit-testing |

Ship via the aggregate `Krypton.Standard.Toolkit` NuGet package (`Krypton.Navigator.Utilities` / `Krypton.Workspace`).

## Architecture

```text
CaptionIntegrated (default, single navigator):
  KryptonForm caption
    ├── InjectViewElement(ViewLayoutNavigatorCaptionTabs, Left)
    │     └── optional group headers / accents / collapse
    └── Form min / max / close (ControlBox)
  Client area
    └── KryptonNavigator (NavigatorMode.Panel) — page content only

CaptionIntegrated + Workspace (multi-strip):
  KryptonForm caption
    └── InjectViewElement(ViewLayoutCaptionDocumentGroups, Left)
          └── one ViewLayoutNavigatorCaptionTabs per workspace cell
  Client area
    └── KryptonWorkspace (cells = document groups)

ClientChrome:
  KryptonForm (ControlBox=false)
  └── KryptonNavigator (BarTab*) + FormMinimize/Maximize/Close specs
        └── optional NavigatorTabGroupBarAccent on grouped pages

CaptionAdjacent:
  KryptonForm (normal caption)
  └── KryptonNavigator (unchanged mode) + optional Form.Text sync
```

`CaptionIntegrated` follows the same inject/revoke pattern as `KryptonRibbon` (`KryptonForm.InjectViewElement` / `RevokeViewElement`).

## Public API

### KryptonNavigator

| Member | Role |
|--------|------|
| `Owner` | `KryptonForm` that receives system commands from form button specs |
| `ControlKryptonFormFeatures` | `true` = form keeps exclusive caption buttons; `false` = navigator may show form min/max/close |
| `Button.FormMinimizeButton` / `FormMaximizeButton` / `FormCloseButton` | Fixed specs; `SC_MINIMIZE` / `SC_MAXIMIZE` / `SC_CLOSE` |

### KryptonPage

| Member | Role |
|--------|------|
| `TabGroupId` | Stable id referencing a `NavigatorTabGroup` in the host catalog; empty = ungrouped. Travels with tear-out and layout save/load. |

### KryptonNavigatorFormIntegrator

| Member | Default | Role |
|--------|---------|------|
| `Form` / `Navigator` | null | Targets for classic single-strip integration |
| `Workspace` | null | When set with CaptionIntegrated, drives multi-strip caption over workspace cells |
| `Enabled` | true | Apply / revoke |
| `Mode` | `CaptionIntegrated` | See modes below |
| `SyncFormTitle` | false | Copy selected page text to `Form.Text` (ignored in CaptionIntegrated) |
| `SuppressFormTitleWhenClientChrome` | true | Clear title when not syncing in ClientChrome / CaptionIntegrated |
| `AllowTearOut` | true | Drag tabs outside any target to create a new window |
| `CloseEmptySourceWindowAfterLastTabMoved` | true | Browser-like close of emptied source window |
| `UseBuiltInTabContextMenu` | true | Show default caption-tab menu when page does not provide one |
| `IncludeFormSystemMenuInTabContextMenu` | true | Also include form system-menu commands on the built-in tab menu |
| `ShowNewTabButton` | false | CaptionIntegrated: show a `+` button after the last tab |
| `AllowTabGroups` | true | Enable caption group chrome / built-in group menu commands |
| `TabGroups` | (collection) | Host catalog of `NavigatorTabGroup` entries |
| `TabGroupAppearance` | (defaults) | Wash strength, header accent, member underline, and member border options (Property Grid expandable) |
| `CreateGroup` / `AssignPageToGroup` / `UngroupPage` | | Membership helpers (also cluster siblings / apply bar accents) |
| `ToggleGroupCollapsed` / `MergeTabGroupsFrom` | | Collapse toggle; cross-window catalog merge |
| `SaveLayout*` / `LoadLayout*` | | Persist groups + page order (navigator) or workspace layout + `NTG` |
| `Apply()` / `Revoke()` | | Manual apply / restore |
| `IsIntegrated` | | Whether settings are applied |
| `IntegrationChanged` | | Fired after apply or revoke |
| `TabContextMenuOpening` | | Customize the built-in caption-tab menu before show |
| `NewTabButtonClick` | | Fired when the caption `+` button is clicked; host creates the page |
| `TabGroupChanged` | | Fired when group catalog or membership chrome should refresh |

### Modes

- **CaptionIntegrated** — Injects tabs into the form caption; navigator becomes `Panel` (content only); form keeps `ControlBox`. Requires themed `KryptonForm` chrome. With `Workspace` set, injects one strip per cell instead.
- **ClientChrome** — `ControlKryptonFormFeatures = false`, `Form.ControlBox = false`; navigator hosts form button specs.
- **CaptionAdjacent** — Form keeps caption buttons; optional title sync only.

## Usage

### Minimal CaptionIntegrated host

```csharp
var integrator = new KryptonNavigatorFormIntegrator
{
    Form = this,
    Navigator = kryptonNavigator1,
    Mode = NavigatorFormIntegrationMode.CaptionIntegrated,
    SyncFormTitle = false,
    AllowTearOut = true,
    CloseEmptySourceWindowAfterLastTabMoved = true,
    ShowNewTabButton = true,
    Enabled = true
};

integrator.NewTabButtonClick += (_, _) => AddPage();

NavigatorTabGroup work = integrator.CreateGroup("Work", Color.DodgerBlue, kryptonNavigator1.Pages[0]);
integrator.AssignPageToGroup(kryptonNavigator1.Pages[1], work.Id);
```

Leave `SyncFormTitle` false in CaptionIntegrated — that mode always clears `Form.Text` so the caption is not crowded by tabs and a duplicate title.

Restore a saved layout with `integrator.LoadLayoutFromFile(...)` after pages exist (or after workspace pages are recreated via `UniqueName` matching).

### Caption new-tab (`+`) button

`ShowNewTabButton` is CaptionIntegrated-only. The control is a compact chrome `+` (not a full-width tab); hovering shows a tooltip from `NavigatorFormIntegrationStrings.NewTab`. The integrator does not create pages itself; handle `NewTabButtonClick` (and/or menu / toolbar actions) to add a `KryptonPage`. Glyph / tooltip text come from `KryptonManager.Strings.NavigatorIntegrationStrings.NewTabButton` / `NewTab`.

### Built-in tab context menu

When a page does not already provide `KryptonContextMenu` or `ContextMenuStrip`, caption tabs can use the integrator's built-in menu. Menu text (and rename-dialog cue/prompt) comes from `KryptonManager.Strings.NavigatorIntegrationStrings` and is refreshed each time the menu opens; form system commands use `SystemMenuStrings`.

- `Move to new window`
- `Close tab` (`Ctrl+W`)
- `Close other tabs`
- `Close tabs to the right`
- When `AllowTabGroups` is enabled: Add to group, New group, Ungroup, Rename (`KryptonInputBox`), Recolor (`KryptonColorDialog`), Collapse/Expand

Right-clicking a caption tab shows this menu. Empty caption space still opens the themed form system menu (`KryptonSystemMenuListener` skips interactive chrome content).

Use `TabContextMenuOpening` to add, remove, or reorder menu items without replacing the whole feature:

```csharp
integrator.TabContextMenuOpening += (s, e) =>
{
    if (e.ContextMenuStrip.Items["MyNewTab"] == null)
    {
        e.ContextMenuStrip.Items.Insert(0, new ToolStripMenuItem(
            KryptonManager.Strings.NavigatorIntegrationStrings.NewTab, null, (_, _) => AddPage())
        {
            Name = "MyNewTab",
            ShortcutKeys = Keys.Control | Keys.T
        });
    }
};
```

## Browser-style tab groups

### Model

| Piece | Role |
|-------|------|
| `KryptonPage.TabGroupId` | Membership; empty = ungrouped |
| `NavigatorTabGroup` | Catalog entry: `Id`, `Title`, `Color`, `Collapsed` |
| `Integrator.TabGroups` | Host catalog |
| `Integrator.TabGroupAppearance` | Shared visual options for every group in that integrator |
| `AllowTabGroups` | Enables caption chrome for groups |

### Caption chrome

`ViewLayoutNavigatorCaptionTabs` renders:

- A group header chip before each contiguous run (collapsed headers show `Title (n)`), washed with the group color and optionally finished with a solid accent bar
- Member tabs keep a solid group-color underline in every state (including selected), so the run reads as one colored cluster
- Collapsed groups hide member tabs (header click expands / activates)
- Drag a **group header** or any member tab to move/tear out the **whole group**
- Drop onto the same strip to **reorder**, or onto another grouped tab / group header to **join** that group (instead of always tearing out)
- Drag a torn-out tab back over another integrated window to **remerge** (docking Transfer glyph or the integrator drop area); empty source windows close when that option is enabled

### Group appearance (`TabGroupAppearance`)

Adjustable at runtime and in the Visual Studio Property Grid (select the integrator → Appearance → TabGroupAppearance):

| Property | Default | Role |
|----------|---------|------|
| `HeaderWashAlpha` | 80 | Soft wash alpha (0–255) on expanded headers |
| `CollapsedHeaderWashAlpha` | 110 | Soft wash alpha on collapsed headers |
| `ShowHeaderAccent` | true | Solid accent bar under the header |
| `HeaderAccentHeight` | 3 | Accent bar height in pixels (0–8) |
| `ShowMemberUnderline` | true | Solid underline on member tabs |
| `MemberUnderlineHeight` | 3 | Underline height in pixels (0–8) |
| `ShowMemberBorder` | true | Tinted tab border via `NavigatorTabGroupBarAccent` |
| `MemberBorderWidth` | 2 | Border width in pixels (0–6; 0 clears the override) |

```csharp
integrator.TabGroupAppearance.HeaderWashAlpha = 120;
integrator.TabGroupAppearance.ShowMemberBorder = false;
```

Changes raise `PropertyChanged`, sync bar accents, and rebuild caption chrome. Non-default values serialize into the host form’s `.Designer.cs`.

### Bar-mode accents (non-caption)

When pages carry `TabGroupId` and the catalog knows the group, `NavigatorTabGroupBarAccent` tints page `State*.Tab` borders so **BarTab** / similar modes show a colored rim without full caption headers (honours `TabGroupAppearance.ShowMemberBorder` / `MemberBorderWidth` when called through the integrator). Call `SyncNavigator` / `SyncWorkspace` after manual membership edits if you are not going through the integrator APIs.

### Tear-out

`TryTearOutPages` copies referenced `NavigatorTabGroup` definitions onto the new window’s integrator (`MergeTabGroupsFrom`) so color/title/collapsed and bar accents survive. Tear-out feedback shows a lightweight `New window` overlay while dragging outside registered targets. Dragging back onto a registered integrator drop area remerges instead of spawning another host.

### Drag-to-split (Workspace)

With `Workspace` assigned, caption-tab drag registers the workspace as a `DragTargetProvider`, so dropping on a **cell edge** uses the normal workspace split targets (same as dragging from a cell tab strip).

## Save / load layouts

### Navigator-only XML (`KNFI`)

| Element | Meaning |
|---------|---------|
| Root `KNFI` (`V="1"`) | Navigator form-integration layout document |
| `NTG` / `G` | Group catalog (`Id`, `Title`, `C`, `Collapsed`) |
| `Pages` / `P` | Page order + `TabGroupId` (`UN`, `TG`) |
| `Selected` | Selected page `UniqueName` |

APIs: `SaveLayoutToXml` / `SaveLayoutToFile` / `SaveLayoutToArray` and matching `LoadLayout*`.

### Workspace / multi-strip

When `Workspace` is set, integrator `SaveLayout*` / `LoadLayout*` delegate to the workspace:

- Page `TabGroupId` is stored as the `TG` attribute on each `KP` page element
- Group catalog is embedded in workspace `GlobalSaving` / `GlobalLoading` as an `NTG` element inside `CGD`

### Docking

- If a docking workspace is the same `KryptonWorkspace` instance the integrator binds, docking `SaveConfig` / `LoadConfig` already nests workspace layout XML; the integrator’s `GlobalSaving` / `GlobalLoading` hooks then persist `NTG` with that workspace document. Keep the integrator attached for the duration of save/load.
- Standalone navigators inside docking float windows should call `SaveLayout*` / `LoadLayout*` (or `MergeTabGroupsFrom`) per host if they are not the workspace being configured.

Helper: `NavigatorTabGroupLayoutSerializer` for direct catalog / navigator layout XML if you are not using the integrator.

Smoke: `Source/TestHarnesses/NavigatorTabGroupLayoutSmoke` round-trips navigator and workspace layouts (exit code `0` = pass).

## IDE-style document groups (Workspace)

Each `KryptonWorkspaceCell` is an independent tab strip / page set. Drag-to-edge already splits cells.

Programmatic helpers in `Krypton.Workspace.KryptonDocumentGroupHelper`:

- `SplitActiveCell(workspace, orientation)`
- `MovePageToNewCell(workspace, page, orientation)`
- `CloseEmptyCells(workspace)`

### Multi-strip caption

Set `KryptonNavigatorFormIntegrator.Workspace` with `Mode = CaptionIntegrated`.

`ViewLayoutCaptionDocumentGroups` injects **one** `ViewLayoutNavigatorCaptionTabs` per workspace cell. Browser-style groups still apply **within** a strip.

`KryptonForm.CustomCaptionAreas` supports multiple client-coordinate drag bands (plus legacy `CustomCaptionArea`). DPI changes rebuild strips and refresh non-client chrome.

## Edge cases

- CaptionIntegrated needs custom form chrome (`UseThemeFormChromeBorderWidth`). Without it, injection has nowhere visible to land.
- Avoid combining CaptionIntegrated with a Ribbon that also injects caption content without testing.
- When maximized, caption tabs are vertically centered with an edge inset so they are not flush against the monitor borders (the form region clips the outer chrome).
- `Revoke()` / `Enabled = false` restores `ControlBox`, `Text`, `AllowIconDisplay`, `Owner`, `ControlKryptonFormFeatures`, and `NavigatorMode`.
- Caption tabs currently mirror page text/image with a simplified button renderer (not the full navigator tab border path). Visual parity with `BarTabOnly` can be tightened later.
- If `CloseEmptySourceWindowAfterLastTabMoved` is enabled, moving the final tab closes the now-empty source window.
- Whole-group tear-out removes every visible drag-allowed member of the group from the source navigator.
- Layout load matches pages by `UniqueName`; unknown names are skipped. Pages present in the navigator but missing from the layout keep their content but move after restored pages.
- Caption-tab drag coordinates account for window borders (`RealWindowBorders`); drops on the local strip cancel tear-out and reorder/join instead.

## Validation

- TestForm demo: **Navigator Form Integration (#925)** (`NavigatorFormIntegrationDemo`) — includes live Wash / Member border / Member underline / Header accent controls.
- Optional PowerShell helpers under `Scripts/Verification/` (see `Scripts/Verification/README.md`), including `Get-NavigatorTabGroupColourShot.ps1` for a caption colour screenshot.

## Packages

- `Krypton.Navigator` — form button specs, `TabGroupId`
- `Krypton.Navigator.Utilities` — integrator, caption strips, group catalog / appearance, bar accents, layout serializer
- `Krypton.Workspace` — `KryptonDocumentGroupHelper`, page `TG` persistence
- `Krypton.Toolkit` — `NavigatorFormIntegrationStrings`, `CustomCaptionAreas`
