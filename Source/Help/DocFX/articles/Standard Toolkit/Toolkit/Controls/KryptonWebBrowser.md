# KryptonWebBrowser

## Overview

`KryptonWebBrowser` is a themed wrapper around the standard Windows Forms `WebBrowser` control, providing Krypton palette integration and context menu support. It's primarily designed for use as a rich text editor or for displaying HTML content within themed applications.

**Namespace:** `Krypton.Toolkit`  
**Assembly:** Krypton.Toolkit  
**Inheritance:** `Object` → `MarshalByRefObject` → `Component` → `Control` → `WebBrowser` → `KryptonWebBrowser`

## Key Features

### Palette Integration
- Integrates with Krypton palette system
- Automatic renderer creation
- Theme-aware context menus

### Context Menu Support
- Native `KryptonContextMenu` support
- Theme-aware `ContextMenuStrip` rendering
- Right-click and keyboard activation

### Rich Text Editing
- Can be used as a WYSIWYG HTML editor
- Full WebBrowser functionality
- Document manipulation

### Double Buffering
- Optimized rendering
- Reduced flicker
- Smooth resizing

---

## Constructor

### KryptonWebBrowser()

Initializes a new instance with Krypton palette integration.

```csharp
public KryptonWebBrowser()
```

**Initialization:**
- Enables double buffering
- Sets up palette integration
- Connects to current global palette

---

## Properties

### KryptonContextMenu
Gets or sets the KryptonContextMenu to show when right-clicked.

```csharp
[Category("Behavior")]
[Description("The shortcut menu to show when the user right-clicks the page.")]
[DefaultValue(null)]
public KryptonContextMenu? KryptonContextMenu { get; set; }
```

**Example:**
```csharp
var contextMenu = new KryptonContextMenu();
var menuItems = contextMenu.Items.Add(new KryptonContextMenuItems());
menuItems.Items.Add(new KryptonContextMenuItem("Copy", null, OnCopy));
menuItems.Items.Add(new KryptonContextMenuItem("Paste", null, OnPaste));

kryptonWebBrowser1.KryptonContextMenu = contextMenu;
```

---

### ContextMenuStrip
Gets or sets the Windows Forms ContextMenuStrip (themed automatically).

```csharp
[Category("Behavior")]
[Description("The Winforms shortcut menu to show when the user right-clicks the page.")]
[DefaultValue(null)]
public override ContextMenuStrip? ContextMenuStrip { get; set; }
```

**Remarks:**
- Automatically applies Krypton renderer when shown
- Consider using `KryptonContextMenu` for better integration

**Example:**
```csharp
var contextMenu = new ContextMenuStrip();
contextMenu.Items.Add("Copy", null, OnCopy);
contextMenu.Items.Add("Paste", null, OnPaste);

kryptonWebBrowser1.ContextMenuStrip = contextMenu;
// Renderer is applied automatically
```

---

### Inherited WebBrowser Properties

All standard `WebBrowser` properties are available:

#### DocumentText
Gets or sets the HTML content displayed in the control.

```csharp
public string DocumentText { get; set; }
```

---

#### Url
Gets or sets the URL of the current document.

```csharp
public Uri Url { get; set; }
```

---

#### Document
Gets the HtmlDocument representing the page currently displayed.

```csharp
[Browsable(false)]
public HtmlDocument Document { get; }
```

---

#### AllowNavigation
Gets or sets whether navigation to other pages is allowed.

```csharp
[DefaultValue(true)]
public bool AllowNavigation { get; set; }
```

---

#### AllowWebBrowserDrop
Gets or sets whether drag-and-drop operations are allowed.

```csharp
[DefaultValue(true)]
public bool AllowWebBrowserDrop { get; set; }
```

---

#### IsWebBrowserContextMenuEnabled
Gets or sets whether the default browser context menu is enabled.

```csharp
[DefaultValue(true)]
public bool IsWebBrowserContextMenuEnabled { get; set; }
```

**Remarks:**
- Set to `false` when using `KryptonContextMenu` or `ContextMenuStrip`

---

#### WebBrowserShortcutsEnabled
Gets or sets whether shortcuts are enabled.

