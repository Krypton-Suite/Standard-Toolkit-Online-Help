# KryptonFileSystemWatcher

## Overview

`KryptonFileSystemWatcher` is a Krypton-themed wrapper around the standard `System.IO.FileSystemWatcher` component. It provides all the functionality of the native FileSystemWatcher while integrating seamlessly with the Krypton palette system for consistent theming across your application.

### Key Features

- **Full FileSystemWatcher Compatibility**: Drop-in replacement with identical API
- **Krypton Palette Integration**: Supports all Krypton palette modes (Global, Professional, Office, etc.)
- **Design-Time Support**: Available in Visual Studio toolbox
- **Event Forwarding**: All standard FileSystemWatcher events are properly forwarded
- **Resource Management**: Proper disposal of underlying resources

## Namespace

```csharp
using Krypton.Toolkit;
```

## Class Declaration

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(FileSystemWatcher))]
[DefaultEvent(nameof(Created))]
[DefaultProperty(nameof(Path))]
[DesignerCategory(@"code")]
[Description(@"Listens to the file system change notifications and raises events when a directory, or file in a directory, changes.")]
public class KryptonFileSystemWatcher : Component
```

## Constructors

### KryptonFileSystemWatcher()

Creates a new instance of `KryptonFileSystemWatcher` with default settings.

```csharp
var watcher = new KryptonFileSystemWatcher();
```

**Initial Values:**
- `Path`: Empty string
- `Filter`: "*.*"
- `EnableRaisingEvents`: `false`
- `IncludeSubdirectories`: `false`
- `NotifyFilter`: `FileName | DirectoryName | LastWrite`
- `InternalBufferSize`: 8192 bytes
- `PaletteMode`: `PaletteMode.Global`

### KryptonFileSystemWatcher(IContainer container)

Creates a new instance and adds it to the specified container.

```csharp
var watcher = new KryptonFileSystemWatcher(components);
```

**Parameters:**
- `container` (IContainer): The container that will contain this component

### KryptonFileSystemWatcher(string path)

Creates a new instance monitoring the specified directory path.

```csharp
var watcher = new KryptonFileSystemWatcher(@"C:\MyFolder");
```

**Parameters:**
- `path` (string): The directory to monitor (standard or UNC notation)

### KryptonFileSystemWatcher(string path, string filter)

Creates a new instance monitoring the specified directory with a file filter.

```csharp
var watcher = new KryptonFileSystemWatcher(@"C:\MyFolder", "*.txt");
```

**Parameters:**
- `path` (string): The directory to monitor
- `filter` (string): File filter pattern (e.g., "*.txt", "*.log")

## Properties

### Path

Gets or sets the path of the directory to watch.

```csharp
[Category(@"Behavior")]
[Description(@"The path of the directory to watch.")]
[DefaultValue("")]
[Editor(typeof(System.Windows.Forms.Design.FolderNameEditor), typeof(System.Drawing.Design.UITypeEditor))]
public string Path { get; set; }
```

**Example:**
```csharp
watcher.Path = @"C:\MyDocuments";
watcher.Path = @"\\Server\SharedFolder";
```

**Notes:**
- Supports standard paths and UNC notation
- Use the folder name editor in the property grid for easy selection
- Must be set before enabling the watcher

### Filter

Gets or sets the filter string used to determine what files are monitored.

```csharp
[Category(@"Behavior")]
[Description(@"The filter string used to determine what files are monitored in a directory.")]
[DefaultValue("*.*")]
public string Filter { get; set; }
```

**Example:**
```csharp
watcher.Filter = "*.txt";        // Only text files
watcher.Filter = "*.log";        // Only log files
watcher.Filter = "*.xml";        // Only XML files
watcher.Filter = "*.*";          // All files (default)
watcher.Filter = "MyFile.*";     // Files named "MyFile" with any extension
```

**Common Patterns:**
- `"*.txt"` - All text files
- `"*.log"` - All log files
- `"*.xml"` - All XML files
- `"*.cs"` - All C# source files
- `"*.*"` - All files (default)

### NotifyFilter

Gets or sets the type of changes to watch for.

```csharp
[Category(@"Behavior")]
[Description(@"The type of changes to watch for.")]
[DefaultValue(NotifyFilters.FileName | NotifyFilters.DirectoryName | NotifyFilters.LastWrite)]
public NotifyFilters NotifyFilter { get; set; }
```

**NotifyFilters Enum Values:**
- `FileName` - Changes to file names
- `DirectoryName` - Changes to directory names
- `Attributes` - Changes to file or folder attributes
- `Size` - Changes to file size
- `LastWrite` - Changes to last write time
- `LastAccess` - Changes to last access time
- `CreationTime` - Changes to creation time
- `Security` - Changes to security settings

**Example:**
```csharp
// Watch for file name changes and writes
watcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite;

