# KryptonPrintDialog

## Overview

The `KryptonPrintDialog` class provides a Krypton-themed wrapper around the standard Windows print dialog. It inherits from `CommonDialog` and implements comprehensive printer selection, page range configuration, and print settings management while maintaining full compatibility with the .NET printing framework and providing enhanced UI theming.

## Class Hierarchy

```
System.Object
└── System.ComponentModel.Component
    └── System.Windows.Forms.CommonDialog
        └── Krypton.Toolkit.KryptonPrintDialog
```

## Constructor and Initialization

```csharp
public KryptonPrintDialog()
```

The constructor initializes enhanced features:
- **CommonDialogHandler**: Creates handler with embedding support enabled
- **Default Icon**: Sets `DialogImageResources.Printer_V10` for printer icon
- **Click Callback**: Handles radio button interactions for print range selection
- **Print Dialog Structure**: Prepares 32-bit and 64-bit PRINTDLG structures

## Key Properties

### Title Property

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public string Title { get; set; }
```

- **Purpose**: Sets the caption text shown in the dialog's title bar
- **Category**: Appearance
- **Default Value**: Empty string (uses system default)

### Icon Property

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
public Icon Icon { get; set; }
```

- **Purpose**: Sets a custom icon displayed in the dialog's title bar
- **Category**: Appearance
- **Default Value**: `DialogImageResources.Printer_V10`

### ShowIcon Property

```csharp
[DefaultValue(false)]
public bool ShowIcon { get; set; }
```

- **Purpose**: Controls whether the dialog displays an icon in the title bar
- **Category**: Appearance
- **Default Value**: `false`

### Document Property

```csharp
[DefaultValue(null)]
public PrintDocument? Document { get; set; }
```

- **Purpose**: Sets the PrintDocument used to obtain PrinterSettings
- **Category**: Data
- **Default Value**: `null`
- **Side Effects**: Automatically configures `PrinterSettings` when document is provided

**Usage Example:**
```csharp
var dialog = new KryptonPrintDialog
{
    Document = myPrintDocument,
    Title = "Print Document"
};
```

### PrinterSettings Property

```csharp
[AllowNull]
public PrinterSettings PrinterSettings { get; set; }
```

- **Purpose**: Gets or sets the PrinterSettings the dialog will modify
- **Category**: Data
- **Default Value**: New `PrinterSettings()` instance
- **Designer Visibility**: Hidden from designer

### Print Range Properties

```csharp
[DefaultValue(false)]
public bool AllowCurrentPage { get; set; }

[DefaultValue(false)]
public bool AllowSomePages { get; set; }

[DefaultValue(true)]
public bool AllowPrintToFile { get; set; }

[DefaultValue(false)]
public bool AllowSelection { get; set; }
```

**Page Range Control Properties:**
- **AllowCurrentPage**: Enables current page printing option
- **AllowSomePages**: Enables page range specification (FROM...TO)
- **AllowPrintToFile**: Shows print-to-file checkbox
- **AllowSelection**: Enables selection-based printing

### Additional Behavior Properties

```csharp
[DefaultValue(false)]
public bool PrintToFile { get; set; }

[DefaultValue(false)]
public bool ShowHelp { get; set; }

[DefaultValue(true)]
public bool ShowNetwork { get; set; }
```

**Print Configuration Properties:**
- **PrintToFile**: Whether print-to-file checkbox is checked
- **ShowHelp**: Whether Help button is displayed
- **ShowNetwork**: Whether Network button is displayed

## Print Dialog Configuration

### Basic Print Setup

```csharp
public void ShowPrintDialog(PrintDocument document)
{
    var dialog = new KryptonPrintDialog
    {
        Title = "Print Document",
        Document = document,
        AllowSomePages = true,
        AllowPrintToFile = true,
        ShowNetwork = true
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        // User clicked Print - PrintDocument.Print() will be called
        // Dialog configuration is automatic via Document property
    }
}
```

### Advanced Print Configuration

