# Release Workflow

## Overview

The Release workflow handles automated releases for multiple branch types: stable releases (master), Long-Term Support (LTS) branches, canary pre-releases, and alpha builds. It builds, packages, and publishes NuGet packages to nuget.org with Discord notifications for each release type.

## Purpose

- **Automated Releases**: Publishes packages automatically on branch pushes
- **Multi-Branch Support**: Handles different release types with appropriate configurations
- **NuGet Publishing**: Automatically publishes to nuget.org
- **Community Notifications**: Announces releases via Discord with branch-specific webhooks
- **Kill Switch Controls**: Emergency disabling capability for each release type

## Trigger Conditions

### Push Events

The workflow triggers on pushes to:

- `master` - Stable production releases
- `alpha` - Alpha / nightly-style builds (`release-alpha`; publishing often driven by `nightly.yml`)
- `canary` - Canary pre-releases
- `V105-LTS` - LTS line (`release-v105-lts`; stable packages, same `build.proj` as master)

**Note**: Each branch has its own job that only runs when `github.ref` matches that branch (`workflow_dispatch` also supported).

## Workflow Structure

The workflow contains **four** jobs:

1. **`release-master`** - Stable releases from `master`
2. **`release-v105-lts`** - Releases from **`V105-LTS`**
3. **`release-canary`** - Canary releases from `canary`
4. **`release-alpha`** - Alpha builds from `alpha` (pack only; scheduled publishing via `nightly.yml`)

### Common Job Structure

All jobs follow a similar pattern:

1. **Kill Switch Check** - Verifies if workflow is disabled
2. **Checkout** - Checks out source code
3. **Setup .NET** - Installs .NET SDKs
4. **Setup .NET Preview** - Installs preview SDK when repository variable `USE_DOTNET_PREVIEW` is not `false` (version from `DOTNET_PREVIEW_SETUP_VERSION`)
5. **Pin SDK via global.json** - Writes repo-root `global.json` (stable 10.x/9.x or preview band per `USE_DOTNET_PREVIEW`, `DOTNET_PREVIEW_SDK_BAND`)
6. **Setup MSBuild** - Configures MSBuild
7. **Setup NuGet** - Configures NuGet
8. **Cache NuGet** - Caches packages
9. **Restore** - Restores dependencies
10. **Build** - Builds the solution
11. **Pack** - Creates NuGet packages
12. **Push NuGet** - Publishes to nuget.org
13. **Get Version** - Extracts version information
14. **Discord Announcement** - Sends notification

## Detailed Job Descriptions

### Job 1: `release-master`

**Condition**: `github.ref == 'refs/heads/master' && github.event_name == 'push'`

**Kill Switch**: `RELEASE_DISABLED`

**Project File**: `Scripts/Build/build.proj`

**Configuration**: `Release`

**Output Location**: `Bin/Packages/Release/`

**Discord Webhook**: `DISCORD_WEBHOOK_MASTER`

**Packages**:

- Krypton.Toolkit
- Krypton.Ribbon
- Krypton.Navigator
- Krypton.Workspace
- Krypton.Docking
- Krypton.Standard.Toolkit

**Version Source**: `Bin/Release/net48/Krypton.Toolkit.dll` or `Krypton.Toolkit 2022.csproj`

**Tag Format**: `v{version}`

**Discord Color**: `77dd76` (green)

**Changelog**: `Documents/Changelog/Changelog.md` on master branch

### Job 2: `release-v105-lts`

**Condition**: `github.ref == 'refs/heads/V105-LTS' && github.event_name == 'push'`

**Kill Switch**: `RELEASE_DISABLED`

**Project File**: `Scripts/Build/build.proj`

**Configuration**: `Release`

**Output Location**: `Bin/Packages/Release/`

**Discord Webhook**: `DISCORD_WEBHOOK_MASTER`

**Packages**: Same as master (stable packages)

