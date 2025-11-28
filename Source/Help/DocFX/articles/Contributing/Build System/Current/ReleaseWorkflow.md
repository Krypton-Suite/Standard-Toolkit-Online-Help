# `release.yml` Developer Guide

Authoritative documentation for `.github/workflows/release.yml`, which coordinates all production and pre-release promotions across branches (`master`, `alpha`, `canary`, `V105-LTS`, `V85-LTS`).

## Quick Reference

| Branch | Job Id | Runner | Build Script | Kill Switch Variable | Discord Webhook |
| --- | --- | --- | --- | --- | --- |
| `master` | `release-master` | `windows-latest` | `Scripts/build.proj` (Build/Pack) | `vars.RELEASE_DISABLED` | `secrets.DISCORD_WEBHOOK_MASTER` |
| `V105-LTS` | `release-v105-lts` | `windows-latest` | `Scripts/build.proj` | `vars.RELEASE_DISABLED` | `secrets.DISCORD_WEBHOOK_MASTER` |
| `V85-LTS` | `release-v85-lts` | `windows-latest` | `Scripts/longtermstable.proj` | `vars.LTS_DISABLED` | `secrets.DISCORD_WEBHOOK_LTS` |
| `canary` | `release-canary` | `windows-latest` | `Scripts/canary.proj` | `vars.CANARY_DISABLED` | `secrets.DISCORD_WEBHOOK_CANARY` |
| `alpha` | `release-alpha` | `windows-latest` | `Scripts/nightly.proj` | `vars.NIGHTLY_DISABLED` | `secrets.DISCORD_WEBHOOK_NIGHTLY` |

Common characteristics:

- Every job runs only when the push target matches its branch **and** the corresponding kill switch reports `enabled=true`.
- All jobs repeat the same setup sequence (checkout → install SDKs → generate `global.json` → MSBuild & NuGet tooling → restore).
- Package publishing relies on `secrets.NUGET_API_KEY` and writes `.nupkg` files into branch-specific directories under `Bin/`.

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
3. **Restore**, **Build**, **Pack** via `Scripts/build.proj`.
4. **Push NuGet Packages**  
   - Searches `Bin/Packages/Release/*.nupkg`.  
   - Uses `dotnet nuget push ... --skip-duplicate`.  
   - Records `packages_published` output for notification gating.
5. **Get Version**  
   - Prefers reading `Bin/Release/net48/Krypton.Toolkit.dll` assembly version.  
   - Falls back to `Krypton.Toolkit 2022.csproj` `<Version>` or default `100.25.1.1`.
6. **Announce Release on Discord** (if packages published and webhook present)  
   - Posts embed with version, package list, TFM coverage, and nuget.org links.

### 2. `release-v105-lts` (105 LTS line)

Matches the `master` job with two differences:

- Messaging still uses the stable Discord webhook (`DISCORD_WEBHOOK_MASTER`).
- Fallback version tag remains standard (`v<version>`), aligning with non-LTS naming.

### 3. `release-v85-lts` (85 LTS line)

Key divergences:

- Kill switch variable is `vars.LTS_DISABLED`.
- SDK set includes .NET 6, 7, and 8 to cover older target frameworks.
- Build/Pack script is `Scripts/longtermstable.proj`.
- Packages publish from `Bin/Packages/Release/*.nupkg` but contain `.LTS` suffixes.
- Version fallback defaults to `85.25.1.1` and the git tag output is `v<version>-lts`.
- Discord notifications use `secrets.DISCORD_WEBHOOK_LTS` with LTS-specific copy.

### 4. `release-canary` (Canary channel)

Highlights:

- Kill switch `vars.CANARY_DISABLED`.
- Build/Packing script `Scripts/canary.proj`, configuration `Canary`.
- Artifacts live in `Bin/Packages/Canary` and binaries under `Bin/Canary/...`.
- Version extraction reads `Bin/Canary/net48/Krypton.Toolkit.dll`; fallback `100.25.1.1`.
- Discord uses `DISCORD_WEBHOOK_CANARY` and points to `.Canary` nuget.org packages.

### 5. `release-alpha` (Nightly/alpha channel)

Characteristics:

- Kill switch `vars.NIGHTLY_DISABLED`.
- Uses `Scripts/nightly.proj` with `Configuration=Nightly`.
- Packages stored under `Bin/Packages/Nightly`.
- Discord uses `DISCORD_WEBHOOK_NIGHTLY`, referencing `.Nightly` packages.

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
| Version fallback used unexpectedly | Assembly or csproj not accessible | Ensure build outputs exist at expected paths; confirm script edits. |

## Operational Checklist

- [ ] Confirm kill switch variable is `false` before triggering releases.
- [ ] Monitor package push logs for `already exists` messages; duplicates are expected on reruns.
- [ ] Validate Discord message in the target channel after publication.
- [ ] Tag repository manually if you rely on the `get_version` output for git tagging.

