# KryptonNavigator

The `KryptonNavigator` class is a versatile navigation control that provides multiple methods for moving between a collection of pages, supporting various display modes and navigation styles.

## Overview

`KryptonNavigator` is a sophisticated navigation control that can display pages in different modes such as tabs, buttons, headers, or custom layouts. It provides a flexible framework for creating multi-page interfaces with support for drag-and-drop, context menus, and various navigation styles.

## Namespace

```csharp
Krypton.Navigator
```

## Inheritance

```csharp
public class KryptonNavigator : VisualSimple, IDragTargetProvider
```

## Key Features

- **Multiple Display Modes**: Support for tabs, buttons, headers, and custom layouts
- **Page Management**: Comprehensive page collection and selection management
- **Drag and Drop**: Full drag-and-drop support for page reordering
- **Context Menus**: Built-in context menu support
- **Themed Appearance**: Full Krypton theme integration
- **Keyboard Navigation**: Complete keyboard accessibility support
- **Design-Time Support**: Full Visual Studio designer integration
- **Performance Optimization**: Efficient page caching and rendering

## Properties

### Navigation Mode

#### Mode
```csharp
[Category("Navigator")]
[Description("Gets and sets the navigator mode.")]
[DefaultValue(NavigatorMode.BarTabGroup)]
public NavigatorMode Mode { get; set; }
```

Gets and sets the navigation mode that determines how pages are displayed.

**Default Value**: `NavigatorMode.BarTabGroup`

### Page Management

#### Pages
```csharp
[Category("Navigator")]
[Description("Collection of navigator pages.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public KryptonPageCollection Pages { get; }
```

Gets access to the collection of navigator pages.

#### SelectedPage
```csharp
[Category("Navigator")]
[Description("Gets and sets the selected page.")]
[DefaultValue(null)]
public KryptonPage SelectedPage { get; set; }
```

Gets and sets the currently selected page.

**Default Value**: `null`

#### SelectedIndex
```csharp
[Category("Navigator")]
[Description("Gets and sets the selected page index.")]
[DefaultValue(-1)]
public int SelectedIndex { get; set; }
```

Gets and sets the index of the currently selected page.

**Default Value**: `-1`

### Behavior Settings

#### AllowTabFocus
```csharp
[Category("Behavior")]
[Description("Gets and sets if tabs can receive focus.")]
[DefaultValue(true)]
public bool AllowTabFocus { get; set; }
```

Gets and sets whether tabs can receive keyboard focus.

**Default Value**: `true`

#### AllowTabSelect
```csharp
[Category("Behavior")]
[Description("Gets and sets if tabs can be selected.")]
[DefaultValue(true)]
public bool AllowTabSelect { get; set; }
```

Gets and sets whether tabs can be selected.

**Default Value**: `true`

#### ControlKryptonFormFeatures
```csharp
[Category("Behavior")]
[Description("Gets and sets if KryptonForm features are controlled.")]
[DefaultValue(false)]
public bool ControlKryptonFormFeatures { get; set; }
```

Gets and sets whether the navigator controls KryptonForm features.

**Default Value**: `false`

### Appearance

#### PageBackStyle
```csharp
[Category("Visuals")]
[Description("Gets and sets the page background style.")]
[DefaultValue(PaletteBackStyle.PanelClient)]
public PaletteBackStyle PageBackStyle { get; set; }
```

Gets and sets the background style for pages.

**Default Value**: `PaletteBackStyle.PanelClient`

### Button Specifications

#### ButtonSpecs
```csharp
[Category("Visuals")]
[Description("Collection of button specifications.")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public NavigatorButtonSpecCollection ButtonSpecs { get; }
```

Gets access to the collection of button specifications for the navigator.

## Events

### SelectedPageChanged
```csharp
[Category("Navigator Selection")]
[Description("Occurs when the SelectedPage property is changed.")]
public event EventHandler SelectedPageChanged;
```

Occurs when the selected page changes.

### Selecting
```csharp
[Category("Navigator Selection")]
[Description("Occurs before a page is selected.")]
public event EventHandler<KryptonPageCancelEventArgs> Selecting;
```

Occurs before a page is selected. Can be cancelled.

### Selected
```csharp
[Category("Navigator Selection")]
[Description("Occurs after a page is selected.")]
public event EventHandler<KryptonPageEventArgs> Selected;
```

Occurs after a page is selected.

### Deselecting
```csharp
[Category("Navigator Selection")]
[Description("Occurs before a page is deselected.")]
public event EventHandler<KryptonPageCancelEventArgs> Deselecting;
```

Occurs before a page is deselected. Can be cancelled.

### Deselected
```csharp
[Category("Navigator Selection")]
[Description("Occurs after a page is deselected.")]
public event EventHandler<KryptonPageEventArgs> Deselected;
```

Occurs after a page is deselected.

### PreviousAction
```csharp
[Category("Navigator")]
[Description("Occurs when the previous action occurs.")]
public event EventHandler PreviousAction;
```

Occurs when the previous action is triggered.