```csharp
[DefaultValue(true)]
public bool WebBrowserShortcutsEnabled { get; set; }
```

---

#### ScriptErrorsSuppressed
Gets or sets whether script error dialogs are suppressed.

```csharp
[DefaultValue(false)]
public bool ScriptErrorsSuppressed { get; set; }
```

---

#### ScrollBarsEnabled
Gets or sets whether scroll bars are displayed.

```csharp
[DefaultValue(true)]
public bool ScrollBarsEnabled { get; set; }
```

---

## Methods

### Navigation Methods

#### Navigate(string)
Navigates to the specified URL.

```csharp
public void Navigate(string urlString)
```

**Example:**
```csharp
kryptonWebBrowser1.Navigate("https://www.example.com");
```

---

#### Navigate(Uri)
Navigates to the specified URI.

```csharp
public void Navigate(Uri url)
```

---

#### GoBack()
Navigates to the previous page in the history.

```csharp
public bool GoBack()
```

---

#### GoForward()
Navigates to the next page in the history.

```csharp
public bool GoForward()
```

---

#### GoHome()
Navigates to the user's home page.

```csharp
public void GoHome()
```

---

#### Refresh()
Reloads the current page.

```csharp
public override void Refresh()
```

---

#### Stop()
Cancels any pending navigation.

```csharp
public void Stop()
```

---

### Document Methods

#### ShowPrintDialog()
Opens the print dialog.

```csharp
public void ShowPrintDialog()
```

---

#### ShowPrintPreviewDialog()
Opens the print preview dialog.

```csharp
public void ShowPrintPreviewDialog()
```

---

#### ShowPropertiesDialog()
Opens the page properties dialog.

```csharp
public void ShowPropertiesDialog()
```

---

#### ShowSaveAsDialog()
Opens the save file dialog.

```csharp
public void ShowSaveAsDialog()
```

---

### Palette Methods

#### GetResolvedPalette()
Gets the resolved palette being used for rendering.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public PaletteBase GetResolvedPalette()
```

---

#### CreateToolStripRenderer()
Creates a ToolStripRenderer appropriate for the current palette.

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Advanced)]
public ToolStripRenderer? CreateToolStripRenderer()
```

**Remarks:**
- Used internally to theme ContextMenuStrip
- Can be used to theme other ToolStrips

---

## Events

### Navigation Events

#### Navigating
Occurs before navigation to a new page.

```csharp
public event WebBrowserNavigatingEventHandler Navigating
```

**Example:**
```csharp
kryptonWebBrowser1.Navigating += (s, e) =>
{
    if (!IsUrlAllowed(e.Url))
    {
        e.Cancel = true;
        MessageBox.Show("Navigation blocked.");
    }
};
```

---

#### Navigated
Occurs after navigation to a new page.

```csharp
public event WebBrowserNavigatedEventHandler Navigated
```

**Example:**
```csharp
kryptonWebBrowser1.Navigated += (s, e) =>
{
    urlTextBox.Text = e.Url.ToString();
};
```

---

#### DocumentCompleted
Occurs when the document finishes loading.

```csharp
public event WebBrowserDocumentCompletedEventHandler DocumentCompleted
```

**Example:**
```csharp
kryptonWebBrowser1.DocumentCompleted += (s, e) =>
{
    statusLabel.Text = "Page loaded";
    ExecuteScript("console.log('Page ready')");
};
```

---

#### ProgressChanged
Occurs when the download progress changes.

```csharp
public event WebBrowserProgressChangedEventHandler ProgressChanged
```

---

## Usage Examples

### Basic HTML Viewer

```csharp
var browser = new KryptonWebBrowser
{
    Dock = DockStyle.Fill,
    AllowNavigation = true,
    ScriptErrorsSuppressed = true
};

browser.Navigate("https://www.example.com");

this.Controls.Add(browser);
```

---

### Rich Text Editor

