# Setting Up Automated DocFX Documentation Builds with GitHub Actions

This guide explains how to set up documentation validation and NuGet-aligned publishing with GitHub Actions.

## Overview

| Workflow | Purpose |
|----------|---------|
| `.github/workflows/build.yml` | Validates DocFX on push/PR (`v/local-dev/` only; no Pages deploy) |
| `.github/workflows/publish-docs-version.yml` | Builds one NuGet version, merges into `docs-versions`, deploys Pages |

## Setup Instructions

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on **Settings** (gear icon at the top)
3. In the left sidebar, click on **Pages**
4. Under **Source**, select **GitHub Actions** from the dropdown
5. Click **Save**

### 2. Configure Repository Permissions

Publishing needs write access for the `docs-versions` branch and Pages:

1. Go to **Settings** → **Actions** → **General**
2. Scroll down to **Workflow permissions**
3. Ensure **Read and write permissions** is selected
4. Click **Save**

### 3. Publish a documentation version

**Manual:** Actions → **Publish Docs Version** → provide `channel`, `version`, `standard_ref`, and optional `extended_ref` / `line`.

**Automated (Standard-Toolkit):** after NuGet push, `repository_dispatch` with type `docs-publish`. Requires a PAT secret in Standard-Toolkit with `actions:write` on this repo. Documented in [Publish Docs From Toolkit](../Source/Help/DocFX/articles/Contributing/Workflows/PublishDocsFromToolkit.md).

### 4. Access Your Documentation

Once a publish completes:

- Site: `https://<username>.github.io/<repository-name>/`
- Example: `https://krypton-suite.github.io/Standard-Toolkit-Online-Help/`
- Version trees: `/v/<PackageVersion>/`
- Catalog: `/versions.json`

## Persistence (`docs-versions` branch)

GitHub Pages replaces the whole site each deploy. Historical Stable/LTS trees are stored on the long-lived `docs-versions` branch and re-deployed with each publish. Canary/Nightly keep only the latest tree of that channel.

## Validation workflow

`build.yml` checks out toolkit `master` siblings and builds `site/v/local-dev/` to catch DocFX/article regressions. It does **not** update `docs-versions` or Pages.

## Troubleshooting

- Missing Pages after push to main: expected — use **Publish Docs Version** (or wait for toolkit dispatch).
- Dropdown empty: `versions.json` has no entries until the first successful publish.
- Canary/Nightly disappeared: by design when a newer package of that channel is published.
