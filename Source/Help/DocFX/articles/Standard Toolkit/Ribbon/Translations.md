# KryptonRibbon translations (`RibbonTranslations.xml`)

## Overview

Issue [#4369](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4369) adds an **instance overlay** of every localizable caption on a given `KryptonRibbon` (tabs, groups, buttons, KeyTips, tooltips, QAT, contexts, app menu, recent docs, backstage, notification bar). Consumers persist the document as `RibbonTranslations.xml` / `.json`, or as a database BLOB via the stream APIs.

This is **not** a replacement for [#4088](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4088) `ToolkitTranslations.xml`. Process-wide QAT / app-menu chrome still lives on `KryptonManager.Strings.RibbonStrings` (`GeneralRibbonStrings`). Optional `<RibbonStrings>` inside a ribbon file can round-trip that chrome, but the default export omits it.

Import never creates or deletes tabs, groups, or items. Unknown XML keys are ignored. Missing keys keep the live values.

Package: `Krypton.Ribbon`. Schema: `Documents/Assets/RibbonTranslations.xsd`.

## Architecture

- `RibbonTranslationWalker` (inside `RibbonTranslationsXmlPersistence`) walks `RibbonTabs` → groups → `GetChildComponents()`, plus QAT, contexts, button specs, app menu, recent docs, notification bar, and backstage.
- Property-driven export: public instance `string` properties marked `[Localizable(true)]`, minus a denylist (images, colors, `Keys`, editor **content**, `ContextName`, `SelectedContext`).
- Match order on import: `TranslationId` → `UniqueName` / `ContextName` / `Site.Name` → `Type` + `Index`.
- JSON is a twin of the XML tree (`RibbonTranslationsJsonPersistence`); identity fields are XML attributes on import.

```
RibbonTranslations.xml / stream / JSON
        │
        ▼
KryptonRibbon Import / Export / Analyze / Auto Discover
        │
        ▼
RibbonTranslationsXmlPersistence  (walker + overlay)
        │
        ▼
Tabs / Groups / Items / QAT / Contexts / App menu / …
        │
        ▼
IComponentChangeService  (designer only)
```

## XML shape

Root element is `KryptonRibbonTranslations` (distinct from `KryptonTranslations` so files cannot be mixed up). `Version="1"` is structural only; older and newer files load best-effort.

```xml
<KryptonRibbonTranslations Version="1" Culture="de-DE" ToolkitVersion="110.0.0.0" RibbonName="kryptonRibbon1">
  <RibbonStrings>
    <AppButtonText Value="Datei" />
  </RibbonStrings>
  <Ribbon>
    <FloatingWindowText Value="Menüband" />
    <FileAppTab>
      <FileAppTabText Value="Datei" />
    </FileAppTab>
    <Tabs>
      <Tab TranslationId="home" Name="kryptonRibbonTab1" Type="KryptonRibbonTab" Index="0">
        <Text Value="Start" />
        <KeyTip Value="S" />
        <Groups>
          <Group TranslationId="clipboard" Index="0">
            <TextLine1 Value="Zwischenablage" />
            <Items>
              <Item TranslationId="paste" Type="KryptonRibbonGroupButton" Index="0">
                <TextLine1 Value="Einfügen" />
                <KeyTip Value="V" />
              </Item>
            </Items>
          </Group>
        </Groups>
      </Tab>
    </Tabs>
  </Ribbon>
</KryptonRibbonTranslations>
```

Loose XSD uses `xs:any processContents="lax"` at each container so new item types and new `[Localizable]` strings appear via reflection.

## Identity (`TranslationId`)

Ribbon items historically had no stable runtime name (only `Site.Name` at design time, `ButtonSpec.UniqueName`, `ContextName`). Additive optional property:

```csharp
[DefaultValue("")]
[Localizable(false)]
public string TranslationId { get; set; }
```

Present on `KryptonRibbon`, `KryptonRibbonTab`, `KryptonRibbonGroup`, `KryptonRibbonGroupItem` (containers and leaves), `KryptonRibbonQATButton`, and `KryptonRibbonRecentDoc`. Empty is not serialized. Implement `IRibbonTranslationIdentity` when adding a new sited ribbon part.

Prefer `TranslationId` for runtime-built ribbons and database round-trips. Designer-sited components still match on `Site.Name` when `TranslationId` is empty.

Root attribute `RibbonName` is `TranslationId` if set, otherwise `Control.Name`. Auto Discovery **skips** a shared file whose `RibbonName` is set and does not match this ribbon. Manual import still overlays (with a debug warning).

## Public API (`KryptonRibbon`)

### Export / import

- `ExportTranslationsToXmlDocument` / `ToXmlFile` / `ToStream`
- `ImportTranslationsFromXmlDocument` / `FromXmlFile` / `FromStream`
- JSON equivalents (`ExportTranslationsToJson`, `ToJsonFile`, `ToJsonStream`, `ImportTranslationsFromJson` / `FromJsonFile` / `FromJsonStream`)
- `AnalyzeTranslationsFromFile` — unmatched XML keys vs live tree (coverage, not a hard fail)
- `MergeMissingTranslationsToFile` — rewrite the file with newly added keys filled from current values

Database apps should turn Auto Discovery off and use the stream overloads.

### Options (`RibbonTranslationOptions`)

| Property | Default | Meaning |
|----------|---------|---------|
| `IncludeDefaults` | `false` | Emit strings even when they match designer defaults (use for templates). |
| `IncludeChrome` | `false` | Include process-wide `KryptonManager.Strings.RibbonStrings`. |
| `IncludeToolTips` | `true` | Tooltip heading/description/title/body. |
| `IncludeKeyTips` | `true` | KeyTip strings. |
| `IncludeContentStrings` | `false` | Editor content (`TextBox.Text`, combo items, mask, …). |
| `ResetFirst` | `true` | Reset exportable strings on **existing** nodes before applying the file. Does not rebuild the tree. |
| `ChangeService` | `null` | Designer `IComponentChangeService` so CodeDom serializes imported values. |

When a group button has a `KryptonCommand`, `TextLine*` is applied to the **command** as well, because that is what the UI displays.

### Events

- `RibbonTranslationsSaving` / `RibbonTranslationsLoading` — extra XML on the root.
- `RibbonTranslationsImported` — after file, stream, or Auto Discovery import.
- `RibbonTranslationsCoverageReported` — after analyze.

## What is in vs out

**In (default):** `FloatingWindowText`; `RibbonFileAppTab.FileAppTabText`; app-button tooltips, menu items, recent docs, app button specs; tab `Text` / `KeyTip`; group `TextLine1` / `TextLine2` / `KeyTipGroup` / `KeyTipDialogLauncher`; leaf `TextLine*` / `KeyTip` / tooltip heading and description; QAT `Text` / `ToolTipTitle` / `ToolTipBody`; context `ContextTitle` only; `ButtonSpec` `Text` / `ExtraText` / tooltips; gallery range `Heading`; notification bar title/text/action buttons; backstage page/command `Text`.

**Out by default:** images, colors, `Keys`, editor content, `ContextName`, `SelectedContext`. Opt in with `IncludeContentStrings` if a consumer really wants editor `Text`.

## Auto Discovery

Defaults **on** (`KryptonRibbon.AutoDiscoverTranslations` static, `EnableAutoDiscoverTranslations` per instance). First `HandleCreated` (skipped in `DesignMode`) probes:

1. Culture ladder: exact → parent/neutral → default (no culture suffix).
2. Format: XML before JSON.
3. File stem: per-ribbon `RibbonTranslations.{ribbonKey}.{culture}` then shared `RibbonTranslations.{culture}`.
4. Directories: `TranslationsSearchPath` or application base directory, then a nested `RibbonTranslations\` subdirectory.

Example for ribbon key `kryptonRibbon1` and UI culture `de-DE`:

- `RibbonTranslations.kryptonRibbon1.de-DE.xml`
- `RibbonTranslations.kryptonRibbon1.de.xml`
- `RibbonTranslations.kryptonRibbon1.xml`
- `RibbonTranslations.de-DE.xml` … `RibbonTranslations.xml`
- then the same stems as `.json`, then the same list under `RibbonTranslations\`.

On miss, **instance captions are not wiped**. `TrySwitchTranslationsCulture` changes `CurrentUICulture` and re-probes with the same rule.

Live ribbons subscribe (weakly) to `KryptonManager.TranslationsImported` so a chrome `ToolkitTranslations.xml` import can re-probe ribbon files. Re-entry during import is ignored.

Database / embedded apps: set `KryptonRibbon.AutoDiscoverTranslations = false` **before** constructing ribbons, or set `EnableAutoDiscoverTranslations = false` on each instance, then call `ImportTranslationsFromStream`.

## Designer

`KryptonRibbon` Smart Tag (`KryptonRibbonActionList`) verbs:

- Import / Export XML and JSON
- Generate template (`IncludeDefaults = true`)
- Merge missing keys
- Switch culture

Import wraps `IDesignerHost.CreateTransaction` and passes `IComponentChangeService` so the property grid and CodeDom pick up nested captions. Then `PerformNeedPaint(true)` refreshes the design surface.

Do **not** re-add a serializable `RibbonStrings` property on `KryptonRibbon`. Chrome stays on `KryptonManager`.

## Usage

```csharp
ribbon.TranslationId = "main";
ribbon.RibbonTabs[0].TranslationId = "home";

// File
ribbon.ExportTranslationsToXmlFile(@"RibbonTranslations.de.xml",
    new RibbonTranslationOptions { IncludeDefaults = true });
ribbon.ImportTranslationsFromXmlFile(@"RibbonTranslations.de.xml");

// Database BLOB
using (var stream = GetBlobStream())
{
    ribbon.ImportTranslationsFromStream(stream);
}

// Coverage
var coverage = ribbon.AnalyzeTranslationsFromFile(@"RibbonTranslations.de.xml");
```