```csharp
var editor = new KryptonWebBrowser
{
    Dock = DockStyle.Fill,
    AllowNavigation = false,
    IsWebBrowserContextMenuEnabled = false,
    ScriptErrorsSuppressed = true
};

// Set up as HTML editor
editor.DocumentText = @"
<!DOCTYPE html>
<html>
<head>
    <style>
        body { font-family: Arial; padding: 10px; }
    </style>
</head>
<body contenteditable='true'>
    Type your content here...
</body>
</html>";

editor.DocumentCompleted += (s, e) =>
{
    // Enable design mode for editing
    editor.Document.DomDocument.GetType()
        .GetProperty("designMode")
        .SetValue(editor.Document.DomDocument, "On", null);
};

this.Controls.Add(editor);
```

---

### HTML Email Preview

```csharp
public class EmailPreview : KryptonPanel
{
    private KryptonWebBrowser browser;
    
    public EmailPreview()
    {
        browser = new KryptonWebBrowser
        {
            Dock = DockStyle.Fill,
            AllowNavigation = false,
            IsWebBrowserContextMenuEnabled = false,
            ScrollBarsEnabled = true
        };
        
        Controls.Add(browser);
    }
    
    public void ShowEmail(string htmlBody)
    {
        string html = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{ 
            font-family: 'Segoe UI', Arial; 
            font-size: 11pt;
            padding: 15px;
        }}
    </style>
</head>
<body>
    {htmlBody}
</body>
</html>";
        
        browser.DocumentText = html;
    }
}
```

---

### Mini Browser with Controls

```csharp
public class MiniBrowser : KryptonPanel
{
    private KryptonTextBox urlTextBox;
    private KryptonButton goButton;
    private KryptonButton backButton;
    private KryptonButton forwardButton;
    private KryptonWebBrowser browser;
    
    public MiniBrowser()
    {
        SetupToolbar();
        SetupBrowser();
    }
    
    private void SetupToolbar()
    {
        var toolbar = new KryptonPanel
        {
            Dock = DockStyle.Top,
            Height = 35
        };
        
        backButton = new KryptonButton
        {
            Text = "◄",
            Location = new Point(5, 5),
            Width = 30,
            Enabled = false
        };
        backButton.Click += (s, e) => browser.GoBack();
        
        forwardButton = new KryptonButton
        {
            Text = "►",
            Location = new Point(40, 5),
            Width = 30,
            Enabled = false
        };
        forwardButton.Click += (s, e) => browser.GoForward();
        
        urlTextBox = new KryptonTextBox
        {
            Location = new Point(75, 5),
            Width = Width - 160,
            Anchor = AnchorStyles.Left | AnchorStyles.Right | AnchorStyles.Top
        };
        urlTextBox.KeyDown += (s, e) =>
        {
            if (e.KeyCode == Keys.Enter)
            {
                NavigateToUrl();
            }
        };
        
        goButton = new KryptonButton
        {
            Text = "Go",
            Location = new Point(Width - 80, 5),
            Width = 70,
            Anchor = AnchorStyles.Right | AnchorStyles.Top
        };
        goButton.Click += (s, e) => NavigateToUrl();
        
        toolbar.Controls.AddRange(new Control[] 
        { 
            backButton, forwardButton, urlTextBox, goButton 
        });
        
        Controls.Add(toolbar);
    }
    
    private void SetupBrowser()
    {
        browser = new KryptonWebBrowser
        {
            Dock = DockStyle.Fill,
            ScriptErrorsSuppressed = true
        };
        
        browser.Navigated += (s, e) =>
        {
            urlTextBox.Text = e.Url.ToString();
            backButton.Enabled = browser.CanGoBack;
            forwardButton.Enabled = browser.CanGoForward;
        };
        
        Controls.Add(browser);
    }
    
    private void NavigateToUrl()
    {
        string url = urlTextBox.Text;
        if (!url.StartsWith("http://") && !url.StartsWith("https://"))
        {
            url = "https://" + url;
        }
        browser.Navigate(url);
    }
}
```

---

### Document Viewer with Context Menu

