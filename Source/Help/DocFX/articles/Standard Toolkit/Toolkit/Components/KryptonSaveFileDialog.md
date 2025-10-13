# KryptonSaveFileDialog

## Overview

The `KryptonSaveFileDialog` class provides a Krypton-themed wrapper around the standard Windows `SaveFileDialog`. It inherits from `FileSaveDialogWrapper` and implements `IDisposable` to provide enhanced appearance, consistent theming, and improved visual integration while maintaining full compatibility with the standard `SaveFileDialog` functionality.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.CommonDialog
            └── System.Windows.Forms.FileDialog
                └── System.Windows.Forms.SaveFileDialog
                    └── Krypton.Toolkit.FileSaveDialogWrapper
                        └── Krypton.Toolkit.KryptonSaveFileDialog
```

## Constructor and Initialization

```csharp
public KryptonSaveFileDialog()
```

The constructor initializes enhanced features:
- **Internal `SaveFileDialog`**: Creates and manages the contained `SaveFileDialog` instance
- **Theme Integration**: Automatic Krypton theming through FileSaveDialogWrapper
- **Full Compatibility**: All standard `SaveFileDialog` properties and methods are proxied

## Key Properties

### SaveFileDialog-Specific Properties

#### CreatePrompt Property

```csharp
[DefaultValue(false)]
public bool CreatePrompt { get; set; }
```

- **Purpose**: Prompts user for permission to create a file if the specified file doesn't exist
- **Category**: Behavior
- **Default Value**: false
- **Usage**: When you want to confirm file creation before proceeding

#### OverwritePrompt Property

```csharp
[DefaultValue(true)]
public bool OverwritePrompt { get; set; }
```

- **Purpose**: Displays a warning if the user specifies a file name that already exists
- **Category**: Behavior
- **Default Value**: true
- **Usage**: Prevents accidental overwriting of existing files

#### CheckWriteAccess Property (NET8_0_OR_GREATER)

```csharp
[DefaultValue(true)]
public bool CheckWriteAccess { get; set; }
```

- **Purpose**: Verifies if the creation of the specified file will be successful
- **Category**: Behavior
- **Default Value**: true
- **Availability**: .NET 8.0 and later
- **Usage**: Validates write permissions before showing the dialog

### Standard FileDialog Properties

All standard FileDialog properties are fully supported:

```csharp
// File and path properties
public string FileName { get; set; }
public string[] FileNames { get; }
public string DefaultExt { get; set; }
public string InitialDirectory { get; set; }

// Filter and validation
public string Filter { get; set; }
public int FilterIndex { get; set; }
public bool ValidateNames { get; set; }
public bool CheckFileExists { get; set; }
public bool CheckPathExists { get; set; }

// Behavior options
public bool AddExtension { get; set; }
public bool DereferenceLinks { get; set; }
public bool RestoreDirectory { get; set; }
public bool SupportMultiDottedExtensions { get; set; }

// Appearance
public string Title { get; set; }

// .NET 8.0+ features
public Guid? ClientGuid { get; set; }
public FileDialogCustomPlacesCollection CustomPlaces { get; }
```

## Key Methods

### OpenFile Method

```csharp
public Stream OpenFile()
```

- **Purpose**: Opens the file selected by the user with read-only permission
- **Returns**: Stream for the selected file
- **Exception**: ArgumentNullException if file name is null
- **Usage**: Direct file access after successful dialog result

### ShowActualDialog Method

```csharp
protected override DialogResult ShowActualDialog(IWin32Window? owner)
```

- **Purpose**: Internal method that displays the themed dialog
- **Returns**: DialogResult indicating user's choice
- **Implementation**: Delegates to the internal `SaveFileDialog` with Krypton theming

### Standard Methods

```csharp
public override void Reset()           // Resets all properties to defaults
public override string ToString()      // Returns string representation
public void Dispose()                  // Cleans up resources
```

## Events

### FileOk Event

```csharp
public override event CancelEventHandler? FileOk
```

- **Purpose**: Occurs when the user clicks Save in the dialog
- **Type**: CancelEventHandler
- **Usage**: Validate file selection or cancel the operation

## Advanced Usage Patterns

### Basic File Save

```csharp
public void SaveDocument()
{
    using var saveDialog = new KryptonSaveFileDialog
    {
        Title = "Save Document",
        Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*",
        FilterIndex = 1,
        DefaultExt = "txt",
        OverwritePrompt = true,
        CheckWriteAccess = true
    };

    if (saveDialog.ShowDialog() == DialogResult.OK)
    {
        // Save the file
        File.WriteAllText(saveDialog.FileName, documentContent);
    }
}
```

### Advanced Save with Validation

```csharp
public class DocumentSaver
{
    public bool SaveDocument(string content, string defaultName)
    {
        using var saveDialog = new KryptonSaveFileDialog
        {
            Title = "Save Document",
            FileName = defaultName,
            Filter = "Word Documents (*.docx)|*.docx|Rich Text (*.rtf)|*.rtf|Text Files (*.txt)|*.txt",
            FilterIndex = 1,
            DefaultExt = "docx",
            InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments),
            OverwritePrompt = true,
            CreatePrompt = false,
            CheckWriteAccess = true
        };

