# Workflow Documentation Index

This directory captures the operational knowledge for the automation hosted under `.github/workflows`. Each document is scoped to a single workflow so release engineers can reason about triggers, required infrastructure, secrets, and recovery steps without digging through YAML.

## Available Guides

| Workflow | Purpose | Document |
| --- | --- | --- |
| `build.yml` | CI compilation and package prep executed on PRs and mainline pushes. | [Build Workflow](Build%20System/Current/BuildWorkflow.md) |
| `release.yml` | Branch-specific release promotion to NuGet/Discord with kill switches. | [Release Workflow](Build%20System/Current/ReleaseWorkflow.md) |

### How to Use This Index

- Start with the guide that matches the workflow which fired (link from GitHub Actions run page).
- Each guide begins with a quick reference section for triggers and infrastructure, followed by deep dives into every job and step.
- If you extend a workflow, update both the corresponding document **and** this table so downstream teams stay aware of the change.

