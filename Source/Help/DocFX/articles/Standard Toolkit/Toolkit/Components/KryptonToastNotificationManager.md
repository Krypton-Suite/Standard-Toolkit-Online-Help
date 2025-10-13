# KryptonToastNotificationManager

## Overview

The `KryptonToastNotificationManager` class provides a component-based manager for toast notifications in Krypton applications. It inherits from `Component` and serves as a design-time component that can be added to forms or used programmatically to manage toast notification functionality with enhanced control and configuration options.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── Krypton.Toolkit.KryptonToastNotificationManager
```

## Constructor and Initialization

```csharp
public KryptonToastNotificationManager()
```

The constructor initializes the component:
- **Component Base**: Inherits from `Component` for design-time support
- **Toolbox Integration**: Available in Visual Studio toolbox with custom bitmap
- **Design-Time Support**: Full design-time integration and configuration

## Key Properties

### Toolbox Integration

The class is decorated with toolbox attributes:

```csharp
[ToolboxItem(true)]
[ToolboxBitmap(typeof(KryptonToastNotificationManager), @"ToolboxBitmaps.KryptonInputBox.bmp")]
```

- **ToolboxItem(true)**: Makes the component available in the Visual Studio toolbox
- **ToolboxBitmap**: Uses a custom bitmap for toolbox representation
- **Design-Time**: Full design-time support for configuration

## Advanced Usage Patterns

### Design-Time Component Usage

```csharp
public partial class MainForm : Form
{
    private KryptonToastNotificationManager toastNotificationManager;

    public MainForm()
    {
        InitializeComponent();
        SetupToastNotificationManager();
    }

    private void SetupToastNotificationManager()
    {
        // The component can be added from the toolbox or created programmatically
        toastNotificationManager = new KryptonToastNotificationManager();
        
        // Add to form's components collection for proper disposal
        Components.Add(toastNotificationManager);
    }
}
```

### Programmatic Toast Notification Management

```csharp
public class ApplicationNotificationService
{
    private KryptonToastNotificationManager notificationManager;
    private Dictionary<string, bool> notificationPreferences;

    public ApplicationNotificationService()
    {
        notificationManager = new KryptonToastNotificationManager();
        notificationPreferences = LoadNotificationPreferences();
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
            notificationPreferences["UpdateNotification"] = false;
            SaveNotificationPreferences();
        }
    }

    public void ShowProgressNotification(string operation, int progress, int maximum)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Operation Progress",
            Message = $"{operation} in progress...",
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
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
        return !notificationPreferences.ContainsKey(notificationKey) || notificationPreferences[notificationKey];
    }

    private Dictionary<string, bool> LoadNotificationPreferences()
    {
        // Implementation to load notification preferences
        return new Dictionary<string, bool>();
    }

    private void SaveNotificationPreferences()
    {
        // Implementation to save notification preferences
    }
}
```

### Centralized Notification Management

```csharp
public class CentralizedNotificationManager
{
    private KryptonToastNotificationManager notificationManager;
    private readonly object lockObject = new object();

    public CentralizedNotificationManager()
    {
        notificationManager = new KryptonToastNotificationManager();
    }

    public void ShowNotification(NotificationType type, string title, string message, 
        MessageBoxIcon icon = MessageBoxIcon.Information, bool showDoNotShowAgain = false)
    {
        lock (lockObject)
        {
            var notificationData = new KryptonBasicToastNotificationData
            {
                Title = title,
                Message = message,
                Icon = icon,
                ShowDoNotShowAgain = showDoNotShowAgain
            };

            switch (type)
            {
                case NotificationType.Basic:
                    KryptonToastNotification.ShowBasicNotification(notificationData);
                    break;
                case NotificationType.WithBooleanReturn:
                    bool result = KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
                    OnNotificationResult(result);
                    break;
                case NotificationType.WithCheckStateReturn:
                    CheckState checkState = KryptonToastNotification.ShowBasicNotificationWithCheckStateReturnValue(notificationData);
                    OnNotificationCheckStateResult(checkState);
                    break;
            }
        }
    }

