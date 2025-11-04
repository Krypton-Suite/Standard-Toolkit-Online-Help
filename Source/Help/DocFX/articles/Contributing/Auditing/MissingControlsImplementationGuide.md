# Missing Controls - Implementation Guide

This guide provides implementation recommendations for the critical missing WinForms controls in the Krypton Toolkit.

---

## 1. KryptonErrorProvider (CRITICAL - Priority 1)

### Standard Control Reference
- **System.Windows.Forms.ErrorProvider**
- **Purpose:** Provides visual validation feedback for controls on forms
- **Behavior:** Shows error icons next to controls with validation errors

### Implementation Requirements

#### Core Features Needed
1. **Component Tray Control** - Non-visual component like standard ErrorProvider
2. **Error Icon Display** - Show icon next to controls with errors
3. **Tooltip on Hover** - Display error message when hovering over icon
4. **Blinking Support** - Optional blinking icon to draw attention
5. **Per-Control Errors** - Set/clear errors for individual controls
6. **Icon Alignment** - Left, Right, Top, Bottom, Middle positions
7. **Custom Icons** - Support custom error icons (themed)

#### Public API Design
```csharp
namespace Krypton.Toolkit;

[ProvideProperty("IconAlignment", typeof(Control))]
[ProvideProperty("IconPadding", typeof(Control))]
[ToolboxBitmap(typeof(KryptonErrorProvider), "ToolboxBitmaps.KryptonErrorProvider.bmp")]
public class KryptonErrorProvider : Component, IExtenderProvider, ISupportInitialize
{
    #region Properties
    
    /// <summary>Gets or sets the rate at which the error icon flashes.</summary>
    public int BlinkRate { get; set; } = 250;
    
    /// <summary>Gets or sets the blink style.</summary>
    public ErrorBlinkStyle BlinkStyle { get; set; } = ErrorBlinkStyle.BlinkIfDifferentError;
    
    /// <summary>Gets or sets the source of data to bind errors to.</summary>
    public object DataSource { get; set; }
    
    /// <summary>Gets or sets the data member to bind to.</summary>
    public string DataMember { get; set; }
    
    /// <summary>Gets or sets the icon displayed next to controls with errors.</summary>
    public Icon Icon { get; set; }
    
    /// <summary>Gets or sets the default icon alignment relative to the control.</summary>
    public ErrorIconAlignment IconAlignment { get; set; } = ErrorIconAlignment.MiddleRight;
    
    /// <summary>Gets or sets the icon padding.</summary>
    public int IconPadding { get; set; } = 0;
    
    /// <summary>Gets or sets the palette for themed error icons.</summary>
    public PaletteMode PaletteMode { get; set; } = PaletteMode.Global;
    
    /// <summary>Gets or sets custom palette.</summary>
    public PaletteBase Palette { get; set; }
    
    #endregion
    
    #region Methods
    
    /// <summary>Sets the error description string for the specified control.</summary>
    public void SetError(Control control, string value);
    
    /// <summary>Gets the error description string for the specified control.</summary>
    public string GetError(Control control);
    
    /// <summary>Sets the icon alignment for the specified control.</summary>
    public void SetIconAlignment(Control control, ErrorIconAlignment value);
    
    /// <summary>Gets the icon alignment for the specified control.</summary>
    public ErrorIconAlignment GetIconAlignment(Control control);
    
    /// <summary>Sets the icon padding for the specified control.</summary>
    public void SetIconPadding(Control control, int value);
    
    /// <summary>Gets the icon padding for the specified control.</summary>
    public int GetIconPadding(Control control);
    
    /// <summary>Clears all errors.</summary>
    public void Clear();
    
    /// <summary>Binds to a data source.</summary>
    public void BindToDataAndErrors(object newDataSource, string newDataMember);
    
    /// <summary>Updates binding when data changes.</summary>
    public void UpdateBinding();
    
    #endregion
    
    #region Events
    
    /// <summary>Occurs when the right mouse button is clicked on the error icon.</summary>
    public event EventHandler RightToLeftChanged;
    
    #endregion
}
```

#### Implementation Details

**File Structure:**
```
Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/
  - KryptonErrorProvider.cs          (Main component)
  - KryptonErrorProvider.Designer.cs (Designer support)

Source/Krypton Components/Krypton.Toolkit/Controls Visuals/
  - VisualErrorIcon.cs               (Error icon display)

Source/Krypton Components/Krypton.Toolkit/Designers/Designers/
  - KryptonErrorProviderDesigner.cs  (Designer)

Source/Krypton Components/Krypton.Toolkit/ToolboxBitmaps/
  - KryptonErrorProvider.bmp         (Toolbox icon)
```

