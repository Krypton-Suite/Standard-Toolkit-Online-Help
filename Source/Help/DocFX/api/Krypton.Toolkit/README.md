# Krypton.Toolkit

The `Krypton.Toolkit` namespace contains the core controls and utilities that form the foundation of the Krypton Standard Toolkit.

## Overview

`Krypton.Toolkit` provides a comprehensive set of themed WinForms controls that can be customized with various visual styles and palettes. All controls in this namespace inherit from base classes that provide common functionality and theming support.

## Key Components

### Base Classes

- **`VisualControlBase`** - Base class for most Krypton controls
- **`VisualSimpleBase`** - Base class for simple controls like buttons
- **`VisualContainerControl`** - Base class for container controls
- **`VisualControl`** - Base class for basic visual controls

### Basic Controls

#### Input Controls
- **[KryptonButton](KryptonButton.md)** - Themed button control with multiple states
- **[KryptonTextBox](KryptonTextBox.md)** - Single-line text input control
- **[KryptonRichTextBox](KryptonRichTextBox.md)** - Multi-line rich text input control
- **[KryptonMaskedTextBox](KryptonMaskedTextBox.md)** - Text input with format masking
- **[KryptonComboBox](KryptonComboBox.md)** - Dropdown selection control
- **[KryptonDomainUpDown](KryptonDomainUpDown.md)** - Domain up/down control
- **[KryptonNumericUpDown](KryptonNumericUpDown.md)** - Numeric up/down control
- **[KryptonDateTimePicker](KryptonDateTimePicker.md)** - Date and time picker control

#### Selection Controls
- **[KryptonCheckBox](KryptonCheckBox.md)** - Checkbox control
- **[KryptonRadioButton](KryptonRadioButton.md)** - Radio button control
- **[KryptonListBox](KryptonListBox.md)** - List selection control
- **[KryptonCheckedListBox](KryptonCheckedListBox.md)** - Checked list box control
- **[KryptonListView](KryptonListView.md)** - List view control
- **[KryptonTreeView](KryptonTreeView.md)** - Tree view control

#### Display Controls
- **[KryptonLabel](KryptonLabel.md)** - Text label control
- **[KryptonPanel](KryptonPanel.md)** - Container panel control
- **[KryptonGroupBox](KryptonGroupBox.md)** - Group box container
- **[KryptonHeaderGroup](KryptonHeaderGroup.md)** - Header group container
- **[KryptonSeparator](KryptonSeparator.md)** - Visual separator control
- **[KryptonBorderEdge](KryptonBorderEdge.md)** - Border edge control

#### Advanced Controls
- **[KryptonDataGridView](KryptonDataGridView.md)** - Data grid view control
- **[KryptonPropertyGrid](KryptonPropertyGrid.md)** - Property grid control
- **[KryptonProgressBar](KryptonProgressBar.md)** - Progress bar control
- **[KryptonScrollBar](KryptonScrollBar.md)** - Scroll bar control
- **[KryptonToggleSwitch](KryptonToggleSwitch.md)** - Toggle switch control
- **[KryptonColorButton](KryptonColorButton.md)** - Color selection button
- **[KryptonDropButton](KryptonDropButton.md)** - Dropdown button control
- **[KryptonCommandLinkButton](KryptonCommandLinkButton.md)** - Command link button

#### Layout Controls
- **[KryptonSplitContainer](KryptonSplitContainer.md)** - Split container control
- **[KryptonGroup](KryptonGroup.md)** - Group container control

### Utility Components

#### Collections
- **[KryptonControlCollection](KryptonControlCollection.md)** - Collection of Krypton controls
- **[KryptonReadOnlyControls](KryptonReadOnlyControls.md)** - Read-only control collection

#### ToolStrip Integration
- **[KryptonToolStripComboBox](KryptonToolStripComboBox.md)** - ToolStrip combo box
- **[KryptonToolStripThemeComboBox](KryptonToolStripThemeComboBox.md)** - Theme selector for ToolStrip

## Common Features

### Theming Support
All controls in `Krypton.Toolkit` support the global theming system managed by `KryptonManager`. They automatically adapt to theme changes and provide consistent visual styling.

### State Management
Controls support multiple visual states:
- **Normal** - Default appearance
- **Disabled** - When the control is disabled
- **Hot** - When the mouse is over the control
- **Pressed** - When the control is being pressed
- **Checked** - For controls that support checked state
- **Focus** - When the control has keyboard focus

### Palette Integration
Each control integrates with the palette system to provide:
- Consistent color schemes
- Theme-aware styling
- Customizable appearance
- High contrast support

### Enhanced Events
Controls provide enhanced event handling with:
- Typed event arguments
- Additional context information
- State change notifications
- Theme change awareness

## Usage Examples

### Basic Control Setup
```csharp
// Create a themed button
KryptonButton button = new KryptonButton();
button.Text = "Click Me";
button.StateCommon.Content.ShortText.Color1 = Color.Blue;

// Create a themed text box
KryptonTextBox textBox = new KryptonTextBox();
textBox.StateCommon.Back.Color1 = Color.White;
textBox.StateCommon.Border.Color1 = Color.Gray;
```

### Theme Integration
```csharp
// The controls automatically use the global theme
KryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;

// All Krypton controls will automatically update their appearance
```

### Custom Styling
```csharp
// Customize individual control appearance
KryptonButton customButton = new KryptonButton();
customButton.StateCommon.Back.Color1 = Color.Red;
customButton.StateCommon.Content.ShortText.Color1 = Color.White;
customButton.StateCommon.Border.Color1 = Color.DarkRed;
```

## Design-Time Support

All controls include comprehensive design-time support:
- Visual Studio toolbox integration
- Property grid customization
- Designer serialization
- Smart tag support
- Custom designers

## Performance Considerations

- Controls are optimized for performance with minimal overhead
- Theme changes are efficiently propagated to all controls
- Memory usage is optimized through shared palette instances
- Rendering is hardware-accelerated where possible

## Related Namespaces

- `Krypton.Ribbon` - Ribbon interface components
- `Krypton.Navigator` - Navigation and tab controls
- `Krypton.Workspace` - Workspace and layout management
- `Krypton.Docking` - Docking framework

## Version Compatibility

The controls in `Krypton.Toolkit` are compatible with:
- .NET Framework 4.7.2+
- .NET 6.0 Windows+
- .NET 7.0 Windows+
- .NET 8.0 Windows+
- .NET 9.0 Windows+
- .NET 10.0 Windows+