// Watch for all changes
watcher.NotifyFilter = NotifyFilters.All;

// Watch only for file creation
watcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.CreationTime;
```

### EnableRaisingEvents

Gets or sets a value indicating whether the component is enabled and raising events.

```csharp
[Category(@"Behavior")]
[Description(@"Indicates whether the component is enabled.")]
[DefaultValue(false)]
public bool EnableRaisingEvents { get; set; }
```

**Example:**
```csharp
watcher.Path = @"C:\MyFolder";
watcher.Filter = "*.txt";
watcher.EnableRaisingEvents = true;  // Start watching
```

**Important:**
- Set `Path` before enabling
- Set to `false` to stop watching
- Must be set to `true` to receive events

### IncludeSubdirectories

Gets or sets a value indicating whether subdirectories should be monitored.

```csharp
[Category(@"Behavior")]
[Description(@"Indicates whether subdirectories within the specified path should be monitored.")]
[DefaultValue(false)]
public bool IncludeSubdirectories { get; set; }
```

**Example:**
```csharp
watcher.Path = @"C:\MyDocuments";
watcher.IncludeSubdirectories = true;  // Monitor all subdirectories
```

**Performance Note:**
- Enabling subdirectory monitoring increases resource usage
- Use with caution on large directory trees

### InternalBufferSize

Gets or sets the size (in bytes) of the internal buffer.

```csharp
[Category(@"Behavior")]
[Description(@"The size (in bytes) of the internal buffer.")]
[DefaultValue(8192)]
public int InternalBufferSize { get; set; }
```

**Example:**
```csharp
watcher.InternalBufferSize = 16384;  // 16KB buffer
```

**Recommendations:**
- Default: 8192 bytes (8KB)
- Increase for high-frequency file operations
- Must be a multiple of 4096
- Larger buffers reduce missed events but use more memory

### SynchronizingObject

Gets or sets the object used to marshal event handler calls.

```csharp
[Category(@"Behavior")]
[Description(@"The object used to marshal the event handler calls that are issued as a result of a directory change.")]
[DefaultValue(null)]
[Browsable(false)]
public ISynchronizeInvoke? SynchronizingObject { get; set; }
```

**Example:**
```csharp
watcher.SynchronizingObject = this;  // Marshal to UI thread
```

**Usage:**
- Set to a form or control to marshal events to the UI thread
- Prevents cross-thread exceptions
- Typically set to the form containing the watcher

### PaletteMode

Gets or sets the palette mode for Krypton integration.

```csharp
[Category(@"Visuals")]
[Description(@"Sets the palette mode.")]
[DefaultValue(PaletteMode.Global)]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PaletteMode PaletteMode { get; set; }
```

**PaletteMode Values:**
- `Global` - Uses the global Krypton palette (default)
- `ProfessionalSystem` - Professional system theme
- `ProfessionalOffice2003` - Office 2003 theme
- `ProfessionalOffice2007` - Office 2007 theme
- `ProfessionalOffice2010` - Office 2010 theme
- `ProfessionalOffice2013` - Office 2013 theme
- `SparkleBlue` - Sparkle Blue theme
- `SparkleOrange` - Sparkle Orange theme
- `SparklePurple` - Sparkle Purple theme
- `Custom` - Use custom palette (requires `Palette` property)

**Example:**
```csharp
watcher.PaletteMode = PaletteMode.ProfessionalOffice2010;
```

### Palette

Gets or sets the custom palette (only used when `PaletteMode` is `Custom`).

```csharp
[Category(@"Visuals")]
[Description(@"Sets the custom palette to be used.")]
[DefaultValue(null)]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public PaletteBase? Palette { get; set; }
```

**Example:**
```csharp
var customPalette = new KryptonPalette();
// Configure custom palette...
watcher.PaletteMode = PaletteMode.Custom;
watcher.Palette = customPalette;
```

### FileSystemWatcher

Gets access to the underlying `FileSystemWatcher` component.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public FileSystemWatcher? FileSystemWatcher { get; }
```

**Example:**
```csharp
var underlyingWatcher = watcher.FileSystemWatcher;
// Direct access to underlying component if needed
```

## Events

### Created

Occurs when a file or directory in the specified `Path` is created.

```csharp
[Category(@"File System")]
[Description(@"Occurs when a file or directory in the specified Path is created.")]
public event FileSystemEventHandler? Created;
```

