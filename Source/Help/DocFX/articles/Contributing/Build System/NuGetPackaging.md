# NuGet Package Creation and Publishing

## Overview

The Krypton Toolkit build system creates NuGet packages for all five component libraries across multiple target frameworks and configurations. Packages are automatically configured with appropriate metadata, icons, dependencies, and source linking.

## Package Structure

### Core Packages

| Package | Description | Assembly |
|---------|-------------|----------|
| `Krypton.Toolkit` | Core toolkit controls | Krypton.Toolkit.dll |
| `Krypton.Ribbon` | Ribbon controls | Krypton.Ribbon.dll |
| `Krypton.Navigator` | Navigation controls | Krypton.Navigator.dll |
| `Krypton.Workspace` | Workspace controls | Krypton.Workspace.dll |
| `Krypton.Docking` | Docking system | Krypton.Docking.dll |

### Package Variants

#### Release/Stable Packages

**Standard Package** (`TFMs=all`):
- Name: `Krypton.Toolkit.{version}.nupkg`
- Frameworks: net472, net48, net481, net8.0-windows, net9.0-windows, net10.0-windows
- Use Case: Full framework support

**Lite Package** (`TFMs=lite`):
- Name: `Krypton.Toolkit.Lite.{version}.nupkg`
- Frameworks: net48, net481, net8.0-windows, net9.0-windows, net10.0-windows
- Use Case: Modern frameworks only

#### Canary Packages (Beta)

- Name: `Krypton.Toolkit.Canary.{version}-beta.nupkg`
- Frameworks: All (net472 - net10.0-windows)
- Symbol Package: `Krypton.Toolkit.Canary.{version}-beta.snupkg`
- Use Case: Beta testing

#### Nightly Packages (Alpha)

- Name: `Krypton.Toolkit.Nightly.{version}-alpha.nupkg`
- Frameworks: All (net472 - net10.0-windows)
- Symbol Package: `Krypton.Toolkit.Nightly.{version}-alpha.snupkg`
- Use Case: Nightly builds

## Package Creation Workflow

### 1. Clean Previous Packages

```cmd
msbuild build.proj /t:CleanPackages
```

**Actions**:
- Deletes all `.nupkg` files from `Bin/Packages/<Configuration>/`

### 2. Clean Build Artifacts

```cmd
msbuild build.proj /t:Clean
```

**Actions**:
- Cleans all Krypton projects
- Removes `obj/` and `bin/` directories
- Deletes intermediate NuGet assets:
  - `*.json`
  - `*.cache`
  - `*.g.targets`
  - `*.g.props`

### 3. Restore Dependencies

```cmd
msbuild build.proj /t:Restore
```

**Actions**:
- Restores NuGet packages for all Krypton projects
- Downloads dependencies
- Generates assets files

### 4. Build Projects

```cmd
msbuild build.proj /t:Build /p:TFMs=all
```

**Actions**:
- Compiles all Krypton projects
- Targets all frameworks specified by `TFMs` property
- Generates assemblies in `Bin/<Configuration>/<TFM>/`

### 5. Pack Projects

```cmd
msbuild build.proj /t:Pack /p:TFMs=all
```

**Actions**:
- Creates NuGet packages from built assemblies
- Applies configuration-specific metadata
- Generates `.nupkg` and optionally `.snupkg` files
- Outputs to `Bin/Packages/<Configuration>/`

### Complete Workflow

```cmd
cd Scripts
msbuild build.proj /t:Clean;Restore;Build;Pack /p:Configuration=Release /p:TFMs=all
```

Or use build scripts:
```cmd
cd Scripts
build-stable.cmd Build
build-stable.cmd Pack
```

## Package Metadata

### Common Metadata (All Configurations)

**From `Directory.Build.props` and `Directory.Build.targets`**:

