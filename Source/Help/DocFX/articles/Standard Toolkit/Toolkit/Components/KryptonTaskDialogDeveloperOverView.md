# KryptonTaskDialog Developer Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Getting Started](#getting-started)
4. [Core Components](#core-components)
5. [Dialog Elements](#dialog-elements)
6. [API Reference](#api-reference)
7. [Usage Examples](#usage-examples)
8. [Advanced Features](#advanced-features)
9. [Theming and Customization](#theming-and-customization)
10. [Best Practices](#best-practices)

---

## Overview

`KryptonTaskDialog` is a modern, flexible dialog component that resembles Windows TaskDialog functionality but is implemented using Krypton's theming engine. It provides a composable approach to building dialogs through individual elements that can be configured and arranged as needed.

### Key Features

- **Modular Element-Based Architecture**: Build dialogs using composable elements (Heading, Content, Footer, etc.)
- **Flexible Display Options**: Support for both modal (`ShowDialog`) and modeless (`Show`) display modes
- **Rich Content Support**: Text, images, icons, buttons, checkboxes, combo boxes, progress bars, and more
- **Full Theme Integration**: Seamlessly integrates with Krypton's theming system
- **Customizable Layout**: Control visibility, colors, fonts, and layout of all elements
- **Form Reusability**: Dialog forms can be reused multiple times by simply calling `Show()` or `ShowDialog()` again
- **Responsive Design**: Automatically adjusts height based on visible elements

### Design Philosophy

Unlike traditional dialogs that use static configurations, `KryptonTaskDialog` uses a **builder pattern** where you:
1. Create a `KryptonTaskDialog` instance
2. Configure individual elements through their properties
3. Show the dialog when ready
4. Optionally reuse the same instance multiple times

---

## Architecture

### Component Hierarchy

```
KryptonTaskDialog (main class)
├── KryptonTaskDialogKryptonForm (specialized form)
│   └── TableLayoutPanel (vertical stack layout)
│       ├── KryptonTaskDialogElementHeading
│       ├── KryptonTaskDialogElementContent
│       ├── KryptonTaskDialogElementExpander
│       ├── KryptonTaskDialogElementRichTextBox
│       ├── KryptonTaskDialogElementFreeWheeler1
│       ├── KryptonTaskDialogElementFreeWheeler2
│       ├── KryptonTaskDialogElementCommandLinkButtons
│       ├── KryptonTaskDialogElementCheckBox
│       ├── KryptonTaskDialogElementComboBox
│       ├── KryptonTaskDialogElementHyperLink
│       ├── KryptonTaskDialogElementProgresBar
│       └── KryptonTaskDialogElementFooterBar
└── KryptonTaskDialogFormProperties (dialog configuration)
    ├── FormInstance (form-level properties)
    └── GlobalInstance (global element settings)
```

### Core Design Patterns

#### 1. Element Base Class Pattern
All elements derive from `KryptonTaskDialogElementBase`, which provides:
- Visibility management
- Background color control (with gradient support)
- Height calculation
- Layout dirty tracking
- Theme integration
- Disposal pattern

#### 2. Interface-Based Feature Extension
Elements implement specific interfaces to expose features:
- `IKryptonTaskDialogElementText`: Text property
- `IKryptonTaskDialogElementIconType`: Icon support
- `IKryptonTaskDialogElementForeColor`: Text color control
- `IKryptonTaskDialogElementRoundedCorners`: Corner rounding
- `IKryptonTaskDialogElementHeight`: Custom height control

#### 3. Property Change Notification
Elements use action delegates for change notifications:
- `VisibleChanged`: Notifies when visibility changes
- `SizeChanged`: Notifies when size changes
- Custom events for element-specific changes

---

## Getting Started

### Basic Usage

```csharp
// Create the dialog
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    // Configure the dialog window
    taskDialog.Dialog.Form.Text = "My Task Dialog";
    taskDialog.Dialog.Form.StartPosition = FormStartPosition.CenterScreen;

    // Configure the heading
    taskDialog.Heading.Text = "Important Message";
    taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldInformation;

    // Configure the content
    taskDialog.Content.Text = "This is the main content of the dialog.";

    // Configure buttons (footer)
    taskDialog.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.OK | 
        KryptonTaskDialogCommonButtonTypes.Cancel;

    // Show the dialog modally
    DialogResult result = taskDialog.ShowDialog();
    
    if (result == DialogResult.OK)
    {
        // User clicked OK
    }
}
```

### Constructor Options

```csharp
// Default width (600 pixels)
KryptonTaskDialog taskDialog = new KryptonTaskDialog();

// Custom width
KryptonTaskDialog taskDialog = new KryptonTaskDialog(800);
```

---

## Core Components

### KryptonTaskDialog

The main class that orchestrates all dialog functionality.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Dialog` | `KryptonTaskDialogFormProperties` | Access to form and global properties |
| `Heading` | `KryptonTaskDialogElementHeading` | Dialog heading element |
| `Content` | `KryptonTaskDialogElementContent` | Main content element |
| `Expander` | `KryptonTaskDialogElementContent` | Expandable content element |
| `RichTextBox` | `KryptonTaskDialogElementRichTextBox` | Rich text box element |
| `FreeWheeler1` | `KryptonTaskDialogElementFreeWheeler1` | FlowLayoutPanel for custom controls |
| `FreeWheeler2` | `KryptonTaskDialogElementFreeWheeler2` | TableLayoutPanel for custom controls |
| `CommandLinkButtons` | `KryptonTaskDialogElementCommandLinkButtons` | Command link buttons element |
| `CheckBox` | `KryptonTaskDialogElementCheckBox` | Checkbox element |
| `ComboBox` | `KryptonTaskDialogElementComboBox` | ComboBox element |
| `HyperLink` | `KryptonTaskDialogElementHyperLink` | Hyperlink element |
| `ProgresBar` | `KryptonTaskDialogElementProgresBar` | Progress bar element |
| `FooterBar` | `KryptonTaskDialogElementFooterBar` | Footer with buttons and expander control |

#### Methods

```csharp
// Show the dialog modally (blocks until closed)
DialogResult ShowDialog(IWin32Window? owner = null);

// Show the dialog modeless (non-blocking)
void Show(IWin32Window? owner = null);

// Close the dialog (for modeless dialogs)
void CloseDialog();

// Hide all elements at once
void HideAllElements();
```

### KryptonTaskDialogFormProperties

Provides centralized access to form-level and global settings.

#### Form Instance Properties

Access via `taskDialog.Dialog.Form`:

| Property | Type | Description |
|----------|------|-------------|
| `Text` | `string` | Title bar text |
| `Icon` | `Icon?` | Form icon |
| `StartPosition` | `FormStartPosition` | Window positioning |
| `Location` | `Point` | Manual position (when StartPosition is Manual) |
| `TopMost` | `bool` | Whether dialog stays on top |
| `ControlBox` | `bool` | Show system menu button |
| `CloseBox` | `bool` | Show close button |
| `MinimizeBox` | `bool` | Show minimize button |
| `MaximizeBox` | `bool` | Show maximize button |
| `ShowInTaskBar` | `bool` | Show in Windows taskbar |
| `IgnoreAltF4` | `bool` | Disable Alt+F4 closing |
| `FormTitleAlign` | `PaletteRelativeAlign` | Title text alignment |
| `RoundedCorners` | `bool` | Round form corners |
| `AutoScaleMode` | `AutoScaleMode` | DPI scaling mode |

#### Global Instance Properties

Access via `taskDialog.Dialog.Globals`:

| Property | Type | Description |
|----------|------|-------------|
| `BackColor1` | `Color` | First background color for all elements |
| `BackColor2` | `Color` | Second background color for gradient |
| `ForeColor` | `Color` | Text color for all elements |
| `RoundedCorners` | `bool` | Rounded corners for all elements |

#### Dialog Result

Access via `taskDialog.Dialog.DialogResult` after the dialog closes.

---

## Dialog Elements

All elements share common base properties:

| Property | Type | Description |
|----------|------|-------------|
| `Visible` | `bool` | Show/hide the element |
| `BackColor1` | `Color` | First background color |
| `BackColor2` | `Color` | Second background color (for gradient) |
| `ShowSeparator` | `bool` | Show separator line at top |
| `Height` | `int` | Current element height (read-only) |

### 1. KryptonTaskDialogElementHeading

Displays a prominent heading with optional icon.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Text` | `string` | Heading text |
| `IconType` | `KryptonTaskDialogIconType` | Icon to display |
| `TextAlignmentHorizontal` | `PaletteRelativeAlign` | Text alignment (Near/Center/Far) |
| `ForeColor` | `Color` | Text color |

#### Icon Types

Available in `KryptonTaskDialogIconType` enum:
- `None` - No icon
- `ShieldError` - Red error shield
- `ShieldWarning` - Yellow warning shield
- `ShieldInformation` - Blue information shield
- `ShieldSuccess` - Green success shield
- `ShieldHelp` - Help shield
- `ShieldKrypton` - Krypton branded shield
- `ShieldUac` - UAC elevation shield
- `CheckGreen` - Green checkmark
- `Document` - Document icon
- `Gear` - Settings gear
- `PowerOff` - Power button
- `ArrowGrayDown` - Down arrow
- `ArrowGrayUp` - Up arrow

#### Example

```csharp
taskDialog.Heading.Visible = true;
taskDialog.Heading.Text = "Installation Complete";
taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldSuccess;
taskDialog.Heading.TextAlignmentHorizontal = PaletteRelativeAlign.Center;
taskDialog.Heading.ForeColor = Color.DarkGreen;
```

### 2. KryptonTaskDialogElementContent

Displays text content with optional image. Can be used for both main content and expander content.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Text` | `string` | Content text (supports line breaks) |
| `ForeColor` | `Color` | Text color |
| `ContentImage` | `ContentImageStorage` | Image configuration |

#### ContentImageStorage Properties

| Property | Type | Description |
|----------|------|-------------|
| `Image` | `Image` | Image to display |
| `Size` | `Size` | Image size (0 for original) |
| `Visible` | `bool` | Show/hide image |
| `PositionedLeft` | `bool` | true = left, false = right |

#### Example

```csharp
taskDialog.Content.Visible = true;
taskDialog.Content.Text = "The installation was successful.\nWould you like to launch the application now?";
taskDialog.Content.ContentImage.Image = myImage;
taskDialog.Content.ContentImage.Size = new Size(48, 48);
taskDialog.Content.ContentImage.Visible = true;
taskDialog.Content.ContentImage.PositionedLeft = true;
```

### 3. KryptonTaskDialogElementExpander

An expandable content area controlled by the footer bar's expander button.

Uses the same properties as `KryptonTaskDialogElementContent`. Typically hidden by default and toggled via the footer expander button.

#### Example

```csharp
// Configure expander content
taskDialog.Expander.Text = "Detailed technical information:\n- Version: 2.1.0\n- Build: 12345";
taskDialog.Expander.Visible = false; // Initially hidden

// Enable footer expander control
taskDialog.FooterBar.Footer.EnableExpanderControls = true;
taskDialog.FooterBar.Footer.ExpanderExpandedText = "Show Details";
taskDialog.FooterBar.Footer.ExpanderCollapsedText = "Hide Details";
```

### 4. KryptonTaskDialogElementFooterBar

Provides common buttons, footer text, and expander control.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `CommonButtons` | `CommonButtonProperties` | Button configuration |
| `Footer` | `FooterProperties` | Footer text and expander |
| `ForeColor` | `Color` | Text color |
| `RoundedCorners` | `bool` | Round button corners |

#### CommonButtonProperties

| Property | Type | Description |
|----------|------|-------------|
| `Buttons` | `KryptonTaskDialogCommonButtonTypes` | Buttons to show (flags enum) |
| `AcceptButton` | `KryptonTaskDialogCommonButtonTypes` | Default accept button |
| `CancelButton` | `KryptonTaskDialogCommonButtonTypes` | Default cancel button |

#### FooterProperties

| Property | Type | Description |
|----------|------|-------------|
| `FootNoteText` | `string` | Footer text |
| `IconType` | `KryptonTaskDialogIconType` | Footer icon |
| `EnableExpanderControls` | `bool` | Show expander button |
| `ExpanderExpandedText` | `string` | Text when collapsed |
| `ExpanderCollapsedText` | `string` | Text when expanded |

#### Button Types (Flags Enum)

```csharp
[Flags]
public enum KryptonTaskDialogCommonButtonTypes
{
    None = 0,
    OK = 1,
    Cancel = 2,
    Yes = 4,
    No = 8,
    Retry = 16,
    Abort = 32,
    Ignore = 64
}
```

#### Example

```csharp
// Configure buttons
taskDialog.FooterBar.CommonButtons.Buttons = 
    KryptonTaskDialogCommonButtonTypes.Yes | 
    KryptonTaskDialogCommonButtonTypes.No |
    KryptonTaskDialogCommonButtonTypes.Cancel;
    
taskDialog.FooterBar.CommonButtons.AcceptButton = KryptonTaskDialogCommonButtonTypes.Yes;
taskDialog.FooterBar.CommonButtons.CancelButton = KryptonTaskDialogCommonButtonTypes.Cancel;

// Configure footer note
taskDialog.FooterBar.Footer.FootNoteText = "This action cannot be undone.";
taskDialog.FooterBar.Footer.IconType = KryptonTaskDialogIconType.ShieldWarning;

// Configure expander
taskDialog.FooterBar.Footer.EnableExpanderControls = true;
taskDialog.FooterBar.Footer.ExpanderExpandedText = "More Info";
taskDialog.FooterBar.Footer.ExpanderCollapsedText = "Less Info";
```

### 5. KryptonTaskDialogElementCommandLinkButtons

Displays a collection of command link buttons.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Buttons` | `ObservableCollection<KryptonCommandLinkButton>` | Button collection |
| `RoundedCorners` | `bool` | Round button corners |
| `ShowFlowDirection` | `bool` | Show flow direction toggle button |
| `FlowDirection` | `FlowDirection` | Button flow direction |

#### Example

```csharp
taskDialog.CommandLinkButtons.Visible = true;

// Add buttons
var button1 = new KryptonCommandLinkButton();
button1.Text = "Option 1";
button1.Description = "This is the first option";
button1.DialogResult = DialogResult.Yes;
taskDialog.CommandLinkButtons.Buttons.Add(button1);

var button2 = new KryptonCommandLinkButton();
button2.Text = "Option 2";
button2.Description = "This is the second option";
button2.DialogResult = DialogResult.No;
taskDialog.CommandLinkButtons.Buttons.Add(button2);

taskDialog.CommandLinkButtons.RoundedCorners = true;
```

### 6. KryptonTaskDialogElementCheckBox

Displays a checkbox.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Text` | `string` | Checkbox text |
| `Checked` | `bool` | Checked state |
| `ForeColor` | `Color` | Text color |

#### Example

```csharp
taskDialog.CheckBox.Visible = true;
taskDialog.CheckBox.Text = "Don't show this message again";
taskDialog.CheckBox.Checked = false;

// After showing dialog
if (taskDialog.CheckBox.Checked)
{
    // User checked the box
}
```

### 7. KryptonTaskDialogElementComboBox

Displays a combo box with optional description.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Items` | `ComboBox.ObjectCollection` | Items collection |
| `SelectedIndex` | `int` | Selected item index (read-only) |
| `SelectedItem` | `object?` | Selected item (read-only) |
| `ComboxWidth` | `int` | Combo box width |
| `DropDownWidth` | `int` | Drop-down width |
| `DropDownStyle` | `InternalComboBoxStyle` | DropDown or DropDownList |
| `Description` | `string` | Description text above combo box |
| `ShowDescription` | `bool` | Show/hide description |
| `ForeColor` | `Color` | Description text color |
| `RoundedCorners` | `bool` | Round combo box corners |

#### Events

```csharp
event Action<object?> SelectedItemChanged;
```

#### Example

```csharp
taskDialog.ComboBox.Visible = true;
taskDialog.ComboBox.Description = "Please select an option:";
taskDialog.ComboBox.ShowDescription = true;
taskDialog.ComboBox.Items.Add("Option 1");
taskDialog.ComboBox.Items.Add("Option 2");
taskDialog.ComboBox.Items.Add("Option 3");
taskDialog.ComboBox.DropDownStyle = InternalComboBoxStyle.DropDownList;
taskDialog.ComboBox.RoundedCorners = true;

taskDialog.ComboBox.SelectedItemChanged += (item) =>
{
    Console.WriteLine($"Selected: {item}");
};

// After showing dialog
object? selected = taskDialog.ComboBox.SelectedItem;
```

### 8. KryptonTaskDialogElementHyperLink

Displays a clickable hyperlink with optional description.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Url` | `string` | URL text to display |
| `Description` | `string` | Description text above link |
| `ShowDescription` | `bool` | Show/hide description |
| `ForeColor` | `Color` | Description text color |

#### Events

```csharp
event Action LinkClicked;
```

#### Example

```csharp
taskDialog.HyperLink.Visible = true;
taskDialog.HyperLink.Description = "For more information, visit:";
taskDialog.HyperLink.ShowDescription = true;
taskDialog.HyperLink.Url = "https://www.example.com";

taskDialog.HyperLink.LinkClicked += () =>
{
    Process.Start(new ProcessStartInfo
    {
        FileName = taskDialog.HyperLink.Url,
        UseShellExecute = true
    });
};
```

### 9. KryptonTaskDialogElementProgresBar

Displays a progress bar with optional description.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `ProgressBar` | `KryptonTaskDialogElementProgresBarProperties` | Progress bar configuration |
| `Description` | `string` | Description text above progress bar |
| `ShowDescription` | `bool` | Show/hide description |
| `ForeColor` | `Color` | Description text color |
| `RoundedCorners` | `bool` | Round progress bar corners |

#### ProgressBarProperties

Access via `taskDialog.ProgresBar.ProgressBar`:
- `Value` - Current value
- `Minimum` - Minimum value
- `Maximum` - Maximum value
- `Style` - Block, Continuous, or Marquee
- Many other KryptonProgressBar properties

#### Example

```csharp
taskDialog.ProgresBar.Visible = true;
taskDialog.ProgresBar.Description = "Installing...";
taskDialog.ProgresBar.ShowDescription = true;
taskDialog.ProgresBar.ProgressBar.Minimum = 0;
taskDialog.ProgresBar.ProgressBar.Maximum = 100;
taskDialog.ProgresBar.ProgressBar.Value = 50;
taskDialog.ProgresBar.RoundedCorners = true;
```

### 10. KryptonTaskDialogElementRichTextBox

Displays a rich text box for formatted text input/display.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Text` | `string` | Plain text content |
| `Enabled` | `bool` | Enable/disable control |
| `ReadOnly` | `bool` | Read-only mode |
| `ScrollBars` | `RichTextBoxScrollBars` | Scrollbar visibility |
| `ElementHeight` | `int` | Control height |
| `EnableContextMenu` | `bool` | Show context menu |
| `RoundedCorners` | `bool` | Round corners |

#### Example

```csharp
taskDialog.RichTextBox.Visible = true;
taskDialog.RichTextBox.Text = "This is editable text.";
taskDialog.RichTextBox.ElementHeight = 200;
taskDialog.RichTextBox.ScrollBars = RichTextBoxScrollBars.Vertical;
taskDialog.RichTextBox.ReadOnly = false;
taskDialog.RichTextBox.EnableContextMenu = true;
taskDialog.RichTextBox.RoundedCorners = true;
```

### 11. KryptonTaskDialogElementFreeWheeler1

Provides a `FlowLayoutPanel` for hosting custom controls.

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `FlowLayoutPanel` | `FlowLayoutPanel` | Panel to add controls to |
| `ElementHeight` | `int` | Control height |

#### Example

```csharp
taskDialog.FreeWheeler1.Visible = true;
taskDialog.FreeWheeler1.ElementHeight = 150;

// Add custom controls
var label = new Label { Text = "Custom Label" };
var textBox = new TextBox();
taskDialog.FreeWheeler1.FlowLayoutPanel.Controls.Add(label);
taskDialog.FreeWheeler1.FlowLayoutPanel.Controls.Add(textBox);
```

### 12. KryptonTaskDialogElementFreeWheeler2

Provides a `TableLayoutPanel` for hosting custom controls.

Similar to FreeWheeler1 but uses TableLayoutPanel instead of FlowLayoutPanel. Better for controls that require precise positioning.

---

## API Reference

### KryptonTaskDialogDefaults

Internal structure containing default values for spacing, sizing, and layout.

```csharp
public record struct KryptonTaskDialogDefaults
{
    public int ClientWidth { get; }
    public int ClientHeight { get; }
    public int PanelLeft { get; }      // Default: 10
    public int PanelTop { get; }       // Default: 10
    public int PanelBottom { get; }    // Default: 10
    public int PanelRight { get; }     // Default: 10
    public int ComponentSpace { get; } // Default: 10
    public int CornerRoundingRatio { get; } // Default: 10
    
    public Padding NullPadding { get; }
    public Padding NullMargin { get; }
    public Padding PanelPadding1 { get; }
    public Size ButtonSize_75x24 { get; }
    public Size ButtonSize_24x75 { get; }
    
    public int GetCornerRouding(bool roundingEnabled);
}
```

### KryptonTaskDialogIconController

Internal class managing icon caching and resizing.

```csharp
public class KryptonTaskDialogIconController : IDisposable
{
    // Get icon resized to specified size
    public Image GetImage(KryptonTaskDialogIconType icontype, int size);
}
```

### KryptonTaskDialogKryptonForm

Specialized `KryptonForm` with dialog-specific behavior.

```csharp
public class KryptonTaskDialogKryptonForm : KryptonForm
{
    // Disable Alt+F4
    public bool IgnoreAltF4 { get; set; }
}
```

---

## Usage Examples

### Example 1: Simple Confirmation Dialog

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "Confirm Delete";
    
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "Delete File";
    taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldWarning;
    
    taskDialog.Content.Visible = true;
    taskDialog.Content.Text = "Are you sure you want to delete this file?\nThis action cannot be undone.";
    
    taskDialog.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.Yes | 
        KryptonTaskDialogCommonButtonTypes.No;
    taskDialog.FooterBar.CommonButtons.AcceptButton = KryptonTaskDialogCommonButtonTypes.No;
    
    DialogResult result = taskDialog.ShowDialog(this);
    
    if (result == DialogResult.Yes)
    {
        // Delete the file
    }
}
```

### Example 2: Progress Dialog (Modeless)

```csharp
KryptonTaskDialog progressDialog = new KryptonTaskDialog();

progressDialog.Dialog.Form.Text = "Processing";
progressDialog.Dialog.Form.CloseBox = false;
progressDialog.Dialog.Form.IgnoreAltF4 = true;

progressDialog.Heading.Visible = true;
progressDialog.Heading.Text = "Please Wait";
progressDialog.Heading.IconType = KryptonTaskDialogIconType.Gear;

progressDialog.Content.Visible = true;
progressDialog.Content.Text = "Processing files...";

progressDialog.ProgresBar.Visible = true;
progressDialog.ProgresBar.ProgressBar.Minimum = 0;
progressDialog.ProgresBar.ProgressBar.Maximum = 100;
progressDialog.ProgresBar.ProgressBar.Value = 0;

progressDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.Cancel;

// Show modeless
progressDialog.Show(this);

// Update progress from background thread
for (int i = 0; i <= 100; i++)
{
    progressDialog.ProgresBar.ProgressBar.Value = i;
    progressDialog.Content.Text = $"Processing file {i} of 100...";
    Thread.Sleep(50);
}

progressDialog.CloseDialog();
progressDialog.Dispose();
```

### Example 3: Input Dialog with ComboBox

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "Select Option";
    
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "Choose Export Format";
    
    taskDialog.Content.Visible = true;
    taskDialog.Content.Text = "Please select the format for exporting your data:";
    
    taskDialog.ComboBox.Visible = true;
    taskDialog.ComboBox.Description = "Export Format:";
    taskDialog.ComboBox.Items.Add("PDF Document");
    taskDialog.ComboBox.Items.Add("Excel Spreadsheet");
    taskDialog.ComboBox.Items.Add("CSV File");
    taskDialog.ComboBox.Items.Add("XML File");
    taskDialog.ComboBox.DropDownStyle = InternalComboBoxStyle.DropDownList;
    
    taskDialog.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.OK | 
        KryptonTaskDialogCommonButtonTypes.Cancel;
    
    DialogResult result = taskDialog.ShowDialog(this);
    
    if (result == DialogResult.OK && taskDialog.ComboBox.SelectedItem != null)
    {
        string format = taskDialog.ComboBox.SelectedItem.ToString();
        // Export with selected format
    }
}
```

### Example 4: Command Link Dialog

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "Update Available";
    
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "A new version is available";
    taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldInformation;
    
    taskDialog.Content.Visible = true;
    taskDialog.Content.Text = "Version 2.0 is now available. What would you like to do?";
    
    taskDialog.CommandLinkButtons.Visible = true;
    
    var btnInstall = new KryptonCommandLinkButton();
    btnInstall.Text = "Install Now";
    btnInstall.Description = "Download and install the update immediately";
    btnInstall.DialogResult = DialogResult.Yes;
    taskDialog.CommandLinkButtons.Buttons.Add(btnInstall);
    
    var btnLater = new KryptonCommandLinkButton();
    btnLater.Text = "Remind Me Later";
    btnLater.Description = "I'll install the update at another time";
    btnLater.DialogResult = DialogResult.No;
    taskDialog.CommandLinkButtons.Buttons.Add(btnLater);
    
    var btnSkip = new KryptonCommandLinkButton();
    btnSkip.Text = "Skip This Version";
    btnSkip.Description = "Don't notify me about this version";
    btnSkip.DialogResult = DialogResult.Ignore;
    taskDialog.CommandLinkButtons.Buttons.Add(btnSkip);
    
    taskDialog.FooterBar.Visible = false; // Using command links instead
    
    DialogResult result = taskDialog.ShowDialog(this);
    
    switch (result)
    {
        case DialogResult.Yes:
            // Install now
            break;
        case DialogResult.No:
            // Remind later
            break;
        case DialogResult.Ignore:
            // Skip version
            break;
    }
}
```

### Example 5: Expandable Details Dialog

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "Error";
    
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "An Error Occurred";
    taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldError;
    
    taskDialog.Content.Visible = true;
    taskDialog.Content.Text = "The operation could not be completed.";
    
    // Configure expandable details
    taskDialog.Expander.Visible = false; // Initially hidden
    taskDialog.Expander.Text = "Exception Details:\n\n" +
        "System.IO.FileNotFoundException: File not found\n" +
        "   at MyApp.FileManager.Open(String path)\n" +
        "   at MyApp.MainForm.LoadDocument()";
    
    taskDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;
    taskDialog.FooterBar.Footer.EnableExpanderControls = true;
    taskDialog.FooterBar.Footer.ExpanderExpandedText = "Show Details";
    taskDialog.FooterBar.Footer.ExpanderCollapsedText = "Hide Details";
    
    taskDialog.ShowDialog(this);
}
```

### Example 6: Custom Controls with FreeWheeler

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog(700))
{
    taskDialog.Dialog.Form.Text = "Advanced Settings";
    
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "Configure Options";
    
    taskDialog.FreeWheeler1.Visible = true;
    taskDialog.FreeWheeler1.ElementHeight = 200;
    
    var flp = taskDialog.FreeWheeler1.FlowLayoutPanel;
    flp.FlowDirection = FlowDirection.TopDown;
    
    // Add custom controls
    var lblName = new Label { Text = "Name:", Width = 100 };
    var txtName = new KryptonTextBox { Width = 200 };
    
    var lblEmail = new Label { Text = "Email:", Width = 100 };
    var txtEmail = new KryptonTextBox { Width = 200 };
    
    var lblPhone = new Label { Text = "Phone:", Width = 100 };
    var txtPhone = new KryptonTextBox { Width = 200 };
    
    flp.Controls.Add(lblName);
    flp.Controls.Add(txtName);
    flp.Controls.Add(lblEmail);
    flp.Controls.Add(txtEmail);
    flp.Controls.Add(lblPhone);
    flp.Controls.Add(txtPhone);
    
    taskDialog.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.OK | 
        KryptonTaskDialogCommonButtonTypes.Cancel;
    
    DialogResult result = taskDialog.ShowDialog(this);
    
    if (result == DialogResult.OK)
    {
        string name = txtName.Text;
        string email = txtEmail.Text;
        string phone = txtPhone.Text;
        // Process input
    }
}
```

---

## Advanced Features

### Form Reusability

Unlike traditional dialogs, `KryptonTaskDialog` instances can be reused:

```csharp
KryptonTaskDialog taskDialog = new KryptonTaskDialog();

// Configure once
taskDialog.Dialog.Form.Text = "Status Update";
taskDialog.Heading.Visible = true;
taskDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;

// Show multiple times with different content
for (int i = 1; i <= 5; i++)
{
    taskDialog.Heading.Text = $"Processing Step {i}";
    taskDialog.Content.Text = $"Completed step {i} of 5";
    taskDialog.ShowDialog(this);
}

taskDialog.Dispose();
```

### Modeless Operation with Updates

```csharp
KryptonTaskDialog statusDialog = new KryptonTaskDialog();

statusDialog.Dialog.Form.Text = "Live Status";
statusDialog.Dialog.Form.CloseBox = false;
statusDialog.Heading.Visible = true;
statusDialog.Content.Visible = true;
statusDialog.FooterBar.Visible = false;

statusDialog.Show(this);

// Update from main thread or use Invoke for cross-thread updates
statusDialog.Heading.Text = "Connecting...";
statusDialog.Content.Text = "Establishing connection to server";
// ... perform operation ...

statusDialog.Heading.Text = "Connected";
statusDialog.Content.Text = "Successfully connected";
// ... continue ...

statusDialog.CloseDialog();
statusDialog.Dispose();
```

### Global Color Themes

Apply colors to all elements at once:

```csharp
taskDialog.Dialog.Globals.BackColor1 = Color.LightBlue;
taskDialog.Dialog.Globals.BackColor2 = Color.AliceBlue;
taskDialog.Dialog.Globals.ForeColor = Color.DarkBlue;
taskDialog.Dialog.Globals.RoundedCorners = true;
```

### Element Visibility Management

Hide all elements, then selectively show what you need:

```csharp
taskDialog.HideAllElements();

// Show only what's needed
taskDialog.Heading.Visible = true;
taskDialog.Content.Visible = true;
taskDialog.FooterBar.Visible = true;
```

### Custom Form Positioning

```csharp
// Manual positioning
taskDialog.Dialog.Form.StartPosition = FormStartPosition.Manual;
taskDialog.Dialog.Form.Location = new Point(100, 100);

// Center on specific screen
taskDialog.Dialog.Form.StartPosition = FormStartPosition.CenterScreen;

// Center on parent
taskDialog.Dialog.Form.StartPosition = FormStartPosition.CenterParent;
taskDialog.ShowDialog(this);
```

### Preventing Dismissal

```csharp
// Disable close box and Alt+F4
taskDialog.Dialog.Form.CloseBox = false;
taskDialog.Dialog.Form.IgnoreAltF4 = true;

// Remove cancel button
taskDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;
```

### Element Separators

Add visual separators between elements:

```csharp
taskDialog.Content.ShowSeparator = true;
taskDialog.FooterBar.ShowSeparator = true;
```

### Background Gradients

```csharp
// Set both colors for gradient
taskDialog.Heading.BackColor1 = Color.LightGreen;
taskDialog.Heading.BackColor2 = Color.White;

// Gradient is automatically applied when both colors are set
// Set only one or use Color.Empty to disable gradient
```

---

## Theming and Customization

### Theme Integration

`KryptonTaskDialog` automatically integrates with the active Krypton theme:

```csharp
// The dialog will automatically use the current theme
KryptonManager.CurrentGlobalPalette = KryptonPalette.PaletteOffice2010Blue;

using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    // Dialog automatically uses Office 2010 Blue theme
    taskDialog.ShowDialog();
}
```

### Custom Colors

Override theme colors for specific elements:

```csharp
// Custom heading colors
taskDialog.Heading.BackColor1 = Color.DarkBlue;
taskDialog.Heading.BackColor2 = Color.CornflowerBlue;
taskDialog.Heading.ForeColor = Color.White;

// Custom content colors
taskDialog.Content.BackColor1 = Color.WhiteSmoke;
taskDialog.Content.ForeColor = Color.Black;

// Custom footer colors
taskDialog.FooterBar.BackColor1 = Color.LightGray;
taskDialog.FooterBar.ForeColor = Color.DarkSlateGray;
```

### Rounded Corners

Control corner rounding globally or per element:

```csharp
// Global rounded corners
taskDialog.Dialog.Globals.RoundedCorners = true;

// Or per element
taskDialog.FooterBar.RoundedCorners = true;
taskDialog.ComboBox.RoundedCorners = true;
taskDialog.ProgresBar.RoundedCorners = true;
taskDialog.RichTextBox.RoundedCorners = true;

// Form corners
taskDialog.Dialog.Form.RoundedCorners = true;
```

### Custom Dialog Width

```csharp
// Default width is 600 pixels
KryptonTaskDialog taskDialog = new KryptonTaskDialog();

// Custom width (e.g., 800 pixels)
KryptonTaskDialog wideDialog = new KryptonTaskDialog(800);
```

### Font Customization

The component respects the theme's base font, but you can customize if needed by accessing internal controls through derived classes or by setting theme fonts.

---

## Best Practices

### 1. Resource Management

Always dispose of dialogs when done:

```csharp
// Using statement (preferred)
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    // Configure and show dialog
}

// Or explicit disposal
KryptonTaskDialog taskDialog = new KryptonTaskDialog();
try
{
    // Configure and show dialog
}
finally
{
    taskDialog.Dispose();
}
```

### 2. Modal vs. Modeless

Use modal dialogs for:
- Decisions requiring immediate user input
- Confirmation dialogs
- Input dialogs

Use modeless dialogs for:
- Progress indicators
- Status updates
- Non-blocking notifications

### 3. Button Configuration

```csharp
// Set appropriate default buttons
taskDialog.FooterBar.CommonButtons.AcceptButton = KryptonTaskDialogCommonButtonTypes.OK;
taskDialog.FooterBar.CommonButtons.CancelButton = KryptonTaskDialogCommonButtonTypes.Cancel;

// This maps to:
// - Enter key → Accept button (OK)
// - Escape key → Cancel button
```

### 4. Element Organization

Show elements in logical order (top to bottom):
1. Heading (title/main message)
2. Content (detailed information)
3. Interactive elements (checkboxes, combo boxes, etc.)
4. Command link buttons (if used)
5. Footer (common buttons and notes)

### 5. Text Formatting

```csharp
// Use Environment.NewLine for line breaks
taskDialog.Content.Text = $"Line 1{Environment.NewLine}Line 2{Environment.NewLine}Line 3";

// Or use string interpolation with \n
taskDialog.Content.Text = "First line\nSecond line\nThird line";
```

### 6. Icon Usage

Choose appropriate icons for context:
- **ShieldError**: Critical errors, failures
- **ShieldWarning**: Warnings, cautions
- **ShieldInformation**: General information
- **ShieldSuccess**: Successful operations
- **ShieldHelp**: Help topics
- **ShieldUac**: Operations requiring elevation

### 7. Progress Dialogs

For long-running operations:

```csharp
KryptonTaskDialog progress = new KryptonTaskDialog();
progress.Dialog.Form.CloseBox = false;
progress.Dialog.Form.IgnoreAltF4 = true;
progress.ProgresBar.Visible = true;

// Consider adding a Cancel button if operation can be cancelled
progress.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.Cancel;

progress.Show(this);

// Update progress in background task
Task.Run(() =>
{
    for (int i = 0; i <= 100; i++)
    {
        if (progress.Dialog.DialogResult == DialogResult.Cancel)
            break;
            
        this.Invoke(() =>
        {
            progress.ProgresBar.ProgressBar.Value = i;
            progress.Content.Text = $"Processing: {i}%";
        });
        
        Thread.Sleep(50);
    }
    
    this.Invoke(() => progress.CloseDialog());
});
```

### 8. Validation

Validate input before closing:

```csharp
taskDialog.ComboBox.Visible = true;
taskDialog.ComboBox.Items.Add("Option 1");
taskDialog.ComboBox.Items.Add("Option 2");

DialogResult result = taskDialog.ShowDialog(this);

if (result == DialogResult.OK)
{
    if (taskDialog.ComboBox.SelectedItem == null)
    {
        KryptonMessageBox.Show("Please select an option.", "Validation Error");
        // Show dialog again or handle as needed
    }
    else
    {
        // Process valid selection
    }
}
```

### 9. Accessibility

Consider accessibility:

```csharp
// Set meaningful text for screen readers
taskDialog.Dialog.Form.Text = "Important: Please Confirm Action";

// Use descriptive text
taskDialog.Heading.Text = "Delete Confirmation";
taskDialog.Content.Text = "Are you sure you want to permanently delete 5 files? This cannot be undone.";

// Clear button labels
// (Common buttons automatically have standard text)
```

### 10. Error Handling

Handle dialog creation errors:

```csharp
try
{
    using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
    {
        // Configure dialog
        taskDialog.Heading.Text = "Test";
        DialogResult result = taskDialog.ShowDialog(this);
    }
}
catch (Exception ex)
{
    // Log error
    Console.WriteLine($"Error showing dialog: {ex.Message}");
    
    // Fallback to simple message box
    MessageBox.Show("An error occurred.", "Error");
}
```

---

## Troubleshooting

### Dialog Not Displaying

**Problem**: Dialog doesn't appear when calling `Show()` or `ShowDialog()`

**Solutions**:
- Ensure at least one element is visible
- Check that `Dialog.Form.StartPosition` is set correctly
- Verify parent form handle is valid if passing owner

### Elements Not Visible

**Problem**: Configured elements don't appear in dialog

**Solutions**:
```csharp
// Make sure element is visible
taskDialog.Content.Visible = true;

// Verify dialog hasn't called HideAllElements()
// If it has, selectively show elements again
```

### Dialog Size Issues

**Problem**: Dialog is too small or doesn't show all content

**Solutions**:
- Dialog height is automatically calculated based on visible elements
- If using custom controls in FreeWheeler, set `ElementHeight`:
```csharp
taskDialog.FreeWheeler1.ElementHeight = 300;
```
- For wider dialogs, specify width in constructor:
```csharp
KryptonTaskDialog taskDialog = new KryptonTaskDialog(800);
```

### Theme Not Applied

**Problem**: Dialog doesn't use current theme

**Solutions**:
- Ensure `KryptonManager.CurrentGlobalPalette` is set before creating dialog
- Theme changes during dialog lifetime are automatically detected
- To force theme update, recreate the dialog instance

### Cross-Thread Updates

**Problem**: Updating modeless dialog from background thread causes exceptions

**Solutions**:
```csharp
// Use Invoke to update from background thread
Task.Run(() =>
{
    this.Invoke(() =>
    {
        taskDialog.Content.Text = "Updated from background thread";
    });
});
```

---

## Performance Considerations

### Dialog Reuse

Reusing dialog instances is more efficient than creating new ones repeatedly:

```csharp
// Good: Reuse instance
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    for (int i = 0; i < 10; i++)
    {
        taskDialog.Content.Text = $"Step {i}";
        taskDialog.ShowDialog();
    }
}

// Less efficient: Create each time
for (int i = 0; i < 10; i++)
{
    using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
    {
        taskDialog.Content.Text = $"Step {i}";
        taskDialog.ShowDialog();
    }
}
```

### Minimize Element Count

Only make visible the elements you actually need:

```csharp
// Start with everything hidden
taskDialog.HideAllElements();

// Show only required elements
taskDialog.Heading.Visible = true;
taskDialog.Content.Visible = true;
taskDialog.FooterBar.Visible = true;
```

### Icon Caching

Icons are automatically cached by `KryptonTaskDialogIconController`, so repeated use of the same icon type doesn't reload the resource.

---

## Migration Guide

### From MessageBox to KryptonTaskDialog

**Before (MessageBox)**:
```csharp
DialogResult result = MessageBox.Show(
    "Are you sure?",
    "Confirm",
    MessageBoxButtons.YesNo,
    MessageBoxIcon.Question);
```

**After (KryptonTaskDialog)**:
```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "Confirm";
    taskDialog.Content.Text = "Are you sure?";
    taskDialog.Content.Visible = true;
    
    taskDialog.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.Yes | 
        KryptonTaskDialogCommonButtonTypes.No;
    
    DialogResult result = taskDialog.ShowDialog();
}
```

### From KryptonMessageBox to KryptonTaskDialog

**Before (KryptonMessageBox)**:
```csharp
KryptonMessageBox.Show(
    "Operation complete!",
    "Success",
    KryptonMessageBoxButtons.OK,
    KryptonMessageBoxIcon.Information);
```

**After (KryptonTaskDialog)**:
```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "Success";
    
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "Operation complete!";
    taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldInformation;
    
    taskDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;
    
    taskDialog.ShowDialog();
}
```

---

## Conclusion

`KryptonTaskDialog` provides a flexible, themeable, and feature-rich dialog system for Windows Forms applications using the Krypton toolkit. Its element-based architecture allows developers to build complex dialogs that can be reused and updated dynamically.

Key advantages:
- **Flexibility**: Compose dialogs from reusable elements
- **Themeable**: Full integration with Krypton themes
- **Reusable**: Show the same dialog instance multiple times
- **Modern**: Supports progress bars, command links, expandable content, and more
- **Extensible**: Add custom controls via FreeWheeler elements

For additional help or to report issues, please refer to the Krypton Toolkit Standard Toolkit repository.

---

**Document Version**: 1.0  
**Last Updated**: October 2025  
**Compatible With**: Krypton Toolkit v100.x.x+

