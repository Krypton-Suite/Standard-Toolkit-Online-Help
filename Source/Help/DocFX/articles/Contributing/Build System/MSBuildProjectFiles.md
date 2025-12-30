# MSBuild Project Files

## Overview

The Krypton Toolkit build system uses MSBuild project files (`.proj`) to orchestrate multi-project builds, NuGet package creation, and distribution archive generation. These files are located in the `Scripts/` directory.

## Project File Structure

All `.proj` files follow a similar structure:
1. Import global properties
2. Define configuration-specific properties
3. Define targets for Clean, Restore, Build
4. Define targets for package creation
5. Define targets for archive creation

## Core Project Files

### build.proj - Stable/Release Builds

**Purpose**: Builds stable production releases

**Key Properties**:
```xml
<Configuration>Release</Configuration>
<ReleaseBuildPath>..\Bin\Release\Zips</ReleaseBuildPath>
<ReleaseZipName>Krypton-Release</ReleaseZipName>
```

**Available Targets**:

#### Clean
Cleans all Krypton component projects for the Release configuration.
```cmd
msbuild build.proj /t:Clean
```

#### Restore
Restores NuGet packages for all Krypton components.
```cmd
msbuild build.proj /t:Restore
```

#### Build (Default)
Builds all Krypton components. Depends on Restore.
```cmd
msbuild build.proj /t:Build
```

#### CleanPackages
Deletes existing NuGet packages from `Bin/Packages/Release/`.
```cmd
msbuild build.proj /t:CleanPackages
```

#### PackLite
Creates NuGet packages for "lite" target frameworks (net48, net481, net8.0+).
- Cleans projects and NuGet assets
- Restores with `TFMs=lite`
- Packs with `TFMs=lite`
```cmd
msbuild build.proj /t:PackLite
```

#### PackAll
Creates NuGet packages for all target frameworks (net472-net10.0-windows).
- Cleans projects and NuGet assets
- Restores with `TFMs=all`
- Packs with `TFMs=all`
```cmd
msbuild build.proj /t:PackAll
```

#### Pack
Master packaging target. Depends on CleanPackages, PackLite, and PackAll.
Generates both Lite and full packages.
```cmd
msbuild build.proj /t:Pack
```

#### Push
Publishes NuGet packages to NuGet.org using `nuget.exe`.
```cmd
msbuild build.proj /t:Push
```
**Note**: Requires `NUGET_API_KEY` environment variable or configured API key.

#### CreateReleaseZip
Creates ZIP archive of Release binaries.
- Uses 7-Zip if available
- Falls back to PowerShell `Compress-Archive`
- Output: `Bin/Release/Zips/Krypton-Release_<yyyyMMdd>.zip`
```cmd
msbuild build.proj /t:CreateReleaseZip
```

#### CreateReleaseTar
Creates TAR.GZ archive of Release binaries.
- Tries 7-Zip (recommended)
- Falls back to Windows 10/11 tar command
- Falls back to Git Bash tar
- Output: `Bin/Release/Zips/Krypton-Release_<yyyyMMdd>.tar.gz`
```cmd
msbuild build.proj /t:CreateReleaseTar
```

#### CreateAllReleaseArchives
Creates both ZIP and TAR.GZ archives.
```cmd
msbuild build.proj /t:CreateAllReleaseArchives
```

### canary.proj - Beta Pre-Release Builds

**Purpose**: Builds beta pre-release packages for early adopters

**Key Properties**:
```xml
<Configuration>Canary</Configuration>
<CanaryBuildPath>..\Bin\Canary\Zips</CanaryBuildPath>
<CanaryZipName>Krypton-Canary</CanaryZipName>
```

**Available Targets**:
- `Clean` - Clean Canary configuration
- `Restore` - Restore packages
- `Build` - Build Canary configuration
- `CleanPackages` - Delete packages from `Bin/Packages/Canary/`
- `PackAll` - Create Canary packages (all TFMs, no Lite variant)
- `Pack` - Master packaging target (CleanPackages + PackAll)
- `Push` - Publish Canary packages
- `CreateCanaryZip` - Create Canary ZIP archive
- `CreateCanaryTar` - Create Canary TAR.GZ archive
- `CreateAllCanaryArchives` - Create both archives

**Key Differences from Stable**:
- No `PackLite` target (Canary always packs all TFMs)
- Packages get `-beta` suffix in NuGet
- Outputs to `Bin/Canary/` and `Bin/Packages/Canary/`

### nightly.proj - Alpha Nightly Builds

**Purpose**: Builds bleeding-edge alpha releases for developers and testers

**Key Properties**:
```xml
<Configuration>Nightly</Configuration>
<NightlyBuildPath>..\Bin\Nightly\Zips</NightlyBuildPath>
<NightlyZipName>Krypton-Nightly</NightlyZipName>
```

**Available Targets**:
- `Clean` - Clean Nightly configuration
- `Restore` - Restore packages
- `Build` - Build Nightly configuration
- `Rebuild` - Clean + Build
- `CleanPackages` - Delete packages from `Bin/Packages/Nightly/`
- `PackAll` - Create Nightly packages (all TFMs)
- `Pack` - Master packaging target
- `Push` - Publish Nightly packages
- `CreateNightlyZip` - Create Nightly ZIP archive
- `CreateNightlyTar` - Create Nightly TAR.GZ archive
- `CreateAllArchives` - Create both archives

**Key Differences**:
- Includes `Rebuild` target
- Packages get `-alpha` suffix in NuGet
- Outputs to `Bin/Nightly/` and `Bin/Packages/Nightly/`

### debug.proj - Debug Builds

**Purpose**: Local development debug builds

