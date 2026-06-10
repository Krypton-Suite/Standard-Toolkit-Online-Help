# Nightly Workflow

## Quick Reference

| Item | Value |
|------|-------|
| Workflow file | `.github/workflows/nightly.yml` |
| Workflow name (Actions UI) | **Nightly Release** |
| Triggers | `schedule` (`0 0 * * *` UTC), `workflow_dispatch` |
| Runner | `windows-2025-vs2026` |
| Environment | `production` (approval before publish, when configured) |
| Checkout branch | `alpha` (`fetch-depth: 0`) |
| Build orchestration | `Scripts/Build/nightly.proj` (`Configuration=Nightly`) |
| Concurrency | `nightly-alpha`, `cancel-in-progress: true` |
| Permissions | `contents: read` |

## Overview

The **Nightly Release** workflow builds and publishes bleeding-edge NuGet packages from the **`alpha`** branch on a daily schedule. It skips work when there are no recent commits (24-hour window, with an optional extended **retention** window), and supports a repository kill switch.

**Related:** The `release.yml` job `release-alpha` shares the `NIGHTLY_DISABLED` kill switch name for alpha-channel publishing — see [Kill switches](../Build%20System/KillSwitches.md).

## Purpose

- Automated nightly packages (`*.Nightly` on nuget.org) without manual runs
- Skip CI and NuGet pushes when `alpha` is quiet (24h + optional retention days)
- Prerelease **WebView2** binaries for `Krypton.Toolkit.Utilities` (cached per version)
- Discord notification when at least one new package is pushed
- Repository and branch guards before checkout

## Trigger Conditions

### Scheduled

- **Cron:** `0 0 * * *` (midnight UTC daily)
- Uses the workflow definition on the branch where the schedule is registered (typically after merge to `master` or the default branch that hosts the file).

### Manual (`workflow_dispatch`)

| Input | Type | Purpose |
|-------|------|---------|
| `retention_check_days` | number (optional) | When there are **no** commits in the last 24h, look back this many days on `alpha` for activity. Overrides `NIGHTLY_RELEASE_RETENTION_CHECK_DAYS` when set. |

Use manual runs to force a build or to test retention behaviour after re-enabling the workflow.

## Workflow Structure

### Job: `nightly`

**Runner:** `windows-2025-vs2026`

**Environment:** `production`

**Concurrency:** group `nightly-alpha`, cancel in-progress runs.

### Step sequence (summary)

| Phase | Steps | Gated by `has_changes` |
|-------|--------|-------------------------|
| Control | Kill switch, repository check, branch check | No |
| Source | Checkout `alpha`, change detection, skip notice | Detection only |
| Toolchain | .NET 9/10, .NET 11 (stable → preview fallback), optional preview SDK, `global.json` | Yes |
| Build | MSBuild, NuGet, cache, WebView2 resolve/restore/populate/save | Yes |
| Publish | Restore, Build, Pack, Push NuGet, Get version, Discord | Yes |

All build/publish steps use:

`if: steps.nightly_release_kill_switch.outputs.enabled == 'true' && steps.check_changes.outputs.has_changes == 'true'`

## Detailed Behaviour

### Kill switch

| Variable | Value | Effect |
|----------|-------|--------|
| `NIGHTLY_DISABLED` | `true` | Workflow disables after kill-switch step; no checkout/build |
| `NIGHTLY_DISABLED` | unset / `false` | Normal operation |

**Location:** Repository Settings → Secrets and variables → Actions → Variables.

### Security verification

**Repository** — must be `Krypton-Suite/Standard-Toolkit`.

**Branch ref** (`GITHUB_REF`) — must be one of:

- `refs/heads/alpha`
- `refs/heads/master`
- `refs/heads/main`

The job always **checks out `ref: alpha`** for build content regardless of which allowed ref triggered the run (for example manual dispatch from `master`).

### Change detection and retention window

**Step:** `Check for changes on alpha`  
**Outputs:** `has_changes` (`true`/`false`), `change_window` (`24h`, `retention_<N>d`, or `none`).

1. **24-hour window** — count commits on `alpha` since 24 hours ago (UTC). If count &gt; 0 → proceed (`change_window=24h`).
2. **Retention window** — if 24h count is 0:
   - Resolve retention days:
     - `workflow_dispatch` input `retention_check_days` (if numeric), else
     - repository variable `NIGHTLY_RELEASE_RETENTION_CHECK_DAYS`, else
     - `0` (no extended window).
   - Cap retention at **90** days (warning if higher).
   - If retention ≤ 0 → skip build (`change_window=none`).
   - Else count commits on `alpha` in the last *N* days; if &gt; 0 → proceed (`change_window=retention_<N>d`).
