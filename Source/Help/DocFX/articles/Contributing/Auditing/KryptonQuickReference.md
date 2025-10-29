# Krypton Toolkit - Quick Reference Card

## 🚀 Standard WinForms → Krypton Migration

### ✅ Direct Replacements (Just change the class name!)
```csharp
// Forms & Containers
Form                  → KryptonForm
Panel                 → KryptonPanel
GroupBox              → KryptonGroupBox
SplitContainer        → KryptonSplitContainer
TableLayoutPanel      → KryptonTableLayoutPanel

// Input Controls
Button                → KryptonButton
TextBox               → KryptonTextBox
RichTextBox           → KryptonRichTextBox
MaskedTextBox         → KryptonMaskedTextBox
CheckBox              → KryptonCheckBox
RadioButton           → KryptonRadioButton
ComboBox              → KryptonComboBox
ListBox               → KryptonListBox
CheckedListBox        → KryptonCheckedListBox
NumericUpDown         → KryptonNumericUpDown
DomainUpDown          → KryptonDomainUpDown
DateTimePicker        → KryptonDateTimePicker
MonthCalendar         → KryptonMonthCalendar
TrackBar              → KryptonTrackBar

// Display Controls
Label                 → KryptonLabel
LinkLabel             → KryptonLinkLabel
PictureBox            → KryptonPictureBox
ProgressBar           → KryptonProgressBar
ScrollBar             → KryptonScrollBar

// Data Controls
DataGridView          → KryptonDataGridView
ListView              → KryptonListView
TreeView              → KryptonTreeView
PropertyGrid          → KryptonPropertyGrid

// Dialogs
MessageBox            → KryptonMessageBox
ColorDialog           → KryptonColorDialog
FontDialog            → KryptonFontDialog
OpenFileDialog        → KryptonOpenFileDialog
SaveFileDialog        → KryptonSaveFileDialog
FolderBrowserDialog   → KryptonFolderBrowserDialog
PrintDialog           → KryptonPrintDialog

// Menus & Toolbars
MenuStrip             → MenuStrip  // Automatically themed (font not customizable)
ContextMenuStrip      → KryptonContextMenu  // Full replacement with MORE features!
ToolStrip             → KryptonToolStrip (or standard ToolStrip - both themed)
StatusStrip           → KryptonStatusStrip (or standard StatusStrip - both themed)
ToolStripMenuItem     → KryptonToolStripMenuItem
ToolStripComboBox     → KryptonToolStripComboBox

// Navigation (Containers)
TabControl            → KryptonNavigator  // Full replacement with 15+ modes!

// Web
WebBrowser            → KryptonWebBrowser
```

---

## ⚠️ Missing Controls (Use Standard WinForms)

```csharp
// These don't have Krypton versions - use standard (NOT themed):
ErrorProvider         → ErrorProvider (standard) ❌
ToolTip               → ToolTip (standard) ❌
FlowLayoutPanel       → FlowLayoutPanel (standard) ❌
HelpProvider          → HelpProvider (standard) ❌
NotifyIcon            → NotifyIcon (standard) ❌

// These ARE fully replaced (not missing):
TabControl            → KryptonNavigator ✅
ContextMenuStrip      → KryptonContextMenu ✅

// These ARE themed automatically (just use the standard control):
MenuStrip             → MenuStrip ✅ (Auto-themed, but font not customizable)
ToolStrip             → ToolStrip or KryptonToolStrip ✅ (Both themed)
StatusStrip           → StatusStrip or KryptonStatusStrip ✅ (Both themed)

// Non-visual components (use standard)
Timer                 → System.Windows.Forms.Timer
ImageList             → ImageList
BindingSource         → BindingSource
BindingNavigator      → BindingNavigator (or build with KryptonToolStrip)
BackgroundWorker      → BackgroundWorker
FileSystemWatcher     → FileSystemWatcher
```

---

## 🎯 Special Cases