**Key Implementation Points:**
1. Use extender provider pattern (IExtenderProvider)
2. Track control errors in Dictionary<Control, ErrorInfo>
3. Create transparent overlay windows for error icons (like standard ErrorProvider)
4. Use `VisualPopupToolTip` for error message display on hover
5. Theme icons based on current palette (error red, warning yellow, info blue)
6. Support data binding via IBindableComponent
7. Handle control parent changes, moves, resizes
8. Dispose overlay windows properly

**Themed Icons:**
- Use palette error colors
- Create icon variations: Error (red), Warning (yellow), Information (blue)
- Respect PaletteMode and custom palettes
- Support RTL layouts

---

## 2. KryptonToolTip (CRITICAL - Priority 2)

### Standard Control Reference
- **System.Windows.Forms.ToolTip**
- **Purpose:** Display help text when user hovers over controls
- **Behavior:** Popup window with styled text

### Implementation Requirements

#### Core Features Needed
1. **Component Tray Control** - Non-visual component
2. **Automatic Popup** - Show on hover
3. **Per-Control Tooltips** - Set tooltip text for any control
4. **Rich Content** - Support for title, text, icon
5. **Positioning** - Smart positioning to stay on screen
6. **Delays** - Initial, AutoPop, ReshowDelay
7. **Manual Control** - Show(), Hide() methods
8. **Theming** - Match current Krypton palette

#### Public API Design
```csharp
namespace Krypton.Toolkit;

[ProvideProperty("ToolTipTitle", typeof(Control))]
[ProvideProperty("ToolTipText", typeof(Control))]
[ProvideProperty("ToolTipIcon", typeof(Control))]
[ProvideProperty("ToolTipShadow", typeof(Control))]
[ToolboxBitmap(typeof(KryptonToolTip), "ToolboxBitmaps.KryptonToolTip.bmp")]
public class KryptonToolTip : Component, IExtenderProvider
{
    #region Properties
    
    /// <summary>Gets or sets whether tooltip is active.</summary>
    public bool Active { get; set; } = true;
    
    /// <summary>Gets or sets initial delay before showing tooltip.</summary>
    public int InitialDelay { get; set; } = 500;
    
    /// <summary>Gets or sets how long tooltip remains visible.</summary>
    public int AutoPopDelay { get; set; } = 5000;
    
    /// <summary>Gets or sets delay before showing subsequent tooltips.</summary>
    public int ReshowDelay { get; set; } = 100;
    
    /// <summary>Gets or sets whether to automatically set delays based on InitialDelay.</summary>
    public bool AutomaticDelay { get; set; } = true;
    
    /// <summary>Gets or sets the default tooltip icon.</summary>
    public ToolTipIcon ToolTipIcon { get; set; } = ToolTipIcon.None;
    
    /// <summary>Gets or sets the default tooltip title.</summary>
    public string ToolTipTitle { get; set; } = string.Empty;
    
    /// <summary>Gets or sets whether to show always (even when parent inactive).</summary>
    public bool ShowAlways { get; set; } = false;
    
    /// <summary>Gets or sets whether to use fade effect.</summary>
    public bool UseFading { get; set; } = true;
    
    /// <summary>Gets or sets whether tooltip is balloon style.</summary>
    public bool IsBalloon { get; set; } = false;
    
    /// <summary>Gets or sets the palette mode.</summary>
    public PaletteMode PaletteMode { get; set; } = PaletteMode.Global;
    
    /// <summary>Gets or sets custom palette.</summary>
    public PaletteBase Palette { get; set; }
    
    /// <summary>Gets or sets the tooltip style.</summary>
    public LabelStyle ToolTipStyle { get; set; } = LabelStyle.ToolTip;
    
    /// <summary>Gets or sets whether to show shadow.</summary>
    public bool ToolTipShadow { get; set; } = true;
    
    #endregion
    
    #region Methods
    
    /// <summary>Sets the tooltip text for a control.</summary>
    public void SetToolTip(Control control, string caption);
    
    /// <summary>Gets the tooltip text for a control.</summary>
    public string GetToolTip(Control control);
    
    /// <summary>Sets the tooltip title for a control.</summary>
    public void SetToolTipTitle(Control control, string title);
    
    /// <summary>Gets the tooltip title for a control.</summary>
    public string GetToolTipTitle(Control control);
    
    /// <summary>Sets the tooltip icon for a control.</summary>
    public void SetToolTipIcon(Control control, ToolTipIcon icon);
    
    /// <summary>Gets the tooltip icon for a control.</summary>
    public ToolTipIcon GetToolTipIcon(Control control);
    
    /// <summary>Sets whether shadow is shown for a control.</summary>
    public void SetToolTipShadow(Control control, bool shadow);
    
    /// <summary>Gets whether shadow is shown for a control.</summary>
    public bool GetToolTipShadow(Control control);
    
    /// <summary>Manually shows a tooltip.</summary>
    public void Show(string text, IWin32Window window);
    
    /// <summary>Manually shows a tooltip at specific position.</summary>
    public void Show(string text, IWin32Window window, Point point);
    
    /// <summary>Manually shows a tooltip at specific position for duration.</summary>
    public void Show(string text, IWin32Window window, Point point, int duration);
    
    /// <summary>Manually shows a tooltip with title.</summary>
    public void Show(string text, string title, ToolTipIcon icon, IWin32Window window, Point point, int duration);
    
    /// <summary>Hides the tooltip.</summary>
    public void Hide(IWin32Window window);
    
    /// <summary>Removes all tooltips.</summary>
    public void RemoveAll();
    
    #endregion
    
    #region Events
    
    /// <summary>Occurs before the tooltip is shown.</summary>
    public event EventHandler<ToolTipEventArgs> Popup;
    
    /// <summary>Occurs when tooltip is drawn (for owner draw).</summary>
    public event EventHandler<DrawToolTipEventArgs> Draw;
    
    #endregion
}
```

