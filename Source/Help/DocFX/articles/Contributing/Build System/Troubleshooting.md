# Troubleshooting Guide

## Overview

This guide provides solutions to common issues encountered when building, developing, and deploying the Krypton Toolkit. Issues are organized by category with symptoms, causes, and detailed solutions.

## Build System Issues

### Visual Studio 2022 Not Detected

**Symptoms**:
- Build scripts report "Unable to detect suitable environment"
- MSBuild not found

**Causes**:
- Visual Studio 2022 not installed
- Non-standard installation path
- Missing MSBuild component

**Solutions**:

1. **Verify Visual Studio Installation**:
```cmd
dir "%ProgramFiles%\Microsoft Visual Studio\2022\"
```

Expected editions: Preview, Enterprise, Professional, Community, BuildTools

2. **Install Visual Studio 2022**:
   - Download from: https://visualstudio.microsoft.com/downloads/
   - Install ".NET desktop development" workload

3. **Manually Specify MSBuild Path**:
```cmd
set MSBUILDPATH=C:\CustomPath\MSBuild\Current\Bin
cd Scripts
"%MSBUILDPATH%\msbuild.exe" /t:Build build.proj
```

4. **Use dotnet build Instead**:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

### SDK Version Not Found

**Symptoms**:
- Error: "The SDK 'Microsoft.NET.Sdk' specified could not be found"
- Build fails with SDK errors

**Causes**:
- Required .NET SDK not installed
- Incorrect SDK version in `global.json`

**Solutions**:

1. **Check Installed SDKs**:
```cmd
dotnet --list-sdks
```

2. **Install Required SDK**:
   - Download from: https://dotnet.microsoft.com/download
   - Minimum: .NET 8.0 SDK

3. **Remove or Update global.json**:
```cmd
del global.json
```

Or edit to use available SDK:
```json
{
  "sdk": {
    "version": "8.0.100",
    "rollForward": "latestFeature"
  }
}
```

### Long Path Errors

**Symptoms**:
- Error: "The specified path, file name, or both are too long"
- Build fails with path length errors

**Cause**:
- Windows long paths not enabled
- Path exceeds 260 characters

**Solutions**:

1. **Enable Long Paths** (Run as Administrator):
```cmd
reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f
```

2. **Restart Computer** after enabling

3. **Verify Setting**:
```cmd
reg query HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled
```

Should show: `LongPathsEnabled    REG_DWORD    0x1`

4. **Move Repository Closer to Root**:
```cmd
# Instead of: C:\Users\Username\Documents\Projects\Krypton\Standard-Toolkit
# Use: C:\Dev\Standard-Toolkit
```

### NuGet Restore Failures

**Symptoms**:
- Error: "Unable to load the service index for source"
- Package restore fails

**Causes**:
- Network connectivity issues
- Corrupted NuGet cache
- Firewall/proxy blocking

**Solutions**:

1. **Clear NuGet Cache**:
```cmd
nuget.exe locals all -clear
```

Or:
```cmd
dotnet nuget locals all --clear
```

2. **Verify Network**:
```cmd
ping api.nuget.org
```

3. **Check NuGet Sources**:
```cmd
nuget.exe sources list
```

4. **Reset NuGet Configuration**:
```cmd
del %APPDATA%\NuGet\NuGet.Config
```

5. **Configure Proxy** (if behind corporate proxy):
```cmd
nuget.exe config -set http_proxy=http://proxy:port
nuget.exe config -set http_proxy.user=username
nuget.exe config -set http_proxy.password=password
```

### Build Hangs or Stalls

**Symptoms**:
- Build process hangs indefinitely
- No output for extended period

**Causes**:
- Deadlocked MSBuild processes
- Antivirus scanning files
- Corrupted build state

**Solutions**:

1. **Kill MSBuild Processes**:
```cmd
taskkill /F /IM MSBuild.exe
taskkill /F /IM dotnet.exe
```

2. **Disable Antivirus Temporarily**:
   - Add repository folder to exclusions
   - Or disable real-time scanning during build

3. **Clean and Rebuild**:
```cmd
cd Scripts
purge.cmd
build-stable.cmd Build
```

4. **Use Single-Threaded Build**:
```cmd
msbuild build.proj /t:Build /m:1
```

### Permission Denied Errors

**Symptoms**:
- Error: "Access to the path '...' is denied"
- Cannot delete or overwrite files

**Causes**:
- Files locked by Visual Studio or other processes
- Insufficient permissions
- Antivirus interference

