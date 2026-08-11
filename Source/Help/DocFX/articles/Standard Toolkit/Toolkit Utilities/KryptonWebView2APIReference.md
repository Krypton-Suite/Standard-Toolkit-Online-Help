# KryptonWebView2 API Reference

## Namespace

`Krypton.Toolkit.Utilities`

## Assembly

`Krypton.Toolkit.Utilities.dll`

## Inheritance Hierarchy

```text
System.Object
└── System.MarshalByRefObject
    └── System.ComponentModel.Component
        └── System.Windows.Forms.Control
            └── Microsoft.Web.WebView2.WinForms.WebView2
                └── Krypton.Toolkit.Utilities.KryptonWebView2
```

## Conditional compilation overview

The full control is compiled when bundled WebView2 assemblies are present under `Krypton.Toolkit.Utilities/Lib/WebView2` (`WEBVIEW2_AVAILABLE`). Without them, a minimal stub `Control` is emitted instead. Supported target frameworks follow the `Krypton.Toolkit.Utilities` project (including .NET Framework 4.7.2+ and modern `-windows` TFMs).

---

## Class: KryptonWebView2

### Summary

Provide a WebView2 control with Krypton styling applied. A modern web browser control that integrates Microsoft's WebView2 engine with the Krypton Toolkit's theming system.

### Attributes

- `[ToolboxItem(true)]` - Available in Visual Studio toolbox
- `[ToolboxBitmap(typeof(KryptonWebView2), "KryptonWebView2.ToolboxBitmaps.WebView2.bmp")]` - Custom toolbox icon
- `[Designer(typeof(KryptonWebView2Designer))]` - Custom designer support
- `[DesignerCategory("code")]` - Code-based designer category
- `[Description("Enables the user to browse web pages using the modern WebView2 engine with Krypton theming support.")]` - Control description
- `[CLSCompliant(false)]` - Not CLS compliant

---

## Constructors

### KryptonWebView2()

**Summary:** Initialize a new instance of the KryptonWebView2 class.

**Remarks:**

- Enables double buffering for smooth rendering
- Sets up resize redraw for proper repainting
- Initializes the Krypton palette system
- Registers for global palette change notifications
- WebView2 engine is not initialized until `EnsureCoreWebView2Async()` is called

**Example:**

```csharp
var webView = new KryptonWebView2();
webView.Size = new Size(800, 600);
await webView.EnsureCoreWebView2Async();
```

---

## Properties

### KryptonContextMenu property

**Type:** `KryptonContextMenu?`

**Access:** Public get/set

**Attributes:**

- `[Category("Behavior")]`
- `[Description("The shortcut menu to show when the user right-clicks the page.")]`
- `[DefaultValue(null)]`

**Summary:** Gets and sets the KryptonContextMenu to show when right-clicked.

**Value:** A `KryptonContextMenu` instance that will be displayed when the user right-clicks on the web content, or `null` if no custom context menu should be shown.

**Behavior:**

- When set to a non-null value, overrides the default WebView2 context menu
- Shows at mouse position for right-clicks
- Centers on control for keyboard activation (Menu key)
- Setting to `null` restores default WebView2 context menu behavior

**Example:**

```csharp
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Copy"));
contextMenu.Items.Add(new KryptonContextMenuItem("Paste"));
webView.KryptonContextMenu = contextMenu;
```

### AllowExternalDrop

**Type:** `bool`

**Access:** Public get/set

**Attributes:**

- `[Category("Behavior")]`
- `[Description("Indicates whether the control allows external drag and drop operations.")]`
- `[DefaultValue(false)]`

**Summary:** Gets or sets a value indicating whether the control allows external drag and drop operations.

**Value:** `true` if external drag and drop is allowed; otherwise, `false`.

**Remarks:** This property forwards to the base WebView2 `AllowExternalDrop` property.

**Example:**

```csharp
webView.AllowExternalDrop = true;
```

### CreationProperties

