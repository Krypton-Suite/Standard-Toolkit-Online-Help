# Email Configuration Guide - Bug Reporting Dialog

## Overview

The `BugReportEmailConfig` class provides configuration for SMTP email settings used by the bug reporting dialog to send bug reports via email. This guide covers how to configure email settings for various email providers.

## Namespace

```csharp
using Krypton.Utilities;
```

## BugReportEmailConfig Class

### Properties

| Property | Type | Required | Default | Description |
|----------|------|----------|---------|-------------|
| `SmtpServer` | `string` | Yes | `string.Empty` | SMTP server address (e.g., "smtp.gmail.com") |
| `SmtpPort` | `int` | Yes | `587` | SMTP server port (commonly 25, 465, or 587) |
| `UseSsl` | `bool` | No | `true` | Whether to use SSL/TLS encryption |
| `FromEmail` | `string` | Yes | `string.Empty` | Sender email address |
| `ToEmail` | `string` | Yes | `string.Empty` | Recipient email address (where bug reports are sent) |
| `Username` | `string` | No* | `string.Empty` | SMTP username for authentication |
| `Password` | `string` | No* | `string.Empty` | SMTP password for authentication |
| `RequiresAuthentication` | `bool` | Read-only | Computed | Indicates if authentication is required (true if Username is set) |

*Required if SMTP server requires authentication

### Constructor

```csharp
public BugReportEmailConfig()
```

Creates a new instance with default values:
- `SmtpPort`: 587
- `UseSsl`: true
- All string properties: `string.Empty`

## Common Email Provider Configurations

### Gmail

Gmail requires an App Password (not your regular password) for SMTP access.

**Steps to Enable:**
1. Enable 2-Step Verification in your Google Account
2. Generate an App Password:
   - Go to Google Account → Security → 2-Step Verification → App passwords
   - Select "Mail" and "Other (Custom name)"
   - Copy the generated 16-character password

**Configuration:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.gmail.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@gmail.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@gmail.com",
    Password = "your-16-character-app-password"
};
```

**Alternative (Port 465):**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.gmail.com",
    SmtpPort = 465,
    UseSsl = true,
    FromEmail = "youremail@gmail.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@gmail.com",
    Password = "your-app-password"
};
```

### Outlook/Hotmail

**Configuration:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp-mail.outlook.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@outlook.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@outlook.com",
    Password = "your-password"
};
```

### Office 365

**Configuration:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.office365.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@yourcompany.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@yourcompany.com",
    Password = "your-password"
};
```

### Yahoo Mail

**Configuration:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "smtp.mail.yahoo.com",
    SmtpPort = 587,
    UseSsl = true,
    FromEmail = "youremail@yahoo.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "youremail@yahoo.com",
    Password = "your-app-password" // Requires App Password
};
```

### Custom SMTP Server

**Configuration:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "mail.yourcompany.com",
    SmtpPort = 587, // or 25, 465, etc.
    UseSsl = true, // Set to false if server doesn't support SSL
    FromEmail = "noreply@yourcompany.com",
    ToEmail = "bugs@yourcompany.com",
    Username = "smtp-username", // Optional, if authentication required
    Password = "smtp-password"   // Optional, if authentication required
};
```

