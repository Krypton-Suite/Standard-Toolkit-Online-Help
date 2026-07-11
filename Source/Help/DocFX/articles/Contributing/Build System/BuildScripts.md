# Build Scripts

## Overview

The Krypton Toolkit provides Windows Command Prompt (`.cmd`) batch scripts for convenient building, packaging, and maintenance. Scripts are organized under `Scripts/VS2022/`, `Scripts/Current/`, and `Scripts/Build/`. The root `run.cmd` launches an interactive menu and invokes these scripts. Each script set uses a `build.proj` in its directory.

Orchestrated MSBuild invocations import root `Directory.Build.props`, so binaries and `.nupkg` files go to `Bin/` and `Bin/Packages/` by default. To match CI, you can pass `/p:UseArtifactsOutput=true`, which redirects outputs to `artifacts/bin/` and `artifacts/packages/`. Script `.proj` Clean/Push/archive targets follow `$(KryptonBuildOutputRoot)` and `$(KryptonPackageOutputRoot)` automatically.

## MSBuild and Visual Studio discovery

All orchestration `.cmd` scripts call the shared helper `Scripts/Common/find-msbuild.cmd` to locate `MSBuild.exe`. Discovery runs in this order:

1. **`MSBUILDPATH` or `MSBUILD_PATH`** — must point at the `MSBuild\Current\Bin` directory when set.
2. **`vswhere.exe`** — `%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe` resolves the real install path (including custom drives and non-default locations).
3. **Fallback** — standard folders under `%ProgramFiles%` or `%ProgramFiles(x86)%`.

Each script folder passes a **profile** to the helper:

| Script folder | Profile | Visual Studio generation |
|---------------|---------|--------------------------|
| `Scripts/Build/` | `2019` | Visual Studio 2019 |
| `Scripts/VS2022/` | `2022` | Visual Studio 2022 |
| `Scripts/Current/` | `18` | Visual Studio 2026 |

On success, the helper prints the resolved product, MSBuild path, and MSBuild tool version before the build starts:

```text
Using build tools:
  Visual Studio: Visual Studio Enterprise 2026
  MSBuild path: A:\Program Files\Microsoft Visual Studio\18\Enterprise\MSBuild\Current\Bin
  MSBuild version: 18.7.8.30822
```

Override example:

```cmd
set MSBUILDPATH=D:\DevTools\VS2022\MSBuild\Current\Bin
Scripts\VS2022\build-stable.cmd
```

## Core Build Scripts

### build-stable.cmd

**Purpose**: Builds stable/release packages interactively

**Usage**:

```cmd
cd Scripts\VS2022
build-stable.cmd [target]
```

Or via the interactive menu: run `run.cmd` from the repository root, select the Visual Studio target, then choose the build option.

**Parameters**:

- `target` (optional) - MSBuild target to execute (default: `Build`)

**Examples**:

```cmd
build-stable.cmd           # Build only
build-stable.cmd Pack      # Pack only
build-stable.cmd Clean     # Clean only
```

**Features**:

- Locates MSBuild via `Scripts\Common\find-msbuild.cmd` (profile `2022` in this folder)
- Reports Visual Studio product, MSBuild path, and MSBuild version at startup
- Displays start and end timestamps with timezone
- Creates detailed build logs in `../Logs/stable-build-log.log`
- Creates binary log in `../Logs/stable-build-log.binlog`
- Shows build summary with timestamps
- Interactive menu option to return to main menu

**Output**:

- Text log: `Logs/stable-build-log.log`
- Binary log: `Logs/stable-build-log.binlog`
- Console summary with timing

### build-canary.cmd

**Purpose**: Builds canary (beta) pre-release packages

**Usage**:

```cmd
cd Scripts\VS2022
build-canary.cmd [target]
```

**Parameters**:

- `target` (optional) - MSBuild target (default: `Build`)

**Features**:

- Locates MSBuild via `find-msbuild.cmd` (same profile as other scripts in the folder)
- Builds using `canary.proj`
- Outputs to `../Logs/canary-build-log.log` and `.binlog`
- Packages go to `Bin/Packages/Canary/` unless the build used `UseArtifactsOutput=true` (`artifacts/packages/Canary/`)
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
cd Scripts\VS2022
build-nightly.cmd [target]
```

**Parameters**:

- `target` (optional) - MSBuild target (default: `Build`)

**Features**:

- Uses `nightly.proj`
- Outputs to `../Logs/nightly-build-log.log` and `.binlog`
- Packages go to `Bin/Packages/Nightly/` by default, or `artifacts/packages/Nightly/` with `UseArtifactsOutput=true`
- Interactive menu integration

**Examples**:

```cmd
build-nightly.cmd Build    # Build nightly
build-nightly.cmd Rebuild  # Clean and rebuild
build-nightly.cmd Pack     # Pack nightly packages
```

**Notes**:

- Invokes MSBuild with **`/m`** (all logical CPUs). `nightly.proj` sets **`BuildInParallel="true"`** on the Krypton.* orchestration target.
- Optional commented switch in the script: `-graphBuild:True` (MSBuild graph scheduling; distinct from `/m`).

## Utility Scripts

### buildsolution.cmd

**Purpose**: Interactive solution builder (profile depends on script folder)

**Usage**:

```cmd
cd Scripts\VS2022
buildsolution.cmd [target]
```

Equivalent scripts exist under `Scripts\Build\` (prompts: 2019 or 2026) and `Scripts\Current\` (uses Visual Studio 2026 only).

**Features**:

- Locates MSBuild via `find-msbuild.cmd` for the chosen generation
- `Scripts\VS2022\`: prompts for Visual Studio 2019 or 2022
- `Scripts\Build\`: prompts for Visual Studio 2019 or 2026
- `Scripts\Current\`: builds with Visual Studio 2026
- Builds using `build.proj`
- Interactive NuGet package creation prompt (`Scripts\VS2022\` and `Scripts\Build\` only)
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

```text
You are about to delete the Bin folder; do you want to continue? (Y/N)
```

**Deletes**:

- `Bin/` - Default build outputs (does not remove `artifacts/`; delete that folder manually if used)
- `Source/Krypton Components/Krypton.Docking/obj/`
- `Source/Krypton Components/Krypton.Navigator/obj/`
- `Source/Krypton Components/Krypton.Ribbon/obj/`
- `Source/Krypton Components/Krypton.Toolkit/obj/`
- `Source/Krypton Components/Krypton.Workspace/obj/`
- `Logs/` (if exists)

**Note**: Does not delete `Krypton.Toolkit.Utilities` or `Krypton.Standard.Toolkit` obj folders. Run from `Scripts/VS2022`, `Scripts/Current`, or `Scripts/Build`.

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

1. Executes `build-stable.cmd Pack`
2. Executes `build-stable.cmd Push`

**Prerequisites**:

- NuGet API key must be configured
- Packages must exist under `Bin/Packages/Release/` (default) or `artifacts/packages/Release/` if you packed with `UseArtifactsOutput=true`

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
- Executes `run.cmd` (main menu launcher in repository root)

**Note**: Assumes `run.cmd` exists in the repository root. The main-menu script is in `Scripts/`.

## Script Patterns

### MSBuild discovery pattern

Build scripts delegate to the shared helper:

```batch
call "%SCRIPT_DIR%..\Common\find-msbuild.cmd" 2022
if errorlevel 1 (
echo "Unable to detect suitable environment. Check if VS 2022 is installed."
echo.
pause
goto exitbatch
)
goto build
```

Replace `2022` with `2019` in `Scripts\Build\` or `18` in `Scripts\Current\`. See [MSBuild and Visual Studio discovery](#msbuild-and-visual-studio-discovery).

### Logging Pattern

Scripts enable detailed logging and parallel builds:

```batch
REM /m: multi-processor MSBuild (all logical CPUs).
"%msbuildpath%\msbuild.exe" /m /t:%targets% build.proj ^
    /fl ^
    /flp:logfile=../Logs/stable-build-log.log ^
    /bl:../Logs/stable-build-log.binlog ^
    /clp:Summary;ShowTimestamp ^
    /v:quiet
```

Parameters:

- `/m` - Use all logical processors (see [Parallel builds](#parallel-builds))
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
"%msbuildpath%\msbuild.exe" /m /t:%targets% build.proj ...
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

### Parallel builds

All orchestration `.cmd` files (`build-stable.cmd`, `build-canary.cmd`, `build-nightly.cmd`, `build-lts.cmd`, `build-installer.cmd`, `debug.cmd`, `buildsolution.cmd`, and related rebuild/custom scripts) pass **`/m`** to MSBuild so compilation uses all logical CPUs.

`nightly.proj` also sets **`BuildInParallel="true"`** on its Build target so sibling `Krypton.*` projects can build in parallel where project references allow (Toolkit first, then Ribbon/Navigator, and so on).

To **limit** parallelism when diagnosing file-lock or memory issues:

```cmd
msbuild /m:1 /t:Build build.proj
```

Or pass a cap, for example `/m:4`. Extra arguments after the script target name are **not** forwarded by the `.cmd` wrappers; invoke `msbuild` directly or edit the script line.

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

None explicitly required. These are used when present:

- `ProgramFiles` / `ProgramFiles(x86)` — fallback MSBuild discovery
- `PATH` — for finding `nuget.exe` during publish

### Optional Environment Variables

- `NUGET_API_KEY` — for automated package publishing
- `MSBUILDPATH` or `MSBUILD_PATH` — override MSBuild location (`MSBuild\Current\Bin` directory)

### Setting Custom MSBuild Path

```cmd
set MSBUILDPATH=D:\DevTools\VS2022\MSBuild\Current\Bin
cd Scripts\VS2022
build-stable.cmd Build
```

## Troubleshooting

### "Unable to detect suitable environment"

**Cause**: `find-msbuild.cmd` could not resolve MSBuild for the script folder's profile (wrong VS generation, missing MSBuild workload, or no installation).

**Solutions**:

1. Install the Visual Studio generation that matches the script folder (2019 / 2022 / 2026).
2. List MSBuild-capable installations with `vswhere`:

   ```cmd
   "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -all -products * -requires Microsoft.Component.MSBuild -property displayName,installationPath
   ```

3. Set an explicit path before running the script:

   ```cmd
   set MSBUILDPATH=D:\Path\To\MSBuild\Current\Bin
   build-stable.cmd Build
   ```

4. Use `dotnet build` for a quick solution build without full orchestration:

   ```cmd
   dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
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
REM Manually inspect Bin/Packages/Release/ or artifacts/packages/Release/
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

- [MSBuild Project Files](MSBuildProjectFiles.md) - Understanding .proj files
- [Troubleshooting](Troubleshooting.md) - Common issues
- [ModernBuild Tool](ModernBuildTool.md) - Alternative TUI tool