**Type:** `object?`

**Access:** Public get/set

**Attributes:**

- `[Category("Behavior")]`
- `[Description("Gets or sets the creation properties for the WebView2 control.")]`
- `[DefaultValue(null)]`

**Summary:** Gets or sets the creation properties for the WebView2 control.

**Value:** The creation properties, or `null` to use default properties.

**Remarks:** This property forwards to the base WebView2 `CreationProperties` property.

### WebViewBackStyle

**Type:** `PaletteBackStyle`

**Access:** Public get/set

**Attributes:**

- `[Category("Visuals")]`
- `[DefaultValue(PaletteBackStyle.PanelClient)]`

**Summary:** Gets and sets the palette background style used for `BackColor` and `DefaultBackgroundColor`.

**Default:** `PaletteBackStyle.PanelClient`

### WebViewContentStyle

**Type:** `PaletteContentStyle`

**Access:** Public get/set

**Attributes:**

- `[Category("Visuals")]`
- `[DefaultValue(PaletteContentStyle.InputControlStandalone)]`

**Summary:** Gets and sets the palette content style used for `ForeColor`.

**Default:** `PaletteContentStyle.InputControlStandalone`

### StateCommon

**Type:** `PaletteTripleRedirect`

**Access:** Public get

**Attributes:**

- `[Category("Visuals")]`
- `[DesignerSerializationVisibility(Content)]`

**Summary:** Common appearance overrides inherited by `StateNormal`, `StateActive`, and `StateDisabled`.

### StateNormal / StateActive / StateDisabled

**Type:** `PaletteTriple`

**Access:** Public get

**Attributes:**

- `[Category("Visuals")]`
- `[DesignerSerializationVisibility(Content)]`

**Summary:** Per-state palette overrides. `StateActive` applies when the control has focus (`PaletteState.Tracking`). `StateDisabled` applies when `Enabled` is `false`.

### AlwaysActive

**Type:** `bool`

**Access:** Public get/set

**Attributes:**

- `[Category("Visuals")]`
- `[DefaultValue(false)]`

**Summary:** When `true`, the control always uses `StateActive` palette colors even when unfocused.

### SetFixedState(bool active)

**Summary:** Fixes the control in the active or normal palette state (useful at design time or for custom focus handling).

### IsActive

**Type:** `bool`

**Access:** Public get

**Attributes:** `[Browsable(false)]`, `[EditorBrowsable(Never)]`

**Summary:** Indicates whether the active palette state is in effect (`ContainsFocus`, `AlwaysActive`, design mode, or `SetFixedState`).

### Hidden appearance properties

The following are **hidden from the designer** and driven from the current palette state. Prefer **Visuals → State###** in the Property Grid, or set `StateCommon.Back.Color1` / `StateCommon.Content.ShortText.Color1` in code:

| Property | Behavior |
|----------|----------|
| `BackColor` | Resolved from active state's back color; setter writes `StateCommon.Back.Color1` |
| `ForeColor` | Resolved from active state's content short-text color; setter writes `StateCommon.Content.ShortText.Color1` |
| `DefaultBackgroundColor` | Synchronized with `BackColor` (WebView2 loading flash / empty document) |
| `Font`, `BackgroundImage`, `BackgroundImageLayout` | Hidden; not used for web rendering |
| `BackColorChanged`, `ForeColorChanged`, `BackgroundImageChanged`, `BackgroundImageLayoutChanged` | Hidden |

**Example (designer-friendly overrides):**

```csharp
// Override background for all states from common
webView.StateCommon.Back.Color1 = Color.FromArgb(240, 240, 240);

// Override active-state foreground only
webView.StateActive.Content.ShortText.Color1 = Color.Navy;
```

### ZoomFactor

**Type:** `double`

**Access:** Public get/set

**Attributes:**

- `[Category("Behavior")]`
- `[Description("Gets or sets the zoom factor for the WebView2 control.")]`
- `[DefaultValue(1.0)]`

