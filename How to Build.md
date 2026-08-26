# How to Build

## What

- The help content is a combination of code trawling and MarkDown files.
- Published output is a **NuGet-versioned** site: `/v/<PackageVersion>/`, with `/` redirecting to the latest Stable version from `versions.json`.

---

## Automated Build (GitHub Actions)

- **Validation:** `.github/workflows/build.yml` builds a disposable `v/local-dev/` tree on push/PR (does not publish Pages).
- **Publish:** `.github/workflows/publish-docs-version.yml` builds one NuGet version into the `docs-versions` branch and deploys GitHub Pages (triggered by `repository_dispatch` from Standard-Toolkit or manual `workflow_dispatch`).
- To enable Pages:
  1. Go to your repository Settings → Pages
  2. Under "Source", select "GitHub Actions"
  3. Docs URL: `https://<username>.github.io/<repository-name>/`

See [Versions](Source/Help/DocFX/articles/Versions.md) and [Publish Docs From Toolkit](Source/Help/DocFX/articles/Contributing/Workflows/PublishDocsFromToolkit.md).

---

## Manual Build (Local Development)

### Applications

- The Help files are built via `DocFX`, which can be installed as a .NET tool
- Install DocFX globally: `dotnet tool install -g docfx`
- Get a good Markdown editor (Either inside visual studio, or standalone - e.g. `MarkDownPad 2`)

---

## Help Files

- Edit the md file(s) [in the `DocFX\articles` subdirectory] to reflect the content, and add the pictures into the images directory.
- If new content is added then update the `yml index` files.
- Articles are included in each version tree at publish time.

## API metadata (toolkit source)

DocFX extracts API reference from toolkit clones:

- Standard Toolkit → `Source/Krypton Components/` → `api/`
- Extended Toolkit → `Source/Krypton Toolkit/` → `api-extended/`

**Local fast path:** sibling folders next to this repo (`../Standard-Toolkit/`, `../Extended-Toolkit/`).

**Published version path:** `Scripts/Build-VersionedDocs.ps1 -Channel … -Version … -StandardRef …` checks out toolkits at those refs under `.toolkit-src/` unless `-UseSiblings` is set.

Metadata is generated for **`net8.0-windows`**. Both Standard and Extended metadata allow compilation errors so a broken module does not abort the whole docs build. Extended skips Ultimate/Lite aggregates, tests, examples, and helper tools. Standard skips `TestForm` and `Krypton.Standard.Toolkit`. Unresolved article xrefs are warnings (see `rules` in `docfx.json`).

DocFX cannot take a Git URL in `metadata.src`. CI checks out both toolkits beside this repo.

---

## Build

### Option 1: Serve current siblings (fast)

From the repository root:

```cmd
run.cmd
```

Or:

```cmd
cd Source\Help\DocFX
docfx docfx.json --serve
```

View at [http://localhost:8080](http://localhost:8080).

### Option 2: Build current siblings into `site/v/local-dev`

```cmd
run.cmd build
```

Output: `Source\Help\Output\site\v\local-dev\` plus stub `versions.json` / root redirect.

### Option 3: Reproduce a published NuGet version

```powershell
.\Scripts\Build-VersionedDocs.ps1 `
  -Channel stable `
  -Version 110.26.11.328 `
  -StandardRef <sha-or-tag> `
  -ExtendedRef <sha-or-tag> `
  -OutputRoot Source\Help\Output\site
```

With `-UpdateCatalog`, also merges into `versions.json` and prunes old canary/nightly under that output root.

### Tip

- run `cls` after each `serve`, so that you can see *fresh* information each time

---

## Fixing

- If you have any Red or yellow text in the build output, then you will need to edit the files referenced and rebuild.
- You can add `--force --logLevel Verbose` to the command line to help
  - Other levels exist `Warning, Info`

---

## More Info

- [DocFX walkthrough overview](http://dotnet.github.io/docfx/tutorial/walkthrough/walkthrough_overview.html)
- [Versions](Source/Help/DocFX/articles/Versions.md)
- [Publish Docs From Toolkit](Source/Help/DocFX/articles/Contributing/Workflows/PublishDocsFromToolkit.md)
