# KryptonIntegratedToolBarManager

## Overview

The `KryptonIntegratedToolBarManager` class provides a comprehensive toolbar management system for Krypton forms. It inherits from `Component` and offers integrated toolbar functionality with 14 predefined buttons, customizable orientation, alignment, and visibility controls. The manager handles the creation, attachment, and management of toolbar buttons within Krypton forms.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── Krypton.Toolkit.KryptonIntegratedToolBarManager
```

## Constructor and Initialization

```csharp
public KryptonIntegratedToolBarManager()
```

The constructor initializes enhanced features:
- **Toolbar Setup**: Creates 14 predefined toolbar buttons with default configurations
- **Default Values**: Sets up default orientation, alignment, and visibility settings
- **Button Array**: Initializes the integrated toolbar button array with all button types
- **Static Properties**: Provides access to shared button and command values

## Key Properties

### Core Properties

#### IntegratedToolBarButtons Property

```csharp
[Category("Visuals"), DefaultValue(null)]
public ButtonSpecAny[] IntegratedToolBarButtons { get; }
```

- **Purpose**: Contains all the integrated toolbar buttons
- **Category**: Visuals
- **Type**: Array of `ButtonSpecAny` objects
- **Usage**: Access to individual toolbar buttons for customization

#### IntegratedToolBarButtonOrientation Property

```csharp
[Category("Visuals"), DefaultValue(PaletteButtonOrientation.FixedTop)]
public PaletteButtonOrientation IntegratedToolBarButtonOrientation { get; set; }
```

- **Purpose**: Controls the orientation of toolbar buttons
- **Category**: Visuals
- **Available Values**:
  - `Inherit`: Inherit orientation from parent
  - `Auto`: Automatic orientation
  - `FixedTop`: Fixed top orientation (default)
  - `FixedBottom`: Fixed bottom orientation
  - `FixedLeft`: Fixed left orientation
  - `FixedRight`: Fixed right orientation

#### IntegratedToolBarButtonAlignment Property

```csharp
[Category("Visuals"), DefaultValue(PaletteRelativeEdgeAlign.Far)]
public PaletteRelativeEdgeAlign IntegratedToolBarButtonAlignment { get; set; }
```

- **Purpose**: Controls the alignment of toolbar buttons
- **Category**: Visuals
- **Available Values**:
  - `Inherit`: Inherit alignment from parent
  - `Near`: Near alignment
  - `Far`: Far alignment (default)

#### ParentForm Property

```csharp
[Category("Visuals"), DefaultValue(null)]
public KryptonForm? ParentForm { get; set; }
```

- **Purpose**: The parent form that contains the toolbar
- **Category**: Visuals
- **Type**: `KryptonForm` or null
- **Usage**: Associates the toolbar manager with a specific form

### Button Visibility Properties

All button visibility properties follow the same pattern:

```csharp
[Category("Visuals"), DefaultValue(false)]
public bool ShowNewButton { get; set; }
public bool ShowOpenButton { get; set; }
public bool ShowSaveButton { get; set; }
public bool ShowSaveAllButton { get; set; }
public bool ShowSaveAsButton { get; set; }
public bool ShowCutButton { get; set; }
public bool ShowCopyButton { get; set; }
public bool ShowPasteButton { get; set; }
public bool ShowUndoButton { get; set; }
public bool ShowRedoButton { get; set; }
public bool ShowPageSetupButton { get; set; }
public bool ShowPrintPreviewButton { get; set; }
public bool ShowPrintButton { get; set; }
public bool ShowQuickPrintButton { get; set; }
```

- **Purpose**: Control the visibility of individual toolbar buttons
- **Category**: Visuals
- **Default Value**: false (all buttons hidden by default)
- **Effect**: Automatically toggles button visibility when changed

### Static Properties

```csharp
public static IntegratedToolBarButtonValues IntegratedToolBarButtonValues { get; }
public static IntegratedToolBarCommandValues IntegratedToolBarCommandValues { get; }
```

- **Purpose**: Shared button and command values across all instances
- **Type**: Static properties for global configuration
- **Usage**: Centralized configuration for all toolbar managers

## Key Methods

### Core Management Methods

#### Reset Method

```csharp
public void Reset()
```

- **Purpose**: Resets the toolbar manager to default settings
- **Effect**: Restores all properties to their default values
- **Usage**: Initialize or restore toolbar to default state

#### ShowIntegrateToolBar Method

```csharp
public void ShowIntegrateToolBar(bool showIntegratedToolBar, KryptonForm parentForm)
```

- **Purpose**: Shows or hides the integrated toolbar on the parent form
- **Parameters**:
  - `showIntegratedToolBar`: Whether to show the toolbar
  - `parentForm`: The form to attach/detach the toolbar from
- **Usage**: Toggle toolbar visibility on a form

#### AttachIntegratedToolBarToParent Method

```csharp
public void AttachIntegratedToolBarToParent(KryptonForm? parentForm)
```

- **Purpose**: Attaches the integrated toolbar to the specified parent form
- **Parameters**:
  - `parentForm`: The form to attach the toolbar to
- **Exception**: `ArgumentNullException` if parentForm is null
- **Usage**: Add toolbar buttons to a form

#### DetachIntegratedToolBarFromParent Method

```csharp
public void DetachIntegratedToolBarFromParent(KryptonForm? parentForm)
```

- **Purpose**: Detaches the integrated toolbar from the specified parent form
- **Parameters**:
  - `parentForm`: The form to detach the toolbar from
- **Exception**: `ArgumentNullException` if parentForm is null
- **Usage**: Remove toolbar buttons from a form

### Configuration Methods

#### UpdateButtonOrientation Method

```csharp
public void UpdateButtonOrientation(PaletteButtonOrientation buttonOrientation)
```

- **Purpose**: Updates the orientation of all toolbar buttons
- **Parameters**:
  - `buttonOrientation`: The new orientation for all buttons
- **Exception**: `ArgumentOutOfRangeException` for invalid orientation
- **Usage**: Change button orientation dynamically

#### UpdateButtonAlignment Method

```csharp
public void UpdateButtonAlignment(PaletteRelativeEdgeAlign buttonAlignment)
```

- **Purpose**: Updates the alignment of all toolbar buttons
- **Parameters**:
  - `buttonAlignment`: The new alignment for all buttons
- **Exception**: `ArgumentOutOfRangeException` for invalid alignment
- **Usage**: Change button alignment dynamically

### Utility Methods

#### ReturnIntegratedToolBarButtonArray Method

```csharp
public ButtonSpecAny[] ReturnIntegratedToolBarButtonArray()
```

- **Purpose**: Returns the array of integrated toolbar buttons
- **Returns**: Array of `ButtonSpecAny` objects
- **Usage**: Access to the button array for custom operations

#### ReturnIsButtonArrayFlipped Method

```csharp
public bool ReturnIsButtonArrayFlipped()
```

- **Purpose**: Returns whether the button array is flipped
- **Returns**: Boolean indicating if the array is flipped
- **Usage**: Check the current state of the button array

## Advanced Usage Patterns

### Basic Toolbar Setup

```csharp
public void SetupBasicToolbar()
{
    var toolbarManager = new KryptonIntegratedToolBarManager();
    
    // Configure button visibility
    toolbarManager.ShowNewButton = true;
    toolbarManager.ShowOpenButton = true;
    toolbarManager.ShowSaveButton = true;
    toolbarManager.ShowCutButton = true;
    toolbarManager.ShowCopyButton = true;
    toolbarManager.ShowPasteButton = true;
    
    // Set orientation and alignment
    toolbarManager.IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedTop;
    toolbarManager.IntegratedToolBarButtonAlignment = PaletteRelativeEdgeAlign.Far;
    
    // Attach to parent form
    toolbarManager.AttachIntegratedToolBarToParent(this);
}
```

### Dynamic Toolbar Configuration

```csharp
public class DynamicToolbarManager
{
    private KryptonIntegratedToolBarManager toolbarManager;
    private KryptonForm parentForm;

