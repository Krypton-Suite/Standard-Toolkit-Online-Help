# KryptonTextBox

The `KryptonTextBox` class is a themed text input control that provides single-line and multi-line text editing capabilities with Krypton styling.

## Overview

`KryptonTextBox` is a fully themed text input control that wraps the standard Windows TextBox control and applies Krypton styling. It supports all standard TextBox functionality including single-line and multi-line editing, password masking, and text selection.

## Namespace

```csharp
Krypton.Toolkit
```

## Inheritance

```csharp
public class KryptonTextBox : VisualControlBase, IContainedInputControl
```

## Key Features

- **Themed Appearance**: Automatically adapts to the current Krypton theme
- **Multiple States**: Supports normal, disabled, active, and focus states
- **Text Editing**: Full text editing capabilities with selection and formatting
- **Password Masking**: Built-in password character masking
- **Multi-line Support**: Optional multi-line text editing
- **Cue Text**: Placeholder text support
- **Button Specifications**: Optional button specifications for additional functionality
- **Accessibility**: Full accessibility support

## Properties

### Text and Content
```csharp
[DefaultProperty("Text")]
[DefaultBindingProperty("Text")]
public string Text { get; set; }
```

Gets or sets the text content of the text box.

### Multiline
```csharp
[Category("Behavior")]
[Description("Indicates whether this is a multiline TextBox control.")]
[DefaultValue(false)]
public bool Multiline { get; set; }
```

Gets or sets a value indicating whether this is a multiline TextBox control.

**Default Value**: `false`

### PasswordChar
```csharp
[Category("Behavior")]
[Description("Gets or sets the character used to mask characters of a password in a single-line TextBox control.")]
[DefaultValue('\0')]
public char PasswordChar { get; set; }
```

Gets or sets the character used to mask characters of a password in a single-line TextBox control.

**Default Value**: `'\0'` (no masking)

### ReadOnly
```csharp
[Category("Behavior")]
[Description("Gets or sets a value indicating whether text in the TextBox is read-only.")]
[DefaultValue(false)]
public bool ReadOnly { get; set; }
```

Gets or sets a value indicating whether text in the TextBox is read-only.

**Default Value**: `false`

### TextAlign
```csharp
[Category("Appearance")]
[Description("Gets or sets how text is aligned in a TextBox control.")]
[DefaultValue(HorizontalAlignment.Left)]
public HorizontalAlignment TextAlign { get; set; }
```

Gets or sets how text is aligned in a TextBox control.

**Default Value**: `HorizontalAlignment.Left`

### AcceptsTab
```csharp
[Category("Behavior")]
[Description("Gets or sets a value indicating whether pressing the TAB key in a multiline text box control types a TAB character in the control instead of moving the focus to the next control in the tab order.")]
[DefaultValue(false)]
public bool AcceptsTab { get; set; }
```

Gets or sets a value indicating whether pressing the TAB key in a multiline text box control types a TAB character in the control instead of moving the focus to the next control in the tab order.

**Default Value**: `false`

### HideSelection
```csharp
[Category("Behavior")]
[Description("Gets or sets a value indicating whether the selected text in the text box control remains highlighted when the control loses focus.")]
[DefaultValue(true)]
public bool HideSelection { get; set; }
```

Gets or sets a value indicating whether the selected text in the text box control remains highlighted when the control loses focus.

**Default Value**: `true`

### Modified
```csharp
[Category("Behavior")]
[Description("Gets or sets a value that indicates that the TextBox control has been modified by the user since the control was created or its contents were last set.")]
[DefaultValue(false)]
public bool Modified { get; set; }
```

Gets or sets a value that indicates that the TextBox control has been modified by the user since the control was created or its contents were last set.

**Default Value**: `false`

### MaxLength
```csharp
[Category("Behavior")]
[Description("Gets or sets the maximum number of characters the user can type or paste into the text box control.")]
[DefaultValue(0)]
public int MaxLength { get; set; }
```

Gets or sets the maximum number of characters the user can type or paste into the text box control.