### NextAction
```csharp
[Category("Navigator")]
[Description("Occurs when the next action occurs.")]
public event EventHandler NextAction;
```

Occurs when the next action is triggered.

### CloseAction
```csharp
[Category("Navigator")]
[Description("Occurs when the close action occurs.")]
public event EventHandler<KryptonPageEventArgs> CloseAction;
```

Occurs when the close action is triggered.

### ContextAction
```csharp
[Category("Navigator")]
[Description("Occurs when the context action occurs.")]
public event EventHandler<KryptonPageEventArgs> ContextAction;
```

Occurs when the context action is triggered.

### ButtonSpecClick
```csharp
[Category("Action")]
[Description("Occurs when a button specification is clicked.")]
public event EventHandler<ButtonSpecClickEventArgs> ButtonSpecClick;
```

Occurs when a button specification is clicked.

## Methods

### SelectPage(KryptonPage page)
```csharp
public void SelectPage(KryptonPage page)
```

Selects the specified page.

### SelectPage(int index)
```csharp
public void SelectPage(int index)
```

Selects the page at the specified index.

### SelectNextPage()
```csharp
public void SelectNextPage()
```

Selects the next page in the collection.

### SelectPreviousPage()
```csharp
public void SelectPreviousPage()
```

Selects the previous page in the collection.

### ClosePage(KryptonPage page)
```csharp
public void ClosePage(KryptonPage page)
```

Closes the specified page.

### ClosePage(int index)
```csharp
public void ClosePage(int index)
```

Closes the page at the specified index.

### ShowContextMenu(Point screenPoint)
```csharp
public void ShowContextMenu(Point screenPoint)
```

Shows the context menu at the specified screen point.

### ShowContextMenu(KryptonPage page, Point screenPoint)
```csharp
public void ShowContextMenu(KryptonPage page, Point screenPoint)
```

Shows the context menu for the specified page at the specified screen point.

## Available Navigator Modes

### BarTabGroup
- **Description**: Standard tab bar with group support
- **Use Case**: Traditional tabbed interface with grouping

### BarTabOnly
- **Description**: Simple tab bar without grouping
- **Use Case**: Basic tabbed interface

### BarRibbonTab
- **Description**: Ribbon-style tab bar
- **Use Case**: Office-style ribbon interface

### BarRibbonAppButton
- **Description**: Ribbon with application button
- **Use Case**: Office-style ribbon with app menu

### BarCheckButtonGroup
- **Description**: Check button group style
- **Use Case**: Radio button-style navigation

### BarCheckButtonGroupOnly
- **Description**: Check button group without header
- **Use Case**: Simple radio button navigation

### BarOutlookFull
- **Description**: Full Outlook-style navigation
- **Use Case**: Outlook-style interface

### BarOutlookMini
- **Description**: Mini Outlook-style navigation
- **Use Case**: Compact Outlook-style interface

### BarOutlookPopup
- **Description**: Popup Outlook-style navigation
- **Use Case**: Dropdown Outlook-style interface

### BarHeaderGroup
- **Description**: Header group style
- **Use Case**: Header-based navigation

### BarHeaderOnly
- **Description**: Header-only style
- **Use Case**: Simple header navigation

### BarHeaderForm
- **Description**: Header form style
- **Use Case**: Form-based header navigation

### BarHeaderFormInTitle
- **Description**: Header form in title style
- **Use Case**: Title bar header navigation

### BarHeaderCustom1
- **Description**: Custom header style 1
- **Use Case**: Custom header navigation

### BarHeaderCustom2
- **Description**: Custom header style 2
- **Use Case**: Custom header navigation

### BarHeaderCustom3
- **Description**: Custom header style 3
- **Use Case**: Custom header navigation

### StackHeaderGroup
- **Description**: Stacked header group
- **Use Case**: Vertical header navigation

### StackHeaderOnly
- **Description**: Stacked header only
- **Use Case**: Vertical header navigation

### StackHeaderForm
- **Description**: Stacked header form
- **Use Case**: Vertical form header navigation

### StackHeaderFormInTitle
- **Description**: Stacked header form in title
- **Use Case**: Vertical title bar header navigation

### StackHeaderCustom1
- **Description**: Custom stacked header 1
- **Use Case**: Custom vertical header navigation

### StackHeaderCustom2
- **Description**: Custom stacked header 2
- **Use Case**: Custom vertical header navigation

### StackHeaderCustom3
- **Description**: Custom stacked header 3
- **Use Case**: Custom vertical header navigation

### ButtonSpecOnly
- **Description**: Button specification only
- **Use Case**: Button-based navigation

### ButtonSpecForm
- **Description**: Button specification form
- **Use Case**: Form-based button navigation

### ButtonSpecFormInTitle
- **Description**: Button specification form in title
- **Use Case**: Title bar button navigation

### ButtonSpecCustom1
- **Description**: Custom button specification 1
- **Use Case**: Custom button navigation

### ButtonSpecCustom2
- **Description**: Custom button specification 2
- **Use Case**: Custom button navigation

### ButtonSpecCustom3
- **Description**: Custom button specification 3
- **Use Case**: Custom button navigation

