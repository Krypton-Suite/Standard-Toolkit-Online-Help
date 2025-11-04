# IKryptonCommand Interface

## Overview

`IKryptonCommand` defines a contract for implementing command objects that can be shared across multiple Krypton controls. It provides a centralized way to manage button state, text, images, and execution logic that can be reused throughout an application.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit

```csharp
public interface IKryptonCommand
```

## Key Concepts

### Command Pattern
The interface implements the Command pattern, separating:
- **What** the command does (Execute event)
- **How** it appears (Text, Image properties)
- **When** it's available (Enabled property)

### Benefits
- **Centralized Logic**: One command, many controls
- **Consistent State**: All controls update together
- **Easy Maintenance**: Change once, affects all
- **Undo/Redo Support**: Can track command execution

---

## Events

### Execute
Occurs when the command needs executing.

```csharp
event EventHandler? Execute
```

**Remarks:**
- Raised by `PerformExecute()` method
- Implement actual command logic in this event handler
- Called when any bound control is activated

**Example:**
```csharp
var saveCommand = new KryptonCommand();
saveCommand.Execute += (s, e) =>
{
    SaveDocument();
    UpdateUI();
};
```

---

### PropertyChanged
Occurs when a property has changed value.

```csharp
event PropertyChangedEventHandler? PropertyChanged
```

**Remarks:**
- Part of `INotifyPropertyChanged` pattern
- Automatically raised when properties change
- Allows controls to update when command changes

**Example:**
```csharp
var command = new KryptonCommand();
command.PropertyChanged += (s, e) =>
{
    if (e.PropertyName == "Enabled")
    {
        Console.WriteLine($"Command enabled state changed: {command.Enabled}");
    }
};
```

---

## Properties

### State Properties

#### Enabled
Gets or sets the enabled state of the command.

```csharp
bool Enabled { get; set; }
```

**Remarks:**
- When `false`, all bound controls are disabled
- When `true`, all bound controls are enabled
- Synchronizes across all controls using this command

**Example:**
```csharp
saveCommand.Enabled = document.IsModified;
// All buttons bound to saveCommand update automatically
```

---

#### Checked
Gets or sets the checked state of the command.

```csharp
bool Checked { get; set; }
```

**Remarks:**
- Used for toggle-style buttons
- Affects visual appearance of bound controls
- Useful for state-based commands (e.g., Bold, Italic)

**Example:**
```csharp
boldCommand.Checked = editor.SelectionIsBold;
```

---

#### CheckState
Gets or sets the check state of the command.

```csharp
CheckState CheckState { get; set; }
```

**Values:**
- `CheckState.Unchecked` - Not checked
- `CheckState.Checked` - Fully checked
- `CheckState.Indeterminate` - Indeterminate state

**Remarks:**
- Provides three-state support
- Useful for commands affecting multiple items

**Example:**
```csharp
if (selectedItems.All(i => i.IsEnabled))
    enableCommand.CheckState = CheckState.Checked;
else if (selectedItems.Any(i => i.IsEnabled))
    enableCommand.CheckState = CheckState.Indeterminate;
else
    enableCommand.CheckState = CheckState.Unchecked;
```

---

### Text Properties

#### Text
Gets or sets the command text.

```csharp
string Text { get; set; }
```

**Remarks:**
- Primary text displayed on controls
- Supports mnemonics (e.g., "&Save")
- Updates all bound controls automatically

**Example:**
```csharp
saveCommand.Text = "&Save";
// All buttons show "Save" with underlined 'S'
```

---

#### ExtraText
Gets or sets the command extra text.

```csharp
string ExtraText { get; set; }
```

**Remarks:**
- Secondary text (e.g., tooltip, description)
- Usage varies by control type
- May appear as tooltip or sub-text

**Example:**
```csharp
saveCommand.ExtraText = "Save the current document";
```

---

#### TextLine1
Gets or sets the command text line 1 for use in KryptonRibbon.

```csharp
string TextLine1 { get; set; }
```

**Remarks:**
- Specific to ribbon controls
- First line of button text in ribbon
- Ignored by non-ribbon controls

**Example:**
```csharp
saveCommand.TextLine1 = "Save";
```

---

#### TextLine2
Gets or sets the command text line 2 for use in KryptonRibbon.

```csharp
string TextLine2 { get; set; }
```

