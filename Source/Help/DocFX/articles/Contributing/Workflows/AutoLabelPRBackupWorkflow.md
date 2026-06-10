# Auto-label PR Backup Workflow

## Quick Reference

- Workflow file: `.github/workflows/auto-label-pr-backup.yml`
- Workflow name: `Auto-label PR backup workflow`
- Trigger: `pull_request` (`opened`, `synchronize`, `reopened`)
- Runner: `ubuntu-latest`
- Permissions: `pull-requests: write`
- Primary action: `actions/github-script@v9`

## Overview

The `auto-label-pr-backup.yml` workflow adds a maintenance label to backup-sync pull requests when they modify the backup workflow definition.

- Workflow file: `.github/workflows/auto-label-pr-backup.yml`
- Workflow name: `Auto-label PR backup workflow`
- Runner: `ubuntu-latest`

## Purpose

- Highlight backup automation PRs that touch `.github/workflows/alpha-backup-sync.yml`.
- Improve triage visibility for automation-related changes.

## Trigger Conditions

Event:

- `pull_request` with types: `opened`, `synchronize`, `reopened`

Base branch filter:

- `alpha-backup`

Additional job-level gate:

- `github.head_ref == 'alpha'`

This constrains matching to PR direction `alpha` -> `alpha-backup`.

## Permissions

- `pull-requests: write`

## Labeling Logic

The script:

1. Lists changed files for the PR.
2. Checks for exact file match:
   - `.github/workflows/alpha-backup-sync.yml`
3. If matched:
   - Reads existing PR labels.
   - Adds `chore:automatic-backup` only if not already present.

If label does not exist in repository, the workflow logs a warning and continues.

## Idempotency

The workflow is safe to run repeatedly:

- It does not re-add the label when already present.
- It does not fail the run when the label is missing.

## Troubleshooting

### Label not added

Check:

- PR base is `alpha-backup`.
- PR head is `alpha`.
- PR includes `.github/workflows/alpha-backup-sync.yml` in changed files.
- Label `chore:automatic-backup` exists.

### Workflow did not run

Check:

- event type is one of `opened/synchronize/reopened`
- workflow file exists on default branch

## Related Documentation

- [Alpha Backup Sync](../AlphaBackupSync.md)
- [GitHub Workflow Index](../GitHubWorkflowIndex.md)
