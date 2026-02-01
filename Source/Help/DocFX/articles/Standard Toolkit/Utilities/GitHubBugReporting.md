# GitHub Bug Reporting Feature (Public API)

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Requirements](#requirements)
4. [Quick Start](#quick-start)
5. [Developer Workflow](#developer-workflow)
6. [API Reference](#api-reference)
7. [Classes](#classes)
8. [Usage Examples](#usage-examples)
9. [Security Considerations](#security-considerations)
10. [Troubleshooting](#troubleshooting)
11. [See Also](#see-also)

---

## Overview

The GitHub Bug Reporting feature in Krypton.Utilities allows your application to let users create bug reports directly on your GitHub repository's issue tracker. The configuration (repository details and authentication) is stored in an AES-256–encrypted file that you create during development and ship with your application. End users never see or configure GitHub settings—they only see a simple form with Title and Description fields.

### Architecture

- **Configuration**: Developer creates an encrypted config file containing Owner, RepositoryName, and Personal Access Token (PAT)
- **Runtime**: Application loads config from the encrypted file using a secret key (stored securely, e.g. environment variable)
- **User Experience**: Dialog shows only Title and Description; creates a generic GitHub issue (no repository-specific template)

### Use Cases

- **Desktop Applications**: Integrate "Report a Bug" into Help menus or About dialogs
- **Internal Tools**: Allow team members to submit issues directly from the app
- **Customer Support**: Streamline bug reporting without users needing GitHub accounts
- **Beta/Alpha Software**: Collect feedback and issues from testers

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Encrypted Configuration** | AES-256-CBC encryption for config file; SHA-256 key derivation |
| **Zero User Configuration** | End users never see Owner, Repository, or PAT fields |
| **Simple Issue Format** | Generic title + body; no repository-specific template |
| **Programmatic API** | Use the dialog, or call `BugReportGitHubService` directly |
| **Configurable Repository** | Target any GitHub repository (owner/repo) you choose |
| **Post-Submission Behavior** | Opens the newly created issue in the user's browser |
| **Error Handling** | Clear messages for missing config, wrong key, or API failures |

---

## Requirements

- **Target Framework**: .NET Framework 4.7.2+ or .NET 5+
- **Dependencies**: Krypton.Toolkit, Krypton.Utilities
- **GitHub**: A GitHub Personal Access Token with `repo` or `public_repo` scope
- **Network**: Outbound HTTPS to `api.github.com`

---

## Quick Start

### 1. Create the Encrypted Config File (Development, One-Time)

```csharp
using Krypton.Utilities;

var config = new BugReportGitHubConfig
{
    Owner = "YourOrg",
    RepositoryName = "YourRepo",
    PersonalAccessToken = "ghp_your_token_here"
};

BugReportGitHubConfigEncryption.SaveEncryptedConfig(
    config,
    @"C:\MyApp\github-issue-config.enc",
    "your-secret-key"
);
```

### 2. Ship the `.enc` File with Your Application

Include `github-issue-config.enc` in your build output (e.g. copy to output directory).

### 3. Show the Dialog at Runtime

```csharp
using Krypton.Utilities;

// Load secret key from environment or secure storage
var secretKey = Environment.GetEnvironmentVariable("MY_APP_GITHUB_KEY") ?? "your-secret-key";

var result = KryptonGitHubIssueReportDialog.Show(this, secretKey);

if (result == DialogResult.OK)
{
    // Issue was created; browser was opened automatically
}
```

---

## Developer Workflow

### Step 1: Create a GitHub Personal Access Token

1. Go to GitHub → Settings → Developer settings → Personal access tokens
2. Generate a new token with scope `repo` (or `public_repo` for public repos only)
3. Copy the token and keep it secure

### Step 2: Create the Encrypted Config File

Use `BugReportGitHubConfigEncryption.SaveEncryptedConfig` with your config, output path, and a secret key. The secret key must be the same at runtime when decrypting. **Never commit the secret key to source control.**

### Step 3: Ship the Config File

- Add the `.enc` file to your project
- Set "Copy to Output Directory" to "Copy if newer" or "Copy always"
- Ensure it is deployed with your application (e.g. alongside the executable)

### Step 4: Provide the Secret Key at Runtime

- **Environment variable** (recommended): `Environment.GetEnvironmentVariable("MY_APP_GITHUB_KEY")`
- **Secure storage**: Windows Credential Manager, Azure Key Vault, etc.
- **Build-time injection**: Inject only in CI/CD; never hardcode

### Step 5: Call the Dialog or Service

- **Dialog**: `KryptonGitHubIssueReportDialog.Show(owner, secretKey)` for user-facing reporting
- **Service**: `BugReportGitHubService.CreateIssue(config, title, body)` for programmatic creation

---

## API Reference

### Namespace

```csharp
using Krypton.Utilities;
```

### Assembly

- **Krypton.Utilities** (references Krypton.Toolkit)

---

## Classes

### BugReportGitHubConfig

Configuration for the target GitHub repository and authentication.

**Location**: `Krypton.Utilities` → `Components/KryptonBugReportingDialog/General/BugReportGitHubConfig.cs`

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Owner` | `string` | GitHub repository owner (e.g. `"Krypton-Suite"`) |
| `RepositoryName` | `string` | Repository name (e.g. `"Standard-Toolkit"`) |
| `PersonalAccessToken` | `string` | GitHub PAT with `repo` or `public_repo` scope |
| `IsValid` | `bool` | `true` if Owner, RepositoryName, and PersonalAccessToken are all non-null and non-whitespace |

#### Example

```csharp
var config = new BugReportGitHubConfig
{
    Owner = "MyCompany",
    RepositoryName = "MyProduct",
    PersonalAccessToken = "ghp_xxxxxxxxxxxx"
};

if (config.IsValid)
{
    // Ready for use
}
```

---

### BugReportGitHubConfigEncryption

Static class for encrypting and decrypting the config file. Uses AES-256-CBC with PKCS7 padding; key derived via SHA-256.

**Location**: `Krypton.Utilities` → `Components/KryptonBugReportingDialog/General/BugReportGitHubConfigEncryption.cs`

#### Methods

| Method | Description |
|--------|-------------|
| `SaveEncryptedConfig(config, filePath, secretKey)` | Encrypts config and writes to file |
| `LoadEncryptedConfig(filePath, secretKey)` | Loads and decrypts; throws on failure |
| `TryLoadEncryptedConfig(filePath, secretKey, out config)` | Safe load; returns `true` on success |
| `GetDefaultConfigFilePath()` | Returns `{AppBaseDirectory}\github-issue-config.enc` |

#### Exceptions

- `ArgumentNullException`: Null or empty parameter
- `InvalidOperationException`: Config not valid (for Save)
- `FileNotFoundException`: Config file not found (for Load)
- `CryptographicException`: Wrong key or corrupted file (for Load)

#### Example

```csharp
// Save (development)
BugReportGitHubConfigEncryption.SaveEncryptedConfig(config, outputPath, secretKey);

// Load (runtime)
if (BugReportGitHubConfigEncryption.TryLoadEncryptedConfig(filePath, secretKey, out var config))
{
    // Use config
}

// Default path
var defaultPath = BugReportGitHubConfigEncryption.GetDefaultConfigFilePath();
```

---

### KryptonGitHubIssueReportDialog

Static class providing the user-facing bug report dialog. Loads config from the encrypted file (or accepts config directly) and shows a form with Title and Description fields. Overloads that accept `initialDescription` pre-fill the description (e.g. exception details from `KryptonExceptionDialog`).

**Location**: `Krypton.Utilities` → `Components/KryptonBugReportingDialog/Controls Toolkit/KryptonGitHubIssueReportDialog.cs`

#### Methods

| Method | Description |
|--------|-------------|
| `Show(owner, secretKey)` | Loads from default config file; shows dialog |
| `Show(owner, secretKey, configFilePath)` | Loads from specified config file; shows dialog |
| `Show(owner, secretKey, configFilePath, initialDescription)` | Loads from file; shows dialog with optional pre-filled description |
| `Show(owner, config)` | Uses provided config directly (no file) |
| `Show(owner, config, initialDescription)` | Uses provided config; shows dialog with optional pre-filled description |

#### Parameters

- `owner`: `IWin32Window?` — Parent window (e.g. your form); can be `null`
- `secretKey`: `string` — Key for decrypting the config file
- `configFilePath`: `string?` — Path to `.enc` file; `null` = default path
- `initialDescription`: `string?` — Optional pre-filled text for the issue description (e.g. exception details)
- `config`: `BugReportGitHubConfig` — Pre-loaded configuration

#### Returns

- `DialogResult.OK` — Issue created successfully; browser opened to the new issue
- `DialogResult.Cancel` — User cancelled, or config load failed, or API error

#### Exceptions

- `ArgumentNullException` — `secretKey` is null or empty; or `config` is null (when using config overloads)
- `InvalidOperationException` — `config` is not valid (when using config overloads)

#### Behavior on Config Load Failure

If the encrypted config cannot be loaded (missing file, wrong key, corrupted data), a `KryptonMessageBox` is shown with an error message and `DialogResult.Cancel` is returned. The dialog is not shown.

#### Example

```csharp
// From encrypted file (default path)
var result = KryptonGitHubIssueReportDialog.Show(this, secretKey);

// From encrypted file (custom path)
var result = KryptonGitHubIssueReportDialog.Show(this, secretKey, @"C:\App\config.enc");

// With pre-filled description (e.g. from exception dialog)
var result = KryptonGitHubIssueReportDialog.Show(this, secretKey, null, exceptionDetails);

// With explicit config (no file)
var config = BugReportGitHubConfigEncryption.LoadEncryptedConfig(path, secretKey);
var result = KryptonGitHubIssueReportDialog.Show(this, config);

// With config and pre-filled description
var result = KryptonGitHubIssueReportDialog.Show(this, config, exceptionDetails);
```

---

### BugReportGitHubService

Service for creating GitHub issues programmatically (without showing the dialog). Supports both synchronous and asynchronous methods.

**Location**: `Krypton.Utilities` → `Components/KryptonBugReportingDialog/General/BugReportGitHubService.cs`

#### Methods (Public API – Title + Body)

| Method | Description |
|--------|-------------|
| `CreateIssue(config, title, body)` | Creates a generic issue (sync) |
| `CreateIssueAsync(config, title, body)` | Creates a generic issue (async) |

#### Parameters

- `config`: `BugReportGitHubConfig` — Valid configuration
- `title`: `string` — Issue title
- `body`: `string` — Issue body (markdown supported)

#### Returns

- `BugReportGitHubResult` — Struct with `Success`, `IssueUrl`, `ErrorMessage`

#### Example

```csharp
var service = new BugReportGitHubService();
var result = service.CreateIssue(config, "Bug: Login fails", "Description here...");

if (result.Success)
{
    Process.Start(new ProcessStartInfo { FileName = result.IssueUrl!, UseShellExecute = true });
}
else
{
    MessageBox.Show(result.ErrorMessage);
}
```

---

### BugReportGitHubResult

Read-only struct representing the outcome of an issue creation attempt.

**Location**: `Krypton.Utilities` → `Components/KryptonBugReportingDialog/General/BugReportGitHubResult.cs`

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `Success` | `bool` | `true` if the issue was created |
| `IssueUrl` | `string?` | URL of the created issue (when successful) |
| `ErrorMessage` | `string?` | Error message (when failed) |

#### Static Factory Methods

| Method | Description |
|--------|-------------|
| `SuccessResult(issueUrl)` | Creates a successful result |
| `FailureResult(errorMessage)` | Creates a failed result |

---

## Usage Examples

### Example 1: Help Menu Integration

```csharp
private void helpReportBugToolStripMenuItem_Click(object sender, EventArgs e)
{
    var secretKey = GetSecretKey(); // From env, config, etc.
    if (string.IsNullOrEmpty(secretKey))
    {
        MessageBox.Show("Bug reporting is not configured.");
        return;
    }

    KryptonGitHubIssueReportDialog.Show(this, secretKey);
}
```

### Example 2: Custom Config Path

```csharp
var configPath = Path.Combine(
    Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData),
    "MyApp",
    "github-issue-config.enc"
);

var result = KryptonGitHubIssueReportDialog.Show(this, secretKey, configPath);
```

### Example 3: Programmatic Issue Creation

```csharp
public async Task ReportBugAsync(string title, string body)
{
    if (!BugReportGitHubConfigEncryption.TryLoadEncryptedConfig(
        BugReportGitHubConfigEncryption.GetDefaultConfigFilePath(),
        _secretKey,
        out var config) || config == null)
    {
        throw new InvalidOperationException("GitHub config not available.");
    }

    var service = new BugReportGitHubService();
    var result = await service.CreateIssueAsync(config, title, body);

    if (result.Success)
    {
        return result.IssueUrl;
    }

    throw new InvalidOperationException(result.ErrorMessage);
}
```

### Example 4: About Dialog with Report Bug Button

```csharp
public partial class AboutForm : KryptonForm
{
    private readonly string _secretKey;

    public AboutForm(string secretKey)
    {
        InitializeComponent();
        _secretKey = secretKey;
        kbtnReportBug.Click += KbtnReportBug_Click;
    }

    private void KbtnReportBug_Click(object? sender, EventArgs e)
    {
        KryptonGitHubIssueReportDialog.Show(this, _secretKey);
    }
}
```

### Example 5: Unhandled Exception Handler

```csharp
Application.ThreadException += (sender, e) =>
{
    var ex = e.Exception;
    var title = $"Unhandled Exception: {ex.GetType().Name}";
    var body = $@"**Message**
{ex.Message}

**Stack Trace**
```
{ex.StackTrace}
```";

    if (TryLoadConfig(out var config))
    {
        var service = new BugReportGitHubService();
        var result = service.CreateIssue(config, title, body);
        if (result.Success)
        {
            MessageBox.Show($"Issue created: {result.IssueUrl}");
        }
    }
};
```

### Example 6: Build-Time Config Generation (CI/CD)

```csharp
// Run during build or release pipeline; output .enc file
[TestMethod]
public void GenerateEncryptedConfig()
{
    var config = new BugReportGitHubConfig
    {
        Owner = Environment.GetEnvironmentVariable("GITHUB_OWNER")!,
        RepositoryName = Environment.GetEnvironmentVariable("GITHUB_REPO")!,
        PersonalAccessToken = Environment.GetEnvironmentVariable("GITHUB_PAT")!
    };

    var outputPath = Path.Combine(OutputDir, "github-issue-config.enc");
    var secretKey = Environment.GetEnvironmentVariable("GITHUB_CONFIG_KEY")!;

    BugReportGitHubConfigEncryption.SaveEncryptedConfig(config, outputPath, secretKey);
}
```

---

## Security Considerations

### Secret Key Storage

| Approach | Security | Recommendation |
|----------|----------|----------------|
| Hardcoded in source | Very low | Never use |
| App.config / appsettings.json | Low | Avoid for production |
| Environment variable | Medium | Acceptable for many scenarios |
| Windows Credential Manager | Higher | Good for desktop apps |
| Azure Key Vault / similar | High | Prefer for enterprise |

### Personal Access Token (PAT)

- Use a token with the minimum required scope (`public_repo` for public repos, `repo` for private)
- Prefer fine-grained PATs when GitHub supports them
- Rotate tokens periodically
- Never log or display the PAT

### Encrypted Config File

- The `.enc` file is encrypted with AES-256-CBC
- A new random IV is used for each save
- Without the secret key, the file contents are not recoverable
- Store the secret key separately from the config file

### Network

- All communication uses HTTPS to `api.github.com`
- Ensure your environment allows outbound HTTPS

---

## Troubleshooting

### "Failed to load GitHub configuration"

**Causes**: Config file missing, wrong path, wrong secret key, or corrupted file.

**Solutions**:
- Verify the `.enc` file exists at the expected path
- Use `GetDefaultConfigFilePath()` to check the default path
- Ensure the secret key matches the one used when saving
- Regenerate the config file if corruption is suspected

### "Create Issue Failed" with 401 Unauthorized

**Causes**: Invalid or expired PAT, or insufficient scope.

**Solutions**:
- Regenerate the PAT in GitHub
- Ensure scope includes `repo` or `public_repo`
- Update the config file with the new PAT

### "Create Issue Failed" with 404 Not Found

**Causes**: Invalid Owner or RepositoryName, or no access to the repository.

**Solutions**:
- Verify Owner and RepositoryName are correct (case-sensitive)
- Ensure the PAT has access to the repository

### Dialog Does Not Open

**Causes**: Config load failed before the dialog could be shown.

**Solutions**:
- Check that `TryLoadEncryptedConfig` would succeed before calling `Show`
- Handle `DialogResult.Cancel` and inspect any message box that was shown

---

## See Also

- **[KryptonExceptionDialog](KryptonExceptionDialog.md)** — The Exception Dialog has an overload (in `Krypton.Utilities`) that accepts `githubSecretKey` and `githubConfigPath`. When provided, the "Report Bug" button opens this GitHub issue dialog with the exception details pre-filled in the description.
- [GitHub REST API – Create an Issue](https://docs.github.com/en/rest/issues/issues#create-an-issue)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)