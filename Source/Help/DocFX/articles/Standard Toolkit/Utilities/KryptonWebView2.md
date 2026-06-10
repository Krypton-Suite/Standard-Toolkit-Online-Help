# KryptonWebView2 Documentation Index

## Overview

This documentation suite provides comprehensive guidance for developers using the `KryptonWebView2` control, a modern web browser control that integrates Microsoft's WebView2 engine with the Krypton Toolkit's theming system.

## Documentation Structure

### 📚 [Developer Guide](KryptonWebView2DeveloperGuide.md)

Complete developer documentation covering all aspects of the control.

- **Quick Start**: Get up and running in minutes
- **Architecture Overview**: Understand the control's design and components
- **API Reference**: Detailed method and property documentation
- **Advanced Features**: WebView2 integration, JavaScript communication, and custom navigation
- **Theming Integration**: Full integration with Krypton's palette system
- **Context Menu System**: Customizable right-click menus
- **Performance Considerations**: Optimization techniques and best practices
- **Migration Guide**: Transitioning from legacy controls
- **Best Practices**: Recommended patterns and approaches

### 🔧 [API Reference](KryptonWebView2APIReference.md)

Comprehensive API documentation with detailed signatures and examples.

- **Class Hierarchy**: Complete inheritance structure
- **Constructors**: Initialization methods and parameters
- **Properties**: All public properties with descriptions and examples
- **Methods**: Public and protected methods with usage examples
- **Events**: Event handling and subscription patterns
- **Inherited Members**: WebView2 base class functionality
- **Requirements**: System requirements and dependencies
- **Related Types**: Associated Krypton Toolkit classes

### 💡 [Examples and Use Cases](KryptonWebView2Examples.md)

Practical, real-world examples demonstrating various usage scenarios.

- **Basic Web Browser**: Complete browser implementation
- **Custom Context Menu**: Advanced context menu with submenus
- **Theme Integration**: Dynamic theme application
- **JavaScript Integration**: Bidirectional communication between C# and JavaScript
- **Navigation Control**: Custom navigation handling and error management
- **Error Handling**: Comprehensive error handling strategies
- **Performance Optimization**: Memory management and performance tuning

### 🛠️ [Troubleshooting and FAQ](KryptonWebView2Troubleshooting.md)

Common issues, solutions, and frequently asked questions.

- **Common Issues**: WebView2 runtime problems, toolbox issues, designer errors
- **Installation Problems**: NuGet package issues, assembly loading errors
- **Runtime Errors**: Navigation failures, process failures
- **Performance Issues**: Slow initialization, high memory usage
- **Theming Problems**: Theme not applied, inconsistent appearance
- **JavaScript Integration Issues**: Script execution failures, message communication
- **Context Menu Issues**: Custom menu not showing
- **FAQ**: Frequently asked questions with detailed answers

## Quick Navigation

### By Task

