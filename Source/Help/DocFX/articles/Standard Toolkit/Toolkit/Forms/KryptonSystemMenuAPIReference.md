# KryptonSystemMenu API Reference

## Namespace
`Krypton.Toolkit`

## Class Declaration
```csharp
public class KryptonSystemMenu : IKryptonSystemMenu, IDisposable
```

## Interfaces Implemented
- `IKryptonSystemMenu`
- `IDisposable`

## Constructors

### KryptonSystemMenu(KryptonForm form)
```csharp
public KryptonSystemMenu(KryptonForm form)
```

**Description**: Initializes a new instance of the KryptonSystemMenu class.

**Parameters**:
- `form` (KryptonForm): The KryptonForm to attach the themed system menu to.

**Exceptions**:
- `ArgumentNullException`: Thrown when `form` parameter is null.

**Example**:
```csharp
var systemMenu = new KryptonSystemMenu(myKryptonForm);
```

## Properties

### ContextMenu
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public KryptonContextMenu ContextMenu { get; }
```

**Description**: Gets the underlying themed context menu.

**Type**: `KryptonContextMenu`

**Access**: Read-only

**Notes**: This property provides access to the underlying menu for advanced customization.

### Enabled
```csharp
[Category(@"Behavior")]
[Description(@"Enables or disables the themed system menu.")]
[DefaultValue(true)]
public bool Enabled { get; set; }
```

**Description**: Gets or sets whether the themed system menu is enabled.

**Type**: `bool`

**Default Value**: `true`

**Notes**: When disabled, the menu will not respond to show requests.

### MenuItemCount
```csharp
[Category(@"Appearance")]
[Description(@"The number of items currently in the themed system menu.")]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public int MenuItemCount { get; }
```

**Description**: Gets the number of items currently in the themed system menu.

**Type**: `int`

**Access**: Read-only

### HasMenuItems
```csharp
[Category(@"Appearance")]
[Description(@"Indicates whether the themed system menu contains any items.")]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool HasMenuItems { get; }
```

**Description**: Gets whether the themed system menu contains any items.

**Type**: `bool`

**Access**: Read-only

### ShowOnLeftClick
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool ShowOnLeftClick { get; set; }
```

**Description**: Gets or sets whether left-click on title bar shows the themed system menu.

**Type**: `bool`

**Default Value**: `true`

### ShowOnRightClick
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool ShowOnRightClick { get; set; }
```

**Description**: Gets or sets whether right-click on title bar shows the themed system menu.

**Type**: `bool`

**Default Value**: `true`

### ShowOnAltSpace
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool ShowOnAltSpace { get; set; }
```

**Description**: Gets or sets whether Alt+Space shows the themed system menu.

**Type**: `bool`

**Default Value**: `true`

### CurrentIconTheme
```csharp
[Category(@"Appearance")]
[Description(@"The current theme name being used for system menu icons.")]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public string CurrentIconTheme { get; }
```

**Description**: Gets the current theme name being used for system menu icons.

**Type**: `string`

**Access**: Read-only

**Return Values**: 
- "Office2013"
- "Office2010" 
- "Office2007"
- "Sparkle"
- "Professional"
- "Microsoft365"
- "Office2003"

## Methods

### Show(Point screenLocation)
```csharp
public void Show(Point screenLocation)
```

**Description**: Shows the themed system menu at the specified screen location.

**Parameters**:
- `screenLocation` (Point): The screen coordinates where to show the menu.

**Returns**: `void`

**Notes**: The position is automatically adjusted to ensure the menu stays within screen bounds.

**Example**:
```csharp
systemMenu.Show(new Point(100, 100));
```

### ShowAtFormTopLeft()
```csharp
public void ShowAtFormTopLeft()
```

**Description**: Shows the themed system menu at the top-left corner of the form.

**Returns**: `void`

**Notes**: Mimics the native system menu behavior.

**Example**:
```csharp
systemMenu.ShowAtFormTopLeft();
```

### Refresh()
```csharp
public void Refresh()
```

**Description**: Refreshes the system menu items based on current form state.

**Returns**: `void`

**Notes**: This method rebuilds the menu structure, updates menu item states, and refreshes icons.

**Example**:
```csharp
systemMenu.Refresh();
```

### HandleKeyboardShortcut(Keys keyData)
```csharp
public bool HandleKeyboardShortcut(Keys keyData)
```

**Description**: Handles keyboard shortcuts for system menu actions.

**Parameters**:
- `keyData` (Keys): The key combination pressed.

**Returns**: `bool` - `true` if the shortcut was handled; otherwise `false`.

**Supported Shortcuts**:
- `Alt+F4`: Close the form
- `Alt+Space`: Show the system menu (if enabled)

**Example**:
```csharp
if (systemMenu.HandleKeyboardShortcut(Keys.Alt | Keys.F4))
{
    // Shortcut was handled
}
```

