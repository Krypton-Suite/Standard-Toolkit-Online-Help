# ButtonStyle Enumeration

## Overview

`ButtonStyle` specifies the visual style and behavior of Krypton buttons. Each style is optimized for specific use cases and UI contexts, from standalone buttons to specialized ribbon and navigator elements.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit

```csharp
public enum ButtonStyle
```

---

## Members

### Standalone
Specifies a standalone button style.

```csharp
Standalone
```

**Usage:** Standard buttons that appear independently  
**Typical Context:** Forms, panels, general UI  
**Appearance:** Full border, solid background, clear button appearance

**Example:**
```csharp
kryptonButton1.ButtonStyle = ButtonStyle.Standalone;
```

---

### Alternate
Specifies an alternate standalone button style.

```csharp
Alternate
```

**Usage:** Alternative styling for standalone buttons  
**Typical Context:** Secondary actions, less prominent buttons  
**Appearance:** Alternate color scheme defined by palette

**Example:**
```csharp
cancelButton.ButtonStyle = ButtonStyle.Alternate;
```

---

### LowProfile
Specifies a low profile button style.

```csharp
LowProfile
```

**Usage:** Subtle buttons with minimal visual weight  
**Typical Context:** Toolbars, inline actions  
**Appearance:** Flat or minimal border, only visible on hover

**Example:**
```csharp
toolbarButton.ButtonStyle = ButtonStyle.LowProfile;
```

**Comparison:**
- More subtle than `Standalone`
- Shows border/background on hover
- Good for reducing visual clutter

---

### ButtonSpec
Specifies a button spec usage style.

```csharp
ButtonSpec
```

**Usage:** Buttons used as button specifications  
**Typical Context:** In-control buttons (close, dropdown, etc.)  
**Appearance:** Very minimal, designed for small spaces

**Example:**
```csharp
closeButton.ButtonStyle = ButtonStyle.ButtonSpec;
```

**Remarks:**
- Used by `ButtonSpec` system
- Typically very small (16x16 or similar)
- Icon-only presentation

---

### BreadCrumb
Specifies a button style appropriate for bread crumbs.

```csharp
BreadCrumb
```

**Usage:** Navigation breadcrumb buttons  
**Typical Context:** Breadcrumb navigation bars  
**Appearance:** Flat with separator styling

**Example:**
```csharp
breadcrumbButton.ButtonStyle = ButtonStyle.BreadCrumb;
```

**Typical Usage:**
```csharp
Home > Documents > Reports > 2024
```

---

### CalendarDay
Specifies a button style appropriate for calendar days.

```csharp
CalendarDay
```

**Usage:** Individual day buttons in calendar controls  
**Typical Context:** `KryptonMonthCalendar`, date pickers  
**Appearance:** Minimal styling suitable for calendar grid

**Example:**
```csharp
dayButton.ButtonStyle = ButtonStyle.CalendarDay;
```

---

### Cluster
Specifies a ribbon cluster button usage style.

```csharp
Cluster
```

**Usage:** Buttons within ribbon clusters  
**Typical Context:** `KryptonRibbon` cluster groups  
**Appearance:** Compact, designed for ribbon layout

**Example:**
```csharp
ribbonButton.ButtonStyle = ButtonStyle.Cluster;
```

**Remarks:**
- Part of the Office-style ribbon interface
- Typically smaller than standalone buttons
- May show text below icon

---

### Gallery
Specifies a ribbon gallery button usage style.

```csharp
Gallery
```

**Usage:** Buttons within ribbon gallery controls  
**Typical Context:** `KryptonRibbon` galleries  
**Appearance:** Designed for gallery item presentation

**Example:**
```csharp
galleryButton.ButtonStyle = ButtonStyle.Gallery;
```

**Use Case:**
- Style galleries (font colors, themes)
- Template galleries
- Quick style selections

---

### NavigatorStack
Specifies a navigator stack usage style.

```csharp
NavigatorStack
```

**Usage:** Buttons in navigator stack mode  
**Typical Context:** `KryptonNavigator` in stack mode  
**Appearance:** Suitable for vertical/horizontal stacking

