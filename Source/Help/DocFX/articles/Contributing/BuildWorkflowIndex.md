# Build Workflows Documentation

## Overview

This document provides an index to build workflow documentation for the Krypton Standard Toolkit. Build workflows are automated processes that handle continuous integration, validation, and release processes.

## Build Workflow Documentation

### [Build Workflow](Workflows/BuildWorkflow.md)

The primary CI/CD workflow that validates code quality and creates releases.

**Key Features**:
- ✅ Validates all pull requests
- ✅ Multi-framework builds (.NET Framework 4.7.2 - 4.8.1, .NET 8 - 10)
- ✅ Automated GitHub releases for master branch
- ✅ NuGet package caching for performance
- ✅ Fork protection

**Triggers**:
- Pull requests to any branch
- Push to protected branches (master, alpha, canary, gold, V85-LTS)
- Manual: workflow_dispatch

**Documentation**: [Full Build Workflow Documentation →](Workflows/BuildWorkflow.md)

---

### [Release Workflow](Workflows/ReleaseWorkflow.md)

Handles automated releases for stable, canary, alpha, and LTS branches.

**Documentation**: [Release Workflow Documentation →](Workflows/ReleaseWorkflow.md)

---

### [Nightly Workflow](Workflows/NightlyWorkflow.md)

Scheduled nightly builds that automatically create and publish bleeding-edge builds.

**Documentation**: [Nightly Workflow Documentation →](Workflows/NightlyWorkflow.md)

---

## Related Documentation

### Build System

For comprehensive build system documentation, see:
- [Build System Documentation Index](BuildSystemDocumentationIndex.md) - Complete guide to the build system, MSBuild files, scripts, and configuration

### GitHub Actions

For general GitHub Actions workflow information, see:
- [GitHub Actions Workflows](GitHubActionsIndex.md) - Overview of all GitHub Actions workflows
- [GitHub Workflow Index](GitHubWorkflowIndex.md) - Index of all GitHub workflows

## Quick Reference

| Workflow | Purpose | Trigger | Output |
|----------|---------|---------|--------|
| Build | CI validation | PR/Push/Manual | Build artifacts |
| Release | Stable releases | Push to release branches/Manual | NuGet packages |
| Nightly | Bleeding-edge builds | Schedule (00:00 UTC)/Manual | Nightly NuGet packages |

## Common Tasks

### Understanding Build Workflows

1. Start with [Build Workflow](Workflows/BuildWorkflow.md) for CI/CD processes
2. Review [Release Workflow](Workflows/ReleaseWorkflow.md) for release processes
3. Check [Nightly Workflow](Workflows/NightlyWorkflow.md) for automated nightly builds

### Troubleshooting Build Issues

1. Check workflow logs in the GitHub Actions tab
2. Review [Build Workflow Documentation](Workflows/BuildWorkflow.md#troubleshooting)
3. Verify required secrets and variables are configured
4. Check kill switch variables if workflows are disabled

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [MSBuild Documentation](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild)
- [NuGet Package Publishing](https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package)

