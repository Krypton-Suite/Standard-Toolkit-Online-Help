# KryptonTaskDialog API Reference

Complete API reference for the KryptonTaskDialog component.

## Namespace
```csharp
Krypton.Toolkit
```

---

## Class: KryptonTaskDialog

Main class for creating and displaying task dialogs.

### Inheritance
```csharp
System.Object
  └─ KryptonTaskDialog : IDisposable
```

### Constructor

#### KryptonTaskDialog()
```csharp
public KryptonTaskDialog(int dialogWidth = 0)
```
Creates a new instance of KryptonTaskDialog.

**Parameters:**
- `dialogWidth` - Width of the dialog in pixels. Default is 600 if 0 or less.

**Example:**
```csharp
var dialog = new KryptonTaskDialog();        // 600px width
var wideDialog = new KryptonTaskDialog(800); // 800px width
```

---

### Properties

#### Dialog
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogFormProperties Dialog { get; }
```
Gets the dialog form properties container.

#### Heading
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementHeading Heading { get; }
```
Gets the heading element properties.

#### Content
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementContent Content { get; }
```
Gets the main content element properties.

#### Expander
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementContent Expander { get; }
```
Gets the expandable content element properties. Controlled by footer expander button.

#### RichTextBox
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementRichTextBox RichTextBox { get; }
```
Gets the rich text box element properties.

#### FreeWheeler1
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementFreeWheeler1 FreeWheeler1 { get; }
```
Gets the FlowLayoutPanel container element for custom controls.

#### FreeWheeler2
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementFreeWheeler2 FreeWheeler2 { get; }
```
Gets the TableLayoutPanel container element for custom controls.

#### CommandLinkButtons
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementCommandLinkButtons CommandLinkButtons { get; }
```
Gets the command link buttons collection element.

#### CheckBox
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementCheckBox CheckBox { get; }
```
Gets the checkbox element properties.

#### ComboBox
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementComboBox ComboBox { get; }
```
Gets the combo box element properties.

#### HyperLink
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementHyperLink HyperLink { get; }
```
Gets the hyperlink element properties.

#### ProgresBar
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementProgresBar ProgresBar { get; }
```
Gets the progress bar element properties.

#### FooterBar
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementFooterBar FooterBar { get; }
```
Gets the footer bar element properties.

---

### Methods

#### ShowDialog
```csharp
public DialogResult ShowDialog(IWin32Window? owner = null)
```
Shows the dialog as a modal dialog (blocks until closed).

**Parameters:**
- `owner` - The parent window that owns this dialog.

**Returns:** The DialogResult indicating how the dialog was closed.

**Example:**
```csharp
DialogResult result = taskDialog.ShowDialog(this);
if (result == DialogResult.OK)
{
    // Handle OK
}
```

#### Show
```csharp
public void Show(IWin32Window? owner = null)
```
Shows the dialog as a modeless dialog (non-blocking).

**Parameters:**
- `owner` - The parent window that launched this dialog.

**Example:**
```csharp
taskDialog.Show(this);
// Continue execution while dialog is visible
```

#### CloseDialog
```csharp
public void CloseDialog()
```
Closes a modeless dialog. Has no effect if dialog is not visible.

**Example:**
```csharp
taskDialog.Show();
// ... do work ...
taskDialog.CloseDialog();
```

#### HideAllElements
```csharp
public void HideAllElements()
```
Hides all dialog elements at once.

**Example:**
```csharp
taskDialog.HideAllElements();
taskDialog.Heading.Visible = true;
taskDialog.Content.Visible = true;
```

#### Dispose
```csharp
public void Dispose()
```
Releases all resources used by the KryptonTaskDialog.

---

## Class: KryptonTaskDialogFormProperties

Provides access to form-level and global properties.

### Properties

#### Form
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public FormInstance Form { get; }
```
Gets the form properties.

