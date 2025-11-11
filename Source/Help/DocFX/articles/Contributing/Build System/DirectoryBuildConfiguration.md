# Directory.Build Configuration

## Overview

The Krypton Toolkit uses MSBuild's `Directory.Build.props` and `Directory.Build.targets` files to centralize build configuration and ensure consistent settings across all projects. These files are automatically imported by MSBuild for all projects in the directory tree.

## File Hierarchy

### Root Level
- `Directory.Build.props` - Global versioning and configuration

### Component Level
- `Source/Krypton Components/Directory.Build.props` - Component-specific properties
- `Source/Krypton Components/Directory.Build.targets` - Component-specific targets

### Inheritance Chain

```
Directory.Build.props (root)
    ↓ imported by
Source/Krypton Components/Directory.Build.props
    ↓ imported by
Each Krypton.*.csproj
```

## Root Directory.Build.props

**Location**: `Directory.Build.props`

**Purpose**: Global version calculation and conditional compilation symbols

### Version Calculation

The toolkit uses date-based semantic versioning:

**Format**: `Major.YY.MM.DayOfYear[-suffix]`

**Components**:
- **Major**: `100` (fixed)
- **Minor**: Current year (2 digits, e.g., `25` for 2025)
- **Build**: Current month (2 digits, e.g., `01` for January)
- **Revision**: Day of year (1-366)
- **Suffix**: Configuration-dependent (e.g., `-alpha`, `-beta`)

**Example**: `100.25.1.305` = Version 100, released in 2025, January, on the 305th day of the year

### Configuration-Based Versioning

#### Canary Configuration
```xml
<When Condition="'$(Configuration)' == 'Canary'">
    <PropertyGroup>
        <Minor>$([System.DateTime]::Now.ToString(yy))</Minor>
        <Build>$([System.DateTime]::Now.ToString(MM))</Build>
        <Revision>$([System.DateTime]::Now.get_DayOfYear().ToString())</Revision>
        
        <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
        <PackageVersion>100.$(Minor).$(Build).$(Revision)-beta</PackageVersion>
    </PropertyGroup>
</When>
```

**Properties**:
- `LibraryVersion`: Assembly version
- `PackageVersion`: NuGet package version with `-beta` suffix

#### Nightly Configuration
```xml
<When Condition="'$(Configuration)' == 'Nightly'">
    <PropertyGroup>
        <Minor>$([System.DateTime]::Now.ToString(yy))</Minor>
        <Build>$([System.DateTime]::Now.ToString(MM))</Build>
        <Revision>$([System.DateTime]::Now.get_DayOfYear().ToString())</Revision>
        
        <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
        <PackageVersion>100.$(Minor).$(Build).$(Revision)-alpha</PackageVersion>
    </PropertyGroup>
</When>
```

**Properties**:
- `PackageVersion`: Has `-alpha` suffix for nightly builds

#### Installer Configuration
```xml
<When Condition="'$(Configuration)' == 'Installer'">
    <PropertyGroup>
        <Minor>$([System.DateTime]::Now.ToString(yy))</Minor>
        <Build>$([System.DateTime]::Now.ToString(MM))</Build>
        <Revision>$([System.DateTime]::Now.get_DayOfYear().ToString())</Revision>
        
        <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
        <PackageVersion>100.$(Minor).$(Build).$(Revision)</PackageVersion>
    </PropertyGroup>
</When>
```

**Special Notes**:
- WiX installers require build numbers ≤ 256
- Uses month number for Build component

#### Release/Stable Configuration (Default)
```xml
<Otherwise>
    <PropertyGroup>
        <Minor>$([System.DateTime]::Now.ToString(yy))</Minor>
        <Build>$([System.DateTime]::Now.ToString(MM))</Build>
        <Revision>$([System.DateTime]::Now.get_DayOfYear().ToString())</Revision>
        
        <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
        <PackageVersion>100.$(Minor).$(Build).$(Revision)</PackageVersion>
    </PropertyGroup>
</Otherwise>
```

### .NET 10 Resource Handling

For .NET 10 compatibility:
```xml
<PropertyGroup Condition="'$(TargetFramework)' == 'net10.0-windows'">
    <GenerateResourceUsePreserializedResources>true</GenerateResourceUsePreserializedResources>
</PropertyGroup>
```

**Purpose**: Uses pre-serialized resources for better performance and compatibility

### Conditional Compilation Symbols

Defines configuration-specific compilation symbols:

```xml
<PropertyGroup Condition="'$(Configuration)' == 'Nightly'">
    <DefineConstants>$(DefineConstants);NIGHTLY</DefineConstants>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)' == 'Canary'">
    <DefineConstants>$(DefineConstants);CANARY</DefineConstants>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)' == 'Alpha'">
    <DefineConstants>$(DefineConstants);ALPHA</DefineConstants>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)' == 'Release'">
    <DefineConstants>$(DefineConstants);RELEASE</DefineConstants>
</PropertyGroup>

<PropertyGroup Condition="'$(Configuration)' == 'LTS'">
    <DefineConstants>$(DefineConstants);LTS</DefineConstants>
</PropertyGroup>
```

**Usage in Code**:
```csharp
#if NIGHTLY
    // Nightly-specific code
#endif

#if CANARY
    // Canary-specific code
#endif

#if DEBUG
    // Debug-specific code
#endif
```

## Component Directory.Build.props

**Location**: `Source/Krypton Components/Directory.Build.props`

**Purpose**: Component-specific build settings, assembly info, and NuGet package metadata

### Import Chain

```xml
<Import Project="$([MSBuild]::GetPathOfFileAbove('Directory.Build.props', '$(MSBuildThisFileDirectory)../../'))" />
```

Imports the root `Directory.Build.props` first, ensuring version properties are available.

### Language Version

```xml
<PropertyGroup>
    <LangVersion>preview</LangVersion>
</PropertyGroup>
```

**Purpose**: Enables latest C# language features (preview)

### Assembly Information

```xml
<PropertyGroup>
    <GenerateAssemblyInfo>true</GenerateAssemblyInfo>
    <NeutralLanguage>en</NeutralLanguage>
    <Authors>Phil Wright (A.K.A ComponentFactory), Peter Wagner (A.K.A Wagnerp), Simon Coghlan (A.K.A Smurf-IV), Giduac, Ahmed Abdelhameed, Lesandro and tobitege</Authors>
    <Copyright>© Component Factory Pty Ltd, 2006 - 2016. Then modifications by Peter Wagner (aka Wagnerp), Simon Coghlan (aka Smurf-IV), Giduac, Ahmed Abdelhameed, Lesandro and tobitege et al. 2017 - 2025. All rights reserved.</Copyright>
</PropertyGroup>
```

**Generated Files**: Auto-generates `AssemblyInfo.cs` with these attributes

### Version Assignment

```xml
<PropertyGroup>
    <Version>$(LibraryVersion)</Version>
</PropertyGroup>
```

Uses `LibraryVersion` from root `Directory.Build.props`.

### Package Output Directory

```xml
<PropertyGroup>
    <PackageOutputPath>$(MSBuildThisFileDirectory)..\..\Bin\Packages\$(Configuration)\</PackageOutputPath>
</PropertyGroup>
```

**Result**: Packages go to `Bin/Packages/<Configuration>/`
- `Bin/Packages/Release/`
- `Bin/Packages/Canary/`
- `Bin/Packages/Nightly/`

### Configuration-Specific Package Metadata

#### Canary Configuration

```xml
<When Condition="'$(Configuration)' == 'Canary'">
    <ItemGroup>
        <None Include="../../../Assets/PNG/NuGet Package Icons/Krypton Canary.png" 
              Link="Icon.png" Pack="true" PackagePath="" />
        <None Include="..\..\..\Documents\License\License.md">
            <Pack>True</Pack>
            <PackagePath>\</PackagePath>
        </None>
        <None Include="..\..\..\README.md">
            <Pack>True</Pack>
            <PackagePath>\</PackagePath>
        </None>
    </ItemGroup>
    
    <PropertyGroup>
        <PackageProjectUrl>https://github.com/Krypton-Suite/Standard-Toolkit</PackageProjectUrl>
        <PackageIcon>Krypton Canary.png</PackageIcon>
        <Authors>Peter William Wagner &amp; Simon Coghlan &amp; Giduac &amp; Ahmed Abdelhameed &amp; Lesandro &amp; tobitege &amp; Thomas Bolon</Authors>
        <PackageLicenseExpression>BSD-3-Clause</PackageLicenseExpression>
        <PackageRequireLicenseAcceptance>True</PackageRequireLicenseAcceptance>
        <PackageTags>Krypton ComponentFactory WinForms Themes Controls DataGrid Ribbon Workspace Tabs .NET Toolkit</PackageTags>
        <PackageReleaseNotes>Get updates here: https://github.com/Krypton-Suite/Standard-Toolkit</PackageReleaseNotes>
        <RepositoryURL>https://github.com/Krypton-Suite/Standard-Toolkit</RepositoryURL>
        <PublishRepositoryUrl>true</PublishRepositoryUrl>
        <EmbedUntrackedSources>true</EmbedUntrackedSources>
    </PropertyGroup>
</When>
```

