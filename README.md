# Krypton Standard Toolkit Online Help

This repository contains the documentation for the Krypton Standard Toolkit, built using DocFX.

## 📚 Documentation

View the online documentation at: [Krypton Standard Toolkit Documentation](https://krypton-suite.github.io/Standard-Toolkit-Online-Help/)

## 🔄 Automated Builds

Documentation is automatically built and deployed using GitHub Actions:
- ✅ Builds automatically on every push to main/master
- ✅ Validates on pull requests
- ✅ Deploys to GitHub Pages

See [Setup Guide](.github/SETUP_GITHUB_PAGES.md) for configuration details.

## 🛠️ Local Development

Local builds expect **sibling** clones of [Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) and [Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit) at `../Standard-Toolkit/` and `../Extended-Toolkit/` (same parent folder as this repo). Standard API pages come from the first clone; Extended API pages from the second. If a sibling is missing, `run.cmd` clones the GitHub repository there as a fallback.

To build the documentation locally:

```bash
# Install DocFX
dotnet tool install -g docfx

# Navigate to the DocFX directory
cd Source/Help/DocFX

# Build and serve locally
docfx docfx.json --serve
```

Then open http://localhost:8080 in your browser.

For more details, see [How to Build.md](How%20to%20Build.md).
