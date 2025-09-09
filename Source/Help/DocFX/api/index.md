# Krypton Toolkit API Documentation

Welcome to the comprehensive API documentation for the Krypton Toolkit Suite. This documentation covers all major components across the five core libraries.

## Overview

The Krypton Toolkit Suite is a comprehensive set of themed controls for Windows Forms applications, providing a modern, professional appearance with extensive customization capabilities. The suite consists of five main libraries:

- **Krypton.Toolkit** - Core controls and theming system
- **Krypton.Ribbon** - Office-style ribbon interface
- **Krypton.Navigator** - Multi-page navigation system
- **Krypton.Workspace** - Layout and workspace management
- **Krypton.Docking** - Advanced docking system

## Quick Navigation

### Core Components (Krypton.Toolkit)

#### Forms and Management
- [KryptonForm](Krypton.Toolkit/KryptonForm.md) - Themed form with custom window chrome
- [KryptonManager](Krypton.Toolkit/KryptonManager.md) - Global theme management and settings

#### Input Controls
- [KryptonTextBox](Krypton.Toolkit/KryptonTextBox.md) - Themed text input control
- [KryptonButton](Krypton.Toolkit/KryptonButton.md) - Themed button control

#### Additional Controls
- `KryptonRichTextBox` - Rich text editing control
- `KryptonMaskedTextBox` - Text input with format masking
- `KryptonComboBox` - Dropdown selection control
- `KryptonListBox` - List selection control
- `KryptonListView` - List view control
- `KryptonTreeView` - Tree view control
- `KryptonDataGridView` - Data grid view control
- `KryptonDateTimePicker` - Date and time picker
- `KryptonNumericUpDown` - Numeric input control
- `KryptonProgressBar` - Progress indicator
- `KryptonTrackBar` - Slider control
- `KryptonCheckBox` - Check box control
- `KryptonRadioButton` - Radio button control
- `KryptonLabel` - Label control
- `KryptonLinkLabel` - Link label control
- `KryptonPanel` - Panel container
- `KryptonGroupBox` - Group box container
- `KryptonSplitContainer` - Split container
- `KryptonScrollBar` - Scroll bar control
- `KryptonSeparator` - Separator control
- `KryptonHeader` - Header control
- `KryptonHeaderGroup` - Header group control
- `KryptonMonthCalendar` - Month calendar control
- `KryptonPictureBox` - Picture box control
- `KryptonPropertyGrid` - Property grid control
- `KryptonMessageBox` - Message box dialog
- `KryptonInputBox` - Input box dialog
- `KryptonColorDialog` - Color selection dialog
- `KryptonFontDialog` - Font selection dialog
- `KryptonOpenFileDialog` - File open dialog
- `KryptonSaveFileDialog` - File save dialog
- `KryptonFolderBrowserDialog` - Folder browser dialog
- `KryptonPrintDialog` - Print dialog
- `KryptonPageSetupDialog` - Page setup dialog
- `KryptonPrintPreviewDialog` - Print preview dialog

### Ribbon Interface (Krypton.Ribbon)

#### Core Ribbon Components
- [KryptonRibbon](Krypton.Ribbon/KryptonRibbon.md) - Main ribbon control
- `KryptonRibbonTab` - Individual ribbon tab
- `KryptonRibbonGroup` - Group of controls within a tab
- `KryptonRibbonContext` - Contextual tab collection
- `KryptonRibbonQATButton` - Quick access toolbar button
- `KryptonRibbonRecentDoc` - Recent document item
- `KryptonGallery` - Gallery control for ribbon

#### Ribbon Controls
- `KryptonRibbonGroupButton` - Button in ribbon group
- `KryptonRibbonGroupCheckBox` - Check box in ribbon group
- `KryptonRibbonGroupComboBox` - Combo box in ribbon group
- `KryptonRibbonGroupDateTimePicker` - Date/time picker in ribbon group
- `KryptonRibbonGroupDomainUpDown` - Domain up/down in ribbon group
- `KryptonRibbonGroupLabel` - Label in ribbon group
- `KryptonRibbonGroupMaskedTextBox` - Masked text box in ribbon group
- `KryptonRibbonGroupNumericUpDown` - Numeric up/down in ribbon group
- `KryptonRibbonGroupRadioButton` - Radio button in ribbon group
- `KryptonRibbonGroupRichTextBox` - Rich text box in ribbon group
- `KryptonRibbonGroupSeparator` - Separator in ribbon group
- `KryptonRibbonGroupTextBox` - Text box in ribbon group
- `KryptonRibbonGroupTrackBar` - Track bar in ribbon group

