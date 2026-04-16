# KryptonTaskDialog Documentation

Complete documentation suite for the KryptonTaskDialog component.

## Overview

KryptonTaskDialog is a modern, flexible dialog component for the Krypton Toolkit that provides a composable approach to building dialogs through individual, configurable elements. Unlike traditional dialog systems, KryptonTaskDialog allows you to construct complex dialogs by showing/hiding and configuring only the elements you need.

### Key Features

✨ **Modular Design** - Build dialogs using independent, composable elements  
🎨 **Full Theme Integration** - Seamlessly integrates with Krypton's theming engine  
🔄 **Reusable Forms** - Show the same dialog instance multiple times  
📐 **Auto-Sizing** - Dialog height adjusts automatically based on visible elements  
🎯 **Rich Content** - Support for text, images, icons, buttons, controls, and custom layouts  
⚡ **Modal & Modeless** - Support for both blocking and non-blocking dialogs  

---

## Documentation Structure

### 📘 [Developer Documentation](KryptonTaskDialogDeveloperOverView.md)

#### Comprehensive guide for developers

Complete documentation covering:

- Overview and key features
- Architecture and design philosophy
- Getting started guide
- Core components and their properties
- All dialog elements with detailed explanations
- API reference
- Extensive usage examples
- Advanced features
- Theming and customization
- Best practices and patterns
- Troubleshooting guide
- Performance considerations
- Migration guide from other dialog systems

**Best for:** Learning the component from scratch, understanding all features

**Size:** ~150 pages

---

### ⚡ [Quick Reference Guide](KryptonTaskDialogQuickReference.md)

#### Fast lookup and cheat sheet

Quick reference including:

- Quick start example
- Core concepts summary
- All element properties at a glance
- Common patterns (confirmations, progress dialogs, input dialogs)
- Theming quick reference
- Best practices checklist
- Common mistakes to avoid
- Handy cheat sheets

**Best for:** Quick lookups when you already know the basics

**Size:** ~20 pages

---

### 🏗️ [Technical Architecture](KryptonTaskDialogArchitecture.md)

#### Internal implementation details

Technical documentation covering:

- Class hierarchy and inheritance
- Design patterns used (Composite, Template Method, Observer, etc.)
- Component implementation details
- Layout system mechanics
- Event flow diagrams
- Theme integration internals
- Memory management and disposal patterns
- Guide to extending the component
- Performance optimization details

**Best for:** Understanding internals, extending the component, debugging

**Size:** ~50 pages

---

### 📖 [Complete API Reference](KryptonTaskDialogAPIReference.md)

#### Exhaustive API documentation

Complete API reference including:

- All classes with inheritance chains
- All properties with types and descriptions
- All methods with signatures and parameters
- All events with signatures
- All enums with values
- Code examples for each member
- Complete working example at the end

**Best for:** Detailed API lookup, IntelliSense-style reference

**Size:** ~40 pages

---

## Quick Navigation

### By Task

**I want to...**