**Remarks:**
- Specific to ribbon controls
- Second line of button text in ribbon
- Ignored by non-ribbon controls

**Example:**
```csharp
saveCommand.TextLine2 = "Document";
// Ribbon button shows:
// Save
// Document
```

---

### Image Properties

#### ImageSmall
Gets or sets the command small image.

```csharp
Image? ImageSmall { get; set; }
```

**Remarks:**
- Typically 16x16 pixels
- Used in menus, toolbars, small buttons
- Should be DPI-aware for high-DPI displays

**Example:**
```csharp
saveCommand.ImageSmall = Properties.Resources.Save16;
```

---

#### ImageLarge
Gets or sets the command large image.

```csharp
Image? ImageLarge { get; set; }
```

**Remarks:**
- Typically 32x32 or 48x48 pixels
- Used in ribbons, large buttons
- Should be DPI-aware for high-DPI displays

**Example:**
```csharp
saveCommand.ImageLarge = Properties.Resources.Save32;
```

---

#### ImageTransparentColor
Gets or sets the command image transparent color.

```csharp
Color ImageTransparentColor { get; set; }
```

**Remarks:**
- Color to treat as transparent in images
- Typically magenta (Color.Magenta) for legacy images
- Modern PNG images with alpha channel don't need this

**Example:**
```csharp
saveCommand.ImageTransparentColor = Color.Magenta;
```

---

### Command Type

#### CommandType
Gets or sets the type of the command.

```csharp
KryptonCommandType CommandType { get; set; }
```

**Values:**
- `KryptonCommandType.General` - Standard command
- Additional types defined by `KryptonCommandType` enum

**Remarks:**
- Allows categorization of commands
- May affect behavior in some contexts

---

## Methods

### PerformExecute()
Generates an Execute event for the command.

```csharp
void PerformExecute()
```

**Remarks:**
- Programmatically executes the command
- Raises the `Execute` event
- Useful for keyboard shortcuts, external triggers

**Example:**
```csharp
// Execute from code
saveCommand.PerformExecute();

// Or from keyboard shortcut
if (e.KeyCode == Keys.S && e.Control)
{
    saveCommand.PerformExecute();
}
```

---

## Implementation

### KryptonCommand Class
The primary implementation of `IKryptonCommand`:

```csharp
public class KryptonCommand : Component, IKryptonCommand, INotifyPropertyChanged
{
    // Implements all interface members
    // Provides designer support
    // Handles property change notifications
}
```

**Usage:**
```csharp
var command = new KryptonCommand
{
    Text = "Save",
    ImageSmall = saveIcon,
    Enabled = false
};

command.Execute += (s, e) => SaveDocument();
```

---

## Usage Examples

### Basic Command

```csharp
// Create command
var saveCommand = new KryptonCommand
{
    Text = "&Save",
    ImageSmall = Properties.Resources.SaveIcon,
    Enabled = false // Initially disabled
};

// Define behavior
saveCommand.Execute += (s, e) =>
{
    SaveDocument();
    MessageBox.Show("Document saved!");
};

// Bind to controls
kryptonButton1.KryptonCommand = saveCommand;
toolStripMenuItem1.KryptonCommand = saveCommand;
ribbonButton1.KryptonCommand = saveCommand;

// Update state
saveCommand.Enabled = document.IsModified;
// All three controls update automatically!
```

---

### Toggle Command

```csharp
var boldCommand = new KryptonCommand
{
    Text = "Bold",
    ImageSmall = Properties.Resources.BoldIcon,
    Checked = false
};

boldCommand.Execute += (s, e) =>
{
    // Toggle the state
    boldCommand.Checked = !boldCommand.Checked;
    
    // Apply formatting
    editor.SelectionFont = new Font(
        editor.SelectionFont,
        boldCommand.Checked ? FontStyle.Bold : FontStyle.Regular);
};

// Bind to buttons
toolbarBoldButton.KryptonCommand = boldCommand;
menuBoldItem.KryptonCommand = boldCommand;

// Update when selection changes
editor.SelectionChanged += (s, e) =>
{
    boldCommand.Checked = editor.SelectionFont.Bold;
};
```

---

### Ribbon Command

