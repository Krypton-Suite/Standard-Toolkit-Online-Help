## KryptonSystemMenu

This guide explains how to use the themed system menu that replaces the native Windows system menu on `KryptonForm`. It covers wiring, APIs, customization, theming, designer usage, and troubleshooting.

### Types and locations

- `KryptonSystemMenu` — `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonSystemMenu.cs`
- `KryptonSystemMenuService` — `Source/Krypton Components/Krypton.Toolkit/General/KryptonSystemMenuService.cs`
- `IKryptonSystemMenu` — `Source/Krypton Components/Krypton.Toolkit/General/Definitions.cs`
- `SystemMenuValues` — `Source/Krypton Components/Krypton.Toolkit/Values/SystemMenuValues.cs`
- `SystemMenuItemCollection` — `Source/Krypton Components/Krypton.Toolkit/General/SystemMenuItemCollection.cs`
- `SystemMenuItemValues` — `Source/Krypton Components/Krypton.Toolkit/Values/SystemMenuItemValues.cs`
- `KryptonSystemMenuItemsEditor` — `Source/Krypton Components/Krypton.Toolkit/Designers/Editors/KryptonSystemMenuItemsEditor.cs`
- `KryptonSystemMenuConverter` — `Source/Krypton Components/Krypton.Toolkit/Converters/KryptonSystemMenuConverter.cs`

### What you get

- **Themed menu**: A `KryptonContextMenu` that mirrors the Windows system menu (Restore, Move, Size, Minimize, Maximize, Close) and adapts to the active palette.
- **Consistent composition**: Items are always built by Krypton; no Win32 menu parsing. Enablement follows form state and properties.
- **Custom items**: Insert your commands above the Close item (with a separator) or append at the end.
- **Icon theming**: Uses theme-appropriate icons; falls back to crisp drawn glyphs.
- **Triggers**: Show on right-click in the title bar, Alt+Space, and optionally icon click/left-click.

### Quick start

```csharp
// In your KryptonForm subclass or instance code
// Add an item above Close, insert a separator, and refresh enablement/icons
KryptonSystemMenu?.AddCustomMenuItem("About", (s, e) => KryptonMessageBox.Show("About Krypton"));
KryptonSystemMenu?.AddSeparator();
KryptonSystemMenu?.Refresh();

// Programmatically show at the classic Alt+Space location
KryptonSystemMenu?.ShowAtFormTopLeft();
```

### How it’s wired into KryptonForm

- `KryptonForm` constructs a `KryptonSystemMenuService` and a `SystemMenuValues` store, and keeps them synchronized.
- `KryptonForm` exposes the menu via `public override IKryptonSystemMenu? KryptonSystemMenu`.
- Title bar interactions (non-client area) use `SystemMenuValues` to determine when to show the menu (right-click, Alt+Space, icon click).
- Setting `MinimizeBox`, `MaximizeBox`, `ControlBox`, or `FormBorderStyle` triggers a rebuild of menu enablement.

### Enabling and triggers

- Configure via `KryptonForm.SystemMenuValues`:
  - **Enabled**: Turns the themed system menu on/off.
  - **ShowOnRightClick**: Show when right-clicking the title bar (default true).
  - **ShowOnAltSpace**: Show on Alt+Space (default true).
  - **ShowOnIconClick**: Show when left-clicking the window icon (default true).
- At the service layer (`KryptonSystemMenuService`):
  - `UseSystemMenu`, `ShowSystemMenuOnRightClick`, `ShowSystemMenuOnAltSpace`, `ShowSystemMenuOnLeftClick` mirror the toggles.
  - Typical usage is indirect via `SystemMenuValues` on the form.

### IKryptonSystemMenu surface

- **Properties**
  - `bool Enabled`
  - `bool ShowOnLeftClick`
  - `bool ShowOnRightClick`
  - `bool ShowOnAltSpace`
  - `int MenuItemCount`
  - `bool HasMenuItems`
  - `string CurrentIconTheme`
- **Methods**
  - `void Show(Point screenLocation)`
  - `void ShowAtFormTopLeft()`
  - `void Refresh()`
  - `bool HandleKeyboardShortcut(Keys keyData)`
  - `void AddCustomMenuItem(string text, EventHandler? clickHandler, bool insertBeforeClose = true)`
  - `void AddSeparator(bool insertBeforeClose = true)`
  - `void ClearCustomItems()`
  - `List<string> GetCustomMenuItems()`
  - `void RefreshThemeIcons()`
  - `void SetIconTheme(string themeName)`
  - `void SetThemeType(ThemeType themeType)`

