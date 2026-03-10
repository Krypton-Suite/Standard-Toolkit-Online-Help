# KryptonJumpList

This document describes the **current** Windows taskbar jump list integration in the Krypton Toolkit.  
It reflects the implementation based on `JumpListValues`, `JumpListItem`, and the COM / WPF bridges that
were added for Windows 7+ style Jump Lists.

## Overview

Jump lists let `VisualForm`-based applications (including `KryptonForm`) expose:

- **User tasks** (e.g. “New document”, “Open settings”)  
- **Custom categories** (e.g. “Recent Files”, “Templates”) – backed by `JumpListValues.Categories` and shown under named headings in the taskbar jump list (supported in the core COM implementation and in the TestForm demo).  
- **Shell–managed sections** like **Recent** and **Frequent** – controlled by `ShowRecentCategory` / `ShowFrequentCategory` **and** the Windows privacy setting “Show recently opened items in Start, Jump Lists, and File Explorer”; if that OS setting is off or Windows has no data, these sections will not appear.  

These appear when the user right‑clicks the app’s taskbar button.

## Core Types

### `JumpListItem`

- **Location**: `Source/Krypton Components/Krypton.Toolkit/General/JumpListItem.cs`
- **Purpose**: Represents a single item (task or destination) that can appear in the jump list.
- **Key properties**:
  - `Title` – Display text shown in the jump list.
  - `Path` – Executable or file path (e.g. app EXE, document path).
  - `Arguments` – Command–line arguments (for tasks).
  - `WorkingDirectory` – Working directory for the process.
  - `IconPath` – Optional icon source (defaults to `Path` if omitted).
  - `IconIndex` – Index within the icon resource.
  - `Description` – Tooltip text.

### `JumpListValues`

- **Location**: `Source/Krypton Components/Krypton.Toolkit/Values/JumpListValues.cs`
- **Purpose**: Stores jump list configuration for a `VisualForm`.
- **Key members**:
  - `AppId` – Application User Model ID (AppUserModelID).
  - `ShowFrequentCategory` – Whether to show the Windows‑managed **Frequent** section.
  - `ShowRecentCategory` – Whether to show the Windows‑managed **Recent** section.
  - `UserTasks : List<JumpListItem>` – Collection of user tasks.
  - `Categories : Dictionary<string, List<JumpListItem>>` – Custom categories.
  - `ResetUserTasks()`, `ClearCategories()` – Helpers to clear state.
  - `Apply()` – Raises the internal `JumpListChanged` event so `VisualForm` can rebuild the shell jump list.

> **Note**  
> Mutating `UserTasks` or `Categories` directly (e.g. `Add`, `Clear`) does **not** automatically update Windows.
> You must either call `Apply()` or use higher-level helpers that raise `JumpListChanged`.

### COM Interop (`PlatformInvoke.cs`)

- **Location**: `Source/Krypton Components/Krypton.Toolkit/General/PlatformInvoke.cs`
- **Purpose**: Provides the native interfaces and CLSIDs used to talk to the Windows shell.
- **Relevant declarations**:
  - `ICustomDestinationList` – Creates and commits a custom jump list.
  - `IShellLinkW` – Represents a shell link used for tasks and destinations.
  - `IObjectCollection` / `IObjectArray` – Collections of shell COM objects.
  - `CustomDestinationList` / `ObjectCollection` – COM classes (CLSIDs) used to create the objects.
  - `IPropertyStore`, `PROPERTYKEY`, `PROPVARIANT`, `PKEY_Title` – Used to set the display title for shell links.
  - `SetCurrentProcessExplicitAppUserModelID` – P/Invoke call to set the process AppUserModelID.

Krypton uses these to:

- Create `IShellLinkW` instances for each `JumpListItem`.
- Set required fields (path, arguments, icon, description, title).
- Place links into categories and the tasks section.
- Commit the list via `ICustomDestinationList.CommitList()`.

## Integration with `VisualForm` / `KryptonForm`

### Properties

On `VisualForm` (and therefore `KryptonForm`) you get:

- `JumpListValues` – Exposes the `JumpListValues` instance.
- `JumpList` – Convenience wrapper that forwards to `JumpListValues`.

### Lifecycle