**Key Properties**:
```xml
<Configuration>Debug</Configuration>
```

**Available Targets**:
- `Clean` - Clean Debug configuration
- `Restore` - Restore packages
- `Build` - Build Debug configuration

**Key Differences**:
- No packaging or archive targets
- Simplified for local development

### installer.proj - Installer Builds

**Purpose**: Builds packages for demo installers

**Key Properties**:
```xml
<Configuration>Installer</Configuration>
```

**Available Targets**:
- `Clean` - Clean Installer configuration
- `Restore` - Restore packages
- `Build` - Build Installer configuration
- `CleanPackages` - Delete packages from `Bin/Packages/Installer/`
- `PackAll` - Create Installer packages
- `Pack` - Master packaging target
- `Push` - Publish Installer packages
- `CreateNightlyZip` - Create Installer ZIP (reuses Nightly zip logic)

**Special Notes**:
- WiX installers require build numbers ≤ 256
- Version uses month number for Build component

## Project File Patterns

### Project Selection Pattern

All `.proj` files use this pattern to select Krypton projects:
```xml
<ItemGroup>
    <Projects Include="..\Source\Krypton Components\Krypton.*\*.csproj" />
</ItemGroup>
```

This selects:
- `Krypton.Toolkit\Krypton.Toolkit 2022.csproj`
- `Krypton.Ribbon\Krypton.Ribbon 2022.csproj`
- `Krypton.Navigator\Krypton.Navigator 2022.csproj`
- `Krypton.Workspace\Krypton.Workspace 2022.csproj`
- `Krypton.Docking\Krypton.Docking 2022.csproj`

### NuGet Asset Cleanup Pattern

Before packing, intermediate NuGet files are deleted:
```xml
<ItemGroup>
    <NugetAssets Include="..\Source\Krypton Components\Krypton.*\obj\*.json" />
    <NugetAssets Include="..\Source\Krypton Components\Krypton.*\obj\*.cache" />
    <NugetAssets Include="..\Source\Krypton Components\Krypton.*\obj\*.g.targets" />
    <NugetAssets Include="..\Source\Krypton Components\Krypton.*\obj\*.g.props" />
</ItemGroup>
<Delete Files="@(NugetAssets)" />
```

This ensures clean package generation.

### MSBuild Invocation Pattern

Projects are built with configuration and TFM control:
```xml
<MSBuild Projects="@(Projects)" 
         Properties="Configuration=$(Configuration);TFMs=all" 
         Targets="Build" />
```

Key properties passed:
- `Configuration` - Debug, Release, Canary, Nightly, Installer
- `TFMs` - `lite`, `all`, or empty

## Archive Generation

### ZIP Archives

Uses multiple fallback methods:
1. **7-Zip** (preferred): Fast, best compression
2. **PowerShell Compress-Archive**: Built-in Windows

Example:
```xml
<!-- 7-Zip method -->
<Exec Command="7z.exe a -tzip &quot;$(ReleaseBuildPath)\$(ReleaseZipName)_$(StringDate).zip&quot; &quot;..\Bin\Release\*&quot; -x!*.json -x!*.pdb"
      Condition="Exists('C:\Program Files\7-Zip\7z.exe')" />

<!-- PowerShell fallback -->
<Exec Command="powershell.exe -Command &quot;Get-ChildItem '..\Bin\Release\*' -Recurse | Where-Object {$_.Extension -notin '.json','.pdb'} | Compress-Archive -DestinationPath '$(ReleaseBuildPath)\$(ReleaseZipName)_$(StringDate).zip' -Force&quot;"
      Condition="!Exists('C:\Program Files\7-Zip\7z.exe')" />
```

### TAR.GZ Archives

Uses multiple fallback methods:
1. **7-Zip**: Creates tar then compresses to tar.gz
2. **Windows tar**: Native tar in Windows 10/11
3. **Git Bash tar**: Uses Git's bundled tar

## Custom Target Execution

### Execute Specific Target
```cmd
msbuild build.proj /t:TargetName
```

### Execute Multiple Targets
```cmd
msbuild build.proj /t:Clean;Build
```

### Override Configuration
```cmd
msbuild build.proj /t:Build /p:Configuration=Debug
```

### Override TFMs
```cmd
msbuild build.proj /t:Build /p:TFMs=lite
```

### Verbose Output
```cmd
msbuild build.proj /t:Build /v:detailed
```

### Save to Log File
```cmd
msbuild build.proj /t:Build /fl /flp:logfile=build.log
```

### Binary Log
```cmd
msbuild build.proj /t:Build /bl:build.binlog
```

## Best Practices

### 1. Clean Before Major Builds
```cmd
msbuild build.proj /t:Clean;Build
```

### 2. Use Rebuild for Complete Rebuild
```cmd
msbuild nightly.proj /t:Rebuild
```

### 3. Test Packaging Locally Before Push
```cmd
msbuild build.proj /t:Pack
# Verify packages in Bin/Packages/Release/
msbuild build.proj /t:Push
```

### 4. Use Binary Logs for Troubleshooting
```cmd
msbuild build.proj /t:Build /bl:build.binlog
# View with MSBuild Structured Log Viewer
```

### 5. Parallel Builds
MSBuild automatically parallelizes project builds. For explicit control:
```cmd
msbuild build.proj /t:Build /m:4
```

## Related Documentation

- [Build Scripts](BuildScripts.md) - Command-line build scripts
- [Directory.Build Configuration](DirectoryBuildConfiguration.md) - Property inheritance
- [NuGet Packaging](NuGetPackaging.md) - Package configuration
- [Version Management](VersionManagement.md) - Versioning details