**Summary:** Gets or sets the zoom factor for the WebView2 control.

**Value:** The zoom factor (1.0 = 100%).

**Remarks:** This property forwards to the base WebView2 `ZoomFactor` property.

**Example:**

```csharp
webView.ZoomFactor = 1.5; // 150% zoom
```

### Dock

**Type:** `DockStyle`

**Access:** Public get/set

**Attributes:**

- `[Category("Layout")]`
- `[Description("Gets or sets which edge of the parent container a control is docked to.")]`
- `[DefaultValue(DockStyle.None)]`

**Summary:** Gets or sets which edge of the parent container a control is docked to.

**Value:** One of the `DockStyle` values. The default is `DockStyle.None`.

**Remarks:** This property forwards to the base Control `Dock` property.

**Example:**

```csharp
webView.Dock = DockStyle.Fill;
```

---

## Methods

### CreateToolStripRenderer()

**Signature:** `public ToolStripRenderer? CreateToolStripRenderer()`

**Attributes:**

- `[Browsable(false)]`
- `[EditorBrowsable(EditorBrowsableState.Advanced)]`

**Summary:** Create a tool strip renderer appropriate for the current renderer/palette pair.

**Returns:** A `ToolStripRenderer` instance that provides Krypton-themed rendering for tool strips, or `null` if no renderer is available.

**Remarks:**

- Creates a renderer that matches the current Krypton theme and palette
- Used internally by the control to ensure consistent theming
- Can be used by advanced users who need custom tool strip rendering

**Example:**

```csharp
var renderer = webView.CreateToolStripRenderer();
if (renderer != null)
{
    myToolStrip.Renderer = renderer;
}
```

### GetResolvedPalette()

**Signature:** `public PaletteBase? GetResolvedPalette()`

**Attributes:**

- `[Browsable(false)]`
- `[EditorBrowsable(EditorBrowsableState.Never)]`

**Summary:** Gets the resolved palette to actually use when drawing.

**Returns:** A `PaletteBase` instance that represents the currently active palette for this control, or `null` if no palette has been assigned yet.

**Remarks:**

- Returns the palette currently being used for rendering this control
- Determined by the control's palette mode and global palette settings
- Primarily used internally by the Krypton framework for rendering operations

**Example:**

```csharp
var palette = webView.GetResolvedPalette() ?? KryptonManager.CurrentGlobalPalette;
var primaryColor = palette.GetColorTable().Color1;
```

---

## Protected Methods

### Dispose(bool disposing)

**Signature:** `protected override void Dispose(bool disposing)`

**Parameters:**

- `disposing` (bool): `true` if managed resources should be disposed; otherwise, `false`.

**Summary:** Clean up any resources being used.

**Remarks:**

- Unhooks from global palette change notifications
- Disposes of the associated KryptonContextMenu if present
- Calls the base class Dispose method to clean up WebView2 resources
- WebView2 engine automatically cleans up native resources when disposed

**Example:**

```csharp
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // Custom cleanup code here
    }
    base.Dispose(disposing);
}
```

### WndProc(ref Message m)

**Signature:** `protected override void WndProc(ref Message m)`

**Parameters:**

- `m` (ref Message): A Windows-based message.

**Summary:** Process Windows-based messages.

**Remarks:**

- Intercepts context menu messages and provides custom KryptonContextMenu handling
- Processes `WM_CONTEXTMENU` and `WM_PARENTNOTIFY` with `WM_RBUTTONDOWN` messages
- When KryptonContextMenu is assigned:
  - Extracts mouse position from message parameters
  - Handles keyboard activation by centering menu on control
  - Adjusts position to match standard context menu behavior
  - Shows KryptonContextMenu if mouse is within client area
  - Consumes message to prevent default WebView2 context menu
- If no KryptonContextMenu is assigned, passes message to base class

**Example:**

```csharp
protected override void WndProc(ref Message m)
{
    // Custom message handling before calling base
    base.WndProc(ref m);
}
```