**Example:**
```csharp
navButton.ButtonStyle = ButtonStyle.NavigatorStack;
```

---

### NavigatorOverflow
Specifies a navigator overflow usage style.

```csharp
NavigatorOverflow
```

**Usage:** Buttons in navigator overflow areas  
**Typical Context:** `KryptonNavigator` overflow menu  
**Appearance:** Compact, list-item style

**Example:**
```csharp
overflowButton.ButtonStyle = ButtonStyle.NavigatorOverflow;
```

---

### NavigatorMini
Specifies a navigator mini usage style.

```csharp
NavigatorMini
```

**Usage:** Miniature buttons in navigator  
**Typical Context:** `KryptonNavigator` mini mode  
**Appearance:** Very compact, icon-focused

**Example:**
```csharp
miniButton.ButtonStyle = ButtonStyle.NavigatorMini;
```

---

### InputControl
Specifies an input control usage style.

```csharp
InputControl
```

**Usage:** Buttons integrated with input controls  
**Typical Context:** Dropdown buttons, spin buttons  
**Appearance:** Designed to blend with input controls

**Example:**
```csharp
dropdownButton.ButtonStyle = ButtonStyle.InputControl;
```

**Typical Controls:**
- `KryptonComboBox` dropdown
- `KryptonNumericUpDown` spin buttons
- `KryptonDateTimePicker` dropdown

---

### ListItem
Specifies a list item usage style.

```csharp
ListItem
```

**Usage:** Buttons styled as list items  
**Typical Context:** List views, menu items  
**Appearance:** Full-width, flat, hover highlight

**Example:**
```csharp
listButton.ButtonStyle = ButtonStyle.ListItem;
```

**Use Case:**
- Custom list implementations
- Menu-like interfaces
- Selection lists

---

### Form
Specifies a form level style.

```csharp
Form
```

**Usage:** Form-level buttons (title bar buttons)  
**Typical Context:** Custom title bar implementations  
**Appearance:** Minimal, system button style

**Example:**
```csharp
minimizeButton.ButtonStyle = ButtonStyle.Form;
```

---

### FormClose
Specifies a form close button style.

```csharp
FormClose
```

**Usage:** Form close button specifically  
**Typical Context:** Custom title bar close button  
**Appearance:** Red hover state, close button styling

**Example:**
```csharp
closeButton.ButtonStyle = ButtonStyle.FormClose;
```

**Remarks:**
- Typically shows red background on hover
- May include 'X' icon
- Standard Windows close button behavior

---

### Command
Specifies a command button style.

```csharp
Command
```

**Usage:** Windows command link buttons  
**Typical Context:** `KryptonCommandLinkButton`  
**Appearance:** Two-line layout with arrow icon

**Example:**
```csharp
commandButton.ButtonStyle = ButtonStyle.Command;
```

**Characteristics:**
- Large heading text
- Smaller description text
- Optional arrow icon
- Typically 60-80px tall

---

### Custom1
Specifies the first custom button style.

```csharp
Custom1
```

**Usage:** User-defined custom style  
**Typical Context:** Application-specific styling  
**Appearance:** Defined by custom palette

**Example:**
```csharp
customButton.ButtonStyle = ButtonStyle.Custom1;

// Define in palette
palette.ButtonStyles.ButtonCustom1.StateNormal.Back.Color1 = Color.Purple;
```

---

### Custom2
Specifies the second custom button style.

```csharp
Custom2
```

**Usage:** User-defined custom style  
**Typical Context:** Application-specific styling  
**Appearance:** Defined by custom palette

---

### Custom3
Specifies the third custom button style.

```csharp
Custom3
```

**Usage:** User-defined custom style  
**Typical Context:** Application-specific styling  
**Appearance:** Defined by custom palette

---

## Usage Examples

### Standard Form Buttons

```csharp
var okButton = new KryptonButton
{
    Text = "OK",
    ButtonStyle = ButtonStyle.Standalone,
    DialogResult = DialogResult.OK
};

var cancelButton = new KryptonButton
{
    Text = "Cancel",
    ButtonStyle = ButtonStyle.Alternate,
    DialogResult = DialogResult.Cancel
};
```