### Menu composition and enablement

- **Restore**: Added only when `WindowState != Normal` and (`MinimizeBox` or `MaximizeBox`) is true; enabled when not Normal.
- **Move / Size**: Added only for sizable borders (`FormBorderStyle.Sizable` or `SizableToolWindow`).
- **Minimize**: Enabled when `MinimizeBox` is true and window is not minimized.
- **Maximize**: Enabled when `MaximizeBox` is true and window is not maximized.
- **Close**: Always present when `ControlBox` is true; shows `Alt+F4` hint.
- **Custom items**: Inserted above Close (with a separator). If appended, call `AddSeparator(insertBeforeClose: false)` to group them.

### Theming and icons

- `CurrentIconTheme` may resolve to: `Office2013`, `Office2010`, `Office2007`, `Sparkle`, `Professional`, `Microsoft365`, `Office2003`.
- Icons follow the active palette; if a themed resource is unavailable, glyphs are drawn at 16px with palette-derived colors.
- Call `RefreshThemeIcons()` after palette/theme changes to rebind images.
- You can force selection via `SetIconTheme(string)` or by convenience `SetThemeType(ThemeType)`.

### Programmatic customization examples

```csharp
// Add a settings command above Close
KryptonSystemMenu?.AddCustomMenuItem("Settings", (s, e) => OpenSettings(), insertBeforeClose: true);

// Append a group to the end (always separated from system items)
KryptonSystemMenu?.AddSeparator(insertBeforeClose: false);
KryptonSystemMenu?.AddCustomMenuItem("Action 1", OnAction1, insertBeforeClose: false);
KryptonSystemMenu?.AddCustomMenuItem("Action 2", OnAction2, insertBeforeClose: false);

// Recompute enablement after changing window chrome/state
KryptonSystemMenu?.Refresh();

// Keyboard shortcuts: Alt+F4 is handled; Alt+Space can invoke ShowAtFormTopLeft
protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
{
    if (KryptonSystemMenu?.HandleKeyboardShortcut(keyData) == true)
    {
        return true;
    }
    return base.ProcessCmdKey(ref msg, keyData);
}
```

### Designer integration

- Configure `KryptonForm.SystemMenuValues` in the designer:
  - **Enabled**, **ShowOnRightClick**, **ShowOnAltSpace**, **ShowOnIconClick**.
  - **CustomMenuItems**: Edit via `KryptonSystemMenuItemsEditor`. Items have `Text`, optional `Shortcut` (displayed as `Text\tShortcut`), `Image`, `Enabled`, `Visible`, and `InsertBeforeClose`.
- At runtime, designer items become `KryptonContextMenuItem` entries; you can also associate a `KryptonCommand` via `SystemMenuItemValues.Command` for decoupled invocation.

### Showing the menu

- **Auto**: Right-click title bar or press Alt+Space (depending on `SystemMenuValues`).
- **Programmatic**: `KryptonSystemMenu.Show(screenPoint)` or `KryptonSystemMenu.ShowAtFormTopLeft()`.

### Diagnostics and troubleshooting

- **No icons or wrong icons**: Call `RefreshThemeIcons()`. Verify the active palette if custom.
- **Items disabled unexpectedly**: Check `MinimizeBox`, `MaximizeBox`, `FormBorderStyle`, and actual window state (`KryptonForm.GetWindowState()`), then call `Refresh()`.
- **Menu not appearing**: Ensure `SystemMenuValues.Enabled` and the relevant trigger flag are true. For icon-click, `SystemMenuValues.ShowOnIconClick` must be true and the click must be on the window icon area.
- **Locate custom items**: `GetCustomMenuItems()` returns the non-standard item texts currently present.

### Notes and compatibility

- **Target forms**: Designed for `KryptonForm`. Custom hosts can use `KryptonSystemMenuService` directly if needed.
- **TFMs**: Compatible with toolkit target frameworks including `net472` and newer Windows TFMs.
- **Localization**: Built-in system item text is sourced from `KryptonManager.Strings.SystemMenuStrings` so it follows your localization settings.

### Migration (from older themed menu implementations)

- The class is `KryptonSystemMenu`. Win32 system menu parsing was removed in favor of consistently built Krypton menus.
- Familiar members remain: `Show`, `Refresh`, `AddCustomMenuItem`, `AddSeparator`, `ClearCustomItems`.
- Designer/editor types: `KryptonSystemMenuItemsEditor`, `SystemMenuValues`, `KryptonSystemMenuConverter`.