### OnGlobalPaletteChanged(object? sender, EventArgs e)

**Signature:** `protected virtual void OnGlobalPaletteChanged(object? sender, EventArgs e)`

**Parameters:**

- `sender` (object?): Source of the event.
- `e` (EventArgs): An EventArgs that contains the event data.

**Summary:** Occurs when the global palette has been changed.

**Remarks:**

- Only responds if using the global palette mode
- Updates the control with the new global palette
- Can be overridden to provide custom palette change handling

**Example:**

```csharp
protected override void OnGlobalPaletteChanged(object? sender, EventArgs e)
{
    base.OnGlobalPaletteChanged(sender, e);
    // Custom palette change handling
    ApplyCustomTheme();
}
```

---

## Private Methods

### SetPalette(PaletteBase palette)

**Signature:** `private void SetPalette(PaletteBase palette)`

**Parameters:**

- `palette` (PaletteBase): The chosen palette.

**Summary:** Sets the palette being used.

**Remarks:**

- Unhooks from current palette events
- Remembers the new palette
- Gets the renderer associated with the palette
- Hooks to new palette events

### OnBaseChanged(object? sender, EventArgs e)

**Signature:** `private void OnBaseChanged(object? sender, EventArgs e)`

**Parameters:**

- `sender` (object?): The sender.
- `e` (EventArgs): The EventArgs instance containing the event data.

**Summary:** Called when there is a change in base renderer or base palette.

**Remarks:**

- Changes in base renderer or base palette require fetching the latest renderer
- Updates the internal renderer reference

### OnKryptonContextMenuDisposed(object? sender, EventArgs e)

**Signature:** `private void OnKryptonContextMenuDisposed(object? sender, EventArgs e)`

**Parameters:**

- `sender` (object?): The sender.
- `e` (EventArgs): The EventArgs instance containing the event data.

**Summary:** Handles disposal of the KryptonContextMenu.

**Remarks:**

- When the current krypton context menu is disposed, removes it to prevent exceptions
- Prevents using a disposed context menu

---

## Inherited Properties (from WebView2)

### CoreWebView2

**Type:** `CoreWebView2?`

**Summary:** Gets the CoreWebView2 object for the WebView2 control.

**Remarks:**

- Returns `null` until `EnsureCoreWebView2Async()` is called
- Provides access to WebView2's core functionality
- Used for navigation, JavaScript execution, and event handling

**Example:**

```csharp
await webView.EnsureCoreWebView2Async();
if (webView.CoreWebView2 != null)
{
    webView.CoreWebView2.Navigate("https://example.com");
}
```

### Source

**Type:** `Uri?`

**Summary:** Gets or sets the URI of the current top-level document.

**Example:**

```csharp
webView.Source = new Uri("https://example.com");
```

### DocumentTitle

**Type:** `string`

**Summary:** Gets the title of the current top-level document.

**Example:**

```csharp
string title = webView.DocumentTitle;
```

### CanGoBack

**Type:** `bool`

**Summary:** Gets whether the WebView2 can navigate to a previous page in the navigation history.

**Example:**

```csharp
if (webView.CanGoBack)
{
    webView.GoBack();
}
```

### CanGoForward

**Type:** `bool`

**Summary:** Gets whether the WebView2 can navigate to a next page in the navigation history.

**Example:**

```csharp
if (webView.CanGoForward)
{
    webView.GoForward();
}
```

---

## Inherited Methods (from WebView2)

### EnsureCoreWebView2Async()

**Signature:** `public Task EnsureCoreWebView2Async()`

**Summary:** Ensures that the WebView2 runtime is installed and initializes the CoreWebView2 object.

**Returns:** A Task that represents the asynchronous operation.

**Remarks:**

- Must be called before using CoreWebView2
- Downloads WebView2 runtime if not installed
- Initializes the WebView2 engine

**Example:**

```csharp
await webView.EnsureCoreWebView2Async();
```

