# Krypton RC NuGet Packages

## Overview

[#4246](https://github.com/Krypton-Suite/Standard-Toolkit/issues/4246) adds a **release candidate** NuGet channel published from the `gold` branch.

RC packages use the **same package IDs** as stable (`Krypton.Toolkit`, `Krypton.Ribbon`, `Krypton.Navigator`, `Krypton.Workspace`, `Krypton.Docking`, `Krypton.Standard.Toolkit`, and the `.Lite` variants). Only the version suffix differs: `110.yy.MM.doy-rc`. That matches [NuGet SemVer 2.0 prerelease ordering](https://learn.microsoft.com/en-us/nuget/concepts/package-versioning?tabs=semver20sort#pre-release-versions): `alpha` &lt; `beta` &lt; `rc` &lt; stable.

Consumers install with prerelease enabled, then drop it at GA without changing PackageReference IDs:

```text
dotnet add package Krypton.Toolkit --prerelease
```

Nightly and Canary keep separate IDs (`.Nightly` / `.Canary`). Do not introduce `Krypton.Toolkit.RC`.

## Architecture

| Channel | Branch | Configuration | Package ID | Version |
|---------|--------|---------------|------------|---------|
| Nightly | `alpha` | `Nightly` | `*.Nightly` | `110.yy.MM.doy-alpha` |
| Canary | `canary` | `Canary` | `*.Canary` | `110.yy.MM.doy-beta` |
| **RC** | **`gold`** | **`RC`** | **stable IDs** | **`110.yy.MM.doy-rc`** |
| Stable | `master` | `Release` | stable IDs | `110.yy.MM.doy` |

Versioning lives in `Directory.Build.props` and `Source/Krypton Components/Directory.Build.targets`. The `RC` configuration does **not** append `.RC` to `PackageId`. Pack uses `PackLite` then `PackAll` (same as stable) via `Scripts/Build/rc.proj`. The NuGet package icon is `Assets/PNG/NuGet Package Icons/Krypton RC.png`.

Same-day gold pushes reuse the same `-rc` version; `dotnet nuget push --skip-duplicate` skips the second upload (same as Canary/Nightly).

## Public API / consumer surface

No new types. New MSBuild configuration `RC` and NuGet prerelease versions of existing packages.

## Usage

### Local build and pack

- VS2022: `.\Scripts\VS2022\build-rc.cmd` (optional argument: `Pack`, `PackLite`, `PackAll`)
- VS2026 / current: `.\Scripts\Current\build-rc.cmd`
- VS2019: `.\Scripts\Build\build-rc.cmd`
- Interactive: `run.cmd` → Build / Pack / Build and pack → **RC version (gold)**

Output: `Bin/Packages/RC/` or `artifacts/packages/RC/` when `UseArtifactsOutput=true`.

### CI publish

`.github/workflows/rc.yml` (**RC Release**):

- Triggers: push to `gold`, or `workflow_dispatch` **from** `gold`
- Gates: `environment: production` (approval), branch check `refs/heads/gold`, kill switch `RC_DISABLED=true`
- Packs `Scripts/Build/rc.proj` with `Configuration=RC`
- Uses **stable** WebView2 (not Canary’s prerelease feed)
- Pushes to nuget.org with `NUGET_API_KEY`
- Optional Discord: secret `DISCORD_WEBHOOK_RC`

Do **not** pack `Configuration=Release` from gold. That would publish an unsuffixed stable version.

GitHub Actions workflow definitions used on a schedule or as the default-branch copy must land on `master` (see `.github/BRANCH_POLICY.md`). After merge to `alpha`, promote `.github/` to `master`, then sync onto `gold`.

## Configuration / persistence

| Name | Kind | Purpose |
|------|------|---------|
| `RC_DISABLED` | Actions variable | `true` no-ops the RC workflow |
| `DISCORD_WEBHOOK_RC` | Actions secret | Discord announcement after a successful publish |
| `NUGET_API_KEY` | Actions secret | nuget.org push (shared with other release workflows) |
| `production` | GitHub Environment | Approval gate before publish |

Templates: `templates-release.yml` maps `gold` → channel `rc` / tag `templates-rc` / `prerelease=true`, still referencing `Krypton.Standard.Toolkit`.

## Edge cases

- **Package identity:** RC nupkgs must be `Krypton.Toolkit.*.nupkg` with version `…-rc`, never `Krypton.Toolkit.RC`.
- **Numeric version vs suffix:** `LibraryVersion` / `AssemblyVersion` stay numeric; only `PackageVersion` has `-rc`.
- **TFMs:** `RC` follows Release TFM selection. `rc.proj` passes `TFMs=all` so PackAll includes net472. PackLite produces `.Lite` RC packages.
- **net11 / WebView2:** RC uses the latest **stable** WebView2 package, matching master. Canary/Nightly still use prerelease WebView2.
- **Case:** the branch name is `gold` (lowercase), unlike `canary.yml` which checks out `Canary`.

## Validation

1. Evaluate versions without a full pack:

   ```text
   dotnet msbuild "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -getProperty:PackageVersion -p:Configuration=RC -nologo -v:q
   dotnet msbuild "Source/Krypton Components/Krypton.Toolkit/Krypton.Toolkit 2022.csproj" -getProperty:PackageId -p:Configuration=RC -p:TFMs=all -nologo -v:q
   ```

   Expect `110.*.*.*-rc` and `Krypton.Toolkit`.

2. Optional local pack: `.\Scripts\VS2022\build-rc.cmd Pack` (or Current). Confirm nupkgs under `Bin/Packages/RC/`.

3. CI dry run: set `RC_DISABLED=true`, dispatch **RC Release** from `gold`, confirm the kill switch skips publish. Then disable the switch and use a `production` environment approval for a real publish.

There is no TestForm demo; this is a build/publish channel, not a control.