    public DynamicToolbarManager(KryptonForm form)
    {
        parentForm = form;
        toolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = form
        };
    }

    public void ConfigureToolbarForDocumentEditor()
    {
        // Show document-related buttons
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowSaveAllButton = true;
        
        // Show editing buttons
        toolbarManager.ShowCutButton = true;
        toolbarManager.ShowCopyButton = true;
        toolbarManager.ShowPasteButton = true;
        toolbarManager.ShowUndoButton = true;
        toolbarManager.ShowRedoButton = true;
        
        // Show print buttons
        toolbarManager.ShowPageSetupButton = true;
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
        toolbarManager.ShowQuickPrintButton = true;
        
        // Attach to form
        toolbarManager.AttachIntegratedToolBarToParent(parentForm);
    }

    public void ConfigureToolbarForImageViewer()
    {
        // Show only relevant buttons for image viewer
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
        
        // Attach to form
        toolbarManager.AttachIntegratedToolBarToParent(parentForm);
    }

    public void UpdateToolbarOrientation(PaletteButtonOrientation orientation)
    {
        toolbarManager.IntegratedToolBarButtonOrientation = orientation;
    }

    public void UpdateToolbarAlignment(PaletteRelativeEdgeAlign alignment)
    {
        toolbarManager.IntegratedToolBarButtonAlignment = alignment;
    }
}
```

### Context-Aware Toolbar

```csharp
public class ContextAwareToolbarManager
{
    private KryptonIntegratedToolBarManager toolbarManager;
    private KryptonForm parentForm;
    private string currentContext;

