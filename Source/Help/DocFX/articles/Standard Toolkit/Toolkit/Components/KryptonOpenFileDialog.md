# KryptonOpenFileDialog

## Overview

The `KryptonOpenFileDialog` class provides a Krypton-themed wrapper around the standard Windows file open dialog. It inherits from `FileDialogWrapper` (which inherits from `ShellDialogWrapper`) and implements `IDisposable` to provide enhanced appearance, consistent theming, and modern .NET functionality while maintaining full compatibility with the standard `OpenFileDialog`.

## Class Hierarchy

```
System.Object
└── Krypton.Toolkit.ShellDialogWrapper (abstract)
    └── Krypton.Toolkit.FileDialogWrapper (abstract)
        └── Krypton.Toolkit.KryptonOpenFileDialog
```

## Constructor and Initialization

```csharp
public KryptonOpenFileDialog()
```

The constructor initializes:
- **Internal Dialog**: Creates `OpenFileDialog` instance for native functionality
- **ShellDialogWrapper**: Sets up Krypton theming and window management
- **Dispose Support**: Implements proper resource cleanup

## Key Properties

### Multiselect Property

```csharp
[DefaultValue(false)]
public bool Multiselect { get; set; }
```

- **Purpose**: Controls whether multiple files can be selected simultaneously
- **Category**: Behavior
- **Default Value**: `false`
- **Affects**: `FileNames` collection vs `FileName` string

**Usage Example:**
```csharp
var dialog = new KryptonOpenFileDialog
{
    Multiselect = true,
    Title = "Select Multiple Images"
};

if (dialog.ShowDialog() == DialogResult.OK)
{
    foreach (string filename in dialog.FileNames)
    {
        ProcessImage(filename);
    }
}
```

### ReadOnlyChecked Property

```csharp
[DefaultValue(false)]
public bool ReadOnlyChecked { get; set; }
```

- **Purpose**: Gets or sets whether the read-only check box is initially checked
- **Category**: Behavior
- **Default Value**: `false`
- **Note**: Read-only checkbox is only shown when `ShowReadOnly` is enabled

**Usage Example:**
```csharp
var dialog = new KryptonOpenFileDialog
{
    ReadOnlyChecked = true,
    Title = "Open Configuration File"
};
```

### ShowReadOnly Property

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool ShowReadOnly { get; set; }
```

**Important**: This property throws `InvalidConstraintException` when accessed
- **Purpose**: Intentionally disabled to maintain modern dialog experience
- **Reason**: Windows 10+ doesn't support read-only checkbox in modern file dialogs
- **Alternative**: Handle read-only checking in your application logic

### SafeFileName Property

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public string SafeFileName { get; }
```

- **Purpose**: Gets the filename (without path) of the selected file
- **Returns**: Filename only, safe from malicious paths
- **Usage**: Safe for display or logging purposes

**Usage Example:**
```csharp
if (dialog.ShowDialog() == DialogResult.OK)
{
    string safeName = dialog.SafeFileName;
    // SafeName = "document.txt" (no path information)
    Logger.Info($"User selected file: {safeName}");
}
```

### SafeFileNames Property

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public string[] SafeFileNames { get; }
```

- **Purpose**: Gets filenames (without paths) of all selected files
- **Returns**: Array of safe filenames only
- **Usage**: Safe for display when `Multiselect` is enabled

## Inherited FileDialogWrapper Properties

All standard file dialog properties are inherited and work identically:

### File Path Properties

```csharp
// File name selection
public override string FileName { get; set; }
public override string[] FileNames { get; }

// Initial directory
public override string InitialDirectory { get; set; }

// File extensions
public override string DefaultExt { get; set; }
public override string Filter { get; set; }
public override int FilterIndex { get; set; }
```

### Behavior Properties

```csharp
// File validation
public override bool CheckFileExists { get; set; }
public override bool CheckPathExists { get; set; }
public override bool ValidateNames { get; set; }

// Extension handling
public override bool AddExtension { get; set; }
public override bool SupportMultiDottedExtensions { get; set; }

// Link handling
public override bool DereferenceLinks { get; set; }

// Directory behavior
public override bool RestoreDirectory { get; set; }
```

### Framework-Specific Properties (.NET 8.0+)

```csharp
#if NET8_0_OR_GREATER
public override Guid? ClientGuid { get; set; }
#endif
```

- **Purpose**: Associates GUID with dialog state for persistence
- **Availability**: .NET 8.0 and later
- **Use Cases**: Different dialog instances can have separate persisted states

### Events and Collections

```csharp
// File validation event
public override event CancelEventHandler? FileOk;