```csharp
public void ConfigureAdvancedPrinting()
{
    var printerSettings = new PrinterSettings();
    var pageSettings = new PageSettings();

    var dialog = new KryptonPrintDialog
    {
        Title = "Advanced Print Configuration",
        PrinterSettings = printerSettings,
        AllowCurrentPage = true,
        AllowSomePages = true,
        AllowSelection = true,
        AllowPrintToFile = true,
        ShowHelp = false,
        ShowNetwork = true,
        PrintToFile = false
    };

    if (dialog.ShowDialog() == DialogResult.OK)
    {
        // Configure page settings
        var document = new PrintDocument
        {
            PrinterSettings = printerSettings,
            DefaultPageSettings = pageSettings
        };

        // Apply configured settings
        ApplyPrintSettings(document, printerSettings);
        
        // Start printing process
        document.Print();
    }
}
```

### Printer-Specific Configuration

```csharp
public class PrinterManager
{
    public PrintDocument ConfigurePrinterDocument()
    {
        var document = new PrintDocument();
        
        var dialog = new KryptonPrintDialog
        {
            Document = document,
            Title = "Select Printer & Settings",
            AllowSomePages = true,
            AllowPrintToFile = false  // Disable print-to-file
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            // PrinterSettings automatically configured
            ValidatePrinterSettings(document.PrinterSettings);
            return document;
        }

        return null;
    }

    private void ValidatePrinterSettings(PrinterSettings settings)
    {
        // Verify printer supports required features
        if (!settings.IsValid)
        {
            MessageBox.Show("Selected printer is not available.", "Printer Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }
}
```

## Advanced Print Configuration

### Custom Page Range Handling

```csharp
public class PageRangeManager
{
    private PrintDocument document;
    private List<int> pagesToPrint = new List<int>();

    public void ConfigurePageRange()
    {
        var dialog = new KryptonPrintDialog
        {
            Title = "Print with Custom Page Range",
            Document = document,
            AllowSomePages = true,
            AllowCurrentPage = false,
            AllowSelection = false  // Focus on page ranges only
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            ProcessPageRange(dialog.PrinterSettings);
        }
    }

    private void ProcessPageRange(PrinterSettings settings)
    {
        switch (settings.PrintRange)
        {
            case PrintRange.AllPages:
                pagesToPrint = GenerateAllPages();
                break;
            case PrintRange.SomePages:
                pagesToPrint = GeneratePageRange(settings.FromPage, settings.ToPage);
                break;
            case PrintRange.CurrentPage:
                pagesToPrint = GenerateCurrentPage();
                break;
            case PrintRange.Selection:
                pagesToPrint = GenerateSelectionPages();
                break;
        }

        // Apply custom page processing
        ApplyCustomPageFilter();
    }

    private List<int> GeneratePageRange(int fromPage, int toPage)
    {
        var pages = new List<int>();
        for (int i = fromPage; i <= toPage; i++)
        {
            pages.Add(i);
        }
        return pages;
    }
}
```

### Print Quality and Duplex Management

```csharp
public class PrintQualityManager
{
    public void ConfigurePrintQuality()
    {
        var printerSettings = new PrinterSettings();
        
        var dialog = new KryptonPrintDialog
        {
            Title = "Quality Print Configuration",
            PrinterSettings = printerSettings,
            AllowPrintToFile = false
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            // Advanced printer settings configuration
            ConfigureAdvancedSettings(printerSettings);
        }
    }

    private void ConfigureAdvancedSettings(PrinterSettings settings)
    {
        // Configure duplex printing if supported
        if (settings.CanDuplex)
        {
            settings.Duplex = Duplex.Horizontal;
        }

        // Configure print quality
        ConfigurePrintQuality(settings);
        
        // Configure paper source
        ConfigurePaperSource(settings);
        
        // Configure orientation
        ConfigureOrientation(settings);
    }

    private void ConfigurePrintQuality(PrinterSettings settings)
    {
        // Available printer resolutions
        var resolutions = settings.PrinterResolutions;
        var highestResolution = resolutions.Cast<PrinterResolution>()
            .OrderByDescending(r => r.X * r.Y)
            .First();

        // Apply highest quality if available
        if (highestResolution.Kind == PrinterResolutionKind.High)
        {
            settings.DefaultPageSettings.PrinterResolution = highestResolution;
        }
    }
}
```