    public ContextAwareToolbarManager(KryptonForm form)
    {
        parentForm = form;
        toolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = form
        };
        currentContext = "Default";
    }

    public void SetContext(string context)
    {
        if (currentContext != context)
        {
            // Detach current toolbar
            toolbarManager.DetachIntegratedToolBarFromParent(parentForm);
            
            // Configure for new context
            ConfigureForContext(context);
            
            // Attach updated toolbar
            toolbarManager.AttachIntegratedToolBarToParent(parentForm);
            
            currentContext = context;
        }
    }

    private void ConfigureForContext(string context)
    {
        // Reset all buttons
        ResetAllButtons();
        
        switch (context)
        {
            case "DocumentEditor":
                ConfigureDocumentEditorButtons();
                break;
            case "ImageViewer":
                ConfigureImageViewerButtons();
                break;
            case "DataViewer":
                ConfigureDataViewerButtons();
                break;
            case "Minimal":
                ConfigureMinimalButtons();
                break;
            default:
                ConfigureDefaultButtons();
                break;
        }
    }

    private void ResetAllButtons()
    {
        toolbarManager.ShowNewButton = false;
        toolbarManager.ShowOpenButton = false;
        toolbarManager.ShowSaveButton = false;
        toolbarManager.ShowSaveAllButton = false;
        toolbarManager.ShowSaveAsButton = false;
        toolbarManager.ShowCutButton = false;
        toolbarManager.ShowCopyButton = false;
        toolbarManager.ShowPasteButton = false;
        toolbarManager.ShowUndoButton = false;
        toolbarManager.ShowRedoButton = false;
        toolbarManager.ShowPageSetupButton = false;
        toolbarManager.ShowPrintPreviewButton = false;
        toolbarManager.ShowPrintButton = false;
        toolbarManager.ShowQuickPrintButton = false;
    }

    private void ConfigureDocumentEditorButtons()
    {
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowCutButton = true;
        toolbarManager.ShowCopyButton = true;
        toolbarManager.ShowPasteButton = true;
        toolbarManager.ShowUndoButton = true;
        toolbarManager.ShowRedoButton = true;
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
    }

    private void ConfigureImageViewerButtons()
    {
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
    }

    private void ConfigureDataViewerButtons()
    {
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowPrintButton = true;
    }

    private void ConfigureMinimalButtons()
    {
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
    }

    private void ConfigureDefaultButtons()
    {
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
    }
}
```

### Custom Button Event Handling

```csharp
public class CustomToolbarEventHandler
{
    private KryptonIntegratedToolBarManager toolbarManager;
    private KryptonForm parentForm;