    public void ShowProgressNotification(string title, string message, int progress, int maximum)
    {
        lock (lockObject)
        {
            var notificationData = new KryptonBasicToastNotificationData
            {
                Title = title,
                Message = message,
                Icon = MessageBoxIcon.Information,
                ProgressValue = progress,
                ProgressMaximum = maximum
            };

            KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
        }
    }

    public void ShowUserInputNotification(string title, string message, string[] options, int defaultIndex = 0)
    {
        lock (lockObject)
        {
            var inputData = new KryptonUserInputToastNotificationData
            {
                Title = title,
                Message = message,
                ComboBoxItems = options,
                SelectedIndex = defaultIndex
            };

            object result = KryptonToastNotification.ShowNotification(inputData);
            OnUserInputResult(result);
        }
    }

    private void OnNotificationResult(bool result)
    {
        // Handle boolean notification result
        Console.WriteLine($"Notification result: {result}");
    }

    private void OnNotificationCheckStateResult(CheckState checkState)
    {
        // Handle CheckState notification result
        Console.WriteLine($"Notification check state: {checkState}");
    }

    private void OnUserInputResult(object result)
    {
        // Handle user input result
        Console.WriteLine($"User input result: {result}");
    }
}

public enum NotificationType
{
    Basic,
    WithBooleanReturn,
    WithCheckStateReturn
}
```

### Application-Wide Notification System

```csharp
public class ApplicationNotificationSystem
{
    private static KryptonToastNotificationManager? _instance;
    private static readonly object _lock = new object();

    public static KryptonToastNotificationManager Instance
    {
        get
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = new KryptonToastNotificationManager();
                    }
                }
            }
            return _instance;
        }
    }

    public static void ShowInfo(string title, string message)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Information
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    public static void ShowWarning(string title, string message)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Warning
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    public static void ShowError(string title, string message)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Error
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    public static bool ShowQuestion(string title, string message, bool showDoNotShowAgain = false)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Question,
            ShowDoNotShowAgain = showDoNotShowAgain
        };

        return KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
    }

    public static void ShowProgress(string title, string message, int progress, int maximum)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }
}
```

## Integration Patterns

### Form Integration

```csharp
public partial class MainForm : Form
{
    private KryptonToastNotificationManager toastManager;

    public MainForm()
    {
        InitializeComponent();
        SetupToastManager();
    }

    private void SetupToastManager()
    {
        toastManager = new KryptonToastNotificationManager();
        Components.Add(toastManager);
    }

    private void OnUpdateAvailable()
    {
        ApplicationNotificationSystem.ShowQuestion(
            "Update Available", 
            "A new version is available. Would you like to update now?",
            showDoNotShowAgain: true);
    }

    private void OnOperationProgress(int progress, int maximum)
    {
        ApplicationNotificationSystem.ShowProgress(
            "Operation Progress",
            "Processing your request...",
            progress,
            maximum);
    }

    private void OnOperationComplete()
    {
        ApplicationNotificationSystem.ShowInfo(
            "Operation Complete",
            "Your operation has been completed successfully.");
    }

    private void OnOperationError(string errorMessage)
    {
        ApplicationNotificationSystem.ShowError(
            "Operation Failed",
            errorMessage);
    }
}
```

### Service Integration

```csharp
public class NotificationService
{
    private KryptonToastNotificationManager notificationManager;
    private readonly ILogger logger;

    public NotificationService(ILogger logger)
    {
        this.logger = logger;
        notificationManager = new KryptonToastNotificationManager();
    }

    public async Task ShowAsyncOperationProgress(string operationName, Func<Task> operation)
    {
        var progress = 0;
        var maximum = 100;

        // Show initial progress
        ShowProgress(operationName, "Starting operation...", progress, maximum);

        try
        {
            // Simulate progress updates
            var progressTimer = new Timer(100);
            progressTimer.Elapsed += (s, e) =>
            {
                progress += 10;
                if (progress <= maximum)
                {
                    ShowProgress(operationName, $"Operation in progress... {progress}%", progress, maximum);
                }
                else
                {
                    progressTimer.Stop();
                    progressTimer.Dispose();
                }
            };
            progressTimer.Start();

            // Execute the actual operation
            await operation();

            // Show completion
            ShowInfo(operationName, "Operation completed successfully!");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Operation failed: {OperationName}", operationName);
            ShowError(operationName, $"Operation failed: {ex.Message}");
        }
    }

