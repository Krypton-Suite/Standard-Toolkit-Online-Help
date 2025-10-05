# KryptonWebView2 Troubleshooting and FAQ

## Table of Contents
1. [Common Issues](#common-issues)
2. [Installation Problems](#installation-problems)
3. [Runtime Errors](#runtime-errors)
4. [Performance Issues](#performance-issues)
5. [Theming Problems](#theming-problems)
6. [JavaScript Integration Issues](#javascript-integration-issues)
7. [Context Menu Issues](#context-menu-issues)
8. [Frequently Asked Questions](#frequently-asked-questions)

## Common Issues

### Issue: WebView2 Runtime Not Found

**Symptoms:**
- `WebView2RuntimeNotFoundException` when calling `EnsureCoreWebView2Async()`
- Control fails to initialize
- Error message about missing WebView2 runtime

**Solutions:**

1. **Install WebView2 Runtime:**
   ```csharp
   try
   {
       await webView.EnsureCoreWebView2Async();
   }
   catch (WebView2RuntimeNotFoundException)
   {
       var result = MessageBox.Show(
           "WebView2 Runtime is not installed. Would you like to download it?",
           "WebView2 Runtime Required",
           MessageBoxButtons.YesNo,
           MessageBoxIcon.Warning);
       
       if (result == DialogResult.Yes)
       {
           Process.Start("https://developer.microsoft.com/en-us/microsoft-edge/webview2/");
       }
   }
   ```

2. **Check Runtime Installation:**
   ```csharp
   private bool IsWebView2RuntimeInstalled()
   {
       try
       {
           var version = CoreWebView2Environment.GetAvailableBrowserVersionString();
           return !string.IsNullOrEmpty(version);
       }
       catch
       {
           return false;
       }
   }
   ```

3. **Use Fixed Version Runtime:**
   ```csharp
   var options = new CoreWebView2EnvironmentOptions();
   var environment = await CoreWebView2Environment.CreateAsync(null, null, options);
   await webView.EnsureCoreWebView2Async(environment);
   ```

### Issue: Control Not Appearing in Toolbox

**Symptoms:**
- KryptonWebView2 not visible in Visual Studio toolbox
- Cannot drag control onto form

**Solutions:**

1. **Check Conditional Compilation:**
   - Ensure `WEBVIEW2_AVAILABLE` is defined in project settings
   - Verify WebView2 NuGet package is installed

2. **Rebuild Solution:**
   ```cmd
   dotnet clean
   dotnet build
   ```

3. **Reset Toolbox:**
   - Right-click toolbox → Reset Toolbox
   - Or Tools → Options → Windows Forms Designer → General → Reset Toolbox

### Issue: Designer Errors

**Symptoms:**
- Designer shows errors when WebView2 control is on form
- Cannot open form in designer

**Solutions:**

1. **Add Designer Support:**
   ```csharp
   [Designer(typeof(KryptonWebView2Designer))]
   public class KryptonWebView2 : WebView2
   ```

2. **Handle Designer Mode:**
   ```csharp
   public KryptonWebView2()
   {
       if (!DesignMode)
       {
           // Only initialize WebView2 in runtime
           _ = InitializeWebView2Async();
       }
   }
   ```

## Installation Problems

### Issue: NuGet Package Installation Fails

**Symptoms:**
- `dotnet add package Microsoft.Web.WebView2` fails
- Package restore errors

**Solutions:**

1. **Clear NuGet Cache:**
   ```cmd
   dotnet nuget locals all --clear
   ```

2. **Update NuGet Sources:**
   ```cmd
   dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
   ```

3. **Manual Package Installation:**
   - Download package from NuGet.org
   - Install manually via Package Manager Console

### Issue: Assembly Loading Errors

**Symptoms:**
- `FileNotFoundException` for WebView2 assemblies
- `BadImageFormatException`

**Solutions:**

1. **Check Target Framework:**
   - Ensure project targets .NET Framework 4.7.2+ or .NET 8+
   - Verify platform target matches (x86/x64/AnyCPU)

2. **Copy Assemblies Manually:**
   ```csharp
   // Copy WebView2 assemblies to output directory
   <ItemGroup>
     <Content Include="WebView2SDK\*.dll">
       <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>
     </Content>
   </ItemGroup>
   ```

## Runtime Errors

### Issue: Navigation Failures

**Symptoms:**
- `NavigationCompleted` event shows `IsSuccess = false`
- Pages fail to load

**Solutions:**

1. **Handle Navigation Errors:**
   ```csharp
   private void OnNavigationCompleted(object? sender, CoreWebView2NavigationCompletedEventArgs e)
   {
       if (!e.IsSuccess)
       {
           string errorMessage = e.WebErrorStatus switch
           {
               CoreWebView2WebErrorStatus.ConnectionTimedOut => "Connection timed out",
               CoreWebView2WebErrorStatus.ConnectionRefused => "Connection refused",
               CoreWebView2WebErrorStatus.HostNameMismatch => "Host name mismatch",
               _ => $"Navigation failed: {e.WebErrorStatus}"
           };
           
           MessageBox.Show(errorMessage, "Navigation Error", MessageBoxButtons.OK, MessageBoxIcon.Warning);
       }
   }
   ```

2. **Retry Failed Navigations:**
   ```csharp
   private async Task NavigateWithRetry(string url, int maxRetries = 3)
   {
       for (int i = 0; i < maxRetries; i++)
       {
           try
           {
               webView.CoreWebView2?.Navigate(url);
               return;
           }
           catch (Exception ex)
           {
               if (i == maxRetries - 1)
               {
                   MessageBox.Show($"Failed to navigate after {maxRetries} attempts: {ex.Message}");
               }
               else
               {
                   await Task.Delay(1000 * (i + 1)); // Exponential backoff
               }
           }
       }
   }
   ```

### Issue: Process Failures

**Symptoms:**
- `ProcessFailed` event fires
- Browser process exits unexpectedly

**Solutions:**

1. **Handle Process Failures:**
   ```csharp
   private void OnProcessFailed(object? sender, CoreWebView2ProcessFailedEventArgs e)
   {
       switch (e.ProcessFailedKind)
       {
           case CoreWebView2ProcessFailedKind.BrowserProcessExited:
               // Restart browser process
               _ = Task.Run(async () => await RestartWebView2());
               break;
           case CoreWebView2ProcessFailedKind.RenderProcessExited:
               // Reload page
               Reload();
               break;
           case CoreWebView2ProcessFailedKind.RenderProcessUnresponsive:
               // Show user notification
               MessageBox.Show("Page is unresponsive. Reloading...");
               Reload();
               break;
       }
   }
   ```

2. **Restart WebView2:**
   ```csharp
   private async Task RestartWebView2()
   {
       try
       {
           await EnsureCoreWebView2Async();
           // Reconfigure settings and event handlers
       }
       catch (Exception ex)
       {
           MessageBox.Show($"Failed to restart WebView2: {ex.Message}");
       }
   }
   ```

## Performance Issues

### Issue: Slow Initialization

**Symptoms:**
- `EnsureCoreWebView2Async()` takes a long time
- UI freezes during initialization

**Solutions:**

1. **Async Initialization:**
   ```csharp
   private async void Form_Load(object sender, EventArgs e)
   {
       // Show loading indicator
       ShowLoadingIndicator();
       
       try
       {
           await webView.EnsureCoreWebView2Async();
           ConfigureWebView2Settings();
       }
       catch (Exception ex)
       {
           MessageBox.Show($"Initialization failed: {ex.Message}");
       }
       finally
       {
           HideLoadingIndicator();
       }
   }
   ```

2. **Preload WebView2:**
   ```csharp
   // Initialize WebView2 in background thread
   private async Task PreloadWebView2()
   {
       await Task.Run(async () =>
       {
           await webView.EnsureCoreWebView2Async();
       });
   }
   ```

### Issue: High Memory Usage

**Symptoms:**
- Application memory usage increases over time
- OutOfMemoryException

**Solutions:**

1. **Monitor Memory Usage:**
   ```csharp
   private async void MonitorMemoryUsage()
   {
       if (webView.CoreWebView2 != null)
       {
           var memoryInfo = await webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Runtime.getHeapUsage", "{}");
           Debug.WriteLine($"Memory usage: {memoryInfo}");
       }
   }
   ```

2. **Optimize Settings:**
   ```csharp
   private void OptimizeForMemory()
   {
       if (webView.CoreWebView2 != null)
       {
           var settings = webView.CoreWebView2.Settings;
           settings.IsGeneralAutofillEnabled = false;
           settings.IsPasswordAutosaveEnabled = false;
           settings.AreDefaultContextMenusEnabled = false;
       }
   }
   ```

## Theming Problems

### Issue: Theme Not Applied

**Symptoms:**
- WebView2 doesn't reflect Krypton theme changes
- Inconsistent appearance

**Solutions:**

1. **Force Theme Update:**
   ```csharp
   protected override void OnGlobalPaletteChanged(object? sender, EventArgs e)
   {
       base.OnGlobalPaletteChanged(sender, e);
       _ = ApplyThemeToWebContent();
   }
   
   private async Task ApplyThemeToWebContent()
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

2. **Inject Theme CSS:**
   ```csharp
   private async Task InjectThemeCSS()
   {
       if (webView.CoreWebView2 != null)
       {
           var palette = webView.GetResolvedPalette();
           var css = $@"
               :root {{
                   --krypton-primary: {palette.GetColorTable().Color1};
                   --krypton-secondary: {palette.GetColorTable().Color2};
                   --krypton-background: {palette.GetColorTable().Color3};
               }}
           ";
           
           await webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync($@"
               var style = document.createElement('style');
               style.textContent = `{css}`;
               document.head.appendChild(style);
           ");
       }
   }
   ```

## JavaScript Integration Issues

### Issue: JavaScript Execution Fails

**Symptoms:**
- `ExecuteScriptAsync()` throws exceptions
- Scripts don't execute

**Solutions:**

1. **Wait for Document Ready:**
   ```csharp
   private async Task ExecuteScriptWhenReady(string script)
   {
       if (webView.CoreWebView2 != null)
       {
           var readyScript = $@"
               if (document.readyState === 'complete') {{
                   {script}
               }} else {{
                   document.addEventListener('DOMContentLoaded', function() {{
                       {script}
                   }});
               }}
           ";
           
           await webView.CoreWebView2.ExecuteScriptAsync(readyScript);
       }
   }
   ```

2. **Handle Script Errors:**
   ```csharp
   private async Task ExecuteScriptSafely(string script)
   {
       try
       {
           var result = await webView.CoreWebView2.ExecuteScriptAsync(script);
           return result;
       }
       catch (Exception ex)
       {
           Debug.WriteLine($"Script execution failed: {ex.Message}");
           return null;
       }
   }
   ```

### Issue: Web Message Communication Fails

**Symptoms:**
- Messages from JavaScript not received
- `WebMessageReceived` event doesn't fire

**Solutions:**

1. **Enable Web Messages:**
   ```csharp
   private void EnableWebMessages()
   {
       if (webView.CoreWebView2 != null)
       {
           webView.CoreWebView2.Settings.IsWebMessageEnabled = true;
           webView.CoreWebView2.WebMessageReceived += OnWebMessageReceived;
       }
   }
   ```

2. **Setup Message Bridge:**
   ```csharp
   private async Task SetupMessageBridge()
   {
       if (webView.CoreWebView2 != null)
       {
           await webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(@"
               window.chrome.webview.addEventListener('message', function(event) {
                   console.log('Message received:', event.data);
               });
           ");
       }
   }
   ```

## Context Menu Issues

### Issue: Custom Context Menu Not Showing

**Symptoms:**
- Right-click shows default WebView2 menu
- Custom KryptonContextMenu not displayed

**Solutions:**

1. **Disable Default Context Menu:**
   ```csharp
   private void SetupCustomContextMenu()
   {
       if (webView.CoreWebView2 != null)
       {
           webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
       }
       
       var contextMenu = new KryptonContextMenu();
       contextMenu.Items.Add(new KryptonContextMenuItem("Custom Item"));
       webView.KryptonContextMenu = contextMenu;
   }
   ```

2. **Check Message Handling:**
   ```csharp
   protected override void WndProc(ref Message m)
   {
       if ((m.Msg == PI.WM_.CONTEXTMENU) && KryptonContextMenu != null)
       {
           // Handle context menu
           var mousePt = new Point(PI.LOWORD(m.LParam), PI.HIWORD(m.LParam));
           if (ClientRectangle.Contains(mousePt))
           {
               KryptonContextMenu.Show(this, PointToScreen(mousePt));
               return; // Consume the message
           }
       }
       
       base.WndProc(ref m);
   }
   ```

## Frequently Asked Questions

### Q: Can I use KryptonWebView2 without WebView2 Runtime?

**A:** No, WebView2 Runtime is required. The control will throw `WebView2RuntimeNotFoundException` if the runtime is not installed.

### Q: Is KryptonWebView2 compatible with .NET Framework?

**A:** Yes, it supports .NET Framework 4.7.2 and later, as well as .NET 8+.

### Q: How do I handle different screen DPI settings?

**A:** WebView2 automatically handles DPI scaling. Ensure your application is DPI-aware:

```csharp
[STAThread]
static void Main()
{
    Application.SetHighDpiMode(HighDpiMode.SystemAware);
    Application.EnableVisualStyles();
    Application.SetCompatibleTextRenderingDefault(false);
    Application.Run(new MainForm());
}
```

### Q: Can I use KryptonWebView2 in a multi-threaded application?

**A:** WebView2 controls must be created and accessed on the UI thread. Use `Invoke` or `BeginInvoke` for cross-thread operations:

```csharp
private void NavigateFromBackgroundThread(string url)
{
    if (InvokeRequired)
    {
        Invoke(new Action<string>(NavigateFromBackgroundThread), url);
        return;
    }
    
    webView.CoreWebView2?.Navigate(url);
}
```

### Q: How do I print web content?

**A:** Use the WebView2 print functionality:

```csharp
private void PrintWebContent()
{
    webView.CoreWebView2?.ExecuteScriptAsync("window.print()");
}
```

### Q: Can I capture screenshots of web content?

**A:** Yes, using the WebView2 screenshot API:

```csharp
private async Task<byte[]> CaptureScreenshot()
{
    if (webView.CoreWebView2 != null)
    {
        var result = await webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Page.captureScreenshot", "{}");
        // Parse result and return image data
    }
    return null;
}
```

### Q: How do I handle file downloads?

**A:** Handle the `DownloadStarting` event:

```csharp
private void SetupDownloadHandling()
{
    if (webView.CoreWebView2 != null)
    {
        webView.CoreWebView2.DownloadStarting += OnDownloadStarting;
    }
}

private void OnDownloadStarting(object? sender, CoreWebView2DownloadStartingEventArgs e)
{
    // Customize download behavior
    e.Handled = true;
    
    // Show save dialog
    var saveDialog = new SaveFileDialog();
    saveDialog.FileName = e.ResultFilePath;
    
    if (saveDialog.ShowDialog() == DialogResult.OK)
    {
        e.ResultFilePath = saveDialog.FileName;
        e.Handled = false; // Allow default download
    }
}
```

### Q: How do I clear browser cache and cookies?

**A:** Use the WebView2 data management APIs:

```csharp
private async Task ClearBrowserData()
{
    if (webView.CoreWebView2 != null)
    {
        // Clear cache
        await webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Network.clearBrowserCache", "{}");
        
        // Clear cookies
        await webView.CoreWebView2.CallDevToolsProtocolMethodAsync("Network.clearBrowserCookies", "{}");
    }
}
```

This comprehensive troubleshooting guide should help developers resolve common issues with the KryptonWebView2 control.
