# `build.yml` Developer Guide

Comprehensive reference for the Build workflow located at `.github/workflows/build.yml`. Use this when responding to failed CI runs or when modifying the pipeline.

## Quick Reference

| Item | Details |
| --- | --- |
| Triggers | `pull_request` (all branches) for open/sync/reopen events, `push` to `master`, `alpha`, `canary`, `gold`, `V105-LTS` |
| Jobs | `build`, `release` (release depends on build) |
| Hosted Images | `windows-2025-vs2026` (build and release jobs) |
| Toolchains | .NET SDKs 9.0.x and 10.0.x, MSBuild x64, NuGet CLI 6.x |
| Global.json | **Pin SDK via global.json** pins latest stable 10.x (fallback 9.x) in `build`/`release`; preview workflows use additional variables |
| Build Scripts | `Scripts/Build/nightly.proj` (build job), `Scripts/Build/build.proj` (release job); both pass `/p:UseArtifactsOutput=true` on MSBuild |
| Secrets/Vars | `NUGET_API_KEY` when publishing; repository variables `DOTNET_PREVIEW_SETUP_VERSION`, `DOTNET_PREVIEW_SDK_BAND`, `USE_DOTNET_PREVIEW` for preview SDK behaviour (see [GitHub Actions Workflows](../../GitHubActionsWorkflows.md#repository-variables-net-preview--ci)) |

## Job Topology

```
pull_request / push
└── build (windows-2025-vs2026)
    └── release (windows-2025-vs2026, master pushes only)
```

## Step-by-Step Breakdown

### Shared Patterns

- **Checkout** leverages `actions/checkout@v6` without depth limits.
- **SDK provisioning** installs .NET 9 and .NET 10; optionally installs the preview SDK via **Setup .NET Preview** when `USE_DOTNET_PREVIEW` is not `false`.
- **`Pin SDK via global.json`** runs PowerShell that resolves the SDK version with `Get-ListedSdkVersion` (stable 10.x → 9.x, or preview band + fallback depending on repository variables).
- **NuGet cache** keys off the hash of every `*.csproj`.

### `build` Job

Purpose: validate the solution for PRs and pushes, producing a Release build via the nightly build script.

1. **Checkout** source.
2. **Setup .NET 9 / .NET 10**.
3. **Setup .NET Preview** when `USE_DOTNET_PREVIEW` ≠ `false` (`DOTNET_PREVIEW_SETUP_VERSION`).
4. **Pin SDK via global.json** — writes `global.json` pinning latest stable 10.x (fallback 9.x) for this job.
5. **Setup MSBuild (x64)**.
6. **Setup NuGet CLI**.
7. **Cache NuGet packages** under `~/.nuget/packages`.
8. **Restore** `Source/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.slnx` with `TFMs=all`.
9. **Build** via `msbuild Scripts/Build/nightly.proj /t:Rebuild /p:Configuration=Release /p:Platform="Any CPU" /p:UseArtifactsOutput=true`.

### `release` Job (master pushes only)

Purpose: pack master builds into NuGet artifacts.

1. **Checkout + SDK setup + Pin SDK via global.json + tooling**: aligned with the `build` job.
2. **Restore**, **Build**, **Pack** via `Scripts/Build/build.proj`.
3. **Get Version** from build output / project files.

### Toolchain Notes

- **New preview bands**: prefer updating repository variables `DOTNET_PREVIEW_SETUP_VERSION` and `DOTNET_PREVIEW_SDK_BAND` rather than hardcoding versions in YAML.

## Extending the Workflow

- **Caches**: adjust `actions/cache` keys if you add lockfiles or new project patterns.
- **Artifacts**: add `actions/upload-artifact` after pack steps if downstream jobs need binaries.
- **Tests**: insert verification commands between restore and build to fail fast.

## Troubleshooting

| Symptom | Likely Cause | Mitigation |
| --- | --- | --- |
| `The SDK 'Microsoft.NET.Sdk' specified could not be found` | `global.json` pinned to missing SDK | Confirm `dotnet --list-sdks` on the runner; ensure preview/stable variables match installed SDKs. |
| Restore fails with `NU1100` | NuGet cache corrupted or feed hiccup | Manually invalidate cache by tweaking key seed (e.g., add `-nuget-v2`). |
| Release job skipped | Non-master branch or workflow triggered via PR | Push to `master` or temporarily change the `if` condition for testing. |

## Verification Checklist

- [ ] For PRs: ensure `build` completes successfully before merging.
- [ ] For master pushes: confirm both `build` and `release` jobs succeed; inspect `Pack Release` logs for produced `.nupkg` files.
- [ ] If packages need to be published, run the dedicated release workflow or a manual job that consumes the packaged artifacts.

