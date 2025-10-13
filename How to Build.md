# How to Build

## What:
- The help content is a combination of code trawling and MarkDown files.
---

## Automated Build (GitHub Actions):
- The documentation is automatically built using GitHub Actions whenever changes are pushed to the main/master branch
- The workflow file is located at `.github/workflows/docfx-build.yml`
- The built documentation is automatically deployed to GitHub Pages
- To enable this:
  1. Go to your repository Settings → Pages
  2. Under "Source", select "GitHub Actions"
  3. The documentation will be available at `https://<username>.github.io/<repository-name>/`
---

## Manual Build (Local Development):

### Applications:
- The Help files are built via `DocFX`, which can be installed as a .NET tool
- Install DocFX globally: `dotnet tool install -g docfx`
- Get a good Markdown editor (Either inside visual studio, or standalone - e.g. `MarkDownPad 2`)
---

## Help Files:
- Edit the md file(s) [in the `DocFX\articles` subdirectory] to reflect the content, and add the pictures into the images directory.
- If new content is added then update the `yml index` files.
---


## Build:
### Option 1: Build and Serve (Recommended for Development)
- Open a command line at the `Source/Help/DocFX` directory
- Run the following command to build and serve the documentation:
```cmd
docfx docfx.json --serve
```
- Now you can view the generated website on http://localhost:8080

### Option 2: Build Only
- Navigate to the `Source/Help/DocFX` directory
- Run:
```cmd
docfx docfx.json
```
- The output will be generated in `Source/Help/Output`
### Tip 
- run `cls` after each `serve`, so that you can see *fresh* information each time
----



## Fixing:
- If you have any Red or yellow text in the build output, then you will need to edit the files referenced and rebuild.
- You can add `--force --logLevel Verbose` to the command line to help
   - Other levels exist `Warning, Info`
---

## More Info:
- http://dotnet.github.io/docfx/tutorial/walkthrough/walkthrough_overview.html