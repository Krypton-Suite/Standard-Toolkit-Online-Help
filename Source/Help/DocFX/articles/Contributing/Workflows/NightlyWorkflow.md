# Nightly Workflow

## Overview

The Nightly workflow automatically creates and publishes bleeding-edge builds from the `alpha` branch on a daily schedule. It includes intelligent change detection to skip builds when no changes have occurred, and features kill switch controls for emergency disabling.

## Purpose

- **Automated Nightly Builds**: Provides latest development builds without manual intervention
- **Change Detection**: Only builds when code has changed in the last 24 hours
- **Bleeding-Edge Testing**: Enables early testing of new features and fixes
- **NuGet Publishing**: Automatically publishes packages to nuget.org
- **Community Notifications**: Announces releases via Discord

## Trigger Conditions

### Scheduled

- **Cron**: `0 0 * * *` (midnight UTC every day)
- **Time Zone**: UTC
- **Frequency**: Once per day

### Manual

- **`workflow_dispatch`**: Can be manually triggered from Actions tab
- **Use Case**: Testing workflow changes or forcing a build

## Workflow Structure

### Job: `nightly`

**Runner**: `windows-latest`

**Environment**: `production` (requires approval before publishing)

**Concurrency**:
- **Group**: `nightly-alpha`
- **Cancel In-Progress**: `true`
- Prevents multiple nightly builds from running simultaneously

### Steps Overview

1. **Kill Switch Check** - Verifies if workflow is disabled
2. **Security Verification** - Validates repository and branch
3. **Checkout** - Checks out `alpha` branch
4. **Change Detection** - Checks for commits in last 24 hours
5. **Skip Notification** - Notifies if no changes found
6. **Setup .NET** - Installs .NET SDKs
7. **Setup .NET 11** - Attempts to install .NET 11 (optional)
8. **Force .NET 10 SDK** - Creates `global.json`
9. **Setup MSBuild** - Configures MSBuild
10. **Setup NuGet** - Configures NuGet
11. **Cache NuGet** - Caches packages
12. **Restore** - Restores dependencies
13. **Build Nightly** - Builds the solution
14. **Pack Nightly** - Creates NuGet packages
15. **Push NuGet Packages** - Publishes to nuget.org
16. **Get Version** - Extracts version information
17. **Announce on Discord** - Sends notification

## Detailed Behavior

### Kill Switch

**Variable**: `NIGHTLY_DISABLED`

**Location**: Repository Settings → Secrets and variables → Actions → Variables

**Values**:
- `true` - Disables workflow (all steps skipped after check)
- `false` or unset - Enables workflow

**Use Cases**:
- Emergency disabling of automated builds
- Maintenance periods
- Preventing duplicate releases

**Implementation**:
```powershell
$disabled = '${{ vars.NIGHTLY_DISABLED }}'
if ($disabled -eq 'true') {
  echo "enabled=false" >> $env:GITHUB_OUTPUT
}
```

All subsequent steps check: `if: steps.nightly_release_kill_switch.outputs.enabled == 'true'`

### Security Verification

#### Repository Check

Validates that workflow only runs on the correct repository:
```powershell
if ($env:GITHUB_REPOSITORY -ne 'Krypton-Suite/Standard-Toolkit') {
  Write-Error "Security: Invalid repository"
  exit 1
}
```

#### Branch Check

Verifies workflow is running from an authorized branch:
```powershell
$allowedRefs = @('refs/heads/alpha', 'refs/heads/master', 'refs/heads/main')
if ($env:GITHUB_REF -notin $allowedRefs) {
  Write-Error "Security: Unauthorized branch"
  exit 1
}
```

**Note**: Workflow checks out `alpha` branch regardless of trigger source.

### Change Detection

**Purpose**: Skips build if no commits in last 24 hours

**Implementation**:
```powershell
$yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
$commitCount = git rev-list --count --since="$yesterday" alpha
```

**Logic**:
- Counts commits on `alpha` branch since 24 hours ago
- If count > 0: proceeds with build
- If count = 0: skips build and logs notice

