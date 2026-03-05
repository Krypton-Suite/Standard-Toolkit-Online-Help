# External Themes: Bundled Display Names

## Table of Contents

1. [Overview](#overview)
2. [Quick reference](#quick-reference)
3. [Architecture](#architecture)
4. [API reference](#api-reference)
5. [Persistence format (XML and binary)](#persistence-format-xml-and-binary)
6. [Import and export behaviour](#import-and-export-behaviour)
7. [Displaying the current theme name](#displaying-the-current-theme-name)
8. [Usage for theme authors](#usage-for-theme-authors)
9. [Usage for application developers](#usage-for-application-developers)
10. [Backward compatibility](#backward-compatibility)
11. [Implementation details](#implementation-details)
12. [Edge cases and behaviour](#edge-cases-and-behaviour)
13. [Testing and verification](#testing-and-verification)
14. [Related types and components](#related-types-and-components)
15. [Troubleshooting](#troubleshooting)

---

## Overview

External (custom) themes in the Krypton Toolkit are represented by **KryptonCustomPaletteBase** instances that can be saved to and loaded from XML files or byte arrays. Previously, these themes had no way to carry a human-readable display name: after load, the only identifier was the file path (when loading from file) or nothing (when loading from stream/bytes), and UI such as KManager could only show a generic label like "Custom".

This feature adds **bundled display names** for external themes:

- **Export:** When a palette has a display name set (`PaletteName`), that name is written into the exported XML (and therefore into any binary export, which is the same XML serialized to bytes).
- **Import:** When loading from XML (file, stream, or byte array), an optional `Name` attribute on the root element is read and applied as the palette’s display name.
- **Display:** When the global theme is Custom and the custom palette has a non-empty name, `ThemeManager.ReturnPaletteModeAsString(KryptonManager)` returns that name so KManager and other UI can show it correctly.

This applies to both **XML** and **binary** (byte-array) formats, because “binary” export is simply the same XML document written to a byte stream.

### Goals

- Allow theme authors to ship a friendly name (e.g. "Corporate Blue", "Dark Mode v2") with their theme file.
- Ensure that name is restored on import and used when displaying the current theme (e.g. in KManager, theme combo boxes, or status text).
- Remain fully backward compatible with existing theme files that do not contain a `Name` attribute.

### Related

- Implements [GitHub Issue #922](https://github.com/Krypton-Suite/Standard-Toolkit/issues/922): *Can external themes have names bundled with them, both with binary & XML, so that they're displayed correctly in KManager.*

---

## Quick reference

| Task | Code |
|------|------|
| Set display name before export | `palette.SetPaletteName("My Theme Name");` |
| Get display name after load | `string name = palette.GetPaletteName();` |
| Get current theme name for UI (including custom) | `string name = ThemeManager.ReturnPaletteModeAsString(kryptonManager);` |
| Export to file (name included if set) | `palette.Export(path, ignoreDefaults);` |
| Export to bytes (name included if set) | `byte[] bytes = palette.Export(ignoreDefaults);` |
| Import from file (name restored from XML if present) | `palette.Import(path, silent);` |
| Import from stream/bytes (name from XML only) | `palette.Import(stream, silent);` or `palette.Import(byteArray, silent);` |

---

## Architecture

### Data flow

1. **Author sets name**  
   `KryptonCustomPaletteBase.SetPaletteName("Display Name")` sets the instance property `PaletteName`.

2. **Export**  
   `ExportToXmlDocument()` (used by all export paths) writes the root element `KryptonPalette` with attributes `Version`, `Generated`, and optionally `Name` (when `PaletteName` is non-empty). File export and byte-array export both use this same XML; bytes are just the UTF-8 (or configured) encoding of that document.

3. **Import**  
   `ImportFromXmlDocument()` parses the root, validates `Version`, then reads the optional `Name` attribute and calls `SetPaletteName(root.GetAttribute("Name"))`. All import entry points (file, stream, byte array) eventually call `ImportFromXmlDocument`, so the name is restored regardless of source.

4. **File import fallback**  
   For `Import(string filename, bool silent)` only, after the document is loaded, if the palette still has no name (`string.IsNullOrWhiteSpace(GetPaletteName())`), the name is set to the file name: `SetPaletteName(Path.GetFileName(ret))`. So older files without `Name` still get a reasonable label when loaded from disk.

5. **Display**  
   Callers that need the “current theme name” (e.g. KManager) use `ThemeManager.ReturnPaletteModeAsString(KryptonManager manager)`. That method checks: if the manager’s mode is `Custom` and `GlobalCustomPalette` is a `KryptonCustomPaletteBase` with a non-empty `GetPaletteName()`, it returns that name; otherwise it returns the string form of the palette mode (e.g. "Custom", "Microsoft365Blue").

### Components involved

| Component | Role |
|----------|------|
| **KryptonCustomPaletteBase** | Holds `PaletteName`; exposes `SetPaletteName` / `GetPaletteName`; reads and writes the `Name` attribute in XML during import/export. |
| **ThemeManager** | `ReturnPaletteModeAsString(KryptonManager)` returns the custom palette’s name when applicable. |
| **KryptonManager** | Holds `GlobalCustomPalette` and `GlobalPaletteMode`; no direct awareness of “display name” (name is resolved via ThemeManager). |

---

## API reference

### KryptonCustomPaletteBase (Krypton.Toolkit)

#### Property

- **`PaletteName`** (string, get only from public API)  
  The display name of the palette. Set via `SetPaletteName`. Written to XML as the root `Name` attribute when non-empty; read from XML on import.

#### Methods

- **`void SetPaletteName(string value)`**  
  Sets the palette display name. Call before export to bundle the name; after import the name is set from XML (or from filename when importing from file and no `Name` is present).

- **`string GetPaletteName()`**  
  Returns the current `PaletteName`. Use after import to get the restored or fallback name.

#### Import overloads (name handling)

- **`string Import(string filename)`**  
  Imports from file. Name is set from root `Name` attribute if present; otherwise from `Path.GetFileName(filename)`.

- **`string Import(string filename, bool silent)`**  
  Same as above; `silent` controls whether success/failure messages are shown.

- **`void Import(Stream stream)`**  
  Imports from stream. Name comes only from the XML `Name` attribute (no filename fallback).

- **`void Import(Stream stream, bool silent)`**  
  Same as above.

- **`void Import(byte[] byteArray)`**  
  Imports from byte array (XML in memory). Name comes only from the XML `Name` attribute.

- **`void Import(byte[] byteArray, bool silent)`**  
  Same as above.

#### Export (name inclusion)

- All export paths use `ExportToXmlDocument()`, which writes `PaletteName` as the root `Name` attribute when non-empty. This applies to:
  - `Export()`, `Export(string filename, ...)`, `Export(Stream stream, ...)`, `Export(bool ignoreDefaults)` (byte array).

### ThemeManager (Krypton.Toolkit)

- **`static string ReturnPaletteModeAsString(KryptonManager manager)`**  
  Returns the theme name to display for the given manager.  
  - If `manager.GlobalPaletteMode == PaletteMode.Custom` and `manager.GlobalCustomPalette` is a `KryptonCustomPaletteBase` with a non-empty `GetPaletteName()`, returns that name.  
  - Otherwise returns the string form of the current palette mode (e.g. "Custom", "Microsoft365Blue").

- **`static string ReturnPaletteModeAsString(PaletteMode paletteMode)`**  
  Returns the standard string for the given mode (e.g. for built-in themes). Used as fallback when no custom name is available.

---

## Persistence format (XML and binary)

### XML structure (root element)

The exported document has a root element `KryptonPalette` with required and optional attributes:

```xml
<KryptonPalette Version="..." Generated="..." Name="...">
  <Properties>...</Properties>
  <Images>...</Images>
</KryptonPalette>
```

| Attribute | Required | Description |
|-----------|----------|-------------|
| **Version** | Yes | Palette format version (integer). Must be ≥ current supported version to import. |
| **Generated** | Yes | Creation timestamp (informational). |
| **Name** | No | Display name of the theme. Omitted when `PaletteName` is null or whitespace. |

- **Name** is written only when `!string.IsNullOrWhiteSpace(PaletteName)` during export.
- **Name** is read in `ImportFromXmlDocument()` with `root.HasAttribute("Name")` and `root.GetAttribute("Name")`; the value is applied via `SetPaletteName(...)`.

### Binary format

“Binary” export is the same XML document serialized to a byte array (e.g. UTF-8). There is no separate binary schema; the `Name` attribute is present or absent in that XML in the same way as in a file. Import from bytes deserializes to XML and then runs the same `ImportFromXmlDocument()` logic, so the name is restored when present.

---

## Import and export behaviour

### Export

- **File:** `Export(string filename, bool ignoreDefaults [, bool silent])`  
  Builds the XML document (including root `Name` when `PaletteName` is set) and writes it to the file.

- **Stream:** `Export(Stream stream, bool ignoreDefaults [, bool silent])`  
  Same XML is written to the stream.

- **Byte array:** `Export(bool ignoreDefaults [, bool silent])`  
  Same XML is written to a `MemoryStream`, then the buffer is returned as `byte[]`.

In all cases, the root `Name` attribute is written only when `PaletteName` is non-empty.

### Import

- **From file:**  
  XML is loaded from the file; `ImportFromXmlDocument()` runs and sets the name from the `Name` attribute if present. Then, in the public `Import(string filename, bool silent)` method, if `GetPaletteName()` is still empty, `SetPaletteName(Path.GetFileName(ret))` is called so legacy files get a filename-based name.

- **From stream or byte array:**  
  XML is loaded from the stream or from a `MemoryStream(byteArray)`; `ImportFromXmlDocument()` runs and sets the name from the `Name` attribute if present. There is no filename, so no fallback; if the XML has no `Name`, the palette name remains whatever it was before (often empty).

### Precedence

- When loading from **file**: bundled `Name` in XML takes precedence; if absent, the filename (without path) is used.
- When loading from **stream/bytes**: only the bundled `Name` in XML is used; there is no other source for the name.

---

## Displaying the current theme name

To show the “current theme” label (e.g. in KManager, a theme selector, or status bar):

```csharp
string displayName = ThemeManager.ReturnPaletteModeAsString(kryptonManager);
// For built-in themes: e.g. "Microsoft365Blue", "SparklePurple".
// For custom theme with bundled name: e.g. "Corporate Blue".
// For custom theme with no name: "Custom".
```

Do **not** rely only on `manager.GlobalPaletteMode` and convert it to string yourself for Custom mode; that would always show "Custom". Use `ThemeManager.ReturnPaletteModeAsString(manager)` so that custom palettes with a set name show that name.

---

## Usage for theme authors

1. **Create or load your palette**  
   Use a `KryptonCustomPaletteBase` (e.g. `KryptonPalette`) and configure colours, fonts, etc.

2. **Set the display name before export**  
   ```csharp
   palette.SetPaletteName("My Company Dark Theme");
   ```

3. **Export to file or bytes**  
   - File: `palette.Export(@"C:\Themes\MyTheme.xml", ignoreDefaults: true);`  
   - Bytes: `byte[] data = palette.Export(ignoreDefaults: true);`  
   The name is stored in the root `Name` attribute.

4. **Distribute the file or embed the bytes**  
   When users (or your app) load this theme, the name "My Company Dark Theme" will be restored and shown wherever the app uses `ThemeManager.ReturnPaletteModeAsString(manager)`.

If you do not set a name before export, the XML will not contain a `Name` attribute. When loaded from file, the loader will fall back to the filename; when loaded from stream/bytes, the palette name will remain empty and UI will show "Custom".

---

## Usage for application developers

### Loading an external theme and applying it

```csharp
// From file
var palette = new KryptonCustomPaletteBase();
palette.Import(themePath, silent: true);
ThemeManager.ApplyTheme(palette, kryptonManager);

// Optional: show the theme name in UI
string name = palette.GetPaletteName();        // e.g. "Corporate Blue"
// or use the global “current theme” name:
string currentName = ThemeManager.ReturnPaletteModeAsString(kryptonManager);
```

### Loading from bytes (e.g. embedded resource or network)

```csharp
byte[] themeBytes = ...; // from resource, API, etc.
var palette = new KryptonCustomPaletteBase();
palette.Import(themeBytes, silent: true);
ThemeManager.ApplyTheme(palette, kryptonManager);
// Display name is whatever was bundled in the XML (no filename fallback).
string name = ThemeManager.ReturnPaletteModeAsString(kryptonManager);
```

### Showing the current theme in a list or status bar

Always use ThemeManager for the display string so custom themes show their name:

```csharp
labelCurrentTheme.Text = ThemeManager.ReturnPaletteModeAsString(kryptonManager);
```

---

## Backward compatibility

- **Existing theme files** that do not have a root `Name` attribute continue to load. When loaded from file, the name is set to the file name (without path) so UI still gets a reasonable label.
- **Existing theme files** that already have a root `Name` attribute (e.g. hand-edited or from a future version) will have that name applied on import.
- **Stream and byte-array import** do not change behaviour for old payloads: if there is no `Name`, the palette name is simply not set from the import (and may remain empty).
- **Export** only adds the `Name` attribute when the palette has a non-empty name; existing code that does not set `PaletteName` produces XML identical to before (no `Name` attribute).
- **ThemeManager.ReturnPaletteModeAsString(manager)** falls back to the previous behaviour when the custom palette has no name: it returns the string form of the mode ("Custom").

No breaking API or file-format changes were introduced.

---

## Implementation details

### Where the name is stored (XML)

- **Export:** In `KryptonCustomPaletteBase.ExportToXmlDocument()`, after creating the root element and setting `Version` and `Generated`, the code checks `!string.IsNullOrWhiteSpace(PaletteName)` and, if true, calls `root.SetAttribute("Name", PaletteName)`.

- **Import:** In `ImportFromXmlDocument()`, after validating the root element and version, the code checks `root.HasAttribute("Name")` and, if true, calls `SetPaletteName(root.GetAttribute("Name"))`. This runs before the rest of the palette tree is imported, so the name is available for the rest of the load and for any UI that reads it immediately after import.

### File import fallback

In `Import(string filename, bool silent)`, after `ImportFromFile` (which calls `ImportFromXmlDocument`) returns, the code sets the file path and then:

```csharp
if (string.IsNullOrWhiteSpace(GetPaletteName()))
{
    SetPaletteName(Path.GetFileName(ret));
}
```

So the bundled name always wins when present; the filename is used only as a fallback for older or name-less files.

### ThemeManager logic

`ReturnPaletteModeAsString(KryptonManager manager)`:

1. If `manager.GlobalPaletteMode != PaletteMode.Custom`, or `manager.GlobalCustomPalette` is not a `KryptonCustomPaletteBase`, or `GetPaletteName()` is null or whitespace, the method returns `ReturnPaletteModeAsString(manager.GlobalPaletteMode)` (the standard mode string, e.g. "Custom").
2. Otherwise it returns `customPalette.GetPaletteName()`.

So any UI that uses this method will show the bundled name for custom palettes when available.

---

## Edge cases and behaviour

| Scenario | Result |
|----------|--------|
| Export with `PaletteName == null` or whitespace | No `Name` attribute written. |
| Export with `PaletteName == " "` | Treated as whitespace; no `Name` attribute (consistent with `string.IsNullOrWhiteSpace`). |
| Import XML with no `Name` from file | Name set to filename (without path). |
| Import XML with no `Name` from stream/bytes | Palette name unchanged (often empty). |
| Import XML with empty `Name=""` | `SetPaletteName("")` is called; name is empty. |
| Import XML with `Name="My Theme"` | `SetPaletteName("My Theme")` is called. |
| Custom palette applied but `GetPaletteName()` empty | `ReturnPaletteModeAsString(manager)` returns "Custom". |
| Manager in Custom mode but `GlobalCustomPalette` is null | Treated as no custom palette; returns "Custom" from mode. |

---

## Testing and verification

1. **Export with name**  
   Set `SetPaletteName("Test Theme")`, export to a file, open the file and confirm the root element has `Name="Test Theme"`.

2. **Import from file (with Name)**  
   Import the file from step 1; confirm `GetPaletteName()` returns `"Test Theme"`.

3. **Import from file (without Name)**  
   Use an older XML file (no `Name` attribute) or remove the attribute; import from file and confirm the name is the filename (e.g. `MyTheme.xml` → "MyTheme.xml").

4. **Import from stream/bytes**  
   Import the same XML via `Import(stream)` or `Import(byteArray)`; confirm the name is restored when `Name` is present, and unchanged/empty when absent.

5. **Display in UI**  
   Apply the custom palette to a `KryptonManager`, then call `ThemeManager.ReturnPaletteModeAsString(manager)` and confirm the returned string is the bundled name (e.g. "Test Theme") rather than "Custom".

6. **Backward compatibility**  
   Load an old theme file (no `Name`); ensure it still loads and that file-based import still assigns the filename as the name.

---

## Related types and components

- **KryptonManager** — Holds `GlobalPaletteMode` and `GlobalCustomPalette`. Does not expose the display name directly; use `ThemeManager.ReturnPaletteModeAsString(manager)`.
- **PaletteBase / ThemeName** — Built-in palettes use `ThemeName` (e.g. "PaletteOffice2013White"). Custom palettes use `PaletteName` for the bundled display name; `KryptonCustomPaletteBase` delegates `ThemeName` to the base palette and does not persist it in the custom palette XML.
- **CommonHelperThemeSelectors** — Theme selector controls use theme names; when the selected item is Custom, they rely on the manager’s custom palette. Display of the current theme in those controls should use `ThemeManager.ReturnPaletteModeAsString(manager)` so the bundled name appears when set.
- **KryptonThemeComboBox, KryptonThemeListBox, KryptonRibbonGroupThemeComboBox** — List built-in theme names and optionally Custom; for the “current” label when Custom is selected, use the return value of `ReturnPaletteModeAsString(manager)`.

---

## Troubleshooting

**Theme still shows "Custom" after loading a file that has a name.**  
- Ensure the XML root has a `Name` attribute (e.g. `<KryptonPalette Version="..." Name="My Theme">`).  
- Ensure you are using `ThemeManager.ReturnPaletteModeAsString(kryptonManager)` for the display string, not a hard-coded "Custom" or only the mode enum.

**Name is the full file path instead of a friendly name.**  
- You are loading from file and the file does not contain a `Name` attribute (e.g. old format). Set the name before export with `SetPaletteName("...")` and re-export, or set it after load with `SetPaletteName("...")` if you do not control the file.

**After loading from stream/bytes, GetPaletteName() is empty.**  
- Stream and byte-array import do not have a filename fallback. The XML must include a root `Name` attribute for the palette to get a name. Re-export the theme with `SetPaletteName("...")` called before export so the attribute is written.

**Export does not write a Name attribute.**  
- Only a non-empty `PaletteName` is written. Call `SetPaletteName("Your Name")` before calling `Export(...)`.

**Old theme files fail to load.**  
- The feature does not change version requirements or required elements. Ensure the file has the required `KryptonPalette` root with `Version` and the `Properties` and `Images` elements. The `Name` attribute is optional and can be added or omitted without affecting load.
