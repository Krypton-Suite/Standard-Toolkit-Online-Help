# KryptonFolderBrowserDialog

## Overview

The `KryptonFolderBrowserDialog` class provides a Krypton-themed wrapper around the standard Windows folder browser dialog. It inherits from `ShellDialogWrapper` and implements `IDisposable` to provide enhanced appearance, consistent theming, and modern .NET functionality while maintaining compatibility across different framework versions.

## Class Hierarchy

```
System.Object
└── Krypton.Toolkit.ShellDialogWrapper (abstract)
    └── Krypton.Toolkit.KryptonFolderBrowserDialog
```

## Constructor and Initialization

```csharp
public KryptonFolderBrowserDialog()
```

The constructor initializes the appropriate internal dialog implementation based on the target framework version:
- **.NET 8.0 or later**: Uses the modern `FolderBrowserDialog` class
- **Earlier frameworks**: Uses the custom `ShellBrowserDialogTFM` implementation

## Key Properties

### SelectedPath Property

```csharp
[AllowNull]
public string SelectedPath { get; set; }
```

- **Purpose**: Gets or sets the directory path of the initial folder shown in the dialog
- **Category**: FolderBrowsing
- **Default Value**: Empty string
- **Editor**: Uses `System.Windows.Forms.Design.SelectedPathEditor` for Visual Studio integration
- **Localizable**: Yes

**Usage Example:**
```csharp
var dialog = new KryptonFolderBrowserDialog
{
    SelectedPath = @"C:\Users\UserName\Documents"
};
```

### RootFolder Property

```csharp
public Environment.SpecialFolder RootFolder { get; set; }
```

- **Purpose**: Gets or sets the root node of the directory tree
- **Type**: `Environment.SpecialFolder`
- **Default Value**: `Environment.SpecialFolder.Desktop`
- **Category**: FolderBrowsing

**Available Root Folders:**
- `Desktop` (default)
- `MyComputer`
- `Favorites`
- `Recent`
- `SendTo`
- `StartMenu`
- `MyDocuments`
- `ProgramFiles`
- `MyMusic`
- `MyPictures`
- `Personal`
- `ProgramFilesCommon`
- `Programs`
- `Startup`
- `Startup`
- `System`
- `Templates`

**Usage Example:**
```csharp
var dialog = new KryptonFolderBrowserDialog
{
    RootFolder = Environment.SpecialFolder.MyDocuments
};
```

### Title Property

```csharp
[AllowNull]
public override string Title { get; set; }
```

- **Purpose**: Gets or sets the dialog title displayed in the window caption
- **Category**: Appearance
- **Default Value**: Empty string
- **Localizable**: Yes

**Usage Example:**
```csharp
var dialog = new KryptonFolderBrowserDialog
{
    Title = "Select Destination Folder"
};
```

## Framework-Specific Properties (.NET 8.0+)

### InitialDirectory Property

```csharp
[AllowNull]
public string InitialDirectory { get; set; }
```

- **Purpose**: Gets or sets the initial directory displayed by the folder browser dialog
- **Category**: FolderBrowsing
- **Default Value**: Empty string
- **Editor**: Uses custom `KryptonInitialDirectoryEditor`
- **Availability**: .NET 8.0 and later

### ClientGuid Property

```csharp
public override Guid? ClientGuid { get; set; }
```

- **Purpose**: Associates a GUID with dialog state for persistence
- **Availability**: .NET 8.0 and later
- **Use Cases**: Different dialog instances can have separate persisted states (position, size, last visited folder)

**Usage Example:**
```csharp
var dialog = new KryptonFolderBrowserDialog
{
    ClientGuid = Guid.Parse("12345678-1234-1234-1234-123456789012")
};
```

## Methods

### ShowDialog Methods

```csharp
public DialogResult ShowDialog()
public DialogResult ShowDialog(IWin32Window? owner)
```

- **Purpose**: Displays the folder browser dialog
- **Overloads**: 
  - Non-modal (no owner window)
  - Modal with parent window
- **Returns**: `DialogResult` enumeration value

**Usage Examples:**
```csharp
// Simple usage
var dialog = new KryptonFolderBrowserDialog();
var result = dialog.ShowDialog();

if (result == DialogResult.OK)
{
    string selectedPath = dialog.SelectedPath;
    // Process selected path
}

// With parent window
var result = dialog.ShowDialog(this);
```

### Reset Method

```csharp
public override void Reset()
```

- **Purpose**: Resets all properties to their default values
- **Usage**: Clears customization and returns dialog to initial state

**Usage Example:**
```csharp
dialog.Reset(); // Clears all custom settings
```

### ToString Method

```csharp
public override string ToString()
```

- **Purpose**: Provides a string representation of the dialog object
- **Returns**: String describing the dialog state

### Dispose Method

```csharp
public void Dispose()
```

- **Purpose**: Releases all resources used by the dialog
- **Implementation**: Calls `IDisposable.Dispose()` on internal dialog
- **Note**: Important for proper resource management, though not strictly required for dialog objects

**Usage Example:**
```csharp
using (var dialog = new KryptonFolderBrowserDialog())
{
    var result = dialog.ShowDialog();
    // Dialog automatically disposed
}
```

