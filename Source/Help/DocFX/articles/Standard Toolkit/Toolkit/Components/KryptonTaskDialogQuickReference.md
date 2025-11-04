# KryptonTaskDialog Quick Reference Guide

## Quick Start

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "My Dialog";
    taskDialog.Heading.Text = "Main Message";
    taskDialog.Content.Text = "Details here";
    taskDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;
    
    DialogResult result = taskDialog.ShowDialog();
}
```

## Core Concepts

### Constructor
```csharp
new KryptonTaskDialog()      // Default width: 600px
new KryptonTaskDialog(800)   // Custom width: 800px
```

### Display Methods
```csharp
DialogResult ShowDialog(IWin32Window? owner = null);  // Modal
void Show(IWin32Window? owner = null);                // Modeless
void CloseDialog();                                   // Close modeless dialog
void HideAllElements();                               // Hide all elements
```

## Dialog Properties

### Form Properties (taskDialog.Dialog.Form)
```csharp
Text                    // Title bar text
Icon                    // Form icon
StartPosition           // FormStartPosition
Location                // Point (when StartPosition is Manual)
TopMost                 // bool
CloseBox                // bool
MinimizeBox             // bool
MaximizeBox             // bool
ControlBox              // bool
ShowInTaskBar           // bool (only works with Show(), not ShowDialog())
IgnoreAltF4             // bool (disable Alt+F4)
FormTitleAlign          // PaletteRelativeAlign
RoundedCorners          // bool
```

### Global Properties (taskDialog.Dialog.Globals)
```csharp
BackColor1              // Color (applies to all elements)
BackColor2              // Color (applies to all elements)
ForeColor               // Color (applies to all elements)
RoundedCorners          // bool (applies to all elements)
```

### Dialog Result
```csharp
taskDialog.Dialog.DialogResult  // Get after closing
taskDialog.Dialog.Visible       // Is dialog visible?
```

## Elements Quick Reference

### Common Element Properties

Every element has these base properties:
```csharp
Visible         // bool
BackColor1      // Color
BackColor2      // Color (for gradient)
ShowSeparator   // bool (show line at top)
Height          // int (read-only)
```

### 1. Heading

```csharp
taskDialog.Heading.Text = "Title";
taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldInformation;
taskDialog.Heading.TextAlignmentHorizontal = PaletteRelativeAlign.Center;
taskDialog.Heading.ForeColor = Color.Blue;
taskDialog.Heading.Visible = true;
```

**Icon Types**: None, ShieldError, ShieldWarning, ShieldInformation, ShieldSuccess, ShieldHelp, ShieldKrypton, ShieldUac, CheckGreen, Document, Gear, PowerOff, ArrowGrayDown, ArrowGrayUp

### 2. Content

```csharp
taskDialog.Content.Text = "Main content\nwith line breaks";
taskDialog.Content.ForeColor = Color.Black;
taskDialog.Content.ContentImage.Image = myImage;
taskDialog.Content.ContentImage.Size = new Size(48, 48);
taskDialog.Content.ContentImage.Visible = true;
taskDialog.Content.ContentImage.PositionedLeft = true; // true=left, false=right
taskDialog.Content.Visible = true;
```

### 3. Expander

Same as Content. Controlled by FooterBar expander button:
```csharp
taskDialog.Expander.Text = "Detailed info...";
taskDialog.Expander.Visible = false; // Initially hidden

taskDialog.FooterBar.Footer.EnableExpanderControls = true;
taskDialog.FooterBar.Footer.ExpanderExpandedText = "Show Details";
taskDialog.FooterBar.Footer.ExpanderCollapsedText = "Hide Details";
```

### 4. FooterBar

```csharp
// Common Buttons
taskDialog.FooterBar.CommonButtons.Buttons = 
    KryptonTaskDialogCommonButtonTypes.Yes | 
    KryptonTaskDialogCommonButtonTypes.No;
taskDialog.FooterBar.CommonButtons.AcceptButton = KryptonTaskDialogCommonButtonTypes.Yes;
taskDialog.FooterBar.CommonButtons.CancelButton = KryptonTaskDialogCommonButtonTypes.No;

// Footer Note
taskDialog.FooterBar.Footer.FootNoteText = "Note text";
taskDialog.FooterBar.Footer.IconType = KryptonTaskDialogIconType.ShieldWarning;

// Styling
taskDialog.FooterBar.ForeColor = Color.Black;
taskDialog.FooterBar.RoundedCorners = true;
taskDialog.FooterBar.Visible = true;
```

**Button Types** (Flags): None, OK, Cancel, Yes, No, Retry, Abort, Ignore

### 5. CommandLinkButtons

```csharp
taskDialog.CommandLinkButtons.Visible = true;

