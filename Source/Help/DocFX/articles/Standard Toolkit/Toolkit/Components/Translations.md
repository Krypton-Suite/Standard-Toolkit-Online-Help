# Translations (XML & JSON)

## Overview

The **Translations** feature lets applications export the built-in Krypton toolkit string sets to a versioned `Translations.xml` or `Translations.json` file and import them back at design-time or at runtime. It also covers application-defined custom strings through a companion persistence layer in `Krypton.Toolkit.Utilities`. It covers:

- `KryptonManager.Strings` (`KryptonGlobalToolkitStrings`) — all shared toolkit strings (buttons, dialogs, message boxes, property-grid labels, …)
- `KryptonDockingManager.Strings` (`DockingManagerStrings`) — docking context-menu and tooltip text
- `WorkspaceMenus` (accessed via `KryptonWorkspace.StateCommon.WorkspaceMenus`) — workspace page context-menu text
- `KryptonCustomStrings` (`Krypton.Toolkit.Utilities`) — application-defined key/value strings and registered strongly typed custom string sets that are not part of the toolkit out of the box
- Optional Windows language-pack (MUI) strings — `UseWindowsLanguagePackStrings` loads matching dialog buttons from `user32.dll` and Explorer column headers from `shell32.dll` for the current UI language (default off)

The built-in toolkit-string workflow is implemented in **`Krypton.Toolkit`** (`ToolkitStringsXmlPersistence` / `ToolkitStringsJsonPersistence`) and surfaced on the above types as `Export…` / `Import…` methods. Application-defined custom strings are persisted separately by **`Krypton.Toolkit.Utilities`** (`KryptonCustomStringsPersistence`). The `KryptonManager` designer exposes Smart Tag verbs for the built-in toolkit strings; custom strings are exported/imported through `KryptonCustomStrings`.

---

## Architecture

```
KryptonManager.Strings          (KryptonGlobalToolkitStrings)
    │ ExportToXmlFile / ExportToXmlDocument / ExportToStream
    │ ImportFromXmlFile / ImportFromXmlDocument / ImportFromStream
    │ ExportToJson / ExportToJsonFile
    │ ImportFromJsonFile
    │ (static helpers)
    │ KryptonManager.AutoDiscoverTranslations (bool, default true)
    │ KryptonManager.LoadTranslationsFromFile
    │ KryptonManager.TryLoadTranslationsFromFile
    │ KryptonManager.TryLoadCultureSpecificTranslations
    │ KryptonManager.TrySwitchTranslationsCulture
    │ KryptonManager.ActiveTranslationsCulture
    │ KryptonManager.TranslationsImported (event)
    │ UseWindowsLanguagePackStrings (bool, default false)
    │   → GeneralStrings.UseOSStrings (user32.dll dialog buttons)
    │   → FileSystemListViewStrings.UseOSStrings (shell32.dll column headers)
    ▼
ToolkitStringsXmlPersistence    (internal static, Krypton.Toolkit)
    Export()  — reflection walk → XmlDocument
    Import()  — XmlDocument → reflection write

ToolkitStringsJsonPersistence   (internal static, Krypton.Toolkit)
    Export()  — reflection walk → JSON string
    ImportFromJson() — JSON → XmlDocument → ToolkitStringsXmlPersistence.Import()

ToolkitStringsXmlMerge          (public static, Krypton.Toolkit)
    MergeFiles() / Merge() — combine two Translations.xml documents

KryptonDockingManager.Strings   (DockingManagerStrings)
    ExportToXmlFile / ExportToXmlDocument
    ImportFromXmlFile / ImportFromXmlDocument

WorkspaceMenus
    ExportToXmlFile / ExportToXmlDocument
    ImportFromXmlFile / ImportFromXmlDocument

KryptonCustomStrings            (Krypton.Toolkit.Utilities)
    ExportToXmlFile / ExportToXmlDocument
    ImportFromXmlFile / ImportFromXmlDocument
    ExportToXmlStream / ImportFromXmlStream
    ExportToJson / ExportToJsonFile
    ExportToJsonStream / ImportFromJsonStream
    ImportFromJsonFile
    TryAutoDiscover / TryLoadCultureSpecificFile / TrySwitchCulture
    CustomStringsImported (event)
    ↓
KryptonCustomStringsPersistence (internal static, Krypton.Toolkit.Utilities)
    Persists dictionary values + registered typed string sets

KryptonCombinedTranslations     (public static, Krypton.Toolkit.Utilities)
    ExportToXmlFile / ExportToXmlDocument
    ImportFromXmlFile / ImportFromXmlDocument
    Combines KryptonManager.Strings + KryptonCustomStrings in one artifact
```

