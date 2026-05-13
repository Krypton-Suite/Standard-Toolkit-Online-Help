# GitHub Workflows Documentation

This directory contains comprehensive developer documentation for all GitHub Actions workflows used in the Krypton Standard Toolkit repository.

## Overview

The repository uses several automated workflows to handle builds, releases, issue management, and pull request automation. Each workflow is documented in detail to help developers understand their purpose, configuration, and behavior.

## Available Workflows

### Build & CI Workflows

- **[Build Workflow](Workflows/BuildWorkflow.md)** - Continuous Integration workflow that builds the solution on pull requests and pushes to main branches. Ensures code quality and build integrity before merging.

### Release Workflows

- **[Release Workflow](Workflows/ReleaseWorkflow.md)** - Handles automated releases for stable, canary, alpha, and LTS branches. Builds, packages, and publishes NuGet packages to nuget.org with Discord notifications.

- **[Nightly Workflow](Workflows/NightlyWorkflow.md)** - Scheduled nightly builds that automatically create and publish bleeding-edge builds from the `alpha` branch. Includes change detection to skip builds when no changes are present.

- **[Canary LTS Release Workflow](Workflows/CanaryLTSReleaseWorkflow.md)** - Handles automated canary LTS releases and publishes NuGet packages to nuget.org with Discord notifications.

### Automation Workflows

- **[Auto-Assign PR Author](Workflows/AutoAssignPRAuthorWorkflow.md)** - Automatically assigns the pull request author as an assignee when a PR is opened, with special handling for Dependabot PRs.

- **[Auto-Label Issue Areas](Workflows/AutoLabelIssueAreasWorkflow.md)** - Automatically labels issues based on the "Areas Affected" field in bug reports and prefixes issue titles based on template type.

## Quick Reference

| Workflow | Trigger | Purpose | Output |
| --- | --- | --- | --- |
| Build | PR/Push/Manual | CI validation | Build artifacts |
| Release | Push to release branches/Manual | Stable releases | NuGet packages |
| Nightly | Schedule (00:00 UTC)/Manual | Bleeding-edge builds | Nightly NuGet packages |
| Auto-Assign PR | PR opened | Assign PR author | Assignment |
| Auto-Label Issues | Issue opened/edited | Label and title issues | Labels, title prefix |

## Workflow Dependencies

```text
┌─────────────────┐
│  Pull Request   │
└────────┬────────┘
         │
         ├──> Auto-Assign PR Author
         │
         └──> Build Workflow
                  │
                  └──> (if master) Release Workflow
                           │
                           └──> NuGet Publishing
                                    │
                                    └──> Discord Notification

┌─────────────────┐
│  Issue Created  │
└────────┬────────┘
         │
         └──> Auto-Label Issue Areas

┌─────────────────┐
│  Schedule (UTC) │
└────────┬────────┘
         │
         └──> Nightly Workflow
                  │
                  ├──> Change Detection
                  │
                  └──> (if changes) Build & Publish
```

## Configuration Requirements

### Required Secrets

- `NUGET_API_KEY` - API key for publishing packages to nuget.org
- `DISCORD_WEBHOOK_MASTER` - Webhook URL for **stable** and **V105-LTS** release notifications (`release-master`, `release-v105-lts`)
- `DISCORD_WEBHOOK_NIGHTLY` - Webhook URL for nightly build notifications
- `DISCORD_WEBHOOK_CANARY` - Webhook URL for canary release notifications

### Required Variables

- `NIGHTLY_DISABLED` - Kill switch for nightly builds (`nightly.yml` and **`release-alpha`** job guard pattern)
- `RELEASE_DISABLED` - Kill switch for **`release-master`** and **`release-v105-lts`**
- `CANARY_DISABLED` - Kill switch for canary releases (`release-canary`)
- `DOTNET_PREVIEW_SETUP_VERSION`, `DOTNET_PREVIEW_SDK_BAND`, `USE_DOTNET_PREVIEW` - Repository **Variables** for preview SDK behaviour (see [GitHub Actions Workflows](GitHubActionsWorkflows.md#repository-variables-net-preview--ci))

### Required Environments

- `production` - Protected environment used by release jobs (and nightly publish where configured); requires approval before publishing

## Branch Strategy

The workflows are designed around the following branch structure:

- **master** - Stable production releases
- **alpha** - Bleeding-edge development (nightly builds)
- **canary** - Pre-release testing builds
- **V105-LTS** - Long-Term Support branch (v105); **`release-v105-lts`** in `release.yml`, **`DISCORD_WEBHOOK_MASTER`**
- **gold** - Release candidate branch

## Troubleshooting

### Workflow Not Running

1. Check if the workflow file exists in `.github/workflows/`
2. Verify the trigger conditions (branch, event type)
3. Check for kill switch variables that might disable the workflow
4. Review workflow permissions in repository settings

### Build Failures

1. Check the workflow logs in the Actions tab
2. Verify .NET SDK versions are available
3. Ensure all required secrets are configured
4. Review MSBuild project files for configuration issues

### Release Issues

1. Verify NuGet API key is valid and has publish permissions
2. Check if packages already exist (duplicate version)
3. Review Discord webhook URLs if notifications fail
4. Check kill switch variables if releases are skipped

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [MSBuild Documentation](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild)
- [NuGet Package Publishing](https://docs.microsoft.com/en-us/nuget/nuget-org/publish-a-package)

## Contributing

When modifying workflows:

1. Test changes in a fork or feature branch first
2. Update the corresponding documentation file
3. Document any new secrets or variables required
4. Update this index if adding new workflows
5. Consider backward compatibility with existing processes