- **Getting Started**: [Developer Guide - Quick Start](KryptonWebView2DeveloperGuide.md#quick-start)
- **API Lookup**: [API Reference](KryptonWebView2APIReference.md)
- **Code Examples**: [Examples and Use Cases](KryptonWebView2Examples.md)
- **Problem Solving**: [Troubleshooting and FAQ](KryptonWebView2Troubleshooting.md)

### By Feature

- **Basic Usage**: [Developer Guide - Quick Start](KryptonWebView2DeveloperGuide.md#quick-start)
- **Context Menus**: [Developer Guide - Context Menu System](KryptonWebView2DeveloperGuide.md#context-menu-system)
- **Theming**: [Developer Guide - Theming Integration](KryptonWebView2DeveloperGuide.md#theming-integration)
- **JavaScript**: [Examples - JavaScript Integration](KryptonWebView2Examples.md#javascript-integration)
- **Performance**: [Developer Guide - Performance Considerations](KryptonWebView2DeveloperGuide.md#performance-considerations)
- **Error Handling**: [Examples - Error Handling](KryptonWebView2Examples.md#error-handling)

### By Experience Level

- **Beginner**: Start with [Developer Guide - Quick Start](KryptonWebView2DeveloperGuide.md#quick-start)
- **Intermediate**: Review [Examples and Use Cases](KryptonWebView2Examples.md)
- **Advanced**: Explore [API Reference](KryptonWebView2APIReference.md) and [Performance Considerations](KryptonWebView2DeveloperGuide.md#performance-considerations)

## Key Features Covered

### 🎨 **Theming Integration**

- Automatic palette system integration via `StateCommon`, `StateNormal`, `StateActive`, and `StateDisabled`
- `BackColor`, `ForeColor`, and `DefaultBackgroundColor` synchronized from palette (hidden from designer)
- Dynamic theme and focus-state updates
- Custom theme injection into web content (optional)
- Consistent appearance with other Krypton controls

### 🖱️ **Context Menu System**

- Customizable right-click menus
- KryptonContextMenu integration
- Dynamic menu generation
- Keyboard and mouse activation support

### 🌐 **WebView2 Integration**

- Modern web rendering engine
- Full WebView2 API access
- JavaScript execution and communication
- Navigation control and error handling

### ⚡ **Performance Optimization**

- Async initialization patterns
- Memory management strategies
- Resource optimization techniques
- Error handling and recovery

### 🔧 **Developer Experience**

- Visual Studio designer support
- Toolbox integration
- Comprehensive error handling
- Extensive documentation and examples

## Prerequisites

Before using KryptonWebView2, ensure you have:

- **Windows 10** version 1803 (build 17134) or later
- **WebView2 Runtime** installed on target systems
- **WebView2 SDK assemblies** for build (bundled under `Lib/WebView2` or via setup scripts — see [WebView2 SDK Setup](WebView2SDKSetup.md))
- **.NET Framework 4.7.2+** or a supported modern `-windows` TFM (per `Krypton.Toolkit.Utilities`)
- **Visual Studio 2022** recommended for development
- **Krypton Toolkit** installed and configured

## Getting Help

### Documentation Resources

1. **Start Here**: [Developer Guide - Quick Start](KryptonWebView2DeveloperGuide.md#quick-start)
2. **Find Examples**: [Examples and Use Cases](KryptonWebView2Examples.md)
3. **Look Up APIs**: [API Reference](KryptonWebView2APIReference.md)
4. **Solve Problems**: [Troubleshooting and FAQ](KryptonWebView2Troubleshooting.md)

### External Resources

- [Microsoft WebView2 Documentation](https://docs.microsoft.com/en-us/microsoft-edge/webview2/)
- [Krypton Toolkit GitHub](https://github.com/Krypton-Suite/Standard-Toolkit)
- [WebView2 Runtime Download](https://developer.microsoft.com/en-us/microsoft-edge/webview2/)

### Community Support

- **GitHub Issues**: Report bugs and request features
- **Discussions**: Ask questions and share solutions
- **Pull Requests**: Contribute improvements and fixes

## Version Information

This documentation covers KryptonWebView2 as part of the Krypton Toolkit Suite. The full control is compiled when `WEBVIEW2_AVAILABLE` is defined (bundled WebView2 SDK under `Lib/WebView2`); see [WebView2 SDK Setup](WebView2SDKSetup.md).

### Compatibility Matrix

| Framework | WebView2 Runtime | Supported |
| --------- | ---------------- | --------- |
| .NET Framework 4.7.2+ (`net472`, `net48`, `net481`) | 1.0.3485.44+ | Yes (when `WEBVIEW2_AVAILABLE`) |
| .NET 8.0+ Windows (`net8.0-windows` and later) | 1.0.3485.44+ | Yes |

**Note:** The full control is compiled when bundled WebView2 SDK assemblies are present under `Krypton.Toolkit.Utilities/Lib/WebView2` (`WEBVIEW2_AVAILABLE`). Without them, a minimal stub is built. Windows only; WebView2 Runtime must be installed on target machines.