        // Add custom places for quick access
        saveDialog.CustomPlaces.Add(Environment.GetFolderPath(Environment.SpecialFolder.Desktop));
        saveDialog.CustomPlaces.Add(Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments));

        // Handle validation
        saveDialog.FileOk += OnFileOk;

        try
        {
            if (saveDialog.ShowDialog() == DialogResult.OK)
            {
                return SaveToFile(saveDialog.FileName, content, saveDialog.FilterIndex);
            }
        }
        finally
        {
            saveDialog.FileOk -= OnFileOk;
        }

        return false;
    }

    private void OnFileOk(object? sender, CancelEventArgs e)
    {
        if (sender is KryptonSaveFileDialog dialog)
        {
            // Validate file extension
            string extension = Path.GetExtension(dialog.FileName).ToLower();
            string expectedExt = GetExpectedExtension(dialog.FilterIndex);

            if (extension != expectedExt)
            {
                MessageBox.Show($"Please use the {expectedExt} extension.", "Invalid Extension", 
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
                e.Cancel = true;
            }
        }
    }

    private string GetExpectedExtension(int filterIndex)
    {
        return filterIndex switch
        {
            1 => ".docx",
            2 => ".rtf",
            3 => ".txt",
            _ => ".txt"
        };
    }

    private bool SaveToFile(string fileName, string content, int filterIndex)
    {
        try
        {
            switch (filterIndex)
            {
                case 1: // Word document
                    return SaveAsWordDocument(fileName, content);
                case 2: // Rich text
                    return SaveAsRichText(fileName, content);
                case 3: // Plain text
                    File.WriteAllText(fileName, content);
                    return true;
                default:
                    return false;
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error saving file: {ex.Message}", "Save Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }
    }
}
```

### Multi-Format Export

```csharp
public class ExportManager
{
    public void ExportData(DataTable data)
    {
        using var saveDialog = new KryptonSaveFileDialog
        {
            Title = "Export Data",
            Filter = "Excel Files (*.xlsx)|*.xlsx|CSV Files (*.csv)|*.csv|XML Files (*.xml)|*.xml",
            FilterIndex = 1,
            DefaultExt = "xlsx",
            InitialDirectory = GetLastExportDirectory(),
            OverwritePrompt = true
        };

        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            ExportToFormat(data, saveDialog.FileName, saveDialog.FilterIndex);
            SaveLastExportDirectory(Path.GetDirectoryName(saveDialog.FileName));
        }
    }

    private void ExportToFormat(DataTable data, string fileName, int formatIndex)
    {
        switch (formatIndex)
        {
            case 1: // Excel
                ExportToExcel(data, fileName);
                break;
            case 2: // CSV
                ExportToCsv(data, fileName);
                break;
            case 3: // XML
                ExportToXml(data, fileName);
                break;
        }
    }
}
```

### Configuration Save Dialog

```csharp
public class ConfigurationManager
{
    public void SaveConfiguration(AppSettings settings)
    {
        using var saveDialog = new KryptonSaveFileDialog
        {
            Title = "Save Configuration",
            Filter = "Configuration Files (*.config)|*.config|JSON Files (*.json)|*.json|XML Files (*.xml)|*.xml",
            FilterIndex = 1,
            DefaultExt = "config",
            InitialDirectory = GetConfigDirectory(),
            FileName = "MyAppSettings",
            OverwritePrompt = true,
            CheckWriteAccess = true
        };

        // Add application-specific custom places
        saveDialog.CustomPlaces.Add(GetConfigDirectory());
        saveDialog.CustomPlaces.Add(Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "MyApp"));

        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            SaveSettings(settings, saveDialog.FileName, saveDialog.FilterIndex);
        }
    }

    private void SaveSettings(AppSettings settings, string fileName, int formatIndex)
    {
        switch (formatIndex)
        {
            case 1: // .config format
                SaveAsConfig(settings, fileName);
                break;
            case 2: // JSON format
                SaveAsJson(settings, fileName);
                break;
            case 3: // XML format
                SaveAsXml(settings, fileName);
                break;
        }
    }
}
```

## Integration Patterns

### MVVM Pattern Integration

```csharp
public class SaveFileDialogService : ISaveFileDialogService
{
    public SaveFileResult ShowSaveDialog(SaveFileDialogOptions options)
    {
        using var dialog = new KryptonSaveFileDialog
        {
            Title = options.Title,
            Filter = options.Filter,
            FilterIndex = options.FilterIndex,
            DefaultExt = options.DefaultExtension,
            InitialDirectory = options.InitialDirectory,
            FileName = options.DefaultFileName,
            OverwritePrompt = options.OverwritePrompt,
            CreatePrompt = options.CreatePrompt
        };

        var result = new SaveFileResult();

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            result.Success = true;
            result.FileName = dialog.FileName;
            result.FilterIndex = dialog.FilterIndex;
        }

