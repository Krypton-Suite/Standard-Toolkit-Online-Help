# How to Build

## What

- The help content is a combination of code trawling and MarkDown files.

---

## Automated Build (GitHub Actions)

- The documentation is automatically built using GitHub Actions whenever changes are pushed to the main/master branch
- The workflow file is located at `.github/workflows/docfx-build.yml`
- The built documentation is automatically deployed to GitHub Pages
- To enable this:
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

## API metadata (toolkit source)

DocFX extracts API reference from **sibling** clones next to this repository (same parent folder, e.g. `Z:\Development\Krypton\`):

- Standard Toolkit → `../Standard-Toolkit/Source/Krypton Components/` → `api/`
- Extended Toolkit → `../Extended-Toolkit/Source/Krypton Toolkit/` → `api-extended/`

Keep those trees current when you want metadata to match local toolkit source. Standard and Extended metadata are generated for `net10.0-windows` only. Pinning that TFM is required because the toolkit projects multi-target (including .NET Framework, where `ReadOnlySpan<T>` comes from `System.Memory` rather than the BCL).

DocFX runs a bare `dotnet restore` and does **not** pass `metadata.properties` into that restore. `build-docfx.ps1` therefore installs temporary `Directory.Build.rsp` files under the sibling Standard/Extended trees (`TFMs=all`, `Configuration=Release` for Extended, `TargetFramework=net10.0-windows`) for the duration of the run, then removes them. Without that, Extended restores `net472` against default `Krypton.Toolkit.Lite` and fails with NU1201. Extended also skips Ultimate/Lite aggregates, tests, examples, and helper tools.

DocFX cannot take a Git URL in `metadata.src`. If a sibling folder is missing, `run.cmd` clones [Krypton-Suite/Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) and/or [Krypton-Suite/Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit) there as a fallback. GitHub Actions checks out the same repositories beside this repo.

---

## Build

### Option 1: Build and Serve (Recommended for Development)

- Open a command line at the `Source/Help/DocFX` directory
- Run the following command to build and serve the documentation:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-docfx.ps1 -Serve
```

- Now you can view the generated website at [http://localhost:8080](http://localhost:8080)

### Option 2: Build Only

- Navigate to the `Source/Help/DocFX` directory
- Run:

```cmd
powershell -NoProfile -ExecutionPolicy Bypass -File .\build-docfx.ps1
```

- The output will be generated in `Source/Help/Output`
- The build script sets the footer's ending year to the current year.

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
