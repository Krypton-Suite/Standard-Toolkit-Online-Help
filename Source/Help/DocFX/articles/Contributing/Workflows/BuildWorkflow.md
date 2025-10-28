# Build Workflow Documentation

**Workflow File**: `.github/workflows/build.yml`  
**Version**: 1.0  

---

## Table of Contents
1. [Overview](#overview)
2. [Purpose](#purpose)
3. [Triggers](#triggers)
4. [Jobs](#jobs)
5. [Configuration](#configuration)
6. [Usage Examples](#usage-examples)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Overview

The Build workflow is the primary continuous integration (CI) gate for the Krypton Toolkit repository. It validates code quality, ensures compilability across all supported target frameworks, and optionally creates GitHub releases for stable master branch pushes.

### Key Features
- ✅ Multi-framework validation (.NET Framework 4.7.2 - 4.8.1, .NET 8-11)
- ✅ Pull request validation
- ✅ Automated release creation for master branch
- ✅ NuGet package caching for performance
- ✅ Cross-branch support
- ✅ Fork protection (prevents abuse from external contributors)

### Workflow Architecture

```
┌─────────────────────────────────────────┐
│         Build Workflow Trigger          │
└───────────┬─────────────────────────────┘
            │
    ┌───────┴──────────┐
    │                  │
┌───▼────┐      ┌──────▼─────┐
│   PR   │      │    Push    │
│  Event │      │   Event    │
└───┬────┘      └──────┬─────┘
    │                  │
    │      ┌───────────┴──────────┐
    │      │                      │
    │   Master?              Other Branch?
    │      │                      │
    └──────┴──────────────────────┴──────┐
                                          │
                                    ┌─────▼─────┐
                                    │ Build Job │
                                    └─────┬─────┘
                                          │
                                    Success?
                                          │
                                ┌─────────┴──────────┐
                                │                    │
                           Yes + Master?            No
                                │                    │
                         ┌──────▼──────┐            │
                         │ Release Job │            │
                         └─────────────┘            │
                                                     │
                                              ┌──────▼──────┐
                                              │  Workflow   │
                                              │  Complete   │
                                              └─────────────┘
```

---

## Purpose

The Build workflow serves multiple critical functions:

### 1. Continuous Integration (CI)
- Validates all pull requests before merge
- Ensures code compiles across all target frameworks
- Catches breaking changes early in development cycle
- Provides fast feedback to developers

### 2. Branch Protection
- Acts as required status check for protected branches
- Prevents merging of broken code
- Only allows builds from same repository (prevents fork abuse)

### 3. Automated Release Pipeline
- Creates GitHub releases automatically when master is updated
- Packages release artifacts (ZIP, TAR.GZ)
- Provides downloadable distributions for end users
- Integrates with tag-based versioning

### 4. Build Validation
- Multi-framework compatibility testing
- Dependency resolution verification
- MSBuild configuration validation
- Output artifact verification

---

## Triggers

```yaml
on:
  pull_request:
    branches: ['**']
    types: [opened, synchronize, reopened]
  push:
    branches:
      - master
      - alpha
      - canary
      - gold
      - V85-LTS
    paths-ignore: ['.git*', '.vscode']
```

### Pull Request Events

**Branches**: All branches (`['**']`)

**Event Types**:
- `opened`: New pull request created
- `synchronize`: Pull request updated with new commits
- `reopened`: Previously closed pull request reopened

**Behavior**:
- Runs build job only (no release)
- Validates changes before merge
- Provides status check for branch protection

**Example**:
```bash
# Create feature branch and push
git checkout -b feature/new-component
git push origin feature/new-component

# Open PR to master → Build workflow triggers automatically
```

### Push Events

**Branches**:
- `master`: Stable production branch
- `alpha`: Development/nightly branch
- `canary`: Pre-release testing branch
- `gold`: (Reserved for future use)
- `V85-LTS`: Long-term support branch

**Paths Ignored**:
- `.git*`: Git configuration files
- `.vscode`: VSCode workspace settings

**Behavior**:
- Runs build job for all listed branches
- Runs release job **only for master branch**
- Skips workflow if only ignored paths changed

**Example**:
```bash
# Push to master
git checkout master
git merge develop
git push origin master

# → Build job runs → Release job runs (master only)
```

---

## Jobs

### Job 1: Build

**Runner**: `windows-2025`

**Condition**:
```yaml
if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
```

**Explanation**:
- Always runs for push events
- For pull requests, only runs if PR is from the same repository
- Prevents external forks from consuming CI resources or accessing secrets

#### Steps Breakdown

##### 1. Checkout
```yaml
- name: Checkout
  uses: actions/checkout@v5
```

**Purpose**: Clone repository at the commit that triggered the workflow

**Default Behavior**:
- Shallow clone (last commit only)
- No submodules
- Checks out the PR merge commit (for PRs) or branch HEAD (for pushes)

##### 2. Setup .NET 9 (GA)
```yaml
- name: Setup .NET 9
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 9.0.x
```

**Purpose**: Install stable .NET 9 SDK

**Configuration**:
- `9.0.x`: Latest stable 9.0 patch version
- Required for .NET 9.0-windows target framework

##### 3. Setup .NET 10 (GA)
```yaml
- name: Setup .NET 10
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 10.0.x
  continue-on-error: true
```

**Purpose**: Install .NET 10 SDK (if available)

**Configuration**:
- `continue-on-error: true`: Workflow continues if .NET 10 unavailable
- Supports future .NET 10.0-windows targets
- Graceful degradation for preview periods

##### 4. Setup .NET 11 (Preview)
```yaml
- name: Setup .NET 11
  uses: actions/setup-dotnet@v4
  with:
    dotnet-version: 11.0.x
  continue-on-error: true
```

**Purpose**: Install .NET 11 preview SDK (if available)

**Configuration**:
- Forward-looking for .NET 11 support
- Optional - won't fail build if unavailable

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

**Purpose**: Dynamically select the latest .NET 10 SDK for build

**Fallback Logic**:
```powershell
if (-not $sdkVersion) {
  # Fallback to .NET 8 if .NET 10 is not available
  $sdkVersion = (dotnet --list-sdks | Select-String "8.0").ToString().Split(" ")[0]
}
```

**Why This Is Needed**:
- Ensures consistent SDK across build steps
- Enables multi-targeting to work correctly
- Provides fallback when newer SDKs unavailable
- `rollForward: latestFeature` allows minor version flexibility

##### 6. Setup MSBuild
```yaml
- name: Setup MSBuild
  uses: microsoft/setup-msbuild@v2
  with:
    msbuild-architecture: x64
```

**Purpose**: Configure MSBuild for x64 builds

**Why MSBuild**:
- Required for full .NET Framework support
- Handles complex multi-targeting scenarios
- Integrates with custom build scripts (`*.proj` files)

##### 7. Setup NuGet
```yaml
- name: Setup NuGet
  uses: NuGet/setup-nuget@v1.2.0
```

**Purpose**: Install NuGet CLI for package restoration

**Note**: While `dotnet restore` could be used, NuGet CLI provides better compatibility with .NET Framework projects.

##### 8. Cache NuGet
```yaml
- name: Cache NuGet
  uses: actions/cache@v4
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
    restore-keys: |
      ${{ runner.os }}-nuget-
```

**Purpose**: Cache NuGet packages between workflow runs

**Cache Strategy**:
- **Key**: OS + hash of all csproj files
- **Path**: Global NuGet packages directory
- **Restore Keys**: Fallback to any previous cache for this OS

**Performance Impact**:
- First run: ~2-3 minutes to download all packages
- Cached runs: ~10-15 seconds to restore from cache
- Cache miss only occurs when csproj files change

##### 9. Restore
```yaml
- name: Restore
  run: dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
```

**Purpose**: Download and restore all NuGet package dependencies

**What Happens**:
1. Reads solution file
2. Parses all project files
3. Resolves package dependencies
4. Downloads packages (or uses cache)
5. Prepares for build

**Common Issues**:
- Network timeouts: NuGet.org connectivity issues
- Version conflicts: Incompatible package versions
- Missing packages: Package no longer available

##### 10. Build
```yaml
- name: Build
  run: msbuild "Scripts/nightly.proj" /t:Rebuild /p:Configuration=Release /p:Platform="Any CPU"
```

**Purpose**: Compile all projects in Release configuration

**MSBuild Parameters**:
- `/t:Rebuild`: Clean + Build (ensures fresh compile)
- `/p:Configuration=Release`: Release mode optimizations
- `/p:Platform="Any CPU"`: Target all CPU architectures

**Build Script**: `Scripts/nightly.proj`
- Orchestrates multi-project builds
- Handles target framework switching
- Manages output paths

**Target Frameworks Built**:
- .NET Framework 4.7.2
- .NET Framework 4.8
- .NET Framework 4.8.1
- .NET 8.0-windows
- .NET 9.0-windows
- .NET 10.0-windows (if SDK available)

**Output Location**: `Bin/Release/`

---

### Job 2: Release

**Runner**: `windows-2025`

**Condition**:
```yaml
if: github.ref == 'refs/heads/master' && github.event_name == 'push'
needs: build
```

**When It Runs**:
- ✅ Only after build job succeeds
- ✅ Only for pushes to master branch
- ❌ Never for pull requests
- ❌ Never for other branches

#### Steps Breakdown

##### 1-10. Build Steps
Repeats checkout, .NET setup, MSBuild configuration, restore

**Why Repeat?**
- Each job runs in isolated environment
- No shared filesystem between jobs
- Jobs can run on different runners

##### 11. Build Release
```yaml
- name: Build Release
  run: msbuild "Scripts/build.proj" /t:Build /p:Configuration=Release /p:Platform="Any CPU"
```

**Difference from Build Job**: Uses `Scripts/build.proj` instead of `nightly.proj`

**build.proj Purpose**:
- Production release configuration
- Includes signing (if configured)
- Optimized for distribution

##### 12. Pack Release
```yaml
- name: Pack Release
  run: msbuild "Scripts/build.proj" /t:Pack /p:Configuration=Release /p:Platform="Any CPU"
```

**Purpose**: Create NuGet packages for all components

**Target**: `Pack` MSBuild target

**Output**: `Bin/Packages/Release/*.nupkg`

**Packages Created**:
- Krypton.Toolkit.{version}.nupkg
- Krypton.Ribbon.{version}.nupkg
- Krypton.Navigator.{version}.nupkg
- Krypton.Workspace.{version}.nupkg
- Krypton.Docking.{version}.nupkg

##### 13. Create Release Archives
```yaml
- name: Create Release Archives
  run: msbuild "Scripts/build.proj" /t:CreateAllReleaseArchives /p:Configuration=Release /p:Platform="Any CPU"
```

**Purpose**: Package binaries into distributable archives

**Target**: `CreateAllReleaseArchives` MSBuild target

**Output**: `Bin/Release/Zips/`
- `Krypton-Release_*.zip`
- `Krypton-Release_*.tar.gz`

**Archive Contents**:
- All DLLs for all target frameworks
- XML documentation files
- License and readme files
- Example configurations

##### 14. Get Version
```yaml
- name: Get Version
  id: get_version
  run: |
    $version = (dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit.csproj" --no-restore --verbosity quiet | Select-String "Version" | ForEach-Object { $_.Line.Split('=')[1].Trim() })
    if (-not $version) {
      $version = "100.25.1.1"  # Fallback version
    }
    echo "version=$version" >> $env:GITHUB_OUTPUT
    echo "tag=v$version" >> $env:GITHUB_OUTPUT
```

**Purpose**: Extract version number for release tagging

**Strategy**:
1. Build project and parse output for version
2. Fallback to hardcoded version if extraction fails

**Outputs**:
- `version`: e.g., `100.25.1.1`
- `tag`: e.g., `v100.25.1.1`

**Used By**: Subsequent steps for release creation and tagging

##### 15. Create Release
```yaml
- name: Create Release
  run: |
    $releaseBody = @"
    ## Krypton Toolkit Suite Release ${{ steps.get_version.outputs.version }}
    
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
    
    gh release create ${{ steps.get_version.outputs.tag }} `
      --title "Release ${{ steps.get_version.outputs.version }}" `
      --notes "$releaseBody" `
      --latest
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Purpose**: Create GitHub release with tag

**GitHub CLI Command**: `gh release create`

**Parameters**:
- `--title`: Human-readable release title
- `--notes`: Markdown-formatted release notes
- `--latest`: Mark as latest release

**Authentication**: Uses automatic `GITHUB_TOKEN` secret

**Result**: Creates release at `https://github.com/{owner}/{repo}/releases/tag/{tag}`

##### 16. Upload Release Assets
```yaml
- name: Upload Release Assets
  run: |
    $zipFile = Get-ChildItem "Bin/Release/Zips/Krypton-Release_*.zip" | Select-Object -First 1
    $tarFile = Get-ChildItem "Bin/Release/Zips/Krypton-Release_*.tar.gz" | Select-Object -First 1
    
    if ($zipFile) {
      gh release upload ${{ steps.get_version.outputs.tag }} "$($zipFile.FullName)" --clobber
    }
    if ($tarFile) {
      gh release upload ${{ steps.get_version.outputs.tag }} "$($tarFile.FullName)" --clobber
    }
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Purpose**: Attach distribution archives to GitHub release

**GitHub CLI Command**: `gh release upload`

**Parameters**:
- `--clobber`: Replace existing assets with same name

**Error Handling**: Checks for file existence before upload

**Result**: Assets available for download from release page

---

## Configuration

### Environment Variables
None required. All configuration is provided through workflow parameters and GitHub secrets.

### Required Secrets

#### GITHUB_TOKEN
- **Type**: Automatic secret (provided by GitHub)
- **Purpose**: Authenticate GitHub CLI for release creation
- **Permissions Required**:
  - `contents: write` - Create releases and upload assets
  - `actions: read` - Read workflow metadata

**Configuration**: No manual setup required

**Verification**:
```yaml
- name: Verify Token
  run: |
    if ($env:GITHUB_TOKEN) {
      Write-Host "✓ GITHUB_TOKEN is available"
    } else {
      Write-Host "✗ GITHUB_TOKEN is missing"
    }
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Build Scripts

The workflow depends on MSBuild project files in `Scripts/` directory:

#### Scripts/nightly.proj
**Used By**: Build job (step 10)

**Purpose**:
- Development/CI build configuration
- Multi-targeting orchestration
- Output path management

**Key Targets**:
- `Rebuild`: Clean and build all projects

#### Scripts/build.proj
**Used By**: Release job (steps 11-13)

**Purpose**:
- Production release configuration
- Package creation
- Archive generation

**Key Targets**:
- `Build`: Compile all projects
- `Pack`: Create NuGet packages
- `CreateAllReleaseArchives`: Generate distribution archives

### Repository Settings

#### Actions Permissions
**Required Settings** (Settings → Actions → General):
- ✅ "Allow all actions and reusable workflows" (or selected actions)
- ✅ Workflow permissions: "Read and write permissions"
- ✅ "Allow GitHub Actions to create and approve pull requests"

#### Branch Protection
**Recommended for Master Branch** (Settings → Branches):
- ✅ Require status checks to pass before merging
  - ✅ Require "build" check to pass
- ✅ Require pull request reviews before merging
- ✅ Require conversation resolution before merging

---

## Usage Examples

### Example 1: Pull Request Workflow

```bash
# 1. Create feature branch
git checkout -b feature/add-new-button
git push origin feature/add-new-button

# 2. Make changes and push
# (edit files)
git add .
git commit -m "Add new button component"
git push origin feature/add-new-button

# 3. Open Pull Request on GitHub
# → Build workflow triggers automatically
# → Status check appears on PR

# 4. Push updates to PR
git commit -m "Address review feedback"
git push origin feature/add-new-button

# → Build workflow triggers again (synchronize event)
# → Updated status check on PR

# 5. Merge PR when build passes
# (merge on GitHub)
```

**Workflow Behavior**:
- Validates each push to PR branch
- Shows build status on PR page
- Prevents merge if build fails (with branch protection)
- Does NOT create releases

### Example 2: Direct Push to Master

```bash
# 1. Ensure local master is up to date
git checkout master
git pull origin master

# 2. Merge feature branch
git merge feature/add-new-button

# 3. Push to master
git push origin master

# → Build job runs
# → If build succeeds → Release job runs
# → GitHub release created automatically
# → Release assets uploaded
```

**Workflow Behavior**:
- Builds code in Release configuration
- Creates NuGet packages
- Generates distribution archives
- Creates GitHub release with version tag
- Uploads ZIP and TAR.GZ to release

**Result**: New release available at `https://github.com/{owner}/{repo}/releases`

### Example 3: Push to Protected Branch (Not Master)

```bash
# Push to alpha branch
git checkout alpha
git push origin alpha

# → Build job runs
# → Release job DOES NOT run (not master)
# → No GitHub release created
```

**Workflow Behavior**:
- Validates build succeeds
- Ensures code compiles across frameworks
- No release artifacts created
- No GitHub release generated

### Example 4: Updating Documentation Only

```bash
# Edit README
git checkout master
git add README.md
git commit -m "Update installation instructions"
git push origin master

# → Build workflow SKIPPED (paths-ignore: .git*)
# → No build triggered
```

**Workflow Behavior**: Skipped entirely due to `paths-ignore` configuration

---

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Build Fails - Project Not Found

**Symptoms**:
```
error MSB4025: The project file could not be loaded. Could not find file
```

**Causes**:
- Incorrect file path in workflow YAML
- Working directory changed unexpectedly
- File renamed or moved

**Solution**:
```yaml
# Add diagnostic step before build
- name: Debug - Show Current Directory
  run: |
    Write-Host "Current directory: $(Get-Location)"
    Write-Host "Solution file exists: $(Test-Path 'Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln')"
```

#### Issue 2: Multi-Targeting Build Failure

**Symptoms**:
```
error NETSDK1045: The current .NET SDK does not support targeting .NET 10.0
```

**Causes**:
- .NET 10 SDK not installed
- SDK setup step failed silently
- Wrong SDK selected by global.json

**Solution**:
```yaml
# Add diagnostic step after SDK setup
- name: Debug - List Installed SDKs
  run: |
    Write-Host "Installed .NET SDKs:"
    dotnet --list-sdks
    Write-Host "`nGlobal.json content:"
    Get-Content global.json
```

**Fix**:
1. Verify "Setup .NET 10" step succeeded
2. Check if `continue-on-error: true` is masking failures
3. Update fallback logic in "Force .NET SDK" step

#### Issue 3: NuGet Restore Fails

**Symptoms**:
```
error NU1301: Unable to load the service index for source https://api.nuget.org/v3/index.json
```

**Causes**:
- Network connectivity issues
- NuGet.org service outage
- TLS/SSL certificate problems
- Proxy configuration issues

**Solution**:
```yaml
# Add retry logic to restore step
- name: Restore with Retry
  run: |
    $retries = 3
    $delay = 10
    for ($i = 1; $i -le $retries; $i++) {
      Write-Host "Restore attempt $i of $retries"
      dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
      if ($LASTEXITCODE -eq 0) {
        break
      }
      if ($i -lt $retries) {
        Write-Host "Restore failed, waiting $delay seconds..."
        Start-Sleep -Seconds $delay
      }
    }
```

**Check Status**: https://status.nuget.org/

#### Issue 4: GitHub Release Creation Fails

**Symptoms**:
```
error: HTTP 404: Not Found (https://api.github.com/repos/.../releases)
```

**Causes**:
- Insufficient GITHUB_TOKEN permissions
- Release with tag already exists
- Invalid tag name format
- Rate limiting

**Solution**:
```yaml
# Check permissions
- name: Verify Permissions
  run: |
    Write-Host "Checking repository permissions..."
    gh api repos/${{ github.repository }} --jq '.permissions'
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

**Permission Fix**:
1. Go to Settings → Actions → General
2. Under "Workflow permissions", select "Read and write permissions"
3. Save changes

#### Issue 5: Cache Not Working

**Symptoms**:
- Restore takes 2-3 minutes every run
- Cache restore step shows "Cache not found"

**Causes**:
- Cache key changed (csproj files modified)
- Cache expired (7 days old)
- Cache size limit reached (10 GB per repository)

**Solution**:
```yaml
# Add cache diagnostics
- name: Cache Statistics
  run: |
    Write-Host "Cache path: ~/.nuget/packages"
    if (Test-Path ~/.nuget/packages) {
      $size = (Get-ChildItem ~/.nuget/packages -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
      Write-Host "Cache size: $([math]::Round($size, 2)) MB"
    }
```

**Optimization**:
- Review cache key specificity
- Consider using restore-keys for partial matches
- Manually clear old caches if needed

#### Issue 6: Release Assets Not Uploading

**Symptoms**:
```
warning: Failed to upload ZIP: ...
```

**Causes**:
- Archive creation step failed
- File path incorrect
- File size exceeds 2GB limit
- Network timeout

**Solution**:
```yaml
# Add verification before upload
- name: Verify Archives
  run: |
    Write-Host "Checking for ZIP archive..."
    $zipFile = Get-ChildItem "Bin/Release/Zips/Krypton-Release_*.zip" -ErrorAction SilentlyContinue
    if ($zipFile) {
      Write-Host "✓ Found: $($zipFile.Name)"
      Write-Host "  Size: $([math]::Round($zipFile.Length / 1MB, 2)) MB"
    } else {
      Write-Host "✗ ZIP file not found"
    }
    
    Write-Host "`nChecking for TAR.GZ archive..."
    $tarFile = Get-ChildItem "Bin/Release/Zips/Krypton-Release_*.tar.gz" -ErrorAction SilentlyContinue
    if ($tarFile) {
      Write-Host "✓ Found: $($tarFile.Name)"
      Write-Host "  Size: $([math]::Round($tarFile.Length / 1MB, 2)) MB"
    } else {
      Write-Host "✗ TAR.GZ file not found"
    }
```

#### Issue 7: Build Succeeds Locally But Fails in CI

**Symptoms**: Build works on developer machine but fails in GitHub Actions

**Causes**:
- Environment differences
- Missing dependencies
- Hardcoded paths
- Local configuration files not committed

**Solution**:
1. **Compare Environments**:
   ```yaml
   - name: Environment Diagnostics
     run: |
       Write-Host "OS: ${{ runner.os }}"
       Write-Host "Architecture: $env:PROCESSOR_ARCHITECTURE"
       Write-Host ".NET SDKs:"
       dotnet --list-sdks
       Write-Host "`nEnvironment Variables:"
       Get-ChildItem Env: | Sort-Object Name
   ```

2. **Test with Clean Repository**:
   ```bash
   # Clone fresh copy
   git clone https://github.com/{owner}/{repo}.git test-repo
   cd test-repo
   
   # Try local build
   dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
   msbuild "Scripts/nightly.proj" /t:Rebuild /p:Configuration=Release /p:Platform="Any CPU"
   ```

3. **Check for Uncommitted Files**:
   ```bash
   git status
   # Look for untracked files that might be needed
   ```

---

## Best Practices

### 1. Pull Request Workflow

**Do**:
- ✅ Always create feature branches from latest master
- ✅ Keep PRs focused and reasonably sized
- ✅ Wait for build to pass before requesting review
- ✅ Address build failures immediately

**Don't**:
- ❌ Push directly to master (use PRs)
- ❌ Force push to PR branches (confuses reviewers)
- ❌ Merge PRs with failing builds
- ❌ Ignore build warnings

### 2. Version Management

**Do**:
- ✅ Update version in project files before release
- ✅ Use semantic versioning (MAJOR.MINOR.PATCH)
- ✅ Tag releases consistently
- ✅ Document version changes in changelog

**Don't**:
- ❌ Reuse version numbers
- ❌ Skip versions
- ❌ Use non-standard version formats

### 3. Build Optimization

**Do**:
- ✅ Leverage NuGet caching
- ✅ Use `--no-restore` when appropriate
- ✅ Minimize dependencies
- ✅ Keep build scripts maintainable

**Don't**:
- ❌ Install unnecessary SDKs
- ❌ Restore packages multiple times
- ❌ Build in Debug mode for releases
- ❌ Include source code in release archives

### 4. Release Management

**Do**:
- ✅ Test releases before tagging
- ✅ Include comprehensive release notes
- ✅ Verify archive contents
- ✅ Announce releases to users

**Don't**:
- ❌ Delete or modify releases after publishing
- ❌ Omit target framework information
- ❌ Skip testing of release archives
- ❌ Push broken code to master

### 5. Debugging Workflow Issues

**When Build Fails**:
1. Read error message carefully
2. Check recent changes to workflow file
3. Review step logs in GitHub Actions UI
4. Reproduce locally if possible
5. Add diagnostic steps to narrow down issue
6. Check GitHub Actions status page for outages

**Diagnostic Template**:
```yaml
- name: Diagnostics
  if: failure()  # Only runs if previous step failed
  run: |
    Write-Host "=== Diagnostics ==="
    Write-Host "Current Directory: $(Get-Location)"
    Write-Host "Runner OS: ${{ runner.os }}"
    Write-Host "GitHub Ref: ${{ github.ref }}"
    Write-Host "Event: ${{ github.event_name }}"
    Write-Host "`nDirectory Contents:"
    Get-ChildItem -Recurse -Depth 2
```

---

## Related Documentation

- [Release Workflow](ReleaseWorkflow.md) - Handles production releases for all branches
- [Nightly Workflow](NightlyWorkflow.md) - Scheduled nightly builds with change detection
- [GitHub Workflows Overview](GitHubWorkflows.md) - Complete workflow documentation

---

## Quick Reference

### Workflow Summary

| Aspect | Details |
|--------|---------|
| **File** | `.github/workflows/build.yml` |
| **Triggers** | Pull requests (all branches), Push (master, alpha, canary, gold, V85-LTS) |
| **Runner** | windows-2025 |
| **Jobs** | 2 (build, release) |
| **Duration** | ~5-10 minutes (build), ~8-12 minutes (release) |
| **Dependencies** | Build scripts, .NET SDKs 9-11, MSBuild, NuGet |

### Required Secrets

| Secret | Required | Purpose |
|--------|----------|---------|
| `GITHUB_TOKEN` | Yes (automatic) | Create GitHub releases |

### Target Frameworks

| Framework | Minimum Version | Required SDK |
|-----------|-----------------|--------------|
| .NET Framework | 4.7.2 | Windows SDK |
| .NET Framework | 4.8 | Windows SDK |
| .NET Framework | 4.8.1 | Windows SDK |
| .NET | 8.0-windows | .NET 8 SDK |
| .NET | 9.0-windows | .NET 9 SDK |
| .NET | 10.0-windows | .NET 10 SDK |