# Canary Release Workflow

## Quick Reference

- Workflow file: `.github/workflows/canary.yml`
- Workflow name: `Canary Release`
- Triggers: `push` (`Canary`), `workflow_dispatch`
- Runner: `windows-2025-vs2026`
- Permissions: `contents: read`
- Environment: `production`

## Overview

The `canary.yml` workflow builds and publishes canary packages from the `Canary` branch.

- Workflow file: `.github/workflows/canary.yml`
- Workflow name: `Canary Release`
- Runner: `windows-2025-vs2026`
- Environment: `production`

## Purpose

- Produce and publish canary NuGet packages for early validation.
- Run as a standalone canary pipeline separate from `release.yml`'s `release-canary` job.

## Triggers

- `push` to branch `Canary`
- `workflow_dispatch` (manual run)

## Safety Controls

### Kill switch

Variable: `CANARY_DISABLED`

- `true` -> workflow warns and all subsequent guarded steps are skipped.
- `false`/unset -> workflow proceeds.

### Security checks

The workflow explicitly verifies:

- repository is `Krypton-Suite/Standard-Toolkit`
- `GITHUB_REF` is `refs/heads/Canary`

Manual runs must be launched on branch `Canary`.

## Toolchain Setup

The workflow installs:

- .NET 9 / 10
- .NET 11 stable attempt (fallback to preview setup if needed)
- optional preview SDK (`DOTNET_PREVIEW_SETUP_VERSION`) when `USE_DOTNET_PREVIEW != 'false'`

Then it pins `global.json` to a resolved SDK version using:

- `DOTNET_PREVIEW_SDK_BAND` (preview path), or
- stable fallback order (`11` -> `10` -> `9`)

## Build and Pack

Build orchestration uses:

- `Scripts/Build/canary.proj`

Targets:

- `Restore`
- `Build`
- `Pack`

with `Configuration=Canary` and `UseArtifactsOutput=true`.

## Additional Pre-Build Step

`Populate WebView2 (Preview)` downloads/extracts WebView2 package content and copies required DLLs into:

- `Source/Krypton Components/Krypton.Toolkit.Utilities/Lib/WebView2`

This ensures required binaries are present for canary build/package flow.

## Publishing

NuGet push step behavior:

- Looks for packages in:
  - `artifacts/packages/Canary/*.nupkg`
  - `Bin/Packages/Canary/*.nupkg`
- Uses `dotnet nuget push --skip-duplicate`
- Applies size gate from `Scripts/CI/StandardToolkitNupkgGuard.ps1`
- Tracks whether any package was newly published

Required secret for publish:

- `NUGET_API_KEY`

## Notifications

When packages were newly published, the workflow posts a Discord embed to:

- `DISCORD_WEBHOOK_CANARY`

If webhook is missing, notification is skipped with warning.

## Concurrency

Concurrency group:

- `canary-alpha`

with `cancel-in-progress: true` to avoid overlapping runs in that group.

## Troubleshooting

### Workflow exits on branch verification

Check:

- run was triggered from `Canary` branch (case-sensitive in current workflow)

### No packages published

Check:

- `NUGET_API_KEY` configured
- version increment/publish duplication behavior (`--skip-duplicate`)
- package size guard thresholds (`STANDARD_TOOLKIT_MIN_NUPKG_MB`)

### Discord notification not sent

Check:

- `packages_published == True`
- `DISCORD_WEBHOOK_CANARY` is configured and valid

## Related Documentation

- [Release Workflow](ReleaseWorkflow.md)
- [GitHub Actions Workflows](../GitHubActionsWorkflows.md)
