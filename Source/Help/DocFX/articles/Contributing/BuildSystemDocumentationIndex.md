# Krypton Toolkit Build System and Workflows Documentation

## Overview

This document contains comprehensive developer documentation for the Krypton Toolkit build system, workflows, and development processes. The documentation is organized into focused topics, each in its own file.

## Documentation Index

### 1. [Build System Overview](Build%20System/BuildSystemOverview.md)
**Start here for an introduction to the build system.**

- Build system architecture and components
- Configuration overview (Stable, Canary, Nightly, Debug, Installer)
- Target frameworks and multi-targeting
- Directory structure
- Build outputs and artifacts
- Prerequisites and requirements
- Common build tasks

### 2. [MSBuild Project Files](Build%20System/MSBuildProjectFiles.md)
**Detailed documentation of `.proj` files.**

- Project file structure and patterns
- `build.proj` - Stable/Release builds
- `canary.proj` - Beta pre-releases
- `nightly.proj` - Alpha nightly builds
- `debug.proj` - Debug builds
- `installer.proj` - Installer packages
- Available targets (Clean, Restore, Build, Pack, Push, etc.)
- Archive generation (ZIP, TAR.GZ)
- Custom target execution

### 3. [Build Scripts](Build%20System/BuildScripts.md)
**Windows command scripts for building and maintenance.**

- `build-stable.cmd` - Stable release builds
- `build-canary.cmd` - Canary release builds
- `build-nightly.cmd` - Nightly release builds
- `buildsolution.cmd` - Interactive builder
- `purge.cmd` - Clean build artifacts
- `publish.cmd` - Publish to NuGet
- Visual Studio detection
- Logging and troubleshooting

### 4. [Directory.Build Configuration](Build%20System/DirectoryBuildConfiguration.md)
**MSBuild property and target configuration.**

- Root `Directory.Build.props` - Global versioning
- Component `Directory.Build.props` - Component properties
- Component `Directory.Build.targets` - Component targets
- Version calculation by configuration
- Conditional compilation symbols
- Assembly information
- NuGet package metadata
- Property inheritance

### 5. [Version Management](Build%20System/VersionManagement.md)
**Automated versioning strategy and implementation.**

- Version format: `Major.Minor.Build.Revision[-Suffix]`
- Date-based semantic versioning
- Configuration-specific versioning
- Version properties (Assembly, File, Package)
- Version ordering and SemVer compliance
- Querying version information
- Best practices and troubleshooting

### 6. [NuGet Package Creation and Publishing](Build%20System/NuGetPackaging.md)
**Complete guide to NuGet packages.**

- Package structure and variants
- Lite vs. full packages
- Configuration-specific packages (Stable, Canary, Nightly)
- Package creation workflow
- Package metadata and dependencies
- Publishing to NuGet.org
- Publishing to GitHub Packages
- Package verification
- Local package testing
- Troubleshooting

### 7. [GitHub Actions CI/CD Workflows](Build%20System/GitHubActionsWorkflows.md)
**Automated continuous integration and deployment.**

- `build.yml` - CI builds for PRs and branches
- `release.yml` - Production releases for multiple branches
- `nightly.yml` - Automated nightly builds with change detection
- Security features and verification
- Required secrets and variables
- Workflow outputs and notifications
- Troubleshooting CI/CD issues
- Manual workflow execution

### 8. [ModernBuild Tool](Build%20System/ModernBuildTool.md)
**Interactive Terminal UI build tool.**

- Installation and running
- User interface layout
- Ops Page - Build operations
- NuGet Page - Package publishing
- Controls and keyboard shortcuts
- Build logs and status
- Project file detection
- Troubleshooting ModernBuild

### 9. [Local Development Workflow](Build%20System/LocalDevelopmentWorkflow.md)
**Developer guide for daily development.**

- Development environment setup
- Daily development cycle
- Building specific projects
- Testing with TestForm and test harnesses
- Debugging (Visual Studio, multiple frameworks)
- Working with multiple target frameworks
- Code style and guidelines
- Making pull requests
- Local package testing
- Performance profiling

### 10. [Troubleshooting Guide](Build%20System/Troubleshooting.md)
**Solutions to common issues.**

- Build system issues
- Compilation errors
- NuGet package issues
- GitHub Actions issues
- Runtime issues
- Performance issues
- Getting help and reporting issues

## Quick Start

### New to the Project?

