# KryptonWebView2 Examples and Use Cases

## Table of Contents
1. [Basic Web Browser](#basic-web-browser)
2. [Custom Context Menu](#custom-context-menu)
3. [Theme Integration](#theme-integration)
4. [JavaScript Integration](#javascript-integration)
5. [Navigation Control](#navigation-control)
6. [Error Handling](#error-handling)
7. [Performance Optimization](#performance-optimization)

## Basic Web Browser

### Simple Web Browser Form

```csharp
public partial class WebBrowserForm : KryptonForm
{
    private KryptonWebView2 webView;
    private KryptonButton btnNavigate;
    private KryptonTextBox txtUrl;
    private KryptonButton btnBack, btnForward, btnRefresh;

    public WebBrowserForm()
    {
        InitializeComponent();
        InitializeWebView();
    }

    private void InitializeWebView()
    {
        webView = new KryptonWebView2();
        webView.Dock = DockStyle.Fill;
        webView.Location = new Point(0, 50);
        webView.Size = new Size(800, 550);
        
        this.Controls.Add(webView);
        
        // Initialize WebView2 engine
        _ = InitializeWebView2Async();
    }

    private async Task InitializeWebView2Async()
    {
        try
        {
            await webView.EnsureCoreWebView2Async();
            ConfigureWebView2Settings();
            SetupEventHandlers();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"Failed to initialize WebView2: {ex.Message}");
        }
    }

    private void ConfigureWebView2Settings()
    {
        if (webView.CoreWebView2 != null)
        {
            webView.CoreWebView2.Settings.AreDefaultContextMenusEnabled = false;
            webView.CoreWebView2.Settings.AreDevToolsEnabled = false;
            webView.CoreWebView2.Settings.IsStatusBarEnabled = false;
        }
    }

    private void SetupEventHandlers()
    {
        if (webView.CoreWebView2 != null)
        {
            webView.CoreWebView2.NavigationStarting += OnNavigationStarting;
            webView.CoreWebView2.NavigationCompleted += OnNavigationCompleted;
            webView.CoreWebView2.DocumentTitleChanged += OnDocumentTitleChanged;
        }
    }

    private void OnNavigationStarting(object? sender, CoreWebView2NavigationStartingEventArgs e)
    {
        // Update URL textbox
        txtUrl.Text = e.Uri;
        
        // Show loading indicator
        btnRefresh.Text = "Loading...";
        btnRefresh.Enabled = false;
    }

    private void OnNavigationCompleted(object? sender, CoreWebView2NavigationCompletedEventArgs e)
    {
        // Hide loading indicator
        btnRefresh.Text = "Refresh";
        btnRefresh.Enabled = true;
        
        // Update navigation buttons
        btnBack.Enabled = webView.CanGoBack;
        btnForward.Enabled = webView.CanGoForward;
        
        if (e.IsSuccess)
        {
            txtUrl.Text = webView.Source?.ToString() ?? "";
        }
        else
        {
            MessageBox.Show($"Navigation failed: {e.WebErrorStatus}");
        }
    }

    private void OnDocumentTitleChanged(object? sender, object e)
    {
        this.Text = $"Web Browser - {webView.DocumentTitle}";
    }

    private void btnNavigate_Click(object sender, EventArgs e)
    {
        if (!string.IsNullOrEmpty(txtUrl.Text))
        {
            string url = txtUrl.Text;
            if (!url.StartsWith("http://") && !url.StartsWith("https://"))
            {
                url = "https://" + url;
            }
            webView.CoreWebView2?.Navigate(url);
        }
    }

    private void btnBack_Click(object sender, EventArgs e)
    {
        webView.GoBack();
    }

    private void btnForward_Click(object sender, EventArgs e)
    {
        webView.GoForward();
    }

    private void btnRefresh_Click(object sender, EventArgs e)
    {
        webView.Reload();
    }
}
```

## Custom Context Menu

### Advanced Context Menu with Submenus

```csharp
public class WebView2ContextMenuBuilder
{
    private readonly KryptonWebView2 webView;

    public WebView2ContextMenuBuilder(KryptonWebView2 webView)
    {
        this.webView = webView;
    }

    public void BuildContextMenu()
    {
        var contextMenu = new KryptonContextMenu();

        // Edit submenu
        var editMenu = new KryptonContextMenuHeading("Edit");
        editMenu.Items.Add(new KryptonContextMenuItem("Cut", Properties.Resources.CutIcon, CutAction));
        editMenu.Items.Add(new KryptonContextMenuItem("Copy", Properties.Resources.CopyIcon, CopyAction));
        editMenu.Items.Add(new KryptonContextMenuItem("Paste", Properties.Resources.PasteIcon, PasteAction));
        editMenu.Items.Add(new KryptonContextMenuSeparator());
        editMenu.Items.Add(new KryptonContextMenuItem("Select All", null, SelectAllAction));

        // Navigation submenu
        var navMenu = new KryptonContextMenuHeading("Navigation");
        navMenu.Items.Add(new KryptonContextMenuItem("Back", Properties.Resources.BackIcon, BackAction));
        navMenu.Items.Add(new KryptonContextMenuItem("Forward", Properties.Resources.ForwardIcon, ForwardAction));
        navMenu.Items.Add(new KryptonContextMenuItem("Refresh", Properties.Resources.RefreshIcon, RefreshAction));
        navMenu.Items.Add(new KryptonContextMenuSeparator());
        navMenu.Items.Add(new KryptonContextMenuItem("Stop", Properties.Resources.StopIcon, StopAction));

        // Page submenu
        var pageMenu = new KryptonContextMenuHeading("Page");
        pageMenu.Items.Add(new KryptonContextMenuItem("View Source", null, ViewSourceAction));
        pageMenu.Items.Add(new KryptonContextMenuItem("Print", Properties.Resources.PrintIcon, PrintAction));
        pageMenu.Items.Add(new KryptonContextMenuItem("Save As...", Properties.Resources.SaveIcon, SaveAsAction));

        contextMenu.Items.Add(editMenu);
        contextMenu.Items.Add(navMenu);
        contextMenu.Items.Add(pageMenu);

        webView.KryptonContextMenu = contextMenu;
    }

    private void CutAction(object sender, EventArgs e)
    {
        webView.CoreWebView2?.ExecuteScriptAsync("document.execCommand('cut')");
    }

    private void CopyAction(object sender, EventArgs e)
    {
        webView.CoreWebView2?.ExecuteScriptAsync("document.execCommand('copy')");
    }

    private void PasteAction(object sender, EventArgs e)
    {
        webView.CoreWebView2?.ExecuteScriptAsync("document.execCommand('paste')");
    }

    private void SelectAllAction(object sender, EventArgs e)
    {
        webView.CoreWebView2?.ExecuteScriptAsync("document.execCommand('selectAll')");
    }

    private void BackAction(object sender, EventArgs e)
    {
        if (webView.CanGoBack)
        {
            webView.GoBack();
        }
    }

    private void ForwardAction(object sender, EventArgs e)
    {
        if (webView.CanGoForward)
        {
            webView.GoForward();
        }
    }

    private void RefreshAction(object sender, EventArgs e)
    {
        webView.Reload();
    }

    private void StopAction(object sender, EventArgs e)
    {
        webView.Stop();
    }

    private async void ViewSourceAction(object sender, EventArgs e)
    {
        if (webView.CoreWebView2 != null)
        {
            var html = await webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML");
            var sourceForm = new SourceViewerForm(html);
            sourceForm.Show();
        }
    }

    private void PrintAction(object sender, EventArgs e)
    {
        webView.CoreWebView2?.ExecuteScriptAsync("window.print()");
    }

    private void SaveAsAction(object sender, EventArgs e)
    {
        var saveDialog = new SaveFileDialog();
        saveDialog.Filter = "HTML Files (*.html)|*.html|All Files (*.*)|*.*";
        
        if (saveDialog.ShowDialog() == DialogResult.OK)
        {
            // Implementation for saving page content
            SavePageContent(saveDialog.FileName);
        }
    }

    private async void SavePageContent(string fileName)
    {
        if (webView.CoreWebView2 != null)
        {
            var html = await webView.CoreWebView2.ExecuteScriptAsync("document.documentElement.outerHTML");
            File.WriteAllText(fileName, html);
        }
    }
}
```

## Theme Integration

### Dynamic Theme Application

```csharp
public class ThemeAwareWebView2 : KryptonWebView2
{
    private Timer themeUpdateTimer;

    public ThemeAwareWebView2()
    {
        themeUpdateTimer = new Timer();
        themeUpdateTimer.Interval = 100; // Update every 100ms
        themeUpdateTimer.Tick += OnThemeUpdateTimer;
        themeUpdateTimer.Start();
    }

    private async void OnThemeUpdateTimer(object? sender, EventArgs e)
    {
        if (CoreWebView2 != null)
        {
            await ApplyCurrentTheme();
        }
    }

    private async Task ApplyCurrentTheme()
    {
        var palette = GetResolvedPalette();
        var colorTable = palette.GetColorTable();
        
        var themeScript = $@"
            (function() {{
                const root = document.documentElement;
                root.style.setProperty('--krypton-primary', '{colorTable.Color1}');
                root.style.setProperty('--krypton-secondary', '{colorTable.Color2}');
                root.style.setProperty('--krypton-background', '{colorTable.Color3}');
                root.style.setProperty('--krypton-text', '{colorTable.Color4}');
                root.style.setProperty('--krypton-accent', '{colorTable.Color5}');
                
                // Apply theme class
                document.body.classList.add('krypton-themed');
                
                // Dispatch theme change event
                window.dispatchEvent(new CustomEvent('kryptonThemeChanged', {{
                    detail: {{
                        primary: '{colorTable.Color1}',
                        secondary: '{colorTable.Color2}',
                        background: '{colorTable.Color3}',
                        text: '{colorTable.Color4}',
                        accent: '{colorTable.Color5}'
                    }}
                }}));
            }})();
        ";
        
        await CoreWebView2.ExecuteScriptAsync(themeScript);
    }

    protected override void OnGlobalPaletteChanged(object? sender, EventArgs e)
    {
        base.OnGlobalPaletteChanged(sender, e);
        _ = ApplyCurrentTheme();
    }

    protected override void Dispose(bool disposing)
    {
        if (disposing)
        {
            themeUpdateTimer?.Stop();
            themeUpdateTimer?.Dispose();
        }
        base.Dispose(disposing);
    }
}
```

## JavaScript Integration

### Bidirectional Communication

```csharp
public class JavaScriptBridge
{
    private readonly KryptonWebView2 webView;

    public JavaScriptBridge(KryptonWebView2 webView)
    {
        this.webView = webView;
        SetupJavaScriptBridge();
    }

    private async void SetupJavaScriptBridge()
    {
        if (webView.CoreWebView2 != null)
        {
            // Add script to execute on document creation
            await webView.CoreWebView2.AddScriptToExecuteOnDocumentCreatedAsync(@"
                window.kryptonBridge = {
                    sendMessage: function(message) {
                        window.chrome.webview.postMessage(message);
                    },
                    getTheme: function() {
                        return window.chrome.webview.hostObjects.kryptonTheme;
                    }
                };
            ");

            // Handle messages from JavaScript
            webView.CoreWebView2.WebMessageReceived += OnWebMessageReceived;

            // Expose host objects to JavaScript
            webView.CoreWebView2.AddHostObjectToScript("kryptonTheme", new ThemeHostObject(webView));
        }
    }

    private void OnWebMessageReceived(object? sender, CoreWebView2WebMessageReceivedEventArgs e)
    {
        try
        {
            var message = e.TryGetWebMessageAsString();
            var messageData = JsonSerializer.Deserialize<WebMessage>(message);
            
            switch (messageData.Type)
            {
                case "navigate":
                    NavigateToUrl(messageData.Data);
                    break;
                case "showDialog":
                    ShowDialog(messageData.Data);
                    break;
                case "updateStatus":
                    UpdateStatusBar(messageData.Data);
                    break;
            }
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Error processing web message: {ex.Message}");
        }
    }

    public async Task SendMessageToWeb(string type, object data)
    {
        if (webView.CoreWebView2 != null)
        {
            var message = new WebMessage { Type = type, Data = data };
            var json = JsonSerializer.Serialize(message);
            await webView.CoreWebView2.ExecuteScriptAsync($"window.dispatchEvent(new CustomEvent('kryptonMessage', {{ detail: {json} }}));");
        }
    }

    private void NavigateToUrl(string url)
    {
        webView.CoreWebView2?.Navigate(url);
    }

    private void ShowDialog(string message)
    {
        MessageBox.Show(message);
    }

    private void UpdateStatusBar(string status)
    {
        // Update application status bar
    }
}

public class WebMessage
{
    public string Type { get; set; } = "";
    public object Data { get; set; } = new();
}

public class ThemeHostObject
{
    private readonly KryptonWebView2 webView;

    public ThemeHostObject(KryptonWebView2 webView)
    {
        this.webView = webView;
    }

    public string GetPrimaryColor()
    {
        var palette = webView.GetResolvedPalette();
        return palette.GetColorTable().Color1;
    }

    public string GetBackgroundColor()
    {
        var palette = webView.GetResolvedPalette();
        return palette.GetColorTable().Color3;
    }
}
```

## Error Handling

### Comprehensive Error Handling

```csharp
public class RobustWebView2 : KryptonWebView2
{
    private int retryCount = 0;
    private const int maxRetries = 3;

    public async Task<bool> InitializeWithRetry()
    {
        while (retryCount < maxRetries)
        {
            try
            {
                await EnsureCoreWebView2Async();
                SetupErrorHandling();
                return true;
            }
            catch (WebView2RuntimeNotFoundException)
            {
                ShowWebView2RuntimeError();
                return false;
            }
            catch (Exception ex)
            {
                retryCount++;
                if (retryCount >= maxRetries)
                {
                    ShowInitializationError(ex);
                    return false;
                }
                
                await Task.Delay(1000 * retryCount); // Exponential backoff
            }
        }
        return false;
    }

    private void SetupErrorHandling()
    {
        if (CoreWebView2 != null)
        {
            CoreWebView2.NavigationCompleted += OnNavigationCompleted;
            CoreWebView2.ProcessFailed += OnProcessFailed;
        }
    }

    private void OnNavigationCompleted(object? sender, CoreWebView2NavigationCompletedEventArgs e)
    {
        if (!e.IsSuccess)
        {
            HandleNavigationError(e.WebErrorStatus);
        }
    }

    private void OnProcessFailed(object? sender, CoreWebView2ProcessFailedEventArgs e)
    {
        switch (e.ProcessFailedKind)
        {
            case CoreWebView2ProcessFailedKind.BrowserProcessExited:
                HandleBrowserProcessExited();
                break;
            case CoreWebView2ProcessFailedKind.RenderProcessExited:
                HandleRenderProcessExited();
                break;
            case CoreWebView2ProcessFailedKind.RenderProcessUnresponsive:
                HandleRenderProcessUnresponsive();
                break;
        }
    }

    private void HandleNavigationError(CoreWebView2WebErrorStatus errorStatus)
    {
        string errorMessage = errorStatus switch
        {
            CoreWebView2WebErrorStatus.Unknown => "An unknown error occurred",
            CoreWebView2WebErrorStatus.CertificateCommonNameIssued => "Certificate common name mismatch",
            CoreWebView2WebErrorStatus.CertificateDateInvalid => "Certificate date invalid",
            CoreWebView2WebErrorStatus.CertificateAuthorityInvalid => "Certificate authority invalid",
            CoreWebView2WebErrorStatus.CertificateContainsErrors => "Certificate contains errors",
            CoreWebView2WebErrorStatus.CertificateNoRevocationMechanism => "Certificate has no revocation mechanism",
            CoreWebView2WebErrorStatus.CertificateUnableToCheckRevocation => "Unable to check certificate revocation",
            CoreWebView2WebErrorStatus.CertificateRevoked => "Certificate revoked",
            CoreWebView2WebErrorStatus.CertificateInvalid => "Certificate invalid",
            CoreWebView2WebErrorStatus.ServerCertificateError => "Server certificate error",
            CoreWebView2WebErrorStatus.HostNameMismatch => "Host name mismatch",
            CoreWebView2WebErrorStatus.ConnectionAborted => "Connection aborted",
            CoreWebView2WebErrorStatus.ConnectionReset => "Connection reset",
            CoreWebView2WebErrorStatus.ConnectionRefused => "Connection refused",
            CoreWebView2WebErrorStatus.ConnectionTimedOut => "Connection timed out",
            CoreWebView2WebErrorStatus.TooManyRedirects => "Too many redirects",
            CoreWebView2WebErrorStatus.UnexpectedRedirect => "Unexpected redirect",
            CoreWebView2WebErrorStatus.UnexpectedClientError => "Unexpected client error",
            CoreWebView2WebErrorStatus.UnexpectedServerError => "Unexpected server error",
            CoreWebView2WebErrorStatus.InvalidServerResponse => "Invalid server response",
            CoreWebView2WebErrorStatus.ContentLengthMismatch => "Content length mismatch",
            CoreWebView2WebErrorStatus.RequestRangeNotSatisfiable => "Request range not satisfiable",
            CoreWebView2WebErrorStatus.MalformedUrl => "Malformed URL",
            CoreWebView2WebErrorStatus.OperationCanceled => "Operation canceled",
            CoreWebView2WebErrorStatus.RequestAborted => "Request aborted",
            CoreWebView2WebErrorStatus.RequestTimeout => "Request timeout",
            CoreWebView2WebErrorStatus.RequestTimeout => "Request timeout",
            CoreWebView2WebErrorStatus.RequestTimeout => "Request timeout",
            _ => "An unknown navigation error occurred"
        };

        ShowErrorDialog("Navigation Error", errorMessage);
    }

    private void HandleBrowserProcessExited()
    {
        ShowErrorDialog("Browser Process Exited", "The WebView2 browser process has exited unexpectedly. The page will be reloaded.");
        _ = Task.Run(async () => await InitializeWithRetry());
    }

    private void HandleRenderProcessExited()
    {
        ShowErrorDialog("Render Process Exited", "The WebView2 render process has exited. The page will be reloaded.");
        Reload();
    }

    private void HandleRenderProcessUnresponsive()
    {
        ShowErrorDialog("Render Process Unresponsive", "The WebView2 render process is unresponsive. The page will be reloaded.");
        Reload();
    }

    private void ShowWebView2RuntimeError()
    {
        var result = MessageBox.Show(
            "WebView2 Runtime is not installed. Would you like to download it?",
            "WebView2 Runtime Required",
            MessageBoxButtons.YesNo,
            MessageBoxIcon.Warning);

        if (result == DialogResult.Yes)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/",
                UseShellExecute = true
            });
        }
    }

    private void ShowInitializationError(Exception ex)
    {
        MessageBox.Show(
            $"Failed to initialize WebView2 after {maxRetries} attempts:\n{ex.Message}",
            "Initialization Error",
            MessageBoxButtons.OK,
            MessageBoxIcon.Error);
    }

    private void ShowErrorDialog(string title, string message)
    {
        MessageBox.Show(message, title, MessageBoxButtons.OK, MessageBoxIcon.Warning);
    }
}
```

## Performance Optimization

### Optimized WebView2 Configuration

```csharp
public class OptimizedWebView2 : KryptonWebView2
{
    public async Task InitializeOptimized()
    {
        await EnsureCoreWebView2Async();
        
        if (CoreWebView2 != null)
        {
            ConfigurePerformanceSettings();
            ConfigureSecuritySettings();
            SetupPerformanceMonitoring();
        }
    }

    private void ConfigurePerformanceSettings()
    {
        var settings = CoreWebView2.Settings;
        
        // Disable unnecessary features for better performance
        settings.AreDefaultContextMenusEnabled = false;
        settings.AreDevToolsEnabled = false;
        settings.IsStatusBarEnabled = false;
        settings.AreHostObjectsAllowed = false;
        settings.IsGeneralAutofillEnabled = false;
        settings.IsPasswordAutosaveEnabled = false;
        settings.IsSwipeNavigationEnabled = false;
        settings.IsPinchZoomEnabled = false;
        
        // Enable hardware acceleration
        settings.IsReputationCheckingRequired = false;
        settings.IsWebMessageEnabled = true;
        
        // Configure for better performance
        CoreWebView2.CallDevToolsProtocolMethodAsync("Performance.enable", "{}");
        CoreWebView2.CallDevToolsProtocolMethodAsync("Runtime.enable", "{}");
    }

    private void ConfigureSecuritySettings()
    {
        var settings = CoreWebView2.Settings;
        
        // Security settings
        settings.IsScriptEnabled = true;
        settings.IsWebMessageEnabled = true;
        settings.AreDefaultScriptDialogsEnabled = false;
        settings.IsSwipeNavigationEnabled = false;
    }

    private void SetupPerformanceMonitoring()
    {
        CoreWebView2.ProcessFailed += OnProcessFailed;
        
        // Monitor memory usage
        var timer = new Timer();
        timer.Interval = 5000; // Check every 5 seconds
        timer.Tick += OnPerformanceTimer;
        timer.Start();
    }

    private async void OnPerformanceTimer(object? sender, EventArgs e)
    {
        try
        {
            // Get memory usage
            var memoryInfo = await CoreWebView2.CallDevToolsProtocolMethodAsync("Runtime.getHeapUsage", "{}");
            
            // Get performance metrics
            var metrics = await CoreWebView2.CallDevToolsProtocolMethodAsync("Performance.getMetrics", "{}");
            
            // Log performance data
            Debug.WriteLine($"Memory Usage: {memoryInfo}");
            Debug.WriteLine($"Performance Metrics: {metrics}");
        }
        catch (Exception ex)
        {
            Debug.WriteLine($"Performance monitoring error: {ex.Message}");
        }
    }

    private void OnProcessFailed(object? sender, CoreWebView2ProcessFailedEventArgs e)
    {
        Debug.WriteLine($"Process failed: {e.ProcessFailedKind}");
        
        // Restart if necessary
        if (e.ProcessFailedKind == CoreWebView2ProcessFailedKind.BrowserProcessExited)
        {
            _ = Task.Run(async () => await InitializeOptimized());
        }
    }
}
```

This comprehensive examples document provides practical, real-world usage scenarios for the KryptonWebView2 control, covering everything from basic usage to advanced performance optimization and error handling.
