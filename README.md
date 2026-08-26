# Krypton Standard Toolkit Online Help

This repository contains the documentation for the Krypton Standard Toolkit, built using DocFX.

## Documentation

View the online documentation at: [Krypton Standard Toolkit Documentation](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/)

Published site layout:

| Path | Content |
|------|---------|
| `/` | Redirects to `/master/` |
| `/master/` | Articles + Standard/Extended API from toolkit `master` |
| `/alpha/` | Same layout from toolkit `alpha` |
| `/v105-lts/` | Same layout from toolkit `V105-LTS` |

Articles are shared across versions; API pages reflect the selected toolkit branch tip. Use the version dropdown in the site navbar to switch.

> **Note:** Bookmarks to the old root `/api/...` paths should use `/master/api/...` (or another version prefix) after this cutover.

## Automated Builds

Documentation is automatically built and deployed using GitHub Actions:
- Builds automatically on every push to main/master
- Validates on pull requests
- Builds `master`, `alpha`, and `V105-LTS` in parallel, then merges into one GitHub Pages site

See [Setup Guide](.github/SETUP_GITHUB_PAGES.md) for configuration details.

## Local Development

Local builds expect **sibling** clones of [Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) and [Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit) at `../Standard-Toolkit/` and `../Extended-Toolkit/` (same parent folder as this repo). If a sibling is missing, `run.cmd` clones the GitHub repository there as a fallback.

```bash
# Install DocFX
dotnet tool install -g docfx

# Fast loop: serve docs from current sibling toolkit checkouts
run.cmd

# Build current siblings into Source/Help/Output/site/master/
run.cmd build

# Build all three versions (clones under .toolkit-src/ when not using siblings)
run.cmd all
```

Or with PowerShell directly:

```powershell
.\Scripts\Build-VersionedDocs.ps1 -All
.\Scripts\Build-VersionedDocs.ps1 -Branch alpha
.\Scripts\Build-VersionedDocs.ps1 -Branch master -UseSiblings -SkipClone -OutputRoot Source\Help\Output\site
```

For more details, see [How to Build.md](How%20to%20Build.md).