```xml
<PropertyGroup>
    <Authors>Peter William Wagner &amp; Simon Coghlan &amp; Giduac &amp; Ahmed Abdelhameed &amp; Lesandro &amp; tobitege &amp; Thomas Bolon</Authors>
    <Copyright>© Krypton Suite 2017 - 2025. Component Factory Pty Ltd 2006 - 2016. All rights reserved.</Copyright>
    <PackageLicenseExpression>BSD-3-Clause</PackageLicenseExpression>
    <PackageRequireLicenseAcceptance>True</PackageRequireLicenseAcceptance>
    <PackageProjectUrl>https://github.com/Krypton-Suite/Standard-Toolkit</PackageProjectUrl>
    <RepositoryURL>https://github.com/Krypton-Suite/Standard-Toolkit</RepositoryURL>
    <PackageTags>Krypton ComponentFactory WinForms Themes Controls DataGrid Ribbon Workspace Tabs .NET Toolkit</PackageTags>
    <PackageReleaseNotes>Get updates here: https://github.com/Krypton-Suite/Standard-Toolkit</PackageReleaseNotes>
    <PublishRepositoryUrl>true</PublishRepositoryUrl>
    <EmbedUntrackedSources>true</EmbedUntrackedSources>
</PropertyGroup>
```

### Configuration-Specific Metadata

#### Stable Release

**Icon**: `Krypton Stable.png`

**Description Template**:
```
An update to Component factory's krypton toolkit to support .NET Framework 4.7.2 - 4.8.1 and .NET 8 - 10.
This package supports all .NET Framework versions starting .NET Framework 4.6.2 - 4.8.1 and .NET 8 - 10.
Also, all libraries are included targeting each specific framework version for performance purposes.
To view all of the standard toolkit package latest version information, please visit:
https://github.com/Krypton-Suite/Krypton-Toolkit-Suite-Version-Dashboard
```

**Files Included**:
- Icon: `Krypton Stable.png`
- License: `License.md`
- Readme: `README.md`

#### Canary (Beta)

**Icon**: `Krypton Canary.png`

**Description Addendum**:
```
This package is for those who want to try out the latest features before deployment.
```

**Changelog Link**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/canary/Documents/Help/Changelog.md`

**Symbol Packages**: Enabled (`.snupkg`)

#### Nightly (Alpha)

**Icon**: `Krypton Nightly.png`

**Description Addendum**:
```
This package is for those who want to try out the latest cutting edge features before deployment.
```

**Changelog Link**: `https://github.com/Krypton-Suite/Standard-Toolkit/blob/alpha/Documents/Help/Changelog.md`

**Symbol Packages**: Enabled (`.snupkg`)

## Package Dependencies

### Framework Dependencies

All packages automatically include framework references based on target:

**NET Framework (net472, net48, net481)**:
- System.dll
- System.Core.dll
- System.Data.dll
- System.Drawing.dll
- System.Windows.Forms.dll
- System.Xml.dll

**.NET (net8.0-windows, net9.0-windows, net10.0-windows)**:
- Microsoft.WindowsDesktop.App.WindowsForms
- Microsoft.WindowsDesktop.App.WPF (transitive)

### Inter-Package Dependencies

**Dependency Chain**:
```
Krypton.Toolkit (base)
    ↑
Krypton.Navigator
    ↑
Krypton.Workspace
    ↑
Krypton.Docking

Krypton.Ribbon → Krypton.Toolkit
```

**Example**: Installing `Krypton.Docking` automatically installs:
- Krypton.Workspace
- Krypton.Navigator
- Krypton.Toolkit

## Package Output Locations

### By Configuration

```
Bin/
├── Packages/
│   ├── Release/
│   │   ├── Krypton.Toolkit.100.25.1.305.nupkg
│   │   ├── Krypton.Toolkit.Lite.100.25.1.305.nupkg
│   │   ├── Krypton.Ribbon.100.25.1.305.nupkg
│   │   └── ...
│   ├── Canary/
│   │   ├── Krypton.Toolkit.Canary.100.25.1.305-beta.nupkg
│   │   ├── Krypton.Toolkit.Canary.100.25.1.305-beta.snupkg
│   │   └── ...
│   ├── Nightly/
│   │   ├── Krypton.Toolkit.Nightly.100.25.1.305-alpha.nupkg
│   │   ├── Krypton.Toolkit.Nightly.100.25.1.305-alpha.snupkg
│   │   └── ...
│   └── Installer/
│       └── ...
```

