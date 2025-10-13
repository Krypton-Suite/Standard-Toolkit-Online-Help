# KryptonProgressBar

## Overview

The `KryptonProgressBar` class provides a Krypton-themed replacement for the standard Windows progress bar. It inherits from `Control` and implements `IContentValues` to provide enhanced visual styling, multiple progress styles, orientation support, alpha transparency, text overlay capabilities, and seamless integration with Krypton Toolkit theming.

## Class Hierarchy

```
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── Krypton.Toolkit.KryptonProgressBar
```

## Constructor and Initialization

```csharp
public KryptonProgressBar()
```

The constructor initializes enhanced features:
- **Double Buffering**: Optimized drawing performance with anti-flicker controls
- **Text Support**: Accessibility-friendly text integration
- **Non-Selectable**: Properly configured to not accept focus
- **Default Values**: Standard progress bar range (0-100), step of 10
- **Marquee Timer**: Internal timer for marquee animations
- **Palette Integration**: Automatic Krypton palette detection and theming
- **LabelValues**: Content management system for text overlay
- **State Management**: Common, disabled, and normal visual states

## Key Properties

### Values Property

```csharp
[Category("Visuals")]
[Description("Progress Bar Label values")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public LabelValues Values { get; }
```

- **Purpose**: Provides full control over text display, styling, and content management
- **Category**: Visuals
- **Type**: `LabelValues` - Comprehensive text and content configuration
- **Designer Visible**: Yes (expandable in property grid)

### Style Property

```csharp
[DefaultValue(ProgressBarStyle.Continuous)]
public ProgressBarStyle Style { get; set; }
```

- **Purpose**: Controls how progress is visually indicated
- **Category**: Behavior
- **Available Styles**:
  - `Continuous`: Solid fill from left to right (default)
  - `Marquee`: Animated scrolling indicator for indeterminate progress
  - `Blocks`: Discrete block segments showing progress

**Usage Example:**
```csharp
progressBar.Style = ProgressBarStyle.Marquee; // Indeterminate progress
progressBar.Style = ProgressBarStyle.Continuous; // Determinate progress
progressBar.Style = ProgressBarStyle.Blocks; // Block-style progress
```

### BlockCount Property

```csharp
[DefaultValue(0)]
public int BlockCount { get; set; }
```

- **Purpose**: Specifies number of blocks when using `ProgressBarStyle.Blocks`
- **Category**: Behavior
- **Default Value**: 0 (automatic sizing based on height)
- **Effect**: Only applies when `Style` is set to `Blocks`

### ValueBackColorStyle Property

```csharp
[DefaultValue(PaletteColorStyle.GlassNormalFull)]
public PaletteColorStyle ValueBackColorStyle { get; set; }
```

- **Purpose**: Controls color drawing style of the filled progress area
- **Category**: Visuals
- **Default Value**: `GlassNormalFull` - Translucent glass effect
- **Other Options**: Various gradient, flat, and specialized styles

### Text Enhancement Properties

```csharp
[DefaultValue(false)]
public bool ShowTextShadow { get; set; }

[DefaultValue(typeof(Color), nameof(Color.Empty))]
public Color TextShadowColor { get; set; }

[DefaultValue(false)]
public bool ShowTextBackdrop { get; set; }

[DefaultValue(typeof(Color), nameof(Color.Empty))]
public Color TextBackdropColor { get; set; }
```

**Advanced Text Features:**
- **Shadow Support**: Adds depth to text with configurable shadow colors
- **Backdrop Support**: Places a rounded background behind text for readability
- **Color Customization**: Automatic color selection or custom colors

### Visual States

```csharp
public PaletteTripleRedirect StateCommon { get; }
public PaletteTriple StateDisabled { get; }
public PaletteTriple StateNormal { get; }
```

- **StateCommon**: Base styling that other states can override
- **StateDisabled**: Visual appearance when control is disabled
- **StateNormal**: Default visual appearance when enabled

## Progress Bar Operation

### Range and Value Properties

```csharp
[DefaultValue(100)]
public int Maximum { get; set; }

[DefaultValue(0)]
public int Minimum { get; set; }

[DefaultValue(0)]
public int Value { get; set; }

[DefaultValue(10)]
public int Step { get; set; }
```

**Range Management:**
- **Validation**: Automatic bounds checking and adjustment
- **Value Constraints**: Ensures Value stays within Minimum-Maximum range
- **Step Control**: Defines increment amount for `PerformStep()` method

### Orientation Support

```csharp
[DefaultValue(VisualOrientation.Top)]
public VisualOrientation Orientation { get; set; }
```

- **Horizontal Progress**: `VisualOrientation.Bottom` (left-to-right)
- **Vertical Progress**: `VisualOrientation.Top` (top-to-bottom)
- **RTL Support**: Automatically handles right-to-left layouts

### UseValueAsText Property

```csharp
[DefaultValue(false)]
public bool UseValueAsText { get; set; }
```