**Default Value**: `0` (no limit)

### CharacterCasing
```csharp
[Category("Behavior")]
[Description("Gets or sets whether the TextBox control modifies the case of characters as they are typed.")]
[DefaultValue(CharacterCasing.Normal)]
public CharacterCasing CharacterCasing { get; set; }
```

Gets or sets whether the TextBox control modifies the case of characters as they are typed.

**Default Value**: `CharacterCasing.Normal`

### ScrollBars
```csharp
[Category("Appearance")]
[Description("Gets or sets which scroll bars should appear in a multiline TextBox control.")]
[DefaultValue(ScrollBars.None)]
public ScrollBars ScrollBars { get; set; }
```

Gets or sets which scroll bars should appear in a multiline TextBox control.

**Default Value**: `ScrollBars.None`

### WordWrap
```csharp
[Category("Behavior")]
[Description("Indicates whether a multiline text box control automatically wraps words to the beginning of the next line when necessary.")]
[DefaultValue(true)]
public bool WordWrap { get; set; }
```

Indicates whether a multiline text box control automatically wraps words to the beginning of the next line when necessary.

**Default Value**: `true`

### CueHint
```csharp
[Category("Appearance")]
[Description("Gets access to the cue hint text appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteCueHintText CueHint { get; }
```

Gets access to the cue hint text appearance. This allows customization of placeholder text styling.

### ButtonSpecs
```csharp
[Category("Visuals")]
[Description("Collection of button specifications.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public TextBoxButtonSpecCollection ButtonSpecs { get; }
```

Gets access to the collection of button specifications that can be added to the text box.

## State Properties

### StateCommon
```csharp
[Category("Visuals")]
[Description("Overrides for defining common text box appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteInputControlTripleRedirect StateCommon { get; }
```

Gets access to the common state appearance that other states can override.

### StateDisabled
```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled text box appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteInputControlTripleStates StateDisabled { get; }
```

Gets access to the disabled state appearance.

### StateNormal
```csharp
[Category("Visuals")]
[Description("Overrides for defining normal text box appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteInputControlTripleStates StateNormal { get; }
```

Gets access to the normal state appearance.

### StateActive
```csharp
[Category("Visuals")]
[Description("Overrides for defining active text box appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteInputControlTripleStates StateActive { get; }
```

Gets access to the active state appearance.

## Events

### TextChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the Text property value changes.")]
public event EventHandler TextChanged;
```

Occurs when the Text property value changes.

### AcceptsTabChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the AcceptsTab property changes.")]
public event EventHandler AcceptsTabChanged;
```

Occurs when the value of the AcceptsTab property changes.

### HideSelectionChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the HideSelection property changes.")]
public event EventHandler HideSelectionChanged;
```

Occurs when the value of the HideSelection property changes.

### TextAlignChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the TextAlign property changes.")]
public event EventHandler TextAlignChanged;
```

Occurs when the value of the TextAlign property changes.

### ModifiedChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the Modified property changes.")]
public event EventHandler ModifiedChanged;
```

Occurs when the value of the Modified property changes.

### MultilineChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the Multiline property changes.")]
public event EventHandler MultilineChanged;
```

Occurs when the value of the Multiline property changes.

### ReadOnlyChanged
```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the ReadOnly property changes.")]
public event EventHandler ReadOnlyChanged;
```

Occurs when the value of the ReadOnly property changes.

### TrackMouseEnter
```csharp
[Category("Mouse")]
[Description("Raises the TrackMouseEnter event in the wrapped control.")]
[EditorBrowsable(EditorBrowsableState.Advanced)]
public event EventHandler TrackMouseEnter;
```

Occurs when the mouse enters the control.

### TrackMouseLeave
```csharp
[Category("Mouse")]
[Description("Raises the TrackMouseLeave event in the wrapped control.")]
[EditorBrowsable(EditorBrowsableState.Advanced)]
public event EventHandler TrackMouseLeave;
```

Occurs when the mouse leaves the control.

## Methods

### SelectAll()
```csharp
public void SelectAll()
```

