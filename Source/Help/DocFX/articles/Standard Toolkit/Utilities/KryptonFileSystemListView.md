# KryptonFileSystemListView

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

`KryptonFileSystemListView` is a specialized WinForms ListView control that provides a file system browser interface with native Windows icons, file type detection, and comprehensive file system navigation capabilities. It extends `KryptonListView` to provide a Krypton-styled, feature-rich file browser component.

### Key Capabilities

- **File System Navigation**: Browse directories with double-click navigation
- **Native Icon Support**: Displays Windows shell icons for files and folders
- **File Filtering**: Filter files by extension patterns
- **Hidden/System File Control**: Toggle visibility of hidden and system files
- **Column Details View**: Shows Name, Type, Size, and Date Modified columns
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
              └─ System.Windows.Forms.ListView
                  └─ Krypton.Toolkit.KryptonListView
                      └─ Krypton.Utilities.KryptonFileSystemListView
```

---

## Features

### Core Features

1. **Directory Navigation**
   - Navigate to any directory path
   - Double-click folders to navigate into them
   - Parent directory navigation via ".." item
   - Automatic path validation

2. **File Display**
   - Display files and folders with proper icons
   - File type detection and description
   - File size formatting (B, KB, MB, GB, TB)
   - Last modified date display
   - Configurable file filtering

3. **Icon Management**
   - Windows shell icon extraction
   - Icon caching for performance
   - Support for both small (16x16) and large (32x32) icons
   - Fallback icon system for missing icons

4. **View Modes**
   - Details view (default) with columns
   - Support for other ListView view modes
   - Auto-resize columns functionality

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
KryptonFileSystemListView
├── FileSystemListViewValues (expandable properties)
│   ├── CurrentPath
│   ├── ShowFiles
│   ├── ShowHiddenFiles
│   ├── ShowSystemFiles
│   ├── FileFilter
│   └── UseLargeIcons
├── ImageList (icon storage)
├── IconCache (Dictionary<string, int>)
└── Event Handlers
    ├── PathChanged
    └── FileSystemError
```

### Key Components

1. **FileSystemListViewValues**: Groups file system-specific properties in an expandable PropertyGrid object
2. **ImageList**: Stores icons for display (16x16 or 32x32 pixels)
3. **IconCache**: Dictionary caching icon indices by file extension or directory marker
4. **Helper Classes**:
   - `FileSystemIconHelper`: Extracts icons from Windows shell
   - `StockIconHelper`: Provides fallback stock icons
   - `KryptonFileSystemListViewStrings`: Localizable string resources

### Data Flow

1. **Navigation**: `NavigateTo(path)` → `Reload()` → `LoadDirectory()` → `CreateDirectoryItem()` / `CreateFileItem()`
2. **Icon Loading**: `GetIconIndex()` → Check cache → Extract icon → Add to ImageList → Cache index
3. **Property Changes**: Property setter → `Reload()` → Refresh display

---

## API Reference