    public CustomToolbarEventHandler(KryptonForm form)
    {
        parentForm = form;
        toolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = form
        };
        
        SetupToolbar();
        AttachEventHandlers();
    }

    private void SetupToolbar()
    {
        // Configure visible buttons
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
        toolbarManager.ShowCutButton = true;
        toolbarManager.ShowCopyButton = true;
        toolbarManager.ShowPasteButton = true;
        
        // Attach to form
        toolbarManager.AttachIntegratedToolBarToParent(parentForm);
    }

    private void AttachEventHandlers()
    {
        var buttons = toolbarManager.IntegratedToolBarButtons;
        
        // Attach event handlers to specific buttons
        if (buttons[0] != null) // New button
        {
            buttons[0].Click += OnNewButtonClick;
        }
        
        if (buttons[1] != null) // Open button
        {
            buttons[1].Click += OnOpenButtonClick;
        }
        
        if (buttons[2] != null) // Save button
        {
            buttons[2].Click += OnSaveButtonClick;
        }
        
        // Add more event handlers as needed
    }

    private void OnNewButtonClick(object? sender, EventArgs e)
    {
        // Handle new button click
        MessageBox.Show("New button clicked!", "Toolbar Event");
    }

    private void OnOpenButtonClick(object? sender, EventArgs e)
    {
        // Handle open button click
        using var openDialog = new OpenFileDialog();
        if (openDialog.ShowDialog() == DialogResult.OK)
        {
            MessageBox.Show($"Opening file: {openDialog.FileName}", "Toolbar Event");
        }
    }

    private void OnSaveButtonClick(object? sender, EventArgs e)
    {
        // Handle save button click
        MessageBox.Show("Save button clicked!", "Toolbar Event");
    }
}
```

## Integration Patterns

### Main Form Integration

```csharp
public partial class MainForm : KryptonForm
{
    private KryptonIntegratedToolBarManager toolbarManager;

    public MainForm()
    {
        InitializeComponent();
        SetupToolbar();
    }

    private void SetupToolbar()
    {
        toolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = this,
            IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedTop,
            IntegratedToolBarButtonAlignment = PaletteRelativeEdgeAlign.Far
        };

        // Configure button visibility based on application type
        ConfigureToolbarButtons();
        
        // Attach toolbar to form
        toolbarManager.AttachIntegratedToolBarToParent(this);
    }

    private void ConfigureToolbarButtons()
    {
        // Show standard buttons
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
        toolbarManager.ShowSaveAsButton = true;
        
        // Show editing buttons
        toolbarManager.ShowCutButton = true;
        toolbarManager.ShowCopyButton = true;
        toolbarManager.ShowPasteButton = true;
        toolbarManager.ShowUndoButton = true;
        toolbarManager.ShowRedoButton = true;
        
        // Show print buttons
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
    }

    protected override void OnFormClosed(FormClosedEventArgs e)
    {
        // Clean up toolbar
        toolbarManager?.DetachIntegratedToolBarFromParent(this);
        base.OnFormClosed(e);
    }
}
```

### Document Editor Integration

```csharp
public class DocumentEditorForm : KryptonForm
{
    private KryptonIntegratedToolBarManager toolbarManager;
    private RichTextBox documentEditor;

    public DocumentEditorForm()
    {
        InitializeComponent();
        SetupDocumentEditor();
        SetupToolbar();
    }

    private void SetupDocumentEditor()
    {
        documentEditor = new RichTextBox
        {
            Dock = DockStyle.Fill,
            Font = new Font("Consolas", 10)
        };
        
        Controls.Add(documentEditor);
    }

    private void SetupToolbar()
    {
        toolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = this,
            IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedTop,
            IntegratedToolBarButtonAlignment = PaletteRelativeEdgeAlign.Far
        };

