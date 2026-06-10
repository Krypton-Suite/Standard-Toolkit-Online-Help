# WebView2 SDK Setup for KryptonWebView2

## Overview

`KryptonWebView2` is implemented in **`Krypton.Toolkit.Utilities`**. The project compiles the full control when bundled WebView2 assemblies exist under:

`Source/Krypton Components/Krypton.Toolkit.Utilities/Lib/WebView2/`

That defines `WEBVIEW2_AVAILABLE`. Without those DLLs, a minimal stub `Control` is built instead.

**Quick start (recommended):** From the repository root:

```cmd
Scripts\WebVew2\Populate-BundledWebView2.cmd
```

Or run `run.cmd` → **WebView2 SDK Tools** (if your menu includes the populate/update options).

**Runtime:** End users still need the [WebView2 Runtime](https://developer.microsoft.com/en-us/microsoft-edge/webview2/) installed (Evergreen or Fixed Version distribution).

## Setup options

### Option 1: Populate bundled DLLs (recommended)

`Populate-BundledWebView2.cmd` downloads the latest stable `Microsoft.Web.WebView2` package, copies the required assemblies into `Lib/WebView2`, and removes the temporary PackageReference so the project uses only bundled references.

```cmd
Scripts\WebVew2\Populate-BundledWebView2.cmd
```

Required files in `Lib/WebView2`:

```text
Lib/WebView2/
├── Microsoft.Web.WebView2.Core.dll
├── Microsoft.Web.WebView2.WinForms.dll
└── WebView2Loader.dll
```

You may commit these DLLs so CI and other developers do not need to run the script (see `.gitignore` un-ignore rule for this folder).

### Option 2: Manual copy

1. Download the [WebView2 SDK](https://developer.microsoft.com/en-us/microsoft-edge/webview2/) or install `Microsoft.Web.WebView2` via NuGet temporarily.
2. Copy the three DLLs listed above into  
   `Source/Krypton Components/Krypton.Toolkit.Utilities/Lib/WebView2/`
3. Rebuild `Krypton.Toolkit.Utilities`.

### Option 3: Temporary NuGet (development only)

```cmd
dotnet add "Source/Krypton Components/Krypton.Toolkit.Utilities/Krypton.Toolkit.Utilities.csproj" package Microsoft.Web.WebView2
dotnet restore "Source/Krypton Components/Krypton.Toolkit.Utilities/Krypton.Toolkit.Utilities.csproj"
```

Copy the DLLs from `%USERPROFILE%\.nuget\packages\microsoft.web.webview2\<version>\` into `Lib/WebView2`, then remove the package reference so the project matches the bundled layout:

```cmd
dotnet remove "Source/Krypton Components/Krypton.Toolkit.Utilities/Krypton.Toolkit.Utilities.csproj" package Microsoft.Web.WebView2
```

### Option 4: Legacy `WebView2SDK` folder (repository root)

Older scripts under `Scripts/WebVew2/` (`Setup-WebView2SDK.cmd`, `Update-WebView2SDK.cmd`) populate a **`WebView2SDK`** folder at the repository root. **The project does not reference that folder** — it uses `Lib/WebView2` inside `Krypton.Toolkit.Utilities`.

If you used the legacy scripts, either:

- Run `Populate-BundledWebView2.cmd` instead, or  
- Manually copy the three DLLs from `WebView2SDK\` into `Source/Krypton Components/Krypton.Toolkit.Utilities/Lib/WebView2/`

Some CI workflows may still populate `WebView2SDK`; ensure `Lib/WebView2` is populated before building `Krypton.Toolkit.Utilities`.

## File structure after setup

```text
Standard-Toolkit/
├── Source/
│   └── Krypton Components/
│       └── Krypton.Toolkit.Utilities/
│           ├── Lib/
│           │   └── WebView2/                    ← Build-time references (required)
│           │       ├── Microsoft.Web.WebView2.Core.dll
│           │       ├── Microsoft.Web.WebView2.WinForms.dll
│           │       └── WebView2Loader.dll
│           └── Components/
│               └── KryptonWebView2/
│                   └── Controls Toolkit/
│                       └── KryptonWebView2.cs
├── Scripts/
│   └── WebVew2/
│       ├── Populate-BundledWebView2.cmd         ← Recommended
│       ├── Setup-WebView2SDK.cmd                ← Legacy (WebView2SDK at root)
│       ├── Update-WebView2SDK.cmd
│       ├── Get-LatestWebView2Version.ps1
│       └── Update-WebView2ProjectVersion.ps1
└── run.cmd
```

## Verification

1. **Build Utilities**

   ```cmd
   dotnet build "Source/Krypton Components/Krypton.Toolkit.Utilities/Krypton.Toolkit.Utilities.csproj" -c Debug
   ```

2. **Confirm**
   - No errors for `Microsoft.Web.WebView2` types
   - `WEBVIEW2_AVAILABLE` defined (DLLs present in `Lib/WebView2`)
   - `KryptonWebView2` in the toolbox when `TestForm` / designer loads `Krypton.Toolkit.Utilities`

3. **Run TestForm** (optional)

   ```cmd
   dotnet run --project "Source/Krypton Components/TestForm/TestForm.csproj" -c Debug
   ```

   Open the `KryptonWebView2` test scenario and confirm themed background colors follow the active palette.

## Troubleshooting

### "WebView2 types not found" or stub control only

- Verify all three DLLs exist under  
  `Source/Krypton Components/Krypton.Toolkit.Utilities/Lib/WebView2/`
- Run `Scripts\WebVew2\Populate-BundledWebView2.cmd`
- Rebuild `Krypton.Toolkit.Utilities` (not only a dependent project)

### Legacy `WebView2SDK` at repository root

- That folder alone does **not** enable `WEBVIEW2_AVAILABLE`
- Copy assemblies into `Lib/WebView2` or run `Populate-BundledWebView2.cmd`

### Assembly loading errors

- Use AnyCPU-compatible builds unless you intentionally target x64
- Replace corrupted DLLs from a fresh NuGet package or SDK download

### Designer / toolbox issues

- Build `Krypton.Toolkit.Utilities` successfully first
- Reset the Visual Studio toolbox; restart the designer
- Ensure `TestForm` references a configuration where `Lib/WebView2` DLLs exist

### GitHub Actions / CI

- Ensure the workflow copies or restores DLLs into **`Lib/WebView2`**, not only `WebView2SDK`
- Restore needs network access to download the WebView2 package when DLLs are not committed

## Runtime requirements

| Requirement | Notes |
|-------------|--------|
| Windows 10 1803+ | WebView2 host |
| WebView2 Runtime | [Download](https://developer.microsoft.com/en-us/microsoft-edge/webview2/) — Evergreen or Fixed Version |
| Application TFM | Same as `Krypton.Toolkit.Utilities` (e.g. `net472`, `net48`, `net8.0-windows`, …) |

Bundled SDK DLLs are for **compilation**. The **runtime** is a separate install on end-user machines (unless you ship Fixed Version).

## Related documentation

- [KryptonWebView2 documentation index](KryptonWebView2.md)
- [Developer guide — theming](KryptonWebView2DeveloperGuide.md#theming-integration)
- [API reference — State properties](KryptonWebView2APIReference.md)
- [Microsoft WebView2 documentation](https://learn.microsoft.com/en-us/microsoft-edge/webview2/)

## Notes

- Prefer committing `Lib/WebView2/*.dll` for repeatable CI, or run `Populate-BundledWebView2.cmd` in the pipeline before build.
- Project references use `HintPath` under `Lib/WebView2`; assemblies are not pulled from a permanent NuGet PackageReference in the shipped layout.
- After setup, configure appearance via **Visuals → State###** on `KryptonWebView2`, not `DefaultBackgroundColor` in the designer.