### Class Declaration

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(KryptonListView))]
[DefaultEvent(nameof(SelectedIndexChanged))]
[DefaultProperty(nameof(FileSystemListViewValues.CurrentPath))]
[DesignerCategory(@"code")]
[Description(@"Displays a file system list with folder and file icons.")]
[Docking(DockingBehavior.Ask)]
public class KryptonFileSystemListView : KryptonListView
```

### Constructor

```csharp
public KryptonFileSystemListView()
```

Initializes a new instance with default settings:
- View mode: Details
- FullRowSelect: true
- GridLines: true
- AllowColumnReorder: true
- Icon size: 16x16 (small icons)
- Default columns: Name, Type, Size, Date Modified

---

## Properties Reference

### Public Properties

#### FileSystemListViewValues

```csharp
public FileSystemListViewValues FileSystemListViewValues { get; }
```

Gets the file system ListView values object containing all file system-specific properties. This is an expandable object that groups related properties for better PropertyGrid organization.

**Access Pattern:**
```csharp
fileSystemListView.FileSystemListViewValues.CurrentPath = @"C:\Users";
fileSystemListView.FileSystemListViewValues.ShowFiles = true;
fileSystemListView.FileSystemListViewValues.FileFilter = "*.txt;*.doc";
```

#### View (Overridden)

```csharp
[DefaultValue(View.Details)]
public new View View { get; set; }
```

Gets or sets how items are displayed in the control. When set to `View.Details`, columns are automatically set up if they don't exist.

**Supported Values:**
- `View.Details` (default): Shows columns with file information
- `View.LargeIcon`: Large icon view
- `View.SmallIcon`: Small icon view
- `View.List`: List view
- `View.Tile`: Tile view

**Note:** Columns are only created/used in Details view.

#### IconCache (Internal)

```csharp
internal Dictionary<string, int> IconCache { get; }
```

Gets the internal icon cache dictionary. Keys are file extensions (lowercase) or `"__DIRECTORY__"` for folders. Values are ImageList indices.

**Note:** This property is internal and primarily used by the control itself.

---

### FileSystemListViewValues Properties

All file system properties are accessed through the `FileSystemListViewValues` property:

#### CurrentPath

```csharp
public string CurrentPath { get; set; }
```

Gets or sets the current directory path to display in the list view.

- **Type**: `string`
- **Default**: `""` (empty string)
- **Category**: Behavior
- **Description**: The current directory path to display in the list view.

**Behavior:**
- Setting this property automatically calls `Reload()` to refresh the display
- Empty string or null values are converted to empty string
- The path is validated when `NavigateTo()` is called

**Example:**
```csharp
fileSystemListView.FileSystemListViewValues.CurrentPath = @"C:\Program Files";
```

#### ShowFiles

```csharp
public bool ShowFiles { get; set; }
```

Gets or sets a value indicating whether files should be displayed in the list view.

- **Type**: `bool`
- **Default**: `true`
- **Category**: Behavior
- **Description**: Indicates whether files should be displayed in the list view.

**Behavior:**
- When `false`, only directories are displayed
- Changing this property triggers `Reload()`

**Example:**
```csharp
// Show only directories
fileSystemListView.FileSystemListViewValues.ShowFiles = false;
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
fileSystemListView.FileSystemListViewValues.ShowHiddenFiles = true;
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
fileSystemListView.FileSystemListViewValues.ShowSystemFiles = true;
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
fileSystemListView.FileSystemListViewValues.FileFilter = "*.txt";

// Show multiple file types
fileSystemListView.FileSystemListViewValues.FileFilter = "*.txt;*.doc;*.pdf";

// Show all files (default)
fileSystemListView.FileSystemListViewValues.FileFilter = "*.*";
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

**Example:**
```csharp
fileSystemListView.FileSystemListViewValues.UseLargeIcons = true;
```

---

## Methods Reference

### Public Methods

#### Reload()

```csharp
public void Reload()
```

Reloads the list view from the current path.

**Behavior:**
- Clears all items, icon cache, and ImageList images
- Adds default folder icon
- Loads directory contents if `CurrentPath` is valid
- Auto-resizes columns in Details view
- Raises `FileSystemError` event on exceptions

**Example:**
```csharp
// Refresh the current directory
fileSystemListView.Reload();
```

**When to Use:**
- After changing filter or visibility settings programmatically
- To refresh the display after external file system changes
- After modifying `FileSystemListViewValues` properties directly

#### NavigateTo(string path)

```csharp
public void NavigateTo(string path)
```

Navigates to the specified path in the list view.

**Parameters:**
- `path` (string): The directory path to navigate to.

**Behavior:**
- Validates that the path exists and is a directory
- Sets `CurrentPath` property
- Calls `Reload()` to refresh display
- Raises `PathChanged` event on success
- Raises `FileSystemError` event if path doesn't exist
- Returns early if path is null or empty

**Exceptions:**
- Raises `FileSystemError` event (does not throw) if directory not found

**Example:**
```csharp
try
{
    fileSystemListView.NavigateTo(@"C:\Users\Public\Documents");
}
catch // NavigateTo doesn't throw, but handle FileSystemError event
{
    // Handle via FileSystemError event
}
```

#### AddDefaultIcon()