        // Configure all document editor buttons
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowSaveAllButton = true;
        toolbarManager.ShowCutButton = true;
        toolbarManager.ShowCopyButton = true;
        toolbarManager.ShowPasteButton = true;
        toolbarManager.ShowUndoButton = true;
        toolbarManager.ShowRedoButton = true;
        toolbarManager.ShowPageSetupButton = true;
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
        toolbarManager.ShowQuickPrintButton = true;
        
        // Attach toolbar
        toolbarManager.AttachIntegratedToolBarToParent(this);
        
        // Attach event handlers
        AttachToolbarEventHandlers();
    }

    private void AttachToolbarEventHandlers()
    {
        var buttons = toolbarManager.IntegratedToolBarButtons;
        
        // Attach handlers for document operations
        if (buttons[0] != null) buttons[0].Click += OnNewDocument;
        if (buttons[1] != null) buttons[1].Click += OnOpenDocument;
        if (buttons[2] != null) buttons[2].Click += OnSaveDocument;
        if (buttons[3] != null) buttons[3].Click += OnSaveAsDocument;
        if (buttons[4] != null) buttons[4].Click += OnSaveAllDocuments;
        if (buttons[5] != null) buttons[5].Click += OnCutText;
        if (buttons[6] != null) buttons[6].Click += OnCopyText;
        if (buttons[7] != null) buttons[7].Click += OnPasteText;
        if (buttons[8] != null) buttons[8].Click += OnUndo;
        if (buttons[9] != null) buttons[9].Click += OnRedo;
        if (buttons[10] != null) buttons[10].Click += OnPageSetup;
        if (buttons[11] != null) buttons[11].Click += OnPrintPreview;
        if (buttons[12] != null) buttons[12].Click += OnPrint;
        if (buttons[13] != null) buttons[13].Click += OnQuickPrint;
    }

    private void OnNewDocument(object? sender, EventArgs e)
    {
        documentEditor.Clear();
        Text = "New Document - Document Editor";
    }

    private void OnOpenDocument(object? sender, EventArgs e)
    {
        using var openDialog = new OpenFileDialog
        {
            Filter = "Rich Text Files (*.rtf)|*.rtf|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        };
        
        if (openDialog.ShowDialog() == DialogResult.OK)
        {
            documentEditor.LoadFile(openDialog.FileName);
            Text = $"{Path.GetFileName(openDialog.FileName)} - Document Editor";
        }
    }

    private void OnSaveDocument(object? sender, EventArgs e)
    {
        // Implementation for save document
        MessageBox.Show("Save document functionality", "Toolbar Event");
    }

    private void OnSaveAsDocument(object? sender, EventArgs e)
    {
        using var saveDialog = new SaveFileDialog
        {
            Filter = "Rich Text Files (*.rtf)|*.rtf|Text Files (*.txt)|*.txt|All Files (*.*)|*.*"
        };
        
        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            documentEditor.SaveFile(saveDialog.FileName);
            Text = $"{Path.GetFileName(saveDialog.FileName)} - Document Editor";
        }
    }

    private void OnSaveAllDocuments(object? sender, EventArgs e)
    {
        MessageBox.Show("Save all documents functionality", "Toolbar Event");
    }

    private void OnCutText(object? sender, EventArgs e)
    {
        documentEditor.Cut();
    }

    private void OnCopyText(object? sender, EventArgs e)
    {
        documentEditor.Copy();
    }

    private void OnPasteText(object? sender, EventArgs e)
    {
        documentEditor.Paste();
    }

    private void OnUndo(object? sender, EventArgs e)
    {
        documentEditor.Undo();
    }

    private void OnRedo(object? sender, EventArgs e)
    {
        documentEditor.Redo();
    }

    private void OnPageSetup(object? sender, EventArgs e)
    {
        MessageBox.Show("Page setup functionality", "Toolbar Event");
    }

    private void OnPrintPreview(object? sender, EventArgs e)
    {
        MessageBox.Show("Print preview functionality", "Toolbar Event");
    }

    private void OnPrint(object? sender, EventArgs e)
    {
        MessageBox.Show("Print functionality", "Toolbar Event");
    }

    private void OnQuickPrint(object? sender, EventArgs e)
    {
        MessageBox.Show("Quick print functionality", "Toolbar Event");
    }
}
```

## Performance Considerations

- **Button Array Management**: Efficient array-based button management
- **Event Handling**: Optimized event attachment and detachment
- **Memory Management**: Proper cleanup of toolbar resources
- **Orientation Updates**: Efficient orientation and alignment updates

## Common Issues and Solutions

### Toolbar Not Showing

**Issue**: Toolbar buttons not appearing on the form  
**Solution**: Ensure proper attachment and visibility:

```csharp
toolbarManager.ShowNewButton = true; // Enable button visibility
toolbarManager.AttachIntegratedToolBarToParent(parentForm); // Attach to form
```

### Buttons Not Responding

**Issue**: Toolbar buttons not responding to clicks  
**Solution**: Attach event handlers to buttons:

```csharp
var buttons = toolbarManager.IntegratedToolBarButtons;
if (buttons[0] != null) // New button
{
    buttons[0].Click += OnNewButtonClick;
}
```

### Orientation Not Updating

**Issue**: Button orientation not changing  
**Solution**: Ensure parent form is set before updating orientation:

```csharp
toolbarManager.ParentForm = parentForm;
toolbarManager.IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedBottom;
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox**: Available with custom bitmap representation
- **Property Window**: All toolbar properties available for configuration
- **Designer Support**: Full design-time support for toolbar configuration

