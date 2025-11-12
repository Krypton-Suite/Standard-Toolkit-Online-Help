# GitHub Actions CI/CD Workflows

## Overview

The Krypton Toolkit uses GitHub Actions for continuous integration, automated testing, and release management. The workflows are designed for Windows-only builds with comprehensive security checks and automated deployments.

## Workflow Files

Located in `.github/workflows/`:

| Workflow | File | Trigger | Purpose |
|----------|------|---------|---------|
| Build | `build.yml` | PR, push to branches | CI builds |
| Release | `release.yml` | Push to release branches | Production releases |
| Nightly | `nightly.yml` | Schedule (daily), manual | Automated nightly builds |

## Build Workflow (build.yml)

**Purpose**: Continuous integration for pull requests and branch commits

### Triggers

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
      - V100-LTS
      - V105-LTS
      - V85-LTS
    paths-ignore: ['.git*', '.vscode']
```

**Events**:
- Pull requests to any branch
- Pushes to main development and LTS branches
- Ignores changes to `.git*` and `.vscode` files

### Jobs

#### 1. Build Job

**Runner**: `windows-latest`

**Condition**: Only runs for PRs from same repository (security)

**Steps**:

1. **Checkout**
```yaml
- uses: actions/checkout@v5
```

2. **Setup .NET SDKs**
```yaml
- name: Setup .NET 9
  uses: actions/setup-dotnet@v5
  with:
    dotnet-version: 9.0.x

- name: Setup .NET 10
  uses: actions/setup-dotnet@v5
  with:
    dotnet-version: 10.0.x
  continue-on-error: true

- name: Setup .NET 11
  uses: actions/setup-dotnet@v5
  with:
    dotnet-version: 11.0.x
  continue-on-error: true
```

**Strategy**: Install .NET 9 (required), 10 (optional), and 11 (optional/future)

3. **Generate global.json**
```yaml
- name: Force .NET 10 SDK via global.json
  run: |
    $sdkVersion = (dotnet --list-sdks | Select-String "10.0").ToString().Split(" ")[0]
    @"
    {
      "sdk": {
        "version": "$sdkVersion",
        "rollForward": "latestFeature"
      }
    }
    "@ | Out-File -Encoding utf8 global.json
```

**Purpose**: Pins SDK version for consistency

4. **Setup MSBuild and NuGet**
```yaml
- name: Setup MSBuild
  uses: microsoft/setup-msbuild@v2
  with:
    msbuild-architecture: x64

- name: Setup NuGet
  uses: NuGet/setup-nuget@v2
```

5. **Cache NuGet Packages**
```yaml
- name: Cache NuGet
  uses: actions/cache@v4
  with:
    path: ~/.nuget/packages
    key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
    restore-keys: |
      ${{ runner.os }}-nuget-
```

**Purpose**: Speeds up builds by caching dependencies

6. **Restore and Build**
```yaml
- name: Restore
  run: dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"

- name: Build
  run: msbuild "Scripts/nightly.proj" /t:Rebuild /p:Configuration=Release
```

**Note**: Uses `nightly.proj` with `Release` configuration for PR builds

#### 2. Release Job (master branch only)

**Runner**: `windows-latest`

**Condition**: Only runs on `master` branch pushes

**Additional Steps** (after build):

1. **Pack Release**
```yaml
- name: Pack Release
  run: msbuild "Scripts/build.proj" /t:Pack /p:Configuration=Release
```

2. **Create Release Archives**
```yaml
- name: Create Release Archives
  run: msbuild "Scripts/build.proj" /t:CreateAllReleaseArchives /p:Configuration=Release
