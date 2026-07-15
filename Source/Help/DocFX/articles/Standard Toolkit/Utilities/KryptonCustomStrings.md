# KryptonCustomStrings

## Overview

`KryptonCustomStrings` and `KryptonCustomStringsManager` let applications define and localize their own strings independently of the built-in `KryptonManager.Strings` categories. Use this API for application-specific labels, messages, and strongly-typed string sets that should participate in the same designer and reset patterns as toolkit strings.

Implements [GitHub Issue #3757](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3757).

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities` (included in the `Krypton.Standard.Toolkit` NuGet package)

| Type | Role |
| --- | --- |
| `KryptonCustomStrings` | Static API for key/value strings and registered string sets |
| `KryptonCustomStringsManager` | Non-visual component for designer access to `CustomStrings` |
| `KryptonCustomStringValues` | Expandable key/value collection (`CustomStrings` property) |

Built-in toolkit strings remain on **`KryptonManager.Strings`** — see [Localization Guide](LocalizationGuide.md) and [KryptonManager.Strings API Reference](../Toolkit/Components/KryptonManagerStringsAPIReference.md).

## Key/value custom strings

### Static API

```csharp
using Krypton.Toolkit.Utilities;

// Set and read by key
KryptonCustomStrings.Set("SaveDraft", "S&ave Draft");
string label = KryptonCustomStrings.Get("SaveDraft", defaultValue: "Save Draft");

// Reset all key/value entries to defaults
KryptonCustomStrings.ResetValues();
```

`KryptonCustomStrings.Values` exposes the underlying `KryptonCustomStringValues` collection for designer serialization and bulk edits.

### Designer workflow

1. Drop a **`KryptonCustomStringsManager`** on the form or add it to the component tray.
2. Expand **CustomStrings** in the property grid.
3. Add keys and localized values; changes persist through the manager component.

## Strongly-typed string sets

Register application string classes that inherit `GlobalId` (same pattern as toolkit string categories):

```csharp
public class DemoAppStrings : GlobalId
{
    public string SaveDraft { get; set; } = "S&ave Draft";
    public string DiscardChanges { get; set; } = "&Discard Changes";

    public override bool IsDefault => /* compare to defaults */;
    public void Reset() { /* restore defaults */ }
}

// Registration (typically at startup)
var appStrings = new DemoAppStrings();
KryptonCustomStrings.RegisterStringSet("DemoApp", appStrings);

// Retrieval
DemoAppStrings? strings = KryptonCustomStrings.GetStringSet<DemoAppStrings>("DemoApp");
kbtnSave.Text = strings?.SaveDraft ?? "Save";
```

### Registry API

| Method | Description |
| --- | --- |
| `RegisterStringSet(name, stringSet)` | Register or replace a named set |
| `GetStringSet<T>(name)` | Get a registered set by name and type |
| `TryGetStringSet(name, out stringSet)` | Non-throwing lookup |
| `ContainsStringSet(name)` | Returns whether the name is registered |
| `UnregisterStringSet(name)` | Remove a registration |
| `ResetStringSets()` | Call `Reset()` on every registered set |

## Relationship to KryptonManager.Strings

| API | Purpose |
| --- | --- |
| `KryptonManager.Strings` | Built-in toolkit UI strings (OK, Cancel, ribbon labels, etc.) |
| `KryptonManager.Strings.CustomStrings` | Small fixed set of toolkit custom action strings |
| `KryptonCustomStrings` | **Application-owned** keys and typed sets in `Krypton.Toolkit.Utilities` |

Do not confuse `KryptonManager.Strings.CustomStrings` with `KryptonCustomStrings` — they serve different scopes.

## Localization

- Mark string properties with `[Localizable(true)]` on your typed string classes where appropriate.
- Use `.resx` satellite assemblies or your preferred localization pipeline to assign values before or after `RegisterStringSet`.
- Call `ResetValues()` / `ResetStringSets()` to restore defaults when switching languages.

## Example

See `TestForm/ApplicationStringsTest.cs` for key/value and typed-set demos wired to buttons and text boxes.

## See also

- [Localization index](LocalizationIndex.md)
- [Localization Guide](LocalizationGuide.md)
- [KryptonManager.Strings API Reference](../Toolkit/Components/KryptonManagerStringsAPIReference.md)
- [KryptonManager](../Toolkit/Components/KryptonManager.md)