- On construction, `VisualForm` creates a `JumpListValues` instance and subscribes to its internal `JumpListChanged` event.
- When the form handle is created, `VisualForm` calls its internal `OnJumpListChanged()` which:
  - Ensures:
    - Not in design mode.
    - Window handle exists.
    - OS is Windows 7+.
    - `AppId` is non-empty.
  - Creates a `CustomDestinationList` instance.
  - Adds **Recent**/**Frequent** categories if enabled.
  - Converts `Categories` and `UserTasks` into `IShellLinkW` objects and appends them.
  - Calls `CommitList()` to apply the jump list to the shell.
- `JumpListValues.Apply()` simply invokes `JumpListChanged`, which in turn causes `VisualForm` to rebuild the COM jump list.

### Error Handling

- If COM activation fails (e.g. `REGDB_E_CLASSNOTREG`), the exception is caught and ignored so the app continues running without a jump list.
- Any other exceptions from the COM layer are captured by `KryptonExceptionHandler`.

## Usage

### 1. Setting the AppUserModelID

Windows uses the AppUserModelID to associate your process with its taskbar icon and jump list.

You must set it **before** any window is created:

```csharp
// Typical Program.Main (WinForms)
[STAThread]
static void Main()
{
    // Set AppID first
    Krypton.Toolkit.PI.SetCurrentProcessExplicitAppUserModelID("MyCompany.MyApp");

    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);

    Application.Run(new MyKryptonForm());
}
```

On the form, match the values:

```csharp
public MyKryptonForm()
{
    InitializeComponent();
    JumpList.AppId = "MyCompany.MyApp";
}
```

### 2. Configuring via Designer

1. Select your `KryptonForm` in the designer.  
2. In the Properties grid, expand `JumpList`.  
3. Set:
   - `AppId` – Same as you use in `SetCurrentProcessExplicitAppUserModelID`.
   - `ShowFrequentCategory` / `ShowRecentCategory` as needed.  
4. Expand `UserTasks`:
   - Click the collection editor `...`.
   - Add `JumpListItem` entries (set `Title`, `Path`, optional `Arguments`, `IconPath`, etc.).
5. Custom categories:
   - Use code or helpers to populate `Categories` at runtime (currently a dictionary, not designer-editable).

### 3. Configuring in Code

```csharp
// Inside a KryptonForm
private void ConfigureJumpList()
{
    JumpList.AppId = "MyCompany.MyApp";

    // Show Windows-managed sections
    JumpList.ShowRecentCategory = true;
    JumpList.ShowFrequentCategory = false;

    // User tasks
    JumpList.UserTasks.Clear();
    JumpList.UserTasks.Add(new JumpListItem
    {
        Title = "New Document",
        Path = Application.ExecutablePath,
        Arguments = "/new",
        Description = "Create a new document",
        IconPath = Application.ExecutablePath,
        IconIndex = 0
    });

    // Custom category: Recent Documents
    var recents = new List<JumpListItem>
    {
        new()
        {
            Title = "Document1.txt",
            Path = @"C:\Docs\Document1.txt",
            Description = @"C:\Docs\Document1.txt"
        },
        new()
        {
            Title = "Document2.txt",
            Path = @"C:\Docs\Document2.txt",
            Description = @"C:\Docs\Document2.txt"
        }
    };

    JumpList.Categories["Recent Documents"] = recents;

    // Apply changes
    JumpList.Apply();
}
```

### 4. Handling Item Clicks

When the user chooses a task or file from the jump list, Windows starts your application with the configured arguments or file path:

```csharp
// Program.Main example
static void Main()
{
    Krypton.Toolkit.PI.SetCurrentProcessExplicitAppUserModelID("MyCompany.MyApp");

    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);

    var args = Environment.GetCommandLineArgs();

    if (args.Length > 1)
    {
        var argument = args[1];
        // Interpret your custom verbs or file paths
        switch (argument)
        {
            case "/new":
                // create new document
                break;
            case "/open":
                // show open dialog
                break;
            default:
                if (File.Exists(argument))
                {
                    // open the file
                }
                break;
        }
    }

    Application.Run(new MyKryptonForm());
}
```

## Requirements & Notes

- **OS**: Windows 7 or later.  
- **.NET**:
  - .NET Framework 4.7.2+ or
  - .NET 8.0‑windows+ (for modern TFMs in this repo).
- Jump lists are only created at runtime (never in the designer).
- If COM activation fails (`REGDB_E_CLASSNOTREG` or similar), Krypton silently skips jump list updates so the app still runs.
- The TestForm jump list demo also includes an optional WPF `System.Windows.Shell.JumpList` bridge for environments where native COM is unreliable; that bridge is **demo-only** and not required for normal applications.

## Benefits

- **Improved UX**: Quick access to common tasks and documents directly from the taskbar.  
- **Native integration**: Uses the same mechanisms as WPF’s [`System.Windows.Shell.JumpList`](https://learn.microsoft.com/en-us/dotnet/api/system.windows.shell.jumplist?view=windowsdesktop-10.0).  
- **Flexible**: Supports user tasks, custom categories, and shell‑managed Recent/Frequent sections.  
- **Safe & resilient**: Handles unsupported or misconfigured environments gracefully without crashing the app.