- **Create my first dialog** → [Developer Documentation - Getting Started](KryptonTaskDialogDeveloperOverView.md#getting-started)
- **Find a specific property** → [API Reference](KryptonTaskDialogAPIReference.md)
- **See usage examples** → [Developer Documentation - Usage Examples](KryptonTaskDialogDeveloperOverView.md#usage-examples)
- **Quickly look up syntax** → [Quick Reference Guide](KryptonTaskDialogQuickReference.md)
- **Understand how it works internally** → [Technical Architecture](KryptonTaskDialogArchitecture.md)
- **Extend the component** → [Technical Architecture - Extending](KryptonTaskDialogArchitecture.md#extending-the-component)
- **Troubleshoot an issue** → [Developer Documentation - Troubleshooting](KryptonTaskDialogDeveloperOverView.md#troubleshooting)
- **Improve performance** → [Technical Architecture - Performance](KryptonTaskDialogArchitecture.md#performance-considerations)
- **Migrate from MessageBox** → [Developer Documentation - Migration Guide](KryptonTaskDialogDeveloperOverView.md#migration-guide)

### By Element

All elements are documented in detail in the [Developer Documentation - Dialog Elements](KryptonTaskDialogDeveloperOverView.md#dialog-elements) section:

1. **Heading** - Title and icon
2. **Content** - Main text with optional image
3. **Expander** - Expandable detail section
4. **RichTextBox** - Formatted text input/display
5. **FreeWheeler1** - FlowLayoutPanel for custom controls
6. **FreeWheeler2** - TableLayoutPanel for custom controls
7. **CommandLinkButtons** - Command-style button collection
8. **CheckBox** - Checkbox for user input
9. **ComboBox** - Dropdown selection
10. **HyperLink** - Clickable hyperlink
11. **ProgressBar** - Progress indicator
12. **FooterBar** - Common buttons and footer notes

---

## Getting Started in 5 Minutes

### 1. Basic Dialog

```csharp
using (KryptonTaskDialog taskDialog = new KryptonTaskDialog())
{
    taskDialog.Dialog.Form.Text = "My Dialog";
    taskDialog.Heading.Text = "Hello World";
    taskDialog.Content.Text = "This is a simple dialog.";
    taskDialog.FooterBar.CommonButtons.Buttons = KryptonTaskDialogCommonButtonTypes.OK;
    
    taskDialog.ShowDialog();
}
```

### 2. Confirmation Dialog

```csharp
using (var dlg = new KryptonTaskDialog())
{
    dlg.Dialog.Form.Text = "Confirm";
    dlg.Heading.Visible = true;
    dlg.Heading.Text = "Delete File?";
    dlg.Heading.IconType = KryptonTaskDialogIconType.ShieldWarning;
    dlg.Content.Visible = true;
    dlg.Content.Text = "This action cannot be undone.";
    dlg.FooterBar.CommonButtons.Buttons = 
        KryptonTaskDialogCommonButtonTypes.Yes | 
        KryptonTaskDialogCommonButtonTypes.No;
    
    return dlg.ShowDialog() == DialogResult.Yes;
}
```

### 3. Progress Dialog

```csharp
var dlg = new KryptonTaskDialog();
dlg.Dialog.Form.Text = "Processing";
dlg.Heading.Visible = true;
dlg.Heading.Text = "Please Wait";
dlg.ProgresBar.Visible = true;
dlg.ProgresBar.ProgressBar.Maximum = 100;

dlg.Show(this);

// Update in loop or from background thread
dlg.ProgresBar.ProgressBar.Value = 50;

dlg.CloseDialog();
dlg.Dispose();
```

**👉 For more examples, see [Developer Documentation - Usage Examples](KryptonTaskDialogDeveloperOverView.md#usage-examples)**

---

## Common Use Cases

### User Interactions

- ✅ Confirmation dialogs (Yes/No/Cancel)
- ℹ️ Information messages with detailed content
- ⚠️ Warning dialogs with expandable details
- ❌ Error dialogs with exception details
- 📝 Input dialogs with text boxes, combo boxes, etc.
- 🔗 Command selection using command link buttons

### Progress & Status

- ⏳ Progress indicators for long operations
- 📊 Status updates during processing
- 🔄 Multi-step wizard-like flows
- ⚙️ Settings/configuration dialogs

### Advanced Scenarios

- 🎛️ Custom control layouts using FreeWheeler
- 📄 Rich text display and editing
- 🌐 Hyperlink navigation
- ☑️ Checkbox agreements (e.g., "Don't show again")
- 🎨 Fully themed dialogs matching application style

---

## Design Philosophy

KryptonTaskDialog follows these design principles:

1. **Composition over Configuration** - Build dialogs by composing elements rather than passing configuration objects
2. **Progressive Disclosure** - Show only what's needed, hide everything else
3. **Reusability** - Single dialog instance can be shown multiple times
4. **Theme Integration** - Automatic synchronization with Krypton themes
5. **Lazy Evaluation** - Layout calculations deferred until needed
6. **Type Safety** - Strongly-typed API with IntelliSense support

---

## Requirements

- **.NET Framework:** 4.7.2 or higher
- **.NET:** 8.0, 9.0, or 10.0 (Windows)
- **Krypton Toolkit:** v100.x.x or higher
- **Platform:** Windows

---

## Element Overview

### Visual Layout (Top to Bottom)

```text
┌────────────────────────────────────┐
│  Heading (Icon + Title)            │
├────────────────────────────────────┤
│  Content (Text + Optional Image)   │
├────────────────────────────────────┤
│  Expander (Expandable Details)     │  ← Toggled by FooterBar
├────────────────────────────────────┤
│  RichTextBox                        │
├────────────────────────────────────┤
│  FreeWheeler1 (FlowLayoutPanel)    │
├────────────────────────────────────┤
│  FreeWheeler2 (TableLayoutPanel)   │
├────────────────────────────────────┤
│  CommandLinkButtons                 │
├────────────────────────────────────┤
│  CheckBox                           │
├────────────────────────────────────┤
│  ComboBox                           │
├────────────────────────────────────┤
│  HyperLink                          │
├────────────────────────────────────┤
│  ProgressBar                        │
├────────────────────────────────────┤
│  FooterBar (Buttons + Notes)       │
└────────────────────────────────────┘
```

**All elements are optional and can be shown/hidden independently.**

---

## Best Practices Summary

### ✅ Do

- Always dispose dialogs using `using` statements
- Use modal (`ShowDialog`) for decisions requiring immediate input
- Use modeless (`Show`) for progress indicators and status updates
- Set `AcceptButton` and `CancelButton` for better keyboard navigation
- Hide elements you don't need with `element.Visible = false`
- Reuse dialog instances when showing multiple times
- Use `Invoke()` when updating modeless dialogs from background threads

### ❌ Don't

- Don't forget to dispose dialogs
- Don't update modeless dialogs from background threads without `Invoke()`
- Don't show dialogs without making at least one element visible
- Don't use `ShowDialog()` for long-running operations (use modeless `Show()` instead)
- Don't ignore theme integration - let the component use theme colors

**👉 Full best practices guide: [Developer Documentation - Best Practices](KryptonTaskDialogDeveloperOverView.md#best-practices)**

---

## Code Examples Repository

### Simple Examples

- [Basic Dialog](#1-basic-dialog)
- [Confirmation Dialog](#2-confirmation-dialog)
- [Progress Dialog](#3-progress-dialog)

### Comprehensive Examples

All in [Developer Documentation - Usage Examples](KryptonTaskDialogDeveloperOverView.md#usage-examples):

1. Simple Confirmation Dialog
2. Progress Dialog (Modeless)
3. Input Dialog with ComboBox
4. Command Link Dialog
5. Expandable Details Dialog
6. Custom Controls with FreeWheeler

---

## Troubleshooting

### Common Issues

**Dialog not displaying?**

- Ensure at least one element has `Visible = true`
- Check `StartPosition` is valid
- Verify parent owner window is valid

**Elements not visible?**

- Check element's `Visible` property
- Ensure you haven't called `HideAllElements()` without re-showing elements

**Cross-thread exceptions?**

- Use `Invoke()` when updating from background threads:

  ```csharp
  this.Invoke(() => taskDialog.Content.Text = "Update");
  ```

**Theme not applied?**

- Ensure `KryptonManager.CurrentGlobalPalette` is set before creating dialog
- Theme changes are automatically detected during dialog lifetime

**👉 Complete troubleshooting guide: [Developer Documentation - Troubleshooting](KryptonTaskDialogDeveloperOverView.md#troubleshooting)**

---

## Contributing

This documentation covers the KryptonTaskDialog component of the Krypton Standard Toolkit. For contributing:

1. Report issues on the [GitHub repository](https://github.com/Krypton-Suite/Standard-Toolkit)
2. Follow the repository guidelines in [AGENTS.md](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/AGENTS.md)
3. Submit pull requests following the contribution guidelines

---

## Additional Resources

### Related Components

- **KryptonMessageBox** - Simple message box dialogs
- **KryptonForm** - Base form used by KryptonTaskDialog
- **KryptonManager** - Theme management

---

## Quick Links

| Document | Purpose | Size |
| --- | --- | --- |
| [📘 Developer Documentation](KryptonTaskDialogDeveloperOverView.md) | Complete guide | ~150 pages |
| [⚡ Quick Reference](KryptonTaskDialogQuickReference.md) | Fast lookup | ~20 pages |
| [🏗️ Architecture](KryptonTaskDialogArchitecture.md) | Internals | ~50 pages |
| [📖 API Reference](KryptonTaskDialogAPIReference.md) | API docs | ~40 pages |

---

**Welcome to KryptonTaskDialog!** Start with the [Getting Started](KryptonTaskDialogDeveloperOverView.md#getting-started) section or try one of the [Quick Examples](#getting-started-in-5-minutes) above.

For questions or issues, please refer to the [Krypton Toolkit Repository](https://github.com/Krypton-Suite/Standard-Toolkit).