var button = new KryptonCommandLinkButton();
button.Text = "Option 1";
button.Description = "Description";
button.DialogResult = DialogResult.Yes;
taskDialog.CommandLinkButtons.Buttons.Add(button);

taskDialog.CommandLinkButtons.RoundedCorners = true;
taskDialog.CommandLinkButtons.FlowDirection = FlowDirection.TopDown;
```

### 6. CheckBox

```csharp
taskDialog.CheckBox.Text = "Don't show again";
taskDialog.CheckBox.Checked = false;
taskDialog.CheckBox.ForeColor = Color.Black;
taskDialog.CheckBox.Visible = true;

// After dialog closes
bool wasChecked = taskDialog.CheckBox.Checked;
```

### 7. ComboBox

```csharp
taskDialog.ComboBox.Description = "Select option:";
taskDialog.ComboBox.ShowDescription = true;
taskDialog.ComboBox.Items.Add("Option 1");
taskDialog.ComboBox.Items.Add("Option 2");
taskDialog.ComboBox.ComboxWidth = 250;
taskDialog.ComboBox.DropDownStyle = InternalComboBoxStyle.DropDownList;
taskDialog.ComboBox.RoundedCorners = true;
taskDialog.ComboBox.Visible = true;

// Event
taskDialog.ComboBox.SelectedItemChanged += (item) => { };

// After dialog closes
object? selected = taskDialog.ComboBox.SelectedItem;
int index = taskDialog.ComboBox.SelectedIndex;
```

### 8. HyperLink

```csharp
taskDialog.HyperLink.Description = "Visit our website:";
taskDialog.HyperLink.ShowDescription = true;
taskDialog.HyperLink.Url = "https://example.com";
taskDialog.HyperLink.ForeColor = Color.Black;
taskDialog.HyperLink.Visible = true;

// Event
taskDialog.HyperLink.LinkClicked += () => 
{
    Process.Start(new ProcessStartInfo
    {
        FileName = taskDialog.HyperLink.Url,
        UseShellExecute = true
    });
};
```

### 9. ProgressBar

```csharp
taskDialog.ProgresBar.Description = "Processing...";
taskDialog.ProgresBar.ShowDescription = true;
taskDialog.ProgresBar.ProgressBar.Minimum = 0;
taskDialog.ProgresBar.ProgressBar.Maximum = 100;
taskDialog.ProgresBar.ProgressBar.Value = 50;
taskDialog.ProgresBar.RoundedCorners = true;
taskDialog.ProgresBar.Visible = true;

// Update during operation
taskDialog.ProgresBar.ProgressBar.Value = 75;
```

### 10. RichTextBox

```csharp
taskDialog.RichTextBox.Text = "Editable text";
taskDialog.RichTextBox.ElementHeight = 200;
taskDialog.RichTextBox.ScrollBars = RichTextBoxScrollBars.Vertical;
taskDialog.RichTextBox.ReadOnly = false;
taskDialog.RichTextBox.Enabled = true;
taskDialog.RichTextBox.EnableContextMenu = true;
taskDialog.RichTextBox.RoundedCorners = true;
taskDialog.RichTextBox.Visible = true;
```

### 11. FreeWheeler1 (FlowLayoutPanel)

```csharp
taskDialog.FreeWheeler1.ElementHeight = 150;
taskDialog.FreeWheeler1.Visible = true;

var label = new Label { Text = "Custom:" };
var textBox = new TextBox();
taskDialog.FreeWheeler1.FlowLayoutPanel.Controls.Add(label);
taskDialog.FreeWheeler1.FlowLayoutPanel.Controls.Add(textBox);
```

### 12. FreeWheeler2 (TableLayoutPanel)

Same as FreeWheeler1 but uses TableLayoutPanel instead.

## Common Patterns

### Simple Confirmation
```csharp
using (var dlg = new KryptonTaskDialog())
{
    dlg.Dialog.Form.Text = "Confirm";
    dlg.Heading.Visible = true;
    dlg.Heading.Text = "Are you sure?";
    dlg.Heading.IconType = KryptonTaskDialogIconType.ShieldWarning;
    dlg.Content.Visible = true;
    dlg.Content.Text = "This action cannot be undone.";
    dlg.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.Yes | 
        KryptonTaskDialogCommonButtonTypes.No;
    
    return dlg.ShowDialog() == DialogResult.Yes;
}
```

### Progress Dialog
```csharp
var dlg = new KryptonTaskDialog();
dlg.Dialog.Form.Text = "Processing";
dlg.Dialog.Form.CloseBox = false;
dlg.Dialog.Form.IgnoreAltF4 = true;
dlg.Heading.Visible = true;
dlg.Heading.Text = "Please Wait";
dlg.Content.Visible = true;
dlg.ProgresBar.Visible = true;
dlg.ProgresBar.ProgressBar.Maximum = 100;
dlg.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.Cancel;

