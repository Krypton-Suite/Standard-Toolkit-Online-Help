# KryptonWebView2 API Reference

## Class: KryptonWebView2

**Namespace**: `Krypton.Toolkit`  
**Assembly**: `Krypton.Toolkit.dll`  
**Inheritance**: `WebView2` → `Control` → `Component` → `MarshalByRefObject` → `object`

### Description
A modern web browser control that integrates Microsoft's WebView2 engine with the Krypton Toolkit's theming system.

---

## Constructors

### KryptonWebView2()
Initializes a new instance of the KryptonWebView2 class.

**Parameters**: None

**Remarks**:
- Enables double buffering for smooth rendering
- Sets up resize redraw for proper repainting  
- Initializes the Krypton palette system
- Registers for global palette change notifications
- WebView2 engine is not initialized until `EnsureCoreWebView2Async()` is called

**Example**:
```csharp
var webView = new KryptonWebView2();
webView.Size = new Size(800, 600);
await webView.EnsureCoreWebView2Async();
```

---

## Properties

### KryptonContextMenu
**Type**: `KryptonContextMenu?`  
**Access**: Get/Set  
**Category**: Behavior  
**Default**: `null`

Gets or sets the KryptonContextMenu to show when right-clicked.

**Value**:
- A `KryptonContextMenu` instance for custom context menu
- `null` to use default WebView2 context menu

**Remarks**:
- Overrides default WebView2 context menu with Krypton-styled menu
- Shows at mouse position for right-click, centered for keyboard activation
- Setting to `null` restores default WebView2 behavior

**Example**:
```csharp
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Copy"));
webView.KryptonContextMenu = contextMenu;
```

---

## Methods

### CreateToolStripRenderer()
**Return Type**: `ToolStripRenderer?`  
**Access**: Public  
**Browsable**: False  
**EditorBrowsable**: Advanced

Creates a tool strip renderer appropriate for the current renderer/palette pair.

**Returns**:
- A `ToolStripRenderer` instance for Krypton-themed rendering
- `null` if no renderer is available

**Remarks**:
- Creates renderer matching current Krypton theme and palette
- Uses resolved palette (control-specific or global)
- Primarily for internal use but available for advanced scenarios

**Example**:
```csharp
var renderer = webView.CreateToolStripRenderer();
if (renderer != null)
{
    myToolStrip.Renderer = renderer;
}
```

### GetResolvedPalette()
**Return Type**: `PaletteBase`  
**Access**: Public  
**Browsable**: False  
**EditorBrowsable**: Never

Gets the resolved palette to actually use when drawing.

**Returns**:
- A `PaletteBase` instance representing the currently active palette

**Remarks**:
- Returns palette currently used for control rendering
- Determined by control's palette mode and global settings
- Primarily for internal framework use

---

## Protected Methods

### Dispose(bool disposing)
**Parameters**:
- `disposing` (bool): true if managed resources should be disposed

**Remarks**:
- Unhooks from global palette change notifications
- Disposes of associated KryptonContextMenu if present
- Calls base class Dispose to clean up WebView2 resources
- WebView2 engine automatically cleans up native resources

### OnGlobalPaletteChanged(object sender, EventArgs e)
**Parameters**:
- `sender` (object): Source of the event
- `e` (EventArgs): Event data

**Remarks**:
- Handles global palette change notifications
- Updates control with new global palette when using global mode
- Ensures theme consistency across the application

### WndProc(ref Message m)
**Parameters**:
- `m` (Message): Windows-based message

**Remarks**:
- Processes Windows messages for custom context menu handling
- Intercepts `WM_CONTEXTMENU` and `WM_PARENTNOTIFY` with `WM_RBUTTONDOWN`
- Shows KryptonContextMenu when assigned and consumes message
- Passes other messages to base class for default handling

---

## Inherited Properties (from WebView2)

### CoreWebView2
**Type**: `CoreWebView2?`  
**Access**: Get

Gets the CoreWebView2 object for the control.

**Remarks**:
- Provides access to WebView2 functionality
- Available after successful initialization via `EnsureCoreWebView2Async()`
- Use for navigation, JavaScript execution, and event handling

### DocumentTitle
**Type**: `string`  
**Access**: Get

Gets the title of the current document.

### Source
**Type**: `Uri?`  
**Access**: Get

Gets the URI of the current page.

### DefaultBackgroundColor
**Type**: `Color`  
**Access**: Get/Set

Gets or sets the default background color.

### ZoomFactor
**Type**: `double`  
**Access**: Get/Set

Gets or sets the zoom factor of the WebView2.

---

## Inherited Methods (from WebView2)

### EnsureCoreWebView2Async()
**Return Type**: `Task`  
**Access**: Public

Ensures that the WebView2 runtime is loaded and initialized.