### GetCurrentTheme()
```csharp
public string GetCurrentTheme()
```

**Description**: Determines the current theme based on the form's palette.

**Returns**: `string` - The current theme name.

**Example**:
```csharp
var theme = systemMenu.GetCurrentTheme();
Console.WriteLine($"Current theme: {theme}");
```

### RefreshThemeIcons()
```csharp
public void RefreshThemeIcons()
```

**Description**: Manually refreshes all icons to match the current theme.

**Returns**: `void`

**Notes**: Call this method when the application theme changes.

**Example**:
```csharp
systemMenu.RefreshThemeIcons();
```

### SetIconTheme(string themeName)
```csharp
public void SetIconTheme(string themeName)
```

**Description**: Manually sets the theme for icon selection.

**Parameters**:
- `themeName` (string): The theme name to use for icons.

**Returns**: `void`

**Notes**: If `themeName` is null or empty, the method returns without action.

**Example**:
```csharp
systemMenu.SetIconTheme("Office2010");
```

### SetThemeType(ThemeType themeType)
```csharp
public void SetThemeType(ThemeType themeType)
```

**Description**: Sets the theme based on specific theme types.

**Parameters**:
- `themeType` (ThemeType): The theme type to use.

**Returns**: `void`

**ThemeType Values**:
- `ThemeType.Black` → "Office2013"
- `ThemeType.Blue` → "Office2010"
- `ThemeType.Silver` → "Office2013"
- `ThemeType.DarkBlue` → "Office2010"
- `ThemeType.LightBlue` → "Office2010"
- `ThemeType.WarmSilver` → "Office2013"
- `ThemeType.ClassicSilver` → "Office2007"

**Example**:
```csharp
systemMenu.SetThemeType(ThemeType.Office2010Blue);
```

## IKryptonSystemMenu Interface

The `KryptonSystemMenu` implements the `IKryptonSystemMenu` interface, which defines the contract for system menu functionality.

### Interface Members

#### Properties
- `bool Enabled { get; set; }`
- `bool ShowOnLeftClick { get; set; }`
- `bool ShowOnRightClick { get; set; }`
- `bool ShowOnAltSpace { get; set; }`
- `string CurrentIconTheme { get; }`

#### Methods
- `void Show(Point screenLocation)`
- `void ShowAtFormTopLeft()`
- `void Refresh()`
- `bool HandleKeyboardShortcut(Keys keyData)`

## IDisposable Implementation

The `KryptonSystemMenu` implements `IDisposable` for proper resource management.

### Dispose()
```csharp
public void Dispose()
```

**Description**: Releases all resources used by the KryptonSystemMenu.

**Example**:
```csharp
using (var systemMenu = new KryptonSystemMenu(form))
{
    // Use the system menu
}
// Automatically disposed
```

### Dispose(bool disposing)
```csharp
protected virtual void Dispose(bool disposing)
```

**Description**: Releases the unmanaged resources used by the KryptonSystemMenu and optionally releases the managed resources.

**Parameters**:
- `disposing` (bool): True to release both managed and unmanaged resources; false to release only unmanaged resources.

## Enumerations

### SystemMenuIconType
```csharp
public enum SystemMenuIconType
{
    Restore,
    Minimize,
    Maximize,
    Close,
    Move,
    Size
}
```

**Description**: Defines the types of system menu icons.

### ThemeType
```csharp
public enum ThemeType
{
    Black,
    Blue,
    Silver,
    DarkBlue,
    LightBlue,
    WarmSilver,
    ClassicSilver
}
```

**Description**: Defines the available theme types for icon selection.

## Events

The `KryptonSystemMenu` class does not expose public events directly. Event handling is managed internally through the underlying `KryptonContextMenu` and its menu items.

### Internal Event Handling

Menu item click events are handled internally:

```csharp
// Internal event handlers (not publicly accessible)
private void OnRestoreItemOnClick(object? sender, EventArgs e)
private void OnMinimizeItemOnClick(object? sender, EventArgs e)
private void OnMaximizeItemOnClick(object? sender, EventArgs e)
private void OnCloseItemOnClick(object? sender, EventArgs e)
```

## Dependencies

### Required Assemblies
- `Krypton.Toolkit.dll`
- `System.Drawing.dll`
- `System.Windows.Forms.dll`

### Required Types
- `KryptonForm`
- `KryptonContextMenu`
- `SystemMenuImageResources`
- `KryptonManager.Strings.SystemMenuStrings`

## Thread Safety

The `KryptonSystemMenu` class is not thread-safe. All operations must be performed on the UI thread.

## See Also

- [KryptonSystemMenu Developer Guide](./KryptonSystemMenuDeveloperGuide.md)
- [KryptonForm Class Reference](./KryptonFormAPIReference.md)
- [KryptonContextMenu Class Reference](./KryptonContextMenuAPIReference.md)
