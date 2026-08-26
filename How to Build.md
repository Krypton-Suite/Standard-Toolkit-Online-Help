# How to Build

## What

- The help content is a combination of code trawling and MarkDown files.

---

## Automated Build (GitHub Actions)

- **Validation:** `.github/workflows/build.yml` builds DocFX for toolkit branches `master`, `alpha`, and `V105-LTS` on push/PR.
- **Publish (NuGet versions):** `.github/workflows/publish-docs-version.yml` publishes `/v/<PackageVersion>/` to GitHub Pages.
- To enable Pages: Settings → Pages → Source = GitHub Actions.

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

## API metadata (toolkit source)

DocFX extracts API reference from **sibling** clones next to this repository (same parent folder, e.g. `Z:\Development\Krypton\`):

- Standard Toolkit → `../Standard-Toolkit/Source/Krypton Components/` → `api/`
- Extended Toolkit → `../Extended-Toolkit/Source/Krypton Toolkit/` → `api-extended/`

Keep those trees current when you want metadata to match local toolkit source. Standard and Extended metadata are generated for `net10.0-windows` only. Pinning that TFM is required because the toolkit projects multi-target (including .NET Framework, where `ReadOnlySpan<T>` comes from `System.Memory` rather than the BCL). Extended also skips Ultimate/Lite aggregates, tests, examples, and helper tools.

DocFX cannot take a Git URL in `metadata.src`. If a sibling folder is missing, `run.cmd` clones [Krypton-Suite/Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) and/or [Krypton-Suite/Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit) there as a fallback. GitHub Actions checks out the same repositories beside this repo.

---

## Build

### Option 1: Build and Serve (Recommended for Development)

From the repository root:

```cmd
run.cmd
```

Or from `Source/Help/DocFX`:

```cmd
docfx docfx.json --serve
```

View at [http://localhost:8080](http://localhost:8080).

### Option 2: Build current siblings into `v/local-dev`

```cmd
run.cmd build
```

### Option 3: Build API docs for master, alpha, and V105-LTS

```cmd
run.cmd all
```

Or:

```powershell
.\Scripts\Build-VersionedDocs.ps1 -BranchTips
.\Scripts\Build-VersionedDocs.ps1 -Branch master
```

Output: `Source/Help/Output/site/v/master/`, `v/alpha/`, `v/v105-lts/`.

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