#### Globals
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public GlobalInstance Globals { get; }
```
Gets the global properties that apply to all elements.

#### Visible
```csharp
public bool Visible { get; }
```
Gets whether the dialog is currently visible.

#### DialogResult
```csharp
public DialogResult DialogResult { get; }
```
Gets the dialog result after the dialog has been closed.

---

## Class: KryptonTaskDialogFormProperties.FormInstance

Form-level properties.

### Properties

#### Location
```csharp
public Point Location { get; set; }
```
Gets or sets the dialog position. Set StartPosition to Manual first.

#### StartPosition
```csharp
public FormStartPosition StartPosition { get; set; }
```
Gets or sets the dialog start position.

**Values:**
- `FormStartPosition.Manual` - Use Location property
- `FormStartPosition.CenterScreen` - Center on primary screen
- `FormStartPosition.CenterParent` - Center on owner window
- `FormStartPosition.WindowsDefaultLocation` - Windows default

#### Text
```csharp
public string Text { get; set; }
```
Gets or sets the title bar text.

#### Icon
```csharp
public Icon? Icon { get; set; }
```
Gets or sets the form icon.

#### TopMost
```csharp
public bool TopMost { get; set; }
```
Gets or sets whether the dialog stays on top of other windows.

#### ControlBox
```csharp
public bool ControlBox { get; set; }
```
Gets or sets whether the system menu button is shown.

#### CloseBox
```csharp
public bool CloseBox { get; set; }
```
Gets or sets whether the close button is shown.

#### MinimizeBox
```csharp
public bool MinimizeBox { get; set; }
```
Gets or sets whether the minimize button is shown.

#### MaximizeBox
```csharp
public bool MaximizeBox { get; set; }
```
Gets or sets whether the maximize button is shown.

#### ShowInTaskBar
```csharp
public bool ShowInTaskBar { get; set; }
```
Gets or sets whether the dialog shows in the Windows taskbar. Only works with Show(), not ShowDialog().

#### IgnoreAltF4
```csharp
public bool IgnoreAltF4 { get; set; }
```
Gets or sets whether Alt+F4 is disabled.

#### FormTitleAlign
```csharp
public PaletteRelativeAlign FormTitleAlign { get; set; }
```
Gets or sets the title bar text alignment.

**Values:**
- `PaletteRelativeAlign.Near` - Left-aligned
- `PaletteRelativeAlign.Center` - Centered
- `PaletteRelativeAlign.Far` - Right-aligned

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Gets or sets whether the form has rounded corners.

#### AutoScaleMode
```csharp
public AutoScaleMode AutoScaleMode { get; set; }
```
Gets or sets the DPI scaling mode.

---

## Class: KryptonTaskDialogFormProperties.GlobalInstance

Global properties that apply to all elements.

### Properties

#### BackColor1
```csharp
public Color BackColor1 { get; set; }
```
Sets the first background color for all elements.

#### BackColor2
```csharp
public Color BackColor2 { get; set; }
```
Sets the second background color for gradient for all elements.

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Sets the text color for all elements that support it.

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Sets rounded corners for all elements that support it.

---

## Interface: IKryptonTaskDialogElementBase

Base interface implemented by all elements.

### Properties

#### Visible
```csharp
public bool Visible { get; set; }
```
Gets or sets whether the element is visible in the dialog.

#### BackColor1
```csharp
public Color BackColor1 { get; set; }
```
Gets or sets the first background color. Overrides theme color.

#### BackColor2
```csharp
public Color BackColor2 { get; set; }
```
Gets or sets the second background color for gradient. Overrides theme color.

#### Height
```csharp
public int Height { get; }
```
Gets the element height. Returns 0 when not visible.

---

## Class: KryptonTaskDialogElementHeading

Heading element with text and icon.

### Inheritance
```csharp
KryptonTaskDialogElementBase
  └─ KryptonTaskDialogElementHeading
      : IKryptonTaskDialogElementIconType
      : IKryptonTaskDialogElementTextAlignmentHorizontal
      : IKryptonTaskDialogElementForeColor
      : IKryptonTaskDialogElementText
