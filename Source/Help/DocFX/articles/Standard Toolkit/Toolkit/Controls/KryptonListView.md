# KryptonListView

## Overview

`KryptonListView` is a Windows Forms control that extends the standard `ListView` with comprehensive Krypton palette styling and theming capabilities. It provides a fully themed list view with support for all standard ListView modes (List, Details, Tiles, SmallIcon, LargeIcon) while integrating seamlessly with the Krypton design system.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `VisualControlBase` → `KryptonListView`

## Key Features

### Palette Integration
- Full Krypton palette support with automatic theme switching
- Support for built-in and custom palettes
- State-based styling (Normal, Disabled, Active, Tracking, CheckedNormal, CheckedTracking)
- Item-level palette application

### Visual Capabilities
- All standard ListView view modes (List, Details, Tiles, Icons)
- Checkboxes and multi-selection support
- Column headers with sorting
- Groups and virtual mode support
- Custom background and border styles
- Item state-based coloring (selected, checked, focused, disabled)

### Behavior Features
- Full mouse tracking and hover states
- KryptonContextMenu integration
- Item selection and activation events
- Label editing support
- Search and hit testing
- Drag-and-drop column reordering

### Performance
- Double-buffered rendering to reduce flicker
- Optimized palette change handling
- Efficient item state updates
- Virtual mode support for large datasets

---

## Constructor

### KryptonListView()

Initializes a new instance of the `KryptonListView` class.

```csharp
public KryptonListView()
```

**Default Settings:**
- `Padding` = `1, 1, 1, 1`
- `BackStyle` = `PaletteBackStyle.InputControlStandalone`
- `BorderStyle` = `PaletteBorderStyle.InputControlStandalone`
- `AlwaysActive` = `false`
- `View` = `View.LargeIcon`

---

## Properties

### Core ListView Properties

#### View
Gets or sets how items are displayed in the control.

```csharp
[Category("Appearance")]
[DefaultValue(View.LargeIcon)]
[Description("How items are displayed in the control.")]
public View View { get; set; }
```

**Available Views:**
- `LargeIcon` - Large icon view (default)
- `SmallIcon` - Small icon view
- `List` - Simple list view
- `Details` - Details view with columns
- `Tile` - Tile view (Windows Vista+)

**Example:**
```csharp
kryptonListView1.View = View.Details;
```

---

#### Items
Gets the collection containing all items in the control.

```csharp
[Category("Behavior")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
[Localizable(true)]
public ListView.ListViewItemCollection Items { get; }
```

**Example:**
```csharp
kryptonListView1.Items.Add(new ListViewItem("Item 1"));
kryptonListView1.Items.Add(new ListViewItem(new[] { "Name", "Value" }));
```

---

#### Columns
Gets the collection of all column headers in Details view.

```csharp
[Category("Behavior")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
[Localizable(true)]
public ListView.ColumnHeaderCollection Columns { get; }
```

**Example:**
```csharp
kryptonListView1.View = View.Details;
kryptonListView1.Columns.Add("Name", 200);
kryptonListView1.Columns.Add("Type", 100);
kryptonListView1.Columns.Add("Size", 80);
```

---

#### CheckBoxes
Gets or sets whether a checkbox appears next to each item.

```csharp
[Category("Appearance")]
[DefaultValue(false)]
[Description("Whether a checkbox appears next to each item.")]
public bool CheckBoxes { get; set; }
```

**Example:**
```csharp
kryptonListView1.CheckBoxes = true;
kryptonListView1.Items.Add("Option 1").Checked = true;
kryptonListView1.Items.Add("Option 2");
```

---

#### MultiSelect
Gets or sets whether multiple items can be selected.

```csharp
[Category("Behavior")]
[DefaultValue(true)]
[Description("Whether multiple items can be selected.")]
public bool MultiSelect { get; set; }
```

---

#### FullRowSelect
Gets or sets whether clicking an item selects all its subitems.

```csharp
[Category("Appearance")]
[DefaultValue(false)]
[Description("Whether clicking an item selects all its subitems.")]
public bool FullRowSelect { get; set; }
```

