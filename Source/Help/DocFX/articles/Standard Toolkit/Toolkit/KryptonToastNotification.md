# KryptonToastNotification

## Overview

The `KryptonToastNotification` class provides a static utility for displaying toast notifications with Krypton theming. It offers a centralized way to show various types of toast notifications including basic notifications, progress bar notifications, and user input notifications with customizable return values and "Do not show again" options.

## Class Hierarchy

```
System.Object
└── Krypton.Toolkit.KryptonToastNotification
```

## Key Methods

### Basic Notification Methods

#### ShowBasicNotification Method

```csharp
public static void ShowBasicNotification(KryptonBasicToastNotificationData toastNotificationData)
```

- **Purpose**: Displays a basic toast notification
- **Parameters**:
  - `toastNotificationData`: Configuration data for the toast notification
- **Returns**: void
- **Usage**: Simple notification display without return values

#### ShowBasicNotificationWithBooleanReturnValue Method

```csharp
public static bool ShowBasicNotificationWithBooleanReturnValue(KryptonBasicToastNotificationData toastNotificationData)
```

- **Purpose**: Displays a basic toast notification with boolean return value
- **Parameters**:
  - `toastNotificationData`: Configuration data for the toast notification
- **Returns**: Boolean value based on the 'Do not show again' option
- **Usage**: Notifications with user preference tracking

#### ShowBasicNotificationWithCheckStateReturnValue Method

```csharp
public static CheckState ShowBasicNotificationWithCheckStateReturnValue(KryptonBasicToastNotificationData toastNotificationData)
```

- **Purpose**: Displays a basic toast notification with CheckState return value
- **Parameters**:
  - `toastNotificationData`: Configuration data for the toast notification
- **Returns**: CheckState value based on the 'Do not show again' option
- **Usage**: Notifications with three-state user preference tracking

### Progress Bar Notification Methods

#### ShowBasicProgressBarNotification Method

```csharp
public static void ShowBasicProgressBarNotification(KryptonBasicToastNotificationData toastNotificationData)
```

- **Purpose**: Displays a basic progress bar notification
- **Parameters**:
  - `toastNotificationData`: Configuration data for the toast notification
- **Returns**: void
- **Usage**: Progress notifications without return values

#### ShowBasicProgressBarNotificationWithBooleanReturnValue Method

```csharp
public static bool ShowBasicProgressBarNotificationWithBooleanReturnValue(KryptonBasicToastNotificationData toastNotificationData)
```

- **Purpose**: Displays a basic progress bar notification with boolean return value
- **Parameters**:
  - `toastNotificationData`: Configuration data for the toast notification
- **Returns**: Boolean value based on the 'Do not show again' option
- **Usage**: Progress notifications with user preference tracking

#### ShowBasicProgressBarNotificationWithCheckStateReturnValue Method

```csharp
public static CheckState ShowBasicProgressBarNotificationWithCheckStateReturnValue(KryptonBasicToastNotificationData toastNotificationData)
```

- **Purpose**: Displays a basic progress bar notification with CheckState return value
- **Parameters**:
  - `toastNotificationData`: Configuration data for the toast notification
- **Returns**: CheckState value based on the 'Do not show again' option
- **Usage**: Progress notifications with three-state user preference tracking

### User Input Notification Methods

#### ShowNotification Method

```csharp
public static object ShowNotification(KryptonUserInputToastNotificationData data)
```

- **Purpose**: Displays a notification with ComboBox for user input
- **Parameters**:
  - `data`: Configuration data for the user input notification
- **Returns**: Object containing the user's selection
- **Usage**: Notifications requiring user input via ComboBox

#### ShowNotificationWithProgressBar Method

```csharp
public static object ShowNotificationWithProgressBar(KryptonUserInputToastNotificationData data)
```

- **Purpose**: Displays a notification with progress bar and ComboBox for user input
- **Parameters**:
  - `data`: Configuration data for the user input notification with progress
- **Returns**: Object containing the user's selection
- **Usage**: Progress notifications requiring user input via ComboBox

## Advanced Usage Patterns

### Basic Toast Notification

```csharp
public void ShowBasicToast()
{
    var notificationData = new KryptonBasicToastNotificationData
    {
        Title = "Information",
        Message = "Operation completed successfully!",
        Icon = MessageBoxIcon.Information
    };

    KryptonToastNotification.ShowBasicNotification(notificationData);
}
```