```

### Properties

#### Text
```csharp
public string Text { get; set; }
```
Gets or sets the heading text.

#### IconType
```csharp
public KryptonTaskDialogIconType IconType { get; set; }
```
Gets or sets the icon type.

**Values:**
- `None` - No icon
- `ArrowGrayDown` - Down arrow
- `ArrowGrayUp` - Up arrow
- `CheckGreen` - Green checkmark
- `Document` - Document icon
- `Gear` - Settings gear
- `PowerOff` - Power button
- `ShieldError` - Red error shield
- `ShieldHelp` - Help shield
- `ShieldInformation` - Blue information shield
- `ShieldKrypton` - Krypton branded shield
- `ShieldSuccess` - Green success shield
- `ShieldUac` - UAC elevation shield
- `ShieldWarning` - Yellow warning shield

#### TextAlignmentHorizontal
```csharp
public PaletteRelativeAlign TextAlignmentHorizontal { get; set; }
```
Gets or sets the horizontal text alignment.

**Values:**
- `PaletteRelativeAlign.Near` - Left-aligned
- `PaletteRelativeAlign.Center` - Centered
- `PaletteRelativeAlign.Far` - Right-aligned

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the text color.

---

## Class: KryptonTaskDialogElementContent

Content element with text and optional image.

### Inheritance
```csharp
KryptonTaskDialogElementBase
  └─ KryptonTaskDialogElementContent
      : IKryptonTaskDialogElementContent
      : IKryptonTaskDialogElementForeColor
```

### Properties

#### Text
```csharp
public string Text { get; set; }
```
Gets or sets the content text. Supports line breaks.

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the text color.

#### ContentImage
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public ContentImageStorage ContentImage { get; }
```
Gets the image configuration.

---

## Class: KryptonTaskDialogElementContent.ContentImageStorage

Image configuration for content elements.

### Properties

#### Image
```csharp
public Image? Image { get; set; }
```
Gets or sets the image to display.

#### Size
```csharp
public Size Size { get; set; }
```
Gets or sets the image size. Use (0, 0) for original size.

#### Visible
```csharp
public bool Visible { get; set; }
```
Gets or sets whether the image is visible.

#### PositionedLeft
```csharp
public bool PositionedLeft { get; set; }
```
Gets or sets whether the image is positioned left (true) or right (false) of text.

---

## Class: KryptonTaskDialogElementFooterBar

Footer bar with buttons, notes, and expander control.

### Inheritance
```csharp
KryptonTaskDialogElementBase
  └─ KryptonTaskDialogElementFooterBar
      : IKryptonTaskDialogElementForeColor
      : IKryptonTaskDialogElementRoundedCorners
```

### Properties

#### CommonButtons
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementFooterBarCommonButtonProperties CommonButtons { get; }
```
Gets the common button configuration.

#### Footer
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementFooterBarFooterProperties Footer { get; }
```
Gets the footer properties (note text and expander).

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the text color for footer text and expander text.

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Gets or sets whether buttons have rounded corners.

---

## Class: KryptonTaskDialogElementFooterBarCommonButtonProperties

Common button configuration.

### Properties

#### Buttons
```csharp
public KryptonTaskDialogCommonButtonTypes Buttons { get; set; }
```
Gets or sets which buttons to display (flags enum).

**Values:**
- `None` - No buttons
- `OK` - OK button
- `Cancel` - Cancel button
- `Yes` - Yes button
- `No` - No button
- `Retry` - Retry button
- `Abort` - Abort button
- `Ignore` - Ignore button

**Example:**
```csharp
CommonButtons.Buttons = 
    KryptonTaskDialogCommonButtonTypes.Yes | 
    KryptonTaskDialogCommonButtonTypes.No |
    KryptonTaskDialogCommonButtonTypes.Cancel;
```

#### AcceptButton
```csharp
public KryptonTaskDialogCommonButtonTypes AcceptButton { get; set; }
```
Gets or sets which button is the default accept button (Enter key).

#### CancelButton
```csharp
public KryptonTaskDialogCommonButtonTypes CancelButton { get; set; }
```
Gets or sets which button is the default cancel button (Escape key).

---

## Class: KryptonTaskDialogElementFooterBarFooterProperties

Footer note and expander configuration.

### Properties

#### FootNoteText
```csharp
public string FootNoteText { get; set; }
```
Gets or sets the footer note text.

#### IconType
```csharp
public KryptonTaskDialogIconType IconType { get; set; }
```
Gets or sets the footer note icon.

