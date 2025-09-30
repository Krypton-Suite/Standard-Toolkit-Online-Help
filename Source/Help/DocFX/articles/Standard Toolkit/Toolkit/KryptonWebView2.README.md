# KryptonWebView2 Control

## Overview

The `KryptonWebView2` control is a modern web browser component that integrates Microsoft's WebView2 engine with the Krypton Toolkit's theming system. It provides a consistent look and feel with other Krypton controls while offering cutting-edge web rendering capabilities.

## Features

### ✅ **Implemented Features**
- **Modern Web Engine**: Based on Microsoft Edge Chromium
- **Krypton Theming**: Full integration with Krypton's theming system
- **Custom Context Menus**: KryptonContextMenu support with proper theming
- **Designer Support**: Visual Studio designer integration
- **Async Operations**: Modern async/await pattern for WebView2 operations
- **Cross-Platform Compatibility**: .NET Framework 4.7.2+ and .NET 8+ support
- **Comprehensive Documentation**: Extensive API and developer documentation
- **Test Form**: Complete working example with navigation controls

### 🔧 **Technical Features**
- **Double Buffering**: Smooth rendering with reduced flicker
- **Palette Integration**: Automatic theme updates
- **Error Handling**: Comprehensive error handling for initialization and navigation
- **Resource Management**: Proper cleanup and disposal
- **Message Processing**: Custom Windows message handling for context menus

## Files Structure

```
Source/Krypton Components/Krypton.Toolkit/Controls Toolkit/
├── KryptonWebView2.cs                           # Main control implementation
├── KryptonWebView2.Documentation.md             # Comprehensive developer guide
├── KryptonWebView2.API.md                       # Complete API reference
├── KryptonWebView2.README.md                    # This file
└── ToolboxBitmaps/WebView2.bmp                  # Toolbox icon

Source/Krypton Components/Krypton.Toolkit/Designers/Designers/
└── KryptonWebView2Designer.cs                   # Designer support

Source/Krypton Components/TestForm/
├── KryptonWebView2Test.cs                       # Test form implementation
├── KryptonWebView2Test.Designer.cs              # Test form designer
└── KryptonWebView2Test.resx                     # Test form resources
```

## Quick Start

### 1. Basic Usage
```csharp
// Create the control
var webView = new KryptonWebView2();
webView.Size = new Size(800, 600);

// Initialize WebView2 engine
await webView.EnsureCoreWebView2Async();

// Navigate to a URL
webView.CoreWebView2?.Navigate("https://example.com");
```

### 2. Custom Context Menu
```csharp
var contextMenu = new KryptonContextMenu();
contextMenu.Items.Add(new KryptonContextMenuItem("Copy"));
contextMenu.Items.Add(new KryptonContextMenuItem("Paste"));

webView.KryptonContextMenu = contextMenu;
```

### 3. Error Handling
```csharp
try
{
    await webView.EnsureCoreWebView2Async();
}
catch (WebView2RuntimeNotFoundException)
{
    MessageBox.Show("WebView2 Runtime is not installed.");
}
```

## Requirements

### System Requirements
- **WebView2 Runtime**: Must be installed on target systems
- **Windows Platform**: Windows 7 SP1 or later (Windows 10+ recommended)
- **.NET Framework**: 4.7.2 or later
- **.NET**: 8.0 or later

### Development Requirements
- **Visual Studio**: 2019 or later (for designer support)
- **WebView2 SDK**: Assemblies must be available (see Setup section)

## Setup Instructions

### 1. WebView2 SDK Setup
1. Download the WebView2 SDK from Microsoft
2. Extract the assemblies to a `WebView2SDK` folder at the repository root:
   ```
   WebView2SDK/
   ├── Microsoft.Web.WebView2.Core.dll
   ├── Microsoft.Web.WebView2.WinForms.dll
   └── WebView2Loader.dll
   ```

### 2. Project Configuration
The project file already includes the necessary assembly references:
- Conditional references for .NET Framework and .NET 8+
- Proper hint paths to the WebView2SDK folder
- Toolbox bitmap integration

### 3. Runtime Distribution
Choose one of these distribution methods:

#### Option A: Evergreen Distribution (Recommended)
- Users install WebView2 Runtime from Microsoft
- Automatic updates via Windows Update
- Smaller application size

#### Option B: Fixed Version Distribution
- Bundle specific WebView2 Runtime with your application
- More control over version and updates
- Larger application size

## Testing

