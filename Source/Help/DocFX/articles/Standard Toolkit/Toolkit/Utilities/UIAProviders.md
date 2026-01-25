# UIA Provider Implementation

## Table of Contents

1. [Overview](#overview)
2. [Problem Statement](#problem-statement)
3. [Architecture & Design](#architecture--design)
4. [Implementation Details](#implementation-details)
5. [Code Patterns & Examples](#code-patterns--examples)
6. [Framework Compatibility](#framework-compatibility)
7. [Extending the Implementation](#extending-the-implementation)
8. [Testing & Validation](#testing--validation)
9. [Troubleshooting](#troubleshooting)
10. [Performance Considerations](#performance-considerations)
11. [Best Practices](#best-practices)

---

## Overview

This document provides comprehensive technical documentation for the UIA (UI Automation) Provider implementation in Krypton Toolkit. The implementation ensures that Krypton controls that wrap standard Windows Forms controls properly expose accessibility information to assistive technologies.

### What is UI Automation?

UI Automation is Microsoft's accessibility framework that enables assistive technologies (screen readers, automation tools, etc.) to interact with applications. It provides a standardized way to:

- Discover UI elements
- Read element properties (name, role, state, value)
- Navigate between elements
- Interact with controls programmatically

### Why This Matters

When Krypton wraps standard Windows Forms controls (e.g., `KryptonTextBox` wraps a `TextBox`), the internal control's accessibility information may not be properly exposed through the wrapper. This causes:

- Screen readers (Narrator, NVDA, JAWS) to fail or provide incorrect information
- UI Automation tools to not discover controls
- Accessibility compliance issues

---

## Problem Statement

### The Wrapping Problem

Krypton controls often wrap standard Windows Forms controls to provide custom styling while maintaining functionality:

```csharp
public class KryptonTextBox : VisualControlBase
{
    private InternalTextBox _textBox;  // Internal TextBox control
    
    public TextBox TextBox => _textBox;  // Exposed for advanced scenarios
}
```

### .NET 6+ UIA Providers

Starting with .NET 6, Microsoft added built-in UIA providers for standard Windows Forms controls. These providers:

- Automatically expose accessibility information
- Support modern accessibility standards
- Work seamlessly with assistive technologies

However, when a control is wrapped:

1. The wrapper control (`KryptonTextBox`) becomes the accessible object
2. The internal control's (`TextBox`) accessibility information is "hidden"
3. Assistive technologies see the wrapper, not the internal control
4. Accessibility information is lost or incorrect

### Example Scenario

**Before Implementation:**
```
Narrator: "Edit, no name specified"
```

**After Implementation:**
```
Narrator: "Test TextBox, edit, type in text"
```

---

## Architecture & Design

### Design Principles

1. **Delegation Pattern**: Delegate accessibility calls to the internal control's accessibility object
2. **Null Safety**: Handle cases where internal control might be null
3. **Framework Compatibility**: Work on both modern (.NET 8+) and legacy (.NET Framework) TFMs
4. **Minimal Overhead**: Efficient delegation with minimal performance impact
5. **Fallback Support**: Provide sensible defaults when internal control information is unavailable

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    KryptonTextBox                       │
│  ┌───────────────────────────────────────────────────┐  │
│  │  CreateAccessibilityInstance()                    │  │
│  │  Returns: KryptonTextBoxAccessibleObject         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        │
                        │ delegates to
                        ▼
┌─────────────────────────────────────────────────────────┐
│         KryptonTextBoxAccessibleObject                   │
│  ┌───────────────────────────────────────────────────┐  │
│  │  Name, Role, State, Value, etc.                  │  │
│  │  ─────────────────────────────────────────────   │  │
│  │  _owner.TextBox.AccessibilityObject.Name         │  │
│  │  _owner.TextBox.AccessibilityObject.Role         │  │
│  │  _owner.TextBox.AccessibilityObject.State        │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                        │
                        │ forwards to
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Internal TextBox.AccessibilityObject         │
│  ┌───────────────────────────────────────────────────┐  │
│  │  .NET 6+ UIA Provider (modern TFMs)              │  │
│  │  OR                                                │  │
│  │  Basic AccessibilityObject (legacy TFMs)         │  │
│  └───────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Class Hierarchy

```
Control.ControlAccessibleObject (base class)
    │
    ├── KryptonTextBoxAccessibleObject
    ├── KryptonRichTextBoxAccessibleObject
    ├── KryptonComboBoxAccessibleObject
    ├── KryptonListBoxAccessibleObject
    ├── KryptonCheckedListBoxAccessibleObject
    ├── KryptonMaskedTextBoxAccessibleObject
    ├── KryptonNumericUpDownAccessibleObject
    ├── KryptonDomainUpDownAccessibleObject
    └── KryptonLinkWrapLabelAccessibleObject
```

---

## Implementation Details

### Core Components

#### 1. AccessibleObject Classes

Each Krypton control has a corresponding `AccessibleObject` class located in:
```
Source/Krypton Components/Krypton.Toolkit/Utilities/Accessibility/
```

**Structure:**
```csharp
internal class KryptonTextBoxAccessibleObject : Control.ControlAccessibleObject
{
    private readonly KryptonTextBox _owner;
    
    public KryptonTextBoxAccessibleObject(KryptonTextBox owner)
        : base(owner)
    {
        _owner = owner;
    }
    
    // Override accessibility properties and methods
    public override string? Name { get { ... } }
    public override AccessibleRole Role { get { ... } }
    // ... etc
}
```

#### 2. Control Integration

Each Krypton control overrides `CreateAccessibilityInstance()`:

```csharp
protected override AccessibleObject CreateAccessibilityInstance()
{
    return new KryptonTextBoxAccessibleObject(this);
}
```

### Property Delegation Pattern

All accessibility properties follow this pattern:

```csharp
public override string? Name
{
    get
    {
        // 1. Try to get from internal control first
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible?.Name != null)
        {
            return internalAccessible.Name;
        }
        
        // 2. Fall back to base implementation
        return base.Name ?? _owner.Name;
    }
}
```

### Role Fallback Strategy

For legacy TFMs, we provide explicit role fallbacks:

```csharp
public override AccessibleRole Role
{
    get
    {
        // Delegate to internal control's role
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible != null)
        {
            var role = internalAccessible.Role;
            // Ensure we have a valid role (legacy TFMs might return Default)
            if (role != AccessibleRole.Default && role != AccessibleRole.None)
            {
                return role;
            }
        }
        
        // Fall back to appropriate role for this control type
        return AccessibleRole.Text;  // For TextBox controls
    }
}
```

### Method Delegation Pattern

Methods follow a similar delegation pattern:

```csharp
public override void DoDefaultAction()
{
    // Delegate to internal control's default action
    var internalAccessible = _owner.TextBox?.AccessibilityObject;
    if (internalAccessible != null)
    {
        internalAccessible.DoDefaultAction();
    }
    else
    {
        base.DoDefaultAction();
    }
}
```

---

## Code Patterns & Examples

### Complete Example: KryptonTextBoxAccessibleObject

```csharp
#region BSD License
/*
 * Original BSD 3-Clause License
 * New BSD 3-Clause License
 * Modifications by Peter Wagner (aka Wagnerp), Simon Coghlan (aka Smurf-IV), 
 * Giduac & Ahmed Abdelhameed et al. 2026 - 2026. All rights reserved.
 */
#endregion

namespace Krypton.Toolkit;

/// <summary>
/// Provides accessibility information for KryptonTextBox control.
/// Delegates to the internal TextBox's accessibility object to ensure 
/// proper UIA provider support.
/// </summary>
internal class KryptonTextBoxAccessibleObject : Control.ControlAccessibleObject
{
    #region Instance Fields
    private readonly KryptonTextBox _owner;
    #endregion

    #region Identity
    /// <summary>
    /// Initialize a new instance of the KryptonTextBoxAccessibleObject class.
    /// </summary>
    /// <param name="owner">The KryptonTextBox control that owns this accessible object.</param>
    public KryptonTextBoxAccessibleObject(KryptonTextBox owner)
        : base(owner)
    {
        _owner = owner;
    }
    #endregion

    #region Public Overrides
    
    /// <summary>
    /// Gets the accessible name of the control.
    /// </summary>
    public override string? Name
    {
        get
        {
            // Try to get name from internal TextBox first
            var internalAccessible = _owner.TextBox?.AccessibilityObject;
            if (internalAccessible?.Name != null)
            {
                return internalAccessible.Name;
            }

            // Fall back to base implementation
            return base.Name ?? _owner.Name;
        }
    }

    /// <summary>
    /// Gets the accessible description of the control.
    /// </summary>
    public override string? Description
    {
        get
        {
            // Try to get description from internal TextBox first
            var internalAccessible = _owner.TextBox?.AccessibilityObject;
            if (internalAccessible?.Description != null)
            {
                return internalAccessible.Description;
            }

            // Fall back to base implementation
            return base.Description;
        }
    }

    /// <summary>
    /// Gets the accessible role of the control.
    /// </summary>
    public override AccessibleRole Role
    {
        get
        {
            // Delegate to internal TextBox's role
            var internalAccessible = _owner.TextBox?.AccessibilityObject;
            if (internalAccessible != null)
            {
                var role = internalAccessible.Role;
                // Ensure we have a valid role (legacy TFMs might return Default)
                if (role != AccessibleRole.Default && role != AccessibleRole.None)
                {
                    return role;
                }
            }

            // Fall back to Text role for TextBox controls
            return AccessibleRole.Text;
        }
    }

    /// <summary>
    /// Gets the state of this accessible object.
    /// </summary>
    public override AccessibleStates State
    {
        get
        {
            // Delegate to internal TextBox's state
            var internalAccessible = _owner.TextBox?.AccessibilityObject;
            if (internalAccessible != null)
            {
                return internalAccessible.State;
            }

            // Fall back to base implementation
            return base.State;
        }
    }

    /// <summary>
    /// Gets the value of the accessible object.
    /// </summary>
    public override string? Value
    {
        get
        {
            // Delegate to internal TextBox's value (which contains the text)
            var internalAccessible = _owner.TextBox?.AccessibilityObject;
            if (internalAccessible?.Value != null)
            {
                return internalAccessible.Value;
            }

            // Fall back to control's text
            return _owner.Text;
        }
    }

    /// <summary>
    /// Performs the default action associated with this accessible object.
    /// </summary>
    public override void DoDefaultAction()
    {
        // Delegate to internal TextBox's default action
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible != null)
        {
            internalAccessible.DoDefaultAction();
        }
        else
        {
            base.DoDefaultAction();
        }
    }

    /// <summary>
    /// Retrieves the child accessible object corresponding to the specified index.
    /// </summary>
    /// <param name="index">The zero-based index of the child accessible object.</param>
    /// <returns>An AccessibleObject that represents the child accessible object.</returns>
    public override AccessibleObject? GetChild(int index)
    {
        // Delegate to internal TextBox's children
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible != null)
        {
            return internalAccessible.GetChild(index);
        }

        return base.GetChild(index);
    }

    /// <summary>
    /// Retrieves the number of children belonging to an accessible object.
    /// </summary>
    /// <returns>The number of children belonging to an accessible object.</returns>
    public override int GetChildCount()
    {
        // Delegate to internal TextBox's child count
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible != null)
        {
            return internalAccessible.GetChildCount();
        }

        return base.GetChildCount();
    }

    /// <summary>
    /// Navigates to another accessible object.
    /// </summary>
    /// <param name="direction">One of the NavigateDirection values.</param>
    /// <returns>An AccessibleObject representing one of the NavigateDirection values.</returns>
    public override AccessibleObject? Navigate(AccessibleNavigation direction)
    {
        // Delegate to internal TextBox's navigation
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible != null)
        {
            return internalAccessible.Navigate(direction);
        }

        return base.Navigate(direction);
    }

    /// <summary>
    /// Selects this accessible object.
    /// </summary>
    /// <param name="flags">One of the AccessibleSelection values.</param>
    public override void Select(AccessibleSelection flags)
    {
        // Delegate to internal TextBox's selection
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        if (internalAccessible != null)
        {
            internalAccessible.Select(flags);
        }
        else
        {
            base.Select(flags);
        }
    }
    #endregion
}
```

### Control Integration Example

```csharp
// In KryptonTextBox.cs, in the Protected Overrides region:

/// <summary>
/// Creates the accessibility object for the KryptonTextBox control.
/// </summary>
/// <returns>A new KryptonTextBoxAccessibleObject instance for the control.</returns>
protected override AccessibleObject CreateAccessibilityInstance() 
    => new KryptonTextBoxAccessibleObject(this);
```

### Special Cases

#### KryptonLinkWrapLabel

Since `KryptonLinkWrapLabel` inherits directly from `LinkLabel`, the implementation is slightly different:

```csharp
public override string? Name
{
    get
    {
        // Since KryptonLinkWrapLabel inherits from LinkLabel, 
        // cast to LinkLabel to access its accessibility object
        var linkLabelAccessible = ((LinkLabel)_owner).AccessibilityObject;
        if (linkLabelAccessible?.Name != null)
        {
            return linkLabelAccessible.Name;
        }

        return base.Name ?? _owner.Name;
    }
}
```

#### KryptonCheckedListBox

Since `CheckedListBox` inherits from `ListBox`, we access it through the `ListBox` property:

```csharp
public override string? Name
{
    get
    {
        // Try to get name from internal ListBox (CheckedListBox inherits from ListBox)
        var internalAccessible = _owner.ListBox?.AccessibilityObject;
        if (internalAccessible?.Name != null)
        {
            return internalAccessible.Name;
        }

        return base.Name ?? _owner.Name;
    }
}
```

---

## Framework Compatibility

### Modern TFMs (net8.0-windows, net9.0-windows, net10.0-windows)

**Features:**
- Built-in UIA providers for standard controls
- Rich accessibility information
- Full UIA pattern support

**Implementation:**
- Directly delegates to internal control's UIA providers
- Leverages all .NET 6+ accessibility enhancements
- No additional work required

### Legacy TFMs (net472, net48, net481)

**Limitations:**
- No built-in UIA providers
- Basic `AccessibilityObject` instances only
- Limited accessibility information

**Implementation:**
- Delegates to internal control's basic `AccessibilityObject`
- Provides explicit `AccessibleRole` fallbacks
- Ensures consistent behavior across TFMs

### Role Fallback Mapping

| Control Type | Fallback Role |
|--------------|---------------|
| TextBox | `AccessibleRole.Text` |
| RichTextBox | `AccessibleRole.Text` |
| ComboBox | `AccessibleRole.ComboBox` |
| ListBox | `AccessibleRole.List` |
| CheckedListBox | `AccessibleRole.List` |
| MaskedTextBox | `AccessibleRole.Text` |
| NumericUpDown | `AccessibleRole.Text` |
| DomainUpDown | `AccessibleRole.Text` |
| LinkWrapLabel | `AccessibleRole.Link` |

### Runtime vs Compile-Time

We use **runtime checks** rather than conditional compilation:

```csharp
// ✅ Good: Runtime check
var role = internalAccessible.Role;
if (role != AccessibleRole.Default && role != AccessibleRole.None)
{
    return role;
}
return AccessibleRole.Text;  // Fallback

// ❌ Avoid: Conditional compilation (harder to maintain)
#if NET48_OR_GREATER
    return internalAccessible.Role;
#else
    return AccessibleRole.Text;
#endif
```

**Benefits:**
- Single codebase for all TFMs
- Easier maintenance
- Consistent behavior
- Better testability

---

## Extending the Implementation

### Adding Support for a New Control

If you need to add UIA provider support for a new Krypton control that wraps a standard control:

#### Step 1: Create the AccessibleObject Class

1. Create a new file in `Utilities/Accessibility/`:
   ```
   Krypton[ControlName]AccessibleObject.cs
   ```

2. Use the template from `KryptonTextBoxAccessibleObject.cs` as a starting point

3. Update the class name and `_owner` field type

4. Update property accessors to use the correct internal control property

#### Step 2: Integrate with the Control

1. Open the Krypton control file (e.g., `Krypton[ControlName].cs`)

2. Find the `#region Protected Overrides` section

3. Add:
   ```csharp
   /// <summary>
   /// Creates the accessibility object for the Krypton[ControlName] control.
   /// </summary>
   /// <returns>A new Krypton[ControlName]AccessibleObject instance.</returns>
   protected override AccessibleObject CreateAccessibilityInstance() 
       => new Krypton[ControlName]AccessibleObject(this);
   ```

#### Step 3: Determine the Internal Control Property

Identify how the control exposes its internal standard control:

- `KryptonTextBox` → `_owner.TextBox`
- `KryptonComboBox` → `_owner.ComboBox`
- `KryptonCheckedListBox` → `_owner.ListBox` (CheckedListBox inherits from ListBox)
- `KryptonLinkWrapLabel` → Cast to `LinkLabel` (inherits from LinkLabel)

#### Step 4: Determine the Fallback Role

Choose the appropriate `AccessibleRole` for the control type:

```csharp
// Text input controls
return AccessibleRole.Text;

// Selection controls
return AccessibleRole.ComboBox;  // or List, etc.

// Navigation controls
return AccessibleRole.Link;
```

#### Step 5: Test

1. Add the control to `AccessibilityTest.cs` in the TestForm project
2. Run the accessibility test
3. Test with Narrator
4. Test with UI Automation tools

### Example: Adding KryptonDateTimePicker

```csharp
// Step 1: Create KryptonDateTimePickerAccessibleObject.cs
internal class KryptonDateTimePickerAccessibleObject : Control.ControlAccessibleObject
{
    private readonly KryptonDateTimePicker _owner;
    
    public KryptonDateTimePickerAccessibleObject(KryptonDateTimePicker owner)
        : base(owner)
    {
        _owner = owner;
    }
    
    public override AccessibleRole Role
    {
        get
        {
            var internalAccessible = _owner.DateTimePicker?.AccessibilityObject;
            if (internalAccessible != null)
            {
                var role = internalAccessible.Role;
                if (role != AccessibleRole.Default && role != AccessibleRole.None)
                {
                    return role;
                }
            }
            return AccessibleRole.Text;  // Appropriate for DateTimePicker
        }
    }
    
    // ... implement other properties and methods
}

// Step 2: In KryptonDateTimePicker.cs
protected override AccessibleObject CreateAccessibilityInstance() 
    => new KryptonDateTimePickerAccessibleObject(this);
```

---

## Testing & Validation

### Automated Testing

The `AccessibilityTest` form in the TestForm project provides automated property validation:

**Location:** `Source/Krypton Components/TestForm/AccessibilityTest.cs`

**Features:**
- Tests all 9 implemented controls
- Validates Name, Description, Role, State, Value
- Checks navigation capabilities
- Displays comprehensive test results

**Usage:**
1. Run TestForm application
2. Select "Accessibility Test (UIA Providers)"
3. Click "Test Accessibility Properties"
4. Review results in the results panel

### Manual Testing with Narrator

**Windows Narrator:**
1. Enable Narrator: `Win + Ctrl + Enter`
2. Navigate to the test form
3. Use `Tab` to navigate between controls
4. Listen to what Narrator announces
5. Verify:
   - Control name is announced
   - Control role is announced
   - Control value is announced (if applicable)
   - Control is interactive

**Expected Output:**
```
"Test TextBox, edit, type in text"
"Test ComboBox, combo box, Option 1, collapsed"
"Test ListBox, list, Item 1, 1 of 5"
```

### Manual Testing with UI Automation Tools

#### Inspect.exe (Windows SDK)

1. Launch Inspect.exe
2. Point to a Krypton control
3. Verify:
   - Control is discoverable
   - Properties are correct (Name, Role, etc.)
   - Patterns are available (if applicable)

#### Accessibility Insights

1. Launch Accessibility Insights for Windows
2. Run FastPass scan
3. Verify no accessibility issues
4. Check control properties

### Testing Checklist

For each control:

- [ ] `AccessibleObject` is created (not null)
- [ ] `Name` property returns correct value
- [ ] `Description` property returns correct value
- [ ] `Role` property returns appropriate role
- [ ] `State` property reflects control state
- [ ] `Value` property returns current value (if applicable)
- [ ] `GetChildCount()` returns correct count
- [ ] `Navigate()` works correctly
- [ ] `DoDefaultAction()` performs expected action
- [ ] Narrator can identify and interact with control
- [ ] UI Automation tools can discover control
- [ ] Works on all target frameworks

### Framework-Specific Testing

Test on each TFM:
- net472
- net48
- net481
- net8.0-windows
- net9.0-windows
- net10.0-windows

**Key Differences to Verify:**
- Role fallbacks work on legacy TFMs
- UIA providers work on modern TFMs
- No regressions in functionality

---

## Troubleshooting

### Common Issues

#### Issue: AccessibleObject is null

**Symptoms:**
- `AccessibilityObject` returns null
- Tests fail with null reference exceptions

**Causes:**
- Internal control not initialized
- Control not added to a form
- Control handle not created

**Solutions:**
```csharp
// Ensure internal control exists
if (_owner.TextBox == null)
{
    return base.Name;  // Fallback
}

// Ensure control is on a form and has a handle
if (!_owner.IsHandleCreated)
{
    _owner.CreateControl();
}
```

#### Issue: Role returns Default or None

**Symptoms:**
- `Role` property returns `AccessibleRole.Default` or `AccessibleRole.None`
- Screen readers don't announce control type correctly

**Solutions:**
- This is expected on legacy TFMs
- Our implementation provides fallback roles
- Verify fallback logic is working:
  ```csharp
  if (role != AccessibleRole.Default && role != AccessibleRole.None)
  {
      return role;
  }
  return AccessibleRole.Text;  // Fallback
  ```

#### Issue: Name property returns null

**Symptoms:**
- Screen readers don't announce control name
- `Name` property returns null

**Solutions:**
- Set `AccessibleName` on the control:
  ```csharp
  kryptonTextBox1.AccessibleName = "User Name Input";
  ```
- Or set `Name` property:
  ```csharp
  kryptonTextBox1.Name = "txtUserName";
  ```
- Verify fallback logic:
  ```csharp
  return base.Name ?? _owner.Name;
  ```

#### Issue: Navigation doesn't work

**Symptoms:**
- Screen reader navigation skips controls
- `Navigate()` returns null

**Solutions:**
- Ensure controls are properly parented
- Verify `GetChild()` and `GetChildCount()` work correctly
- Check that controls are in the tab order

### Debugging Tips

#### Enable Accessibility Debugging

```csharp
// Add debug output to verify delegation
public override string? Name
{
    get
    {
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        System.Diagnostics.Debug.WriteLine(
            $"KryptonTextBox Name: Internal={internalAccessible?.Name}, " +
            $"Base={base.Name}, Owner={_owner.Name}");
        
        if (internalAccessible?.Name != null)
        {
            return internalAccessible.Name;
        }
        
        return base.Name ?? _owner.Name;
    }
}
```

#### Verify Internal Control Access

```csharp
// Add validation
if (_owner.TextBox == null)
{
    throw new InvalidOperationException(
        "Internal TextBox is null. Control may not be initialized.");
}
```

#### Test with UI Automation Spy

Use UI Automation Spy to inspect the accessibility tree:
1. Launch UI Automation Spy
2. Point to control
3. Inspect properties
4. Compare with expected values

---

## Performance Considerations

### Overhead Analysis

**Delegation Pattern:**
- Property access: ~1-2 property lookups + null checks
- Method calls: ~1 method call + null check
- **Estimated overhead: < 1 microsecond per call**

**Memory:**
- One `AccessibleObject` instance per control
- Minimal memory footprint (~100 bytes per instance)

### Optimization Strategies

#### 1. Cache Internal Accessibility Object

**Current Implementation:**
```csharp
public override string? Name
{
    get
    {
        var internalAccessible = _owner.TextBox?.AccessibilityObject;
        // ... access properties
    }
}
```

**Optimized (if needed):**
```csharp
private AccessibleObject? _cachedInternalAccessible;

private AccessibleObject? InternalAccessible
{
    get
    {
        if (_cachedInternalAccessible == null)
        {
            _cachedInternalAccessible = _owner.TextBox?.AccessibilityObject;
        }
        return _cachedInternalAccessible;
    }
}
```

**Note:** Current implementation is already efficient. Caching is only needed if profiling shows performance issues.

#### 2. Lazy Initialization

Accessibility objects are created on-demand when first accessed:
```csharp
// Created when AccessibilityObject property is first accessed
var accessible = control.AccessibilityObject;
```

This is already handled by the framework - no changes needed.

### Performance Best Practices

1. **Avoid unnecessary property access**
   ```csharp
   // ❌ Bad: Multiple property accesses
   if (_owner.TextBox != null && _owner.TextBox.AccessibilityObject != null)
   {
       return _owner.TextBox.AccessibilityObject.Name;
   }
   
   // ✅ Good: Single access with null-conditional
   var internalAccessible = _owner.TextBox?.AccessibilityObject;
   if (internalAccessible?.Name != null)
   {
       return internalAccessible.Name;
   }
   ```

2. **Use null-conditional operators**
   ```csharp
   // ✅ Efficient and safe
   return _owner.TextBox?.AccessibilityObject?.Name ?? base.Name;
   ```

3. **Minimize allocations**
   - Reuse variables where possible
   - Avoid creating temporary objects in hot paths

---

## Best Practices

### Code Organization

1. **File Location**
   - Place all `AccessibleObject` classes in `Utilities/Accessibility/`
   - Follow naming convention: `Krypton[ControlName]AccessibleObject.cs`

2. **Namespace**
   - Use `Krypton.Toolkit` namespace
   - Keep classes `internal` (not public API)

3. **Region Organization**
   ```csharp
   #region Instance Fields
   #endregion
   
   #region Identity
   #endregion
   
   #region Public Overrides
   #endregion
   ```

### Implementation Guidelines

1. **Always Provide Fallbacks**
   ```csharp
   // ✅ Good: Always has a fallback
   return internalAccessible?.Name ?? base.Name ?? _owner.Name;
   
   // ❌ Bad: Can return null unexpectedly
   return internalAccessible?.Name;
   ```

2. **Handle Null Cases**
   ```csharp
   // ✅ Good: Null-safe
   var internalAccessible = _owner.TextBox?.AccessibilityObject;
   if (internalAccessible != null)
   {
       // Use it
   }
   
   // ❌ Bad: Can throw NullReferenceException
   return _owner.TextBox.AccessibilityObject.Name;
   ```

3. **Use Appropriate Roles**
   - Match the control's semantic meaning
   - Use standard `AccessibleRole` values
   - Don't use `Default` or `None` as fallbacks

4. **Document Special Cases**
   ```csharp
   /// <summary>
   /// Gets the accessible role of the control.
   /// Note: On legacy TFMs, provides explicit fallback to Text role
   /// when internal control returns Default or None.
   /// </summary>
   ```

### Testing Guidelines

1. **Test on All TFMs**
   - Don't assume behavior is the same
   - Verify fallbacks work correctly

2. **Test with Real Tools**
   - Don't rely only on automated tests
   - Test with Narrator, NVDA, JAWS
   - Test with UI Automation tools

3. **Test Edge Cases**
   - Null internal controls
   - Disabled controls
   - Hidden controls
   - Controls not in tab order

### Maintenance

1. **Keep in Sync**
   - When internal control changes, update `AccessibleObject`
   - When new properties are added, consider accessibility implications

2. **Review Regularly**
   - Check for new .NET accessibility features
   - Update fallback roles if needed
   - Verify compatibility with new TFMs

3. **Document Changes**
   - Update this documentation
   - Update implementation plan document
   - Note any breaking changes

---

## Additional Resources

### Microsoft Documentation

- [UI Automation Overview](https://learn.microsoft.com/en-us/dotnet/framework/ui-automation/ui-automation-overview)
- [Accessibility in Windows Forms](https://learn.microsoft.com/en-us/dotnet/desktop/winforms/advanced/accessibility-in-windows-forms-controls)
- [.NET 6 WinForms Accessibility Improvements](https://devblogs.microsoft.com/dotnet/whats-new-in-windows-forms-in-net-6-0/)

### Tools

- **Inspect.exe**: Windows SDK tool for inspecting accessibility properties
- **Accessibility Insights**: Microsoft's accessibility testing tool
- **UI Automation Spy**: Inspect UI Automation tree
- **Narrator**: Windows built-in screen reader

---

## Conclusion

This implementation provides comprehensive UIA provider support for Krypton controls that wrap standard Windows Forms controls. By using a delegation pattern with proper fallbacks, we ensure:

- ✅ Accessibility information is properly exposed
- ✅ Works on both modern and legacy TFMs
- ✅ Minimal performance overhead
- ✅ Easy to extend and maintain

For questions or issues, refer to the troubleshooting section or create an issue in the repository.