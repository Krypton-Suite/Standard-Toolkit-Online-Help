# How to Build

## What:
- The help content is a combination of code trawling and MarkDown files.
---

## Applications:
- The Help files are built via `DocFX`, Download the latest from https://github.com/dotnet/docfx/releases
- Unzip to your favourite location
- Get a good Markdown editor (Either inside visual studio, or standalone - e.g. `MarkDownPad 2`)
---

## Help Files:
- Edit the md file(s) [in the `DocFX\articles` subdirectory] to reflect the content, and add the pictures into the images directory.
- If new content is added then update the `yml index` files.
---


## Buid:
- Open a command line at the Help directory
- Copy in the location of the DocFX.exe
- Copy the following onto the end of the command line to "build" and then "serve" html help generated
```cmd
docfx\docfx.json --serve
```
- e.g 
```cmd 
<##PATH-TO-HELP##>\Help>Z:\DocFX\docfx.exe docfx\docfx.json --serve
```
- Now you can view the generated website on http://localhost:8080.
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