### Navigation System (Krypton.Navigator)

#### Core Navigation Components
- [KryptonNavigator](Krypton.Navigator/KryptonNavigator.md) - Main navigation control
- `KryptonPage` - Individual navigator page
- `KryptonPageCollection` - Collection of navigator pages

#### Navigation Modes
- **BarTabGroup** - Standard tab bar with group support
- **BarTabOnly** - Simple tab bar without grouping
- **BarRibbonTab** - Ribbon-style tab bar
- **BarRibbonAppButton** - Ribbon with application button
- **BarCheckButtonGroup** - Check button group style
- **BarOutlookFull** - Full Outlook-style navigation
- **BarOutlookMini** - Mini Outlook-style navigation
- **BarOutlookPopup** - Popup Outlook-style navigation
- **BarHeaderGroup** - Header group style
- **BarHeaderOnly** - Header-only style
- **BarHeaderForm** - Header form style
- **StackHeaderGroup** - Stacked header group
- **StackHeaderOnly** - Stacked header only
- **ButtonSpecOnly** - Button specification only
- **Panel** - Panel mode
- **Group** - Group mode

### Workspace Management (Krypton.Workspace)

#### Core Workspace Components
- [KryptonWorkspace](Krypton.Workspace/KryptonWorkspace.md) - Main workspace control
- `KryptonWorkspaceSequence` - Workspace sequence for layout organization
- `KryptonWorkspaceCell` - Individual workspace cell
- `KryptonWorkspaceCollection` - Collection of workspace items

#### Workspace Features
- **Flexible Layout System** - Hierarchical layout of navigator instances
- **Docking Support** - Full docking capabilities for panels
- **Resizable Panels** - Adjustable panel sizes with splitters
- **Workspace Persistence** - Save and restore workspace layouts
- **Maximized Mode** - Support for maximized panels
- **Context Menus** - Built-in context menu support
- **Drag and Drop** - Full drag-and-drop support for panel management

### Docking System (Krypton.Docking)

#### Core Docking Components
- [KryptonDocking](Krypton.Docking/KryptonDocking.md) - Main docking system documentation
- `KryptonDockspace` - Main docking space
- `KryptonFloatspace` - Floating docking space
- `KryptonAutoHiddenPanel` - Auto-hidden panel
- `KryptonFloatingWindow` - Floating window
- `KryptonDockableNavigator` - Dockable navigator
- `KryptonDockableWorkspace` - Dockable workspace
- `KryptonAutoHiddenGroup` - Auto-hidden group
- `KryptonAutoHiddenSlidePanel` - Auto-hidden slide panel

#### Docking Features
- **Advanced Docking** - Full docking capabilities with drag-and-drop support
- **Floating Windows** - Support for floating dockable panels
- **Auto-Hide Panels** - Panels that can be auto-hidden and shown on demand
- **Layout Persistence** - Save and restore docking layouts
- **Multiple Docking Areas** - Support for multiple docking spaces

## Getting Started

### Basic Setup
```csharp
// Set global theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// Create themed form
KryptonForm form = new KryptonForm();
form.Text = "My Themed Application";
form.Size = new Size(800, 600);
form.Show();
```

### Adding Controls
```csharp
// Add themed controls
KryptonTextBox textBox = new KryptonTextBox();
textBox.Text = "Themed text box";

KryptonButton button = new KryptonButton();
button.Text = "Themed button";
button.Click += (sender, e) => MessageBox.Show("Button clicked!");

form.Controls.Add(textBox);
form.Controls.Add(button);
```

### Creating a Ribbon Interface
```csharp
// Create ribbon
KryptonRibbon ribbon = new KryptonRibbon();
ribbon.Dock = DockStyle.Top;

// Add tabs and groups
KryptonRibbonTab homeTab = new KryptonRibbonTab();
homeTab.Text = "Home";
ribbon.RibbonTabs.Add(homeTab);

KryptonRibbonGroup clipboardGroup = new KryptonRibbonGroup();
clipboardGroup.Text = "Clipboard";
homeTab.RibbonGroups.Add(clipboardGroup);

form.Controls.Add(ribbon);
```

### Creating a Navigation Interface
```csharp
// Create navigator
KryptonNavigator navigator = new KryptonNavigator();
navigator.Dock = DockStyle.Fill;
navigator.Mode = NavigatorMode.BarTabGroup;

// Add pages
KryptonPage page1 = new KryptonPage();
page1.Text = "Page 1";
navigator.Pages.Add(page1);

form.Controls.Add(navigator);
```

