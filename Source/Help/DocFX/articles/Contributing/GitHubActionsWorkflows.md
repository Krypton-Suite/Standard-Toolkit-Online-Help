# Krypton Toolkit - GitHub Actions Workflows Guide

## Table of Contents

- [Overview](#overview)
- [Workflow Architecture](#workflow-architecture)
- [build.yml - Continuous Integration](#buildyml---continuous-integration)
- [release.yml - Manual Releases](#releaseyml---manual-releases)
- [nightly.yml - Automated Nightly Builds](#nightlyyml---automated-nightly-builds)
- [Configuration Guide](#configuration-guide)
- [Discord Notifications](#discord-notifications)
- [Troubleshooting](#troubleshooting)
- [Advanced Topics](#advanced-topics)

---

## Overview

The Krypton Toolkit uses GitHub Actions for automated CI/CD across multiple release channels. The system consists of three specialized workflows that handle continuous integration, manual releases, and automated nightly builds.

### Key Features

✅ **Automated NuGet Publishing** - Push packages to nuget.org automatically  
✅ **Branch-Specific Configurations** - Different builds for different release types  
✅ **Discord Notifications** - Rich embeds announcing new releases  
✅ **Fault-Tolerant Design** - Graceful degradation when secrets missing  
✅ **Smart Notifications** - Only notify when packages actually published  
✅ **Idempotent Operations** - Safe to re-run workflows  

---

## Workflow Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                   GITHUB ACTIONS WORKFLOWS                    │
├───────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ build.yml   │  │ release.yml  │  │ nightly.yml  │          │
│  ├─────────────┤  ├──────────────┤  ├──────────────┤          │
│  │ CI CHECK    │  │   MANUAL     │  │  AUTOMATED   │          │
│  │             │  │  RELEASES    │  │   NIGHTLY    │          │
│  │ • All PRs   │  │              │  │              │          │
│  │ • All Push  │  │ • master     │  │ • Schedule   │          │
│  │             │  │ • V85-LTS    │  │   (00:00 UTC)│          │
│  │ Fast build  │  │ • canary     │  │ • Manual     │          │
│  │ Validation  │  │ • alpha      │  │              │          │
│  │             │  │              │  │ alpha branch │          │
│  └─────────────┘  └──────────────┘  └──────────────┘          │
│        ↓                 ↓                  ↓                 │
│    Verify            Publish           Auto-Publish           │
│                                                               │
└───────────────────────────────────────────────────────────────┘
```

### Workflow Separation Philosophy

| Workflow | Purpose | When to Run | Outputs |
|----------|---------|-------------|---------|
| **build.yml** | Validation | Every PR, every push | Build logs only |
| **release.yml** | Distribution | Manual pushes to release branches | Packages, archives, releases |
| **nightly.yml** | Automation | Daily at midnight | Packages (if version changed) |

---

## build.yml - Continuous Integration

**File**: `.github/workflows/build.yml`

### Purpose

Fast validation that code compiles correctly across all target frameworks. Provides quick feedback for pull requests and commits.

### Triggers

```yaml
on:
  pull_request:
    branches: ['**']  # All PRs
    types: [opened, synchronize, reopened]
  push:
    branches:
      - master
      - alpha
      - canary
      - gold
      - V95
      - V85-LTS
    paths-ignore: ['.git*', '.vscode']
```

**Runs On**: Every PR and every push to listed branches

### What It Does

```yaml
jobs:
  build:
    runs-on: windows-2022
    steps:
      1. Checkout code
      2. Setup .NET SDKs (6, 7, 8, 9, 10)
      3. Setup MSBuild and NuGet
      4. Restore NuGet packages
      5. Build solution
```

**Does NOT**:

- ❌ Create NuGet packages
- ❌ Publish to nuget.org
- ❌ Create releases
- ❌ Send notifications

### SDK Installation

Installs all SDKs to support every branch's target frameworks:

```yaml
- .NET 6 (LTS)  → For V85-LTS (net6.0-windows)
- .NET 7        → For V85-LTS (net7.0-windows)
- .NET 8 (LTS)  → For all branches (net8.0-windows)
- .NET 9 (GA)   → For master/canary/alpha (net9.0-windows)
- .NET 10       → For master/canary/alpha (net10.0-windows)
```

**Why all SDKs?**: Single build job must handle PRs from any branch

### Execution Time

⚡ **~3-5 minutes** (optimized for speed)

### When to Check

- ✅ Before merging PRs (must be green)
- ✅ After pushing to any branch (quick validation)
- ✅ When adding new target frameworks

---

## release.yml - Manual Releases

**File**: `.github/workflows/release.yml`

### Purpose

Creates and publishes releases when code is pushed to specific branches. Each branch gets its own specialized job with appropriate configuration.

### Triggers

```yaml
on:
  push:
    branches:
      - master
      - alpha
      - canary
      - V85-LTS
```

**Only Runs On**: Manual pushes to release branches

### Jobs Overview

Four independent jobs, one per branch:

| Job | Branch | Purpose | Artifacts |
|-----|--------|---------|-----------|
| `release-master` | master | Stable production | Packages + Archives + GitHub Release |
| `release-v85-lts` | V85-LTS | Long-term support | LTS Packages |
| `release-canary` | canary | Pre-release testing | Canary Packages |
| `release-alpha` | alpha | Manual alpha | Alpha Packages |

---

### Job: `release-master`

**Stable production releases**

#### Configuration

- **Build Script**: `Scripts/build.proj`
- **Configuration**: `Release`
- **Target Frameworks**: net472, net48, net481, net8.0, net9.0, net10.0
- **Output**: `Bin/Packages/Release/`

#### Steps

1. **Setup Environment**

   ```yaml
   - Setup .NET 9, 10
   - Force .NET 10 SDK via global.json
   - Setup MSBuild, NuGet
   - Cache NuGet packages
   ```

2. **Build and Package**

   ```yaml
   - Restore solution
   - Build (Scripts/build.proj)
   - Pack (creates lite + full packages)
   ```

3. **Publish to NuGet** ⭐

   ```yaml
   - Check NUGET_API_KEY present
   - Find all .nupkg files
   - Push each with --skip-duplicate
   - Track if any packages published (new vs skipped)
   - Set packages_published output
   ```

4. **Create Archives**

   ```yaml
   - CreateAllReleaseArchives
   - Generates ZIP and TAR.GZ
   - Output: Bin/Release/Zips/
   ```

5. **Version Detection** ⭐

   ```yaml
   - Read from Bin/Release/net48/Krypton.Toolkit.dll
   - Fallback to csproj XML parsing
   - Fallback to hardcoded version
   - Set version and tag outputs
   ```

6. **Diagnostics**

   ```yaml
   - List all package files
   - List all archive files
   - Verify GITHUB_TOKEN present
   - Verify NUGET_API_KEY present
   ```

7. **Create/Update GitHub Release** ⭐

   ```yaml
   - Check if release v{version} exists
   - If exists: gh release edit
   - If new: gh release create --latest
   ```

8. **Upload Assets**

   ```yaml
   - Upload ZIP to release (with error handling)
   - Upload TAR.GZ to release (with error handling)
   ```

9. **Discord Notification** (conditional) ⭐

   ```yaml
   - Only if packages_published == True
   - Check DISCORD_WEBHOOK_MASTER present
   - Send rich embed with version, packages, links
   ```

#### Unique Features

- ✅ Only job that creates GitHub releases
- ✅ Creates both lite (5 TFMs) and full (6 TFMs) packages
- ✅ Includes downloadable archives (ZIP, TAR.GZ)
- ✅ Diagnostics step for troubleshooting
- ✅ Idempotent release creation

#### Execution Time

🕐 **~12-15 minutes**

---

### Job: `release-v85-lts`

**Long-Term Support releases**

#### Configuration

- **Build Script**: `Scripts/longtermstable.proj`
- **Configuration**: `Release`
- **Target Frameworks**: net462, net47, net471, net472, net48, net481, net6.0, net7.0, net8.0
- **Output**: `Bin/Packages/Release/`
- **Package Names**: `Krypton.*.LTS` (separate IDs)

#### SDKs Required

```yaml
- .NET 6 (LTS)  → net6.0-windows
- .NET 7        → net7.0-windows
- .NET 8 (LTS)  → net8.0-windows + .NET Framework targets
```

**No .NET 9 or 10** - LTS focuses on stability

#### Steps

1. Setup .NET 6, 7, 8
2. Restore → Build → Pack
3. Push LTS packages to NuGet (fault-tolerant)
4. Get Version from assembly
5. Discord notification (if packages published)

#### Unique Features

- ✅ Broadest framework support (9 target frameworks)
- ✅ Separate package identities (*.LTS suffix)
- ✅ Legacy framework support (net462 - 2015 vintage)
- ✅ Stable SDK versions only (no previews)

#### Execution Time

🕐 **~15-18 minutes** (more target frameworks)

---

### Job: `release-canary`

**Pre-release feature testing**

#### Configuration

- **Build Script**: `Scripts/canary.proj`
- **Configuration**: `Canary`
- **Target Frameworks**: net472, net48, net481, net8.0, net9.0, net10.0
- **Output**: `Bin/Packages/Canary/`

#### Steps

1. Setup .NET 9, 10
2. Restore → Build → Pack
3. Push canary packages to NuGet
4. Get Version
5. Discord notification (if packages published)

#### Unique Features

- ✅ Pre-release versioning
- ✅ Yellow Discord embeds (warning color)
- ✅ For early adopters and beta testers

#### Execution Time

🕐 **~10-12 minutes**

---

### Job: `release-alpha`

**Manual alpha/nightly releases**

#### Configuration

- **Build Script**: `Scripts/nightly.proj`
- **Configuration**: `Nightly`
- **Target Frameworks**: net472, net48, net481, net8.0, net9.0, net10.0
- **Output**: `Bin/Packages/Nightly/`

#### Steps

1. Setup .NET 9, 10
2. Restore → Build → Pack
3. Push nightly packages to NuGet
4. Get Version
5. Discord notification (if packages published)

#### Unique Features

- ✅ Manual trigger only (scheduled runs use `nightly.yml`)
- ✅ Purple Discord embeds
- ✅ For developers and bleeding-edge testing

#### Execution Time

🕐 **~10-12 minutes**

---

## nightly.yml - Automated Nightly Builds

**File**: `.github/workflows/nightly.yml`

### Purpose

Automatically build and publish nightly packages from the alpha branch every day at midnight UTC.

### Triggers

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Midnight UTC daily
  workflow_dispatch:      # Manual trigger for testing
```

**Scheduled**: Runs every night at 00:00 UTC  
**Manual**: Can be triggered from GitHub Actions UI

### Important: Branch Behavior

```yaml
steps:
  - name: Checkout
    uses: actions/checkout@v5
    with:
      ref: alpha  # ALWAYS builds alpha branch
```

**Key Point**:

- Workflow file lives on `master` (default branch)
- Always checks out and builds `alpha` branch
- This is how scheduled workflows work in GitHub Actions

### Steps

1. **Checkout** alpha branch (explicitly)
2. **Setup** .NET 9 + 10 SDKs
3. **Restore** NuGet packages
4. **Build** using `Scripts/nightly.proj`
5. **Pack** NuGet packages
6. **Push** to nuget.org (with smart detection)
7. **Get Version** from compiled assembly
8. **Notify Discord** (only if new packages published)

### Smart Notification Logic

```powershell
# During push, track if packages are new or skipped
foreach ($package in $packages) {
  $output = dotnet nuget push "$package" --skip-duplicate 2>&1
  
  # Detect if actually pushed or skipped
  if ($output -notmatch "already exists" -and $output -notmatch "was not pushed") {
    $publishedAny = $true  # New package!
  }
}

# Output for conditional step
echo "packages_published=$publishedAny" >> $env:GITHUB_OUTPUT
```

**Discord step**:

```yaml
- name: Announce Nightly Release on Discord
  if: steps.push_nuget.outputs.packages_published == 'True'  # Only if new
```

### Behavior Scenarios

| Scenario | Build | Package | Push | Discord |
|----------|-------|---------|------|---------|
| **Code changed, version bumped** | ✅ | ✅ | ✅ New | ✅ Sent |
| **No code change, same version** | ✅ | ✅ | ⏭️ Skipped | ❌ Not sent |
| **No API key configured** | ✅ | ✅ | ⏭️ Skipped | ❌ Not sent |
| **Partial changes (some packages new)** | ✅ | ✅ | ⚠️ Mixed | ✅ Sent |

**Benefit**: No Discord spam from nightly builds when version hasn't changed!

### Execution Time

🕐 **~10-12 minutes**

### Testing Nightly Workflow

**Manual Trigger**:

1. GitHub → Actions → "Nightly Release"
2. Click "Run workflow"
3. Select branch: `master` (it will build alpha)
4. Click "Run workflow"

**Check Results**:

- View logs for build success
- Check nuget.org for new packages
- Check Discord for notification (if packages published)

---

## Configuration Guide

### Required GitHub Secrets

#### 1. NUGET_API_KEY (Required)

**Purpose**: Authenticate with nuget.org to publish packages

**Setup Steps**:

1. **Get API Key from nuget.org**:
   - Login to [nuget.org](https://www.nuget.org)
   - Click username → API Keys
   - Click "Create"
   - Configure:
     - **Key Name**: "GitHub Actions - Krypton Toolkit"
     - **Select Scopes**: ✅ Push, ✅ Push new packages and package versions
     - **Select Packages**: All packages (or glob pattern `Krypton.*`)
     - **Expiration**: 365 days
   - Click "Create"
   - **Copy the key** (shown only once!)

2. **Add to GitHub**:
   - Repository → Settings
   - Secrets and variables → Actions
   - New repository secret
   - **Name**: `NUGET_API_KEY` (exact spelling)
   - **Secret**: Paste the API key
   - Click "Add secret"

**Used By**: All release workflows

**What Happens Without It**:

- Workflows succeed but skip NuGet push
- Warning logged: "NUGET_API_KEY not set - skipping NuGet push"
- No packages published
- No Discord notifications sent

---

#### 2. Discord Webhooks (Optional)

**Purpose**: Send rich notifications to Discord when releases are published

**Four Separate Webhooks** (one per release type):

| Secret Name | Branch | Channel Suggestion | Color |
|-------------|--------|--------------------|-------|
| `DISCORD_WEBHOOK_MASTER` | master | `#releases` or `#announcements` | Blue |
| `DISCORD_WEBHOOK_LTS` | V85-LTS | `#lts-releases` or `#releases` | Orange |
| `DISCORD_WEBHOOK_CANARY` | canary | `#canary-builds` or `#pre-releases` | Yellow |
| `DISCORD_WEBHOOK_NIGHTLY` | alpha | `#nightly-builds` or `#dev-releases` | Purple |

**Setup Steps** (repeat for each webhook):

1. **Create Webhook in Discord**:
   - Open Discord server
   - Server Settings → Integrations → Webhooks
   - Click "New Webhook"
   - Configure:
     - **Name**: "Krypton [Type] Releases" (e.g., "Krypton Stable Releases")
     - **Channel**: Select target channel (#releases, #nightly-builds, etc.)
     - **Avatar**: (optional) Upload Krypton logo
   - Click "Copy Webhook URL"

2. **Add to GitHub**:
   - Repository → Settings → Secrets and variables → Actions
   - New repository secret
   - **Name**: Use exact name from table above
   - **Secret**: Paste webhook URL (complete URL, no modifications)
   - Click "Add secret"

**Webhook URL Format**:

```html
https://discord.com/api/webhooks/{id}/{token}
```

or

```html
https://discordapp.com/api/webhooks/{id}/{token}
```

**DO NOT** add `/discord` or any suffix - use the URL exactly as provided!

**What Happens Without Webhooks**:

- Workflows succeed normally
- Warning logged: "[Webhook name] not set - skipping Discord notification"
- No notifications sent
- Packages still published to NuGet

---

## Discord Notifications

### Notification Content

All Discord notifications use rich embeds with this structure:

```
┌────────────────────────────────────────────────────┐
│ 🎉 Krypton Toolkit Stable Release                  | 
│ A new stable release is now available!             │
├────────────────────────────────────────────────────┤
│ 📌 Version                                         │
│ 100.25.1.1                                         │
│                                                    │
│ 📦 NuGet Packages                                  │
│ - Krypton.Toolkit                                  │
│ - Krypton.Ribbon                                   │
│ - Krypton.Navigator                                │
│ - Krypton.Workspace                                │
│ - Krypton.Docking                                  │
│                                                    │
│ 🎯 Target Frameworks                               │
│ • .NET Framework 4.7.2                             │
│ • .NET Framework 4.8                               │
│ • .NET Framework 4.8.1                             │
│ • .NET 8.0                                         │
│ • .NET 9.0                                         │
│ • .NET 10.0                                        │
│                                                    │
│ 🔗 NuGet Packages                                  │
│ • Toolkit  • Ribbon  • Navigator                   │
│ • Workspace  • Docking                             │
│ (each is a clickable link)                         │
│                                                    │
│ 📥 GitHub Release                                  │
│ Download Archives                                  │
│                                                    │
│ Released • Today at 12:24 PM                       │
└────────────────────────────────────────────────────┘
```

### Release Type Styling

Each release type has distinct visual styling:

#### Master (Stable)

- **Title**: 🎉 Krypton Toolkit Stable Release
- **Description**: A new stable release is now available!
- **Color**: Blue (#3498DB)
- **Extra Field**: 📥 GitHub Release (download archives)

#### V85-LTS (Long-Term Support)

- **Title**: 🛡️ Krypton Toolkit LTS Release
- **Description**: A new Long-Term Support release is now available!
- **Color**: Orange (#E67E22)
- **Packages**: Krypton.*.LTS
- **Frameworks**: 9 targets (most comprehensive)

#### Canary (Pre-Release)

- **Title**: 🐤 Krypton Toolkit Canary Release
- **Description**: A new canary pre-release is now available for early testing!
- **Color**: Yellow (#FFFF00)

#### Nightly (Alpha)

- **Title**: 🚀 Krypton Toolkit Nightly Release
- **Description**: A new nightly build is now available for bleeding-edge testing!
- **Color**: Purple (#9B59B6)

### Conditional Sending

Notifications are sent **only when**:

```yaml
if: steps.push_nuget.outputs.packages_published == 'True'
```

**Sent**:

- ✅ At least one package was newly published to NuGet
- ✅ Webhook is configured

**NOT Sent**:

- ❌ All packages already exist (version unchanged)
- ❌ NuGet push was skipped (no API key)
- ❌ Webhook not configured
- ❌ Push failed for all packages

**Benefit**: Prevents notification spam from:

- Scheduled nightly builds with no code changes
- Re-running workflows
- Testing without secrets

### Testing Discord Notifications

**Method 1: Manual Webhook Test**

```powershell
# PowerShell test script
$webhook = "YOUR_WEBHOOK_URL_HERE"

$payload = @{
  embeds = @(@{
    title = "🧪 Test Notification"
    description = "Testing Krypton Toolkit webhook"
    color = 3447003
    fields = @(
      @{
        name = "Status"
        value = "If you see this, webhook is working!"
        inline = $false
      }
    )
    timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
  })
} | ConvertTo-Json -Depth 10

Invoke-RestMethod -Uri $webhook -Method Post -Body $payload -ContentType "application/json"
```

**Method 2: Trigger Nightly Workflow**

1. Ensure alpha branch has different version than what's on nuget.org
2. GitHub → Actions → Nightly Release → Run workflow
3. Wait for completion
4. Check Discord channel

---

## Troubleshooting

### Issue: Workflow Exits with Code 1

**Symptoms**:

- Build succeeds
- No compilation errors
- Workflow shows red X

**Common Causes & Solutions**:

#### 1. Version Detection Failed

**Log shows**: Empty version or parsing error

**Solution**: Now uses assembly-based detection (most reliable):

```powershell
# Reads actual compiled DLL
$dllPath = Get-ChildItem "Bin/Release/net48/Krypton.Toolkit.dll"
$assemblyVersion = [System.Reflection.AssemblyName]::GetAssemblyName($dllPath.FullName).Version
```

**Fallbacks**: csproj XML → hardcoded version

#### 2. GitHub Release Already Exists

**Error**: `release already exists`

**Solution**: Idempotent create-or-update logic:

```powershell
gh release view $tag 2>&1 | Out-Null
if ($LASTEXITCODE -eq 0) {
  gh release edit $tag ...  # Update existing
} else {
  gh release create $tag ... # Create new
}
```

#### 3. Missing API Key

**Error**: `401 Unauthorized` from nuget.org

**Solution**: Check before pushing:

```powershell
if (-not $env:NUGET_API_KEY) {
  Write-Warning "NUGET_API_KEY not set - skipping"
  exit 0  # Success exit, not failure
}
```

#### 4. Missing Webhook

**Error**: HTTP error from Discord

**Solution**: Check before posting:

```powershell
if (-not $env:DISCORD_WEBHOOK_NIGHTLY) {
  Write-Warning "Webhook not set - skipping"
  exit 0
}
```

---

### Issue: Discord Shows Empty Version

**Symptoms**:

```
📌 Version
``
```

**Cause**: `Get Version` step missing or failed

**Solution**:

1. Ensure `Get Version` step has `id: get_version`
2. Check assembly was built (DLL exists)
3. Verify path matches configuration:
   - Master: `Bin/Release/net48/`
   - Canary: `Bin/Canary/net48/`
   - Nightly: `Bin/Nightly/net48/`

**Check logs for**:

```
Got version from assembly: 100.25.1.1
Final determined version: 100.25.1.1
```

---

### Issue: No Discord Notification

**Checklist**:

1. **Was notification sent?**
   - Check workflow logs for "Announce ... on Discord" step
   - Look for "skipped" indicator in GitHub UI

2. **Check condition**:

   ```
   if: steps.push_nuget.outputs.packages_published == 'True'
   ```

   - Log shows: `packages_published=false` → Notification skipped (expected)
   - Log shows: `packages_published=True` → Should have sent

3. **Check webhook**:
   - Log shows: "Webhook not set" → Add secret to GitHub
   - No warning → Webhook present

4. **Verify in Discord**:
   - Check correct channel
   - Webhook still exists in Server Settings?
   - Bot has permission to post?

5. **Test webhook manually** (see Testing section above)

---

### Issue: Scheduled Workflow Doesn't Run

**Symptoms**:

- Manual trigger works
- Midnight UTC passes with no run

**Causes**:

#### 1. Workflow Not on Default Branch

**GitHub Rule**: Scheduled workflows only run from the default branch

**Solution**:

- Ensure `nightly.yml` is merged to `master` (default branch)
- Check Settings → General → Default branch

**Verification**:

```cmd
git checkout master
git pull origin master
ls .github/workflows/nightly.yml  # Should exist
```

#### 2. Workflows Disabled

**Check**: Settings → Actions → General
**Enable**: "Allow all actions and reusable workflows"

#### 3. Incorrect Cron Syntax

**Test cron**: Use [crontab.guru](https://crontab.guru/)

**Examples**:

```yaml
'0 0 * * *'      # Midnight UTC daily ✅
'0 0 * * 1-5'    # Weekdays only ✅
'0 */6 * * *'    # Every 6 hours ✅
'0 0 * * 0'      # Sundays only ✅
```

#### 4. No Recent Activity

**GitHub Behavior**: Workflows may be disabled if repository has no activity for 60 days

**Solution**: Make any commit to re-enable

---

### Issue: Packages Skipped (Already Exist)

**Log shows**:

```
Package Krypton.Toolkit.100.25.1.1.nupkg already exists - skipped
```

**This is EXPECTED if**:

- ✅ Version wasn't bumped
- ✅ Re-running workflow
- ✅ Same version already on nuget.org

**To publish new packages**:

1. Bump version in `Directory.Build.props`
2. Commit and push
3. Workflow will publish new version

**Note**: `--skip-duplicate` flag prevents errors, workflow continues successfully

---

## Advanced Topics

### Customizing Nightly Schedule

**Current**: `'0 0 * * *'` (midnight UTC daily)

**Change to different time**:

```yaml
on:
  schedule:
    - cron: '0 2 * * *'  # 2 AM UTC
```

**Weekdays only**:

```yaml
- cron: '0 0 * * 1-5'  # Mon-Fri at midnight
```

**Twice daily**:

```yaml
- cron: '0 0,12 * * *'  # Midnight and noon
```

**Weekly**:

```yaml
- cron: '0 0 * * 0'  # Sundays at midnight
```

**Test syntax**: <https://crontab.guru/>

---

### Manual Workflow Trigger

All workflows support manual triggering for testing.

**Add to any workflow**:

```yaml
on:
  push:
    branches: [master]
  workflow_dispatch:  # Enables manual trigger
```

**Usage**:

1. GitHub → Actions
2. Select workflow
3. "Run workflow" button
4. Select branch
5. Click "Run workflow"

**Current Status**:

- ✅ `nightly.yml` - Has `workflow_dispatch`
- ❌ `release.yml` - Could be added for testing
- ❌ `build.yml` - Could be added for testing

---

### Workflow Artifacts

To save build outputs for download:

```yaml
- name: Upload Packages
  uses: actions/upload-artifact@v4
  with:
    name: nuget-packages
    path: Bin/Packages/Release/*.nupkg
    retention-days: 7
```

**Benefit**: Download packages without pushing to NuGet

**Access**: Actions → Workflow run → Artifacts section

---

### Concurrent Workflow Runs

**Current Behavior**: Multiple workflows can run simultaneously

**To limit concurrency** (prevent simultaneous releases):

```yaml
concurrency:
  group: release-${{ github.ref }}
  cancel-in-progress: false  # Queue instead of cancel
```

**Use case**: Prevent two releases from running at same time

---

### Environment Protection

For additional safety on production releases:

**Setup**:

1. Settings → Environments → New environment
2. Name: `production`
3. Configure:
   - ✅ Required reviewers (select team members)
   - ✅ Wait timer (e.g., 5 minutes)

**Use in workflow**:

```yaml
jobs:
  release-master:
    runs-on: windows-2022
    environment: production  # Requires approval
```

**Benefit**: Manual approval required before publishing to nuget.org

---

### Debugging Workflows

#### Enable Debug Logging

**Repository Settings**:

- Settings → Secrets → New secret
- **Name**: `ACTIONS_STEP_DEBUG`
- **Value**: `true`

**Next run shows**:

- Detailed step-by-step execution
- Variable values
- Command outputs

#### Enable Runner Diagnostic Logging

**Secret**:

- **Name**: `ACTIONS_RUNNER_DEBUG`
- **Value**: `true`

**Shows**: Internal GitHub Actions runner details

#### Add Custom Diagnostics

```yaml
- name: Debug Info
  run: |
    Write-Host "Current directory: $(Get-Location)"
    Write-Host "Environment variables:"
    Get-ChildItem env: | Format-Table -AutoSize
    Write-Host "Files in current directory:"
    Get-ChildItem -Recurse
```

---

### Workflow Monitoring

#### Success/Failure Notifications

**GitHub Marketplace Actions**:

- [action-slack](https://github.com/8398a7/action-slack) - Slack notifications
- [notify-workflow-status](https://github.com/ravsamhq/notify-slack-action) - Multi-platform
- [action-status-discord](https://github.com/sarisia/actions-status-discord) - Discord status

**Example**:

```yaml
- name: Workflow Status
  if: always()
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK_STATUS }}
    status: ${{ job.status }}
```

#### Workflow Run Analytics

**View in GitHub**:

- Insights → Actions
- See:
  - Success/failure rates
  - Execution times
  - Billable minutes
  - Workflow trends

---

### Security Best Practices

#### Secret Rotation

**NuGet API Key** (annually):

1. Create new API key on nuget.org
2. Update GitHub secret
3. Delete old API key on nuget.org
4. Test with manual workflow trigger

**Discord Webhooks** (as needed):

- Regenerate in Discord if compromised
- Update GitHub secret
- Old URL stops working immediately

#### Least Privilege

**NuGet API Key Scoping**:

- ✅ Push scope only (not delete/unlist)
- ✅ Specific to Krypton.* packages
- ✅ Limited expiration (365 days max)

**GitHub Token**:

- ✅ Auto-generated per workflow run
- ✅ Scoped to repository only
- ✅ Expires after job completes

#### Branch Protection

**Recommended for**: master, V85-LTS, canary, alpha

**Settings** → Branches → Add rule:

- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass (build.yml)
- ✅ Require branches to be up to date before merging
- ✅ Include administrators
- ✅ Require linear history

**Benefit**: Prevents accidental direct pushes that trigger releases

---

## Workflow Maintenance

### Updating .NET SDK Versions

When new .NET version releases (e.g., .NET 11):

1. **Update workflow SDK steps**:

   ```yaml
   - name: Setup .NET 11 (preview)
     uses: actions/setup-dotnet@v4
     with:
       dotnet-version: 11.0.x
       dotnet-quality: preview
   ```

2. **Update global.json generation**:

   ```powershell
   $sdkVersion = (dotnet --list-sdks | Select-String "11.0").ToString().Split(" ")[0]
   ```

3. **Update target frameworks** in `.csproj` files (see Build System docs)

4. **Update Discord notifications**:

   ```powershell
   value = "• .NET Framework 4.7.2`n...`n• .NET 11.0"
   ```

5. **Test on feature branch** before merging

### Workflow Performance Optimization

#### Cache Optimization

**Current**: Caches `~/.nuget/packages`

**Advanced**: Also cache MSBuild output

```yaml
- name: Cache Build
  uses: actions/cache@v4
  with:
    path: |
      **/bin
      **/obj
    key: build-${{ hashFiles('**/*.cs') }}
```

**Trade-off**: Faster builds vs. cache storage usage

#### Conditional Steps

Skip expensive steps when not needed:

```yaml
- name: Create Archives
  if: github.ref == 'refs/heads/master'  # Only on master
  run: ...
```

#### Matrix Strategy

Build multiple configurations in parallel:

```yaml
strategy:
  matrix:
    configuration: [Release, Debug]
    framework: [net48, net10.0-windows]
```

**Note**: Current workflows don't use matrix (sequential is clearer for releases)

---

## Workflow Testing Checklist

Before merging workflow changes:

### Pre-Merge

- [ ] Workflow syntax valid (GitHub validates on commit)
- [ ] Tested on feature branch with `workflow_dispatch`
- [ ] All secrets referenced are documented
- [ ] Error handling present for external calls
- [ ] Logging sufficient for debugging
- [ ] No secrets in logs or echo statements

### Post-Merge

- [ ] Build workflow passes on next PR
- [ ] Release workflow tested on each branch
- [ ] NuGet packages published successfully
- [ ] Discord notifications received
- [ ] GitHub releases created (master)
- [ ] Archives uploadable

### Nightly-Specific

- [ ] Manual trigger works
- [ ] Checks out alpha branch correctly
- [ ] Handles unchanged version (no spam)
- [ ] Midnight UTC schedule working (check next day)

---

## Quick Reference

### Workflow Triggers Summary

| Workflow | Automatic Triggers | Manual Trigger |
|----------|-------------------|----------------|
| build.yml | PR, Push to any release branch | ❌ |
| release.yml | Push to master/V85-LTS/canary/alpha | ❌ |
| nightly.yml | Daily at 00:00 UTC | ✅ workflow_dispatch |

### Secret Names Reference

| Secret | Type | Required | Used By |
|--------|------|----------|---------|
| `NUGET_API_KEY` | NuGet API Key | Yes (for publishing) | All release workflows |
| `DISCORD_WEBHOOK_MASTER` | Discord URL | No | release.yml (master) |
| `DISCORD_WEBHOOK_LTS` | Discord URL | No | release.yml (V85-LTS) |
| `DISCORD_WEBHOOK_CANARY` | Discord URL | No | release.yml (canary) |
| `DISCORD_WEBHOOK_NIGHTLY` | Discord URL | No | release.yml (alpha), nightly.yml |

### Workflow File Locations

```
.github/
└── workflows/
    ├── build.yml      (194 lines)
    ├── release.yml    (866 lines)
    └── nightly.yml    (208 lines)
```

### Common Commands

**View workflow runs**:

```
GitHub → Actions tab
```

**Manually trigger nightly**:

```
Actions → Nightly Release → Run workflow
```

**Check workflow status from CLI**:

```cmd
gh run list --workflow=release.yml
gh run view [run-id]
gh run watch [run-id]
```

---

## Document Information

**Document**: GitHub Actions Workflows Guide
**Companion Document**: [Build System Guide](BuildSystem.md)  

### Related Documentation

- [Build System Guide](BuildSystem.md) - MSBuild scripts and project configuration

---

## Next Steps

✅ **Read Next**: [Build System Guide](BuildSystem.md) for MSBuild scripts and project structure  
✅ **Setup**: Configure GitHub Secrets (NUGET_API_KEY and Discord webhooks)  
✅ **Test**: Manually trigger nightly workflow to verify configuration  
✅ **Monitor**: Watch first automated nightly build at midnight UTC  
