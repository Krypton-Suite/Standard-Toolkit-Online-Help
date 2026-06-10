# Krypton.Toolkit TypeInitializationException: missing System.Memory

## Overview

This document explains the cause, diagnosis, fixes, and verification steps for the exception seen during Windows Forms startup:

System.TypeInitializationException: The type initializer for 'Krypton.Toolkit.KryptonManager' threw an exception.

Inner-most cause:

System.IO.FileNotFoundException: Could not load file or assembly 'System.Memory, Version=4.0.1.2, Culture=neutral, PublicKeyToken=cc7b13ffcd2ddd51'

This usually appears in a multi-target SDK-style project that includes a .NET Framework (net48) target alongside a modern .NET target. Krypton types (palettes/resources) are deserialized during InitializeComponent and require System.Memory at runtime when the app runs under .NET Framework.

---

## Root cause (technical)

- The Krypton library (or types serialized in form resources used by Krypton palettes) requires the System.Memory assembly at runtime.
- When running the net48 build, the .NET Framework loader (Fusion) attempts to resolve System.Memory by exact identity or using binding redirects.
- The required System.Memory assembly/version was not available in the application probing paths and no binding redirect mapped the request to an available version, resulting in FileNotFoundException during resource deserialization.
- The FileNotFoundException inside static initialization causes the observed TypeInitializationException chain.

---

## Why resource deserialization triggers assembly loads

- WinForms designer files (InitializeComponent) use ComponentResourceManager to read resources (ResX) and may deserialize objects or load typed resources.
- DeserializingResourceReader will validate and attempt to load the CLR types referenced by resources. If those types live in assemblies that are missing, assembly load errors surface while constructing form objects (or in library static initializers invoked from resources).

---

## Fixes applied (what to change in the project)

Two complementary changes were applied in the project file to resolve the issue for the net48 target:

1) Ensure System.Memory is a restored package for the net48 build so the exact assembly will be copied to output.

Add a conditional PackageReference that only applies when targeting .NET Framework:

```xml
<!-- In your SDK project file (.csproj) -->
<ItemGroup Condition="'$(TargetFramework)' == 'net48'">
  <PackageReference Include="System.Memory" Version="4.5.4" />
</ItemGroup>
```

2) Enable binding redirect generation when building for .NET Framework so version mismatches are handled automatically:

```xml
<PropertyGroup>
  <AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>
  <GenerateBindingRedirectsOutputType>true</GenerateBindingRedirectsOutputType>
</PropertyGroup>
```

Rationale:
- Adding System.Memory ensures a compatible assembly is restored and copied to the bin folder for net48.
- Auto-generated binding redirects let the runtime map requests for different System.Memory versions to the available version when multiple packages target different versions.

---

## Alternative solutions (choose based on needs)

- Remove the net48 target if you do not need to run on .NET Framework. Target only modern .NET (e.g., net10.0-windows) which avoids these binding issues.
- Add an explicit app.config binding redirect (manual) instead of auto-generation. Example:

```xml
<!-- app.config / <runtime> section -->
<runtime>
  <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
	<dependentAssembly>
	  <assemblyIdentity name="System.Memory" publicKeyToken="cc7b13ffcd2ddd51" culture="neutral" />
	  <bindingRedirect oldVersion="0.0.0.0-4.5.4.0" newVersion="4.5.4.0" />
	</dependentAssembly>
  </assemblyBinding>
</runtime>
```

- Copy the exact System.Memory.dll to the output folder manually (not recommended as a long-term fix).

---

## Verification & testing checklist

1. Restore and build for net48:

```sh
dotnet restore
dotnet build -f net48
```

2. Confirm output contains System.Memory.dll (or a redirected binding entry):

- Check bin\Debug\net48\ (or your configuration path) for System.Memory.dll.
- Check the generated app.config (if produced) for assemblyBinding entries.

3. Run the application (the net48 build) and confirm it no longer throws during Form construction.

4. If still failing, enable Fusion logs to capture assembly binding attempts (see troubleshooting below).

---

## Troubleshooting steps (if problem persists)

- Confirm which target is running: when launching from Visual Studio ensure the project is actually being run as the net48 build if you intend to test net48 behavior.
- Inspect inner exceptions and resource names to identify which resource or Krypton type triggers the load.
- Check bin output for System.Memory and validate its assembly identity (version, public key token). Use a simple tool or PowerShell to inspect:

```powershell
# Example: get file properties with reflection metadata (requires appropriate tool)
```

- Capture assembly binding logs (Fusion):
  - Run Fuslogvw.exe (Assembly Binding Log Viewer) with logging enabled.
  - Reproduce the failure and inspect the log entries to see probing locations and versions attempted.

- If a third-party dependency requires a different System.Memory version, use bindingRedirect to map oldVersion->newVersion.

---

## CI / Build pipeline notes

- Ensure your CI restores packages for all targeted frameworks before building. Example pipeline steps:

```sh
dotnet restore
dotnet build -f net48 --configuration Release
```

- Building for net48 on headless agents may require .NET Framework targeting packs or Visual Studio Build Tools installed. Confirm the build agent has the required workloads.

- AutoGenerateBindingRedirects runs in MSBuild for net48 builds; ensure the build uses the SDK that supports these targets.

---

## Best practices & recommendations

- For multi-targeted projects, add framework-specific PackageReferences when older runtimes need additional compatibility packages.
- Prefer AutoGenerateBindingRedirects for SDK-style projects that produce .NET Framework outputs to avoid manual maintenance of app.config binding redirects.
- Prefer modern .NET targets where possible to reduce assembly-binding complexity.
- Keep third-party packages updated and read their compatibility notes (Krypton release notes may document required dependencies).

---

## References & tools

- Fuslogvw.exe — Assembly Binding Log Viewer (for .NET Framework binding failures).
- dotnet CLI: dotnet add package, dotnet restore, dotnet build.
- Microsoft docs: AutoGenerateBindingRedirects and binding redirect behavior in SDK-style projects.

---

## Appendix: applied csproj snippet

The following is the exact change used to fix the issue in an SDK-style multi-target project:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
	<OutputType>WinExe</OutputType>
	<TargetFrameworks>net48;net10.0-windows</TargetFrameworks>
	<Nullable>enable</Nullable>
	<UseWindowsForms>true</UseWindowsForms>
	<AutoGenerateBindingRedirects>true</AutoGenerateBindingRedirects>
	<GenerateBindingRedirectsOutputType>true</GenerateBindingRedirectsOutputType>
	<ImplicitUsings>enable</ImplicitUsings>
	<LangVersion>preview</LangVersion>
  </PropertyGroup>

  <ItemGroup>
	<PackageReference Include="Krypton.Standard.Toolkit.Nightly" Version="110.26.5.141-alpha" />
  </ItemGroup>

  <ItemGroup Condition="'$(TargetFramework)' == 'net48'">
	<PackageReference Include="System.Memory" Version="4.5.4" />
  </ItemGroup>
</Project>
```

---

If you need additional edits (explicit app.config, test scripts, CI pipeline changes, or a sample project reproducer), provide guidance on the desired output format and I will prepare it.