Selects all text in the text box.

### Clear()
```csharp
public void Clear()
```

Clears all text from the text box control.

### Copy()
```csharp
public void Copy()
```

Copies the current selection in the text box to the Clipboard.

### Cut()
```csharp
public void Cut()
```

Moves the current selection in the text box to the Clipboard.

### Paste()
```csharp
public void Paste()
```

Replaces the current selection in the text box with the contents of the Clipboard.

### Undo()
```csharp
public void Undo()
```

Undoes the last edit operation in the text box.

### AppendText(string text)
```csharp
public void AppendText(string text)
```

Appends text to the current text of the text box.

## Usage Examples

### Basic Text Box Setup
```csharp
// Create a basic themed text box
KryptonTextBox textBox = new KryptonTextBox();
textBox.Size = new Size(200, 25);
textBox.Text = "Enter text here";
textBox.TextChanged += (sender, e) => Console.WriteLine("Text changed: " + textBox.Text);
```

### Password Text Box
```csharp
// Create a password text box
KryptonTextBox passwordBox = new KryptonTextBox();
passwordBox.PasswordChar = '*';
passwordBox.MaxLength = 20;
passwordBox.Text = "Enter password";
```

### Multi-line Text Box
```csharp
// Create a multi-line text box
KryptonTextBox multiLineBox = new KryptonTextBox();
multiLineBox.Multiline = true;
multiLineBox.ScrollBars = ScrollBars.Vertical;
multiLineBox.Size = new Size(300, 100);
multiLineBox.AcceptsTab = true;
multiLineBox.WordWrap = true;
```

### Custom Styling
```csharp
// Create a text box with custom styling
KryptonTextBox customBox = new KryptonTextBox();
customBox.Text = "Custom styled text box";

// Customize the normal state
customBox.StateNormal.Back.Color1 = Color.White;
customBox.StateNormal.Border.Color1 = Color.Gray;
customBox.StateNormal.Content.ShortText.Color1 = Color.Black;

// Customize the active state
customBox.StateActive.Back.Color1 = Color.LightBlue;
customBox.StateActive.Border.Color1 = Color.Blue;
```

### Cue Text (Placeholder)
```csharp
// Create a text box with cue text
KryptonTextBox cueBox = new KryptonTextBox();
cueBox.CueHint.CueHintText = "Enter your name here...";
cueBox.CueHint.CueHintColor = Color.Gray;
```

### Button Specifications
```csharp
// Create a text box with button specifications
KryptonTextBox buttonBox = new KryptonTextBox();
ButtonSpecAny clearButton = new ButtonSpecAny();
clearButton.Type = PaletteButtonSpecStyle.Close;
clearButton.Click += (sender, e) => buttonBox.Clear();
buttonBox.ButtonSpecs.Add(clearButton);
```

### Theme Integration
```csharp
// The text box automatically uses the global theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// All KryptonTextBox instances will automatically update their appearance
```

## Design-Time Support

The `KryptonTextBox` control includes comprehensive design-time support:

- **Toolbox Integration**: Available in the Visual Studio toolbox
- **Property Grid**: Full property grid support with categorized properties
- **Smart Tags**: Quick access to common properties and actions
- **Designer Serialization**: Proper serialization of all properties
- **Default Property**: Text property is marked as the default property

## Accessibility

The control provides full accessibility support:

- **Screen Reader Support**: Properly announces text content and state
- **Keyboard Navigation**: Supports Tab key navigation and text editing
- **Focus Indicators**: Visual focus indicators for keyboard users
- **Text Selection**: Full text selection and editing capabilities

## Performance Considerations

- The control is optimized for performance with minimal overhead
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Text rendering is optimized for performance

## Related Components

- `KryptonRichTextBox` - Rich text editing control
- `KryptonMaskedTextBox` - Text input with format masking
- `KryptonComboBox` - Dropdown selection control
- `KryptonManager` - Global theme management
- `PaletteInputControlTripleStates` - Input control state management
- `ButtonSpecAny` - Button specification for additional functionality
