# Detachable Ribbons - Code Examples

This document provides practical code examples for common scenarios when working with detachable ribbons.

---

## Table of Contents

1. [Basic Examples](#basic-examples)
2. [Event Handling](#event-handling)
3. [User Preferences](#user-preferences)
4. [UI Integration](#ui-integration)
5. [Advanced Scenarios](#advanced-scenarios)

---

## Basic Examples

### Example 1: Simple Enable and Detach

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;

    public MainForm()
    {
        InitializeComponent();
        
        _ribbon = new KryptonRibbon
        {
            Dock = DockStyle.Top,
            AllowDetach = true  // Enable feature
        };
        
        InitializeRibbonContent();
        Controls.Add(_ribbon);
    }

    private void DetachButton_Click(object sender, EventArgs e)
    {
        _ribbon.Detach();
    }

    private void ReattachButton_Click(object sender, EventArgs e)
    {
        _ribbon.Reattach();
    }
}
```

---

### Example 2: Conditional Detach Based on State

```csharp
private void ToggleRibbonDetach()
{
    if (_ribbon.IsDetached)
    {
        _ribbon.Reattach();
    }
    else
    {
        _ribbon.Detach();
    }
}

private void UpdateToggleButton()
{
    toggleButton.Text = _ribbon.IsDetached 
        ? "Reattach Ribbon" 
        : "Detach Ribbon";
    toggleButton.Enabled = _ribbon.AllowDetach;
}
```

---

## Event Handling

### Example 3: Update UI on State Change

```csharp
public MainForm()
{
    InitializeComponent();
    InitializeRibbon();
    HookRibbonEvents();
}

private void HookRibbonEvents()
{
    _ribbon.RibbonDetached += OnRibbonDetached;
    _ribbon.RibbonReattached += OnRibbonReattached;
}

private void OnRibbonDetached(object? sender, EventArgs e)
{
    // Update menu items
    detachMenuItem.Enabled = false;
    reattachMenuItem.Enabled = true;
    
    // Update status bar
    statusLabel.Text = "Ribbon is detached";
    
    // Update toolbar buttons
    detachToolbarButton.Enabled = false;
    reattachToolbarButton.Enabled = true;
    
    // Adjust form layout
    PerformLayout();
}

private void OnRibbonReattached(object? sender, EventArgs e)
{
    // Update menu items
    detachMenuItem.Enabled = true;
    reattachMenuItem.Enabled = false;
    
    // Update status bar
    statusLabel.Text = "Ribbon is attached";
    
    // Update toolbar buttons
    detachToolbarButton.Enabled = true;
    reattachToolbarButton.Enabled = false;
    
    // Adjust form layout
    PerformLayout();
}
```

---

### Example 4: Logging State Changes

```csharp
private void HookRibbonEvents()
{
    _ribbon.RibbonDetached += (s, e) =>
    {
        Logger.Info("Ribbon detached by user");
        Analytics.TrackEvent("RibbonDetached");
    };

    _ribbon.RibbonReattached += (s, e) =>
    {
        Logger.Info("Ribbon reattached by user");
        Analytics.TrackEvent("RibbonReattached");
    };
}
```

---

## User Preferences

### Example 5: Save and Restore Detach State with Position Persistence

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;

    public MainForm()
    {
        InitializeComponent();
        InitializeRibbon();
        HookPreferenceEvents();
        LoadUserPreferences();
    }

    private void HookPreferenceEvents()
    {
        // Use the new DetachPreferencesChanged event for automatic saving
        _ribbon.DetachPreferencesChanged += OnDetachPreferencesChanged;
    }

    private void OnDetachPreferencesChanged(object? sender, DetachPreferencesEventArgs e)
    {
        // Save detached state
        Properties.Settings.Default.RibbonDetached = e.IsDetached;
        
        // Save window position if available
        if (e.FloatingWindowPosition.HasValue)
        {
            Properties.Settings.Default.RibbonFloatingX = e.FloatingWindowPosition.Value.X;
            Properties.Settings.Default.RibbonFloatingY = e.FloatingWindowPosition.Value.Y;
        }
        else
        {
            // Clear position if not available
            Properties.Settings.Default.RibbonFloatingX = 0;
            Properties.Settings.Default.RibbonFloatingY = 0;
        }
        
        Properties.Settings.Default.Save();
    }

    private void LoadUserPreferences()
    {
        _ribbon.AllowDetach = true;
        
        // Load saved preferences
        bool wasDetached = Properties.Settings.Default.RibbonDetached;
        Point? savedPosition = null;
        
        // Load saved position if available
        if (Properties.Settings.Default.RibbonFloatingX != 0 || 
            Properties.Settings.Default.RibbonFloatingY != 0)
        {
            savedPosition = new Point(
                Properties.Settings.Default.RibbonFloatingX,
                Properties.Settings.Default.RibbonFloatingY);
        }
        
        // Restore state using the new LoadDetachPreferences method
        _ribbon.LoadDetachPreferences(wasDetached, savedPosition);
    }
}
```

---

### Example 6: Registry-Based Preferences

```csharp
using Microsoft.Win32;

private void SavePreferenceToRegistry(bool isDetached)
{
    using (var key = Registry.CurrentUser.CreateSubKey(@"Software\YourApp\Ribbon"))
    {
        key?.SetValue("Detached", isDetached);
    }
}

private bool LoadPreferenceFromRegistry()
{
    using (var key = Registry.CurrentUser.OpenSubKey(@"Software\YourApp\Ribbon"))
    {
        return (bool)(key?.GetValue("Detached") ?? false);
    }
}

private void HookRegistryEvents()
{
    _ribbon.RibbonDetached += (s, e) => SavePreferenceToRegistry(true);
    _ribbon.RibbonReattached += (s, e) => SavePreferenceToRegistry(false);
}
```

---

## UI Integration

### Example 7: Context Menu Integration

```csharp
private void CreateRibbonContextMenu()
{
    var contextMenu = new ContextMenuStrip();
    
    var detachItem = new ToolStripMenuItem("Detach Ribbon")
    {
        Enabled = !_ribbon.IsDetached && _ribbon.AllowDetach
    };
    detachItem.Click += (s, e) => _ribbon.Detach();
    
    var reattachItem = new ToolStripMenuItem("Reattach Ribbon")
    {
        Enabled = _ribbon.IsDetached
    };
    reattachItem.Click += (s, e) => _ribbon.Reattach();
    
    contextMenu.Items.Add(detachItem);
    contextMenu.Items.Add(reattachItem);
    contextMenu.Items.Add(new ToolStripSeparator());
    
    var allowDetachItem = new ToolStripMenuItem("Allow Detach")
    {
        Checked = _ribbon.AllowDetach
    };
    allowDetachItem.Click += (s, e) =>
    {
        _ribbon.AllowDetach = !_ribbon.AllowDetach;
        allowDetachItem.Checked = _ribbon.AllowDetach;
        UpdateContextMenuItems();
    };
    contextMenu.Items.Add(allowDetachItem);
    
    _ribbon.ContextMenuStrip = contextMenu;
    
    // Update menu when state changes
    _ribbon.RibbonDetached += (s, e) => UpdateContextMenuItems();
    _ribbon.RibbonReattached += (s, e) => UpdateContextMenuItems();
}

private void UpdateContextMenuItems()
{
    if (_ribbon.ContextMenuStrip != null)
    {
        var items = _ribbon.ContextMenuStrip.Items;
        if (items.Count >= 2)
        {
            items[0].Enabled = !_ribbon.IsDetached && _ribbon.AllowDetach;
            items[1].Enabled = _ribbon.IsDetached;
        }
    }
}
```

---

### Example 8: Toolbar Button Integration

```csharp
private void CreateToolbar()
{
    var toolbar = new ToolStrip();
    
    var detachButton = new ToolStripButton("Detach")
    {
        Image = Properties.Resources.DetachIcon,
        Enabled = !_ribbon.IsDetached && _ribbon.AllowDetach
    };
    detachButton.Click += (s, e) => _ribbon.Detach();
    
    var reattachButton = new ToolStripButton("Reattach")
    {
        Image = Properties.Resources.ReattachIcon,
        Enabled = _ribbon.IsDetached
    };
    reattachButton.Click += (s, e) => _ribbon.Reattach();
    
    toolbar.Items.Add(detachButton);
    toolbar.Items.Add(reattachButton);
    
    Controls.Add(toolbar);
    
    // Update buttons when state changes
    _ribbon.RibbonDetached += (s, e) =>
    {
        detachButton.Enabled = false;
        reattachButton.Enabled = true;
    };
    
    _ribbon.RibbonReattached += (s, e) =>
    {
        detachButton.Enabled = true;
        reattachButton.Enabled = false;
    };
}
```

---

### Example 9: Status Bar Integration

```csharp
private void UpdateStatusBar()
{
    statusBarLabel.Text = _ribbon.IsDetached
        ? "Ribbon: Detached (Floating Window)"
        : "Ribbon: Attached";
    
    statusBarLabel.ForeColor = _ribbon.IsDetached
        ? Color.Orange
        : Color.Black;
}

private void HookStatusBarUpdates()
{
    _ribbon.RibbonDetached += (s, e) => UpdateStatusBar();
    _ribbon.RibbonReattached += (s, e) => UpdateStatusBar();
}
```

---

## Advanced Scenarios

### Example 10: Multi-Monitor Support with Position Persistence (Simplified)

```csharp
public class RibbonDetachManager
{
    private KryptonRibbon _ribbon;

    public RibbonDetachManager(KryptonRibbon ribbon)
    {
        _ribbon = ribbon;
        _ribbon.AllowDetach = true;
        HookEvents();
        LoadPreferences();
    }

    private void HookEvents()
    {
        // Use the built-in preference persistence system
        _ribbon.DetachPreferencesChanged += OnDetachPreferencesChanged;
    }

    private void OnDetachPreferencesChanged(object? sender, DetachPreferencesEventArgs e)
    {
        // Save preferences (position is automatically validated for multi-monitor support)
        Properties.Settings.Default.RibbonDetached = e.IsDetached;
        if (e.FloatingWindowPosition.HasValue)
        {
            Properties.Settings.Default.RibbonFloatingX = e.FloatingWindowPosition.Value.X;
            Properties.Settings.Default.RibbonFloatingY = e.FloatingWindowPosition.Value.Y;
        }
        Properties.Settings.Default.Save();
    }

    private void LoadPreferences()
    {
        // Load saved preferences
        bool wasDetached = Properties.Settings.Default.RibbonDetached;
        Point? savedPosition = null;
        
        if (Properties.Settings.Default.RibbonFloatingX != 0 || 
            Properties.Settings.Default.RibbonFloatingY != 0)
        {
            savedPosition = new Point(
                Properties.Settings.Default.RibbonFloatingX,
                Properties.Settings.Default.RibbonFloatingY);
        }
        
        // LoadDetachPreferences automatically handles multi-monitor position validation
        _ribbon.LoadDetachPreferences(wasDetached, savedPosition);
    }
}
```

---

### Example 11: Screen Size-Based Auto-Detach

```csharp
public class AdaptiveRibbonManager
{
    private KryptonRibbon _ribbon;
    private const int MIN_SCREEN_HEIGHT = 768;

    public AdaptiveRibbonManager(KryptonRibbon ribbon)
    {
        _ribbon = ribbon;
        _ribbon.AllowDetach = true;
        CheckScreenSize();
    }

    private void CheckScreenSize()
    {
        var primaryScreen = Screen.PrimaryScreen;
        var workingArea = primaryScreen.WorkingArea;
        
        if (workingArea.Height < MIN_SCREEN_HEIGHT)
        {
            // Suggest detaching ribbon for small screens
            var result = MessageBox.Show(
                $"Your screen height ({workingArea.Height}px) is limited.\n\n" +
                "Would you like to detach the ribbon to save vertical space?",
                "Optimize Layout",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            
            if (result == DialogResult.Yes)
            {
                _ribbon.Detach();
            }
        }
    }

    public void HandleScreenChanged()
    {
        // Called when screen configuration changes
        if (!_ribbon.IsDetached)
        {
            CheckScreenSize();
        }
    }
}
```

---

### Example 12: Command Pattern for Undo/Redo

```csharp
public interface IRibbonCommand
{
    void Execute();
    void Undo();
}

public class DetachRibbonCommand : IRibbonCommand
{
    private KryptonRibbon _ribbon;
    private bool _wasDetached;

    public DetachRibbonCommand(KryptonRibbon ribbon)
    {
        _ribbon = ribbon;
        _wasDetached = ribbon.IsDetached;
    }

    public void Execute()
    {
        if (!_wasDetached)
        {
            _ribbon.Detach();
        }
    }

    public void Undo()
    {
        if (!_wasDetached && _ribbon.IsDetached)
        {
            _ribbon.Reattach();
        }
    }
}

public class RibbonCommandManager
{
    private Stack<IRibbonCommand> _undoStack = new();
    private Stack<IRibbonCommand> _redoStack = new();

    public void ExecuteCommand(IRibbonCommand command)
    {
        command.Execute();
        _undoStack.Push(command);
        _redoStack.Clear();
    }

    public void Undo()
    {
        if (_undoStack.Count > 0)
        {
            var command = _undoStack.Pop();
            command.Undo();
            _redoStack.Push(command);
        }
    }

    public void Redo()
    {
        if (_redoStack.Count > 0)
        {
            var command = _redoStack.Pop();
            command.Execute();
            _undoStack.Push(command);
        }
    }
}
```

---

### Example 13: MVVM Pattern Integration

```csharp
public class RibbonViewModel : INotifyPropertyChanged
{
    private KryptonRibbon _ribbon;
    private bool _isDetached;
    private bool _allowDetach;

    public RibbonViewModel(KryptonRibbon ribbon)
    {
        _ribbon = ribbon;
        _allowDetach = ribbon.AllowDetach;
        _isDetached = ribbon.IsDetached;
        
        HookEvents();
    }

    public bool IsDetached
    {
        get => _isDetached;
        private set
        {
            if (_isDetached != value)
            {
                _isDetached = value;
                OnPropertyChanged();
                OnPropertyChanged(nameof(CanDetach));
                OnPropertyChanged(nameof(CanReattach));
            }
        }
    }

    public bool AllowDetach
    {
        get => _allowDetach;
        set
        {
            if (_allowDetach != value)
            {
                _allowDetach = value;
                _ribbon.AllowDetach = value;
                OnPropertyChanged();
                OnPropertyChanged(nameof(CanDetach));
            }
        }
    }

    public bool CanDetach => AllowDetach && !IsDetached;
    public bool CanReattach => IsDetached;

    public ICommand DetachCommand { get; }
    public ICommand ReattachCommand { get; }

    private void HookEvents()
    {
        _ribbon.RibbonDetached += (s, e) => IsDetached = true;
        _ribbon.RibbonReattached += (s, e) => IsDetached = false;
        
        DetachCommand = new RelayCommand(
            () => _ribbon.Detach(),
            () => CanDetach);
        
        ReattachCommand = new RelayCommand(
            () => _ribbon.Reattach(),
            () => CanReattach);
    }

    public event PropertyChangedEventHandler? PropertyChanged;
    
    protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
}
```

---

### Example 14: Async Operations with Progress

```csharp
public async Task<bool> DetachRibbonAsync(IProgress<string>? progress = null)
{
    progress?.Report("Preparing to detach ribbon...");
    
    await Task.Delay(50); // Small delay for UI responsiveness
    
    if (!_ribbon.AllowDetach)
    {
        progress?.Report("Detach is not enabled");
        return false;
    }
    
    progress?.Report("Detaching ribbon...");
    
    var result = await Task.Run(() => _ribbon.Detach());
    
    if (result)
    {
        progress?.Report("Ribbon detached successfully");
    }
    else
    {
        progress?.Report("Failed to detach ribbon");
    }
    
    return result;
}
```

---

### Example 15: Validation Before Detach

```csharp
public class RibbonDetachValidator
{
    private KryptonRibbon _ribbon;

    public RibbonDetachValidator(KryptonRibbon ribbon)
    {
        _ribbon = ribbon;
    }

    public ValidationResult ValidateDetach()
    {
        var result = new ValidationResult();

        if (!_ribbon.AllowDetach)
        {
            result.AddError("Detach functionality is not enabled");
        }

        if (_ribbon.IsDetached)
        {
            result.AddError("Ribbon is already detached");
        }

        if (_ribbon.Parent == null)
        {
            result.AddError("Ribbon has no parent control");
        }

        if (_ribbon.FindForm() == null)
        {
            result.AddError("Ribbon is not contained within a form");
        }

        // Check if ribbon has unsaved changes (example)
        if (HasUnsavedChanges())
        {
            result.AddWarning("There are unsaved changes. Detaching may affect workflow.");
        }

        return result;
    }

    private bool HasUnsavedChanges()
    {
        // Implement your logic here
        return false;
    }
}

public class ValidationResult
{
    private List<string> _errors = new();
    private List<string> _warnings = new();

    public bool IsValid => _errors.Count == 0;
    public IEnumerable<string> Errors => _errors;
    public IEnumerable<string> Warnings => _warnings;

    public void AddError(string message) => _errors.Add(message);
    public void AddWarning(string message) => _warnings.Add(message);
}
```

---

## Testing Examples

### Example 16: Unit Test Structure

```csharp
[TestClass]
public class DetachableRibbonTests
{
    [TestMethod]
    public void Detach_WhenAllowDetachIsFalse_ReturnsFalse()
    {
        // Arrange
        var ribbon = new KryptonRibbon { AllowDetach = false };
        var form = new KryptonForm();
        form.Controls.Add(ribbon);

        // Act
        var result = ribbon.Detach();

        // Assert
        Assert.IsFalse(result);
        Assert.IsFalse(ribbon.IsDetached);
    }

    [TestMethod]
    public void Detach_WhenAllowDetachIsTrue_ReturnsTrue()
    {
        // Arrange
        var ribbon = new KryptonRibbon { AllowDetach = true };
        var form = new KryptonForm();
        form.Controls.Add(ribbon);

        // Act
        var result = ribbon.Detach();

        // Assert
        Assert.IsTrue(result);
        Assert.IsTrue(ribbon.IsDetached);
    }

    [TestMethod]
    public void Reattach_WhenDetached_ReturnsTrue()
    {
        // Arrange
        var ribbon = new KryptonRibbon { AllowDetach = true };
        var form = new KryptonForm();
        form.Controls.Add(ribbon);
        ribbon.Detach();

        // Act
        var result = ribbon.Reattach();

        // Assert
        Assert.IsTrue(result);
        Assert.IsFalse(ribbon.IsDetached);
    }
}
```

---

## Adding Custom Buttons to Ribbon

### Example 17: Detach/Reattach Buttons in Ribbon

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonRibbon _ribbon;
    private ButtonSpecAny? _detachButton;
    private ButtonSpecAny? _reattachButton;

    public MainForm()
    {
        InitializeComponent();
        InitializeRibbon();
        AddRibbonButtons();
    }

    private void AddRibbonButtons()
    {
        // Detach button - appears when ribbon is attached
        _detachButton = new ButtonSpecAny
        {
            Text = "Detach",
            ToolTipTitle = "Detach Ribbon",
            ToolTipBody = "Move the ribbon into a floating window",
            UniqueName = "DetachButton",
            Edge = PaletteRelativeEdgeAlign.Far  // Right side, next to minimize/expand
        };
        _detachButton.Click += (s, e) => _ribbon.Detach();
        _ribbon.ButtonSpecs.Add(_detachButton);

        // Reattach button - appears when ribbon is detached
        _reattachButton = new ButtonSpecAny
        {
            Text = "Reattach",
            ToolTipTitle = "Reattach Ribbon",
            ToolTipBody = "Move the ribbon back to the form",
            UniqueName = "ReattachButton",
            Edge = PaletteRelativeEdgeAlign.Far,
            Visible = false  // Initially hidden
        };
        _reattachButton.Click += (s, e) => _ribbon.Reattach();
        _ribbon.ButtonSpecs.Add(_reattachButton);

        // Update button visibility when state changes
        _ribbon.RibbonDetached += (s, e) => UpdateRibbonButtons();
        _ribbon.RibbonReattached += (s, e) => UpdateRibbonButtons();
    }

    private void UpdateRibbonButtons()
    {
        if (_detachButton != null)
            _detachButton.Visible = !_ribbon.IsDetached;
        if (_reattachButton != null)
            _reattachButton.Visible = _ribbon.IsDetached;
        _ribbon.PerformNeedPaint(true);
    }
}
```

---

### Example 18: Custom Button with Image

```csharp
private void AddCustomHelpButton()
{
    var helpButton = new ButtonSpecAny
    {
        Text = "Help",
        ToolTipTitle = "Help",
        ToolTipBody = "Open help documentation",
        UniqueName = "HelpButton",
        Edge = PaletteRelativeEdgeAlign.Far,
        // ImageSmall = yourImage16x16,  // Optional: 16x16 image
        // ImageLarge = yourImage32x32    // Optional: 32x32 image
    };
    helpButton.Click += (s, e) => ShowHelp();
    _ribbon.ButtonSpecs.Add(helpButton);
}
```

---

## See Also

- [Full Documentation](KryptonDetachableRibbon.md) - Comprehensive feature documentation
- [API Reference](KryptonDetachableRibbonsAPIReference.md) - Quick API reference
- [Issue #595](https://github.com/Krypton-Suite/Standard-Toolkit/issues/595) - Original feature request