### Running the Test Form
1. Build the solution
2. Run the TestForm project
3. Navigate to the KryptonWebView2 test form
4. Test various features:
   - Navigation with address bar
   - Back/Forward/Refresh buttons
   - Error handling scenarios

### Test Scenarios
- **Normal Navigation**: Test with various websites
- **Error Handling**: Test with invalid URLs
- **Context Menu**: Right-click to test custom context menu
- **Theme Changes**: Switch themes to test integration
- **Resize**: Test control resizing and layout

## API Documentation

### Key Properties
- `KryptonContextMenu`: Custom context menu for right-click operations
- `CoreWebView2`: Access to WebView2 functionality (after initialization)
- `DocumentTitle`: Current document title
- `Source`: Current page URI

### Key Methods
- `EnsureCoreWebView2Async()`: Initialize WebView2 engine
- `CreateToolStripRenderer()`: Create themed renderer for tool strips
- `GetResolvedPalette()`: Get current active palette

### Key Events
- `NavigationStarting`: Before navigation begins
- `NavigationCompleted`: After navigation completes
- `DocumentTitleChanged`: When document title changes
- `WebMessageReceived`: When JavaScript sends messages to C#

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

## Troubleshooting

### Common Issues

#### WebView2 Runtime Not Found
**Problem**: `WebView2RuntimeNotFoundException` during initialization  
**Solution**: Install WebView2 Runtime from Microsoft's website

#### Designer Issues
**Problem**: Control doesn't appear in toolbox or designer  
**Solution**: 
1. Ensure WebView2 SDK assemblies are in correct location
2. Rebuild the solution
3. Reset the Visual Studio toolbox

#### Context Menu Not Showing
**Problem**: KryptonContextMenu doesn't appear on right-click  
**Solution**: 
1. Ensure `KryptonContextMenu` property is set
2. Check that the menu has items added
3. Verify the menu is not disposed

### Debug Tips
1. Enable DevTools: `CoreWebView2.Settings.AreDevToolsEnabled = true`
2. Check WebView2 logs in `%TEMP%\WebView2\`
3. Use F12 developer tools in the WebView2 control
4. Monitor navigation events for error details

## Performance Considerations

### Memory Management
- WebView2 engine manages its own memory efficiently
- Multiple WebView2 instances share the same browser process
- Dispose the control properly to clean up resources
- Avoid creating unnecessary WebView2 instances

### Async Operations
- Always use async/await for WebView2 operations
- Avoid blocking the UI thread during navigation
- Use cancellation tokens for long-running operations

## Security Considerations

### WebView2 Security
- WebView2 runs in a separate process for security
- JavaScript execution can be controlled via settings
- Network access follows system proxy settings
- Content Security Policy can be enforced for web content

### Best Practices
- Be cautious with JavaScript execution
- Validate all user input before navigation
- Use HTTPS for sensitive operations
- Consider Content Security Policy for web content

## Contributing

### Development Guidelines
- Follow existing code patterns and naming conventions
- Add comprehensive XML documentation for new APIs
- Include unit tests for new functionality
- Update documentation for any API changes

### Code Style
- Use 4-space indentation (consistent with project)
- Follow existing comment and documentation patterns
- Use async/await for WebView2 operations
- Handle exceptions appropriately

## Support and Resources

### Documentation
- **Developer Guide**: `KryptonWebView2.Documentation.md`
- **API Reference**: `KryptonWebView2.API.md`
- **Inline Documentation**: XML comments in source code

### External Resources
- **Krypton Toolkit**: [GitHub Repository](https://github.com/Krypton-Suite/Standard-Toolkit)
- **WebView2 Documentation**: [Microsoft WebView2 Docs](https://docs.microsoft.com/en-us/microsoft-edge/webview2/)
- **WebView2 Runtime**: [Download from Microsoft](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)

### Issues and Support
- **Bug Reports**: [GitHub Issues](https://github.com/Krypton-Suite/Standard-Toolkit/issues)
- **Feature Requests**: [GitHub Issues](https://github.com/Krypton-Suite/Standard-Toolkit/issues)
- **Community**: [GitHub Discussions](https://github.com/Krypton-Suite/Standard-Toolkit/discussions)

## License

This implementation follows the same BSD 3-Clause License as the Krypton Toolkit project.

## Version History

### Initial Implementation
- Basic WebView2 control with Krypton theming
- Custom context menu support
- Designer integration
- Comprehensive documentation
- Test form with navigation controls

### Future Enhancements
- Additional WebView2 features integration
- Enhanced theming options
- Performance optimizations
- Additional test scenarios