## Print Job Management

### Background Printing

```csharp
public class BackgroundPrintService
{
    private PrintDocument? currentDocument;
    private BackgroundWorker? printWorker;

    public void PrintDocumentAsync(PrintDocument document)
    {
        var dialog = new KryptonPrintDialog
        {
            Title = "Background Print Job",
            Document = document,
            AllowPrintToFile = true
        };

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            StartBackgroundPrint(document);
        }
    }

    private void StartBackgroundPrint(PrintDocument document)
    {
        currentDocument = document;
        printWorker = new BackgroundWorker
        {
            WorkerReportsProgress = true
        };

        printWorker.DoWork += OnPrintWork;
        printWorker.ProgressChanged += OnPrintProgress;
        printWorker.RunWorkerCompleted += OnPrintCompleted;

        printWorker.RunWorkerAsync();
    }

    private void OnPrintWork(object? sender, DoWorkEventArgs e)
    {
        if (currentDocument != null)
        {
            currentDocument.Print();
        }
    }

    private void OnPrintProgress(object? sender, ProgressChangedEventArgs e)
    {
        UpdatePrintProgress(e.ProgressPercentage);
    }

    private void OnPrintCompleted(object? sender, RunWorkerCompletedEventArgs e)
    {
        if (e.Error != null)
        {
            MessageBox.Show($"Print failed: {e.Error.Message}", "Print Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        else
        {
            MessageBox.Show("Print job completed successfully.", "Print Complete", 
                MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        currentDocument = null;
        printWorker?.Dispose();
        printWorker = null;
    }
}
```

### Print Queue Management

```csharp
public class PrintQueueManager
{
    public async Task<bool> QueuePrintJob(PrintDocument document)
    {
        var dialog = new KryptonPrintDialog
        {
            Title = "Queue Print Job",
            Document = document,
            ShowHelp = true
        };

        var result = dialog.ShowDialog();
        if (result == DialogResult.OK)
        {
            // Queue the print job
            return await QueueDocument(document);
        }

        return false;
    }

    private async Task<bool> QueueDocument(PrintDocument document)
    {
        try
        {
            // Simulate asynchronous print queuing
            await Task.Run(() =>
            {
                // Add to print queue
                PrintQueue.Add(document);
                
                // Process queue
                ProcessPrintQueue();
            });

            return true;
        }
        catch (Exception ex)
        {
            LogPrintError(ex);
            return false;
        }
    }

    private void ProcessPrintQueue()
    {
        // Implementation for queued print processing
        foreach (var document in PrintQueue.GetQueue())
        {
            ExecutePrintJob(document);
        }
    }
}
```

## Error Handling and Validation

### Printer Availability Checking

```csharp
public class PrinterValidator
{
    public bool ValidatePrintSetup(out string errorMessage)
    {
        errorMessage = string.Empty;

        try
        {
            var printSettings = new PrinterSettings();
            
            if (!printSettings.IsValid)
            {
                errorMessage = "No printers are installed on this system.";
                return false;
            }

            if (!printSettings.IsPlotter)
            {
                // Check for common printer issues
                if (!printSettings.SupportsColor && RequiresColor())
                {
                    errorMessage = "Selected printer does not support color printing.";
                    return false;
                }
            }

            return true;
        }
        catch (Exception ex)
        {
            errorMessage = $"Printer validation error: {ex.Message}";
            return false;
        }
    }

    private bool RequiresColor()
    {
        // Determine if current document requires color printing
        return DocumentHasColor();
    }

    public DialogResult ShowValidatedPrintDialog(PrintDocument document)
    {
        if (!ValidatePrintSetup(out string errorMessage))
        {
            MessageBox.Show(errorMessage, "Print Setup Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return DialogResult.Cancel;
        }

        var dialog = new KryptonPrintDialog
        {
            Document = document,
            Title = "Validated Print Setup"
        };

        return dialog.ShowDialog();
    }
}
```