#### EnableExpanderControls
```csharp
public bool EnableExpanderControls { get; set; }
```
Gets or sets whether the expander button and text are shown.

#### ExpanderExpandedText
```csharp
public string ExpanderExpandedText { get; set; }
```
Gets or sets the text shown when the expander is collapsed (to expand it).

#### ExpanderCollapsedText
```csharp
public string ExpanderCollapsedText { get; set; }
```
Gets or sets the text shown when the expander is expanded (to collapse it).

---

## Class: KryptonTaskDialogElementCommandLinkButtons

Command link buttons collection.

### Inheritance
```csharp
KryptonTaskDialogElementBase
  └─ KryptonTaskDialogElementCommandLinkButtons
      : IKryptonTaskDialogElementRoundedCorners
      : IKryptonTaskDialogElementFlowDirection
```

### Properties

#### Buttons
```csharp
[Editor(typeof(ButtonsCollectionEditor), typeof(UITypeEditor))]
public ObservableCollection<KryptonCommandLinkButton> Buttons { get; }
```
Gets the command link button collection.

**Example:**
```csharp
var button = new KryptonCommandLinkButton();
button.Text = "Option 1";
button.Description = "Description text";
button.DialogResult = DialogResult.Yes;
CommandLinkButtons.Buttons.Add(button);
```

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Gets or sets whether buttons have rounded corners.

#### ShowFlowDirection
```csharp
public bool ShowFlowDirection { get; set; }
```
Gets or sets whether the flow direction toggle button is shown.

#### FlowDirection
```csharp
public FlowDirection FlowDirection { get; set; }
```
Gets or sets the button layout direction.

**Values:**
- `FlowDirection.LeftToRight`
- `FlowDirection.TopDown`
- `FlowDirection.RightToLeft`
- `FlowDirection.BottomUp`

---

## Class: KryptonTaskDialogElementCheckBox

Checkbox element.

### Inheritance
```csharp
KryptonTaskDialogElementSingleLineControlBase
  └─ KryptonTaskDialogElementCheckBox
      : IKryptonTaskDialogElementText
```

### Properties

#### Text
```csharp
public string Text { get; set; }
```
Gets or sets the checkbox text.

#### Checked
```csharp
public bool Checked { get; set; }
```
Gets or sets the checked state.

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the text color.

---

## Class: KryptonTaskDialogElementComboBox

ComboBox element with optional description.

### Inheritance
```csharp
KryptonTaskDialogElementSingleLineControlBase
  └─ KryptonTaskDialogElementComboBox
      : IKryptonTaskDialogElementDescription
      : IKryptonTaskDialogElementRoundedCorners
```

### Properties

#### Items
```csharp
[Editor("System.Windows.Forms.Design.ListControlStringCollectionEditor, ...", typeof(UITypeEditor))]
public ComboBox.ObjectCollection Items { get; }
```
Gets the items collection.

**Example:**
```csharp
ComboBox.Items.Add("Option 1");
ComboBox.Items.Add("Option 2");
```

#### SelectedIndex
```csharp
public int SelectedIndex { get; }
```
Gets the selected item index. Returns -1 if no selection.

#### SelectedItem
```csharp
public object? SelectedItem { get; }
```
Gets the selected item. Returns null if no selection.

#### ComboxWidth
```csharp
[DefaultValue(250)]
public int ComboxWidth { get; set; }
```
Gets or sets the combo box width.

#### DropDownWidth
```csharp
public int DropDownWidth { get; set; }
```
Gets or sets the drop-down list width.

#### DropDownStyle
```csharp
public InternalComboBoxStyle DropDownStyle { get; set; }
```
Gets or sets the combo box style.

**Values:**
- `InternalComboBoxStyle.DropDown` - Editable
- `InternalComboBoxStyle.DropDownList` - Selection only

#### Description
```csharp
public string Description { get; set; }
```
Gets or sets the description text above the combo box.

#### ShowDescription
```csharp
public bool ShowDescription { get; set; }
```
Gets or sets whether the description is visible.

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the description text color.

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Gets or sets whether the combo box has rounded corners.

### Events

