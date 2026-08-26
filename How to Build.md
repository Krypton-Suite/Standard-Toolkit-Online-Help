# How to Build

## What

- The help content is a combination of code trawling and MarkDown files.
- Published output is a **multi-version** site: `/master/`, `/alpha/`, `/v105-lts/`, with `/` redirecting to `/master/`.

---

## Automated Build (GitHub Actions)

- The documentation is built by `.github/workflows/build.yml` on push/PR to main/master.
- A matrix builds Standard + Extended API for toolkit branches `master`, `alpha`, and `V105-LTS` in parallel.
- A merge job stitches the three trees, adds the root redirect, and deploys to GitHub Pages.
- To enable Pages:
  1. Go to your repository Settings → Pages
  2. Under "Source", select "GitHub Actions"
  3. The documentation will be available at `https://<username>.github.io/<repository-name>/`

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
- Articles are **shared** across version trees; only API metadata changes per toolkit branch.

## API metadata (toolkit source)

DocFX extracts API reference from toolkit clones:

- Standard Toolkit → `Source/Krypton Components/` → `api/`
- Extended Toolkit → `Source/Krypton Toolkit/` → `api-extended/`

**Local fast path:** sibling folders next to this repo (`../Standard-Toolkit/`, `../Extended-Toolkit/`).

**Multi-version path:** `Scripts/Build-VersionedDocs.ps1` clones each branch under `.toolkit-src/` (gitignored) unless `-UseSiblings` is set.

Metadata is generated for **`net8.0-windows`** only (common TFM across master / alpha / V105-LTS). Both Standard and Extended metadata allow compilation errors so a broken module (or missing optional NuGet) does not abort the whole docs build. Extended skips Ultimate/Lite aggregates, tests, examples, and helper tools. Standard skips `TestForm` and `Krypton.Standard.Toolkit`. Unresolved article xrefs are warnings (see `rules` in `docfx.json`).

DocFX cannot take a Git URL in `metadata.src`. GitHub Actions checks out both toolkits at the matrix branch beside this repo.

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

### Option 2: Build current siblings into `site/master`

```cmd
run.cmd build
```

Output: `Source\Help\Output\site\master\` plus root redirect at `site\index.html`.

### Option 3: Build all versions (master, alpha, V105-LTS)

```cmd
run.cmd all
```

Or:

```powershell
.\Scripts\Build-VersionedDocs.ps1 -All -OutputRoot Source\Help\Output\site
```

Output:

```text
Source/Help/Output/site/
  index.html      → redirects to master/
  master/
  alpha/
  v105-lts/
```

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
