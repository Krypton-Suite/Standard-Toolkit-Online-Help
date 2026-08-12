# Workspace Page.Tag Persistence (TypeConverter)

## Overview

When a `KryptonWorkspace` saves and loads layout XML, each `KryptonPage` can carry a `Tag` (`object?`). Issue [#3959](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3959) replaced lossy `Tag.ToString()` persistence with TypeConverter-based round-tripping for convertible values. Arbitrary object graphs are intentionally not auto-serialized.

Owned by:

- `Krypton.Toolkit` — `XmlHelper.ObjectToXmlAttributes` / `XmlHelper.XmlAttributesToObject`
- `Krypton.Workspace` — `KryptonWorkspace.WritePageElement` / `ReadPageElement`

## Attribute format

| Attribute | Meaning |
|-----------|---------|
| `TAG` | Invariant string form of the tag value |
| `TAGT` | Type identity as `FullName, AssemblyName` (no version/culture/publicKeyToken) |

Rules when writing:

- `null` — omit both attributes
- `string` — write `TAG` only (legacy-compatible)
- other types — write `TAG` + `TAGT` only when `TypeDescriptor.GetConverter(type)` can convert **to and from** `string` via invariant conversion
- non-convertible — omit attributes (do not write `ToString()`)

Rules when reading:

- `TAG` absent — do **not** overwrite the existing page `Tag` (preserves tags on pages matched from `existingPages`)
- `TAG` present, `TAGT` absent — assign the string (legacy layout files)
- both present — resolve the type and `ConvertFromInvariantString`; on failure fall back to the string value

Type resolution tries `Type.GetType`, then the name before the comma (helps BCL types across `mscorlib` / `System.Private.CoreLib`), then loaded assemblies in the current `AppDomain`.

## Architecture

```text
KryptonWorkspaceCell.SaveToXml
  -> WritePageElement  (attributes including TAG/TAGT)
  -> OnPageSaving      (custom data inside CPD)

KryptonWorkspaceCell.LoadFromXml
  -> ReadPageElement   (attributes including TAG/TAGT)
  -> OnPageLoading     (custom data inside CPD)
```

Docking `KryptonSpace` overrides `WritePageElement` / `ReadPageElement` and does **not** persist `Tag`; docking apps that need page metadata should use `KryptonDockingManager.PageSaving` / `PageLoading`.

## Usage

### Convertible tags (automatic)

```csharp
page.Tag = "document-id";
page.Tag = 42;           // Int32Converter
page.Tag = true;         // BooleanConverter

workspace.SaveLayoutToFile("layout.xml");
workspace.LoadLayoutFromFile("layout.xml");
```

### Non-convertible tags (events)

```csharp
workspace.PageSaving += (s, e) =>
{
    if (e.Page.Tag is MyPayload payload)
    {
        e.XmlWriter.WriteStartElement("MyPayload");
        e.XmlWriter.WriteAttributeString("Id", payload.Id);
        e.XmlWriter.WriteEndElement();
    }
};

workspace.PageLoading += (s, e) =>
{
    // Read custom elements from e.XmlReader while positioned on CPD
};
```

## Edge cases

- Empty convertible strings are not written (`TextToXmlAttribute` skips empty values).
- Custom types must be loadable in the process (already referenced/loaded) for `TAGT` resolution.
- Do not store live UI references in `Tag` expecting them to survive save/load.
- Legacy files with only `TAG` continue to load as `string`.

## Validation

TestForm demo: **Feature 3959 Workspace Page.Tag** (`Feature3959WorkspacePageTagPersistDemo`), registered in `StartScreen.AddButtons()`.

Manual steps:

1. Open the demo; confirm string, int, and custom tags.
2. Leave **Use PageSaving/PageLoading** checked → Save Layout → Clear Tags → Load Layout → string/int/`DemoTagPayload` restored; saved XML contains `TAGT` and `CustomTag`.
3. Uncheck the option → Reset Tags → Save → Clear → Load → string/int restored; custom tag remains null; XML has no `CustomTag`.
