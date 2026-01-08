# ModernBuild Tool

## Overview

ModernBuild is an interactive Terminal UI (TUI) application that provides a modern, user-friendly interface for building, packing, and publishing the Krypton Toolkit. It offers real-time build output, comprehensive configuration options, and simplified NuGet operations.

**Location**: `Scripts/ModernBuild/`

**Technology**: .NET with Terminal.Gui

**Target Frameworks**: net472, net8.0-windows, net9.0-windows, net10.0-windows

## Features

- Interactive keyboard-driven UI
- Real-time build output streaming
- Auto-detection of MSBuild and NuGet
- Support for all build configurations (Stable, Canary, Nightly, Debug)
- Integrated NuGet package publishing
- Build log management
- Clean operations
- Create ZIP archives
- Test/preview NuGet push commands

## Installation and Running

### Running with dotnet run (Recommended)

```cmd
cd Scripts/ModernBuild
dotnet run --project ModernBuild.csproj
```

**Advantages**:
- No build step required
- Always uses latest code
- Works across all platforms

### Building and Running Executable

```cmd
cd Scripts/ModernBuild
dotnet build ModernBuild.csproj -c Release

# Run built executable
bin\Release\net10.0-windows\ModernBuild.exe
```

### Running from Repository Root

```cmd
dotnet run --project Scripts/ModernBuild/ModernBuild.csproj
```

**Important**: Always run from repository root for correct path detection.

## User Interface

### UI Layout

```
┌─────────────────────────────────────────────────────────────────┐
│ Tasks                  │ Live Output                            │
│ ┌───────────────────┐  │ ┌───────────────────────────────────┐ │
│ │ F1: Channel       │  │ │ MSBuild output appears here...    │ │
│ │ F2: Action        │  │ │ Real-time streaming...            │ │
│ │ F3: Config        │  │ │                                   │ │
│ │ F4: Switch Page   │  │ │ Press Enter on a line to copy it  │ │
│ │ F5: Run/Stop      │  │ └───────────────────────────────────┘ │
│ │ ESC/F10: Exit     │  │                                       │
│ └───────────────────┘  │                                       │
├─────────────────────────────────────────────────────────────────┤
│ Build Settings                                                  │
│ Project: Scripts/nightly.proj                                   │
│ MSBuild: C:\Program Files\...\MSBuild.exe                       │
│ Log: Logs/nightly-build.binlog                                  │
├─────────────────────────────────────────────────────────────────┤
│ Summary (paged)                                                 │
│ ┌───────────────────────────────────────────────────────────┐   │
│ │ Build completed successfully                              │   │
│ │ Time: 00:05:23                                            │   │
│ └───────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### UI Components

| Component | Description |
|-----------|-------------|
| **Tasks** | Hotkeys and current selections |
| **Live Output** | Streaming MSBuild/NuGet output |
| **Build Settings** | Current project, MSBuild path, log location |
| **Summary** | Recent log tail for quick diagnostics |
| **Status Bar** | Run status, elapsed time, error/warning counts |

## Global Controls

| Key | Action |
|-----|--------|
| **F4** | Switch between Ops and NuGet pages |
| **F5** | Start/Stop current action |
| **ESC** or **F10** | Exit application |
| **Auto-Scroll** | Toggle following live output |

## Ops Page (Build Operations)

### Purpose
Build, rebuild, pack, and clean operations

### Controls

| Key | Control | Options |
|-----|---------|---------|
| **F1** | Channel | Nightly → Canary → Stable |
| **F2** | Action | Build → Rebuild → Pack → BuildPack → Debug |
| **F3** | Config | Release ↔ Debug |
| **F5** | Run | Execute selected action |
| **F6** | Tail | Buffer size: 200 → 500 → 1000 lines |
| **F7** | Clean | Delete Bin/, obj/, Logs/ |
| **F8** | Clear | Clear live output |
| **F9** | PackMode | Pack → PackLite → PackAll (Stable only) |

### Channel Selection (F1)

**Nightly**:
- Project: `Scripts/nightly.proj`
- Config: Defaults to Debug
- Packages: `.Nightly` with `-alpha` suffix

**Canary**:
- Project: `Scripts/canary.proj`
- Config: Canary or Release
- Packages: `.Canary` with `-beta` suffix

**Stable**:
- Project: `Scripts/build.proj`
- Config: Release
- Packages: Standard and `.Lite` variants

### Action Selection (F2)

**Build**:
- Runs `MSBuild /t:Rebuild`
- Compiles all projects
- Generates binaries

**Rebuild**:
- Same as Build
- Ensures clean compilation

**Pack**:
- Runs `MSBuild /t:Pack`
- Creates NuGet packages
- Requires prior build

**BuildPack**:
- Runs `MSBuild /t:Rebuild;Pack`
- Builds then packs in one step

**Debug**:
- Runs `MSBuild /t:Clean;Rebuild`
- Switches to Nightly channel
- Uses Debug configuration

### Configuration Selection (F3)

**Release**:
- Optimized builds
- No debug symbols (except for Canary/Nightly)
- Recommended for production

**Debug**:
- Debug symbols included
- No optimizations
- Used for development

**Note**: Nightly channel may auto-switch to Debug

### Pack Mode (F9) - Stable Only

Available when Channel is Stable and Action is Pack or BuildPack:

**Pack**:
- Runs both PackLite and PackAll
- Generates standard and lite packages

**PackLite**:
- Runs `MSBuild /t:PackLite /p:TFMs=lite`
- Generates lite packages only

**PackAll**:
- Runs `MSBuild /t:PackAll /p:TFMs=all`
- Generates standard packages only

### Clean Operation (F7)

Deletes:
- `Bin/` directory
- `obj/` directories in all Krypton projects
- `Logs/` directory

**Warning**: This is destructive and cannot be undone!

### Clear Output (F8)

- Clears live output display
- Resets horizontal scroll
- Does not delete log files

## NuGet Page (Package Publishing)

### Purpose
Package creation, validation, and publishing to NuGet.org or GitHub Packages

### Controls

| Key | Control | Options |
|-----|---------|---------|
| **F1** | Channel | Nightly → Canary → Stable |
| **F2** | Action | Rebuild+Pack → Push → Pack+Push → Rebuild+Pack+Push → Update NuGet |
| **F3** | Config | Release ↔ Debug (keep Release for publishing) |
| **F5** | Run | Execute selected action(s) |
| **F6** | Symbols | Toggle `.snupkg` inclusion |
| **F7** | SkipDup | Toggle `--skip-duplicate` flag |
| **F8** | Source | Default → NuGet.org → GitHub → Custom |
| **Create ZIP** | Create `Bin/<yyyyMMdd>_NuGet_Packages.zip` |
| **TEST** | Preview push commands without executing |

### Action Selection (F2)

**Rebuild+Pack**:
- Rebuilds projects
- Packs NuGet packages
- Does not publish

**Push**:
- Publishes existing packages only
- Requires packages in `Bin/Packages/<Configuration>/`

**Pack+Push**:
- Packs packages
- Publishes to selected source

**Rebuild+Pack+Push**:
- Complete workflow
- Rebuilds, packs, and publishes

**Update NuGet**:
- Runs `nuget.exe update -Self -NonInteractive`
- Updates NuGet CLI tool

### Symbol Packages (F6)

**Enabled**:
- Includes `.snupkg` files in push operations
- Required for debugging support

**Disabled**:
- Only pushes `.nupkg` files

### Skip Duplicate (F7)

**Enabled**:
- Adds `--skip-duplicate` flag
- Silently skips packages that already exist on server

**Disabled**:
- Fails if package already exists

### Source Selection (F8)

**Default**:
- Uses default NuGet configuration
- Typically NuGet.org

**NuGet.org**:
- Explicit NuGet.org publishing
- Requires API key configuration

**GitHub**:
- GitHub Packages
- Requires `github` source configured

**Custom**:
- Custom NuGet source
- Not configurable via UI (requires manual setup)

### NuGet.org Configuration

#### Set API Key
```cmd
nuget.exe setapikey <YOUR_API_KEY> -Source https://api.nuget.org/v3/index.json
```

#### Verify Configuration
```cmd
nuget.exe sources list
```

### GitHub Packages Configuration

#### Add Source
```cmd
nuget.exe sources add -Name github ^
  -Source https://nuget.pkg.github.com/Krypton-Suite/index.json ^
  -Username YOUR_USERNAME ^
  -Password YOUR_GITHUB_TOKEN
