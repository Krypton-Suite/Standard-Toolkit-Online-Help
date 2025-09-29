# KryptonSystemMenu Usage Examples

This file contains comprehensive examples demonstrating various ways to use the KryptonSystemMenu class in different scenarios.

## Table of Contents

- [Example 1: Basic Integration](#example-1-basic-kryptonsystemmenu-integration)
- [Example 2: Advanced Positioning](#example-2-advanced-system-menu-with-custom-positioning)
- [Example 3: Theme Management](#example-3-theme-integration-and-management)
- [Example 4: Custom Behavior](#example-4-custom-menu-behavior-and-state-management)
- [Example 5: Event Integration](#example-5-integration-with-form-events-and-state-changes)
- [Example 6: Error Handling](#example-6-error-handling-and-robustness)
- [Example 7: Performance Optimization](#example-7-performance-optimization-and-best-practices)
- [Example 8: Screen Positioning](#example-8-custom-menu-positioning-and-screen-bounds-handling)
- [Example 9: Settings Integration](#example-9-integration-with-application-settings-and-configuration)
- [Additional Notes](#additional-notes)

## Example 1: Basic KryptonSystemMenu Integration

The most straightforward way to integrate KryptonSystemMenu into your form.

```cs
using System;
using System.Drawing;
using System.Windows.Forms;
using Krypton.Toolkit;

public partial class BasicExampleForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;

    public BasicExampleForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
    }

    private void InitializeSystemMenu()
    {
        // Create the system menu instance
        _systemMenu = new KryptonSystemMenu(this);

        // Configure basic settings
        _systemMenu.Enabled = true;
        _systemMenu.ShowOnAltSpace = true;
    }

    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        // Handle system menu keyboard shortcuts
        if (_systemMenu?.HandleKeyboardShortcut(keyData) == true)
        {
            return true;
        }

        return base.ProcessCmdKey(ref msg, keyData);
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

## Example 2: Advanced System Menu with Custom Positioning

Demonstrates how to show the system menu at custom positions based on different user interactions.

```cs
public partial class AdvancedExampleForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;

    public AdvancedExampleForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
        SetupEventHandlers();
    }

    private void InitializeSystemMenu()
    {
        _systemMenu = new KryptonSystemMenu(this);
    }

    private void SetupEventHandlers()
    {
        // Show menu on different mouse events
        MouseClick += OnMouseClick;
        MouseDown += OnMouseDown;
        KeyDown += OnKeyDown;
    }

    private void OnMouseClick(object? sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Right && _systemMenu != null)
        {
            // Show menu at cursor position
            _systemMenu.Show(Cursor.Position);
        }
    }

    private void OnMouseDown(object? sender, MouseEventArgs e)
    {
        if (e.Button == MouseButtons.Left && e.Clicks == 2 && _systemMenu != null)
        {
            // Show menu at form center on double-click
            var center = new Point(
                Location.X + Width / 2,
                Location.Y + Height / 2
            );
            _systemMenu.Show(center);
        }
    }

    private void OnKeyDown(object? sender, KeyEventArgs e)
    {
        if (e.KeyCode == Keys.F10 && _systemMenu != null)
        {
            // Show menu on F10 key
            _systemMenu.ShowAtFormTopLeft();
        }
    }
}
```

## Example 3: Theme Integration and Management

Shows how to integrate KryptonSystemMenu with Krypton theme management for consistent styling.

```cs
public partial class ThemeExampleForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;
    private KryptonManager _kryptonManager;

    public ThemeExampleForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
        InitializeThemeManager();
    }

    private void InitializeSystemMenu()
    {
        _systemMenu = new KryptonSystemMenu(this);
    }

    private void InitializeThemeManager()
    {
        _kryptonManager = new KryptonManager();
        _kryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
    }

    private void ChangeTheme(PaletteMode mode)
    {
        // Change the global palette
        _kryptonManager.GlobalPaletteMode = mode;

        // Refresh system menu icons to match new theme
        _systemMenu?.RefreshThemeIcons();

        // Get current theme information
        var currentTheme = _systemMenu?.GetCurrentTheme();
        Console.WriteLine($"Current theme: {currentTheme}");
    }

    private void SetSpecificTheme()
    {
        if (_systemMenu != null)
        {
            // Set specific theme type
            _systemMenu.SetThemeType(ThemeType.Office2010Blue);

            // Or set specific theme name
            _systemMenu.SetIconTheme("Sparkle");
        }
    }

    private void OnThemeChanged(object? sender, EventArgs e)
    {
        // Handle theme change events
        _systemMenu?.RefreshThemeIcons();
    }
}
```

## Example 4: Custom Menu Behavior and State Management

Demonstrates how to customize when and how the system menu is shown based on application state.

```cs
public partial class CustomBehaviorForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;
    private bool _allowSystemMenu = true;

    public CustomBehaviorForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
    }

    private void InitializeSystemMenu()
    {
        _systemMenu = new KryptonSystemMenu(this);
    }

    private void UpdateSystemMenuBehavior()
    {
        if (_systemMenu != null)
        {
            // Enable/disable based on custom logic
            _systemMenu.Enabled = _allowSystemMenu && !IsMinimized;

            // Control trigger behaviors
            _systemMenu.ShowOnLeftClick = AllowLeftClickMenu;
            _systemMenu.ShowOnRightClick = AllowRightClickMenu;
            _systemMenu.ShowOnAltSpace = AllowAltSpaceMenu;

            // Refresh to apply changes
            _systemMenu.Refresh();
        }
    }

    private bool AllowLeftClickMenu => true;
    private bool AllowRightClickMenu => true;
    private bool AllowAltSpaceMenu => true;
    private bool IsMinimized => WindowState == FormWindowState.Minimized;

    protected override void OnWindowStateChanged(EventArgs e)
    {
        base.OnWindowStateChanged(e);
        UpdateSystemMenuBehavior();
    }

    private void ToggleSystemMenu()
    {
        _allowSystemMenu = !_allowSystemMenu;
        UpdateSystemMenuBehavior();
    }
}
```

## Example 5: Integration with Form Events and State Changes

Shows how to integrate system menu updates with various form events and system events for responsive behavior.

```cs
public partial class EventIntegrationForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;

    public EventIntegrationForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
        SetupEventHandlers();
    }

    private void InitializeSystemMenu()
    {
        _systemMenu = new KryptonSystemMenu(this);
    }

    private void SetupEventHandlers()
    {
        // Form events
        Load += OnFormLoad;
        WindowStateChanged += OnWindowStateChanged;
        Resize += OnFormResize;
        Move += OnFormMove;

        // System events
        SystemEvents.UserPreferenceChanged += OnUserPreferenceChanged;
    }

    private void OnFormLoad(object? sender, EventArgs e)
    {
        // Initial setup
        _systemMenu?.Refresh();
        LogMenuState("Form Loaded");
    }

    private void OnWindowStateChanged(object? sender, EventArgs e)
    {
        // Update menu when window state changes
        _systemMenu?.Refresh();
        LogMenuState("Window State Changed");
    }

    private void OnFormResize(object? sender, EventArgs e)
    {
        // Update menu when form is resized
        _systemMenu?.Refresh();
    }

    private void OnFormMove(object? sender, EventArgs e)
    {
        // Handle form move if needed
    }

    private void OnUserPreferenceChanged(object? sender, UserPreferenceChangedEventArgs e)
    {
        // Handle system theme changes
        if (e.Category == UserPreferenceCategory.General)
        {
            _systemMenu?.RefreshThemeIcons();
        }
    }

    private void LogMenuState(string eventName)
    {
        if (_systemMenu != null)
        {
            Console.WriteLine($"{eventName}: Menu enabled={_systemMenu.Enabled}, " +
                            $"Items={_systemMenu.MenuItemCount}, " +
                            $"Theme={_systemMenu.CurrentIconTheme}");
        }
    }
}
```

## Example 6: Error Handling and Robustness

Demonstrates proper error handling and robust practices for production applications.

```cs
public partial class RobustExampleForm : KryptonForm
{
    private KryptonSystemMenu? _systemMenu;
    private bool _isDisposed = false;

    public RobustExampleForm()
    {
        InitializeComponent();
        InitializeSystemMenu();
    }

    private void InitializeSystemMenu()
    {
        try
        {
            _systemMenu = new KryptonSystemMenu(this);
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to initialize system menu: {ex.Message}", 
                          "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void SafeShowMenu()
    {
        try
        {
            if (_systemMenu?.Enabled == true && _systemMenu.HasMenuItems && !_isDisposed)
            {
                _systemMenu.ShowAtFormTopLeft();
            }
        }
        catch (ObjectDisposedException)
        {
            // System menu was disposed
            _systemMenu = null;
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error showing system menu: {ex.Message}", 
                          "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }

    private void SafeRefreshMenu()
    {
        try
        {
            _systemMenu?.Refresh();
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error refreshing menu: {ex.Message}");
        }
    }

    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        try
        {
            return _systemMenu?.HandleKeyboardShortcut(keyData) == true || 
                   base.ProcessCmdKey(ref msg, keyData);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error handling keyboard shortcut: {ex.Message}");
            return base.ProcessCmdKey(ref msg, keyData);
        }
    }

    protected override void Dispose(bool disposing)
    {
        if (!_isDisposed)
        {
            if (disposing)
            {
                try
                {
                    _systemMenu?.Dispose();
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error disposing system menu: {ex.Message}");
                }
                finally
                {
                    _systemMenu = null;
                    _isDisposed = true;
                }
            }
            base.Dispose(disposing);
        }
    }
}
```

## Example 7: Performance Optimization and Best Practices

Demonstrates performance optimization techniques and best practices for handling frequent events.

```cs
public partial class OptimizedExampleForm : KryptonForm
    {
        private KryptonSystemMenu? _systemMenu;
        private bool _needsRefresh = false;
        private DateTime _lastRefreshTime = DateTime.MinValue;
        private readonly TimeSpan _refreshThrottle = TimeSpan.FromMilliseconds(100);

        public OptimizedExampleForm()
        {
            InitializeComponent();
            InitializeSystemMenu();
            SetupOptimizedEventHandlers();
        }

        private void InitializeSystemMenu()
        {
            _systemMenu = new KryptonSystemMenu(this);
        }

        private void SetupOptimizedEventHandlers()
        {
            // Use throttled refresh for frequent events
            Resize += OnFormResizeThrottled;
            Move += OnFormMoveThrottled;
            WindowStateChanged += OnWindowStateChangedOptimized;
        }

        private void OnFormResizeThrottled(object? sender, EventArgs e)
        {
            RequestRefresh();
        }

        private void OnFormMoveThrottled(object? sender, EventArgs e)
        {
            // Menu position doesn't need refresh on move
        }

        private void OnWindowStateChangedOptimized(object? sender, EventArgs e)
        {
            // Window state changes always need immediate refresh
            _systemMenu?.Refresh();
        }

        private void RequestRefresh()
        {
            _needsRefresh = true;
            
            // Use a timer to throttle refresh calls
            if (DateTime.Now - _lastRefreshTime > _refreshThrottle)
            {
                PerformRefresh();
            }
        }

        private void PerformRefresh()
        {
            if (_needsRefresh)
            {
                _systemMenu?.Refresh();
                _needsRefresh = false;
                _lastRefreshTime = DateTime.Now;
            }
        }

        protected override void OnPaint(PaintEventArgs e)
        {
            // Perform any pending refresh before painting
            PerformRefresh();
            base.OnPaint(e);
        }
    }

```

## Example 8: Custom Menu Positioning and Screen Bounds Handling

Advanced positioning techniques with screen bounds awareness.

```cs
public partial class PositioningExampleForm : KryptonForm
    {
        private KryptonSystemMenu? _systemMenu;

        public PositioningExampleForm()
        {
            InitializeComponent();
            InitializeSystemMenu();
            SetupPositioningHandlers();
        }

        private void InitializeSystemMenu()
        {
            _systemMenu = new KryptonSystemMenu(this);
        }

        private void SetupPositioningHandlers()
        {
            MouseClick += OnMouseClickForPositioning;
        }

        private void OnMouseClickForPositioning(object? sender, MouseEventArgs e)
        {
            if (_systemMenu == null) return;

            Point menuPosition;

            switch (e.Button)
            {
                case MouseButtons.Left:
                    // Show at click position
                    menuPosition = PointToScreen(e.Location);
                    break;

                case MouseButtons.Right:
                    // Show at cursor position
                    menuPosition = Cursor.Position;
                    break;

                case MouseButtons.Middle:
                    // Show at form center
                    menuPosition = new Point(
                        Location.X + Width / 2,
                        Location.Y + Height / 2
                    );
                    break;

                default:
                    return;
            }

            ShowMenuAtPosition(menuPosition);
        }

        private void ShowMenuAtPosition(Point position)
        {
            try
            {
                // The Show method automatically adjusts position to stay within screen bounds
                _systemMenu.Show(position);
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error showing menu: {ex.Message}", 
                              "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void ShowMenuAtScreenPosition(Screen screen)
        {
            if (_systemMenu == null) return;

            // Show menu at the center of a specific screen
            var screenCenter = new Point(
                screen.Bounds.X + screen.Bounds.Width / 2,
                screen.Bounds.Y + screen.Bounds.Height / 2
            );

            _systemMenu.Show(screenCenter);
        }

        private void ShowMenuAtFormCorner()
        {
            if (_systemMenu == null) return;

            // Show at different corners based on form position
            var formScreen = Screen.FromControl(this);
            var formBounds = formScreen.Bounds;
            var formCenter = new Point(
                formBounds.X + formBounds.Width / 2,
                formBounds.Y + formBounds.Height / 2
            );

            Point cornerPosition;

            if (Location.X < formCenter.X)
            {
                // Form is on left side, show menu at top-left
                cornerPosition = new Point(Location.X, Location.Y);
            }
            else
            {
                // Form is on right side, show menu at top-right
                cornerPosition = new Point(Location.X + Width, Location.Y);
            }

            _systemMenu.Show(cornerPosition);
        }
    }

```

## Example 9: Integration with Application Settings and Configuration

Shows how to persist settings and apply them on application startup.

```cs
public partial class ConfigurationExampleForm : KryptonForm
    {
        private KryptonSystemMenu? _systemMenu;
        private SystemMenuSettings _settings;

        public ConfigurationExampleForm()
        {
            InitializeComponent();
            LoadSettings();
            InitializeSystemMenu();
            ApplySettings();
        }

        private void LoadSettings()
        {
            // Load settings from configuration
            _settings = new SystemMenuSettings
            {
                Enabled = Properties.Settings.Default.SystemMenuEnabled,
                ShowOnLeftClick = Properties.Settings.Default.SystemMenuShowOnLeftClick,
                ShowOnRightClick = Properties.Settings.Default.SystemMenuShowOnRightClick,
                ShowOnAltSpace = Properties.Settings.Default.SystemMenuShowOnAltSpace,
                Theme = Properties.Settings.Default.SystemMenuTheme
            };
        }

        private void InitializeSystemMenu()
        {
            _systemMenu = new KryptonSystemMenu(this);
        }

        private void ApplySettings()
        {
            if (_systemMenu != null)
            {
                _systemMenu.Enabled = _settings.Enabled;
                _systemMenu.ShowOnLeftClick = _settings.ShowOnLeftClick;
                _systemMenu.ShowOnRightClick = _settings.ShowOnRightClick;
                _systemMenu.ShowOnAltSpace = _settings.ShowOnAltSpace;

                if (!string.IsNullOrEmpty(_settings.Theme))
                {
                    _systemMenu.SetIconTheme(_settings.Theme);
                }
            }
        }

        private void SaveSettings()
        {
            if (_systemMenu != null)
            {
                Properties.Settings.Default.SystemMenuEnabled = _systemMenu.Enabled;
                Properties.Settings.Default.SystemMenuShowOnLeftClick = _systemMenu.ShowOnLeftClick;
                Properties.Settings.Default.SystemMenuShowOnRightClick = _systemMenu.ShowOnRightClick;
                Properties.Settings.Default.SystemMenuShowOnAltSpace = _systemMenu.ShowOnAltSpace;
                Properties.Settings.Default.SystemMenuTheme = _systemMenu.CurrentIconTheme;
                Properties.Settings.Default.Save();
            }
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            SaveSettings();
            base.OnFormClosing(e);
        }

        private void UpdateSettings(SystemMenuSettings newSettings)
        {
            _settings = newSettings;
            ApplySettings();
        }
    }

}
```

### SystemMenuSettings Class

```cs
/// <summary>
/// Configuration class for system menu settings
/// </summary>
public class SystemMenuSettings
{
    public bool Enabled { get; set; } = true;
    public bool ShowOnLeftClick { get; set; } = true;
    public bool ShowOnRightClick { get; set; } = true;
    public bool ShowOnAltSpace { get; set; } = true;
    public string Theme { get; set; } = "Office2013";
}
```

# Additional Notes:

 1. Always dispose of KryptonSystemMenu instances properly
 2. Handle exceptions when showing menus
 3. Check menu state before operations
 4. Use throttling for frequent refresh operations
 5. Integrate with application settings for persistence
 6. Consider screen bounds when positioning menus
 7. Handle theme changes appropriately
 8. Use the using statement for automatic disposal