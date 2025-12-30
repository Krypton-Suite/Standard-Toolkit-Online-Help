# Version Management and Versioning Strategy

## Overview

The Krypton Toolkit uses an automated, date-based semantic versioning system that generates unique version numbers based on the build date and configuration. This ensures consistent, traceable versioning across all releases without manual intervention.

## Version Format

### Structure

```
Major.Minor.Build.Revision[-Suffix]
```

### Components

| Component | Description | Value | Example |
|-----------|-------------|-------|---------|
| **Major** | Major version number (fixed) | `100` | `100` |
| **Minor** | Year of release (2 digits) | Current YY | `25` (2025) |
| **Build** | Month of release (2 digits) | Current MM | `01` (January) |
| **Revision** | Day of year (1-366) | Current DayOfYear | `305` |
| **Suffix** | Pre-release identifier | Configuration-dependent | `-alpha`, `-beta` |

### Examples

```
100.25.1.305        # Stable release on Jan 31, 2025 (day 305 of year)
100.25.1.305-beta   # Canary release on Jan 31, 2025
100.25.1.305-alpha  # Nightly release on Jan 31, 2025
```

## Configuration-Specific Versioning

### Release/Stable

**LibraryVersion**: `100.YY.MM.DayOfYear`  
**PackageVersion**: `100.YY.MM.DayOfYear`

**Example**:
```xml
<LibraryVersion>100.25.1.305</LibraryVersion>
<PackageVersion>100.25.1.305</PackageVersion>
```

**NuGet Package Names**:
- `Krypton.Toolkit.100.25.1.305.nupkg`
- `Krypton.Toolkit.Lite.100.25.1.305.nupkg` (lite variant)

**Use Cases**:
- Production releases
- Stable deployments
- Long-term support

### Canary (Beta)

**LibraryVersion**: `100.YY.MM.DayOfYear`  
**PackageVersion**: `100.YY.MM.DayOfYear-beta`

**Example**:
```xml
<LibraryVersion>100.25.1.305</LibraryVersion>
<PackageVersion>100.25.1.305-beta</PackageVersion>
```

**NuGet Package Names**:
- `Krypton.Toolkit.Canary.100.25.1.305-beta.nupkg`

**Pre-release Tag**: `-beta`

**Use Cases**:
- Beta testing
- Feature previews
- Pre-release validation

### Nightly (Alpha)

**LibraryVersion**: `100.YY.MM.DayOfYear`  
**PackageVersion**: `100.YY.MM.DayOfYear-alpha`

**Example**:
```xml
<LibraryVersion>100.25.1.305</LibraryVersion>
<PackageVersion>100.25.1.305-alpha</PackageVersion>
```

**NuGet Package Names**:
- `Krypton.Toolkit.Nightly.100.25.1.305-alpha.nupkg`

**Pre-release Tag**: `-alpha`

**Use Cases**:
- Bleeding-edge builds
- Developer testing
- Continuous integration

### Installer

**LibraryVersion**: `100.YY.MM.DayOfYear`  
**PackageVersion**: `100.YY.MM.DayOfYear`

**Special Constraint**: WiX installers require Build ≤ 256, so the month-based Build component works well.

**Use Cases**:
- Demo installers
- Setup packages
- Distribution media

## Version Calculation Implementation

### MSBuild Property Functions

Located in `Directory.Build.props`:

```xml
<PropertyGroup>
    <Minor>$([System.DateTime]::Now.ToString(yy))</Minor>
    <Build>$([System.DateTime]::Now.ToString(MM))</Build>
    <Revision>$([System.DateTime]::Now.get_DayOfYear().ToString())</Revision>
    
    <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
    <PackageVersion>100.$(Minor).$(Build).$(Revision)[-suffix]</PackageVersion>
</PropertyGroup>
```

### Date Functions

