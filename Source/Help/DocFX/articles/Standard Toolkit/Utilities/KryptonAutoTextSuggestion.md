# KryptonAutoTextSuggestion

## Overview

`KryptonAutoTextSuggestion` is a non-visual `Component` that attaches to Krypton text controls and shows a themed suggestion popup as the user types.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`

## Key properties

| Property | Description |
| --- | --- |
| `AttachedControl` | Text control to monitor (`KryptonTextBox`, etc.) |
| `Suggestions` | List of `KryptonAutoTextSuggestItem` entries |
| `MinCharsToShow` | Minimum typed characters before popup (default 1) |
| `ShowDelay` | Delay before showing suggestions (ms) |
| `MatchMode` | `StartsWith`, `Contains`, etc. |

## Usage

```csharp
using Krypton.Toolkit.Utilities;

var suggestions = new KryptonAutoTextSuggestion(components)
{
    AttachedControl = kryptonTextBox1,
    MinCharsToShow = 2,
    ShowDelay = 300
};
suggestions.Suggestions.Add(new KryptonAutoTextSuggestItem("Contoso Ltd."));
```

## See also

- [KryptonTextBox](../Toolkit/Controls/KryptonTextBox.md)
- [KryptonSearchBox](../Toolkit/Controls/KryptonSearchBox.md) — built-in search suggestions