`ToolkitStringsXmlPersistence` is visible to `Krypton.Docking` and `Krypton.Workspace` via `InternalsVisibleTo` declared in `Krypton.Toolkit/Global/GlobalDeclarations.cs`.

---

## XML Format

```xml
<?xml version="1.0"?>
<KryptonTranslations Version="1" Culture="en-GB" Generated="29/07/2026 10:00:00">
  <GeneralStrings>
    <!-- Text displayed on OK buttons in dialogs. -->
    <OK Value="OK" />
    <!-- Text displayed on Cancel buttons in dialogs. -->
    <Cancel Value="Cancel" />
  </GeneralStrings>
  <MessageBoxStrings>
    <MoreDetails Value="More Details" />
    ...
  </MessageBoxStrings>
  ...
</KryptonTranslations>
```

### Key rules

| Attribute | Meaning |
|---|---|
| `Version` | Integer format version (currently `1`). Import rejects files with a lower version number. |
| `Culture` | `CultureInfo.Name` at export time. On import, a mismatch emits a `Debug.WriteLine` warning (controllable via `warnOnCultureMismatch`). |
| `Generated` | Timestamp — informational only. |
| `Value` | The string value. |
| `IsNull` | `"true"` if the property value is `null` (rare). |

### What gets exported

Only properties decorated with **`[Localizable(true)]`** and of type `string` are included.  Nested objects derived from `GlobalId` (or `Storage`) are traversed recursively and written as container elements.

When `includeDefaults = false` (the default), properties whose current value equals the value declared in `[DefaultValue(...)]` are omitted.  Use `includeDefaults = true` to see the complete string catalogue.

### Unknown elements on import

Unrecognised element names are silently ignored, making the format forward- and backward-compatible at best effort.

---

## Public API

### `KryptonGlobalToolkitStrings` (accessed via `KryptonManager.Strings`)

```csharp
// Export
XmlDocument ExportToXmlDocument(bool includeDefaults = false);
void        ExportToXmlFile(string filename, bool includeDefaults = false);
void        ExportToStream(Stream stream, bool includeDefaults = false);

// Import (XML)
void ImportFromXmlDocument(XmlDocument doc,
        bool resetFirst = true, bool refreshOpenForms = true, bool warnOnCultureMismatch = true);
void ImportFromXmlFile(string filename,
        bool resetFirst = true, bool refreshOpenForms = true, bool warnOnCultureMismatch = true);
void ImportFromStream(Stream stream,
        bool resetFirst = true, bool refreshOpenForms = true, bool warnOnCultureMismatch = true);

// JSON
string ExportToJson(bool includeDefaults = false);
void   ExportToJsonFile(string filename, bool includeDefaults = false);
void   ImportFromJsonFile(string filename, bool resetFirst = true, bool refreshOpenForms = true);

// Optional Windows language-pack (MUI) strings — default false.
// When true, matching dialog buttons use user32.dll and Explorer column headers use shell32.dll.
bool UseWindowsLanguagePackStrings { get; set; }

// Fine-grained equivalents (also used by UseWindowsLanguagePackStrings):
// GeneralStrings.UseOSStrings
// FileSystemListViewStrings.UseOSStrings
```

### `KryptonManager` (static convenience)

```csharp
static void LoadTranslationsFromFile(string path, bool refreshOpenForms = false);
static bool TryLoadTranslationsFromFile(string path, bool refreshOpenForms = false);
static bool TryLoadCultureSpecificTranslations(
        string? directory = null,
        CultureInfo? culture = null,
        string baseName = "Translations",
        bool refreshOpenForms = false);
static bool TrySwitchTranslationsCulture(
        CultureInfo culture,
        string? directory = null,
        string baseName = "Translations",
        bool refreshOpenForms = true);
static bool TrySwitchTranslationsCulture(
        string cultureName,
        string? directory = null,
        string baseName = "Translations",
        bool refreshOpenForms = true);
static CultureInfo? ActiveTranslationsCulture { get; }

// Auto-discovery — set to false before the first Krypton type use to suppress file probing.
static bool AutoDiscoverTranslations { get; set; }  // default: true

// Event — fires after a successful import via LoadTranslationsFromFile / TryLoadTranslationsFromFile
// or after a successful auto-discovery load / culture switch.
static event EventHandler? TranslationsImported;
```