**Without Authentication:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    SmtpServer = "mail.yourcompany.com",
    SmtpPort = 25,
    UseSsl = false,
    FromEmail = "noreply@yourcompany.com",
    ToEmail = "bugs@yourcompany.com"
    // Username and Password not required
};
```

## Port Numbers

Common SMTP ports:

| Port | Protocol | Description |
|------|----------|-------------|
| 25 | SMTP | Standard SMTP (often blocked by ISPs) |
| 465 | SMTPS | SMTP over SSL (legacy, but still used) |
| 587 | SMTP + STARTTLS | Modern standard, recommended |

**Recommendation:** Use port 587 with `UseSsl = true` for most modern email providers.

## Security Best Practices

### 1. Never Hardcode Credentials

❌ **Bad:**
```csharp
var emailConfig = new BugReportEmailConfig
{
    Password = "MyPassword123!" // Never do this!
};
```

✅ **Good:**
```csharp
// Load from secure configuration
var emailConfig = LoadEmailConfigFromSecureStorage();
```

### 2. Use App Passwords

For providers that support it (Gmail, Yahoo), use App Passwords instead of your main account password.

### 3. Store Configuration Securely

**Options:**
- Encrypted configuration files
- Windows Credential Manager
- Environment variables (for server deployments)
- Secure vaults (Azure Key Vault, AWS Secrets Manager, etc.)

### 4. Example: Loading from Configuration File

```csharp
public static BugReportEmailConfig LoadEmailConfig()
{
    // Example: Load from app.config or appsettings.json
    return new BugReportEmailConfig
    {
        SmtpServer = ConfigurationManager.AppSettings["SmtpServer"],
        SmtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"]),
        UseSsl = bool.Parse(ConfigurationManager.AppSettings["UseSsl"]),
        FromEmail = ConfigurationManager.AppSettings["FromEmail"],
        ToEmail = ConfigurationManager.AppSettings["ToEmail"],
        Username = ConfigurationManager.AppSettings["SmtpUsername"],
        Password = DecryptPassword(ConfigurationManager.AppSettings["SmtpPassword"])
    };
}
```

### 5. Example: Using Environment Variables

```csharp
public static BugReportEmailConfig LoadEmailConfigFromEnvironment()
{
    return new BugReportEmailConfig
    {
        SmtpServer = Environment.GetEnvironmentVariable("SMTP_SERVER"),
        SmtpPort = int.Parse(Environment.GetEnvironmentVariable("SMTP_PORT") ?? "587"),
        UseSsl = bool.Parse(Environment.GetEnvironmentVariable("SMTP_USE_SSL") ?? "true"),
        FromEmail = Environment.GetEnvironmentVariable("SMTP_FROM_EMAIL"),
        ToEmail = Environment.GetEnvironmentVariable("SMTP_TO_EMAIL"),
        Username = Environment.GetEnvironmentVariable("SMTP_USERNAME"),
        Password = Environment.GetEnvironmentVariable("SMTP_PASSWORD")
    };
}
```

## Troubleshooting

### Common Issues

#### 1. Authentication Failed

**Symptoms:** Email sending fails with authentication error.

**Solutions:**
- Verify username and password are correct
- For Gmail/Yahoo, ensure you're using an App Password, not your regular password
- Check if 2-Step Verification is enabled (required for App Passwords)
- Verify the `Username` property matches the `FromEmail` (for some providers)

#### 2. Connection Timeout

**Symptoms:** Email sending times out.

**Solutions:**
- Check firewall settings
- Verify SMTP server address is correct
- Try different port (587 vs 465)
- Check if your ISP blocks port 25

#### 3. SSL/TLS Errors

**Symptoms:** SSL handshake fails.

**Solutions:**
- Verify `UseSsl` matches server requirements
- For port 587, use `UseSsl = true` (STARTTLS)
- For port 465, use `UseSsl = true` (implicit SSL)
- For port 25, try `UseSsl = false`

#### 4. Port Blocked

**Symptoms:** Cannot connect to SMTP server.

**Solutions:**
- Try port 587 instead of 25 (most ISPs block port 25)
- Check corporate firewall settings
- Verify SMTP server allows connections from your IP

### Testing Email Configuration

```csharp
public static bool TestEmailConfiguration(BugReportEmailConfig config)
{
    try
    {
        var service = new BugReportEmailService();
        var success = service.SendBugReport(
            config,
            "Test Email",
            "This is a test email from the bug reporting system.",
            null
        );
        
        if (success)
        {
            MessageBox.Show("Email configuration is working correctly!", 
                "Success", MessageBoxButtons.OK, MessageBoxIcon.Information);
            return true;
        }
        else
        {
            MessageBox.Show("Failed to send test email. Please check your configuration.", 
                "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return false;
        }
    }
    catch (Exception ex)
    {
        MessageBox.Show($"Error testing email configuration:\n\n{ex.Message}", 
            "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
        return false;
    }
}
```

## Usage Example

```csharp
using Krypton.Utilities;

// Load email configuration
var emailConfig = LoadEmailConfigFromSecureStorage();

// Show bug reporting dialog
var result = KryptonBugReportingDialog.Show(exception, emailConfig);

if (result == DialogResult.OK)
{
    // Bug report sent successfully
    MessageBox.Show("Thank you for reporting this bug!");
}
```

## Related Documentation

- [Bug Reporting Dialog Documentation](BugReportingDialog.md)
- [Bug Reporting Dialog API Reference](BugReportingDialog-API.md)
- [Bug Reporting Dialog Examples](BugReportingDialog-Examples.md)
- [Bug Reporting Dialog Quick Reference](BugReportingDialog-QuickReference.md)

