# KryptonWebView2

## Overview

`KryptonWebView2` is a modern web browser control that integrates Microsoft's WebView2 engine with the Krypton Toolkit's theming system. It provides a consistent look and feel with other Krypton controls while offering modern web rendering capabilities.

## Features

### Core Features
- **Modern Web Engine**: Based on Microsoft Edge Chromium for excellent performance and standards compliance
- **Krypton Theming**: Full integration with Krypton's theming system for consistent appearance
- **Custom Context Menus**: Support for KryptonContextMenu with proper theming
- **Designer Support**: Full Visual Studio designer integration
- **Async Operations**: Modern async/await pattern for navigation and JavaScript execution
- **Cross-Platform Compatibility**: Works with .NET Framework 4.7.2+ and .NET 8+

### Advanced Features
- **Zoom Control**: Customizable zoom levels for better accessibility
- **Background Colors**: Customizable background colors for loading states
- **External Drop**: Support for drag-and-drop operations
- **Navigation Events**: Comprehensive navigation event handling
- **JavaScript Interop**: Execute JavaScript and receive results from C#

## Requirements

### System Requirements
- **WebView2 Runtime**: Must be installed on the target system
- **Windows Platform**: Windows 7 SP1 or later (Windows 10+ recommended)
- **.NET Framework**: 4.7.2 or later
- **.NET**: 8.0 or later

### Development Requirements
- **Visual Studio**: 2019 or later (for designer support)
- **WebView2 SDK**: Assemblies must be available (see Setup section)

## Setup and Installation

### 1. WebView2 Runtime
The WebView2 Runtime must be installed on target systems. It can be:
- **Evergreen**: Automatically updated by Microsoft (recommended)
- **Fixed Version**: Bundled with your application
- **Preview**: For testing with latest features

### 2. SDK Assemblies
Place the following WebView2 SDK assemblies in a `WebView2SDK` folder at the repository root:
- `Microsoft.Web.WebView2.Core.dll`
- `Microsoft.Web.WebView2.WinForms.dll`
- `WebView2Loader.dll`

### 3. Project Configuration
The project file already includes the necessary assembly references for both .NET Framework and .NET 8+ targets.

## Basic Usage

### Creating the Control
```csharp
var webView = new KryptonWebView2();
webView.Size = new Size(800, 600);
webView.Location = new Point(10, 10);

// Add to form
this.Controls.Add(webView);
```

### Initialization
```csharp
private async void InitializeWebView()
{
    try
    {
        // Initialize the WebView2 engine
        await webView.EnsureCoreWebView2Async();
        
        // Navigate to a URL
        webView.CoreWebView2?.Navigate("https://example.com");
    }
    catch (Exception ex)
    {
        MessageBox.Show($"WebView2 initialization failed: {ex.Message}");
    }
}
```

### Navigation
```csharp
// Navigate to a URL
webView.CoreWebView2?.Navigate("https://example.com");

// Navigate with additional options
webView.CoreWebView2?.Navigate("https://example.com", 
    Microsoft.Web.WebView2.Core.CoreWebView2HttpHeaders.FromString("Custom-Header: Value"));

// Navigate to local HTML content
webView.CoreWebView2?.NavigateToString("<html><body><h1>Hello World!</h1></body></html>");
```

## Advanced Usage

### Custom Context Menu
```csharp
var contextMenu = new KryptonContextMenu();

// Add menu items
var copyItem = new KryptonContextMenuItem("Copy");
var pasteItem = new KryptonContextMenuItem("Paste");
var separator = new KryptonContextMenuSeparator();
var propertiesItem = new KryptonContextMenuItem("Properties");

copyItem.Click += (s, e) => { /* Copy logic */ };
pasteItem.Click += (s, e) => { /* Paste logic */ };
propertiesItem.Click += (s, e) => { /* Properties logic */ };

contextMenu.Items.AddRange(new KryptonContextMenuItemBase[] {
    copyItem, pasteItem, separator, propertiesItem
});

webView.KryptonContextMenu = contextMenu;
```

