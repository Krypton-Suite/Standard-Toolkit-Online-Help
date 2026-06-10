# GitHub Workflows Documentation

This directory contains comprehensive developer documentation for all GitHub Actions workflows used in the Krypton Standard Toolkit repository.

## Overview

The repository uses several automated workflows to handle builds, releases, issue management, and pull request automation. Each workflow is documented in detail to help developers understand their purpose, configuration, and behavior.

## Available Workflows

### Build & CI Workflows

- **[Build Workflow](Workflows/BuildWorkflow.md)** - Continuous Integration workflow that builds the solution on pull requests and pushes to main branches. Ensures code quality and build integrity before merging.
- **[Build TestForm Workflow](Workflows/BuildTestFormWorkflow.md)** - Validates restore/build of the TestForm sample and checks linked `.resx` resources.
- **[CodeQL Workflow](Workflows/CodeQLWorkflow.md)** - Runs CodeQL security and quality analysis on PRs, pushes, and a weekly schedule.

### Release Workflows

- **[Release Workflow](Workflows/ReleaseWorkflow.md)** - Handles automated releases for stable, canary, alpha, and LTS branches. Builds, packages, and publishes NuGet packages to nuget.org with Discord notifications.

- **[Nightly Workflow](Workflows/NightlyWorkflow.md)** - Scheduled **Nightly Release** from `alpha` (`windows-2025-vs2026`, `nightly.proj`). Skips when no commits in 24h unless `NIGHTLY_RELEASE_RETENTION_CHECK_DAYS` / manual `retention_check_days` applies; WebView2 prerelease cache; NuGet guard on push.

- **[Canary LTS Release Workflow](Workflows/CanaryLTSReleaseWorkflow.md)** - Handles automated canary LTS releases and publishes NuGet packages to nuget.org with Discord notifications.
- **[Canary Workflow](Workflows/CanaryWorkflow.md)** - Standalone canary release pipeline that builds and publishes from the `Canary` branch.
- **[Templates Release Workflow](Workflows/TemplatesReleaseWorkflow.md)** - Builds and publishes Visual Studio template ZIP and VSIX artifacts to GitHub Releases.

### Automation Workflows

- **[Auto-Assign PR Author](Workflows/AutoAssignPRAuthorWorkflow.md)** - Automatically assigns the pull request author as an assignee when a PR is opened, with special handling for Dependabot PRs.

- **[Auto-Label Issue Areas](Workflows/AutoLabelIssueAreasWorkflow.md)** - Automatically labels issues based on the "Areas Affected" field in bug reports and prefixes issue titles based on template type.
- **[Auto-complete Linked Issues](Workflows/AutoCompleteIssuesWorkflow.md)** - Closes linked issues and applies completion labels on merged PRs in the configured branch direction.
- **[Auto-label PR Backup Workflow](Workflows/AutoLabelPRBackupWorkflow.md)** - Adds backup-maintenance labels to `alpha` -> `alpha-backup` PRs that modify backup automation.
- **[Alpha Backup Sync](AlphaBackupSync.md)** - Nightly/manual automation to sync `alpha` into `alpha-backup`, with optional backup-repo push and Discord notifications.
- **[Repository Mirror](Workflows/RepositoryMirror.md)** - Mirrors major branches (`master`, `gold`, `canary`, `alpha`, `V105-LTS`, `V85-LTS`) and tags to a separate GitHub repository via force-push. **Requires the workflow file on `master` for the daily schedule.**
- **[Repository Restore from Mirror](Workflows/RepositoryRestoreFromMirrorWorkflow.md)** - Manual-only workflow to restore branches (and optionally tags) from the mirror back into the source repo. Supports dry run (default), `new_branch`, point-in-time `restore_date`, and guarded `force_push`. Umbrella guide: [Repository backup and restore](Workflows/RepositoryBackupAndRestore.md).

### Branch policy and CI alignment ([#3610](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3610))

