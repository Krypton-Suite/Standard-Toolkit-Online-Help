## Version 9x Breaking Changes

## V90.00 (2024-11-12 - Build 2411 - November 2024)

There are list of changes that have occurred during the development of the V90.00 version

* [#632](https://github.com/Krypton-Suite/Standard-Toolkit/issues/632), **[Breaking Change]** `KryptonPropertyGrid` should have a customisable back colour.
  * `KryptonPropertyGrid` now uses the State### sets like the rest of the controls.
  * Any build breaks in the designers can just be deleted, as the the colouring will be done by the `State####` equivalents
* [#1435](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1435), **Breaking Change** Take KMB back to the Winform override (Remove Checkbox etc)
* and [#1432](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1432), **Breaking Change placeholder** Copy `KryptonMessageBox` to `KryptonMessageBoxDep`
  * The introduction of new Parameters elements to the `KryptonMessageBox` is now supported in the `KryptonMessageBoxDep` class
  * This is so that the `KryptonMessageBox` gets back to being a drop in replacement for the WinForm `MessageBox`
  * And a start of the introduction of the `KryptonMessageDialog` implementation of the UWP `MessageDialog`
* [#1424](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1424), **Breaking Change** `KryptonMessageBox` does not obey tab characters like `MessageBox`
  * The optional `ContentAlignment` for a `KryptonMessageBox.Show` command is no longer possible.
* [#1356](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1356), AppButton colours don't change while switching themes
  * See <https://github.com/Krypton-Suite/Standard-Toolkit/issues/1356#issuecomment-2039412890>
  * `RibbonAppButton` has become `RibbonFileAppButton`
  * Addition `RibbonFileAppTab` to hold the tab text (Defaults to `File`)
  * Colours for the `FileAppTab` have been moved into the `StateCommon` area
* [#1206](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1206), Remove the `Font Size` (as it is already covered by the actual font !)
* [#1224](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1224), Move `GlobalPaletteMode` into `GlobalPalette` and rename
  * BaseFont is now part of the KryptonManager class, and will override the applied palette font(s)
  * `CustomPalette` must be derived from the `KryptonCustomPaletteBase` class
  * `BasePaletteMode` has been removed from `KryptonCustomPaletteBase` class
* [#124](https://github.com/Krypton-Suite/Standard-Toolkit/issues/124), When setting AllowFormChrome = false, then the Form Bar should still be Theme rendered
  * `AllowFormChrome` has been removed and replaced with `UseThemeFormChromeBorderWidth` to better explain what it is doing
  * It means that a theme can get closer to "Material Design", and that the Title bar can still be themed (And rounded)
* [#215](https://github.com/Krypton-Suite/Standard-Toolkit/issues/215), `KryptonTreeView` Multi Node Select
  * Designer values named `State####Pressed` have changed to `State#####MultiSelect` to reflect usage
  * New ReeView Designer value `MultiSelect` allows drawing of selected items and retrieval via `CheckedNodes`
* [#1268](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1268),  Many Krypton Controls have a `CornerRoundingRadius` that overrides the State#### Node Rounding values. Please remove!
  * `CornerRoundingRadius` overrides **ONLY** the `StateCommon.Border.Rounding` which is incorrect.
  * All `CornerRoundingRadius` have been removed
* [#1269](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1269),  Remove AllowFormIntegrate to give consistent experience on all supported OS's
  * Please check the images in the issue.
  * To fix: just remove `AllowFormIntegrate` from your deisgner files
* [#1266](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1266), Since V 5.400, the QAT button is supposed to perform the close, therefore the Close Form button should not be visible
  * The RibbonAppButton has a new Designer field for setting the "Form Close Visible" to off by default
    
## V95.00 (2025-02-01 - Build 2502 - February 2025)

* Resolved [#1212](https://github.com/Krypton-Suite/Standard-Toolkit/issues/1842), **[Breaking Change]** `KColorButton` 'drop-down' arrow should be drawn
  * Create Scaled Drop Glyph and use for colour button and comboDrops
  * Remove the `PaletteRedirectDropDownButton`
  * Remove `KryptonPaletteImagesDropDownButton`
  * **Breaking Change**: Remove `DropDownButtonImages` from designers