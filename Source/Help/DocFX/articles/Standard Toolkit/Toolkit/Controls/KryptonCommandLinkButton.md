# KryptonCommandLinkButton

## Overview

`KryptonCommandLinkButton` is a specialized button control that displays in the Windows command link style, featuring a primary heading, descriptive text, and an optional UAC shield icon. It's designed for presenting users with clear, descriptive action choices in dialogs and wizards.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `VisualSimpleBase` → `KryptonCommandLinkButton`  
**Implements:** `IButtonControl`

## Key Features

### Command Link Style
- Large heading text (primary action)
- Secondary descriptive text
- Optional UAC shield icon
- Arrow indicator (implied by style)

### Full Button Functionality
- Click event support
- DialogResult integration
- Default button capability
- Mnemonic support

### Krypton Integration
- Full palette support
- State-based styling (Normal, Disabled, Tracking, Pressed)
- Focus and default state overrides
- Command binding support

### Visual States
- Normal, Tracking (hover), Pressed, Disabled
- Default button highlighting
- Focus rectangle display

---

## Constructor

### KryptonCommandLinkButton()

Initializes a new instance with command link styling.

```csharp
public KryptonCommandLinkButton()
```

**Default Settings:**
- `ButtonStyle` = `ButtonStyle.Command`
- `AutoSize` = `false`
- `DialogResult` = `DialogResult.None`
- `UseMnemonic` = `true`
- `Orientation` = `VisualOrientation.Top`
- `DefaultSize` = `319 x 61`

---

## Properties

### Content Properties

#### CommandLinkTextValues
Gets access to the button's heading and description text.

```csharp
[Category("CommandLink")]
[Description("CommandLink Button Text")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public CommandLinkTextValues CommandLinkTextValues { get; }
```

**Available Properties:**
- `Heading` - Primary large text
- `Description` - Secondary descriptive text
- `HeadingFont` - Font for heading
- `DescriptionFont` - Font for description
- `HeadingTextHAlignment` - Horizontal alignment for heading
- `HeadingTextVAlignment` - Vertical alignment for heading
- `DescriptionTextHAlignment` - Horizontal alignment for description
- `DescriptionTextVAlignment` - Vertical alignment for description

**Example:**
```csharp
kryptonCommandLinkButton1.CommandLinkTextValues.Heading = "Create a new document";
kryptonCommandLinkButton1.CommandLinkTextValues.Description = "Start with a blank document or choose from a template";
```

---

#### UACShieldIcon
Gets access to the UAC shield icon settings.

```csharp
[Category("CommandLink")]
[Description("CommandLink Button Image")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public CommandLinkImageValues UACShieldIcon { get; }
```

**Remarks:**
- Displays the Windows UAC shield icon
- Useful for operations requiring elevation
- Automatically scales with DPI

**Example:**
```csharp
// Show UAC shield icon
kryptonCommandLinkButton1.UACShieldIcon.Image = SystemIcons.Shield.ToBitmap();
```

---

