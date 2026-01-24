# KryptonJumpList

This document describes the implementation of Windows taskbar jump list functionality for the Krypton Toolkit, allowing applications to customize the right-click menu on their taskbar icon.

## Overview

The jump list feature enables VisualForm-based applications (including KryptonForm) to add custom tasks, recent files, frequent files, and custom categories to the Windows taskbar jump list. This provides users with quick access to common actions and recently used files directly from the taskbar.

## Features

- **User Tasks**: Always-visible items that appear at the top of the jump list
- **Recent Files**: Automatically tracked recent files (Windows-managed)
- **Frequent Files**: Automatically tracked frequently used files (Windows-managed)
- **Custom Categories**: Application-defined categories with custom items
- **Designer Support**: Full Visual Studio designer integration for configuring jump list items
- **Runtime Configuration**: Programmatic access to modify jump lists at runtime

## Implementation Details

### New Classes

#### `KryptonJumpList`
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonJumpList.cs`
- **Purpose**: Manages the jump list and handles COM interop with Windows Shell APIs
- **Note**: Works with `VisualForm` instances (including `KryptonForm` which inherits from `VisualForm`)
- **Key Methods**:
  - `Refresh()`: Updates the jump list with current items
  - `Clear()`: Removes all items from the jump list
  - `AddCustomCategory()`: Adds a custom category with items
  - `RemoveCustomCategory()`: Removes a custom category

#### `KryptonJumpListItem`
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonJumpListItem.cs`
- **Purpose**: Represents a single jump list item
- **Properties**:
  - `Title`: Display title
  - `Path`: Path to executable or file
  - `Arguments`: Command-line arguments
  - `WorkingDirectory`: Working directory for the application
  - `IconPath`: Path to icon file
  - `IconIndex`: Icon index within the icon file
  - `Description`: Tooltip/description text

#### `KryptonJumpListItems`
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/KryptonJumpListItems.cs`
- **Purpose**: Collection of jump list items with designer support

#### `JumpListValues`
- **Location**: `Source/Krypton Components/Krypton.Toolkit/Values/JumpListValues.cs`
- **Purpose**: Storage for jump list configuration values
- **Properties**:
  - `Enabled`: Enable/disable the jump list
  - `AppId`: Application user model ID
  - `ShowFrequentCategory`: Show Windows-managed frequent files
  - `ShowRecentCategory`: Show Windows-managed recent files
  - `UserTasks`: Collection of user tasks

### Enhanced APIs

#### PlatformInvoke.cs
Added COM interop declarations for jump list functionality:
- `ICustomDestinationList`: Interface for managing jump lists
- `IShellLinkW`: Interface for creating shell links (shortcuts)
- `IObjectCollection`: Interface for collections of COM objects
- `IObjectArray`: Base interface for object arrays
- Related GUIDs, enums, and structures

### Integration with VisualForm

#### New Properties
- `JumpListValues`: Access to jump list configuration
- `JumpList`: Direct access to the jump list instance (runtime only)

#### Automatic Integration
- Jump list is automatically created when a `VisualForm` (or `KryptonForm`) is instantiated
- Jump list is refreshed when the form handle is created (if enabled)
- Changes to `JumpListValues` automatically refresh the jump list
- **Note**: Jump list functionality is available on `VisualForm`, making it accessible to all forms that inherit from it (including `KryptonForm`)

## Usage

### Designer Usage

1. Select a `KryptonForm` (or any `VisualForm`) in the designer
2. In the Properties window, expand `JumpListValues`
3. Set `Enabled` to `true`
4. Optionally set `AppId` (recommended for proper Windows integration)
5. Configure `ShowFrequentCategory` and `ShowRecentCategory` as needed
6. Expand `UserTasks` and click the ellipsis (...) button to open the collection editor
7. Add jump list items:
   - Click "Add" in the collection editor
   - Set `Title` (e.g., "New Document")
   - Set `Path` to the executable or file path
   - Optionally set `Arguments`, `WorkingDirectory`, `IconPath`, etc.

### Programmatic Usage

```csharp
// Enable jump list
form.JumpListValues.Enabled = true;
form.JumpListValues.AppId = "MyCompany.MyApp";

// Add user tasks
var newDocTask = new KryptonJumpListItem("New Document", 
    Application.ExecutablePath, 
    "/new");
form.JumpListValues.UserTasks.Add(newDocTask);

var openTask = new KryptonJumpListItem("Open", 
    Application.ExecutablePath, 
    "/open");
form.JumpListValues.UserTasks.Add(openTask);

// Add custom category
var recentFiles = new KryptonJumpListItems();
recentFiles.Add(new KryptonJumpListItem("Document1.txt", 
    @"C:\Documents\Document1.txt"));
recentFiles.Add(new KryptonJumpListItem("Document2.txt", 
    @"C:\Documents\Document2.txt"));

form.JumpList?.AddCustomCategory("Recent Documents", recentFiles);

// Refresh the jump list
form.JumpList?.Refresh();
```

### Handling Jump List Item Clicks

When a user clicks a jump list item, Windows launches the application with the specified path and arguments. Handle this in your application's startup code:

```csharp
static void Main()
{
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);

    // Check for jump list arguments
    string[] args = Environment.GetCommandLineArgs();
    if (args.Length > 1)
    {
        string argument = args[1];
        // Handle jump list item click
        if (argument == "/new")
        {
            // Create new document
        }
        else if (argument == "/open")
        {
            // Open file dialog
        }
        else if (File.Exists(argument))
        {
            // Open the file
        }
    }

    Application.Run(new MainForm());
}
```

## Requirements

- **Windows Version**: Windows 7 or later
- **.NET Framework**: 4.7.2 or later
- **.NET**: 8.0-windows or later

## Technical Notes

- Jump lists are only created at runtime (not in design mode)
- The implementation gracefully handles cases where jump lists are not supported
- COM objects are properly released to prevent memory leaks
- The jump list is automatically refreshed when the form handle is created (if enabled)
- Changes to `JumpListValues` properties automatically trigger a refresh
- Jump list functionality is implemented in `VisualForm`, following the same pattern as `TaskbarOverlayIcon`
- Available to all forms inheriting from `VisualForm` (including `KryptonForm`)

## Benefits

1. **Enhanced User Experience**: Quick access to common tasks and recent files
2. **Windows Integration**: Native Windows 7+ taskbar integration
3. **Designer Support**: Easy configuration through Visual Studio designer
4. **Flexible Configuration**: Support for tasks, categories, and Windows-managed lists
5. **Runtime Management**: Programmatic control over jump list contents
