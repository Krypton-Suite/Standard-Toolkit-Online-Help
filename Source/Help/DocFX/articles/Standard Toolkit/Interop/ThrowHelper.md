# ThrowHelper

## Overview

`ThrowHelper` (`Krypton.Interop`) is a shared internal static class that moves exception construction onto a cold path. Call sites stay smaller and more likely to be inlined; methods marked with `[DoesNotReturn]` only throw.

This addresses [#4142](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4142). Helpers are visible to sibling toolkit assemblies via `InternalsVisibleTo` and are **not** part of the public NuGet API.

## API

| Method | Use when |
| --- | --- |
| `ThrowIfNull(argument, paramName?)` | Null check with optional `[CallerArgumentExpression]` |
| `ThrowArgumentNullException(...)` / `<T>` | Parameter null (statement or `??` / ternary / switch arm) |
| `ThrowArgumentException(...)` / `<T>` | Invalid argument |
| `ThrowArgumentOutOfRangeException(...)` / `<T>` | Out-of-range (including palette switch discard arms) |
| `ThrowInvalidOperationException(...)` / `<T>` | Invalid state |
| `ThrowNullReferenceException(...)` / `<T>` | **Legacy only** — preserve existing NRE + `SharedStaticFunctions` messages |
| `ThrowNotSupportedException(...)` / `<T>` | Unsupported operation |
| `ThrowNotImplementedException(...)` / `<T>` | Stub / not-yet-implemented members |
| `ThrowObjectDisposedException(...)` / `<T>` | Use after dispose |
| `ThrowInvalidCastException(...)` / `<T>` | Invalid cast |
| `ThrowWin32Exception(...)` / `<T>` | Win32 / P/Invoke failure |

Prefer **ArgumentNullException** for new parameter validation. Do not mass-convert NRE call sites to ArgumentNullException.

## Usage

```csharp
ThrowHelper.ThrowIfNull(ribbon);

if (ribbon is null)
{
    ThrowHelper.ThrowArgumentNullException(nameof(ribbon));
}

_ribbon = ribbon ?? ThrowHelper.ThrowArgumentNullException<KryptonRibbon>(nameof(ribbon));

_ => ThrowHelper.ThrowArgumentOutOfRangeException<PaletteGraphicsHint>(nameof(style))
```

### Flow analysis note

Roslyn does not always honour `[DoesNotReturn]` across assemblies for definite assignment (e.g. `is not Type x` pattern variables). When that happens, follow the helper with an unreachable exit the compiler accepts, for example `throw null!;` or `return ThrowHelper.ThrowXxx<T>(...)`.

### PlatformInvoke note

`PlatformInvoke.cs` lives in the `Krypton.Toolkit` namespace inside the Interop assembly. Prefer the qualified form `Krypton.Interop.ThrowHelper` there to avoid name collisions with other `ThrowHelper` types (for example CsWin32-generated helpers).
## Roll-out status

Statement and expression throws for ArgumentNull / Argument / OutOfRange / InvalidOperation / NullReference / NotSupported / NotImplemented / ObjectDisposed / InvalidCast / Win32 are converted across Toolkit / Ribbon / Navigator / Workspace / Docking / Utilities / Interop / TestForm. Intentional leftovers include `DebugTools.NotImplemented(...)` and any exception types without a helper.

Mechanical converters (re-run carefully; review ternary / expression-bodied constructors and generic type inference):

```powershell
powershell -NoProfile -File .\Scripts\UnitTest\Convert-ThrowHelpers.ps1
powershell -NoProfile -File .\Scripts\UnitTest\Convert-ThrowHelpers-Pass2.ps1
```

Pass 1 covers statement forms; Pass 2 covers `??` / `=>` expression forms (large palette switches need a long method lookback). Prefer fixing remaining sites by hand over blind re-runs.

## Polyfills (`net472`)

Under `#if NETFRAMEWORK` in `Krypton.Interop/Utilities/`:

- `DoesNotReturnAttribute` / `DoesNotReturnIfAttribute`
- `CallerArgumentExpressionAttribute`
