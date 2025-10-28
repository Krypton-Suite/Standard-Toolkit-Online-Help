# KryptonForm API Reference

## Overview

`KryptonForm` is a form control that draws window chrome using a Krypton palette, providing a themed and customizable window appearance with full support for custom title bars, button specifications, and system menu customization.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit.dll  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `ScrollableControl` → `ContainerControl` → `Form` → `VisualForm` → `KryptonForm`  
**Implements:** `IContentValues`

---

## Constructor

### KryptonForm()

Initializes a new instance of the `KryptonForm` class.

```csharp
public KryptonForm()
```

**Remarks:**
- Sets default properties including header style, title alignment, and double buffering
- Creates button specification collections for form control buttons (Min, Max, Close)
- Initializes palette storage for active, inactive, and common states
- Sets up the view hierarchy for rendering the form chrome
- Configures system menu service and tooltip manager

---

## Properties

### Window Style Properties

#### MinimizeBox

Gets or sets a value indicating whether the minimize button is displayed.

```csharp
[DefaultValue(true)]
[Category("Window Style")]
public new bool MinimizeBox { get; set; }
```

#### MaximizeBox

Gets or sets a value indicating whether the maximize button is displayed.

```csharp
[DefaultValue(true)]
[Category("Window Style")]
public new bool MaximizeBox { get; set; }
```

#### CloseBox

Gets or sets a value indicating whether the close button is displayed.

```csharp
[DefaultValue(true)]
[Category("Window Style")]
public new bool CloseBox { get; set; }
```

#### ControlBox

Gets or sets a value indicating whether the form has a control box.

```csharp
[DefaultValue(true)]
[Category("Window Style")]
public new bool ControlBox { get; set; }
```

#### FormBorderStyle

Gets or sets the border style of the form.

```csharp
[Category("Appearance")]
[DefaultValue(FormBorderStyle.Sizable)]
public new FormBorderStyle FormBorderStyle { get; set; }
```

### Appearance Properties

#### TextExtra

Gets or sets the extra text associated with the control (secondary title text).

```csharp
[Category("Appearance")]
[DefaultValue("")]
public string? TextExtra { get; set; }
```

#### HeaderStyle

Gets or sets the header style for the form title bar.

```csharp
[Category("Visuals")]
[DefaultValue(HeaderStyle.Form)]
public HeaderStyle HeaderStyle { get; set; }
```

**Possible Values:**
- `HeaderStyle.Form` - Standard form header style
- `HeaderStyle.Primary` - Primary header style
- `HeaderStyle.Secondary` - Secondary header style
- `HeaderStyle.DockActive` - Active dock header style
- `HeaderStyle.DockInactive` - Inactive dock header style
- `HeaderStyle.Calendar` - Calendar header style
- `HeaderStyle.Custom1` - Custom header style 1
- `HeaderStyle.Custom2` - Custom header style 2
- `HeaderStyle.Custom3` - Custom header style 3

#### FormTitleAlign

Gets or sets the title position relative to available space.

```csharp
[Category("Visuals")]
[DefaultValue(PaletteRelativeAlign.Near)]
public PaletteRelativeAlign FormTitleAlign { get; set; }
```

**Possible Values:**
- `PaletteRelativeAlign.Near` - Left-aligned
- `PaletteRelativeAlign.Center` - Center-aligned
- `PaletteRelativeAlign.Far` - Right-aligned
- `PaletteRelativeAlign.Inherit` - Inherit from palette

#### TitleStyle

Gets or sets the title style arrangement (modern vs classic).

```csharp
[Category("Appearance")]
[DefaultValue(KryptonFormTitleStyle.Inherit)]
public KryptonFormTitleStyle TitleStyle { get; set; }
```

**Possible Values:**
- `KryptonFormTitleStyle.Inherit` - Use palette default
- `KryptonFormTitleStyle.Classic` - Classic left-aligned title
- `KryptonFormTitleStyle.Modern` - Modern center-aligned title

#### GroupBorderStyle

Gets or sets the chrome group border style.

```csharp
[Category("Visuals")]
[DefaultValue(PaletteBorderStyle.FormMain)]
public PaletteBorderStyle GroupBorderStyle { get; set; }
```