        return result;
    }
}

public class SaveFileDialogOptions
{
    public string Title { get; set; } = "Save File";
    public string Filter { get; set; } = "All Files (*.*)|*.*";
    public int FilterIndex { get; set; } = 1;
    public string DefaultExtension { get; set; } = string.Empty;
    public string InitialDirectory { get; set; } = string.Empty;
    public string DefaultFileName { get; set; } = string.Empty;
    public bool OverwritePrompt { get; set; } = true;
    public bool CreatePrompt { get; set; } = false;
}

public class SaveFileResult
{
    public bool Success { get; set; }
    public string FileName { get; set; } = string.Empty;
    public int FilterIndex { get; set; }
}
```

### Async File Operations

```csharp
public class AsyncFileSaver
{
    public async Task<bool> SaveFileAsync(string content, string defaultName)
    {
        var saveDialog = new KryptonSaveFileDialog
        {
            Title = "Save File",
            FileName = defaultName,
            Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*",
            FilterIndex = 1,
            DefaultExt = "txt",
            OverwritePrompt = true
        };

        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            try
            {
                await File.WriteAllTextAsync(saveDialog.FileName, content);
                return true;
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error saving file: {ex.Message}", "Save Error", 
                    MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
        }

        return false;
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: All standard `SaveFileDialog` properties available
- **Theme Integration**: Automatic Krypton theming applied
- **Serialization**: Design-time settings saved to designer files

### Property Categories

- **Behavior**: Core dialog functionality (`CreatePrompt`, `OverwritePrompt`, `CheckWriteAccess`)
- **Data**: File and path properties (`FileName`, `Filter`, `InitialDirectory`)
- **Appearance**: Visual properties (`Title`)

## Performance Considerations

- **Theme Integration**: Lightweight wrapper with minimal overhead
- **Memory Management**: Proper disposal of internal dialog resources
- **Thread Safety**: Standard Windows Forms thread safety applies
- **Resource Cleanup**: Automatic cleanup through IDisposable implementation

## Common Issues and Solutions

### File Access Denied

**Issue**: Save operation fails with access denied  
**Solution**: Use CheckWriteAccess property and handle exceptions:

```csharp
saveDialog.CheckWriteAccess = true;
saveDialog.FileOk += (sender, e) =>
{
    try
    {
        // Test write access
        File.WriteAllText(saveDialog.FileName, "test");
        File.Delete(saveDialog.FileName);
    }
    catch (UnauthorizedAccessException)
    {
        MessageBox.Show("Access denied to the selected location.", "Access Denied", 
            MessageBoxButtons.OK, MessageBoxIcon.Warning);
        e.Cancel = true;
    }
};
```

### Filter Not Working

**Issue**: File filter not applied correctly  
**Solution**: Ensure proper filter format:

```csharp
// Correct format: "Description|Pattern|Description|Pattern"
saveDialog.Filter = "Text Files (*.txt)|*.txt|All Files (*.*)|*.*";
saveDialog.FilterIndex = 1; // Select first filter
```

### Path Not Found

**Issue**: InitialDirectory doesn't exist  
**Solution**: Validate directory before setting:

```csharp
string initialDir = GetInitialDirectory();
if (Directory.Exists(initialDir))
{
    saveDialog.InitialDirectory = initialDir;
}
else
{
    saveDialog.InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyDocuments);
}
```

## Migration from Standard SaveFileDialog

### Direct Replacement

```csharp
// Old code
SaveFileDialog saveDialog = new SaveFileDialog();

// New code
KryptonSaveFileDialog saveDialog = new KryptonSaveFileDialog();
```

### Enhanced Features

```csharp
// Standard SaveFileDialog (basic)
var standardSfd = new SaveFileDialog();

// KryptonSaveFileDialog (enhanced)
var kryptonSfd = new KryptonSaveFileDialog
{
    Title = "Save Document",
    Filter = "Text Files (*.txt)|*.txt",
    OverwritePrompt = true,
    CreatePrompt = false,
    CheckWriteAccess = true, // .NET 8.0+ feature
    CustomPlaces = // Enhanced custom places support
};
```

## Real-World Integration Examples

### Document Editor Save

```csharp
public partial class DocumentEditor : Form
{
    private string currentDocument = string.Empty;
    private bool isModified = false;

    private void SaveDocument()
    {
        if (string.IsNullOrEmpty(currentDocument))
        {
            SaveAsDocument();
        }
        else
        {
            SaveToCurrentFile();
        }
    }

    private void SaveAsDocument()
    {
        using var saveDialog = new KryptonSaveFileDialog
        {
            Title = "Save Document As",
            Filter = "Rich Text Format (*.rtf)|*.rtf|Text Files (*.txt)|*.txt|Word Documents (*.docx)|*.docx",
            FilterIndex = 1,
            DefaultExt = "rtf",
            InitialDirectory = GetLastSaveDirectory(),
            OverwritePrompt = true,
            CheckWriteAccess = true
        };

        // Add recent folders as custom places
        foreach (string recentFolder in GetRecentFolders())
        {
            if (Directory.Exists(recentFolder))
            {
                saveDialog.CustomPlaces.Add(recentFolder);
            }
        }

        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            SaveToFile(saveDialog.FileName, saveDialog.FilterIndex);
            currentDocument = saveDialog.FileName;
            isModified = false;
            UpdateTitle();
            AddToRecentFiles(saveDialog.FileName);
        }
    }

    private void SaveToFile(string fileName, int formatIndex)
    {
        try
        {
            switch (formatIndex)
            {
                case 1: // RTF
                    richTextBox.SaveFile(fileName, RichTextBoxStreamType.RichText);
                    break;
                case 2: // TXT
                    File.WriteAllText(fileName, richTextBox.Text);
                    break;
                case 3: // DOCX
                    SaveAsWordDocument(fileName);
                    break;
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error saving file: {ex.Message}", "Save Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
```

### Image Export Dialog

```csharp
public class ImageExporter
{
    public void ExportImage(Image image)
    {
        using var saveDialog = new KryptonSaveFileDialog
        {
            Title = "Export Image",
            Filter = "PNG Files (*.png)|*.png|JPEG Files (*.jpg)|*.jpg|Bitmap Files (*.bmp)|*.bmp|TIFF Files (*.tiff)|*.tiff",
            FilterIndex = 1,
            DefaultExt = "png",
            InitialDirectory = Environment.GetFolderPath(Environment.SpecialFolder.MyPictures),
            OverwritePrompt = true,
            FileName = "ExportedImage"
        };

        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            ExportImageToFormat(image, saveDialog.FileName, saveDialog.FilterIndex);
        }
    }

    private void ExportImageToFormat(Image image, string fileName, int formatIndex)
    {
        try
        {
            switch (formatIndex)
            {
                case 1: // PNG
                    image.Save(fileName, ImageFormat.Png);
                    break;
                case 2: // JPEG
                    image.Save(fileName, ImageFormat.Jpeg);
                    break;
                case 3: // BMP
                    image.Save(fileName, ImageFormat.Bmp);
                    break;
                case 4: // TIFF
                    image.Save(fileName, ImageFormat.Tiff);
                    break;
            }
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Error exporting image: {ex.Message}", "Export Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
```