// Custom places for navigation
public override FileDialogCustomPlacesCollection CustomPlaces { get; }
```

## File Opening Method

### OpenFile Method

```csharp
public Stream OpenFile()
```

- **Purpose**: Opens the selected file with read-only permissions
- **Returns**: `Stream` for reading the file
- **Exception**: Throws `ArgumentNullException` if `FileName` is null
- **Usage**: Convenient method for immediate file access

**Usage Example:**
```csharp
var dialog = new KryptonOpenFileDialog
{
    Filter = "Text files (*.txt)|*.txt|All files (*.*)|*.*",
    FilterIndex = 1,
    CheckFileExists = true
};

if (dialog.ShowDialog() == DialogResult.OK)
{
    using (Stream fileStream = dialog.OpenFile())
    using (var reader = new StreamReader(fileStream))
    {
        string content = reader.ReadToEnd();
        ProcessFileContent(content);
    }
}
```

## Dialog Behavior and Configuration

### Standard File Open Properties

```csharp
public void ConfigureDocumentOpen()
{
    var dialog = new KryptonOpenFileDialog
    {
        Title = "Open Document",
        InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
        Filter = "Word Documents (*.docx)|*.docx|Word 97-2003 (*.doc)|*.doc|All Files (*.*)|*.*",
        FilterIndex = 1,
        CheckFileExists = true,
        ValidateNames = true,
        AddExtension = true,
        RestoreDirectory = false
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        OpenDocument(dialog.FileName);
    }
}
```

### Multi-File Selection

```csharp
public void ImportMultipleImages()
{
    var dialog = new KryptonOpenFileDialog
    {
        Title = "Import Images",
        Multiselect = true,
        Filter = "Image Files|*.jpg;*.jpeg;*.png;*.bmp;*.gif|All Files|*.*",
        InitialDirectory = GetLastUsedImageFolder(),
        CheckFileExists = true
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        List<string> imageFiles = dialog.FileNames.ToList();
        ImportImageBatch(imageFiles);
    }
}
```

### Safe File Operations

```csharp
public class SafeFileOperations
{
    private static readonly string[] DangerousExtensions = { ".exe", ".bat", ".cmd", ".ps1" };
    
    public string? SelectDocument()
    {
        var dialog = new KryptonOpenFileDialog
        {
            Title = "Select Document",
            Filter = "Safe Documents (*.txt;*.docx;*.pdf)|*.txt;*.docx;*.pdf|All Files|*.*",
            CheckFileExists = true,
            ValidateNames = true
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            string filename = dialog.SafeFileName.ToLowerInvariant();
            
            if (DangerousExtensions.Any(ext => filename.EndsWith(ext)))
            {
                MessageBox.Show("This file type is not allowed.", "Security Warning", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return null;
            }
            
            return dialog.FileName;
        }

        return null;
    }
}
```

## Advanced Usage Patterns

### File Type Validation

```csharp
public class FileValidator
{
    public ValidationResult ValidateSelectedFile(KryptonOpenFileDialog dialog)
    {
        var result = new ValidationResult();

        // Check if file was actually selected
        if (string.IsNullOrEmpty(dialog.FileName))
        {
            result.AddError("No file selected");
            return result;
        }

        // File existence check
        if (dialog.CheckFileExists && !File.Exists(dialog.FileName))
        {
            result.AddError("Selected file does not exist");
            return result;
        }

        // Size validation
        var fileInfo = new FileInfo(dialog.FileName);
        if (fileInfo.Length > MaxAllowedFileSize)
        {
            result.AddError($"File too large: {fileInfo.Length:N0} bytes (max: {MaxAllowedFileSize:N0})");
            return result;
        }

        // Extension validation
        string allowedExtensions = dialog.Filter.Split('|')[dialog.FilterIndex * 2 - 2];
        var pattern = new Regex(allowedExtensions.Replace("*", ".*"));
        if (!pattern.IsMatch(dialog.FileName))
        {
            result.AddError("File extension not allowed");
            return result;
        }

        result.IsValid = true;
        return result;
    }
}
```

### Dialog State Persistence

```csharp
public class PersistentFileDialog : KryptonOpenFileDialog
{
    private static readonly string SettingsFile = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
        "MyApp", "DialogSettings.json");

