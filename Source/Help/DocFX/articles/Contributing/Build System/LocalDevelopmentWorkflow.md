# Local Development Workflow

## Overview

This guide provides recommended workflows for local development of the Krypton Toolkit. It covers daily development tasks, testing changes, debugging, and preparing releases.

## Development Environment Setup

### Initial Setup

1. **Install Prerequisites**:
   - Visual Studio 2022 (Community, Professional, or Enterprise)
   - .NET 8.0 SDK (minimum)
   - .NET 9.0 SDK (recommended)
   - .NET 10.0 SDK (optional)
   - Git for Windows

2. **Clone Repository**:
```cmd
git clone https://github.com/Krypton-Suite/Standard-Toolkit.git
cd Standard-Toolkit
```

3. **Enable Windows Long Paths**:
```cmd
# Run as Administrator
reg add HKLM\SYSTEM\CurrentControlSet\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f
```

4. **Restore NuGet Packages**:
```cmd
dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"
```

### Opening the Solution

**Option 1: Visual Studio 2022**
```cmd
start "Source\Krypton Components\Krypton Toolkit Suite 2022 - VS2022.sln"
```

**Option 2: Command Line**
```cmd
cd "Source\Krypton Components"
devenv "Krypton Toolkit Suite 2022 - VS2022.sln"
```

## Daily Development Workflow

### Typical Development Cycle

1. **Pull Latest Changes**:
```cmd
git pull origin master
```

2. **Create Feature Branch** (optional):
```cmd
git checkout -b feature/my-new-feature
```

3. **Build Debug Configuration**:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

Or in Visual Studio:
- Press `Ctrl+Shift+B` or
- Menu: Build → Build Solution

4. **Make Code Changes**:
- Edit source files in `Source/Krypton Components/`
- Follow coding guidelines in `Source/.editorconfig`

5. **Test Changes**:
- Run TestForm: `dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug`
- Or press `F5` in Visual Studio with TestForm as startup project

6. **Rebuild After Changes**:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

7. **Commit Changes**:
```cmd
git add .
git commit -m "Fix autosizing issue (#2433)"
```

## Building Specific Projects

### Build Single Component

```cmd
# Toolkit only
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Debug

# Ribbon only
dotnet build "Source/Krypton Components/Krypton.Ribbon/Krypton.Ribbon 2022.csproj" -c Debug
```

### Build All Components

```cmd
cd Scripts
msbuild debug.proj /t:Build
```

Or:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

### Clean Build

```cmd
cd Scripts
msbuild debug.proj /t:Clean;Build
```

Or:
```cmd
dotnet clean "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug
```

## Testing Changes

### Using TestForm

**TestForm** is a WinForms sample application for validating changes.

**Location**: `Source/Krypton Components/TestForm/`

**Running TestForm**:

Option 1: Command Line
```cmd
dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug
```

Option 2: Visual Studio
1. Right-click TestForm project
2. Set as StartUp Project
3. Press `F5`

**Adding Test Scenarios**:

1. Open `TestForm/Form1.cs` (or appropriate form)
2. Add controls to test your changes
3. Run and verify behavior

Example:
```csharp
// Add to Form1.cs
private void AddMyTestControl()
{
    var button = new KryptonButton
    {
        Text = "Test Button",
        Location = new Point(10, 10)
    };
    this.Controls.Add(button);
}
```

### Using Test Harnesses

**Location**: `Source/TestHarnesses/`

**Available Harnesses**:
- `DockingConfigTest/` - Docking configuration tests
- `FormBorderStyleNoneTest/` - Form border testing
- `KryptonFormDimensionTest/` - Form dimension tests
- `MultiSelectionTest/` - Multi-selection scenarios
- `ShowTabsTest/` - Tab control tests
- `ThemeSwapRepro/` - Theme switching tests

**Running a Harness**:
```cmd
cd "Source/TestHarnesses/ThemeSwapRepro"
dotnet run -c Debug
```

**Creating a New Harness**:

