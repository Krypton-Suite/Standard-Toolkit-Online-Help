# KryptonSystemTreeView

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
10. [Icon Management](#icon-management)
11. [Best Practices](#best-practices)
12. [Known Limitations](#known-limitations)
13. [Troubleshooting](#troubleshooting)

---

## Overview

`KryptonSystemTreeView` is a simplified WinForms TreeView control that provides a hierarchical file system browser starting from all available drives. It extends `KryptonTreeView` to provide a Krypton-styled file browser that always displays drives as root nodes, without the complexity of multiple root modes found in `KryptonFileSystemTreeView`.

### Key Capabilities

- **Drive-Based Root**: Always starts from all available drives
- **Hierarchical Navigation**: Expandable tree structure for browsing directories
- **Native Icon Support**: Displays Windows shell icons for files, folders, and drives
- **File Filtering**: Filter files by extension patterns
- **Hidden/System File Control**: Toggle visibility of hidden and system files
- **Lazy Loading**: Directories are loaded on-demand when expanded
- **Icon Caching**: Efficient icon caching to improve performance
- **Large Icon Support**: Configurable icon size (16x16 or 32x32)
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
                      └─ Krypton.Utilities.KryptonSystemTreeView
```

### Comparison with KryptonFileSystemTreeView

| Feature | KryptonSystemTreeView | KryptonFileSystemTreeView |
|---------|----------------------|--------------------------|
| Root Modes | Fixed (Drives only) | Multiple (Desktop, Computer, Drives, CustomPath) |
| Special Folders | No | Yes (Desktop mode) |
| Icon Size | Configurable (16x16 or 32x32) | Fixed (16x16) |
| Complexity | Simpler | More complex |
| Use Case | Simple drive-based browsing | Explorer-like interfaces |

---

## Features

### Core Features

1. **Drive-Based Root**
   - Always displays all available drives as root nodes
   - Drive labels include volume name or drive type
   - Drive-specific icons (Fixed, Removable, CD-ROM, Network, RAM)

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
   - Configurable icon size (16x16 or 32x32)
   - Fallback icon system for missing icons

5. **Filtering Options**
   - Show/hide files
   - Show/hide hidden files
   - Show/hide system files
   - File extension filtering (e.g., "*.txt", "*.txt;*.doc")

6. **Error Handling**
   - File system error events
   - Graceful handling of access denied errors
   - Directory not found handling

---

## Architecture

### Component Structure

```
KryptonSystemTreeView
├── SystemTreeViewValues (expandable properties)
│   ├── ShowFiles (bool)
│   ├── ShowHiddenFiles (bool)
│   ├── ShowSystemFiles (bool)
│   ├── FileFilter (string)
│   └── UseLargeIcons (bool)
├── ImageList (icon storage)
├── IconCache (Dictionary<string, int>)
├── Dummy Nodes (for lazy loading)
└── Event Handlers
    └── FileSystemError
```

### Key Components

1. **SystemTreeViewValues**: Groups system tree view-specific properties in an expandable PropertyGrid object
2. **ImageList**: Stores icons for display (16x16 or 32x32 pixels, configurable)
3. **IconCache**: Dictionary caching icon indices by file extension, directory marker, or drive type
4. **Dummy Nodes**: Hidden placeholder nodes (`"__DUMMY__"`) used to enable expansion without pre-loading children
5. **Helper Classes**:
   - `FileSystemIconHelper`: Extracts icons from Windows Shell
   - `StockIconHelper`: Provides fallback stock icons

### Data Flow

1. **Initialization**: Constructor → Create ImageList → `AddDefaultIcon()` → `Reload()` → Load all drives
2. **Expansion**: User expands node → `OnBeforeExpand()` → Check for dummy node → `LoadDirectoryNodes()` → Replace dummy with real nodes
3. **Icon Loading**: `GetIconIndex()` → Check cache → Extract icon → Add to ImageList → Cache index
4. **Property Changes**: Property setter → `Reload()` → Refresh display

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
[DefaultProperty(nameof(SystemTreeViewValues))]
[DesignerCategory(@"code")]
[Description(@"Displays a hierarchical file system tree starting from all drives with folder and file icons.")]
[Docking(DockingBehavior.Ask)]
public class KryptonSystemTreeView : KryptonTreeView
```

### Constructor

```csharp
public KryptonSystemTreeView()
```

Initializes a new instance with default settings:
- Show files: `true`
- Show hidden files: `false`
- Show system files: `false`
- File filter: `"*.*"`
- Use large icons: `false` (16x16 pixels)
- Show plus/minus: `true`
- Show root lines: `true`
- Show lines: `true`
- Automatically calls `Reload()` to load all drives

---

## Properties Reference

### Public Properties

#### SystemTreeViewValues

```csharp
public SystemTreeViewValues SystemTreeViewValues { get; }
```

Gets the system TreeView values object containing all system tree view-specific properties. This is an expandable object that groups related properties for better PropertyGrid organization.

**Access Pattern:**
```csharp
systemTreeView.SystemTreeViewValues.ShowFiles = true;
systemTreeView.SystemTreeViewValues.UseLargeIcons = true;
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
string? selectedPath = systemTreeView.SelectedPath;
if (!string.IsNullOrEmpty(selectedPath))
{
    Console.WriteLine($"Selected: {selectedPath}");
}
```

#### IconCache (Internal)

```csharp
internal Dictionary<string, int> IconCache { get; }
```

Gets the internal icon cache dictionary. Keys are file extensions (lowercase), `"__DIRECTORY__"` for folders, or `"__DRIVE_{DriveType}__"` for drives. Values are ImageList indices.

**Note:** This property is internal and primarily used by the control itself.

---

### SystemTreeViewValues Properties

All system tree view properties are accessed through the `SystemTreeViewValues` property:

#### ShowFiles

```csharp
public bool ShowFiles { get; set; }
```

Gets or sets a value indicating whether files should be displayed in the tree view.

- **Type**: `bool`
- **Default**: `true`
- **Category**: Behavior
- **Description**: Indicates whether files should be displayed in the tree view.

**Behavior:**
- When `false`, only directories are displayed
- Changing this property triggers `Reload()`

**Example:**
```csharp
// Show only directories
systemTreeView.SystemTreeViewValues.ShowFiles = false;
```

#### ShowHiddenFiles

```csharp
public bool ShowHiddenFiles { get; set; }
```

Gets or sets a value indicating whether hidden files should be displayed.

- **Type**: `bool`
- **Default**: `false`
- **Category**: Behavior
- **Description**: Indicates whether hidden files should be displayed.

**Behavior:**
- Files and folders with `FileAttributes.Hidden` are filtered based on this setting
- Changing this property triggers `Reload()`

**Example:**
```csharp
systemTreeView.SystemTreeViewValues.ShowHiddenFiles = true;
```

#### ShowSystemFiles

```csharp
public bool ShowSystemFiles { get; set; }
```

Gets or sets a value indicating whether system files should be displayed.

- **Type**: `bool`
- **Default**: `false`
- **Category**: Behavior
- **Description**: Indicates whether system files should be displayed.

**Behavior:**
- Files and folders with `FileAttributes.System` are filtered based on this setting
- Changing this property triggers `Reload()`

**Example:**
```csharp
systemTreeView.SystemTreeViewValues.ShowSystemFiles = true;
```

#### FileFilter

```csharp
public string FileFilter { get; set; }
```

Gets or sets the file filter to apply when showing files.

- **Type**: `string`
- **Default**: `"*.*"` (all files)
- **Category**: Behavior
- **Description**: The file filter to apply when showing files (e.g., "*.txt" or "*.txt;*.doc").

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
systemTreeView.SystemTreeViewValues.FileFilter = "*.txt";

// Show multiple file types
systemTreeView.SystemTreeViewValues.FileFilter = "*.txt;*.doc;*.pdf";

// Show all files
systemTreeView.SystemTreeViewValues.FileFilter = "*.*";
```

#### UseLargeIcons

```csharp
public bool UseLargeIcons { get; set; }
```

Gets or sets a value indicating whether to use large icons (32x32) instead of small icons (16x16).

- **Type**: `bool`
- **Default**: `false` (16x16 icons)
- **Category**: Appearance
- **Description**: Indicates whether to use large icons (32x32) instead of small icons (16x16).

**Behavior:**
- When `true`, ImageList size is set to 32x32 pixels
- When `false`, ImageList size is set to 16x16 pixels
- Changing this property clears the icon cache and reloads icons
- Icons are re-extracted at the new size
- Triggers `Reload()` to refresh display

**Example:**
```csharp
systemTreeView.SystemTreeViewValues.UseLargeIcons = true;
```

---

## Methods Reference

### Public Methods

#### Reload()

```csharp
public void Reload()
```

Reloads the tree view with all available drives.

**Behavior:**
- Clears all nodes, icon cache, and ImageList images
- Adds default folder icon
- Loads all available drives as root nodes
- Shows drives even if not ready (e.g., CD-ROM without disc)
- Raises `FileSystemError` event for individual drive errors

**Example:**
```csharp
// Refresh the tree view
systemTreeView.Reload();
```

**When to Use:**
- After changing filter or visibility settings programmatically
- To refresh the display after external file system changes
- After modifying `SystemTreeViewValues` properties directly
- After drive changes (e.g., USB drive inserted/removed)

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
- Matches nodes by name or full path
- Expands nodes as needed (but doesn't force expansion of all parent nodes)
- Selects the target node and ensures it's visible
- Returns `false` if path doesn't exist or cannot be found in tree

**Example:**
```csharp
bool success = systemTreeView.NavigateToPath(@"C:\Users\Public\Documents");
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

### Internal Methods

#### AddDefaultIcon()

```csharp
internal void AddDefaultIcon()
```

Adds a default folder icon to the image list.

**Behavior:**
- Attempts to get stock folder icon via `StockIconHelper`
- Falls back to a simple gray bitmap if icon retrieval fails
- Creates bitmap at current ImageList size (16x16 or 32x32)
- Adds icon at index 0 (used as fallback)

**When Called:**
- Automatically called during construction
- Called when `UseLargeIcons` changes
- Called during `Reload()` to reset icon list

---

## Events Reference

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
- Drive access errors during `Reload()`

**Example:**
```csharp
systemTreeView.FileSystemError += (sender, e) =>
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

### SystemTreeViewValues

Groups system tree view-specific properties for PropertyGrid display.

**Location:** `Krypton.Utilities.SystemTreeViewValues`

**Properties:**
- `ShowFiles` (bool)
- `ShowHiddenFiles` (bool)
- `ShowSystemFiles` (bool)
- `FileFilter` (string)
- `UseLargeIcons` (bool)

**Features:**
- Expandable object converter for PropertyGrid
- Automatic `Reload()` on property changes
- Inherits from `Storage` base class

### FileSystemErrorEventArgs

Provides data for the `FileSystemError` event.

**Location:** `Krypton.Toolkit.FileSystemErrorEventArgs`

**Properties:**
- `Path` (string, read-only): The path where the error occurred
- `Exception` (Exception, read-only): The exception that occurred

**Constructor:**
```csharp
public FileSystemErrorEventArgs(string path, Exception exception)
```

### FileSystemIconHelper

Helper class for extracting file and folder icons from Windows Shell.

**Location:** `Krypton.Toolkit.FileSystemIconHelper` (internal)

**Methods:**
- `GetFileSystemIcon(string path, bool largeIcon)`: Gets icon for file/folder
- `GetFolderIcon(bool largeIcon)`: Gets generic folder icon
- `GetFileIcon(string extension, bool largeIcon)`: Gets icon for file extension

**Implementation:**
- Uses Windows Shell API (`SHGetFileInfo`)
- Returns disposable `Icon` objects
- Returns `null` on failure

### StockIconHelper

Provides fallback stock icons when file-specific icons cannot be retrieved.

**Location:** `Krypton.Toolkit.StockIconHelper`

**Methods:**
- `GetStockIcon(StockIconId stockIconId)`: Gets a stock Windows icon

**Common Stock Icons:**
- `Folder`: Generic folder icon
- `DocumentNotAssociated`: Generic document icon
- `DriveFixed`: Fixed drive icon
- `DriveRemove`: Removable drive icon
- `DriveCD`: CD-ROM drive icon
- `DriveNetwork`: Network drive icon

---

## Icon Management

### Icon Extraction Process

1. **Cache Check**: First checks `_iconCache` dictionary
2. **Icon Extraction**:
   - **Directories**: Tries `FileSystemIconHelper.GetFileSystemIcon()` → `GetFolderIcon()` → `StockIconHelper.GetStockIcon(Folder)`
   - **Files**: Tries `GetFileSystemIcon()` → `GetFileIcon(extension)` → `StockIconHelper.GetStockIcon(DocumentNotAssociated)`
   - **Drives**: Uses `GetDriveIconIndex()` which tries actual drive path → drive type stock icon → folder icon
3. **Bitmap Conversion**: Converts `Icon` to `Bitmap` at ImageList size (16x16 or 32x32)
4. **ImageList Addition**: Adds bitmap to ImageList, forces handle creation
5. **Caching**: Stores index in cache dictionary

### Icon Cache

**Cache Key Format:**
- Directories: `"__DIRECTORY__"`
- Files: File extension (lowercase), e.g., `".txt"`
- Files without extension: `"__FILE__"`
- Drives: `"__DRIVE_{DriveType}__"` (e.g., `"__DRIVE_Fixed__"`)

**Cache Benefits:**
- Avoids re-extracting icons for same file types
- Improves performance when displaying many files
- Reduces Windows Shell API calls

**Cache Management:**
- Cleared on `Reload()`
- Cleared when `UseLargeIcons` changes
- Dictionary uses case-insensitive string comparison

### Icon Sizes

- **Small Icons**: 16x16 pixels (default)
- **Large Icons**: 32x32 pixels (when `UseLargeIcons = true`)

**Changing Icon Size:**
Setting `UseLargeIcons` automatically:
1. Updates ImageList size
2. Clears icon cache
3. Clears ImageList images
4. Adds new default icon
5. Reloads tree with new icon size

### Drive Icons

Drive icons are determined with fallback strategy:

1. **Primary**: Try to get icon from actual drive root path
2. **Secondary**: Use drive type stock icon:
   - `DriveType.Fixed` → `StockIconHelper.StockIconId.DriveFixed`
   - `DriveType.Removable` → `StockIconHelper.StockIconId.DriveRemove`
   - `DriveType.CDRom` → `StockIconHelper.StockIconId.DriveCD`
   - `DriveType.Network` → `StockIconHelper.StockIconId.DriveNetwork`
   - Default → `StockIconHelper.StockIconId.DriveFixed`
3. **Tertiary**: Use folder icon
4. **Final**: Use default icon (index 0)

### Icon Fallback Strategy

The control implements a multi-tier fallback system:

1. **Primary**: Extract icon from actual file/folder path or extension
2. **Secondary**: Use generic folder icon or extension-based icon
3. **Tertiary**: Use Windows stock icons
4. **Final**: Use default icon (index 0) - gray bitmap

This ensures icons are always displayed, even when extraction fails.

---

## Usage Examples

### Basic Usage

```csharp
using Krypton.Utilities;

// Create control
KryptonSystemTreeView systemTreeView = new KryptonSystemTreeView();
systemTreeView.Dock = DockStyle.Fill;

// Add to form
this.Controls.Add(systemTreeView);
```

### Configure Display Options

```csharp
// Hide files, show only directories
systemTreeView.SystemTreeViewValues.ShowFiles = false;

// Show hidden and system files
systemTreeView.SystemTreeViewValues.ShowHiddenFiles = true;
systemTreeView.SystemTreeViewValues.ShowSystemFiles = true;

// Filter files
systemTreeView.SystemTreeViewValues.FileFilter = "*.exe;*.dll";

// Use large icons
systemTreeView.SystemTreeViewValues.UseLargeIcons = true;
```

### Handle Events

```csharp
// File system error event
systemTreeView.FileSystemError += (sender, e) =>
{
    if (e.Exception is UnauthorizedAccessException)
    {
        MessageBox.Show($"Access denied: {e.Path}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
    }
    else if (e.Exception is DirectoryNotFoundException)
    {
        MessageBox.Show($"Directory not found: {e.Path}", "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
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
systemTreeView.AfterSelect += (sender, e) =>
{
    string? selectedPath = systemTreeView.SelectedPath;
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
bool success = systemTreeView.NavigateToPath(@"C:\Users\Public\Documents");
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
systemTreeView.AfterSelect += (sender, e) =>
{
    string? selectedPath = systemTreeView.SelectedPath;
    if (!string.IsNullOrEmpty(selectedPath) && Directory.Exists(selectedPath))
    {
        fileListView.NavigateTo(selectedPath);
    }
};
```

### Refresh After Drive Changes

```csharp
// Refresh tree when drives change (e.g., USB inserted)
private void OnDriveChanged(object sender, EventArgs e)
{
    systemTreeView.Reload();
}
```

---

## Best Practices

### 1. Error Handling

Always handle the `FileSystemError` event:

```csharp
systemTreeView.FileSystemError += (sender, e) =>
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

### 3. Icon Size Selection

Choose appropriate icon size based on use case:
- **Small Icons (16x16)**: Default, better for dense displays, faster loading
- **Large Icons (32x32)**: Better visibility, more modern appearance, slower loading

### 4. Thread Safety

File system operations should be performed on the UI thread:

```csharp
// Correct: On UI thread
systemTreeView.Reload();

// If loading from background thread:
this.Invoke(new Action(() => systemTreeView.Reload()));
```

### 5. Property Changes

Properties automatically trigger `Reload()`. Avoid calling `Reload()` manually after property changes:

```csharp
// Correct: Reload happens automatically
systemTreeView.SystemTreeViewValues.ShowFiles = false;

// Incorrect: Unnecessary reload
systemTreeView.SystemTreeViewValues.ShowFiles = false;
systemTreeView.Reload(); // Not needed
```

### 6. NavigateToPath Limitations

`NavigateToPath()` requires parent nodes to be expanded. For best results:

```csharp
// Expand parent nodes first
TreeNode? parentNode = FindNodeByPath(systemTreeView.Nodes, @"C:\Users");
if (parentNode != null)
{
    parentNode.Expand();
    systemTreeView.NavigateToPath(@"C:\Users\Public\Documents");
}
```

### 7. Drive Changes

Handle drive insertion/removal by calling `Reload()`:

```csharp
// Monitor for drive changes
ManagementEventWatcher watcher = new ManagementEventWatcher(
    new WqlEventQuery("SELECT * FROM Win32_VolumeChangeEvent"));
watcher.EventArrived += (sender, e) => 
{
    this.Invoke(new Action(() => systemTreeView.Reload()));
};
watcher.Start();
```

---

## Known Limitations

### 1. Fixed Root Mode

The control always starts from drives. Unlike `KryptonFileSystemTreeView`, there's no option for Desktop, Computer, or CustomPath modes.

### 2. NavigateToPath Requires Expanded Parents

`NavigateToPath()` may fail if parent directories are not already expanded. The method doesn't automatically expand parent nodes.

### 3. No Virtual Mode

The control does not support virtual mode. All nodes are loaded into memory. For very large directory trees, performance may degrade.

### 4. File Filter Limitations

The filter uses `Directory.GetFiles()` which supports simple wildcard patterns. Complex regex patterns are not supported.

### 5. No Custom Sorting

Sorting is handled by the base `TreeView` control. Custom sort comparers can be implemented via `TreeViewNodeSorter` property.

### 6. Dummy Nodes Visible in Some Scenarios

Dummy nodes are hidden via `DrawNode` event, but may be visible in certain edge cases or custom drawing scenarios.

### 7. Icon Cache Cleared on Reload

Icon cache is cleared on `Reload()`, which may cause slower initial display after reload.

### 8. Drive Labels May Be Incomplete

Drive labels are formatted as `"{Name} ({VolumeLabel})"` or `"{Name} {DriveType}"`. If volume label cannot be read, drive type is shown instead.

### 9. No Drag-and-Drop Support

Drag-and-drop is not implemented. Can be added via standard WinForms drag-and-drop events.

### 10. No Directory Expansion Events

Unlike `KryptonFileSystemTreeView`, there are no `DirectoryExpanding` or `DirectoryExpanded` events. Only `FileSystemError` event is available.

---

## Troubleshooting

### Issue: Tree Not Loading

**Symptoms:** Tree view appears empty after creation.

**Solutions:**
- Ensure control handle is created (control is visible)
- Check that drives are available (`DriveInfo.GetDrives()`)
- Handle `FileSystemError` event for underlying issues
- Verify constructor calls `Reload()` (should happen automatically)

### Issue: Icons Not Displaying

**Symptoms:** Icons appear as default/gray icons or not at all.

**Solutions:**
- Check Windows Shell API availability
- Verify `UseLargeIcons` setting matches desired size
- Check icon extraction permissions
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
- Check icon cache (cleared on `Reload()`)
- Ensure `StockIconHelper` is working correctly
- Try calling `Reload()` to refresh icons

### Issue: Icon Size Not Changing

**Symptoms:** Icons remain same size after changing `UseLargeIcons`.

**Solutions:**
- Verify `UseLargeIcons` property is set correctly
- Ensure `Reload()` is called (should happen automatically)
- Check that ImageList size is updated
- Clear icon cache manually if needed

### Issue: Drives Not Showing

**Symptoms:** No drives appear in tree view.

**Solutions:**
- Check that drives are available: `DriveInfo.GetDrives().Length > 0`
- Handle `FileSystemError` event for drive access errors
- Verify user has permissions to enumerate drives
- Try calling `Reload()` manually

---

## Additional Resources

### Related Controls

- **[KryptonFileSystemTreeView](KryptonFileSystemTreeView.md)**: More advanced version with multiple root modes
- **[KryptonFileSystemListView](KryptonFileSystemListView.md)**: List view version of file system browser
- **[KryptonTreeView](../Toolkit/Controls/KryptonTreeView.md)**: Base TreeView control with Krypton styling

### Windows API Dependencies

- **Shell32.dll**: Icon extraction (`SHGetFileInfo`)
- **User32.dll**: Icon destruction (`DestroyIcon`)