**Event Handler Signature:**
```csharp
void OnFileCreated(object sender, FileSystemEventArgs e)
```

**FileSystemEventArgs Properties:**
- `FullPath` (string): Full path of the created file/directory
- `Name` (string): Name of the file/directory
- `ChangeType` (WatcherChangeTypes): Type of change (`Created`)

**Example:**
```csharp
watcher.Created += (sender, e) =>
{
    Console.WriteLine($"File created: {e.FullPath}");
    Console.WriteLine($"Name: {e.Name}");
    Console.WriteLine($"Change type: {e.ChangeType}");
};
```

### Changed

Occurs when a file or directory in the specified `Path` is changed.

```csharp
[Category(@"File System")]
[Description(@"Occurs when a file or directory in the specified Path is changed.")]
public event FileSystemEventHandler? Changed;
```

**Example:**
```csharp
watcher.Changed += (sender, e) =>
{
    Console.WriteLine($"File changed: {e.FullPath}");
    
    // Check what changed
    if (e.ChangeType == WatcherChangeTypes.Changed)
    {
        // File was modified
    }
};
```

**Note:** The `Changed` event can fire multiple times for a single file operation. Consider debouncing if needed.

### Deleted

Occurs when a file or directory in the specified `Path` is deleted.

```csharp
[Category(@"File System")]
[Description(@"Occurs when a file or directory in the specified Path is deleted.")]
public event FileSystemEventHandler? Deleted;
```

**Example:**
```csharp
watcher.Deleted += (sender, e) =>
{
    Console.WriteLine($"File deleted: {e.FullPath}");
    // Clean up references, update UI, etc.
};
```

### Renamed

Occurs when a file or directory in the specified `Path` is renamed.

```csharp
[Category(@"File System")]
[Description(@"Occurs when a file or directory in the specified Path is renamed.")]
public event RenamedEventHandler? Renamed;
```

**Event Handler Signature:**
```csharp
void OnFileRenamed(object sender, RenamedEventArgs e)
```

**RenamedEventArgs Properties:**
- `FullPath` (string): Full path of the renamed file/directory
- `Name` (string): New name
- `OldFullPath` (string): Previous full path
- `OldName` (string): Previous name
- `ChangeType` (WatcherChangeTypes): Type of change (`Renamed`)

**Example:**
```csharp
watcher.Renamed += (sender, e) =>
{
    Console.WriteLine($"File renamed:");
    Console.WriteLine($"  Old: {e.OldFullPath}");
    Console.WriteLine($"  New: {e.FullPath}");
};
```

### Error

Occurs when the internal buffer overflows.

```csharp
[Category(@"File System")]
[Description(@"Occurs when the internal buffer overflows.")]
public event ErrorEventHandler? Error;
```

**Event Handler Signature:**
```csharp
void OnError(object sender, ErrorEventArgs e)
```

**ErrorEventArgs Properties:**
- `GetException()` (Exception): The exception that occurred

**Example:**
```csharp
watcher.Error += (sender, e) =>
{
    var ex = e.GetException();
    Console.WriteLine($"FileSystemWatcher error: {ex.Message}");
    
    // Increase buffer size or handle error
    watcher.InternalBufferSize *= 2;
};
```

**Common Causes:**
- Too many rapid file changes
- Buffer size too small
- Network latency (for UNC paths)

## Methods

### BeginInit()

Begins the initialization of the FileSystemWatcher. Used for design-time support.

```csharp
public void BeginInit()
```

**Example:**
```csharp
watcher.BeginInit();
watcher.Path = @"C:\MyFolder";
watcher.Filter = "*.txt";
watcher.EndInit();
```

### EndInit()

Ends the initialization of the FileSystemWatcher. Used for design-time support.

```csharp
public void EndInit()
```

**Example:**
See `BeginInit()` example above.

### WaitForChanged(WatcherChangeTypes changeType)

Synchronously waits for a specific type of change to occur.

```csharp
public WaitForChangedResult WaitForChanged(WatcherChangeTypes changeType)
```

**Parameters:**
- `changeType` (WatcherChangeTypes): Type of change to wait for (`Created`, `Deleted`, `Changed`, `Renamed`, `All`)

**Returns:**
- `WaitForChangedResult`: Structure containing information about the change

**Example:**
```csharp
var result = watcher.WaitForChanged(WatcherChangeTypes.Created);
Console.WriteLine($"File created: {result.Name}");
```

**Note:** This method blocks the calling thread until a change occurs.

### WaitForChanged(WatcherChangeTypes changeType, int timeout)

Synchronously waits for a specific type of change with a timeout.