```csharp
public void AddDefaultIcon()
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

**Example:**
```csharp
// Manually add default icon (usually not needed)
fileSystemListView.AddDefaultIcon();
```

#### AutoResizeAllColumns()

```csharp
public void AutoResizeAllColumns()
```

Auto-resizes all columns to fit their content.

**Behavior:**
- Only works in Details view
- Uses `ColumnHeaderAutoResizeStyle.ColumnContent`
- Resizes all columns to fit the widest item content
- No effect if not in Details view or no columns exist

**Example:**
```csharp
fileSystemListView.AutoResizeAllColumns();
```

#### AutoResizeColumnHeaders()

```csharp
public void AutoResizeColumnHeaders()
```

Auto-resizes all columns to fit the header text.

**Behavior:**
- Only works in Details view
- Uses `ColumnHeaderAutoResizeStyle.HeaderSize`
- Resizes all columns to fit header text width
- Useful when content is empty

**Example:**
```csharp
fileSystemListView.AutoResizeColumnHeaders();
```

---

### Protected Methods

#### OnPathChanged(EventArgs e)

```csharp
protected virtual void OnPathChanged(EventArgs e)
```

Raises the `PathChanged` event.

**Parameters:**
- `e`: An `EventArgs` containing the event data.

**Usage:**
Override to add custom behavior when path changes.

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

### Private Methods

#### SetupColumns()

Sets up default columns for Details view:
- **Name**: 250px width, left-aligned
- **Type**: 100px width, left-aligned
- **Size**: 100px width, right-aligned
- **Date Modified**: 150px width, left-aligned

Column headers use localized strings from `KryptonManager.Strings.FileSystemListViewStrings`.

#### LoadDirectory(string directoryPath)

Loads directory contents:
1. Adds parent directory item ("..")
2. Adds subdirectories (filtered by hidden/system settings)
3. Adds files (if `ShowFiles` is true, filtered by `FileFilter` and hidden/system settings)
4. Handles `UnauthorizedAccessException` for individual items
5. Raises `FileSystemError` for directory-level errors

#### CreateDirectoryItem(string name, string fullPath)

Creates a `ListViewItem` for a directory:
- Sets `Tag` to full path
- Sets icon index via `GetIconIndex()`
- Adds sub-items: Type ("File folder"), Size (empty), Date Modified

#### CreateFileItem(FileInfo fileInfo)

Creates a `ListViewItem` for a file:
- Sets `Tag` to full path
- Sets icon index via `GetIconIndex()`
- Adds sub-items: Type (from `GetFileTypeDescription()`), Size (from `FormatFileSize()`), Date Modified

#### GetIconIndex(string path, bool isDirectory)

Gets or creates icon index for a path:
1. Creates cache key (extension for files, `"__DIRECTORY__"` for folders)
2. Checks cache
3. Extracts icon via `FileSystemIconHelper` with fallbacks
4. Converts icon to bitmap and adds to ImageList
5. Caches index
6. Returns index (0 if all fails)

#### GetFileTypeDescription(string extension)

Returns human-readable file type description:
- Maps common extensions to descriptions (e.g., ".txt" → "Text Document")
- Returns "File" for empty extension
- Returns "{EXT} File" for unknown extensions

#### FormatFileSize(long bytes)

Formats file size with appropriate units:
- Formats as B, KB, MB, GB, or TB
- Uses 0 decimal places for bytes, 2 for others
- Example: "1.5 MB", "1024 B"

#### CreateBitmapForImageList(Bitmap sourceBitmap)

Creates a properly sized bitmap for ImageList:
- Creates bitmap at ImageList size
- Uses high-quality bicubic interpolation
- Returns null on failure

---

## Events Reference

### PathChanged

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when the current path changes.")]
public event EventHandler? PathChanged;
```

Occurs when the current path changes.

**Event Data:** `EventArgs` (no additional data)

**Raised When:**
- `NavigateTo()` successfully changes the path
- `CurrentPath` property is set and path is valid

**Example:**
```csharp
fileSystemListView.PathChanged += (sender, e) =>
{
    Console.WriteLine($"Path changed to: {fileSystemListView.FileSystemListViewValues.CurrentPath}");
};
```

### FileSystemError