#### Implementation Details

**File Structure:**
```
Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/
  - KryptonToolTip.cs                (Main component)

Source/Krypton Components/Krypton.Toolkit/Controls Visuals/
  - VisualToolTip.cs                 (Enhanced VisualPopupToolTip)

Source/Krypton Components/Krypton.Toolkit/Designers/Designers/
  - KryptonToolTipDesigner.cs        (Designer)

Source/Krypton Components/Krypton.Toolkit/EventArgs/
  - DrawToolTipEventArgs.cs          (Custom draw event args)
```

**Key Implementation Points:**
1. Leverage existing `VisualPopupToolTip` class
2. Use `ToolTipManager` internally for timing
3. Track control tooltip info in Dictionary<Control, ToolTipInfo>
4. Hook control mouse events (MouseEnter, MouseMove, MouseLeave)
5. Position tooltip using smart positioning logic from existing popups
6. Theme using current palette (ToolTip style)
7. Support fading in/out with timers
8. Handle control parent/visibility changes

**Integration with Existing Code:**
- Many Krypton controls already have `ToolTipValues` property
- KryptonToolTip should work alongside existing tooltip infrastructure
- Consider adding `[ExtenderProvidedProperty]` support to Krypton controls

---

## 3. KryptonFlowLayoutPanel (HIGH - Priority 3)

### Standard Control Reference
- **System.Windows.Forms.FlowLayoutPanel**
- **Purpose:** Dynamically arrange child controls in flow direction
- **Behavior:** Auto-wrap controls based on available space

### Implementation Requirements

#### Core Features Needed
1. **Panel Container** - Derives from Panel or custom container
2. **Flow Direction** - LeftToRight, RightToLeft, TopDown, BottomUp
3. **Auto-Wrapping** - Wrap to next row/column when space runs out
4. **WrapContents** - Enable/disable wrapping
5. **FlowBreak** - Force break after specific controls
6. **Padding/Margin** - Respect control margins and panel padding
7. **Theming** - Themed background and borders

#### Public API Design
```csharp
namespace Krypton.Toolkit;

[ToolboxBitmap(typeof(KryptonFlowLayoutPanel), "ToolboxBitmaps.KryptonFlowLayoutPanel.bmp")]
[Designer(typeof(KryptonFlowLayoutPanelDesigner))]
[Docking(DockingBehavior.Ask)]
[ProvideProperty("FlowBreak", typeof(Control))]
public class KryptonFlowLayoutPanel : KryptonPanel, IExtenderProvider
{
    #region Properties
    
    /// <summary>Gets or sets the flow direction.</summary>
    public FlowDirection FlowDirection { get; set; } = FlowDirection.LeftToRight;
    
    /// <summary>Gets or sets whether contents wrap.</summary>
    public bool WrapContents { get; set; } = true;
    
    /// <summary>Gets or sets whether auto-scroll is enabled.</summary>
    public override bool AutoScroll { get; set; } = false;
    
    /// <summary>Gets or sets the auto-scroll margin.</summary>
    public new Size AutoScrollMargin { get; set; }
    
    /// <summary>Gets or sets the auto-scroll minimum size.</summary>
    public new Size AutoScrollMinSize { get; set; }
    
    #endregion
    
    #region Methods
    
    /// <summary>Sets whether a control should cause a flow break.</summary>
    public void SetFlowBreak(Control control, bool value);
    
    /// <summary>Gets whether a control causes a flow break.</summary>
    public bool GetFlowBreak(Control control);
    
    #endregion
}
```