```csharp
var pasteCommand = new KryptonCommand
{
    TextLine1 = "Paste",
    TextLine2 = "Clipboard",
    ImageSmall = Properties.Resources.Paste16,
    ImageLarge = Properties.Resources.Paste32,
    ExtraText = "Insert content from clipboard"
};

pasteCommand.Execute += (s, e) =>
{
    if (Clipboard.ContainsText())
    {
        editor.SelectedText = Clipboard.GetText();
    }
};

// Update enabled state based on clipboard
var clipboardTimer = new Timer { Interval = 100 };
clipboardTimer.Tick += (s, e) =>
{
    pasteCommand.Enabled = Clipboard.ContainsText();
};
clipboardTimer.Start();

// Bind to ribbon
ribbonPasteButton.KryptonCommand = pasteCommand;
```

---

### Command with Undo Support

```csharp
public class UndoableCommand : KryptonCommand
{
    private Stack<Action> undoStack = new Stack<Action>();
    
    public UndoableCommand(string text, Action<Action> executeWithUndo)
    {
        Text = text;
        Execute += (s, e) =>
        {
            Action undo = null;
            executeWithUndo(u => undo = u);
            
            if (undo != null)
            {
                undoStack.Push(undo);
            }
        };
    }
    
    public void Undo()
    {
        if (undoStack.Count > 0)
        {
            var undoAction = undoStack.Pop();
            undoAction();
        }
    }
}

// Usage:
var deleteCommand = new UndoableCommand("Delete", provideUndo =>
{
    var backup = GetSelectedItems();
    DeleteSelectedItems();
    
    // Provide undo action
    provideUndo(() => RestoreItems(backup));
});
```

---

### Dynamic Command State

```csharp
public class DocumentCommands
{
    private Document document;
    
    public KryptonCommand SaveCommand { get; }
    public KryptonCommand SaveAsCommand { get; }
    public KryptonCommand CloseCommand { get; }
    
    public DocumentCommands(Document doc)
    {
        document = doc;
        
        SaveCommand = new KryptonCommand
        {
            Text = "&Save",
            ImageSmall = Resources.SaveIcon
        };
        SaveCommand.Execute += (s, e) => document.Save();
        
        SaveAsCommand = new KryptonCommand
        {
            Text = "Save &As...",
            ImageSmall = Resources.SaveAsIcon
        };
        SaveAsCommand.Execute += (s, e) => document.SaveAs();
        
        CloseCommand = new KryptonCommand
        {
            Text = "&Close",
            ImageSmall = Resources.CloseIcon
        };
        CloseCommand.Execute += (s, e) => document.Close();
        
        // Update state
        document.ModifiedChanged += UpdateCommandStates;
        UpdateCommandStates();
    }
    
    private void UpdateCommandStates(object sender = null, EventArgs e = null)
    {
        SaveCommand.Enabled = document.IsModified;
        SaveAsCommand.Enabled = document.IsOpen;
        CloseCommand.Enabled = document.IsOpen;
    }
}
```

---

### Command Manager

```csharp
public class CommandManager
{
    private Dictionary<string, KryptonCommand> commands = new();
    
    public KryptonCommand Register(string id, string text, EventHandler execute)
    {
        var command = new KryptonCommand { Text = text };
        command.Execute += execute;
        commands[id] = command;
        return command;
    }
    
    public KryptonCommand Get(string id) => commands[id];
    
    public void EnableAll() => commands.Values.ToList().ForEach(c => c.Enabled = true);
    
    public void DisableAll() => commands.Values.ToList().ForEach(c => c.Enabled = false);
    
    public void EnableGroup(params string[] ids)
    {
        foreach (var id in ids)
        {
            if (commands.ContainsKey(id))
            {
                commands[id].Enabled = true;
            }
        }
    }
}

// Usage:
var manager = new CommandManager();

manager.Register("save", "Save", (s, e) => Save());
manager.Register("open", "Open", (s, e) => Open());
manager.Register("close", "Close", (s, e) => Close());

// Bind to controls
saveButton.KryptonCommand = manager.Get("save");
openButton.KryptonCommand = manager.Get("open");

// Bulk operations
manager.DisableAll(); // Disable everything
manager.EnableGroup("open"); // Only enable open
```

---

### Keyboard Shortcuts with Commands