---

### Toolbar Buttons

```csharp
var toolStrip = new KryptonToolStrip();

var newButton = new KryptonButton
{
    Text = "New",
    ButtonStyle = ButtonStyle.LowProfile,
    Image = Properties.Resources.NewIcon
};

var openButton = new KryptonButton
{
    Text = "Open",
    ButtonStyle = ButtonStyle.LowProfile,
    Image = Properties.Resources.OpenIcon
};
```

---

### Command Link Dialog

```csharp
public class ChoiceDialog : KryptonForm
{
    public ChoiceDialog()
    {
        var option1 = new KryptonCommandLinkButton
        {
            ButtonStyle = ButtonStyle.Command
        };
        option1.CommandLinkTextValues.Heading = "Create New";
        option1.CommandLinkTextValues.Description = "Start with a blank document";
        
        var option2 = new KryptonCommandLinkButton
        {
            ButtonStyle = ButtonStyle.Command
        };
        option2.CommandLinkTextValues.Heading = "Open Existing";
        option2.CommandLinkTextValues.Description = "Open a file from disk";
    }
}
```

---

### Custom Title Bar

```csharp
public class CustomTitleBar : KryptonPanel
{
    public CustomTitleBar()
    {
        var minimizeButton = new KryptonButton
        {
            ButtonStyle = ButtonStyle.Form,
            Text = "—",
            Size = new Size(30, 30)
        };
        
        var maximizeButton = new KryptonButton
        {
            ButtonStyle = ButtonStyle.Form,
            Text = "□",
            Size = new Size(30, 30)
        };
        
        var closeButton = new KryptonButton
        {
            ButtonStyle = ButtonStyle.FormClose,
            Text = "✕",
            Size = new Size(45, 30)
        };
    }
}
```

---

### Ribbon Integration

```csharp
var ribbon = new KryptonRibbon();
var tab = new KryptonRibbonTab { Text = "Home" };
var group = new KryptonRibbonGroup { TextLine1 = "Actions" };

var button1 = new KryptonRibbonGroupButton
{
    ButtonStyle = ButtonStyle.Cluster,
    TextLine1 = "Save",
    ImageLarge = Properties.Resources.SaveLarge
};

group.Items.Add(button1);
tab.Groups.Add(group);
ribbon.RibbonTabs.Add(tab);
```

---

### List-Style Interface

```csharp
public class ActionList : KryptonPanel
{
    public ActionList()
    {
        int y = 0;
        var actions = new[] { "Open File", "Save File", "Export Data", "Print" };
        
        foreach (var action in actions)
        {
            var button = new KryptonButton
            {
                Text = action,
                ButtonStyle = ButtonStyle.ListItem,
                Location = new Point(0, y),
                Size = new Size(200, 30),
                TextAlign = ContentAlignment.MiddleLeft
            };
            
            Controls.Add(button);
            y += 30;
        }
    }
}
```

---

### Custom Styled Buttons

```csharp
// Define custom palette
var customPalette = new KryptonCustomPaletteBase();

// Configure Custom1 style
customPalette.ButtonStyles.ButtonCustom1.StateNormal.Back.Color1 = Color.DarkBlue;
customPalette.ButtonStyles.ButtonCustom1.StateNormal.Back.Color2 = Color.LightBlue;
customPalette.ButtonStyles.ButtonCustom1.StateNormal.Content.ShortText.Color1 = Color.White;

// Use custom style
var brandedButton = new KryptonButton
{
    Text = "Branded Action",
    ButtonStyle = ButtonStyle.Custom1
};

// Apply palette
KryptonManager.CurrentGlobalPalette = customPalette;
```

---

### Dynamic Style Switching

```csharp
private void UpdateButtonStyle(KryptonButton button, bool isImportant)
{
    if (isImportant)
    {
        button.ButtonStyle = ButtonStyle.Standalone;
        button.StateCommon.Back.Color1 = Color.Orange;
    }
    else
    {
        button.ButtonStyle = ButtonStyle.LowProfile;
    }
}
```

---

### Context-Appropriate Styles

