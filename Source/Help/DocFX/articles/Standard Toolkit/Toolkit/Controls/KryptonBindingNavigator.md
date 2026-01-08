# KryptonBindingNavigator

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [API Reference](#api-reference)
4. [Usage Examples](#usage-examples)
5. [Integration with BindingSource](#integration-with-bindingsource)
6. [Customization](#customization)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

---

## Overview

`KryptonBindingNavigator` is a user control that provides a comprehensive user interface for navigating and manipulating data bound to a `BindingSource`. It offers a complete set of navigation controls including First, Previous, Next, Last buttons, a position textbox, count display, and Add/Delete functionality.

### Key Characteristics

- **Inheritance**: `UserControl`
- **Namespace**: `Krypton.Toolkit`
- **Assembly**: `Krypton.Toolkit`
- **Designer Support**: Full design-time support with Toolbox integration
- **Data Binding**: Integrates seamlessly with `System.Windows.Forms.BindingSource`

### Purpose

The `KryptonBindingNavigator` control simplifies the implementation of data navigation interfaces by providing:

- Standard navigation controls (First, Previous, Next, Last)
- Direct position navigation via text input
- Visual feedback of current position and total count
- Add and Delete operations
- Automatic state management based on data source state
- Consistent Krypton-themed appearance

---

## Features

### Core Features

1. **Navigation Controls**
   - Move First (`|<`) - Navigate to the first item
   - Move Previous (`<`) - Navigate to the previous item
   - Move Next (`>`) - Navigate to the next item
   - Move Last (`>|`) - Navigate to the last item

2. **Position Display**
   - Textbox showing current 1-based position
   - Direct position entry with Enter key validation
   - Automatic validation on focus loss
   - Count label displaying "of N" format

3. **Data Manipulation**
   - Add New button (`+`) - Adds a new item to the data source
   - Delete button (`×`) - Removes the current item

4. **Automatic State Management**
   - Buttons automatically enable/disable based on position
   - Position textbox updates on navigation
   - Count label updates when data changes
   - Handles empty lists, single items, and large datasets

5. **Event Integration**
   - Subscribes to `BindingSource` events (PositionChanged, CurrentChanged, ListChanged)
   - Raises `RefreshItems` event for custom handling
   - Automatic refresh on data source changes

### Visual Layout

The control arranges elements horizontally in the following order:

```
[|<] [<] [Position] [of N] [>] [>|] [++] [×]
```

With appropriate spacing between groups:
- Navigation buttons grouped together
- Position display grouped together
- Add/Delete buttons grouped together

---

## API Reference

### Properties

#### BindingSource

```csharp
public BindingSource? BindingSource { get; set; }
```

**Category**: Data  
**Description**: Gets or sets the `BindingSource` component that is the source of data.

**Remarks**:
- Setting this property automatically subscribes to `BindingSource` events
- When set to `null`, all navigation controls are disabled
- Changing the `BindingSource` automatically refreshes the control state
- The control listens to `PositionChanged`, `CurrentChanged`, and `ListChanged` events

**Example**:
```csharp
var bindingSource = new BindingSource { DataSource = myList };
kryptonBindingNavigator1.BindingSource = bindingSource;
```

---

#### AddNewItemEnabled

```csharp
public bool AddNewItemEnabled { get; set; }
```

**Category**: Behavior  
**Default Value**: `true`  
**Description**: Gets or sets a value indicating whether the Add New button is enabled.

**Remarks**:
- When `false`, the Add New button is disabled regardless of `BindingSource.AllowNew`
- When `true`, the button state depends on `BindingSource.AllowNew` and data availability
- This provides an additional layer of control beyond the `BindingSource` settings

**Example**:
```csharp
// Disable Add New functionality
kryptonBindingNavigator1.AddNewItemEnabled = false;
```

---

#### DeleteItemEnabled

```csharp
public bool DeleteItemEnabled { get; set; }
```

**Category**: Behavior  
**Default Value**: `true`  
**Description**: Gets or sets a value indicating whether the Delete button is enabled.

**Remarks**:
- When `false`, the Delete button is disabled regardless of `BindingSource.AllowRemove`
- When `true`, the button state depends on `BindingSource.AllowRemove` and data availability
- The button is also disabled when there are no items in the data source

**Example**:
```csharp
// Disable Delete functionality
kryptonBindingNavigator1.DeleteItemEnabled = false;
```

---

#### MoveFirstItem

```csharp
public KryptonButton? MoveFirstItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the Move First button control.

**Remarks**:
- Returns `null` if the button hasn't been initialized
- Use this property to customize the button appearance or behavior
- The button text is set to `"|<"` by default
- Button size is fixed at 30x25 pixels

**Example**:
```csharp
if (kryptonBindingNavigator1.MoveFirstItem != null)
{
    kryptonBindingNavigator1.MoveFirstItem.Values.Text = "First";
    kryptonBindingNavigator1.MoveFirstItem.Values.Image = myIcon;
}
```

---

#### MovePreviousItem

```csharp
public KryptonButton? MovePreviousItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the Move Previous button control.

**Remarks**:
- Returns `null` if the button hasn't been initialized
- Button text is set to `"<"` by default
- Button size is fixed at 30x25 pixels

---

#### MoveNextItem

```csharp
public KryptonButton? MoveNextItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the Move Next button control.

**Remarks**:
- Returns `null` if the button hasn't been initialized
- Button text is set to `">"` by default
- Button size is fixed at 30x25 pixels

---

#### MoveLastItem

```csharp
public KryptonButton? MoveLastItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the Move Last button control.

**Remarks**:
- Returns `null` if the button hasn't been initialized
- Button text is set to `">|"` by default
- Button size is fixed at 30x25 pixels

---

#### AddNewItem

```csharp
public KryptonButton? AddNewItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the Add New button control.

**Remarks**:
- Returns `null` if the button hasn't been initialized
- Button text is set to `"+"` by default
- Button size is fixed at 30x25 pixels
- Button state depends on `AddNewItemEnabled` and `BindingSource.AllowNew`

---

#### DeleteItem

```csharp
public KryptonButton? DeleteItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the Delete button control.

**Remarks**:
- Returns `null` if the button hasn't been initialized
- Button text is set to `"×"` by default
- Button size is fixed at 30x25 pixels
- Button state depends on `DeleteItemEnabled`, `BindingSource.AllowRemove`, and data availability

---

#### PositionItem

```csharp
public KryptonTextBox? PositionItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the position textbox control.

**Remarks**:
- Returns `null` if the textbox hasn't been initialized
- Width is fixed at 50 pixels, height matches button height (25 pixels)
- Displays 1-based position (user-friendly)
- Validates input on Enter key press and focus loss
- Automatically restores valid position if invalid input is entered

**Example**:
```csharp
if (kryptonBindingNavigator1.PositionItem != null)
{
    kryptonBindingNavigator1.PositionItem.Width = 60;
    kryptonBindingNavigator1.PositionItem.TextAlign = HorizontalAlignment.Center;
}
```

---

#### CountItem

```csharp
public KryptonLabel? CountItem { get; }
```

**Category**: N/A (Browsable: false)  
**Description**: Gets the count label control.

**Remarks**:
- Returns `null` if the label hasn't been initialized
- Displays text in format `"of N"` where N is the total count
- Uses `LabelStyle.NormalControl` by default
- AutoSize is enabled

**Example**:
```csharp
if (kryptonBindingNavigator1.CountItem != null)
{
    kryptonBindingNavigator1.CountItem.Values.Text = $"Total: {count}";
}
```

---

### Methods

#### RefreshItemsInternal

```csharp
public void RefreshItemsInternal()
```

**Description**: Refreshes the state of all navigator items to reflect the current state of the data.

**Remarks**:
- This method is called automatically when:
  - The `BindingSource` changes
  - The position changes (`PositionChanged` event)
  - The current item changes (`CurrentChanged` event)
  - The list changes (`ListChanged` event)
- Manually call this method when you need to force a refresh without changing the `BindingSource`
- Raises the `RefreshItems` event before updating the UI
- Updates button states, position textbox, and count label

**Example**:
```csharp
// Force a refresh after programmatic data changes
myBindingSource.Add(newItem);
kryptonBindingNavigator1.RefreshItemsInternal();
```

---

### Events

#### RefreshItems

```csharp
public event EventHandler? RefreshItems;
```

**Category**: Action  
**Description**: Occurs when `RefreshItemsInternal()` is called to refresh the state of the items.

**Remarks**:
- Raised before the UI is updated
- Use this event to perform custom actions when the navigator refreshes
- The event is raised even when there's no `BindingSource` assigned
- Useful for updating related UI elements or performing validation

**Example**:
```csharp
kryptonBindingNavigator1.RefreshItems += (sender, e) =>
{
    // Update custom display
    UpdateStatusLabel();
    
    // Perform validation
    ValidateCurrentItem();
};
```

---

## Usage Examples

### Basic Usage

The simplest way to use `KryptonBindingNavigator` is to bind it to a `BindingSource`:

```csharp
// Create data source
var dataList = new List<Person>
{
    new Person { Id = 1, Name = "John Doe" },
    new Person { Id = 2, Name = "Jane Smith" },
    new Person { Id = 3, Name = "Bob Johnson" }
};

// Create BindingSource
var bindingSource = new BindingSource
{
    DataSource = dataList,
    AllowNew = true
};

// Bind to navigator
kryptonBindingNavigator1.BindingSource = bindingSource;

// Bind to DataGridView for display
dataGridView1.DataSource = bindingSource;
```

---

### Complete Example with Detail Controls

This example demonstrates a full data entry form with navigation:

```csharp
public partial class PersonForm : KryptonForm
{
    private BindingSource _bindingSource = null!;
    private List<Person> _dataList = null!;

    public PersonForm()
    {
        InitializeComponent();
        InitializeData();
    }

    private void InitializeData()
    {
        // Create sample data
        _dataList = new List<Person>
        {
            new Person { Id = 1, FirstName = "John", LastName = "Doe", Email = "john@example.com" },
            new Person { Id = 2, FirstName = "Jane", LastName = "Smith", Email = "jane@example.com" }
        };

        // Create BindingSource
        _bindingSource = new BindingSource
        {
            DataSource = _dataList,
            AllowNew = true
        };

        // Bind navigator
        kryptonBindingNavigator1.BindingSource = _bindingSource;

        // Bind detail controls
        txtFirstName.DataBindings.Add("Text", _bindingSource, "FirstName");
        txtLastName.DataBindings.Add("Text", _bindingSource, "LastName");
        txtEmail.DataBindings.Add("Text", _bindingSource, "Email");

        // Subscribe to events
        _bindingSource.CurrentChanged += BindingSource_CurrentChanged;
        kryptonBindingNavigator1.RefreshItems += Navigator_RefreshItems;
    }

    private void BindingSource_CurrentChanged(object? sender, EventArgs e)
    {
        if (_bindingSource.Current is Person person)
        {
            lblStatus.Text = $"Current: {person.FirstName} {person.LastName}";
        }
    }

    private void Navigator_RefreshItems(object? sender, EventArgs e)
    {
        // Custom refresh logic
        UpdateStatusDisplay();
    }

    private void UpdateStatusDisplay()
    {
        int count = _bindingSource?.Count ?? 0;
        int position = _bindingSource?.Position + 1 ?? 0;
        lblInfo.Text = $"Item {position} of {count}";
    }
}
```

---

### Customizing Button Appearance

You can customize individual buttons through the exposed properties:

```csharp
// Customize Move First button
if (kryptonBindingNavigator1.MoveFirstItem != null)
{
    kryptonBindingNavigator1.MoveFirstItem.Values.Text = "First";
    kryptonBindingNavigator1.MoveFirstItem.Values.Image = Properties.Resources.FirstIcon;
    kryptonBindingNavigator1.MoveFirstItem.ButtonStyle = ButtonStyle.Standalone;
}

// Customize Add New button
if (kryptonBindingNavigator1.AddNewItem != null)
{
    kryptonBindingNavigator1.AddNewItem.Values.Text = "Add";
    kryptonBindingNavigator1.AddNewItem.Values.Image = Properties.Resources.AddIcon;
}

// Customize position textbox
if (kryptonBindingNavigator1.PositionItem != null)
{
    kryptonBindingNavigator1.PositionItem.Width = 60;
    kryptonBindingNavigator1.PositionItem.TextAlign = HorizontalAlignment.Center;
    kryptonBindingNavigator1.PositionItem.PromptText = "Position";
}
```

---

### Handling Empty Lists

The navigator automatically handles empty lists, but you may want to provide custom handling:

```csharp
kryptonBindingNavigator1.RefreshItems += (sender, e) =>
{
    if (_bindingSource?.Count == 0)
    {
        // Show message or disable related controls
        lblMessage.Text = "No items available. Click Add to create a new item.";
        btnSave.Enabled = false;
    }
    else
    {
        lblMessage.Text = string.Empty;
        btnSave.Enabled = true;
    }
};
```

---

### Programmatic Navigation

You can programmatically navigate using the `BindingSource`:

```csharp
// Navigate to first item
_bindingSource.MoveFirst();

// Navigate to last item
_bindingSource.MoveLast();

// Navigate to specific position (0-based)
_bindingSource.Position = 5;

// Navigate relative
_bindingSource.MoveNext();
_bindingSource.MovePrevious();

// The navigator will automatically update
```

---

### Conditional Enable/Disable

Control when Add/Delete operations are allowed:

```csharp
// Disable Add New in certain conditions
if (IsReadOnlyMode)
{
    kryptonBindingNavigator1.AddNewItemEnabled = false;
}

// Disable Delete for specific items
kryptonBindingNavigator1.RefreshItems += (sender, e) =>
{
    if (_bindingSource?.Current is Person person && person.IsProtected)
    {
        kryptonBindingNavigator1.DeleteItemEnabled = false;
    }
    else
    {
        kryptonBindingNavigator1.DeleteItemEnabled = true;
    }
};
```

---

## Integration with BindingSource

### BindingSource Requirements

`KryptonBindingNavigator` works with any `BindingSource` that:

1. Has a `DataSource` assigned (can be `null` initially)
2. Implements standard `BindingSource` functionality
3. Supports `Position`, `Count`, `Current` properties
4. Raises `PositionChanged`, `CurrentChanged`, and `ListChanged` events

### Supported Data Sources

The navigator works with various data source types:

- **Generic Lists** (`List<T>`)
  ```csharp
  var list = new List<Person>();
  bindingSource.DataSource = list;
  ```

- **Arrays**
  ```csharp
  var array = new Person[10];
  bindingSource.DataSource = array;
  ```

- **DataTables**
  ```csharp
  var table = new DataTable();
  bindingSource.DataSource = table;
  ```

- **Collections**
  ```csharp
  var collection = new BindingList<Person>();
  bindingSource.DataSource = collection;
  ```

### BindingSource Properties

#### AllowNew

```csharp
bindingSource.AllowNew = true; // Enable Add New functionality
```

**Note**: `AllowNew` is read-write and controls whether new items can be added. When `false`, the Add New button is disabled.

#### AllowRemove

**Note**: `AllowRemove` is read-only and depends on the underlying data source. For `List<T>`, it's automatically `true`. For read-only collections, it's `false`.

### Event Handling

The navigator automatically subscribes to these `BindingSource` events:

1. **PositionChanged**: Triggered when `BindingSource.Position` changes
2. **CurrentChanged**: Triggered when `BindingSource.Current` changes
3. **ListChanged**: Triggered when items are added, removed, or modified

All these events cause `RefreshItemsInternal()` to be called, updating the UI.

---

## Customization

### Layout Customization

The control uses a custom layout algorithm in `OnLayout()`. To customize spacing or positioning, you can:

1. **Adjust Padding**: Modify the control's `Padding` property
   ```csharp
   kryptonBindingNavigator1.Padding = new Padding(10, 5, 10, 5);
   ```

2. **Override OnLayout**: Create a derived class and override `OnLayout()` (advanced)

### Button Customization

All buttons are accessible through their respective properties:

```csharp
// Change button text
kryptonBindingNavigator1.MoveFirstItem!.Values.Text = "First";

// Change button style
kryptonBindingNavigator1.MoveFirstItem!.ButtonStyle = ButtonStyle.Standalone;

// Add images
kryptonBindingNavigator1.MoveFirstItem!.Values.Image = myImage;

// Change size (note: may affect layout)
kryptonBindingNavigator1.MoveFirstItem!.Size = new Size(40, 30);
```

### Position Textbox Customization

```csharp
var positionBox = kryptonBindingNavigator1.PositionItem;
if (positionBox != null)
{
    positionBox.Width = 60;
    positionBox.TextAlign = HorizontalAlignment.Center;
    positionBox.PromptText = "Go to";
    positionBox.InputControlStyle = InputControlStyle.Standalone;
}
```

### Count Label Customization

```csharp
var countLabel = kryptonBindingNavigator1.CountItem;
if (countLabel != null)
{
    countLabel.LabelStyle = LabelStyle.TitlePanel;
    countLabel.Values.Font = new Font("Arial", 10, FontStyle.Bold);
}
```

### Theming

The control inherits theming from the Krypton palette system:

```csharp
// Apply global theme
kryptonManager1.GlobalPaletteMode = PaletteMode.Office2010Blue;

// The navigator automatically uses the theme
```

---

## Best Practices

### 1. Always Set BindingSource

Always assign a `BindingSource` (even if initially empty) rather than leaving it `null`:

```csharp
// Good
var bindingSource = new BindingSource { DataSource = new List<Person>() };
kryptonBindingNavigator1.BindingSource = bindingSource;

// Avoid
kryptonBindingNavigator1.BindingSource = null; // Disables all functionality
```

### 2. Handle RefreshItems Event

Use the `RefreshItems` event to keep related UI elements synchronized:

```csharp
kryptonBindingNavigator1.RefreshItems += (sender, e) =>
{
    UpdateRelatedControls();
    ValidateCurrentItem();
};
```

### 3. Use BindingSource for Data Operations

Perform data operations through the `BindingSource`, not directly on the data source:

```csharp
// Good - Navigator updates automatically
_bindingSource.AddNew();
_bindingSource.RemoveCurrent();
_bindingSource.MoveNext();

// Avoid - Navigator won't update automatically
_dataList.Add(newItem);
_dataList.RemoveAt(index);
```

### 4. Validate Before Operations

Add validation before allowing Add/Delete operations:

```csharp
kryptonBindingNavigator1.RefreshItems += (sender, e) =>
{
    if (_bindingSource?.Current != null)
    {
        bool canDelete = ValidateCanDelete(_bindingSource.Current);
        kryptonBindingNavigator1.DeleteItemEnabled = canDelete;
    }
};
```

### 5. Handle Empty States

Provide user feedback when the list is empty:

```csharp
kryptonBindingNavigator1.RefreshItems += (sender, e) =>
{
    if (_bindingSource?.Count == 0)
    {
        lblMessage.Text = "No items. Click Add to create one.";
        lblMessage.Visible = true;
    }
    else
    {
        lblMessage.Visible = false;
    }
};
```

### 6. Dispose Properly

The control automatically unsubscribes from events in `Dispose()`, but ensure proper cleanup:

```csharp
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // Navigator automatically cleans up BindingSource subscriptions
        _bindingSource?.Dispose();
    }
    base.Dispose(disposing);
}
```

### 7. Use Data Binding for Detail Controls

Bind detail controls to the same `BindingSource` for automatic synchronization:

```csharp
// All controls stay synchronized automatically
txtName.DataBindings.Add("Text", _bindingSource, "Name");
txtEmail.DataBindings.Add("Text", _bindingSource, "Email");
numericAge.DataBindings.Add("Value", _bindingSource, "Age");
```

---

## Troubleshooting

### Common Issues

#### Buttons Are Disabled

**Symptom**: All navigation buttons are disabled.

**Possible Causes**:
1. `BindingSource` is `null`
2. `BindingSource.DataSource` is `null` or empty
3. `BindingSource.Count` is 0

**Solution**:
```csharp
// Check BindingSource
if (kryptonBindingNavigator1.BindingSource == null)
{
    kryptonBindingNavigator1.BindingSource = myBindingSource;
}

// Check data source
if (bindingSource.Count == 0)
{
    // Add items or inform user
}
```

---

#### Add New Button Doesn't Work

**Symptom**: Add New button is disabled or doesn't add items.

**Possible Causes**:
1. `AddNewItemEnabled` is `false`
2. `BindingSource.AllowNew` is `false`
3. Data source doesn't support adding items

**Solution**:
```csharp
// Enable AddNewItemEnabled
kryptonBindingNavigator1.AddNewItemEnabled = true;

// Enable BindingSource.AllowNew
bindingSource.AllowNew = true;

// Ensure data source supports adding
// For List<T>, this works automatically
```

---

#### Delete Button Doesn't Work

**Symptom**: Delete button is disabled or doesn't remove items.

**Possible Causes**:
1. `DeleteItemEnabled` is `false`
2. `BindingSource.AllowRemove` is `false` (read-only)
3. Data source doesn't support removal
4. No items in the list

**Solution**:
```csharp
// Enable DeleteItemEnabled
kryptonBindingNavigator1.DeleteItemEnabled = true;

// Check if data source supports removal
// For List<T>, AllowRemove is automatically true
// For read-only collections, it's false

// Ensure there are items to delete
if (bindingSource.Count > 0)
{
    // Delete should work
}
```

---

#### Position Textbox Doesn't Update

**Symptom**: Position textbox shows incorrect value or doesn't update.

**Possible Causes**:
1. `BindingSource` events not firing
2. Manual position changes not triggering refresh

**Solution**:
```csharp
// Manually refresh after programmatic changes
bindingSource.Position = newPosition;
kryptonBindingNavigator1.RefreshItemsInternal();
```

---

#### Count Label Shows "of 0"

**Symptom**: Count label always shows "of 0" even when there are items.

**Possible Causes**:
1. `BindingSource` is `null`
2. `BindingSource.DataSource` is `null`
3. `BindingSource.Count` is actually 0

**Solution**:
```csharp
// Verify BindingSource has data
if (bindingSource?.Count > 0)
{
    // Count should update automatically
    // If not, manually refresh
    kryptonBindingNavigator1.RefreshItemsInternal();
}
```

---

#### Navigation Buttons Don't Respond

**Symptom**: Clicking navigation buttons doesn't change position.

**Possible Causes**:
1. `BindingSource` is `null`
2. Event handlers not connected
3. Data source issues

**Solution**:
```csharp
// Verify BindingSource is set
if (kryptonBindingNavigator1.BindingSource == null)
{
    kryptonBindingNavigator1.BindingSource = myBindingSource;
}

// Verify data source
if (bindingSource.Count == 0)
{
    // No items to navigate
}
```

---

### Performance Considerations

1. **Large Datasets**: The navigator performs well with large datasets. Navigation is O(1) operation.

2. **Frequent Updates**: If you're making many rapid changes, consider batching updates:
   ```csharp
   // Suspend updates temporarily
   bindingSource.SuspendBinding();
   // Make multiple changes
   // ...
   bindingSource.ResumeBinding();
   // Navigator updates automatically
   ```

3. **Event Handling**: The `RefreshItems` event fires frequently. Keep handlers lightweight:
   ```csharp
   // Good - lightweight handler
   kryptonBindingNavigator1.RefreshItems += (s, e) => UpdateLabel();
   
   // Avoid - heavy operations
   kryptonBindingNavigator1.RefreshItems += (s, e) => 
   {
       // Don't do heavy database queries here
   };
   ```

---

## Additional Resources

- **BindingSource Documentation**: [MSDN BindingSource](https://learn.microsoft.com/dotnet/api/system.windows.forms.bindingsource)