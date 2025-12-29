# Krypton Bug Reporting Dialog - Code Examples

## Table of Contents

1. [Basic Usage](#basic-usage)
2. [Exception Handling](#exception-handling)
3. [Configuration Management](#configuration-management)
4. [Custom Integration](#custom-integration)
5. [Advanced Scenarios](#advanced-scenarios)

## Basic Usage

### Example 1: Simple Bug Report Dialog

```csharp
using Krypton.Utilities;
using System.Windows.Forms;

public class BugReportExample
{
    public void ShowBugReport()
    {
        var emailConfig = new BugReportEmailConfig
        {
            SmtpServer = "smtp.example.com",
            SmtpPort = 587,
            UseSsl = true,
            FromEmail = "app@example.com",
            ToEmail = "bugs@example.com"
        };

        var result = KryptonBugReportingDialog.Show(emailConfig);
        
        if (result == DialogResult.OK)
        {
            MessageBox.Show("Thank you for your bug report!");
        }
    }
}
```

### Example 2: Bug Report with Exception

```csharp
using Krypton.Utilities;

public class ExceptionBugReport
{
    public void HandleException(Exception ex)
    {
        var emailConfig = GetEmailConfig();
        
        // Show bug reporting dialog with exception details pre-filled
        KryptonBugReportingDialog.Show(ex, emailConfig);
    }
    
    private BugReportEmailConfig GetEmailConfig()
    {
        return new BugReportEmailConfig
        {
            SmtpServer = "smtp.example.com",
            SmtpPort = 587,
            UseSsl = true,
            FromEmail = "app@example.com",
            ToEmail = "bugs@example.com",
            Username = "app@example.com",
            Password = "password"
        };
    }
}
```

## Exception Handling

### Example 3: Global Exception Handler

```csharp
using Krypton.Utilities;
using System;
using System.Threading;
using System.Windows.Forms;

public class ApplicationMain
{
    private static BugReportEmailConfig _emailConfig;

    [STAThread]
    static void Main()
    {
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        
        // Configure email settings
        _emailConfig = LoadEmailConfig();
        
        // Set up global exception handlers
        Application.SetUnhandledExceptionMode(UnhandledExceptionMode.CatchException);
        Application.ThreadException += Application_ThreadException;
        AppDomain.CurrentDomain.UnhandledException += CurrentDomain_UnhandledException;
        
        Application.Run(new MainForm());
    }
    
    private static void Application_ThreadException(object sender, ThreadExceptionEventArgs e)
    {
        // Handle UI thread exceptions
        BugReportingHelper.ShowExceptionWithBugReporting(e.Exception, _emailConfig);
    }
    
    private static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
    {
        // Handle non-UI thread exceptions
        if (e.ExceptionObject is Exception ex)
        {
            BugReportingHelper.ShowExceptionWithBugReporting(ex, _emailConfig);
        }
    }
    
    private static BugReportEmailConfig LoadEmailConfig()
    {
        // Load from configuration file or settings
        return new BugReportEmailConfig
        {
            SmtpServer = Properties.Settings.Default.SmtpServer,
            SmtpPort = Properties.Settings.Default.SmtpPort,
            UseSsl = Properties.Settings.Default.UseSsl,
            FromEmail = Properties.Settings.Default.FromEmail,
            ToEmail = Properties.Settings.Default.ToEmail,
            Username = Properties.Settings.Default.SmtpUsername,
            Password = Properties.Settings.Default.SmtpPassword
        };
    }
}
```

### Example 4: Try-Catch with Bug Reporting

```csharp
using Krypton.Utilities;

public class DataProcessor
{
    private readonly BugReportEmailConfig _emailConfig;
    
    public DataProcessor(BugReportEmailConfig emailConfig)
    {
        _emailConfig = emailConfig;
    }
    
    public void ProcessFile(string filePath)
    {
        try
        {
            // Your processing code
            var data = File.ReadAllText(filePath);
            ProcessData(data);
        }
        catch (FileNotFoundException ex)
        {
            // File not found - show error without bug reporting
            MessageBox.Show($"File not found: {filePath}", "Error", 
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
        catch (Exception ex)
        {
            // Unexpected error - show with bug reporting option
            BugReportingHelper.ShowExceptionWithBugReporting(
                ex, 
                _emailConfig,
                highlightColor: Color.Red,
                showCopyButton: true,
                showSearchBox: true
            );
        }
    }
    
    private void ProcessData(string data)
    {
        // Process the data
    }
}
```

### Example 5: Async Exception Handling

```csharp
using Krypton.Utilities;
using System.Threading.Tasks;

public class AsyncProcessor
{
    private readonly BugReportEmailConfig _emailConfig;
    
    public AsyncProcessor(BugReportEmailConfig emailConfig)
    {
        _emailConfig = emailConfig;
    }
    
    public async Task ProcessAsync()
    {
        try
        {
            await DoWorkAsync();
        }
        catch (Exception ex)
        {
            // Switch back to UI thread for dialog
            await Task.Run(() =>
            {
                Application.Invoke(new Action(() =>
                {
                    BugReportingHelper.ShowExceptionWithBugReporting(ex, _emailConfig);
                }));
            });
        }
    }
    
    private async Task DoWorkAsync()
    {
        await Task.Delay(1000);
        throw new InvalidOperationException("Something went wrong");
    }
}
```

## Configuration Management

### Example 6: Configuration from App.config

```csharp
using Krypton.Utilities;
using System.Configuration;

public class ConfigManager
{
    public static BugReportEmailConfig LoadFromAppConfig()
    {
        return new BugReportEmailConfig
        {
            SmtpServer = ConfigurationManager.AppSettings["BugReport.SmtpServer"] 
                ?? "smtp.example.com",
            SmtpPort = int.Parse(
                ConfigurationManager.AppSettings["BugReport.SmtpPort"] ?? "587"),
            UseSsl = bool.Parse(
                ConfigurationManager.AppSettings["BugReport.UseSsl"] ?? "true"),
            FromEmail = ConfigurationManager.AppSettings["BugReport.FromEmail"] 
                ?? string.Empty,
            ToEmail = ConfigurationManager.AppSettings["BugReport.ToEmail"] 
                ?? string.Empty,
            Username = ConfigurationManager.AppSettings["BugReport.Username"] 
                ?? string.Empty,
            Password = ConfigurationManager.AppSettings["BugReport.Password"] 
                ?? string.Empty
        };
    }
}
```

**App.config:**
```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <appSettings>
    <add key="BugReport.SmtpServer" value="smtp.example.com" />
    <add key="BugReport.SmtpPort" value="587" />
    <add key="BugReport.UseSsl" value="true" />
    <add key="BugReport.FromEmail" value="app@example.com" />
    <add key="BugReport.ToEmail" value="bugs@example.com" />
    <add key="BugReport.Username" value="app@example.com" />
    <add key="BugReport.Password" value="your-password" />
  </appSettings>
</configuration>
```

### Example 7: Configuration from JSON File

```csharp
using Krypton.Utilities;
using System.IO;
using System.Text.Json;

public class JsonConfigManager
{
    public static BugReportEmailConfig LoadFromJson(string configPath)
    {
        if (!File.Exists(configPath))
        {
            throw new FileNotFoundException("Configuration file not found", configPath);
        }
        
        var json = File.ReadAllText(configPath);
        var config = JsonSerializer.Deserialize<EmailConfigJson>(json);
        
        return new BugReportEmailConfig
        {
            SmtpServer = config.SmtpServer,
            SmtpPort = config.SmtpPort,
            UseSsl = config.UseSsl,
            FromEmail = config.FromEmail,
            ToEmail = config.ToEmail,
            Username = config.Username,
            Password = config.Password
        };
    }
    
    private class EmailConfigJson
    {
        public string SmtpServer { get; set; }
        public int SmtpPort { get; set; }
        public bool UseSsl { get; set; }
        public string FromEmail { get; set; }
        public string ToEmail { get; set; }
        public string Username { get; set; }
        public string Password { get; set; }
    }
}
```

**config.json:**
```json
{
  "SmtpServer": "smtp.example.com",
  "SmtpPort": 587,
  "UseSsl": true,
  "FromEmail": "app@example.com",
  "ToEmail": "bugs@example.com",
  "Username": "app@example.com",
  "Password": "your-password"
}
```

### Example 8: Secure Configuration Storage

```csharp
using Krypton.Utilities;
using System.Security.Cryptography;
using System.Text;

public class SecureConfigManager
{
    public static BugReportEmailConfig LoadSecureConfig()
    {
        // In production, use Windows Credential Manager or similar
        var encryptedPassword = GetEncryptedPassword();
        var decryptedPassword = DecryptPassword(encryptedPassword);
        
        return new BugReportEmailConfig
        {
            SmtpServer = Environment.GetEnvironmentVariable("BUG_REPORT_SMTP_SERVER") 
                ?? "smtp.example.com",
            SmtpPort = int.Parse(
                Environment.GetEnvironmentVariable("BUG_REPORT_SMTP_PORT") ?? "587"),
            UseSsl = true,
            FromEmail = Environment.GetEnvironmentVariable("BUG_REPORT_FROM_EMAIL") 
                ?? string.Empty,
            ToEmail = Environment.GetEnvironmentVariable("BUG_REPORT_TO_EMAIL") 
                ?? string.Empty,
            Username = Environment.GetEnvironmentVariable("BUG_REPORT_USERNAME") 
                ?? string.Empty,
            Password = decryptedPassword
        };
    }
    
    private static string GetEncryptedPassword()
    {
        // Retrieve from secure storage
        return string.Empty;
    }
    
    private static string DecryptPassword(string encrypted)
    {
        // Decrypt password
        return string.Empty;
    }
}
```

## Custom Integration

### Example 9: Custom Exception Dialog Integration

```csharp
using Krypton.Utilities;
using Krypton.Toolkit;

public class CustomExceptionHandler
{
    private readonly BugReportEmailConfig _emailConfig;
    
    public CustomExceptionHandler(BugReportEmailConfig emailConfig)
    {
        _emailConfig = emailConfig;
    }
    
    public void ShowException(Exception ex)
    {
        // Show exception dialog with custom bug reporting callback
        KryptonExceptionDialog.Show(
            ex,
            highlightColor: Color.Orange,
            showCopyButton: true,
            showSearchBox: true,
            bugReportCallback: exception =>
            {
                // Custom logic before showing bug report
                LogException(exception);
                
                // Show bug reporting dialog
                var result = KryptonBugReportingDialog.Show(exception, _emailConfig);
                
                // Custom logic after bug report
                if (result == DialogResult.OK)
                {
                    TrackBugReportSent(exception);
                }
            }
        );
    }
    
    private void LogException(Exception ex)
    {
        // Log to file or database
    }
    
    private void TrackBugReportSent(Exception ex)
    {
        // Track analytics or metrics
    }
}
```

### Example 10: Conditional Bug Reporting

```csharp
using Krypton.Utilities;

public class ConditionalBugReporter
{
    private readonly BugReportEmailConfig _emailConfig;
    private readonly bool _enableBugReporting;
    
    public ConditionalBugReporter(BugReportEmailConfig emailConfig, bool enableBugReporting)
    {
        _emailConfig = emailConfig;
        _enableBugReporting = enableBugReporting;
    }
    
    public void HandleException(Exception ex)
    {
        if (_enableBugReporting && IsProductionEnvironment())
        {
            // Show with bug reporting in production
            BugReportingHelper.ShowExceptionWithBugReporting(ex, _emailConfig);
        }
        else
        {
            // Show without bug reporting in development
            Krypton.Toolkit.KryptonExceptionDialog.Show(ex);
        }
    }
    
    private bool IsProductionEnvironment()
    {
        #if DEBUG
            return false;
        #else
            return true;
        #endif
    }
}
```

### Example 11: Bug Report with Additional Context

```csharp
using Krypton.Utilities;
using System.Text;

public class ContextualBugReporter
{
    private readonly BugReportEmailConfig _emailConfig;
    
    public void ReportBugWithContext(Exception ex, Dictionary<string, string> context)
    {
        // Build enhanced bug description with context
        var enhancedDescription = BuildEnhancedDescription(ex, context);
        
        // Create a custom exception with enhanced message
        var enhancedException = new Exception(enhancedDescription, ex);
        
        // Show bug reporting dialog
        KryptonBugReportingDialog.Show(enhancedException, _emailConfig);
    }
    
    private string BuildEnhancedDescription(Exception ex, Dictionary<string, string> context)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Exception Details:");
        sb.AppendLine($"Type: {ex.GetType().Name}");
        sb.AppendLine($"Message: {ex.Message}");
        sb.AppendLine();
        sb.AppendLine("Additional Context:");
        
        foreach (var kvp in context)
        {
            sb.AppendLine($"{kvp.Key}: {kvp.Value}");
        }
        
        return sb.ToString();
    }
}
```

## Advanced Scenarios

### Example 12: Programmatic Email Sending

```csharp
using Krypton.Utilities;
using System.Collections.Generic;

public class ProgrammaticReporter
{
    private readonly BugReportEmailService _emailService;
    private readonly BugReportEmailConfig _emailConfig;
    
    public ProgrammaticReporter(BugReportEmailConfig emailConfig)
    {
        _emailService = new BugReportEmailService();
        _emailConfig = emailConfig;
    }
    
    public bool SendBugReport(string description, string steps, List<string> attachments)
    {
        var subject = $"Bug Report - {Application.ProductName} v{Application.ProductVersion}";
        var body = BuildEmailBody(description, steps);
        
        return _emailService.SendBugReport(_emailConfig, subject, body, attachments);
    }
    
    private string BuildEmailBody(string description, string steps)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Bug Report");
        sb.AppendLine("==========");
        sb.AppendLine();
        sb.AppendLine($"Application: {Application.ProductName}");
        sb.AppendLine($"Version: {Application.ProductVersion}");
        sb.AppendLine($"Date: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
        sb.AppendLine($"User: {Environment.UserName}");
        sb.AppendLine($"OS: {Environment.OSVersion}");
        sb.AppendLine();
        sb.AppendLine("Bug Description:");
        sb.AppendLine("----------------");
        sb.AppendLine(description);
        sb.AppendLine();
        sb.AppendLine("Steps to Reproduce:");
        sb.AppendLine("-------------------");
        sb.AppendLine(steps);
        
        return sb.ToString();
    }
}
```

### Example 13: Fallback to File Save

```csharp
using Krypton.Utilities;
using System.IO;
using System.Text;

public class FallbackReporter
{
    private readonly BugReportEmailConfig _emailConfig;
    
    public void ReportBug(Exception ex)
    {
        var result = KryptonBugReportingDialog.Show(ex, _emailConfig);
        
        if (result != DialogResult.OK)
        {
            // Email sending failed or was cancelled - save to file
            var saveResult = SaveBugReportToFile(ex);
            
            if (saveResult == DialogResult.OK)
            {
                MessageBox.Show(
                    "Bug report saved to file. Please send it manually to bugs@example.com",
                    "Bug Report Saved",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }
        }
    }
    
    private DialogResult SaveBugReportToFile(Exception ex)
    {
        using var dialog = new SaveFileDialog
        {
            Filter = "Text Files|*.txt|All Files|*.*",
            FileName = $"BugReport_{DateTime.Now:yyyyMMdd_HHmmss}.txt"
        };
        
        if (dialog.ShowDialog() == DialogResult.OK)
        {
            var content = FormatBugReport(ex);
            File.WriteAllText(dialog.FileName, content);
            return DialogResult.OK;
        }
        
        return DialogResult.Cancel;
    }
    
    private string FormatBugReport(Exception ex)
    {
        var sb = new StringBuilder();
        sb.AppendLine("Bug Report");
        sb.AppendLine("==========");
        sb.AppendLine($"Date: {DateTime.Now:yyyy-MM-dd HH:mm:ss}");
        sb.AppendLine($"Application: {Application.ProductName}");
        sb.AppendLine($"Version: {Application.ProductVersion}");
        sb.AppendLine();
        sb.AppendLine("Exception:");
        sb.AppendLine($"Type: {ex.GetType().Name}");
        sb.AppendLine($"Message: {ex.Message}");
        sb.AppendLine($"Stack Trace: {ex.StackTrace}");
        
        return sb.ToString();
    }
}
```

### Example 14: Testing Email Configuration

```csharp
using Krypton.Utilities;

public class EmailConfigTester
{
    public bool TestConfiguration(BugReportEmailConfig config)
    {
        try
        {
            var service = new BugReportEmailService();
            var testSubject = "Test Email - Bug Reporting Configuration";
            var testBody = $"This is a test email sent at {DateTime.Now:yyyy-MM-dd HH:mm:ss}";
            
            var result = service.SendBugReport(config, testSubject, testBody, null);
            
            if (result)
            {
                MessageBox.Show(
                    "Email configuration test successful!",
                    "Test Successful",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information
                );
            }
            else
            {
                MessageBox.Show(
                    "Email configuration test failed. Please check your settings.",
                    "Test Failed",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
            
            return result;
        }
        catch (Exception ex)
        {
            MessageBox.Show(
                $"Error testing email configuration:\n{ex.Message}",
                "Test Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
            return false;
        }
    }
}
```

### Example 15: Multi-Environment Configuration

```csharp
using Krypton.Utilities;

public class EnvironmentConfigManager
{
    public static BugReportEmailConfig GetConfigForEnvironment()
    {
        var environment = Environment.GetEnvironmentVariable("APP_ENVIRONMENT") ?? "Development";
        
        return environment switch
        {
            "Production" => new BugReportEmailConfig
            {
                SmtpServer = "smtp.production.com",
                SmtpPort = 587,
                UseSsl = true,
                FromEmail = "app@production.com",
                ToEmail = "bugs@production.com",
                Username = "app@production.com",
                Password = GetProductionPassword()
            },
            "Staging" => new BugReportEmailConfig
            {
                SmtpServer = "smtp.staging.com",
                SmtpPort = 587,
                UseSsl = true,
                FromEmail = "app@staging.com",
                ToEmail = "bugs@staging.com",
                Username = "app@staging.com",
                Password = GetStagingPassword()
            },
            _ => new BugReportEmailConfig
            {
                SmtpServer = "smtp.dev.com",
                SmtpPort = 587,
                UseSsl = true,
                FromEmail = "app@dev.com",
                ToEmail = "dev-bugs@dev.com",
                Username = "app@dev.com",
                Password = GetDevPassword()
            }
        };
    }
    
    private static string GetProductionPassword() => "prod-password";
    private static string GetStagingPassword() => "staging-password";
    private static string GetDevPassword() => "dev-password";
}
```

## See Also

- [Full Documentation](BugReportingDialog.md)
- [API Reference](BugReportingDialog-API.md)
- [Quick Reference](BugReportingDialog-QuickReference.md)

