# KryptonWebView2

## Overview

`KryptonWebView2` hosts the Microsoft Edge WebView2 engine with Krypton palette integration, `KryptonContextMenu` support, and designer support. Use it when you need modern Chromium-based web content inside a themed WinForms application.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Requires:** WebView2 runtime and `WEBVIEW2_AVAILABLE` build configuration (see project conditional compilation)

## Key features

- Chromium-based rendering via `Microsoft.Web.WebView2.WinForms`
- Palette-driven border and background styling consistent with other Krypton controls
- `KryptonContextMenu` for themed right-click menus
- Async initialization via `EnsureCoreWebView2Async()`
- Navigation, zoom, and `CoreWebView2` scripting APIs from the WebView2 SDK

## Basic usage

```csharp
using Krypton.Toolkit.Utilities;

var webView = new KryptonWebView2
{
    Dock = DockStyle.Fill,
    KryptonContextMenu = myContextMenu
};

await webView.EnsureCoreWebView2Async();
webView.CoreWebView2?.Navigate("https://example.com");
```

## Comparison with KryptonWebBrowser

| Control | Engine | Status |
| --- | --- | --- |
| [KryptonWebBrowser](../Toolkit/Controls/KryptonWebBrowser.md) | Legacy IE `WebBrowser` | Maintained for compatibility |
| `KryptonWebView2` | Microsoft Edge WebView2 | Preferred for new development |

## See also

- [KryptonWebBrowser](../Toolkit/Controls/KryptonWebBrowser.md)
- [KryptonContextMenu](../Toolkit/Components/KryptonContextMenu.md)
- [Microsoft WebView2 documentation](https://learn.microsoft.com/microsoft-edge/webview2/)
