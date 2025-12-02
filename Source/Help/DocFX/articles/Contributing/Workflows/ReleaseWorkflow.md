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
- `alpha` - Alpha/nightly releases
- `canary` - Canary pre-releases
- `V105-LTS` - Long-Term Support v105 branch
- `V85-LTS` - Long-Term Support v85 branch

**Note**: Each branch has its own job that only runs for that specific branch.

## Workflow Structure

The workflow contains five separate jobs, each handling a different release type:

1. **`release-master`** - Stable releases from master branch
2. **`release-v105-lts`** - LTS releases from V105-LTS branch
3. **`release-v85-lts`** - LTS releases from V85-LTS branch
4. **`release-canary`** - Canary releases from canary branch
5. **`release-alpha`** - Alpha releases from alpha branch

### Common Job Structure

All jobs follow a similar pattern:

1. **Kill Switch Check** - Verifies if workflow is disabled
2. **Checkout** - Checks out source code
3. **Setup .NET** - Installs .NET SDKs
4. **Force .NET 10 SDK** - Creates `global.json`
5. **Setup MSBuild** - Configures MSBuild
6. **Setup NuGet** - Configures NuGet
7. **Cache NuGet** - Caches packages
8. **Restore** - Restores dependencies
9. **Build** - Builds the solution
10. **Pack** - Creates NuGet packages
11. **Push NuGet** - Publishes to nuget.org
12. **Get Version** - Extracts version information
13. **Discord Announcement** - Sends notification

## Detailed Job Descriptions

### Job 1: `release-master`

**Condition**: `github.ref == 'refs/heads/master' && github.event_name == 'push'`

**Kill Switch**: `RELEASE_DISABLED`

**Project File**: `Scripts/build.proj`

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

**Project File**: `Scripts/build.proj`

**Configuration**: `Release`

**Output Location**: `Bin/Packages/Release/`

**Discord Webhook**: `DISCORD_WEBHOOK_MASTER`

**Packages**: Same as master (stable packages)

**Version Source**: Same as master

**Tag Format**: `v{version}`

**Discord Color**: `77dd76` (green)

**Changelog**: `Documents/Changelog/Changelog.md` on V105-LTS branch

**Note**: Uses same webhook as master but different changelog location.

### Job 3: `release-v85-lts`

**Condition**: `github.ref == 'refs/heads/V85-LTS' && github.event_name == 'push'`

**Kill Switch**: `LTS_DISABLED`

**Project File**: `Scripts/longtermstable.proj`

**Configuration**: `Release`

**Output Location**: `Bin/Packages/Release/`

**Discord Webhook**: `DISCORD_WEBHOOK_LTS`

**Packages**:
- Krypton.Toolkit.LTS
- Krypton.Ribbon.LTS
- Krypton.Navigator.LTS
- Krypton.Workspace.LTS
- Krypton.Docking.LTS

**Version Source**: `Bin/Release/net48/Krypton.Toolkit.dll` or `Krypton.Toolkit 2022.csproj`

**Tag Format**: `v{version}-lts`

**Discord Color**: `0094ff` (blue)

**Changelog**: `Documents/Help/Changelog.md` on V85-LTS branch

**Target Frameworks**: .NET Framework 4.6.2, 4.7, 4.7.1, 4.7.2, 4.8, 4.8.1, .NET 6.0, 7.0, 8.0

**Special Note**: Uses .NET 6, 7, and 8 SDKs (not 9 and 10) for compatibility with older frameworks.

### Job 4: `release-canary`

**Condition**: `github.ref == 'refs/heads/canary' && github.event_name == 'push'`

**Kill Switch**: `CANARY_DISABLED`

**Project File**: `Scripts/canary.proj`

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

### Job 5: `release-alpha`

**Condition**: `github.ref == 'refs/heads/alpha' && github.event_name == 'push'`

**Kill Switch**: `NIGHTLY_DISABLED`

**Project File**: `Scripts/nightly.proj`

**Configuration**: `Nightly`

**Output Location**: `Bin/Packages/Nightly/` (not published)

**Discord Webhook**: None (publishing handled by nightly.yml)

**Packages**: Built but not published (nightly.yml handles publishing)

**Note**: This job only builds and packs. NuGet publishing is intentionally skipped as it's handled by the scheduled nightly workflow which includes change detection.

## Detailed Behavior

### Kill Switches

Each job has its own kill switch variable:

| Job | Variable | Purpose |
|-----|----------|---------|
| release-master | `RELEASE_DISABLED` | Disable stable releases |
| release-v105-lts | `RELEASE_DISABLED` | Disable V105 LTS releases |
| release-v85-lts | `LTS_DISABLED` | Disable V85 LTS releases |
| release-canary | `CANARY_DISABLED` | Disable canary releases |
| release-alpha | `NIGHTLY_DISABLED` | Disable alpha builds |

