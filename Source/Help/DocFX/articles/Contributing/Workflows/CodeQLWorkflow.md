# CodeQL Advanced Workflow

## Quick Reference

- Workflow file: `.github/workflows/codeql.yml`
- Workflow name: `CodeQL Advanced`
- Triggers: `push`, `pull_request`, `schedule`
- Runner: `ubuntu-latest` (default)
- Primary actions: `github/codeql-action/init@v4`, `github/codeql-action/analyze@v4`

## Overview

The `codeql.yml` workflow runs GitHub Advanced Security CodeQL analysis on a schedule and on code changes for selected branches.

- Workflow file: `.github/workflows/codeql.yml`
- Workflow name: `CodeQL Advanced`
- Runner: `ubuntu-latest` (or `macos-latest` for Swift matrix entries)

## Purpose

- Perform static security and quality analysis across repository languages.
- Surface findings in GitHub code scanning alerts.
- Provide recurring (scheduled) analysis independent of PR activity.

## Triggers

The workflow triggers on:

- `push` to `master`, `V105-LTS`, `V85-LTS`, `alpha`, `canary`, `gold`
- `pull_request` targeting the same branches
- weekly schedule: Monday 00:00 UTC (`0 0 * * 1`)

## Permissions

Per job permissions:

- `security-events: write` (required to publish results)
- `packages: read`
- `actions: read`
- `contents: read`

## Language Matrix

Current matrix entries:

- `actions`
- `csharp`
- `javascript-typescript`
- `python`

All currently run with `build-mode: none`.

## Execution Flow

For each matrix language:

1. Checkout repository.
2. Initialize CodeQL (`github/codeql-action/init@v4`).
3. Optional manual build step (only if `build-mode == manual`; currently not used).
4. Analyze and upload results (`github/codeql-action/analyze@v4`).

## Build Mode Notes

- `build-mode: none` is suitable for interpreted languages and scenarios where autobuild/manual build is unnecessary.
- For compiled-language deep analysis requiring build context, set `build-mode: manual` and provide concrete build commands in the placeholder step.

## Operational Guidance

### When to adjust matrix languages

Update matrix if repository language profile changes substantially (for example, adding/removing maintained language areas).

### When to switch to manual build mode

Use manual mode if:

- analysis misses meaningful data for compiled components
- CodeQL logs indicate inability to infer project build context

## Troubleshooting

### No alerts appear

Check:

- workflow actually ran on branch/event
- Code Scanning is enabled in repository security settings
- permissions include `security-events: write`

### Analysis fails for a language

Check:

- matrix entry matches supported CodeQL language IDs
- init/analyze action versions are compatible
- if using manual mode, ensure build commands succeed

## Related Documentation

- [GitHub Actions Workflows](../GitHubActionsWorkflows.md)
- [GitHub code scanning docs](https://docs.github.com/code-security/code-scanning)