```csharp
public enum ButtonContext
{
    Primary,
    Secondary,
    Toolbar,
    Navigation,
    Inline
}

public static ButtonStyle GetStyleForContext(ButtonContext context)
{
    return context switch
    {
        ButtonContext.Primary => ButtonStyle.Standalone,
        ButtonContext.Secondary => ButtonStyle.Alternate,
        ButtonContext.Toolbar => ButtonStyle.LowProfile,
        ButtonContext.Navigation => ButtonStyle.BreadCrumb,
        ButtonContext.Inline => ButtonStyle.ButtonSpec,
        _ => ButtonStyle.Standalone
    };
}

// Usage:
primaryButton.ButtonStyle = GetStyleForContext(ButtonContext.Primary);
toolButton.ButtonStyle = GetStyleForContext(ButtonContext.Toolbar);
```

---

## Design Guidelines

### Style Selection Guide

| Style | Use When | Avoid When |
|-------|----------|------------|
| **Standalone** | Primary actions on forms | Toolbars, dense layouts |
| **Alternate** | Secondary/cancel actions | Primary actions |
| **LowProfile** | Toolbars, many buttons | Important standalone actions |
| **ButtonSpec** | Small in-control buttons | Large standalone buttons |
| **Command** | 2-3 major choices in dialogs | Many options, space-constrained |
| **ListItem** | Vertical list of options | Few options, need prominence |
| **Form** | Custom title bars | Regular form buttons |
| **Custom** | Branded buttons | Standard UI patterns |

---

### Visual Hierarchy

**High Prominence:**
1. `Standalone` - Most prominent
2. `Command` - Large, descriptive
3. `Alternate` - Secondary prominence

**Medium Prominence:**
4. `LowProfile` - Visible but subtle
5. `BreadCrumb` - Navigation context

**Low Prominence:**
6. `ButtonSpec` - Minimal
7. `InputControl` - Integrated
8. `Form` - System-level

---

### Context-Specific Styles

**Form Dialogs:**
- OK/Accept: `Standalone`
- Cancel: `Alternate`
- Help/Options: `LowProfile`

**Toolbars:**
- All buttons: `LowProfile`
- Active tool: May use `Standalone`

**Ribbons:**
- Group buttons: `Cluster`
- Gallery items: `Gallery`

**Navigation:**
- Breadcrumbs: `BreadCrumb`
- Tab pages: `NavigatorStack`

---

### Palette Integration

Each `ButtonStyle` maps to palette definitions:

```csharp
// Palette structure
PaletteBackStyle.ButtonStandalone
PaletteBackStyle.ButtonAlternate
PaletteBackStyle.ButtonLowProfile
PaletteBackStyle.ButtonSpec
// ... etc.

PaletteBorderStyle.ButtonStandalone
// ... etc.

PaletteContentStyle.ButtonStandalone
// ... etc.
```

**Custom Styles Example:**
```csharp
var palette = new KryptonPalette();

// Define Custom1 appearance
palette.ButtonStyles.ButtonCustom1.StateNormal.Back.Color1 = brandColor1;
palette.ButtonStyles.ButtonCustom1.StateTracking.Back.Color1 = brandColor2;
palette.ButtonStyles.ButtonCustom1.StatePressed.Back.Color1 = brandColor3;

// All buttons with Custom1 style will use these colors
```

---

## Related Types

### Associated Enumerations
- `PaletteBackStyle` - Background styling
- `PaletteBorderStyle` - Border styling
- `PaletteContentStyle` - Content styling
- `PaletteButtonStyle` - Button-specific palette style

### Controls Using ButtonStyle
- `KryptonButton`
- `KryptonDropButton`
- `KryptonCommandLinkButton`
- `KryptonCheckButton`
- `KryptonColorButton`
- `ButtonSpec` implementations
- `KryptonRibbon` buttons
- `KryptonNavigator` buttons

---

## See Also

- [KryptonButton](KryptonButton.md) - Standard button control
- [KryptonCommandLinkButton](KryptonCommandLinkButton.md) - Command link button
- [PaletteBackStyle](PaletteBackStyle.md) - Background style enumeration
- [ButtonSpec](ButtonSpec.md) - Button specification system