`TryLoadTranslationsFromFile` and `LoadTranslationsFromFile` accept either `.xml` or `.json` (detected from the file extension).
`TryLoadCultureSpecificTranslations` probes exact → neutral → default with graceful fallback and is used by auto-discovery.
`TrySwitchTranslationsCulture` sets `CurrentUICulture` / `DefaultThreadCurrentUICulture`, reloads matching files, and falls back to built-in defaults when no file is found.

`TryLoadTranslationsFromFile` swallows exceptions and returns `false` when the file is missing or invalid — suitable for optional startup loading without try/catch boilerplate.

`TranslationsImported` fires after a successful import so application code can react (rebuild menus, update status bars, etc.) without polling.

### `DockingManagerStrings`

```csharp
XmlDocument ExportToXmlDocument(bool includeDefaults = false);
void        ExportToXmlFile(string filename, bool includeDefaults = false);
void        ImportFromXmlDocument(XmlDocument doc, bool resetFirst = true);
void        ImportFromXmlFile(string filename, bool resetFirst = true);
```

### `WorkspaceMenus`

```csharp
XmlDocument ExportToXmlDocument(bool includeDefaults = false);
void        ExportToXmlFile(string filename, bool includeDefaults = false);
void        ImportFromXmlDocument(XmlDocument doc, bool resetFirst = true);
void        ImportFromXmlFile(string filename, bool resetFirst = true);
```

### `KryptonCustomStrings` (`Krypton.Toolkit.Utilities`)

```csharp
// Existing runtime access
static KryptonCustomStringValues Values { get; }
static string Get(string key, string defaultValue = "");
static void   Set(string key, string value);
static void   RegisterStringSet(string name, GlobalId stringSet);
static T?     GetStringSet<T>(string name) where T : GlobalId;

// Persistence
static XmlDocument ExportToXmlDocument(bool includeDefaults = false);
static void        ExportToXmlFile(string filename, bool includeDefaults = false);
static void        ExportToXmlStream(Stream stream, bool includeDefaults = false);
static void        ImportFromXmlDocument(XmlDocument doc, bool resetFirst = true);
static void        ImportFromXmlFile(string filename, bool resetFirst = true);
static void        ImportFromXmlStream(Stream stream, bool resetFirst = true);
static string      ExportToJson(bool includeDefaults = false);
static void        ExportToJsonFile(string filename, bool includeDefaults = false);
static void        ExportToJsonStream(Stream stream, bool includeDefaults = false);
static void        ImportFromJsonFile(string filename, bool resetFirst = true);
static void        ImportFromJsonStream(Stream stream, bool resetFirst = true);
static bool        AutoDiscoverCustomTranslations { get; set; }  // default: false
static bool        TryAutoDiscover(string? directory = null);
static bool        TryLoadCultureSpecificFile(
        string directory,
        string baseName = "CustomTranslations",
        CultureInfo? culture = null);
static bool        TrySwitchCulture(CultureInfo culture, string? directory = null, string baseName = "CustomTranslations");
static bool        TrySwitchCulture(string cultureName, string? directory = null, string baseName = "CustomTranslations");
static event EventHandler? CustomStringsImported;
```

`KryptonCustomStrings` persists to its own custom-translations format rooted at `<KryptonCustomTranslations>`. It does not share `KryptonManager` auto-discovery or designer verbs, but it now has its own opt-in auto-discovery and designer verbs on `KryptonCustomStringsManager`.

### Parameters

| Parameter | Default | Meaning |
|---|---|---|
| `includeDefaults` | `false` | Emit strings even when they equal the toolkit default. |
| `resetFirst` | `true` | Reset all strings to defaults before applying imported values, so strings absent from the file revert to their built-in text. |
| `refreshOpenForms` | `true` / `false` | Invalidate and refresh all open forms after import (toolkit strings only). |
| `warnOnCultureMismatch` | `true` | Write a `Debug.WriteLine` warning when the file culture differs from `Thread.CurrentUICulture`. |

---

## Usage

### Startup auto-load (zero-code — recommended for built-in toolkit strings)

Simply place `Translations.xml` (or `Translations.json`) in the application's output directory and set **Copy to Output Directory = Copy if newer**. `KryptonManager` discovers and loads it automatically before any control is shown. No code is required.

