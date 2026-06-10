# `release.yml` Developer Guide

Authoritative documentation for `.github/workflows/release.yml`, which coordinates production and pre-release promotions for pushes to `master`, `alpha`, `canary`, and `V105-LTS` (see the workflow `on.push.branches` list for the current set).

**How code reaches `master`:** Feature work merges into `alpha` first. Stable releases are promoted through **`alpha` → `canary` → `gold`**, then a **`gold` → `master`** pull request. When repository rulesets are enabled, [Master merge guard](../../Workflows/MasterMergeGuardWorkflow.md) enforces that path; **`release-master`** runs on the **push** that results from merging that PR—not from direct feature pushes to `master`. See [Branch promotion policy](../../BranchPromotionPolicy.md).

## Quick Reference

| Branch | Job Id | Runner | Build Script | Kill Switch Variable | Discord Webhook |
| --- | --- | --- | --- | --- | --- |
| `master` | `release-master` | `windows-2025-vs2026` | `Scripts/Build/build.proj` (Build/Pack) | `vars.RELEASE_DISABLED` | `secrets.DISCORD_WEBHOOK_MASTER` |
| `V105-LTS` | `release-v105-lts` | `windows-2025-vs2026` | `Scripts/Build/build.proj` | `vars.RELEASE_DISABLED` | `secrets.DISCORD_WEBHOOK_MASTER` |
| `canary` | `release-canary` | `windows-2025-vs2026` | `Scripts/Build/canary.proj` | `vars.CANARY_DISABLED` | `secrets.DISCORD_WEBHOOK_CANARY` |
| `alpha` | `release-alpha` | `windows-2025-vs2026` | `Scripts/Build/nightly.proj` | `vars.NIGHTLY_DISABLED` | `secrets.DISCORD_WEBHOOK_NIGHTLY` |

Common characteristics:

- Every job runs only when the push target matches its branch **and** the corresponding kill switch reports `enabled=true`.
- **SDK setup**: install **.NET 9.0.x** and **10.0.x**. Jobs that publish preview TFMs also run **Setup .NET Preview** (unless repository variable **`USE_DOTNET_PREVIEW`** is `false`) and **Pin SDK via global.json**, which resolves `sdk.version` using **`DOTNET_PREVIEW_SDK_BAND`** / **`Get-ListedSdkVersion`** when preview is enabled, or stable **10.x → 9.x** when preview is disabled (see [GitHub Actions Workflows](../../GitHubActionsWorkflows.md#repository-variables-net-preview--ci)).
- The **`release-v105-lts`** job pins **stable** SDKs only (no preview setup step).
- Orchestrated **Build** and **Pack** steps pass **`/m`** and `/p:UseArtifactsOutput=true`, so outputs go under `artifacts/bin/` and `artifacts/packages/` on the runner. **Push** and **Get Version** steps try `artifacts/...` first, then fall back to legacy `Bin/...` for compatibility with older layouts or local debugging.
- Package publishing relies on `secrets.NUGET_API_KEY`.

## Kill Switches

- Stored under **Repository Settings → Actions → Variables**.
- Each job exits early if its switch evaluates to `'true'`, logging a warning that includes remediation steps.
- When disabled, the pipeline still shows as successful but with most steps skipped, making it clear releases are paused intentionally.

## Job Deep Dive

### 1. `release-master` (Stable)

**Trigger:** `push` to `master` (typically after merging a **`gold` → `master`** promotion PR).

1. **Release Kill Switch Check (`vars.RELEASE_DISABLED`)**
   - Emits `enabled` output consumed by every subsequent step.
2. **Checkout + SDK setup + Pin SDK via global.json + tooling**  
   - **Setup .NET** (9.0.x / 10.0.x), optional **Setup .NET Preview** when `USE_DOTNET_PREVIEW` is not `false`, then **Pin SDK via global.json** (preview band or stable per variables).
3. **Restore**, **Build**, **Pack** via `Scripts/Build/build.proj` with `msbuild /m` and `/p:UseArtifactsOutput=true`.
4. **Push NuGet Packages**  
   - Collects `artifacts/packages/Release/*.nupkg` and `Bin/Packages/Release/*.nupkg`.  
   - Uses `dotnet nuget push ... --skip-duplicate`.  
   - Records `packages_published` output for notification gating.
5. **Get Version**  
   - Prefers `artifacts/bin/Release/net48/Krypton.Toolkit.dll`, then `Bin/Release/net48/Krypton.Toolkit.dll`.  
   - Falls back to `Krypton.Toolkit 2022.csproj` `<Version>` or default `100.25.1.1`.
6. **Announce Release on Discord** (if packages published and webhook present)  
   - Posts embed with version, package list, TFM coverage, and nuget.org links.

### 2. `release-v105-lts` (105 LTS line)

**Trigger:** `push` to **`V105-LTS`**.

Same overall pipeline as **`release-master`**, but:

- **Discord**: uses **`DISCORD_WEBHOOK_MASTER`** (same secret as master).
- **SDK**: installs **9.0.x / 10.0.x** and **Pin SDK via global.json** using **stable** 10.x → 9.x only (no **Setup .NET Preview** step in this job).

### 3. `release-canary` (Canary channel)

Highlights:

- Kill switch `vars.CANARY_DISABLED`.
- Build/Pack uses `Scripts/Build/canary.proj` with `Configuration=Canary`, `msbuild /m`, and `/p:UseArtifactsOutput=true`.
- Packages: `artifacts/packages/Canary/` then `Bin/Packages/Canary/`. Binaries for version: `artifacts/bin/Canary/net48/Krypton.Toolkit.dll` then `Bin/Canary/net48/Krypton.Toolkit.dll`; fallback `100.25.1.1`.
- Discord uses `DISCORD_WEBHOOK_CANARY` and points to `.Canary` nuget.org packages.

### 4. `release-alpha` (Nightly/alpha channel)

Characteristics:

- Kill switch `vars.NIGHTLY_DISABLED`.
- Uses `Scripts/Build/nightly.proj` with `Configuration=Nightly`, `msbuild /m`, `BuildInParallel="true"`, and `/p:UseArtifactsOutput=true`.
- Produces packages under `artifacts/packages/Nightly/` (with `Bin/Packages/Nightly/` as fallback for discovery scripts).
- Discord uses `DISCORD_WEBHOOK_NIGHTLY`, referencing `.Nightly` packages. NuGet publishing for scheduled alpha/nightly drops may also be handled by `nightly.yml`; see that workflow for schedule-driven pushes.

## Shared step details

### SDK and `global.json`

Workflow steps named **Pin SDK via global.json** run PowerShell that:

1. Lists SDKs with `dotnet --list-sdks`.
2. Chooses a version via **`Get-ListedSdkVersion`** (matches the scripts in `.github/workflows/release.yml`).
3. Writes repo-root **`global.json`** with `"rollForward": "latestFeature"`.

Preview vs stable selection is driven by repository variables **`USE_DOTNET_PREVIEW`**, **`DOTNET_PREVIEW_SETUP_VERSION`**, and **`DOTNET_PREVIEW_SDK_BAND`** (see [GitHub Actions Workflows](../../GitHubActionsWorkflows.md#repository-variables-net-preview--ci)).

### NuGet publishing logic

- Packages iterate serially; failures log warnings but do not fail the workflow (resilience for flaky pushes).
- Successful pushes toggle `$publishedAny` to `$true`, which determines whether Discord announcements run.
- Missing `NUGET_API_KEY` skips publishing gracefully; ensure repo secrets are populated before enabling release branches.

### Version Discovery

Priority order:

1. Assembly version via `[System.Reflection.AssemblyName]::GetAssemblyName(...)`.
2. `<Version>` node from `Krypton.Toolkit 2022.csproj`.
3. Hard-coded fallback (channel-specific).

Outputs `version` and `tag`, enabling downstream release automation or manual tagging.

## Extending the Workflow

- **New Release Channel**: Duplicate a job, change branch filter, update kill switch variable name, and point to the correct MSBuild project and Discord webhook.
- **Custom Notifications**: Add steps after `Announce ...` conditioned on the same outputs (`packages_published` + kill switch).
- **Artifact Sharing**: Insert `actions/upload-artifact` after pack steps if packages must be inspected before publishing.
- **Telemetry**: Wrap `dotnet` commands with additional logging by piping to `Tee-Object` or storing logs in `Logs/`.

## Troubleshooting Playbook

| Symptom | Diagnosis | Action |
| --- | --- | --- |
| Job skipped entirely | Branch mismatch or kill switch `true` | Verify `github.ref` and repository variables. |
| `dotnet nuget push` failing with 403 | Expired or missing `NUGET_API_KEY` | Rotate key in repo secrets; rerun job. |
| Discord step skipped | `packages_published=false` or missing webhook secret | Confirm packages actually produced, check secret names. |
| Version fallback used unexpectedly | Assembly or csproj not accessible | Ensure build outputs exist under `artifacts/bin/...` or `Bin/...`; confirm `UseArtifactsOutput` matches the layout you expect. |

## Operational Checklist

- [ ] Confirm kill switch variable is `false` before triggering releases.
- [ ] Monitor package push logs for `already exists` messages; duplicates are expected on reruns.
- [ ] Validate Discord message in the target channel after publication.
- [ ] Tag repository manually if you rely on the `get_version` output for git tagging.

## Related documentation

- [Branch promotion policy](../../BranchPromotionPolicy.md)
- [Master merge guard](../../Workflows/MasterMergeGuardWorkflow.md)
- [Branch promotion guard](../../Workflows/BranchPromotionGuardWorkflow.md)