3. **Skip** — if still no commits, `has_changes=false` and **Skip notification** logs a notice; no build/publish.

**Use case for retention:** After `NIGHTLY_DISABLED=true` for several days, set `NIGHTLY_RELEASE_RETENTION_CHECK_DAYS=7` (or pass `retention_check_days` on a manual run) so the next scheduled run can still publish if `alpha` had commits during that week.

### .NET SDK setup

| Step | When | Detail |
|------|------|--------|
| Setup .NET (9 and 10) | Kill switch on | `9.0.x`, `10.0.x` |
| Setup .NET 11 (stable) | Kill switch on | `DOTNET_PREVIEW_SETUP_VERSION` or `11.0.x`; `continue-on-error: true` |
| Setup .NET 11 (preview fallback) | Stable step failed | Same version with `dotnet-quality: preview` |
| Setup .NET Preview | `USE_DOTNET_PREVIEW != 'false'` | `DOTNET_PREVIEW_SETUP_VERSION`, preview quality |

### Pin SDK via `global.json`

Runs only when `has_changes == true`. Uses `USE_DOTNET_PREVIEW` and `DOTNET_PREVIEW_SDK_BAND`:

- **`USE_DOTNET_PREVIEW=false`:** Prefer latest installed **11.0**, then 10.0, then 9.0.
- **Preview enabled:** Require `DOTNET_PREVIEW_SDK_BAND`; pin latest SDK matching that band, fallback to 11.0 then 10.0.

Writes `rollForward: latestFeature`.

### WebView2 (prerelease)

Nightly builds use the latest **prerelease** WebView2 package for `Krypton.Toolkit.Utilities`:

1. **Resolve WebView2 version** — NuGet search API (`prerelease=true`); fallback `1.0.3595.46`.
2. **Restore WebView2 cache** — `actions/cache/restore` under `${{ runner.temp }}/webview2`, key `webview2-<os>-<version>`.
3. **Populate WebView2 (Preview)** — Download/extract nupkg if needed; copy `Microsoft.Web.WebView2.Core.dll`, `Microsoft.Web.WebView2.WinForms.dll`, `WebView2Loader.dll` into `Source/Krypton Components/Krypton.Toolkit.Utilities/Lib/WebView2`.
4. **Save WebView2 cache** — `actions/cache/save` on success.

### Build and pack

**Project:** `Scripts/Build/nightly.proj`  
**Properties:** `Configuration=Nightly`, `Platform=Any CPU`, `UseArtifactsOutput=true`  
**Parallelism:** `msbuild /m`

| Step | MSBuild target |
|------|----------------|
| Restore | `/t:Restore` |
| Build Nightly | `/t:Build` with `/restore` |
| Pack Nightly | `/t:Pack` with `/restore` |

### NuGet publishing

**Secret:** `NUGET_API_KEY` (optional — missing key skips push with warning, `packages_published=false`).

**Package search paths (both):**

- `artifacts/packages/Nightly/*.nupkg`
- `Bin/Packages/Nightly/*.nupkg`

**Guard:** Dot-sources `Scripts/CI/StandardToolkitNupkgGuard.ps1` — `Test-StandardToolkitNupkgPushAllowed` per package. If any package fails the size gate, the step **exits 1**.

**Variable:** `STANDARD_TOOLKIT_MIN_NUPKG_MB` (passed to guard script).

**Push:** `dotnet nuget push` to `https://api.nuget.org/v3/index.json` with `--skip-duplicate`.

**Output:** `packages_published` — `true` only if at least one package was newly pushed (not duplicate).

### Version extraction

**Step:** `Get Version`  
**Project (MSBuild fallback):** `Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj`  
**Configuration:** `Nightly`

1. **Primary:** `Krypton.Toolkit.dll` assembly version from (first hit):
   - `artifacts/bin/Nightly/net48/Krypton.Toolkit.dll`
   - `Bin/Nightly/net48/Krypton.Toolkit.dll`
   - Recursive search under `artifacts/bin`, `Bin/Nightly`, `Bin`
2. **Fallback:** `dotnet msbuild -getProperty:Version` on the csproj above.
3. **Hard fallback:** `100.25.1.1`

Accepted version format: `^[1-9]\d{2,}\.\d+\.\d+\.\d+$`

**Outputs:** `version`, `tag` (e.g. `v100.25.1.1-nightly`)

### Discord notification

**When:** `packages_published == 'True'` and kill switch enabled.