#### Text
Gets or sets the heading text (maps to `CommandLinkTextValues.Heading`).

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public new string Text { get; set; }
```

**Remarks:**
- Hidden in designer (use `CommandLinkTextValues.Heading` instead)
- Provided for compatibility

---

### Appearance Properties

#### ButtonStyle
Gets or sets the button style.

```csharp
[Category("Visuals")]
[Description("Button style.")]
public ButtonStyle ButtonStyle { get; set; }
```

**Default:** `ButtonStyle.Command`

**Remarks:**
- Locked to Command style for proper appearance
- Rarely needs to be changed

---

#### Orientation
Gets or sets the visual orientation of the control.

```csharp
[Category("Visuals")]
[Description("Visual orientation of the control.")]
[DefaultValue(typeof(VisualOrientation), "Top")]
public virtual VisualOrientation Orientation { get; set; }
```

**Available Values:**
- `Top` - Normal horizontal layout (default)
- `Bottom` - Flipped horizontal
- `Left` - Vertical left-to-right
- `Right` - Vertical right-to-left

---

#### AutoSize
Gets or sets whether the control automatically resizes to fit content.

```csharp
[Browsable(true)]
[DefaultValue(false)]
public override bool AutoSize { get; set; }
```

**Default:** `false`

**Remarks:**
- Command links typically have fixed dimensions
- Set to `true` for dynamic sizing

---

### State Properties

#### StateCommon
Gets access to common appearance settings that other states can override.

```csharp
[Category("Visuals")]
[Description("Overrides for defining common button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect StateCommon { get; }
```

**Example:**
```csharp
kryptonCommandLinkButton1.StateCommon.Back.Color1 = Color.AliceBlue;
kryptonCommandLinkButton1.StateCommon.Border.Rounding = 5;
```

---

#### StateNormal
Gets access to normal state appearance.

```csharp
[Category("Visuals")]
[Description("Overrides for defining normal button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateNormal { get; }
```

---

#### StateTracking
Gets access to hot tracking (hover) appearance.

```csharp
[Category("Visuals")]
[Description("Overrides for defining hot tracking button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateTracking { get; }
```

---

#### StatePressed
Gets access to pressed appearance.

```csharp
[Category("Visuals")]
[Description("Overrides for defining pressed button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StatePressed { get; }
```

---

#### StateDisabled
Gets access to disabled appearance.

```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled button appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTriple StateDisabled { get; }
```

---

#### OverrideDefault
Gets access to appearance when the button is the default button.

```csharp
[Category("Visuals")]
[Description("Overrides for defining normal button appearance when default.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect OverrideDefault { get; }
```

**Remarks:**
- Applied when button is the form's `AcceptButton`
- Typically shows highlighted border

---

#### OverrideFocus
Gets access to appearance when the button has focus.

```csharp
[Category("Visuals")]
[Description("Overrides for defining button appearance when it has focus.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTripleRedirect OverrideFocus { get; }
```

---

### Behavior Properties

#### DialogResult
Gets or sets the dialog result value returned when clicked.

```csharp
[Category("Behavior")]
[Description("The dialog-box result produced in a modal form by clicking the button.")]
[DefaultValue(typeof(DialogResult), "None")]
public DialogResult DialogResult { get; set; }
```

**Example:**
```csharp
kryptonCommandLinkButton1.DialogResult = DialogResult.OK;
```

---

#### KryptonCommand
Gets or sets the associated command.

```csharp
[Category("Behavior")]
[Description("Command associated with the button.")]
[DefaultValue(null)]
public virtual IKryptonCommand? KryptonCommand { get; set; }
```

**Remarks:**
- Automatically synchronizes `Enabled` state with command
- Executes command on click

**Example:**
```csharp
var command = new KryptonCommand
{
    Text = "Save Document",
    Enabled = documentModified
};
command.Execute += (s, e) => SaveDocument();

kryptonCommandLinkButton1.KryptonCommand = command;
```

---

#### UseMnemonic
Gets or sets whether ampersand characters create mnemonics.

```csharp
[Category("Appearance")]
[Description("When true the first character after an ampersand will be used as a mnemonic.")]
[DefaultValue(true)]
public bool UseMnemonic { get; set; }
```

**Example:**
```csharp
kryptonCommandLinkButton1.CommandLinkTextValues.Heading = "&Open File";
kryptonCommandLinkButton1.UseMnemonic = true;
// Alt+O will activate the button
```

---

## Methods

### PerformClick()
Generates a Click event for the control.

```csharp
public void PerformClick()
```

**Example:**
```csharp
kryptonCommandLinkButton1.PerformClick(); // Programmatically click
```

---

### NotifyDefault(bool)
Notifies the button it is the default button.

```csharp
public void NotifyDefault(bool value)
```

**Parameters:**
- `value` - True if this is the default button

**Remarks:**
- Called automatically by the form
- Applies `OverrideDefault` styling

---

### SetFixedState(PaletteState)
Fixes the control to a particular palette state.

```csharp
public virtual void SetFixedState(PaletteState state)
```

**Parameters:**
- `state` - Palette state to fix

**Remarks:**
- Useful for preview/design scenarios
- Prevents state changes

**Example:**
```csharp
kryptonCommandLinkButton1.SetFixedState(PaletteState.Pressed); // Always show pressed
```

---

### ResetText()
Resets the text property to its default value.

```csharp
public override void ResetText()
```

---

## Events

### Click
Occurs when the button is clicked.

```csharp
[DefaultEvent("Click")]
public event EventHandler Click
```

**Example:**
```csharp
kryptonCommandLinkButton1.Click += (s, e) =>
{
    OpenDocument();
};
```

---

### KryptonCommandChanged
Occurs when the KryptonCommand property changes.

```csharp
[Category("Property Changed")]
[Description("Occurs when the value of the KryptonCommand property changes.")]
public event EventHandler KryptonCommandChanged
```

---

## Usage Examples

### Basic Command Link

```csharp
var commandLink = new KryptonCommandLinkButton
{
    Location = new Point(20, 20),
    Size = new Size(350, 70)
};

commandLink.CommandLinkTextValues.Heading = "Create a new document";
commandLink.CommandLinkTextValues.Description = "Start with a blank document";

commandLink.Click += (s, e) =>
{
    CreateNewDocument();
};

this.Controls.Add(commandLink);
```

---

### Dialog with Command Links

```csharp
public class DocumentDialog : KryptonForm
{
    public DocumentDialog()
    {
        Text = "What do you want to do?";
        Size = new Size(450, 300);
        
        var newButton = new KryptonCommandLinkButton
        {
            Location = new Point(20, 20),
            Size = new Size(400, 70)
        };
        newButton.CommandLinkTextValues.Heading = "Create a new document";
        newButton.CommandLinkTextValues.Description = "Start with a blank document or choose from templates";
        newButton.DialogResult = DialogResult.Yes;
        newButton.Tag = "New";
        
        var openButton = new KryptonCommandLinkButton
        {
            Location = new Point(20, 100),
            Size = new Size(400, 70)
        };
        openButton.CommandLinkTextValues.Heading = "Open an existing document";
        openButton.CommandLinkTextValues.Description = "Browse for a document on your computer";
        openButton.DialogResult = DialogResult.No;
        openButton.Tag = "Open";
        
        var cancelButton = new KryptonButton
        {
            Text = "Cancel",
            Location = new Point(345, 220),
            DialogResult = DialogResult.Cancel
        };
        
        Controls.AddRange(new Control[] { newButton, openButton, cancelButton });
        CancelButton = cancelButton;
    }
}

// Usage:
using (var dialog = new DocumentDialog())
{
    if (dialog.ShowDialog() == DialogResult.Yes)
    {
        CreateNewDocument();
    }
    else if (dialog.ShowDialog() == DialogResult.No)
    {
        OpenExistingDocument();
    }
}
```

---

### Wizard Navigation

```csharp
public class WizardPage : KryptonPanel
{
    public WizardPage()
    {
        var option1 = new KryptonCommandLinkButton
        {
            Location = new Point(20, 20),
            Size = new Size(400, 70)
        };
        option1.CommandLinkTextValues.Heading = "Express Installation";
        option1.CommandLinkTextValues.Description = "Recommended for most users. Installs with default settings.";
        option1.Click += (s, e) => SelectExpressInstall();
        
        var option2 = new KryptonCommandLinkButton
        {
            Location = new Point(20, 100),
            Size = new Size(400, 70)
        };
        option2.CommandLinkTextValues.Heading = "Custom Installation";
        option2.CommandLinkTextValues.Description = "Choose which features to install and where to install them.";
        option2.Click += (s, e) => SelectCustomInstall();
        
        Controls.AddRange(new Control[] { option1, option2 });
    }
}
```

---

### UAC Elevation Required

```csharp
var elevatedButton = new KryptonCommandLinkButton
{
    Location = new Point(20, 20),
    Size = new Size(400, 70)
};

elevatedButton.CommandLinkTextValues.Heading = "Install System-Wide";
elevatedButton.CommandLinkTextValues.Description = "Install for all users (requires administrator privileges)";

// Show UAC shield icon
elevatedButton.UACShieldIcon.Image = SystemIcons.Shield.ToBitmap();

elevatedButton.Click += (s, e) =>
{
    if (IsElevated())
    {
        InstallSystemWide();
    }
    else
    {
        RestartElevated();
    }
};
```

---

### With Mnemonics

```csharp
var button1 = new KryptonCommandLinkButton
{
    Location = new Point(20, 20),
    Size = new Size(400, 70)
};
button1.CommandLinkTextValues.Heading = "&New Project";
button1.CommandLinkTextValues.Description = "Create a new project from scratch";

var button2 = new KryptonCommandLinkButton
{
    Location = new Point(20, 100),
    Size = new Size(400, 70)
};
button2.CommandLinkTextValues.Heading = "&Open Project";
button2.CommandLinkTextValues.Description = "Open an existing project from disk";

// Alt+N activates button1, Alt+O activates button2
```

---

### Conditional Enabling

```csharp
private void UpdateCommandLinks()
{
    // Enable/disable based on state
    newDocButton.Enabled = !documentIsOpen;
    
    saveDocButton.Enabled = documentIsOpen && documentIsModified;
    saveDocButton.CommandLinkTextValues.Description = documentIsModified
        ? "Save your changes to the current document"
        : "No changes to save";
    
    closeDocButton.Enabled = documentIsOpen;
}
```

---

### Custom Styling

```csharp
var styledButton = new KryptonCommandLinkButton();

// Customize appearance
styledButton.StateNormal.Back.Color1 = Color.LightBlue;
styledButton.StateNormal.Back.Color2 = Color.AliceBlue;
styledButton.StateNormal.Back.ColorStyle = PaletteColorStyle.Linear;

styledButton.StateTracking.Back.Color1 = Color.SkyBlue;
styledButton.StateTracking.Border.Color1 = Color.DodgerBlue;
styledButton.StateTracking.Border.Width = 2;

styledButton.StatePressed.Back.Color1 = Color.DeepSkyBlue;

// Custom fonts
styledButton.CommandLinkTextValues.HeadingFont = new Font("Segoe UI", 14F, FontStyle.Bold);
styledButton.CommandLinkTextValues.DescriptionFont = new Font("Segoe UI", 9F);
```

---

### Task Selection Dialog

```csharp
public class TaskSelectionDialog : KryptonForm
{
    public string SelectedTask { get; private set; }
    
    public TaskSelectionDialog()
    {
        Text = "Choose a task";
        Size = new Size(500, 350);
        
        var label = new KryptonLabel
        {
            Text = "What would you like to do?",
            Location = new Point(20, 20),
            AutoSize = true,
            LabelStyle = LabelStyle.BoldPanel
        };
        
        var tasks = new[]
        {
            ("Backup", "Create a backup of your important files"),
            ("Restore", "Restore files from a previous backup"),
            ("Schedule", "Set up automatic backup schedules"),
            ("Settings", "Configure backup preferences")
        };
        
        int y = 50;
        foreach (var (heading, description) in tasks)
        {
            var button = new KryptonCommandLinkButton
            {
                Location = new Point(20, y),
                Size = new Size(450, 60)
            };
            
            button.CommandLinkTextValues.Heading = heading;
            button.CommandLinkTextValues.Description = description;
            button.Click += (s, e) =>
            {
                SelectedTask = heading;
                DialogResult = DialogResult.OK;
            };
            
            Controls.Add(button);
            y += 70;
        }
        
        Controls.Add(label);
    }
}

// Usage:
using (var dialog = new TaskSelectionDialog())
{
    if (dialog.ShowDialog() == DialogResult.OK)
    {
        ExecuteTask(dialog.SelectedTask);
    }
}
```

---

### Command Binding

```csharp
public class DocumentWindow : KryptonForm
{
    private KryptonCommand saveCommand;
    private KryptonCommandLinkButton saveButton;
    
    public DocumentWindow()
    {
        // Create command
        saveCommand = new KryptonCommand
        {
            Text = "Save",
            Enabled = false
        };
        saveCommand.Execute += (s, e) => SaveDocument();
        
        // Bind to button
        saveButton = new KryptonCommandLinkButton
        {
            KryptonCommand = saveCommand
        };
        saveButton.CommandLinkTextValues.Heading = "Save Document";
        saveButton.CommandLinkTextValues.Description = "Save changes to the current document";
        
        // Command enabled state automatically controls button
    }
    
    private void OnDocumentModified()
    {
        saveCommand.Enabled = true; // Button automatically enables
    }
}
```

---

### Dynamic Button List

```csharp
public class ActionPanel : KryptonPanel
{
    public ActionPanel(List<(string heading, string description, Action action)> actions)
    {
        int y = 10;
        
        foreach (var (heading, description, action) in actions)
        {
            var button = new KryptonCommandLinkButton
            {
                Location = new Point(10, y),
                Size = new Size(380, 65)
            };
            
            button.CommandLinkTextValues.Heading = heading;
            button.CommandLinkTextValues.Description = description;
            button.Click += (s, e) => action();
            
            Controls.Add(button);
            y += 75;
        }
        
        Height = y + 10;
    }
}

// Usage:
var actions = new List<(string, string, Action)>
{
    ("Import Data", "Import data from a CSV or Excel file", ImportData),
    ("Export Data", "Export current data to a file", ExportData),
    ("Clear Data", "Remove all current data", ClearData)
};

var panel = new ActionPanel(actions);
```

---

## Design Considerations

### Command Link Guidelines

Per Windows UX guidelines, use command links when:

1. **Presenting clear choices** - Each option is distinct and clear
2. **Need explanatory text** - Description helps users understand
3. **2-7 options** - Too many becomes overwhelming
4. **Task-based actions** - "Create new" vs "Open existing"

**Don't use command links for:**
- Simple Yes/No/Cancel dialogs (use standard buttons)
- More than 7 options (use list or other control)
- When space is limited

---

### Text Guidelines

**Heading:**
- 1-5 words
- Action verb or noun phrase
- Use sentence case
- Include mnemonic if needed

**Description:**
- 1-2 sentences
- Explain what happens or when to choose this
- Complete sentences with punctuation
- Avoid restating the heading

**Examples:**

✅ **Good:**
```
Heading: "Create a new database"
Description: "Start with an empty database and add your own data."
```

❌ **Bad:**
```
Heading: "Create Database"  // Too terse
Description: "Creates a new database."  // Just restates heading
```

---

### Layout Guidelines

**Spacing:**
- 10-20px between buttons
- 20-40px margins from container edges
- Group related options closer

**Sizing:**
- Minimum height: 50px
- Recommended height: 60-70px
- Width: Accommodate longest description + margins
- All buttons in a group should be same width

---

### State Hierarchy

Visual states are applied in this order:

1. **StateDisabled** - When `Enabled = false`
2. **StatePressed** - When mouse button down
3. **StateTracking** - When mouse hovering
4. **OverrideDefault** - When button is form's AcceptButton
5. **OverrideFocus** - When button has focus
6. **StateNormal** - Default state

---

## Common Scenarios

### Setup Wizard Choice

```csharp
public class SetupTypeDialog : KryptonForm
{
    public SetupTypeDialog()
    {
        Text = "Choose Setup Type";
        
        var typical = new KryptonCommandLinkButton();
        typical.CommandLinkTextValues.Heading = "&Typical";
        typical.CommandLinkTextValues.Description = 
            "Recommended for most users. Installs the most common features.";
        typical.DialogResult = DialogResult.Yes;
        
        var complete = new KryptonCommandLinkButton();
        complete.CommandLinkTextValues.Heading = "&Complete";
        complete.CommandLinkTextValues.Description = 
            "Installs all program features. Requires the most disk space.";
        complete.DialogResult = DialogResult.No;
        
        var custom = new KryptonCommandLinkButton();
        custom.CommandLinkTextValues.Heading = "C&ustom";
        custom.CommandLinkTextValues.Description = 
            "Choose which features to install. For advanced users.";
        custom.DialogResult = DialogResult.Retry;
    }
}
```

---

### Feature Selection

```csharp
public class FeatureDialog : KryptonForm
{
    public List<string> SelectedFeatures { get; } = new List<string>();
    
    public FeatureDialog()
    {
        var cloudSync = CreateFeatureButton(
            "Enable Cloud Sync",
            "Automatically sync your files across devices",
            "CloudSync");
        
        var autoBackup = CreateFeatureButton(
            "Enable Auto-Backup",
            "Automatically backup your work every hour",
            "AutoBackup");
        
        var offlineMode = CreateFeatureButton(
            "Enable Offline Mode",
            "Continue working without an internet connection",
            "OfflineMode");
    }
    
    private KryptonCommandLinkButton CreateFeatureButton(
        string heading, string description, string feature)
    {
        var button = new KryptonCommandLinkButton();
        button.CommandLinkTextValues.Heading = heading;
        button.CommandLinkTextValues.Description = description;
        button.Click += (s, e) =>
        {
            SelectedFeatures.Add(feature);
            EnableFeature(feature);
        };
        return button;
    }
}
```

---

### Troubleshooting Options

```csharp
public class TroubleshootDialog : KryptonForm
{
    public TroubleshootDialog()
    {
        Text = "Troubleshooting Options";
        
        CreateOption(
            "Run Diagnostic",
            "Automatically detect and fix common problems",
            () => RunDiagnostic());
        
        CreateOption(
            "Reset Settings",
            "Restore all settings to their default values",
            () => ConfirmReset());
        
        CreateOption(
            "Repair Installation",
            "Re-install missing or corrupted files",
            () => RepairInstall());
        
        CreateOption(
            "Contact Support",
            "Get help from our technical support team",
            () => ContactSupport());
    }
}
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** Krypton.Toolkit core components
- **COM Visible:** Yes (`ComVisible(true)`)

---

## Known Limitations

1. **Fixed Layout:** Optimized for horizontal command link layout
2. **Text Serialization:** Text property serialization suppressed (use CommandLinkTextValues)
3. **Icon Limitation:** UAC shield icon primary use case
4. **Size:** Works best at recommended dimensions (300-400px wide, 60-70px tall)

---

## Comparison with Alternatives

### vs KryptonButton

**KryptonCommandLinkButton:**
- ✅ Two-line text (heading + description)
- ✅ Large, clear choice presentation
- ✅ Built-in UAC shield support
- ❌ Takes more vertical space
- ❌ Limited to specific use cases

**KryptonButton:**
- ✅ Compact size
- ✅ Flexible usage
- ✅ Standard button appearance
- ❌ Single line text
- ❌ Less descriptive

---

### When to Use

**Use KryptonCommandLinkButton for:**
- Wizard navigation
- Setup/installation choices
- Task selection dialogs
- Feature opt-in screens
- Administrative actions

**Use standard KryptonButton for:**
- OK/Cancel/Apply buttons
- Toolbars and ribbons
- Small action buttons
- Densely packed UIs

---

## See Also

- [KryptonButton](KryptonButton.md) - Standard button control
- [ButtonStyle Enumeration](../Enumerations/ButtonStyle.md) - Available button styles
- [CommandLinkTextValues](../Values/CommandLinkTextValues.md) - Text values class
- [IKryptonCommand](../Interfaces/IKryptonCommand.md) - Command interface

---

*Last Updated: October 2025*  
*Krypton Toolkit Version: 100+*