1. Create new WinForms project in `Source/TestHarnesses/`
2. Add reference to Krypton components:
```xml
<ItemGroup>
    <ProjectReference Include="..\..\Krypton Components\Krypton.Toolkit\Krypton.Toolkit 2022.csproj" />
</ItemGroup>
```
3. Implement minimal repro of issue
4. Document reproduction steps

## Debugging

### Debug in Visual Studio

1. **Set Breakpoints**:
   - Click in left margin of code editor
   - Or press `F9` on desired line

2. **Start Debugging**:
   - Press `F5`
   - Or Menu: Debug → Start Debugging

3. **Debug Controls**:
   - `F5` - Continue
   - `F10` - Step Over
   - `F11` - Step Into
   - `Shift+F11` - Step Out
   - `Shift+F5` - Stop Debugging

### Debug Specific Framework

```cmd
# Debug with .NET 8
dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug -f net8.0-windows

# Debug with .NET Framework 4.8
dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug -f net48
```

### Attach to Running Process

1. Run TestForm or harness
2. Visual Studio: Debug → Attach to Process
3. Select TestForm.exe or harness
4. Click Attach

### Debug Build Output

**Debug binaries** are in:
```
Bin/Debug/<tfm>/
├── net48/
│   ├── Krypton.Toolkit.dll
│   ├── Krypton.Toolkit.pdb
│   └── ...
├── net8.0-windows/
│   └── ...
```

## Working with Multiple Target Frameworks

### Build for Specific TFM

```cmd
# .NET Framework 4.8 only
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Debug -f net48

# .NET 8 only
dotnet build "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -c Debug -f net8.0-windows
```

### Conditional Compilation

Use preprocessor directives for framework-specific code:

```csharp
#if NET8_0_OR_GREATER
    // .NET 8+ code
    using System.Runtime.CompilerServices;
    [MethodImpl(MethodImplOptions.AggressiveOptimization)]
#elif NETFRAMEWORK
    // .NET Framework code
#endif
```

### Configuration-Specific Code

```csharp
#if DEBUG
    Console.WriteLine("Debug mode");
#endif

#if NIGHTLY
    // Nightly build code
#endif

#if CANARY
    // Canary build code
#endif
```

## Code Style and Guidelines

### EditorConfig

The repository uses `.editorconfig` for consistent formatting:
- Location: `Source/.editorconfig`
- Enforces: Indentation, line endings, naming conventions

### Coding Standards

1. **Indentation**: 4 spaces
2. **Line Endings**: CRLF (Windows)
3. **Encoding**: UTF-8 with BOM
4. **No Variable Aliasing**: Check for existing variables before adding new ones
5. **Use Global Usings**: Defined in `GlobalDeclarations.cs`
6. **WinForms Designer**: Keep object declarations at file bottom

### Example:
```csharp
// Good
private void HandleButtonClick(object sender, EventArgs e)
{
    if (sender is KryptonButton button)
    {
        button.Enabled = false;
    }
}

// Bad
private void HandleButtonClick(object sender,EventArgs e){
  var btn = sender as KryptonButton;
  if(btn != null)
    btn.Enabled=false;
}
```

## Making a Pull Request

### Pre-PR Checklist

1. **Build Successfully**:
```cmd
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Release
```

2. **Test Changes**:
   - Run TestForm
   - Verify in relevant test harnesses

3. **Check Linting** (if available):
```cmd
dotnet format "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" --verify-no-changes
```

4. **Commit with Good Message**:
```cmd
git commit -m "Fix autosizing in KryptonDataGridView (#2433)"
```

### Creating PR

1. **Push to Fork**:
```cmd
git push origin feature/my-new-feature
```

2. **Open PR on GitHub**:
   - Go to https://github.com/Krypton-Suite/Standard-Toolkit
   - Click "New Pull Request"
   - Select your branch
   - Fill in description with:
     - What changed
     - Why it changed
     - How to test
     - Screenshots/GIFs for UI changes