**Solutions**:

1. **Close Visual Studio**:
   - File → Exit
   - Verify no devenv.exe processes:
```cmd
tasklist | findstr devenv
```

2. **Close File Explorer** in repository directory

3. **Run as Administrator**:
   - Right-click CMD → Run as Administrator

4. **Check File Locks**:
   - Download Process Explorer: https://learn.microsoft.com/en-us/sysinternals/downloads/process-explorer
   - Find → Find Handle or DLL
   - Search for locked file

5. **Restart Computer** (last resort)

## Compilation Errors

### Type or Namespace Not Found

**Symptoms**:
- Error: "The type or namespace name 'X' could not be found"
- Missing using directives

**Causes**:
- Missing project reference
- Incorrect namespace
- Using global usings incorrectly

**Solutions**:

1. **Rebuild Solution**:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

2. **Check Project References**:
   - Open `.csproj` file
   - Verify `<ProjectReference>` elements

3. **Check Global Usings**:
   - Location: `Source/Krypton Components/Krypton.*/Global/GlobalDeclarations.cs`
   - Don't add new `using` statements in individual files

4. **Clean and Restore**:
```cmd
cd Scripts
purge.cmd
dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

### Designer Errors

**Symptoms**:
- "The designer could not be shown for this file"
- Designer crashes or shows errors

**Causes**:
- Corrupted designer cache
- Build errors in referenced projects
- WinForms designer compatibility issues

**Solutions**:

1. **Rebuild Solution**:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

2. **Clean Designer Cache**:
```cmd
rd /s /q "%LOCALAPPDATA%\Microsoft\VisualStudio\17.0_*\ComponentModelCache"
```

3. **Close and Reopen Designer**:
   - Close form
   - Rebuild project
   - Reopen form

4. **Check Build Errors**:
   - Fix any compilation errors first
   - Designer requires clean build

5. **Use Code-Behind** (if designer won't open):
   - Edit `.Designer.cs` directly
   - Or use `InitializeComponent()` manually

### C# Language Version Errors

**Symptoms**:
- "Feature 'X' is not available in C# 7.3"
- Language feature errors

**Causes**:
- Using newer C# features in .NET Framework targets
- `LangVersion` mismatch

**Solutions**:

1. **Use Conditional Compilation**:
```csharp
#if NET8_0_OR_GREATER
    // C# 12 features
    string result = $"Value: {value}";
#else
    // C# 7.3 compatible
    string result = string.Format("Value: {0}", value);
#endif
```

2. **Check LangVersion Setting**:
   - Location: `Source/Krypton Components/Directory.Build.props`
   - Should be: `<LangVersion>preview</LangVersion>`

3. **Avoid Newer Features in Shared Code**:
   - Use features compatible with C# 7.3 for .NET Framework
   - Use newer features only in .NET 8+ code paths

## NuGet Package Issues

### Package Already Exists on NuGet.org

**Symptoms**:
- Error: "409 Conflict - The package version already exists"
- Cannot publish package

**Causes**:
- Version already published
- Trying to republish same version

**Solutions**:

1. **Use Skip Duplicate**:
```cmd
dotnet nuget push *.nupkg --skip-duplicate
```

2. **Delete Package** (within 72 hours):
   - Go to https://www.nuget.org
   - My Packages → Select package → Delete

3. **Wait for Different Version**:
   - Build on a different day (version changes daily)

4. **Manually Bump Version** (not recommended):
```xml
<PropertyGroup>
    <Version>100.25.1.999</Version>
</PropertyGroup>
```

### Missing Dependencies in Package

**Symptoms**:
- Runtime error: "Could not load file or assembly 'X'"
- NuGet package doesn't include dependencies

**Causes**:
- Incorrect `PackageReference` in `.csproj`
- Dependencies not transitive

**Solutions**:

1. **Verify Package Contents**:
```cmd
# Extract package (it's a ZIP)
tar -xf Krypton.Toolkit.100.25.1.305.nupkg -C extracted
type extracted\*.nuspec
```

2. **Check Project References**:
```xml
<ItemGroup>
    <ProjectReference Include="..\Krypton.Toolkit\Krypton.Toolkit 2022.csproj" />