**Version Source**: Same as master

**Tag Format**: `v{version}`

**Discord Color**: `77dd76` (green)

**Changelog**: `Documents/Changelog/Changelog.md` on V105-LTS branch

**Note**: Uses same webhook as master but different changelog location.

### Job 3: `release-canary`

**Condition**: `github.ref == 'refs/heads/canary' && (github.event_name == 'push' || github.event_name == 'workflow_dispatch')`

**Kill Switch**: `CANARY_DISABLED`

**Project File**: `Scripts/Build/canary.proj`

**Configuration**: `Canary`

**Output Location**: `Bin/Packages/Canary/`

**Discord Webhook**: `DISCORD_WEBHOOK_CANARY`

**Packages**:

- Krypton.Toolkit.Canary
- Krypton.Ribbon.Canary
- Krypton.Navigator.Canary
- Krypton.Workspace.Canary
- Krypton.Docking.Canary
- Krypton.Standard.Toolkit.Canary

**Version Source**: `Bin/Canary/net48/Krypton.Toolkit.dll` or `Krypton.Toolkit 2022.csproj`

**Tag Format**: `v{version}-canary`

**Discord Color**: `16776960` (yellow)

**Changelog**: `Documents/Changelog/Changelog.md` on canary branch

### Job 4: `release-alpha`

**Condition**: `github.ref == 'refs/heads/alpha' && (github.event_name == 'push' || github.event_name == 'workflow_dispatch')`

**Kill Switch**: `NIGHTLY_DISABLED`

**Project File**: `Scripts/Build/nightly.proj`

**Configuration**: `Nightly`

**Output Location**: `Bin/Packages/Nightly/` (not published)

**Discord Webhook**: None (publishing handled by nightly.yml)

**Packages**: Built but not published (nightly.yml handles publishing)

**Note**: This job only builds and packs. NuGet publishing is intentionally skipped as it's handled by the scheduled nightly workflow which includes change detection.

## Detailed Behavior

### Kill Switches

Each job has its own kill switch variable:

| Job | Variable | Purpose |
| --- | --- | --- |
| release-master | `RELEASE_DISABLED` | Disable stable releases |
| release-v105-lts | `RELEASE_DISABLED` | Disable V105-LTS releases |
| release-canary | `CANARY_DISABLED` | Disable canary releases |
| release-alpha | `NIGHTLY_DISABLED` | Disable alpha builds |

**Location**: Repository Settings → Secrets and variables → Actions → Variables

**Implementation**: All steps after kill switch check are conditional:

```yaml
if: steps.{kill_switch_id}.outputs.enabled == 'true'
```

### .NET SDK Versions

**Typical setup** (`release-master`, **`release-v105-lts`**, `release-canary`, `release-alpha`):