This applies to the built-in toolkit string sets managed by `KryptonManager.Strings`. `KryptonCustomStrings` are application-defined and should be registered before import.

For custom strings, opt-in auto-discovery is available through `KryptonCustomStrings.AutoDiscoverCustomTranslations`. Discovery is attempted after the first typed string-set registration and uses the same exact → neutral → default culture fallback rules (XML before JSON).

### Manual startup load (explicit, non-throwing)

Use when auto-discovery is disabled or when loading a culture-specific file:

```csharp
KryptonManager.AutoDiscoverTranslations = false; // suppress auto-discovery if needed
KryptonManager.TryLoadTranslationsFromFile(
    Path.Combine(AppContext.BaseDirectory, "Translations.xml"));
```

### Explicit startup load (throws on error)

```csharp
KryptonManager.LoadTranslationsFromFile("Translations.xml");
```

### Runtime load with immediate UI refresh

```csharp
KryptonManager.Strings.ImportFromXmlFile(
    openFileDialog.FileName,
    resetFirst: true,
    refreshOpenForms: true);
```

### Stream (e.g. embedded resource)

```csharp
using var stream = Assembly.GetExecutingAssembly()
    .GetManifestResourceStream("MyApp.Resources.Translations.xml")!;
KryptonManager.Strings.ImportFromStream(stream);
```

### Docking manager strings

```csharp
// Export
myDockingManager.Strings.ExportToXmlFile("DockingTranslations.xml");
myDockingManager.Strings.ExportToJsonFile("DockingTranslations.json");

// Import
myDockingManager.Strings.ImportFromXmlFile("DockingTranslations.xml");
myDockingManager.Strings.ImportFromJsonFile("DockingTranslations.json");
```

### Workspace page-menu strings

```csharp
myWorkspace.StateCommon.WorkspaceMenus.ExportToXmlFile("WorkspaceMenuTranslations.xml");
myWorkspace.StateCommon.WorkspaceMenus.ImportFromXmlFile("WorkspaceMenuTranslations.xml");
myWorkspace.StateCommon.WorkspaceMenus.ExportToJsonFile("WorkspaceMenuTranslations.json");
myWorkspace.StateCommon.WorkspaceMenus.ImportFromJsonFile("WorkspaceMenuTranslations.json");
```

### Custom application strings

```csharp
// Dictionary-style strings
KryptonCustomStrings.Set("SaveDraft", "S&ave Draft");

// Strongly typed custom string set
var demoStrings = new DemoAppStrings();
KryptonCustomStrings.RegisterStringSet("DemoApp", demoStrings);

// Persist both dictionary values and registered typed sets
KryptonCustomStrings.ExportToXmlFile("CustomTranslations.xml", includeDefaults: true);
KryptonCustomStrings.ImportFromXmlFile("CustomTranslations.xml");
```

Registered typed string sets must be registered by the application before import. Unknown registration names in the file are ignored so applications can evolve their custom string surface without breaking older files.

### Manual startup load for custom strings

```csharp
KryptonCustomStrings.RegisterStringSet("DemoApp", new DemoAppStrings());
KryptonCustomStrings.ImportFromXmlFile(
    Path.Combine(AppContext.BaseDirectory, "CustomTranslations.xml"));
```

### Combined toolkit + custom artifact

```csharp
KryptonCombinedTranslations.ExportToXmlFile("AllTranslations.xml", includeDefaults: true);
KryptonCombinedTranslations.ImportFromXmlFile("AllTranslations.xml");
```

### Optional Windows language-pack strings

Use this when you want OS-localised labels for the small set of strings that map to stable Windows MUI resources. It does **not** replace XML/JSON translations for the full toolkit string set.

```csharp
// Master switch (dialog buttons + Explorer column headers)
KryptonManager.Strings.UseWindowsLanguagePackStrings = true;

// Or enable only one surface:
KryptonManager.Strings.GeneralStrings.UseOSStrings = true;                 // OK, Cancel, Yes, No, …
KryptonManager.Strings.FileSystemListViewStrings.UseOSStrings = true;      // Name, Type, Size, …
```

While enabled, getters prefer the OS MUI text for the current UI language and fall back to the toolkit defaults if a resource cannot be loaded. Custom property values remain stored and are used again when the flag is turned off. `Reset()` clears the flag back to `false`.

This flag is a runtime/design-time option; it is **not** written into `Translations.xml` / `.json` (persistence only walks localisable string properties).

---

## Validation — Custom Strings Demo