    private void ShowProgress(string title, string message, int progress, int maximum)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    private void ShowInfo(string title, string message)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Information
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    private void ShowError(string title, string message)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Error
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }
}
```

### MVVM Integration

```csharp
public class NotificationViewModel : INotifyPropertyChanged
{
    private KryptonToastNotificationManager notificationManager;
    private string _statusMessage;
    private int _progressValue;
    private int _progressMaximum;

    public NotificationViewModel()
    {
        notificationManager = new KryptonToastNotificationManager();
        StatusMessage = "Ready";
        ProgressValue = 0;
        ProgressMaximum = 100;
    }

    public string StatusMessage
    {
        get => _statusMessage;
        set
        {
            _statusMessage = value;
            OnPropertyChanged();
        }
    }

    public int ProgressValue
    {
        get => _progressValue;
        set
        {
            _progressValue = value;
            OnPropertyChanged();
        }
    }

    public int ProgressMaximum
    {
        get => _progressMaximum;
        set
        {
            _progressMaximum = value;
            OnPropertyChanged();
        }
    }

    public ICommand ShowNotificationCommand => new RelayCommand(ShowNotification);
    public ICommand ShowProgressCommand => new RelayCommand(ShowProgress);
    public ICommand ShowUserInputCommand => new RelayCommand(ShowUserInput);

    private void ShowNotification()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Notification",
            Message = StatusMessage,
            Icon = MessageBoxIcon.Information
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    private void ShowProgress()
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = "Progress",
            Message = "Operation in progress...",
            Icon = MessageBoxIcon.Information,
            ProgressValue = ProgressValue,
            ProgressMaximum = ProgressMaximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    private void ShowUserInput()
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = "User Input",
            Message = "Please select an option:",
            ComboBoxItems = new[] { "Option 1", "Option 2", "Option 3" },
            SelectedIndex = 0
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        if (result != null)
        {
            StatusMessage = $"Selected: {result}";
        }
    }

    public event PropertyChangedEventHandler? PropertyChanged;

    protected virtual void OnPropertyChanged([CallerMemberName] string? propertyName = null)
    {
        PropertyChanged?.Invoke(this, new PropertyChangedEventArgs(propertyName));
    }
}

public class RelayCommand : ICommand
{
    private readonly Action _execute;
    private readonly Func<bool>? _canExecute;

    public RelayCommand(Action execute, Func<bool>? canExecute = null)
    {
        _execute = execute ?? throw new ArgumentNullException(nameof(execute));
        _canExecute = canExecute;
    }

    public event EventHandler? CanExecuteChanged
    {
        add { CommandManager.RequerySuggested += value; }
        remove { CommandManager.RequerySuggested -= value; }
    }

    public bool CanExecute(object? parameter)
    {
        return _canExecute?.Invoke() ?? true;
    }

    public void Execute(object? parameter)
    {
        _execute();
    }
}
```

## Performance Considerations

- **Component Lifecycle**: Proper component management and disposal
- **Memory Management**: Efficient memory usage for notification management
- **Thread Safety**: Safe usage in multi-threaded environments
- **Resource Cleanup**: Automatic cleanup through Component base class

## Common Issues and Solutions

### Component Not Available in Toolbox

**Issue**: KryptonToastNotificationManager not showing in Visual Studio toolbox  
**Solution**: Ensure proper assembly reference and toolbox refresh:

```csharp
// The component should be available automatically
// If not, try:
// 1. Rebuild the solution
// 2. Reset Visual Studio toolbox
// 3. Check assembly references
```

### Notifications Not Showing

**Issue**: Toast notifications not appearing  
**Solution**: Ensure proper notification data configuration:

```csharp
var notificationData = new KryptonBasicToastNotificationData
{
    Title = "Title",
    Message = "Message",
    Icon = MessageBoxIcon.Information
    // Ensure all required properties are set
};