</ItemGroup>
```

3. **Rebuild and Repack**:
```cmd
cd Scripts
msbuild build.proj /t:Clean;Build;Pack
```

### Wrong Framework Assemblies

**Symptoms**:
- Runtime error: "Could not load file or assembly"
- Wrong .NET version loaded

**Causes**:
- Incorrect TFM in package
- `TFMs` property not set correctly

**Solutions**:

1. **Verify Package Frameworks**:
```cmd
tar -xf Krypton.Toolkit.100.25.1.305.nupkg -C extracted
dir extracted\lib
```

Should show: `net472/`, `net48/`, `net481/`, `net8.0-windows/`, etc.

2. **Rebuild with Correct TFMs**:
```cmd
cd Scripts
msbuild build.proj /t:Clean;Build;Pack /p:TFMs=all
```

3. **Check Target Framework in Consumer Project**:
```xml
<PropertyGroup>
    <TargetFramework>net8.0-windows</TargetFramework>
</PropertyGroup>
```

### Symbol Package Not Uploading

**Symptoms**:
- `.snupkg` file not appearing on NuGet.org
- Cannot debug with source link

**Causes**:
- Symbols not enabled in build
- Incorrect symbol format

**Solutions**:

1. **Verify Symbol Settings**:
   - Location: `Source/Krypton Components/Directory.Build.targets`
```xml
<IncludeSymbols>True</IncludeSymbols>
<SymbolPackageFormat>snupkg</SymbolPackageFormat>
```

2. **Rebuild with Symbols**:
```cmd
cd Scripts
build-canary.cmd Pack
```

3. **Manually Upload Symbols**:
```cmd
nuget.exe push Krypton.Toolkit.Canary.100.25.1.305-beta.nupkg -Source https://api.nuget.org/v3/index.json
# .snupkg is automatically uploaded
```

## GitHub Actions Issues

### Workflow Not Triggering

**Symptoms**:
- Push to branch doesn't trigger workflow
- Scheduled workflow doesn't run

**Causes**:
- Workflow disabled
- Branch not in trigger list
- Kill-switch enabled (for nightly)

**Solutions**:

1. **Check Workflow Status**:
   - Go to Actions tab
   - Check if workflow is enabled

2. **Verify Triggers**:
   - Open `.github/workflows/build.yml`
   - Check `on:` section for branch names

3. **Check Kill-Switch** (nightly only):
   - Settings → Secrets and variables → Actions → Variables
   - Set `NIGHTLY_DISABLED=false` or delete

4. **Manually Trigger**:
   - Actions tab → Select workflow → Run workflow

### NuGet Push Fails in CI

**Symptoms**:
- Error: "401 Unauthorized"
- Packages not published

**Causes**:
- Invalid or expired `NUGET_API_KEY`
- Secret not configured

**Solutions**:

1. **Generate New API Key**:
   - Go to https://www.nuget.org/account/apikeys
   - Create API Key with push permission
   - Expiration: At least 1 year

2. **Update Secret**:
   - Repository Settings → Secrets and variables → Actions → Secrets
   - Update `NUGET_API_KEY`

3. **Verify Secret in Workflow**:
```yaml
env:
  NUGET_API_KEY: ${{ secrets.NUGET_API_KEY }}
```

### Release Creation Fails

**Symptoms**:
- Error: "Resource not accessible by integration"
- Release not created

**Causes**:
- Insufficient `GITHUB_TOKEN` permissions
- Release already exists

**Solutions**:

1. **Check Token Permissions**:
   - Repository Settings → Actions → General
   - Workflow permissions: "Read and write permissions"

2. **Delete Existing Release**:
```cmd
gh release delete v100.25.1.305
```

3. **Recreate Release**:
   - Workflow updates existing release instead of failing

## Runtime Issues

### Could Not Load File or Assembly

**Symptoms**:
- Error: "Could not load file or assembly 'Krypton.Toolkit'"
- Assembly not found at runtime

**Causes**:
- DLL not in output directory
- Version mismatch
- Missing binding redirect (.NET Framework)

**Solutions**:

1. **Verify DLL Location**:
```cmd
dir "Bin\Debug\net48\Krypton.Toolkit.dll"
```

2. **Check Binding Redirects** (.NET Framework):
```xml
<runtime>
  <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
    <dependentAssembly>
      <assemblyIdentity name="Krypton.Toolkit" publicKeyToken="..." culture="neutral" />
      <bindingRedirect oldVersion="0.0.0.0-100.255.255.255" newVersion="100.25.1.305" />
    </dependentAssembly>
  </assemblyBinding>
</runtime>
```

3. **Clean and Rebuild**:
```cmd
cd Scripts
purge.cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