- Install **.NET 9.0.x** and **10.0.x**.
- **`release-master`** and **`release-canary`** also run **Setup .NET Preview** when repository variable **`USE_DOTNET_PREVIEW`** is not `false`, then **Pin SDK via global.json** (preview band or stable per [`DOTNET_PREVIEW_SDK_BAND`](../GitHubActionsWorkflows.md#repository-variables-net-preview--ci)).
- **`release-v105-lts`** pins **stable** SDKs only in **Pin SDK via global.json** (no preview setup step).

See [`Build System/Current/ReleaseWorkflow.md`](../Build%20System/Current/ReleaseWorkflow.md) for authoritative step-by-step detail.

### Build Projects

Each job uses a different project file:

| Job | Project File | Purpose |
| --- | --- | --- |
| release-master | `Scripts/Build/build.proj` | Stable release build |
| release-v105-lts | `Scripts/Build/build.proj` | Same as master; branch **V105-LTS** |
| release-canary | `Scripts/Build/canary.proj` | Canary build |
| release-alpha | `Scripts/Build/nightly.proj` | Nightly configuration / alpha branch |

### NuGet Publishing

**Process**:

1. Scans for `.nupkg` files in package directory
2. Pushes each package with `--skip-duplicate` flag
3. Tracks if any packages were actually published
4. Continues on individual package failures

**Package Detection**:

- `master` / **V105-LTS**: `Bin/Packages/Release/*.nupkg` (and `artifacts/packages/Release/` when using artifact output)
- **Canary**: `Bin/Packages/Canary/*.nupkg`
- Alpha: `Bin/Packages/Nightly/*.nupkg` (not published)

**Required Secret**: `NUGET_API_KEY`

**Output Variable**: `packages_published` (true/false)

### Version Extraction

**Methods** (in order of preference):

1. **Assembly Version** (Primary)
   - Reads from built DLL using reflection
   - Path varies by job (Release/Canary/Nightly)

2. **Project File** (Fallback)
   - Parses XML from `.csproj` file
   - Extracts `<Version>` element

3. **Hardcoded Fallback**
   - Default fallback (e.g. `100.25.1.1`) when extraction fails

**Output Variables**:

- `version` - Version number
- `tag` - Git tag format (varies by job)

### Discord Notifications

**Trigger**: Only if packages were published (`packages_published == 'True'`)

**Webhooks**:

- Master / **V105-LTS**: `DISCORD_WEBHOOK_MASTER`
- Canary: `DISCORD_WEBHOOK_CANARY`
- Alpha: None in this workflow (see **nightly.yml**)

**Message Structure**:

- Title (varies by release type)
- Description
- Version field
- NuGet package links
- Target frameworks list
- Changelog link
- Timestamp

**Colors**:

- Master / **V105-LTS**: `77dd76` (green)
- Canary: `16776960` (yellow)

## Configuration

### Required Secrets

- **`NUGET_API_KEY`**: API key for nuget.org publishing
  - Required for all jobs that publish packages
  - Get from: https://www.nuget.org/account/apikeys

- **`DISCORD_WEBHOOK_MASTER`**: Stable / **V105-LTS** notifications (`release-master`, `release-v105-lts`)

- **`DISCORD_WEBHOOK_CANARY`**: Canary notifications

**Note**: There is **no** `DISCORD_WEBHOOK_LTS` in current `release.yml`; **V105-LTS** reuses **`DISCORD_WEBHOOK_MASTER`**.

**Note**: Webhooks are optional. Workflow continues if not set.

### Required Variables

- **`RELEASE_DISABLED`**: Kill switch for **`release-master`** and **`release-v105-lts`**

- **`CANARY_DISABLED`**: Kill switch for canary releases

- **`NIGHTLY_DISABLED`**: Kill switch for alpha builds
  - Affects: alpha job

## Troubleshooting

### Job Not Running

**Possible Causes**:

1. Wrong branch pushed to
2. Kill switch enabled
3. Workflow file syntax errors
4. Branch condition not met

**Solutions**:

- Verify branch name matches job condition
- Check kill switch variable in repository settings
- Review workflow logs for errors
- Confirm push event occurred

### Build Failures

**Common Causes**:

1. Missing project file
2. Incorrect configuration name
3. SDK version mismatches
4. Compilation errors

**Solutions**:

- Verify project file exists at specified path
- Check configuration name matches project file
- Ensure correct SDK versions installed
- Review build logs for specific errors

### NuGet Publishing Failed

**Possible Causes**:

1. Missing or invalid `NUGET_API_KEY`
2. Package version already exists (handled gracefully)
3. Invalid package format
4. Network issues

**Solutions**:

- Verify API key is set and valid
- Check if package version already exists (this is normal)
- Review NuGet push logs
- Verify package files are valid

### Discord Notification Not Sent

**Possible Causes**:

1. No packages were published (expected if duplicates)
2. Missing webhook secret
3. Invalid webhook URL
4. Discord API issues

**Solutions**:

- Check `packages_published` output in logs
- Verify webhook secret is set
- Test webhook URL manually
- Check Discord server settings

### Version Extraction Failed

**Behavior**: Uses fallback version

**Solutions**:

- Verify build completed successfully
- Check if DLL exists at expected path
- Review version extraction logs
- Ensure project file has `<Version>` element

### Wrong Project File Used

**Issue**: Job uses incorrect project file

**Solution**: Verify job condition matches intended branch and update project file reference if needed

## Usage Examples

- **Create a Stable Release**: Push to `master`; the release-master job builds, packs, and publishes to NuGet.
- **Create an LTS-line release**: Push to **`V105-LTS`**; **`release-v105-lts`** publishes stable packages (same IDs as master).
- **Create a Canary Pre-Release**: Push to `canary`; the release-canary job publishes Canary packages.

## Related Workflows

- **Build Workflow**: Similar build process for CI
- **Nightly Workflow**: Handles scheduled alpha builds with change detection

## Code Reference

**File**: `.github/workflows/release.yml`

**Key Components**:

- Event: `push` to release branches
- Jobs: **four** branch-specific jobs (`release-master`, `release-v105-lts`, `release-canary`, `release-alpha`)
- Kill Switches: Branch-specific disable controls

## Maintenance Notes

### Adding New Release Branch

To add support for a new release branch:

1. Create new job in workflow file:

   ```yaml
   release-new-branch:
     runs-on: windows-2025-vs2026
     if: github.ref == 'refs/heads/new-branch' && (github.event_name == 'push' || github.event_name == 'workflow_dispatch')
   ```

2. Configure kill switch variable
3. Set appropriate project file and configuration
4. Configure Discord webhook if needed
5. Update package paths and naming

### Modifying Kill Switches

To change kill switch behavior:

1. Update variable name in job
2. Update check logic in kill switch step
3. Update all conditional steps
4. Document in this file

### Updating .NET Versions

To change SDK versions:

1. Update `Setup .NET` step with new versions
2. Update `global.json` generation if needed
3. Test with sample push

### Changing Package Names

If package naming changes:

1. Update Discord notification message
2. Verify package paths in publishing step
3. Update documentation

## Best Practices

1. **Branch Strategy**: Keep release branches separate and well-defined
2. **Kill Switches**: Use for maintenance or emergency stops
3. **Version Management**: Ensure versions increment correctly
4. **Testing**: Test release process on non-production branches first
5. **Notifications**: Keep Discord webhooks updated
6. **Security**: Never commit secrets or API keys
7. **Documentation**: Update this file when making changes

## Workflow Flow Diagram

```text
Push to Release Branch
    │
    ├─> Determine Branch Type
    │   ├─> master → release-master
    │   ├─> V105-LTS → release-v105-lts
    │   ├─> canary → release-canary
    │   └─> alpha → release-alpha
    │
    ├─> Kill Switch Check
    │   └─> If disabled: Exit
    │
    ├─> Checkout Branch
    │
    ├─> Setup .NET SDKs
    │   └─> (Version depends on job)
    │
    ├─> Setup Build Tools
    │
    ├─> Restore & Build
    │   └─> (Project file depends on job)
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
        └─> (Webhook depends on job)
```

## Release Type Comparison

| Type | Branch | Kill Switch | Project | Config | Webhook | Tag Format |
| --- | --- | --- | --- | --- | --- | --- |
| Stable | master | RELEASE_DISABLED | Scripts/Build/build.proj | Release | MASTER | v{version} |
| LTS (v105) | V105-LTS | RELEASE_DISABLED | Scripts/Build/build.proj | Release | MASTER | v{version} |
| Canary | canary | CANARY_DISABLED | Scripts/Build/canary.proj | Canary | CANARY | v{version}-canary |
| Alpha | alpha | NIGHTLY_DISABLED | Scripts/Build/nightly.proj | Nightly | — | N/A |