### Creating a Workspace Layout
```csharp
// Create workspace
KryptonWorkspace workspace = new KryptonWorkspace();
workspace.Dock = DockStyle.Fill;

// Create layout
KryptonWorkspaceSequence rootSequence = new KryptonWorkspaceSequence(Orientation.Horizontal);
KryptonWorkspaceCell leftCell = new KryptonWorkspaceCell();
KryptonWorkspaceCell rightCell = new KryptonWorkspaceCell();

rootSequence.Children.Add(leftCell);
rootSequence.Children.Add(rightCell);
workspace.Root = rootSequence;

form.Controls.Add(workspace);
```

## Theme System

### Available Themes

#### Office 2007 Themes
- `PaletteMode.Office2007Blue` - Office 2007 Blue theme
- `PaletteMode.Office2007Silver` - Office 2007 Silver theme
- `PaletteMode.Office2007Black` - Office 2007 Black theme
- `PaletteMode.Office2007DarkGray` - Office 2007 Dark Gray theme

#### Office 2010 Themes
- `PaletteMode.Office2010Blue` - Office 2010 Blue theme
- `PaletteMode.Office2010Silver` - Office 2010 Silver theme
- `PaletteMode.Office2010Black` - Office 2010 Black theme
- `PaletteMode.Office2010DarkGray` - Office 2010 Dark Gray theme

#### Office 2013 Themes
- `PaletteMode.Office2013White` - Office 2013 White theme
- `PaletteMode.Office2013LightGray` - Office 2013 Light Gray theme
- `PaletteMode.Office2013DarkGray` - Office 2013 Dark Gray theme

#### Sparkle Themes
- `PaletteMode.SparkleBlue` - Sparkle Blue theme
- `PaletteMode.SparkleOrange` - Sparkle Orange theme
- `PaletteMode.SparklePurple` - Sparkle Purple theme

#### Microsoft 365 Themes
- `PaletteMode.Microsoft365Blue` - Microsoft 365 Blue theme
- `PaletteMode.Microsoft365Black` - Microsoft 365 Black theme
- `PaletteMode.Microsoft365DarkGray` - Microsoft 365 Dark Gray theme

### Theme Switching
```csharp
// Switch themes at runtime
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010BlackDarkMode;

// Or use a custom palette
CustomPalette customPalette = new CustomPalette();
KryptonManager.GlobalPalette = customPalette;
```

## Design-Time Support

All Krypton controls include comprehensive design-time support:

- **Visual Studio Integration** - Full integration with Visual Studio designers
- **Property Grid Support** - Complete property grid integration with categorized properties
- **Smart Tags** - Quick access to common properties and actions
- **Designer Serialization** - Proper serialization of all properties
- **Toolbox Integration** - Available in the Visual Studio toolbox
- **Context Menus** - Right-click context menus for control operations

## Accessibility

The Krypton Toolkit provides full accessibility support:

- **Screen Reader Support** - Properly announces control state and content
- **Keyboard Navigation** - Full keyboard navigation support
- **Focus Management** - Proper focus handling and indicators
- **High Contrast** - Support for high contrast themes
- **Accessibility Properties** - Proper accessibility properties and descriptions

## Performance Considerations

- **Optimized Rendering** - Efficient rendering with minimal overhead
- **Theme Caching** - Themes are cached as singleton instances
- **Memory Optimization** - Shared palette instances for optimal memory usage
- **Efficient Updates** - Theme changes are efficiently propagated
- **Layout Optimization** - Optimized layout calculations and updates

## Best Practices

1. **Initialize Early** - Set the global palette mode early in application startup
2. **Use Consistent Themes** - Maintain theme consistency across the application
3. **Handle Theme Changes** - Subscribe to theme change events for theme-dependent updates
4. **Custom Palettes** - Implement custom palettes for specialized requirements
5. **Performance** - Avoid frequent theme switching in performance-critical scenarios
6. **Accessibility** - Ensure proper accessibility support for all controls
7. **Design-Time** - Leverage design-time support for rapid development

## Related Resources

- [Krypton Toolkit GitHub Repository](https://github.com/Krypton-Suite/Standard-Toolkit)
- [Documentation](https://github.com/Krypton-Suite/Standard-Toolkit/wiki)
- [Examples and Samples](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/Source/Krypton%20Components/TestForm)
- [Community Support](https://github.com/Krypton-Suite/Standard-Toolkit/discussions)
- Looking for the API reference? Please visit this [link](https://github.com/Krypton-Suite/Help-Files/releases) for the latest version of the documentation.

## License

The Krypton Toolkit Suite is licensed under the BSD 3-Clause License. See the [LICENSE](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/LICENSE) file for details.