### Panel
- **Description**: Panel mode
- **Use Case**: Panel-based navigation

### Group
- **Description**: Group mode
- **Use Case**: Group-based navigation

## Usage Examples

### Basic Navigator Setup
```csharp
// Create a basic navigator
KryptonNavigator navigator = new KryptonNavigator();
navigator.Dock = DockStyle.Fill;

// Set the navigation mode
navigator.Mode = NavigatorMode.BarTabGroup;

// Add pages
KryptonPage page1 = new KryptonPage();
page1.Text = "Page 1";
page1.TextTitle = "First Page";
navigator.Pages.Add(page1);

KryptonPage page2 = new KryptonPage();
page2.Text = "Page 2";
page2.TextTitle = "Second Page";
navigator.Pages.Add(page2);
```

### Tab-Style Navigation
```csharp
// Configure for tab-style navigation
navigator.Mode = NavigatorMode.BarTabOnly;
navigator.AllowTabFocus = true;
navigator.AllowTabSelect = true;

// Handle page selection
navigator.SelectedPageChanged += (sender, e) =>
{
    Console.WriteLine($"Selected page: {navigator.SelectedPage?.Text}");
};
```

### Outlook-Style Navigation
```csharp
// Configure for Outlook-style navigation
navigator.Mode = NavigatorMode.BarOutlookFull;

// Add Outlook-style pages
KryptonPage mailPage = new KryptonPage();
mailPage.Text = "Mail";
mailPage.ImageSmall = Properties.Resources.mail_16;
navigator.Pages.Add(mailPage);

KryptonPage calendarPage = new KryptonPage();
calendarPage.Text = "Calendar";
calendarPage.ImageSmall = Properties.Resources.calendar_16;
navigator.Pages.Add(calendarPage);
```

### Header-Style Navigation
```csharp
// Configure for header-style navigation
navigator.Mode = NavigatorMode.BarHeaderGroup;

// Add header-style pages
KryptonPage headerPage1 = new KryptonPage();
headerPage1.Text = "Header 1";
headerPage1.TextDescription = "First header section";
navigator.Pages.Add(headerPage1);

KryptonPage headerPage2 = new KryptonPage();
headerPage2.Text = "Header 2";
headerPage2.TextDescription = "Second header section";
navigator.Pages.Add(headerPage2);
```

### Programmatic Navigation
```csharp
// Navigate programmatically
navigator.SelectNextPage();
navigator.SelectPreviousPage();

// Select specific page
if (navigator.Pages.Count > 0)
{
    navigator.SelectPage(0);
}

// Close pages
navigator.ClosePage(navigator.SelectedPage);
```

### Event Handling
```csharp
// Handle selection events
navigator.Selecting += (sender, e) =>
{
    // Can cancel selection
    if (e.Page.Text == "Restricted")
    {
        e.Cancel = true;
    }
};

navigator.Selected += (sender, e) =>
{
    Console.WriteLine($"Page selected: {e.Page.Text}");
};

// Handle close events
navigator.CloseAction += (sender, e) =>
{
    Console.WriteLine($"Closing page: {e.Page.Text}");
};
```

### Custom Button Specifications
```csharp
// Add custom buttons to the navigator
ButtonSpecAny customButton = new ButtonSpecAny();
customButton.Type = PaletteButtonSpecStyle.PendantClose;
customButton.Text = "Custom";
customButton.Click += (sender, e) => MessageBox.Show("Custom button clicked!");
navigator.ButtonSpecs.Add(customButton);
```

### Context Menu Support
```csharp
// Show context menu
navigator.ContextAction += (sender, e) =>
{
    Point screenPoint = Control.MousePosition;
    navigator.ShowContextMenu(e.Page, screenPoint);
};
```

## Design-Time Support

The `KryptonNavigator` control includes comprehensive design-time support:

- **Navigator Designer**: Specialized designer for navigator layout
- **Property Grid**: Full property grid integration
- **Smart Tags**: Quick access to common navigator properties
- **Designer Serialization**: Proper serialization of all properties
- **Toolbox Integration**: Available in the Visual Studio toolbox
- **Context Menu**: Right-click context menu for navigator operations

## Accessibility

The control provides full accessibility support:

- **Screen Reader Support**: Properly announces navigator structure and state
- **Keyboard Navigation**: Full keyboard navigation with arrow keys and Tab
- **Focus Management**: Proper focus handling and indicators
- **High Contrast**: Support for high contrast themes
- **Page Announcements**: Proper announcement of page changes

## Performance Considerations

- The navigator is optimized for performance with efficient page caching
- Theme changes are efficiently propagated
- Memory usage is optimized through shared palette instances
- Page switching and mode changes are optimized
- Drag-and-drop operations are optimized for smooth performance

## Related Components

- `KryptonPage` - Individual navigator page
- `KryptonPageCollection` - Collection of navigator pages
- `NavigatorMode` - Navigation mode enumeration
- `ButtonSpecAny` - Button specification for custom buttons
- `KryptonPageEventArgs` - Page event arguments
- `KryptonPageCancelEventArgs` - Page cancel event arguments
