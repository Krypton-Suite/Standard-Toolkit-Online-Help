# Build System Overview

## Introduction

The Krypton Toolkit Suite uses a sophisticated MSBuild-based build system designed for Windows environments. The build system supports multiple release channels, target frameworks, and automated CI/CD workflows.

## Key Features

- **Multi-Channel Builds**: Support for Stable, Canary, Nightly, Debug, and Installer configurations
- **Multi-Target Framework**: Builds for .NET Framework 4.7.2-4.8.1, .NET 8-10 Windows
- **Automated Versioning**: Date-based semantic versioning (Major.YY.MM.DayOfYear)
- **NuGet Package Creation**: Automated package generation with configuration-specific metadata
- **Archive Generation**: Creates ZIP and TAR.GZ distribution archives
- **CI/CD Integration**: Full GitHub Actions workflow support
- **Modern Build Tool**: Optional Terminal UI tool for interactive builds

## Build System Components

### 1. MSBuild Project Files (`.proj`)

Located in `Scripts/`:
- `build.proj` - Stable/Release builds
- `canary.proj` - Beta pre-release builds
- `nightly.proj` - Alpha nightly builds
- `debug.proj` - Debug builds
- `installer.proj` - Installer-specific builds

### 2. Windows Command Scripts (`.cmd`)

Located in `Scripts/`:
- `build-stable.cmd` - Build stable releases
- `build-canary.cmd` - Build canary releases
- `build-nightly.cmd` - Build nightly releases
- `buildsolution.cmd` - Interactive solution builder
- `purge.cmd` - Clean build artifacts
- `publish.cmd` - Publish packages to NuGet

### 3. Directory.Build Files

- `Directory.Build.props` (root) - Global build properties and versioning
- `Source/Krypton Components/Directory.Build.props` - Component-specific properties
- `Source/Krypton Components/Directory.Build.targets` - Component-specific targets

### 4. GitHub Actions Workflows

Located in `.github/workflows/`:
- `build.yml` - CI builds for pull requests and branches
- `release.yml` - Production releases for multiple branches
- `nightly.yml` - Automated nightly releases with change detection

### 5. ModernBuild Tool

Located in `Scripts/ModernBuild/`:
- Modern Terminal UI tool for interactive builds
- Supports all build configurations and NuGet operations
- Real-time build output and logging

## Build Configurations

### Configuration Overview

| Configuration | Purpose | Package Suffix | Target Audience |
|--------------|---------|----------------|-----------------|
| Release | Stable production releases | None or `.Lite` | Production users |
| Canary | Beta pre-releases | `.Canary` (with `-beta` tag) | Early adopters |
| Nightly | Alpha nightly builds | `.Nightly` (with `-alpha` tag) | Developers/testers |
| Debug | Development debugging | N/A | Local development |
| Installer | Demo installer packages | `.Installer` | Demo/installer use |

### Target Frameworks (TFMs)

The build system supports multiple target framework monikers:

- **Full Framework**: `net472`, `net48`, `net481`
- **.NET**: `net8.0-windows`, `net9.0-windows`, `net10.0-windows`

Two packaging modes:
- **Lite** (`TFMs=lite`): Latest frameworks only (net48, net481, net8.0+)
- **All** (`TFMs=all`): All supported frameworks

## Directory Structure

```
Standard-Toolkit/
├── Scripts/              # Build scripts and project files
│   ├── *.cmd            # Windows batch scripts
│   ├── *.proj           # MSBuild project files
│   └── ModernBuild/     # Modern build tool
├── Source/
│   └── Krypton Components/
│       ├── Krypton.Toolkit/
│       ├── Krypton.Ribbon/
│       ├── Krypton.Navigator/
│       ├── Krypton.Workspace/
│       └── Krypton.Docking/
├── Bin/                 # Build outputs
│   ├── Debug/
│   ├── Release/
│   ├── Canary/
│   ├── Nightly/
│   └── Packages/        # NuGet packages
├── Logs/                # Build logs
└── Documents/
    └── Workflows/       # Build documentation
```