```csharp
public class MainForm : KryptonForm
{
    private Dictionary<Keys, KryptonCommand> keyboardCommands = new();
    
    public MainForm()
    {
        // Create commands
        var saveCommand = new KryptonCommand { Text = "Save" };
        saveCommand.Execute += (s, e) => Save();
        
        var openCommand = new KryptonCommand { Text = "Open" };
        openCommand.Execute += (s, e) => Open();
        
        // Map shortcuts
        keyboardCommands[Keys.Control | Keys.S] = saveCommand;
        keyboardCommands[Keys.Control | Keys.O] = openCommand;
        
        // Bind to controls
        saveButton.KryptonCommand = saveCommand;
        openButton.KryptonCommand = openCommand;
    }
    
    protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
    {
        if (keyboardCommands.ContainsKey(keyData))
        {
            var command = keyboardCommands[keyData];
            if (command.Enabled)
            {
                command.PerformExecute();
                return true;
            }
        }
        
        return base.ProcessCmdKey(ref msg, keyData);
    }
}
```

---

### Command Logging

```csharp
public class LoggingCommand : KryptonCommand
{
    private ILogger logger;
    
    public LoggingCommand(ILogger log)
    {
        logger = log;
        
        Execute += (s, e) =>
        {
            logger.LogInformation($"Command '{Text}' executed");
        };
        
        PropertyChanged += (s, e) =>
        {
            logger.LogDebug($"Command '{Text}' property '{e.PropertyName}' changed");
        };
    }
}
```

---

### Conditional Command Execution

```csharp
public class ConfirmableCommand : KryptonCommand
{
    public string ConfirmMessage { get; set; }
    
    public ConfirmableCommand(string confirmMessage = null)
    {
        ConfirmMessage = confirmMessage;
        Execute += OnExecute;
    }
    
    private void OnExecute(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(ConfirmMessage))
        {
            var result = MessageBox.Show(
                ConfirmMessage,
                "Confirm Action",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);
            
            if (result != DialogResult.Yes)
            {
                return; // User cancelled
            }
        }
        
        // Proceed with actual execution
        ExecuteCore();
    }
    
    protected virtual void ExecuteCore()
    {
        // Override in derived classes
    }
}

// Usage:
var deleteCommand = new ConfirmableCommand("Are you sure you want to delete?")
{
    Text = "Delete"
};
```

---

## Design Patterns

### Command Factory

```csharp
public static class CommandFactory
{
    public static KryptonCommand CreateFileCommand(string action, EventHandler handler)
    {
        var command = new KryptonCommand
        {
            Text = action,
            ImageSmall = GetIconForAction(action)
        };
        command.Execute += handler;
        return command;
    }
    
    private static Image GetIconForAction(string action)
    {
        return action switch
        {
            "New" => Properties.Resources.NewIcon,
            "Open" => Properties.Resources.OpenIcon,
            "Save" => Properties.Resources.SaveIcon,
            _ => null
        };
    }
}
```

---

### Composite Command

```csharp
public class CompositeCommand : KryptonCommand
{
    private List<KryptonCommand> childCommands = new();
    
    public void AddCommand(KryptonCommand command)
    {
        childCommands.Add(command);
        UpdateState();
    }
    
    private void UpdateState()
    {
        // Enabled if all children are enabled
        Enabled = childCommands.All(c => c.Enabled);
    }
    
    protected override void OnExecute()
    {
        // Execute all child commands
        foreach (var command in childCommands)
        {
            if (command.Enabled)
            {
                command.PerformExecute();
            }
        }
    }
}
```

---

## Best Practices

### Command Naming
- Use clear, action-oriented names: "Save", "Open", "Delete"
- Include mnemonics: "&Save", "&Open"
- Be consistent across application

### State Management
- Update `Enabled` based on application state
- Use `Checked` for toggle states
- Use `CheckState.Indeterminate` for mixed selections

### Image Guidelines
- Provide both small (16x16) and large (32x32) images
- Use consistent icon style across commands
- Consider high-DPI displays

### Event Handling
- Keep Execute handlers lightweight
- Use async/await for long-running operations
- Provide user feedback (progress, completion)

### Testing
- Commands centralize logic - easier to test
- Mock commands for UI testing
- Test enabled state logic separately

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** System.ComponentModel (INotifyPropertyChanged)

---

## See Also

- [KryptonCommand](KryptonCommand.md) - Concrete implementation
- [KryptonButton](KryptonButton.md) - Control using commands
- [KryptonRibbon](KryptonRibbon.md) - Ribbon command support
- [INotifyPropertyChanged](https://docs.microsoft.com/en-us/dotnet/api/system.componentmodel.inotifypropertychanged) - Property change notification