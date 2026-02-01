# Developer Guide: License Header via EditorConfig

This document describes how the Krypton Standard Toolkit project configures and applies the BSD 3-Clause license header to C# source files using EditorConfig and Visual Studio’s built-in file header support. It is intended for contributors and maintainers who add or edit source files and need to ensure consistent license headers.

---

## 1. Overview

- **What:** A single, repository-wide license header template is defined in EditorConfig. IDEs (notably Visual Studio) use this template when you add or fix file headers so that every `.cs` file can have the same BSD license block at the top.
- **Where:** The template is set in `Source/.editorconfig` under the `[*.cs]` section via the `file_header_template` property.
- **Why:** Keeping the header in one place (EditorConfig) avoids duplicating the exact text across many files or tools and aligns with the project’s use of EditorConfig for code style (see `Source/.editorconfig` and `AGENTS.md`).

The header text matches the **New BSD 3-Clause License** notice used by this project (see repository `LICENSE` and `Documents/License/License.md`).

---

## 2. Where It Is Configured

| Item | Location |
|------|----------|
| EditorConfig file | `Source/.editorconfig` |
| Section | `[*.cs]` |
| Property | `file_header_template` |

The solution links this file (e.g. in `Krypton Toolkit Suite 2022 - VS2022.sln` / `.slnx`), so all C# projects under `Source/Krypton Components` inherit the setting.

---

## 3. Canonical License Header Text

When rendered in a C# file, the header should look exactly like this (including blank lines and spacing):

```csharp
#region BSD License
/*
 *
 *  New BSD 3-Clause License (https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/LICENSE)
 *  Modifications by Peter Wagner(aka Wagnerp), Simon Coghlan(aka Smurf-IV), Giduac, tobitege, Lesandro, KamaniAR, et al. 2026 - 2026. All rights reserved.
 *
 */
#endregion
```