### TabControl → KryptonNavigator (Full Replacement!)
```csharp
// KryptonNavigator REPLACES TabControl with MORE features!
// For simple tabs, use BarTabGroup mode (like TabControl):
var navigator = new KryptonNavigator
{
    NavigatorMode = NavigatorMode.BarTabGroup  // Simple tab mode
};

// Add pages (just like TabPages)
var page1 = new KryptonPage 
{ 
    Text = "Page 1",
    // Add controls to page
};
var page2 = new KryptonPage { Text = "Page 2" };
navigator.Pages.Add(page1);
navigator.Pages.Add(page2);

// Advanced: Navigator has 15+ modes!
// - BarRibbonTabGroup (ribbon-style tabs)
// - OutlookFull (Outlook navigation pane)
// - OutlookMini (mini Outlook nav)
// - HeaderBarCheckButtonGroup (buttons in header)
// - StackCheckButtonGroup (stacked buttons)
// ... and many more!
```

### MenuStrip → Automatically Themed!
```csharp
// Good news: Standard MenuStrip is automatically themed by Krypton!
var menuStrip = new MenuStrip();  // This will be Krypton-themed!

// Add File menu
var fileMenu = new ToolStripMenuItem("&File");
fileMenu.DropDownItems.Add("&New", null, OnNew);
fileMenu.DropDownItems.Add("&Open", null, OnOpen);
fileMenu.DropDownItems.Add(new ToolStripSeparator());
fileMenu.DropDownItems.Add("E&xit", null, OnExit);
menuStrip.Items.Add(fileMenu);

// Add Edit menu
var editMenu = new ToolStripMenuItem("&Edit");
editMenu.DropDownItems.Add("&Cut", null, OnCut);
editMenu.DropDownItems.Add("&Copy", null, OnCopy);
editMenu.DropDownItems.Add("&Paste", null, OnPaste);
menuStrip.Items.Add(editMenu);

Controls.Add(menuStrip);

// ⚠️ LIMITATION: Font cannot be customized (controlled by Krypton renderer)
// menuStrip.Font = new Font("Arial", 12); // This won't work

// For advanced scenarios requiring font control:
// Option 1: Use KryptonRibbon (modern Office-style, font customizable)
// Option 2: Use KryptonToolStrip (toolbar-style menu, font customizable)
// Option 3: Use KryptonContextMenu (rich menus, font customizable)
```

---

## 🆕 Bonus Krypton-Only Controls

These controls don't exist in standard WinForms:

```csharp
// Modern UI
KryptonToastNotification    // Modern toast notifications
KryptonToggleSwitch         // iOS-style toggle
KryptonCommandLinkButton    // Vista-style command link
KryptonBreadCrumb           // Breadcrumb navigation
KryptonSplashScreen         // Splash screen

// Advanced Components
KryptonRibbon               // Office-style ribbon
KryptonNavigator            // Advanced tab control
KryptonDocking              // Docking panels
KryptonWorkspace            // Workspace management

// Enhanced Dialogs
KryptonTaskDialog           // Modern task dialog
KryptonInformationBox       // Enhanced message box
KryptonInputBox             // Input dialog
KryptonAboutBox             // About dialog
KryptonExceptionDialog      // Exception display

// Specialized
KryptonHeader               // Section header
KryptonHeaderGroup          // Panel with header
KryptonBorderEdge           // Border/separator
KryptonDropButton           // Button with dropdown
KryptonColorButton          // Color picker button
KryptonCalcInput            // Calculator input
KryptonWrapLabel            // Auto-wrapping label
KryptonThemeBrowser         // Theme selection UI
```

---

## 🎨 Theming Basics

### Set Global Theme
```csharp
// In Program.cs or Form.Load
KryptonManager manager = new KryptonManager();
manager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;

// Or use static method
KryptonManager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
```