- **[Branch policy and workflow hardening](BranchPolicyandWorkflowHardening.md)** - Overview: PR pairing rules, `.github/`-only propagation from `master`, warn-then-fail rollout.
- **[PR branch policy](Workflows/PRBranchPolicyWorkflow.md)** - Validates pull request base/head pairings on same-repo PRs (no master ancestry check).
- **[Sync .github from master](Workflows/SyncGitHubFromMasterWorkflow.md)** - Opens automated PRs copying only `.github/` from `master` to release branches (path checkout, not merge).

**Promotion guards (separate):** [Branch promotion policy](BranchPromotionPolicy.md) documents `alpha` → `canary` → `gold` → `master` source-branch enforcement.

## Quick Reference

| Workflow | Trigger | Purpose | Output |
| --- | --- | --- | --- |
| Build | PR/Push/Manual | CI validation | Build artifacts |
| Build TestForm | PR/Push/Manual | Validate TestForm sample + linked resources | CI validation logs |
| CodeQL Advanced | PR/Push/Schedule | Security and quality static analysis | Code scanning alerts |
| Release | Push to release branches/Manual | Stable releases | NuGet packages |
| Nightly | Schedule (00:00 UTC)/Manual | Bleeding-edge builds | Nightly NuGet packages |
| Canary Release | Push to `Canary`/Manual | Standalone canary publishing | Canary NuGet packages |
| Templates Release | Push on `Templates/**`/Manual | Publish VS template assets | ZIP + VSIX release assets |
| Auto-Assign PR | PR opened | Assign PR author | Assignment |
| Auto-Label Issues | Issue opened/edited | Label and title issues | Labels, title prefix |
| Auto-complete Issues | PR closed (merged, gated branches)/Manual | Label + close linked issues and clear assignees | Issue lifecycle updates |
| Auto-label PR Backup | PR opened/sync/reopened (`alpha` -> `alpha-backup`) | Tag backup workflow modification PRs | PR label updates |
| Alpha Backup Sync | Schedule (00:00 UTC)/Manual | Sync `alpha` to `alpha-backup` + optional off-repo backup | PR sync + optional backup snapshot |
| Repository Mirror | Push to major branches/Schedule (02:00 UTC)/Manual (optional dry run) | Mirror branches + tags to external repo | Force-pushed refs on mirror repo |
| Repository Restore from Mirror | Manual only | Restore branches/tags from mirror to source | `restore/…` branches or force-pushed tips |
| PR branch policy | PR opened/sync/reopened (same repo) | Validate branch pairing and `.github/`-only rules | Warnings or failed check |
| Sync .github from master | Push to `master` (`.github/**`)/Mon 03:30 UTC/Manual | Copy `.github/` tree to release branches | Sync PRs per target branch |

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
- `MIRROR_REPO`, `MIRROR_BRANCHES`, `MIRROR_SYNC_TAGS`, `REPO_MIRROR_DISABLED` - Repository Mirror configuration (see [Repository Mirror](Workflows/RepositoryMirror.md#configuration-reference))

### Mirror & backup secrets (optional)

- `MIRROR_REPO_TOKEN` - PAT with **Contents: write** on the mirror target repository
- `DISCORD_WEBHOOK_MIRROR` - Discord webhook for mirror run notifications
- `BACKUP_REPO_TOKEN`, `DISCORD_WEBHOOK_ALPHA_BACKUP` - Alpha Backup Sync (see [Alpha Backup Sync](AlphaBackupSync.md))

### Required Environments

- `production` - Protected environment used by release jobs (and nightly publish where configured); requires approval before publishing

## Branch Strategy

The workflows are designed around the following branch structure:

- **master** - Stable production releases
- **alpha** - Bleeding-edge development (nightly builds)
- **canary** - Pre-release testing builds
- **V105-LTS** - Long-Term Support branch (v105); **`release-v105-lts`** in `release.yml`, **`DISCORD_WEBHOOK_MASTER`**
- **gold** - Release candidate branch
- **V85-LTS** - Long-Term Support branch (v85); mirrored by [Repository Mirror](Workflows/RepositoryMirror.md) when present on source

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