## Package Content Structure

### Assemblies (lib/)

```
lib/
├── net472/
│   └── Krypton.Toolkit.dll
├── net48/
│   └── Krypton.Toolkit.dll
├── net481/
│   └── Krypton.Toolkit.dll
├── net8.0-windows/
│   └── Krypton.Toolkit.dll
├── net9.0-windows/
│   └── Krypton.Toolkit.dll
└── net10.0-windows/
    └── Krypton.Toolkit.dll
```

### Package Files

```
/
├── Icon.png (package icon)
├── License.md
└── README.md
```

### Symbol Packages (.snupkg)

```
lib/
├── net472/
│   └── Krypton.Toolkit.pdb
├── net48/
│   └── Krypton.Toolkit.pdb
└── ...
```

## Publishing Packages

### Publishing to NuGet.org

#### Prerequisites

1. **NuGet Account**: Create at https://www.nuget.org
2. **API Key**: Generate at https://www.nuget.org/account/apikeys
3. **Configure Key**:
```cmd
nuget.exe setapikey <YOUR_API_KEY> -Source https://api.nuget.org/v3/index.json
```

#### Manual Publishing

```cmd
cd Scripts

# Build and pack
msbuild build.proj /t:Build;Pack

# Push to NuGet.org
msbuild build.proj /t:Push
```

Or use `publish.cmd`:
```cmd
cd Scripts
publish.cmd
```

#### Push Individual Package

```cmd
cd Bin/Packages/Release
nuget.exe push Krypton.Toolkit.100.25.1.305.nupkg -Source https://api.nuget.org/v3/index.json
```

#### Push with Symbol Package

```cmd
nuget.exe push Krypton.Toolkit.Canary.100.25.1.305-beta.nupkg -Source https://api.nuget.org/v3/index.json
# Symbol package (.snupkg) is automatically uploaded
```

### Publishing to GitHub Packages

#### Prerequisites

1. **GitHub Token**: Generate personal access token with `write:packages` scope
2. **Configure Source**:
```cmd
nuget.exe sources add -Name github -Source https://nuget.pkg.github.com/Krypton-Suite/index.json -Username USERNAME -Password TOKEN
```

#### Publish to GitHub

```cmd
nuget.exe push Krypton.Toolkit.100.25.1.305.nupkg -Source github
```

### Publishing Options

#### Skip Duplicate Packages

```cmd
dotnet nuget push *.nupkg --skip-duplicate
```

**Behavior**: Silently skips packages that already exist on server

#### Dry Run (Test Mode)

Using `ModernBuild` tool:
1. Run ModernBuild
2. Switch to NuGet page (F4)
3. Click TEST button

Shows preview of push commands without actually pushing.

## Package Verification

### Inspect Package Contents

#### Using NuGet CLI

```cmd
nuget.exe list Krypton.Toolkit -Source Bin/Packages/Release -AllVersions
```

#### Using NuGet Package Explorer

1. Download: https://github.com/NuGetPackageExplorer/NuGetPackageExplorer
2. Open `.nupkg` file
3. Inspect:
   - Package metadata
   - File contents
   - Dependencies
   - Framework targets

#### Using Command Line

```cmd
# Extract package (it's a ZIP file)
cd Bin/Packages/Release
mkdir extracted
tar -xf Krypton.Toolkit.100.25.1.305.nupkg -C extracted
dir extracted
```

### Validate Package

#### Using dotnet pack --no-build

After building:
```cmd
dotnet pack "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" --no-build --output test-packages
```

Compare with production packages.

#### Using NuGet Validator

```powershell
# Install validator
dotnet tool install --global NuGet.Validator

# Validate package
nuget-validator Krypton.Toolkit.100.25.1.305.nupkg
```