### Available Themes
```csharp
PaletteMode.Microsoft365Black
PaletteMode.Microsoft365Blue
PaletteMode.Microsoft365Silver
PaletteMode.Microsoft365White
PaletteMode.Office2007Blue
PaletteMode.Office2007Silver
PaletteMode.Office2010Blue
PaletteMode.Office2010Silver
PaletteMode.Office2010Black
PaletteMode.Office2013White
PaletteMode.SparkleBlue
PaletteMode.SparkleOrange
PaletteMode.SparklePurple
PaletteMode.ProfessionalOffice2003
PaletteMode.ProfessionalSystem
// ... and many more
```

### Per-Control Theme Override
```csharp
var button = new KryptonButton
{
    PaletteMode = PaletteMode.Office2007Blue  // Override global theme
};
```

---

## 💡 Common Patterns

### Form with Krypton Controls
```csharp
public partial class MyForm : KryptonForm  // Use KryptonForm
{
    public MyForm()
    {
        InitializeComponent();
        
        // Theme is automatically applied
    }
}
```

### Validation (Until KryptonErrorProvider Exists)
```csharp
// Use standard ErrorProvider (not themed)
var errorProvider = new ErrorProvider();
errorProvider.SetError(textBox, "This field is required");

// Or use control state
kryptonTextBox.StateCommon.Border.Color1 = Color.Red;
kryptonLabel.StateCommon.ShortText.Color1 = Color.Red;
kryptonLabel.Text = "Error: This field is required";
```

### Tooltips (Until KryptonToolTip Exists)
```csharp
// Option 1: Use standard ToolTip (not themed)
var toolTip = new ToolTip();
toolTip.SetToolTip(kryptonButton, "Click me!");

// Option 2: Use control's built-in tooltip
kryptonButton.ToolTipValues.Heading = "Help";
kryptonButton.ToolTipValues.Description = "Click me!";
kryptonButton.ToolTipValues.EnableToolTips = true;
```

### FlowLayoutPanel (Until KryptonFlowLayoutPanel Exists)
```csharp
// Use standard FlowLayoutPanel
var flow = new FlowLayoutPanel
{
    BackColor = Color.Transparent,  // Match Krypton background
    FlowDirection = FlowDirection.LeftToRight,
    WrapContents = true
};

// Add Krypton controls to it
flow.Controls.Add(new KryptonButton { Text = "Button 1" });
flow.Controls.Add(new KryptonButton { Text = "Button 2" });
```

### Context Menu
```csharp
// KryptonContextMenu is MORE powerful than ContextMenuStrip!
var contextMenu = new KryptonContextMenu();

var menuItems = new KryptonContextMenuItems();
menuItems.Items.Add(new KryptonContextMenuItem("Cut"));
menuItems.Items.Add(new KryptonContextMenuItem("Copy"));
menuItems.Items.Add(new KryptonContextMenuItem("Paste"));
menuItems.Items.Add(new KryptonContextMenuSeparator());

// You can add rich items not available in ContextMenuStrip:
menuItems.Items.Add(new KryptonContextMenuCheckBox("Show Toolbar"));
menuItems.Items.Add(new KryptonContextMenuColorColumns(16)); // Color picker!
menuItems.Items.Add(new KryptonContextMenuMonthCalendar());  // Calendar!
menuItems.Items.Add(new KryptonContextMenuProgressBar());    // Progress bar!

contextMenu.Items.Add(menuItems);

kryptonTextBox.KryptonContextMenu = contextMenu;  // Assign to control
```

### System Tray Icon (Until KryptonNotifyIcon Exists)
```csharp
// Use standard NotifyIcon with KryptonContextMenu
var notifyIcon = new NotifyIcon
{
    Icon = SystemIcons.Application,
    Text = "My App",
    Visible = true
};

var contextMenu = new KryptonContextMenu();
// ... setup context menu ...

notifyIcon.MouseClick += (s, e) =>
{
    if (e.Button == MouseButtons.Right)
    {
        contextMenu.Show(Cursor.Position);
    }
};
```

---

## 🔧 DataGridView Enhanced Columns

Krypton adds these special columns to DataGridView:

