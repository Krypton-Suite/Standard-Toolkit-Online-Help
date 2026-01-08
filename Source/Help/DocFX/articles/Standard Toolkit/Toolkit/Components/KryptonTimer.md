# KryptonTimer Developer Documentation

## Overview

`KryptonTimer` is a Krypton-themed wrapper for the standard WinForms `Timer` component. It provides timer functionality with full Krypton palette integration for consistency with other Krypton components.

## Key Features

- **Timer Functionality**: Full compatibility with standard `Timer` component
- **Krypton Integration**: `PaletteMode` and `Palette` properties for consistency
- **Global Palette Support**: Automatically responds to global palette changes
- **Standard API**: Maintains all standard `Timer` properties and methods
- **Component Support**: Can be added to component containers

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
public class KryptonTimer : Component
```

## Properties

### Timer Properties

#### `Enabled`
```csharp
[Category("Behavior")]
[Description("Indicates whether the timer is running.")]
[DefaultValue(false)]
public bool Enabled { get; set; }
```

Gets or sets a value indicating whether the timer is running. When `true`, the timer raises `Tick` events at the specified interval.

#### `Interval`
```csharp
[Category("Behavior")]
[Description("The time, in milliseconds, between timer ticks.")]
[DefaultValue(100)]
public int Interval { get; set; }
```

Gets or sets the time, in milliseconds, between timer ticks. Default is 100ms. Minimum value is 1ms.

### Palette Properties

#### `PaletteMode`
```csharp
[Category("Visuals")]
[Description("Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PaletteMode PaletteMode { get; set; }
```

Gets or sets the palette mode. This property is hidden from the designer as it's primarily for internal consistency. See `KryptonToolStripContainer` documentation for available palette modes.

#### `Palette`
```csharp
[Category("Visuals")]
[Description("Sets the custom palette to be used.")]
[DefaultValue(null)]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PaletteBase? Palette { get; set; }
```

Gets or sets a custom palette implementation. This property is hidden from the designer.

### Access to Underlying Component

#### `Timer`
```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public Timer? Timer { get; }
```

Gets access to the underlying `Timer` component for advanced scenarios.

## Methods

### `Start`
```csharp
public void Start()
```

Starts the timer. This is equivalent to setting `Enabled = true`.

**Example:**
```csharp
timer.Start();
```

### `Stop`
```csharp
public void Stop()
```

Stops the timer. This is equivalent to setting `Enabled = false`.

**Example:**
```csharp
timer.Stop();
```

## Events

### `Tick`
```csharp
[Category("Behavior")]
[Description("Occurs when the specified timer interval has elapsed and the timer is enabled.")]
public event EventHandler? Tick;
```

Occurs when the specified timer interval has elapsed and the timer is enabled. This is the main event for timer functionality.

**Example:**
```csharp
timer.Tick += (sender, e) =>
{
    // Timer tick logic here
    UpdateClock();
};
```

## Usage Examples

### Basic Timer

```csharp
public partial class MyForm : KryptonForm
{
    private KryptonTimer timer;

    public MyForm()
    {
        InitializeComponent();
        
        // Create timer
        timer = new KryptonTimer
        {
            Interval = 1000, // 1 second
            Enabled = true
        };
        
        timer.Tick += Timer_Tick;
    }

    private void Timer_Tick(object? sender, EventArgs e)
    {
        // Update UI every second
        labelTime.Text = DateTime.Now.ToString("HH:mm:ss");
    }
}
```

### Periodic Updates

```csharp
// Update status every 5 seconds
var statusTimer = new KryptonTimer
{
    Interval = 5000, // 5 seconds
    Enabled = true
};

statusTimer.Tick += (s, e) =>
{
    UpdateStatus();
};
```

### Animation Timer

```csharp
// Smooth animation at 60 FPS
var animationTimer = new KryptonTimer
{
    Interval = 16, // ~60 FPS (1000ms / 60 ≈ 16ms)
    Enabled = true
};

animationTimer.Tick += (s, e) =>
{
    AnimateProgress();
};
```

### Polling Timer

```csharp
// Poll for changes every 2 seconds
var pollTimer = new KryptonTimer
{
    Interval = 2000,
    Enabled = true
};

pollTimer.Tick += (s, e) =>
{
    CheckForUpdates();
};
```

### Start/Stop Control

```csharp
private void buttonStart_Click(object sender, EventArgs e)
{
    timer.Start();
    buttonStart.Enabled = false;
    buttonStop.Enabled = true;
}

private void buttonStop_Click(object sender, EventArgs e)
{
    timer.Stop();
    buttonStart.Enabled = true;
    buttonStop.Enabled = false;
}
```

### Dynamic Interval

```csharp
// Change interval based on conditions
timer.Interval = isFastMode ? 100 : 1000;
```

## Best Practices

1. **Interval Selection**: Choose appropriate intervals:
   - UI updates: 16-33ms (30-60 FPS)
   - Status updates: 1000-5000ms (1-5 seconds)
   - Polling: 2000-10000ms (2-10 seconds)

2. **Timer Disposal**: Always dispose of timers when forms are closed to prevent memory leaks.

3. **Performance**: Keep `Tick` event handlers lightweight. For heavy operations, consider using background threads.

4. **Multiple Timers**: Use separate timers for different purposes rather than one timer with complex logic.

5. **Start/Stop**: Use `Start()` and `Stop()` methods for clarity, or set `Enabled` property directly.

6. **Interval Changes**: Changing `Interval` while the timer is running takes effect immediately.

7. **Thread Safety**: Timer `Tick` events are raised on the UI thread, so you can safely update UI controls.

## Technical Details

### Timer Thread

The `KryptonTimer` uses a `System.Windows.Forms.Timer`, which:
- Runs on the UI thread
- Is safe for updating UI controls
- Has lower precision than `System.Timers.Timer` or `System.Threading.Timer`
- Is suitable for UI-related timing operations

### Palette Integration

While the timer itself doesn't have visual appearance, it integrates with the Krypton palette system for consistency. This allows for future enhancements and ensures the component follows Krypton patterns.

### Global Palette Changes

The timer automatically responds to global palette changes when `PaletteMode` is set to `Global` (default).

## See Also

- `System.Windows.Forms.Timer` - The underlying timer component
- `System.Timers.Timer` - For non-UI thread timing (not used by KryptonTimer)
- `System.Threading.Timer` - For background thread timing (not used by KryptonTimer)

