# Build Scripts

## Overview

The Krypton Toolkit provides Windows Command Prompt (`.cmd`) batch scripts for convenient building, packaging, and maintenance. These scripts are located in the `Scripts/` directory and provide user-friendly interfaces to the MSBuild project files.

## Core Build Scripts

### build-stable.cmd

**Purpose**: Builds stable/release packages interactively

**Usage**:
```cmd
cd Scripts
build-stable.cmd [target]
```

**Parameters**:
- `target` (optional) - MSBuild target to execute (default: `Build`)

**Examples**:
```cmd
build-stable.cmd           # Build only
build-stable.cmd Pack      # Pack only
build-stable.cmd Clean     # Clean only
```

**Features**:
- Auto-detects Visual Studio 2022 installation
- Supports Preview, Enterprise, Professional, Community, and BuildTools editions
- Displays start and end timestamps with timezone
- Creates detailed build logs in `../Logs/stable-build-log.log`
- Creates binary log in `../Logs/stable-build-log.binlog`
- Shows build summary with timestamps
- Interactive menu option to return to main menu

**Visual Studio Detection Order**:
1. Visual Studio 2022 Preview
2. Visual Studio 2022 Enterprise
3. Visual Studio 2022 Professional
4. Visual Studio 2022 Community
5. Visual Studio 2022 BuildTools

**Output**:
- Text log: `Logs/stable-build-log.log`
- Binary log: `Logs/stable-build-log.binlog`
- Console summary with timing

### build-canary.cmd

**Purpose**: Builds canary (beta) pre-release packages

**Usage**:
```cmd
cd Scripts
build-canary.cmd [target]
```

**Parameters**:
- `target` (optional) - MSBuild target (default: `Build`)

**Features**:
- Same Visual Studio detection as build-stable.cmd
- Builds using `canary.proj`
- Outputs to `../Logs/canary-build-log.log` and `.binlog`
- Packages go to `Bin/Packages/Canary/`
- Interactive menu integration

**Examples**:
```cmd
build-canary.cmd Build     # Build canary
build-canary.cmd Pack      # Pack canary packages
```

### build-nightly.cmd

**Purpose**: Builds nightly (alpha) bleeding-edge packages

**Usage**:
```cmd
cd Scripts
build-nightly.cmd [target]
```

**Parameters**:
- `target` (optional) - MSBuild target (default: `Build`)

**Features**:
- Uses `nightly.proj`
- Outputs to `../Logs/nightly-build-log.log` and `.binlog`
- Packages go to `Bin/Packages/Nightly/`
- Interactive menu integration

**Examples**:
```cmd
build-nightly.cmd Build    # Build nightly
build-nightly.cmd Rebuild  # Clean and rebuild
build-nightly.cmd Pack     # Pack nightly packages
```

**Notes**:
- Includes commented options for `-graphBuild:True` (parallel project graph builds)

## Utility Scripts

### buildsolution.cmd

**Purpose**: Interactive solution builder with VS 2019/2022 support

**Usage**:
```cmd
cd Scripts
buildsolution.cmd [target]
```

**Features**:
- Prompts for Visual Studio version (2019 or 2022)
- Builds using `build.proj`
- Interactive NuGet package creation prompt
- Displays completion timestamps

**Workflow**:
1. Select Visual Studio version
2. Build completes
3. Prompt: Create NuGet packages? (y/n)
4. If yes, prompt for VS version for packing
5. Complete

**Parameters**:
- `target` (optional) - MSBuild target (default: `Build`)

**Examples**:
```cmd
buildsolution.cmd          # Interactive build
buildsolution.cmd Rebuild  # Interactive rebuild
```

### purge.cmd

**Purpose**: Cleans build artifacts and intermediate files

**Usage**:
```cmd
cd Scripts
purge.cmd
```

**Interactive Prompts**:
```
You are about to delete the Bin folder; do you want to continue? (Y/N)
```

**Deletes**:
- `Bin/` - All build outputs
- `Source/Krypton Components/Krypton.Docking/obj/`
- `Source/Krypton Components/Krypton.Navigator/obj/`
- `Source/Krypton Components/Krypton.Ribbon/obj/`
- `Source/Krypton Components/Krypton.Toolkit/obj/`
- `Source/Krypton Components/Krypton.Workspace/obj/`
- `Logs/` (if exists)

**Warning**: This operation is destructive and cannot be undone!

**Use Cases**:
- Before major version changes
- When switching between configurations
- To resolve build cache issues
- To free disk space

### publish.cmd

**Purpose**: Simplified NuGet package publishing

**Usage**:
```cmd
cd Scripts
publish.cmd
```

**Workflow**:
1. Executes `build.cmd Pack`
2. Executes `build.cmd Push`

**Prerequisites**:
- NuGet API key must be configured
- Packages must exist in `Bin/Packages/Release/`

**Configuration**:
Set API key once:
```cmd
nuget.exe setapikey <YOUR_API_KEY> -Source https://api.nuget.org/v3/index.json
```

### main-menu.cmd

**Purpose**: Returns to the main build menu system

**Usage**:
```cmd
cd Scripts
main-menu.cmd
```

**Features**:
- Changes directory to parent (`cd ..`)
- Executes `run.cmd` (main menu launcher)