```csharp
var viewer = new KryptonWebBrowser
{
    Dock = DockStyle.Fill,
    IsWebBrowserContextMenuEnabled = false
};

var contextMenu = new KryptonContextMenu();
var menuItems = contextMenu.Items.Add(new KryptonContextMenuItems());

menuItems.Items.Add(new KryptonContextMenuItem("Copy", null, (s, e) =>
{
    viewer.Document?.ExecCommand("Copy", false, null);
}));

menuItems.Items.Add(new KryptonContextMenuItem("Select All", null, (s, e) =>
{
    viewer.Document?.ExecCommand("SelectAll", false, null);
}));

menuItems.Items.Add(new KryptonContextMenuSeparator());

menuItems.Items.Add(new KryptonContextMenuItem("Print", null, (s, e) =>
{
    viewer.ShowPrintDialog();
}));

viewer.KryptonContextMenu = contextMenu;
```

---

### Markdown Preview

```csharp
public class MarkdownPreview : KryptonPanel
{
    private KryptonWebBrowser browser;
    
    public MarkdownPreview()
    {
        browser = new KryptonWebBrowser
        {
            Dock = DockStyle.Fill,
            AllowNavigation = false
        };
        
        Controls.Add(browser);
    }
    
    public void ShowMarkdown(string markdown)
    {
        // Use a markdown library like Markdig
        var html = Markdig.Markdown.ToHtml(markdown);
        
        string styledHtml = $@"
<!DOCTYPE html>
<html>
<head>
    <style>
        body {{
            font-family: 'Segoe UI', Arial;
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
        }}
        code {{
            background: #f4f4f4;
            padding: 2px 5px;
            border-radius: 3px;
        }}
        pre {{
            background: #f4f4f4;
            padding: 10px;
            border-radius: 5px;
            overflow-x: auto;
        }}
    </style>
</head>
<body>
    {html}
</body>
</html>";
        
        browser.DocumentText = styledHtml;
    }
}
```

---

### Script Execution

```csharp
private void ExecuteJavaScript()
{
    kryptonWebBrowser1.DocumentCompleted += (s, e) =>
    {
        // Execute JavaScript after document loads
        var document = kryptonWebBrowser1.Document;
        
        // Change background color
        document.InvokeScript("eval", new object[] 
        { 
            "document.body.style.backgroundColor = '#f0f0f0';" 
        });
        
        // Get element content
        var result = document.InvokeScript("eval", new object[] 
        { 
            "document.getElementById('myElement').innerHTML;" 
        });
    };
}
```

---

### PDF Viewer (Alternative)

```csharp
// Display PDF using embedded PDF reader
var pdfViewer = new KryptonWebBrowser
{
    Dock = DockStyle.Fill,
    AllowNavigation = false
};

// Navigate to PDF file
pdfViewer.Navigate(@"C:\Documents\Report.pdf");

// Or embed in HTML
string pdfPath = @"C:\Documents\Report.pdf";
pdfViewer.DocumentText = $@"
<!DOCTYPE html>
<html>
<body style='margin:0'>
    <embed src='file:///{pdfPath}' 
           type='application/pdf' 
           width='100%' 
           height='100%' />
</body>
</html>";
```

---

### Restricted Browser

```csharp
private HashSet<string> allowedDomains = new HashSet<string>
{
    "example.com",
    "docs.microsoft.com"
};

private void SetupRestrictedBrowser()
{
    kryptonWebBrowser1.Navigating += (s, e) =>
    {
        var domain = e.Url.Host;
        if (!allowedDomains.Any(d => domain.EndsWith(d)))
        {
            e.Cancel = true;
            MessageBox.Show($"Navigation to {domain} is not allowed.",
                          "Restricted",
                          MessageBoxButtons.OK,
                          MessageBoxIcon.Warning);
        }
    };
}
```

---

## Design Considerations

### Context Menu Handling

The control intercepts `WM_CONTEXTMENU` and `WM_PARENTNOTIFY` messages to show themed context menus:

1. Right-click detected
2. Check if `KryptonContextMenu` is set
3. If set, show at click location
4. Otherwise, fall back to standard behavior

---

### Palette Integration

- Connects to current global palette on construction
- Creates themed renderers for ContextMenuStrip
- Responds to palette change events
- Minimal overhead when not using context menus

---

### WebBrowser Limitations

Inherits standard `WebBrowser` control limitations:
- Uses Internet Explorer rendering engine
- Limited HTML5/CSS3 support on older Windows versions
- Security restrictions on local file access
- Consider alternatives (WebView2) for modern web content

---

## Common Scenarios

