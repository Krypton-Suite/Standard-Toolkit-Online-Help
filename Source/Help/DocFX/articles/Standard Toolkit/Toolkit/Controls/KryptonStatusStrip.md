# KryptonStatusStrip

## Overview

The `KryptonStatusStrip` class provides a Krypton-themed replacement for the standard Windows `StatusStrip`. It inherits from `StatusStrip` and offers enhanced visual styling, seamless theme integration, and improved appearance while maintaining full compatibility with the standard `StatusStrip` functionality.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── System.Windows.Forms.ToolStrip
                └── System.Windows.Forms.StatusStrip
                    └── Krypton.Toolkit.KryptonStatusStrip
```

## Constructor and Initialization

```csharp
public KryptonStatusStrip()
```

The constructor initializes enhanced features:
- **Krypton Rendering**: Sets `RenderMode` to `ToolStripRenderMode.ManagerRenderMode` for automatic Krypton theming
- **Palette Integration**: Automatic theme detection and application
- **Visual States**: Common, Normal, and Disabled state management
- **Progress Bar Support**: Enhanced progress bar integration

## Key Properties

### ProgressBars Property

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public ToolStripProgressBar[] ProgressBars { get; set; }
```

- **Purpose**: Array of progress bars for enhanced progress tracking
- **Category**: Runtime
- **Usage**: Multiple progress indicators for complex operations
- **Integration**: Automatically styled with Krypton themes

### Visual State Properties

```csharp
public PaletteBack StateCommon { get; }
public PaletteBack StateDisabled { get; }
public PaletteBack StateNormal { get; }
```

- **StateCommon**: Base styling configuration for all states
- **StateNormal**: Default appearance when enabled
- **StateDisabled**: Appearance when control is disabled

## Advanced Usage Patterns

### Basic Status Strip Setup

```csharp
public void SetupBasicStatusStrip()
{
    var statusStrip = new KryptonStatusStrip();
    
    // Add status label
    var statusLabel = new ToolStripStatusLabel("Ready");
    statusStrip.Items.Add(statusLabel);
    
    // Add progress bar
    var progressBar = new ToolStripProgressBar();
    statusStrip.Items.Add(progressBar);
    
    // Add separator
    statusStrip.Items.Add(new ToolStripSeparator());
    
    // Add time label
    var timeLabel = new ToolStripStatusLabel();
    timeLabel.Spring = true; // Fill remaining space
    timeLabel.TextAlign = ContentAlignment.MiddleRight;
    statusStrip.Items.Add(timeLabel);
    
    Controls.Add(statusStrip);
}
```

### Enhanced Status Strip with Multiple Progress Bars