#### SelectedItemChanged
```csharp
public event Action<object?> SelectedItemChanged;
```
Raised when the selected item changes.

---

## Class: KryptonTaskDialogElementHyperLink

Hyperlink element with optional description.

### Inheritance
```csharp
KryptonTaskDialogElementSingleLineControlBase
  └─ KryptonTaskDialogElementHyperLink
      : IKryptonTaskDialogElementDescription
      : IKryptonTaskDialogElementUrl
```

### Properties

#### Url
```csharp
public string Url { get; set; }
```
Gets or sets the URL text to display.

#### Description
```csharp
public string Description { get; set; }
```
Gets or sets the description text above the link.

#### ShowDescription
```csharp
public bool ShowDescription { get; set; }
```
Gets or sets whether the description is visible.

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the description text color.

### Events

#### LinkClicked
```csharp
public event Action LinkClicked;
```
Raised when the link is clicked.

---

## Class: KryptonTaskDialogElementProgresBar

Progress bar element with optional description.

### Inheritance
```csharp
KryptonTaskDialogElementSingleLineControlBase
  └─ KryptonTaskDialogElementProgresBar
      : IKryptonTaskDialogElementDescription
      : IKryptonTaskDialogElementRoundedCorners
```

### Properties

#### ProgressBar
```csharp
[TypeConverter(typeof(ExpandableObjectConverter))]
public KryptonTaskDialogElementProgresBarProperties ProgressBar { get; }
```
Gets the progress bar configuration. Exposes most KryptonProgressBar properties including:
- `Value` - Current value
- `Minimum` - Minimum value
- `Maximum` - Maximum value
- `Style` - Block, Continuous, or Marquee
- Many other KryptonProgressBar properties

#### Description
```csharp
public string Description { get; set; }
```
Gets or sets the description text above the progress bar.

#### ShowDescription
```csharp
public bool ShowDescription { get; set; }
```
Gets or sets whether the description is visible.

#### ForeColor
```csharp
public Color ForeColor { get; set; }
```
Gets or sets the description text color.

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Gets or sets whether the progress bar has rounded corners.

---

## Class: KryptonTaskDialogElementRichTextBox

Rich text box element.

### Inheritance
```csharp
KryptonTaskDialogElementBase
  └─ KryptonTaskDialogElementRichTextBox
      : IKryptonTaskDialogElementText
      : IKryptonTaskDialogElementHeight
      : IKryptonTaskDialogElementRoundedCorners
```

### Properties

#### Text
```csharp
public string Text { get; set; }
```
Gets or sets the plain text content.

#### Enabled
```csharp
public bool Enabled { get; set; }
```
Gets or sets whether the control is enabled.

#### ReadOnly
```csharp
public bool ReadOnly { get; set; }
```
Gets or sets whether the text is read-only.

#### ScrollBars
```csharp
public RichTextBoxScrollBars ScrollBars { get; set; }
```
Gets or sets which scrollbars are enabled.

**Values:**
- `RichTextBoxScrollBars.None`
- `RichTextBoxScrollBars.Horizontal`
- `RichTextBoxScrollBars.Vertical`
- `RichTextBoxScrollBars.Both`
- `RichTextBoxScrollBars.ForcedHorizontal`
- `RichTextBoxScrollBars.ForcedVertical`
- `RichTextBoxScrollBars.ForcedBoth`

#### ElementHeight
```csharp
public int ElementHeight { get; set; }
```
Gets or sets the element height.

#### EnableContextMenu
```csharp
public bool EnableContextMenu { get; set; }
```
Gets or sets whether the context menu (Copy/Cut/Paste) is enabled.

#### RoundedCorners
```csharp
public bool RoundedCorners { get; set; }
```
Gets or sets whether the control has rounded corners.

---

## Class: KryptonTaskDialogElementFreeWheeler1

FlowLayoutPanel container for custom controls.

### Inheritance
```csharp
KryptonTaskDialogElementSingleLineControlBase
  └─ KryptonTaskDialogElementFreeWheeler1
      : IKryptonTaskDialogElementHeight
```

### Properties

#### FlowLayoutPanel
```csharp
public FlowLayoutPanel FlowLayoutPanel { get; }
```
Gets the internal FlowLayoutPanel to add controls to.

