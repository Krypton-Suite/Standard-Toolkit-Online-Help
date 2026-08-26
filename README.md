# Krypton Standard Toolkit Online Help

This repository contains the documentation for the Krypton Standard Toolkit, built using DocFX.

## Documentation

View the online documentation at: [Krypton Standard Toolkit Documentation](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/)

Published site layout:

| Path | Content |
|------|---------|
| `/` | Redirects to latest Stable (`versions.json` → `default`) |
| `/versions.json` | Catalog for the navbar version dropdown |
| `/v/<PackageVersion>/` | Articles + Standard/Extended API for that NuGet version |

Channels: **Stable** and **LTS** keep every published version; **Canary** and **Nightly** keep latest only. Dropdown labels are exact NuGet version strings.

> **Note:** Older bookmarks to `/master/...`, `/alpha/...`, or `/v105-lts/...` should use `/v/<PackageVersion>/...` after the NuGet-aligned cutover.

## Automated Builds

| Workflow | Role |
|----------|------|
| `.github/workflows/build.yml` | PR/push validation — disposable `v/local-dev/` only |
| `.github/workflows/publish-docs-version.yml` | Publish one version to the `docs-versions` branch and deploy Pages |

Publishing is triggered by `repository_dispatch` (`docs-publish`) from Standard-Toolkit after a NuGet push, or manually via **Actions → Publish Docs Version**.

**Secret (in Standard-Toolkit):** a PAT with `actions:write` on this repo (e.g. `DOCS_DISPATCH_TOKEN`) so release workflows can dispatch. See [Publish Docs From Toolkit](Source/Help/DocFX/articles/Contributing/Workflows/PublishDocsFromToolkit.md).

See [Setup Guide](.github/SETUP_GITHUB_PAGES.md) for Pages configuration.

## Local Development

Local builds expect **sibling** clones of [Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) and [Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit) at `../Standard-Toolkit/` and `../Extended-Toolkit/`. If a sibling is missing, `run.cmd` clones the GitHub repository there as a fallback.

```bash
# Install DocFX
dotnet tool install -g docfx

# Fast loop: serve docs from current sibling toolkit checkouts
run.cmd

# Build current siblings into Source/Help/Output/site/v/local-dev/
run.cmd build
```

Or with PowerShell:

```powershell
.\Scripts\Build-VersionedDocs.ps1 -LocalDev -UseSiblings -SkipClone -OutputRoot Source\Help\Output\site

.\Scripts\Build-VersionedDocs.ps1 `
  -Channel stable `
  -Version 110.26.11.328 `
  -StandardRef <sha-or-tag> `
  -ExtendedRef <sha-or-tag>
```

For more details, see [How to Build.md](How%20to%20Build.md) and [Versions](Source/Help/DocFX/articles/Versions.md).
