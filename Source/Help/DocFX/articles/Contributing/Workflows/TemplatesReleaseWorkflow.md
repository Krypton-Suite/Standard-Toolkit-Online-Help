# Visual Studio Templates Release Workflow

## Quick Reference

- Workflow file: `.github/workflows/templates-release.yml`
- Workflow name: `Visual Studio Templates Release`
- Triggers: `push` (template-related paths), `workflow_dispatch`
- Runner: `windows-2025-vs2026`
- Permissions: `contents: write`
- Environment: `production`

## Overview

The `templates-release.yml` workflow builds and publishes Visual Studio template artifacts (ZIP templates and VSIX package) to GitHub Releases.

- Workflow file: `.github/workflows/templates-release.yml`
- Workflow name: `Visual Studio Templates Release`
- Runner: `windows-2025-vs2026`
- Environment: `production`

## Purpose

- Package Krypton item/project templates in distributable formats.
- Build a VSIX installer for one-click template installation in Visual Studio.
- Publish channel-specific artifacts to GitHub Releases.

## Triggers

The workflow runs on:

- `push` to `master`, `alpha`, `canary`, `V110`
- only when files under `Templates/**` or the workflow file itself change
- manual trigger via `workflow_dispatch`

## Kill Switch

Variable: `TEMPLATES_RELEASE_DISABLED`

- `true` -> workflow logs warning and exits via step gating.
- `false` or unset -> workflow proceeds.

Location: Repository Settings -> Secrets and variables -> Actions -> Variables.

## Channel Resolution

Release metadata is derived from the source branch:

- `master` -> `stable`
- `canary` -> `canary`
- `alpha` -> `alpha`
- `V110` -> `current`
- other branches -> `dev-<sanitized-branch>`

The workflow computes:

- release tag
- release title
- prerelease flag
- build-stamped template version (`<channel>-<UTC timestamp>`)
- VSIX version (`110.0.MMdd.HHmm`)

## Artifacts Produced

The workflow creates:

1. Item template zip: `Krypton Form`
2. Item template zip: `Krypton Ribbon Form`
3. Project template zip: `Krypton WinForms App`
4. Project template zip: `Krypton Ribbon WinForms App`
5. Bundle zip of full `Templates` tree
6. VSIX package built from `Templates/Vsix/Krypton.Templates.Vsix`

All artifacts are also uploaded as workflow artifacts using `actions/upload-artifact@v4`.

## VSIX Build Details

Before building VSIX:

- The workflow updates `source.extension.vsixmanifest` version dynamically.
- It writes UTF-8 content without BOM handling issues.

Build execution:

- `dotnet restore` on VSIX project
- `dotnet msbuild` with:
  - `Configuration=Release`
  - `DeployExtension=false`
  - `VsixVersion=<computed>`

## Publishing

Publishing uses `softprops/action-gh-release@v2`:

- `tag_name` and release metadata from resolved channel.
- `make_latest=true` only for stable channel.
- Existing files are overwritten (`overwrite_files: true`).

Release body includes installation guidance and asset list.

## Permissions and Safety

- Permission scope: `contents: write`
- No external package publication (NuGet) in this workflow.
- Environment protection (`production`) can enforce approvals.

## Troubleshooting

### Workflow skips immediately

Check `TEMPLATES_RELEASE_DISABLED`.

### Missing artifact errors

Check template directories exist:

- `Templates/ItemTemplates/KryptonForm`
- `Templates/ItemTemplates/KryptonRibbonForm`
- `Templates/ProjectTemplates/KryptonWinFormsApp`
- `Templates/ProjectTemplates/KryptonRibbonWinFormsApp`
- `Templates/README.md`

### VSIX not produced

Check:

- VSIX project path and manifest path exist.
- Manifest version replacement succeeded.
- Build logs under VSIX build step.

## Related Documentation

- [GitHub Actions Workflows](../GitHubActionsWorkflows.md)
- [GitHub Workflow Index](../GitHubWorkflowIndex.md)
