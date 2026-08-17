# Krypton About Box

## Overview

`KryptonAboutBox` is the comprehensive About dialog for applications built on the Standard Toolkit. It lives in the `Krypton.Toolkit.Utilities` assembly (`Krypton.Standard.Toolkit` NuGet package) and addresses [issue #2222](https://github.com/Krypton-Suite/Standard-Toolkit/issues/2222).

The dialog has two audiences:

- **Users** — product name, version, copyright, company, and description (VB About Box).
- **Developers** — application properties, loaded assemblies, and per-assembly attributes ([About The About Box](https://blog.codinghorror.com/about-the-about-box/)).

An optional Toolkit Information page can credit Krypton (license, Discord, docs, referenced assembly versions).

## Architecture

| Type | Role |
| --- | --- |
| `KryptonAboutBox` | Public static `Show` / `ShowAsync` entry point |
| `KryptonAboutBoxData` | Host identity, images, RTL, toolkit-page flag |
| `KryptonAboutToolkitData` | Optional Toolkit page chrome and link text |
| `VisualAboutBoxForm` | Designer-backed dialog (RTL applied at runtime) |
| `KryptonAboutBoxUtilities` | Assembly attribute scrape, grids, build date |
| `InternalAssemblyDetails` | Assembly combo + attribute grid |

Strings remain on `KryptonManager.Strings.AboutBoxStrings` and `AboutBoxBasicStrings` in `Krypton.Toolkit` so they stay localisable with the rest of the toolkit.

```
KryptonAboutBox.Show(...)
        │
        ▼
VisualAboutBoxForm
        ├── General / Description / Theme
        ├── File Information
        │     ├── Application (AppDomain + assembly names)
        │     ├── Assemblies (loaded assemblies)
        │     └── Assembly Details (attributes for a selected assembly)
        └── Toolkit Information (optional)
```

## Public API

### Zero-config

```csharp
KryptonAboutBox.Show();
KryptonAboutBox.Show(typeof(MainForm).Assembly);

await KryptonAboutBox.ShowAsync();
```

`Show()` uses `Assembly.GetEntryAssembly()`, then `GetCallingAssembly()` if the host has no entry assembly. Name, version, copyright, company, and description come from file version info and assembly attributes.

### Data object

```csharp
var data = new KryptonAboutBoxData
{
    CurrentAssembly = typeof(MainForm).Assembly,
    ApplicationName = "My App",          // optional override
    Version = "1.2.3",                   // optional
    Copyright = "Copyright © 2026",      // optional
    Company = "Example Ltd",             // optional
    Description = "Short description.",  // optional
    HeaderImage = Resources.Header,
    MainImage = Resources.Logo,
    ShowToolkitInformation = true,
    ShowSystemInformationButton = true,
    UseFullBuiltOnDate = true,
    UseRtlLayout = KryptonUseRTLLayout.No
};

KryptonAboutBox.Show(data, new KryptonAboutToolkitData());
```

When a string override is empty, the matching attribute / `FileVersionInfo` value is used.

### Toolkit page

`KryptonAboutToolkitData` controls Discord / developer / version buttons, theme combo, system information, and link text. `LinkArea` values that still match the constructor defaults are replaced with areas computed from the actual caption so localisation does not break the clickable range. Custom `LinkArea` values that fit the caption are honoured.

## Pages

| Page | Content |
| --- | --- |
| General | Logo, version, build date, **binary date/time**, copyright, company |
| Description | Assembly description / file description |
| File Information → Application | AppDomain base directory, friendly name, build date, binary date/time, entry/executing/current assembly |
| File Information → Assemblies | Name, version, binary date/time, location for loaded assemblies |
| File Information → Assembly Details | Combo of loaded assemblies and their custom attributes |
| Theme | Live `KryptonThemeComboBox` |
| Toolkit Information | Optional Krypton attribution, Discord, docs, referenced versions |

OK closes with `DialogResult.OK`. System Information launches `MSInfo32.exe`.

## RTL

Set `KryptonAboutBoxData.UseRtlLayout` to `KryptonUseRTLLayout.Yes`. The main form sets `RightToLeft` and `RightToLeftLayout`. There is no separate RTL form.

## Edge cases

- Empty `Assembly.Location` (single-file publish): file version info is skipped; attributes and `AssemblyName` are still used. Build date and binary date/time may be blank.
- Binary date/time uses the PE COFF `TimeDateStamp` only when it is a plausible calendar date (2000 through now). Deterministic SDK builds store a content hash in that field (which can decode as nonsense dates such as 2069); those are ignored and the file last-write time is used instead.
- `net472` through current Windows TFMs: AppDomain fields use `BaseDirectory` and `FriendlyName` only (no obsolete `SetupInformation`).
- Theme and Toolkit pages are extra relative to a classic About box; hide Toolkit with `ShowToolkitInformation = false`.