## Build Outputs

### Binary Outputs

Location: `Bin/<Configuration>/`

Each configuration produces outputs for all target frameworks in separate subdirectories:
- `net472/`, `net48/`, `net481/`
- `net8.0-windows/`, `net9.0-windows/`, `net10.0-windows/`

### NuGet Packages

Location: `Bin/Packages/<Configuration>/`

Generated packages:
- `Krypton.Toolkit[.Suffix].<version>.nupkg`
- `Krypton.Ribbon[.Suffix].<version>.nupkg`
- `Krypton.Navigator[.Suffix].<version>.nupkg`
- `Krypton.Workspace[.Suffix].<version>.nupkg`
- `Krypton.Docking[.Suffix].<version>.nupkg`
- Symbol packages: `*.snupkg` (for Canary and Nightly)

### Distribution Archives

Location: `Bin/<Configuration>/Zips/`

Generated archives:
- `Krypton-<Channel>_<yyyyMMdd>.zip`
- `Krypton-<Channel>_<yyyyMMdd>.tar.gz`

## Prerequisites

### Required Software

1. **Windows 10/11**
   - Long paths must be enabled for local builds

2. **Visual Studio 2022**
   - Any edition: Preview, Enterprise, Professional, Community, or BuildTools
   - Required workload: .NET desktop development

3. **.NET SDKs**
   - .NET Framework 4.7.2-4.8.1 developer packs
   - .NET 8.0 SDK (minimum)
   - .NET 9.0 SDK (recommended)
   - .NET 10.0 SDK (optional, for latest builds)

4. **NuGet CLI** (for package publishing)
   - Download from: https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
   - Place in PATH or in `Scripts/` directory

### Optional Software

- **7-Zip** - For creating TAR.GZ archives
- **Git** - For source control and automated workflows

## Common Build Tasks

### Build Debug (Local Development)
```cmd
cd Scripts
build-stable.cmd Build
```
or
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

### Build Release
```cmd
cd Scripts
build-stable.cmd Build
```

### Build and Pack Release
```cmd
cd Scripts
msbuild build.proj /t:Build
msbuild build.proj /t:Pack
```

### Build Nightly
```cmd
cd Scripts
build-nightly.cmd Build
```

### Clean Build Artifacts
```cmd
cd Scripts
purge.cmd
```

### Create Distribution Archives
```cmd
cd Scripts
msbuild build.proj /t:CreateAllReleaseArchives
```

## Build System Workflow

1. **Configuration Selection**: Choose build configuration (Debug, Release, Canary, Nightly)
2. **Version Calculation**: Automatic version generation based on current date
3. **Project Restore**: NuGet package restoration for all projects
4. **Compilation**: Multi-target compilation for all frameworks
5. **Package Creation**: NuGet package generation with metadata
6. **Archive Generation**: Optional ZIP/TAR.GZ archive creation
7. **Publishing**: Optional push to NuGet.org or GitHub Packages

## Next Steps

For detailed information about specific aspects of the build system:

- [MSBuild Project Files](MSBuildProjectFiles.md) - Detailed .proj file documentation
- [Build Scripts](BuildScripts.md) - Command script documentation
- [Directory.Build Configuration](DirectoryBuildConfiguration.md) - MSBuild configuration
- [Version Management](VersionManagement.md) - Versioning strategy
- [NuGet Packaging](NuGetPackaging.md) - Package creation and publishing
- [GitHub Actions Workflows](GitHubActionsWorkflows.md) - CI/CD documentation
- [ModernBuild Tool](ModernBuildTool.md) - Interactive build tool
- [Troubleshooting](Troubleshooting.md) - Common issues and solutions

## Additional Resources

- [Visual Studio 2022 Downloads](https://visualstudio.microsoft.com/downloads/)
- [.NET SDK Downloads](https://dotnet.microsoft.com/download)
- [MSBuild Reference](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild)
- [NuGet Documentation](https://docs.microsoft.com/en-us/nuget/)