```

3. **Get Version**
```yaml
- name: Get Version
  id: get_version
  run: |
    $version = (dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit.csproj" --no-restore --verbosity quiet | Select-String "Version" | ForEach-Object { $_.Line.Split('=')[1].Trim() })
    if (-not $version) {
      $version = "100.25.1.1"  # Fallback
    }
    echo "version=$version" >> $env:GITHUB_OUTPUT
    echo "tag=v$version" >> $env:GITHUB_OUTPUT
```

4. **Create GitHub Release**
```yaml
- name: Create Release
  run: |
    gh release create ${{ steps.get_version.outputs.tag }} \
      --title "Release ${{ steps.get_version.outputs.version }}" \
      --notes "..." \
      --latest
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

5. **Upload Release Assets**
```yaml
- name: Upload Release Assets
  run: |
    gh release upload ${{ steps.get_version.outputs.tag }} \
      "Bin/Release/Zips/Krypton-Release_*.zip" \
      "Bin/Release/Zips/Krypton-Release_*.tar.gz" \
      --clobber
```

## Release Workflow (release.yml)

**Purpose**: Production releases for multiple branches with deployment

### Triggers

```yaml
on:
  push:
    branches:
      - master
      - alpha
      - canary
      - V100-LTS
      - V105-LTS
      - V85-LTS
```

### Jobs

#### 1. release-master (Stable Release)

**Security Checks**:
```yaml
- name: Security - Verify Repository
  run: |
    if ($env:GITHUB_REPOSITORY -ne 'Krypton-Suite/Standard-Toolkit') {
      Write-Error "Invalid repository"
      exit 1
    }

- name: Security - Verify Branch
  run: |
    if ($env:GITHUB_REF -ne 'refs/heads/master') {
      Write-Error "Invalid branch"
      exit 1
    }
```

**Key Steps**:
1. Checkout code
2. Setup .NET 9, 10, 11
3. Setup MSBuild and NuGet
4. Restore and build
5. Pack packages
6. **Push to NuGet.org**:
```yaml
- name: Push NuGet Packages to nuget.org
  id: push_nuget
  run: |
    $packages = Get-ChildItem "Bin/Packages/Release/*.nupkg"
    foreach ($package in $packages) {
      dotnet nuget push "$($package.FullName)" \
        --api-key $env:NUGET_API_KEY \
        --source https://api.nuget.org/v3/index.json \
        --skip-duplicate
    }
  env:
    NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

7. Create release archives
8. Get version from assembly
9. Create or update GitHub release
10. Upload release assets
11. **Announce on Discord**:
```yaml
- name: Announce Release on Discord
  if: steps.push_nuget.outputs.packages_published == 'True'
  run: |
    # Send Discord webhook notification
  env:
    DISCORD_WEBHOOK_MASTER: ${{ secrets.DISCORD_WEBHOOK_MASTER }}
```

#### 2. release-canary (Beta Release)

**Branch**: `canary`

**Differences from master**:
- Uses `Scripts/canary.proj`
- Configuration: `Canary`
- Package suffix: `.Canary` with `-beta`
- Outputs to `Bin/Packages/Canary/`
- Discord webhook: `DISCORD_WEBHOOK_CANARY`
- Git tag: `v{version}-canary`

#### 3. release-alpha (Alpha Release)

**Branch**: `alpha`

**Differences from master**:
- Uses `Scripts/nightly.proj`
- Configuration: `Nightly`
- Package suffix: `.Nightly` with `-alpha`
- Outputs to `Bin/Packages/Nightly/`
- No automated publishing (handled by nightly.yml)

#### 4. release-v85-lts, release-v100-lts, release-v105-lts

**Purpose**: Long-term support releases

**Differences**:
- Uses `Scripts/longtermstable.proj`
- Different .NET SDK versions (e.g., .NET 6, 7, 8 for V85-LTS)
- Package suffix: `.LTS`
- Discord webhook: `DISCORD_WEBHOOK_LTS`
- Git tag: `v{version}-lts`

## Nightly Workflow (nightly.yml)

**Purpose**: Automated daily builds with change detection and kill-switch

### Triggers

```yaml
on:
  schedule:
    - cron: '0 0 * * *'  # Midnight UTC daily
  workflow_dispatch:  # Manual trigger
```

### Default Branch Requirement

**Important**: The `nightly.yml` workflow **must** be present in the repository's default branch (typically `master` or `main`) for the scheduled trigger to work.

#### Why This Matters

GitHub Actions has a critical requirement for scheduled workflows:

**Scheduled workflows (`schedule` trigger with `cron`) only run from the workflow file in the default branch.**

This means:
- Even though the workflow checks out and builds the `alpha` branch
- The workflow file itself (`nightly.yml`) must exist in the default branch
- If `nightly.yml` only exists in `alpha`, the scheduled trigger will never fire
- Manual triggers (`workflow_dispatch`) will work from any branch, but scheduled runs won't

#### Practical Implications

1. **Workflow File Location**:
   - Must be committed to default branch: `.github/workflows/nightly.yml`
   - Can exist in other branches, but won't run on schedule from there

2. **Workflow Updates**:
   - To update the nightly workflow, merge changes to the default branch
   - Changes in feature branches won't affect scheduled runs
   - Test changes using `workflow_dispatch` (manual trigger) before merging

3. **Branch Checkout**:
   - The workflow file is in `master` (default branch)
   - But it checks out `alpha` branch for building:
     ```yaml
     - name: Checkout
       uses: actions/checkout@v5
       with:
         ref: alpha  # Build from alpha, not master
     ```

4. **Multi-Branch Strategy**:
   - Workflow definition lives in `master`
   - Source code comes from `alpha`
   - This separation allows:
     - Stable workflow automation
     - Bleeding-edge code in alpha
     - Scheduled consistency

#### Verification

To verify the workflow will run on schedule:

1. **Check Default Branch**:
```bash
# View repository default branch
gh repo view --json defaultBranchRef --jq .defaultBranchRef.name
```

2. **Verify Workflow Location**:
```bash
# Ensure workflow exists in default branch
git checkout master
ls .github/workflows/nightly.yml
```

3. **Check GitHub UI**:
   - Go to repository **Settings** → **General**
   - Confirm "Default branch" setting
   - Go to **Actions** tab
   - Scheduled workflows show next run time only if in default branch

#### Common Mistakes

❌ **Wrong**: Workflow only in `alpha` branch
```
alpha/.github/workflows/nightly.yml  ✗ Won't run on schedule
```

✅ **Correct**: Workflow in default branch, builds from `alpha`
```
master/.github/workflows/nightly.yml  ✓ Runs on schedule
  └─ checks out alpha branch for build
```

#### Troubleshooting

**Symptom**: Scheduled workflow not running

**Possible Causes**:
1. Workflow file not in default branch
2. Wrong default branch configured
3. Kill-switch enabled (`NIGHTLY_DISABLED=true`)

**Solutions**:
```bash
# 1. Verify workflow in default branch
git checkout master
git log -- .github/workflows/nightly.yml

# 2. Copy workflow from alpha to master if needed
git checkout master
git checkout alpha -- .github/workflows/nightly.yml
git commit -m "Add nightly workflow to default branch"
git push origin master

# 3. Verify via GitHub API
curl -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/Krypton-Suite/Standard-Toolkit/actions/workflows
```

#### References

- [GitHub Actions: Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)
- [GitHub Docs: Scheduled events](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#scheduled-events)

### Security Features

#### 1. Repository Verification
```yaml
- name: Security - Verify Repository
  run: |
    if ($env:GITHUB_REPOSITORY -ne 'Krypton-Suite/Standard-Toolkit') {
      Write-Error "Security: Invalid repository"
      exit 1
    }
```

#### 2. Branch Verification
```yaml
- name: Security - Verify Branch
  run: |
    $allowedRefs = @('refs/heads/alpha', 'refs/heads/master', 'refs/heads/main')
    if ($env:GITHUB_REF -notin $allowedRefs) {
      Write-Error "Security: Unauthorized branch"
      exit 1
    }
```

#### 3. Kill-Switch Check
```yaml
- name: Kill-Switch Check
  id: kill_switch
  run: |
    $disabled = '${{ vars.NIGHTLY_DISABLED }}'
    if ($disabled -eq 'true') {
      Write-Host "::warning::Nightly workflow is DISABLED"
      echo "enabled=false" >> $env:GITHUB_OUTPUT
      exit 0
    }
    echo "enabled=true" >> $env:GITHUB_OUTPUT
```

**Configuration**: Set `NIGHTLY_DISABLED=true` in repository variables to disable

### Change Detection

```yaml
- name: Check for changes in last 24 hours
  id: check_changes
  run: |
    $yesterday = (Get-Date).AddDays(-1).ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss")
    $commitCount = git rev-list --count --since="$yesterday" alpha
    
    if ([int]$commitCount -gt 0) {
      echo "has_changes=true" >> $env:GITHUB_OUTPUT
    } else {
      echo "has_changes=false" >> $env:GITHUB_OUTPUT
    }
```

**Behavior**: Skips build if no commits in last 24 hours

### Workflow Steps (if changes detected)

1. Checkout `alpha` branch
2. Setup .NET SDKs
3. Setup MSBuild and NuGet
4. Restore and build (Nightly configuration)
5. Pack nightly packages
6. **Push to NuGet.org**:
```yaml
- name: Push NuGet Packages to nuget.org
  run: |
    $packages = Get-ChildItem "Bin/Packages/Nightly/*.nupkg"
    foreach ($package in $packages) {
      dotnet nuget push "$($package.FullName)" \
        --api-key $env:NUGET_API_KEY \
        --source https://api.nuget.org/v3/index.json \
        --skip-duplicate
    }
```

7. Get version from assembly
8. Announce on Discord (if packages published)

## Required Secrets and Variables

### Secrets

Configure in **Settings → Secrets and variables → Actions → Secrets**:

| Secret | Purpose | Required For |
|--------|---------|--------------|
| `NUGET_API_KEY` | NuGet.org publishing | All release workflows |
| `DISCORD_WEBHOOK_MASTER` | Stable release announcements | release.yml (master) |
| `DISCORD_WEBHOOK_CANARY` | Canary release announcements | release.yml (canary) |
| `DISCORD_WEBHOOK_NIGHTLY` | Nightly release announcements | nightly.yml |
| `DISCORD_WEBHOOK_LTS` | LTS release announcements | release.yml (LTS branches) |

**Note**: `GITHUB_TOKEN` is automatically provided by GitHub Actions

### Variables

Configure in **Settings → Secrets and variables → Actions → Variables**:

| Variable | Purpose | Values |
|----------|---------|--------|
| `NIGHTLY_DISABLED` | Kill-switch for nightly builds | `true` or `false` |

## Workflow Outputs

### Artifacts

None explicitly uploaded, but packages are published to:
- NuGet.org
- GitHub Releases (for stable)

### Logs

Available in GitHub Actions UI:
- Build logs
- MSBuild output
- NuGet push results

### Notifications

Discord webhooks send rich embeds with:
- Version number
- Package links
- Target frameworks
- Timestamp

## Troubleshooting

### Build Fails with "SDK Not Found"

**Cause**: .NET SDK version unavailable

**Solution**: Workflows have `continue-on-error: true` for newer SDKs

### NuGet Push Fails with 401 Unauthorized

**Cause**: Invalid or expired `NUGET_API_KEY`

**Solution**:
1. Generate new API key at https://www.nuget.org/account/apikeys
2. Update secret in repository settings

### Nightly Workflow Not Running

**Possible Causes**:
1. Kill-switch enabled (`NIGHTLY_DISABLED=true`)
2. No commits in last 24 hours
3. Workflow disabled in repository settings

**Solutions**:
1. Check kill-switch variable
2. Manually trigger via `workflow_dispatch`
3. Enable workflow in **Actions** tab

### Discord Notification Not Sent

**Cause**: Webhook secret not configured or invalid

**Solution**: Verify Discord webhook URL in secrets

### Release Already Exists

**Cause**: Trying to create duplicate release

**Behavior**: Workflow updates existing release instead of creating new one

### Wrong Version Extracted

**Cause**: Version detection fails

**Fallback**: Uses default version `100.25.1.1`

**Solution**: Check version calculation in `Directory.Build.props`

## Best Practices

### 1. Test Workflows Locally

Use `act` to test GitHub Actions locally:
```cmd
# Install act: https://github.com/nektos/act
act push -W .github/workflows/build.yml
```

### 2. Use Environments for Protection

Production releases use `production` environment:
```yaml
environment: production
```

Requires manual approval before deployment.

### 3. Monitor Workflow Runs

Regularly check workflow runs in **Actions** tab for:
- Build failures
- Deployment issues
- Security alerts

### 4. Rotate Secrets Regularly

Update `NUGET_API_KEY` periodically for security.

### 5. Test Package Publishing

Use `--skip-duplicate` to safely test publishing:
```yaml
dotnet nuget push *.nupkg --skip-duplicate
```

### 6. Use Structured Logging

Workflows use PowerShell for structured output:
```powershell
echo "version=$version" >> $env:GITHUB_OUTPUT
Write-Host "::notice::Message"
Write-Host "::warning::Warning"
Write-Host "::error::Error"
```

## Manual Workflow Execution

### Trigger Nightly Build Manually

1. Go to **Actions** tab
2. Select **Nightly Release** workflow
3. Click **Run workflow**
4. Select branch (usually `alpha`)
5. Click **Run workflow** button

### Parameters

Nightly workflow accepts no input parameters; it uses the current branch state.

## Advanced Scenarios

### Conditional Step Execution

```yaml
- name: Conditional Step
  if: steps.previous_step.outputs.some_value == 'true'
  run: echo "Condition met"
```

### Matrix Builds (Future Enhancement)

To build multiple configurations in parallel:
```yaml
strategy:
  matrix:
    configuration: [Release, Debug, Canary, Nightly]
```

### Custom Build Paths

Override output paths in workflow:
```yaml
- name: Build
  run: msbuild build.proj /p:OutputPath=custom-output
```

## Related Documentation

- [Build Scripts](03-Build-Scripts.md) - Local build commands
- [NuGet Packaging](06-NuGet-Packaging.md) - Package publishing
- [Version Management](05-Version-Management.md) - Version strategy
- [MSBuild Project Files](02-MSBuild-Project-Files.md) - Build targets