Demo name: **`ApplicationStringsTest`** (registered in `StartScreen.AddButtons()` as `"Custom Strings"`).

### Manual steps

1. Run `dotnet run --project ".\Source\Krypton Components\TestForm\TestForm.csproj" -c Debug`
2. Open **Custom Strings**.
3. Edit the dictionary string and typed string values.
4. Click **Export XML** or **Export JSON**.
5. Change or reset the values in the form.
6. Click **Import XML** or **Import JSON** and verify both the dictionary-backed and typed string-backed buttons restore.

---

## Designer Integration

The `KryptonManager` Smart Tag (design-time action list) exposes these translation actions:

- **Import Translations from Xml file…** — opens a file picker, loads the selected XML file, and notifies `IComponentChangeService` so the Property Grid refreshes immediately.
- **Export Translations to Xml file…** — opens a save dialog and writes `Translations.xml` at the chosen location (non-default strings only).
- **Import Translations from Json file…** — same as above but for a JSON translations file.
- **Export Translations to Json file…** — opens a save dialog and writes `Translations.json` (non-default strings only).
- **Generate Translation Template…** — exports XML with `includeDefaults: true`, producing a complete template with every overridable string and its XML comment.
- **Switch Translations Culture…** — prompts for a culture name and optional translations directory, then calls `TrySwitchTranslationsCulture` with graceful fallback.
- **UI Culture** (Smart Tag property) — dropdown of common cultures (free-form entry allowed). Changing it switches the designer UI culture and loads matching `Translations.{culture}.*` files.
- **Use Windows Language Pack** (Smart Tag property) — toggles `UseWindowsLanguagePackStrings` so matching dialog buttons / Explorer column headers use the installed Windows language pack.

No code is required to use these verbs at design time. Design-time culture switching affects the Visual Studio designer session only; runtime apps should call `TrySwitchTranslationsCulture` (or use their own UI).

The **Translations.xml Demo** (`TranslationsXmlDemoForm` in TestForm) also exposes a **Use Windows language pack strings** checkbox for interactive validation.

`KryptonCustomStringsManager` also exposes designer verbs for XML/JSON import/export of application-defined custom strings.

---

## Auto-Discovery

`KryptonManager` automatically probes the application's base directory at type-initialisation time (i.e. the first time any Krypton type is used). It looks for these files **in priority order**, using the current UI culture:

1. `Translations.{exact-culture}.xml` — e.g. `Translations.en-GB.xml`
2. `Translations.{neutral-culture}.xml` — e.g. `Translations.en.xml`
3. `Translations.xml` — culture-agnostic default
4. The same three candidates with `.json` (XML is preferred over JSON)

The first file that exists **and loads successfully** wins. Missing files are skipped. Invalid files are traced to `Debug.WriteLine` and the next candidate is tried — auto-discovery never throws or blocks startup.

### Opting out

Set `AutoDiscoverTranslations` to `false` **before** the first use of any Krypton type (e.g. at the very top of `Main()`):

```csharp
KryptonManager.AutoDiscoverTranslations = false;
```

This is useful in unit-test hosts, tools that manage translations entirely in code, or any scenario where the file in the base directory should not be loaded automatically.

### How to ship a translations file

1. Export a template via the `KryptonManager` designer verb **Generate Translation Template…** or call `ExportToXmlFile` with `includeDefaults: true`.
2. Edit the file to supply your translated strings. The XML comments explain each string.
3. Name culture-specific files with a dotted culture suffix (`Translations.fr-FR.xml`, `Translations.fr.xml`) and keep an optional default `Translations.xml` as fallback.
4. Add the file(s) to your project and set **Copy to Output Directory = Copy if newer**.
5. Ship. No code changes are required — auto-discovery picks up the best match on first run.

### Per-culture files

Ship multiple files side by side:

```
Translations.en-GB.xml
Translations.en.xml
Translations.fr-FR.xml
Translations.xml
```

Auto-discovery (and `TryLoadCultureSpecificTranslations`) resolve them with graceful fallback. To switch culture at runtime:

```csharp
// Sets CurrentUICulture, reloads Translations.fr-FR.xml (or fallback), refreshes open forms.
// Returns false when no file matched — built-in defaults are restored in that case.
KryptonManager.TrySwitchTranslationsCulture("fr-FR", refreshOpenForms: true);

// Strongly-typed overload:
KryptonManager.TrySwitchTranslationsCulture(new CultureInfo("de-DE"));

// Last successfully switched/loaded culture:
var active = KryptonManager.ActiveTranslationsCulture;
```