```csharp
[Category(@"Behavior")]
[Description(@"Occurs when an error occurs while loading the file system.")]
public event EventHandler<FileSystemErrorEventArgs>? FileSystemError;
```

Occurs when an error occurs while loading the file system.

**Event Data:** `FileSystemErrorEventArgs`
- `Path` (string): The path where the error occurred
- `Exception` (Exception): The exception that occurred

**Raised When:**
- Directory not found during `NavigateTo()`
- Access denied when reading directory contents
- General exceptions during directory loading
- Icon extraction failures (swallowed, not raised)

**Example:**
```csharp
fileSystemListView.FileSystemError += (sender, e) =>
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
- `DirectoryNotFoundException`: Path doesn't exist
- `UnauthorizedAccessException`: Insufficient permissions
- `IOException`: General I/O errors

---

## Related Classes

### FileSystemListViewValues

Groups file system-specific properties for PropertyGrid display.

**Location:** `Krypton.Utilities.FileSystemListViewValues`

**Properties:**
- `CurrentPath` (string)
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
- `Application`: Application icon

### KryptonFileSystemListViewStrings

Localizable string resources for column headers and messages.

**Location:** `Krypton.Toolkit.KryptonFileSystemListViewStrings`

**Properties:**
- `ColumnNameName`: "Name" column header
- `ColumnTypeName`: "Type" column header
- `ColumnSizeName`: "Size" column header
- `ColumnDateModifiedName`: "Date Modified" column header
- `DirectoryNotFoundMessage`: Error message for missing directories
- `UseOSStrings`: Toggle to use OS-defined strings from shell32.dll

**Access:**
```csharp
KryptonManager.Strings.FileSystemListViewStrings.ColumnNameName
```

---

## Icon Management

### Icon Extraction Process

1. **Cache Check**: First checks `_iconCache` dictionary
2. **Icon Extraction**:
   - **Directories**: Tries `FileSystemIconHelper.GetFileSystemIcon()` → `GetFolderIcon()` → `StockIconHelper.GetStockIcon(Folder)`
   - **Files**: Tries `GetFileSystemIcon()` → `GetFileIcon(extension)` → `StockIconHelper.GetStockIcon(DocumentNotAssociated)`
3. **Bitmap Conversion**: Converts `Icon` to `Bitmap` at ImageList size
4. **ImageList Addition**: Adds bitmap to ImageList, forces handle creation
5. **Caching**: Stores index in cache dictionary

### Icon Cache

**Cache Key Format:**
- Directories: `"__DIRECTORY__"`
- Files: File extension (lowercase), e.g., `".txt"`
- Files without extension: `"__FILE__"`

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
5. Reloads directory with new icon size

### Icon Fallback Strategy

The control implements a multi-tier fallback system:

1. **Primary**: Extract icon from actual file/folder path
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
KryptonFileSystemListView fileListView = new KryptonFileSystemListView();
fileListView.Dock = DockStyle.Fill;

// Navigate to a directory
fileListView.NavigateTo(@"C:\Users");

// Add to form
this.Controls.Add(fileListView);
```

### Configure Properties

```csharp
// Set initial path
fileListView.FileSystemListViewValues.CurrentPath = @"C:\Program Files";

// Configure display options
fileListView.FileSystemListViewValues.ShowFiles = true;
fileListView.FileSystemListViewValues.ShowHiddenFiles = false;
fileListView.FileSystemListViewValues.ShowSystemFiles = false;

// Filter files
fileListView.FileSystemListViewValues.FileFilter = "*.exe;*.dll";

// Use large icons
fileListView.FileSystemListViewValues.UseLargeIcons = true;
```

### Handle Events

```csharp
// Path changed event
fileListView.PathChanged += (sender, e) =>
{
    statusLabel.Text = $"Current: {fileListView.FileSystemListViewValues.CurrentPath}";
};

// File system error event
fileListView.FileSystemError += (sender, e) =>
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

### Get Selected Items

```csharp
// Handle selection change
fileListView.SelectedIndexChanged += (sender, e) =>
{
    if (fileListView.SelectedItems.Count > 0)
    {
        string? selectedPath = fileListView.SelectedItems[0].Tag as string;
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
    }
};
```

### Custom Column Resizing

```csharp
// Auto-resize columns after loading
fileListView.PathChanged += (sender, e) =>
{
    // Wait for items to load, then resize
    fileListView.BeginInvoke(new Action(() =>
    {
        fileListView.AutoResizeAllColumns();
    }));
};
```

### Filter Files Dynamically

```csharp
// Filter to show only images
fileListView.FileSystemListViewValues.FileFilter = "*.jpg;*.jpeg;*.png;*.gif;*.bmp";