#### GroupBackStyle

Gets or sets the chrome group background style.

```csharp
[Category("Visuals")]
[DefaultValue(PaletteBackStyle.FormMain)]
public PaletteBackStyle GroupBackStyle { get; set; }
```

### Visual Configuration Properties

#### UseThemeFormChromeBorderWidth

Gets or sets a value indicating whether custom chrome is allowed.

```csharp
[Category("Visuals")]
[DefaultValue(true)]
public new bool UseThemeFormChromeBorderWidth { get; set; }
```

#### AllowStatusStripMerge

Gets or sets whether the form status strip should be considered for merging into chrome.

```csharp
[Category("Visuals")]
[DefaultValue(true)]
public bool AllowStatusStripMerge { get; set; }
```

#### AllowButtonSpecToolTips

Gets or sets whether tooltips should be displayed for button specs.

```csharp
[Category("Visuals")]
[DefaultValue(false)]
public bool AllowButtonSpecToolTips { get; set; }
```

#### AllowIconDisplay

Gets or sets whether the icon is allowed to be shown.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public bool AllowIconDisplay { get; set; }
```

#### UseDropShadow

**(Obsolete)** Gets or sets whether to use drop shadow around the form.

```csharp
[Category("Visuals")]
[DefaultValue(false)]
[Obsolete("Deprecated - Only use if you are using Windows 7, 8 or 8.1.")]
public bool UseDropShadow { get; set; }
```

### Palette Properties

#### StateCommon

Gets access to the common form appearance entries that other states can override.

```csharp
[Category("Visuals")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteFormRedirect? StateCommon { get; }
```

#### StateInactive

Gets access to the inactive form appearance entries.

```csharp
[Category("Visuals")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteForm StateInactive { get; }
```

#### StateActive

Gets access to the active form appearance entries.

```csharp
[Category("Visuals")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public PaletteForm StateActive { get; }
```

### Button Specification Properties

#### ButtonSpecs

Gets the collection of button specifications.

```csharp
[Category("Visuals")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public FormButtonSpecCollection ButtonSpecs { get; }
```

#### ButtonSpecMin

Gets access to the minimize button specification.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public ButtonSpecFormWindowMin ButtonSpecMin { get; }
```

#### ButtonSpecMax

Gets access to the maximize button specification.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public ButtonSpecFormWindowMax ButtonSpecMax { get; }
```

#### ButtonSpecClose

Gets access to the close button specification.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public ButtonSpecFormWindowClose ButtonSpecClose { get; }
```

### System Menu Properties

#### SystemMenuValues

Gets access to the system menu values for configuration.

```csharp
[Category("Appearance")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Content)]
public SystemMenuValues SystemMenuValues { get; set; }
```

#### KryptonSystemMenu

Gets access to the system menu for advanced customization.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Advanced)]
public override IKryptonSystemMenu? KryptonSystemMenu { get; }
```

### Behavior Properties

#### InertForm

Gets or sets whether the border should be inert to changes (no resizing or moving).

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public bool InertForm { get; set; }
```

#### ActiveControl

Gets or sets the active control on the container control.

```csharp
[DefaultValue(null)]
public new Control? ActiveControl { get; set; }
```

#### IsMdiContainer

Gets or sets whether the form is a container for MDI child forms.

```csharp
[Category("Behavior")]
[DefaultValue(false)]
public new bool IsMdiContainer { get; set; }
```

### State Properties

#### IsInAdministratorMode

Gets a value indicating whether the user is currently an administrator.

```csharp
[Category("Appearance")]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public bool IsInAdministratorMode { get; private set; }
```

### Chrome Properties

#### CustomCaptionArea

Gets or sets a rectangle to treat as a custom caption area.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public Rectangle CustomCaptionArea { get; set; }
```

### Manager Properties

#### ToolTipManager

Gets access to the ToolTipManager used for displaying tooltips.

```csharp
[Browsable(false)]
[DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
public ToolTipManager ToolTipManager { get; }
```

---

## Methods

### Public Methods

#### GetWindowState()

Gets the current state of the window.

```csharp
[EditorBrowsable(EditorBrowsableState.Never)]
public FormWindowState GetWindowState()
```

**Returns:** `FormWindowState` - The current window state (Normal, Minimized, or Maximized)

**Remarks:** This method queries the actual window style directly and is more accurate than the `WindowState` property which can be slightly out of date.

#### InjectViewElement(ViewBase, ViewDockStyle)

Allows an extra view element to be injected into the caption area.

```csharp
[EditorBrowsable(EditorBrowsableState.Never)]
public void InjectViewElement(ViewBase element, ViewDockStyle style)
```

**Parameters:**
- `element` - Reference to view element to inject
- `style` - Docking style of the element

**Remarks:** Used primarily for advanced customization scenarios, such as adding ribbon application buttons to the title bar.

#### RevokeViewElement(ViewBase, ViewDockStyle)

Removes a previously injected view element from the caption area.

```csharp
[EditorBrowsable(EditorBrowsableState.Never)]
public void RevokeViewElement(ViewBase element, ViewDockStyle style)
```

**Parameters:**
- `element` - Reference to view element to remove
- `style` - Docking style of the element

#### RecreateMinMaxCloseButtons()

Triggers recreation of min/max/close buttons on next layout.

```csharp
[EditorBrowsable(EditorBrowsableState.Never)]
public void RecreateMinMaxCloseButtons()
```

**Remarks:** Call this method when you've made changes that require button recreation.

#### UpdateDropShadowDraw(bool)

Updates the drop shadow around the form.

```csharp
public void UpdateDropShadowDraw(bool useDropShadow)
```

**Parameters:**
- `useDropShadow` - Whether to enable drop shadow

**Remarks:** This method is obsolete and only relevant for Windows 7, 8, and 8.1.

### Hit Testing Methods

#### HitTestMinButton(Point)

Determines if the provided point is inside the minimize button.

```csharp
public bool HitTestMinButton(Point pt)
```

**Parameters:**
- `pt` - Window-relative point to test

**Returns:** `true` if inside the button; otherwise `false`

#### HitTestMaxButton(Point)

Determines if the provided point is inside the maximize button.

```csharp
public bool HitTestMaxButton(Point pt)
```

**Parameters:**
- `pt` - Window-relative point to test

**Returns:** `true` if inside the button; otherwise `false`

#### HitTestCloseButton(Point)

Determines if the provided point is inside the close button.

```csharp
public bool HitTestCloseButton(Point pt)
```

**Parameters:**
- `pt` - Window-relative point to test

**Returns:** `true` if inside the button; otherwise `false`

### Static Administrator Methods

#### GetHasCurrentInstanceGotAdministrativeRights()

Checks if the current application instance has administrative rights.

```csharp
public static bool GetHasCurrentInstanceGotAdministrativeRights()
```

**Returns:** `true` if running with administrator privileges; otherwise `false`

#### SetIsInAdministratorMode(bool)

Sets the administrator mode state.

```csharp
public static void SetIsInAdministratorMode(bool value)
```

**Parameters:**
- `value` - Administrator mode state

#### GetIsInAdministratorMode()

Gets the current administrator mode state.

```csharp
public static bool GetIsInAdministratorMode()
```

**Returns:** `true` if in administrator mode; otherwise `false`

### IContentValues Implementation

#### GetImage(PaletteState)

Gets the image used for showing on the title bar.

```csharp
public Image? GetImage(PaletteState state)
```

**Parameters:**
- `state` - Form state

**Returns:** Image for the title bar icon

#### GetImageTransparentColor(PaletteState)

Gets the image color that should be interpreted as transparent.

```csharp
public Color GetImageTransparentColor(PaletteState state)
```

**Parameters:**
- `state` - Form state

**Returns:** Transparent color (always returns `GlobalStaticValues.EMPTY_COLOR`)

#### GetShortText()

Gets the short text used as the main caption title.

```csharp
public string GetShortText()
```

**Returns:** The form's `Text` property value

#### GetLongText()

Gets the long text used as the secondary caption title.

```csharp
public string GetLongText()
```

**Returns:** The form's `TextExtra` property value

---

## Protected Methods

### Override Methods

#### CreateRedirector()

Creates the redirector instance.

```csharp
protected override PaletteRedirect CreateRedirector()
```

**Returns:** `PaletteRedirect` derived class instance

#### OnControlAdded(ControlEventArgs)

Raises the ControlAdded event.

```csharp
protected override void OnControlAdded(ControlEventArgs e)
```

**Remarks:** Monitors for StatusStrip controls to enable status strip merging.

#### OnControlRemoved(ControlEventArgs)

Raises the ControlRemoved event.

```csharp
protected override void OnControlRemoved(ControlEventArgs e)
```

**Remarks:** Unhooks from StatusStrip events when removed.

#### OnLoad(EventArgs)

Raises the Load event.

```csharp
protected override void OnLoad(EventArgs e)
```

**Remarks:** Applies custom chrome when the control is fully created and positioned.

#### OnTextChanged(EventArgs)

Raises the TextChanged event.

```csharp
protected override void OnTextChanged(EventArgs e)
```

#### OnButtonSpecChanged(object, EventArgs)

Processes a notification from palette storage of a button spec change.

```csharp
protected override void OnButtonSpecChanged(object? sender, EventArgs e)
```

#### OnWindowActiveChanged()

Called when the active state of the window changes.

```csharp
protected override void OnWindowActiveChanged()
```

**Remarks:** Updates palettes to use active or inactive state appearance.

#### OnPaletteChanged(EventArgs)

Raises the PaletteChanged event.

```csharp
protected override void OnPaletteChanged(EventArgs e)
```

#### OnUseThemeFormChromeBorderWidthChanged(object, EventArgs)

Occurs when the UseThemeFormChromeBorderWidthChanged event is fired.

```csharp
protected override void OnUseThemeFormChromeBorderWidthChanged(object? sender, EventArgs e)
```

#### WndProc(ref Message)

Processes Windows messages.

```csharp
protected override void WndProc(ref Message m)
```

**Remarks:** Handles custom system menu behavior including:
- Right-click in non-client area
- Help button (F1)
- Context menu requests

#### OnHandleCreated(EventArgs)

Raises the HandleCreated event.

```csharp
protected override void OnHandleCreated(EventArgs e)
```

**Remarks:** Ensures proper layout for MDI containers and registers with ActiveFormTracker.

### Chrome Methods

#### WindowChromeStart()

Performs setup for custom chrome.

```csharp
protected override void WindowChromeStart()
```

#### WindowChromeEnd()

Performs cleanup when custom chrome ending.

```csharp
protected override void WindowChromeEnd()
```

#### WindowChromeHitTest(Point)

Performs hit testing for window chrome.

```csharp
protected override IntPtr WindowChromeHitTest(Point pt)
```

**Parameters:**
- `pt` - Point in window coordinates

**Returns:** Hit test result code

#### WindowChromePaint(Graphics, Rectangle)

Performs painting of the window chrome.

```csharp
protected override void WindowChromePaint(Graphics g, Rectangle bounds)
```

**Parameters:**
- `g` - Graphics instance to use for drawing
- `bounds` - Bounds enclosing the window chrome

#### OnWM_NCLBUTTONDOWN(ref Message)

Processes the WM_NCLBUTTONDOWN message when overriding window chrome.

```csharp
protected override bool OnWM_NCLBUTTONDOWN(ref Message m)
```

**Parameters:**
- `m` - A Windows-based message

**Returns:** `true` if the message was processed; otherwise `false`

**Remarks:** Handles icon click for system menu display.

#### WindowChromeLeftMouseDown(Point)

Processes the left mouse down event.

```csharp
protected override bool WindowChromeLeftMouseDown(Point windowPoint)
```

**Parameters:**
- `windowPoint` - Window coordinate of the mouse down

**Returns:** `true` if event is processed; otherwise `false`

#### OnMove(EventArgs)

Raises the Move event.

```csharp
protected override void OnMove(EventArgs e)
```

### System Menu Methods

#### IsInTitleBarArea(Point)

Determines if the specified screen point is within the title bar area.

```csharp
protected override bool IsInTitleBarArea(Point screenPoint)
```

**Parameters:**
- `screenPoint` - The screen coordinates to test

**Returns:** `true` if the point is in the title bar area; otherwise `false`

#### IsOnControlButtons(Point)

Determines if the specified screen point is over the control buttons (min/max/close).

```csharp
protected override bool IsOnControlButtons(Point screenPoint)
```

**Parameters:**
- `screenPoint` - The screen coordinates to test

**Returns:** `true` if the point is over control buttons; otherwise `false`

#### ShowSystemMenu(Point)

Shows the system menu at the specified screen location.

```csharp
protected override void ShowSystemMenu(Point screenLocation)
```

**Parameters:**
- `screenLocation` - The screen coordinates where the menu should appear

#### ShowSystemMenuAtFormTopLeft()

Shows the system menu at the form's top-left position.

```csharp
protected override void ShowSystemMenuAtFormTopLeft()
```

#### HandleSystemMenuKeyboardShortcut(Keys)

Handles keyboard shortcuts for the system menu.

```csharp
protected override bool HandleSystemMenuKeyboardShortcut(Keys keyData)
```

**Parameters:**
- `keyData` - The key data to process

**Returns:** `true` if the shortcut was handled; otherwise `false`

#### ProcessCmdKey(ref Message, Keys)

Processes a command key.

```csharp
protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
```

**Parameters:**
- `msg` - A Message, passed by reference, that represents the Win32 message to process
- `keyData` - One of the Keys values that represents the key to process

**Returns:** `true` if the character was processed; otherwise `false`

---

## Nested Types

### FormButtonSpecCollection

Collection for managing `ButtonSpecAny` instances.

```csharp
public class FormButtonSpecCollection : ButtonSpecCollection<ButtonSpecAny>
```

**Constructor:**
```csharp
public FormButtonSpecCollection(KryptonForm owner)
```

### FormFixedButtonSpecCollection

Collection for managing `ButtonSpecFormFixed` instances.

```csharp
public class FormFixedButtonSpecCollection : ButtonSpecCollection<ButtonSpecFormFixed>
```

**Constructor:**
```csharp
public FormFixedButtonSpecCollection(KryptonForm owner)
```

---

## Examples

### Example 1: Basic KryptonForm Creation

```csharp
using Krypton.Toolkit;

public partial class MyForm : KryptonForm
{
    public MyForm()
    {
        InitializeComponent();
        
        // Set basic properties
        Text = "My Application";
        TextExtra = "Version 1.0";
        HeaderStyle = HeaderStyle.Form;
    }
}
```

### Example 2: Customizing Form Appearance

```csharp
using Krypton.Toolkit;

public partial class CustomForm : KryptonForm
{
    public CustomForm()
    {
        InitializeComponent();
        
        // Modern centered title
        TitleStyle = KryptonFormTitleStyle.Modern;
        
        // Custom header style
        HeaderStyle = HeaderStyle.Primary;
        
        // Customize active state colors
        StateActive.Back.Color1 = Color.DarkBlue;
        StateActive.Back.Color2 = Color.Navy;
        StateActive.Header.Content.ShortText.Color1 = Color.White;
        
        // Customize inactive state
        StateInactive.Back.Color1 = Color.Gray;
        StateInactive.Back.Color2 = Color.DarkGray;
    }
}
```

### Example 3: Adding Custom Button Specs

```csharp
using Krypton.Toolkit;

public partial class ButtonSpecForm : KryptonForm
{
    public ButtonSpecForm()
    {
        InitializeComponent();
        
        // Add a custom help button
        var helpButton = new ButtonSpecAny
        {
            Type = PaletteButtonSpecStyle.Help,
            ToolTipTitle = "Help",
            ToolTipBody = "Click for help information"
        };
        helpButton.Click += HelpButton_Click;
        
        ButtonSpecs.Add(helpButton);
        AllowButtonSpecToolTips = true;
    }
    
    private void HelpButton_Click(object sender, EventArgs e)
    {
        MessageBox.Show("Help information", "Help");
    }
}
```

### Example 4: Customizing System Menu

```csharp
using Krypton.Toolkit;

public partial class SystemMenuForm : KryptonForm
{
    public SystemMenuForm()
    {
        InitializeComponent();
        
        // Configure system menu
        SystemMenuValues.Enabled = true;
        SystemMenuValues.ShowOnRightClick = true;
        SystemMenuValues.ShowOnIconClick = true;
        SystemMenuValues.ShowOnAltSpace = true;
        
        // Add custom menu items
        var customItem = new ToolStripMenuItem("Custom Action");
        customItem.Click += CustomItem_Click;
        SystemMenuValues.CustomMenuItems.Add(customItem);
    }
    
    private void CustomItem_Click(object sender, EventArgs e)
    {
        MessageBox.Show("Custom action executed!");
    }
}
```

### Example 5: Handling Administrator Mode

```csharp
using Krypton.Toolkit;

public partial class AdminForm : KryptonForm
{
    public AdminForm()
    {
        InitializeComponent();
        
        // Check administrator rights
        bool isAdmin = KryptonForm.GetHasCurrentInstanceGotAdministrativeRights();
        
        if (isAdmin)
        {
            TextExtra = "[Administrator]";
            StateActive.Header.Content.ShortText.Color1 = Color.Red;
        }
        else
        {
            TextExtra = "[Standard User]";
        }
    }
}
```

### Example 6: MDI Container Setup

```csharp
using Krypton.Toolkit;

public partial class MdiParentForm : KryptonForm
{
    public MdiParentForm()
    {
        InitializeComponent();
        
        // Set up as MDI container
        IsMdiContainer = true;
        
        // Create child forms
        var child1 = new KryptonForm
        {
            MdiParent = this,
            Text = "Child 1",
            Size = new Size(400, 300)
        };
        child1.Show();
        
        var child2 = new KryptonForm
        {
            MdiParent = this,
            Text = "Child 2",
            Size = new Size(400, 300)
        };
        child2.Show();
    }
}
```

### Example 7: Status Strip Merging

```csharp
using Krypton.Toolkit;

public partial class StatusStripForm : KryptonForm
{
    public StatusStripForm()
    {
        InitializeComponent();
        
        // Enable status strip merging
        AllowStatusStripMerge = true;
        
        // Create and configure status strip
        var statusStrip = new StatusStrip
        {
            Dock = DockStyle.Bottom,
            RenderMode = ToolStripRenderMode.ManagerRenderMode
        };
        
        statusStrip.Items.Add(new ToolStripStatusLabel("Ready"));
        
        Controls.Add(statusStrip);
    }
}
```

### Example 8: Disabling Window Controls

```csharp
using Krypton.Toolkit;

public partial class LockedForm : KryptonForm
{
    public LockedForm()
    {
        InitializeComponent();
        
        // Disable resizing and moving
        InertForm = true;
        FormBorderStyle = FormBorderStyle.FixedSingle;
        
        // Remove minimize and maximize buttons
        MinimizeBox = false;
        MaximizeBox = false;
    }
}
```

---

## Remarks

### Important Notes

1. **Custom Chrome**: The `KryptonForm` automatically applies custom window chrome based on the selected palette. This can be controlled via `UseThemeFormChromeBorderWidth` property.

2. **Palette Modes**: The form appearance is driven by the palette system. You can customize appearances through `StateActive`, `StateInactive`, and `StateCommon` properties.

3. **Button Specifications**: Form control buttons (Min, Max, Close) are implemented as button specifications, allowing for complete customization.

4. **System Menu**: The form provides a themed system menu that can be fully customized through `SystemMenuValues` property.

5. **Status Strip Merging**: When `AllowStatusStripMerge` is enabled and conditions are met, the status strip is merged into the form chrome for a seamless appearance.

6. **MDI Support**: Full support for MDI parent and child forms with proper chrome rendering.

7. **DPI Awareness**: The form automatically handles DPI scaling for icons and chrome elements.

### Best Practices

1. Always set the `Text` property for the main title and `TextExtra` for secondary information.
2. Use appropriate `HeaderStyle` values to match your application's visual style.
3. Customize palette states (`StateActive`, `StateInactive`) for consistent branding.
4. Enable `AllowButtonSpecToolTips` if you're adding custom button specifications with tooltips.
5. Configure `SystemMenuValues` to control system menu behavior and customize menu items.
6. Test your forms in both active and inactive states to ensure proper appearance.