### JavaScript Interop
```csharp
// Execute JavaScript and get result
var result = await webView.CoreWebView2?.ExecuteScriptAsync("document.title");

// Add JavaScript to page
await webView.CoreWebView2?.AddScriptToExecuteOnDocumentCreatedAsync(
    "window.myCustomFunction = function() { return 'Hello from JavaScript!'; }");

// Subscribe to JavaScript events
webView.CoreWebView2?.WebMessageReceived += (s, e) => {
    var message = e.TryGetWebMessageAsString();
    // Handle message from JavaScript
};
```

### Navigation Events
```csharp
webView.NavigationStarting += (s, e) => {
    // Navigation is starting
    statusLabel.Text = "Loading...";
};

webView.NavigationCompleted += (s, e) => {
    // Navigation completed
    statusLabel.Text = "Loaded";
    
    if (!e.IsSuccess)
    {
        MessageBox.Show($"Navigation failed: {e.WebErrorStatus}");
    }
};

webView.DocumentTitleChanged += (s, e) => {
    // Document title changed
    this.Text = $"WebView2 - {webView.DocumentTitle}";
};
```

### Custom Settings
```csharp
// Configure WebView2 settings
webView.CoreWebView2?.Settings.AreDefaultContextMenusEnabled = false;
webView.CoreWeb2?.Settings.AreDevToolsEnabled = true;
webView.CoreWebView2?.Settings.IsStatusBarEnabled = false;
webView.CoreWebView2?.Settings.IsZoomControlEnabled = true;

// Set user agent
webView.CoreWebView2?.Settings.UserAgent = "MyCustomApp/1.0";
```

## Theming Integration

### Palette Integration
The control automatically integrates with Krypton's theming system:

```csharp
// Global palette changes are automatically handled
KryptonManager.GlobalPalette = KryptonManager.PaletteOffice2010Blue;

// The control will automatically update its appearance
```

### Custom Rendering
For advanced theming scenarios:

```csharp
// Get the current renderer
var renderer = webView.CreateToolStripRenderer();

// Apply to other controls for consistency
myToolStrip.Renderer = renderer;
```

## Error Handling

### Initialization Errors
```csharp
try
{
    await webView.EnsureCoreWebView2Async();
}
catch (WebView2RuntimeNotFoundException)
{
    MessageBox.Show("WebView2 Runtime is not installed. Please install it and try again.");
}
catch (WebView2RuntimeVersionNotSupportedException)
{
    MessageBox.Show("WebView2 Runtime version is not supported. Please update it.");
}
catch (Exception ex)
{
    MessageBox.Show($"WebView2 initialization failed: {ex.Message}");
}
```

### Navigation Errors
```csharp
webView.NavigationCompleted += (s, e) => {
    if (!e.IsSuccess)
    {
        switch (e.WebErrorStatus)
        {
            case CoreWebView2WebErrorStatus.Unknown:
                // Handle unknown error
                break;
            case CoreWebView2WebErrorStatus.HostNameNotResolved:
                // Handle DNS resolution failure
                break;
            case CoreWebView2WebErrorStatus.ConnectionRefused:
                // Handle connection refused
                break;
            // Handle other error types...
        }
    }
};
```

## Performance Considerations

### Memory Management
- The WebView2 engine manages its own memory
- Disposing the control properly cleans up resources
- Avoid creating multiple WebView2 instances unnecessarily

### Async Operations
- Always use async/await for WebView2 operations
- Avoid blocking the UI thread during navigation
- Use cancellation tokens for long-running operations

### Resource Cleanup
```csharp
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // WebView2 resources are automatically cleaned up
        // Additional cleanup can be added here if needed
    }
    base.Dispose(disposing);
}
```

## Troubleshooting

### Common Issues

