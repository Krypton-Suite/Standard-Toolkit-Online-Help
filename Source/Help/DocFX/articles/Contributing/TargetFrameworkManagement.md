# Target Framework Management Guide

This document provides comprehensive guidance on managing target framework selection across the Krypton Standard Toolkit solution. The target framework configuration is centralized using MSBuild's `Directory.Build.props` mechanism, ensuring consistency and maintainability across all projects.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [How It Works](#how-it-works)
- [Configuration Scenarios](#configuration-scenarios)
- [Managing Target Frameworks](#managing-target-frameworks)
- [Adding New Projects](#adding-new-projects)
- [Overriding Behavior](#overriding-behavior)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## Overview

The Krypton Standard Toolkit supports multiple .NET target frameworks to ensure broad compatibility:

- **.NET Framework**: `net472`, `net48`, `net481`
- **.NET (Modern)**: `net8.0-windows`, `net9.0-windows`, `net10.0-windows`

The target framework selection logic is centralized in `Source/Krypton Components/Directory.Build.props`, eliminating the need to duplicate configuration across individual project files. This approach provides:

- **Single Source of Truth**: All target framework logic in one location
- **Consistency**: All projects automatically use the same framework selection rules
- **Maintainability**: Changes propagate automatically to all projects
- **Flexibility**: Support for different build configurations and scenarios

---

## Architecture

### File Structure

```
Source/Krypton Components/
├── Directory.Build.props          ← Centralized target framework logic
├── Krypton.Toolkit/
│   └── Krypton.Toolkit 2022.csproj
├── Krypton.Ribbon/
│   └── Krypton.Ribbon 2022.csproj
├── Krypton.Navigator/
│   └── Krypton.Navigator 2022.csproj
├── Krypton.Workspace/
│   └── Krypton.Workspace 2022.csproj
├── Krypton.Docking/
│   └── Krypton.Docking 2022.csproj
├── Krypton.Utilities/
│   └── Krypton.Utilities.csproj
├── Krypton.Standard.Toolkit/
│   └── Krypton.Standard.Toolkit.csproj
└── TestForm/
    └── TestForm.csproj
```

### MSBuild Import Chain

The `Directory.Build.props` file is automatically imported by MSBuild for all projects in the directory and its subdirectories. The import hierarchy is:

1. Root `Directory.Build.props` (if exists)
2. `Source/Krypton Components/Directory.Build.props` ← **Target framework logic here**
3. Individual project `.csproj` files

Properties defined in `Directory.Build.props` are available to all projects, but individual projects can override them if needed.

---

## How It Works

### The Selection Logic

The target framework selection uses MSBuild's `<Choose>` element with conditional evaluation:

```xml
<Choose>
    <!-- Condition 1: Debug/Nightly/Canary builds -->
    <When Condition="'$(Configuration)' == 'Nightly' Or '$(Configuration)' == 'Canary' Or '$(Configuration)' == 'Debug'">
        <PropertyGroup>
            <TargetFrameworks>net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
        </PropertyGroup>
    </When>
    
    <!-- Condition 2: Skip .NET Framework builds -->
    <When Condition="'$(SkipNetFramework)' == 'true'">
        <PropertyGroup>
            <TargetFrameworks>net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
        </PropertyGroup>
    </When>
    
    <!-- Condition 3: Default (Release/Installer) -->
    <Otherwise>
        <PropertyGroup>
            <TargetFrameworks>net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
            <!-- Override when TFMs=all -->
            <TargetFrameworks Condition="'$(TFMs)' == 'all'">net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
        </PropertyGroup>
    </Otherwise>
</Choose>
```

### Evaluation Order

MSBuild evaluates conditions in order:

1. **First**: Checks if Configuration is `Debug`, `Nightly`, or `Canary`
2. **Second**: Checks if `SkipNetFramework` property is `true`
3. **Third**: Falls back to the default (`Otherwise`) case

**Important**: Only the first matching condition applies. If multiple conditions could match, the first one wins.

---

## Configuration Scenarios

### Scenario 1: Debug Development Builds

**Configuration**: `Debug`, `Nightly`, or `Canary`

**Target Frameworks**: All frameworks
```
net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows
```

**Use Case**: 
- Comprehensive testing across all supported frameworks
- Ensuring compatibility during development
- CI/CD pipelines that need full coverage

**Example Build Command**:
```cmd
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Debug
```

### Scenario 2: Skip .NET Framework (Modern Only)

**Property**: `SkipNetFramework=true`

**Target Frameworks**: Modern .NET only
```
net8.0-windows;net9.0-windows;net10.0-windows
```

**Use Case**:
- Faster builds during development/testing
- CI scenarios where .NET Framework support isn't needed
- Testing modern .NET features only

**Example Build Command**:
```cmd
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -p:SkipNetFramework=true
```

### Scenario 3: Release/Stable Builds (Default)

**Configuration**: `Release`, `Installer`, or any other configuration

**Target Frameworks**: .NET Framework 4.8+ and modern .NET
```
net48;net481;net8.0-windows;net9.0-windows;net10.0-windows
```

**Use Case**:
- Production builds
- NuGet package creation
- Balanced build time vs. compatibility

**Example Build Command**:
```cmd
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Release
```

### Scenario 4: All Frameworks (Including net472)

**Property**: `TFMs=all`

**Target Frameworks**: All frameworks including .NET Framework 4.7.2
```
net472;net48;net481;net8.0-windows;net9.0-windows;net10.0-windows
```

**Use Case**:
- Full compatibility testing
- Legacy support validation
- Complete framework coverage

**Example Build Command**:
```cmd
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Release -p:TFMs=all
```

**Note**: This only works when the default (`Otherwise`) branch is active. It won't work with `Debug`/`Nightly`/`Canary` configurations since they already include all frameworks.

---

## Managing Target Frameworks

### Modifying the Centralized Logic

To change target framework selection for all projects, edit `Source/Krypton Components/Directory.Build.props`:

#### Adding a New Target Framework

1. Locate the relevant `<TargetFrameworks>` property group
2. Add the new TFM to the semicolon-separated list:

```xml
<TargetFrameworks>net48;net481;net8.0-windows;net9.0-windows;net10.0-windows;net11.0-windows</TargetFrameworks>
```

3. Update all relevant conditions (Debug, SkipNetFramework, default)

#### Removing a Target Framework

1. Remove the TFM from all `<TargetFrameworks>` properties
2. Ensure you update all three condition branches

#### Changing Framework Selection Rules

1. Modify the condition expressions in the `<Choose>` element
2. Adjust the `<TargetFrameworks>` values in the corresponding `<PropertyGroup>`

**Example**: To exclude `net472` from Debug builds:

```xml
<When Condition="'$(Configuration)' == 'Nightly' Or '$(Configuration)' == 'Canary' Or '$(Configuration)' == 'Debug'">
    <PropertyGroup>
        <TargetFrameworks>net48;net481;net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
    </PropertyGroup>
</When>
```

### Adding a New Configuration

To add a new build configuration that uses specific target frameworks:

1. Add a new `<When>` condition before the `<Otherwise>` block:

```xml
<When Condition="'$(Configuration)' == 'YourNewConfig'">
    <PropertyGroup>
        <TargetFrameworks>net8.0-windows;net9.0-windows</TargetFrameworks>
    </PropertyGroup>
</When>
```

2. Ensure the new configuration is defined in project files (if needed):

```xml
<PropertyGroup>
    <Configurations>Debug;Release;Installer;Nightly;Canary;YourNewConfig</Configurations>
</PropertyGroup>
```

### Modifying Framework Lists

When updating framework lists, maintain consistency across all branches:

| Branch | Typical Frameworks | Notes |
|--------|-------------------|-------|
| Debug/Nightly/Canary | All frameworks | Maximum compatibility testing |
| SkipNetFramework | Modern .NET only | Fast builds, modern features |
| Default (Release) | net48+ and modern | Production balance |

---

## Adding New Projects

### Automatic Inheritance

New projects added to `Source/Krypton Components/` or any subdirectory automatically inherit the target framework configuration from `Directory.Build.props`. **No action is required.**

### Project File Structure

Your new project file should look like this:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Library</OutputType>
    <!-- Other project-specific properties -->
  </PropertyGroup>
  
  <!-- Target frameworks are automatically set by Directory.Build.props -->
</Project>
```

### Verification

To verify a project is using the centralized configuration:

1. Build the project and check the output
2. Inspect the build log for target framework information
3. Use MSBuild property evaluation:

```cmd
dotnet msbuild "YourProject.csproj" -t:GetTargetFramework -p:Configuration=Debug
```

---

## Overriding Behavior

### Project-Level Override

If a specific project needs different target frameworks, you can override the centralized setting by defining `<TargetFrameworks>` directly in the project file:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <!-- Override centralized configuration -->
  <PropertyGroup>
    <TargetFrameworks>net8.0-windows;net9.0-windows</TargetFrameworks>
  </PropertyGroup>
  
  <!-- Rest of project file -->
</Project>
```

**Warning**: Overriding should be rare and well-documented. It breaks the "single source of truth" principle.

### Conditional Override

You can also conditionally override based on project-specific needs:

```xml
<PropertyGroup Condition="'$(MSBuildProjectName)' == 'SpecialProject'">
    <TargetFrameworks>net8.0-windows</TargetFrameworks>
</PropertyGroup>
```

### Build-Time Override

Override target frameworks at build time using MSBuild properties:

```cmd
dotnet build YourProject.csproj -p:TargetFrameworks=net8.0-windows
```

**Note**: This overrides the centralized configuration for that specific build only.

---

## Troubleshooting

### Problem: Project Not Using Centralized Configuration

**Symptoms**:
- Project builds with different frameworks than expected
- Build output shows unexpected target frameworks

**Solutions**:

1. **Verify Import Chain**:
   - Ensure `Directory.Build.props` exists in `Source/Krypton Components/`
   - Check that the project is in a subdirectory of that location

2. **Check for Overrides**:
   - Search the project file for `<TargetFrameworks>` property
   - Remove any project-level definitions if they shouldn't be there

3. **Verify MSBuild Evaluation**:
   ```cmd
   dotnet msbuild YourProject.csproj -t:GetTargetFramework -v:detailed
   ```

### Problem: Configuration Not Matching Expected Behavior

**Symptoms**:
- Debug builds not including all frameworks
- Release builds including net472 when they shouldn't

**Solutions**:

1. **Check Configuration Name**:
   - Ensure configuration names match exactly (case-sensitive)
   - Verify: `Debug`, `Nightly`, `Canary` (not `debug`, `DEBUG`)

2. **Verify Condition Logic**:
   - Review the `<Choose>` conditions in `Directory.Build.props`
   - Ensure conditions are evaluated in the correct order

3. **Check Property Values**:
   ```cmd
   dotnet build YourProject.csproj -c Debug -v:detailed
   ```
   Look for property evaluation in the build log

### Problem: TFMs=all Not Working

**Symptoms**:
- Setting `TFMs=all` doesn't include net472

**Solutions**:

1. **Check Configuration**:
   - `TFMs=all` only works with Release/Installer configurations
   - Debug/Nightly/Canary already include all frameworks

2. **Verify Property Syntax**:
   ```cmd
   dotnet build YourProject.csproj -c Release -p:TFMs=all
   ```

### Problem: SkipNetFramework Not Working

**Symptoms**:
- Setting `SkipNetFramework=true` still builds .NET Framework targets

**Solutions**:

1. **Check Condition Order**:
   - Debug/Nightly/Canary configurations take precedence
   - Use Release configuration with SkipNetFramework

2. **Verify Property Value**:
   ```cmd
   dotnet build YourProject.csproj -c Release -p:SkipNetFramework=true -v:detailed
   ```

### Problem: Build Performance Issues

**Symptoms**:
- Builds taking too long
- Building unnecessary frameworks

**Solutions**:

1. **Use SkipNetFramework for Development**:
   ```cmd
   dotnet build -p:SkipNetFramework=true
   ```

2. **Build Specific Framework**:
   ```cmd
   dotnet build -f net8.0-windows
   ```

3. **Use Release Configuration**:
   - Release builds exclude net472 by default (faster)

---

## Best Practices

### 1. Centralize All Framework Logic

✅ **Do**: Keep all target framework selection in `Directory.Build.props`

❌ **Don't**: Duplicate framework logic in individual project files

### 2. Document Special Cases

If a project must override the centralized configuration:

✅ **Do**: Add a comment explaining why:
```xml
<!-- This project only supports .NET 8+ due to API dependencies -->
<PropertyGroup>
    <TargetFrameworks>net8.0-windows;net9.0-windows;net10.0-windows</TargetFrameworks>
</PropertyGroup>
```

❌ **Don't**: Override without documentation

### 3. Test Configuration Changes

Before committing changes to `Directory.Build.props`:

1. Build a representative project in each configuration
2. Verify expected frameworks are built
3. Check build output for correctness

### 4. Use Appropriate Configurations

- **Development**: Use `Debug` for comprehensive testing
- **CI/CD**: Use `Nightly` or `Canary` for full framework coverage
- **Local Testing**: Use `SkipNetFramework=true` for faster iteration
- **Production**: Use `Release` for optimized builds

### 5. Maintain Framework Lists Consistently

When adding/removing frameworks:

1. Update all three condition branches
2. Update documentation
3. Test across all configurations
4. Update CI/CD pipelines if needed

### 6. Version Control Considerations

- Commit `Directory.Build.props` changes with clear messages
- Document breaking changes if framework support is removed
- Tag releases when framework support changes

### 7. Performance Optimization

- Use `SkipNetFramework=true` during active development
- Use Release configuration for production builds
- Build specific frameworks when testing: `-f net8.0-windows`

---

## Advanced Topics

### MSBuild Property Evaluation

Understanding MSBuild property evaluation order helps debug issues:

1. **Imports**: `Directory.Build.props` is imported early
2. **Properties**: Properties are evaluated in order of appearance
3. **Conditions**: Conditions are evaluated at property evaluation time
4. **Overrides**: Later definitions override earlier ones

### Property Precedence

When multiple sources define `<TargetFrameworks>`:

1. **Command-line** (`-p:TargetFrameworks=...`) - Highest precedence
2. **Project file** - Medium precedence
3. **Directory.Build.props** - Lower precedence (but applies to all projects)

### Conditional Framework Selection

You can create more complex conditions if needed:

```xml
<When Condition="'$(Configuration)' == 'Debug' And '$(SkipNetFramework)' != 'true'">
    <PropertyGroup>
        <TargetFrameworks>net472;net48;net481;net8.0-windows</TargetFrameworks>
    </PropertyGroup>
</When>
```

### Framework-Specific Code

When writing framework-specific code, use conditional compilation:

```csharp
#if NET472 || NET48 || NET481
    // .NET Framework specific code
#else
    // Modern .NET specific code
#endif
```

Or use MSBuild conditions in project files:

```xml
<ItemGroup Condition="'$(TargetFramework)' == 'net472'">
    <Reference Include="LegacyAssembly" />
</ItemGroup>
```

---

## Related Documentation

- [MSBuild Directory.Build.props Documentation](https://learn.microsoft.com/en-us/visualstudio/msbuild/customize-your-build)
- [.NET Target Frameworks](https://learn.microsoft.com/en-us/dotnet/standard/frameworks)
- [Multi-targeting in .NET](https://learn.microsoft.com/en-us/dotnet/standard/frameworks#how-to-specify-target-frameworks)

---

## Summary

The centralized target framework management system provides:

- ✅ Consistent framework selection across all projects
- ✅ Easy maintenance through single-file configuration
- ✅ Flexible build scenarios via MSBuild properties
- ✅ Automatic inheritance for new projects

By following this guide, you can effectively manage target frameworks across the entire Krypton Standard Toolkit solution while maintaining consistency and reducing maintenance overhead.