dlg.Show(this);

// Update from background thread
this.Invoke(() => 
{
    dlg.ProgresBar.ProgressBar.Value = 50;
    dlg.Content.Text = "50% complete";
});

// Close when done
dlg.CloseDialog();
dlg.Dispose();
```

### Input Dialog
```csharp
using (var dlg = new KryptonTaskDialog())
{
    dlg.Dialog.Form.Text = "Input Required";
    dlg.Content.Visible = true;
    dlg.Content.Text = "Please enter your name:";
    
    dlg.FreeWheeler1.Visible = true;
    dlg.FreeWheeler1.ElementHeight = 50;
    var txt = new KryptonTextBox { Width = 300 };
    dlg.FreeWheeler1.FlowLayoutPanel.Controls.Add(txt);
    
    dlg.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.OK | 
        KryptonTaskDialogCommonButtonTypes.Cancel;
    
    if (dlg.ShowDialog() == DialogResult.OK)
    {
        string input = txt.Text;
        // Use input
    }
}
```

### Dialog Reuse
```csharp
using (var dlg = new KryptonTaskDialog())
{
    dlg.Dialog.Form.Text = "Status";
    dlg.Heading.Visible = true;
    dlg.Content.Visible = true;
    dlg.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;
    
    for (int i = 1; i <= 5; i++)
    {
        dlg.Heading.Text = $"Step {i}";
        dlg.Content.Text = $"Processing step {i} of 5";
        dlg.ShowDialog();
    }
}
```

## Theming

```csharp
// Dialog automatically uses current theme
KryptonManager.CurrentGlobalPalette = KryptonPalette.PaletteOffice2010Blue;

// Override theme colors
taskDialog.Heading.BackColor1 = Color.Navy;
taskDialog.Heading.BackColor2 = Color.LightBlue;
taskDialog.Heading.ForeColor = Color.White;

// Global color override
taskDialog.Dialog.Globals.BackColor1 = Color.WhiteSmoke;
taskDialog.Dialog.Globals.ForeColor = Color.Black;
taskDialog.Dialog.Globals.RoundedCorners = true;
```

## Best Practices

1. **Always dispose**: Use `using` statements or explicit disposal
2. **Modal for decisions**: Use `ShowDialog()` for confirmations
3. **Modeless for progress**: Use `Show()` for long operations
4. **Set default buttons**: Configure AcceptButton and CancelButton
5. **Hide unused elements**: Only show what you need
6. **Reuse instances**: More efficient than creating new dialogs
7. **Thread safety**: Use `Invoke()` for cross-thread updates

## Common Mistakes

### ❌ Don't
```csharp
// Don't show without making elements visible
var dlg = new KryptonTaskDialog();
dlg.ShowDialog(); // Nothing visible!

// Don't forget to dispose
var dlg = new KryptonTaskDialog();
dlg.ShowDialog();
// Memory leak!

// Don't update modeless dialog from background thread directly
Task.Run(() => dlg.Content.Text = "Update"); // Exception!
```

### ✅ Do
```csharp
// Make elements visible
using (var dlg = new KryptonTaskDialog())
{
    dlg.Heading.Visible = true;
    dlg.Content.Visible = true;
    dlg.ShowDialog();
} // Automatically disposed

// Use Invoke for cross-thread updates
Task.Run(() => 
{
    this.Invoke(() => dlg.Content.Text = "Update");
});
```

## Cheat Sheet

### Element Visibility Toggle
```csharp
dlg.HideAllElements();
dlg.Heading.Visible = true;
dlg.Content.Visible = true;
dlg.FooterBar.Visible = true;
```

### Gradient Background
```csharp
element.BackColor1 = Color.LightBlue; // Top
element.BackColor2 = Color.White;     // Bottom
// Gradient automatically applied when both set
```

### Positioning
```csharp
// Center on screen (default)
dlg.Dialog.Form.StartPosition = FormStartPosition.CenterScreen;

// Center on parent
dlg.Dialog.Form.StartPosition = FormStartPosition.CenterParent;
dlg.ShowDialog(this);

// Manual position
dlg.Dialog.Form.StartPosition = FormStartPosition.Manual;
dlg.Dialog.Form.Location = new Point(100, 100);
```

### Prevent Close
```csharp
dlg.Dialog.Form.CloseBox = false;
dlg.Dialog.Form.IgnoreAltF4 = true;
```

---

**For detailed documentation, see**:
[KryptonTaskDialogDeveloperOverView](KryptonTaskDialogDeveloperOverView.md)

