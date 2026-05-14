# Build Workflow

## Overview

The Build workflow provides continuous integration (CI) for the Krypton Standard Toolkit. It validates code changes by building the solution on pull requests and pushes to main branches, ensuring build integrity before code is merged or released.

## Purpose

- **CI Validation**: Ensures all changes compile successfully
- **Multi-Target Framework Support**: Builds for multiple .NET versions
- **Pre-Release Validation**: Validates builds before they reach release workflows
- **Security**: Only builds PRs from the same repository (prevents fork-based attacks)

## Trigger Conditions

### Pull Requests

- **Branches**: All branches (`**`)
- **Types**: `opened`, `synchronize`, `reopened`
  - Runs when PR is created, updated, or reopened

### Pushes

- **Branches**:
  - `master`
  - `alpha`
  - `canary`
  - `gold`
  - `V105-LTS`
- **Path Filters**: Ignores changes to `.git*` and `.vscode` directories

### Security Filter

The build job includes a security check:

```yaml
if: github.event_name != 'pull_request' || github.event.pull_request.head.repo.full_name == github.repository
```

This ensures:

- All pushes are built
- Only PRs from the same repository are built (not forks)

## Workflow Structure

### Job 1: `build`

**Runner**: `windows-2025-vs2026` (see `.github/workflows/build.yml`)

**Purpose**: Builds the solution to validate changes

**Steps**:

1. **Checkout**
   - Uses `actions/checkout@v6`

2. **Setup .NET**
   - Uses `actions/setup-dotnet@v5`
   - Installs .NET 9.0.x and 10.0.x SDKs

3. **Setup .NET Preview**
   - Runs when repository variable `USE_DOTNET_PREVIEW` is not `false`
   - Uses `DOTNET_PREVIEW_SETUP_VERSION` with `dotnet-quality: preview` so the matching preview SDK is available on the runner

4. **Pin SDK via global.json**
   - PowerShell resolves the SDK version from `dotnet --list-sdks` (latest stable 10.x, fallback 9.x)
   - Writes `global.json` with `rollForward: latestFeature`

5. **Setup MSBuild**
   - Uses `microsoft/setup-msbuild@v3`, x64

6. **Setup NuGet**
   - Uses `NuGet/setup-nuget@v4`

7. **Cache NuGet**
   - Uses `actions/cache@v5` on `~/.nuget/packages`

8. **Restore**
   - `dotnet restore` on `Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.slnx` with `TFMs=all`

9. **Build**
   - `msbuild Scripts/Build/nightly.proj /t:Rebuild ...`

### Job 2: `release`

**Runner**: `windows-2025-vs2026`

**Condition**: Only runs on `master` branch pushes

**Purpose**: Prepares release artifacts (builds and packages)

**Dependencies**: Requires `build` job to complete successfully

**Steps**:

1. **Checkout** - Same as build job

2. **Setup .NET** - Same as build job

3. **Pin SDK via global.json** - Same stable pin as build job (10.x → 9.x)

4. **Setup MSBuild** - Same as build job

5. **Setup NuGet** - Same as build job

6. **Cache NuGet** - Same as build job

7. **Restore** - Same solution restore as build job (`*.slnx`)

8. **Build Release**
   - Uses `Scripts/Build/build.proj` instead of `nightly.proj`
   - Configuration: `Release`
   - Platform: `Any CPU`
   - Target: `Build`

9. **Pack Release**
   - Uses `Scripts/Build/build.proj`
   - Configuration: `Release`
   - Platform: `Any CPU`
   - Target: `Pack`
   - Creates NuGet packages in `Bin/Packages/Release/`

10. **Get Version**
    - Extracts version from built assembly or project file
    - Sets output variables: `version` and `tag`
    - Fallback version: `100.25.1.1` if extraction fails

## Detailed Behavior

### .NET SDK Management

The workflow writes **`Pin SDK via global.json`**: PowerShell picks the latest listed **10.0.*.* SDK**, then falls back to **9.0.*.***, using the same `Get-ListedSdkVersion` helper pattern as other workflows. Fail the step if neither line exists.

Preview SDK installation is conditional on **`USE_DOTNET_PREVIEW`** (repository variable); version comes from **`DOTNET_PREVIEW_SETUP_VERSION`**.

**Benefits**:

- Avoids null `.ToString()` on empty `Select-String` results
- Pins a concrete `sdk.version` with `rollForward: latestFeature`

### Build Projects

**Build Job**:

- Uses `Scripts/Build/nightly.proj`
- Rebuilds everything from scratch
- Validates full build process

**Release Job**:

- Uses `Scripts/Build/build.proj`
- Standard release build configuration
- Creates packages for distribution

### NuGet Caching

**Cache Strategy**:

- **Key**: `${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}`
- **Path**: `~/.nuget/packages`
- **Restore Keys**: Falls back to partial match if exact key not found

**Benefits**:

- Faster builds by reusing packages
- Reduces network traffic
- Speeds up CI pipeline

### Version Extraction

The release job attempts multiple methods to extract version:

1. **Assembly Version** (Primary)
   - Reads version from built DLL
   - Most reliable method

2. **Project File** (Fallback)
   - Parses XML from `.csproj` file
   - Extracts `<Version>` element

3. **Hardcoded Fallback**
   - Uses `100.25.1.1` if all methods fail
   - Ensures workflow doesn't fail due to version issues

## Build Artifacts

### Build Job Outputs

- Compiled assemblies in `Bin/Release/` or `Bin/Nightly/`
- Organized by target framework (e.g., `net48`, `net8.0-windows`)

### Release Job Outputs

- NuGet packages in `Bin/Packages/Release/`
- Version information in job outputs

## Target Frameworks

The solution builds for multiple target frameworks:

- **.NET Framework**: 4.7.2, 4.8, 4.8.1
- **.NET**: 8.0, 9.0, 10.0 (Windows-specific)

All frameworks are built in a single workflow run.

## Configuration

### No Secrets Required

The build workflow doesn't require any secrets. It only validates builds and doesn't publish packages.

### Required Tools

- .NET 9.0.x and 10.0.x SDKs (installed by workflow)
- MSBuild (installed by workflow)
- NuGet (installed by workflow)

## Troubleshooting

### Build Failures

**Common Causes**:

1. **Compilation Errors**: Check code for syntax or type errors
2. **Missing Dependencies**: Verify all NuGet packages restore correctly
3. **SDK Version Issues**: Check `global.json` generation in logs
4. **MSBuild Errors**: Review build logs for specific errors

**Solutions**:

- Review build logs in Actions tab
- Test builds locally with same SDK versions
- Check for breaking changes in dependencies
- Verify project file configurations

### NuGet Restore Failures

**Possible Causes**:

1. Network issues
2. Package source unavailable
3. Invalid package references
4. Cache corruption

**Solutions**:

- Check NuGet package sources
- Clear cache and retry
- Verify package versions exist
- Review `nuget.config` if present

### Version Extraction Failures

**Behavior**: Workflow continues with fallback version

**Solutions**:

- Check if assembly was built successfully
- Verify project file has `<Version>` element
- Review version extraction script in logs

### PR from Fork Not Building

**Expected Behavior**: This is a security feature

**Reason**: Prevents potential security risks from untrusted code

**Solution**: Fork PRs should be merged via a branch in the main repository

## Usage Examples

- **Submit a Pull Request**: Create a PR from your branch; the build workflow runs automatically to validate the changes.
- **Validate Before Merge**: Push to your branch and open a PR; fix any build failures before merging.
- **Release Build**: On push to `master`, the release job builds and packs NuGet packages.

## Related Workflows

- **Release Workflow**: Uses similar build process for publishing
- **Nightly Workflow**: Uses `nightly.proj` for scheduled builds

## Code Reference

**File**: `.github/workflows/build.yml`

**Key Components**:

- Event: `pull_request` and `push`
- Jobs: `build` and `release`
- Build Tools: MSBuild, .NET SDK, NuGet

## Maintenance Notes

### Updating .NET Versions

To add support for new .NET versions:

1. Add version to `Setup .NET` step:

   ```yaml
   dotnet-version: |
     9.0.x
     10.0.x
     11.0.x  # New version
   ```

2. Update `global.json` generation if needed
3. Test with sample PR

### Modifying Build Projects

If build project files change:

1. Update paths in workflow steps
2. Verify target names (`Build`, `Pack`, `Rebuild`)
3. Test configuration changes

### Cache Invalidation

To force cache refresh:

- Modify a `.csproj` file (changes hash)
- Or manually clear cache in Actions settings

## Best Practices

1. **Keep Builds Fast**: Leverage caching and parallel builds
2. **Fail Fast**: Build should fail on any compilation error
3. **Consistent Environments**: Use same SDK versions as local development
4. **Clear Logs**: Ensure build output is readable and actionable