```csharp
public class EnhancedStatusStrip : KryptonStatusStrip
{
    private ToolStripStatusLabel statusLabel;
    private ToolStripProgressBar mainProgressBar;
    private ToolStripProgressBar secondaryProgressBar;
    private ToolStripStatusLabel timeLabel;
    private ToolStripStatusLabel memoryLabel;
    private Timer updateTimer;

    public EnhancedStatusStrip()
    {
        InitializeComponents();
        SetupTimer();
    }

    private void InitializeComponents()
    {
        // Main status label
        statusLabel = new ToolStripStatusLabel("Ready")
        {
            Spring = true,
            TextAlign = ContentAlignment.MiddleLeft
        };

        // Main progress bar
        mainProgressBar = new ToolStripProgressBar
        {
            Name = "MainProgress",
            Visible = false
        };

        // Secondary progress bar
        secondaryProgressBar = new ToolStripProgressBar
        {
            Name = "SecondaryProgress",
            Visible = false
        };

        // Time label
        timeLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // Memory label
        memoryLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // Add items to status strip
        Items.AddRange(new ToolStripItem[]
        {
            statusLabel,
            new ToolStripSeparator(),
            mainProgressBar,
            secondaryProgressBar,
            new ToolStripSeparator(),
            memoryLabel,
            timeLabel
        });

        // Store progress bars for easy access
        ProgressBars = new[] { mainProgressBar, secondaryProgressBar };
    }

    private void SetupTimer()
    {
        updateTimer = new Timer { Interval = 1000 }; // Update every second
        updateTimer.Tick += OnTimerTick;
        updateTimer.Start();
    }

    private void OnTimerTick(object? sender, EventArgs e)
    {
        // Update time
        timeLabel.Text = DateTime.Now.ToString("HH:mm:ss");

        // Update memory usage
        var memoryUsage = GC.GetTotalMemory(false);
        memoryLabel.Text = $"Memory: {memoryUsage / 1024 / 1024:F1} MB";
    }

    public void SetStatus(string message)
    {
        statusLabel.Text = message;
    }

    public void ShowMainProgress(int value, int maximum = 100)
    {
        mainProgressBar.Maximum = maximum;
        mainProgressBar.Value = value;
        mainProgressBar.Visible = true;
    }

    public void HideMainProgress()
    {
        mainProgressBar.Visible = false;
    }

    public void ShowSecondaryProgress(int value, int maximum = 100)
    {
        secondaryProgressBar.Maximum = maximum;
        secondaryProgressBar.Value = value;
        secondaryProgressBar.Visible = true;
    }

    public void HideSecondaryProgress()
    {
        secondaryProgressBar.Visible = false;
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            updateTimer?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```

### Application Status Manager

```csharp
public class ApplicationStatusManager
{
    private readonly KryptonStatusStrip statusStrip;
    private readonly Dictionary<string, ToolStripStatusLabel> statusLabels;
    private readonly Dictionary<string, ToolStripProgressBar> progressBars;

    public ApplicationStatusManager(KryptonStatusStrip statusStrip)
    {
        this.statusStrip = statusStrip;
        statusLabels = new Dictionary<string, ToolStripStatusLabel>();
        progressBars = new Dictionary<string, ToolStripProgressBar>();
    }

    public void AddStatusLabel(string key, string text, bool spring = false)
    {
        var label = new ToolStripStatusLabel(text)
        {
            Spring = spring
        };

        statusLabels[key] = label;
        statusStrip.Items.Add(label);
    }

    public void AddProgressBar(string key, bool visible = false)
    {
        var progressBar = new ToolStripProgressBar
        {
            Name = key,
            Visible = visible
        };

        progressBars[key] = progressBar;
        statusStrip.Items.Add(progressBar);
    }

    public void UpdateStatus(string key, string text)
    {
        if (statusLabels.TryGetValue(key, out var label))
        {
            label.Text = text;
        }
    }

    public void UpdateProgress(string key, int value, int maximum = 100)
    {
        if (progressBars.TryGetValue(key, out var progressBar))
        {
            progressBar.Maximum = maximum;
            progressBar.Value = value;
            progressBar.Visible = true;
        }
    }

    public void HideProgress(string key)
    {
        if (progressBars.TryGetValue(key, out var progressBar))
        {
            progressBar.Visible = false;
        }
    }

    public void ShowProgress(string key)
    {
        if (progressBars.TryGetValue(key, out var progressBar))
        {
            progressBar.Visible = true;
        }
    }
}
```

### File Operation Status Strip