### Help Viewer

```csharp
public class HelpViewer : KryptonForm
{
    private KryptonWebBrowser browser;
    private string helpBasePath;
    
    public HelpViewer(string helpPath)
    {
        helpBasePath = helpPath;
        
        browser = new KryptonWebBrowser
        {
            Dock = DockStyle.Fill,
            AllowNavigation = true
        };
        
        // Restrict navigation to help files only
        browser.Navigating += (s, e) =>
        {
            if (!e.Url.LocalPath.StartsWith(helpBasePath))
            {
                e.Cancel = true;
            }
        };
        
        Controls.Add(browser);
        ShowHelp("index.html");
    }
    
    public void ShowHelp(string page)
    {
        browser.Navigate(Path.Combine(helpBasePath, page));
    }
}
```

---

### License Agreement Viewer

```csharp
public class LicenseDialog : KryptonForm
{
    private KryptonWebBrowser browser;
    private KryptonCheckBox acceptCheckBox;
    private KryptonButton acceptButton;
    
    public LicenseDialog()
    {
        browser = new KryptonWebBrowser
        {
            Dock = DockStyle.Fill,
            AllowNavigation = false,
            IsWebBrowserContextMenuEnabled = false,
            ScrollBarsEnabled = true
        };
        
        var bottomPanel = new KryptonPanel
        {
            Dock = DockStyle.Bottom,
            Height = 50
        };
        
        acceptCheckBox = new KryptonCheckBox
        {
            Text = "I accept the terms and conditions",
            Location = new Point(10, 10)
        };
        acceptCheckBox.CheckedChanged += (s, e) =>
        {
            acceptButton.Enabled = acceptCheckBox.Checked;
        };
        
        acceptButton = new KryptonButton
        {
            Text = "Accept",
            Location = new Point(Width - 110, 10),
            Enabled = false,
            DialogResult = DialogResult.OK
        };
        
        bottomPanel.Controls.Add(acceptCheckBox);
        bottomPanel.Controls.Add(acceptButton);
        
        Controls.Add(browser);
        Controls.Add(bottomPanel);
        
        LoadLicense();
    }
    
    private void LoadLicense()
    {
        browser.DocumentText = File.ReadAllText("License.html");
    }
}
```

---

## Compatibility

- **Target Frameworks:** `net472`, `net48`, `net481`, `net8.0-windows`, `net9.0-windows`, `net10.0-windows`
- **Windows Forms:** Required
- **Dependencies:** 
  - Krypton.Toolkit core
  - Internet Explorer (WebBrowser uses IE rendering engine)

---

## Known Limitations

1. **Rendering Engine:** Uses Internet Explorer - limited modern web support
2. **Context Menu:** Right-click interception may not work in all scenarios
3. **Keyboard Menu:** `WM_CONTEXTMENU` from keyboard sometimes not fired
4. **Workaround:** Uses `WM_PARENTNOTIFY` to intercept right mouse button

---

## Migration to WebView2

For modern web content, consider migrating to WebView2:

```csharp
// Old: KryptonWebBrowser (IE engine)
var oldBrowser = new KryptonWebBrowser();

// New: WebView2 (Chromium engine)
// Note: Requires Microsoft.Web.WebView2 NuGet package
var newBrowser = new Microsoft.Web.WebView2.WinForms.WebView2();
await newBrowser.EnsureCoreWebView2Async();
```

**WebView2 Advantages:**
- Modern Chromium rendering
- Better HTML5/CSS3/JavaScript support
- Regular updates
- Better performance

**KryptonWebBrowser Advantages:**
- No additional dependencies
- Simpler for basic HTML
- Works on all Windows versions
- Krypton theming integration

---

## See Also

- [KryptonContextMenu](KryptonContextMenu.md) - Context menu control
- [KryptonRichTextBox](KryptonRichTextBox.md) - Alternative for rich text
- [WebView2](https://docs.microsoft.com/en-us/microsoft-edge/webview2/) - Modern browser control
- [KryptonWebView2](KryptonWebView2.md)
- [HtmlDocument](https://docs.microsoft.com/en-us/dotnet/api/system.windows.forms.htmldocument) - Document manipulation