#### Implementation Details

**File Structure:**
```
Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/
  - KryptonFlowLayoutPanel.cs        (Main control)

Source/Krypton Components/Krypton.Toolkit/View Layout/
  - ViewLayoutFlow.cs                (Flow layout engine)

Source/Krypton Components/Krypton.Toolkit/Designers/Designers/
  - KryptonFlowLayoutPanelDesigner.cs (Designer)
```

**Key Implementation Points:**
1. Inherit from `KryptonPanel` for theming support
2. Override `OnLayout()` to implement flow algorithm
3. Use `IExtenderProvider` for `FlowBreak` property
4. Track flow break controls in HashSet<Control>
5. Implement flow layout algorithm:
   - Calculate available space
   - Position controls left-to-right (or flow direction)
   - Wrap when control doesn't fit
   - Handle flow breaks
   - Respect margins and padding
6. Support RTL layouts
7. Handle control size changes and visibility
8. Designer support for setting FlowBreak in properties window

**Flow Algorithm Pseudo-code:**
```csharp
protected override void OnLayout(LayoutEventArgs e)
{
    int x = Padding.Left;
    int y = Padding.Top;
    int rowHeight = 0;
    int availableWidth = ClientSize.Width - Padding.Horizontal;
    
    foreach (Control control in Controls)
    {
        if (!control.Visible) continue;
        
        int controlWidth = control.Width + control.Margin.Horizontal;
        int controlHeight = control.Height + control.Margin.Vertical;
        
        // Check if wrap needed
        if (WrapContents && x + controlWidth > availableWidth && x > Padding.Left)
        {
            x = Padding.Left;
            y += rowHeight;
            rowHeight = 0;
        }
        
        // Position control
        control.Location = new Point(
            x + control.Margin.Left,
            y + control.Margin.Top
        );
        
        // Update position
        x += controlWidth;
        rowHeight = Math.Max(rowHeight, controlHeight);
        
        // Check for flow break
        if (GetFlowBreak(control))
        {
            x = Padding.Left;
            y += rowHeight;
            rowHeight = 0;
        }
    }
    
    base.OnLayout(e);
}
```

---

## 4. KryptonHelpProvider (MEDIUM - Priority 4)

### Standard Control Reference
- **System.Windows.Forms.HelpProvider**
- **Purpose:** Context-sensitive help (F1 key, help button)
- **Behavior:** Shows help when F1 pressed or help button clicked

### Implementation Requirements

#### Core Features Needed
1. **Component Tray Control** - Non-visual component
2. **F1 Key Support** - Show help when F1 pressed
3. **Help String** - Simple string per control
4. **Help Keyword** - Keyword for help file lookup
5. **Help Navigator** - How to navigate help (Topic, Find, Index, etc.)
6. **Help Button** - Show help button on forms
7. **HTML Help Support** - Open CHM files
8. **Online Help Support** - Open URLs

#### Public API Design (Brief)
```csharp
[ProvideProperty("HelpKeyword", typeof(Control))]
[ProvideProperty("HelpNavigator", typeof(Control))]
[ProvideProperty("HelpString", typeof(Control))]
[ProvideProperty("ShowHelp", typeof(Control))]
public class KryptonHelpProvider : Component, IExtenderProvider
{
    public string HelpNamespace { get; set; }
    
    public void SetHelpKeyword(Control ctl, string keyword);
    public string GetHelpKeyword(Control ctl);
    
    public void SetHelpNavigator(Control ctl, HelpNavigator navigator);
    public HelpNavigator GetHelpNavigator(Control ctl);
    
    public void SetHelpString(Control ctl, string helpString);
    public string GetHelpString(Control ctl);
    
    public void SetShowHelp(Control ctl, bool value);
    public bool GetShowHelp(Control ctl);
}
```

---

## 5. KryptonNotifyIcon (MEDIUM - Priority 5)

### Standard Control Reference
- **System.Windows.Forms.NotifyIcon**
- **Purpose:** System tray icon
- **Behavior:** Icon in system tray with context menu and notifications

### Implementation Requirements

#### Core Features Needed
1. **Component Tray Control** - Non-visual component
2. **System Tray Icon** - Show icon in notification area
3. **Tooltip** - Hover text
4. **Context Menu** - Right-click menu (use `KryptonContextMenu`)
5. **Balloon Tips** - Show balloon notifications (legacy)
6. **Click Events** - Single click, double click
7. **Icon Animation** - Change icon for animation effects

