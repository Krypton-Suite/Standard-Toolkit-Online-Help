# Krypton.Resources

## Overview

`Krypton.Resources` is the shared image and string bank for theme chrome, toolbars, glyphs, and dialog art. It is an internal assembly (`IsPackable=false`). NuGet packages for `Krypton.Toolkit`, the sibling modules, and `Krypton.Standard.Toolkit` copy `Krypton.Resources.dll` into `lib\{tfm}`. It is not a separate package id.

Typed accessors stay in the `Krypton.Toolkit.ResourceFiles.*` namespaces. `RootNamespace` is `Krypton.Toolkit` so existing resource names stay stable. Toolbox bitmaps and `Krypton.Toolkit` `Properties\Resources` stay in Toolkit.

## Packaging

`Source/Krypton Components/Krypton.Shared/Krypton.Resources.Package.targets` adds the DLL and PDB. The lib folder is `_KryptonPackageLibFolder` (`netX.0-windows7.0`). Project references use `PrivateAssets=all` so consumers do not get a package dependency on an id that is not published.

The placeholder project under `Krypton.Resources/Fallback` is not in the solution and is not packed. Its output is `Fallback/obj/fallback-bin` so it cannot replace the real DLL in `Bin`.

## Missing DLL

Toolkit embeds the placeholder as `Krypton.Toolkit.ResourcesFallback.dll`. `KryptonResourcesAssemblyResolve` handles `AssemblyResolve` for the simple name `Krypton.Resources`:

1. If `Krypton.Resources.dll` is beside `Krypton.Toolkit.dll`, that file is loaded.
2. Otherwise the embedded placeholder is loaded and a trace warning is written once.

On modern TFMs the handler is registered with `[ModuleInitializer]`. .NET Framework does not run that attribute, so `KryptonPreserializedResourceAssemblyResolve.Register` (the first resource touch on `KryptonManager` and `ToolkitStaticVariables`) registers it as well.

The placeholder uses the same assembly name, version, and strong-name key as the full bank. Image getters draw a glyph chosen from the resource name (check, radio, arrow, close, minimise, maximise, folder, error, grip, or a small mark) at the original pixel size. Horizontal strips are tiled into cells so `ImageList.Images.AddStrip` still slices them. The background is magenta, the same colour key as `SharedStaticVariables.TRANSPARENCY_KEY_COLOR`. `PaletteSchemaResources` and `OutlookGridStringResources` are the real resx. Cursor bytes are the real resx.

Control captions and label text are compiled into Toolkit, so they do not depend on the resource DLL.

## Validation

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -STA -File .\Scripts\UnitTests\UnitTest-ResourcesFallback.ps1
powershell -NoProfile -ExecutionPolicy Bypass -STA -File .\Scripts\UnitTests\UnitTest-CommandLinkArrow.ps1
```

The first script copies Debug binaries to a temp folder without `Krypton.Resources.dll`. The second checks that the real command-link arrow is still 32×32 when the full DLL is present.