// Filter to show only documents
fileListView.FileSystemListViewValues.FileFilter = "*.txt;*.doc;*.docx;*.pdf";

// Show all files
fileListView.FileSystemListViewValues.FileFilter = "*.*";
```

### Browse-Only Mode (Directories Only)

```csharp
// Hide files, show only directories
fileListView.FileSystemListViewValues.ShowFiles = false;
```

### Advanced: Custom File Type Descriptions

The control includes built-in file type descriptions, but you can extend `GetFileTypeDescription()` for custom mappings:

```csharp
// The method maps extensions like:
// ".txt" → "Text Document"
// ".doc" → "Microsoft Word Document"
// ".pdf" → "PDF Document"
// etc.
```

### Integration with File Dialogs

```csharp
// Use with OpenFileDialog
OpenFileDialog openDialog = new OpenFileDialog();
if (openDialog.ShowDialog() == DialogResult.OK)
{
    string selectedFile = openDialog.FileName;
    string directory = Path.GetDirectoryName(selectedFile);
    fileListView.NavigateTo(directory);
    
    // Optionally select the file (requires custom implementation)
}
```

---

## Best Practices

### 1. Error Handling

Always handle the `FileSystemError` event:

```csharp
fileListView.FileSystemError += (sender, e) =>
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

- **Icon Caching**: The control caches icons automatically. Avoid clearing the cache unnecessarily.
- **Large Directories**: For directories with thousands of files, consider:
  - Using file filters to limit displayed items
  - Implementing virtual mode (not currently supported)
  - Showing directories only (`ShowFiles = false`)

### 3. Path Validation

Validate paths before navigation:

```csharp
string path = GetPathFromUser();
if (Directory.Exists(path))
{
    fileListView.NavigateTo(path);
}
else
{
    MessageBox.Show("Directory does not exist.");
}
```

### 4. Thread Safety

File system operations should be performed on the UI thread:

```csharp
// Correct: On UI thread
fileListView.NavigateTo(path);

// If loading from background thread:
this.Invoke(new Action(() => fileListView.NavigateTo(path)));
```

### 5. Resource Management

The control manages icon resources internally. Icons are:
- Extracted and cloned (safe to dispose)
- Added to ImageList (ImageList takes ownership)
- Cached for reuse

No manual disposal required for normal usage.

### 6. Property Changes

Properties in `FileSystemListViewValues` automatically trigger `Reload()`. Avoid calling `Reload()` manually after property changes:

```csharp
// Correct: Reload happens automatically
fileListView.FileSystemListViewValues.CurrentPath = @"C:\Users";

// Incorrect: Unnecessary reload
fileListView.FileSystemListViewValues.CurrentPath = @"C:\Users";
fileListView.Reload(); // Not needed
```

### 7. View Mode Considerations

- **Details View**: Full functionality with columns
- **Other Views**: Icons display, but columns are not used
- Switch to Details view before accessing column properties

### 8. Filter Syntax

Use proper filter syntax:
- Single pattern: `"*.txt"`
- Multiple patterns: `"*.txt;*.doc"` (semicolon-separated)
- All files: `"*.*"`

---

## Known Limitations

### 1. Virtual Mode Not Supported

The control does not support virtual mode (`VirtualMode = true`). All items are loaded into memory. For very large directories (10,000+ items), performance may degrade.

### 2. No Built-in Selection Path Properties

While `ListViewItem.Tag` contains the full path, there are no convenience properties like `SelectedPath` or `SelectedPaths` (these are commented out in the source). Access selected paths via:

```csharp
if (fileListView.SelectedItems.Count > 0)
{
    string? path = fileListView.SelectedItems[0].Tag as string;
}
```