### Toast with User Preference

```csharp
public class NotificationManager
{
    public void ShowNotificationWithPreference()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Update Available",
            Message = "A new version of the application is available. Would you like to download it now?",
            Icon = MessageBoxIcon.Question,
            ShowDoNotShowAgain = true
        };

        bool doNotShowAgain = KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
        
        if (doNotShowAgain)
        {
            SaveUserPreference("UpdateNotification", false);
        }
    }

    private void SaveUserPreference(string key, bool value)
    {
        // Implementation to save user preference
        Console.WriteLine($"Preference saved: {key} = {value}");
    }
}
```

### Progress Bar Notification

```csharp
public class ProgressNotificationManager
{
    public void ShowProgressNotification()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Download Progress",
            Message = "Downloading file...",
            Icon = MessageBoxIcon.Information,
            ProgressValue = 50,
            ProgressMaximum = 100
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    public void ShowProgressWithPreference()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Backup Progress",
            Message = "Creating backup of your files...",
            Icon = MessageBoxIcon.Information,
            ProgressValue = 75,
            ProgressMaximum = 100,
            ShowDoNotShowAgain = true
        };

        CheckState doNotShowAgain = KryptonToastNotification.ShowBasicProgressBarNotificationWithCheckStateReturnValue(notificationData);
        
        switch (doNotShowAgain)
        {
            case CheckState.Checked:
                SaveUserPreference("BackupProgress", false);
                break;
            case CheckState.Unchecked:
                SaveUserPreference("BackupProgress", true);
                break;
            case CheckState.Indeterminate:
                // User didn't make a choice
                break;
        }
    }
}
```

### User Input Notification

```csharp
public class UserInputNotificationManager
{
    public void ShowUserInputNotification()
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "Select Action",
            Message = "Choose what you would like to do:",
            ComboBoxItems = new[] { "Continue", "Pause", "Cancel" },
            SelectedIndex = 0
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        
        if (result != null)
        {
            string selectedAction = result.ToString();
            ProcessUserAction(selectedAction);
        }
    }

    public void ShowProgressWithUserInput()
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "Download Options",
            Message = "Download in progress. Choose an action:",
            ComboBoxItems = new[] { "Continue", "Pause", "Cancel" },
            SelectedIndex = 0,
            ProgressValue = 60,
            ProgressMaximum = 100
        };

        object result = KryptonToastNotification.ShowNotificationWithProgressBar(inputData);
        
        if (result != null)
        {
            string selectedAction = result.ToString();
            ProcessDownloadAction(selectedAction);
        }
    }

    private void ProcessUserAction(string action)
    {
        switch (action)
        {
            case "Continue":
                // Continue operation
                break;
            case "Pause":
                // Pause operation
                break;
            case "Cancel":
                // Cancel operation
                break;
        }
    }

    private void ProcessDownloadAction(string action)
    {
        switch (action)
        {
            case "Continue":
                // Continue download
                break;
            case "Pause":
                // Pause download
                break;
            case "Cancel":
                // Cancel download
                break;
        }
    }
}
```

### Notification with Custom Actions

```csharp
public class CustomActionNotificationManager
{
    public void ShowCustomActionNotification()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "File Operation",
            Message = "File has been moved to Recycle Bin. What would you like to do?",
            Icon = MessageBoxIcon.Warning,
            ShowDoNotShowAgain = true
        };

        bool doNotShowAgain = KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
        
        if (doNotShowAgain)
        {
            SaveUserPreference("FileOperationNotification", false);
        }
        
        // Show additional options
        ShowAdditionalOptions();
    }

    private void ShowAdditionalOptions()
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "Additional Options",
            Message = "Choose an additional action:",
            ComboBoxItems = new[] { "Restore File", "Empty Recycle Bin", "Do Nothing" },
            SelectedIndex = 2
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        
        if (result != null)
        {
            ProcessAdditionalAction(result.ToString());
        }
    }

    private void ProcessAdditionalAction(string action)
    {
        switch (action)
        {
            case "Restore File":
                // Restore file from recycle bin
                break;
            case "Empty Recycle Bin":
                // Empty recycle bin
                break;
            case "Do Nothing":
                // Do nothing
                break;
        }
    }
}
```