| Function | Purpose | Format | Example |
|----------|---------|--------|---------|
| `DateTime.Now.ToString(yy)` | 2-digit year | `yy` | `25` (2025) |
| `DateTime.Now.ToString(MM)` | 2-digit month | `MM` | `01` (January) |
| `DateTime.Now.get_DayOfYear()` | Day of year | `1-366` | `305` |

### Build Time Consistency

All version components are calculated **at build time**, ensuring:
- Same version across all projects in single build
- Reproducible builds on same date
- No manual version updates required

## Version Properties

### Assembly Version

**Property**: `AssemblyVersion`  
**Applied To**: All assemblies (DLLs)

**Example**:
```xml
<AssemblyVersion>100.25.1.305</AssemblyVersion>
```

**Visible In**:
- Assembly properties
- File properties dialog
- Reflection API

### File Version

**Property**: `FileVersion`  
**Applied To**: Binary files

**Example**:
```xml
<FileVersion>100.25.1.305</FileVersion>
```

**Visible In**:
- File properties dialog
- Windows Explorer details

### Informational Version

**Property**: `Version` (MSBuild) / `InformationalVersion` (Assembly)  
**Applied To**: Assemblies

**Example**:
```xml
<Version>100.25.1.305</Version>
```

**Visible In**:
- NuGet package metadata
- Assembly informational version
- `AssemblyInformationalVersionAttribute`

### Package Version

**Property**: `PackageVersion`  
**Applied To**: NuGet packages

**Example**:
```xml
<PackageVersion>100.25.1.305-beta</PackageVersion>
```

**Visible In**:
- NuGet package filename
- NuGet.org metadata
- Package dependency resolution

## Version Ordering

### Semantic Versioning Rules

NuGet follows semantic versioning (SemVer 2.0):

**Stable Release**:
```
100.25.1.305
```

**Pre-release Ordering** (lower to higher):
```
100.25.1.305-alpha    # Nightly (lowest precedence)
100.25.1.305-beta     # Canary
100.25.1.305          # Stable (highest precedence)
```

### Multiple Builds Same Day

If multiple builds occur on the same day:

**Option 1**: Sequential revision numbers
- Not currently implemented
- Would require manual intervention

**Option 2**: Time-based revision
- Could use hours/minutes
- Example: `100.25.1.30512` (day 305, 12:00)

**Current Behavior**: Same version for multiple builds on same day

## Querying Version Information

### At Build Time

From MSBuild:
```cmd
msbuild /t:Build /p:Version
```

### From Assembly

Using PowerShell:
```powershell
$dll = Get-Item "Bin/Release/net48/Krypton.Toolkit.dll"
$version = [System.Reflection.AssemblyName]::GetAssemblyName($dll.FullName).Version
Write-Host "Version: $version"
```

Using C#:
```csharp
using System.Reflection;

var assembly = Assembly.LoadFrom("Krypton.Toolkit.dll");
var version = assembly.GetName().Version;
Console.WriteLine($"Version: {version}");
```

### From NuGet Package

Using PowerShell:
```powershell
$package = Get-ChildItem "Bin/Packages/Release/*.nupkg" | Select-Object -First 1
$packageName = $package.Name
Write-Host "Package: $packageName"
```

## Version Visibility

### Where Versions Appear

1. **Assembly Attributes**
   - `AssemblyVersion`
   - `AssemblyFileVersion`
   - `AssemblyInformationalVersion`

2. **NuGet Package Metadata**
   - Package filename
   - `.nuspec` version element
   - NuGet.org listing

3. **Build Logs**
   - MSBuild output
   - CI/CD logs

4. **File Properties**
   - Windows Explorer
   - Right-click → Properties → Details

5. **Runtime**
   - `Assembly.GetName().Version`
   - Application about dialogs

## Versioning Best Practices

### 1. Never Manually Override

Let the build system calculate versions automatically to ensure consistency.

### 2. Use Pre-release Tags Correctly

- `-alpha` for nightly/unstable builds
- `-beta` for canary/preview builds
- No suffix for stable releases