1. Start with [Build System Overview](Build%20System/BuildSystemOverview.md)
2. Set up your environment using [Local Development Workflow](Build%20System/LocalDevelopmentWorkflow.md)
3. Try building with [Build Scripts](Build%20System/BuildScripts.md)

### Building the Toolkit?

1. Review [Build Scripts](Build%20System/BuildScripts.md)
2. Understand [MSBuild Project Files](Build%20System/MSBuildProjectFiles.md)
3. Learn about [Version Management](Build%20System/VersionManagement.md)

### Creating Packages?

1. Read [NuGet Package Creation and Publishing](Build%20System/NuGetPackaging.md)
2. Understand [Version Management](Build%20System/VersionManagement.md)
3. Review [Directory.Build Configuration](Build%20System/DirectoryBuildConfiguration.md)

### Setting up CI/CD?

1. Study [GitHub Actions CI/CD Workflows](Build%20System/GitHubActionsWorkflows.md)
2. Understand [Version Management](Build%20System/VersionManagement.md)
3. Review [NuGet Package Creation and Publishing](Build%20System/NuGetPackaging.md)

### Troubleshooting?

1. Check [Troubleshooting Guide](Build%20System/Troubleshooting.md) first
2. Review relevant topic documentation
3. Check GitHub Issues

## Common Tasks

### Build Debug Locally
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

See: [Local Development Workflow](Build%20System/LocalDevelopmentWorkflow.md#building-specific-projects)

### Build Release
```cmd
cd Scripts
build-stable.cmd Build
```

See: [Build Scripts](Build%20System/BuildScripts.md#build-stable-cmd)

### Create NuGet Packages
```cmd
cd Scripts
msbuild build.proj /t:Build;Pack
```

See: [NuGet Package Creation and Publishing](Build%20System/NuGetPackaging.md#package-creation-workflow)

### Publish to NuGet.org
```cmd
cd Scripts
publish.cmd
```

See: [NuGet Package Creation and Publishing](Build%20System/NuGetPackaging.md#publishing-to-nugetorg)

### Clean Build Artifacts
```cmd
cd Scripts
purge.cmd
```

See: [Build Scripts](Build%20System/BuildScripts.md#purge-cmd)

### Run TestForm
```cmd
dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug
```

See: [Local Development Workflow](Build%20System/LocalDevelopment-Workflow.md#using-testform)

## Conventions

### Code Examples

All code examples use:
- **Windows Command Prompt** syntax (not PowerShell or Bash)
- **Absolute paths** where needed for clarity
- **Relative paths** from repository root by default

### Terminology

| Term | Meaning |
|------|---------|
| **TFM** | Target Framework Moniker (e.g., `net8.0-windows`) |
| **Configuration** | Build configuration (Debug, Release, Canary, Nightly, Installer) |
| **Channel** | Release channel (Stable, Canary, Nightly) |
| **Lite** | Package variant with fewer frameworks (`TFMs=lite`) |
| **All** | Package variant with all frameworks (`TFMs=all`) |
| **CI/CD** | Continuous Integration / Continuous Deployment |

## Contributing to Documentation

### Updating Documentation

1. Edit relevant `.md` file in `Documents/Workflows/`
2. Follow existing formatting and structure
3. Update cross-references if needed
4. Update this README if adding new files

### Adding New Documentation

1. Create new file: `##-New-Topic.md`
2. Add entry to [Documentation Index](#documentation-index)
3. Add to [Quick Start](#quick-start) if relevant
4. Add cross-references in related documents

### Documentation Standards

- Use Markdown formatting
- Include code examples for common tasks
- Provide troubleshooting tips where applicable
- Cross-reference related documentation
- Keep line length reasonable (80-120 characters preferred)
- Use tables for structured information
- Include command-line examples with expected outputs

## Additional Resources

### External Documentation

- [MSBuild Reference](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild)
- [NuGet Documentation](https://docs.microsoft.com/en-us/nuget/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [.NET SDK Documentation](https://docs.microsoft.com/en-us/dotnet/)

### Repository Links

- [GitHub Repository](https://github.com/Krypton-Suite/Standard-Toolkit)
- [NuGet Packages](https://www.nuget.org/packages?q=Krypton.Toolkit)
- [GitHub Issues](https://github.com/Krypton-Suite/Standard-Toolkit/issues)
- [GitHub Releases](https://github.com/Krypton-Suite/Standard-Toolkit/releases)

### Krypton Suite Resources

- [Krypton Toolkit Suite Version Dashboard](https://github.com/Krypton-Suite/Krypton-Toolkit-Suite-Version-Dashboard)