**Example:**
```csharp
kryptonListView1.View = View.Details;
kryptonListView1.FullRowSelect = true; // Entire row highlights
```

---

#### GridLines
Gets or sets whether grid lines appear between rows and columns.

```csharp
[Category("Appearance")]
[DefaultValue(false)]
[Description("Whether grid lines are drawn around items and subitems.")]
public bool GridLines { get; set; }
```

---

#### Groups
Gets the collection of ListViewGroup objects assigned to the control.

```csharp
[Category("Behavior")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
[Localizable(true)]
public ListViewGroupCollection Groups { get; }
```

**Example:**
```csharp
var group1 = new ListViewGroup("Group 1");
var group2 = new ListViewGroup("Group 2");
kryptonListView1.Groups.Add(group1);
kryptonListView1.Groups.Add(group2);

kryptonListView1.Items.Add(new ListViewItem("Item 1", group1));
kryptonListView1.Items.Add(new ListViewItem("Item 2", group2));
```

---

#### ShowGroups
Gets or sets whether items are displayed in groups.

```csharp
[Category("Behavior")]
[DefaultValue(true)]
[Description("Whether items are displayed in groups.")]
public bool ShowGroups { get; set; }
```

---

### Selection Properties

#### SelectedItems
Gets the items that are selected in the control.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ListView.SelectedListViewItemCollection SelectedItems { get; }
```

**Example:**
```csharp
foreach (ListViewItem item in kryptonListView1.SelectedItems)
{
    Console.WriteLine($"Selected: {item.Text}");
}
```

---

#### SelectedIndices
Gets the indexes of the selected items.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ListView.SelectedIndexCollection SelectedIndices { get; }
```

---

#### CheckedItems
Gets the currently checked items.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ListView.CheckedListViewItemCollection CheckedItems { get; }
```

**Example:**
```csharp
foreach (ListViewItem item in kryptonListView1.CheckedItems)
{
    Console.WriteLine($"Checked: {item.Text}");
}
```

---

#### CheckedIndices
Gets the indexes of the currently checked items.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ListView.CheckedIndexCollection CheckedIndices { get; }
```

---

#### FocusedItem
Gets or sets the item that currently has focus.

```csharp
[Category("Appearance")]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ListViewItem? FocusedItem { get; set; }
```

---

### Image List Properties

#### LargeImageList
Gets or sets the ImageList to use when displaying items as large icons.

```csharp
[Category("Behavior")]
[DefaultValue(null)]
[Description("Icons to use when View is set to LargeIcon.")]
public ImageList? LargeImageList { get; set; }
```

**Example:**
```csharp
var largeImages = new ImageList { ImageSize = new Size(48, 48) };
largeImages.Images.Add("folder", Properties.Resources.FolderIcon);
largeImages.Images.Add("file", Properties.Resources.FileIcon);

kryptonListView1.LargeImageList = largeImages;
kryptonListView1.Items.Add("Documents", "folder");
kryptonListView1.Items.Add("Report.pdf", "file");
```

---

#### SmallImageList
Gets or sets the ImageList to use when displaying items as small icons.

```csharp
[Category("Behavior")]
[DefaultValue(null)]
[Description("Icons to use when View is set to SmallIcon or List.")]
public ImageList? SmallImageList { get; set; }
```

---

#### StateImageList
Gets or sets the ImageList for application-defined states.

```csharp
[Category("Behavior")]
[DefaultValue(null)]
[Description("State images for custom item states.")]
public ImageList? StateImageList { get; set; }
```

---

### Palette State Properties

#### StateCommon
Gets access to common appearance settings that other states can override.

```csharp
[Category("Visuals")]
[Description("Overrides for defining common appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeStateRedirect StateCommon { get; }
```

**Example:**
```csharp
kryptonListView1.StateCommon.Back.Color1 = Color.White;
kryptonListView1.StateCommon.Border.Rounding = 5;
```

---

#### StateNormal
Gets access to normal state appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining normal appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeState StateNormal { get; }
```

---

#### StateDisabled
Gets access to disabled state appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining disabled appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeState StateDisabled { get; }
```