    public PersistentFileDialog()
    {
        LoadSettings();
    }

    protected override void OnFileOk(CancelEventArgs e)
    {
        if (!e.Cancel)
        {
            SaveSettings();
        }
        base.OnFileOk(e);
    }

    private void LoadSettings()
    {
        try
        {
            if (File.Exists(SettingsFile))
            {
                var settings = JsonConvert.DeserializeObject<DialogSettings>(File.ReadAllText(SettingsFile));
                InitialDirectory = settings.LastDirectory;
                FilterIndex = settings.LastFilterIndex;
                Filter = settings.LastFilter;
            }
        }
        catch
        {
            // Use defaults
            InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
        }
    }

    private void SaveSettings()
    {
        try
        {
            var settings = new DialogSettings
            {
                LastDirectory = Path.GetDirectoryName(FileName) ?? InitialDirectory,
                LastFilterIndex = FilterIndex,
                LastFilter = Filter
            };

            var directory = Path.GetDirectoryName(SettingsFile);
            Directory.CreateDirectory(directory!);
            File.WriteAllText(SettingsFile, JsonConvert.SerializeObject(settings, Formatting.Indented));
        }
        catch
        {
            // Ignore save errors
        }
    }
}
```

### Multi-Selection with Validation

```csharp
public class BatchFileProcessor
{
    public void ProcessBatch()
    {
        var dialog = new KryptonOpenFileDialog
        {
            Title = "Select Files for Processing",
            Multiselect = true,
            Filter = "Supported Files|*.txt;*.csv;*.json|All Files|*.*",
            CheckFileExists = true
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            var validFiles = ValidateFiles(dialog.FileNames);
            
            if (validFiles.Count != dialog.FileNames.Length)
            {
                var invalidFiles = dialog.FileNames.Except(validFiles).ToArray();
                ShowInvalidFilesWarning(invalidFiles);
            }

            if (validFiles.Any())
            {
                ProcessFilesAsync(validFiles);
            }
        }
    }

    private List<string> ValidateFiles(string[] files)
    {
        var validFiles = new List<string>();

        foreach (string file in files)
        {
            try
            {
                var fileInfo = new FileInfo(file);
                if (fileInfo.Exists && fileInfo.Length <= MaxFileSize && IsFileFormatSupported(file))
                {
                    validFiles.Add(file);
                }
            }
            catch
            {
                // Skip invalid files
            }
        }

        return validFiles;
    }
}
```

## Custom Places Integration

```csharp
public class FileDialogWithCustomPlaces : KryptonOpenFileDialog
{
    public FileDialogWithCustomPlaces()
    {
        InitializeCustomPlaces();
    }

    private void InitializeCustomPlaces()
    {
        // Add application-specific folders
        CustomPlaces.Add("My Documents", Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments));
        CustomPlaces.Add("Desktop", Environment.GetFolderPath(Environment.SpecialFolder.Desktop));
        
        // Add project folders
        CustomPlaces.Add("Documents", @"C:\MyApp\Documents");
        CustomPlaces.Add("Templates", @"C:\MyApp\Templates");
        CustomPlaces.Add("Backups", @"C:\MyApp\Backups");
        
