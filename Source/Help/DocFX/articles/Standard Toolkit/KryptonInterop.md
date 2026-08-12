# Interoperability

The Krypton Standard Toolkit uses Win32 P/Invoke through the internal **`Krypton.Interop`** assembly. Call sites in Toolkit, Ribbon, Navigator, Workspace, Docking, and Utilities continue to use the `PI` and `Libraries` types in the `Krypton.Toolkit` namespace.

## Topics

- [LibraryImport dual-path interop](Interop/LibraryImportDualPathInterop.md) — `[LibraryImport]` on modern TFMs with `[DllImport]` fallback for .NET Framework
- [ThrowHelper](Interop/ThrowHelper.md)

## Related documentation

- [Cross-project Source Linking](../Contributing/CrossProjectSourceLinking.md) — build and packaging notes for `Krypton.Interop.dll`