#### Public API Design (Brief)
```csharp
public class KryptonNotifyIcon : Component
{
    public Icon Icon { get; set; }
    public string Text { get; set; }
    public bool Visible { get; set; }
    public KryptonContextMenu ContextMenu { get; set; }
    public ToolTipIcon BalloonTipIcon { get; set; }
    public string BalloonTipText { get; set; }
    public string BalloonTipTitle { get; set; }
    
    public void ShowBalloonTip(int timeout);
    public void ShowBalloonTip(int timeout, string tipTitle, string tipText, ToolTipIcon tipIcon);
    
    public event MouseEventHandler MouseClick;
    public event MouseEventHandler MouseDoubleClick;
    public event EventHandler BalloonTipClicked;
    // ... more events
}
```

**Implementation Note:**
- Use P/Invoke to Shell_NotifyIcon API
- Integrate with `KryptonContextMenu` for themed menus
- Consider using Windows 10 toast notifications instead of balloon tips
- Could integrate with `KryptonToastNotification` for modern notifications

---

## 6. KryptonTabControl (LOW - Priority 6)

### Note
This is a **wrapper/simplified mode** for KryptonNavigator, not a new control.

### Implementation Approach

**Option A: Wrapper Class**
```csharp
/// <summary>
/// Simplified tab control wrapping KryptonNavigator
/// </summary>
public class KryptonTabControl : KryptonNavigator
{
    public KryptonTabControl()
    {
        // Set to simple tab mode
        NavigatorMode = NavigatorMode.BarTabGroup;
        
        // Hide complex features
        // Simplify API surface
    }
    
    // Expose simplified API similar to TabControl
    [Browsable(false)]
    public new NavigatorMode NavigatorMode
    {
        get => base.NavigatorMode;
        set => base.NavigatorMode = NavigatorMode.BarTabGroup; // Force tab mode
    }
    
    public TabAlignment Alignment { get; set; }
    
    // Map TabPages to KryptonPages
    [DesignerSerializationVisibility(DesignerSerializationVisibility.Hidden)]
    public TabPageCollection TabPages => /* wrapper around Pages */;
}
```

**Option B: Documentation**
Instead of new control, provide documentation showing how to use Navigator as simple TabControl:
- Set `NavigatorMode = NavigatorMode.BarTabGroup`
- Hide unnecessary properties
- Provide migration guide

---

## Implementation Priority Summary

| Control | Priority | Complexity | Impact | Estimated Effort |
|---------|----------|------------|--------|------------------|
| KryptonErrorProvider | ⚠️ CRITICAL | Medium | Very High | 2-3 weeks |
| KryptonToolTip | ⚠️ CRITICAL | Medium | High | 2-3 weeks |
| KryptonFlowLayoutPanel | HIGH | Medium | Medium-High | 1-2 weeks |
| KryptonHelpProvider | MEDIUM | Low | Medium | 1 week |
| KryptonNotifyIcon | MEDIUM | Low-Medium | Medium | 1 week |
| ~~KryptonTabControl~~ | ✅ DONE | N/A | N/A | Already replaced by Navigator |

**Total Estimated Effort:** 7-10 weeks for all critical and high priority controls

---

## Testing Strategy

For each control:

1. **Unit Tests** - Basic functionality
2. **Designer Tests** - Toolbox, property grid, serialization
3. **Theme Tests** - All built-in themes
4. **DPI Tests** - Various DPI settings
5. **Accessibility Tests** - Screen readers, keyboard navigation
6. **RTL Tests** - Right-to-left layouts
7. **Data Binding Tests** - (ErrorProvider)
8. **Integration Tests** - Works with other Krypton controls

---

## Resources Needed

1. **Developer Time** - 7-12 weeks total
2. **Designer Time** - Toolbox icons, designer support
3. **Tester Time** - Comprehensive testing
4. **Documentation Time** - API docs, migration guides, samples

---

## Success Criteria

- [ ] All controls match standard WinForms API where applicable
- [ ] All controls support current Krypton theming system
- [ ] All controls have designer support
- [ ] All controls have comprehensive XML documentation
- [ ] All controls have sample usage in TestForm
- [ ] All controls support accessibility features
- [ ] All controls support high DPI
- [ ] All controls support RTL layouts
- [ ] Migration guide published
- [ ] NuGet packages updated

---

**Next Steps:**
1. Review and approve implementation designs
2. Create GitHub issues for each control
3. Assign developers
4. Set milestones
5. Begin implementation with KryptonErrorProvider (highest priority)