### Property Categories

- **Visuals**: Core toolbar properties (`IntegratedToolBarButtons`, `IntegratedToolBarButtonOrientation`, `IntegratedToolBarButtonAlignment`, `ParentForm`)
- **Button Visibility**: Individual button visibility controls
- **Behavior**: Toolbar behavior and event handling

## Migration and Compatibility

### From Standard ToolStrip

```csharp
// Old way
ToolStrip toolStrip = new ToolStrip();
toolStrip.Items.Add(new ToolStripButton("New"));
toolStrip.Items.Add(new ToolStripButton("Open"));

// New way
var toolbarManager = new KryptonIntegratedToolBarManager();
toolbarManager.ShowNewButton = true;
toolbarManager.ShowOpenButton = true;
toolbarManager.AttachIntegratedToolBarToParent(parentForm);
```

### From Custom Toolbar

```csharp
// Old way (custom toolbar implementation)
// CustomToolbar customToolbar = new CustomToolbar();

// New way
var toolbarManager = new KryptonIntegratedToolBarManager();
// Configure and attach toolbar
```

## Real-World Integration Examples

### Application Main Toolbar

```csharp
public partial class MainApplicationForm : KryptonForm
{
    private KryptonIntegratedToolBarManager mainToolbarManager;
    private KryptonIntegratedToolBarManager secondaryToolbarManager;

    public MainApplicationForm()
    {
        InitializeComponent();
        SetupMainToolbar();
        SetupSecondaryToolbar();
    }

    private void SetupMainToolbar()
    {
        mainToolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = this,
            IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedTop,
            IntegratedToolBarButtonAlignment = PaletteRelativeEdgeAlign.Far
        };

        // Configure main toolbar buttons
        mainToolbarManager.ShowNewButton = true;
        mainToolbarManager.ShowOpenButton = true;
        mainToolbarManager.ShowSaveButton = true;
        mainToolbarManager.ShowSaveAsButton = true;
        mainToolbarManager.ShowCutButton = true;
        mainToolbarManager.ShowCopyButton = true;
        mainToolbarManager.ShowPasteButton = true;
        mainToolbarManager.ShowUndoButton = true;
        mainToolbarManager.ShowRedoButton = true;
        
        // Attach main toolbar
        mainToolbarManager.AttachIntegratedToolBarToParent(this);
    }

    private void SetupSecondaryToolbar()
    {
        secondaryToolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = this,
            IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedTop,
            IntegratedToolBarButtonAlignment = PaletteRelativeEdgeAlign.Near
        };

        // Configure secondary toolbar buttons
        secondaryToolbarManager.ShowPageSetupButton = true;
        secondaryToolbarManager.ShowPrintPreviewButton = true;
        secondaryToolbarManager.ShowPrintButton = true;
        secondaryToolbarManager.ShowQuickPrintButton = true;
        
        // Attach secondary toolbar
        secondaryToolbarManager.AttachIntegratedToolBarToParent(this);
    }

    public void UpdateToolbarForContext(string context)
    {
        switch (context)
        {
            case "Document":
                UpdateToolbarForDocument();
                break;
            case "Image":
                UpdateToolbarForImage();
                break;
            case "Data":
                UpdateToolbarForData();
                break;
        }
    }

    private void UpdateToolbarForDocument()
    {
        // Show all document-related buttons
        mainToolbarManager.ShowNewButton = true;
        mainToolbarManager.ShowOpenButton = true;
        mainToolbarManager.ShowSaveButton = true;
        mainToolbarManager.ShowSaveAsButton = true;
        mainToolbarManager.ShowCutButton = true;
        mainToolbarManager.ShowCopyButton = true;
        mainToolbarManager.ShowPasteButton = true;
        mainToolbarManager.ShowUndoButton = true;
        mainToolbarManager.ShowRedoButton = true;
    }

    private void UpdateToolbarForImage()
    {
        // Show only image-related buttons
        mainToolbarManager.ShowNewButton = false;
        mainToolbarManager.ShowOpenButton = true;
        mainToolbarManager.ShowSaveButton = false;
        mainToolbarManager.ShowSaveAsButton = true;
        mainToolbarManager.ShowCutButton = false;
        mainToolbarManager.ShowCopyButton = true;
        mainToolbarManager.ShowPasteButton = false;
        mainToolbarManager.ShowUndoButton = false;
        mainToolbarManager.ShowRedoButton = false;
    }

    private void UpdateToolbarForData()
    {
        // Show data-related buttons
        mainToolbarManager.ShowNewButton = true;
        mainToolbarManager.ShowOpenButton = true;
        mainToolbarManager.ShowSaveButton = true;
        mainToolbarManager.ShowSaveAsButton = true;
        mainToolbarManager.ShowCutButton = false;
        mainToolbarManager.ShowCopyButton = true;
        mainToolbarManager.ShowPasteButton = false;
        mainToolbarManager.ShowUndoButton = false;
        mainToolbarManager.ShowRedoButton = false;
    }
}
```