For application-defined custom strings:

```csharp
KryptonCustomStrings.TrySwitchCulture("fr-FR");
```

---

## Reflection Rules (what `ToolkitStringsXmlPersistence` traverses)

- Visits **public instance properties** of the target object.
- Skips indexers and non-readable properties.
- For `string` properties: only emits those decorated with `[Localizable(true)]`.
- For `GlobalId`/`Storage`-derived properties: recurses, writing a container element named after the property.
- All other property types are ignored (no `Keys`, `bool`, `int`, etc. are persisted by the toolkit strings helper).
- Default detection uses `[DefaultValue(...)]`; properties without this attribute are always considered non-default.

---

## JSON Format

Toolkit strings can also be exported/imported as JSON via `ToolkitStringsJsonPersistence`:

```csharp
// Export to JSON file
KryptonManager.Strings.ExportToJsonFile("Translations.json", includeDefaults: true);

// Import from JSON file
KryptonManager.Strings.ImportFromJsonFile("Translations.json");
```

The JSON structure mirrors the XML hierarchy:

```json
{
  "Version": 1,
  "Culture": "en-GB",
  "Generated": "29/07/2026 10:00:00",
  "GeneralStrings": {
    "OK": "OK",
    "Cancel": "Cancel"
  },
  "MessageBoxStrings": {
    "MoreDetails": "More Details"
  }
}
```

JSON import works by converting the JSON into the canonical XML format internally, so all validation, reset, and refresh behaviour is shared with the XML path.

---

## Merge Utility

`ToolkitStringsXmlMerge` merges two Translations.xml files — useful when upgrading the toolkit and carrying custom translations forward:

```csharp
// Merge: overlay values overwrite baseline; baseline-only values are kept.
ToolkitStringsXmlMerge.MergeFiles(
    baselinePath: "Translations-Template.xml",    // fresh export from new toolkit version
    overlayPath:  "Translations-Custom.xml",       // user's existing customisations
    outputPath:   "Translations-Merged.xml");

// In-memory merge:
var merged = ToolkitStringsXmlMerge.Merge(baselineDoc, overlayDoc);
```

`KryptonCustomStringsXmlMerge` provides the same merge workflow for `KryptonCustomTranslations`.

---

## XSD Schema

`Documents/Assets/Translations.xsd` provides an XML Schema that external editors can reference for IntelliSense and validation. Reference it in your `Translations.xml`:

```xml
<KryptonTranslations xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xsi:noNamespaceSchemaLocation="Translations.xsd"
                     Version="1" Culture="en-GB" Generated="...">
```

For custom strings, use `Documents/Assets/CustomTranslations.xsd` and `Documents/Assets/CustomTranslations.schema.json`.

---

## TranslationsImported Event

`KryptonManager.TranslationsImported` fires after a successful import via `LoadTranslationsFromFile` or `TryLoadTranslationsFromFile`:

```csharp
KryptonManager.TranslationsImported += (_, _) =>
{
    // Rebuild menus, update status bars, etc.
    statusLabel.Text = "Translations reloaded.";
};
```

The event is **not** raised by the lower-level `Strings.ImportFromXmlFile` / `ImportFromStream` methods — subscribe to the static event only when using the `KryptonManager` convenience entry points.

`KryptonCustomStrings.CustomStringsImported` is raised after successful XML/JSON imports for application-defined custom strings.

---

## Edge Cases

| Scenario | Behaviour |
|---|---|
| File not found (`TryLoadTranslationsFromFile`) | Returns `false`; `Debug.WriteLine` trace. |
| File not found (`LoadTranslationsFromFile`) | Throws `FileNotFoundException` (from `XmlDocument.Load`). |
| Version < 1 | `ArgumentException` thrown with a descriptive message. |
| Unknown element names | Silently ignored. |
| Culture mismatch | `Debug.WriteLine` warning; import continues. |
| `null` string value | Serialised as `IsNull="true" Value=""`; restored as `null`. |
| `resetFirst = false` | Only strings present in the XML are overwritten; other strings retain their current (possibly customised) values. |
| `UseWindowsLanguagePackStrings = true` | Matching dialog / Explorer strings come from OS MUI; other toolkit strings unchanged. Missing OS resources fall back to toolkit defaults. |
| Language pack not installed / resource missing | OS load fails quietly; toolkit default (or previously set custom value when the flag is off) is used. |