- **Purpose**: Automatically displays current value as percentage text
- **Format**: Shows as "{Value}%" (e.g., "75%")
- **Integration**: Works alongside custom `Text` property

### Marquee Animation

```csharp
[DefaultValue(100)]
public int MarqueeAnimationSpeed { get; set; }
```

- **Purpose**: Controls marquee animation speed in milliseconds
- **Usage**: Only applies when `Style` is `ProgressBarStyle.Marquee`
- **Performance**: Lower values = faster animation

## Advanced Usage Patterns

### Indeterminate Progress

```csharp
public void StartIndeterminateWork()
{
    progressBar.Style = ProgressBarStyle.Marquee;
    progressBar.MarqueeAnimationSpeed = 50; // Fast animation
    progressBar.Text = "Processing...";
    
    // Start background work
    Task.Run(() => PerformLongRunningOperation());
}

public void CompleteWork()
{
    // Convert to determinate for final update
    progressBar.Style = ProgressBarStyle.Continuous;
    progressBar.Value = progressBar.Maximum;
    progressBar.Text = "Complete!";
}
```

### Block-Style Progress

```csharp
public void SetupBlockProgress()
{
    // Configure for block display
    progressBar.Style = ProgressBarStyle.Blocks;
    progressBar.BlockCount = 20; // 20 discrete blocks
    
    // Configure visual styling
    progressBar.ValueBackColorStyle = PaletteColorStyle.Linear40;
    
    // Add custom text
    progressBar.ShowTextBackdrop = true;
    progressBar.TextBackdropColor = Color.FromArgb(100, Color.White);
    progressBar.Text = "Processing items...";
}
```

### Value-Based Progress with Steps

```csharp
public class TaskProgressManager
{
    private readonly KryptonProgressBar progressBar;
    private int currentStep = 0;
    private int totalSteps = 0;

    public TaskProgressManager(KryptonProgressBar progressBar)
    {
        this.progressBar = progressBar;
        ConfigureProgressBar();
    }

    public void InitializeTask(int totalSteps, string taskName)
    {
        this.totalSteps = totalSteps;
        currentStep = 0;
        
        progressBar.Minimum = 0;
        progressBar.Maximum = totalSteps;
        progressBar.Value = 0;
        progressBar.Text = $"Starting {taskName}...";
        progressBar.Style = ProgressBarStyle.Continuous;
    }

    public void StepComplete(string stepDescription)
    {
        currentStep++;
        progressBar.PerformStep();
        
        float percentage = (float)currentStep / totalSteps * 100;
        progressBar.Text = $"{stepDescription} ({percentage:F0}%)";
    }

    public void TaskComplete(string completionMessage)
    {
        progressBar.Value = progressBar.Maximum;
        progressBar.Text = completionMessage;
        
        // Show completion briefly then reset
        var timer = new System.Windows.Forms.Timer { Interval = 2000 };
        timer.Tick += (s, e) =>
        {
            progressBar.Text = string.Empty;
            timer.Stop();
            timer.Dispose();
        };
        timer.Start();
    }

    private void ConfigureProgressBar()
    {
        progressBar.UseValueAsText = false; // Use custom text instead
        progressBar.ShowTextShadow = true;
        progressBar.ShowTextBackdrop = true;
        progressBar.ValueBackColorStyle = PaletteColorStyle.GlassNormalFull;
    }
}
```

### Multi-Stage Progress with Visual States

```csharp
public class MultiStageProgress : UserControl
{
    private readonly KryptonProgressBar progressBar;
    private readonly List<ProgressStage> stages = new List<ProgressStage>();

    public class ProgressStage
    {
        public string Name { get; set; }
        public int Duration { get; set; }
        public PaletteColorStyle Style { get; set; }
        public string Message { get; set; }
    }

    public void AddStage(string name, int duration, string message, PaletteColorStyle style)
    {
        stages.Add(new ProgressStage
        {
            Name = name,
            Duration = duration,
            Message = message,
            Style = style
        });
    }

    public async Task ExecuteStages()
    {
        int totalDuration = stages.Sum(s => s.Duration);
        progressBar.Maximum = totalDuration;
        progressBar.Value = 0;
        progressBar.Style = ProgressBarStyle.Continuous;

        foreach (var stage in stages)
        {
            progressBar.Text = stage.Message;
            progressBar.ValueBackColorStyle = stage.Style;

            for (int i = 0; i < stage.Duration; i += 100)
            {
                await Task.Delay(100); // Simulate work
                progressBar.Value += 100;
            }
        }

        progressBar.Text = "All stages complete!";
    }
}
```

## Design-Time Integration

### Visual Studio Designer

- **Toolbox Integration**: Available with custom bitmap representation
- **Property Window**: Comprehensive visual state configuration
- **Default Properties**: Value and binding property configured
- **Serialization**: Design-time settings saved to designer files

### Property Categories