## Dialog Operation

### Display Behavior

The dialog automatically handles:
- **Theme Integration**: Uses Krypton styling instead of Windows native appearance
- **DPI Scaling**: Automatically adapts to different display scaling factors
- **Window Management**: Ensures proper parent-child relationships and window state
- **Cross-Platform Compatibility**: Adapts behavior based on target framework

### User Interaction

1. **Initial Display**: Shows the folder tree starting from the `RootFolder` location
2. **Navigation**: Users can browse through the folder hierarchy
3. **Selection**: Users click "OK" to select a folder or "Cancel" to abort
4. **Result**: Returns `DialogResult.OK` with `SelectedPath` populated, or `DialogResult.Cancel`

## Internal Implementation Details

### Target Framework Behavior

#### .NET 8.0 and Later
- Uses modern `System.Windows.Forms.FolderBrowserDialog`
- Supports `ClientGuid` for state persistence
- Includes `InitialDirectory` property
- Native folder picker with enhanced UX

#### Earlier Frameworks
- Uses custom `ShellBrowserDialogTFM` wrapper
- Based on `OpenFileDialog` with folder selection modifications
- Customized button text ("Select Folder" instead of "Open")
- Hidden file input controls transformed for folder selection

### Theme Integration

The dialog integrates with Krypton themING through:
- **ShellDialogWrapper**: Base class provides theme-aware window management
- **Window Hooking**: Custom window procedures for styling injection
- **DPI Handling**: Automatic scaling for high-DPI displays
- **Button Customization**: Themed OK/Cancel buttons with proper positioning

## Advanced Usage Patterns

### Folder Selection Workflow

```csharp
public string BrowseForFolder(string initialPath = null)
{
    using var dialog = new KryptonFolderBrowserDialog
    {
        Title = "Choose Destination Folder",
        RootFolder = Environment.SpecialFolder.MyComputer,
        SelectedPath = initialPath ?? Environment.GetFolderPath(Environment.SpecialFolder.Desktop)
    };

#if NET8_0_OR_GREATER
    dialog.ClientGuid = new Guid("Your-Unique-Dialog-ID");
#endif

    return dialog.ShowDialog() == DialogResult.OK 
        ? dialog.SelectedPath 
        : null;
}
```

### Validation and Error Handling

```csharp
public bool ValidateFolderSelection(string path)
{
    try
    {
        return !string.IsNullOrWhiteSpace(path) && 
               Directory.Exists(path);
    }
    catch (ArgumentException)
    {
        return false;
    }
}
```

### Multi-Dialog Coordination

```csharp
public class FolderSelectionService
{
    private static readonly Guid ImportDialogId = new("Import-Dialog-ID");
    private static readonly Guid ExportDialogId = new("Export-Dialog-ID");

    public string BrowseForImportFolder() => 
        ShowDialogWithId("Select Import Folder", ImportDialogId);

    public string BrowseForExportFolder() => 
        ShowDialogWithId("Select Export Folder", ExportDialogId);

    private string ShowDialogWithId(string title, Guid clientId)
    {
        using var dialog = new KryptonFolderBrowserDialog
        {
            Title = title,
            RootFolder = Environment.SpecialFolder.MyDocuments
        };

#if NET8_0_OR_GREATER
        dialog.ClientGuid = clientId;
#endif

        return dialog.ShowDialog() == DialogResult.OK ? dialog.SelectedPath : null;
    }
}
```

## Design-Time Integration

### Visual Studio Designer Support

- **Toolbox**: Appears in Visual Studio toolbox with custom bitmap
- **Properties Window**: All properties exposed with appropriate categories
- **Property Editors**: Specialized editors for folder paths and directory selection
- **Serialization**: Design-time settings preserved in form resources

### Property Categories

- **FolderBrowsing**: Core folder selection properties
- **Appearance**: Visual customization properties
- **Behavior**: Dialog operational settings

## Performance Considerations

- **Lazy Initialization**: Dialog resources created only when needed
- **Memory Management**: Proper disposal prevents memory leaks
- **Thread Safety**: Dialog should be created and used on UI thread
- **State Persistence**: ClientGuid usage may have minor storage overhead

## Common Issues and Solutions

### Directory Not Found

**Issue**: SelectedPath refers to non-existent directory
**Solution**: Validate before setting or handle gracefully in user code

### Permission Denied

**Issue**: User lacks access to selected folder
**Solution**: Implement proper access validation or provide meaningful error messages

### Cross-Framework Compatibility

**Issue**: Code relying on .NET 8.0+ specific features
**Solution**: Use conditional compilation or feature detection

## Migration from Standard FolderBrowserDialog

### Direct Replacement

```csharp
// Old code
using FolderBrowserDialog = System.Windows.Forms.FolderBrowserDialog;
var dialog = new FolderBrowserDialog();

// New code
var dialog = new KryptonFolderBrowserDialog();
```

### Feature Parity Migration

Most `System.Windows.Forms.FolderBrowserDialog` APIs have direct equivalents:
- `SelectedPath` → `SelectedPath`
- `RootFolder` → `RootFolder`
- `Description` → Not available (by design)
- `ShowDialog()` → `ShowDialog()`