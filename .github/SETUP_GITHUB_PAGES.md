# Setting Up Automated DocFX Documentation Builds with GitHub Actions

This guide explains how to set up automated documentation builds using the GitHub Actions workflow included in this repository.

## Overview

The workflow (`.github/workflows/build.yml`) automatically:
- **Builds** the DocFX documentation when changes are pushed
- **Deploys** to GitHub Pages on pushes to main/master branches
- **Validates** documentation on pull requests (without deploying)

## Setup Instructions

### 1. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click on **Settings** (gear icon at the top)
3. In the left sidebar, click on **Pages**
4. Under **Source**, select **GitHub Actions** from the dropdown
5. Click **Save**

### 2. Configure Repository Permissions

The workflow requires specific permissions to deploy to GitHub Pages:

1. Go to **Settings** → **Actions** → **General**
2. Scroll down to **Workflow permissions**
3. Ensure **Read and write permissions** is selected
4. Check **Allow GitHub Actions to create and approve pull requests** (if needed)
5. Click **Save**

### 3. Trigger the Workflow

The workflow will automatically run when:
- Code is pushed to `main`, `master`
- A pull request is opened targeting `main` or `master`
- Manually triggered via the **Actions** tab

To manually trigger:
1. Go to the **Actions** tab in your repository
2. Select **Build and Deploy DocFX Documentation** from the left sidebar
3. Click **Run workflow** → **Run workflow**

### 4. Access Your Documentation

Once the workflow completes successfully:
- Your documentation will be available at: `https://<username>.github.io/<repository-name>/`
- For example: `https://krypton-suite.github.io/Standard-Toolkit-Online-Help/`

## Workflow Details

### Build Job
- Runs on: Windows (latest)
- Installs: .NET SDK 8.x and DocFX
- Builds: Documentation from `Source/Help/DocFX`
- Outputs: To `Source/Help/Output`

### Deploy Job
- Runs on: Ubuntu (latest)
- Triggers: Only on pushes to main/master branches
- Action: Deploys built documentation to GitHub Pages

## Customization

### Change Target Branches

Edit `.github/workflows/docfx-build.yml` to modify which branches trigger the workflow:

```yaml
on:
  push:
    branches:
      - main
      - your-branch-name
```

### Disable Automatic Deployment

To build without deploying, remove or comment out the `deploy` job section in the workflow file.

### Add Build Steps

You can add additional steps before or after the DocFX build, such as:
- Running tests
- Validating links
- Checking for broken references

## Troubleshooting

### Build Fails
- Check the **Actions** tab for detailed error logs
- Ensure `docfx.json` is valid
- Verify all referenced files and paths exist

### Deployment Fails
- Ensure GitHub Pages is enabled (see step 1)
- Check workflow permissions (see step 2)
- Verify the Pages source is set to "GitHub Actions"

### Documentation Not Updating
- Check if the workflow completed successfully in the Actions tab
- Clear your browser cache
- Wait a few minutes for GitHub Pages to update

## Additional Resources

- [DocFX Documentation](https://dotnet.github.io/docfx/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
- [Issue #22](https://github.com/Krypton-Suite/Standard-Toolkit-Online-Help/issues/22)

## Support

If you encounter issues:
1. Check the Actions logs for detailed error messages
2. Review the [DocFX troubleshooting guide](https://dotnet.github.io/docfx/docs/faq.html)
3. Open an issue in the repository with:
   - Error messages from the Actions log
   - Steps to reproduce the problem
   - Expected vs. actual behavior