---

#### StateActive
Gets access to active state appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining active appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteDouble StateActive { get; }
```

**Remarks:**
- Applied when the control has focus or `AlwaysActive = true`

---

#### StateTracking
Gets access to hot tracking item appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining hot tracking item appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeNodeTriple StateTracking { get; }
```

**Remarks:**
- Applied to selected/hovered items

---

#### StateCheckedNormal
Gets access to normal checked item appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining normal checked item appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeNodeTriple StateCheckedNormal { get; }
```

---

#### StateCheckedTracking
Gets access to hot tracking checked item appearance settings.

```csharp
[Category("Visuals")]
[Description("Overrides for defining hot tracking checked item appearance.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeNodeTriple StateCheckedTracking { get; }
```

---

#### OverrideFocus
Gets access to item appearance when it has focus.

```csharp
[Category("Visuals")]
[Description("Overrides for defining item appearance when it has focus.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteTreeNodeTripleRedirect OverrideFocus { get; }
```

---

### Style Properties

#### BackStyle
Gets or sets the background style.

```csharp
[Category("Visuals")]
[Description("Style used to draw the background.")]
public PaletteBackStyle BackStyle { get; set; }
```

**Default:** `PaletteBackStyle.InputControlStandalone`

---

#### BorderStyle
Gets or sets the border style.

```csharp
[Category("Visuals")]
[Description("Style used to draw the border.")]
public PaletteBorderStyle BorderStyle { get; set; }
```

**Default:** `PaletteBorderStyle.InputControlStandalone`

---

#### AlwaysActive
Gets or sets whether the control is always active or only when it has focus.

```csharp
[Category("Visuals")]
[Description("Determines if the control is always active or only when focused.")]
[DefaultValue(false)]
public bool AlwaysActive { get; set; }
```

**Example:**
```csharp
kryptonListView1.AlwaysActive = true; // Always show active state colors
```

---

### Behavior Properties

#### Activation
Gets or sets the type of action required to activate an item.

```csharp
[Category("Behavior")]
[DefaultValue(ItemActivation.Standard)]
[Description("Type of action required to activate an item.")]
public ItemActivation Activation { get; set; }
```

**Values:**
- `Standard` - Single click
- `OneClick` - Single click (Vista+ style)
- `TwoClick` - Double click

---

#### LabelEdit
Gets or sets whether the user can edit item labels.

```csharp
[Category("Behavior")]
[DefaultValue(false)]
[Description("Whether the user can edit item labels.")]
public bool LabelEdit { get; set; }
```

**Example:**
```csharp
kryptonListView1.LabelEdit = true;
kryptonListView1.AfterLabelEdit += (s, e) =>
{
    if (string.IsNullOrEmpty(e.Label))
    {
        e.CancelEdit = true; // Reject empty labels
    }
};
```

---

#### HotTracking
Gets or sets whether item text appears as a hyperlink when hovered.

```csharp
[Category("Behavior")]
[DefaultValue(false)]
[Description("Whether item text appears as hyperlink when hovered.")]
public bool HotTracking { get; set; }
```

---

#### HoverSelection
Gets or sets whether items are automatically selected on hover.

```csharp
[Category("Behavior")]
[DefaultValue(false)]
[Description("Whether items are automatically selected on hover.")]
public bool HoverSelection { get; set; }
```

---

#### AllowColumnReorder
Gets or sets whether columns can be reordered by dragging headers.

```csharp
[Category("Behavior")]
[DefaultValue(false)]
[Description("Whether columns can be reordered by dragging.")]
public bool AllowColumnReorder { get; set; }
```

---

#### Sorting
Gets or sets the sort order for items.

```csharp
[Category("Behavior")]
[DefaultValue(SortOrder.None)]
[Description("Sort order for items in the control.")]
public SortOrder Sorting { get; set; }
```

**Values:**
- `None` - No sorting
- `Ascending` - Sort ascending
- `Descending` - Sort descending

---

#### ListViewItemSorter
Gets or sets the custom sorting comparer.

```csharp
[Category("Behavior")]
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public IComparer? ListViewItemSorter { get; set; }
```

**Example:**
```csharp
public class ListViewItemComparer : IComparer
{
    private int _column;
    public ListViewItemComparer(int column) => _column = column;
    
    public int Compare(object? x, object? y)
    {
        return String.Compare(
            ((ListViewItem)x).SubItems[_column].Text,
            ((ListViewItem)y).SubItems[_column].Text);
    }
}

kryptonListView1.ListViewItemSorter = new ListViewItemComparer(0);
```

---

### Contained Control

#### ListView
Gets access to the contained ListView instance.

```csharp
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
[Browsable(false)]
public ListView ListView { get; }
```

**Remarks:**
- Provides access to underlying ListView for advanced scenarios
- Use sparingly - prefer using KryptonListView properties

---

## Methods

### Item Management

#### Clear()
Removes all items and columns from the control.

```csharp
public void Clear()
```

**Example:**
```csharp
kryptonListView1.Clear();
```

---

#### BeginUpdate() / EndUpdate()
Suspends/resumes drawing during bulk operations.

```csharp
public void BeginUpdate()
public void EndUpdate()
```

**Example:**
```csharp
kryptonListView1.BeginUpdate();
try
{
    for (int i = 0; i < 1000; i++)
    {
        kryptonListView1.Items.Add($"Item {i}");
    }
}
finally
{
    kryptonListView1.EndUpdate();
}
```

---

#### EnsureVisible(int)
Scrolls to ensure the specified item is visible.

```csharp
public void EnsureVisible(int index)
```

**Example:**
```csharp
kryptonListView1.EnsureVisible(kryptonListView1.Items.Count - 1);
```

---

### Search and Hit Testing

#### FindItemWithText(string)
Finds the first item that begins with the specified text.

```csharp
public ListViewItem? FindItemWithText(string text)
public ListViewItem? FindItemWithText(string text, bool includeSubItemsInSearch, int startIndex)
public ListViewItem? FindItemWithText(string text, bool includeSubItemsInSearch, int startIndex, bool isPrefixSearch)
```

**Example:**
```csharp
var item = kryptonListView1.FindItemWithText("Report");
if (item != null)
{
    item.Selected = true;
    item.EnsureVisible();
}
```

---

#### HitTest(int, int)
Provides item information at the specified coordinates.

```csharp
public ListViewHitTestInfo HitTest(int x, int y)
public ListViewHitTestInfo HitTest(Point point)
```

**Example:**
```csharp
var hitTest = kryptonListView1.HitTest(e.X, e.Y);
if (hitTest.Item != null)
{
    Console.WriteLine($"Clicked on: {hitTest.Item.Text}");
}
```

---

#### GetItemAt(int, int)
Retrieves the item at the specified location.

```csharp
public ListViewItem? GetItemAt(int x, int y)
```

---

#### GetItemRect(int)
Retrieves the bounding rectangle for a specific item.

```csharp
public Rectangle GetItemRect(int index)
public Rectangle GetItemRect(int index, ItemBoundsPortion portion)
```

---

### Layout and Arrangement

#### ArrangeIcons()
Arranges items when displayed as icons.

```csharp
public void ArrangeIcons()
public void ArrangeIcons(ListViewAlignment value)
```

**Example:**
```csharp
kryptonListView1.View = View.LargeIcon;
kryptonListView1.ArrangeIcons(ListViewAlignment.SnapToGrid);
```

---

#### AutoResizeColumns()
Resizes column widths automatically.

```csharp
public void AutoResizeColumns(ColumnHeaderAutoResizeStyle headerAutoResize)
public void AutoResizeColumn(int columnIndex, ColumnHeaderAutoResizeStyle headerAutoResize)
```

**Example:**
```csharp
kryptonListView1.AutoResizeColumns(ColumnHeaderAutoResizeStyle.ColumnContent);
```

---

#### Sort()
Sorts the items using the current sort order or comparer.

```csharp
public void Sort()
```

---

#### RedrawItems(int, int, bool)
Forces a range of items to be redrawn.

```csharp
public void RedrawItems(int startIndex, int endIndex, bool invalidateOnly)
```

---

### State Management

#### SetFixedState(bool)
Sets the fixed state of the control.

```csharp
public void SetFixedState(bool active)
```

**Remarks:**
- Overrides automatic active state detection
- Useful for maintaining visual state during operations

---

#### IsActive
Gets whether the input control is currently active.

```csharp
[Browsable(false)]
public bool IsActive { get; }
```

**Calculated based on:**
- Design mode
- `AlwaysActive` property
- Control has focus
- Mouse is over control

---

## Events

### Selection Events

#### SelectedIndexChanged
Occurs when the selection state of an item changes.

```csharp
[Category("Behavior")]
public event EventHandler? SelectedIndexChanged
```

**Example:**
```csharp
kryptonListView1.SelectedIndexChanged += (s, e) =>
{
    statusLabel.Text = $"{kryptonListView1.SelectedItems.Count} items selected";
};
```

---

#### ItemSelectionChanged
Occurs when the selection state of an individual item changes.

```csharp
[Category("Behavior")]
public event ListViewItemSelectionChangedEventHandler? ItemSelectionChanged
```

**Example:**
```csharp
kryptonListView1.ItemSelectionChanged += (s, e) =>
{
    if (e.IsSelected)
    {
        Console.WriteLine($"Selected: {e.Item.Text}");
    }
};
```

---

### Item Events

#### ItemActivate
Occurs when an item is activated.

```csharp
[Category("Action")]
public event EventHandler? ItemActivate
```

**Example:**
```csharp
kryptonListView1.ItemActivate += (s, e) =>
{
    if (kryptonListView1.SelectedItems.Count > 0)
    {
        OpenFile(kryptonListView1.SelectedItems[0].Text);
    }
};
```

---

#### ItemCheck
Occurs when the check state of an item is about to change.

```csharp
[Category("Behavior")]
public event ItemCheckEventHandler? ItemCheck
```

**Example:**
```csharp
kryptonListView1.ItemCheck += (s, e) =>
{
    // Prevent unchecking if it's the last checked item
    if (e.NewValue == CheckState.Unchecked && kryptonListView1.CheckedItems.Count == 1)
    {
        e.NewValue = CheckState.Checked;
    }
};
```

---

#### ItemChecked
Occurs when the check state of an item changes.

```csharp
[Category("Behavior")]
public event ItemCheckedEventHandler? ItemChecked
```

---

### Label Editing Events

#### BeforeLabelEdit
Occurs when the user starts editing an item label.

```csharp
[Category("Behavior")]
public event LabelEditEventHandler? BeforeLabelEdit
```

**Example:**
```csharp
kryptonListView1.BeforeLabelEdit += (s, e) =>
{
    // Only allow editing of certain items
    if (kryptonListView1.Items[e.Item].Tag is string tag && tag == "readonly")
    {
        e.CancelEdit = true;
    }
};
```

---

#### AfterLabelEdit
Occurs when a label is edited by the user.

```csharp
[Category("Behavior")]
public event LabelEditEventHandler? AfterLabelEdit
```

**Example:**
```csharp
kryptonListView1.AfterLabelEdit += (s, e) =>
{
    if (string.IsNullOrWhiteSpace(e.Label))
    {
        e.CancelEdit = true;
        MessageBox.Show("Label cannot be empty.");
    }
};
```

---

### Column Events

#### ColumnClick
Occurs when a column header is clicked.

```csharp
[Category("Action")]
public event ColumnClickEventHandler? ColumnClick
```

**Example:**
```csharp
kryptonListView1.ColumnClick += (s, e) =>
{
    kryptonListView1.ListViewItemSorter = new ListViewItemComparer(e.Column);
    kryptonListView1.Sort();
};
```

---

### Virtual Mode Events

#### SearchForVirtualItem
Occurs when the ListView is in virtual mode and a search is taking place.

```csharp
[Category("Action")]
public event SearchForVirtualItemEventHandler? SearchForVirtualItem
```

---

#### VirtualItemsSelectionRangeChanged
Occurs in virtual mode when the selection state of a range changes.

```csharp
[Category("Behavior")]
public event ListViewVirtualItemsSelectionRangeChangedEventHandler? VirtualItemsSelectionRangeChanged
```

---

## Usage Examples

### Basic File Explorer Style

```csharp
var listView = new KryptonListView
{
    View = View.Details,
    FullRowSelect = true,
    GridLines = true,
    Dock = DockStyle.Fill
};

listView.Columns.Add("Name", 200);
listView.Columns.Add("Type", 100);
listView.Columns.Add("Size", 80);

// Add items
var item1 = new ListViewItem(new[] { "Document.docx", "Word Document", "45 KB" });
var item2 = new ListViewItem(new[] { "Image.png", "PNG Image", "230 KB" });
listView.Items.Add(item1);
listView.Items.Add(item2);

this.Controls.Add(listView);
```

---

### Checklist with Custom Styling

```csharp
var checkList = new KryptonListView
{
    View = View.List,
    CheckBoxes = true,
    MultiSelect = false
};

// Custom styling
checkList.StateTracking.Node.Back.Color1 = Color.LightBlue;
checkList.StateCheckedNormal.Node.Back.Color1 = Color.LightGreen;

checkList.Items.Add("Task 1");
checkList.Items.Add("Task 2");
checkList.Items.Add("Task 3");

checkList.ItemChecked += (s, e) =>
{
    int completed = checkList.CheckedItems.Count;
    int total = checkList.Items.Count;
    progressLabel.Text = $"{completed}/{total} completed";
};
```

---

### Grouped Items

```csharp
var listView = new KryptonListView
{
    View = View.Tile,
    ShowGroups = true
};

var recentGroup = new ListViewGroup("Recent Files");
var favoritesGroup = new ListViewGroup("Favorites");

listView.Groups.Add(recentGroup);
listView.Groups.Add(favoritesGroup);

listView.Items.Add(new ListViewItem("Report.pdf", recentGroup));
listView.Items.Add(new ListViewItem("Presentation.pptx", recentGroup));
listView.Items.Add(new ListViewItem("Budget.xlsx", favoritesGroup));
```

---

### Sortable Details View

```csharp
private int _sortColumn = 0;
private SortOrder _sortOrder = SortOrder.Ascending;

private void SetupSortableListView()
{
    kryptonListView1.View = View.Details;
    kryptonListView1.Columns.Add("Name", 150);
    kryptonListView1.Columns.Add("Date", 100);
    kryptonListView1.Columns.Add("Size", 80);
    
    kryptonListView1.ColumnClick += OnColumnClick;
}

private void OnColumnClick(object? sender, ColumnClickEventArgs e)
{
    if (e.Column == _sortColumn)
    {
        _sortOrder = _sortOrder == SortOrder.Ascending 
            ? SortOrder.Descending 
            : SortOrder.Ascending;
    }
    else
    {
        _sortColumn = e.Column;
        _sortOrder = SortOrder.Ascending;
    }
    
    kryptonListView1.ListViewItemSorter = new ListViewItemComparer(_sortColumn, _sortOrder);
    kryptonListView1.Sort();
}
```

---

### Dynamic Item Colors

```csharp
private void UpdateItemColors()
{
    kryptonListView1.BeginUpdate();
    
    foreach (ListViewItem item in kryptonListView1.Items)
    {
        if (item.Tag is FileInfo fileInfo)
        {
            if (fileInfo.Extension == ".exe")
            {
                item.ForeColor = Color.Red;
                item.Font = new Font(item.Font, FontStyle.Bold);
            }
            else if (fileInfo.Extension == ".txt")
            {
                item.ForeColor = Color.Blue;
            }
        }
    }
    
    kryptonListView1.EndUpdate();
}
```

---

### Context Menu Integration

```csharp
var contextMenu = new KryptonContextMenu();
var menuItems = contextMenu.Items.Add(new KryptonContextMenuItems());

menuItems.Items.Add(new KryptonContextMenuItem("Open", null, OnOpen));
menuItems.Items.Add(new KryptonContextMenuItem("Rename", null, OnRename));
menuItems.Items.Add(new KryptonContextMenuSeparator());
menuItems.Items.Add(new KryptonContextMenuItem("Delete", null, OnDelete));

kryptonListView1.KryptonContextMenu = contextMenu;

private void OnOpen(object? sender, EventArgs e)
{
    if (kryptonListView1.SelectedItems.Count > 0)
    {
        var item = kryptonListView1.SelectedItems[0];
        // Open logic
    }
}
```

---

## Design Considerations

### State Hierarchy

The control resolves item appearance using the following priority:

1. **Item state** (Selected, Checked, Focused, Disabled)
2. **Override states** (OverrideFocus when focused)
3. **State-specific properties** (StateTracking, StateCheckedNormal, etc.)
4. **StateCommon property**
5. **Palette defaults**

---

### Performance Tips

1. **Bulk Operations:** Use `BeginUpdate()`/`EndUpdate()`
```csharp
kryptonListView1.BeginUpdate();
// Add/modify many items
kryptonListView1.EndUpdate();
```

2. **Virtual Mode:** For large datasets (1000+ items)
```csharp
// Note: Virtual mode commented out in source - implementation needed
```

3. **Image Lists:** Reuse ImageList instances
```csharp
// Share ImageList across multiple controls
var sharedImages = new ImageList();
kryptonListView1.SmallImageList = sharedImages;
kryptonListView2.SmallImageList = sharedImages;
```

---

### Designer Support

The control is fully designer-compatible:
- Appears in the Toolbox under "Krypton Toolkit"
- Property grid shows categorized properties
- Collection editors for Items, Columns, Groups
- Serializes only non-default values

---

## Common Scenarios

### File Manager View

```csharp
private void SetupFileManager()
{
    kryptonListView1.View = View.Details;
    kryptonListView1.FullRowSelect = true;
    kryptonListView1.GridLines = true;
    kryptonListView1.AllowColumnReorder = true;
    
    kryptonListView1.Columns.Add("Name", 200);
    kryptonListView1.Columns.Add("Modified", 120);
    kryptonListView1.Columns.Add("Type", 100);
    kryptonListView1.Columns.Add("Size", 80);
    
    kryptonListView1.SmallImageList = fileIcons;
    
    LoadFiles(@"C:\Users\Documents");
}
```

---

### Task List with Progress

```csharp
private void CreateTaskList()
{
    var taskList = new KryptonListView
    {
        View = View.Details,
        CheckBoxes = true,
        FullRowSelect = true
    };
    
    taskList.Columns.Add("Task", 250);
    taskList.Columns.Add("Status", 100);
    taskList.Columns.Add("Priority", 80);
    
    taskList.ItemChecked += (s, e) =>
    {
        e.Item.SubItems[1].Text = e.Item.Checked ? "Complete" : "Pending";
        e.Item.ForeColor = e.Item.Checked ? Color.Gray : Color.Black;
    };
}
```

---

### Image Gallery

```csharp
private void SetupImageGallery()
{
    kryptonListView1.View = View.LargeIcon;
    kryptonListView1.LargeImageList = new ImageList 
    { 
        ImageSize = new Size(128, 128) 
    };
    
    foreach (var imagePath in Directory.GetFiles(@"C:\Pictures", "*.jpg"))
    {
        var thumbnail = Image.FromFile(imagePath);
        kryptonListView1.LargeImageList.Images.Add(Path.GetFileName(imagePath), thumbnail);
        kryptonListView1.Items.Add(Path.GetFileName(imagePath), Path.GetFileName(imagePath));
    }
}
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** Krypton.Toolkit core components

---

## Known Limitations

- Virtual mode properties are commented out (VirtualMode, VirtualListSize)
- Requires manual handle creation for some theme features
- Item-level theming updates occur on palette changes

---

## See Also

- [KryptonTreeView](KryptonTreeView.md) - Tree view variant
- [KryptonDataGridView](KryptonDataGridView.md) - Data grid variant
- [PaletteTreeState](../Palette/PaletteTreeState.md) - Palette system
- [PaletteBackStyle Enumeration](../Enumerations/PaletteBackStyle.md) - Background styles