**Features**:
- Custom Canary icon
- Includes License.md and README.md
- Source link enabled

#### Nightly Configuration

Similar to Canary, but uses `Krypton Nightly.png` icon.

#### Release/Stable Configuration

```xml
<Otherwise>
    <ItemGroup>
        <None Include="../../../Assets/PNG/NuGet Package Icons/Krypton Stable.png" 
              Link="Icon.png" Pack="true" PackagePath="" />
        <None Include="..\..\..\Documents\License\License.md">
            <Pack>True</Pack>
            <PackagePath>\</PackagePath>
        </None>
        <None Include="..\..\..\README.md">
            <Pack>True</Pack>
            <PackagePath>\</PackagePath>
        </None>
    </ItemGroup>
    
    <PropertyGroup>
        <TFMs Condition="'$(TFMs)' == ''">lite</TFMs>
    </PropertyGroup>
    
    <PropertyGroup>
        <PackageProjectUrl>https://github.com/Krypton-Suite/Standard-Toolkit</PackageProjectUrl>
        <PackageIcon>Krypton Stable.png</PackageIcon>
        <Authors>Peter William Wagner &amp; Simon Coghlan &amp; Giduac &amp; Ahmed Abdelhameed &amp; Lesandro &amp; tobitege &amp; Thomas Bolon</Authors>
        <PackageLicenseExpression>BSD-3-Clause</PackageLicenseExpression>
        <PackageReadmeFile>README.md</PackageReadmeFile>
        <PackageRequireLicenseAcceptance>True</PackageRequireLicenseAcceptance>
        <PackageTags>Krypton ComponentFactory WinForms Themes Controls DataGrid Ribbon Workspace Tabs .NET Toolkit</PackageTags>
        <PackageReleaseNotes>Get updates here: https://github.com/Krypton-Suite/Standard-Toolkit</PackageReleaseNotes>
        <RepositoryURL>https://github.com/Krypton-Suite/Standard-Toolkit</RepositoryURL>
        <PublishRepositoryUrl>true</PublishRepositoryUrl>
        <EmbedUntrackedSources>true</EmbedUntrackedSources>
    </PropertyGroup>
</Otherwise>
```

**Special Feature**: Defaults `TFMs` to `lite` if not specified

## Component Directory.Build.targets

**Location**: `Source/Krypton Components/Directory.Build.targets`

**Purpose**: Advanced versioning, assembly metadata, and package ID customization

### Version Properties by Configuration

#### Canary
```xml
<When Condition="'$(Configuration)' == 'Canary'">
    <PropertyGroup>
        <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
        <PackageVersion>100.$(Minor).$(Build).$(Revision)-beta</PackageVersion>
        <AssemblyVersion>100.$(Minor).$(Build).$(Revision)</AssemblyVersion>
        <FileVersion>100.$(Minor).$(Build).$(Revision)</FileVersion>
        
        <LangVersion>preview</LangVersion>
        <AnalysLevel>preview</AnalysLevel>
        
        <IncludeSymbols>True</IncludeSymbols>
        <SymbolPackageFormat>snupkg</SymbolPackageFormat>
    </PropertyGroup>
</When>
```

**Features**:
- Separate symbol packages (`.snupkg`)
- Preview language and analyzer versions

#### Nightly
Similar to Canary with `-alpha` suffix and symbol packages.

#### Release/Stable
```xml
<Otherwise>
    <PropertyGroup>
        <LibraryVersion>100.$(Minor).$(Build).$(Revision)</LibraryVersion>
        <PackageVersion>100.$(Minor).$(Build).$(Revision)</PackageVersion>
        <AssemblyVersion>100.$(Minor).$(Build).$(Revision)</AssemblyVersion>
        <FileVersion>100.$(Minor).$(Build).$(Revision)</FileVersion>
        
        <LangVersion>preview</LangVersion>
        <AnalysLevel>preview</AnalysLevel>
    </PropertyGroup>
</Otherwise>
```

