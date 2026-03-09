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

---

## Workflow Summary

### [Build Workflow](Workflows/BuildWorkflow.md)

**File**: `.github/workflows/build.yml`

Primary CI/CD workflow for validating code quality and creating releases.

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

**Jobs**:

1. **build** - Compiles and validates code
2. **release** - Creates GitHub releases (master only)

**Documentation**: [Full Build Workflow Documentation →](Workflows/BuildWorkflow.md)

---

### [Release Workflow](Workflows/ReleaseWorkflow.md)

**File**: `.github/workflows/release.yml`

Handles production releases across four different release channels.

**Key Features**:

- ✅ Four independent release channels (Master, LTS, Canary, Alpha)
- ✅ Automatic NuGet package publishing
- ✅ GitHub release creation with artifacts (master only)
- ✅ Discord webhook notifications
- ✅ Multi-framework support
- ✅ Intelligent duplicate detection

**Triggers**:

- Push to: master, alpha, canary, V105-LTS, V85-LTS
- Manual: workflow_dispatch

**Release Channels**:

| Channel | Branch | Package Suffix | Tag Format | Discord Color |
| --- | --- | --- | --- | --- |
| **Stable** | master | - | `v{ver}` | Blue 🔵 |
| **LTS** | V85-LTS | `.LTS` | `v{ver}-lts` | Orange 🟠 |
| **Canary** | canary | - | `v{ver}-canary` | Yellow 🟡 |
| **Alpha** | alpha | - | `v{ver}-nightly` | Purple 🟣 |

**Jobs**:

1. **release-master** - Stable production releases
2. **release-v85-lts** - Long-term support releases
3. **release-canary** - Pre-release builds
4. **release-alpha** - Bleeding-edge builds

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
| `DISCORD_WEBHOOK_MASTER` | Release (master) | Stable release announcements |
| `DISCORD_WEBHOOK_LTS` | Release (V85-LTS) | LTS release announcements |
| `DISCORD_WEBHOOK_CANARY` | Release (canary) | Canary release announcements |
| `DISCORD_WEBHOOK_NIGHTLY` | Nightly, Release (alpha) | Nightly release announcements |

**Documentation**: See individual workflow docs for detailed secret configuration.

### Build Scripts

| Script | Used By | Configuration | Purpose |
| --- | --- | --- | --- |
| `Scripts/build.proj` | Build, Release (master) | Release | Stable production builds |
| `Scripts/longtermstable.proj` | Release (V85-LTS) | Release | LTS builds |
| `Scripts/canary.proj` | Release (canary) | Canary | Pre-release builds |
| `Scripts/nightly.proj` | Build, Nightly, Release (alpha) | Nightly | Development builds |

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
└─ Release Workflow → release-canary (NuGet + Discord)

Event: Push to V85-LTS
└─ Release Workflow → release-v85-lts (NuGet + Discord)

Event: Cron Schedule (00:00 UTC)
└─ Nightly Workflow → Check changes → Build if needed

Event: Manual Trigger
└─ Any workflow with workflow_dispatch
```

---

## Target Frameworks

### By Workflow/Channel

| Framework | Build | Release (Master) | Release (LTS) | Release (Canary) | Release (Alpha) | Nightly |
| --- | --- | --- | --- | --- | --- | --- |
| .NET 4.6.2 | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| .NET 4.7.x | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| .NET 4.7.2 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| .NET 4.8 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| .NET 4.8.1 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| .NET 6 | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| .NET 7 | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| .NET 8 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| .NET 9 | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| .NET 10 | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| .NET 11 | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |

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

#### Create an LTS Release

**Workflow**: [Release Workflow - LTS](Workflows/ReleaseWorkflow.md#job-3-release-v85-lts)

1. Cherry-pick changes to V85-LTS branch
2. Update LTS version
3. Push to V85-LTS
4. Workflow creates LTS NuGet packages

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