### Multi-Document Interface Toolbar

```csharp
public class MDIToolbarManager
{
    private KryptonIntegratedToolBarManager toolbarManager;
    private KryptonForm parentForm;
    private List<KryptonForm> childForms;

    public MDIToolbarManager(KryptonForm parent)
    {
        parentForm = parent;
        childForms = new List<KryptonForm>();
        SetupToolbar();
    }

    private void SetupToolbar()
    {
        toolbarManager = new KryptonIntegratedToolBarManager
        {
            ParentForm = parentForm,
            IntegratedToolBarButtonOrientation = PaletteButtonOrientation.FixedTop,
            IntegratedToolBarButtonAlignment = PaletteRelativeEdgeAlign.Far
        };

        // Configure MDI toolbar
        toolbarManager.ShowNewButton = true;
        toolbarManager.ShowOpenButton = true;
        toolbarManager.ShowSaveButton = true;
        toolbarManager.ShowSaveAsButton = true;
        toolbarManager.ShowSaveAllButton = true;
        toolbarManager.ShowCutButton = true;
        toolbarManager.ShowCopyButton = true;
        toolbarManager.ShowPasteButton = true;
        toolbarManager.ShowUndoButton = true;
        toolbarManager.ShowRedoButton = true;
        toolbarManager.ShowPrintPreviewButton = true;
        toolbarManager.ShowPrintButton = true;
        
        // Attach toolbar
        toolbarManager.AttachIntegratedToolBarToParent(parentForm);
        
        // Attach event handlers
        AttachMDIEventHandlers();
    }

    private void AttachMDIEventHandlers()
    {
        var buttons = toolbarManager.IntegratedToolBarButtons;
        
        if (buttons[0] != null) buttons[0].Click += OnNewDocument;
        if (buttons[1] != null) buttons[1].Click += OnOpenDocument;
        if (buttons[2] != null) buttons[2].Click += OnSaveDocument;
        if (buttons[3] != null) buttons[3].Click += OnSaveAsDocument;
        if (buttons[4] != null) buttons[4].Click += OnSaveAllDocuments;
        if (buttons[5] != null) buttons[5].Click += OnCut;
        if (buttons[6] != null) buttons[6].Click += OnCopy;
        if (buttons[7] != null) buttons[7].Click += OnPaste;
        if (buttons[8] != null) buttons[8].Click += OnUndo;
        if (buttons[9] != null) buttons[9].Click += OnRedo;
        if (buttons[11] != null) buttons[11].Click += OnPrintPreview;
        if (buttons[12] != null) buttons[12].Click += OnPrint;
    }

    public void AddChildForm(KryptonForm childForm)
    {
        childForms.Add(childForm);
        UpdateToolbarState();
    }

    public void RemoveChildForm(KryptonForm childForm)
    {
        childForms.Remove(childForm);
        UpdateToolbarState();
    }

    private void UpdateToolbarState()
    {
        bool hasActiveChild = childForms.Count > 0;
        
        // Enable/disable buttons based on child form state
        var buttons = toolbarManager.IntegratedToolBarButtons;
        
        // Update button states based on active child form
        // Implementation depends on specific requirements
    }

    private void OnNewDocument(object? sender, EventArgs e)
    {
        // Create new child document
        var newDocument = new DocumentForm();
        AddChildForm(newDocument);
        newDocument.Show();
    }

    private void OnOpenDocument(object? sender, EventArgs e)
    {
        using var openDialog = new OpenFileDialog();
        if (openDialog.ShowDialog() == DialogResult.OK)
        {
            var document = new DocumentForm();
            document.LoadFile(openDialog.FileName);
            AddChildForm(document);
            document.Show();
        }
    }

    private void OnSaveDocument(object? sender, EventArgs e)
    {
        // Save active child document
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Save document logic
        }
    }

    private void OnSaveAsDocument(object? sender, EventArgs e)
    {
        // Save active child document as
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Save as logic
        }
    }

    private void OnSaveAllDocuments(object? sender, EventArgs e)
    {
        // Save all child documents
        foreach (var child in childForms)
        {
            // Save each document
        }
    }

    private void OnCut(object? sender, EventArgs e)
    {
        // Cut from active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Cut logic
        }
    }

    private void OnCopy(object? sender, EventArgs e)
    {
        // Copy from active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Copy logic
        }
    }

    private void OnPaste(object? sender, EventArgs e)
    {
        // Paste to active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Paste logic
        }
    }

    private void OnUndo(object? sender, EventArgs e)
    {
        // Undo in active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Undo logic
        }
    }

    private void OnRedo(object? sender, EventArgs e)
    {
        // Redo in active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Redo logic
        }
    }

    private void OnPrintPreview(object? sender, EventArgs e)
    {
        // Print preview for active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Print preview logic
        }
    }

    private void OnPrint(object? sender, EventArgs e)
    {
        // Print active child
        var activeChild = GetActiveChildForm();
        if (activeChild != null)
        {
            // Print logic
        }
    }

    private KryptonForm? GetActiveChildForm()
    {
        // Get the currently active child form
        return childForms.FirstOrDefault(f => f.ContainsFocus);
    }
}
```

## License and Attribution

This class is part of the Krypton Toolkit Suite under the BSD 3-Clause License. It provides comprehensive toolbar management functionality with 14 predefined buttons, customizable orientation and alignment, and seamless integration with Krypton forms, enabling consistent toolbar experiences across Krypton applications.