**Remarks**:
- Must be called before using WebView2 functionality
- Throws exceptions if WebView2 runtime is not available
- Should be called asynchronously

**Example**:
```csharp
try
{
    await webView.EnsureCoreWebView2Async();
    // WebView2 is now ready to use
}
catch (Exception ex)
{
    // Handle initialization error
}
```

### EnsureCoreWebView2Async(CoreWebView2Environment environment)
**Parameters**:
- `environment` (CoreWebView2Environment): Custom environment

**Return Type**: `Task`  
**Access**: Public

Ensures that the WebView2 runtime is loaded with a custom environment.

---

## Inherited Events (from WebView2)

### NavigationStarting
**Type**: `EventHandler<CoreWebView2NavigationStartingEventArgs>`  
**Access**: Public

Occurs before navigation starts.

**Example**:
```csharp
webView.NavigationStarting += (s, e) => {
    statusLabel.Text = "Loading...";
};
```

### NavigationCompleted
**Type**: `EventHandler<CoreWebView2NavigationCompletedEventArgs>`  
**Access**: Public

Occurs after navigation completes.

**Example**:
```csharp
webView.NavigationCompleted += (s, e) => {
    if (e.IsSuccess)
    {
        statusLabel.Text = "Loaded";
    }
    else
    {
        MessageBox.Show($"Navigation failed: {e.WebErrorStatus}");
    }
};
```

### DocumentTitleChanged
**Type**: `EventHandler<object>`  
**Access**: Public

Occurs when the document title changes.

### WebMessageReceived
**Type**: `EventHandler<CoreWebView2WebMessageReceivedEventArgs>`  
**Access**: Public

Occurs when JavaScript sends a message to C#.

---

## CoreWebView2 Properties and Methods

### Navigation
```csharp
// Navigate to URL
CoreWebView2?.Navigate("https://example.com");

// Navigate with headers
CoreWebView2?.Navigate("https://example.com", headers);

// Navigate to HTML string
CoreWebView2?.NavigateToString("<html><body>Hello</body></html>");

// Navigate to local file
CoreWebView2?.Navigate($"file:///{filePath}");
```

### History
```csharp
// Go back
CoreWebView2?.GoBack();

// Go forward  
CoreWebView2?.GoForward();

// Reload
CoreWebView2?.Reload();

// Stop
CoreWebView2?.Stop();
```

### JavaScript
```csharp
// Execute JavaScript and get result
var result = await CoreWebView2?.ExecuteScriptAsync("document.title");

// Add script to execute on document creation
await CoreWebView2?.AddScriptToExecuteOnDocumentCreatedAsync(script);

// Remove script
await CoreWebView2?.RemoveScriptToExecuteOnDocumentCreatedAsync(scriptId);
```

### Settings
```csharp
var settings = CoreWebView2?.Settings;

// Enable/disable features
settings.AreDefaultContextMenusEnabled = false;
settings.AreDevToolsEnabled = true;
settings.IsStatusBarEnabled = false;
settings.IsZoomControlEnabled = true;
settings.AreHostObjectsAllowed = true;

// Set user agent
settings.UserAgent = "MyApp/1.0";
```

---

## Design-Time Support

### Toolbox Integration
- **ToolboxItem**: True
- **ToolboxBitmap**: WebView2.bmp
- **Designer**: KryptonWebView2Designer
- **Category**: Krypton Controls

### Designer Properties
The control supports all standard WebView2 properties in the designer:
- Size and Location
- Anchor and Dock
- DefaultBackgroundColor
- ZoomFactor
- AllowExternalDrop

### Custom Properties
- **KryptonContextMenu**: Custom context menu for right-click operations

---

## Exception Handling

### WebView2RuntimeNotFoundException
Thrown when WebView2 runtime is not installed.

**Solution**: Install WebView2 runtime from Microsoft's website.

### WebView2RuntimeVersionNotSupportedException  
Thrown when WebView2 runtime version is not supported.

**Solution**: Update WebView2 runtime to a supported version.

### InvalidOperationException
Thrown when attempting to use WebView2 functionality before initialization.

**Solution**: Call `EnsureCoreWebView2Async()` first.

---

## Threading Considerations

- WebView2 operations are generally thread-safe
- UI updates should be performed on the UI thread
- Use `Invoke` or `BeginInvoke` for cross-thread UI updates
- Async operations return to the calling thread context

---

## Performance Notes

- WebView2 engine manages its own memory efficiently
- Multiple WebView2 instances share the same browser process
- Dispose the control properly to clean up resources
- Avoid creating unnecessary WebView2 instances

---

## Security Considerations

- WebView2 runs in a separate process for security
- JavaScript execution can be controlled via settings
- Network access follows system proxy settings
- Content Security Policy can be enforced for web content