**Note**: This assumes a `run.cmd` exists in the root directory.

## Script Patterns

### Visual Studio Detection Pattern

All build scripts use this pattern:
```batch
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Preview\MSBuild\Current\Bin" goto vs17prev
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin" goto vs17ent
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin" goto vs17pro
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin" goto vs17com
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin" goto vs17build

echo "Unable to detect suitable environment. Check if VS 2022 is installed."
pause
goto exitbatch

:vs17prev
set msbuildpath=%ProgramFiles%\Microsoft Visual Studio\2022\Preview\MSBuild\Current\Bin
goto build
```

### Logging Pattern

Scripts enable detailed logging:
```batch
"%msbuildpath%\msbuild.exe" /t:%targets% build.proj ^
    /fl ^
    /flp:logfile=../Logs/stable-build-log.log ^
    /bl:../Logs/stable-build-log.binlog ^
    /clp:Summary;ShowTimestamp ^
    /v:quiet
```

Parameters:
- `/fl` - Enable file logging
- `/flp:logfile=<path>` - Specify log file location
- `/bl:<path>` - Binary log file
- `/clp:Summary;ShowTimestamp` - Console logger parameters
- `/v:quiet` - Verbosity level

### Timezone Detection

Scripts capture timezone information:
```batch
for /f "tokens=* usebackq" %%A in (`tzutil /g`) do (
    set "zone=%%A"
)
```

### Target Parameter Pattern

Scripts accept optional target parameter:
```batch
set targets=Build
if not "%~1" == "" set targets=%~1
"%msbuildpath%\msbuild.exe" /t:%targets% build.proj ...
```

Usage:
```cmd
build-stable.cmd Pack      # Sets targets=Pack
build-stable.cmd           # Uses default targets=Build
```

## Advanced Usage

### Custom Logging

Add custom MSBuild parameters:
```cmd
build-stable.cmd Build /v:detailed /flp:logfile=custom.log
```

### Parallel Builds

Enable multi-core builds:
```cmd
build-stable.cmd Build /m:4
```

### Binary Log Analysis

View binary logs with MSBuild Structured Log Viewer:
```cmd
# Install viewer
dotnet tool install --global MSBuildStructuredLogViewer

# Open log
msbuildlogviewer Logs/stable-build-log.binlog
```

### Automated Builds (CI/CD)

For non-interactive automation:
```cmd
@echo off
cd Scripts

REM Clean build
purge.cmd < nul

REM Build stable
echo Y | purge.cmd
build-stable.cmd Build

REM Check exit code
if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

echo Build succeeded!
```

## Environment Requirements

### Required Environment Variables

None explicitly required, but these are respected:
- `ProgramFiles` - Visual Studio installation detection
- `PATH` - For finding `nuget.exe` during publish

### Optional Environment Variables

- `NUGET_API_KEY` - For automated package publishing
- `MSBUILDPATH` - Override MSBuild location

### Setting Custom MSBuild Path

```cmd
set MSBUILDPATH=C:\CustomPath\MSBuild\Current\Bin
build-stable.cmd Build
```

## Troubleshooting

### "Unable to detect suitable environment"

**Cause**: Visual Studio 2022 not found

**Solutions**:
1. Install Visual Studio 2022
2. Verify installation path:
   ```cmd
   dir "%ProgramFiles%\Microsoft Visual Studio\2022\"
   ```
3. Manual MSBuild invocation:
   ```cmd
   "C:\Path\To\MSBuild.exe" /t:Build build.proj
   ```

### Build Hangs or Stalls

**Solutions**:
1. Kill MSBuild processes:
   ```cmd
   taskkill /F /IM MSBuild.exe
   ```
2. Clean and retry:
   ```cmd
   purge.cmd
   build-stable.cmd Build
   ```

### Incorrect Build Configuration

**Cause**: Cached build state

**Solutions**:
```cmd
purge.cmd
build-stable.cmd Build
```

### Permission Denied Errors

**Cause**: Files locked by IDE or antivirus

**Solutions**:
1. Close Visual Studio
2. Disable antivirus temporarily
3. Run as Administrator

## Best Practices

### 1. Always Check Logs
After any build failure:
```cmd
notepad Logs\stable-build-log.log
```

### 2. Clean Between Configurations
```cmd
purge.cmd
build-stable.cmd Build
```

### 3. Verify Before Publishing
```cmd
build-stable.cmd Pack
# Manually inspect Bin/Packages/Release/
build-stable.cmd Push
```

### 4. Use Binary Logs for Complex Issues
```cmd
build-stable.cmd Build
# If issues occur:
msbuildlogviewer Logs/stable-build-log.binlog
```

### 5. Script Automation
Create custom automation scripts:
```batch
@echo off
call build-stable.cmd Clean
call build-stable.cmd Build
call build-stable.cmd Pack
echo All operations completed!
```

## Related Documentation

- [MSBuild Project Files](02-MSBuild-Project-Files.md) - Understanding .proj files
- [Local Development Workflow](09-Local-Development-Workflow.md) - Developer workflows
- [Troubleshooting](10-Troubleshooting.md) - Common issues
- [ModernBuild Tool](08-ModernBuild-Tool.md) - Alternative TUI tool