        // Add network locations (if accessible)
        try
        {
            CustomPlaces.Add("Network Drive", @"\\Server\Shared");
        }
        catch
        {
            // Network location not accessible
        }
    }
}
```

## Event Handling

### FileOk Event Usage

```csharp
public void ConfigureWithValidation()
{
    var dialog = new KryptonOpenFileDialog
    {
        Title = "Open Project File",
        Filter = "Project Files (*.proj)|*.proj|All Files|*.*",
        CheckFileExists = true
    };

    dialog.FileOk += (sender, e) =>
    {
        // Pre-validation before dialog closes
        if (!ValidateProjectFile(dialog.FileName))
        {
            e.Cancel = true;
            MessageBox.Show("Invalid project file format.", "Validation Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
        else
        {
            LogFileSelection(dialog.SafeFileName);
        }
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        LoadProject(dialog.FileName);
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: All properties properly categorized and exposed
- **Custom Editors**: Specialized editors for filter strings and custom places
- **Serialization**: Design-time settings saved to designer files

### Property Categories

- **Behavior**: Dialog behavior (`Multiselect`, `ReadOnlyChecked`, file validation properties)
- **Data**: File selection properties (`FileName`, `FileNames`, `InitialDirectory`)
- **Appearance**: Visual customization (inherited from `ShellDialogWrapper`)

## Performance Considerations

- **Memory Management**: Proper disposal prevents memory leaks
- **File Enumeration**: Large directories handled efficiently by Windows
- **Filter Performance**: Complex filter patterns may slow file enumeration
- **Multi-Selection**: Memory usage scales with number of selected files

## Common Issues and Solutions

### ShowReadOnly Access Errors

**Issue**: `InvalidConstraintException` when accessing `ShowReadOnly`  
**Solution**: This is intended behavior; read-only functionality implemented in application layer

### Multi-Selection Not Working

**Issue**: Only single file selection despite `Multiselect = true`  
**Solution**: Ensure filters support multiple files or use "All Files" pattern

### File Access Denied

**Issue**: File appears in dialog but cannot be opened  
**Solution**: Implement proper exception handling around file operations:

```csharp
try
{
    using (Stream stream = dialog.OpenFile())
    {
        // File operations
    }
}
catch (UnauthorizedAccessException)
{
    MessageBox.Show("Access denied to selected file.", "Error", 
        MessageBoxButtons.OK, MessageBoxIcon.Error);
}
```

### Filter Syntax Confusion

**Issue**: Filter not working as expected  
**Solution**: Use proper filter syntax:

```csharp
// Correct format
Filter = "Text Files (*.txt)|*.txt|Image Files (*.jpg;*.png)|*.jpg;*.png|All Files (*.*)|*.*";

// Format description: "Display Text|Pattern|Display Text|Pattern|..."
```

## Migration from Standard OpenFileDialog

### Direct Replacement

```csharp
// Old code
using OpenFileDialog = System.Windows.Forms.OpenFileDialog;
var dialog = new OpenFileDialog();

// New code
var dialog = new KryptonOpenFileDialog();
```

### Enhanced Features

```csharp
// Standard OpenFileDialog (basic)
var standardDialog = new OpenFileDialog();

// KryptonOpenFileDialog (enhanced)
var kryptonDialog = new KryptonOpenFileDialog
{
    Title = "Enhanced File Selection",  // Custom title support
    Multiselect = true,                 // Multi-selection
    CheckFileExists = true,             // Validation
    ValidateNames = true               // Name validation
};

// Additional framework-specific features (.NET 8.0+)
#if NET8_0_OR_GREATER
kryptonDialog.ClientGuid = Guid.NewGuid();  // State persistence
#endif
```

## Real-World Integration Examples

### Project File Manager

```csharp
public class ProjectManager
{
    public Project? OpenProject()
    {
        var dialog = new KryptonOpenFileDialog
        {
            Title = "Open Project",
            InitialDirectory = GetProjectsDirectory(),
            Filter = "Project Files (*.proj)|*.proj|All Files|*.*",
            CheckFileExists = true,
            ValidateNames = true
        };

        dialog.FileOk += OnProjectFileValidating;

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            return LoadProjectFromFile(dialog.FileName);
        }

        return null;
    }

    private void OnProjectFileValidating(object? sender, CancelEventArgs e)
    {
        if (sender is KryptonOpenFileDialog dialog)
        {
            if (!IsValidProjectFile(dialog.FileName))
            {
                MessageBox.Show("Invalid project file format.", "Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                e.Cancel = true;
            }
        }
    }
}
```

### Image Import Workflow

```csharp
public class ImageImporter
{
    public List<string> ImportImages(bool multipleSelection = true)
    {
        var dialog = new KryptonOpenFileDialog
        {
            Title = multipleSelection ? "Import Images" : "Import Image",
            Multiselect = multipleSelection,
            Filter = "Image Files (*.jpg;*.jpeg;*.png;*.bmp;*.gif)|*.jpg;*.jpeg;*.png;*.bmp;*.gif|All Files|*.*",
            InitialDirectory = GetLastUsedImageDirectory(),
            CheckFileExists = true
        };

        if (dialog.ShowDialog() == DialogResult.OK)
       � {
            var selectedFiles = multipleSelection 
                ? dialog.FileNames.ToList() 
                : new List<string> { dialog.FileName };

            // Validate and filter images
            var validImages = selectedFiles.Where(IsValidImageFile).ToList();
            
            if (validImages.Count != selectedFiles.Count)
            {
                ShowImageValidationWarning(selectedFiles.Count - validImages.Count);
            }

            return validImages;
        }

        return new List<string>();
    }
}
```