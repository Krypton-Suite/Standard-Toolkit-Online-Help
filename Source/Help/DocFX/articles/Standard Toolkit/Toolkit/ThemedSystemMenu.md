## Themed System Menu (KryptonSystemMenu)

This document describes the themed system menu feature that replaces the native Windows system menu with a `KryptonContextMenu` integrated with the current Krypton palette.

### Overview

- **What it is**: A fully theme-aware drop-in replacement for the native system menu, shown from a `KryptonForm` title area or keyboard.
- **How it works**: The menu is always built by Krypton (no parsing of the native Win32 system menu). Items reflect the current window capabilities and state, and icons adapt to the active palette/theme.
- **Where it lives**:
  - `KryptonSystemMenu` (core) — `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonSystemMenu.cs`
  - `KryptonSystemMenuService` (form wiring) — `Source/Krypton Components/Krypton.Toolkit/General/KryptonSystemMenuService.cs`
  - `SystemMenuValues` (design-time values) — `Source/Krypton Components/Krypton.Toolkit/Values/SystemMenuValues.cs`
  - `KryptonSystemMenuItemsEditor` (designer) — `Source/Krypton Components/Krypton.Toolkit/Designers/Editors/KryptonSystemMenuItemsEditor.cs`
  - `KryptonSystemMenuConverter` (type converter) — `Source/Krypton Components/Krypton.Toolkit/Converters/KryptonSystemMenuConverter.cs`

### Key capabilities

- **Standard commands**: Restore, Move, Size, Minimize, Maximize, Close (with state-aware enablement)
- **Theme-aware icons**: Chooses images based on detected theme, with safe fallbacks to drawn vector-like glyphs
- **Trigger options**: Right-click title bar, Alt+Space, optional left-click title bar, optional click on window icon
- **Custom items**: Add custom items and separators; designer-configured items are inserted above Close
- **Resilient**: Always constructs a consistent menu; falls back to drawn icons if themed images are unavailable

### Architecture

- **`KryptonSystemMenu`**
  - Owns a `KryptonContextMenu` and an internal `KryptonContextMenuItems` group
  - Builds a consistent menu via `BuildSystemMenu()` and `CreateBasicMenuItems()`
  - Dynamically enables items via `UpdateMenuItemsState()`
  - Provides icon selection and drawing fallbacks (`GetSystemMenuIcon`, `GetDrawnIcon`, `RefreshIcons`)
  - Public surface (selected):
    - Properties: `Enabled`, `MenuItemCount`, `HasMenuItems`, `CurrentIconTheme`
    - Methods: `Show(Point)`, `ShowAtFormTopLeft()`, `Refresh()`, `HandleKeyboardShortcut(Keys)`, `AddCustomMenuItem(...)`, `AddSeparator(...)`, `ClearCustomItems()`, `GetCustomMenuItems()`, `RefreshThemeIcons()`, `SetIconTheme(string)`, `SetThemeType(ThemeType)`

- **`KryptonSystemMenuService`**
  - Created by `KryptonForm` to encapsulate user interaction wiring
  - Exposes toggles for which triggers are active: `UseThemedSystemMenu`, `ShowThemedSystemMenuOnRightClick`, `ShowThemedSystemMenuOnAltSpace`, and optionally `ShowThemedSystemMenuOnLeftClick`
  - Forwards `HandleKeyboardShortcut(Keys)` and `Refresh()` to the underlying `KryptonSystemMenu`
  - Property `ThemedSystemMenu` exposes the `KryptonSystemMenu` instance

- **`SystemMenuValues` (design-time)**
  - Persists values for designer and runtime: `Enabled`, `ShowOnRightClick`, `ShowOnAltSpace`, `ShowOnIconClick`, and `CustomMenuItems`
  - Uses `KryptonSystemMenuItemsEditor` to edit `CustomMenuItems` at design time

### How it’s wired into `KryptonForm`