**Benefits**:
- Saves CI minutes
- Prevents duplicate packages
- Reduces noise in notifications

### .NET SDK Setup

**Versions Installed**:
- .NET 9.0.x
- .NET 10.0.x
- .NET 11.0.x (optional, continues on error)

**Special Handling**:
- .NET 11 setup has `continue-on-error: true`
- Falls back gracefully if .NET 11 not available
- Logs notice if .NET 11 setup fails

**global.json Generation**:
- Prefers .NET 10 SDK
- Falls back to .NET 8 if .NET 10 unavailable
- Uses `rollForward: latestFeature`

### Build Process

**Project File**: `Scripts/nightly.proj`

**Configuration**: `Nightly`

**Platform**: `Any CPU`

**Targets**:
1. `Build` - Compiles solution
2. `Pack` - Creates NuGet packages

**Output Location**: `Bin/Packages/Nightly/`

### NuGet Publishing

**Process**:
1. Scans for `.nupkg` files in `Bin/Packages/Nightly/`
2. Pushes each package to nuget.org
3. Uses `--skip-duplicate` flag to handle existing packages
4. Tracks if any packages were actually published

**Package Detection**:
```powershell
$packages = Get-ChildItem "Bin/Packages/Nightly/*.nupkg"
```

**Publishing Logic**:
- Checks output for "already exists" or "was not pushed"
- Only marks as published if package was new
- Continues with remaining packages on individual failures

**Required Secret**: `NUGET_API_KEY`

**Output Variable**: `packages_published` (true/false)

### Version Extraction

**Methods** (in order of preference):

1. **Assembly Version** (Primary)
   ```powershell
   $dllPath = Get-ChildItem "Bin/Nightly/net48/Krypton.Toolkit.dll"
   $assemblyVersion = [System.Reflection.AssemblyName]::GetAssemblyName($dllPath.FullName).Version
   ```

2. **Project File** (Fallback)
   ```powershell
   [xml]$projXml = Get-Content "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit.csproj"
   $versionNode = $projXml.SelectSingleNode("//Version")
   ```

3. **Hardcoded Fallback**
   - Version: `100.25.1.1`
   - Tag: `v100.25.1.1-nightly`

**Output Variables**:
- `version` - Version number (e.g., `100.25.1.1`)
- `tag` - Git tag format (e.g., `v100.25.1.1-nightly`)

### Discord Notification

**Trigger**: Only if packages were published (`packages_published == 'True'`)

**Required Secret**: `DISCORD_WEBHOOK_NIGHTLY`

**Message Content**:
- Title: "🚀 Krypton Toolkit Nightly Release"
- Version information
- NuGet package links
- Target frameworks list
- Changelog link

**Color**: `10181046` (purple/blue)

**Packages Listed**:
- Krypton.Toolkit.Nightly
- Krypton.Ribbon.Nightly
- Krypton.Navigator.Nightly
- Krypton.Workspace.Nightly
- Krypton.Docking.Nightly
- Krypton.Standard.Toolkit.Nightly

## Configuration

### Required Secrets

- **`NUGET_API_KEY`**: API key for nuget.org publishing
  - Get from: https://www.nuget.org/account/apikeys
  - Requires "Push" permission

- **`DISCORD_WEBHOOK_NIGHTLY`**: Discord webhook URL for notifications
  - Create in Discord server settings
  - Optional (workflow continues if not set)

### Required Variables

- **`NIGHTLY_DISABLED`**: Kill switch variable
  - Set to `true` to disable workflow
  - Set to `false` or leave unset to enable

### Required Environments

- **`production`**: Protected environment
  - Requires approval before publishing
  - Prevents accidental releases
  - Configure in repository settings

## Troubleshooting

### Workflow Not Running

**Possible Causes**:
1. Kill switch enabled (`NIGHTLY_DISABLED=true`)
2. No changes in last 24 hours (expected behavior)
3. Schedule not configured correctly
4. Workflow file syntax errors

