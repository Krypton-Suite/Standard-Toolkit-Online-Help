# Documentation versions

This site publishes a separate documentation tree for each **NuGet package version** that has been released. Trees live under `/v/<PackageVersion>/`. The site root redirects to the latest **Stable** version listed in `versions.json`.

## Channels and retention

| Channel | Typical package id | Path example | Retention |
|---------|-------------------|--------------|-----------|
| **Stable** | `Krypton.Standard.Toolkit` | `/v/110.26.11.328/` | Keep every published version |
| **LTS** | `Krypton.Standard.Toolkit` (from an LTS line, e.g. `V105-LTS`) | `/v/105.25.11.310/` | Keep every published version |
| **Canary** | `Krypton.Standard.Toolkit.Canary` | `/v/110.26.6.173-beta/` | Latest only |
| **Nightly** | `Krypton.Standard.Toolkit.Nightly` | `/v/110.26.8.221-alpha/` | Latest only |

Dropdown labels use the **exact NuGet version string** (same as on nuget.org), grouped by channel. LTS entries may also record a `line` (e.g. `V105-LTS`); new LTS lines are added when those packages are published—nothing is hard-coded to a single LTS branch name.

## Site layout

```text
/
  index.html       → redirect to latest Stable
  versions.json    → catalog for the navbar dropdown
  v/<version>/     → full DocFX tree (articles + api + api-extended)
```

Conceptual articles are baked into each version tree at publish time. API pages reflect the toolkit sources at the SHA used for that NuGet package.

## How versions are published

1. A Stable / LTS / Canary / Nightly NuGet publish in **Standard-Toolkit** (or a manual `workflow_dispatch`) triggers `publish-docs-version.yml` in this repo.
2. DocFX builds against the release `standard_ref` / `extended_ref`.
3. Output is merged into the long-lived `docs-versions` branch (`v/<version>/`), old Canary/Nightly trees are pruned, and `versions.json` is updated.
4. That branch tree is deployed to GitHub Pages.

Until Standard-Toolkit emits `repository_dispatch` (`docs-publish`), use **Actions → Publish Docs Version** with channel, version, and git refs. See [Publishing docs from toolkit releases](Contributing/Workflows/PublishDocsFromToolkit.md).

Pushes and PRs to this repo only **validate** a disposable `v/local-dev/` build; they do not publish version trees.