```csharp
public WaitForChangedResult WaitForChanged(WatcherChangeTypes changeType, int timeout)
```

**Parameters:**
- `changeType` (WatcherChangeTypes): Type of change to wait for
- `timeout` (int): Timeout in milliseconds

**Returns:**
- `WaitForChangedResult`: Structure containing information about the change, or default if timeout

**Example:**
```csharp
var result = watcher.WaitForChanged(WatcherChangeTypes.Created, 5000);
if (result.TimedOut)
{
    Console.WriteLine("Timeout waiting for file creation");
}
else
{
    Console.WriteLine($"File created: {result.Name}");
}
```

## Usage Examples

### Basic File Monitoring

```csharp
using Krypton.Toolkit;
using System.IO;

public class FileMonitor
{
    private KryptonFileSystemWatcher _watcher;

    public void StartMonitoring(string folderPath)
    {
        _watcher = new KryptonFileSystemWatcher(folderPath)
        {
            Filter = "*.txt",
            NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite,
            IncludeSubdirectories = false
        };

        _watcher.Created += OnFileCreated;
        _watcher.Changed += OnFileChanged;
        _watcher.Deleted += OnFileDeleted;
        _watcher.Renamed += OnFileRenamed;
        _watcher.Error += OnError;

        _watcher.EnableRaisingEvents = true;
    }

    private void OnFileCreated(object sender, FileSystemEventArgs e)
    {
        Console.WriteLine($"Created: {e.FullPath}");
    }

    private void OnFileChanged(object sender, FileSystemEventArgs e)
    {
        Console.WriteLine($"Changed: {e.FullPath}");
    }

    private void OnFileDeleted(object sender, FileSystemEventArgs e)
    {
        Console.WriteLine($"Deleted: {e.FullPath}");
    }

    private void OnFileRenamed(object sender, RenamedEventArgs e)
    {
        Console.WriteLine($"Renamed: {e.OldFullPath} -> {e.FullPath}");
    }

    private void OnError(object sender, ErrorEventArgs e)
    {
        Console.WriteLine($"Error: {e.GetException().Message}");
    }

    public void StopMonitoring()
    {
        if (_watcher != null)
        {
            _watcher.EnableRaisingEvents = false;
            _watcher.Dispose();
        }
    }
}
```

### Monitoring with UI Thread Marshaling

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonFileSystemWatcher _watcher;

    public MainForm()
    {
        InitializeComponent();
        SetupFileWatcher();
    }

    private void SetupFileWatcher()
    {
        _watcher = new KryptonFileSystemWatcher(@"C:\MyFolder")
        {
            Filter = "*.log",
            SynchronizingObject = this  // Marshal events to UI thread
        };

        _watcher.Created += OnFileCreated;
        _watcher.Changed += OnFileChanged;
        _watcher.EnableRaisingEvents = true;
    }

    private void OnFileCreated(object sender, FileSystemEventArgs e)
    {
        // Safe to update UI directly - already on UI thread
        listBoxFiles.Items.Add($"Created: {e.Name}");
    }

    private void OnFileChanged(object sender, FileSystemEventArgs e)
    {
        // Safe to update UI directly
        listBoxFiles.Items.Add($"Changed: {e.Name}");
    }

    protected override void OnFormClosing(FormClosingEventArgs e)
    {
        _watcher?.Dispose();
        base.OnFormClosing(e);
    }
}
```

### Monitoring with Debouncing

```csharp
public class DebouncedFileWatcher
{
    private KryptonFileSystemWatcher _watcher;
    private System.Windows.Forms.Timer _debounceTimer;
    private readonly Dictionary<string, DateTime> _pendingChanges = new();

    public DebouncedFileWatcher(string folderPath)
    {
        _watcher = new KryptonFileSystemWatcher(folderPath)
        {
            Filter = "*.*",
            NotifyFilter = NotifyFilters.LastWrite
        };

        _watcher.Changed += OnFileChanged;
        _watcher.EnableRaisingEvents = true;

        _debounceTimer = new System.Windows.Forms.Timer { Interval = 1000 };
        _debounceTimer.Tick += OnDebounceTimerTick;
    }

    private void OnFileChanged(object sender, FileSystemEventArgs e)
    {
        _pendingChanges[e.FullPath] = DateTime.Now;
        _debounceTimer.Stop();
        _debounceTimer.Start();
    }

    private void OnDebounceTimerTick(object sender, EventArgs e)
    {
        _debounceTimer.Stop();
        
        foreach (var change in _pendingChanges)
        {
            ProcessFileChange(change.Key);
        }
        
        _pendingChanges.Clear();
    }