- A `KryptonSystemMenuService` is constructed by the form and synchronized with `SystemMenuValues`
- The form exposes `public override IKryptonSystemMenu? KryptonSystemMenu => _themedSystemMenuService?.ThemedSystemMenu;`
- Title bar interactions are forwarded to the service. Typical defaults:
  - **Right-click**: enabled
  - **Alt+Space**: enabled
  - **Left-click**: available via service, may be off by default depending on values wiring
  - **Icon click**: governed by `SystemMenuValues.ShowOnIconClick`

### Menu composition and enablement

- Items are added in a Windows-like order:
  - Conditional `Restore` (only when not Normal and when Minimize/Maximize is relevant)
  - Conditional `Move` and `Size` (form is sizable)
  - Separator (when appropriate)
  - Always `Minimize` and `Maximize` (enablement follows `MinimizeBox`/`MaximizeBox` and state)
  - Separator
  - `Close` (shows “Alt+F4” shortcut text)
- Designer-defined custom items are inserted above the `Close` item and separated for clarity

### Icon theming

- The icon provider attempts to infer an active theme name such as: `Office2013`, `Office2010`, `Office2007`, `Sparkle`, `Professional`, `Microsoft365`, `Office2003`
- For each theme, a small 16px image is selected when available; otherwise a crisp, drawn fallback is produced
- Transparency is normalized to 32bpp ARGB before use
- The `CurrentIconTheme` property exposes the currently inferred icon theme name

### Usage examples

- **Access from a form and add a custom command**
```csharp
// Add a custom item above Close
KryptonSystemMenu?.AddCustomMenuItem("About This Form", (s, e) =>
{
    using var dlg = new KryptonMessageBox("KryptonForm", "This is a demo.");
    dlg.ShowDialog(this);
});
```

- **Insert a separator before Close**
```csharp
KryptonSystemMenu?.AddSeparator(insertBeforeClose: true);
```

- **Refresh state and icons after you change window state or theme**
```csharp
KryptonSystemMenu?.Refresh();
KryptonSystemMenu?.RefreshThemeIcons();
```

- **Show the menu at the top-left of the form (Alt+Space behavior)**
```csharp
KryptonSystemMenu?.ShowAtFormTopLeft();
```

### Designer integration

- Use `SystemMenuValues.CustomMenuItems` to define custom items in the designer; items are inserted above Close
- Use `SystemMenuValues.Enabled`, `ShowOnRightClick`, `ShowOnAltSpace`, `ShowOnIconClick` to control triggers
- At runtime, `KryptonForm` syncs these values into `KryptonSystemMenuService`

### Keyboard shortcuts

- `Alt+Space`: shows the menu (if enabled)
- `Alt+F4`: built-in Close action is always available; `HandleKeyboardShortcut(Keys)` also handles it

### Migration notes (from KryptonThemedSystemMenu)

- Class renamed to `KryptonSystemMenu`; native system menu parsing has been removed in favor of a consistent Krypton-built menu
- Properties and methods like `Show`, `Refresh`, `AddCustomMenuItem`, `AddSeparator`, and `ClearCustomItems` remain familiar but live on the new class
- Designer/editor types were renamed to `KryptonSystemMenuItemsEditor`, `SystemMenuValues`, and `KryptonSystemMenuConverter`

### Testing and demos

- See `Source/Krypton Components/TestForm/ThemedSystemMenuTest.cs` and `DesignerMenuTest.cs` for interactive scenarios
- Manual checks:
  - Toggle Maximize/Minimize boxes on the form and verify enablement of menu items
  - Change themes/palettes and verify icons update; if no resource icon is available, a drawn fallback should appear
  - Add custom items and confirm they appear above Close with a separator

### Troubleshooting

- **No icons or wrong icons**: Icons fall back to drawn glyphs automatically; call `RefreshThemeIcons()` after theme changes
- **Items not enabling/disabling**: Ensure the form’s `MinimizeBox`, `MaximizeBox`, `FormBorderStyle`, and `WindowState` reflect the intended state, then call `Refresh()`
- **Menu not appearing**: Confirm the relevant trigger is enabled in `SystemMenuValues`/service; for title bar interactions, ensure the click is not on control buttons

### Compatibility

- Target frameworks include `net472` and newer windows TFMs used by the toolkit
- Works with `KryptonForm`; custom forms can host `KryptonSystemMenuService` if needed