## Integration Patterns

### Application Notification System

```csharp
public class ApplicationNotificationSystem
{
    private readonly Dictionary<string, bool> userPreferences;

    public ApplicationNotificationSystem()
    {
        userPreferences = LoadUserPreferences();
    }

    public void ShowUpdateNotification()
    {
        if (!ShouldShowNotification("UpdateNotification"))
            return;

        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Application Update",
            Message = "A new version is available. Would you like to update now?",
            Icon = MessageBoxIcon.Information,
            ShowDoNotShowAgain = true
        };

        bool doNotShowAgain = KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
        
        if (doNotShowAgain)
        {
            userPreferences["UpdateNotification"] = false;
            SaveUserPreferences();
        }
    }

    public void ShowBackupProgress()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Backup in Progress",
            Message = "Creating backup of your data...",
            Icon = MessageBoxIcon.Information,
            ProgressValue = 0,
            ProgressMaximum = 100
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    public void ShowErrorNotification(string errorMessage)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Error",
            Message = errorMessage,
            Icon = MessageBoxIcon.Error
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    private bool ShouldShowNotification(string notificationKey)
    {
        return !userPreferences.ContainsKey(notificationKey) || userPreferences[notificationKey];
    }

    private Dictionary<string, bool> LoadUserPreferences()
    {
        // Implementation to load user preferences
        return new Dictionary<string, bool>();
    }

    private void SaveUserPreferences()
    {
        // Implementation to save user preferences
    }
}
```

### File Operation Notifications

```csharp
public class FileOperationNotificationManager
{
    public void ShowFileOperationProgress(string fileName, int progress, int maximum)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "File Operation",
            Message = $"Processing {fileName}...",
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    public void ShowFileOperationComplete(string fileName, bool success)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = success ? "Success" : "Error",
            Message = success ? $"File {fileName} processed successfully" : $"Error processing {fileName}",
            Icon = success ? MessageBoxIcon.Information : MessageBoxIcon.Error
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    public void ShowFileConflictResolution(string fileName)
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "File Conflict",
            Message = $"File {fileName} already exists. What would you like to do?",
            ComboBoxItems = new[] { "Overwrite", "Rename", "Skip" },
            SelectedIndex = 0
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        
        if (result != null)
        {
            ProcessFileConflict(fileName, result.ToString());
        }
    }

    private void ProcessFileConflict(string fileName, string action)
    {
        switch (action)
        {
            case "Overwrite":
                // Overwrite existing file
                break;
            case "Rename":
                // Rename new file
                break;
            case "Skip":
                // Skip this file
                break;
        }
    }
}
```

## Performance Considerations

- **Static Methods**: Efficient static method calls without instance creation
- **Memory Management**: Minimal memory footprint for utility class
- **Notification Lifecycle**: Proper notification creation and disposal
- **User Preferences**: Efficient preference storage and retrieval

## Common Issues and Solutions

### Notification Not Showing

**Issue**: Toast notification not appearing  
**Solution**: Ensure proper notification data configuration:

```csharp
var notificationData = new KryptonBasicToastNotificationData
{
    Title = "Notification Title",
    Message = "Notification message",
    Icon = MessageBoxIcon.Information
    // Ensure all required properties are set
};

KryptonToastNotification.ShowBasicNotification(notificationData);
```

### Progress Bar Not Updating

**Issue**: Progress bar not showing progress correctly  
**Solution**: Ensure proper progress values:

```csharp
var notificationData = new KryptonBasicToastNotificationData
{
    Title = "Progress",
    Message = "Operation in progress...",
    ProgressValue = 50,    // Current progress
    ProgressMaximum = 100  // Maximum progress
};

KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
```

### User Input Not Working

**Issue**: ComboBox not showing options or not returning values  
**Solution**: Ensure proper ComboBox configuration:

```csharp
var inputData = new KryptonUserInputToastNotificationData
{
    Title = "Select Option",
    Message = "Choose an option:",
    ComboBoxItems = new[] { "Option 1", "Option 2", "Option 3" },
    SelectedIndex = 0  // Default selection
};

object result = KryptonToastNotification.ShowNotification(inputData);
```

## Design-Time Integration

### Visual Studio Designer

- **Static Class**: Not available in toolbox (static utility class)
- **Method Access**: Accessible through code only
- **Configuration**: Notification data configuration through code

