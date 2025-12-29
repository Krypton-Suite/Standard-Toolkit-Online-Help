# KryptonFileSystemTreeView

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Architecture](#architecture)
4. [API Reference](#api-reference)
5. [Usage Examples](#usage-examples)
6. [Properties Reference](#properties-reference)
7. [Methods Reference](#methods-reference)
8. [Events Reference](#events-reference)
9. [Related Classes](#related-classes)
10. [Root Modes](#root-modes)
11. [Icon Management](#icon-management)
12. [Best Practices](#best-practices)
13. [Known Limitations](#known-limitations)
14. [Troubleshooting](#troubleshooting)

---

## Overview

`KryptonFileSystemTreeView` is a specialized WinForms TreeView control that provides a hierarchical file system browser with native Windows icons, multiple root display modes, and comprehensive file system navigation capabilities. It extends `KryptonTreeView` to provide a Krypton-styled, feature-rich file browser component similar to Windows Explorer.

### Key Capabilities

- **Multiple Root Modes**: Desktop, Computer, Drives, or CustomPath
- **Hierarchical Navigation**: Expandable tree structure for browsing directories
- **Native Icon Support**: Displays Windows shell icons for files, folders, and drives
- **Special Folders**: Support for Desktop, Computer, Network, Recycle Bin, etc.
- **File Filtering**: Filter files by extension patterns
- **Hidden/System File Control**: Toggle visibility of hidden and system files
- **Lazy Loading**: Directories are loaded on-demand when expanded
- **Icon Caching**: Efficient icon caching to improve performance
- **Error Handling**: Comprehensive error event system for file system access issues

### Namespace

```csharp
using Krypton.Utilities;
```

### Inheritance Hierarchy

```
System.Object
  └─ System.MarshalByRefObject
      └─ System.ComponentModel.Component
          └─ System.Windows.Forms.Control
              └─ System.Windows.Forms.TreeView
                  └─ Krypton.Toolkit.KryptonTreeView
                      └─ Krypton.Utilities.KryptonFileSystemTreeView
```

---

## Features

### Core Features

1. **Root Display Modes**
   - **Desktop**: Explorer-style with special folders (Computer, Network, Recycle Bin, etc.) and drives
   - **Computer**: Computer root with all drives
   - **Drives**: All drives directly as root nodes
   - **CustomPath**: Custom root directory path

2. **Directory Navigation**
   - Expandable tree structure
   - Lazy loading (directories loaded on expansion)
   - Parent-child relationships
   - Drive-level navigation

3. **File Display**
   - Display files and folders with proper icons
   - File type detection via extension
   - Configurable file filtering
   - Optional file display (directories-only mode)

4. **Icon Management**
   - Windows shell icon extraction
   - Icon caching for performance
   - Drive-specific icons (Fixed, Removable, CD-ROM, Network, RAM)
   - Folder open/closed state icons
   - Fallback icon system for missing icons

5. **Special Folders**
   - Desktop folder
   - Computer (CLSID-based)
   - Control Panel (CLSID-based)
   - Network (CLSID-based)
   - Recycle Bin (CLSID-based)
   - My Documents
   - Shared Documents

6. **Filtering Options**
   - Show/hide files
   - Show/hide hidden files
   - Show/hide system files
   - File extension filtering (e.g., "*.txt", "*.txt;*.doc")
   - Show/hide special folders (Desktop mode only)

7. **Error Handling**
   - File system error events
   - Graceful handling of access denied errors
   - Directory not found handling

---

## Architecture

### Component Structure

```
KryptonFileSystemTreeView
├── FileSystemTreeViewValues (expandable properties)
│   ├── RootMode (FileSystemRootMode)
│   ├── RootPath (string)
│   ├── ShowFiles (bool)
│   ├── ShowHiddenFiles (bool)
│   ├── ShowSystemFiles (bool)
│   ├── FileFilter (string)
│   └── ShowSpecialFolders (bool)
├── ImageList (icon storage)
├── IconCache (Dictionary<string, int>)
├── Dummy Nodes (for lazy loading)
└── Event Handlers
    ├── DirectoryExpanding
    ├── DirectoryExpanded
    └── FileSystemError
```

### Key Components

1. **FileSystemTreeViewValues**: Groups file system-specific properties in an expandable PropertyGrid object
2. **ImageList**: Stores icons for display (16x16 pixels, fixed size)
3. **IconCache**: Dictionary caching icon indices by file extension, directory marker, or drive type
4. **Dummy Nodes**: Hidden placeholder nodes (`"__DUMMY__"`) used to enable expansion without pre-loading children
5. **Helper Classes**:
   - `FileSystemIconHelper`: Extracts icons from Windows Shell
   - `StockIconHelper`: Provides fallback stock icons

### Data Flow

1. **Initialization**: Constructor → `InitializeImageList()` → `AddDefaultIcon()` → `Reload()` (on handle creation)
2. **Expansion**: User expands node → `OnBeforeExpand()` → Check for dummy node → `LoadDirectoryNodes()` → Replace dummy with real nodes
3. **Icon Loading**: `GetIconIndex()` → Check cache → Extract icon → Add to ImageList → Cache index
4. **Property Changes**: Property setter → `Reload()` → Refresh display based on `RootMode`

### Lazy Loading Mechanism

The control uses dummy nodes to implement lazy loading:

1. Each directory node initially contains one dummy child node (`"__DUMMY__"`)
2. When user expands a node, `OnBeforeExpand()` detects the dummy node
3. Dummy node is removed and replaced with actual directory/file nodes
4. Dummy nodes are hidden from view via `OnDrawNode()` event handler

This ensures directories are only loaded when needed, improving initial load time.

---

## API Reference

### Class Declaration

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(KryptonTreeView), "ToolboxBitmaps.KryptonTreeView.bmp")]
[DefaultEvent(nameof(AfterSelect))]
[DefaultProperty(nameof(FileSystemTreeViewValues))]
[DesignerCategory(@"code")]
[Description(@"Displays a hierarchical file system tree with Krypton styling.")]
[Docking(DockingBehavior.Ask)]
public class KryptonFileSystemTreeView : KryptonTreeView
```

### Constructor

```csharp
public KryptonFileSystemTreeView()
```

Initializes a new instance with default settings:
- Root mode: `FileSystemRootMode.Drives`
- Show files: `true`
- Show hidden files: `false`
- Show system files: `false`
- File filter: `"*.*"`
- Show special folders: `true`
- Icon size: 16x16 pixels
- Show plus/minus: `true`
- Show root lines: `true`
- Show lines: `true`

---

## Properties Reference

### Public Properties

#### FileSystemTreeViewValues

```csharp
public FileSystemTreeViewValues FileSystemTreeViewValues { get; }
```

Gets the file system TreeView values object containing all file system-specific properties. This is an expandable object that groups related properties for better PropertyGrid organization.

**Access Pattern:**
```csharp
fileSystemTreeView.FileSystemTreeViewValues.RootMode = FileSystemRootMode.Desktop;
fileSystemTreeView.FileSystemTreeViewValues.ShowFiles = true;
```

#### RootMode

```csharp
[Category(@"Behavior")]
[Description(@"Determines the root display mode: Desktop (Explorer-style with special folders), Computer (drives only), Drives (all drives), or CustomPath (use RootPath).")]
[DefaultValue(FileSystemRootMode.Drives)]
public FileSystemRootMode RootMode { get; set; }
```

Gets or sets the root mode for the tree view.

**Values:**
- `FileSystemRootMode.Desktop`: Desktop root with special folders and drives
- `FileSystemRootMode.Computer`: Computer root with all drives
- `FileSystemRootMode.Drives`: All drives as root nodes (default)
- `FileSystemRootMode.CustomPath`: Custom root directory (uses `RootPath`)

**Behavior:**
- Changing this property automatically calls `Reload()` to refresh the display

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.Desktop;
```

#### RootPath

```csharp
[Category(@"Behavior")]
[Description(@"The root directory path to display in the tree view (used when RootMode is CustomPath).")]
[DefaultValue("")]
public string RootPath { get; set; }
```

Gets or sets the root directory path to display in the tree view (used when `RootMode` is `CustomPath`).

**Behavior:**
- Only used when `RootMode` is `FileSystemRootMode.CustomPath`
- If path is invalid or empty when in CustomPath mode, falls back to `Drives` mode
- Changing this property automatically calls `Reload()` if in CustomPath mode

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.CustomPath;
fileSystemTreeView.RootPath = @"C:\Users";
```

#### ShowFiles

```csharp
[Category(@"Behavior")]
[Description(@"Indicates whether files should be displayed in the tree view.")]
[DefaultValue(true)]
public bool ShowFiles { get; set; }
```

Gets or sets a value indicating whether files should be displayed in the tree view.

**Behavior:**
- When `false`, only directories are displayed
- Changing this property triggers `Reload()`

**Example:**
```csharp
// Show only directories
fileSystemTreeView.ShowFiles = false;
```

#### ShowHiddenFiles

```csharp
[Category(@"Behavior")]
[Description(@"Indicates whether hidden files should be displayed.")]
[DefaultValue(false)]
public bool ShowHiddenFiles { get; set; }
```

Gets or sets a value indicating whether hidden files should be displayed.

**Behavior:**
- Files and folders with `FileAttributes.Hidden` are filtered based on this setting
- Changing this property triggers `Reload()`

**Example:**
```csharp
fileSystemTreeView.ShowHiddenFiles = true;
```

#### ShowSystemFiles

```csharp
[Category(@"Behavior")]
[Description(@"Indicates whether system files should be displayed.")]
[DefaultValue(false)]
public bool ShowSystemFiles { get; set; }
```

Gets or sets a value indicating whether system files should be displayed.

**Behavior:**
- Files and folders with `FileAttributes.System` are filtered based on this setting
- Changing this property triggers `Reload()`

**Example:**
```csharp
fileSystemTreeView.ShowSystemFiles = true;
```

#### FileFilter

```csharp
[Category(@"Behavior")]
[Description("The file filter to apply when showing files (e.g., \"*.txt\" or \"*.txt;*.doc\").")]
[DefaultValue("*.*")]
public string FileFilter { get; set; }
```

Gets or sets the file filter to apply when showing files.

**Filter Syntax:**
- Single pattern: `"*.txt"` - shows only .txt files
- Multiple patterns: `"*.txt;*.doc;*.pdf"` - shows files matching any pattern
- All files: `"*.*"` - shows all files

**Behavior:**
- Used with `Directory.GetFiles(directoryPath, filter)`
- Changing this property triggers `Reload()` only if `ShowFiles` is `true`
- Null values are converted to `"*.*"`

**Examples:**
```csharp
// Show only text files
fileSystemTreeView.FileFilter = "*.txt";

// Show multiple file types
fileSystemTreeView.FileFilter = "*.txt;*.doc;*.pdf";
```

#### ShowSpecialFolders

```csharp
[Category(@"Behavior")]
[Description(@"Indicates whether special folders (Desktop, Computer, Network, Recycle Bin, etc.) should be displayed when RootMode is Desktop.")]
[DefaultValue(true)]
public bool ShowSpecialFolders { get; set; }
```

Gets or sets a value indicating whether special folders should be displayed when `RootMode` is `Desktop`.

**Behavior:**
- Only affects display when `RootMode` is `FileSystemRootMode.Desktop`
- Special folders include: Computer, Control Panel, Network, Recycle Bin, My Documents, Shared Documents
- Changing this property triggers `Reload()` only if in Desktop mode

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.Desktop;
fileSystemTreeView.ShowSpecialFolders = false; // Hide special folders
```

#### SelectedPath

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public string? SelectedPath { get; }
```

Gets the full path of the currently selected file or folder.

**Returns:**
- The full path string if a node is selected, otherwise `null`
- Path is stored in `TreeNode.Tag` property

**Example:**
```csharp
string? selectedPath = fileSystemTreeView.SelectedPath;
if (!string.IsNullOrEmpty(selectedPath))
{
    Console.WriteLine($"Selected: {selectedPath}");
}
```

---

## Methods Reference

### Public Methods

#### Reload()

```csharp
public void Reload()
```

Reloads the tree view from the root path based on the current `RootMode`.

**Behavior:**
- Clears all nodes
- Loads root nodes based on `RootMode`:
  - `Desktop`: Calls `LoadDesktopRoot()`
  - `Computer`: Calls `LoadComputerRoot()`
  - `Drives`: Calls `LoadDriveRoots()`
  - `CustomPath`: Calls `LoadCustomPath()`
- Does not clear icon cache (icons persist across reloads)

**Example:**
```csharp
// Refresh the tree view
fileSystemTreeView.Reload();
```

**When to Use:**
- After changing `RootMode` or `RootPath` programmatically
- To refresh the display after external file system changes
- After modifying `FileSystemTreeViewValues` properties directly

#### NavigateToPath(string path)

```csharp
public bool NavigateToPath(string path)
```

Navigates to the specified path in the tree view and selects it.

**Parameters:**
- `path` (string): The directory or file path to navigate to.

**Returns:**
- `true` if the path was found and selected; otherwise, `false`.

**Behavior:**
- Splits path into components
- Traverses tree nodes matching path components
- Expands nodes as needed (but doesn't force expansion of all parent nodes)
- Selects the target node and ensures it's visible
- Returns `false` if path doesn't exist or cannot be found in tree

**Example:**
```csharp
bool success = fileSystemTreeView.NavigateToPath(@"C:\Users\Public\Documents");
if (success)
{
    Console.WriteLine("Navigation successful");
}
else
{
    Console.WriteLine("Path not found in tree");
}
```

**Limitations:**
- Requires path to be already loaded in the tree (parent nodes must be expanded)
- May not work for paths under collapsed nodes
- For best results, ensure parent directories are expanded first

---

### Protected Methods

#### OnHandleCreated(EventArgs e)

```csharp
protected override void OnHandleCreated(EventArgs e)
```

Ensures initial population of the tree when the control is created.

**Behavior:**
- Calls base implementation
- Calls `Reload()` if not in design mode
- Ensures tree is populated when control becomes visible

**Usage:**
Override to add custom initialization logic.

#### OnDirectoryExpanding(DirectoryExpandingEventArgs e)

```csharp
protected virtual void OnDirectoryExpanding(DirectoryExpandingEventArgs e)
```

Raises the `DirectoryExpanding` event.

**Parameters:**
- `e`: A `DirectoryExpandingEventArgs` containing the event data.

**Usage:**
Override to add custom behavior before directory expansion.

#### OnDirectoryExpanded(DirectoryExpandedEventArgs e)

```csharp
protected virtual void OnDirectoryExpanded(DirectoryExpandedEventArgs e)
```

Raises the `DirectoryExpanded` event.

**Parameters:**
- `e`: A `DirectoryExpandedEventArgs` containing the event data.

**Usage:**
Override to add custom behavior after directory expansion.

#### OnFileSystemError(FileSystemErrorEventArgs e)

```csharp
protected virtual void OnFileSystemError(FileSystemErrorEventArgs e)
```

Raises the `FileSystemError` event.

**Parameters:**
- `e`: A `FileSystemErrorEventArgs` containing the event data.

**Usage:**
Override to add custom error handling or logging.

---

## Events Reference

### DirectoryExpanding

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when a directory is being expanded.")]
public event EventHandler<DirectoryExpandingEventArgs>? DirectoryExpanding;
```

Occurs when a directory is being expanded.

**Event Data:** `DirectoryExpandingEventArgs`
- `DirectoryPath` (string, read-only): The path of the directory being expanded
- `Cancel` (bool): Set to `true` to cancel the expansion

**Raised When:**
- User expands a directory node
- Before directory contents are loaded

**Example:**
```csharp
fileSystemTreeView.DirectoryExpanding += (sender, e) =>
{
    Console.WriteLine($"Expanding: {e.DirectoryPath}");
    
    // Optionally cancel expansion
    // e.Cancel = true;
};
```

**Use Cases:**
- Log directory access
- Validate permissions before loading
- Cancel expansion based on custom logic
- Show loading indicators

### DirectoryExpanded

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when a directory has been expanded.")]
public event EventHandler<DirectoryExpandedEventArgs>? DirectoryExpanded;
```

Occurs when a directory has been expanded or a node is selected.

**Event Data:** `DirectoryExpandedEventArgs`
- `Path` (string, read-only): The path that was expanded or selected

**Raised When:**
- Directory expansion completes
- Node is selected (via `AfterSelect` event)

**Example:**
```csharp
fileSystemTreeView.DirectoryExpanded += (sender, e) =>
{
    Console.WriteLine($"Expanded/Selected: {e.Path}");
};
```

**Use Cases:**
- Update status bar with current path
- Load related data based on selected directory
- Update other UI controls

### FileSystemError

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when an error occurs while loading the file system.")]
public event EventHandler<FileSystemErrorEventArgs>? FileSystemError;
```

Occurs when an error occurs while loading the file system.

**Event Data:** `FileSystemErrorEventArgs`
- `Path` (string, read-only): The path where the error occurred
- `Exception` (Exception, read-only): The exception that occurred

**Raised When:**
- Access denied when reading directory contents
- General exceptions during directory loading
- Drive access errors

**Example:**
```csharp
fileSystemTreeView.FileSystemError += (sender, e) =>
{
    MessageBox.Show(
        $"Error accessing {e.Path}:\n{e.Exception.Message}",
        "File System Error",
        MessageBoxButtons.OK,
        MessageBoxIcon.Warning
    );
};
```

**Common Exception Types:**
- `UnauthorizedAccessException`: Insufficient permissions
- `IOException`: General I/O errors
- `DirectoryNotFoundException`: Directory doesn't exist

---

## Related Classes

### FileSystemTreeViewValues

Groups file system-specific properties for PropertyGrid display.

**Location:** `Krypton.Utilities.FileSystemTreeViewValues`

**Properties:**
- `RootMode` (FileSystemRootMode)
- `RootPath` (string)
- `ShowFiles` (bool)
- `ShowHiddenFiles` (bool)
- `ShowSystemFiles` (bool)
- `FileFilter` (string)
- `ShowSpecialFolders` (bool)

**Features:**
- Expandable object converter for PropertyGrid
- Automatic `Reload()` on property changes
- Inherits from `Storage` base class

### FileSystemRootMode Enum

Specifies the root display mode for the file system tree view.

**Location:** `Krypton.Toolkit.FileSystemRootMode`

**Values:**
- `Desktop`: Desktop root with special folders and drives
- `Computer`: Computer root with all drives
- `Drives`: All drives as root nodes
- `CustomPath`: Custom root directory

### DirectoryExpandingEventArgs

Provides data for the `DirectoryExpanding` event.

**Location:** `Krypton.Toolkit.DirectoryExpandingEventArgs`

**Properties:**
- `DirectoryPath` (string, read-only): The path of the directory being expanded
- `Cancel` (bool): Set to `true` to cancel the expansion

**Inherits from:** `CancelEventArgs`

### DirectoryExpandedEventArgs

Provides data for the `DirectoryExpanded` event.

**Location:** `Krypton.Toolkit.DirectoryExpandedEventArgs`

**Properties:**
- `Path` (string, read-only): The path that was expanded or selected

### FileSystemErrorEventArgs

Provides data for the `FileSystemError` event.

**Location:** `Krypton.Toolkit.FileSystemErrorEventArgs`

**Properties:**
- `Path` (string, read-only): The path where the error occurred
- `Exception` (Exception, read-only): The exception that occurred

---

## Root Modes

### Desktop Mode

Displays Desktop as root with special folders (Computer, Network, Recycle Bin, etc.) and drives, similar to Windows Explorer.

**Structure:**
```
Desktop
├── Computer (CLSID: ::{20D04FE0-3AEA-1069-A2D8-08002B30309D})
│   └── [All Drives]
├── Control Panel (CLSID: ::{21EC2020-3AEA-1069-A2DD-08002B30309D})
├── My Documents
├── Shared Documents
├── Network (CLSID: ::{208D2C60-3AEA-1069-A2D7-08002B30309D})
├── Recycle Bin (CLSID: ::{645FF040-5081-101B-9F08-00AA002F954E})
└── [All Drives directly under Desktop]
```

**Special Folders:**
- Only shown when `ShowSpecialFolders` is `true`
- Computer CLSID expands to show all drives
- Other CLSID folders (Control Panel, Network, Recycle Bin) don't expand to file system contents

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.Desktop;
fileSystemTreeView.ShowSpecialFolders = true;
```

### Computer Mode

Displays Computer as root with all drives.

**Structure:**
```
Computer
├── C:\ (Local Disk)
├── D:\ (CD Drive)
├── E:\ (Removable Disk)
└── ...
```

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.Computer;
```

### Drives Mode (Default)

Displays all drives directly as root nodes.

**Structure:**
```
C:\ (Local Disk)
D:\ (CD Drive)
E:\ (Removable Disk)
...
```

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.Drives;
```

### CustomPath Mode

Uses the custom `RootPath` property to determine the root directory.

**Structure:**
```
[RootPath Directory]
├── [Subdirectories]
└── [Files]
```

**Behavior:**
- If `RootPath` is invalid or empty, falls back to `Drives` mode
- Root node is expanded by default

**Example:**
```csharp
fileSystemTreeView.RootMode = FileSystemRootMode.CustomPath;
fileSystemTreeView.RootPath = @"C:\Users";
```

---

## Icon Management

### Icon Extraction Process

1. **Cache Check**: First checks `_iconCache` dictionary
2. **Icon Extraction**:
   - **Directories**: Uses `FileSystemIconHelper.GetFolderIcon()`
   - **Files**: Uses `FileSystemIconHelper.GetFileIcon(extension)`
   - **Drives**: Uses `GetDriveIconIndex()` which maps drive types to stock icons
3. **Bitmap Conversion**: Converts `Icon` to `Bitmap` at ImageList size (16x16)
4. **ImageList Addition**: Adds bitmap to ImageList, forces handle creation
5. **Caching**: Stores index in cache dictionary

### Icon Cache

**Cache Key Format:**
- Directories: `"DIR"`
- Files: File extension (lowercase), e.g., `".txt"`
- Drives: `"DRIVE_{DriveType}"` (e.g., `"DRIVE_Fixed"`)
- Folder Open: `"DIR_OPEN"`

**Cache Benefits:**
- Avoids re-extracting icons for same file types
- Improves performance when displaying many files
- Reduces Windows Shell API calls

**Cache Management:**
- Not cleared on `Reload()` (icons persist)
- Dictionary uses case-insensitive string comparison

### Icon Sizes

- **Fixed Size**: 16x16 pixels (not configurable)
- **Large Icons**: Not supported (unlike `KryptonFileSystemListView`)

### Drive Icons

Drive icons are mapped based on `DriveType`:

- `DriveType.Fixed` → `StockIconHelper.StockIconId.DriveFixed`
- `DriveType.Network` → `StockIconHelper.StockIconId.DriveNetwork`
- `DriveType.CDRom` → `StockIconHelper.StockIconId.DriveCD`
- `DriveType.Removable` → `StockIconHelper.StockIconId.DriveRemove`
- `DriveType.Ram` → `StockIconHelper.StockIconId.DriveRAM`
- Default → `StockIconHelper.StockIconId.DriveFixed`

### Folder Open/Closed States

- **Closed Folder**: Standard folder icon (from `GetIconIndex()`)
- **Open Folder**: `StockIconHelper.StockIconId.FolderOpen` (set on `AfterExpand`)
- **Collapsed**: Resets to closed folder icon (on `BeforeCollapse`)

### Icon Fallback Strategy

The control implements a multi-tier fallback system:

1. **Primary**: Extract icon from actual file/folder path or extension
2. **Secondary**: Use generic folder icon or extension-based icon
3. **Tertiary**: Use Windows stock icons
4. **Final**: Use default icon (index 0) - blue bitmap

This ensures icons are always displayed, even when extraction fails.

---

## Usage Examples

### Basic Usage

```csharp
using Krypton.Utilities;

// Create control
KryptonFileSystemTreeView fileTreeView = new KryptonFileSystemTreeView();
fileTreeView.Dock = DockStyle.Fill;

// Add to form
this.Controls.Add(fileTreeView);
```

### Configure Root Mode

```csharp
// Desktop mode (Explorer-style)
fileTreeView.RootMode = FileSystemRootMode.Desktop;
fileTreeView.ShowSpecialFolders = true;

// Computer mode
fileTreeView.RootMode = FileSystemRootMode.Computer;

// Drives mode (default)
fileTreeView.RootMode = FileSystemRootMode.Drives;

// Custom path mode
fileTreeView.RootMode = FileSystemRootMode.CustomPath;
fileTreeView.RootPath = @"C:\Users";
```

### Configure Display Options

```csharp
// Hide files, show only directories
fileTreeView.ShowFiles = false;

// Show hidden and system files
fileTreeView.ShowHiddenFiles = true;
fileTreeView.ShowSystemFiles = true;

// Filter files
fileTreeView.FileFilter = "*.exe;*.dll";
```

### Handle Events

```csharp
// Directory expanding event
fileTreeView.DirectoryExpanding += (sender, e) =>
{
    statusLabel.Text = $"Loading: {e.DirectoryPath}";
    
    // Optionally cancel expansion
    // if (someCondition) e.Cancel = true;
};

// Directory expanded event
fileTreeView.DirectoryExpanded += (sender, e) =>
{
    statusLabel.Text = $"Current: {e.Path}";
};

// File system error event
fileTreeView.FileSystemError += (sender, e) =>
{
    if (e.Exception is UnauthorizedAccessException)
    {
        MessageBox.Show($"Access denied: {e.Path}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
    }
    else
    {
        MessageBox.Show($"Error: {e.Exception.Message}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
    }
};
```

### Get Selected Path

```csharp
// Handle selection change
fileTreeView.AfterSelect += (sender, e) =>
{
    string? selectedPath = fileTreeView.SelectedPath;
    if (!string.IsNullOrEmpty(selectedPath))
    {
        if (Directory.Exists(selectedPath))
        {
            Console.WriteLine($"Selected folder: {selectedPath}");
        }
        else if (File.Exists(selectedPath))
        {
            FileInfo fileInfo = new FileInfo(selectedPath);
            Console.WriteLine($"Selected file: {selectedPath} ({fileInfo.Length} bytes)");
        }
    }
};
```

### Navigate to Path

```csharp
// Navigate to a specific path
bool success = fileTreeView.NavigateToPath(@"C:\Users\Public\Documents");
if (success)
{
    Console.WriteLine("Navigation successful");
}
else
{
    Console.WriteLine("Path not found - ensure parent directories are expanded");
}
```

### Integration with File System ListView

```csharp
// Synchronize TreeView selection with ListView
fileTreeView.AfterSelect += (sender, e) =>
{
    string? selectedPath = fileTreeView.SelectedPath;
    if (!string.IsNullOrEmpty(selectedPath) && Directory.Exists(selectedPath))
    {
        fileListView.NavigateTo(selectedPath);
    }
};
```

---

## Best Practices

### 1. Error Handling

Always handle the `FileSystemError` event:

```csharp
fileTreeView.FileSystemError += (sender, e) =>
{
    // Log error
    Logger.LogError($"File system error at {e.Path}: {e.Exception}");
    
    // Show user-friendly message
    if (e.Exception is UnauthorizedAccessException)
    {
        // Handle access denied gracefully
    }
};
```

### 2. Performance Considerations

- **Lazy Loading**: The control uses lazy loading by default. Directories are only loaded when expanded.
- **Large Directories**: For directories with thousands of items, consider:
  - Using file filters to limit displayed items
  - Showing directories only (`ShowFiles = false`)
  - Implementing custom virtual mode (not currently supported)

### 3. Root Mode Selection

Choose the appropriate root mode for your use case:
- **Desktop**: For Explorer-like interfaces
- **Computer**: For drive-focused browsing
- **Drives**: For simple drive listing (default)
- **CustomPath**: For application-specific root directories

### 4. Thread Safety

File system operations should be performed on the UI thread:

```csharp
// Correct: On UI thread
fileTreeView.Reload();

// If loading from background thread:
this.Invoke(new Action(() => fileTreeView.Reload()));
```

### 5. Property Changes

Properties automatically trigger `Reload()`. Avoid calling `Reload()` manually after property changes:

```csharp
// Correct: Reload happens automatically
fileTreeView.RootMode = FileSystemRootMode.Desktop;

// Incorrect: Unnecessary reload
fileTreeView.RootMode = FileSystemRootMode.Desktop;
fileTreeView.Reload(); // Not needed
```

### 6. NavigateToPath Limitations

`NavigateToPath()` requires parent nodes to be expanded. For best results:

```csharp
// Expand parent nodes first
TreeNode? parentNode = FindNodeByPath(fileTreeView.Nodes, @"C:\Users");
if (parentNode != null)
{
    parentNode.Expand();
    fileTreeView.NavigateToPath(@"C:\Users\Public\Documents");
}
```

### 7. Special Folders

Special folders (Computer, Network, etc.) use CLSIDs and may not expand to file system contents. Handle these cases:

```csharp
fileTreeView.DirectoryExpanding += (sender, e) =>
{
    if (e.DirectoryPath.StartsWith("::", StringComparison.Ordinal))
    {
        // Handle special folder CLSID
        // Most special folders don't expand to file system contents
    }
};
```

---

## Known Limitations

### 1. Fixed Icon Size

Icon size is fixed at 16x16 pixels. Unlike `KryptonFileSystemListView`, there's no `UseLargeIcons` property.

### 2. NavigateToPath Requires Expanded Parents

`NavigateToPath()` may fail if parent directories are not already expanded. The method doesn't automatically expand parent nodes.

### 3. Special Folders Don't Expand

Most special folders (Control Panel, Network, Recycle Bin) use CLSIDs and don't expand to show file system contents. Only Computer expands to show drives.

### 4. No Virtual Mode

The control does not support virtual mode. All nodes are loaded into memory. For very large directory trees, performance may degrade.

### 5. File Filter Limitations

The filter uses `Directory.GetFiles()` which supports simple wildcard patterns. Complex regex patterns are not supported.

### 6. No Custom Sorting

Sorting is handled by the base `TreeView` control. Custom sort comparers can be implemented via `TreeViewNodeSorter` property.

### 7. Dummy Nodes Visible in Some Scenarios

Dummy nodes are hidden via `DrawNode` event, but may be visible in certain edge cases or custom drawing scenarios.

### 8. Icon Cache Not Cleared on Reload

Icon cache persists across `Reload()` calls. This improves performance but may show stale icons if file associations change.

### 9. Drive Labels May Be Incomplete

Drive labels are formatted as `"{VolumeLabel} ({Path})"` or `"{Path} ({DriveType})"`. If volume label cannot be read, drive type is shown instead.

### 10. No Drag-and-Drop Support

Drag-and-drop is not implemented. Can be added via standard WinForms drag-and-drop events.

---

## Troubleshooting

### Issue: Tree Not Loading

**Symptoms:** Tree view appears empty after creation.

**Solutions:**
- Ensure control handle is created (control is visible)
- Check `RootMode` and `RootPath` settings
- Handle `FileSystemError` event for underlying issues
- Verify `OnHandleCreated` is called (not in design mode)

### Issue: Icons Not Displaying

**Symptoms:** Icons appear as default/gray icons or not at all.

**Solutions:**
- Check Windows Shell API availability
- Verify icon extraction permissions
- Check `FileSystemError` event for underlying issues
- Ensure proper disposal of icon resources

### Issue: Performance Degradation with Large Directories

**Symptoms:** Slow expansion or UI freezing with large directories.

**Solutions:**
- Use file filters to limit displayed items
- Set `ShowFiles = false` to show directories only
- Consider implementing background loading (requires custom implementation)
- Use lazy loading (already implemented by default)

### Issue: NavigateToPath Fails

**Symptoms:** `NavigateToPath()` returns `false` even for valid paths.

**Solutions:**
- Ensure parent directories are expanded first
- Verify path exists: `Directory.Exists(path) || File.Exists(path)`
- Check path format (use `Path.GetFullPath()` if needed)
- Handle case sensitivity (paths are compared case-insensitively)

### Issue: Special Folders Don't Expand

**Symptoms:** Computer, Network, Recycle Bin don't show contents.

**Solutions:**
- This is expected behavior for most special folders
- Only Computer expands to show drives
- Other CLSID folders don't have file system children
- Consider hiding special folders if not needed: `ShowSpecialFolders = false`

### Issue: Access Denied Errors

**Symptoms:** `FileSystemError` event raised with `UnauthorizedAccessException`.

**Solutions:**
- Handle `FileSystemError` event gracefully
- Check user permissions
- Use `ShowHiddenFiles` and `ShowSystemFiles` appropriately
- Consider running with elevated permissions if needed

### Issue: Drive Icons Wrong

**Symptoms:** Drive icons don't match drive types.

**Solutions:**
- Verify `DriveInfo.DriveType` is correct
- Check icon cache (may need to clear manually)
- Ensure `StockIconHelper` is working correctly

### Issue: Folder Open/Closed Icons Not Updating

**Symptoms:** Folder icons don't change when expanded/collapsed.

**Solutions:**
- Verify `AfterExpand` and `BeforeCollapse` events are firing
- Check that `GetFolderOpenIconIndex()` returns valid index
- Ensure ImageList contains open folder icon

---

## Additional Resources

### Related Controls

- **KryptonFileSystemListView**: List view version of file system browser
- **KryptonSystemTreeView**: Simplified version starting from all drives
- **KryptonTreeView**: Base TreeView control with Krypton styling

### Windows API Dependencies

- **Shell32.dll**: Icon extraction (`SHGetFileInfo`)
- **User32.dll**: Icon destruction (`DestroyIcon`)

### Source Code Location

```
Source/Krypton Components/Krypton.Utilities/KryptonFileSystemTreeView/
├── Controls Toolkit/
│   └── KryptonFileSystemTreeView.cs
└── Values/
    └── FileSystemTreeViewValues.cs
```