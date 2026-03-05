# Canary LTS Release Workflow

## Table of Contents

1. [Overview](#overview)
2. [Purpose and Context](#purpose-and-context)
3. [Relationship to Other Workflows](#relationship-to-other-workflows)
4. [Triggers and Branch Policy](#triggers-and-branch-policy)
5. [Prerequisites](#prerequisites)
6. [Kill Switch](#kill-switch)
7. [Workflow Logic — Step by Step](#workflow-logic--step-by-step)
8. [Build System and Package Output](#build-system-and-package-output)
9. [Versioning and Package Identity](#versioning-and-package-identity)
10. [Secrets and Variables Reference](#secrets-and-variables-reference)
11. [Discord Notifications](#discord-notifications)
12. [Security and Permissions](#security-and-permissions)
13. [Troubleshooting](#troubleshooting)
14. [See Also](#see-also)

---

## Overview

The **Canary LTS Release** workflow (`canary-lts-release.yml`) builds and publishes **Canary** NuGet packages from the **V105-LTS** branch only. It is the only workflow that produces Canary packages when running on V105-LTS; the main Canary pipeline runs from the `canary` branch.

| Attribute | Value |
|-----------|--------|
| **Workflow file** | `.github/workflows/canary-lts-release.yml` |
| **Display name** | Canary LTS Release |
| **Runner** | `windows-latest` |
| **Allowed branch** | `V105-LTS` only |

---

## Purpose and Context

- **Canary** builds are pre-release packages (version suffix `-beta`) that include the latest code and support preview .NET versions (e.g. .NET 11). Package IDs use the `.Canary` suffix (e.g. `Krypton.Toolkit.Canary`, `Krypton.Standard.Toolkit.Canary`).
- **V105-LTS** is the long-term support line aligned with .NET 9/10 (and related targets). The main Release workflow on V105-LTS produces **stable** packages (no suffix). This workflow adds the ability to publish **Canary** (pre-release) packages from the same branch.
- **Use case**: Ship pre-release Canary builds from the LTS branch for testing and validation before cutting a stable LTS release, without using the `canary` branch.

---

## Relationship to Other Workflows

| Workflow | Branch | Build type | Package IDs / Notes |
|----------|--------|------------|---------------------|
| **Release** (release.yml) | `master` | Release | Krypton.Toolkit, Krypton.Standard.Toolkit, etc. |
| **Release** (release.yml) | **V105-LTS** | Release | Same stable IDs; LTS changelog links. |
| **Release** (release.yml) | `canary` | Canary | Krypton.Toolkit.Canary, Krypton.Standard.Toolkit.Canary, etc. |
| **Canary LTS Release** (this) | **V105-LTS** | Canary | Same Canary IDs as `canary` branch; built from V105-LTS. |
| **Release** (release.yml) | V85-LTS | Release (LTS) | Krypton.Toolkit.LTS, etc. (different solution/proj). |
| **Nightly** (nightly.yml) | `alpha` (checked out) | Nightly | Krypton.Toolkit.Nightly, etc. |

- **Canary LTS** and **Canary (canary branch)** both produce the same package IDs (e.g. `Krypton.Toolkit.Canary`). They differ by branch and version/build content; NuGet version (e.g. `110.yy.MM.ddd-beta`) distinguishes them.
- This workflow does **not** run on `canary`, `master`, or any branch other than `V105-LTS`.

---

## Triggers and Branch Policy

### Triggers

| Trigger | When it runs |
|---------|----------------------|
| **Push** | Any push to the `V105-LTS` branch. |
| **workflow_dispatch** | Manual run from **Actions** → **Canary LTS Release** → **Run workflow** (branch must be **V105-LTS** when using "Run workflow" from the UI). |

### Branch enforcement

The job condition is:

```yaml
if: github.ref == 'refs/heads/V105-LTS' && (github.event_name == 'push' || github.event_name == 'workflow_dispatch')
```

- The workflow may appear in the Actions list for other branches (e.g. when opened from a PR), but the **job will not run** unless the ref is exactly `refs/heads/V105-LTS`.
- For **workflow_dispatch**, GitHub uses the **default branch** or the branch selector; to run this workflow you must either set V105-LTS as the branch in the dropdown or trigger from a context where the ref is V105-LTS.

---

## Prerequisites

- **Repository**: Contains the Standard Toolkit solution and `Scripts/Build/canary.proj`.
- **Branch**: Workflow logic runs only on `V105-LTS`.
- **Secrets** (see [Secrets and Variables Reference](#secrets-and-variables-reference)):
  - **NUGET_API_KEY** (required for push): nuget.org API key with push permission.
  - **AUTHENTICODE_CERT_BASE64** (optional): Base64-encoded .pfx for code signing.
  - **AUTHENTICODE_CERT_PASSWORD** (optional): Password for the .pfx.
  - **DISCORD_WEBHOOK_CANARY** (optional): Discord webhook for release announcements.
- **Variables**:
  - **CANARY_LTS_DISABLED**: Set to `true` to disable the workflow (kill switch).

---

## Kill Switch

The workflow can be disabled without code changes.

| Item | Value |
|------|--------|
| **Variable** | `CANARY_LTS_DISABLED` |
| **Location** | **Settings** → **Secrets and variables** → **Actions** → **Variables** |
| **To disable** | Set value to `true` (case-sensitive). |
| **To re-enable** | Set value to `false` or remove the variable. |

When disabled, the first step writes a warning and sets `enabled=false`; all subsequent steps are skipped via `if: steps.canary_lts_kill_switch.outputs.enabled == 'true'`.

---

## Workflow Logic — Step by Step

### 1. Canary LTS Release Kill Switch Check

- **Id**: `canary_lts_kill_switch`
- **Shell**: PowerShell
- **Behaviour**: Reads `vars.CANARY_LTS_DISABLED`. If `'true'`, sets output `enabled=false` and logs a warning; otherwise sets `enabled=true`. All later steps depend on this output.

### 2. Checkout

- **Action**: `actions/checkout@v6`
- **Condition**: Kill switch enabled.
- **Effect**: Full checkout of the repository at the commit that triggered the run (e.g. HEAD of V105-LTS on push).

### 3. Setup .NET

- **Action**: `actions/setup-dotnet@v5`
- **Versions**: `9.0.x`, `10.0.x`
- **Condition**: Kill switch enabled.
- **Purpose**: Provides .NET 9 and 10 runtimes/SDKs for building and packing the multi-targeting projects.

### 4. Setup .NET 11 (Preview)

- **Action**: `actions/setup-dotnet@v5`
- **Version**: `11.0.x` with `dotnet-quality: preview`
- **Condition**: Kill switch enabled.
- **Purpose**: Canary configuration supports .NET 11; this step ensures the preview SDK is available.

### 5. Force .NET 11 SDK via global.json

- **Condition**: Kill switch enabled.
- **Behaviour**: Detects the installed 11.0 SDK (e.g. via `dotnet --list-sdks`), writes a `global.json` in the repo root that pins the SDK version with `rollForward: latestFeature`. Subsequent `dotnet`/MSBuild calls use .NET 11 for building and packing.

### 6. Setup MSBuild

- **Action**: `microsoft/setup-msbuild@v2`
- **Options**: `msbuild-architecture: x64`
- **Condition**: Kill switch enabled.
- **Purpose**: Makes MSBuild available for `Scripts/Build/canary.proj`.

### 7. Setup NuGet

- **Action**: `NuGet/setup-nuget@v2.0.1`
- **Condition**: Kill switch enabled.
- **Purpose**: Ensures `nuget.exe` (and related) is on PATH for restore and pack.

### 8. Cache NuGet

- **Action**: `actions/cache@v5`
- **Path**: `~/.nuget/packages`
- **Key**: `${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}`
- **Condition**: Kill switch enabled.
- **Purpose**: Speeds up restore by reusing the NuGet package cache across runs when project files are unchanged.

### 9. Setup WebView2 SDK

- **Condition**: Kill switch enabled.
- **Behaviour**:
  - Creates `WebView2SDK` directory if missing.
  - Resolves latest stable **Microsoft.Web.WebView2** (NuGet search or API); fallback version `1.0.3595.46`.
  - Temporarily adds the package to `Krypton.Utilities.csproj`, restores, copies `Microsoft.Web.WebView2.Core.dll`, `Microsoft.Web.WebView2.WinForms.dll`, and `WebView2Loader.dll` into `WebView2SDK\`, then removes the package reference.
- **Purpose**: Canary build can bundle WebView2; this step provides the SDK files expected by the build without persisting the package reference in the repo.

### 10. Restore

- **Command**: `dotnet restore "Source/Current/Krypton Components/Krypton Toolkit Suite 2022 - VS2022.slnx"`
- **Condition**: Kill switch enabled.
- **Purpose**: Restores dependencies for the solution used by the Canary build.

### 11. Prepare Code Signing Certificate (Optional)

- **Id**: `prepare_cert`
- **Condition**: Kill switch enabled.
- **Behaviour**: If secret `AUTHENTICODE_CERT_BASE64` is set, decodes it and writes a .pfx to `$env:RUNNER_TEMP\codesign.pfx`, then sets outputs `cert_path` and `cert_available=true`. Otherwise `cert_available=false`. Build step uses this to enable Authenticode signing when a certificate is present.

### 12. Build Canary

- **Condition**: Kill switch enabled.
- **Command**: `msbuild "Scripts/Build/canary.proj" /t:Build /p:Configuration=Canary /p:Platform="Any CPU"` with optional signing parameters when `prepare_cert` has made a certificate available.
- **Purpose**: Builds all Canary-configuration outputs (DLLs, etc.) for the TFMs defined in the solution. See [Build System and Package Output](#build-system-and-package-output).

### 13. Pack Canary

- **Command**: `msbuild "Scripts/Build/canary.proj" /t:Pack /p:Configuration=Canary /p:Platform="Any CPU"`
- **Condition**: Kill switch enabled.
- **Purpose**: Cleans old Canary packages, then builds and packs all projects in Canary configuration; produces `.nupkg` files. Output location is defined by the build (see next section).

### 14. Push NuGet Packages to nuget.org

- **Id**: `push_nuget`
- **Condition**: Kill switch enabled.
- **Behaviour**:
  - If `NUGET_API_KEY` is not set: logs a warning, sets `packages_published=false`, exits successfully (no failure).
  - Otherwise: enumerates `Artefacts/Packages/Canary/*.nupkg`, and for each runs `dotnet nuget push ... --source https://api.nuget.org/v3/index.json --skip-duplicate`. Sets `packages_published=true` if at least one package was actually pushed (not skipped as duplicate).
- **Note**: If your build outputs to `Bin/Packages/Canary` instead of `Artefacts/Packages/Canary`, the push step will find no packages; see [Troubleshooting](#troubleshooting).

### 15. Get Version

- **Id**: `get_version`
- **Condition**: Kill switch enabled.
- **Behaviour**:
  - Prefer: read version from `Artefacts/Canary/net48/Krypton.Toolkit.dll` via reflection.
  - Fallback: parse `Version` from `Source/Current/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj`.
  - Last resort: `100.25.1.1`.
  - Outputs: `version`, `tag=v<version>-canary-lts`.

### 16. Announce Canary LTS Release on Discord

- **Condition**: Kill switch enabled **and** `steps.push_nuget.outputs.packages_published == 'True'`.
- **Behaviour**: If `DISCORD_WEBHOOK_CANARY` is set, sends an embed with title "Krypton Toolkit Canary LTS Release", version, branch V105-LTS, package links, and changelog link to the V105-LTS Changelog. If the webhook is not set, logs a warning and exits successfully.

---

## Build System and Package Output

- **Project**: `Scripts/Build/canary.proj`
- **Configuration**: `Canary`
- **Targets used**: `Build`, then `Pack` (which depends on `CleanPackages` and `PackAll`).

The Canary configuration is defined in:

- **Directory.Build.props** (root and under `Source/Current/Krypton Components`): version schema, `PackageVersion` with `-beta` suffix, `PackageId` suffix `.Canary` for the “all TFMs” build.
- **Directory.Build.targets**: TFM set and package metadata (description, icon, etc.) for Canary.

**Package output path**:

- The workflow expects **NuGet packages** in: `Artefacts/Packages/Canary/*.nupkg`.
- The workflow expects **assembly version** from: `Artefacts/Canary/net48/Krypton.Toolkit.dll`.
- In the Current tree, `Source/Current/Krypton Components/Directory.Build.props` sets `PackageOutputPath` to `Bin\Packages\$(Configuration)\`. If the build does not override this (e.g. with a central Artefacts path), packages may instead be under `Bin/Packages/Canary/`. In that case, either the build should be updated to output to `Artefacts/Packages/Canary/`, or the workflow’s push and version steps should be updated to use `Bin/Packages/Canary` and `Bin/Canary` (see [Troubleshooting](#troubleshooting)).

**Projects built**: All `Krypton.*` projects under `Source/Current/Krypton Components` with `Configuration=Canary` and `TFMs=all`, including the Standard Toolkit meta-package.

---

## Versioning and Package Identity

- **Assembly / library version**: Driven by `Directory.Build.props` for Canary: `110.$(Minor).$(Build).$(Revision)` with Minor=year, Build=month, Revision=day-of-year.
- **NuGet package version**: Same base with prerelease suffix, e.g. `110.yy.MM.ddd-beta` (e.g. `110.26.2.45-beta`).
- **Package IDs**: Same as the main Canary channel, e.g.:
  - `Krypton.Toolkit.Canary`
  - `Krypton.Ribbon.Canary`
  - `Krypton.Navigator.Canary`
  - `Krypton.Workspace.Canary`
  - `Krypton.Docking.Canary`
  - `Krypton.Standard.Toolkit.Canary`

Canary LTS and Canary (from `canary` branch) share these IDs; the NuGet version and the fact that this workflow runs only from V105-LTS distinguish LTS canary builds.

---

## Secrets and Variables Reference

| Name | Type | Required | Description |
|------|------|----------|-------------|
| **NUGET_API_KEY** | Secret | Yes (for push) | nuget.org API key; push to https://api.nuget.org/v3/index.json. If unset, push is skipped and the workflow still succeeds. |
| **AUTHENTICODE_CERT_BASE64** | Secret | No | Base64-encoded .pfx used for Authenticode signing. If set, Build step enables signing. |
| **AUTHENTICODE_CERT_PASSWORD** | Secret | No | Password for the .pfx. Only used when AUTHENTICODE_CERT_BASE64 is set. |
| **DISCORD_WEBHOOK_CANARY** | Secret | No | Discord webhook URL. If set and at least one package was pushed, an announcement is sent. |
| **CANARY_LTS_DISABLED** | Variable | No | Kill switch. Set to `true` to disable the workflow. |

---

## Discord Notifications

- **When**: Only if the push step actually published at least one package (`packages_published == 'True'`) and `DISCORD_WEBHOOK_CANARY` is set.
- **Content**: Embed titled "Krypton Toolkit Canary LTS Release", with version, branch (V105-LTS), links to the six Canary packages on nuget.org, and a link to the V105-LTS Changelog. Footer: "Canary LTS (V105-LTS)".
- **Webhook**: Same as for the main Canary release (`release-canary` in release.yml); you can use one channel or separate channels by using a different webhook secret for LTS if desired.

---

## Security and Permissions

- **Permissions**: Uses default `GITHUB_TOKEN` for checkout. No special scopes are required unless you add steps that need them.
- **Secrets**: All sensitive data (NuGet key, certificate, Discord webhook) are stored as repository secrets and are not logged.
- **Branch**: The job runs only when `github.ref == 'refs/heads/V105-LTS'`, so only the V105-LTS branch can trigger this pipeline.
- **Certificate**: The .pfx is written to `RUNNER_TEMP` and used only for the build; it is not committed or re-exposed in logs.

---

## Troubleshooting

### Workflow does not run when I push to V105-LTS

- Confirm the push was to `V105-LTS` (e.g. `git push origin V105-LTS`).
- Check that the job condition is satisfied: **Actions** → run → job; if the job is skipped, the condition at the top of the job will show the evaluated expression.
- Ensure the kill switch is not set: Variables → `CANARY_LTS_DISABLED` should be `false` or absent.

### "No NuGet packages found to push"

- The push step looks for `Artefacts/Packages/Canary/*.nupkg`. If the build writes to a different path (e.g. `Bin/Packages/Canary/` per Current `Directory.Build.props`), no packages will be found.
- **Fix**: Either (1) ensure the build outputs to `Artefacts/Packages/Canary` (e.g. by setting `PackageOutputPath` or a central output dir in CI), or (2) change the workflow to match the actual output path (e.g. `Bin/Packages/Canary/*.nupkg`) and, for version detection, the path that contains `Krypton.Toolkit.dll` (e.g. `Bin/Canary/net48/`).

### Build or Pack fails

- Check the **Build Canary** and **Pack Canary** logs for MSBuild errors.
- Confirm .NET 11 preview SDK is available (Setup .NET 11 step and global.json step).
- Confirm WebView2 SDK step completed and `WebView2SDK` contains the expected DLLs if the build requires them.
- Locally: `msbuild Scripts/Build/canary.proj /t:Build /p:Configuration=Canary /p:Platform="Any CPU"` (and same for `Pack`) to reproduce.

### Get Version fails or uses fallback

- The step expects `Artefacts/Canary/net48/Krypton.Toolkit.dll`. If build output is under `Bin/Canary/`, that path will not exist and the step will fall back to csproj or `100.25.1.1`.
- Align the path in the "Get Version" step with the actual build output directory, or ensure the build writes to `Artefacts/Canary/`.

### NuGet push fails (e.g. 403 or 409)

- Verify **NUGET_API_KEY** is correct and has push permission for the package IDs.
- For 409: version already exists; the script uses `--skip-duplicate`, so the run may still succeed but no new version is pushed. Check NuGet for that version.

### Kill switch has no effect

- Variable name must be exactly `CANARY_LTS_DISABLED` and value `true` (lowercase). Variables are case-sensitive.
- Ensure you are editing **Variables** under **Actions**, not environment-specific variables, unless the workflow uses an environment.