## Custom Print Document Integration

### Multi-Page Document Handler

```csharp
public class MultiPagePrintDocument : PrintDocument
{
    private List<string> pages = new List<string>();
    private int currentPageIndex = 0;

    public MultiPagePrintDocument(List<string> contentPages)
    {
        pages = contentPages ?? new List<string>();
        
        // Configure base settings
        PrintPage += OnPrintPage;
        BeginPrint += OnBeginPrint;
        EndPrint += OnEndPrint;
    }

    private void OnBeginPrint(object? sender, PrintEventArgs e)
    {
        currentPageIndex = 0;
    }

    private void OnPrintPage(object? sender, PrintPageEventArgs e)
    {
        if (currentPageIndex < pages.Count)
        {
            // Print current page content
            string pageContent = pages[currentPageIndex];
            DrawPageContent(e.Graphics, pageContent, e.PageBounds);
            
            currentPageIndex++;
            
            // Check if more pages to print
            e.HasMorePages = currentPageIndex < pages.Count;
        }
    }

    private void OnEndPrint(object? sender, PrintEventArgs e)
    {
        if (e.PrintAction == PrintAction.PrintToPrinter && !e.Cancel)
        {
            OnPrintCompleted?.Invoke(this, EventArgs.Empty);
        }
    }

    public event EventHandler<EventArgs>? OnPrintCompleted;

    private void DrawPageContent(Graphics g, string content, Rectangle bounds)
    {
        using var font = new Font("Arial", 12);
        using var brush = new SolidBrush(Color.Black);
        
        g.DrawString(content, font, brush, bounds);
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: All properties properly categorized and exposed
- **Default Events**: Configured with appropriate default event handler
- **Serialization**: Design-time settings saved to designer files

### Property Categories

- **Data**: Core print configuration (`Document`, `PrinterSettings`)
- **Behavior**: Print behavior properties (`AllowCurrentPage`, `AllowSomePages`, etc.)
- **Appearance**: Visual customization (`Title`, `Icon`, `ShowIcon`)

## Performance Considerations

- **Resource Management**: Proper cleanup of printer resources
- **Memory Usage**: Minimized memory footprint during print operations
- **Thread Safety**: Designed for safe background printing
- **Error Recovery**: Graceful handling of printer communication failures

## Common Issues and Solutions

### Printer Not Found

**Issue**: Printer settings show no available printers  
**Solution**: Check printer installation and availability:

```csharp
public bool CheckPrinterAvailability()
{
    var printers = PrinterSettings.InstalledPrinters;
    if (printers.Count == 0)
    {
        MessageBox.Show("No printers installed. Please install a printer first.", 
            "No Printers", MessageBoxButtons.OK, MessageBoxIcon.Information);
        return false;
    }
    return true;
}
```

### Print Range Validation

**Issue**: Invalid page ranges cause print failures  
**Solution**: Implement range validation:

```csharp
private bool ValidatePageRange(PrinterSettings settings)
{
    if (settings.PrintRange == PrintRange.SomePages)
    {
        var document = settings.PrintDocument;
        int pageCount = GetDocumentPageCount(document);
        
        if (settings.FromPage < 1 || settings.ToPage < 1 || 
            settings.FromPage > pageCount || settings.ToPage > pageCount ||
            settings.FromPage > settings.ToPage)
        {
            MessageBox.Show($"Invalid page range. Document has {pageCount} pages.", 
                "Invalid Range", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            return false;
        }
    }
    return true;
}
```

### Print Job Cancellation

**Issue**: Long print jobs cannot be cancelled  
**Solution**: Implement progress monitoring and cancellation:

```csharp
public class CancellablePrintDocument : PrintDocument
{
    private CancellationTokenSource? cancellationTokenSource;
    private bool isPrinting = false;

    public CancellationToken StartPrinting()
    {
        cancellationTokenSource = new CancellationTokenSource();
        isPrinting = true;
        return cancellationTokenSource.Token;
    }

    public void CancelPrinting()
    {
        cancellationTokenSource?.Cancel();
        isPrinting = false;
    }

    protected override void OnPrintPage(PrintPageEventArgs e)
    {
        if (!isPrinting || cancellationTokenSource?.IsCancellationRequested == true)
        {
            e.Cancel = true;
            return;
        }

        // Print page content
        base.OnPrintPage(e);
    }
}
```

## Migration from Standard PrintDialog

### Direct Replacement

```csharp
// Old code
using PrintDialog = System.Windows.Forms.PrintDialog;
var dialog = new PrintDialog();

// New code
var dialog = new KryptonPrintDialog();
```

### Enhanced Features

```csharp
// Standard PrintDialog (basic)
var standardDialog = new PrintDialog();

// KryptonPrintDialog (enhanced)
var kryptonDialog = new KryptonPrintDialog
{
    Title = "Enhanced Print Configuration",
    Icon = customPrintIcon,
    ShowIcon = true,
    AllowCurrentPage = true,
    AllowSomePages = true,
    AllowPrintToFile = true
};
```

## Real-World Integration Examples

### Document Management System

```csharp
public class DocumentPrintManager : Form
{
    private PrintDocument currentDocument;

    public void PrintDocument(IDocument document)
    {
        // Convert document to PrintDocument
        currentDocument = CreatePrintDocument(document);

        var dialog = new KryptonPrintDialog
        {
            Title = $"Print {document.Title}",
            Document = currentDocument,
            AllowSomePages = document.PageCount > 1,
            AllowSelection = document.HasSelection,
            AllowPrintToFile = true,
            Icon = document.FileIcon,
            ShowIcon = true
        };

        dialog.PrinterSettings.PrintRange = PrintRange.AllPages;
        
        if (dialog.ShowDialog() == DialogResult.OK)
        {
            // Configure additional settings based on user selection
            ConfigurePrintOptions(document, dialog.PrinterSettings);
            
            // Execute print job
            PerformPrintJob();
        }
    }

    private PrintDocument CreatePrintDocument(IDocument document)
    {
        var printDoc = new PrintDocument();
        
        // Configure printing events
        printDoc.BeginPrint += (s, e) => OnBeginDocumentPrint(document);
        printDoc.PrintPage += (s, e) => OnPrintDocumentPage(document, e);
        printDoc.EndPrint += (s, e) => OnEndDocumentPrint(document);
        
        return printDoc;
    }

    private void ConfigurePrintOptions(IDocument document, PrinterSettings settings)
    {
        // Configure document-specific printing options
        ConfigureColorPrinting(document, settings);
        ConfigurePageMargins(document, settings);
        ConfigureOrientation(document, settings);
    }
}
```

### Report Printing Service

```csharp
public class ReportPrintService
{
    public void PrintReport(IReport report)
    {
        var printDocument = CreateReportPrintDocument(report);
        
        var dialog = new KryptonPrintDialog
        {
            Title = $"Print Report: {report.Name}",
            Document = printDocument,
            AllowSomePages = report.PageCount > 1,
            ShowHelp = true,
            AllowPrintToFile = report.AllowFileOutput
        };

        // Preset common options
        dialog.PrinterSettings.DefaultPageSettings.Landscape = report.IsLandscape;
        dialog.PrinterSettings.Copies = report.DefaultCopies;

        if (dialog.ShowDialog() == DialogResult.OK)
        {
            // Apply report-specific configurations
            ApplyReportSettings(printDocument, report, dialog.PrinterSettings);
            
            // Execute print
            printDocument.Print();
            
            // Log print activity
            LogPrintActivity(report, dialog.PrinterSettings);
        }
    }

    private PrintDocument CreateReportPrintDocument(IReport report)
    {
        var document = new PrintDocument();
        
        // Configure report-specific printing
        ConfigureReportPrinting(document, report);
        
        return document;
    }

    private void ApplyReportSettings(PrintDocument document, IReport report, PrinterSettings settings)
    {
        // Apply complex report configurations
        ConfigureReportLayout(document, report);
        ConfigureDataSources(document, report);
        ConfigureOutputOptions(document, settings);
    }
}
```