```

#### Generate Token
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate token with `write:packages` scope
3. Use token as password

### Create ZIP

Creates archive of all NuGet packages:
- Filename: `Bin/<yyyyMMdd>_NuGet_Packages.zip`
- Includes all `.nupkg` and optionally `.snupkg` files
- Useful for offline distribution

### TEST Mode

Previews `nuget.exe push` commands without executing:
```
nuget.exe push Bin\Packages\Release\Krypton.Toolkit.100.25.1.305.nupkg -Source https://api.nuget.org/v3/index.json
nuget.exe push Bin\Packages\Release\Krypton.Ribbon.100.25.1.305.nupkg -Source https://api.nuget.org/v3/index.json
...
```

**Use Cases**:
- Verify package names
- Check version numbers
- Validate configuration before actual push

## Build Logs

### Log Locations

| Channel | Text Log | Binary Log |
|---------|----------|------------|
| **Nightly** | `Logs/nightly-build-summary.log` | `Logs/nightly-build.binlog` |
| **Canary** | `Logs/canary-build-summary.log` | `Logs/canary-build.binlog` |
| **Stable** | `Logs/stable-build-summary.log` | `Logs/stable-build.binlog` |

### Log Types

**Text Log** (`.log`):
- Human-readable
- Build summary
- Error and warning messages

**Binary Log** (`.binlog`):
- Complete MSBuild log
- Viewable with MSBuild Structured Log Viewer
- Best for detailed analysis

### Viewing Binary Logs

```cmd
# Install viewer
dotnet tool install --global MSBuildStructuredLogViewer

