# Build TestForm Workflow

## Quick Reference

- Workflow file: `.github/workflows/build-testform.yml`
- Workflow name: `Build TestForm`
- Triggers: `pull_request`, `push`, `workflow_dispatch`
- Runner: `windows-2025-vs2026`
- Permissions: `contents: read`

## Overview

The `build-testform.yml` workflow validates that the WinForms sample application (`TestForm`) restores and builds across all configured TFMs, and that linked `.resx` file references are valid.

- Workflow file: `.github/workflows/build-testform.yml`
- Workflow name: `Build TestForm`
- Runner: `windows-2025-vs2026`
- Trigger types: pull request, push, manual (`workflow_dispatch`)

This workflow is CI-focused. It does not publish packages or create releases.

## Purpose

- Provide an additional quality gate for the sample app used for manual validation.
- Catch broken linked-resource references early (missing files in `.resx` references).
- Validate both stable and preview SDK paths (depending on repository variables).

## Triggers

The workflow runs on:

- `pull_request` (`opened`, `synchronize`, `reopened`) for all branches
- `push` to `master`, `alpha`, `canary`, `gold`, `V105-LTS` (with `paths-ignore` for `.git*` and `.vscode`)
- `workflow_dispatch`

## Job Model

The workflow has two jobs:

1. `Stable`
2. `Preview`

Both jobs:

- Check out repository code.
- Set up .NET SDKs.
- Restore NuGet cache.
- Restore `Source/Krypton Components/TestForm/TestForm.csproj`.
- Validate linked resources in two `.resx` files.
- Build `TestForm` with `-p:TFMs=all`.

### Stable job

Key behavior:

- Uses .NET 9/10 setup.
- Pins `global.json` to a stable SDK (`10.x`, fallback `9.x`) with `allowPrerelease: false`.
- Is skipped for `canary`/`alpha` push/PR contexts unless `USE_DOTNET_PREVIEW == 'false'`.

### Preview job

Key behavior:

- Runs when `vars.USE_DOTNET_PREVIEW != 'false'`.
- Installs preview SDK using `DOTNET_PREVIEW_SETUP_VERSION`.
- Pins `global.json` to `DOTNET_PREVIEW_SDK_BAND` with `allowPrerelease: true`.

## Repository Variables

The workflow depends on the same preview SDK variables used by other CI workflows:

- `DOTNET_PREVIEW_SETUP_VERSION`
- `DOTNET_PREVIEW_SDK_BAND`
- `USE_DOTNET_PREVIEW`

Behavior of `USE_DOTNET_PREVIEW`:

- `false`: Preview job skipped; Stable may cover canary/alpha contexts.
- other/unset: Preview job enabled.

## Resource Validation Gate

Before build, each job validates linked-file references in:

- `Source\Krypton Components\TestForm\Properties\Resources.resx`
- `Source\Krypton Components\TestForm\KryptonTaskDialogDemo\KryptonTaskDialogDemoResources.resx`

For every `ResXFileRef` entry, the referenced file path must exist. Missing references fail the job with a clear error summary.

## Caching

NuGet cache restore/save is used per job with distinct keys:

- stable key prefix: `nuget-testform-stable-`
- preview key prefix: `nuget-testform-preview-`

Cache save occurs only on success and non-PR events.

## What This Workflow Does Not Do

- Does not create NuGet packages.
- Does not publish to nuget.org.
- Does not create GitHub releases.
- Does not post Discord notifications.

## Troubleshooting

### Preview job fails to resolve SDK band

Check:

- `DOTNET_PREVIEW_SETUP_VERSION` is set to an installable preview line.
- `DOTNET_PREVIEW_SDK_BAND` matches installed SDK major/minor (for example `11.0`).

### Resource validation fails

Check:

- Referenced files in `.resx` exist in repository and are included in commits.
- Relative paths in `ResXFileRef` entries are correct.

### Stable/Preview job unexpectedly skipped

Check:

- Branch context (especially `alpha`/`canary` conditions).
- `USE_DOTNET_PREVIEW` value.

## Related Documentation

- [Build Workflow](BuildWorkflow.md)
- [GitHub Actions Workflows](../GitHubActionsWorkflows.md)
