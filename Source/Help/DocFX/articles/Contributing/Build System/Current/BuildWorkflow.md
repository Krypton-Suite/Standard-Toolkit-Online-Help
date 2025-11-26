# `build.yml` Developer Guide

Comprehensive reference for the Build workflow located at `.github/workflows/build.yml`. Use this when responding to failed CI runs or when modifying the pipeline.

## Quick Reference

| Item | Details |
| --- | --- |
| Triggers | `pull_request` (all branches) for open/sync/reopen events, `push` to `master`, `alpha`, `canary`, `gold`, `V105-LTS`, `V85-LTS` |
| Jobs | `build`, `release` (release depends on build) |
| Hosted Images | `windows-2025` (build), `windows-2025` (release) |
| Toolchains | .NET SDKs 9.0.x and 10.0.x, MSBuild x64, NuGet CLI 6.x |
| Global.json | Generated on the fly to force the latest installed 10.0 SDK |
| Build Scripts | `Scripts/nightly.proj` (build job), `Scripts/build.proj` (release job) |
| Secrets/Vars | `NUGET_API_KEY` (only needed when invoking release job manually) |

## Job Topology

```
pull_request / push
└── build (windows-2025)
    └── release (windows-2025, master pushes only)
```

- `build` executes for all configured events.  
- `release` runs only on `refs/heads/master` pushes **after** `build` succeeds.

## Step-by-Step Breakdown

### Shared Patterns

- **Checkout** leverages `actions/checkout@v6` without depth limits.
- **SDK provisioning** installs both .NET 9 and .NET 10 so multi-target solutions build consistently.
- **Dynamic `global.json`** ensures the pipeline pins to the newest 10.0 SDK present on the runner. This protects against SDK rollouts that include previews and automatically maintains parity with GitHub's hosted images.
- **NuGet cache** keys off the hash of every `*.csproj`, so template changes automatically refresh the cache.

### `build` Job (windows-2022)

Purpose: validate the solution for PRs and pushes, producing a Release build via the nightly build script.

1. **Checkout** source.
2. **Setup .NET 9 / .NET 10**: installs SDKs required by the solution.
3. **Force SDK via `global.json`**:
   - Runs `dotnet --list-sdks`.
   - Picks the first entry containing `10.0`.
   - Writes `global.json` with `"rollForward": "latestFeature"` so 10.x feature bands remain valid.
4. **Setup MSBuild (x64)** for compatibility with legacy csproj tooling.
5. **Setup NuGet CLI** to support restore operations not exposed via dotnet.
6. **Cache NuGet packages** under `~/.nuget/packages`.
7. **Restore** the full solution (`Krypton Toolkit Suite 2022 - VS2022.sln`).
8. **Build** via `msbuild Scripts/nightly.proj /t:Rebuild /p:Configuration=Release /p:Platform="Any CPU"`.
   - Script encapsulates multi-project orchestration and ensures parity with nightly builds.

### `release` Job (windows-2025, master pushes only)

Purpose: promote master builds to NuGet packages when commits land directly on `master`.

1. **Checkout + SDK setup + global.json + tooling**: mirrored from the `build` job to avoid cross-runner drift.
2. **Restore** solution again (isolated workspace).
3. **Build Release**: `msbuild Scripts/build.proj /t:Build /p:Configuration=Release`.
4. **Pack Release**: `msbuild Scripts/build.proj /t:Pack ...` creates `.nupkg` artifacts under `Bin/Packages/Release`.
5. **Get Version** (`pwsh`):
   - Runs `dotnet build` on `Krypton.Toolkit.csproj` quietly.
   - Parses the `Version=` log line; default fallback `100.25.1.1`.
   - Emits `version` and `tag` outputs used downstream (e.g., release notes or notifications).
6. **(Optional) Publish NuGet packages**: not automated in this workflow; packages remain as artifacts unless another step consumes them.

### Toolchain Notes

- All commands run via PowerShell (`pwsh`) inline scripts, so any modifications should stay compatible with Core PowerShell 7.
- Keep scripts idempotent; the workflow assumes clean workspaces on each hosted runner.

## Extending the Workflow

- **New SDKs**: mirror the `Setup .NET X` pattern, then update the global.json writer if the preferred default changes.
- **Additional caches**: leverage `actions/cache@v4`; ensure keys incorporate relevant files (e.g., `packages.lock.json`).
- **Artifacts**: if you need to consume build outputs later, add `actions/upload-artifact` after the build/pack steps.
- **Testing hooks**: insert test commands between restore and build stages to fail fast on regressions.

## Troubleshooting

| Symptom | Likely Cause | Mitigation |
| --- | --- | --- |
| `The SDK 'Microsoft.NET.Sdk' specified could not be found` | `global.json` pinned to missing SDK | Confirm the `dotnet --list-sdks` output includes `10.0.x`; update script to handle installation lag. |
| Restore fails with `NU1100` | NuGet cache corrupted or feed hiccup | Manually invalidate cache by tweaking key seed (e.g., add `-nuget-v2`). |
| Release job skipped | Non-master branch or workflow triggered via PR | Push to `master` or temporarily change the `if` condition for testing. |

## Verification Checklist

- [ ] For PRs: ensure `build` completes successfully before merging.
- [ ] For master pushes: confirm both `build` and `release` jobs succeed; inspect `Pack Release` logs for produced `.nupkg` files.
- [ ] If packages need to be published, run the dedicated release workflow or a manual job that consumes the packaged artifacts.

