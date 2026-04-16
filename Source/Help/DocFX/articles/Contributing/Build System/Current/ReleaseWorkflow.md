# `release.yml` Developer Guide

Authoritative documentation for `.github/workflows/release.yml`, which coordinates production and pre-release promotions for pushes to `master`, `alpha`, `canary`, and `V105-LTS` (see the workflow `on.push.branches` list for the current set).

## Quick Reference

| Branch | Job Id | Runner | Build Script | Kill Switch Variable | Discord Webhook |
| --- | --- | --- | --- | --- | --- |
| `master` | `release-master` | `windows-2025-vs2026` | `Scripts/Build/build.proj` (Build/Pack) | `vars.RELEASE_DISABLED` | `secrets.DISCORD_WEBHOOK_MASTER` |
| `V105-LTS` | `release-v105-lts` | `windows-2025-vs2026` | `Scripts/Build/build.proj` | `vars.RELEASE_DISABLED` | `secrets.DISCORD_WEBHOOK_MASTER` |
| `canary` | `release-canary` | `windows-2025-vs2026` | `Scripts/Build/canary.proj` | `vars.CANARY_DISABLED` | `secrets.DISCORD_WEBHOOK_CANARY` |
| `alpha` | `release-alpha` | `windows-2025-vs2026` | `Scripts/Build/nightly.proj` | `vars.NIGHTLY_DISABLED` | `secrets.DISCORD_WEBHOOK_NIGHTLY` |

Common characteristics:

- Every job runs only when the push target matches its branch **and** the corresponding kill switch reports `enabled=true`.
- All jobs repeat the same setup sequence (checkout → install SDKs → generate `global.json` → MSBuild & NuGet tooling → restore).
- Orchestrated **Build** and **Pack** steps pass `/p:UseArtifactsOutput=true`, so outputs go under `artifacts/bin/` and `artifacts/packages/` on the runner. **Push** and **Get Version** steps try `artifacts/...` first, then fall back to legacy `Bin/...` for compatibility with older layouts or local debugging.
- Package publishing relies on `secrets.NUGET_API_KEY`.

## Kill Switches

- Stored under **Repository Settings → Actions → Variables**.
- Each job exits early if its switch evaluates to `'true'`, logging a warning that includes remediation steps.
- When disabled, the pipeline still shows as successful but with most steps skipped, making it clear releases are paused intentionally.

## Job Deep Dive

### 1. `release-master` (Stable)

**Trigger:** `push` to `master`.

1. **Release Kill Switch Check (`vars.RELEASE_DISABLED`)**  
   - Emits `enabled` output consumed by every subsequent step.
2. **Checkout + Tooling Setup**  
   - Dual SDK install (9.0.x and 10.0.x) plus generated `global.json`.
3. **Restore**, **Build**, **Pack** via `Scripts/Build/build.proj` with `/p:UseArtifactsOutput=true`.
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

Matches the `master` job with two differences:

- Messaging still uses the stable Discord webhook (`DISCORD_WEBHOOK_MASTER`).
- Fallback version tag remains standard (`v<version>`), aligning with non-LTS naming.

### 3. `release-canary` (Canary channel)

Highlights:

- Kill switch `vars.CANARY_DISABLED`.
- Build/Pack uses `Scripts/Build/canary.proj` with `Configuration=Canary` and `/p:UseArtifactsOutput=true`.
- Packages: `artifacts/packages/Canary/` then `Bin/Packages/Canary/`. Binaries for version: `artifacts/bin/Canary/net48/Krypton.Toolkit.dll` then `Bin/Canary/net48/Krypton.Toolkit.dll`; fallback `100.25.1.1`.
- Discord uses `DISCORD_WEBHOOK_CANARY` and points to `.Canary` nuget.org packages.

### 4. `release-alpha` (Nightly/alpha channel)

Characteristics:

- Kill switch `vars.NIGHTLY_DISABLED`.
- Uses `Scripts/Build/nightly.proj` with `Configuration=Nightly` and `/p:UseArtifactsOutput=true`.
- Produces packages under `artifacts/packages/Nightly/` (with `Bin/Packages/Nightly/` as fallback for discovery scripts).
- Discord uses `DISCORD_WEBHOOK_NIGHTLY`, referencing `.Nightly` packages. NuGet publishing for scheduled alpha/nightly drops may also be handled by `nightly.yml`; see that workflow for schedule-driven pushes.

## Shared Step Details

### SDK & Tooling Provisioning

```pwsh
dotnet --list-sdks | Select-String "10.0" | Split(" ")[0]
```

The snippet above enforces the latest 10.0 SDK. If GitHub images add previews, adjust the filter to avoid matching pre-release identifiers.

### NuGet Publishing Logic

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