## Troubleshooting

### Package Already Exists on NuGet.org

**Symptom**: "409 Conflict" when pushing

**Cause**: Version already published

**Solutions**:
1. Use `--skip-duplicate` flag
2. Bump version (rebuild on different day)
3. Delete package from NuGet.org (within 72 hours)

### Missing Dependencies

**Symptom**: Runtime errors about missing assemblies

**Cause**: Incorrect package references

**Solution**: Verify `PackageReference` in `.csproj`:
```xml
<ItemGroup>
    <PackageReference Include="Krypton.Toolkit" Version="100.25.1.305" />
</ItemGroup>
```

### Wrong Framework Assemblies

**Symptom**: Assemblies for wrong .NET version

**Cause**: Incorrect TFM selection

**Solution**: Rebuild with correct TFMs:
```cmd
msbuild build.proj /t:Clean;Build;Pack /p:TFMs=all
```

### Symbol Package Not Uploading

**Symptom**: `.snupkg` not appearing on NuGet.org

**Cause**: Symbols not enabled or format wrong

**Solution**: Verify in `Directory.Build.targets`:
```xml
<IncludeSymbols>True</IncludeSymbols>
<SymbolPackageFormat>snupkg</SymbolPackageFormat>
```

### Package Icon Not Showing

**Symptom**: Default icon on NuGet.org

**Cause**: Icon file not embedded or path wrong

**Solution**: Verify in `Directory.Build.props`:
```xml
<None Include="../../../Assets/PNG/NuGet Package Icons/Krypton Stable.png" 
      Link="Icon.png" Pack="true" PackagePath="" />
<PackageIcon>Krypton Stable.png</PackageIcon>
```

## Advanced Scenarios

### Local Package Testing

#### Local NuGet Source

```cmd
# Create local source
mkdir C:\LocalNuGet
nuget.exe sources add -Name local -Source C:\LocalNuGet

# Copy packages
copy Bin\Packages\Release\*.nupkg C:\LocalNuGet\

# Install from local
nuget.exe install Krypton.Toolkit -Source local -OutputDirectory packages
```

#### Test Project

```xml
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>net8.0-windows</TargetFramework>
        <UseWindowsForms>true</UseWindowsForms>
    </PropertyGroup>
    
    <ItemGroup>
        <PackageReference Include="Krypton.Toolkit" Version="100.25.1.305" />
    </ItemGroup>
</Project>
```

### Automated Package Testing

```powershell
# Extract and verify
$package = "Krypton.Toolkit.100.25.1.305.nupkg"
$temp = "temp-extract"
mkdir $temp
tar -xf $package -C $temp

# Check frameworks
$frameworks = Get-ChildItem "$temp/lib" -Directory
Write-Host "Frameworks: $($frameworks.Name -join ', ')"

# Cleanup
Remove-Item $temp -Recurse -Force
```

## Best Practices

### 1. Always Clean Before Packing

```cmd
msbuild build.proj /t:Clean;Pack
```

### 2. Test Packages Locally First

Install from local source before publishing to NuGet.org.

### 3. Verify Package Contents

Use NuGet Package Explorer or extract and inspect.

### 4. Use Semantic Versioning

Follow pre-release conventions:
- `-alpha` for nightly
- `-beta` for canary
- No suffix for stable

### 5. Include Symbol Packages

Enable for pre-release packages to aid debugging:
```xml
<IncludeSymbols>True</IncludeSymbols>
<SymbolPackageFormat>snupkg</SymbolPackageFormat>
```

### 6. Document Changes

Update release notes and changelog before major releases.

## Related Documentation

- [Version Management](VersionManagement.md) - Version strategy
- [MSBuild Project Files](MSBuildProjectFiles.md) - Pack targets
- [Directory.Build Configuration](DirectoryBuildConfiguration.md) - Package metadata
- [GitHub Actions Workflows](GitHubActionsWorkflows.md) - Automated publishing
- [Build Scripts](BuildScripts.md) - Packaging commands