KryptonToastNotification.ShowBasicNotification(notificationData);
```

### Component Disposal Issues

**Issue**: Component not being disposed properly  
**Solution**: Add to form's Components collection:

```csharp
public partial class MainForm : Form
{
    private KryptonToastNotificationManager toastManager;

    public MainForm()
    {
        InitializeComponent();
        toastManager = new KryptonToastNotificationManager();
        Components.Add(toastManager); // Ensures proper disposal
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox**: Available with custom bitmap representation
- **Property Window**: Component properties available for configuration
- **Designer Support**: Full design-time support for component management

### Property Categories

- **Design**: Standard component design properties
- **Behavior**: Component behavior and configuration
- **Appearance**: Visual appearance properties

## Migration and Compatibility

### From Static Notification Methods

```csharp
// Old way (direct static calls)
// KryptonToastNotification.ShowBasicNotification(notificationData);

// New way (with component management)
var notificationManager = new KryptonToastNotificationManager();
// Use through ApplicationNotificationSystem or similar wrapper
ApplicationNotificationSystem.ShowInfo("Title", "Message");
```

### From Custom Notification Systems

```csharp
// Old way (custom notification system)
// CustomNotificationSystem.Show("Message", "Title");

// New way
var notificationManager = new KryptonToastNotificationManager();
var notificationData = new KryptonBasicToastNotificationData
{
    Title = "Title",
    Message = "Message",
    Icon = MessageBoxIcon.Information
};
KryptonToastNotification.ShowBasicNotification(notificationData);
```

## Real-World Integration Examples

### Enterprise Application Notification System

```csharp
public class EnterpriseNotificationSystem
{
    private static KryptonToastNotificationManager? _instance;
    private static readonly object _lock = new object();
    private readonly Dictionary<string, NotificationSettings> _notificationSettings;

    public EnterpriseNotificationSystem()
    {
        _notificationSettings = LoadNotificationSettings();
    }

    public static KryptonToastNotificationManager Instance
    {
        get
        {
            if (_instance == null)
            {
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        _instance = new KryptonToastNotificationManager();
                    }
                }
            }
            return _instance;
        }
    }

    public void ShowSystemNotification(NotificationLevel level, string title, string message, 
        string category = "General", bool showDoNotShowAgain = false)
    {
        var settings = GetNotificationSettings(category);
        if (!settings.Enabled)
            return;

        var icon = GetIconForLevel(level);
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = icon,
            ShowDoNotShowAgain = showDoNotShowAgain
        };

        switch (level)
        {
            case NotificationLevel.Info:
                KryptonToastNotification.ShowBasicNotification(notificationData);
                break;
            case NotificationLevel.Warning:
                KryptonToastNotification.ShowBasicNotification(notificationData);
                break;
            case NotificationLevel.Error:
                KryptonToastNotification.ShowBasicNotification(notificationData);
                break;
            case NotificationLevel.Question:
                bool result = KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
                OnQuestionResult(result, category);
                break;
        }

        LogNotification(level, title, message, category);
    }

    public void ShowOperationProgress(string operationId, string title, string message, 
        int progress, int maximum)
    {
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = title,
            Message = message,
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
        
        LogProgress(operationId, progress, maximum);
    }

    public void ShowUserDecision(string title, string message, string[] options, 
        string category = "UserDecision")
    {
        var inputData = new KryptonUserInputToastNotificationData
        {
            Title = title,
            Message = message,
            ComboBoxItems = options,
            SelectedIndex = 0
        };

        object result = KryptonToastNotification.ShowNotification(inputData);
        OnUserDecisionResult(result, category);
    }

    private MessageBoxIcon GetIconForLevel(NotificationLevel level)
    {
        return level switch
        {
            NotificationLevel.Info => MessageBoxIcon.Information,
            NotificationLevel.Warning => MessageBoxIcon.Warning,
            NotificationLevel.Error => MessageBoxIcon.Error,
            NotificationLevel.Question => MessageBoxIcon.Question,
            _ => MessageBoxIcon.Information
        };
    }

    private NotificationSettings GetNotificationSettings(string category)
    {
        if (_notificationSettings.TryGetValue(category, out var settings))
        {
            return settings;
        }
        return new NotificationSettings { Enabled = true };
    }

    private void OnQuestionResult(bool result, string category)
    {
        // Handle question result
        Console.WriteLine($"Question result for {category}: {result}");
    }

    private void OnUserDecisionResult(object result, string category)
    {
        // Handle user decision result
        Console.WriteLine($"User decision for {category}: {result}");
    }

    private void LogNotification(NotificationLevel level, string title, string message, string category)
    {
        // Implementation to log notification
        Console.WriteLine($"Notification: {level} - {title} - {message} - {category}");
    }

    private void LogProgress(string operationId, int progress, int maximum)
    {
        // Implementation to log progress
        Console.WriteLine($"Progress: {operationId} - {progress}/{maximum}");
    }

    private Dictionary<string, NotificationSettings> LoadNotificationSettings()
    {
        // Implementation to load notification settings
        return new Dictionary<string, NotificationSettings>();
    }
}

public enum NotificationLevel
{
    Info,
    Warning,
    Error,
    Question
}

public class NotificationSettings
{
    public bool Enabled { get; set; } = true;
    public bool ShowDoNotShowAgain { get; set; } = false;
    public int Timeout { get; set; } = 5000;
}
```

### Multi-Tenant Notification System

```csharp
public class MultiTenantNotificationSystem
{
    private readonly Dictionary<string, KryptonToastNotificationManager> _tenantManagers;
    private readonly object _lock = new object();

    public MultiTenantNotificationSystem()
    {
        _tenantManagers = new Dictionary<string, KryptonToastNotificationManager>();
    }

    public void ShowTenantNotification(string tenantId, string title, string message, 
        MessageBoxIcon icon = MessageBoxIcon.Information)
    {
        var manager = GetTenantManager(tenantId);
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = $"[{tenantId}] {title}",
            Message = message,
            Icon = icon
        };

        KryptonToastNotification.ShowBasicNotification(notificationData);
    }

    public void ShowTenantProgress(string tenantId, string title, string message, 
        int progress, int maximum)
    {
        var manager = GetTenantManager(tenantId);
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = $"[{tenantId}] {title}",
            Message = message,
            Icon = MessageBoxIcon.Information,
            ProgressValue = progress,
            ProgressMaximum = maximum
        };

        KryptonToastNotification.ShowBasicProgressBarNotification(notificationData);
    }

    public bool ShowTenantQuestion(string tenantId, string title, string message, 
        bool showDoNotShowAgain = false)
    {
        var manager = GetTenantManager(tenantId);
        var notificationData = new KryptonBasicToastNotificationData
        {
            Title = $"[{tenantId}] {title}",
            Message = message,
            Icon = MessageBoxIcon.Question,
            ShowDoNotShowAgain = showDoNotShowAgain
        };

        return KryptonToastNotification.ShowBasicNotificationWithBooleanReturnValue(notificationData);
    }

    private KryptonToastNotificationManager GetTenantManager(string tenantId)
    {
        lock (_lock)
        {
            if (!_tenantManagers.TryGetValue(tenantId, out var manager))
            {
                manager = new KryptonToastNotificationManager();
                _tenantManagers[tenantId] = manager;
            }
            return manager;
        }
    }

    public void RemoveTenant(string tenantId)
    {
        lock (_lock)
        {
            if (_tenantManagers.TryGetValue(tenantId, out var manager))
            {
                manager.Dispose();
                _tenantManagers.Remove(tenantId);
            }
        }
    }
}
```

## License and Attribution

This class is part of the Krypton Toolkit Suite under the BSD 3-Clause License. It provides a component-based approach to toast notification management with design-time support, enabling consistent notification handling across Krypton applications with proper component lifecycle management.