```csharp
public class FileOperationStatusStrip : KryptonStatusStrip
{
    private ToolStripStatusLabel operationLabel;
    private ToolStripProgressBar operationProgressBar;
    private ToolStripStatusLabel fileLabel;
    private ToolStripStatusLabel speedLabel;
    private ToolStripStatusLabel timeLabel;

    public FileOperationStatusStrip()
    {
        InitializeComponents();
    }

    private void InitializeComponents()
    {
        // Operation label
        operationLabel = new ToolStripStatusLabel("Ready")
        {
            Spring = true
        };

        // Operation progress bar
        operationProgressBar = new ToolStripProgressBar
        {
            Name = "OperationProgress",
            Visible = false
        };

        // File label
        fileLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // Speed label
        speedLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // Time label
        timeLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        Items.AddRange(new ToolStripItem[]
        {
            operationLabel,
            new ToolStripSeparator(),
            operationProgressBar,
            new ToolStripSeparator(),
            fileLabel,
            speedLabel,
            timeLabel
        });

        ProgressBars = new[] { operationProgressBar };
    }

    public void StartFileOperation(string operation, string fileName)
    {
        operationLabel.Text = operation;
        fileLabel.Text = Path.GetFileName(fileName);
        operationProgressBar.Visible = true;
        operationProgressBar.Value = 0;
    }

    public void UpdateFileOperation(int progress, string speed, string timeRemaining)
    {
        operationProgressBar.Value = progress;
        speedLabel.Text = speed;
        timeLabel.Text = timeRemaining;
    }

    public void CompleteFileOperation()
    {
        operationLabel.Text = "Ready";
        fileLabel.Text = string.Empty;
        speedLabel.Text = string.Empty;
        timeLabel.Text = string.Empty;
        operationProgressBar.Visible = false;
    }
}
```

## Integration Patterns

### Main Form Status Strip

```csharp
public partial class MainForm : Form
{
    private KryptonStatusStrip statusStrip;
    private ToolStripStatusLabel statusLabel;
    private ToolStripProgressBar progressBar;
    private ToolStripStatusLabel timeLabel;
    private ToolStripStatusLabel userLabel;

    public MainForm()
    {
        InitializeComponent();
        SetupStatusStrip();
    }

    private void SetupStatusStrip()
    {
        statusStrip = new KryptonStatusStrip();

        // Status label
        statusLabel = new ToolStripStatusLabel("Ready")
        {
            Spring = true
        };

        // Progress bar
        progressBar = new ToolStripProgressBar
        {
            Visible = false
        };

        // Time label
        timeLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // User label
        userLabel = new ToolStripStatusLabel
        {
            Text = Environment.UserName,
            TextAlign = ContentAlignment.MiddleRight
        };

        statusStrip.Items.AddRange(new ToolStripItem[]
        {
            statusLabel,
            new ToolStripSeparator(),
            progressBar,
            new ToolStripSeparator(),
            timeLabel,
            userLabel
        });

        Controls.Add(statusStrip);

        // Update time every second
        var timer = new Timer { Interval = 1000 };
        timer.Tick += (s, e) => timeLabel.Text = DateTime.Now.ToString("HH:mm:ss");
        timer.Start();
    }

    public void SetStatus(string message)
    {
        statusLabel.Text = message;
    }

    public void ShowProgress(int value, int maximum = 100)
    {
        progressBar.Maximum = maximum;
        progressBar.Value = value;
        progressBar.Visible = true;
    }

    public void HideProgress()
    {
        progressBar.Visible = false;
    }
}
```

### Document Editor Status Strip

```csharp
public class DocumentEditorStatusStrip : KryptonStatusStrip
{
    private ToolStripStatusLabel documentLabel;
    private ToolStripStatusLabel positionLabel;
    private ToolStripStatusLabel selectionLabel;
    private ToolStripStatusLabel zoomLabel;
    private ToolStripStatusLabel modeLabel;

    public DocumentEditorStatusStrip()
    {
        InitializeComponents();
    }

    private void InitializeComponents()
    {
        // Document label
        documentLabel = new ToolStripStatusLabel("Untitled")
        {
            Spring = true
        };

        // Position label
        positionLabel = new ToolStripStatusLabel("Line 1, Col 1");

        // Selection label
        selectionLabel = new ToolStripStatusLabel("No selection");

        // Zoom label
        zoomLabel = new ToolStripStatusLabel("100%");

        // Mode label
        modeLabel = new ToolStripStatusLabel("Insert");

        Items.AddRange(new ToolStripItem[]
        {
            documentLabel,
            new ToolStripSeparator(),
            positionLabel,
            selectionLabel,
            zoomLabel,
            modeLabel
        });
    }

    public void UpdateDocumentInfo(string fileName, bool isModified)
    {
        string displayName = string.IsNullOrEmpty(fileName) ? "Untitled" : Path.GetFileName(fileName);
        if (isModified)
        {
            displayName += " *";
        }
        documentLabel.Text = displayName;
    }

    public void UpdateCursorPosition(int line, int column)
    {
        positionLabel.Text = $"Line {line}, Col {column}";
    }

    public void UpdateSelection(string selection)
    {
        selectionLabel.Text = string.IsNullOrEmpty(selection) ? "No selection" : $"{selection.Length} characters selected";
    }

    public void UpdateZoom(int zoomPercentage)
    {
        zoomLabel.Text = $"{zoomPercentage}%";
    }

    public void UpdateMode(bool insertMode)
    {
        modeLabel.Text = insertMode ? "Insert" : "Overwrite";
    }
}
```