**Secret:** `DISCORD_WEBHOOK_NIGHTLY` (optional — warning and skip if unset).

**Content highlights:**

- Nightly package links (Toolkit, Ribbon, Navigator, Workspace, Docking, Standard.Toolkit)
- Target frameworks including **.NET 11.0**
- Changelog: `alpha` branch path `Documents/Changelog/Changelog.md`

## Configuration

### Secrets

| Secret | Required | Purpose |
|--------|----------|---------|
| `NUGET_API_KEY` | For publish | nuget.org push |
| `DISCORD_WEBHOOK_NIGHTLY` | No | Release announcement |

### Variables

| Variable | Purpose |
|----------|---------|
| `NIGHTLY_DISABLED` | Kill switch (`true` disables) |
| `NIGHTLY_RELEASE_RETENTION_CHECK_DAYS` | Extended lookback when 24h has no commits (max 90) |
| `USE_DOTNET_PREVIEW` | `false` skips preview SDK step; affects `global.json` pinning |
| `DOTNET_PREVIEW_SETUP_VERSION` | .NET 11 install version (e.g. `11.0.x`) |
| `DOTNET_PREVIEW_SDK_BAND` | Required when preview enabled; band for `global.json` |
| `STANDARD_TOOLKIT_MIN_NUPKG_MB` | Minimum package size gate for push |

### Environment

- **`production`** — use GitHub environment protection so NuGet push requires approval when configured.

## Troubleshooting

| Symptom | Likely cause | Action |
|---------|----------------|--------|
| Workflow skipped immediately | `NIGHTLY_DISABLED=true` | Clear or set variable to `false` |
| “No commits in 24h” notice | No `alpha` commits in 24h and retention 0 | Commit to `alpha`, set retention days, or manual dispatch |
| Build steps skipped | `has_changes=false` | Same as above; check `change_window` in logs |
| NuGet push skipped | Missing `NUGET_API_KEY` | Add secret |
| Job failed on push | Nupkg size guard | Check `STANDARD_TOOLKIT_MIN_NUPKG_MB` and package sizes |
| Duplicate packages only | Versions already on nuget.org | Expected; `packages_published=false`, no Discord |
| WebView2 warnings | Cache corrupt / download fail | Re-run; check logs under Populate WebView2 |
| Wrong repository/branch error | Security steps | Run only on allowed repo/ref |
| Version fallback `100.25.1.1` | DLL/MSBuild version not found | Inspect build outputs under `artifacts/bin` / `Bin` |

## Workflow flow

```text
Trigger (schedule 00:00 UTC or workflow_dispatch)
    │
    ├─> Kill switch (NIGHTLY_DISABLED)
    │       └─> disabled → stop
    │
    ├─> Verify repository + GITHUB_REF
    │
    ├─> Checkout alpha (full history)
    │
    ├─> Change detection
    │       ├─> commits in 24h → has_changes=true
    │       ├─> else retention window (var/input, max 90d)
    │       └─> else → skip notice, stop (no build)
    │
    ├─> Setup .NET 9/10, 11 (stable/preview), optional preview SDK
    ├─> Pin global.json (if has_changes)
    ├─> MSBuild + NuGet + package cache
    ├─> WebView2 resolve → cache restore → populate → cache save
    ├─> msbuild nightly.proj: Restore → Build → Pack
    ├─> Push NuGet (guard + skip-duplicate) → packages_published
    ├─> Get version from assembly / MSBuild
    └─> Discord (if packages_published)
```

## Maintenance

### Change schedule

Edit `on.schedule` cron in `.github/workflows/nightly.yml` (must be on the branch GitHub uses for scheduled workflows).

### Change retention default

Set repository variable `NIGHTLY_RELEASE_RETENTION_CHECK_DAYS` (integer, ≤ 90), or document manual `retention_check_days` for one-off runs.

### Align documentation

When changing `nightly.yml`, update this file and [GitHub Workflow Index](../GitHubWorkflowIndex.md) quick-reference row if triggers or kill switches change.

## Related documentation

- [Build workflow](BuildWorkflow.md) — PR CI (different trigger; shares SDK/WebView2 patterns on `alpha`)
- [Release workflow](ReleaseWorkflow.md) — `release-alpha` and shared `NIGHTLY_DISABLED`
- [Kill switches](../Build%20System/KillSwitches.md)
- [Build scripts](../Build%20System/BuildScripts.md) — `nightly.proj`

## Code reference

**File:** [.github/workflows/nightly.yml](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/workflows/nightly.yml)
