# Nightly Release Workflow Documentation

**Workflow File**: `.github/workflows/nightly.yml`  
**Version**: 1.0  

---

## Table of Contents
1. [Overview](#overview)
2. [Purpose](#purpose)
3. [Triggers](#triggers)
4. [Change Detection](#change-detection)
5. [Workflow Steps](#workflow-steps)
6. [Configuration](#configuration)
7. [Usage Examples](#usage-examples)
8. [Troubleshooting](#troubleshooting)
9. [Best Practices](#best-practices)

---

## Overview

The Nightly Release workflow provides automated daily builds from the alpha branch with intelligent change detection. It runs every night at midnight UTC, but only publishes packages when actual code changes have been committed in the last 24 hours.

### Key Features
- ⏰ **Scheduled Execution**: Runs automatically at 00:00 UTC daily
- 🔍 **Change Detection**: Checks for commits before building
- 💰 **Resource Efficient**: Skips build when no changes detected
- 📦 **NuGet Publishing**: Automatically publishes to nuget.org
- 💬 **Discord Integration**: Notifies channel on successful release
- 🔧 **Manual Triggering**: Can be run manually for testing

### Workflow Decision Tree

```
┌─────────────────────┐
│ Cron Trigger        │
│ 00:00 UTC Daily     │
└──────────┬──────────┘
           │
     ┌─────▼─────┐
     │ Checkout  │
     │ with full │
     │ history   │
     └─────┬─────┘
           │
     ┌─────▼─────────────────┐
     │ Check for commits     │
     │ in last 24 hours      │
     └─────┬─────────────────┘
           │
    ┌──────┴────────┐
    │               │
Changes?         No Changes?
    │               │
    ▼               ▼
┌───────────┐  ┌──────────────┐
│ Proceed   │  │ Skip Notice  │
│ with      │  │ All steps    │
│ Build     │  │ skipped      │
└─────┬─────┘  └──────┬───────┘
      │                │
      ▼                │
┌───────────┐          │
│ Setup .NET│          │
│ Build     │          │
│ Pack      │          │
│ Push      │          │
│ Notify    │          │
└─────┬─────┘          │
      │                │
      └────────┬───────┘
               │
         ┌─────▼──────┐
         │ Workflow   │
         │ Complete   │
         └────────────┘
```

---

## Purpose

### Primary Goals

#### 1. Automated Nightly Builds
Provides bleeding-edge builds for developers and early testers without manual intervention.

**Benefits**:
- Always-available latest code
- Regular testing of integration
- Catch issues early
- Enable rapid iteration

#### 2. Resource Optimization
Prevents unnecessary builds and package versions when no code has changed.

**Benefits**:
- Reduces GitHub Actions minutes usage
- Avoids cluttering NuGet with duplicate versions
- Minimizes disk space consumption
- Faster workflow execution when no changes

#### 3. Continuous Integration
Validates that the alpha branch stays in a buildable state.

**Benefits**:
- Early detection of build breaks
- Immediate feedback on breaking changes
- Encourages frequent commits
- Maintains code quality

#### 4. Distribution Channel
Makes nightly builds easily accessible via NuGet.

**Benefits**:
- Simple installation via NuGet Package Manager
- Automated dependency resolution
- Multi-framework support
- Version tracking

---

## Triggers

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Midnight UTC daily
  workflow_dispatch:      # Manual triggering
```

### Scheduled Trigger

**Schedule**: `0 0 * * *` (Midnight UTC every day)

**Cron Syntax Breakdown**:
- `0` - Minute (00)
- `0` - Hour (00 UTC)
- `*` - Day of month (every day)
- `*` - Month (every month)
- `*` - Day of week (every day)

**Timezone**: UTC (Coordinated Universal Time)

**Equivalent Times** (Examples):
- UTC: 00:00 (midnight)
- EST: 19:00 (7 PM previous day)
- PST: 16:00 (4 PM previous day)
- CET: 01:00 (1 AM)
- JST: 09:00 (9 AM)

**Execution Notes**:
- May be delayed by a few minutes during high load
- Runs on GitHub-hosted infrastructure
- Requires workflow file on default branch or the branch being monitored

### Manual Trigger (workflow_dispatch)

**Purpose**: Allows manual execution for testing or on-demand builds

**How to Trigger**:
1. Navigate to repository on GitHub
2. Click "Actions" tab
3. Select "Nightly Release" workflow
4. Click "Run workflow" button
5. Select branch (typically alpha)
6. Click "Run workflow"

**Use Cases**:
- Testing workflow changes
- Creating build after critical hotfix
- Verifying workflow functionality
- Forcing build regardless of change detection

**Note**: Manual triggers always run all steps (change detection still occurs but can be ignored)

---

## Change Detection

### Rationale

Without change detection, the workflow would:
- Create duplicate NuGet package versions
- Consume GitHub Actions minutes unnecessarily
- Generate redundant build logs
- Clutter workflow run history

With change detection:
- Only publishes when code actually changes
- Saves ~70% of workflow runs (typical)
- Keeps NuGet versions meaningful
- Reduces infrastructure cost

### Implementation

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

### How It Works

#### Step 1: Calculate 24-Hour Window
```powershell
$yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
```

**Example**:
- Current time: `2025-10-28 00:00:00 UTC`
- Yesterday: `2025-10-27 00:00:00 UTC`
- Window: All commits between these times

#### Step 2: Query Git History
```powershell
$commitCount = git rev-list --count --since="$yesterday" alpha
```

**Git Command Breakdown**:
- `git rev-list`: List commit objects
- `--count`: Return count instead of commit hashes
- `--since="$yesterday"`: Only commits after specified date
- `alpha`: Branch to check

**Output**: Number of commits (integer)

#### Step 3: Set Output Variable
```powershell
if ([int]$commitCount -gt 0) {
    echo "has_changes=true" >> $env:GITHUB_OUTPUT
} else {
    echo "has_changes=false" >> $env:GITHUB_OUTPUT
}
```

**Result**: `has_changes` variable set to `true` or `false`

### Requirements

#### Full Git History Required
```yaml
- name: Checkout
  uses: actions/checkout@v5
  with:
    ref: alpha
    fetch-depth: 0  # ← Critical!
```

**Why `fetch-depth: 0`?**
- Default is shallow clone (only latest commit)
- Shallow clone lacks history for date-based queries
- `fetch-depth: 0` fetches complete history
- Enables accurate commit counting

**Performance Impact**:
- Adds ~5-10 seconds to checkout
- Increases network transfer slightly
- Negligible compared to full build time

### Edge Cases

#### Case 1: Workflow Runs at 00:05 UTC (5 minutes late)
**Behavior**: Checks commits from 23:55 previous day to 00:05 current day
**Result**: May miss commits from 00:00-00:05, but they'll be caught next day

#### Case 2: Multiple Commits in 24 Hours
**Behavior**: Counts all commits, builds once
**Result**: Single build with all changes

#### Case 3: Only Documentation Changes
**Behavior**: Counts as change, triggers build
**Consideration**: Could add path filtering if needed

#### Case 4: Workflow Disabled for >24 Hours
**Behavior**: Checks last 24 hours from current time
**Result**: May skip intermediate changes if re-enabled

---

## Workflow Steps

### Job: nightly

**Runner**: `windows-2025`

**No Branch Restrictions**: Runs on the branch containing the workflow file (typically alpha)

### Step-by-Step Breakdown

#### 1. Checkout with Full History
```yaml
- name: Checkout
  uses: actions/checkout@v5
  with:
    ref: alpha
    fetch-depth: 0
```

**Purpose**: Clone repository with complete git history

**Configuration**:
- `ref: alpha`: Explicitly checkout alpha branch
- `fetch-depth: 0`: Fetch all history (required for change detection)

#### 2. Check for Changes in Last 24 Hours
```yaml
- name: Check for changes in last 24 hours
  id: check_changes
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    
    # Get commits from last 24 hours on alpha branch
    $yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
    $commitCount = git rev-list --count --since="$yesterday" alpha
    
    Write-Host "Commits in last 24 hours: $commitCount"
    
    if ([int]$commitCount -gt 0) {
      Write-Host "Changes detected - proceeding with nightly build"
      echo "has_changes=true" >> $env:GITHUB_OUTPUT
    } else {
      Write-Host "No changes detected - skipping nightly build"
      echo "has_changes=false" >> $env:GITHUB_OUTPUT
    }
```

**Purpose**: Determine if build should proceed

**Output**: `has_changes` (true/false)

**Logging**:
- Displays commit count
- Shows decision reasoning
- Helps with debugging

#### 3. Skip Notification
```yaml
- name: Skip notification
  if: steps.check_changes.outputs.has_changes == 'false'
  run: |
    Write-Host "::notice::No commits in the last 24 hours. Skipping nightly build and publish."
```

**Purpose**: Display workflow notice when skipping

**Condition**: Only runs if `has_changes=false`

**Notice Format**: Uses GitHub Actions annotation syntax (`::notice::`)

**Result**: Yellow notice box in workflow summary

#### 4-7. Setup .NET SDKs (Conditional)
```yaml
- name: Setup .NET 9
  if: steps.check_changes.outputs.has_changes == 'true'
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 9.0.x

- name: Setup .NET 10
  if: steps.check_changes.outputs.has_changes == 'true'
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 10.0.x
  continue-on-error: true

- name: Setup .NET 11
  if: steps.check_changes.outputs.has_changes == 'true'
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 11.0.x
  continue-on-error: true
```

**Purpose**: Install .NET SDKs for multi-targeting

**Condition**: Only runs if changes detected

**SDK Strategy**:
- .NET 9: Required (fails if unavailable)
- .NET 10: Optional (continues on error)
- .NET 11: Optional (continues on error)

#### 8. Force .NET 10 SDK via global.json (Conditional)
```yaml
- name: Force .NET 10 SDK via global.json
  if: steps.check_changes.outputs.has_changes == 'true'
  run: |
    $sdkVersion = (dotnet --list-sdks | Select-String "10.0").ToString().Split(" ")[0]
    if (-not $sdkVersion) {
      # Fallback to .NET 8 if .NET 10 is not available
      $sdkVersion = (dotnet --list-sdks | Select-String "8.0").ToString().Split(" ")[0]
    }
    Write-Output "Using SDK $sdkVersion"
    @"
    {
      "sdk": {
        "version": "$sdkVersion",
        "rollForward": "latestFeature"
      }
    }
    "@ | Out-File -Encoding utf8 global.json
```

**Purpose**: Select appropriate SDK for build

**Fallback Logic**: .NET 10 → .NET 8

**Condition**: Only runs if changes detected

#### 9-11. Setup MSBuild, NuGet, Cache (Conditional)
Standard build tooling setup (see Build Workflow documentation)

**Condition**: Only runs if changes detected

#### 12. Restore (Conditional)
```yaml
- name: Restore
  if: steps.check_changes.outputs.has_changes == 'true'
  run: dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
```

**Purpose**: Download NuGet packages

**Condition**: Only runs if changes detected

#### 13. Build Nightly (Conditional)
```yaml
- name: Build Nightly
  if: steps.check_changes.outputs.has_changes == 'true'
  run: msbuild "Scripts/nightly.proj" /t:Build /p:Configuration=Nightly /p:Platform="Any CPU"
```

**Purpose**: Compile projects in Nightly configuration

**Build Script**: `Scripts/nightly.proj`

**Configuration**: `Nightly`
- Less aggressive optimization
- More debugging information
- Suitable for development testing

**Output**: `Bin/Nightly/{framework}/`

**Condition**: Only runs if changes detected

#### 14. Pack Nightly (Conditional)
```yaml
- name: Pack Nightly
  if: steps.check_changes.outputs.has_changes == 'true'
  run: msbuild "Scripts/nightly.proj" /t:Pack /p:Configuration=Nightly /p:Platform="Any CPU"
```

**Purpose**: Create NuGet packages

**Output**: `Bin/Packages/Nightly/*.nupkg`

**Packages**:
- Krypton.Toolkit.{version}.nupkg
- Krypton.Ribbon.{version}.nupkg
- Krypton.Navigator.{version}.nupkg
- Krypton.Workspace.{version}.nupkg
- Krypton.Docking.{version}.nupkg

**Condition**: Only runs if changes detected

#### 15. Push NuGet Packages to nuget.org (Conditional)
```yaml
- name: Push NuGet Packages to nuget.org
  if: steps.check_changes.outputs.has_changes == 'true'
  id: push_nuget
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    if (-not $env:NUGET_API_KEY) {
      Write-Warning "NUGET_API_KEY not set - skipping NuGet push"
      echo "packages_published=false" >> $env:GITHUB_OUTPUT
      exit 0
    }
    
    $packages = Get-ChildItem "Bin/Packages/Nightly/*.nupkg" -ErrorAction SilentlyContinue
    $publishedAny = $false
    
    if ($packages) {
      foreach ($package in $packages) {
        Write-Output "Pushing package: $($package.Name)"
        try {
          $output = dotnet nuget push "$($package.FullName)" --api-key $env:NUGET_API_KEY --source https://api.nuget.org/v3/index.json --skip-duplicate 2>&1 | Out-String
          Write-Output $output
          # Check if package was actually pushed (not skipped)
          if ($output -notmatch "already exists" -and $output -notmatch "was not pushed") {
            $publishedAny = $true
            Write-Host "Package $($package.Name) was published"
          } else {
            Write-Host "Package $($package.Name) already exists - skipped"
          }
        } catch {
          Write-Warning "Failed to push $($package.Name): $_"
        }
      }
    } else {
      Write-Output "No NuGet packages found to push"
    }
    
    echo "packages_published=$publishedAny" >> $env:GITHUB_OUTPUT
  env:
    NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

**Purpose**: Publish packages to NuGet.org

**Key Features**:
- Gracefully handles missing API key
- Uses `--skip-duplicate` to avoid errors
- Tracks whether any new packages were published
- Continues on individual package failures

**Output Variable**: `packages_published` (true/false)

**Condition**: Only runs if changes detected

#### 16. Get Version (Conditional)
```yaml
- name: Get Version
  if: steps.check_changes.outputs.has_changes == 'true'
  id: get_version
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    $version = $null
    
    # Try to get version from the built assembly (most reliable)
    try {
      $dllPath = Get-ChildItem "Bin/Nightly/net48/Krypton.Toolkit.dll" -ErrorAction Stop
      $assemblyVersion = [System.Reflection.AssemblyName]::GetAssemblyName($dllPath.FullName).Version
      $version = $assemblyVersion.ToString()
      Write-Host "Got version from assembly: $version"
    } catch {
      Write-Host "Could not read version from assembly: $_"
    }
    
    # Fallback: Try to read from csproj XML
    if (-not $version) {
      try {
        $proj = 'Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj'
        [xml]$projXml = Get-Content $proj
        $versionNode = $projXml.SelectSingleNode("//Version")
        if ($versionNode) {
          $version = $versionNode.InnerText.Trim()
          Write-Host "Got version from csproj: $version"
        }
      } catch {
        Write-Host "Could not read version from csproj: $_"
      }
    }
    
    # Last resort fallback
    if (-not $version) {
      Write-Warning "Version not found, using fallback."
      $version = "100.25.1.1"
    }
    
    Write-Host "Final determined version: $version"
    echo "version=$version" >> $env:GITHUB_OUTPUT
    echo "tag=v$version-nightly" >> $env:GITHUB_OUTPUT
```

**Purpose**: Extract version for Discord notification

**Three-Tier Strategy**:
1. Read from built DLL (most reliable)
2. Parse csproj XML
3. Hardcoded fallback

**Output Variables**:
- `version`: e.g., `100.25.1.1`
- `tag`: e.g., `v100.25.1.1-nightly`

**Condition**: Only runs if changes detected

#### 17. Announce Nightly Release on Discord
```yaml
- name: Announce Nightly Release on Discord
  if: steps.push_nuget.outputs.packages_published == 'True'
  shell: pwsh
  run: |
    if (-not $env:DISCORD_WEBHOOK_NIGHTLY) {
      Write-Warning "DISCORD_WEBHOOK_NIGHTLY not set - skipping Discord notification"
      exit 0
    }
    
    $payload = @{
      embeds = @(
        @{
          title = "🚀 Krypton Toolkit Nightly Release"
          description = "A new nightly build is now available for bleeding-edge testing!"
          color = 10181046
          fields = @(
            @{
              name = "📌 Version"
              value = "``${{ steps.get_version.outputs.version }}``"
              inline = $true
            }
            @{
              name = "📦 NuGet Packages"
              value = "- Krypton.Toolkit`n- Krypton.Ribbon`n- Krypton.Navigator`n- Krypton.Workspace`n- Krypton.Docking"
              inline = $false
            }
            @{
              name = "🎯 Target Frameworks"
              value = "• .NET Framework 4.7.2`n• .NET Framework 4.8`n• .NET Framework 4.8.1`n• .NET 8.0`n• .NET 9.0`n• .NET 10.0"
              inline = $false
            }
            @{
              name = "🔗 NuGet Packages"
              value = "• [Toolkit](https://www.nuget.org/packages/Krypton.Toolkit)`n• [Ribbon](https://www.nuget.org/packages/Krypton.Ribbon)`n• [Navigator](https://www.nuget.org/packages/Krypton.Navigator)`n• [Workspace](https://www.nuget.org/packages/Krypton.Workspace)`n• [Docking](https://www.nuget.org/packages/Krypton.Docking)"
              inline = $false
            }
          )
          footer = @{
            text = "Released"
          }
          timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ss.fffZ")
        }
      )
    } | ConvertTo-Json -Depth 10
    
    Invoke-RestMethod -Uri $env:DISCORD_WEBHOOK_NIGHTLY -Method Post -Body $payload -ContentType "application/json"
  env:
    DISCORD_WEBHOOK_NIGHTLY: ${{ secrets.DISCORD_WEBHOOK_NIGHTLY }}
```

**Purpose**: Send release announcement to Discord

**Condition**: Only runs if `packages_published == 'True'`

**Webhook Design**:
- Purple embed (color: 10181046)
- Nightly-specific branding (🚀 rocket emoji)
- Version number in code block
- Package list with clickable links
- UTC timestamp

**Graceful Handling**: Exits successfully if webhook not configured

---

## Configuration

### Required Secrets

#### NUGET_API_KEY
- **Type**: Secret
- **Required**: Yes
- **Purpose**: Authenticate with NuGet.org for package publishing

**How to Obtain**:
1. Log in to https://nuget.org
2. Go to Account Settings → API Keys
3. Create new API key:
   - **Name**: "GitHub Actions Nightly"
   - **Expiration**: 365 days (or as needed)
   - **Scopes**: Push
   - **Glob Pattern**: `Krypton.*`
4. Copy API key (shown only once)
5. Add to GitHub repository secrets:
   - Go to repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `NUGET_API_KEY`
   - Value: [paste API key]
   - Click "Add secret"

**Security Best Practices**:
- Rotate every 90-180 days
- Use narrowest scope possible
- Monitor NuGet package activity
- Enable 2FA on NuGet account

#### DISCORD_WEBHOOK_NIGHTLY
- **Type**: Secret
- **Required**: No (optional)
- **Purpose**: Post release announcements to Discord channel

**How to Obtain**:
1. Open Discord server (must have Manage Webhooks permission)
2. Go to Server Settings → Integrations → Webhooks
3. Click "New Webhook"
4. Configure webhook:
   - **Name**: "Nightly Releases"
   - **Channel**: Select announcement channel
   - **Avatar**: Optional custom icon
5. Click "Copy Webhook URL"
6. Add to GitHub repository secrets (same process as NUGET_API_KEY)

**Webhook URL Format**: `https://discord.com/api/webhooks/{id}/{token}`

**Security**:
- Don't commit to version control
- Regenerate if compromised
- Monitor Discord for unauthorized posts

### Environment Variables

None required. All configuration through secrets and workflow parameters.

### Build Scripts

**Script File**: `Scripts/nightly.proj`

**Purpose**:
- Nightly/development build configuration
- Multi-framework orchestration
- Package creation

**Targets Used**:
- `Build`: Compile all projects
- `Pack`: Create NuGet packages

**Configuration**: `Nightly`
- Less optimization than Release
- More debugging information
- Faster build times

---

## Usage Examples

### Example 1: Normal Scheduled Execution (With Changes)

**Scenario**: Developer pushes 3 commits to alpha throughout the day

```bash
# Day's activity
10:00 UTC - Developer pushes commit 1
14:00 UTC - Developer pushes commit 2
18:00 UTC - Developer pushes commit 3

# Nightly workflow execution
00:00 UTC (next day) - Workflow triggers automatically
00:01 UTC - Checkout completes
00:02 UTC - Change detection: "3 commits in last 24 hours"
00:03 UTC - Build starts
00:10 UTC - Build completes
00:11 UTC - Packages published to NuGet
00:12 UTC - Discord notification sent
00:13 UTC - Workflow complete ✓
```

**Result**:
- New nightly packages available on NuGet
- Discord announcement posted
- Workflow duration: ~13 minutes

### Example 2: Normal Scheduled Execution (No Changes)

**Scenario**: No commits to alpha branch yesterday

```bash
# Day's activity
(no commits to alpha)

# Nightly workflow execution
00:00 UTC - Workflow triggers automatically
00:01 UTC - Checkout completes
00:02 UTC - Change detection: "0 commits in last 24 hours"
00:02 UTC - Skip notification displayed
00:02 UTC - All build steps skipped
00:02 UTC - Workflow complete ✓
```

**Result**:
- No packages published
- No Discord notification
- Workflow duration: ~2 minutes
- **Saved**: ~11 minutes of CI time

### Example 3: Manual Trigger for Testing

**Scenario**: Developer testing workflow changes

```bash
# Manual trigger from GitHub UI
1. Navigate to Actions → Nightly Release
2. Click "Run workflow"
3. Select branch: alpha
4. Click "Run workflow" button

# Workflow execution
- Runs immediately (doesn't wait for cron)
- Change detection still occurs
- Proceeds based on detected changes
- Results visible in Actions tab
```

**Use Cases**:
- Testing workflow modifications
- Forcing build after hotfix
- Verifying NuGet/Discord integration
- Debugging issues

### Example 4: Weekly Development Cycle

**Typical Week Pattern**:

```
Monday:
- 5 commits → Nightly build publishes
Tuesday:
- 3 commits → Nightly build publishes
Wednesday:
- 0 commits → Nightly build skipped
Thursday:
- 7 commits → Nightly build publishes
Friday:
- 2 commits → Nightly build publishes
Weekend:
- 0 commits → Nightly builds skipped (Sat & Sun)

Weekly Stats:
- Workflows run: 7
- Builds executed: 4
- Builds skipped: 3
- CI time saved: ~33 minutes
```

---

## Troubleshooting

### Issue 1: Change Detection Always Shows "No Changes"

**Symptoms**:
```
Commits in last 24 hours: 0
No changes detected - skipping nightly build
```

**Possible Causes**:
1. Git history not fetched (`fetch-depth: 0` missing)
2. Wrong branch specified
3. Commits outside 24-hour window
4. Git command failing silently

**Diagnostic Steps**:
```yaml
# Add after checkout step
- name: Debug Git History
  run: |
    Write-Host "=== Current Branch ==="
    git branch -a
    
    Write-Host "`n=== Recent Commits on Alpha ==="
    git log --oneline alpha -n 10
    
    Write-Host "`n=== Commits in Last 24 Hours ==="
    $yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
    git log --since="$yesterday" --oneline alpha
    
    Write-Host "`n=== Full History Check ==="
    git log --oneline alpha | Measure-Object | Select-Object -ExpandProperty Count
```

**Solutions**:
1. **Verify fetch-depth**: Ensure `fetch-depth: 0` in checkout step
2. **Check branch name**: Verify "alpha" is correct branch name
3. **Test locally**:
   ```bash
   git rev-list --count --since="24 hours ago" alpha
   ```
4. **Review commit timestamps**: Ensure commits are recent

### Issue 2: Build Runs But No Packages Published

**Symptoms**:
```
Package Krypton.Toolkit.100.25.1.1.nupkg already exists - skipped
packages_published=false
```

**Cause**: All packages already exist with current version

**Expected Behavior**: This is normal when version hasn't changed

**Solutions**:
- **If intentional**: No action needed
- **If new version intended**:
  1. Update version in project files
  2. Commit version change
  3. Next nightly build will publish new version

**Version Update Process**:
```xml
<!-- Edit: Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj -->
<PropertyGroup>
  <Version>100.26.0.0</Version>  <!-- Increment version -->
</PropertyGroup>
```

### Issue 3: Discord Notification Not Sent

**Symptoms**: Workflow completes successfully but no Discord message

**Diagnostic Checklist**:
```yaml
# Add debug step
- name: Debug Discord Notification
  run: |
    Write-Host "Packages published: ${{ steps.push_nuget.outputs.packages_published }}"
    Write-Host "Webhook configured: $(if ($env:DISCORD_WEBHOOK_NIGHTLY) { 'Yes' } else { 'No' })"
    
    if ($env:DISCORD_WEBHOOK_NIGHTLY) {
      Write-Host "Webhook URL format: $($env:DISCORD_WEBHOOK_NIGHTLY.Substring(0, 40))..."
    }
  env:
    DISCORD_WEBHOOK_NIGHTLY: ${{ secrets.DISCORD_WEBHOOK_NIGHTLY }}
```

**Common Causes & Solutions**:

| Cause | Solution |
|-------|----------|
| `packages_published=false` | Update version and rebuild |
| Webhook secret not set | Add `DISCORD_WEBHOOK_NIGHTLY` secret |
| Invalid webhook URL | Regenerate webhook in Discord |
| Webhook deleted in Discord | Create new webhook |
| Network timeout | Retry workflow manually |

**Test Webhook**:
```bash
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "Test message from command line"}'
```

### Issue 4: Workflow Not Triggering at Scheduled Time

**Symptoms**: Workflow doesn't run at expected time

**Possible Causes**:
1. Workflow file not on correct branch
2. GitHub Actions disabled
3. Repository inactive (60+ days no activity)
4. High load on GitHub Actions (delayed)

**Diagnostic Steps**:
1. **Verify workflow file location**:
   - Check `.github/workflows/nightly.yml` exists on alpha branch
   - Ensure YAML syntax is valid
2. **Check Actions status**:
   - Settings → Actions → General
   - Ensure "Allow all actions" is enabled
3. **Review recent runs**:
   - Actions tab → Nightly Release
   - Check last successful run timestamp
4. **Manual trigger test**:
   - Use workflow_dispatch to verify functionality

**Solutions**:
- **Wrong branch**: Push workflow file to correct branch
- **Disabled Actions**: Enable in repository settings
- **Inactive repo**: Push any commit to wake up
- **Delays**: Normal; may be delayed by 10-15 minutes

### Issue 5: Build Fails with SDK Error

**Symptoms**:
```
error NETSDK1045: The current .NET SDK does not support targeting .NET 10.0
```

**Cause**: Required SDK not available or not selected

**Solution**:
```yaml
# Check SDK availability
- name: Debug SDK Setup
  run: |
    Write-Host "=== Installed SDKs ==="
    dotnet --list-sdks
    
    Write-Host "`n=== Global.json Content ==="
    if (Test-Path global.json) {
      Get-Content global.json
    } else {
      Write-Host "global.json not found"
    }
    
    Write-Host "`n=== Active SDK ==="
    dotnet --version
```

**Fixes**:
1. **Verify SDK installation**: Check "Setup .NET" step logs
2. **Update global.json logic**: Ensure fallback to .NET 8 works
3. **Check continue-on-error**: .NET 10/11 should not fail build

### Issue 6: NuGet Push Fails with 403 Forbidden

**Symptoms**:
```
error: Response status code does not indicate success: 403 (Forbidden)
```

**Causes**:
- Invalid or expired API key
- API key lacks push permission
- Package name not owned by account

**Solutions**:
1. **Verify API key**: Log in to nuget.org and check API keys
2. **Check permissions**: Ensure "Push" scope is enabled
3. **Regenerate key**: Create new API key if expired
4. **Update secret**: Replace `NUGET_API_KEY` in GitHub
5. **Verify ownership**: Confirm you own the package prefix

---

## Best Practices

### 1. Version Management

**Do**:
- ✅ Increment version regularly (weekly or per feature)
- ✅ Use pre-release versions for nightly (e.g., `100.26.0-nightly.20251028`)
- ✅ Document version changes in changelog
- ✅ Keep version consistent across all packages

**Don't**:
- ❌ Reuse version numbers
- ❌ Skip version increments for significant changes
- ❌ Use production version numbers for nightly

**Recommended Versioning Scheme**:
```
MAJOR.MINOR.PATCH.BUILD

Example:
100.26.0.0        - Production
100.26.0-nightly  - Nightly builds
```

### 2. Change Detection

**Do**:
- ✅ Keep `fetch-depth: 0` in checkout
- ✅ Monitor for false negatives (changes not detected)
- ✅ Review skip logs to ensure expected behavior
- ✅ Test manually when suspicious

**Don't**:
- ❌ Remove change detection to "fix" issues
- ❌ Ignore consistent skipping patterns
- ❌ Assume all changes trigger builds

**Monitoring**:
- Weekly review of workflow runs
- Check ratio of runs vs. builds
- Investigate if ratio significantly changes

### 3. Resource Optimization

**Do**:
- ✅ Leverage change detection to save CI minutes
- ✅ Use NuGet caching for faster restores
- ✅ Monitor GitHub Actions usage
- ✅ Set up usage alerts

**Don't**:
- ❌ Force builds when unnecessary
- ❌ Disable caching without reason
- ❌ Ignore workflow duration increases

**Optimization Checklist**:
- [ ] Change detection enabled
- [ ] NuGet cache configured
- [ ] Shallow clone for non-change-detection steps
- [ ] Conditional step execution working

### 4. Discord Notifications

**Do**:
- ✅ Test webhook before deploying
- ✅ Use appropriate channel for nightly builds
- ✅ Keep message format consistent
- ✅ Include version and package links

**Don't**:
- ❌ Spam channels with test messages
- ❌ Share webhook URLs publicly
- ❌ Send notifications for every workflow run

**Best Channel Setup**:
- **#nightly-releases**: Automated nightly notifications
- **#releases**: Stable releases only
- **#dev-notifications**: Development/testing messages

### 5. Testing and Maintenance

**Do**:
- ✅ Test workflow changes with manual trigger
- ✅ Review logs regularly for warnings
- ✅ Update .NET SDK versions quarterly
- ✅ Rotate NuGet API keys annually
- ✅ Monitor NuGet.org for successful publishes

**Don't**:
- ❌ Test in production (use test workflow)
- ❌ Ignore workflow warnings
- ❌ Leave deprecated actions
- ❌ Keep expired API keys

**Maintenance Schedule**:
- **Weekly**: Review workflow runs
- **Monthly**: Check API key expiration
- **Quarterly**: Update .NET SDKs, review workflow performance
- **Annually**: Rotate API keys, audit secrets

---

## Related Documentation

- [Build Workflow](BuildWorkflow.md) - CI/CD for pull requests and builds
- [Release Workflow](ReleaseWorkflow.md) - Production releases for all channels
- [GitHub Workflows Overview](GitHubWorkflows.md) - Complete documentation

---

## Quick Reference

### Workflow Summary

| Aspect | Details |
|--------|---------|
| **File** | `.github/workflows/nightly.yml` |
| **Trigger** | Scheduled (00:00 UTC daily) + Manual |
| **Runner** | windows-2025 |
| **Duration** | ~2 min (skipped) or ~12-15 min (full build) |
| **Branch** | alpha |

### Key Output Variables

| Variable | Step | Possible Values | Used By |
|----------|------|-----------------|---------|
| `has_changes` | check_changes | `true`, `false` | All subsequent steps |
| `packages_published` | push_nuget | `true`, `false` | Discord notification |
| `version` | get_version | Version string | Discord notification |
| `tag` | get_version | Tag string | Future use |

### Required Secrets

| Secret | Required | Purpose |
|--------|----------|---------|
| `NUGET_API_KEY` | Yes | Publish to NuGet.org |
| `DISCORD_WEBHOOK_NIGHTLY` | No | Discord notifications |

### Target Frameworks

- .NET Framework 4.7.2, 4.8, 4.8.1
- .NET 8.0-windows, 9.0-windows, 10.0-windows

### NuGet Packages

- Krypton.Toolkit
- Krypton.Ribbon
- Krypton.Navigator
- Krypton.Workspace
- Krypton.Docking