- **One blank line** after `#region BSD License` and after `/*`.
- **One blank line** before `*/` and before `#endregion`.
- **Two spaces** before “New BSD”, “Modifications”, and “All rights reserved.”
- The **year range** (e.g. `2025 - 2026`) must be updated manually when the calendar year changes (see [Section 7](#7-maintaining-the-year-range)).

The `file_header_template` value in `.editorconfig` encodes this as a **single line** with newlines represented as `\n` (see [Section 5](#5-editorconfig-format)).

---

## 4. How to Apply the Header

### 4.1 Single file (Visual Studio)

1. Open the `.cs` file.
2. Place the caret on the **first line** of the file (or where the header should be inserted).
3. Press **Ctrl+.** (Quick Actions and Refactorings).
4. Choose **“Add file header”** (or “Add banner” depending on VS version).
5. The IDE inserts the header from `file_header_template` at the top of the file.

If a header already exists but does not match the template, the same light bulb / Quick Actions may offer to **fix the file header** so it matches.

### 4.2 Project or solution (Visual Studio)

1. Use **“Add file header”** (or fix file header) as above on any file that triggers the suggestion.
2. In the **“Fix all occurrences in:”** list, select **Project** or **Solution**.
3. In the **“Fix all occurrences”** preview dialog, review the changes.
4. Click **Apply** to add or update headers across the selected scope.

Use **Project** to limit changes to one project; use **Solution** to update all C# files in the solution that are missing or mismatched headers.

### 4.3 Other editors

- EditorConfig is a standard format; support for `file_header_template` is **IDE-dependent**. Visual Studio and VS-based products use it for “Add file header” and file header fixes.
- Other editors (e.g. VS Code, Rider) may or may not honor `file_header_template`; refer to their documentation. If they do not, maintain the header manually using the canonical text in [Section 3](#3-canonical-license-header-text).

---

## 5. EditorConfig Format

- The property must live under a section that matches C# files, e.g. `[*.cs]`.
- EditorConfig values cannot contain real newlines. All line breaks in the header are encoded as the two-character escape **`\n`** (backslash + letter n).
- The value is a single line; the IDE interprets `\n` and inserts actual newlines when applying the header.

Example (conceptually; the real line in `Source/.editorconfig` is one long line):

```ini
[*.cs]
file_header_template = #region BSD License\n/*\n *\n *  New BSD 3-Clause License (...)\n *  Modifications by ...\n *\n */\n#endregion
```

- To **change the header text**, edit `Source/.editorconfig`, update the `file_header_template` value, and keep newlines as `\n`. After saving, re-apply “Add file header” or “Fix all” where needed.

---

## 6. Supported Placeholders

- **`{fileName}`** — Replaced with the current file name (e.g. `MyClass.cs`). The project’s template does not use it, so the same text is used for every file.
- **Year / date placeholders** — **Not supported.** The .NET/EditorConfig file header support does not define placeholders such as `{currentYear}` or `{yearRange}`. A feature request exists ([dotnet/roslyn#44329](https://github.com/dotnet/roslyn/issues/44329)) but is not implemented. Therefore the year range in the header is **fixed text** and must be updated manually (see [Section 7](#7-maintaining-the-year-range)).

---

## 7. Maintaining the Year Range

The canonical header includes a year range (e.g. **2025 - 2026**). Because there is no year placeholder:

1. **When the calendar year changes** (e.g. from 2026 to 2027), a maintainer should update the year range in **one place**: the `file_header_template` value in `Source/.editorconfig`.
2. Update the range to reflect your policy (e.g. “2026 - 2027” for a range, or “2027 - 2027” for a single year).
3. A short comment in `.editorconfig` next to `file_header_template` reminds maintainers to update the year when needed.
4. Optionally, run “Fix all in Solution” for the file header to refresh existing files; otherwise new files and manual “Add file header” uses will get the new range.

---

## 8. Relationship to `.licenseheader` Files

Some projects under `Source/Krypton Components` still contain **`.licenseheader`** files (e.g. `Krypton.Toolkit.licenseheader`, `Krypton.Docking.licenseheader`). Those are used by **third-party extensions** (e.g. “License Header Manager” or similar) that run inside Visual Studio or the build.

- **EditorConfig** (`file_header_template`) is the **primary**, repository-defined source for the license text and is used by Visual Studio’s built-in “Add file header” and file header fix.
- If you use an extension that reads `.licenseheader` files, keep the text in those files **in sync** with the canonical header in this document and with `file_header_template` (including the year range) to avoid conflicting headers.
- New development can rely solely on EditorConfig and “Add file header”; the `.licenseheader` files can be phased out or kept for teams that depend on that tooling.

---

## 9. Build-Time and Analyzer (IDE0073)

- **IDE0073** (“Require file header”) is a .NET analyzer rule that can warn when a file’s header does not match the configured template. The project does **not** currently enable IDE0073 as an error in `Source/.editorconfig`; file headers are applied and maintained via EditorConfig and IDE actions rather than enforced at build time.
- If you want to **enforce** the header at build time, you can add under `[*.cs]` something like:
  - `dotnet_diagnostic.IDE0073.severity = warning`
  - or `= error`
  and ensure `file_header_template` is set as desired. Be aware: because the year is not a placeholder, any change to the year in the template may require re-running “Fix all” so existing files match and the build stays clean.

---

## 10. Troubleshooting

| Issue | What to check |
|-------|----------------|
| “Add file header” doesn’t appear | Caret must be near the top of the file (e.g. first line). Try **Ctrl+.** and look for “Add file header” or “Add banner”. |
| Header doesn’t match project standard | Ensure `Source/.editorconfig` is linked from the solution and that the `[*.cs]` section contains the correct `file_header_template` (including `\n` for newlines). |
| Wrong or old year in header | Update the year range in `file_header_template` in `Source/.editorconfig`, then use “Fix file header” / “Fix all in Solution” to refresh files, or add the header manually with the correct text. |
| Different header in one project | EditorConfig is inherited from `Source/.editorconfig`. If a project has its own `.editorconfig`, a nested `[*.cs]` section could override `file_header_template`; adjust or remove the override. |

---

## 11. References

- [Add file header (Visual Studio)](https://learn.microsoft.com/en-us/visualstudio/ide/reference/add-file-header)
- [EditorConfig](https://editorconfig.org/) and [Create portable custom editor options (Visual Studio)](https://learn.microsoft.com/en-us/visualstudio/ide/create-portable-custom-editor-options)
- [IDE0073: Require file header](https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/style-rules/ide0073)
- Roslyn feature request for a year placeholder: [dotnet/roslyn#44329](https://github.com/dotnet/roslyn/issues/44329)
- Repository: `Source/.editorconfig`, `AGENTS.md`, `Documents/License/License.md`, root `LICENSE`
