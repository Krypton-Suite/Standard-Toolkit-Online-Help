# KryptonGitHubIssueReportDialog

## Overview

`KryptonGitHubIssueReportDialog` displays a Krypton-themed dialog that creates GitHub issues via the REST API. End users enter only **title** and **description**; repository owner, name, and personal access token are loaded from encrypted configuration supplied by the developer.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`  
**Type:** Static class (`ToolboxItem(false)`)

Related types:

| Type | Role |
| --- | --- |
| `BugReportGitHubConfig` | Owner, repository name, PAT |
| `BugReportGitHubConfigEncryption` | AES-256 encrypt/decrypt config files |
| `BugReportGitHubService` | Issues API submission |
| `BugReportGitHubResult` | Success/failure result data |

## Developer setup

1. Create a GitHub [personal access token](https://github.com/settings/tokens) with `repo` (or `public_repo`) scope.
2. Build a `BugReportGitHubConfig`:

```csharp
var config = new BugReportGitHubConfig
{
    Owner = "YourOrg",
    RepositoryName = "YourRepo",
    PersonalAccessToken = patFromSecureStore
};
```

3. Encrypt and ship the config file (do **not** commit the PAT or secret key to source control):

```csharp
using System.Security;

var secret = new SecureString();
foreach (char c in Environment.GetEnvironmentVariable("BUG_REPORT_KEY")!)
{
    secret.AppendChar(c);
}
secret.MakeReadOnly();

BugReportGitHubConfigEncryption.SaveEncryptedConfig(
    config,
    @"C:\YourApp\github-bugreport.enc",
    secret);
```

4. At runtime, load with the same secret and show the dialog:

```csharp
DialogResult result = KryptonGitHubIssueReportDialog.Show(
    owner: this,
    secretKey: secret);
```

`DialogResult.OK` indicates the issue was created successfully.

## Show overloads

| Overload | Use when |
| --- | --- |
| `Show(owner, secretKey)` | Default encrypted config path |
| `Show(owner, secretKey, configFilePath)` | Custom config file location |
| `Show(owner, secretKey, configFilePath, initialDescription)` | Pre-fill description (e.g. exception stack trace) |
| `Show(owner, config)` | In-memory config (no file) |
| `Show(owner, config, initialDescription)` | In-memory config + pre-filled body |

### Exception dialog integration

```csharp
string details = exception.ToString();
KryptonGitHubIssueReportDialog.Show(
    this,
    secretKey,
    initialDescription: details);
```

## Security notes

- Config files use **AES-256-CBC** with a random IV per save; key derived via SHA-256 from your secret.
- Store the decryption secret outside source (environment variable, OS vault, deployment secret).
- PATs should use minimum required scope and be rotated periodically.
- Users never see Owner, RepositoryName, or PAT fields in the dialog UI.

## Troubleshooting

**"Failed to load GitHub configuration"**

- Encrypted file missing, corrupted, or wrong secret key
- Verify `BugReportGitHubConfigEncryption.GetDefaultConfigFilePath()` or your custom path

**`InvalidOperationException` on in-memory config**

- `BugReportGitHubConfig.IsValid` is false — set Owner, RepositoryName, and PersonalAccessToken

**API errors after submit**

- PAT expired or lacks `repo` / `public_repo` scope
- Repository does not allow issue creation for the token's user

## See also

- [Bug reporting dialog API](BugReportingDialogAPI.md) — e-mail/file reports via `KryptonBugReportingDialog`
- [KryptonExceptionDialog](../Toolkit/Components/KryptonExceptionDialog.md)
- [Exception handling overview](../Toolkit/Components/ExceptionHandling.md)
- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
