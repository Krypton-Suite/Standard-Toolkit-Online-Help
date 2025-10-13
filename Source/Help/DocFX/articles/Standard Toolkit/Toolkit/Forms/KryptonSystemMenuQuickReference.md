# KryptonSystemMenu Quick Reference

## Quick Start

```csharp
// 1. Create system menu
var systemMenu = new KryptonSystemMenu(myKryptonForm);

// 2. Show menu
systemMenu.ShowAtFormTopLeft();

// 3. Handle shortcuts
protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
{
    return systemMenu.HandleKeyboardShortcut(keyData) || base.ProcessCmdKey(ref msg, keyData);
}
```

## Common Tasks

### Show Menu at Different Locations
```csharp
// Top-left corner (native behavior)
systemMenu.ShowAtFormTopLeft();

// Cursor position
systemMenu.Show(Cursor.Position);

// Custom position
systemMenu.Show(new Point(100, 100));

// Form center
var center = new Point(Location.X + Width/2, Location.Y + Height/2);
systemMenu.Show(center);
```

### Enable/Disable Menu Features
```csharp
// Enable/disable entire menu
systemMenu.Enabled = false;

// Control trigger behaviors
systemMenu.ShowOnLeftClick = true;
systemMenu.ShowOnRightClick = true;
systemMenu.ShowOnAltSpace = true;
```

### Theme Management
```csharp
// Get current theme
var theme = systemMenu.CurrentIconTheme;

// Set specific theme
systemMenu.SetIconTheme("Office2010");

// Set by theme type
systemMenu.SetThemeType(ThemeType.Office2010Blue);

// Refresh after theme change
systemMenu.RefreshThemeIcons();
```

### State Management
```csharp
// Refresh menu states
systemMenu.Refresh();

// Check menu status
if (systemMenu.HasMenuItems)
{
    Console.WriteLine($"Menu has {systemMenu.MenuItemCount} items");
}
```

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Alt+F4` | Close form |
| `Alt+Space` | Show system menu |

## Supported Themes

| Theme Name | Description |
|------------|-------------|
| `Office2013` | Default, modern theme |
| `Office2010` | Classic Office 2010 |
| `Office2007` | Office 2007 style |
| `Sparkle` | Vibrant colors |
| `Professional` | Neutral, professional |
| `Microsoft365` | Modern Microsoft 365 |
| `Office2003` | Classic Office 2003 |

## ThemeType Mappings

| ThemeType | Icon Theme |
|-----------|------------|
| `Black` | Office2013 |
| `Blue` | Office2010 |
| `Silver` | Office2013 |
| `DarkBlue` | Office2010 |
| `LightBlue` | Office2010 |
| `WarmSilver` | Office2013 |
| `ClassicSilver` | Office2007 |

## Menu Items

| Item | Icon | Enabled When |
|------|------|--------------|
| **Restore** | ✓ | Window not in Normal state |
| **Move** | - | Resizable form |
| **Size** | - | Resizable form |
| **Minimize** | ✓ | MinimizeBox = true |
| **Maximize** | ✓ | MaximizeBox = true |
| **Close** | ✓ | ControlBox = true |

## Troubleshooting

### Menu Not Showing
```csharp
// Check these conditions
if (!systemMenu.Enabled) return;
if (!systemMenu.HasMenuItems) return;
if (_form.IsDisposed) return;

systemMenu.ShowAtFormTopLeft();
```

### Icons Missing
```csharp
// Force icon refresh
systemMenu.RefreshThemeIcons();

// Check theme detection
var theme = systemMenu.GetCurrentTheme();
Debug.WriteLine($"Theme: {theme}");
```

### Menu Items Not Working
```csharp
// Check form properties
Debug.WriteLine($"MinimizeBox: {_form.MinimizeBox}");
Debug.WriteLine($"MaximizeBox: {_form.MaximizeBox}");
Debug.WriteLine($"ControlBox: {_form.ControlBox}");
Debug.WriteLine($"WindowState: {_form.WindowState}");

// Refresh menu
systemMenu.Refresh();
```

## Best Practices

### 1. Always Check for Null
```csharp
if (systemMenu?.Enabled == true)
{
    systemMenu.ShowAtFormTopLeft();
}
```

### 2. Proper Disposal
```csharp
// Using statement (recommended)
using (var systemMenu = new KryptonSystemMenu(form))
{
    // Use system menu
}

// Manual disposal
systemMenu?.Dispose();
```

### 3. Theme Integration
```csharp
// Refresh icons when theme changes
kryptonManager.GlobalPalette = newPalette;
systemMenu?.RefreshThemeIcons();
```

### 4. Error Handling
```csharp
try
{
    systemMenu.ShowAtFormTopLeft();
}
catch (ObjectDisposedException)
{
    // System menu was disposed
}
catch (Exception ex)
{
    Debug.WriteLine($"Error: {ex.Message}");
}
```

## Integration Patterns

### Basic Form Integration
```csharp
public partial class MainForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;

    protected override void OnLoad(EventArgs e)
    {
        base.OnLoad(e);
        _systemMenu = new KryptonSystemMenu(this);
    }

    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        return _systemMenu?.HandleKeyboardShortcut(keyData) == true || 
               base.ProcessCmdKey(ref msg, keyData);
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            _systemMenu?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```

### Theme Change Integration
```csharp
private void OnThemeChanged(object sender, EventArgs e)
{
    _systemMenu?.RefreshThemeIcons();
}
```

### Window State Integration
```csharp
protected override void OnWindowStateChanged(EventArgs e)
{
    base.OnWindowStateChanged(e);
    _systemMenu?.Refresh();
}
```

## Performance Tips

1. **Reuse Instance**: Create once, reuse throughout form lifetime
2. **Lazy Refresh**: Only call `Refresh()` when needed
3. **Theme Caching**: Icons are cached automatically
4. **State Updates**: Use direct field references for efficiency

## Common Mistakes

❌ **Don't create multiple instances**
```csharp
// Bad
var menu1 = new KryptonSystemMenu(form);
var menu2 = new KryptonSystemMenu(form);
```

✅ **Create once and reuse**
```csharp
// Good
var systemMenu = new KryptonSystemMenu(form);
```

❌ **Don't forget disposal**
```csharp
// Bad - memory leak
var systemMenu = new KryptonSystemMenu(form);
```

✅ **Always dispose**
```csharp
// Good
using (var systemMenu = new KryptonSystemMenu(form))
{
    // Use menu
}
```

❌ **Don't ignore theme changes**
```csharp
// Bad - icons won't update
kryptonManager.GlobalPalette = newPalette;
```

✅ **Refresh after theme changes**
```csharp
// Good
kryptonManager.GlobalPalette = newPalette;
systemMenu.RefreshThemeIcons();
```