4. **Copy DLLs Manually** (if project reference fails):
```cmd
copy "Bin\Debug\net48\Krypton.*.dll" "MyApp\bin\Debug\net48\"
```

### Theme or Palette Issues

**Symptoms**:
- Controls don't apply theme
- Palette changes not visible

**Causes**:
- `KryptonManager` not set up
- Palette not assigned to controls

**Solutions**:

1. **Add KryptonManager**:
```csharp
private KryptonManager kryptonManager = new KryptonManager();

public Form1()
{
    InitializeComponent();
    kryptonManager.GlobalPaletteMode = PaletteMode.Office2010Blue;
}
```

2. **Assign Palette to Form**:
```csharp
this.Palette = new KryptonPalette();
```

3. **Check Palette Inheritance**:
   - Controls inherit from form palette
   - Verify `PaletteMode` is set

### High DPI Scaling Issues

**Symptoms**:
- Controls appear blurry
- Layout breaks on high DPI screens

**Causes**:
- DPI awareness not enabled
- WinForms auto-scaling issues

**Solutions**:

1. **Enable DPI Awareness** (app.manifest):
```xml
<dpiAware>true/PM</dpiAware>
<dpiAwareness>PerMonitorV2</dpiAwareness>
```

2. **Set Application DPI Mode**:
```csharp
// Program.cs
Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
Application.EnableVisualStyles();
Application.SetCompatibleTextRenderingDefault(false);
```

3. **Use AutoScaleMode**:
```csharp
this.AutoScaleMode = AutoScaleMode.Dpi;
```

## Performance Issues

### Slow Build Times

**Symptoms**:
- Build takes excessive time
- Build slower than expected

**Causes**:
- Antivirus scanning
- Too many parallel builds
- Large solution

**Solutions**:

1. **Exclude from Antivirus**:
   - Add repository folder to exclusions
   - Add `Bin/`, `obj/`, `.git/` to exclusions

2. **Adjust Parallel Builds**:
```cmd
# Reduce parallelism
msbuild build.proj /t:Build /m:2

# Or disable
msbuild build.proj /t:Build /m:1
```

3. **Build Specific Projects**:
```cmd
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Debug
```

4. **Use Binary Logs for Analysis**:
```cmd
msbuild build.proj /t:Build /bl:build.binlog
msbuildlogviewer build.binlog
```

### Memory Issues During Build

**Symptoms**:
- Out of memory errors
- Build process crashes

**Causes**:
- Insufficient RAM
- Memory leak in MSBuild

**Solutions**:

1. **Increase Available Memory**:
   - Close other applications
   - Close Visual Studio during command-line builds

2. **Reduce Parallel Builds**:
```cmd
msbuild build.proj /t:Build /m:1
```

3. **Build in Chunks**:
```cmd
# Build Toolkit first
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj"

# Then Ribbon
dotnet build "Source/Krypton Components/Krypton.Ribbon/Krypton.Ribbon 2022.csproj"
```

4. **Restart Computer** to free memory

## Getting Help

### Check Documentation

1. Read relevant documentation:
   - [Build System Overview](BuildSystemOverview.md)
   - [MSBuild Project Files](MSBuildProjectFiles.md)
   - [Build Scripts](BuildScripts.md)

### Check Logs

1. **Build Logs**:
   - Location: `Logs/*.log`
   - Binary logs: `Logs/*.binlog`

2. **View Binary Logs**:
```cmd
dotnet tool install --global MSBuildStructuredLogViewer
msbuildlogviewer Logs/stable-build.binlog
```

### Search Issues

1. **GitHub Issues**:
   - https://github.com/Krypton-Suite/Standard-Toolkit/issues
   - Search for similar problems

2. **Stack Overflow**:
   - Tag: `krypton-toolkit`
   - Search for error messages

### Report Issues

If problem persists:

1. **Create GitHub Issue**:
   - Go to: https://github.com/Krypton-Suite/Standard-Toolkit/issues/new
   - Use issue template
   - Include:
     - Symptoms
     - Steps to reproduce
     - Environment (OS, VS version, .NET version)
     - Build logs (if applicable)
     - Screenshots/GIFs

2. **Provide Minimal Repro**:
   - Create minimal test case
   - Share in test harness format

## Related Documentation

- [Build System Overview](BuildSystemOverview.md) - System architecture
- [Build Scripts](BuildScripts.md) - Build commands
- [GitHub Actions Workflows](GitHubActionsWorkflows.md) - CI/CD
- [NuGet Packaging](NuGetPackaging.md) - Package troubleshooting