- **Behavior**: Core progress functionality (`Style`, `Maximum`, `Minimum`, `Value`)
- **Visuals**: Appearance and styling properties (`Values`, `StateCommon`, `StateNormal`)
- **Layout**: Orientation and text positioning

## Performance Considerations

- **Double Buffering**: Eliminates flicker during updates
- **Optimized Rendering**: Efficient graphics operations for smooth animation
- **Memory Management**: Proper disposal of graphics resources
- **Theme Integration**: Lightweight palette switching without full repaints

## Common Issues and Solutions

### Marquee Animation Not Working

**Issue**: Marquee style not animating  
**Solution**: Ensure control is enabled and `Style` is properly set:

```csharp
progressBar.Style = ProgressBarStyle.Marquee;
progressBar.MarqueeAnimationSpeed = 50;
progressBar.Enabled = true; // Required for animation
```

### Text Not Visible

**Issue**: Text overlay not showing despite being set  
**Solution**: Configure text rendering options:

```csharp
progressBar.ShowTextBackdrop = true;
progressBar.TextBackdropColor = Color.FromArgb(150, Color.Black);
progressBar.ShowTextShadow = false; // Ensure shadow isn't conflicting
```

### Theme Not Applied

**Issue**: Custom theming not visible  
**Solution**: Properly configure state properties:

```csharp
progressBar.StateNormal.Back.Color1 = Color.Blue;
progressBar.StateNormal.Back.Color2 = Color.DarkBlue;
progressBar.ValueBackColorStyle = PaletteColorStyle.Linear40;
```

## Migration from Standard ProgressBar

### Direct Replacement

```csharp
// Old code
ProgressBar progressBar = new ProgressBar();

// New code
KryptonProgressBar progressBar = new KryptonProgressBar();
```

### Enhanced Features

```csharp
// Standard ProgressBar (basic)
var standardPb = new ProgressBar();

// KryptonProgressBar (enhanced)
var kryptonPb = new KryptonProgressBar
{
    Style = ProgressBarStyle.Continuous,
    ValueBackColorStyle = PaletteColorStyle.GlassNormalFull,
    ShowTextBackdrop = true,
    TextBackdropColor = Color.FromArgb(100, Color.White),
    Text = "Custom progress message",
    Orientation = VisualOrientation.Top
};
```

## Real-World Integration Examples

### File Upload Progress

```csharp
public class FileUploader : UserControl
{
    private KryptonProgressBar progressBar;
    private Label statusLabel;

    public async Task UploadFiles(List<string> filePaths)
    {
        progressBar.Maximum = filePaths.Count;
        progressBar.Value = 0;
        progressBar.Text = "Starting upload...";

        for (int i = 0; i < filePaths.Count; i++)
        {
            string fileName = Path.GetFileName(filePaths[i]);
            progressBar.Text = $"Uploading {fileName}";
            
            await SimulateFileUpload(filePaths[i]);
            
            progressBar.PerformStep();
            
            // Update completion percentage
            int percentage = (i + 1) * 100 / filePaths.Count;
            statusLabel.Text = $"Progress: {percentage}%";
        }

        progressBar.Text = "Upload complete!";
        progressBar.ValueBackColorStyle = PaletteColorStyle.LinearGreen; // Success color
    }

    private async Task SimulateFileUpload(string filePath)
    {
        // Simulate upload process
        await Task.Delay(Random.Shared.Next(1000, 3000));
    }
}
```

### Installation Progress Wizard

```csharp
public class InstallationWizard : Form
{
    private List<InstallationStep> installationSteps;
    private int currentStepIndex = 0;

    public class InstallationStep
    {
        public string Name { get; set; }
        public string Description { get; set; }
        public int Duration { get; set; }
        public bool IsCritical { get; set; }
    }

    public async Task ExecuteInstallation()
    {
        progressBar.Maximum = installationSteps.Count;
        progressBar.Value = 0;
        progressBar.ShowTextBackdrop = true;
        progressBar.TextBackdropColor = Color.FromArgb(200, Color.Black);

        foreach (var step in installationSteps)
        {
            // Update UI
            stepNameLabel.Text = step.Name;
            stepDescriptionLabel.Text = step.Description;
            
            progressBar.Text = $"Step {currentStepIndex + 1}: {step.Name}";
            
            // Set color based on criticality
            if (step.IsCritical)
            {
                progressBar.ValueBackColorStyle = PaletteColorStyle.LinearRed;
            }
            else
            {
                progressBar.ValueBackColorStyle = PaletteColorStyle.GlassNormalFull;
            }

            // Simulate installation step
            await SimulateInstallationStep(step);

            // Update progress
            progressBar.PerformStep();
            currentStepIndex++;
        }

        // Completion
        progressBar.ValueBackColorStyle = PaletteColorStyle.LinearGreen;
        progressBar.Text = "Installation complete!";
    }

    private async Task SimulateInstallationStep(InstallationStep step)
    {
        // Simulate step duration
        await Task.Delay(step. Duration);
    }
}
```