## Performance Considerations

- **Theme Integration**: Lightweight wrapper with minimal overhead
- **Memory Management**: Proper disposal of timers and resources
- **Rendering**: Optimized Krypton rendering through ManagerRenderMode
- **Progress Bar Updates**: Efficient progress bar styling and updates

## Common Issues and Solutions

### Progress Bar Not Visible

**Issue**: Progress bar not showing in status strip  
**Solution**: Ensure proper visibility and sizing:

```csharp
progressBar.Visible = true;
progressBar.Size = new Size(200, 16); // Set explicit size
```

### Status Text Not Updating

**Issue**: Status label text not updating  
**Solution**: Ensure proper thread safety for UI updates:

```csharp
if (InvokeRequired)
{
    Invoke(new Action(() => statusLabel.Text = message));
}
else
{
    statusLabel.Text = message;
}
```

### Theme Not Applied

**Issue**: Status strip not using Krypton theme  
**Solution**: Ensure RenderMode is set correctly:

```csharp
statusStrip.RenderMode = ToolStripRenderMode.ManagerRenderMode;
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: All standard StatusStrip properties available
- **Theme Integration**: Automatic Krypton theming applied
- **Item Collection**: Standard ToolStrip item collection editor

### Property Categories

- **Appearance**: Visual properties and styling
- **Behavior**: Functional properties and events
- **Layout**: Sizing and positioning properties

## Migration from Standard StatusStrip

### Direct Replacement

```csharp
// Old code
StatusStrip statusStrip = new StatusStrip();

// New code
KryptonStatusStrip statusStrip = new KryptonStatusStrip();
```

### Enhanced Features

```csharp
// Standard StatusStrip (basic)
var standardSs = new StatusStrip();

// KryptonStatusStrip (enhanced)
var kryptonSs = new KryptonStatusStrip
{
    // Automatic Krypton theming
    // Enhanced progress bar support
    // Improved visual styling
};
```

## Real-World Integration Examples

### Application Main Status Strip

```csharp
public partial class MainApplicationForm : Form
{
    private KryptonStatusStrip mainStatusStrip;
    private ToolStripStatusLabel statusLabel;
    private ToolStripProgressBar mainProgressBar;
    private ToolStripStatusLabel connectionLabel;
    private ToolStripStatusLabel timeLabel;
    private ToolStripStatusLabel versionLabel;

    public MainApplicationForm()
    {
        InitializeComponent();
        SetupMainStatusStrip();
    }