3. **Address Review Comments**:
```cmd
# Make changes
git add .
git commit -m "Address review comments"
git push origin feature/my-new-feature
```

## Local Package Testing

### Create Local Packages

```cmd
cd Scripts
msbuild debug.proj /t:Build
msbuild debug.proj /t:Pack
```

**Note**: Debug packages go to `Bin/Packages/Debug/`

### Install Local Packages

1. **Create Local NuGet Source**:
```cmd
mkdir C:\LocalNuGet
nuget.exe sources add -Name local -Source C:\LocalNuGet
```

2. **Copy Packages**:
```cmd
copy Bin\Packages\Debug\*.nupkg C:\LocalNuGet\
```

3. **Install in Test Project**:
```cmd
cd MyTestProject
dotnet add package Krypton.Toolkit --source local
```

### Test in Another Solution

Create a simple test project:
```cmd
dotnet new winforms -n KryptonTest -f net8.0-windows
cd KryptonTest
dotnet add package Krypton.Toolkit --source C:\LocalNuGet
```

Add test code:
```csharp
using Krypton.Toolkit;

public class Form1 : KryptonForm
{
    public Form1()
    {
        var button = new KryptonButton { Text = "Click Me" };
        Controls.Add(button);
    }
}
```

## Performance Profiling

### Using Visual Studio Profiler

1. Open solution in Visual Studio 2022
2. Debug → Performance Profiler
3. Select profiling tools:
   - CPU Usage
   - Memory Usage
   - .NET Object Allocation

4. Start profiling
5. Perform actions in TestForm
6. Stop profiling
7. Analyze results

### Benchmarking

For micro-benchmarks, use BenchmarkDotNet:

```csharp
using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;

[MemoryDiagnoser]
public class ButtonBenchmarks
{
    [Benchmark]
    public void CreateButton()
    {
        var button = new KryptonButton();
    }
}

// Run
BenchmarkRunner.Run<ButtonBenchmarks>();
```

## Troubleshooting Development Issues

### Build Errors

**"SDK not found"**:
- Install required .NET SDK
- Verify with `dotnet --list-sdks`

**"Project file could not be loaded"**:
- Check `.csproj` XML syntax
- Restore NuGet packages

**"Type or namespace not found"**:
- Clean and rebuild
- Check project references

### Runtime Errors

**"Could not load file or assembly"**:
- Verify DLL in `Bin/Debug/<tfm>/`
- Check binding redirects (for .NET Framework)

**Designer Errors**:
- Rebuild solution
- Close and reopen designer
- Clean `obj/` directories

### Git Issues

**Merge Conflicts**:
```cmd
git status
# Resolve conflicts in files
git add .
git commit -m "Resolve merge conflicts"
```

**Undo Local Changes**:
```cmd
git checkout -- path/to/file.cs
```

**Reset to Remote**:
```cmd
git fetch origin
git reset --hard origin/master
```

## Quick Reference

### Common Commands

```cmd
# Build Debug
dotnet build "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln" -c Debug

# Run TestForm
dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug

# Clean
dotnet clean "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"

# Restore
dotnet restore "Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.sln"

# Purge
cd Scripts
purge.cmd
```

### Keyboard Shortcuts (Visual Studio)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Shift+B` | Build Solution |
| `F5` | Start Debugging |
| `Ctrl+F5` | Start Without Debugging |
| `F9` | Toggle Breakpoint |
| `F10` | Step Over |
| `F11` | Step Into |
| `Ctrl+K, Ctrl+D` | Format Document |
| `Ctrl+.` | Quick Actions |

## Related Documentation

- [Build Scripts](03-Build-Scripts.md) - Build commands
- [MSBuild Project Files](02-MSBuild-Project-Files.md) - Build system
- [ModernBuild Tool](08-ModernBuild-Tool.md) - Interactive builds
- [Troubleshooting](10-Troubleshooting.md) - Common issues
- [Build System Overview](01-Build-System-Overview.md) - System architecture