    private void ProcessFileChange(string filePath)
    {
        Console.WriteLine($"File change processed: {filePath}");
        // Your processing logic here
    }
}
```

### Monitoring Network Shares

```csharp
public void MonitorNetworkShare()
{
    var watcher = new KryptonFileSystemWatcher(@"\\Server\SharedFolder")
    {
        Filter = "*.xlsx",
        NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite,
        InternalBufferSize = 16384  // Larger buffer for network
    };

    watcher.Created += (s, e) => Console.WriteLine($"Network file created: {e.FullPath}");
    watcher.Changed += (s, e) => Console.WriteLine($"Network file changed: {e.FullPath}");
    watcher.Error += (s, e) => Console.WriteLine($"Network error: {e.GetException().Message}");

    watcher.EnableRaisingEvents = true;
}
```

## Best Practices

### 1. Always Dispose

Always dispose of the watcher when done:

```csharp
using (var watcher = new KryptonFileSystemWatcher())
{
    // Use watcher
}
// Automatically disposed
```

Or in a form:

```csharp
protected override void OnFormClosing(FormClosingEventArgs e)
{
    _watcher?.Dispose();
    base.OnFormClosing(e);
}
```

### 2. Set Path Before Enabling

Always set the `Path` property before setting `EnableRaisingEvents` to `true`:

```csharp
watcher.Path = @"C:\MyFolder";  // Set path first
watcher.Filter = "*.txt";
watcher.EnableRaisingEvents = true;  // Then enable
```

### 3. Handle Errors

Always handle the `Error` event:

```csharp
watcher.Error += (sender, e) =>
{
    var ex = e.GetException();
    // Log error, increase buffer, or handle appropriately
};
```

### 4. Use SynchronizingObject for UI Updates

When updating UI from events, set `SynchronizingObject`:

```csharp
watcher.SynchronizingObject = this;  // Form or control
```

### 5. Adjust Buffer Size for High-Frequency Operations

Increase `InternalBufferSize` for directories with many rapid changes:

```csharp
watcher.InternalBufferSize = 16384;  // 16KB instead of default 8KB
```

### 6. Be Selective with NotifyFilter

Only watch for changes you actually need:

```csharp
// Only watch for file name changes and writes
watcher.NotifyFilter = NotifyFilters.FileName | NotifyFilters.LastWrite;
```

### 7. Consider Debouncing for Changed Events

The `Changed` event can fire multiple times. Consider debouncing:

```csharp
// See debouncing example above
```

## Threading Considerations

### Events Are Raised on Background Threads

By default, events are raised on background threads. Use `SynchronizingObject` to marshal to UI thread:

```csharp
watcher.SynchronizingObject = this;  // Marshal to form's thread
```

### Manual Thread Marshaling

If not using `SynchronizingObject`, manually marshal:

```csharp
watcher.Created += (sender, e) =>
{
    if (InvokeRequired)
    {
        Invoke(new Action(() => UpdateUI(e)));
    }
    else
    {
        UpdateUI(e);
    }
};
```

## Integration with Krypton Palette System

### Using Global Palette

```csharp
var watcher = new KryptonFileSystemWatcher();
// Uses global palette automatically
```

### Using Specific Theme

```csharp
watcher.PaletteMode = PaletteMode.ProfessionalOffice2010;
```

### Using Custom Palette

```csharp
var customPalette = new KryptonPalette();
// Configure palette...
watcher.PaletteMode = PaletteMode.Custom;
watcher.Palette = customPalette;
```

## Limitations and Considerations

1. **Network Paths**: May have delays or missed events on network shares
2. **Buffer Overflow**: Can occur with very high-frequency changes
3. **Multiple Events**: `Changed` event can fire multiple times for single operation
4. **Security**: Requires appropriate file system permissions
5. **Performance**: Monitoring large directory trees can impact performance

## Troubleshooting

### Events Not Firing

- Ensure `Path` is set before `EnableRaisingEvents = true`
- Check file system permissions
- Verify the path exists and is accessible
- Check `Filter` pattern matches files

### Missing Events

- Increase `InternalBufferSize`
- Reduce monitoring scope (disable `IncludeSubdirectories`)
- Check for buffer overflow in `Error` event

### Cross-Thread Exceptions

- Set `SynchronizingObject` property
- Or manually marshal to UI thread using `Invoke`

## Related Components

- `KryptonSplitter` - For resizing docked controls
- `KryptonTimer` - For timed operations
- `KryptonManager` - For global palette management

## See Also

- [System.IO.FileSystemWatcher Documentation](https://docs.microsoft.com/dotnet/api/system.io.filesystemwatcher)
