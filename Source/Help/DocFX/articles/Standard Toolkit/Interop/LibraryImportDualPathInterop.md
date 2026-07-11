# LibraryImport Dual-Path Interop

## Overview

Issue [#3874](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3874) migrates eligible Win32 P/Invoke declarations from runtime `[DllImport]` marshalling to source-generated `[LibraryImport]` on modern target frameworks, while retaining `[DllImport]` for .NET Framework (`net472` / `net48` / `net481`).

This builds on [#3855](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3855) / [#3860](https://github.com/Krypton-Suite/Standard-Toolkit/pull/3860), which moved shared interop into the internal `Krypton.Interop` assembly. Call sites continue to use `PI` and `Libraries` in the `Krypton.Toolkit` namespace.

**Scope:** performance and trim/AOT friendliness on `net8.0-windows` and newer TFMs. **Not** a replacement of all P/Invoke, and **not** a drop of .NET Framework support.

## Architecture

```text
Callers (Toolkit / Ribbon / Navigator / Utilities / TestForm / ...)
        |
        v
   Krypton.Interop  (namespace: Krypton.Toolkit — PI / Libraries)
        |
        +-- #if NET8_0_OR_GREATER
        |       [LibraryImport] static partial ...  (+ source generator output)
        +-- #else
                [DllImport] static extern ...       (runtime marshalling)
```

Key types and files:

| Item | Location |
|------|----------|
| `PI` (platform invoke surface) | `Source/Krypton Components/Krypton.Interop/General/PlatformInvoke.cs` |
| `Libraries` (DLL name constants) | Same file (top of `PlatformInvoke.cs`) |
| Interop project | `Source/Krypton Components/Krypton.Interop/Krypton.Interop.csproj` |
| Bulk conversion script | `Scripts/Tools/Convert-DllImportToLibraryImport.ps1` |

Design rules:

- Declare **new shared Win32 APIs** on `PI` (or a `partial` sibling file in `Krypton.Interop`).
- **Call sites** should use `PI` instead of local `[DllImport]` / `[LibraryImport]` blocks.
- **Facades** such as `ImageNativeMethods` and `PlatformEvents` may remain for historical call shapes, but should forward to `PI`.
- `AllowUnsafeBlocks` is enabled on `Krypton.Interop` (and `TestForm` where demo code uses `LibraryImport`) because the source generator and some signatures may require unsafe code.

## .NET Framework and .NET 7+ compatibility

[`LibraryImportAttribute`](https://learn.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.libraryimportattribute?view=net-10.0) is a **.NET 7+** feature. The toolkit still ships **net472**, **net48**, and **net481**. Dual-path gating is how both worlds coexist:

| Build TFM | Branch compiled | Consumer requirement |
|-----------|-----------------|----------------------|
| **net472 / net48 / net481** | `#else` → `[DllImport]` | .NET Framework only |
| **net8.0-windows+** | `#if NET8_0_OR_GREATER` → `[LibraryImport]` | Modern .NET only |

We gate on **`NET8_0_OR_GREATER`** because the repo’s modern TFMs start at **net8.0-windows**.

**Do not** use unconditional `[LibraryImport]` — that breaks net472 builds immediately.

## Dual-path convention

### Minimal example

```csharp
#if NET8_0_OR_GREATER
[LibraryImport(Libraries.User32)]
[DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
internal static partial uint GetDpiForWindow(IntPtr hWnd);
#else

[DllImport(Libraries.User32)]
[DefaultDllImportSearchPaths(DllImportSearchPath.System32)]
internal static extern uint GetDpiForWindow(IntPtr hWnd);
#endif
```

### Attribute mapping

| `DllImport` | `LibraryImport` |
|-------------|-----------------|
| `extern` method | `static partial` method on a `partial` type |
| `CharSet.Unicode` / `Auto` (Windows) | `StringMarshalling.Utf16` (prefer explicit `*W` entry points) |
| `SetLastError = true` | `SetLastError = true` |
| Implicit `bool` return/parameter | Explicit `[MarshalAs(UnmanagedType.Bool)]` / `[return: MarshalAs(UnmanagedType.Bool)]` |
| `[In]` / `[Out]` on by-ref | Use `in` / `ref` / `out`; drop `[In]`/`[Out]` on the LibraryImport branch |
| `BOOL` enum return | Keep `BOOL`; do not change to `bool` on the LibraryImport branch |

## What stays on DllImport today

The conversion script and initial #3874 pass left these categories on classic `[DllImport]` (often on **all** TFMs). See **Migrating hard signatures** below for how Microsoft and this repo can eventually convert many of them.

| Category | Examples in `PI` | Why blocked initially |
|----------|------------------|------------------------|
| `StringBuilder` out-buffers | `GetWindowText`, `LoadString` (helpers), `GetMenuString` (helpers) | `GetClassName` / `GetMenuString` / `LoadString` use `[Out] char[]` on net8+; `GetWindowText` still uses `WM_GETTEXT` helper |
| `HandleRef` | `SetMenu`, GDI+ `HandleRef` paths | Generator does not support `HandleRef` |
| Arrays | `ExtractIconEx` (`IntPtr[]`) | Array marshalling not generator-friendly |
| Managed **classes** | `MONITORINFO`, `PRINTDLG_*` | Reference-type layout + field initializers |
| Complex structs | `PAINTSTRUCT` (`byte[]` field), `CHOOSEFONT`, `DTTOPTS` | Non-blittable embedded arrays / layouts |
| COM | `IShellLink`, etc. | COM interop separate from P/Invoke generator |
| `BestFitMapping` | Legacy ANSI helpers | Not supported on `LibraryImport` |

`KryptonPrintDialog` keeps local `PrintDlg_*` imports because `PRINTDLG_32` / `PRINTDLG_64` are managed classes with WinForms-style layout.

## Migrating hard signatures (Microsoft patterns)

Microsoft’s own codebases ([PowerToys](https://github.com/microsoft/PowerToys) 0.97+, [PowerShell](https://github.com/PowerShell/PowerShell) 7.x, [WinForms](https://github.com/dotnet/winforms)) do **not** convert everything at once. They combine:

1. **`LibraryImport` for simple blittable APIs** (primitives, `IntPtr`, blittable structs, `string` in/out where supported).
2. **`DllImport` where conversion cost exceeds benefit** (complex marshalling, COM, `LPStruct` classes).
3. **Signature redesign** so more APIs become generator-compatible.
4. **CsWin32** for new APIs and increasingly for existing surfaces (WinForms #7880+).

Reference implementations worth reading:

- PowerShell `FileSystemProvider.cs` — mixed `LibraryImport` + remaining `DllImport` for `FindFirstStreamW` / `LPStruct` data ([v7.5.0](https://github.com/PowerShell/PowerShell/blob/v7.5.0/src/System.Management.Automation/namespaces/FileSystemProvider.cs)).
- PowerShell `Clipboard.cs` — full `LibraryImport` for clipboard/kernel32 where signatures are simple ([v7.5.0](https://github.com/PowerShell/PowerShell/blob/v7.5.0/src/Microsoft.PowerShell.Commands.Management/commands/management/Clipboard.cs)).
- PowerToys CmdPal — `NativeMethods.json` with `"allowMarshaling": false` + CsWin32; keeps `DllImport` for `StringBuilder` cases like `SystemParametersInfo` ([v0.97.2](https://github.com/microsoft/PowerToys/blob/v0.97.2/src/modules/cmdpal/Microsoft.CmdPal.UI/Controls/ShortcutControl/NativeMethods.cs)).
- [.NET interop best practices](https://learn.microsoft.com/en-us/dotnet/standard/native-interop/best-practices) and [P/Invoke source generation](https://learn.microsoft.com/en-us/dotnet/standard/native-interop/pinvoke-source-generation).

### 1. `StringBuilder` → `[Out] char[]` or avoid the buffer import

The runtime team’s guidance for out-string buffers ([dotnet/docs#35862](https://github.com/dotnet/docs/issues/35862)):

```csharp
#if NET8_0_OR_GREATER
[LibraryImport(Libraries.User32, EntryPoint = "GetClassNameW", SetLastError = true,
    StringMarshalling = StringMarshalling.Utf16)]
internal static partial int GetClassName(IntPtr hWnd, [Out] char[] lpClassName, int nMaxCount);
#else
[DllImport(Libraries.User32, EntryPoint = "GetClassNameW", CharSet = CharSet.Unicode, SetLastError = true)]
internal static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
#endif

internal static string GetClassNameString(IntPtr hWnd)
{
#if NET8_0_OR_GREATER
    char[] buffer = new char[256];
    int length = GetClassName(hWnd, buffer, buffer.Length);
    return length > 0 ? new string(buffer, 0, length) : string.Empty;
#else
    var sb = new StringBuilder(256);
    return GetClassName(hWnd, sb, sb.Capacity) > 0 ? sb.ToString() : string.Empty;
#endif
}
```

Prefer `new string(buffer, 0, length)` over `TrimEnd('\0')` when the API returns the written length.

**Already in this repo:** `GetWindowText(IntPtr)` does not call `GetWindowText` P/Invoke at all — it uses `WM_GETTEXTLENGTH` / `WM_GETTEXT` via `SendMessage`, which avoids the buffer import entirely (`PlatformInvoke.cs`).

### 2. Fixed embedded strings → blittable struct with `fixed char[]`

**Already in this repo** for stock icons:

```csharp
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
internal unsafe struct SHSTOCKICONINFO
{
    public uint cbSize;
    public IntPtr hIcon;
    public int iSysImageIndex;
    public int iIcon;
    public fixed char szPath[260];
}
```

`SHGetStockIconInfo` is dual-path `LibraryImport` / `DllImport` with `ref SHSTOCKICONINFO`. This matches the Win32 layout and avoids `StringBuilder` in the struct.

### 3. `IntPtr` buffer + caller-side marshalling

PowerToys uses `SHGetPathFromIDListW(IntPtr pidl, IntPtr pszPath)` and manages the buffer in managed code rather than `StringBuilder` in the import signature. Same idea as `Marshal` / `Span` over allocated or stack memory for modern TFMs.

### 4. `HandleRef` → `IntPtr` + `GC.KeepAlive`

**Already in this repo:**

```csharp
internal static BOOL EndDialog(HandleRef hDlg, IntPtr nResult)
{
    BOOL result = EndDialog(hDlg.Handle, nResult);
    GC.KeepAlive(hDlg.Wrapper);
    return result;
}
```

The low-level import uses `IntPtr`; the `HandleRef` overload is a managed wrapper only. Prefer this pattern over `HandleRef` in new `LibraryImport` declarations.

### 5. Managed class → blittable `struct`

`MONITORINFO` in `PI` is today a **class** with field initializers (`cbSize = SizeOf(...)`), which forces `[In, Out] MONITORINFO` and runtime marshalling:

```csharp
// Current — DllImport only
private static extern bool _GetMonitorInfo(IntPtr hMonitor, [In, Out] MONITORINFO lpmi);
```

**WinForms / CsWin32 approach:** nested blittable structs (`MONITORINFOEXW` with `fixed char szDevice[...]` or CsWin32-generated layouts), `cbSize` set by caller before the call, `ref` or `unsafe` pointer to struct. After redesign:

```csharp
#if NET8_0_OR_GREATER
[LibraryImport(Libraries.User32, EntryPoint = "GetMonitorInfoW", SetLastError = true)]
[return: MarshalAs(UnmanagedType.Bool)]
internal static partial bool GetMonitorInfo(IntPtr hMonitor, ref MONITORINFO lpmi);
#endif
```

`PAINTSTRUCT` needs the same treatment: replace `byte[] rgbReserved` with `fixed byte rgbReserved[32]` in an `unsafe struct` (or match CsWin32’s generated layout).

### 6. Out arrays → `fixed` buffer, `IntPtr` + size, or split API

`ExtractIconEx` with `IntPtr[]` stays on `DllImport` today. Options used elsewhere:

- Fixed-size stack buffer (`IntPtr` × N) in an `unsafe` local block for small N.
- CsWin32-generated signature with pointer + count.
- Keep `DllImport` if call frequency is low (PowerToys leaves several shell APIs on `DllImport`).

### 7. `PRINTDLG` / common dialogs

WinForms-style **managed classes** (`PRINTDLG_32` / `PRINTDLG_64` with reference fields) are not blittable. Microsoft’s long-term direction is CsWin32 **struct** layouts that mirror the C header exactly (value type, no field initializers, explicit `cbSize`/`lStructSize` before call). That is a **large, behavior-sensitive refactor** — keep `DllImport` in `KryptonPrintDialog` until a dedicated layout audit.

### 8. CsWin32 for new and migrated APIs

PowerToys CmdPal `NativeMethods.json`:

```json
{
  "$schema": "https://aka.ms/CsWin32.schema.json",
  "allowMarshaling": false
}
```

`allowMarshaling: false` forces blittable, generator-friendly types — good for `LibraryImport` and NativeAOT. Policy for Krypton:

- Do **not** bulk-regenerate all of `PI`.
- Add `NativeMethods.txt` entries for **new** APIs; optionally migrate one subsystem at a time (as PowerShell does file-by-file).
- Wrap or re-export from `PI` so Framework call sites stay stable.

### 9. When to stop migrating

PowerShell and PowerToys **leave `DllImport` in place** when:

- The signature uses `MarshalAs(LPStruct)` on a non-blittable class (e.g. PowerShell `AlternateStreamNativeData` in `FileSystemProvider.cs`).
- COM vtables or `StringBuilder` remain simpler on classic marshalling.
- SYSLIB1054 analyzer says the signature is not suitable for `LibraryImport`.

Use the analyzer as the authority; do not force `LibraryImport` for marginal cases.

### Suggested migration order (future work)

| Priority | Target | Technique | Status |
|----------|--------|-----------|--------|
| 1 | `GetClassName`, `GetMenuString`, `LoadString` | `[Out] char[]` + string helper | Done — `GetClassNameString`, `GetMenuStringString`, `LoadString(..., uint)` |
| 2 | `MONITORINFO`, `PAINTSTRUCT` | class → blittable struct; audit call sites | Pending |
| 3 | `HandleRef` GDI paths | `IntPtr` imports + `GC.KeepAlive` wrappers |
| 4 | `ExtractIconEx` | CsWin32 or unsafe fixed buffer |
| 5 | `PRINTDLG_*` | CsWin32 struct redesign + dedicated test pass |

## Consolidation status

Routed to `PI` (no local import at call site):

- `ImageNativeMethods`, `StockIconHelper`, `LocalWindowsHook` / `LocalCbtHook`
- `KryptonAlternateCommandLinkButton`, `PlatformEvents`, TestForm `Program`
- Floating toolbar / code-editor Win32 helpers

Still local by design:

- `KryptonPrintDialog` — `PrintDlg_32` / `PrintDlg_64`
- Remaining hard signatures inside `PI` (see tables above)

## Conversion helper

`Scripts/Tools/Convert-DllImportToLibraryImport.ps1` converts eligible declarations only. After running:

1. Ensure containing types are `partial`.
2. Build `net472` and `net8.0-windows`.
3. Fix `SYSLIB1051` / `SYSLIB1052` / `CS0227` manually.

## Validation

```powershell
dotnet build ".\Source\Krypton Components\Krypton.Interop\Krypton.Interop.csproj" -c Debug -f net472
dotnet build ".\Source\Krypton Components\Krypton.Interop\Krypton.Interop.csproj" -c Debug -f net8.0-windows
dotnet build ".\Source\Krypton Components\Krypton.Toolkit\Krypton.Toolkit.csproj" -c Debug -f net472
dotnet build ".\Source\Krypton Components\Krypton.Toolkit\Krypton.Toolkit.csproj" -c Debug -f net8.0-windows
```

Manual TestForm smoke: DPI / AppUserModelID, stock icons, hooks/CBT, floating toolbars, extended message box positioning, print dialog.

Related: PR [#3878](https://github.com/Krypton-Suite/Standard-Toolkit/pull/3878), issue [#3874](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3874).
