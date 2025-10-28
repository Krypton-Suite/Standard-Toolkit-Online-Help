# GitHub Workflows Documentation

## Table of Contents
1. [Overview](#overview)
2. [Build Workflow](#build-workflow)
3. [Release Workflow](#release-workflow)
4. [Nightly Release Workflow](#nightly-release-workflow)
5. [Nightly Release Test Workflow](#nightly-release-test-workflow)
6. [Configuration & Secrets](#configuration--secrets)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Overview

The Krypton Toolkit uses GitHub Actions for continuous integration, automated builds, releases, and package distribution. The workflow system handles multiple release channels with different stability levels:

- **Master**: Stable production releases
- **V85-LTS**: Long-Term Support releases with extended framework support
- **Canary**: Pre-release builds for early testing
- **Alpha**: Nightly builds for bleeding-edge development
- **Pull Requests**: Automated testing and validation

### Workflow Architecture

```
┌─────────────────┐
│  Pull Request   │──> Build Workflow ──> Validation Only
└─────────────────┘

┌─────────────────┐
│  Push to Branch │──> Build Workflow ──> Build + Conditional Release
└─────────────────┘
                    │
                    ├──> master ──────> Release Workflow (Stable)
                    ├──> V85-LTS ─────> Release Workflow (LTS)
                    ├──> canary ──────> Release Workflow (Canary)
                    └──> alpha ───────> Release Workflow (Alpha)

┌─────────────────┐
│ Cron Schedule   │──> Nightly Workflow ──> Automated Nightly Builds
│  (00:00 UTC)    │
└─────────────────┘
```

---

## Build Workflow

**File**: `.github/workflows/build.yml`

### Purpose

The Build workflow validates code quality and ensures compilability across all supported target frameworks. It serves as the primary CI/CD gate for pull requests and branch pushes.

### Triggers

```yaml
on:
  pull_request:
    branches: ['**']
    types: [opened, synchronize, reopened]
  push:
    branches: [master, alpha, canary, gold, V85-LTS]
    paths-ignore: ['.git*', '.vscode']
```

- **Pull Requests**: All branches, triggered on open, sync, or reopen
- **Push Events**: Protected branches only (master, alpha, canary, gold, V85-LTS)
- **Ignores**: Git metadata and VSCode configuration changes

### Jobs

#### 1. Build Job

**Runner**: `windows-2022`

**Conditions**: 
- Always runs for push events
- Only runs for PRs from the same repository (prevents external fork abuse)

**Steps**:

1. **Checkout**: Clone the repository with default depth
2. **Setup .NET 9** (GA): Install stable .NET 9 SDK
3. **Setup .NET 10** (GA): Install .NET 10 SDK (continues on error if unavailable)
4. **Setup .NET 11** (Preview): Install .NET 11 preview SDK (continues on error if unavailable)
5. **Force .NET 10 SDK via global.json**: 
   - Dynamically generates `global.json` to use the latest available .NET 10 SDK
   - Falls back to .NET 8 if .NET 10 is unavailable
6. **Setup MSBuild**: Configure MSBuild x64 architecture
7. **Setup NuGet**: Install NuGet CLI
8. **Cache NuGet**: Cache NuGet packages for faster subsequent builds
9. **Restore**: Restore NuGet dependencies for the solution
10. **Build**: Execute MSBuild with Release configuration via `Scripts/nightly.proj`

**Target Frameworks Built**:
- .NET Framework 4.7.2, 4.8, 4.8.1
- .NET 8.0-windows, 9.0-windows, 10.0-windows

#### 2. Release Job

**Runner**: `windows-2022`

**Conditions**: 
- Only runs after successful build
- Only runs for pushes to `master` branch
- Does NOT run for pull requests or other branches

**Steps**:

1. **Checkout**: Clone the repository
2. **Setup .NET 9** (GA)
3. **Setup .NET 10** (Preview with preview quality)
4. **Force .NET 10 SDK via global.json**
5. **Setup MSBuild**
6. **Setup NuGet**
7. **Cache NuGet**
8. **Restore**: Restore dependencies
9. **Build Release**: Build using `Scripts/build.proj`
10. **Pack Release**: Create NuGet packages
11. **Create Release Archives**: Generate ZIP and TAR.GZ distribution archives
12. **Get Version**: Extract version from assembly or project file
13. **Create Release**: Create GitHub release with version tag
14. **Upload Release Assets**: Attach ZIP and TAR.GZ files to the GitHub release

**Outputs**:
- GitHub Release with tag `v{version}`
- Release archives: `Krypton-Release_*.zip`, `Krypton-Release_*.tar.gz`

### Configuration

**Environment Variables**: None required

**Secrets**: 
- `GITHUB_TOKEN` (automatic): Used for creating GitHub releases

### Usage Examples

#### Trigger via Pull Request
```bash
# Create a feature branch and push
git checkout -b feature/my-feature
git push origin feature/my-feature

# Open a PR to any branch → Build workflow runs automatically
```

#### Trigger via Push to Master
```bash
# Merge to master
git checkout master
git merge feature/my-feature
git push origin master

# Build workflow runs → On success, Release job creates GitHub release
```

### Debugging Tips

1. **Build Failures**: Check MSBuild output in "Build" step
2. **.NET SDK Issues**: Review "Setup .NET" steps for version availability
3. **NuGet Restore Failures**: Check "Restore" step and network connectivity
4. **Release Creation Failures**: Verify `GITHUB_TOKEN` permissions

---

## Release Workflow

**File**: `.github/workflows/release.yml`

### Purpose

The Release workflow handles production releases across four different release channels: Stable (master), LTS (V85-LTS), Canary, and Alpha. Each channel targets different audiences and stability requirements.

### Triggers

```yaml
on:
  push:
    branches: [master, alpha, canary, V85-LTS]
```

- **Master**: Stable production releases
- **Alpha**: Bleeding-edge nightly-style releases (on-push)
- **Canary**: Pre-release early testing builds
- **V85-LTS**: Long-term support releases

### Jobs

#### 1. release-master

**Purpose**: Create stable production releases from the master branch

**Runner**: `windows-2022`

**Conditions**: `github.ref == 'refs/heads/master' && github.event_name == 'push'`

**Steps**:

1. **Checkout**: Clone repository
2. **Setup .NET 9, 10, 11**: Multi-version .NET SDK installation
3. **Force .NET 10 SDK via global.json**: Dynamic SDK selection
4. **Setup MSBuild & NuGet**
5. **Cache NuGet**: Performance optimization
6. **Restore**: Dependency restoration
7. **Build Release**: Build via `Scripts/build.proj` (Release configuration)
8. **Pack Release**: Create NuGet packages
9. **Push NuGet Packages**: Publish to nuget.org with duplicate skip
   - Uses `--skip-duplicate` flag
   - Sets `packages_published` output (true/false)
10. **Create Release Archives**: Generate ZIP and TAR.GZ files
11. **Get Version**: Extract version from built assembly (fallbacks to csproj, then hardcoded)
12. **Diagnostics**: List all artifacts and verify secrets
13. **Create or Update Release**: 
    - Creates GitHub release if it doesn't exist
    - Updates existing release if it already exists
14. **Upload Release Assets**: Attach archives to GitHub release
15. **Announce Release on Discord**: Send webhook notification (conditional on successful publish)

**Target Frameworks**:
- .NET Framework 4.7.2, 4.8, 4.8.1
- .NET 8.0-windows, 9.0-windows, 10.0-windows

**NuGet Packages**:
- Krypton.Toolkit
- Krypton.Ribbon
- Krypton.Navigator
- Krypton.Workspace
- Krypton.Docking

**GitHub Release Tag**: `v{version}` (e.g., `v100.25.1.1`)

**Discord Notification**: Blue embed (color: 3447003) with stable release announcement

#### 2. release-v85-lts

**Purpose**: Long-Term Support releases with extended framework support

**Runner**: `windows-2022`

**Conditions**: `github.ref == 'refs/heads/V85-LTS' && github.event_name == 'push'`

**Key Differences from Master**:
- **Build Script**: Uses `Scripts/longtermstable.proj`
- **.NET SDKs**: .NET 6 (LTS), .NET 7, .NET 8 (LTS) instead of 9, 10, 11
- **Target Frameworks**: 
  - .NET Framework 4.6.2, 4.7, 4.7.1, 4.7.2, 4.8, 4.8.1
  - .NET 6.0-windows, 7.0-windows, 8.0-windows
- **Package Names**: Suffixed with `.LTS` (e.g., `Krypton.Toolkit.LTS`)
- **Version Fallback**: `85.25.1.1`
- **GitHub Release Tag**: `v{version}-lts`
- **Discord Notification**: Orange embed (color: 15105570) with LTS designation

**Use Case**: Organizations requiring support for older .NET Framework versions or LTS .NET versions only

#### 3. release-canary

**Purpose**: Pre-release builds for early adopters and testing

**Runner**: `windows-2022`

**Conditions**: `github.ref == 'refs/heads/canary' && github.event_name == 'push'`

**Key Differences**:
- **Build Script**: Uses `Scripts/canary.proj`
- **Configuration**: `Canary` instead of `Release`
- **Build Output Path**: `Bin/Canary/` and `Bin/Packages/Canary/`
- **Version Source**: Reads from `Bin/Canary/net48/Krypton.Toolkit.dll`
- **GitHub Release Tag**: `v{version}-canary`
- **Discord Notification**: Yellow embed (color: 16776960) with canary warning

**Use Case**: Testing new features before they reach stable

#### 4. release-alpha

**Purpose**: Nightly-style builds from alpha branch (on push, not scheduled)

**Runner**: `windows-2022`

**Conditions**: `github.ref == 'refs/heads/alpha' && github.event_name == 'push'`

**Key Differences**:
- **Build Script**: Uses `Scripts/nightly.proj` (Nightly configuration)
- **Build Output Path**: `Bin/Nightly/` and `Bin/Packages/Nightly/`
- **Version Source**: Reads from `Bin/Nightly/net48/Krypton.Toolkit.dll`
- **GitHub Release Tag**: `v{version}-nightly`
- **Discord Notification**: Purple embed (color: 10181046) with nightly designation

**Use Case**: Immediate builds when alpha branch is updated (not scheduled)

### Shared Components

#### Version Detection Strategy

All release jobs use a three-tier fallback approach:

1. **Primary**: Read assembly version from built DLL
   ```powershell
   $assemblyVersion = [System.Reflection.AssemblyName]::GetAssemblyName($dllPath.FullName).Version
   ```

2. **Fallback**: Parse csproj XML for `<Version>` node
   ```powershell
   [xml]$projXml = Get-Content 'Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj'
   $version = $projXml.SelectSingleNode("//Version").InnerText.Trim()
   ```

3. **Last Resort**: Hardcoded fallback version (varies by channel)

#### NuGet Push Logic

```powershell
dotnet nuget push "$($package.FullName)" \
  --api-key $env:NUGET_API_KEY \
  --source https://api.nuget.org/v3/index.json \
  --skip-duplicate
```

- **Duplicate Handling**: `--skip-duplicate` prevents errors when version already exists
- **Detection**: Checks output for "already exists" or "was not pushed"
- **Output Variable**: Sets `packages_published=true` only if new packages were published

#### Discord Webhook Integration

Webhooks are triggered conditionally based on `packages_published` output:

```yaml
if: steps.push_nuget.outputs.packages_published == 'True'
```

**Webhook Payload Structure**:
```json
{
  "embeds": [
    {
      "title": "Release Announcement",
      "description": "Release details",
      "color": "<channel-specific>",
      "fields": [
        { "name": "Version", "value": "...", "inline": true },
        { "name": "NuGet Packages", "value": "...", "inline": false },
        { "name": "Target Frameworks", "value": "...", "inline": false },
        { "name": "NuGet Packages", "value": "...", "inline": false }
      ],
      "footer": { "text": "Released" },
      "timestamp": "<ISO8601>"
    }
  ]
}
```

### Configuration

**Required Secrets**:
- `NUGET_API_KEY`: API key for publishing to nuget.org
- `GITHUB_TOKEN`: Automatically provided for GitHub release creation
- `DISCORD_WEBHOOK_MASTER`: Webhook URL for master releases (optional)
- `DISCORD_WEBHOOK_LTS`: Webhook URL for LTS releases (optional)
- `DISCORD_WEBHOOK_CANARY`: Webhook URL for canary releases (optional)
- `DISCORD_WEBHOOK_NIGHTLY`: Webhook URL for alpha/nightly releases (optional)

### Usage Examples

#### Stable Release (Master)
```bash
git checkout master
git merge develop
git push origin master
# → Builds, packages, publishes NuGet, creates GitHub release, notifies Discord
```

#### LTS Release
```bash
git checkout V85-LTS
git cherry-pick <commit-hash>
git push origin V85-LTS
# → Creates LTS packages with extended framework support
```

#### Canary Pre-Release
```bash
git checkout canary
git merge feature/experimental
git push origin canary
# → Publishes canary packages for early testing
```

### Troubleshooting

#### Issue: NuGet Push Fails with "Duplicate Package"
**Solution**: This is expected behavior. The workflow uses `--skip-duplicate` and will log a warning but continue.

#### Issue: GitHub Release Creation Fails
**Diagnostic Steps**:
1. Check "Diagnostics - List Artifacts" step output
2. Verify `GITHUB_TOKEN` has `contents: write` permission
3. Ensure release archives were created successfully

#### Issue: Discord Notification Not Sent
**Possible Causes**:
1. Webhook secret not configured (check "DISCORD_WEBHOOK_*" is set)
2. `packages_published == 'false'` (all packages were duplicates)
3. Webhook URL is invalid or expired

#### Issue: Version Detection Returns Fallback
**Diagnostic Steps**:
1. Check if DLL was built successfully
2. Verify DLL path matches expected location (`Bin/<Config>/net48/Krypton.Toolkit.dll`)
3. Ensure `<Version>` tag exists in csproj

---

## Nightly Release Workflow

**File**: `.github/workflows/nightly.yml`

### Purpose

Automated nightly builds from the alpha branch, scheduled to run daily at midnight UTC. This workflow includes intelligent change detection to avoid publishing when there are no code changes.

### Triggers

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Midnight UTC daily
  workflow_dispatch:      # Manual triggering for testing
```

- **Scheduled**: Runs automatically every day at 00:00 UTC
- **Manual**: Can be triggered manually from GitHub Actions UI for testing

### Jobs

#### nightly

**Runner**: `windows-2022`

**No Branch Restrictions**: Runs on the branch where the workflow file exists (typically alpha)

**Key Features**:
- **Change Detection**: Checks for commits in the last 24 hours before building
- **Conditional Execution**: Skips build steps if no changes detected
- **Resource Efficiency**: Saves CI time and prevents unnecessary package versions

**Steps**:

1. **Checkout**: Clone alpha branch with full git history (`fetch-depth: 0`)

2. **Check for changes in last 24 hours**:
   ```powershell
   $yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
   $commitCount = git rev-list --count --since="$yesterday" alpha
   ```
   - Counts commits in the last 24 hours
   - Sets `has_changes=true/false` output variable
   - Determines whether subsequent steps should run

3. **Skip notification**: Displays notice if no changes detected
   ```
   No commits in the last 24 hours. Skipping nightly build and publish.
   ```

4. **Setup .NET 9** (GA) - *Conditional on has_changes*

5. **Setup .NET 10** (GA) - *Conditional on has_changes*
   - Continues on error if unavailable

6. **Setup .NET 11** (Preview) - *Conditional on has_changes*
   - Continues on error if unavailable

7. **Force .NET 10 SDK via global.json** - *Conditional on has_changes*
   - Dynamically selects latest .NET 10 SDK
   - Falls back to .NET 8 if needed

8. **Setup MSBuild** - *Conditional on has_changes*

9. **Setup NuGet** - *Conditional on has_changes*

10. **Cache NuGet** - *Conditional on has_changes*

11. **Restore** - *Conditional on has_changes*

12. **Build Nightly** - *Conditional on has_changes*
    - Uses `Scripts/nightly.proj` with Nightly configuration

13. **Pack Nightly** - *Conditional on has_changes*

14. **Push NuGet Packages to nuget.org** - *Conditional on has_changes*
    - Publishes to `Bin/Packages/Nightly/*.nupkg`
    - Uses `--skip-duplicate` flag
    - Sets `packages_published` output

15. **Get Version** - *Conditional on has_changes*
    - Three-tier fallback strategy (assembly → csproj → hardcoded)
    - Fallback version: `100.25.1.1`

16. **Announce Nightly Release on Discord**
    - Only runs if `packages_published == 'True'`
    - Purple embed (color: 10181046)

### Change Detection Logic

The workflow uses git to determine if there have been any commits to the alpha branch in the last 24 hours:

```powershell
# Get commits from last 24 hours on alpha branch
$yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
$commitCount = git rev-list --count --since="$yesterday" alpha

if ([int]$commitCount -gt 0) {
    echo "has_changes=true" >> $env:GITHUB_OUTPUT
} else {
    echo "has_changes=false" >> $env:GITHUB_OUTPUT
}
```

**Why Full History is Required**:
- `fetch-depth: 0` ensures git has complete history to check commit dates
- Shallow clones would not have sufficient history for accurate counting

### Workflow Behavior

#### Scenario 1: No Changes
```
00:00 UTC - Workflow triggered by cron
├─ Checkout (fetch full history)
├─ Check for changes → 0 commits found
├─ Skip notification displayed
└─ All build steps skipped
Duration: ~1 minute
```

#### Scenario 2: Changes Detected
```
00:00 UTC - Workflow triggered by cron
├─ Checkout (fetch full history)
├─ Check for changes → 5 commits found
├─ Setup .NET SDKs
├─ Build and Pack
├─ Push to NuGet (if not duplicate)
├─ Announce on Discord (if published)
└─ Complete
Duration: ~10-15 minutes
```

#### Scenario 3: Manual Trigger (workflow_dispatch)
- Always runs all steps regardless of change detection
- Useful for testing or forcing a build
- Can override change detection by modifying the workflow

### Configuration

**Required Secrets**:
- `NUGET_API_KEY`: For publishing to nuget.org
- `DISCORD_WEBHOOK_NIGHTLY`: For Discord notifications (optional)

**Environment Variables**: None

### Usage Examples

#### Normal Operation (Automatic)
```
# Workflow runs automatically at 00:00 UTC
# No manual intervention required
# Publishes only if changes exist
```

#### Manual Trigger for Testing
1. Go to GitHub Actions → Nightly Release
2. Click "Run workflow"
3. Select branch (usually alpha)
4. Click "Run workflow" button

#### Force Build Regardless of Changes
Temporarily modify the workflow condition:
```yaml
# Change from:
if: steps.check_changes.outputs.has_changes == 'true'

# To:
if: steps.check_changes.outputs.has_changes == 'true' || github.event_name == 'workflow_dispatch'
```

### Target Frameworks
- .NET Framework 4.7.2, 4.8, 4.8.1
- .NET 8.0-windows, 9.0-windows, 10.0-windows

### NuGet Packages
- Krypton.Toolkit (nightly version)
- Krypton.Ribbon (nightly version)
- Krypton.Navigator (nightly version)
- Krypton.Workspace (nightly version)
- Krypton.Docking (nightly version)

### Troubleshooting

#### Issue: Nightly Build Not Triggering
**Possible Causes**:
1. Cron schedule timezone issue (ensure 00:00 UTC is correct for your needs)
2. Workflow file not on the branch being monitored
3. GitHub Actions disabled for repository

**Solution**: 
- Verify workflow file exists on alpha branch
- Check GitHub Actions settings are enabled
- Manually trigger to test

#### Issue: Build Runs But No Packages Published
**Likely Cause**: All packages already exist with current version

**Solution**:
1. Check NuGet.org for existing version
2. Increment version in project files if needed
3. Review "Push NuGet Packages" step logs for "already exists" messages

#### Issue: Change Detection Always Shows "No Changes"
**Diagnostic Steps**:
1. Verify `fetch-depth: 0` is set in checkout step
2. Check git log manually:
   ```bash
   git log --since="24 hours ago" --oneline alpha
   ```
3. Ensure commits are being pushed to alpha branch

#### Issue: Change Detection Always Shows "Changes Exist"
**Possible Cause**: Git history not properly fetched or branch specification incorrect

**Solution**:
1. Verify branch name in `git rev-list` command matches actual branch
2. Check that checkout step specifies `ref: alpha`

---

## Nightly Release Test Workflow

**File**: `.github/workflows/nightly-release-test.yml`

### Purpose

A testing/staging version of the nightly release workflow with additional safeguards. This workflow is designed for testing nightly release processes on a specific branch without affecting production nightly releases.

### Differences from Production Nightly Workflow

| Feature | Production (`nightly.yml`) | Test (`nightly-release-test.yml`) |
|---------|---------------------------|-----------------------------------|
| **Branch Restriction** | No explicit restriction | Explicitly checks `refs/heads/alpha` |
| **Concurrency Control** | None | `nightly-alpha` group, cancel-in-progress |
| **.NET 11 Support** | Yes (.NET 11 preview) | No (.NET 11 not included) |
| **.NET 10 Quality** | GA | Preview (`dotnet-quality: preview`) |
| **Purpose** | Production nightly builds | Testing and validation |

### Triggers

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Midnight UTC daily
  workflow_dispatch:      # Manual triggering for testing
```

Same as production nightly workflow.

### Jobs

#### nightly

**Runner**: `windows-2022`

**Conditions**: 
```yaml
if: github.ref == 'refs/heads/alpha'
```
- Only runs if the push/trigger is on the alpha branch
- Prevents accidental execution on other branches

**Concurrency Control**:
```yaml
concurrency:
  group: nightly-alpha
  cancel-in-progress: true
```
- Ensures only one nightly build runs at a time
- Automatically cancels previous runs if a new one starts
- Prevents resource contention and duplicate builds

**Steps**:

1. **Checkout alpha branch**: Explicitly checks out alpha with full history
   ```yaml
   ref: alpha
   fetch-depth: 0
   ```

2. **Check for changes in last 24 hours**: Identical to production workflow

3. **Skip notification**: Displays notice if no changes

4. **Setup .NET 9** (GA) - *Conditional*

5. **Setup .NET 10 (preview)** - *Conditional*
   - Uses `dotnet-quality: preview` (production uses GA)

6. **Force .NET 10 SDK via global.json** - *Conditional*

7. **Setup MSBuild** - *Conditional*

8. **Setup NuGet** - *Conditional*

9. **Cache NuGet** - *Conditional*

10. **Restore** - *Conditional*

11. **Build Nightly** - *Conditional*

12. **Pack Nightly** - *Conditional*

13. **Push NuGet Packages to nuget.org** - *Conditional*
    - Same logic as production
    - **Warning**: Still publishes to production NuGet.org!

### Key Configuration Differences

#### Checkout Step
```yaml
# Test workflow explicitly specifies branch
- name: Checkout alpha branch
  uses: actions/checkout@v5
  with:
    ref: alpha
    fetch-depth: 0
```

#### .NET 10 Setup
```yaml
# Test workflow uses preview quality
- name: Setup .NET 10 (preview)
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 10.0.x
    dotnet-quality: preview  # ← Difference
```

### When to Use This Workflow

**Use Test Workflow When**:
- Testing changes to the nightly release process
- Validating new .NET SDK versions
- Debugging workflow issues without affecting production
- Testing change detection logic

**Use Production Workflow When**:
- Ready for production nightly releases
- All testing is complete
- Workflow is stable and proven

### Important Warnings

⚠️ **NuGet Publishing**: This test workflow still publishes to production NuGet.org. Packages published here are real and public.

⚠️ **Discord Notifications**: If configured, this will send notifications to production Discord channels.

### Migration to Production

When moving from test to production:

1. **Review Differences**: Compare test and production workflows
2. **Update .NET SDK Quality**: Change from `preview` to GA if applicable
3. **Remove Branch Restriction**: Or adjust to match production needs
4. **Verify Concurrency Settings**: Adjust or remove as needed
5. **Test Manually**: Use `workflow_dispatch` to test before relying on cron

### Configuration

**Required Secrets**: Same as production nightly workflow
- `NUGET_API_KEY`
- `DISCORD_WEBHOOK_NIGHTLY` (optional)

### Troubleshooting

#### Issue: Workflow Doesn't Run on Alpha Branch
**Possible Cause**: Branch name mismatch

**Solution**:
1. Verify actual branch name: `git branch -a`
2. Ensure workflow file exists on alpha branch
3. Check branch protection rules

#### Issue: Concurrent Builds Cancelling Each Other
**Expected Behavior**: This is intentional due to concurrency control

**Solution**: 
- Wait for current build to complete before triggering another
- Disable concurrency control if multiple simultaneous builds are needed:
  ```yaml
  # Remove or comment out:
  # concurrency:
  #   group: nightly-alpha
  #   cancel-in-progress: true
  ```

#### Issue: .NET 10 Preview Not Available
**Expected Behavior**: Build continues due to `continue-on-error` setting

**Solution**: No action needed; workflow will use available SDKs

---

## Configuration & Secrets

### Required Secrets

All secrets are configured at repository level (Settings → Secrets and variables → Actions).

#### NUGET_API_KEY
- **Type**: Secret
- **Used By**: All release workflows
- **Purpose**: Authenticates with NuGet.org for package publishing
- **How to Obtain**:
  1. Log in to nuget.org
  2. Go to Account Settings → API Keys
  3. Create new API key with "Push" permission
  4. Set expiration appropriately
  5. Copy key and add to GitHub secrets

**Security Notes**:
- Never commit this key to version control
- Rotate periodically (recommended: every 90 days)
- Use separate keys for different repositories if possible

#### GITHUB_TOKEN
- **Type**: Automatic secret
- **Used By**: Build workflow (release job), Release workflow
- **Purpose**: Authenticate GitHub CLI for release creation
- **Configuration**: No manual setup required; automatically provided by GitHub

**Required Permissions**:
- `contents: write` - Create releases and upload assets
- `actions: read` - Read workflow runs

#### DISCORD_WEBHOOK_MASTER
- **Type**: Secret (optional)
- **Used By**: Release workflow (master releases)
- **Purpose**: Post release announcements to Discord channel
- **How to Obtain**:
  1. Open Discord server settings
  2. Go to Integrations → Webhooks
  3. Create new webhook for master releases
  4. Copy webhook URL
  5. Add to GitHub secrets

#### DISCORD_WEBHOOK_LTS
- **Type**: Secret (optional)
- **Used By**: Release workflow (V85-LTS releases)
- **Purpose**: Post LTS release announcements
- **Configuration**: Same as DISCORD_WEBHOOK_MASTER but for LTS channel

#### DISCORD_WEBHOOK_CANARY
- **Type**: Secret (optional)
- **Used By**: Release workflow (canary releases)
- **Purpose**: Post canary release announcements
- **Configuration**: Same as above but for canary releases

#### DISCORD_WEBHOOK_NIGHTLY
- **Type**: Secret (optional)
- **Used By**: Nightly workflow, Nightly test workflow, Release workflow (alpha releases)
- **Purpose**: Post nightly/alpha release announcements
- **Configuration**: Same as above but for nightly releases

### Environment Variables

No custom environment variables are required. All configuration is handled through:
- Workflow file parameters
- GitHub secrets
- Dynamic detection (e.g., SDK versions)

### Build Scripts

Workflows rely on MSBuild project files in the `Scripts/` directory:

| Script File | Purpose | Configuration | Used By |
|------------|---------|---------------|---------|
| `build.proj` | Stable releases | Release | Release workflow (master) |
| `nightly.proj` | Nightly/Alpha builds | Nightly | Build workflow, Nightly workflows, Release workflow (alpha) |
| `canary.proj` | Canary pre-releases | Canary | Release workflow (canary) |
| `longtermstable.proj` | LTS releases | Release | Release workflow (V85-LTS) |

**Script Responsibilities**:
- Define build targets and dependencies
- Specify output paths
- Configure multi-targeting
- Handle packaging logic

### Project Configuration Files

#### Directory.Build.props
- Shared MSBuild properties for all projects
- Defines common settings (version, authors, license, etc.)
- Located at `Source/Krypton Components/Directory.Build.props`

#### Directory.Build.targets
- Shared MSBuild targets
- Post-build actions and customizations
- Located at `Source/Krypton Components/Directory.Build.targets`

#### global.json (Dynamic)
- Generated at runtime by workflows
- Specifies .NET SDK version to use
- Enables SDK rollForward behavior
- Not committed to repository (regenerated each build)

### Permissions Required

**Repository Settings**:
- Actions must be enabled
- Workflow permissions must be set to "Read and write permissions"
- Check Settings → Actions → General → Workflow permissions

**Branch Protection** (Recommended):
- Require status checks for build workflow
- Require pull request reviews before merging to master
- Restrict push access to protected branches

---

## Troubleshooting

### Common Issues and Solutions

#### Build Failures

##### Issue: MSBuild Error - Project Not Found
**Symptoms**:
```
error MSB4025: The project file could not be loaded. Could not find file
```

**Causes**:
- Incorrect path to solution or project file
- Working directory changed unexpectedly
- File case sensitivity (Windows vs Linux runners)

**Solution**:
1. Verify file paths in workflow YAML
2. Ensure checkout step completed successfully
3. Check step logs for current working directory
4. Use relative paths from repository root

##### Issue: Multi-Targeting Build Failure
**Symptoms**:
```
error NETSDK1045: The current .NET SDK does not support targeting .NET X.X
```

**Causes**:
- Required .NET SDK not installed
- Wrong SDK version selected by global.json
- SDK setup step failed silently

**Solution**:
1. Review "Setup .NET" steps for errors
2. Check if `continue-on-error: true` is masking failures
3. Verify target frameworks in csproj match installed SDKs
4. Update "Force .NET SDK via global.json" logic if needed

##### Issue: Reference Assemblies Not Found
**Symptoms**:
```
error MSB4236: The SDK 'Microsoft.NET.Sdk' specified could not be found
```

**Causes**:
- .NET SDK corrupted or incomplete
- Workload installation issues
- Runner disk space issues

**Solution**:
1. Add diagnostic step to list installed SDKs:
   ```yaml
   - name: Diagnostics - List SDKs
     run: dotnet --list-sdks
   ```
2. Clear NuGet cache:
   ```yaml
   - name: Clear NuGet Cache
     run: dotnet nuget locals all --clear
   ```
3. Check runner disk space

#### NuGet Issues

##### Issue: NuGet Restore Fails
**Symptoms**:
```
error NU1301: Unable to load the service index for source
```

**Causes**:
- Network connectivity issues
- NuGet.org outage
- Incorrect NuGet source configuration
- TLS/SSL issues

**Solution**:
1. Check NuGet service status: https://status.nuget.org
2. Add retry logic:
   ```yaml
   - name: Restore with Retry
     run: |
       for i in 1 2 3; do
         dotnet restore && break || sleep 10
       done
   ```
3. Verify NuGet sources:
   ```yaml
   - name: List NuGet Sources
     run: dotnet nuget list source
   ```

##### Issue: NuGet Push Fails with 403 Forbidden
**Symptoms**:
```
error: Response status code does not indicate success: 403 (Forbidden)
```

**Causes**:
- Invalid or expired API key
- API key lacks push permission
- Package version already exists and not using `--skip-duplicate`
- Package name/prefix not owned by account

**Solution**:
1. Verify `NUGET_API_KEY` secret is set correctly
2. Check API key permissions on nuget.org
3. Verify package version doesn't exist:
   ```bash
   # Check on nuget.org
   https://www.nuget.org/packages/Krypton.Toolkit/{version}
   ```
4. Ensure `--skip-duplicate` flag is used for idempotency

##### Issue: NuGet Package Not Found After Build
**Symptoms**:
```
No NuGet packages found to push
```

**Causes**:
- Pack step failed
- Incorrect output path
- Package files not created

**Solution**:
1. Check Pack step logs for errors
2. Add diagnostic step:
   ```yaml
   - name: List Package Files
     run: Get-ChildItem -Recurse Bin/Packages
   ```
3. Verify MSBuild pack target is being executed
4. Check project file for `<IsPackable>true</IsPackable>`

#### Release Creation Issues

##### Issue: GitHub Release Creation Fails
**Symptoms**:
```
error: HTTP 404: Not Found (https://api.github.com/repos/.../releases)
```

**Causes**:
- Insufficient GITHUB_TOKEN permissions
- Tag already exists
- Invalid tag name format
- Network issues

**Solution**:
1. Verify workflow permissions:
   - Settings → Actions → General → Workflow permissions
   - Must be "Read and write permissions"
2. Check if release exists:
   ```bash
   gh release view v{version}
   ```
3. Add error handling:
   ```yaml
   - name: Create Release
     continue-on-error: true
     run: gh release create ...
   ```

##### Issue: Release Assets Not Uploading
**Symptoms**:
```
warning: Failed to upload ZIP: ...
```

**Causes**:
- Files not created by archive step
- Incorrect file path or glob pattern
- Network timeout
- File size exceeds GitHub limits

**Solution**:
1. Verify archive creation:
   ```yaml
   - name: Verify Archives Exist
     run: |
       if (-not (Test-Path "Bin/Release/Zips/*.zip")) {
         throw "ZIP archive not found"
       }
   ```
2. Check file sizes (GitHub limit: 2GB per file)
3. Add retry logic for uploads
4. Use `--clobber` flag to replace existing assets

#### Discord Webhook Issues

##### Issue: Discord Notification Not Sent
**Symptoms**: No error, but notification doesn't appear in Discord

**Causes**:
- Webhook URL not configured
- Webhook URL invalid or expired
- Discord server deleted webhook
- Payload exceeds Discord size limit
- Condition not met (`packages_published == 'false'`)

**Solution**:
1. Verify secret is configured:
   ```yaml
   - name: Check Webhook
     run: |
       if ($env:DISCORD_WEBHOOK_NIGHTLY) {
         Write-Host "Webhook is configured"
       } else {
         Write-Host "Webhook NOT configured"
       }
   ```
2. Test webhook manually:
   ```bash
   curl -X POST "WEBHOOK_URL" \
     -H "Content-Type: application/json" \
     -d '{"content": "Test message"}'
   ```
3. Review previous step outputs to ensure conditions are met

##### Issue: Discord Webhook Returns 400 Bad Request
**Symptoms**:
```
error: Invoke-RestMethod : 400 (Bad Request)
```

**Causes**:
- Invalid JSON payload
- Payload exceeds 2000 character limit
- Missing required fields
- Invalid embed structure

**Solution**:
1. Validate JSON before sending:
   ```powershell
   $payload | ConvertTo-Json -Depth 10 | Write-Host
   ```
2. Reduce description/field text length
3. Verify embed structure matches Discord API spec
4. Test payload with Discord webhook tester

#### Workflow Scheduling Issues

##### Issue: Scheduled Workflow Not Running
**Symptoms**: Workflow doesn't trigger at scheduled time

**Causes**:
- Workflow file not on default branch (usually main/master)
- Cron syntax incorrect
- GitHub Actions disabled
- Repository inactive (no activity in 60 days)

**Solution**:
1. Verify workflow file is on default branch
2. Validate cron syntax: https://crontab.guru
3. Check Actions are enabled in repository settings
4. Manually trigger to wake up repository
5. Note: Scheduled workflows may be delayed during high load periods

##### Issue: Workflow Runs Multiple Times
**Symptoms**: Workflow triggered more than once per schedule

**Causes**:
- Multiple branches have the workflow file
- Workflow dispatch triggered manually
- GitHub Actions scheduling quirk

**Solution**:
1. Add branch restriction:
   ```yaml
   jobs:
     nightly:
       if: github.ref == 'refs/heads/alpha'
   ```
2. Implement concurrency control:
   ```yaml
   concurrency:
     group: nightly-release
     cancel-in-progress: true
   ```

#### Change Detection Issues

##### Issue: Change Detection Always Returns False
**Symptoms**: Workflow always skips build even when commits exist

**Causes**:
- Shallow clone (insufficient git history)
- Wrong branch being checked
- Timezone issues in date comparison
- Git command failing silently

**Solution**:
1. Ensure full history:
   ```yaml
   - uses: actions/checkout@v5
     with:
       fetch-depth: 0  # ← Must be 0
   ```
2. Add debug output:
   ```powershell
   git log --since="24 hours ago" --oneline alpha
   Write-Host "Commits found: $commitCount"
   ```
3. Verify branch exists:
   ```powershell
   git branch -a | Select-String "alpha"
   ```

##### Issue: Change Detection Always Returns True
**Symptoms**: Workflow always builds even when no recent commits

**Causes**:
- Git command not filtering correctly
- Branch reference incorrect
- Date calculation error

**Solution**:
1. Verify git command:
   ```powershell
   # Test command manually
   $yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
   git rev-list --count --since="$yesterday" alpha
   ```
2. Check branch specification matches actual branch name
3. Validate date format and UTC conversion

### Debugging Strategies

#### Enable Detailed Logging

Add diagnostic steps to workflow:

```yaml
- name: Diagnostics
  run: |
    Write-Host "=== Environment Information ==="
    Write-Host "Runner OS: ${{ runner.os }}"
    Write-Host "GitHub Ref: ${{ github.ref }}"
    Write-Host "GitHub SHA: ${{ github.sha }}"
    Write-Host "Event Name: ${{ github.event_name }}"
    
    Write-Host "`n=== Installed .NET SDKs ==="
    dotnet --list-sdks
    
    Write-Host "`n=== Current Directory ==="
    Get-Location
    
    Write-Host "`n=== Directory Contents ==="
    Get-ChildItem -Recurse -Depth 2
```

#### Test Locally

Reproduce workflow steps locally:

```powershell
# Navigate to repository root
cd "Z:\Development\Krypton\Standard-Toolkit"

# Restore dependencies
dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"

# Build
msbuild "Scripts/nightly.proj" /t:Build /p:Configuration=Nightly /p:Platform="Any CPU"

# Pack
msbuild "Scripts/nightly.proj" /t:Pack /p:Configuration=Nightly /p:Platform="Any CPU"
```

#### Review Workflow Run Logs

1. Go to repository → Actions tab
2. Click on workflow run
3. Expand failed step
4. Look for error messages in red
5. Check subsequent steps for cascade failures
6. Download logs for offline analysis

#### Use Workflow Dispatch for Testing

Test changes without waiting for schedule:

```yaml
on:
  workflow_dispatch:
    inputs:
      debug_enabled:
        description: 'Enable debug logging'
        required: false
        default: 'false'
```

Then in workflow:
```yaml
- name: Debug Info
  if: github.event.inputs.debug_enabled == 'true'
  run: |
    # Detailed debug output here
```

### Getting Help

#### Internal Resources
- Review workflow files in `.github/workflows/`
- Check build scripts in `Scripts/` directory
- Consult repository documentation in `Documents/`

#### External Resources
- **GitHub Actions Documentation**: https://docs.github.com/actions
- **MSBuild Documentation**: https://learn.microsoft.com/visualstudio/msbuild
- **NuGet Documentation**: https://learn.microsoft.com/nuget
- **Discord Webhook API**: https://discord.com/developers/docs/resources/webhook

#### Support Channels
- Open an issue in the repository
- Contact repository maintainers
- Review existing GitHub Discussions
- Check Actions community forum

---

## Best Practices

### Workflow Design

#### 1. Use Conditional Steps
Avoid running unnecessary steps:
```yaml
- name: Expensive Operation
  if: github.event_name == 'push' && github.ref == 'refs/heads/master'
  run: ...
```

#### 2. Implement Idempotency
Ensure workflows can run multiple times safely:
- Use `--skip-duplicate` for NuGet pushes
- Check for existing releases before creating
- Use `--clobber` flag for asset uploads

#### 3. Add Error Handling
Gracefully handle expected failures:
```yaml
- name: Optional Step
  continue-on-error: true
  run: ...
```

#### 4. Cache Dependencies
Speed up builds with caching:
```yaml
- uses: actions/cache@v4
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
```

#### 5. Use Concurrency Control
Prevent resource waste:
```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Security

#### 1. Protect Secrets
- Never log secrets or API keys
- Use GitHub Secrets, not environment variables
- Rotate credentials regularly
- Use minimum required permissions

#### 2. Limit Workflow Permissions
Set specific permissions:
```yaml
permissions:
  contents: write
  packages: write
```

#### 3. Validate External Input
If using workflow_dispatch with inputs:
```yaml
- name: Validate Input
  run: |
    if ($env:INPUT_VALUE -notmatch '^[a-zA-Z0-9_-]+$') {
      throw "Invalid input format"
    }
```

#### 4. Pin Action Versions
Use specific versions, not floating tags:
```yaml
# Good
- uses: actions/checkout@v5.1.0

# Avoid
- uses: actions/checkout@latest
```

### Performance

#### 1. Minimize Checkout Depth
Use shallow clones when full history isn't needed:
```yaml
- uses: actions/checkout@v5
  with:
    fetch-depth: 1  # Shallow clone (faster)
```

#### 2. Parallel Jobs
Split independent work into parallel jobs:
```yaml
jobs:
  build:
    strategy:
      matrix:
        configuration: [Debug, Release]
```

#### 3. Skip Unchanged Paths
Avoid triggering on irrelevant changes:
```yaml
on:
  push:
    paths-ignore:
      - '**.md'
      - 'docs/**'
```

#### 4. Use Artifacts for Job Communication
Pass build outputs between jobs:
```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build-output
    path: Bin/Release/
```

### Maintenance

#### 1. Regular Updates
- Update action versions quarterly
- Review deprecated actions
- Update .NET SDK versions
- Test workflow changes in non-production first

#### 2. Monitor Workflow Health
- Review failed runs regularly
- Set up notifications for failures
- Track build times for performance regression

#### 3. Document Changes
- Comment complex workflow logic
- Update this documentation when workflows change
- Link to relevant issues/PRs in commit messages

#### 4. Version Control
- Commit workflow changes with descriptive messages
- Use feature branches for workflow development
- Test with `workflow_dispatch` before merging

### Testing

#### 1. Test Before Merging
Use test workflow patterns:
- Create `*-test.yml` versions
- Test with `workflow_dispatch`
- Use non-production secrets for testing

#### 2. Validate Configuration
Before pushing workflow changes:
```bash
# Validate YAML syntax
yamllint .github/workflows/*.yml

# Use GitHub's workflow validator
# (automatic when pushing to repository)
```

#### 3. Incremental Rollout
Roll out changes gradually:
1. Test on feature branch
2. Deploy to test/staging workflow
3. Monitor for issues
4. Promote to production workflow

---

## Appendix

### Workflow File Locations
- `.github/workflows/build.yml`
- `.github/workflows/release.yml`
- `.github/workflows/nightly.yml`
- `.github/workflows/nightly-release-test.yml`

### Related Documentation
- `README.md` - Repository overview and setup instructions
- `Documents/Changelog/Changelog.md` - Release history
- `LICENSE` - License information

### Quick Reference: Workflow Triggers Summary

| Workflow | Trigger Type | Branches | Schedule | Manual |
|----------|-------------|----------|----------|--------|
| Build | PR + Push | All / Protected | - | ❌ |
| Release | Push | master, alpha, canary, V85-LTS | - | ❌ |
| Nightly | Scheduled + Manual | alpha | 00:00 UTC daily | ✅ |
| Nightly Test | Scheduled + Manual | alpha | 00:00 UTC daily | ✅ |

### Quick Reference: Release Channels

| Channel | Branch | Configuration | NuGet Suffix | Tag Format | Discord Color |
|---------|--------|--------------|--------------|------------|---------------|
| Stable | master | Release | - | `v{ver}` | Blue (3447003) |
| LTS | V85-LTS | Release | `.LTS` | `v{ver}-lts` | Orange (15105570) |
| Canary | canary | Canary | - | `v{ver}-canary` | Yellow (16776960) |
| Nightly | alpha | Nightly | - | `v{ver}-nightly` | Purple (10181046) |

### Quick Reference: Required Secrets

| Secret Name | Required By | Purpose | Optional |
|------------|-------------|---------|----------|
| `NUGET_API_KEY` | All release workflows | Publish to NuGet.org | ❌ |
| `GITHUB_TOKEN` | Build, Release workflows | Create GitHub releases | ❌ (auto) |
| `DISCORD_WEBHOOK_MASTER` | Release (master) | Discord notifications | ✅ |
| `DISCORD_WEBHOOK_LTS` | Release (V85-LTS) | Discord notifications | ✅ |
| `DISCORD_WEBHOOK_CANARY` | Release (canary) | Discord notifications | ✅ |
| `DISCORD_WEBHOOK_NIGHTLY` | Nightly, Release (alpha) | Discord notifications | ✅ |