# Open log
msbuildlogviewer Logs/nightly-build.binlog
```

## Status Information

### Status Bar

Displays:
- **Status**: RUNNING / DONE / FAILED
- **Elapsed Time**: `00:05:23`
- **Errors**: `Errors: 0`
- **Warnings**: `Warnings: 3`

### Summary Panel Navigation

| Key | Action |
|-----|--------|
| **PageUp** | Previous page |
| **PageDown** | Next page |
| **Home** | First page |
| **End** | Last page |

## Prerequisites

### Required

1. **Visual Studio 2022**
   - ModernBuild auto-detects MSBuild via `vswhere.exe`

2. **NuGet CLI**
   - Download: https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
   - Place in PATH or `Scripts/` directory

### Optional

- **.NET 10 SDK**: For building ModernBuild itself

## Project File Detection

ModernBuild looks for project files in these locations:

**Nightly**:
1. `Scripts/nightly.proj`
2. `Scripts/Project-Files/nightly.proj`

**Canary**:
1. `Scripts/canary.proj`
2. `Scripts/Project-Files/canary.proj`

**Stable**:
1. `Scripts/build.proj`
2. `Scripts/Project-Files/build.proj`

**Installer** (not exposed in UI):
1. `Scripts/installer.proj`
2. `Scripts/Project-Files/installer.proj`

## Troubleshooting

### "Could not find MSBuild.exe"

**Cause**: Visual Studio 2022 not installed or not detected

**Solutions**:
1. Install Visual Studio 2022
2. Verify installation:
```cmd
dir "%ProgramFiles%\Microsoft Visual Studio\2022\"
```
3. ModernBuild checks these locations:
   - Preview
   - Enterprise
   - Professional
   - Community
   - BuildTools

### "nuget.exe not found"

**Cause**: NuGet CLI not in PATH

**Solutions**:
1. Download NuGet CLI:
```cmd
curl -o Scripts\nuget.exe https://dist.nuget.org/win-x86-commandline/latest/nuget.exe
```
2. Add to PATH

### "Project file not found: ..."

**Cause**: `.proj` files missing or wrong location

**Solution**: Verify files exist:
```cmd
dir Scripts\*.proj
```

### Build Succeeds with No Observable Work

**Cause**: Configuration/TFM mismatch

**Solution**:
1. Check ModernBuild output for skipped targets
2. Verify `TFMs` property in build settings
3. Clean and rebuild

### No Packages Found to Push

**Cause**: Packages not created or wrong location

**Solutions**:
1. Run Rebuild+Pack before Push
2. Verify packages exist:
```cmd
dir Bin\Packages\Release\*.nupkg
```

### Custom NuGet Source Fails

**Cause**: Custom source not implemented in UI

**Workaround**: Use command line for custom sources

## Advanced Features

### Process Management

ModernBuild kills the entire MSBuild process tree when you stop a running action:
- Terminates MSBuild.exe
- Terminates child processes
- Prevents zombie processes

### Real-time Output

- Streams MSBuild output line-by-line
- Auto-scrolls when enabled
- Supports copy-to-clipboard (press Enter on line)

### Build Statistics

Tracks:
- Elapsed time
- Error count
- Warning count
- Build status

## Best Practices

### 1. Run from Repository Root

```cmd
cd Z:\Development\Krypton\Standard-Toolkit
dotnet run --project Scripts/ModernBuild/ModernBuild.csproj
```

### 2. Clean Before Major Builds

Use F7 (Clean) before switching configurations or channels.

### 3. Test Before Publishing

Use TEST button on NuGet page to preview push commands.

### 4. Monitor Logs

Check binary logs for detailed troubleshooting:
```cmd
msbuildlogviewer Logs/nightly-build.binlog
```

### 5. Use Skip Duplicate for Safety

Enable SkipDup (F7) when testing publishing to avoid errors.

### 6. Verify Packages Locally

Before publishing:
1. Check `Bin/Packages/<Configuration>/`
2. Verify version numbers
3. Inspect with NuGet Package Explorer

## Comparison with Command-Line Scripts

| Feature | ModernBuild | Build Scripts |
|---------|-------------|---------------|
| **UI** | Interactive TUI | Command-line |
| **Real-time Output** | Yes | Yes (console) |
| **Build Logs** | Binary + text | Text only |
| **NuGet Publishing** | Integrated | Separate scripts |
| **Configuration Switching** | F-key toggle | Command parameter |
| **Package Preview** | TEST mode | Manual inspection |
| **Clean Operations** | F7 key | purge.cmd |
| **Learning Curve** | Low | Medium |

## Related Documentation

- [Build Scripts](BuildScripts.md) - Command-line alternatives
- [NuGet Packaging](NuGetPackaging.md) - Package details
- [MSBuild Project Files](MSBuildProjectFiles.md) - Build targets
- [Troubleshooting](Troubleshooting.md) - Common issues

