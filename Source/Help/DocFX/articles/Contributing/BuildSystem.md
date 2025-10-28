# Krypton Toolkit - Build System Guide

## Table of Contents

- [Overview](#overview)
- [Build Scripts](#build-scripts)
- [Project Structure](#project-structure)
- [Multi-Targeting](#multi-targeting)
- [Package Configuration](#package-configuration)
- [Local Development](#local-development)
- [Build Customization](#build-customization)
- [Reference](#reference)

---

## Overview

The Krypton Toolkit build system uses MSBuild project files (`.proj`) to orchestrate building, packaging, and distributing the toolkit across multiple target frameworks and release channels.

### Build System Components

```
Scripts/
├── build.proj              # Master/stable releases
├── longtermstable.proj     # V85-LTS releases  
├── canary.proj             # Canary pre-releases
├── nightly.proj            # Nightly/alpha builds
└── Batch Files/            # Convenience batch scripts
    ├── build-stable.cmd
    ├── build-canary.cmd
    └── build-nightly.cmd
```

### Key Concepts

- **Multi-targeting**: Single build produces DLLs for multiple .NET versions
- **Configuration-based**: Different builds for Debug, Release, Nightly, Canary, LTS
- **Modular**: Separate projects for Toolkit, Ribbon, Navigator, Workspace, Docking
- **Automated**: MSBuild orchestrates entire build → pack → publish pipeline

---

## Build Scripts

### build.proj - Stable Releases

**Used By**: Master branch  
**Configuration**: `Release`  
**Output**: `Bin/Release/`, `Bin/Packages/Release/`

#### Target Frameworks

**Default** (lite packages):

- net48, net481, net8.0-windows, net9.0-windows, net10.0-windows

**With `TFMs=all`** (full packages):

- net472, net48, net481, net8.0-windows, net9.0-windows, net10.0-windows

#### Key Targets

**Clean**:

```cmd
msbuild build.proj /t:Clean /p:Configuration=Release
```

Removes all build outputs from `Bin/Release/`

**Restore**:

```cmd
msbuild build.proj /t:Restore /p:Configuration=Release /p:TFMs=all
```

Restores NuGet packages for all Krypton.* projects

**Build**:

```cmd
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=all
```

Compiles all projects with specified target frameworks

**Pack**:

```cmd
msbuild build.proj /t:Pack /p:Configuration=Release
```

Special behavior - creates TWO sets of packages:

1. **PackLite**: Uses `TFMs=lite` (default frameworks)
2. **PackAll**: Uses `TFMs=all` (includes net472)

**CleanPackages**:

```cmd
msbuild build.proj /t:CleanPackages
```

Removes existing `.nupkg` files from `Bin/Packages/Release/`

**CreateAllReleaseArchives**:

```cmd
msbuild build.proj /t:CreateAllReleaseArchives /p:Configuration=Release
```

Creates ZIP and TAR.GZ archives:

- Output: `Bin/Release/Zips/Krypton-Release_YYYYMMDD.zip`
- Output: `Bin/Release/Zips/Krypton-Release_YYYYMMDD.tar.gz`

Methods used (in order of preference):

1. 7-Zip (if available at `C:\Program Files\7-Zip\7z.exe`)
2. PowerShell `Compress-Archive`
3. Windows tar command
4. Git Bash tar

**Push** (local development only):

```cmd
set NUGET_API_KEY=your-key
msbuild build.proj /t:Push /p:Configuration=Release
```

Pushes packages matching pattern: `*.$(LibraryVersion).nupkg`

**Note**: GitHub Actions workflows handle pushing with enhanced error handling

---

### longtermstable.proj - LTS Releases

**Used By**: V85-LTS branch  
**Configuration**: `Release`  
**Output**: `Bin/Release/`, `Bin/Packages/Release/`  
**Package Names**: `Krypton.*.LTS`

#### Target Frameworks (9 total)

```
.NET Framework 4.6.2  (net462)
.NET Framework 4.7    (net47)
.NET Framework 4.7.1  (net471)
.NET Framework 4.7.2  (net472)
.NET Framework 4.8    (net48)
.NET Framework 4.8.1  (net481)
.NET 6.0 Windows      (net6.0-windows)
.NET 7.0 Windows      (net7.0-windows)
.NET 8.0 Windows      (net8.0-windows)
```

**Note**: Broadest framework support for maximum compatibility

#### Key Differences from build.proj

1. **No PackLite/PackAll split** - Only `PackAll` target
2. **Different package IDs** - Configured in V85-LTS branch's `.csproj` files
3. **Stable SDKs only** - Uses .NET 6, 7, 8 (no 9 or 10)
4. **Legacy support** - Includes net462 (2015), net47, net471

#### Usage

```cmd
REM Build LTS packages
msbuild longtermstable.proj /t:Build /p:Configuration=Release /p:TFMs=all

REM Pack LTS packages
msbuild longtermstable.proj /t:Pack /p:Configuration=Release

REM View created packages
dir ..\Bin\Packages\Release\*.LTS.*.nupkg
```

---

### canary.proj - Pre-Release Builds

**Used By**: Canary branch  
**Configuration**: `Canary`  
**Output**: `Bin/Canary/`, `Bin/Packages/Canary/`

#### Target Frameworks (6 total)

```
net472
net48
net481
net8.0-windows
net9.0-windows
net10.0-windows
```

**Same as nightly**, includes net472 for compatibility testing

#### Targets

**PackAll** only (no lite/full split):

```cmd
msbuild canary.proj /t:Pack /p:Configuration=Canary
```

**CreateAllCanaryArchives**:

```cmd
msbuild canary.proj /t:CreateAllCanaryArchives /p:Configuration=Canary
```

Output: `Bin/Canary/Zips/Krypton-Canary_YYYYMMDD.{zip,tar.gz}`

#### Usage

```cmd
REM Build canary packages locally
cd Scripts
msbuild canary.proj /t:Clean
msbuild canary.proj /t:Restore
msbuild canary.proj /t:Build /p:Configuration=Canary
msbuild canary.proj /t:Pack /p:Configuration=Canary

REM View packages
dir ..\Bin\Packages\Canary\
```

---

### nightly.proj - Nightly Builds

**Used By**: Alpha branch  
**Configuration**: `Nightly`  
**Output**: `Bin/Nightly/`, `Bin/Packages/Nightly/`

#### Target Frameworks (6 total)

```
net472
net48
net481
net8.0-windows
net9.0-windows
net10.0-windows
```

#### Special Targets

**Rebuild**:

```cmd
msbuild nightly.proj /t:Rebuild /p:Configuration=Nightly
```

Combines `Clean` + `Build` (full rebuild)

**CreateAllArchives**:

```cmd
msbuild nightly.proj /t:CreateAllArchives /p:Configuration=Nightly
```

Output: `Bin/Nightly/Zips/Krypton-Nightly_YYYYMMDD.{zip,tar.gz}`

#### Usage

```cmd
REM Quick nightly build
cd Scripts
build-nightly.cmd

REM Or manually
msbuild nightly.proj /t:Rebuild /p:Configuration=Nightly
msbuild nightly.proj /t:Pack /p:Configuration=Nightly
```

---

## Project Structure

### Solution Layout

```
Source/Krypton Components/
├── Krypton Toolkit Suite 2022 - VS2022.sln
├── Directory.Build.props           # Global properties
├── Directory.Build.targets         # Global targets
├── Krypton.Toolkit/
│   ├── Krypton.Toolkit 2022.csproj
│   └── [source files]
├── Krypton.Ribbon/
│   ├── Krypton.Ribbon 2022.csproj
│   └── [source files]
├── Krypton.Navigator/
│   ├── Krypton.Navigator 2022.csproj
│   └── [source files]
├── Krypton.Workspace/
│   ├── Krypton.Workspace 2022.csproj
│   └── [source files]
├── Krypton.Docking/
│   ├── Krypton.Docking 2022.csproj
│   └── [source files]
└── TestForm/                       # Test application
    └── TestForm.csproj
```

### Directory.Build.props

**Purpose**: Global properties inherited by all projects

**Key Settings**:

```xml
<PropertyGroup>
  <!-- Versioning -->
  <LibraryVersion>100.25.1.1</LibraryVersion>
  <Version>$(LibraryVersion)</Version>
  <AssemblyVersion>$(LibraryVersion)</AssemblyVersion>
  <FileVersion>$(LibraryVersion)</FileVersion>
  
  <!-- Package Metadata -->
  <Company>Component Factory Pty Ltd, Peter Wagner, Simon Coghlan et al.</Company>
  <Authors>Peter William Wagner &amp; Simon Coghlan &amp; ...</Authors>
  <PackageLicenseExpression>BSD-3-Clause</PackageLicenseExpression>
  <PackageReadmeFile>README.md</PackageReadmeFile>
  <PackageRequireLicenseAcceptance>True</PackageRequireLicenseAcceptance>
  <PackageTags>Krypton ComponentFactory WinForms Themes Controls ...</PackageTags>
  
  <!-- Output Paths -->
  <OutputPath>..\..\..\Bin\$(Configuration)\</OutputPath>
  <PackageOutputPath>..\..\..\Bin\Packages\$(Configuration)\</PackageOutputPath>
</PropertyGroup>

<!-- README in all packages -->
<ItemGroup>
  <None Include="..\..\..\README.md">
    <Pack>True</Pack>
    <PackagePath>\</PackagePath>
  </None>
</ItemGroup>
```

**Applies To**: All 5 Krypton component projects

### Directory.Build.targets

**Purpose**: Global build targets and symbol package configuration

**Key Settings**:

```xml
<PropertyGroup Condition="'$(Configuration)' == 'Nightly' Or '$(Configuration)' == 'Canary'">
  <!-- Symbol Packages -->
  <IncludeSymbols>True</IncludeSymbols>
  <SymbolPackageFormat>snupkg</SymbolPackageFormat>
</PropertyGroup>
```

**Effect**: Nightly and Canary builds automatically create `.snupkg` symbol packages

---

## Multi-Targeting

### How It Works

Projects use `<TargetFrameworks>` (plural) to build for multiple .NET versions:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFrameworks>net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
  </PropertyGroup>
</Project>
```

**Build Process**:

1. MSBuild detects multiple targets
2. Builds each framework sequentially (or parallel with `/m`)
3. Outputs to separate directories:
   - `Bin/Release/net48/Krypton.Toolkit.dll`
   - `Bin/Release/net481/Krypton.Toolkit.dll`
   - `Bin/Release/net8.0-windows/Krypton.Toolkit.dll`
   - etc.

### Configuration-Based Targeting

Projects use `<Choose>` to vary frameworks by configuration:

```xml
<Choose>
  <!-- Nightly, Canary, Debug: Include net472 -->
  <When Condition="'$(Configuration)' == 'Nightly' Or '$(Configuration)' == 'Canary' Or '$(Configuration)' == 'Debug'">
    <PropertyGroup>
      <TargetFrameworks>net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
    </PropertyGroup>
  </When>
  
  <!-- Release: Exclude net472 by default -->
  <Otherwise>
    <PropertyGroup>
      <TargetFrameworks>net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
      
      <!-- Override with TFMs=all to include net472 -->
      <TargetFrameworks Condition="'$(TFMs)' == 'all'">
        net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows
      </TargetFrameworks>
    </PropertyGroup>
  </Otherwise>
</Choose>
```

### Target Framework Matrix

| Configuration | Default TFMs | With `TFMs=all` | Count |
|---------------|--------------|-----------------|-------|
| Debug | net472, 48, 481, 8, 9, 10 | Same | 6 |
| Release | net48, 481, 8, 9, 10 | + net472 | 5 → 6 |
| Nightly | net472, 48, 481, 8, 9, 10 | Same | 6 |
| Canary | net472, 48, 481, 8, 9, 10 | Same | 6 |
| LTS (V85-LTS branch) | net462, 47, 471, 472, 48, 481, 6, 7, 8 | Same | 9 |

### TFM Property Usage

The `TFMs` property controls which frameworks to build:

```cmd
REM Build with default frameworks
msbuild build.proj /t:Build /p:Configuration=Release

REM Build with all frameworks (includes net472)
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=all

REM Build with lite frameworks (same as default for Release)
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=lite
```

**Used in**:

- `build.proj` - PackLite (default) vs PackAll (TFMs=all)
- All build scripts - Pass to MSBuild for individual projects

---

## Package Configuration

### NuGet Package Structure

Each NuGet package contains:

```
Krypton.Toolkit.100.25.1.1.nupkg
├── lib/
│   ├── net472/
│   │   └── Krypton.Toolkit.dll
│   ├── net48/
│   │   └── Krypton.Toolkit.dll
│   ├── net481/
│   │   └── Krypton.Toolkit.dll
│   ├── net8.0-windows/
│   │   └── Krypton.Toolkit.dll
│   ├── net9.0-windows/
│   │   └── Krypton.Toolkit.dll
│   └── net10.0-windows/
│       └── Krypton.Toolkit.dll
├── README.md
└── [metadata]
```

### Symbol Packages

Configured in `Directory.Build.targets`:

```xml
<IncludeSymbols>True</IncludeSymbols>
<SymbolPackageFormat>snupkg</SymbolPackageFormat>
```

**Creates**:

```
Krypton.Toolkit.100.25.1.1.snupkg
├── lib/
│   ├── net472/
│   │   ├── Krypton.Toolkit.dll
│   │   └── Krypton.Toolkit.pdb
│   └── [other frameworks...]
└── [source files for Source Link]
```

**Publishing**: Automatically uploaded when pushing main package

**Benefit**: Developers can debug through Krypton Toolkit code

### Package Metadata

**From Directory.Build.props**:

```xml
<PropertyGroup>
  <Company>Component Factory Pty Ltd, Peter Wagner, Simon Coghlan et al.</Company>
  <Product>Krypton Toolkit</Product>
  <Copyright>© Component Factory Pty Ltd, Peter Wagner, Simon Coghlan et al. 2017 - 2025. All rights reserved.</Copyright>
  
  <Authors>Peter William Wagner &amp; Simon Coghlan &amp; Giduac &amp; Ahmed Abdelhameed &amp; Lesandro &amp; tobitege &amp; Thomas Bolon</Authors>
  <PackageLicenseExpression>BSD-3-Clause</PackageLicenseExpression>
  <PackageReadmeFile>README.md</PackageReadmeFile>
  <PackageRequireLicenseAcceptance>True</PackageRequireLicenseAcceptance>
  <PackageTags>Krypton ComponentFactory WinForms Themes Controls DataGrid Ribbon Workspace Tabs .NET Toolkit</PackageTags>
  <PackageReleaseNotes>Get updates here: https://github.com/Krypton-Suite/Standard-Toolkit</PackageReleaseNotes>
  
  <RepositoryUrl>https://github.com/Krypton-Suite/Standard-Toolkit</RepositoryUrl>
  <RepositoryType>git</RepositoryType>
  <PackageProjectUrl>https://github.com/Krypton-Suite/Standard-Toolkit</PackageProjectUrl>
  <PackageIcon>Krypton.png</PackageIcon>
</PropertyGroup>
```

**Per-Project**:

```xml
<!-- In Krypton.Toolkit 2022.csproj -->
<PropertyGroup>
  <PackageId>Krypton.Toolkit</PackageId>
  <Description>This is the core toolkit module.</Description>
</PropertyGroup>
```

Similar for Ribbon, Navigator, Workspace, Docking

---

## Local Development

### Quick Start

#### Debug Build (Fast)

```cmd
cd "Source\Krypton Components"
dotnet build "Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

Output: `Bin/Debug/net472/`, `Bin/Debug/net48/`, etc.

#### Run Test Application

```cmd
dotnet run --project "TestForm/TestForm.csproj" -c Debug
```

**Or** open solution in Visual Studio 2022 and press F5

---

### Building Specific Configurations

#### Stable Release Build

```cmd
cd Scripts

REM Using batch file (recommended)
build-stable.cmd

REM Or manually
msbuild build.proj /t:Clean
msbuild build.proj /t:Restore
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=all
msbuild build.proj /t:Pack /p:Configuration=Release
```

**Output**:

- Binaries: `Bin/Release/{framework}/`
- Packages: `Bin/Packages/Release/`

#### LTS Build

```cmd
cd Scripts
msbuild longtermstable.proj /t:Rebuild /p:Configuration=Release
msbuild longtermstable.proj /t:Pack /p:Configuration=Release
```

**Requires**: .NET 6, 7, 8 SDKs installed

#### Canary Build

```cmd
cd Scripts
build-canary.cmd

REM Or manually
msbuild canary.proj /t:Build /p:Configuration=Canary
msbuild canary.proj /t:Pack /p:Configuration=Canary
```

#### Nightly Build

```cmd
cd Scripts
build-nightly.cmd

REM Or manually
msbuild nightly.proj /t:Rebuild /p:Configuration=Nightly
msbuild nightly.proj /t:Pack /p:Configuration=Nightly
```

---

### Working with Packages Locally

#### Create Packages

```cmd
cd Scripts
msbuild build.proj /t:Pack /p:Configuration=Release
```

**View created packages**:

```cmd
dir ..\Bin\Packages\Release\*.nupkg
```

**Expected output**:

```
Krypton.Toolkit.100.25.1.1.nupkg
Krypton.Toolkit.100.25.1.1.snupkg
Krypton.Ribbon.100.25.1.1.nupkg
Krypton.Ribbon.100.25.1.1.snupkg
Krypton.Navigator.100.25.1.1.nupkg
Krypton.Navigator.100.25.1.1.snupkg
Krypton.Workspace.100.25.1.1.nupkg
Krypton.Workspace.100.25.1.1.snupkg
Krypton.Docking.100.25.1.1.nupkg
Krypton.Docking.100.25.1.1.snupkg
```

#### Inspect Package Contents

```cmd
REM Extract package (it's a ZIP file)
cd ..\Bin\Packages\Release
7z x Krypton.Toolkit.100.25.1.1.nupkg -o"extracted"

REM Or use NuGet Package Explorer (GUI)
REM Download from: https://github.com/NuGetPackageExplorer/NuGetPackageExplorer
```

#### Test Package Locally

**Method 1: Local folder source**

```cmd
REM Add local folder as NuGet source
nuget sources add -Name "Local" -Source "Z:\Development\Krypton\Standard-Toolkit\Bin\Packages\Release"

REM In test project
dotnet add package Krypton.Toolkit --version 100.25.1.1 --source Local
```

**Method 2: Direct package reference**

```xml
<!-- In test .csproj -->
<ItemGroup>
  <PackageReference Include="Krypton.Toolkit" Version="100.25.1.1">
    <Source>Z:\Development\Krypton\Standard-Toolkit\Bin\Packages\Release</Source>
  </PackageReference>
</ItemGroup>
```

#### Publish to Test Feed

**Azure Artifacts / GitHub Packages / MyGet**:

```cmd
set TEST_FEED_URL=https://pkgs.dev.azure.com/yourorg/_packaging/test/nuget/v3/index.json
set TEST_FEED_KEY=your-test-key

dotnet nuget push Krypton.Toolkit.100.25.1.1.nupkg --source %TEST_FEED_URL% --api-key %TEST_FEED_KEY%
```

---

## Build Customization

### Adding a New Target Framework

**Example**: Add .NET 11.0 support

#### 1. Update Project Files

Edit all 5 component `.csproj` files:

```xml
<TargetFrameworks>net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows;net11.0-windows</TargetFrameworks>
```

**Files to update**:

- `Krypton.Toolkit/Krypton.Toolkit 2022.csproj`
- `Krypton.Ribbon/Krypton.Ribbon 2022.csproj`
- `Krypton.Navigator/Krypton.Navigator 2022.csproj`
- `Krypton.Workspace/Krypton.Workspace 2022.csproj`
- `Krypton.Docking/Krypton.Docking 2022.csproj`

#### 2. Test Locally

```cmd
REM Install .NET 11 SDK first
dotnet --list-sdks  # Verify 11.0.x present

REM Build
cd "Source\Krypton Components"
dotnet build "Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

#### 3. Update GitHub Actions Workflows

See [GitHub Actions Workflows Guide](GitHubActionsIndex.md)

---

### Conditional Compilation

Use preprocessor directives for framework-specific code:

```csharp
#if NET472
    // Code for .NET Framework 4.7.2 only
#elif NET48_OR_GREATER
    // Code for .NET Framework 4.8+
#elif NET8_0_OR_GREATER
    // Code for .NET 8.0+
#endif
```

**Common Symbols**:

- `NET472`, `NET48`, `NET481` - Specific .NET Framework versions
- `NET6_0`, `NET7_0`, `NET8_0`, `NET9_0`, `NET10_0` - Specific .NET versions
- `NET48_OR_GREATER` - .NET Framework 4.8+
- `NET6_0_OR_GREATER` - .NET 6.0+
- `NETCOREAPP` - Any .NET Core/.NET 5+ version
- `NETFRAMEWORK` - Any .NET Framework version
- `WINDOWS` - Windows-specific TFMs

**Example**:

```csharp
#if NETFRAMEWORK
    // Use .NET Framework APIs
    using System.Configuration;
#else
    // Use modern .NET APIs
    using System.Text.Json;
#endif
```

---

### Custom Build Configurations

#### Add New Configuration

**In Directory.Build.props**:

```xml
<Configurations>Debug;Release;Installer;Nightly;Canary;LTS;MyCustomConfig</Configurations>
```

**In individual .csproj**:

```xml
<PropertyGroup Condition="'$(Configuration)' == 'MyCustomConfig'">
  <TargetFrameworks>net48;net9.0-windows</TargetFrameworks>
  <DefineConstants>MY_CUSTOM_FLAG</DefineConstants>
  <Optimize>True</Optimize>
</PropertyGroup>
```

**Create build script** (`Scripts/mycustom.proj`):

```xml
<Project>
  <Import Project="..\Directory.Build.props" />
  
  <PropertyGroup>
    <Configuration>MyCustomConfig</Configuration>
  </PropertyGroup>
  
  <Target Name="Build">
    <ItemGroup>
      <Projects Include="..\Source\Krypton Components\Krypton.*\*.csproj" />
    </ItemGroup>
    <MSBuild Projects="@(Projects)" Properties="Configuration=$(Configuration)" />
  </Target>
</Project>
```

**Build**:

```cmd
msbuild mycustom.proj /t:Build
```

---

### Version Management

#### Version Location

**Single source of truth**: `Directory.Build.props`

```xml
<PropertyGroup>
  <LibraryVersion>100.25.1.1</LibraryVersion>
  <Version>$(LibraryVersion)</Version>
  <AssemblyVersion>$(LibraryVersion)</AssemblyVersion>
  <FileVersion>$(LibraryVersion)</FileVersion>
</PropertyGroup>
```

**Propagates to**:

- All 5 component assemblies
- All NuGet packages
- All symbol packages
- GitHub release tags

#### Updating Version

**For new release**:

1. Edit `Directory.Build.props`:

   ```xml
   <LibraryVersion>100.26.0.0</LibraryVersion>
   ```

2. Update changelog in `Documents/Changelog/Changelog.md`

3. Commit:

   ```cmd
   git add Directory.Build.props Documents/Changelog/Changelog.md
   git commit -m "Bump version to 100.26.0.0"
   ```

4. Push to trigger release workflow

**Do NOT**:

- ❌ Edit version in individual `.csproj` files
- ❌ Edit `AssemblyInfo.cs` files (not used)
- ❌ Manually edit assembly attributes

#### Version Format

**Semantic versioning**: `Major.Minor.Build.Revision`

**Example**: `100.25.1.1`

- **100** - Major version (product generation, V100 = current)
- **25** - Minor version (feature set, monthly releases)
- **1** - Build number (increment for each release)
- **1** - Revision (hotfixes, usually 1)

**LTS versioning**: `85.24.0.0`

- **85** - Major version (V85 = LTS branch)
- **24** - Minor version
- **0** - Build number
- **0** - Revision

---

## Build Output Structure

### Directory Layout

```
Bin/
├── Debug/
│   ├── net472/
│   │   ├── Krypton.Toolkit.dll
│   │   ├── Krypton.Toolkit.pdb
│   │   └── [dependencies]
│   ├── net48/
│   ├── net481/
│   ├── net8.0-windows/
│   ├── net9.0-windows/
│   └── net10.0-windows/
│
├── Release/
│   ├── net48/          # Lite package
│   ├── net481/
│   ├── net472/         # Full package only
│   ├── net8.0-windows/
│   ├── net9.0-windows/
│   └── net10.0-windows/
│
├── Canary/
│   └── [6 frameworks]
│
├── Nightly/
│   └── [6 frameworks]
│
├── Packages/
│   ├── Release/
│   │   ├── Krypton.Toolkit.100.25.1.1.nupkg
│   │   ├── Krypton.Toolkit.100.25.1.1.snupkg
│   │   ├── Krypton.Ribbon.100.25.1.1.nupkg
│   │   ├── Krypton.Ribbon.100.25.1.1.snupkg
│   │   └── [other packages]
│   ├── Canary/
│   │   └── [canary packages]
│   └── Nightly/
│       └── [nightly packages]
│
└── Release/
    └── Zips/
        ├── Krypton-Release_20251024.zip
        └── Krypton-Release_20251024.tar.gz
```

### File Sizes

**Typical sizes** (per framework):

| Component | Debug | Release | Difference |
|-----------|-------|---------|------------|
| Krypton.Toolkit.dll | ~1.8 MB | ~1.3 MB | -28% (optimizations) |
| Krypton.Ribbon.dll | ~600 KB | ~450 KB | -25% |
| Krypton.Navigator.dll | ~400 KB | ~300 KB | -25% |
| Krypton.Workspace.dll | ~200 KB | ~150 KB | -25% |
| Krypton.Docking.dll | ~150 KB | ~110 KB | -27% |

**NuGet Package sizes** (all frameworks):

| Package | Without Symbols | With Symbols |
|---------|-----------------|--------------|
| Krypton.Toolkit | ~8-10 MB | +2 MB |
| Krypton.Ribbon | ~3-4 MB | +1 MB |
| Krypton.Navigator | ~2-2.5 MB | +0.5 MB |
| Krypton.Workspace | ~1-1.2 MB | +0.3 MB |
| Krypton.Docking | ~0.8-1 MB | +0.2 MB |

---

## Build Performance

### Optimization Strategies

#### Parallel Builds

```cmd
REM Use all CPU cores (default)
msbuild build.proj /t:Build /m

REM Limit to 4 cores
msbuild build.proj /t:Build /m:4

REM Single-threaded (for debugging)
msbuild build.proj /t:Build /m:1
```

**Typical speedup**: 2-4x on multi-core systems

#### Incremental Builds

**First build**:

```cmd
msbuild build.proj /t:Build
```

Compiles everything: ~5-10 minutes

**Subsequent builds**:

```cmd
REM Change one file
msbuild build.proj /t:Build
```

Only recompiles changed files: ~30-60 seconds

**Force full rebuild**:

```cmd
msbuild build.proj /t:Rebuild
```

#### Build Only What You Need

**Single project**:

```cmd
cd "Source\Krypton Components\Krypton.Toolkit"
dotnet build "Krypton.Toolkit 2022.csproj" -c Debug
```

**Single framework**:

```cmd
dotnet build "Krypton.Toolkit 2022.csproj" -c Debug -f net10.0-windows
```

**Single configuration**:

```cmd
REM Build only Debug (skip Release, Nightly, etc.)
dotnet build "Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

---

### Build Troubleshooting

#### Issue: Build Fails with SDK Not Found

**Error**: `error NETSDK1045: The current .NET SDK does not support targeting .NET 9.0`

**Cause**: Required SDK not installed

**Solution**:

```cmd
REM Check installed SDKs
dotnet --list-sdks

REM Install missing SDK
REM Download from: https://dotnet.microsoft.com/download
```

**Required SDKs by Configuration**:

- **Debug/Nightly/Canary**: .NET 9, 10
- **Release**: .NET 9, 10 (for full build)
- **LTS**: .NET 6, 7, 8

---

#### Issue: NuGet Restore Fails

**Error**: `NU1101: Unable to find package ...`

**Solutions**:

1. **Clear NuGet cache**:

   ```cmd
   dotnet nuget locals all --clear
   ```

2. **Verify NuGet sources**:

   ```cmd
   dotnet nuget list source
   ```

3. **Manually restore**:

   ```cmd
   dotnet restore "Source\Krypton Components\Krypton Toolkit Suite 2022 - VS2022.sln" --force
   ```

4. **Check internet connection** (required for nuget.org)

---

#### Issue: Duplicate Symbol Errors

**Error**: `error CS0433: The type exists in both ...`

**Cause**: Same assembly referenced multiple times

**Solution**: Clean and rebuild

```cmd
msbuild build.proj /t:Clean
msbuild build.proj /t:Rebuild
```

**Prevention**: Use `dotnet clean` before major builds

---

#### Issue: Out of Memory During Build

**Error**: `error MSB4018: OutOfMemoryException`

**Cause**: Building too many frameworks simultaneously

**Solutions**:

1. **Reduce parallelization**:

   ```cmd
   msbuild build.proj /t:Build /m:2
   ```

2. **Build frameworks sequentially**:

   ```cmd
   dotnet build -f net472
   dotnet build -f net48
   # etc.
   ```

3. **Close other applications** (Visual Studio, browsers)

4. **Increase system page file** (Windows virtual memory)

---

## Build Script Reference

### Common MSBuild Properties

| Property | Values | Description | Example |
|----------|--------|-------------|---------|
| `Configuration` | Debug, Release, Nightly, Canary, LTS | Build configuration | `/p:Configuration=Release` |
| `TFMs` | `all`, `lite`, (empty) | Target framework set | `/p:TFMs=all` |
| `Platform` | `Any CPU`, x86, x64 | Target platform | `/p:Platform="Any CPU"` |
| `LibraryVersion` | 100.25.1.1 | Package version | Defined in props |

### Common MSBuild Targets

| Target | Purpose | Example |
|--------|---------|---------|
| `Clean` | Remove outputs | `msbuild build.proj /t:Clean` |
| `Restore` | Restore NuGet packages | `msbuild build.proj /t:Restore` |
| `Build` | Compile projects | `msbuild build.proj /t:Build` |
| `Rebuild` | Clean + Build | `msbuild build.proj /t:Rebuild` |
| `Pack` | Create NuGet packages | `msbuild build.proj /t:Pack` |
| `PackLite` | Create lite packages | `msbuild build.proj /t:PackLite` |
| `PackAll` | Create full packages | `msbuild build.proj /t:PackAll` |
| `Push` | Upload to NuGet | `msbuild build.proj /t:Push` |
| `CreateAllReleaseArchives` | Create ZIP/TAR.GZ | `msbuild build.proj /t:CreateAllReleaseArchives` |

### MSBuild Verbosity Levels

```cmd
REM Quiet (minimal output)
msbuild build.proj /v:q

REM Minimal
msbuild build.proj /v:m

REM Normal (default)
msbuild build.proj /v:n

REM Detailed
msbuild build.proj /v:d

REM Diagnostic (very verbose)
msbuild build.proj /v:diag
```

**Use diagnostic** when troubleshooting build issues

### Binary Logging

```cmd
REM Create binary log for analysis
msbuild build.proj /t:Build /bl:build.binlog

REM View with MSBuild Structured Log Viewer
REM Download: http://msbuildlog.com/
```

**Benefits**:

- Post-mortem analysis of builds
- Share build logs without sensitive data
- Visualize build graph and timing

---

## Package Publishing

### Local Publishing to nuget.org

**Prerequisites**:

1. NuGet API key from nuget.org
2. Packages built (`.nupkg` files)

**Steps**:

```cmd
REM Set API key (session only)
set NUGET_API_KEY=your-api-key-here

REM Navigate to packages
cd Bin\Packages\Release

REM Push single package
dotnet nuget push Krypton.Toolkit.100.25.1.1.nupkg ^
  --api-key %NUGET_API_KEY% ^
  --source https://api.nuget.org/v3/index.json

REM Push all packages (with duplicate protection)
for %%f in (*.nupkg) do (
  dotnet nuget push %%f ^
    --api-key %NUGET_API_KEY% ^
    --source https://api.nuget.org/v3/index.json ^
    --skip-duplicate
)
```

**Symbol packages**: Automatically pushed with main packages

---

### Publishing to Alternative Feeds

#### GitHub Packages

```cmd
REM Authenticate (one-time)
dotnet nuget add source https://nuget.pkg.github.com/Krypton-Suite/index.json ^
  --name github ^
  --username YOUR_GITHUB_USERNAME ^
  --password YOUR_GITHUB_PAT

REM Push
dotnet nuget push Krypton.Toolkit.100.25.1.1.nupkg ^
  --source github
```

#### Azure Artifacts

```cmd
REM Add feed source
dotnet nuget add source https://pkgs.dev.azure.com/yourorg/_packaging/yourfeed/nuget/v3/index.json ^
  --name azure ^
  --username any ^
  --password YOUR_PAT

REM Push
dotnet nuget push Krypton.Toolkit.100.25.1.1.nupkg --source azure
```

#### Private NuGet Server

```cmd
dotnet nuget push Krypton.Toolkit.100.25.1.1.nupkg ^
  --source https://your-nuget-server.com/api/v2/package ^
  --api-key your-key
```

---

## Development Best Practices

### Before Building

1. **Pull latest changes**:

   ```cmd
   git pull origin master
   ```

2. **Clean previous outputs**:

   ```cmd
   cd Scripts
   msbuild build.proj /t:Clean
   ```

3. **Restore packages**:

   ```cmd
   msbuild build.proj /t:Restore
   ```

### During Development

1. **Use incremental builds**:

   ```cmd
   REM In Visual Studio: Ctrl+Shift+B
   REM Or command line:
   dotnet build -c Debug
   ```

2. **Build specific project**:

   ```cmd
   cd "Source\Krypton Components\Krypton.Toolkit"
   dotnet build -c Debug
   ```

3. **Test immediately**:

   ```cmd
   cd ..\TestForm
   dotnet run -c Debug
   ```

### Before Committing

1. **Build all configurations**:

   ```cmd
   dotnet build -c Debug
   dotnet build -c Release
   ```

2. **Check for warnings**:

   ```cmd
   REM Review build output for warnings
   REM Fix any CS#### warnings
   ```

3. **Test in TestForm**:
   - Run application
   - Test changed functionality
   - Verify no regressions

4. **Clean build**:

   ```cmd
   msbuild build.proj /t:Rebuild /p:Configuration=Release /p:TFMs=all
   ```

---

## Build System Maintenance

### Regular Tasks

**Weekly**:

- ✅ Clean build outputs: `msbuild build.proj /t:Clean`
- ✅ Update NuGet packages: `dotnet restore --force`

**Monthly**:

- ✅ Check for .NET SDK updates
- ✅ Review build warnings (aim for zero warnings)
- ✅ Clean NuGet cache: `dotnet nuget locals all --clear`

**Per Release**:

- ✅ Bump version in `Directory.Build.props`
- ✅ Update `Changelog.md`
- ✅ Full rebuild with all TFMs
- ✅ Test packages locally before publishing

### Updating Dependencies

#### NuGet Package Dependencies

**Check for updates**:

```cmd
dotnet list package --outdated
```

**Update specific package**:

```cmd
dotnet add package System.Resources.Extensions --version 9.0.0
```

**Update in `.csproj`**:

```xml
<PackageReference Include="System.Resources.Extensions" Version="9.0.0" />
```

**Test after updating**:

- Build all configurations
- Run TestForm
- Check for breaking changes

---

## Advanced Build Scenarios

### Cross-Configuration Builds

**Build multiple configs in sequence**:

```cmd
FOR %%c IN (Debug,Release,Nightly,Canary) DO (
  msbuild build.proj /t:Build /p:Configuration=%%c
)
```

### Selective Project Builds

**Build only Toolkit and Ribbon**:

```xml
<!-- Custom build script -->
<Target Name="BuildCore">
  <ItemGroup>
    <CoreProjects Include="..\Source\Krypton Components\Krypton.Toolkit\*.csproj" />
    <CoreProjects Include="..\Source\Krypton Components\Krypton.Ribbon\*.csproj" />
  </ItemGroup>
  <MSBuild Projects="@(CoreProjects)" Properties="Configuration=Release" />
</Target>
```

### Custom Package Output

**Change package output directory**:

```xml
<PropertyGroup>
  <PackageOutputPath>C:\MyPackages\</PackageOutputPath>
</PropertyGroup>
```

Or via command line:

```cmd
msbuild build.proj /t:Pack /p:PackageOutputPath=C:\MyPackages\
```

---

## Build System Integration

### Visual Studio Integration

**Configurations available in VS**:

- Debug
- Release
- Nightly
- Canary
- LTS (on V85-LTS branch)

**Select configuration**: Build → Configuration Manager

**Build from VS**:

- Build → Build Solution (Ctrl+Shift+B)
- Build → Rebuild Solution
- Build → Clean Solution

**NuGet Package Manager**:

- Tools → NuGet Package Manager → Package Manager Console
- `dotnet pack` from console

---

### Command-Line Build Tools

#### Visual Studio Developer Command Prompt

**Launch**:

- Start → Visual Studio 2022 → Developer Command Prompt

**Advantages**:

- MSBuild in PATH
- All Visual Studio tools available
- Correct environment variables set

**Build**:

```cmd
cd Z:\Development\Krypton\Standard-Toolkit\Scripts
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=all
```

#### Standard Command Prompt

**Requirements**:

- .NET SDK installed (includes MSBuild)
- PATH includes .NET SDK location

**Build**:

```cmd
dotnet build "Source\Krypton Components\Krypton Toolkit Suite 2022 - VS2022.sln" -c Release
```

---

## Troubleshooting Build Issues

### Common Build Errors

#### Error: Project File Not Found

**Error**: `error MSB4019: The imported project "..." was not found`

**Cause**: Relative paths incorrect

**Solution**: Run MSBuild from correct directory

```cmd
REM Must be in Scripts/ directory
cd Scripts
msbuild build.proj /t:Build
```

---

#### Error: Target Framework Not Supported

**Error**: `error NU1202: Package ... is not compatible with net10.0-windows`

**Cause**: Dependency doesn't support target framework

**Solutions**:

1. **Conditional dependency**:

   ```xml
   <PackageReference Include="LegacyPackage" Version="1.0.0" Condition="$(TargetFramework.StartsWith('net4'))" />
   ```

2. **Framework-specific dependencies**:

   ```xml
   <ItemGroup Condition="'$(TargetFramework)' == 'net48'">
     <PackageReference Include="SpecificPackage" Version="1.0.0" />
   </ItemGroup>
   ```

3. **Remove unsupported framework** from `TargetFrameworks`

---

#### Error: Assembly Version Conflict

**Error**: `error CS1703: Multiple assemblies with equivalent identity have been imported`

**Cause**: Binding redirect needed or duplicate references

**Solution**:

```xml
<!-- Add to .csproj -->
<PropertyGroup>
  <AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>
</PropertyGroup>
```

Or for .NET Framework only:

```xml
<ItemGroup Condition="$(TargetFramework.StartsWith('net4'))">
  <Reference Include="System.ValueTuple">
    <HintPath>..\packages\System.ValueTuple.4.5.0\lib\net47\System.ValueTuple.dll</HintPath>
  </Reference>
</ItemGroup>
```

---

### Build Performance Issues

#### Slow Builds

**Diagnostics**:

```cmd
REM Binary log captures timing
msbuild build.proj /t:Build /bl:build.binlog

REM Open in MSBuild Structured Log Viewer
REM Download: http://msbuildlog.com/
```

**Common Causes**:

1. Antivirus scanning (exclude Bin/, obj/ directories)
2. Network latency (NuGet restore)
3. Insufficient RAM (reduce parallelization)
4. Disk I/O (use SSD, exclude from indexing)

**Optimizations**:

```xml
<!-- In .csproj -->
<PropertyGroup>
  <AccelerateBuildsInVisualStudio>true</AccelerateBuildsInVisualStudio>
  <UseSharedCompilation>true</UseSharedCompilation>
</PropertyGroup>
```

---

## Build Script Internals

### ItemGroup Patterns

Build scripts use wildcards to include all Krypton projects:

```xml
<ItemGroup>
  <Projects Include="..\Source\Krypton Components\Krypton.*\*.csproj" />
</ItemGroup>
```

**Matches**:

- `Krypton.Toolkit/Krypton.Toolkit 2022.csproj`
- `Krypton.Ribbon/Krypton.Ribbon 2022.csproj`
- `Krypton.Navigator/Krypton.Navigator 2022.csproj`
- `Krypton.Workspace/Krypton.Workspace 2022.csproj`
- `Krypton.Docking/Krypton.Docking 2022.csproj`

**Excludes**:

- `TestForm/` (doesn't match pattern)
- Other non-component projects

**Benefit**: Automatically includes new components without script changes

### Target Dependencies

Targets can depend on other targets:

```xml
<Target Name="Pack" DependsOnTargets="CleanPackages;PackLite;PackAll">
  <!-- Runs CleanPackages, then PackLite, then PackAll -->
</Target>

<Target Name="Build" DependsOnTargets="Restore">
  <!-- Runs Restore first, then Build -->
</Target>
```

**Order of execution**: Dependencies run first, in order specified

### Property Evaluation

```xml
<PropertyGroup>
  <Configuration>Release</Configuration>
  <ReleaseBuildPath>..\Bin\Release\Zips</ReleaseBuildPath>
  <ReleaseZipName>Krypton-Release</ReleaseZipName>
  <StringDate>$([System.DateTime]::Now.ToString('yyyyMMdd'))</StringDate>
</PropertyGroup>
```

**Property Functions**:

- `$([System.DateTime]::Now.ToString('yyyyMMdd'))` - Current date
- `$([System.IO.Path]::GetFullPath(...))` - Absolute path
- `$(MSBuildProjectDirectory)` - Script directory

---

## Package Verification

### After Local Build

#### Check Package Contents

```cmd
cd Bin\Packages\Release

REM List files
7z l Krypton.Toolkit.100.25.1.1.nupkg

REM Extract
7z x Krypton.Toolkit.100.25.1.1.nupkg -o"extracted"
dir extracted\lib\
```

**Expected structure**:

```
lib/
├── net472/
├── net48/
├── net481/
├── net8.0-windows/
├── net9.0-windows/
└── net10.0-windows/
```

#### Validate Package Metadata

**Using NuGet**:

```cmd
nuget spec Krypton.Toolkit.100.25.1.1.nupkg
```

**Check**:

- ✅ All target frameworks present
- ✅ Dependencies correct
- ✅ Version matches expected
- ✅ README.md included
- ✅ License expression present

#### Test Installation

```cmd
REM Create test project
mkdir test
cd test
dotnet new console -f net8.0

REM Add local package
dotnet add package Krypton.Toolkit --version 100.25.1.1 --source ..\Bin\Packages\Release

REM Verify installation
dotnet list package
```

---

## Reference

### Build Script Parameters

#### build.proj

```cmd
msbuild build.proj /t:{Target} /p:Configuration={Config} /p:TFMs={TFMs} /p:Platform={Platform}
```

**Parameters**:

- `Target`: Clean, Restore, Build, Pack, Push, CreateAllReleaseArchives
- `Config`: Release
- `TFMs`: `all` (includes net472), `lite` (excludes net472), or empty (default)
- `Platform`: `Any CPU` (required)

**Examples**:

```cmd
REM Full build with all frameworks
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=all /p:Platform="Any CPU"

REM Pack both lite and full
msbuild build.proj /t:Pack /p:Configuration=Release

REM Create archives
msbuild build.proj /t:CreateAllReleaseArchives /p:Configuration=Release /p:Platform="Any CPU"
```

#### longtermstable.proj

```cmd
REM LTS build
msbuild longtermstable.proj /t:Build /p:Configuration=Release /p:TFMs=all /p:Platform="Any CPU"

REM LTS pack
msbuild longtermstable.proj /t:Pack /p:Configuration=Release
```

**Note**: Always uses `TFMs=all` (all 9 frameworks)

#### canary.proj

```cmd
REM Canary build
msbuild canary.proj /t:Build /p:Configuration=Canary /p:Platform="Any CPU"

REM Canary pack
msbuild canary.proj /t:Pack /p:Configuration=Canary

REM Canary archives
msbuild canary.proj /t:CreateAllCanaryArchives /p:Configuration=Canary /p:Platform="Any CPU"
```

#### nightly.proj

```cmd
REM Nightly rebuild
msbuild nightly.proj /t:Rebuild /p:Configuration=Nightly /p:Platform="Any CPU"

REM Nightly pack
msbuild nightly.proj /t:Pack /p:Configuration=Nightly

REM Nightly archives
msbuild nightly.proj /t:CreateAllArchives /p:Configuration=Nightly /p:Platform="Any CPU"
```

---

### Output Directory Reference

| Configuration | Binaries | Packages | Archives |
|---------------|----------|----------|----------|
| Debug | `Bin/Debug/{tfm}/` | N/A | N/A |
| Release | `Bin/Release/{tfm}/` | `Bin/Packages/Release/` | `Bin/Release/Zips/` |
| Nightly | `Bin/Nightly/{tfm}/` | `Bin/Packages/Nightly/` | `Bin/Nightly/Zips/` |
| Canary | `Bin/Canary/{tfm}/` | `Bin/Packages/Canary/` | `Bin/Canary/Zips/` |
| LTS | `Bin/Release/{tfm}/` | `Bin/Packages/Release/` | `Bin/Release/Zips/` |

**Note**: LTS uses Release directories but creates `*.LTS.*.nupkg` packages

---

### Component Projects

All 5 components follow same structure:

#### Krypton.Toolkit

**Package ID**: `Krypton.Toolkit` (or `Krypton.Toolkit.LTS` on V85-LTS)  
**Description**: Core toolkit module  
**Size**: Largest (~8-10 MB package)  
**Dependencies**: None (base library)

#### Krypton.Ribbon

**Package ID**: `Krypton.Ribbon`  
**Description**: Ribbon module  
**Dependencies**: Krypton.Toolkit

#### Krypton.Navigator

**Package ID**: `Krypton.Navigator`  
**Description**: Navigator module  
**Dependencies**: Krypton.Toolkit

#### Krypton.Workspace

**Package ID**: `Krypton.Workspace`  
**Description**: Workspace module  
**Dependencies**: Krypton.Navigator, Krypton.Toolkit

#### Krypton.Docking

**Package ID**: `Krypton.Docking`  
**Description**: Docking module  
**Dependencies**: Krypton.Navigator, Krypton.Toolkit

**Dependency Graph**:

```
Krypton.Toolkit (base)
    ├── Krypton.Ribbon
    ├── Krypton.Navigator
    │   ├── Krypton.Workspace
    │   └── Krypton.Docking
    └── Krypton.Workspace (indirect)
```

---

## Build System Customization

### Adding a New Component

#### 1. Create Project

```cmd
cd "Source\Krypton Components"
dotnet new classlib -n Krypton.NewComponent -f net48
```

#### 2. Configure Project

Edit `Krypton.NewComponent/Krypton.NewComponent.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <!-- Copy target framework setup from existing component -->
  <Choose>
    <When Condition="'$(Configuration)' == 'Nightly' Or '$(Configuration)' == 'Canary' Or '$(Configuration)' == 'Debug'">
      <PropertyGroup>
        <TargetFrameworks>net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
      </PropertyGroup>
    </When>
    <Otherwise>
      <PropertyGroup>
        <TargetFrameworks>net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
        <TargetFrameworks Condition="'$(TFMs)' == 'all'">net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
      </PropertyGroup>
    </Otherwise>
  </Choose>
  
  <!-- Package metadata -->
  <PropertyGroup>
    <PackageId>Krypton.NewComponent</PackageId>
    <Description>This is the new component module.</Description>
  </PropertyGroup>
  
  <!-- Copy other properties from existing component -->
</Project>
```

#### 3. Add to Solution

```cmd
dotnet sln "Krypton Toolkit Suite 2022 - VS2022.sln" add "Krypton.NewComponent/Krypton.NewComponent.csproj"
```

#### 4. Build Scripts (Automatic)

Build scripts use wildcard pattern `Krypton.*\*.csproj`, so new component is automatically included!

**Verify**:

```cmd
cd Scripts
msbuild build.proj /t:Build /p:Configuration=Release
```

Should build Krypton.NewComponent automatically

#### 5. Update Workflows

See [GitHub Actions Workflows Guide](GitHubActionsIndex.md)

---

### Custom Build Properties

#### Add Build Number

```xml
<!-- In Directory.Build.props -->
<PropertyGroup>
  <BuildNumber Condition="'$(BuildNumber)' == ''">0</BuildNumber>
  <LibraryVersion>100.25.$(BuildNumber).1</LibraryVersion>
</PropertyGroup>
```

**Use from command line**:

```cmd
msbuild build.proj /t:Build /p:BuildNumber=42
REM Creates version: 100.25.42.1
```

**In CI/CD**:

```cmd
REM Use GitHub run number
msbuild build.proj /t:Build /p:BuildNumber=%GITHUB_RUN_NUMBER%
```

#### Add Git Commit Hash

```xml
<PropertyGroup>
  <SourceRevisionId>$(SourceRevisionId)</SourceRevisionId>
  <InformationalVersion>$(Version)+$(SourceRevisionId)</InformationalVersion>
</PropertyGroup>
```

**Reads from**: Git (automatic with .NET SDK)

**Results in**:

- Package version: `100.25.1.1`
- Informational version: `100.25.1.1+a1b2c3d4`

---

## Build Environment Requirements

### Minimum Requirements

**Operating System**:

- Windows 10 version 1809 or later
- Windows 11
- Windows Server 2019 or later

**Software**:

- Visual Studio 2022 (v17.0 or later)
- .NET SDK 8.0 or later (minimum)
- MSBuild (included with VS or .NET SDK)

**For Full Builds**:

- All .NET SDKs: 6.0, 7.0, 8.0, 9.0, 10.0
- NuGet CLI (optional, for `nuget.exe push`)

**Disk Space**:

- Source code: ~200 MB
- Build outputs: ~500 MB per configuration
- NuGet cache: ~1-2 GB
- **Recommended**: 5 GB free space

**Memory**:

- Minimum: 4 GB RAM
- Recommended: 8 GB RAM
- For parallel builds: 16 GB RAM

---

### SDK Installation

#### Install All Required SDKs

**Using Visual Studio Installer**:

1. Visual Studio Installer → Modify
2. Individual components tab
3. Select:
   - ✅ .NET 6.0 Runtime
   - ✅ .NET 7.0 Runtime
   - ✅ .NET 8.0 Runtime
   - ✅ .NET 9.0 Runtime
   - ✅ .NET 10.0 Preview Runtime

**Using winget** (Windows Package Manager):

```cmd
winget install Microsoft.DotNet.SDK.6
winget install Microsoft.DotNet.SDK.7
winget install Microsoft.DotNet.SDK.8
winget install Microsoft.DotNet.SDK.9
winget install Microsoft.DotNet.SDK.Preview  # .NET 10
```

**Using dotnet-install script**:

```powershell
# Download script
Invoke-WebRequest -Uri https://dot.net/v1/dotnet-install.ps1 -OutFile dotnet-install.ps1

# Install each SDK
.\dotnet-install.ps1 -Version 6.0
.\dotnet-install.ps1 -Version 7.0
.\dotnet-install.ps1 -Version 8.0
.\dotnet-install.ps1 -Version 9.0
.\dotnet-install.ps1 -Channel 10.0 -Quality preview
```

#### Verify Installation

```cmd
dotnet --list-sdks
```

**Expected output**:

```
6.0.xxx [C:\Program Files\dotnet\sdk]
7.0.xxx [C:\Program Files\dotnet\sdk]
8.0.xxx [C:\Program Files\dotnet\sdk]
9.0.xxx [C:\Program Files\dotnet\sdk]
10.0.xxx-preview.x [C:\Program Files\dotnet\sdk]
```

---

## Build System FAQ

### Q: Why does Release build both lite and full packages?

**A**: Deployment flexibility:

- **Lite** (5 TFMs): Smaller download, modern frameworks only
- **Full** (6 TFMs): Maximum compatibility, includes net472

Users choose based on their minimum supported framework.

### Q: What's the difference between Configuration and TFMs?

**A**:

- **Configuration**: Build type (Debug, Release, Nightly, etc.)
  - Controls: Optimizations, symbols, output directory
- **TFMs**: Which frameworks to target
  - Controls: Which DLLs are generated

Both are independent:

```cmd
REM Release config, all TFMs
msbuild build.proj /t:Build /p:Configuration=Release /p:TFMs=all

REM Debug config, all TFMs
msbuild build.proj /t:Build /p:Configuration=Debug /p:TFMs=all
```

### Q: Why are there so many build scripts?

**A**: Each release channel has different requirements:

- **build.proj**: Lite + full packages (unique)
- **longtermstable.proj**: 9 target frameworks (unique)
- **canary.proj**: Canary-specific packaging
- **nightly.proj**: Nightly-specific packaging

Separate scripts ensure clean builds for each channel.

### Q: Can I build without Visual Studio?

**A**: Yes, only .NET SDK required:

```cmd
REM Install .NET SDK only (no Visual Studio)
winget install Microsoft.DotNet.SDK.9

REM Build
cd Scripts
dotnet build "..\Source\Krypton Components\Krypton Toolkit Suite 2022 - VS2022.sln" -c Release
```

**Limitation**: Designer support requires Visual Studio

### Q: How do I build for only one framework?

**A**: Use `dotnet build` with `-f` flag:

```cmd
cd "Source\Krypton Components\Krypton.Toolkit"
dotnet build -c Debug -f net10.0-windows
```

**Output**: Only `Bin/Debug/net10.0-windows/` (other frameworks skipped)

---

## Document Information

**Document**: Build System Guide
**Companion Document**: [GitHub Actions Workflows Guide](GitHubActionsIndex.md)

### Related Documentation

- [GitHub Actions Workflows Guide](GitHubActionsIndex.md) - CI/CD pipelines

---

## Next Steps

✅ **Read Next**: [GitHub Actions Workflows Guide](GitHubActionsIndex.md) for CI/CD automation  
✅ **Setup**: Install all required .NET SDKs  
✅ **Test**: Run local build to verify environment  
✅ **Develop**: Use incremental builds for fast iteration  
