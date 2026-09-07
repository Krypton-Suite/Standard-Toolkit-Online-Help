# Krypton Toolkit - WinForms Controls & Features Audit

**Last reviewed:** 2026-09-07 against V110 Nightly (Build 2611) source.

This audit compares the Standard Toolkit against standard Windows Forms controls and common modern UI patterns. Package placement matters: many extras live in `Krypton.Toolkit.Utilities` (NuGet: [Krypton.Standard.Toolkit](https://www.nuget.org/packages/Krypton.Standard.Toolkit)), not in `Krypton.Toolkit`.

---

## Executive Summary

Core `Krypton.Toolkit` covers almost every commonly used WinForms control, plus theming, ribbon/navigator/docking/workspace in sibling assemblies, and a large Utilities catalog. Remaining standard gaps are specialised (page setup, charting, a dedicated `SplitButton` type) rather than everyday form controls.

Previous versions of this document were out of date. Notable corrections from this review:

| Claim in the old audit | Actual status |
| --- | --- |
| `KryptonToolTip` not implemented | Implemented in `Krypton.Toolkit` (`IExtenderProvider`, hosted content, palette) |
| `KryptonPrintPreviewDialog` / `PrintPreviewControl` missing | Implemented in `Krypton.Toolkit` |
| `KryptonHScrollBar` / `KryptonVScrollBar` missing | Implemented; `KryptonScrollBar` is obsolete (remove in V120 LTS) |
| `KryptonSplitButton` fully implemented | **No such type.** Use `KryptonDropButton` with `Splitter` (default `true`) |
| Markdown editor / preview fully implemented | **No such types** |
| `KryptonCodeEditor` / `KryptonSearchBox` / `KryptonAboutBox` in core | They are in `Krypton.Toolkit.Utilities` |
| `KryptonCommandLinkButton` in core | Vista-style command link is Utilities; core has `KryptonAlternateCommandLinkButton` |
| ListView virtual / groups / tile, TreeView checkboxes, ComboBox DropDownList | All present on the core controls |

**Coverage of common WinForms UI controls:** effectively complete for everyday forms. **Quality:** high, with ongoing DPI/accessibility work rather than a blank slate.

---

## 1. IMPLEMENTED CONTROLS — `Krypton.Toolkit`

### Core input

- **KryptonButton**
- **KryptonCheckBox**
- **KryptonCheckButton**
- **KryptonRadioButton**
- **KryptonTextBox** — includes `CueHint` watermark/placeholder
- **KryptonMaskedTextBox**
- **KryptonRichTextBox** — includes justify (#4008)
- **KryptonComboBox** — `DropDown`, `DropDownList`, and `Simple` (#4339); `AutoCompleteMode` / `AutoCompleteSource`; `DrawMode` exposed
- **KryptonNumericUpDown** / **KryptonDomainUpDown** — themed glyphs (#4049)
- **KryptonDateTimePicker** — month/year-only display (#4193)
- **KryptonMonthCalendar**
- **KryptonColorButton**
- **KryptonTrackBar**
- **KryptonDropButton** — drop-down button; `Splitter` defaults to `true` (split-button behaviour)
- **KryptonAlternateCommandLinkButton** — command-link styled `KryptonButton` (the Vista-style `KryptonCommandLinkButton` is Utilities)

### Extended input (Krypton-specific)

- **KryptonCheckSet** — mutually exclusive checkbox group
- **KryptonToggleSwitch** — styles and optional vertical orientation
- **KryptonCalcInput**
- **KryptonSearchBox** is **not** in core; see Utilities
- **KryptonRating** — Toolbox star/heart/circle/image ratings; Full / Half / Exact precision (#3928)
- **KryptonTagInput** / **KryptonTagChip** — wrap-capable tag editor (#3927)

### Display

- **KryptonLabel** / **KryptonLinkLabel** / **KryptonWrapLabel** / **KryptonLinkWrapLabel**
- **KryptonProgressBar**
- **KryptonPictureBox**
- **KryptonHScrollBar** / **KryptonVScrollBar**
- **KryptonScrollBar** — obsolete wrapper; use H/V; removal planned for V120 LTS
- **KryptonPropertyGrid**
- **KryptonBorderEdge** / **KryptonSeparator**

### List and data

- **KryptonListBox** / **KryptonCheckedListBox**
- **KryptonListView** — `VirtualMode` / `VirtualListSize` / `RetrieveVirtualItem` / `CacheVirtualItems` (#3847); `ShowGroups`; `View` including Tile; `StateImageList`; `Sorting`; themed column headers; `ShowItemToolTips` via `KryptonToolTip` (#4336)
- **KryptonTreeView** — `CheckBoxes`; `StateImageList` / `ImageList`; `MultiSelect`; `RightToLeftLayout`
- **KryptonDataGridView** — inherits `DataGridView` (including `VirtualMode`) plus custom columns:
  - TextBox, ComboBox, CheckBox, Button, Link, Image
  - DateTimePicker, NumericUpDown, DomainUpDown, MaskedTextBox
  - Progress, Rating, Icon
- **KryptonBindingNavigator** — First/Previous/Next/Last, position, count, Add/Delete, BindingSource

### Container and layout

- **KryptonPanel** / **KryptonGroup** / **KryptonGroupBox**
- **KryptonHeader** / **KryptonHeaderGroup**
- **KryptonSplitContainer** / **KryptonSplitter**
- **KryptonTableLayoutPanel** / **KryptonFlowLayoutPanel**
- **KryptonBreadCrumb**
- **KryptonToolStripContainer**

### Form and dialogs

- **KryptonForm** — caption chrome, help button, fade values, pulsing border, `MenuBar` / title-bar menu bind, RTL caption buttons
- **KryptonFormTitleBar**
- **KryptonMessageBox** — optional Copy button; overlay icons
- **KryptonInputBox** / **KryptonInputBoxManager**
- **KryptonTaskDialog** — Vista-style; RTF on rich-text elements (#4287)
- **KryptonColorDialog** / **KryptonFontDialog**
- **KryptonOpenFileDialog** / **KryptonSaveFileDialog** / **KryptonFolderBrowserDialog** — shell wrappers (`FileDialogWrapper` / `ShellDialogWrapper`), DPI-aware custom UI
- **KryptonPrintDialog** / **KryptonPrintDocument**
- **KryptonPrintPreviewDialog** / **KryptonPrintPreviewControl**
- **KryptonInformationBox**
- **KryptonSplashScreen** — static Show / ShowAsync API (richer manager is Utilities)
- Toolkit also has an **internal** `KryptonExceptionDialog` helper; the public consumer API is Utilities

There is **no** public `KryptonAboutBox` in core; that lives in Utilities.

### Menu and toolbar

- **KryptonContextMenu** — full `ContextMenuStrip` replacement, plus:
  - CheckBox, CheckButton, RadioButton, Item, Items
  - ComboBox, TextBox, LinkLabel
  - ColorColumns, ImageSelect, MonthCalendar, ProgressBar
  - Heading, Separator
  - Gallery / GalleryItem / GalleryRange (in-menu galleries, live preview) (#3862)
  - Mini Toolbar pairing (designer-configurable)
- **KryptonMenuBar** — native bar (not a `MenuStrip` subclass); `KryptonContextMenuItem` tops + context drop-downs; assign `KryptonForm.MenuBar` (#4242)
- **KryptonMenuStrip** — themed `MenuStrip` with `PaletteMode` / `Palette` (#1110 / #2689)
- **KryptonToolStrip** / **KryptonToolStripMenuItem** / **KryptonToolStripComboBox** / **KryptonToolStripThemeComboBox**
- **KryptonStatusStrip** / **KryptonProgressBarToolStripItem**

### Web

- **KryptonWebBrowser** — wraps `WebBrowser` (IE engine). Modern Chromium hosting is **KryptonWebView2** in Utilities.

### Notifications and chrome helpers

- **KryptonToastNotificationManager** — Toolbox stub; **toast UI is `KryptonToast` in Utilities**
- **KryptonPoweredByButton** / **KryptonToolkitPoweredByControl**
- **KryptonSystemMenu**

### Providers and components

- **KryptonToolTip** — `IExtenderProvider` (`SetKryptonToolTipTitle` / Description / Image / Content); themed `VisualPopupToolTip`; optional hosted controls (hyperlinks, any Control) (#4192)
- **KryptonErrorProvider**
- **KryptonNotifyIcon**
- **KryptonHelpProvider** / **KryptonHelpCommand**
- **KryptonFileSystemWatcher**
- **KryptonTimer**
- **KryptonCommand** and integrated toolbar commands (Cut/Copy/Paste/Save/Print/PrintPreview/PageSetup/QuickPrint)
- **KryptonManager** — global palette, strings, touchscreen scaling, pulsing-border defaults
- **KryptonCustomPaletteBase** — `.kthemex` / `.ktheme` / XML; collections; thumbnails
- **KryptonThemeBrowser** / **KryptonThemeComboBox** / **KryptonThemeListBox** / **KryptonThemeListView** (previews, live hover preview) (#3870)

---

## 2. IMPLEMENTED CONTROLS — `Krypton.Toolkit.Utilities`

Require the **Krypton.Standard.Toolkit** package (`Krypton.Toolkit.Utilities` assembly).

### Editors and specialised input

- **KryptonCodeEditor** — native syntax highlighting, line numbers, folding, auto-complete (14+ languages); no Scintilla dependency
- **KryptonSearchBox** — search/clear button specs on `KryptonTextBox`
- **KryptonAutoTextSuggestion**
- **KryptonTreeComboBox**
- **KryptonMultiColumnComboBox**
- **KryptonCheckedListComboBox**
- **KryptonComboBoxUserControl** — drop-down hosting an arbitrary user control
- **KryptonTagInputControl** — panel-hosted tag editor (core also has `KryptonTagInput`)
- **KryptonEnumButton** / **KryptonEnumCommandLinkButton**
- **KryptonCountdownButton**
- **KryptonCheckBoxExtended**
- **KryptonKnob** / **KryptonKnobAlternate**
- **KryptonCircularProgressBar**
- **KryptonQRCode**
- **KryptonDropZone**
- **KryptonCommandLinkButton** — Vista-style command link

There is **no** `KryptonMarkdownEditor` or `KryptonMarkdownPreview`.

### Dialogs and shells

- **KryptonAboutBox** — comprehensive About (#2222)
- **KryptonExceptionDialog** — public API
- **KryptonFoldableDialog**
- **KryptonMessageBoxExtended**
- **KryptonBugReportingDialog** / GitHub issue report
- **KryptonSystemInformation** — msinfo32-style (#3176)
- **KryptonSplashScreenManager**
- **KryptonToast** — toast notifications (use this, not the Toolkit manager stub)
- **KryptonOAuth2** login UI

### File system, browser, colour

- **KryptonFileSystemListView** / **KryptonFileSystemTreeView** / **KryptonSystemTreeView**
- **KryptonExplorerBrowser** / **KryptonBrowserControl**
- **KryptonWebView2** — Chromium (`WebView2`)
- **KryptonScreenColorPicker** / **KryptonColourPicker**
- **KryptonCheckSum** / verify-file checksum UI

### Menus, strips, radial

- **KryptonRadialMenu** / **KryptonRadialMenuControl**
- **KryptonEnhancedContextMenu** / **KryptonMiniToolbar**
- ToolStrip suite (#4048): enhanced strip/status, hosted editors, MRU items, UAC shield, loading circle, toolbar slider, blinking status label, floating toolbars
- **KryptonHtmlToolTipContent** — HTML fragment helper for `KryptonToolTip` hosted content

### Logging, palettes, strings

- **KryptonLog** / **KryptonLogViewer**
- **KryptonPaletteCollectionEditor**
- **KryptonPaletteFileListBox** / **KryptonPaletteFileComboBox** / **KryptonPaletteFileTreeView**
- **KryptonCustomThemeGenerator** / **KryptonCustomThemeBuilder**
- **KryptonCustomStrings** / **KryptonCustomStringsManager**
- **KryptonMultiSelectTreeView** — rubber-band / Ctrl-Shift selection (core `KryptonTreeView` also has `MultiSelect`)
- **KryptonPrintPreviewControl** — Utilities variant (Toolkit also has one)

---

## 3. SIBLING LIBRARIES

| Assembly | Role |
| --- | --- |
| **Krypton.Themes** | Extra builtin palettes (optional; auto-discovered). Toolkit must not project-reference Themes. |
| **Krypton.Ribbon** | Office-style ribbon, galleries, QAT, backstage, `KryptonRibbonToolbar`. RTL (#2382). DPI-scaled QAT overflow (#4253, #4254). |
| **Krypton.Navigator** | Full `TabControl` replacement (15+ modes: bar tabs, ribbon tabs, Outlook, buttons, stacked, …). |
| **Krypton.Navigator.Utilities** | `KryptonNavigatorFormIntegrator` (caption-integrated tabs, #925), `KryptonTabbedMdiManager`, `KryptonNavigatorTaskbarThumbnails` (#882, #4129). |
| **Krypton.Workspace** | Tileable workspace of `KryptonPage`s. |
| **Krypton.Docking** | Docking via `KryptonDockingManager` (auto-hide, float, persist). |
| **Krypton.Toolkit.JumpList** | `WpfJumpListBridge` — WinForms jump lists via WPF `System.Windows.Shell.JumpList`. |
| **Krypton.Interop** | Internal Win32 / nullable polyfills; bundled in module packages, not a consumer package. |

For simple tabs, use `KryptonNavigator` with `NavigatorMode.BarTabGroup`. There is no separate `KryptonTabControl`.

---

## 4. REMAINING STANDARD WINFORMS GAPS

Only items that still have no Krypton type (or no dedicated type) belong here.

### Use a sibling or existing control instead

| Standard | Use instead |
| --- | --- |
| TabControl | `KryptonNavigator` (`BarTabGroup` for simple tabs) |
| ContextMenuStrip | `KryptonContextMenu` |
| SplitButton | `KryptonDropButton` (`Splitter` defaults to `true`). No `KryptonSplitButton` class. |
| WebBrowser (Chromium) | `KryptonWebView2` (Utilities). `KryptonWebBrowser` is the IE `WebBrowser` wrapper. |
| ToolTip | `KryptonToolTip` (core) and/or per-control `ToolTipValues` |

### Not implemented (and usually not needed)

| Control | Impact | Notes |
| --- | --- | --- |
| **PageSetupDialog** | Low | Printing; `KryptonIntegratedToolbarPageSetupCommand` exists, but no themed page-setup dialog. |
| **ImageList** | Low | Non-visual; standard `ImageList` works with ListView/TreeView/ToolStrip. |
| **BindingSource** | Low | Non-visual; works with Krypton data controls. `KryptonBindingNavigator` is the themed navigator. |
| **BackgroundWorker** | None | Non-visual; no themed version required. |

### Not implemented (optional product)

| Control | Impact | Notes |
| --- | --- | --- |
| **Chart** (`System.Windows.Forms.DataVisualization.Charting`) | Medium | Not part of inbox WinForms on all TFMs; recommend a third-party chart or a future Utilities control. |
| **Dedicated KryptonSplitButton** | Low | API sugar over `KryptonDropButton`; not required for parity. |

---

## 5. REMAINING MODERN / ADVANCED GAPS

### Missing (not in Toolkit or Utilities)

- **Markdown editor / preview** — previously listed as done; there is no `KryptonMarkdownEditor` or `KryptonMarkdownPreview`. Closest: `KryptonCodeEditor` (Utilities) with Markdown highlighting, or host HTML in `KryptonWebView2`.
- **Automatic OS dark / light follow** — many dark, light, and high-contrast **builtin palettes** exist (#1551, #942, #4168). There is no automatic switch when Windows “Apps use light theme” or High Contrast changes.
- **Charting** — see above.

### Implemented (were listed as gaps)

- **Search box** — `KryptonSearchBox` (Utilities)
- **Rating** — `KryptonRating` (core)
- **Tag / token input** — `KryptonTagInput` (core) and `KryptonTagInputControl` (Utilities)
- **Code editor** — `KryptonCodeEditor` (Utilities)
- **Breadcrumb** — `KryptonBreadCrumb`
- **Touch scaling** — `KryptonManager.UseTouchscreenSupport` / `TouchscreenSettings`
- **Print preview** — `KryptonPrintPreviewDialog` / `KryptonPrintPreviewControl` (core)
- **Standalone H/V scrollbars** — `KryptonHScrollBar` / `KryptonVScrollBar`

### High DPI / scaling

**Status:** Substantial support; remaining work is verification on individual controls, not a missing subsystem.

- `VisualForm` / `KryptonForm` handle `DpiChanged` and update DPI factors.
- Ribbon QAT overflow, extra button, and related glyphs scale with DPI (#3851, #4253, #4254).
- High-DPI magenta image-border fix (#3736).
- File dialogs handle `DpiChanged`.
- Per-monitor DPI awareness is an **application** manifest / `ApplicationConfiguration` setting; Krypton cannot force it for the host exe.

---

## 6. ACCESSIBILITY

Not a blank audit. Coverage is real but not a substitute for Narrator/JAWS/NVDA sign-off on every control.

| Area | Status |
| --- | --- |
| **AccessibleName / Description / Role** | Inherited from `Control`; usable on all Krypton controls |
| **Custom AccessibleObject** | Present for TextBox, ComboBox, ListBox, ListView, CheckedListBox, Numeric/Domain UpDown, MaskedTextBox, RichTextBox, RadioButton, CheckButton, DropButton, ColorButton, LinkWrapLabel, Rating, command links, ButtonSpecs (#3658) |
| **Keyboard / tab order** | Standard WinForms tab order; mnemonics on buttons/labels; MenuBar Alt activation; Ribbon keytips |
| **High contrast palettes** | Builtin modes: `HighContrast`, Office 2007/2010/2013, Sparkle, Material (+ Ripple) (#4168). Glass/transparency disabled when `SystemInformation.HighContrast` |
| **Automatic high-contrast theme switch** | Not implemented (palettes exist; app must select them) |
| **Screen readers (Narrator / JAWS / NVDA)** | Partial via UIA from AccessibleObjects; no dedicated automation-peer layer (WinForms uses MSAA/UIA, not WPF AutomationPeer) |

---

## 7. FEATURE COMPLETENESS ON EXISTING CONTROLS

### KryptonListView

- Virtual mode, groups, tile/large/small/details views, state images, sorting property, themed headers, Krypton item tooltips — **present**
- Open: dedicated sort **glyphs** in themed headers (column click is exposed; visual indicator completeness still worth a pass)

### KryptonTreeView

- CheckBoxes, ImageList, StateImageList, MultiSelect, RightToLeftLayout — **present**
- Open: node state persistence is application-level, not a built-in serializer

### KryptonComboBox

- DropDown / DropDownList / Simple, AutoComplete, DrawMode — **present**
- Grid combo cells still reject `Simple` (always-visible list cannot live in a cell)

### KryptonDataGridView

- Inherits standard `DataGridView` features including VirtualMode
- Extra column types as listed above
- Themed overlay scrollbars (native scroll path restored #3682)
- Open: treat “every DGV event/paint customisation” as inherited unless a specific gap is filed

### KryptonTextBox

- CueHint (optional shimmer), AutoComplete, ButtonSpecs, pulsing border — **present**

### Cross-cutting

| Topic | Status |
| --- | --- |
| RTL | Forms, many controls, Ribbon (#2382). Continue to verify Utilities extras. |
| Touch | Global scale via `KryptonManager` |
| Designer “Modified” on drop | Constructor factory defaults (#4325) |
| Pulsing / glowing borders | Per-control and `KryptonManager.PulsingBorderValues` (#4248, #3784) |

---

## 8. WINFORMS ON .NET 5+

| Feature | Status |
| --- | --- |
| Task dialogs | `KryptonTaskDialog` |
| Async Show / ShowDialog (.NET 9+) | `KryptonFormAsync` helpers; splash/message APIs expose `ShowAsync` where applicable (#4177) |
| Dark / light | Many builtin dark/light palettes; no auto OS follow |
| High contrast | Builtin palettes; no auto OS follow |
| File pickers | Custom Krypton shell dialogs, not the raw Win11 `IFileDialog` chrome (by design for theming) |
| UIA | Custom AccessibleObjects; not a full Win11 UIA rewrite |

---

## 9. WHAT KRYPTON HAS THAT STOCK WINFORMS DOES NOT

- Theme catalog (core + extra Themes assembly), `.kthemex` / collections / thumbnails / live preview
- Ribbon, Navigator, Workspace, Docking
- Native MenuBar + rich ContextMenu (galleries, mini toolbar)
- Toggle switch, rating, tag input, calc input, breadcrumb
- Toast (Utilities), splash, About, exception, foldable dialog, system information
- Code editor, search box, knobs, radial menu, WebView2, screen colour picker, QR, drop zone
- Command links, enum buttons, binding navigator
- Jump lists (JumpList assembly)

---

## 10. RECOMMENDATIONS

### Critical

None remaining for standard WinForms coverage. Previous critical items (`ErrorProvider`, `ToolTip`, `FlowLayoutPanel`, `NotifyIcon`, `HelpProvider`, `Splitter`) are done.

### High (quality, not missing controls)

1. **Accessibility pass** — exercise Narrator (and optionally NVDA) on MenuBar, TagInput, Rating, ListView virtual mode, Navigator caption tabs, Ribbon RTL.
2. **DPI spot-check** — Utilities extras and remaining owner-draw controls at 150% / 200% per-monitor.
3. **Document WinForms → Krypton mapping** for consumers (this file plus README); keep Utilities vs Toolkit placement explicit.

### Medium (optional new product)

1. **Markdown editor / preview** — only if product wants a first-class control; do not document as existing.
2. **Page setup dialog** — themed `PageSetupDialog` if print apps need it.
3. **OS theme follow** — optional `KryptonManager` hook for AppsUseLightTheme / High Contrast.
4. **Charting** — prefer documenting a third-party recommendation over a from-scratch chart.

### Low

1. Dedicated `KryptonSplitButton` subclass (cosmetic API over `KryptonDropButton`).
2. Themed `ImageList` / `BindingSource` — not useful.
3. Remove obsolete `KryptonScrollBar` in V120 LTS (already planned).
4. Flesh out or delete `KryptonToastNotificationManager` so consumers are not pointed at an empty Toolkit stub.

### Do not implement as a separate control

- **KryptonTabControl** — Navigator `BarTabGroup` is the replacement.

---

## 11. CONTROL MAPPING TABLE

| Standard WinForms | Krypton equivalent | Assembly | Notes |
| --- | --- | --- | --- |
| Button | KryptonButton | Toolkit | |
| SplitButton | KryptonDropButton (`Splitter`) | Toolkit | No `KryptonSplitButton` type |
| CheckBox | KryptonCheckBox | Toolkit | Extended variant in Utilities |
| RadioButton | KryptonRadioButton | Toolkit | |
| TextBox | KryptonTextBox | Toolkit | CueHint, ButtonSpecs |
| Search-style TextBox | KryptonSearchBox | Utilities | |
| RichTextBox | KryptonRichTextBox | Toolkit | |
| MaskedTextBox | KryptonMaskedTextBox | Toolkit | |
| ComboBox | KryptonComboBox | Toolkit | Simple + DropDownList + AutoComplete |
| ListBox | KryptonListBox | Toolkit | |
| CheckedListBox | KryptonCheckedListBox | Toolkit | |
| ListView | KryptonListView | Toolkit | Virtual, groups, tile |
| TreeView | KryptonTreeView | Toolkit | CheckBoxes, StateImageList, MultiSelect |
| DataGridView | KryptonDataGridView | Toolkit | Extra column types |
| Label / LinkLabel | KryptonLabel / LinkLabel / Wrap* | Toolkit | |
| PictureBox | KryptonPictureBox | Toolkit | |
| ProgressBar | KryptonProgressBar | Toolkit | Circular in Utilities |
| TrackBar | KryptonTrackBar | Toolkit | |
| HScrollBar / VScrollBar | KryptonHScrollBar / KryptonVScrollBar | Toolkit | `KryptonScrollBar` obsolete |
| NumericUpDown / DomainUpDown | KryptonNumericUpDown / DomainUpDown | Toolkit | |
| DateTimePicker / MonthCalendar | KryptonDateTimePicker / MonthCalendar | Toolkit | |
| Panel / GroupBox | KryptonPanel / GroupBox / Group | Toolkit | |
| SplitContainer / Splitter | KryptonSplitContainer / Splitter | Toolkit | |
| TabControl | KryptonNavigator | Navigator | `BarTabGroup` for simple tabs |
| TableLayoutPanel / FlowLayoutPanel | KryptonTableLayoutPanel / FlowLayoutPanel | Toolkit | |
| Form | KryptonForm | Toolkit | |
| ToolStrip / StatusStrip / MenuStrip | KryptonToolStrip / StatusStrip / MenuStrip | Toolkit | Native MenuBar also available |
| ContextMenuStrip | KryptonContextMenu | Toolkit | |
| WebBrowser | KryptonWebBrowser | Toolkit | IE engine |
| WebView2 | KryptonWebView2 | Utilities | Chromium |
| PropertyGrid | KryptonPropertyGrid | Toolkit | |
| ErrorProvider | KryptonErrorProvider | Toolkit | |
| ToolTip | KryptonToolTip | Toolkit | Also `ToolTipValues` on controls |
| NotifyIcon | KryptonNotifyIcon | Toolkit | |
| HelpProvider | KryptonHelpProvider | Toolkit | |
| BindingNavigator | KryptonBindingNavigator | Toolkit | |
| Timer | KryptonTimer | Toolkit | Optional; `System.Windows.Forms.Timer` is fine |
| FileSystemWatcher | KryptonFileSystemWatcher | Toolkit | Optional |
| ImageList / BindingSource | (standard) | — | Work as-is |
| PrintDialog | KryptonPrintDialog | Toolkit | |
| PrintPreviewDialog / Control | KryptonPrintPreviewDialog / Control | Toolkit | |
| PageSetupDialog | (none) | — | Toolbar PageSetup command only |
| Open/Save/Folder dialogs | KryptonOpenFileDialog / Save / FolderBrowser | Toolkit | |
| FontDialog / ColorDialog | KryptonFontDialog / ColorDialog | Toolkit | Screen picker in Utilities |
| MessageBox | KryptonMessageBox | Toolkit | Extended / foldable in Utilities |
| TaskDialog | KryptonTaskDialog | Toolkit | |
| About | KryptonAboutBox | Utilities | |
| Chart | (none) | — | Recommend third-party |

---

## 12. CONCLUSION

The toolkit’s **standard WinForms coverage is complete** for the controls applications actually theme. Gaps called out in older audits (`ToolTip`, print preview, H/V scrollbars, ListView virtual mode, TreeView checkboxes, ComboBox styles) are implemented. Several items were **mis-filed** as core Toolkit (code editor, search box, About box, Vista command link) or **never existed** (markdown editor, `KryptonSplitButton`).

**Immediate documentation actions (this review):** treat `KryptonToolTip` as done; send toast/About/exception/search/code-editor consumers to Utilities; recommend `KryptonDropButton` for split buttons; stop listing markdown as shipped.