### Usage Patterns

- **Basic Notifications**: Simple information display
- **Progress Notifications**: Operation progress tracking
- **User Input**: Interactive notifications with choices
- **Preference Tracking**: "Do not show again" functionality

## Migration and Compatibility

### From Standard MessageBox

```csharp
// Old way
MessageBox.Show("Message", "Title", MessageBoxButtons.OK, MessageBoxIcon.Information);

// New way
var notificationData = new KryptonBasicToastNotificationData
{
    Title = "Title",
    Message = "Message",
    Icon = MessageBoxIcon.Information
};
KryptonToastNotification.ShowBasicNotification(notificationData);
```

### From Custom Toast Systems

```csharp
// Old way (if using custom toast system)
// CustomToast.Show("Message", "Title", ToastType.Info);

// New way
var notificationData = new KryptonBasicToastNotificationData
{
    Title = "Title",
    Message = "Message",
    Icon = MessageBoxIcon.Information
};
KryptonToastNotification.ShowBasicNotification(notificationData);
```

## Real-World Integration Examples

### Application Update Manager

```csharp
public class ApplicationUpdateManager
{
    public void CheckForUpdates()
    {
        // Simulate update check
        bool updateAvailable = CheckUpdateAvailability();
        
        if (updateAvailable)
        {
            ShowUpdateNotification();
        }
    }

    private void ShowUpdateNotification()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Update Available",
            Message = "A new version of the application is available. Would you like to download and install it now?",
            Icon = MessageBoxIcon.Question,
            ShowDoNotShowAgain = true
        };

        bool doNotShowAgain = KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
        
        if (doNotShowAgain)
        {
            SaveUpdatePreference(false);
        }
        else
        {
            ShowUpdateOptions();
        }
    }

    private void ShowUpdateOptions()
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "Update Options",
            Message = "Choose how you would like to proceed:",
            ComboBoxItems = new[] { "Download Now", "Download Later", "Skip This Version" },
            SelectedIndex = 0
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        
        if (result != null)
        {
            ProcessUpdateChoice(result.ToString());
        }
    }

    private void ProcessUpdateChoice(string choice)
    {
        switch (choice)
        {
            case "Download Now":
                StartUpdateDownload();
                break;
            case "Download Later":
                ScheduleUpdateDownload();
                break;
            case "Skip This Version":
                SkipCurrentVersion();
                break;
        }
    }

    private bool CheckUpdateAvailability()
    {
        // Implementation to check for updates
        return true;
    }

    private void SaveUpdatePreference(bool showUpdates)
    {
        // Implementation to save update preference
    }

    private void StartUpdateDownload()
    {
        // Implementation to start update download
    }

    private void ScheduleUpdateDownload()
    {
        // Implementation to schedule update download
    }

    private void SkipCurrentVersion()
    {
        // Implementation to skip current version
    }
}
```

### Backup System Notifications

```csharp
public class BackupSystemNotificationManager
{
    public void ShowBackupProgress(string backupName, int progress, int maximum)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Backup Progress",
            Message = $"Creating backup: {backupName}",
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    public void ShowBackupComplete(string backupName, bool success)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = success ? "Backup Complete" : "Backup Failed",
            Message = success ? $"Backup {backupName} completed successfully" : $"Backup {backupName} failed",
            Icon = success ? MessageBoxIcon.Information : MessageBoxIcon.Error
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    public void ShowBackupConflict(string backupName)
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "Backup Conflict",
            Message = $"Backup {backupName} already exists. What would you like to do?",
            ComboBoxItems = new[] { "Overwrite", "Create New", "Cancel" },
            SelectedIndex = 1
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        
        if (result != null)
        {
            ProcessBackupConflict(backupName, result.ToString());
        }
    }

    private void ProcessBackupConflict(string backupName, string action)
    {
        switch (action)
        {
            case "Overwrite":
                // Overwrite existing backup
                break;
            case "Create New":
                // Create new backup with different name
                break;
            case "Cancel":
                // Cancel backup operation
                break;
        }
    }
}
```

## License and Attribution

This class is part of the Krypton Toolkit Suite under the BSD 3-Clause License. It provides a centralized toast notification utility with support for basic notifications, progress tracking, user input, and preference management, enabling consistent notification display across Krypton applications.