### Assembly Info
```xml
<PropertyGroup>
    <GenerateAssemblyInfo>true</GenerateAssemblyInfo>
    <NeutralLanguage>en</NeutralLanguage>
    <Authors>Peter Wagner (A.K.A Wagnerp) and Simon Coghlan (A.K.A Smurf-IV), Giduac, Ahmed Abdelhameed, Lesandro, tobitege, Phil Wright (A.K.A ComponentFactory)</Authors>
    <Copyright>© Krypton Suite (Peter Wagner (aka Wagnerp), Simon Coghlan (aka Smurf-IV), Giduac, Ahmed Abdelhameed, Lesandro and tobitege) 2017 - 2025. Component Factory Pty Ltd (Phil Wright), 2006 - 2016. All rights reserved.</Copyright>
</PropertyGroup>
```

### Package ID Customization

#### Canary
```xml
<When Condition="'$(Configuration)' == 'Canary'">
    <PropertyGroup>
        <PackageId Condition="'$(TFMs)' == 'all'">$(PackageId).Canary</PackageId>
        <Description Condition="'$(TFMs)' == 'all'">
            An update to Component factory's krypton toolkit to support .NET Framework 4.7.2 - 4.8.1 and .NET 8 - 10. 
            $(Description) This package supports all .NET Framework versions starting .NET Framework 4.6.2 - 4.8.1 and .NET 8 - 10. 
            Also, all libraries are included targeting each specific framework version for performance purposes. 
            To view all of the standard toolkit package latest version information, please visit: 
            https://github.com/Krypton-Suite/Krypton-Toolkit-Suite-Version-Dashboard/blob/main/Documents/Modules/Standard/Krypton-Toolkit-Suite-Standard-Modules.md 
            To find out what's new, please visit: https://github.com/Krypton-Suite/Standard-Toolkit/blob/canary/Documents/Help/Changelog.md 
            This package is for those who want to try out the latest features before deployment.
        </Description>
    </PropertyGroup>
</When>
```

**Result**: Package named `Krypton.Toolkit.Canary` with detailed description

#### Nightly
Similar with `.Nightly` suffix and alpha-specific description.

#### Release (Lite)
```xml
<PropertyGroup>
    <PackageId Condition="'$(TFMs)' == 'lite'">$(PackageId).Lite</PackageId>
    <Description Condition="'$(TFMs)' == 'lite'">
        An update to Component factory's krypton toolkit to support .NET Framework 4.8 - 4.8.1 and .NET 8 - 10. 
        $(Description) This package supports all .NET Framework versions starting .NET Framework 4.8 - 4.8.1, .NET 6 - 8. 
        Also, all libraries are included targeting each specific framework version for performance purposes.
    </Description>
</PropertyGroup>
```

#### Release (All)
```xml
<PropertyGroup>
    <PackageId Condition="'$(TFMs)' == 'all'">$(PackageId)</PackageId>
    <Description Condition="'$(TFMs)' == 'all'">
        An update to Component factory's krypton toolkit to support .NET Framework 4.7.2 - 4.8.1 and .NET 8 - 10. 
        $(Description) This package supports all .NET Framework versions starting .NET Framework 4.6.2 - 4.8.1 and .NET 8 - 10.
    </Description>
</PropertyGroup>
```

## Properties Reference

### Global Properties

| Property | Source | Purpose |
|----------|--------|---------|
| `LibraryVersion` | Root Directory.Build.props | Assembly version |
| `PackageVersion` | Root Directory.Build.props | NuGet package version |
| `Configuration` | MSBuild | Build configuration |
| `TFMs` | MSBuild/props | Target frameworks mode (lite/all) |

### Component Properties

| Property | Source | Purpose |
|----------|--------|---------|
| `LangVersion` | Component Directory.Build.props | C# language version |
| `PackageOutputPath` | Component Directory.Build.props | NuGet output directory |
| `Version` | Component Directory.Build.props | Project version |
| `AssemblyVersion` | Component Directory.Build.targets | Assembly version |
| `FileVersion` | Component Directory.Build.targets | File version |

## Customization

### Override Version Locally

In a project file (`.csproj`):
```xml
<PropertyGroup>
    <Version>1.2.3.4</Version>
</PropertyGroup>
```

### Override Package Output

```xml
<PropertyGroup>
    <PackageOutputPath>C:\CustomPath\</PackageOutputPath>
</PropertyGroup>
```

### Add Custom Compilation Symbol

```xml
<PropertyGroup>
    <DefineConstants>$(DefineConstants);CUSTOM_SYMBOL</DefineConstants>
</PropertyGroup>
```

## Related Documentation

- [Version Management](05-Version-Management.md) - Detailed versioning strategy
- [NuGet Packaging](06-NuGet-Packaging.md) - Package creation
- [MSBuild Project Files](02-MSBuild-Project-Files.md) - .proj files
- [Build System Overview](01-Build-System-Overview.md) - System overview