**Example:**
```csharp
var label = new Label { Text = "Name:" };
var textBox = new TextBox();
FreeWheeler1.FlowLayoutPanel.Controls.Add(label);
FreeWheeler1.FlowLayoutPanel.Controls.Add(textBox);
```

#### ElementHeight
```csharp
public int ElementHeight { get; set; }
```
Gets or sets the element height.

---

## Class: KryptonTaskDialogElementFreeWheeler2

TableLayoutPanel container for custom controls.

### Inheritance
```csharp
KryptonTaskDialogElementSingleLineControlBase
  └─ KryptonTaskDialogElementFreeWheeler2
      : IKryptonTaskDialogElementHeight
```

### Properties

#### TableLayoutPanel
```csharp
public TableLayoutPanel TableLayoutPanel { get; }
```
Gets the internal TableLayoutPanel to add controls to.

#### ElementHeight
```csharp
public int ElementHeight { get; set; }
```
Gets or sets the element height.

---

## Enum: KryptonTaskDialogIconType

Icon types for heading and footer.

```csharp
public enum KryptonTaskDialogIconType
{
    None = 0,
    ArrowGrayDown,
    ArrowGrayUp,
    CheckGreen,
    Document,
    Gear,
    PowerOff,
    ShieldError,
    ShieldHelp,
    ShieldInformation,
    ShieldKrypton,
    ShieldSuccess,
    ShieldUac,
    ShieldWarning
}
```

---

## Enum: KryptonTaskDialogCommonButtonTypes

Common button types (flags enum).

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

**Example:**
```csharp
// Single button
Buttons = KryptonTaskDialogCommonButtonTypes.OK;

// Multiple buttons
Buttons = KryptonTaskDialogCommonButtonTypes.Yes | 
          KryptonTaskDialogCommonButtonTypes.No |
          KryptonTaskDialogCommonButtonTypes.Cancel;
```

---

## Complete Example

```csharp
using Krypton.Toolkit;

// Create dialog
using (var taskDialog = new KryptonTaskDialog(700))
{
    // Configure form
    taskDialog.Dialog.Form.Text = "Sample Dialog";
    taskDialog.Dialog.Form.StartPosition = FormStartPosition.CenterParent;
    taskDialog.Dialog.Form.RoundedCorners = true;
    
    // Configure heading
    taskDialog.Heading.Visible = true;
    taskDialog.Heading.Text = "Important Message";
    taskDialog.Heading.IconType = KryptonTaskDialogIconType.ShieldInformation;
    taskDialog.Heading.TextAlignmentHorizontal = PaletteRelativeAlign.Near;
    
    // Configure content
    taskDialog.Content.Visible = true;
    taskDialog.Content.Text = "This is the main message content.\nIt supports multiple lines.";
    taskDialog.Content.ContentImage.Image = myImage;
    taskDialog.Content.ContentImage.Size = new Size(48, 48);
    taskDialog.Content.ContentImage.Visible = true;
    taskDialog.Content.ContentImage.PositionedLeft = true;
    
    // Configure checkbox
    taskDialog.CheckBox.Visible = true;
    taskDialog.CheckBox.Text = "Don't show this again";
    
    // Configure buttons
    taskDialog.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.OK | 
        KryptonTaskDialogCommonButtonTypes.Cancel;
    taskDialog.FooterBar.CommonButtons.AcceptButton = KryptonTaskDialogCommonButtonTypes.OK;
    taskDialog.FooterBar.CommonButtons.CancelButton = KryptonTaskDialogCommonButtonTypes.Cancel;
    taskDialog.FooterBar.RoundedCorners = true;
    
    // Configure footer note
    taskDialog.FooterBar.Footer.FootNoteText = "Additional information";
    taskDialog.FooterBar.Footer.IconType = KryptonTaskDialogIconType.ShieldWarning;
    
    // Show dialog
    DialogResult result = taskDialog.ShowDialog(this);
    
    // Check result
    if (result == DialogResult.OK)
    {
        bool dontShowAgain = taskDialog.CheckBox.Checked;
        // Process result
    }
}
```