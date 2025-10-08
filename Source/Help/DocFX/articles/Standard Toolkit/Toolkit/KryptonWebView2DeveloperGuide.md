# KryptonWebView2

## Overview

The `KryptonWebView2` control is a modern web browser control that integrates Microsoft's WebView2 engine with the Krypton Toolkit's theming system. It provides a consistent look and feel with other Krypton controls while offering modern web rendering capabilities based on Microsoft Edge Chromium.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Architecture Overview](#architecture-overview)
3. [API Reference](#api-reference)
4. [Advanced Features](#advanced-features)
5. [Theming Integration](#theming-integration)
6. [Context Menu System](#context-menu-system)
7. [Performance Considerations](#performance-considerations)
8. [Troubleshooting](#troubleshooting)
9. [Migration Guide](#migration-guide)
10. [Best Practices](#best-practices)

## Quick Start

### Basic Usage

```csharp
using Krypton.Toolkit;

// Create the control
var webView = new KryptonWebView2();
webView.Size = new Size(800, 600);
webView.Location = new Point(10, 10);

// Add to form
this.Controls.Add(webView);

// Initialize and navigate
await webView.EnsureCoreWebView2Async();
webView.CoreWebView2?.Navigate("https://example.com");
```

### With Custom Context Menu

```csharp
// Create custom context menu
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Copy", null, CopyAction));
contextMenu.Items.Add(new KryptonContextMenuItem("Paste", null, PasteAction));
contextMenu.Items.Add(new KryptonContextMenuSeparator());
contextMenu.Items.Add(new KryptonContextMenuItem("Refresh", null, RefreshAction));

// Assign to WebView2
webView.KryptonContextMenu = contextMenu;
```

## Architecture Overview

### Control Hierarchy

```
KryptonWebView2 : WebView2
├── Palette Integration
├── Context Menu System
├── Rendering System
└── Theme Management
```

### Key Components

1. **WebView2 Engine**: Microsoft's modern web rendering engine
2. **Krypton Palette System**: Theme and styling integration
3. **Context Menu System**: Customizable right-click menus
4. **Rendering Pipeline**: Double-buffered, optimized drawing

### Conditional Compilation

The control is wrapped in `#if WEBVIEW2_AVAILABLE` directives, ensuring it only compiles when WebView2 dependencies are available.

## API Reference

### Constructor

#### `KryptonWebView2()`

Initializes a new instance of the KryptonWebView2 class.

**Features Enabled:**
- Double buffering for smooth rendering
- Resize redraw for proper repainting
- Krypton palette system initialization
- Global palette change notifications

**Example:**
```csharp
var webView = new KryptonWebView2();
```

### Properties

#### `KryptonContextMenu`

```csharp
[Category("Behavior")]
[Description("The shortcut menu to show when the user right-clicks the page.")]
[DefaultValue(null)]
public KryptonContextMenu? KryptonContextMenu { get; set; }
```

**Description:** Gets and sets the KryptonContextMenu to show when right-clicked.

**Usage:**
```csharp
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Custom Action"));
webView.KryptonContextMenu = contextMenu;
```

**Behavior:**
- Overrides default WebView2 context menu
- Shows at mouse position for right-clicks
- Centers on control for keyboard activation (Menu key)
- Setting to `null` restores default behavior

### Methods

#### `CreateToolStripRenderer()`

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Advanced)]
public ToolStripRenderer? CreateToolStripRenderer()
```

**Description:** Creates a tool strip renderer appropriate for the current renderer/palette pair.

**Returns:** A `ToolStripRenderer` instance that provides Krypton-themed rendering for tool strips, or `null` if no renderer is available.

**Usage:**
```csharp
var renderer = webView.CreateToolStripRenderer();
if (renderer != null)
{
    myToolStrip.Renderer = renderer;
}
```

#### `GetResolvedPalette()`

```csharp
[Browsable(false)]
[EditorBrowsable(EditorBrowsableState.Never)]
public PaletteBase GetResolvedPalette()
```

**Description:** Gets the resolved palette currently being used for rendering.

**Returns:** A `PaletteBase` instance representing the currently active palette.

### Events

#### `OnGlobalPaletteChanged`

```csharp
protected virtual void OnGlobalPaletteChanged(object? sender, EventArgs e)
```

**Description:** Occurs when the global palette has been changed.

**Usage:** Override this method to respond to global theme changes.

## Advanced Features

### WebView2 Integration

The control inherits all WebView2 functionality while adding Krypton theming:

```csharp
// Initialize WebView2 engine
await webView.EnsureCoreWebView2Async();

// Access CoreWebView2 for advanced features
if (webView.CoreWebView2 != null)
{
    // Execute JavaScript
    await webView.CoreWebView2.ExecuteScriptAsync("console.log('Hello from KryptonWebView2!')");
    
    // Navigate to URL
    webView.CoreWebView2.Navigate("https://example.com");
    
    // Set user agent
    webView.CoreWebView2.Settings.UserAgent = "MyKryptonApp/1.0";
    
    // Handle navigation events
    webView.CoreWebView2.NavigationStarting += OnNavigationStarting;
    webView.CoreWebView2.NavigationCompleted += OnNavigationCompleted;
}
```

### Custom Navigation Handling

```csharp
private async void OnNavigationStarting(object? sender, CoreWebView2NavigationStartingEventArgs e)
{
    // Custom navigation logic
    if (e.Uri.Contains("blocked-site.com"))
    {
        e.Cancel = true;
        await webView.CoreWebView2.ExecuteScriptAsync("alert('Site blocked!')");
    }
}

private void OnNavigationCompleted(object? sender, CoreWebView2NavigationCompletedEventArgs e)
{
    if (e.IsSuccess)
    {
        // Navigation successful
        this.Text = $"Loaded: {webView.CoreWebView2.DocumentTitle}";
    }
    else
    {
        // Handle navigation error
        MessageBox.Show($"Navigation failed: {e.WebErrorStatus}");
    }
}
```

### JavaScript Integration

```csharp
// Inject JavaScript
await webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(@"
    window.kryptonTheme = {
        primaryColor: '#0078D4',
        backgroundColor: '#FFFFFF'
    };
");

// Call JavaScript functions
var result = await webView.CoreWebView2.ExecuteScriptAsync("getPageTitle()");
var title = JsonSerializer.Deserialize<string>(result);

// Handle JavaScript messages
webView.CoreWebView2.WebMessageReceived += OnWebMessageReceived;

private void OnWebMessageReceived(object? sender, CoreWebView2WebMessageReceivedEventArgs e)
{
    var message = e.TryGetWebMessageAsString();
    // Process message from web content
}
```

## Theming Integration

### Palette System

The control automatically integrates with Krypton's palette system:

```csharp
// Global theme changes are automatically applied
KryptonManager.GlobalPalette = PaletteOffice2013Blue;

// The control will automatically update its appearance
```

### Custom Theming

```csharp
// Access the resolved palette
var palette = webView.GetResolvedPalette();

// Create custom tool strip renderer
var renderer = webView.CreateToolStripRenderer();
if (renderer != null)
{
    // Apply to custom tool strips
    myCustomToolStrip.Renderer = renderer;
}
```

### Theme-Aware Web Content

```csharp
// Inject theme information into web content
private async void ApplyThemeToWebContent()
{
    var palette = webView.GetResolvedPalette();
    var primaryColor = palette.GetColorTable().Color1;
    
    var script = $@"
        document.documentElement.style.setProperty('--krypton-primary', '{primaryColor}');
        document.body.classList.add('krypton-themed');
    ";
    
    await webView.CoreWebView2.ExecuteScriptAsync(script);
}
```

## Context Menu System

### Basic Context Menu

```csharp
var contextMenu = new KryptonContextMenu();

// Add menu items
contextMenu.Items.Add(new KryptonContextMenuItem("Copy", null, CopyAction));
contextMenu.Items.Add(new KryptonContextMenuItem("Paste", null, PasteAction));
contextMenu.Items.Add(new KryptonContextMenuSeparator());
contextMenu.Items.Add(new KryptonContextMenuItem("Refresh", null, RefreshAction));

webView.KryptonContextMenu = contextMenu;
```

### Advanced Context Menu

```csharp
var contextMenu = new KryptonContextMenu();

// Add submenu
var editMenu = new KryptonContextMenuHeading("Edit");
editMenu.Items.Add(new KryptonContextMenuItem("Cut", Properties.Resources.CutIcon, CutAction));
editMenu.Items.Add(new KryptonContextMenuItem("Copy", Properties.Resources.CopyIcon, CopyAction));
editMenu.Items.Add(new KryptonContextMenuItem("Paste", Properties.Resources.PasteIcon, PasteAction));

// Add navigation submenu
var navMenu = new KryptonContextMenuHeading("Navigation");
navMenu.Items.Add(new KryptonContextMenuItem("Back", Properties.Resources.BackIcon, BackAction));
navMenu.Items.Add(new KryptonContextMenuItem("Forward", Properties.Resources.ForwardIcon, ForwardAction));
navMenu.Items.Add(new KryptonContextMenuItem("Refresh", Properties.Resources.RefreshIcon, RefreshAction));

contextMenu.Items.Add(editMenu);
contextMenu.Items.Add(navMenu);

webView.KryptonContextMenu = contextMenu;
```

### Dynamic Context Menu

```csharp
private void SetupDynamicContextMenu()
{
    var contextMenu = new KryptonContextMenu();
    
    // Add items based on current state
    if (webView.CoreWebView2?.CanGoBack == true)
    {
        contextMenu.Items.Add(new KryptonContextMenuItem("Back", null, BackAction));
    }
    
    if (webView.CoreWebView2?.CanGoForward == true)
    {
        contextMenu.Items.Add(new KryptonContextMenuItem("Forward", null, ForwardAction));
    }
    
    contextMenu.Items.Add(new KryptonContextMenuItem("Refresh", null, RefreshAction));
    
    webView.KryptonContextMenu = contextMenu;
}
```

## Performance Considerations

### Initialization

```csharp
// Initialize WebView2 engine asynchronously to avoid blocking UI
private async Task InitializeWebView2()
{
    try
    {
        // Show loading indicator
        ShowLoadingIndicator();
        
        // Initialize WebView2 engine
        await webView.EnsureCoreWebView2Async();
        
        // Configure settings for better performance
        webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
        webView.CoreWebView2.Settings.AreDevToolsEnabled = false;
        webView.CoreWebView2.Settings.IsStatusBarEnabled = false;
        
        // Hide loading indicator
        HideLoadingIndicator();
    }
    catch (Exception ex)
    {
        // Handle initialization errors
        MessageBox.Show($"Failed to initialize WebView2: {ex.Message}");
    }
}
```

### Memory Management

```csharp
// Proper disposal
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // Clean up WebView2 resources
        webView?.Dispose();
    }
    base.Dispose(disposing);
}
```

### Resource Optimization

```csharp
// Configure WebView2 for optimal performance
private void ConfigureWebView2Performance()
{
    if (webView.CoreWebView2 != null)
    {
        // Disable unnecessary features
        webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
        webView.CoreWebView2.Settings.AreDevToolsEnabled = false;
        webView.CoreWebView2.Settings.IsStatusBarEnabled = false;
        webView.CoreWebView2.Settings.AreHostObjectsAllowed = false;
        
        // Enable hardware acceleration
        webView.CoreWebView2.Settings.IsGeneralAutofillEnabled = false;
        webView.CoreWebView2.Settings.IsPasswordAutosaveEnabled = false;
    }
}
```

## Troubleshooting

### Common Issues

#### WebView2 Runtime Not Installed

**Error:** `WebView2 runtime not found`

**Solution:**
```csharp
try
{
    await webView.EnsureCoreWebView2Async();
}
catch (WebView2RuntimeNotFoundException)
{
    MessageBox.Show("WebView2 Runtime is not installed. Please install it from: https://developer.microsoft.com/en-us/microsoft-edge/webview2/");
}
```

#### Initialization Failures

**Error:** `EnsureCoreWebView2Async failed`

**Solution:**
```csharp
private async Task<bool> InitializeWebView2WithRetry()
{
    int maxRetries = 3;
    int retryCount = 0;
    
    while (retryCount < maxRetries)
    {
        try
        {
            await webView.EnsureCoreWebView2Async();
            return true;
        }
        catch (Exception ex)
        {
            retryCount++;
            if (retryCount >= maxRetries)
            {
                MessageBox.Show($"Failed to initialize WebView2 after {maxRetries} attempts: {ex.Message}");
                return false;
            }
            
            // Wait before retry
            await Task.Delay(1000 * retryCount);
        }
    }
    
    return false;
}
```

#### Context Menu Not Showing

**Issue:** Custom context menu not appearing

**Solution:**
```csharp
// Ensure context menu is properly assigned
if (webView.KryptonContextMenu == null)
{
    var contextMenu = new KryptonContextMenu();
    contextMenu.Items.Add(new KryptonContextMenuItem("Test"));
    webView.KryptonContextMenu = contextMenu;
}

// Check if WebView2 default context menus are disabled
if (webView.CoreWebView2 != null)
{
    webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
}
```

### Debugging Tips

#### Enable Developer Tools

```csharp
// Enable developer tools for debugging
webView.CoreWebView2.Settings.AreDevToolsEnabled = true;

// Open developer tools programmatically
webView.CoreWebView2.OpenDevToolsWindow();
```

#### Logging and Diagnostics

```csharp
// Enable logging
webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Runtime.enable", "{}");

// Handle console messages
webView.CoreWebView2.ConsoleMessageReceived += OnConsoleMessageReceived;

private void OnConsoleMessageReceived(object? sender, CoreWebView2ConsoleMessageReceivedEventArgs e)
{
    Debug.WriteLine($"WebView2 Console: {e.Message}");
}
```

## Migration Guide

### From WebBrowser Control

```csharp
// Old WebBrowser approach
var webBrowser = new WebBrowser();
webBrowser.Navigate("https://example.com");

// New KryptonWebView2 approach
var webView = new KryptonWebView2();
await webView.EnsureCoreWebView2Async();
webView.CoreWebView2?.Navigate("https://example.com");
```

### From KryptonWebBrowser

```csharp
// Old KryptonWebBrowser
var kryptonWebBrowser = new KryptonWebBrowser();
kryptonWebBrowser.Navigate("https://example.com");

// New KryptonWebView2
var webView = new KryptonWebView2();
await webView.EnsureCoreWebView2Async();
webView.CoreWebView2?.Navigate("https://example.com");
```

### Event Migration

```csharp
// WebBrowser events
webBrowser.DocumentCompleted += OnDocumentCompleted;
webBrowser.Navigating += OnNavigating;

// WebView2 events
webView.CoreWebView2.NavigationCompleted += OnNavigationCompleted;
webView.CoreWebView2.NavigationStarting += OnNavigationStarting;
```

## Best Practices

### 1. Async Initialization

```csharp
// Always initialize WebView2 asynchronously
private async void Form_Load(object sender, EventArgs e)
{
    await InitializeWebView2();
}

private async Task InitializeWebView2()
{
    try
    {
        await webView.EnsureCoreWebView2Async();
        // Configure settings after initialization
        ConfigureWebView2Settings();
    }
    catch (Exception ex)
    {
        // Handle initialization errors
        LogError($"WebView2 initialization failed: {ex.Message}");
    }
}
```

### 2. Proper Resource Management

```csharp
// Implement proper disposal
protected override void Dispose(bool disposing)
{
    if (disposing)
    {
        // Unsubscribe from events
        if (webView.CoreWebView2 != null)
        {
            webView.CoreWebView2.NavigationStarting -= OnNavigationStarting;
            webView.CoreWebView2.NavigationCompleted -= OnNavigationCompleted;
        }
        
        // Dispose WebView2 control
        webView?.Dispose();
    }
    base.Dispose(disposing);
}
```

### 3. Error Handling

```csharp
// Comprehensive error handling
private async Task NavigateSafely(string url)
{
    try
    {
        if (webView.CoreWebView2 != null)
        {
            await webView.CoreWebView2.NavigateAsync(url);
        }
    }
    catch (WebView2RuntimeNotFoundException)
    {
        ShowWebView2RuntimeError();
    }
    catch (Exception ex)
    {
        LogError($"Navigation failed: {ex.Message}");
        ShowErrorMessage($"Failed to navigate to {url}");
    }
}
```

### 4. Theme Integration

```csharp
// Respond to theme changes
private void OnGlobalPaletteChanged(object? sender, EventArgs e)
{
    // Update web content theme
    ApplyThemeToWebContent();
}

private async void ApplyThemeToWebContent()
{
    if (webView.CoreWebView2 != null)
    {
        var palette = webView.GetResolvedPalette();
        var primaryColor = palette.GetColorTable().Color1;
        
        var script = $@"
            document.documentElement.style.setProperty('--krypton-primary', '{primaryColor}');
        ";
        
        await webView.CoreWebView2.ExecuteScriptAsync(script);
    }
}
```

### 5. Performance Optimization

```csharp
// Optimize for performance
private void OptimizeWebView2Performance()
{
    if (webView.CoreWebView2 != null)
    {
        // Disable unnecessary features
        webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
        webView.CoreWebView2.Settings.AreDevToolsEnabled = false;
        webView.CoreWebView2.Settings.IsStatusBarEnabled = false;
        
        // Configure for better performance
        webView.CoreWebView2.Settings.IsGeneralAutofillEnabled = false;
        webView.CoreWebView2.Settings.IsPasswordAutosaveEnabled = false;
    }
}
```

## Conclusion

The `KryptonWebView2` control provides a powerful, modern web browsing experience while maintaining full integration with the Krypton Toolkit's theming system. By following the best practices outlined in this guide, developers can create rich, themed web applications that provide a consistent user experience across their entire application.

For more information about WebView2 capabilities, refer to the [Microsoft WebView2 documentation](https://docs.microsoft.com/en-us/microsoft-edge/webview2/).

For Krypton Toolkit theming information, refer to the [Krypton Toolkit documentation](https://github.com/Krypton-Suite/Standard-Toolkit).
