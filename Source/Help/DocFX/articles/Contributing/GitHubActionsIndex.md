# GitHub Actions Workflows Documentation

## Overview

This directory contains comprehensive documentation for all GitHub Actions workflows used in the Krypton Toolkit repository. Each workflow is documented in detail with purpose, configuration, usage examples, troubleshooting guides, and best practices.

---

## Quick Navigation

### Workflow Documentation

| Workflow | File | Purpose | Documentation |
| --- | --- | --- | --- |
| **Build** | `build.yml` | CI/CD validation and releases | [Build Workflow](Workflows/BuildWorkflow.md) |
| **Release** | `release.yml` | Multi-channel production releases | [Release Workflow](Workflows/ReleaseWorkflow.md) |
| **Nightly** | `nightly.yml` | Scheduled nightly builds | [Nightly Workflow](Workflows/NightlyWorkflow.md) |
| **Canary LTS** | `canary-lts-release.yml` | Canary packages from V105-LTS | [Canary LTS Release Workflow](Workflows/CanaryLTSReleaseWorkflow.md) |

---

## Workflow Summary

### [Build Workflow](Workflows/BuildWorkflow.md)

**File**: `.github/workflows/build.yml`

Primary CI/CD workflow for validating code quality and creating releases.

**Key Features**:

- ✅ Validates all pull requests
- ✅ Multi-framework builds (.NET Framework 4.7.2 - 4.8.1, .NET 8 - 11)
- ✅ Automated GitHub releases for master branch
- ✅ NuGet package caching for performance
- ✅ Fork protection

**Triggers**:

- Pull requests to any branch
- Push to protected branches (master, alpha, canary, gold, V105-LTS)
- Manual: workflow_dispatch

**Jobs**:

1. **build** - Compiles and validates code
2. **release** - Creates GitHub releases (master only)

**Documentation**: [Full Build Workflow Documentation →](Workflows/BuildWorkflow.md)

---

### [Release Workflow](Workflows/ReleaseWorkflow.md)

**File**: `.github/workflows/release.yml`

Handles production releases across **four** branch-specific jobs in [`release.yml`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/.github/workflows/release.yml).

**Key Features**:

- ✅ Four jobs: **`release-master`**, **`release-v105-lts`**, **`release-canary`**, **`release-alpha`**
- ✅ Automatic NuGet package publishing (where implemented)
- ✅ Discord webhook notifications (`DISCORD_WEBHOOK_MASTER` shared by master **and** **V105-LTS**)
- ✅ Multi-framework support via MSBuild scripts under `Scripts/Build/`
- ✅ Intelligent duplicate detection (`--skip-duplicate`)

**Triggers**:

- Push to: **master**, **alpha**, **canary**, **V105-LTS**
- Manual: **workflow_dispatch**

**Release channels**:

| Channel | Branch | Notes | Discord |
| --- | --- | --- | --- |
| **Stable** | `master` | `Scripts/Build/build.proj` | `DISCORD_WEBHOOK_MASTER` |
| **V105 line** | `V105-LTS` | Same stable packages as master; different branch | `DISCORD_WEBHOOK_MASTER` |
| **Canary** | `canary` | `canary.proj`, Canary packages | `DISCORD_WEBHOOK_CANARY` |
| **Alpha** | `alpha` | `nightly.proj`; primary NuGet publish often via **`nightly.yml`** | — (this workflow) / **`DISCORD_WEBHOOK_NIGHTLY`** in nightly |

**Jobs** (see [Release Workflow](Workflows/ReleaseWorkflow.md)):

1. **release-master**
2. **release-v105-lts**
3. **release-canary**
4. **release-alpha**

**Documentation**: [Full Release Workflow Documentation →](Workflows/ReleaseWorkflow.md)

---

### [Nightly Workflow](Workflows/NightlyWorkflow.md)

**File**: `.github/workflows/nightly.yml`

Automated nightly builds with intelligent change detection.

**Key Features**:

- ⏰ Scheduled execution (00:00 UTC daily)
- 🔍 Change detection (checks for commits in last 24 hours)
- 💰 Resource efficient (skips build when no changes)
- 📦 Automatic NuGet publishing
- 💬 Discord integration
- 🔧 Manual triggering support

**Triggers**:

- Scheduled: Daily at midnight UTC (`0 0 * * *`)
- Manual: workflow_dispatch

**Workflow Behavior**:

- **With Changes**: Builds, packs, publishes to NuGet, sends Discord notification
- **No Changes**: Skips all build steps, completes in ~2 minutes

**Target Branch**: alpha

**Documentation**: [Full Nightly Workflow Documentation →](Workflows/NightlyWorkflow.md)

---

## Getting Started

### For Contributors

**First Time Setup**:

1. Read [Build Workflow](Workflows/BuildWorkflow.md) to understand CI/CD process
2. Review [Release Workflow](Workflows/ReleaseWorkflow.md) for release channels
3. Familiarize yourself with [Nightly Workflow](Workflows/NightlyWorkflow.md) for daily builds

**Common Tasks**:

- **Submit a Pull Request**: See [Build Workflow Usage Examples](Workflows/BuildWorkflow.md#usage-examples)
- **Create a Release**: See [Release Workflow Usage Examples](Workflows/ReleaseWorkflow.md#usage-examples)

### For Maintainers

**Workflow Management**:

- **Update .NET SDKs**: Review all workflows for SDK version references
- **Rotate Secrets**: Check [Configuration](#configuration--secrets) section in each workflow
- **Monitor Builds**: Review workflow run history in GitHub Actions tab
- **Troubleshoot Issues**: Use troubleshooting sections in each workflow doc

**Best Practices**:

- Document any workflow modifications
- Keep all four workflow docs in sync
- Update version numbers in documentation when workflows change

---

## Configuration & Secrets

### Required Secrets

All secrets are configured at repository level (Settings → Secrets and variables → Actions).

| Secret | Required By | Purpose |
| --- | --- | --- |
| `NUGET_API_KEY` | All release workflows | Publish packages to nuget.org |
| `GITHUB_TOKEN` | Build, Release (master) | Create GitHub releases (automatic) |
| `DISCORD_WEBHOOK_MASTER` | Release (**master** and **V105-LTS**) | Stable / V105-line announcements |
| `DISCORD_WEBHOOK_CANARY` | Release (canary) | Canary announcements |
| `DISCORD_WEBHOOK_NIGHTLY` | Nightly, Release (alpha-related) | Nightly / alpha channel announcements |

**Documentation**: See individual workflow docs for detailed secret configuration.

### Build Scripts

| Script | Used By | Configuration | Purpose |
| --- | --- | --- | --- |
| `Scripts/Build/build.proj` | Release (**master**, **V105-LTS**) | Release | Stable production / V105-line builds |
| `Scripts/Build/canary.proj` | Release (canary), `canary.yml` | Canary | Canary builds |
| `Scripts/Build/nightly.proj` | Build, Nightly, Release (alpha) | Nightly | Development / CI builds |

---

## Workflow Decision Tree

### Which Workflow Runs When?

```plaintext
Event: Pull Request
├─ Any Branch → Build Workflow → Validation Only
└─ Result: Status check on PR

Event: Push to master
├─ Build Workflow → Build Job
└─ Build Workflow → Release Job (GitHub release)
└─ Release Workflow → release-master (NuGet + Discord)

Event: Push to alpha
└─ Release Workflow → release-alpha (NuGet + Discord)

Event: Push to canary
├─ Release Workflow → release-canary (NuGet + Discord)
└─ canary.yml (if using Canary branch) → Canary packages

Event: Push to V105-LTS
├─ Release Workflow → release-v105-lts (stable NuGet + Discord via MASTER webhook)
└─ Canary LTS Release Workflow → canary-lts-release (Canary packages from LTS branch)

Event: Cron Schedule (00:00 UTC)
└─ Nightly Workflow → Check changes → Build if needed

Event: Manual Trigger
└─ Any workflow with workflow_dispatch
```

---

## Target Frameworks

TFMs are driven by the solution and shared MSBuild props (`Directory.Build.props`, etc.), not by this index. **`release-master`** and **`release-v105-lts`** both consume **`Scripts/Build/build.proj`** and publish the same stable package IDs from different branches; **Canary** / **Nightly** jobs use **`canary.proj`** / **`nightly.proj`** with different package IDs.

| Area | Typical TFMs (see projects for exact roll-forward) |
| --- | --- |
| **CI (`build.yml`)** | Multi-target build via `nightly.proj` / solution — **.NET Framework 4.7.2–4.8.1**, **.NET 8–11** windows TFMs as defined in the repo |
| **Standalone** | `canary.yml` (Canary branch), `canary-lts-release.yml` (**V105-LTS** canary packages) |

**Note**: Older documentation referred to a separate **V85-LTS** / `longtermstable.proj` pipeline; the current [`release.yml`](https://github.com/Krypton-Suite/Standard-Toolkit/blob/master/.github/workflows/release.yml) has **four** jobs only (`release-master`, `release-v105-lts`, `release-canary`, `release-alpha`).

---

## Common Tasks

### How Do I...?

#### Validate My Pull Request

**Workflow**: [Build Workflow](Workflows/BuildWorkflow.md)

1. Create feature branch
2. Push changes
3. Open pull request
4. Build workflow runs automatically
5. Fix any failures before merging

#### Create a Stable Release

**Workflow**: [Release Workflow - Master](Workflows/ReleaseWorkflow.md#job-1-release-master)

1. Update version in project files
2. Commit to master branch
3. Push to master
4. Workflow creates NuGet packages, GitHub release, and Discord notification

#### Create an LTS-line release (V105)

**Workflow**: [Release Workflow — `release-v105-lts`](Workflows/ReleaseWorkflow.md#job-2-release-v105-lts)

1. Merge or cherry-pick to **`V105-LTS`**
2. Push to **`V105-LTS`**
3. **`release-v105-lts`** builds with **`Scripts/Build/build.proj`** and publishes stable packages (same webhook as master unless you change the workflow)

#### Test a Workflow Change

1. Push to alpha branch
2. Manually trigger test workflow
3. Review results
4. Migrate changes to production if successful

#### Force a Nightly Build

**Workflow**: [Nightly Workflow](Workflows/NightlyWorkflow.md)

1. Go to Actions → Nightly Release
2. Click "Run workflow"
3. Select alpha branch
4. Click "Run workflow" button

#### Check Workflow Status

1. Navigate to repository
2. Click "Actions" tab
3. Select workflow from left sidebar
4. View recent runs and logs

---

## Troubleshooting

### Quick Troubleshooting Guide

| Issue | Likely Workflow | Solution Link |
| --- | --- | --- |
| PR build fails | Build | [Build Troubleshooting](Workflows/BuildWorkflow.md#troubleshooting) |
| NuGet push fails | Any release | [Release Troubleshooting](Workflows/ReleaseWorkflow.md#troubleshooting) |
| Discord notification not sent | Release/Nightly | [Nightly Troubleshooting](Workflows/NightlyWorkflow.md#troubleshooting) |
| GitHub release creation fails | Build | [Build Troubleshooting](Workflows/BuildWorkflow.md#troubleshooting) |
| Nightly build always skipped | Nightly | [Nightly Troubleshooting](Workflows/NightlyWorkflow.md#troubleshooting) |

### Common Issues Across Workflows

#### Multi-Targeting Build Failures

**Symptom**: `error NETSDK1045: The current .NET SDK does not support targeting .NET X.X`

**Solution**:

1. Check SDK setup steps in workflow logs
2. Verify `continue-on-error` is set for optional SDKs
3. Review global.json generation logic

#### NuGet Package Already Exists

**Symptom**: `Package already exists - skipped`

**Expected**: This is normal; increment version to publish new package

#### Workflow Not Triggering

**Symptom**: Workflow doesn't run at expected time

**Common Causes**:

- Workflow file not on correct branch
- GitHub Actions disabled in settings
- Branch protection preventing push
- Cron schedule timezone confusion

---

## Best Practices

### Workflow Development

1. **Document Changes**: Update workflow docs when modifying workflows
2. **Version Control**: Commit workflow changes with clear messages
3. **Review Logs**: Always review workflow logs after changes
4. **Monitor Performance**: Track workflow duration and optimize

### Release Management

1. **Version Discipline**: Increment versions consistently
2. **Test Releases**: Validate in canary before stable
3. **Communicate**: Announce releases to users
4. **Monitor**: Watch for issues after releases
5. **Document**: Update changelog with releases

### Security

1. **Rotate Secrets**: NuGet API keys every 90-180 days
2. **Minimum Permissions**: Use narrowest scopes
3. **Monitor Activity**: Watch for unauthorized publishes
4. **Enable 2FA**: On NuGet and GitHub accounts
5. **Never Commit**: Keep secrets out of version control

### Maintenance

1. **Quarterly SDK Updates**: Update .NET versions
2. **Action Version Updates**: Keep GitHub Actions up to date
3. **Regular Reviews**: Review workflow performance monthly
4. **Clean Up**: Remove old test packages from NuGet
5. **Documentation**: Keep docs in sync with workflows

---

## Additional Resources

### GitHub Actions Documentation

- [GitHub Actions Overview](https://docs.github.com/actions)
- [Workflow Syntax](https://docs.github.com/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

### .NET Documentation

- [.NET SDK Download](https://dotnet.microsoft.com/download)
- [MSBuild Reference](https://learn.microsoft.com/visualstudio/msbuild)
- [Multi-Targeting](https://learn.microsoft.com/dotnet/standard/frameworks)

### NuGet Documentation

- [NuGet Package Publishing](https://learn.microsoft.com/nuget/nuget-org/publish-a-package)
- [NuGet API Keys](https://learn.microsoft.com/nuget/nuget-org/scoped-api-keys)
- [Package Versioning](https://learn.microsoft.com/nuget/concepts/package-versioning)

### Discord Integration

- [Discord Webhook Guide](https://discord.com/developers/docs/resources/webhook)
- [Discord Embed Formatting](https://discord.com/developers/docs/resources/channel#embed-object)

---

## Contributing to Documentation

### Reporting Issues

Found an error or unclear section in the documentation?

1. Open an issue in the repository
2. Tag with `documentation` label
3. Reference specific workflow and section
4. Suggest improvements if possible

### Updating Documentation

When modifying workflows:

1. Update corresponding workflow documentation file
2. Update this index if structure changes
3. Update version history
4. Review all cross-references
5. Test documentation links

### Documentation Standards

- **Clear Language**: Write for developers of all experience levels
- **Code Examples**: Include working examples with context
- **Troubleshooting**: Add common issues and solutions
- **Keep Updated**: Review quarterly for accuracy
- **Cross-Reference**: Link to related sections
- **Version Numbers**: Update when workflows change

---

## Support

### Getting Help

1. **Documentation**: Check specific workflow documentation first
2. **Troubleshooting**: Review troubleshooting sections
3. **Issues**: Search existing GitHub issues
4. **Team**: Contact repository maintainers
5. **Community**: Ask in discussions or Discord

### Providing Feedback

We welcome feedback on workflow documentation:

- Clarity improvements
- Additional examples
- Missing troubleshooting scenarios
- Better organization
- Error corrections

---

## Quick Links

### Documentation

- [Build Workflow Documentation](Workflows/BuildWorkflow.md)
- [Release Workflow Documentation](Workflows/ReleaseWorkflow.md)
- [Nightly Workflow Documentation](Workflows/NightlyWorkflow.md)
