# Visual Studio Templates

## Purpose

This document describes how Krypton Visual Studio templates are implemented, packaged, and released in this repository.

It is intended for maintainers who need to:

- modify existing templates,
- add new templates,
- troubleshoot installation or release issues, and
- evolve the templates release workflow.

## Scope

This guide covers templates under `Templates/` and the automation in `.github/workflows/templates-release.yml`.

It does not describe NuGet package publishing (`release.yml`, `canary.yml`, `nightly.yml`) except where branch/channel alignment matters.

## Feature Context

Issue context: [#908](https://github.com/Krypton-Suite/Standard-Toolkit/issues/908).

The goal is to enable developers to create Krypton-first forms/projects directly from Visual Studio:

- `Add > New Item` (item templates)
- `Create a new project` (project templates)

## Directory Layout

Templates are intentionally isolated at repository root:

- `Templates/ItemTemplates/KryptonForm`
- `Templates/ItemTemplates/KryptonRibbonForm`
- `Templates/ProjectTemplates/KryptonWinFormsApp`
- `Templates/ProjectTemplates/KryptonRibbonWinFormsApp`

Supporting files:

- `Templates/README.md` (consumer install notes)
- `.github/workflows/templates-release.yml` (zip + release automation)

## Current Template Inventory

### Item Templates

1. `KryptonForm`
   - Generates a standard `KryptonForm` partial class with Designer file.
2. `KryptonRibbonForm`
   - Generates a `KryptonForm` plus a pre-added `KryptonRibbon` control.
   - Note: this is a template label, not a framework class named `KryptonRibbonForm`.

### Project Templates

1. `KryptonWinFormsApp`
   - New WinForms app with `MainForm : KryptonForm`.
2. `KryptonRibbonWinFormsApp`
   - New WinForms app with `MainForm : KryptonForm` and `KryptonRibbon`.

## Template Anatomy

Each template folder contains:

- one `.vstemplate` descriptor
- one or more source files copied into the target project

### `.vstemplate` responsibilities

The descriptor controls:

- template display metadata (`Name`, `Description`, `SortOrder`)
- template type (`Item` or `Project`)
- target language (`ProjectType = CSharp`)
- default filename/project name
- parameter replacement behavior (`ReplaceParameters="true"`)

### Source file responsibilities

Template source files include tokenized values, for example:

- `$rootnamespace$` for item template namespaces
- `$safeitemrootname$` for item class/file names
- `$safeprojectname$` for project namespace and project file naming

Visual Studio resolves these values when the template is instantiated.

## Item Template Design Guidelines

For WinForms/Krypton item templates:

- Always create matching `partial` class + `*.Designer.cs`.
- Keep `Dispose(bool)` and `components` pattern designer-compatible.
- Prefer explicit `System.Windows.Forms`/`System.Drawing` usage in designer file.
- Avoid fragile runtime-only initialization in designer files.

### Ribbon item template specifics

`KryptonRibbonForm` template includes:

- a `Krypton.Ribbon.KryptonRibbon` field,
- basic ribbon initialization,
- `Controls.Add(kryptonRibbon)` in `InitializeComponent()`.

This gives users a working ribbon surface immediately after item creation.

## Project Template Design Guidelines

Project templates should remain minimal and predictable:

- SDK-style `.csproj`
- `UseWindowsForms=true`
- `TargetFramework=net10.0-windows`
- `ImplicitUsings=enable`
- `Nullable=enable`
- a single `PackageReference` to `Krypton.Standard.Toolkit`

App bootstrap:

- `ApplicationConfiguration.Initialize()`
- `KryptonManager.GlobalPaletteMode = PaletteModeManager.Office2010Blue`
- `Application.Run(new MainForm())`

## Why `Krypton.Standard.Toolkit`

Using `Krypton.Standard.Toolkit` in project templates reduces setup friction by giving users a single dependency that covers common Krypton scenarios out-of-the-box.

If package strategy changes in the future, update all project template `.csproj` files consistently.

## Release Automation

Workflow file: `.github/workflows/templates-release.yml`

### Trigger conditions

- Push to: `master`, `alpha`, `canary`, `V105-LTS`
- Path filter:
  - `Templates/**`
  - `.github/workflows/templates-release.yml`
- Manual trigger: `workflow_dispatch`

### Security / control knobs

- Required permission: `contents: write` (needed for release asset updates)
- Kill switch variable:
  - `TEMPLATES_RELEASE_DISABLED=true` disables publish steps

### Branch to channel mapping

- `master` -> `stable` -> `templates-stable`
- `canary` -> `canary` -> `templates-canary`
- `alpha` -> `alpha` -> `templates-alpha`
- `V105-LTS` -> `lts` -> `templates-lts`
- other branch via manual dispatch -> `dev-<sanitized-branch>` -> `templates-<sanitized-branch>`

### Release assets produced

Per workflow run:

- item zip: Krypton Form
- item zip: Krypton Ribbon Form
- project zip: Krypton WinForms App
- project zip: Krypton Ribbon WinForms App
- bundle zip: complete `Templates/` tree

### Release publishing semantics

- Uses `softprops/action-gh-release@v2`
- `overwrite_files: true` updates assets on existing tag
- `make_latest: true` only for stable channel
- `prerelease: true` for canary/alpha/dev channels

## Zip Shape Contract (Critical)

Visual Studio expects each template zip to contain its `.vstemplate` file at archive root.

The workflow intentionally zips each template folder contents (`<folder>\*`) instead of the parent folder itself.

If this contract is broken, templates can appear missing or fail to instantiate.

## Developer Workflow

## 1) Edit or add template

- Create/modify files under `Templates/ItemTemplates` or `Templates/ProjectTemplates`.
- Keep naming clear and stable; template folder names become maintenance anchors.

## 2) Validate descriptor and token usage

Checklist:

- `.vstemplate` `Type` matches template type (`Item`/`Project`).
- `ProjectType` is `CSharp`.
- `ReplaceParameters="true"` applied where tokens are present.
- `TargetFileName` tokens align with generated file naming.

## 3) Smoke-test locally in Visual Studio

Manual process:

1. Zip template folder contents (not the parent folder).
2. Copy zips to VS template directories:
   - Item: `%USERPROFILE%\Documents\Visual Studio 2022\Templates\ItemTemplates\Visual C#\`
   - Project: `%USERPROFILE%\Documents\Visual Studio 2022\Templates\ProjectTemplates\Visual C#\`
3. Restart Visual Studio.
4. Verify template appears and instantiates cleanly.
5. Build generated project.

## 4) Update docs

At minimum:

- update `Templates/README.md`
- update this document if behavior/architecture changed

## 5) Verify release workflow impact

If new template folders are added, update `templates-release.yml`:

- path validation block (`Test-Path` checks)
- zip output variables
- release body asset list
- files list passed to release action

## Adding a New Template (Repeatable Procedure)

1. Add template directory with `.vstemplate` + source files.
2. Add consumer-facing mention in `Templates/README.md`.
3. Add packaging support in `templates-release.yml`.
4. Manual-install smoke test in VS.
5. Push branch and verify release workflow artifacts.

## Troubleshooting

### Template does not appear in Visual Studio

Check:

- zip shape (is `.vstemplate` at zip root?)
- zip copied to correct VS folder
- Visual Studio restarted
- descriptor `ProjectType` and `Type` values valid

### Template appears but fails to create files

Check:

- `ProjectItem` entries reference existing files
- token usage (`$safeitemrootname$`, `$safeprojectname$`, `$rootnamespace$`) is valid
- syntax errors in template source files

### Workflow ran but no release asset updates

Check:

- branch is in allowed set (or manual run with default mapping)
- `TEMPLATES_RELEASE_DISABLED` is not true
- run has `contents: write`
- release action logs for permissions or tag conflicts

### IDE YAML diagnostics show unresolved marketplace actions

Local editor analyzers may fail to resolve actions (`actions/checkout`, `upload-artifact`, `action-gh-release`) even when workflow is valid on GitHub Actions runners. Validate by running workflow in CI.

## Backward Compatibility Notes

- Template names are user-facing; changing names impacts discoverability.
- Existing release tags (`templates-stable`, `templates-canary`, etc.) are long-lived channels; prefer updating assets over proliferating new tags.
- Keep generated code broadly WinForms-designer compatible.

## Future Enhancements (Optional)

- Publish a VSIX for one-click install in addition to zip assets.
- Add CI validation that checks each `.vstemplate` references existing files.
- Add generated project compile smoke test in workflow.
- Add icon assets and category metadata per template.

## Maintainer Quick Checklist

- [ ] Template files added/updated under `Templates/`
- [ ] `.vstemplate` metadata and tokens verified
- [ ] Local Visual Studio install test passed
- [ ] `Templates/README.md` updated
- [ ] `templates-release.yml` updated for new assets
- [ ] Workflow run confirmed and release assets present