**Solutions**:
- Check variable `NIGHTLY_DISABLED` in repository settings
- Verify commits exist on `alpha` branch
- Review workflow schedule syntax
- Check Actions tab for errors

### Build Skipped Due to No Changes

**Expected Behavior**: This is intentional

**Reason**: Saves resources when no new code exists

**Solution**: Make a commit to `alpha` branch or manually trigger workflow

### NuGet Publishing Failed

**Possible Causes**:
1. Missing or invalid `NUGET_API_KEY`
2. Package version already exists
3. Network issues
4. Invalid package format

**Solutions**:
- Verify API key is set and valid
- Check if package version already exists (this is handled gracefully)
- Review NuGet push logs
- Verify package files are valid

### Discord Notification Not Sent

**Possible Causes**:
1. No packages were published (expected if duplicates)
2. Missing `DISCORD_WEBHOOK_NIGHTLY` secret
3. Webhook URL invalid
4. Discord API issues

**Solutions**:
- Check `packages_published` output in logs
- Verify webhook secret is set
- Test webhook URL manually
- Check Discord server settings

### Version Extraction Failed

**Behavior**: Uses fallback version `100.25.1.1`

**Solutions**:
- Verify build completed successfully
- Check if DLL exists at expected path
- Review version extraction logs
- Ensure project file has `<Version>` element

### .NET 11 Setup Failed

**Expected Behavior**: This is normal if .NET 11 is not yet available

**Solution**: Workflow continues with .NET 10 (this is intentional)

## Related Workflows

- **Build Workflow**: Similar build process for CI
- **Release Workflow**: Similar publishing process for stable releases

## Code Reference

**File**: `.github/workflows/nightly.yml`

**Key Components**:
- Event: `schedule` and `workflow_dispatch`
- Environment: `production`
- Concurrency: `nightly-alpha` group
- Kill Switch: `NIGHTLY_DISABLED` variable

## Maintenance Notes

### Updating Schedule

To change the build schedule:

```yaml
schedule:
  - cron: '0 0 * * *'  # Change cron expression
```

**Common Schedules**:
- `0 0 * * *` - Daily at midnight UTC
- `0 */6 * * *` - Every 6 hours
- `0 0 * * 1` - Weekly on Monday

### Modifying Change Detection Window

To change the 24-hour window:

```powershell
$yesterday = (Get-Date).AddHours(-24).AddDays(-1)  # Change hours
```

### Adding New Packages

If new NuGet packages are added:

1. Update Discord notification message
2. Verify package paths in publishing step
3. Test package creation in build step

### Kill Switch Management

**To Disable**:
1. Go to Repository Settings → Secrets and variables → Actions
2. Add/Edit variable: `NIGHTLY_DISABLED` = `true`
3. Save

**To Re-enable**:
1. Set `NIGHTLY_DISABLED` = `false`
2. Or delete the variable

## Best Practices

1. **Monitor Builds**: Check Actions tab regularly for failures
2. **Version Management**: Ensure version numbers increment correctly
3. **Change Detection**: Let the workflow skip when appropriate
4. **Kill Switch**: Use for maintenance or emergency stops
5. **Notifications**: Keep Discord webhook updated
6. **Security**: Never commit secrets or API keys

## Workflow Flow Diagram

```
Schedule Trigger (00:00 UTC)
    │
    ├─> Kill Switch Check
    │   └─> If disabled: Exit
    │
    ├─> Security Verification
    │   ├─> Repository Check
    │   └─> Branch Check
    │
    ├─> Checkout alpha Branch
    │
    ├─> Change Detection (24h)
    │   └─> If no changes: Skip & Exit
    │
    ├─> Setup .NET SDKs (9, 10, 11)
    │
    ├─> Setup Build Tools (MSBuild, NuGet)
    │
    ├─> Restore & Build
    │
    ├─> Pack NuGet Packages
    │
    ├─> Publish to nuget.org
    │   └─> If published: Continue
    │   └─> If skipped: Exit (no notification)
    │
    ├─> Extract Version
    │
    └─> Discord Notification (if published)
```