**Location**: Repository Settings → Secrets and variables → Actions → Variables

**Implementation**: All steps after kill switch check are conditional:
```yaml
if: steps.{kill_switch_id}.outputs.enabled == 'true'
```

### .NET SDK Versions

**Most Jobs** (master, V105-LTS, canary, alpha):
- .NET 9.0.x
- .NET 10.0.x

**V85-LTS Job**:
- .NET 6.0.x
- .NET 7.0.x
- .NET 8.0.x

**Reason**: V85-LTS supports older frameworks that require earlier SDKs.

### Build Projects

Each job uses a different project file:

| Job | Project File | Purpose |
|-----|--------------|---------|
| release-master | `Scripts/build.proj` | Standard release build |
| release-v105-lts | `Scripts/build.proj` | Standard release build |
| release-v85-lts | `Scripts/longtermstable.proj` | LTS-specific build |
| release-canary | `Scripts/canary.proj` | Canary-specific build |
| release-alpha | `Scripts/nightly.proj` | Nightly/alpha build |

### NuGet Publishing

**Process**:
1. Scans for `.nupkg` files in package directory
2. Pushes each package with `--skip-duplicate` flag
3. Tracks if any packages were actually published
4. Continues on individual package failures

**Package Detection**:
- Master/V105-LTS: `Bin/Packages/Release/*.nupkg`
- V85-LTS: `Bin/Packages/Release/*.nupkg`
- Canary: `Bin/Packages/Canary/*.nupkg`
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
   - Master/V105-LTS/Canary/Alpha: `100.25.1.1`
   - V85-LTS: `85.25.1.1`

**Output Variables**:
- `version` - Version number
- `tag` - Git tag format (varies by job)

### Discord Notifications

**Trigger**: Only if packages were published (`packages_published == 'True'`)

**Webhooks**:
- Master/V105-LTS: `DISCORD_WEBHOOK_MASTER`
- V85-LTS: `DISCORD_WEBHOOK_LTS`
- Canary: `DISCORD_WEBHOOK_CANARY`
- Alpha: None (handled by nightly.yml)

**Message Structure**:
- Title (varies by release type)
- Description
- Version field
- NuGet package links
- Target frameworks list
- Changelog link
- Timestamp

**Colors**:
- Master/V105-LTS: `77dd76` (green)
- V85-LTS: `0094ff` (blue)
- Canary: `16776960` (yellow)

## Configuration

### Required Secrets

- **`NUGET_API_KEY`**: API key for nuget.org publishing
  - Required for all jobs that publish packages
  - Get from: https://www.nuget.org/account/apikeys

- **`DISCORD_WEBHOOK_MASTER`**: Webhook for stable releases
  - Used by: master and V105-LTS jobs

- **`DISCORD_WEBHOOK_LTS`**: Webhook for LTS releases
  - Used by: V85-LTS job

- **`DISCORD_WEBHOOK_CANARY`**: Webhook for canary releases
  - Used by: canary job

**Note**: Webhooks are optional. Workflow continues if not set.

### Required Variables

- **`RELEASE_DISABLED`**: Kill switch for stable releases
  - Affects: master and V105-LTS jobs

- **`LTS_DISABLED`**: Kill switch for LTS releases
  - Affects: V85-LTS job

- **`CANARY_DISABLED`**: Kill switch for canary releases
  - Affects: canary job

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

## Related Workflows

- **Build Workflow**: Similar build process for CI
- **Nightly Workflow**: Handles scheduled alpha builds with change detection

## Code Reference

**File**: `.github/workflows/release.yml`

**Key Components**:
- Event: `push` to release branches
- Jobs: 5 separate jobs for different release types
- Kill Switches: Branch-specific disable controls

## Maintenance Notes

### Adding New Release Branch

To add support for a new release branch:

1. Create new job in workflow file:
   ```yaml
   release-new-branch:
     runs-on: windows-latest
     if: github.ref == 'refs/heads/new-branch' && github.event_name == 'push'
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

```
Push to Release Branch
    │
    ├─> Determine Branch Type
    │   ├─> master → release-master
    │   ├─> V105-LTS → release-v105-lts
    │   ├─> V85-LTS → release-v85-lts
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
|------|--------|-------------|---------|--------|---------|------------|
| Stable | master | RELEASE_DISABLED | build.proj | Release | MASTER | v{version} |
| LTS v105 | V105-LTS | RELEASE_DISABLED | build.proj | Release | MASTER | v{version} |
| LTS v85 | V85-LTS | LTS_DISABLED | longtermstable.proj | Release | LTS | v{version}-lts |
| Canary | canary | CANARY_DISABLED | canary.proj | Canary | CANARY | v{version}-canary |
| Alpha | alpha | NIGHTLY_DISABLED | nightly.proj | Nightly | None | N/A |