### Navigate(string uri)

**Signature:** `public void Navigate(string uri)`

**Parameters:**

- `uri` (string): The URI to navigate to.

**Summary:** Navigates the WebView2 to the specified URI.

**Example:**

```csharp
webView.Navigate("https://example.com");
```

### GoBack()

**Signature:** `public void GoBack()`

**Summary:** Navigates the WebView2 to the previous page in the navigation history.

**Example:**

```csharp
webView.GoBack();
```

### GoForward()

**Signature:** `public void GoForward()`

**Summary:** Navigates the WebView2 to the next page in the navigation history.

**Example:**

```csharp
webView.GoForward();
```

### Reload()

**Signature:** `public void Reload()`

**Summary:** Reloads the current page.

**Example:**

```csharp
webView.Reload();
```

### Stop()

**Signature:** `public void Stop()`

**Summary:** Stops all navigations and pending resource fetches on the current page.

**Example:**

```csharp
webView.Stop();
```

---

## Events

### NavigationStarting

**Type:** `EventHandler<CoreWebView2NavigationStartingEventArgs>`

**Summary:** Occurs when the WebView2 is about to navigate to a new page.

**Example:**

```csharp
webView.CoreWebView2.NavigationStarting += (sender, e) =>
{
    if (e.Uri.Contains("blocked-site.com"))
    {
        e.Cancel = true;
    }
};
```

### NavigationCompleted

**Type:** `EventHandler<CoreWebView2NavigationCompletedEventArgs>`

**Summary:** Occurs when the WebView2 has finished navigating to a new page.

**Example:**

```csharp
webView.CoreWebView2.NavigationCompleted += (sender, e) =>
{
    if (e.IsSuccess)
    {
        Console.WriteLine($"Loaded: {webView.DocumentTitle}");
    }
};
```

### DocumentTitleChanged

**Type:** `EventHandler<object>`

**Summary:** Occurs when the document title changes.

**Example:**

```csharp
webView.CoreWebView2.DocumentTitleChanged += (sender, e) =>
{
    this.Text = webView.DocumentTitle;
};
```

### NewWindowRequested

**Type:** `EventHandler<CoreWebView2NewWindowRequestedEventArgs>`

**Summary:** Occurs when a new window is requested.

**Example:**

```csharp
webView.CoreWebView2.NewWindowRequested += (sender, e) =>
{
    // Open in same window instead of new window
    e.NewWindow = webView.CoreWebView2;
    e.Handled = true;
};
```

---

## Requirements

### System Requirements

- Windows 10 version 1803 (build 17134) or later
- WebView2 Runtime installed on target system
- Supported TFMs per `Krypton.Toolkit.Utilities` (including .NET Framework 4.7.2+ and modern `-windows` TFMs)

### Dependencies

- Bundled `Microsoft.Web.WebView2.Core.dll` and `Microsoft.Web.WebView2.WinForms.dll` under `Lib/WebView2` (see [WebView2 SDK Setup](WebView2SDKSetup.md)), or equivalent references
- `WebView2Loader.dll` (deployed with the WebView2 runtime on target machines)

### Conditional compilation details

The full control is built when `WEBVIEW2_AVAILABLE` is defined (bundled assemblies present). Otherwise a stub `Control` is compiled. See [WebView2 SDK Setup](WebView2SDKSetup.md).

---

## Related Types

### KryptonContextMenu class

Custom context menu system that integrates with Krypton theming.

### PaletteBase

Base class for Krypton palette system.

### IRenderer

Interface for Krypton rendering system.

### ToolStripRenderer

Base class for tool strip rendering.

---

## See Also

- [Microsoft WebView2 Documentation](https://docs.microsoft.com/en-us/microsoft-edge/webview2/)
- [Krypton Toolkit Documentation](https://github.com/Krypton-Suite/Standard-Toolkit)
- `KryptonWebBrowser` - Legacy WebBrowser control with Krypton theming