#### WebView2 Runtime Not Found
**Problem**: `WebView2RuntimeNotFoundException` during initialization
**Solution**: Install WebView2 Runtime from Microsoft's website or use Fixed Version distribution

#### Designer Issues
**Problem**: Control doesn't appear in toolbox or designer
**Solution**: 
1. Ensure WebView2 SDK assemblies are in the correct location
2. Rebuild the solution
3. Reset the Visual Studio toolbox

#### Context Menu Not Showing
**Problem**: KryptonContextMenu doesn't appear on right-click
**Solution**: 
1. Ensure `KryptonContextMenu` property is set
2. Check that the menu has items added
3. Verify the menu is not disposed

#### Navigation Failures
**Problem**: Navigation fails with various error codes
**Solution**: 
1. Check network connectivity
2. Verify URL format
3. Handle navigation events for proper error reporting

### Debugging Tips
1. Enable DevTools for debugging web content
2. Use `CoreWebView2.Settings.AreDevToolsEnabled = true`
3. Check WebView2 logs in `%TEMP%\WebView2\`
4. Use F12 developer tools in the WebView2 control

## Migration from KryptonWebBrowser

### Key Differences
| Feature | KryptonWebBrowser | KryptonWebView2 |
|---------|-------------------|-----------------|
| Engine | Internet Explorer | Microsoft Edge Chromium |
| Performance | Slower, limited | Fast, modern |
| Standards | Limited HTML5/CSS3 | Full HTML5/CSS3 |
| JavaScript | Limited ES5 | Full ES6+ |
| Async | Synchronous | Async/Await |

### Migration Steps
1. Replace `KryptonWebBrowser` with `KryptonWebView2`
2. Add async initialization: `await EnsureCoreWebView2Async()`
3. Update navigation calls to use `CoreWebView2.Navigate()`
4. Update event handlers to use WebView2 events
5. Test thoroughly as behavior may differ

## Best Practices

### Design Time
- Use the Visual Studio designer for layout
- Set properties through the Properties window
- Test in different themes during development

### Runtime
- Always initialize WebView2 asynchronously
- Handle initialization errors gracefully
- Provide user feedback during navigation
- Use appropriate timeout values for network operations

### Security
- Be cautious with JavaScript execution
- Validate all user input before navigation
- Consider Content Security Policy for web content
- Use HTTPS for sensitive operations

## Examples

### Complete Example
See `KryptonWebView2Test.cs` for a complete working example that demonstrates:
- Control initialization
- Navigation with error handling
- Custom context menu
- Navigation controls (Back, Forward, Refresh)
- Address bar integration

### Integration Examples
The control can be integrated into various scenarios:
- Help systems with local HTML content
- Web-based configuration interfaces
- Embedded web applications
- Rich content display with modern web standards

## API Reference

For complete API documentation, see the inline XML documentation in the source code. The control inherits all properties and methods from the base `WebView2` control while adding Krypton-specific functionality. More can be found [here](KryptonWebView2API.md).

### Key Properties
- `KryptonContextMenu`: Custom context menu for right-click operations
- `CreateToolStripRenderer()`: Creates themed renderer for tool strips
- `GetResolvedPalette()`: Gets the current active palette

### Key Events
All WebView2 events are available:
- `NavigationStarting`: Fired before navigation begins
- `NavigationCompleted`: Fired after navigation completes
- `DocumentTitleChanged`: Fired when document title changes
- `WebMessageReceived`: Fired when JavaScript sends messages to C#

## Support and Resources

- **Krypton Toolkit Documentation**: [GitHub Repository](https://github.com/Krypton-Suite/Standard-Toolkit)
- **WebView2 Documentation**: [Microsoft WebView2 Docs](https://docs.microsoft.com/en-us/microsoft-edge/webview2/)
- **WebView2 Runtime**: [Download from Microsoft](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)
- **Issues and Bug Reports**: [GitHub Issues](https://github.com/Krypton-Suite/Standard-Toolkit/issues)