### 3. Icon Extraction Failures Are Silent

Icon extraction failures are caught and result in fallback to default icon. The `FileSystemError` event is not raised for icon failures.

### 4. File Filter Limitations

The filter uses `Directory.GetFiles()` which supports simple wildcard patterns. Complex regex patterns are not supported.

### 5. No Custom Sorting

Sorting is handled by the base `ListView` control. Custom sort comparers can be implemented via `ListViewItemSorter` property.

### 6. Column Customization

Default columns are hardcoded. To add custom columns:
1. Clear existing columns
2. Add custom columns
3. Modify `CreateDirectoryItem()` and `CreateFileItem()` to populate custom columns

### 7. No Drag-and-Drop Support

Drag-and-drop is not implemented. Can be added via standard WinForms drag-and-drop events.

### 8. RTL Support

Right-to-left (RTL) layout support depends on base `ListView` RTL capabilities. Not explicitly tested.

### 9. Icon Size Change Requires Reload

Changing `UseLargeIcons` clears the cache and reloads. This may cause a brief delay for large directories.

### 10. Parent Directory Navigation

The ".." item navigates to the parent directory, but there's no built-in "up" button or breadcrumb navigation.

---

## Troubleshooting

### Issue: Icons Not Displaying

**Symptoms:** Icons appear as default/gray icons or not at all.

**Possible Causes:**
1. Icon extraction failing silently
2. ImageList handle not created
3. Icon size mismatch

**Solutions:**
- Check Windows Shell API availability
- Verify `UseLargeIcons` matches desired size
- Check `FileSystemError` event for underlying issues
- Ensure proper permissions for icon extraction

### Issue: Performance Degradation with Many Files

**Symptoms:** Slow loading or UI freezing with large directories.

**Solutions:**
- Use file filters to limit displayed items
- Set `ShowFiles = false` to show directories only
- Consider implementing virtual mode (requires custom implementation)
- Use background threading for navigation (invoke on UI thread)

### Issue: Access Denied Errors

**Symptoms:** `FileSystemError` event raised with `UnauthorizedAccessException`.

**Solutions:**
- Handle `FileSystemError` event gracefully
- Check user permissions
- Use `ShowHiddenFiles` and `ShowSystemFiles` appropriately
- Consider running with elevated permissions if needed

### Issue: Columns Not Displaying

**Symptoms:** Columns don't appear in Details view.

**Solutions:**
- Ensure `View` property is set to `View.Details`
- Check that `SetupColumns()` was called (automatic in Details view)
- Verify columns weren't cleared manually

### Issue: File Filter Not Working

**Symptoms:** All files displayed despite filter setting.

**Solutions:**
- Verify filter syntax (e.g., `"*.txt"` not `".txt"`)
- Ensure `ShowFiles` is `true`
- Check that `Reload()` is called after filter change (automatic)

### Issue: Path Navigation Fails

**Symptoms:** `NavigateTo()` doesn't change directory.

**Solutions:**
- Verify path exists: `Directory.Exists(path)`
- Check path format (use `Path.GetFullPath()` if needed)
- Handle `FileSystemError` event for details
- Ensure path is not null or empty

### Issue: Icons Wrong Size

**Symptoms:** Icons appear too large or too small.

**Solutions:**
- Set `UseLargeIcons = true` for 32x32 icons
- Set `UseLargeIcons = false` for 16x16 icons
- Changing this property automatically reloads icons

### Issue: Selected Item Path Not Available

**Symptoms:** Cannot get selected file/folder path.

**Solutions:**
- Access via `SelectedItems[0].Tag as string`
- Check for null before using
- Verify item is selected (`SelectedItems.Count > 0`)

---

## Additional Resources

### Related Controls

- **KryptonFileSystemTreeView**: Tree view version of file system browser
- **KryptonListView**: Base ListView control with Krypton styling

### Windows API Dependencies

- **Shell32.dll**: Icon extraction (`SHGetFileInfo`)
- **User32.dll**: Icon destruction (`DestroyIcon`)

### String Resources

Access localized strings via:
```csharp
KryptonManager.Strings.FileSystemListViewStrings
```