### 3. Understand NuGet Versioning

Pre-releases are **not** installed by default:
```cmd
# Installs latest stable only
Install-Package Krypton.Toolkit

# Includes pre-releases
Install-Package Krypton.Toolkit -Pre
```

### 4. Version Pinning

For production, always pin to specific stable versions:
```xml
<PackageReference Include="Krypton.Toolkit" Version="100.25.1.305" />
```

Avoid floating versions in production:
```xml
<!-- Don't use in production -->
<PackageReference Include="Krypton.Toolkit" Version="100.*" />
```

### 5. CI/CD Version Retrieval

In GitHub Actions workflows:
```yaml
- name: Get Version
  id: get_version
  shell: pwsh
  run: |
    $dll = Get-Item "Bin/Release/net48/Krypton.Toolkit.dll"
    $version = [System.Reflection.AssemblyName]::GetAssemblyName($dll.FullName).Version.ToString()
    echo "version=$version" >> $env:GITHUB_OUTPUT
```

## Version History and Tracking

### Build Logs

Every build records version information:
```
Logs/stable-build-log.log
Logs/canary-build-log.log
Logs/nightly-build-log.log
```

### Git Tags

Release workflows create Git tags:
```
v100.25.1.305        # Stable
v100.25.1.305-beta   # Canary
v100.25.1.305-alpha  # Nightly
v100.25.1.305-lts    # LTS
```

### NuGet History

All published versions are tracked on NuGet.org:
- https://www.nuget.org/packages/Krypton.Toolkit
- https://www.nuget.org/packages/Krypton.Toolkit.Canary
- https://www.nuget.org/packages/Krypton.Toolkit.Nightly

## Troubleshooting

### Version Mismatch Between Builds

**Symptom**: Different projects have different versions in same build

**Cause**: Builds span midnight or year/month boundary

**Solution**: Rebuild all projects in single invocation:
```cmd
msbuild build.proj /t:Rebuild
```

### Old Version After Clean Build

**Symptom**: Version doesn't update after purge

**Cause**: Cached NuGet packages or IDE state

**Solution**:
```cmd
purge.cmd
nuget.exe locals all -clear
msbuild build.proj /t:Rebuild
```

### Pre-release Not Showing in NuGet

**Symptom**: Can't find `-alpha` or `-beta` packages

**Cause**: Pre-release filter not enabled

**Solution**:
```cmd
# Command line
nuget.exe install Krypton.Toolkit -Pre

# Visual Studio
Check "Include prerelease" in NuGet Package Manager
```

### Version Conflict in Multi-Project Solution

**Symptom**: Different Krypton assemblies have different versions

**Cause**: Mixed configurations or stale binaries

**Solution**:
```cmd
purge.cmd
msbuild build.proj /t:Rebuild /p:Configuration=Release
```

## Advanced Scenarios

### Custom Version Format

To use a custom version format, override in project:
```xml
<PropertyGroup>
    <Version>1.2.3-custom</Version>
    <AssemblyVersion>1.2.3.0</AssemblyVersion>
    <FileVersion>1.2.3.0</FileVersion>
</PropertyGroup>
```

**Warning**: This breaks automated versioning!

### Build Metadata

Add build metadata per SemVer 2.0:
```xml
<PackageVersion>100.25.1.305-beta+buildid.12345</PackageVersion>
```

**Note**: Build metadata is ignored in version precedence.

### Version Stamping from CI

Override version in CI/CD:
```cmd
msbuild build.proj /t:Pack /p:PackageVersion=100.25.1.305-ci.%BUILD_NUMBER%
```

## Related Documentation

- [Directory.Build Configuration](DirectoryBuildConfiguration.md) - Version calculation details
- [NuGet Packaging](NuGetPackaging.md) - Package versioning
- [GitHub Actions Workflows](GitHubActionsWorkflows.md) - Automated versioning
- [MSBuild Project Files](MSBuildProjectFiles.md) - Build orchestration

