# WinForms Designer Extensibility SDK (#593)

## Overview

Visual Studio’s .NET WinForms designer is out of process: `devenv.exe` stays on .NET Framework, and real controls live in `DesignToolsServer.exe` on the application TFM. This guide describes how Krypton splits designers, action lists, and glyphs out of the runtime assemblies for modern Windows TFMs, while keeping in-process designers for .NET Framework.

Owning packages: `Krypton.Toolkit`, `Krypton.Ribbon`, `Krypton.Navigator`, `Krypton.Workspace`, `Krypton.Toolkit.Utilities`, `Krypton.Navigator.Utilities`. `Krypton.Docking` has no `ControlDesigner` types, so nothing was ported.

Do **not** add `Microsoft.WinForms.Designer.SDK` to a runtime or application project. That package is design-time only and leaks into consumer apps ([dotnet/winforms#13296](https://github.com/dotnet/winforms/issues/13296)).

## Architecture

| Layer | TFM | Role |
|-------|-----|------|
| Runtime (`Krypton.Toolkit`, …) | net4x + net8/9/10/11-windows | Controls only on modern TFMs. No SDK PackageReference. |
| `*.Design` (Server) | modern Windows TFMs only | Designers, action lists, glyphs. References SDK 1.6.0. Loaded by DesignToolsServer. |
| `Krypton.Toolkit.Design.Client` | **net472 only** | VS-hosted type-editor UI (`OpenFileDialog` / `FolderBrowserDialog`). |
| `Krypton.Toolkit.Design.Protocol` | same TFMs as `Directory.Build.props` | Shared DTOs, `KryptonDesignerEndpointNames`, and `KryptonDesignerEditorNames` (Client editor AQNs). |

`[Designer]` attributes use a string that resolves to the runtime assembly on `NETFRAMEWORK` and to `Krypton.*.Design` otherwise:

```csharp
[Designer("Krypton.Toolkit.KryptonButtonDesigner, " + KryptonWinFormsDesignerSdk.AssemblyName)]
```

`KryptonWinFormsDesignerSdk.AssemblyName` is defined per runtime project (`General\KryptonWinFormsDesignerSdk.cs`). Utilities stub designers that point at `KryptonStubDesigner` use the Toolkit Design assembly name, because that type lives in Toolkit.

### Dual compile

Existing designer `.cs` files stay in the runtime tree. On modern TFMs the runtime **Compile Remove**s them. Each `*.Design` project **Compile Include**s the same files and aliases SDK types in `GlobalDeclarations.cs` (`ControlDesigner` → `Microsoft.DotNet.DesignTools.Designers.ControlDesigner`, and the matching action-list / glyph / behavior types).

`IncludeWinFormsDesignReferences=true` so `DesignerVerb` and `IDesignerHost` still resolve. Aliases disambiguate `ControlDesigner`.

Public types that remain in the runtime on Framework: type editors (`KryptonDesignerImageEditor`, collection editors) and designer UI under `Designers\Controls Visuals` and `Designers\Editors`. On modern TFMs, `[Editor]` attributes for image/folder pickers use assembly-qualified Client names (`KryptonWinFormsDesignerSdk.ImageEditor`); in-process editor types stay in the runtime as a Framework fallback. Internal `ControlDesigner` / `ComponentDesigner` subclasses and action lists move to Design.Server on modern TFMs.

Do **not** copy each designer into a parallel `Krypton.Toolkit.Server` tree with `#if NETFRAMEWORK` stubs. Dual-compile is the catalogue strategy. Add a new Client/Server pair only when the type cannot dual-compile (VS-hosted editor, ViewModel + `IDataPipeObject`, or SDK `CodeDomSerializer`).

### SDK API mismatches

`KryptonDesignerSdkCompat` (dual-compiled; **public** under `KRYPTON_WINFORMS_DESIGNER_SDK`) wraps:

- `AssociatedComponents` — SDK type is `IReadOnlyCollection<IComponent>`; Framework is `ICollection`.
- `ToArrayList` — SDK `AssociatedComponents` is not `ICollection`.

Other `#if KRYPTON_WINFORMS_DESIGNER_SDK` forks:

- `KryptonGroupPanelDesigner.SnapLines` uses the SDK base implementation (SDK `SnapLine` is not the Framework type).
- `KryptonSplitContainerBehavior.OnMouseUp` takes `(Glyph?, MouseButtons, Point)` on the SDK.
- `KryptonGroupPanelDesigner.InheritanceAttribute` is non-nullable on the SDK; `InitializeNewComponent` takes `IDictionary?`.
- Design.Server assemblies are `[assembly: CLSCompliant(false)]` because they wrap non-CLS `Microsoft.DotNet.DesignTools` types.

`NoneExcludedImageIndexConverter` lives in `Converters\` (runtime). It used to sit in `KryptonTreeViewDesigner.cs`, which is excluded from modern TFMs.

### InternalsVisibleTo

Runtime assemblies and `Krypton.Interop` grant InternalsVisibleTo the matching `*.Design` assemblies using the existing Krypton public key (`KryptonWinFormsDesignerSdkPublicKey` in `Directory.Build.props`). Design.Server needs Interop for `ThrowHelper` and `SharedStaticConstants`.

Do **not** add a Toolkit → Design `ProjectReference` (circular: Design already references Toolkit). Design projects are built via the solution. Packing uses `Exists()` on `Bin\<Config>\<tfm>\`.

## Shared MSBuild

| File | Purpose |
|------|---------|
| `Directory.Build.props` | `KryptonWinFormsDesignerSdkVersion` (1.6.0), `KryptonWinFormsDesignerSdkEnabled`, public key. |
| `Krypton.Shared/Krypton.WinFormsDesignerSdk.props` | Signing, SDK PackageReference, `KRYPTON_WINFORMS_DESIGNER_SDK`, `IncludeWinFormsDesignReferences=true`. Does not override TFMs. |
| `Krypton.Shared/Krypton.WinFormsDesignerSdk.Server.props` | Imports the above; **overrides TargetFrameworks to modern-only**. |
| `Krypton.Shared/Krypton.WinFormsDesignerSdk.Package.targets` | Packs Server DLL + Protocol into `lib\{tfm}\Design\WinForms\Server\`, Client + Protocol net472 into `lib\{tfm}\Design\WinForms\`. |

`Krypton.Standard.Toolkit` `AddReferencedAssembliesToPackage` packs the same layout for the meta-package (modern TFMs only).

## New projects

| Project | Assembly |
|---------|----------|
| `Krypton.Toolkit.Design.Protocol` | DTOs + `KryptonDesignerEndpointNames` (`EditImage`, `EditFolderPath`) + `KryptonDesignerEditorNames` |
| `Krypton.Toolkit.Design.Client` | net472; `KryptonDesignerImageEditor`, `KryptonDesignerFolderNameEditor` in `Krypton.Toolkit.Design.Client` |
| `Krypton.Toolkit.Design` | Toolkit designers + action lists + split-container glyphs/behavior + `KryptonDesignerActionItem` + `KryptonDesignerSdkCompat` + linked `KryptonDesignerTypeRoutingProvider` |
| `Krypton.Ribbon.Design` | Ribbon designers + action lists; refs Toolkit.Design |
| `Krypton.Navigator.Design` | Navigator designer and action lists |
| `Krypton.Workspace.Design` | Workspace designers and action list; refs Navigator.Design |
| `Krypton.Toolkit.Utilities.Design` | Utilities designers (including `KryptonCustomStringsManagerDesigner.cs`, which is not under `Designers\Designers\`) |
| `Krypton.Navigator.Utilities.Design` | Navigator.Utilities designers and action lists |

SNK path for new projects: `Krypton.Interop\StrongKrypton.snk`.

Design projects sit under the **DesignerSdk** solution folder (`/Source/DesignerSdk/` in the `.slnx`). Disk paths stay `Source/Krypton Components/Krypton.*.Design*`.

`Source/Krypton Components/Krypton.Shared/KryptonDesignerTypeRoutingProvider.cs` is **Compile Include**d (linked) into every Design.Server project.

## Type routing

The SDK does **not** infer `FooEditorVM` from `FooEditor`. Every connection is an explicit string match.

| Attribute | String | Resolved by |
|-----------|--------|-------------|
| `[Designer("X")]` or `[Designer("X, Assembly")]` | `X` / full name | Server `KryptonDesignerTypeRoutingProvider` (this assembly’s `ComponentDesigner` types) plus assembly-qualified load |
| `[Editor("Y, Assembly", typeof(UITypeEditor))]` | Assembly-qualified Client type | devenv loads `Design/WinForms/` Client DLLs. SDK 1.6 net472 Client has no type-routing API |
| `[DesignerSerializer("Z", "…CodeDomSerializer")]` | FQN | Loaded Server assemblies (`Type.GetType`), **not** type routing |

The linked provider registers `type.Name` and `type.FullName` for every non-abstract `ComponentDesigner` in that Design assembly.

## Type editors (Client / Protocol)

On modern TFMs, image and folder `[Editor]` attributes use `KryptonWinFormsDesignerSdk.ImageEditor` / `FolderNameEditor` / `InitialDirectoryEditor`:

- **.NET Framework:** assembly-qualified in-process type (`Krypton.Toolkit.KryptonDesignerImageEditor, Krypton.Toolkit`), including the themed `VisualSelectResourceForm` picker.
- **Modern TFMs:** assembly-qualified Client type (`Krypton.Toolkit.Design.Client.KryptonDesignerImageEditor, Krypton.Toolkit.Design.Client`). Keep these strings in sync with `KryptonDesignerEditorNames`.

SDK 1.6’s net472 Client surface has no `Microsoft.DotNet.DesignTools.TypeRouting` API. Do not add a Client `TypeRoutingProvider` unless the SDK is bumped. Client editors are packed for Visual Studio (`lib\{tfm}\Design\WinForms\`). They are plain WinForms dialogs, not Krypton-themed, so Client does not pack net472 Toolkit into that folder.

Simple Client editors (file/folder) run in devenv.exe and return a value the SDK marshals back. They do **not** need a ViewModel.

Protocol DTOs (`KryptonDesignerEditImageRequest`, folder equivalents) and `KryptonDesignerEndpointNames` exist. `ExportRequestHandler` / ViewModel RPC is **not** wired. Use that stack when:

- The Client cannot reference the property type
- The dialog must round-trip a structured object through `IDataPipeObject`
- A smart-tag command must `InvokePropertyEditor` on that object

`[AllowNull]` from the Designer SDK is internal on net472 — use `T?` on Protocol properties.

## ProjectReference does not load OOP designers

`Microsoft.NET.DesignerSupport.targets` builds `{Project}.designer.deps.json` from **NuGet** `project.assets.json` only. A solution `ProjectReference` to Toolkit shows the control but uses the default `ControlDesigner` (no smart tags, no Client editors).

- **TestForm** stays on `ProjectReference` for runtime validation (`WinFormsDesignerSdkDemo` / StartScreen **593 WinForms Designer SDK**). Do not convert it to NuGet-only.
- Exercise OOP designers in Visual Studio against a **packed nupkg** (CI feed or a local folder feed). Restart VS after replacing the package; design-time assemblies are cached.

## NuGet layout

Per [control-library-nuget-package-spec.md](https://github.com/microsoft/winforms-designer-extensibility/blob/main/docs/sdk/control-library-nuget-package-spec.md):

```
lib\{tfm}\Design\WinForms\Server\   Krypton.*.Design.dll + Protocol (modern TFM)
lib\{tfm}\Design\WinForms\          Krypton.Toolkit.Design.Client.dll + Protocol (net472)
```

Individual Toolkit nupkgs use `Package.targets` with `$(TargetFramework)` (`net8.0-windows`). Standard.Toolkit uses `_LibFolderName` (`net8.0-windows7.0`, …).

CI pack jobs (`Scripts/Build/Krypton.Orchestration.targets`) must **build** Protocol, Client, and `*.Design` before Pack. Runtime projects do not ProjectReference Design (circular). Packing uses `Exists()`; if those DLLs are missing, the nupkg is produced without `Design/WinForms`. `Scripts/CI/Test-KryptonDesignerSdkInPackages.ps1` fails pack workflows when the folder is absent on modern TFMs.

## Breaking changes (modern TFMs only)

These public types are compiled into `*.Design` instead of the runtime:

- `KryptonNavigatorDesigner`, `KryptonNavigatorActionList`
- `KryptonDesignerActionItem`
- `KryptonBackstageViewDesigner`

Related designer types that were already internal (`KryptonPageDesigner`, `KryptonPageActionList`, workspace designers) also compile only into `*.Design` on modern TFMs.

.NET Framework (`net472` / `net48` / `net481`) is unchanged: designers remain in the runtime assemblies.

## Do not

- Add `Microsoft.WinForms.Designer.SDK` to runtime or application csprojs.
- Add a Toolkit → Design ProjectReference.
- Convert TestForm to NuGet-only so OOP designers load; keep a packed-nupkg host for that.
- Put new `PaletteMode` or packing paths in the wrong `lib\{tfm}` folder.
- Leave `Documents/Development/` files in a pull request.
