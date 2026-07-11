# KryptonCodeEditor

## Overview

`KryptonCodeEditor` is a native WinForms code editor with syntax highlighting, line numbers, code folding, and Krypton palette integration.

**Namespace:** `Krypton.Toolkit.Utilities`  
**Assembly:** `Krypton.Toolkit.Utilities`

## Key features

- Syntax highlighting for common languages
- Line number gutter and current-line highlighting
- Code folding regions
- Krypton-themed colours via active palette
- Designer toolbox support

## Usage

```csharp
using Krypton.Toolkit.Utilities;

var editor = new KryptonCodeEditor
{
    Dock = DockStyle.Fill,
    Text = "// Your code here",
    Font = new Font("Cascadia Code", 10f)
};
```

Configure `Language` (syntax highlighting) via the property grid or code:

```csharp
editor.Language = Language.CSharp;
```

## See also

- [Krypton Toolkit Utilities index](KryptonToolkitUtilitiesIndex.md)