    private void SetupMainStatusStrip()
    {
        mainStatusStrip = new KryptonStatusStrip();

        // Main status label
        statusLabel = new ToolStripStatusLabel("Application Ready")
        {
            Spring = true,
            TextAlign = ContentAlignment.MiddleLeft
        };

        // Main progress bar
        mainProgressBar = new ToolStripProgressBar
        {
            Name = "MainProgress",
            Visible = false,
            Size = new Size(200, 16)
        };

        // Connection status
        connectionLabel = new ToolStripStatusLabel("Disconnected")
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // Time display
        timeLabel = new ToolStripStatusLabel
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        // Version info
        versionLabel = new ToolStripStatusLabel($"v{Application.ProductVersion}")
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        mainStatusStrip.Items.AddRange(new ToolStripItem[]
        {
            statusLabel,
            new ToolStripSeparator(),
            mainProgressBar,
            new ToolStripSeparator(),
            connectionLabel,
            timeLabel,
            versionLabel
        });

        Controls.Add(mainStatusStrip);

        // Update time every second
        var timer = new Timer { Interval = 1000 };
        timer.Tick += OnTimerTick;
        timer.Start();
    }

    private void OnTimerTick(object? sender, EventArgs e)
    {
        timeLabel.Text = DateTime.Now.ToString("HH:mm:ss");
    }

    public void SetStatus(string message)
    {
        statusLabel.Text = message;
    }

    public void ShowProgress(int value, int maximum = 100)
    {
        mainProgressBar.Maximum = maximum;
        mainProgressBar.Value = value;
        mainProgressBar.Visible = true;
    }

    public void HideProgress()
    {
        mainProgressBar.Visible = false;
    }

    public void UpdateConnectionStatus(bool connected)
    {
        connectionLabel.Text = connected ? "Connected" : "Disconnected";
        connectionLabel.ForeColor = connected ? Color.Green : Color.Red;
    }
}
```

### Database Operation Status Strip

```csharp
public class DatabaseStatusStrip : KryptonStatusStrip
{
    private ToolStripStatusLabel operationLabel;
    private ToolStripProgressBar operationProgressBar;
    private ToolStripStatusLabel recordLabel;
    private ToolStripStatusLabel speedLabel;
    private ToolStripStatusLabel connectionLabel;

    public DatabaseStatusStrip()
    {
        InitializeComponents();
    }

    private void InitializeComponents()
    {
        // Operation label
        operationLabel = new ToolStripStatusLabel("Ready")
        {
            Spring = true
        };

        // Operation progress bar
        operationProgressBar = new ToolStripProgressBar
        {
            Name = "OperationProgress",
            Visible = false,
            Size = new Size(150, 16)
        };

        // Record label
        recordLabel = new ToolStripStatusLabel("0 records");

        // Speed label
        speedLabel = new ToolStripStatusLabel("0 records/sec");

        // Connection label
        connectionLabel = new ToolStripStatusLabel("Disconnected")
        {
            TextAlign = ContentAlignment.MiddleRight
        };

        Items.AddRange(new ToolStripItem[]
        {
            operationLabel,
            new ToolStripSeparator(),
            operationProgressBar,
            new ToolStripSeparator(),
            recordLabel,
            speedLabel,
            connectionLabel
        });

        ProgressBars = new[] { operationProgressBar };
    }

    public void StartDatabaseOperation(string operation, int totalRecords)
    {
        operationLabel.Text = operation;
        operationProgressBar.Maximum = totalRecords;
        operationProgressBar.Value = 0;
        operationProgressBar.Visible = true;
        recordLabel.Text = "0 records";
        speedLabel.Text = "0 records/sec";
    }

    public void UpdateDatabaseOperation(int processedRecords, double recordsPerSecond)
    {
        operationProgressBar.Value = processedRecords;
        recordLabel.Text = $"{processedRecords} records";
        speedLabel.Text = $"{recordsPerSecond:F1} records/sec";
    }

    public void CompleteDatabaseOperation()
    {
        operationLabel.Text = "Ready";
        operationProgressBar.Visible = false;
        recordLabel.Text = "0 records";
        speedLabel.Text = "0 records/sec";
    }

    public void UpdateConnectionStatus(bool connected, string serverName = "")
    {
        connectionLabel.Text = connected ? $"Connected to {serverName}" : "Disconnected";
        connectionLabel.ForeColor = connected ? Color.Green : Color.Red;
    }
}
```