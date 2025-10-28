# Release Workflow Documentation

**Workflow File**: `.github/workflows/release.yml`  
**Version**: 1.0  

---

## Table of Contents
1. [Overview](#overview)
2. [Release Channels](#release-channels)
3. [Jobs](#jobs)
4. [Configuration](#configuration)
5. [Usage Examples](#usage-examples)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

---

## Overview

The Release workflow handles production releases across four different release channels, each targeting different audiences and stability requirements. This workflow automates building, packaging, publishing to NuGet.org, creating GitHub releases, and announcing on Discord.

### Key Features
- ✅ Four independent release channels (Master, LTS, Canary, Alpha)
- ✅ Automatic NuGet package publishing
- ✅ GitHub release creation with artifacts
- ✅ Discord webhook notifications
- ✅ Multi-framework support
- ✅ Intelligent duplicate detection
- ✅ Comprehensive version detection

### Workflow Architecture

```
┌──────────────────┐
│  Push to Branch  │
└────────┬─────────┘
         │
    ┌────┴────┬────────┬─────────┐
    │         │        │         │
┌───▼───┐ ┌──▼──┐ ┌───▼───┐ ┌───▼────┐
│Master │ │ LTS │ │Canary │ │ Alpha  │
└───┬───┘ └──┬──┘ └───┬───┘ └───┬────┘
    │        │        │         │
    ▼        ▼        ▼         ▼
Build    Build    Build     Build
Pack     Pack     Pack      Pack
    │        │        │         │
    ▼        ▼        ▼         ▼
Publish  Publish  Publish   Publish
to NuGet to NuGet to NuGet  to NuGet
    │        │        │         │
    ▼        ▼        ▼         ▼
Create   (No      (No       (No
GitHub   GitHub   GitHub    GitHub
Release  Release) Release)  Release)
    │        │        │         │
    ▼        ▼        ▼         ▼
Discord  Discord  Discord   Discord
Notify   Notify   Notify    Notify
```

---

## Release Channels

### Quick Comparison

| Channel | Branch | Config | Frameworks | NuGet Suffix | Tag | Discord Color |
|---------|--------|--------|------------|--------------|-----|---------------|
| **Stable** | master | Release | 4.7.2-4.8.1, 8-10 | - | `v{ver}` | Blue |
| **LTS** | V85-LTS | Release | 4.6.2-4.8.1, 6-8 | `.LTS` | `v{ver}-lts` | Orange |
| **Canary** | canary | Canary | 4.7.2-4.8.1, 8-10 | - | `v{ver}-canary` | Yellow |
| **Alpha** | alpha | Nightly | 4.7.2-4.8.1, 8-10 | - | `v{ver}-nightly` | Purple |

### Channel Details

#### Master (Stable)
**Purpose**: Production-ready stable releases

**When to Use**:
- Final tested features
- Bug fixes for production
- Major releases
- Official version numbers

**Target Audience**: Production users, stable applications

**Release Frequency**: As needed (typically monthly to quarterly)

**Build Configuration**: Release (fully optimized)

#### V85-LTS (Long-Term Support)
**Purpose**: Extended framework support for legacy applications

**When to Use**:
- Organizations requiring .NET 6/7 support
- Applications on older .NET Framework versions (4.6.2-4.7.1)
- Long-term stability required
- Minimal breaking changes

**Target Audience**: Enterprise users, legacy application maintainers

**Release Frequency**: Less frequent, stability-focused updates

**Build Configuration**: Release (optimized for LTS frameworks)

**Unique Features**:
- Separate NuGet packages with `.LTS` suffix
- No .NET 9/10/11 targets (focuses on LTS versions)
- Extended .NET Framework support (4.6.2, 4.7, 4.7.1)

#### Canary (Pre-Release)
**Purpose**: Early testing builds before stable release

**When to Use**:
- Feature previews
- Beta testing
- Release candidates
- Pre-production validation

**Target Audience**: Early adopters, testers, QA teams

**Release Frequency**: Weekly to monthly

**Build Configuration**: Canary (optimized but marked as pre-release)

#### Alpha (Nightly-style)
**Purpose**: Bleeding-edge development builds (push-triggered)

**When to Use**:
- Latest development features
- Continuous integration testing
- Rapid iteration
- Developer testing

**Target Audience**: Developers, contributors, advanced users

**Release Frequency**: On every push to alpha branch

**Build Configuration**: Nightly (less optimized, more debugging info)

---

## Jobs

### Job 1: release-master

**Runner**: `windows-2025`

**Condition**: `github.ref == 'refs/heads/master' && github.event_name == 'push'`

#### Workflow Steps

##### 1. Checkout
```yaml
- name: Checkout
  uses: actions/checkout@v5
```
Clones the repository at the commit that triggered the workflow.

##### 2-4. Setup .NET 9, 10, 11
```yaml
- name: Setup .NET 9
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 9.0.x

- name: Setup .NET 10
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 10.0.x
  continue-on-error: true

- name: Setup .NET 11
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 11.0.x
  continue-on-error: true
```

**Purpose**: Install multiple .NET SDK versions for multi-targeting

**Key Details**:
- .NET 9 is required (fails if unavailable)
- .NET 10 and 11 are optional (continue-on-error)
- Enables building for .NET 8-11 Windows targets

##### 5. Force .NET 10 SDK via global.json
```yaml
- name: Force .NET 10 SDK via global.json
  run: |
    $sdkVersion = (dotnet --list-sdks | Select-String "10.0").ToString().Split(" ")[0]
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

**Purpose**: Dynamically select the latest .NET 10 SDK for consistent builds

**Fallback**: Falls back to .NET 8 if .NET 10 unavailable

##### 6-8. Setup MSBuild, NuGet, Cache
Standard build tooling setup (see Build Workflow documentation)

##### 9. Restore
```yaml
- name: Restore
  run: dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
```
Downloads and restores NuGet package dependencies.

##### 10. Build Release
```yaml
- name: Build Release
  run: msbuild "Scripts/build.proj" /t:Build /p:Configuration=Release /p:Platform="Any CPU"
```

**Purpose**: Compile all projects in Release configuration

**Build Script**: `Scripts/build.proj`
- Production build settings
- Code signing (if configured)
- Optimization enabled

**Output**: `Bin/Release/{framework}/`

##### 11. Pack Release
```yaml
- name: Pack Release
  run: msbuild "Scripts/build.proj" /t:Pack /p:Configuration=Release /p:Platform="Any CPU"
```

**Purpose**: Create NuGet packages

**Output**: `Bin/Packages/Release/*.nupkg`

**Packages Created**:
- Krypton.Toolkit.{version}.nupkg
- Krypton.Ribbon.{version}.nupkg
- Krypton.Navigator.{version}.nupkg
- Krypton.Workspace.{version}.nupkg
- Krypton.Docking.{version}.nupkg

##### 12. Push NuGet Packages to nuget.org
```yaml
- name: Push NuGet Packages to nuget.org
  id: push_nuget
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    if (-not $env:NUGET_API_KEY) {
      Write-Warning "NUGET_API_KEY not set - skipping NuGet push"
      echo "packages_published=false" >> $env:GITHUB_OUTPUT
      exit 0
    }
    
    $packages = Get-ChildItem "Bin/Packages/Release/*.nupkg" -ErrorAction SilentlyContinue
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

**Purpose**: Publish NuGet packages to nuget.org

**Key Features**:
- **Duplicate Detection**: Uses `--skip-duplicate` flag
- **Error Handling**: Continues on individual package failures
- **Output Variable**: Sets `packages_published=true/false`
- **Graceful Degradation**: Warns if API key missing (doesn't fail)

**Logic Flow**:
1. Check for `NUGET_API_KEY` secret
2. Find all .nupkg files in `Bin/Packages/Release/`
3. For each package:
   - Push with `--skip-duplicate` flag
   - Check output for "already exists" message
   - Track if any new packages were published
4. Set output variable for Discord notification condition

**Output Variable**: `packages_published` (true/false)
- `true`: At least one new package was published
- `false`: All packages were duplicates or push was skipped

##### 13. Create Release Archives
```yaml
- name: Create Release Archives
  run: msbuild "Scripts/build.proj" /t:CreateAllReleaseArchives /p:Configuration=Release /p:Platform="Any CPU"
```

**Purpose**: Package binaries into distributable archives

**Output**: `Bin/Release/Zips/`
- `Krypton-Release_{version}.zip`
- `Krypton-Release_{version}.tar.gz`

**Archive Contents**:
- All compiled DLLs for all target frameworks
- XML documentation files
- License and legal notices
- README and changelog

##### 14. Get Version
```yaml
- name: Get Version
  id: get_version
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    $version = $null
    
    # Try to get version from the built assembly (most reliable)
    try {
      $dllPath = Get-ChildItem "Bin/Release/net48/Krypton.Toolkit.dll" -ErrorAction Stop
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
    echo "tag=v$version" >> $env:GITHUB_OUTPUT
```

**Purpose**: Extract version number for tagging and release notes

**Three-Tier Strategy**:
1. **Primary**: Read from built assembly (most reliable)
2. **Fallback**: Parse csproj XML for `<Version>` tag
3. **Last Resort**: Hardcoded fallback version

**Output Variables**:
- `version`: e.g., `100.25.1.1`
- `tag`: e.g., `v100.25.1.1`

##### 15. Diagnostics - List Artefacts
```yaml
- name: Diagnostics - List Artifacts
  shell: pwsh
  run: |
    Write-Host "=== Files in Bin/Packages/Release ==="
    Get-ChildItem -Path Bin/Packages/Release -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_.FullName }
    Write-Host "`n=== Files in Bin/Release/Zips ==="
    Get-ChildItem -Path Bin/Release/Zips -Recurse -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_.FullName }
    Write-Host "`n=== Secrets Check ==="
    Write-Host "GITHUB_TOKEN present: $(if ($env:GITHUB_TOKEN) { 'yes' } else { 'no' })"
    Write-Host "NUGET_API_KEY present: $(if ($env:NUGET_API_KEY) { 'yes' } else { 'no' })"
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

**Purpose**: Diagnostic information for troubleshooting

**Information Displayed**:
- List of NuGet packages created
- List of release archives created
- Verification that required secrets are present

##### 16. Create or Update Release
```yaml
- name: Create or Update Release
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    $version = "${{ steps.get_version.outputs.version }}"
    $tag = "v$version"
    $releaseTitle = "Release $version"
    $releaseBody = @"
    ## Krypton Toolkit Suite Release $version
    
    This release includes:
    - All Krypton Toolkit components
    - NuGet packages for multiple target frameworks
    - Release archives (ZIP and TAR.GZ formats)
    
    ### Downloads
    - **ZIP Archive**: `Krypton-Release_*.zip`
    - **TAR.GZ Archive**: `Krypton-Release_*.tar.gz`
    
    ### Target Frameworks
    - .NET Framework 4.7.2
    - .NET Framework 4.8
    - .NET Framework 4.8.1
    - .NET 8.0 Windows
    - .NET 9.0 Windows
    - .NET 10.0 Windows
    "@
    
    Write-Host "Preparing to create or update release $tag"
    
    # Check if release exists
    $releaseExists = $false
    gh release view $tag 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
      $releaseExists = $true
    }
    
    if ($releaseExists) {
      Write-Host "Release $tag exists - updating"
      gh release edit $tag --title $releaseTitle --notes "$releaseBody"
    } else {
      Write-Host "Creating release $tag"
      gh release create $tag --title $releaseTitle --notes "$releaseBody" --latest
    }
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Purpose**: Create GitHub release or update existing one

**Logic**:
1. Check if release with tag already exists
2. If exists: Update title and notes
3. If not exists: Create new release with `--latest` flag

**Release Notes**: Markdown-formatted with:
- Release overview
- List of included components
- Download links
- Supported frameworks

##### 17. Upload Release Assets
```yaml
- name: Upload Release Assets
  shell: pwsh
  run: |
    $ErrorActionPreference = 'Stop'
    $tag = "${{ steps.get_version.outputs.tag }}"
    $zipFile = Get-ChildItem "Bin/Release/Zips/Krypton-Release_*.zip" -ErrorAction SilentlyContinue | Select-Object -First 1
    $tarFile = Get-ChildItem "Bin/Release/Zips/Krypton-Release_*.tar.gz" -ErrorAction SilentlyContinue | Select-Object -First 1
    
    if ($zipFile) {
      Write-Host "Uploading $($zipFile.Name)"
      try {
        gh release upload $tag "$($zipFile.FullName)" --clobber
      } catch {
        Write-Warning "Failed to upload ZIP: $_"
      }
    } else {
      Write-Warning "ZIP release archive not found; skipping upload."
    }
    
    if ($tarFile) {
      Write-Host "Uploading $($tarFile.Name)"
      try {
        gh release upload $tag "$($tarFile.FullName)" --clobber
      } catch {
        Write-Warning "Failed to upload TAR.GZ: $_"
      }
    } else {
      Write-Warning "TAR.GZ release archive not found; skipping upload."
    }
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Purpose**: Attach distribution archives to GitHub release

**Features**:
- **Existence Check**: Verifies files exist before upload
- **Error Handling**: Continues if upload fails (logs warning)
- **Clobber Flag**: Replaces existing assets with same name

##### 18. Announce Release on Discord
```yaml
- name: Announce Release on Discord
  if: steps.push_nuget.outputs.packages_published == 'True'
  shell: pwsh
  run: |
    if (-not $env:DISCORD_WEBHOOK_MASTER) {
      Write-Warning "DISCORD_WEBHOOK_MASTER not set - skipping Discord notification"
      exit 0
    }
    
    $payload = @{
      embeds = @(
        @{
          title = "🎉 Krypton Toolkit Stable Release"
          description = "A new stable release is now available!"
          color = 3447003
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
            @{
              name = "📥 GitHub Release"
              value = "[Download Archives](https://github.com/${{ github.repository }}/releases/tag/${{ steps.get_version.outputs.tag }})"
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
    
    Invoke-RestMethod -Uri "${{ secrets.DISCORD_WEBHOOK_MASTER }}" -Method Post -Body $payload -ContentType "application/json"
  env:
    DISCORD_WEBHOOK_MASTER: ${{ secrets.DISCORD_WEBHOOK_MASTER }}
```

**Purpose**: Send release announcement to Discord channel

**Condition**: Only runs if `packages_published == 'True'`

**Webhook Structure**:
- **Embed Title**: Channel-specific emoji and title
- **Description**: Brief release description
- **Color**: Blue (3447003) for stable releases
- **Fields**:
  - Version number
  - List of packages
  - Target frameworks
  - NuGet package links
  - GitHub release link
- **Timestamp**: ISO 8601 UTC timestamp

**Graceful Handling**: Exits successfully if webhook not configured

---

### Job 2: release-v85-lts

**Runner**: `windows-2025`

**Condition**: `github.ref == 'refs/heads/V85-LTS' && github.event_name == 'push'`

#### Key Differences from Master

##### .NET SDK Setup
```yaml
# .NET 6 (LTS) - needed for net6.0-windows target
- name: Setup .NET 6
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 6.0.x

# .NET 7 - needed for net7.0-windows target
- name: Setup .NET 7
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 7.0.x

# .NET 8 (LTS) - needed for net8.0-windows target
- name: Setup .NET 8
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 8.0.x
```

**Why Different**: LTS focuses on long-term support versions (6, 7, 8) instead of bleeding-edge (9, 10, 11)

##### Build Script
```yaml
- name: Build LTS Release
  run: msbuild "Scripts/longtermstable.proj" /t:Build /p:Configuration=Release /p:Platform="Any CPU"

- name: Pack LTS Release
  run: msbuild "Scripts/longtermstable.proj" /t:Pack /p:Configuration=Release /p:Platform="Any CPU"
```

**Script**: `Scripts/longtermstable.proj` (instead of `build.proj`)

##### Target Frameworks
- .NET Framework 4.6.2, 4.7, 4.7.1, 4.7.2, 4.8, 4.8.1
- .NET 6.0-windows, 7.0-windows, 8.0-windows

**Extended Framework Support**: Includes older .NET Framework versions

##### Package Names
- Krypton.Toolkit.LTS.{version}.nupkg
- Krypton.Ribbon.LTS.{version}.nupkg
- etc.

**Suffix**: `.LTS` added to all package names

##### Version Fallback
```yaml
$version = "85.25.1.1"  # LTS-specific fallback
```

##### Release Tag
```yaml
echo "tag=v$version-lts" >> $env:GITHUB_OUTPUT
```

**Format**: `v{version}-lts` (e.g., `v85.25.1.1-lts`)

##### Discord Notification
- **Color**: Orange (15105570)
- **Title**: "🛡️ Krypton Toolkit LTS Release"
- **Webhook**: `DISCORD_WEBHOOK_LTS`

##### No GitHub Release
The LTS job does NOT create GitHub releases (only NuGet packages and Discord notification).

---

### Job 3: release-canary

**Runner**: `windows-2025`

**Condition**: `github.ref == 'refs/heads/canary' && github.event_name == 'push'`

#### Key Differences from Master

##### .NET SDK Setup
Same as master (9, 10 preview)

##### Build Script
```yaml
- name: Build Canary
  run: msbuild "Scripts/canary.proj" /t:Build /p:Configuration=Canary /p:Platform="Any CPU"

- name: Pack Canary
  run: msbuild "Scripts/canary.proj" /t:Pack /p:Configuration=Canary /p:Platform="Any CPU"
```

**Script**: `Scripts/canary.proj`
**Configuration**: `Canary` (instead of Release)

##### Output Paths
- Build: `Bin/Canary/`
- Packages: `Bin/Packages/Canary/`

##### Version Detection
```yaml
$dllPath = Get-ChildItem "Bin/Canary/net48/Krypton.Toolkit.dll"
```

##### Release Tag
```yaml
echo "tag=v$version-canary" >> $env:GITHUB_OUTPUT
```

**Format**: `v{version}-canary`

##### Discord Notification
- **Color**: Yellow (16776960)
- **Title**: "🐤 Krypton Toolkit Canary Release"
- **Webhook**: `DISCORD_WEBHOOK_CANARY`

##### No GitHub Release
The Canary job does NOT create GitHub releases.

---

### Job 4: release-alpha

**Runner**: `windows-2025`

**Condition**: `github.ref == 'refs/heads/alpha' && github.event_name == 'push'`

#### Key Differences from Master

##### .NET SDK Setup
Same as master (9, 10 preview)

##### Build Script
```yaml
- name: Build Alpha
  run: msbuild "Scripts/nightly.proj" /t:Build /p:Configuration=Nightly /p:Platform="Any CPU"

- name: Pack Alpha
  run: msbuild "Scripts/nightly.proj" /t:Pack /p:Configuration=Nightly /p:Platform="Any CPU"
```

**Script**: `Scripts/nightly.proj`
**Configuration**: `Nightly` (debug symbols, less optimization)

##### Output Paths
- Build: `Bin/Nightly/`
- Packages: `Bin/Packages/Nightly/`

##### Version Detection
```yaml
$dllPath = Get-ChildItem "Bin/Nightly/net48/Krypton.Toolkit.dll"
```

##### Release Tag
```yaml
echo "tag=v$version-nightly" >> $env:GITHUB_OUTPUT
```

**Format**: `v{version}-nightly`

##### Discord Notification
- **Color**: Purple (10181046)
- **Title**: "🚀 Krypton Toolkit Nightly Release"
- **Webhook**: `DISCORD_WEBHOOK_NIGHTLY`

##### No GitHub Release
The Alpha job does NOT create GitHub releases.

---

## Configuration

### Required Secrets

#### NUGET_API_KEY
- **Type**: Secret
- **Required By**: All release jobs
- **Purpose**: Authenticate with NuGet.org for package publishing
- **How to Obtain**:
  1. Log in to https://nuget.org
  2. Go to Account Settings → API Keys
  3. Create new API key with "Push" permission
  4. Set appropriate expiration
  5. Copy key and add to GitHub repository secrets

**Security**:
- Rotate every 90 days
- Use separate keys for different repositories
- Never commit to version control

#### GITHUB_TOKEN
- **Type**: Automatic secret
- **Required By**: Master release job (for GitHub release creation)
- **Purpose**: Authenticate GitHub CLI
- **Configuration**: No manual setup required

**Required Permissions**:
- `contents: write`
- `actions: read`

#### DISCORD_WEBHOOK_MASTER
- **Type**: Secret (optional)
- **Required By**: Master release job
- **Purpose**: Post stable release announcements
- **How to Obtain**:
  1. Open Discord server settings
  2. Go to Integrations → Webhooks
  3. Create new webhook for releases channel
  4. Copy webhook URL
  5. Add to GitHub repository secrets

**Format**: `https://discord.com/api/webhooks/{id}/{token}`

#### DISCORD_WEBHOOK_LTS
- **Type**: Secret (optional)
- **Required By**: LTS release job
- **Purpose**: Post LTS release announcements
- **Configuration**: Same as DISCORD_WEBHOOK_MASTER

#### DISCORD_WEBHOOK_CANARY
- **Type**: Secret (optional)
- **Required By**: Canary release job
- **Purpose**: Post canary release announcements
- **Configuration**: Same as DISCORD_WEBHOOK_MASTER

#### DISCORD_WEBHOOK_NIGHTLY
- **Type**: Secret (optional)
- **Required By**: Alpha release job
- **Purpose**: Post nightly release announcements
- **Configuration**: Same as DISCORD_WEBHOOK_MASTER

### Build Scripts

| Script | Job | Configuration | Purpose |
|--------|-----|---------------|---------|
| `Scripts/build.proj` | Master | Release | Stable production builds |
| `Scripts/longtermstable.proj` | LTS | Release | LTS builds with extended framework support |
| `Scripts/canary.proj` | Canary | Canary | Pre-release builds |
| `Scripts/nightly.proj` | Alpha | Nightly | Development builds |

### Repository Settings

#### Actions Permissions
(Settings → Actions → General)
- ✅ Workflow permissions: "Read and write permissions"
- ✅ Allow GitHub Actions to create/approve pull requests (for master only)

---

## Usage Examples

### Example 1: Stable Release (Master)

```bash
# 1. Prepare release branch
git checkout master
git pull origin master

# 2. Update version in project files
# Edit: Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj
# Update <Version>100.26.0.0</Version>

# 3. Commit version change
git add .
git commit -m "Bump version to 100.26.0.0"

# 4. Push to master
git push origin master

# → Workflow triggers automatically
# → Builds, packs, publishes NuGet
# → Creates GitHub release v100.26.0.0
# → Uploads ZIP and TAR.GZ
# → Posts to Discord
```

**Result**:
- NuGet packages published to nuget.org
- GitHub release created with archives
- Discord notification sent (if webhook configured)

### Example 2: LTS Release

```bash
# 1. Cherry-pick bug fix to LTS branch
git checkout V85-LTS
git cherry-pick <commit-hash>

# 2. Update LTS version
# Edit: <Version>85.26.0.0</Version>

# 3. Push to V85-LTS
git push origin V85-LTS

# → Workflow triggers
# → Builds with .NET 6/7/8 only
# → Publishes *.LTS packages to NuGet
# → Posts to Discord with LTS designation
# → No GitHub release created
```

**Result**:
- Krypton.Toolkit.LTS packages published
- Discord notification with LTS branding
- No GitHub release

### Example 3: Canary Pre-Release

```bash
# 1. Merge feature to canary for testing
git checkout canary
git merge feature/experimental-ui

# 2. Update canary version
# Edit: <Version>100.27.0.0-canary.1</Version>

# 3. Push to canary
git push origin canary

# → Workflow triggers
# → Builds in Canary configuration
# → Publishes to NuGet with canary version
# → Posts to Discord with yellow canary branding
```

**Result**:
- Canary packages available for early testing
- Discord notification with pre-release warning
- No GitHub release

### Example 4: Alpha Development Build

```bash
# 1. Push feature to alpha
git checkout alpha
git push origin alpha

# → Workflow triggers on every push
# → Builds in Nightly configuration
# → Publishes to NuGet
# → Posts to Discord with nightly branding

# Note: Consider using scheduled nightly.yml instead
# for automatic daily builds with change detection
```

---

## Troubleshooting

### Issue 1: NuGet Push Fails with 403 Forbidden

**Symptoms**:
```
error: Response status code does not indicate success: 403 (Forbidden)
```

**Causes**:
- Invalid or expired `NUGET_API_KEY`
- API key lacks push permission
- Package name/prefix not owned by account

**Solution**:
1. Verify API key on nuget.org:
   - Go to Account Settings → API Keys
   - Check expiration date
   - Verify "Push" permission is enabled
2. Regenerate API key if needed
3. Update `NUGET_API_KEY` secret in GitHub

### Issue 2: All Packages Skipped (Duplicates)

**Symptoms**:
```
Package Krypton.Toolkit.100.25.1.1.nupkg already exists - skipped
packages_published=false
```

**Expected Behavior**: This is normal when version hasn't changed

**Solutions**:
- **Update Version**: Increment version in project files before releasing
- **Verify Intent**: Ensure you intended to create a new release
- **Check NuGet**: Visit nuget.org to confirm existing version

**Note**: Discord notification won't be sent when all packages are duplicates.

### Issue 3: Discord Notification Not Sent

**Symptoms**: Build succeeds but no Discord message

**Possible Causes**:
1. **Webhook not configured**: `DISCORD_WEBHOOK_*` secret not set
2. **No packages published**: `packages_published=false` (all duplicates)
3. **Invalid webhook URL**: Webhook expired or deleted
4. **Payload too large**: Unlikely but possible

**Solution**:
```yaml
# Add debug step before Discord notification
- name: Debug Discord
  run: |
    Write-Host "Packages published: ${{ steps.push_nuget.outputs.packages_published }}"
    Write-Host "Webhook configured: $(if ($env:DISCORD_WEBHOOK_MASTER) { 'yes' } else { 'no' })"
  env:
    DISCORD_WEBHOOK_MASTER: ${{ secrets.DISCORD_WEBHOOK_MASTER }}
```

**Test Webhook**:
```bash
curl -X POST "WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"content": "Test message"}'
```

### Issue 4: GitHub Release Creation Fails

**Symptoms**:
```
error: HTTP 404: Not Found
```

**Causes**:
- Insufficient `GITHUB_TOKEN` permissions
- Release with same tag already exists
- Network issues

**Solution**:
1. **Check Permissions**:
   - Settings → Actions → General
   - Workflow permissions: "Read and write permissions"
2. **Check Existing Release**:
   ```bash
   gh release view v100.25.1.1
   ```
3. **Delete Existing Release** (if needed):
   ```bash
   gh release delete v100.25.1.1
   ```

### Issue 5: Version Detection Returns Fallback

**Symptoms**:
```
Version not found, using fallback.
version=100.25.1.1
```

**Causes**:
- DLL not built successfully
- Incorrect DLL path
- Assembly version not set in project

**Solution**:
1. **Verify Build Success**:
   ```yaml
   - name: Verify DLL Exists
     run: |
       Test-Path "Bin/Release/net48/Krypton.Toolkit.dll"
   ```
2. **Check Project File**:
   ```xml
   <PropertyGroup>
     <Version>100.26.0.0</Version>
   </PropertyGroup>
   ```
3. **Add Diagnostics**:
   ```yaml
   - name: Debug Version Detection
     run: |
       Write-Host "Assembly path: Bin/Release/net48/Krypton.Toolkit.dll"
       $dll = Get-ChildItem "Bin/Release/net48/Krypton.Toolkit.dll"
       Write-Host "File exists: $($dll -ne $null)"
       if ($dll) {
         $asm = [System.Reflection.AssemblyName]::GetAssemblyName($dll.FullName)
         Write-Host "Assembly version: $($asm.Version)"
       }
   ```

### Issue 6: Wrong Release Channel Triggered

**Symptoms**: Alpha workflow runs when expecting master, etc.

**Cause**: Pushed to wrong branch

**Solution**:
```bash
# Verify current branch
git branch

# Check which branch you're pushing to
git push --dry-run origin alpha
```

**Prevention**:
- Use branch protection rules
- Require pull requests for important branches
- Set up CI status checks

---

## Best Practices

### 1. Version Management

**Do**:
- ✅ Increment version before releasing
- ✅ Use semantic versioning (MAJOR.MINOR.PATCH.BUILD)
- ✅ Update changelog with release
- ✅ Tag commits with version number

**Don't**:
- ❌ Reuse version numbers
- ❌ Publish without updating version
- ❌ Use non-standard version formats

### 2. Release Testing

**Do**:
- ✅ Test in canary before promoting to master
- ✅ Verify packages install correctly
- ✅ Test on all target frameworks
- ✅ Review GitHub release before announcing

**Don't**:
- ❌ Push untested code to master
- ❌ Skip integration testing
- ❌ Ignore build warnings

### 3. NuGet Package Management

**Do**:
- ✅ Use `--skip-duplicate` for idempotency
- ✅ Verify package contents before publishing
- ✅ Monitor nuget.org for successful upload
- ✅ Test package installation in sample project

**Don't**:
- ❌ Delete published packages (use unlisting instead)
- ❌ Publish debug builds to production
- ❌ Include unnecessary files in packages

### 4. Discord Notifications

**Do**:
- ✅ Test webhook before configuring
- ✅ Use separate webhooks per channel
- ✅ Monitor Discord for successful posts
- ✅ Keep notification messages concise

**Don't**:
- ❌ Share webhook URLs publicly
- ❌ Spam channels with test messages
- ❌ Include sensitive information in notifications

### 5. Security

**Do**:
- ✅ Rotate NuGet API keys regularly
- ✅ Use separate keys for different repositories
- ✅ Monitor for unauthorized package updates
- ✅ Enable 2FA on NuGet account

**Don't**:
- ❌ Commit secrets to version control
- ❌ Share API keys with others
- ❌ Use overly permissive API key scopes

---

## Related Documentation

- [Build Workflow](Build-Workflow.md) - CI/CD for pull requests and builds
- [Nightly Workflow](Nightly-Workflow.md) - Scheduled nightly builds
- [GitHub Workflows Overview](../GitHub-Workflows.md) - Complete documentation

---

## Quick Reference

### Release Channels

| Channel | Branch | Package Suffix | Tag Format |
|---------|--------|----------------|------------|
| Stable | master | - | `v{version}` |
| LTS | V85-LTS | `.LTS` | `v{version}-lts` |
| Canary | canary | - | `v{version}-canary` |
| Alpha | alpha | - | `v{version}-nightly` |

### Required Secrets

| Secret | Master | LTS | Canary | Alpha |
|--------|--------|-----|--------|-------|
| `NUGET_API_KEY` | ✅ | ✅ | ✅ | ✅ |
| `GITHUB_TOKEN` | ✅ | ❌ | ❌ | ❌ |
| `DISCORD_WEBHOOK_*` | Optional | Optional | Optional | Optional |

### Target Frameworks by Channel

| Framework | Master | LTS | Canary | Alpha |
|-----------|--------|-----|--------|-------|
| .NET 4.6.2 | ❌ | ✅ | ❌ | ❌ |
| .NET 4.7.x | ❌ | ✅ | ❌ | ❌ |
| .NET 4.7.2 | ✅ | ✅ | ✅ | ✅ |
| .NET 4.8.x | ✅ | ✅ | ✅ | ✅ |
| .NET 6 | ❌ | ✅ | ❌ | ❌ |
| .NET 7 | ❌ | ✅ | ❌ | ❌ |
| .NET 8 | ✅ | ✅ | ✅ | ✅ |
| .NET 9 | ✅ | ❌ | ✅ | ✅ |
| .NET 10 | ✅ | ❌ | ✅ | ✅ |