```csharp
var grid = new KryptonDataGridView();

// Standard columns (themed)
grid.Columns.Add(new KryptonDataGridViewTextBoxColumn());
grid.Columns.Add(new KryptonDataGridViewCheckBoxColumn());
grid.Columns.Add(new KryptonDataGridViewComboBoxColumn());
grid.Columns.Add(new KryptonDataGridViewButtonColumn());
grid.Columns.Add(new KryptonDataGridViewLinkColumn());
grid.Columns.Add(new KryptonDataGridViewImageColumn());

// Krypton-enhanced columns
grid.Columns.Add(new KryptonDataGridViewDateTimePickerColumn());
grid.Columns.Add(new KryptonDataGridViewNumericUpDownColumn());
grid.Columns.Add(new KryptonDataGridViewDomainUpDownColumn());
grid.Columns.Add(new KryptonDataGridViewMaskedTextBoxColumn());
grid.Columns.Add(new KryptonDataGridViewProgressColumn());  // Progress bar!
grid.Columns.Add(new KryptonDataGridViewRatingColumn());    // Star rating!
grid.Columns.Add(new KryptonDataGridViewIconColumn());      // Icon display
```

---

## 📚 Documentation Links

- **Full Audit:** [Krypton Toolkit Audit](KryptonToolkitAudit.md) - Complete control inventory
- **Summary:** [Krypton Audit Summary](KryptonAuditSummary.md) - Executive summary and gaps
- **Implementation Guide:** [Missing Controls Implementation Guide](MissingControlsImplementationGuide.md) - How to implement missing controls
- **This File:** [Krypton Quick Reference](KryptonQuickReference.md) - Quick reference card
- **RTL Audit:** [Krypton RTL Audit Summary](KryptonRTLAuditSummary.md) - Summarises which controls need RTL support

---

## 🐛 Common Issues

### Issue: Controls not themed
**Solution:** Ensure form inherits from `KryptonForm` or add `KryptonManager` component

### Issue: Standard dialogs not themed
**Solution:** Use `Krypton*Dialog` classes instead of standard dialogs

### Issue: MenuStrip not themed
**Solution:** It IS themed! Standard `MenuStrip` automatically adopts Krypton theming when used in a `KryptonForm` or with `KryptonManager`

### Issue: Can't change MenuStrip font
**Solution:** This is a limitation - MenuStrip font is controlled by the Krypton renderer and cannot be customized. For font control, use:
- `KryptonRibbon` (font customizable)
- `KryptonToolStrip` (font customizable)
- `KryptonContextMenu` (font customizable)

### Issue: ContextMenuStrip not themed
**Solution:** Use `KryptonContextMenu` instead of `ContextMenuStrip` - it's a full replacement with MORE features (colors, calendars, progress bars, etc.)!

### Issue: Need validation error icons
**Solution:** Use standard `ErrorProvider` (not themed) - or wait for `KryptonErrorProvider`

### Issue: Need tooltips
**Solution:** Use standard `ToolTip` (not themed) or use control's `ToolTipValues` property

### Issue: Need FlowLayout
**Solution:** Use standard `FlowLayoutPanel` with `BackColor = Color.Transparent`

---

## ⚡ Quick Start Template

```csharp
using Krypton.Toolkit;

namespace MyKryptonApp
{
    public partial class MainForm : KryptonForm
    {
        private readonly KryptonManager _manager = new KryptonManager();
        
        public MainForm()
        {
            InitializeComponent();
            
            // Set theme
            _manager.GlobalPaletteMode = PaletteMode.Microsoft365Blue;
            
            // Add controls
            var button = new KryptonButton
            {
                Text = "Click Me!",
                Location = new Point(10, 10)
            };
            button.Click += Button_Click;
            Controls.Add(button);
            
            var textBox = new KryptonTextBox
            {
                Location = new Point(10, 50),
                Width = 200
            };
            textBox.CueHint.CueHintText = "Enter text...";  // Watermark
            Controls.Add(textBox);
        }
        
        private void Button_Click(object sender, EventArgs e)
        {
            KryptonMessageBox.Show("Hello, Krypton!", "Info",
                MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}
```

