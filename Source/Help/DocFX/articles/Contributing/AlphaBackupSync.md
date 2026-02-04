# Alpha to Alpha-Backup Sync (GitHub Actions)

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Requirements](#requirements)
4. [Triggers](#triggers)
5. [Kill Switch](#kill-switch)
6. [Setup](#setup)
7. [Workflow Logic (Step by Step)](#workflow-logic-step-by-step)
8. [Auto-Merge](#auto-merge)
9. [Separate Repository Backup (Dated Directories)](#separate-repository-backup-dated-directories)
10. [Discord Notifications](#discord-notifications)
11. [Security and Permissions](#security-and-permissions)
12. [Edge Cases and Behaviour](#edge-cases-and-behaviour)
13. [Troubleshooting](#troubleshooting)
14. [See Also](#see-also)

---

## Overview

The **Alpha to Alpha-Backup Sync** workflow is a GitHub Actions automation that keeps a backup of the `alpha` branch when it has commits in the last 24 hours. It runs at midnight UTC (or on manual trigger) and:

1. **Same-repo backup**: Creates or updates the `alpha-backup` branch via a PR from `alpha`, with optional auto-merge when approved.
2. **Separate-repo backup** (optional): Pushes a full snapshot of `alpha` into a dated directory in another repository (e.g. `Standard Toolkit Backup - 2025-02-03`).
3. **Discord** (optional): Sends a notification summarizing the run.

### Purpose

- **Backup**: Maintain `alpha-backup` in the same repo and/or dated snapshots in a separate backup repo.
- **Automation**: No manual copying; the workflow detects recent activity and proposes the sync via a PR, and optionally pushes to a backup repo.
- **Visibility**: Optional Discord notifications when changes are detected.

---

## Key Features

| Feature | Description |
|---------|-------------|
| **24-hour window** | Only acts when `alpha` has at least one commit in the last 24 hours. |
| **Branch creation** | Creates `alpha-backup` from current `alpha` if the branch does not exist. |
| **PR-based sync** | Sync is proposed via a PR (base: `alpha-backup`, head: `alpha`). |
| **Auto-merge** | Enables auto-merge on the PR so it merges when requirements (e.g. approval) are met. |
| **No duplicate PRs** | Reuses an existing open PR from `alpha` → `alpha-backup` instead of opening another. |
| **No no-op PRs** | Does not open a PR when `alpha-backup` is already up to date with `alpha`. |
| **Dated backup dirs** | Optional push to a separate repo into directories like `Standard Toolkit Backup - YYYY-MM-DD`. |
| **Kill switch** | Can be disabled via repository variable without changing code. |
| **Discord (optional)** | Sends a summary when changes are detected. |
| **Manual run** | Can be triggered from the Actions tab via **Run workflow**. |

---

## Requirements

- **Repository**: GitHub repository containing an `alpha` branch.
- **Permissions**: Workflow needs `contents: write` and `pull-requests: write`.
- **Discord (optional)**: Webhook URL stored as `DISCORD_WEBHOOK_ALPHA_BACKUP`.
- **Backup repo (optional)**: Variable `BACKUP_REPO`, secret `BACKUP_REPO_TOKEN` (PAT with push access).

---

## Triggers

| Trigger | When |
|---------|------|
| **Schedule** | Daily at **00:00 UTC** (`cron: '0 0 * * *'`). |
| **Manual** | **Actions** → **Alpha to Alpha-Backup Sync** → **Run workflow** → **Run workflow**. |

---

## Kill Switch

The workflow can be disabled without changing code:

- **Variable**: `ALPHA_BACKUP_SYNC_DISABLED`
- **Location**: Repository **Settings** → **Secrets and variables** → **Actions** → **Variables** tab
- **To disable**: Set value to `true`
- **To re-enable**: Set value to `false` or delete the variable

When disabled, the workflow still runs (triggered by schedule or manual) but exits immediately after the kill switch check with a warning. No checkout, branch creation, PR creation, backup push, or Discord notification occurs.

---

## Setup

### 1. Workflow file

The workflow is defined in:

```
.github/workflows/alpha-backup-sync.yml
```

### 2. Auto-merge (for same-repo PR sync)

- **Settings** → **General** → **Pull Requests** → enable **Allow auto-merge**.
- The workflow enables auto-merge on each sync PR; the PR will merge when branch protection requirements (e.g. approvals) are satisfied.

### 3. Discord (optional)

1. In your Discord server, create an **Incoming Webhook** (Channel → Integrations → Webhooks).
2. Copy the webhook URL.
3. **Settings** → **Secrets and variables** → **Actions** → **Secrets**.
4. Add secret: **Name** `DISCORD_WEBHOOK_ALPHA_BACKUP`, **Value** the webhook URL.

### 4. Separate repository backup (optional)

1. Create a backup repository (e.g. `Krypton-Suite/Standard-Toolkit-Backup`).
2. **Variables**: Add `BACKUP_REPO` with value `owner/repo` (e.g. `Krypton-Suite/Standard-Toolkit-Backup`).
3. **Secrets**: Add `BACKUP_REPO_TOKEN` (PAT with `repo` scope and push access to the backup repo).
4. Optional variables:
   - `BACKUP_DIR_PREFIX`: Directory name prefix (default: `Standard Toolkit Backup`).
   - `BACKUP_BRANCH`: Branch to push to (default: `main`).

---

## Workflow Logic (Step by Step)

### Step 1: Kill switch check

- Checks `vars.ALPHA_BACKUP_SYNC_DISABLED`.
- If `true`, sets `enabled=false` and all subsequent steps are skipped.
- Otherwise sets `enabled=true`.

### Step 2: Checkout

- Checks out `alpha` with `fetch-depth: 0` (full history).

### Step 3: Check for changes on alpha in last 24 hours

- Computes timestamp for 24 hours ago (UTC).
- Runs `git rev-list --count --since="<timestamp>" alpha`.
- If count > 0: `has_changes=true`; otherwise `has_changes=false`.
- All sync steps run only when `has_changes == 'true'`.

### Step 4: Ensure alpha-backup exists

- Uses GitHub API to check if `alpha-backup` exists.
- If not, creates it from current `alpha` SHA.
- Returns `'exists'` or `'created'`.

### Step 5: Create PR from alpha to alpha-backup

- Compares `alpha-backup...alpha`.
- If `ahead_by === 0`: no PR created.
- If an open PR from `alpha` → `alpha-backup` exists: reuses it.
- Otherwise: creates a new PR and returns `pr_number`, `pr_url`, `pr_node_id`.

### Step 6: Enable auto-merge on PR

- When a PR exists (has `pr_node_id`), calls GraphQL `enablePullRequestAutoMerge` with merge method `MERGE`.
- If the repo does not have "Allow auto-merge" enabled, logs a warning and continues.

### Step 7: Push alpha to backup repository (dated directory)

- Runs only when `BACKUP_REPO` and `BACKUP_REPO_TOKEN` are set.
- Clones the backup repo.
- Creates directory `{BACKUP_DIR_PREFIX} - YYYY-MM-DD` (e.g. `Standard Toolkit Backup - 2025-02-03`).
- Copies full alpha contents (excluding `.git`) into that directory.
- Commits and pushes to `BACKUP_BRANCH` (default `main`).

### Step 8: Discord notification

- When `DISCORD_WEBHOOK_ALPHA_BACKUP` is set, sends an embed with branch status, PR link (if any), backup repo info (if pushed), and workflow run link.

---

## Auto-Merge

The workflow enables auto-merge on each sync PR via the GitHub GraphQL API. The PR will merge automatically when:

- **Settings** → **General** → **Pull Requests** → **Allow auto-merge** is enabled.
- Branch protection requirements (e.g. required approvals, status checks) are satisfied.

Merge method is `MERGE` (merge commit). If "Allow auto-merge" is not enabled on the repo, the step logs a warning and continues without failing.

---

## Separate Repository Backup (Dated Directories)

When `BACKUP_REPO` and `BACKUP_REPO_TOKEN` are configured, the workflow pushes a full snapshot of `alpha` into the backup repo.

### Directory structure

Each run creates a new dated directory at the root of the backup repo:

```
Standard-Toolkit-Backup/
├── Standard Toolkit Backup - 2025-02-01/
│   ├── Source/
│   ├── Documents/
│   ├── .github/
│   └── ... (full alpha contents, excluding .git)
├── Standard Toolkit Backup - 2025-02-02/
│   └── ...
├── Standard Toolkit Backup - 2025-02-03/
│   └── ...
```

### Configuration

| Variable / Secret | Required | Default | Description |
|-------------------|----------|---------|-------------|
| `BACKUP_REPO` | Yes (for backup) | — | Full repo name, e.g. `Krypton-Suite/Standard-Toolkit-Backup` |
| `BACKUP_REPO_TOKEN` | Yes (for backup) | — | PAT with push access to the backup repo |
| `BACKUP_DIR_PREFIX` | No | `Standard Toolkit Backup` | Prefix for the directory name |
| `BACKUP_BRANCH` | No | `main` | Branch in the backup repo to push to |

### Behaviour

- Date is UTC (`YYYY-MM-DD`).
- Contents are copied with `rsync` (excluding `.git`).
- Each run adds a new directory; previous backups remain.
- If the backup repo is empty, the workflow creates the initial commit on the configured branch.

---

## Discord Notifications

### When a notification is sent

- Only when alpha had at least one commit in the last 24 hours.
- Only if `DISCORD_WEBHOOK_ALPHA_BACKUP` is set.

### Message contents

- Title: "Alpha → Alpha-Backup Sync"
- Description: Branch status, PR link (if any), backup repo and directory (if pushed), workflow run link
- Footer: "Alpha Backup Sync"
- Colour: Blue

---

## Security and Permissions

### Workflow permissions

- `contents: write`: Create/update refs (e.g. create `alpha-backup`).
- `pull-requests: write`: Create and read PRs, enable auto-merge.

### Tokens

- **Same-repo operations**: `GITHUB_TOKEN` (provided by Actions).
- **Backup repo push**: `BACKUP_REPO_TOKEN` (PAT with `repo` scope and push access to the backup repo).

---

## Edge Cases and Behaviour

| Scenario | Behaviour |
|----------|-----------|
| **alpha-backup does not exist** | Branch created from current `alpha`. No PR (identical). Discord reports branch created. |
| **alpha-backup exists, alpha is ahead** | PR created or reused. Auto-merge enabled. Discord includes PR link. |
| **alpha-backup already up to date** | No PR. Discord still sent if webhook set. |
| **Open PR already exists** | No second PR; auto-merge enabled on existing PR. |
| **No commits on alpha in last 24h** | All sync steps skipped. |
| **Kill switch enabled** | All steps after kill switch check skipped. |
| **Backup repo not configured** | Backup push step skipped (exits 0). |
| **Backup repo empty** | Initial commit created on configured branch. |

---

## Troubleshooting

### Workflow is disabled / does nothing

- Check **Settings** → **Secrets and variables** → **Actions** → **Variables** for `ALPHA_BACKUP_SYNC_DISABLED` = `true`. Set to `false` or delete to re-enable.

### Workflow does not run at midnight

- Confirm the workflow file is on the default branch and Actions are enabled.
- GitHub may skip scheduled runs for inactive repos; use manual run to verify.

### alpha-backup was not created

- Ensure the job has `contents: write` and branch protection does not block creation.
- Check the "Ensure alpha-backup exists" step log for API errors.

### No PR is created

- Verify "Check for changes" shows `has_changes=true`.
- If `ahead_by === 0`, no PR is opened (e.g. first run after creating `alpha-backup`).
- If an open PR already exists, the workflow reuses it.

### Auto-merge not working

- Enable **Allow auto-merge** in **Settings** → **General** → **Pull Requests**.
- Check branch protection rules on `alpha-backup` (approvals, status checks).

### Backup repo push fails

- Verify `BACKUP_REPO_TOKEN` has push access to the backup repo.
- Ensure `BACKUP_REPO` is correct (`owner/repo`).
- Check that `BACKUP_BRANCH` matches the default branch if the repo is empty.

### Discord notification not received

- Confirm `DISCORD_WEBHOOK_ALPHA_BACKUP` is set and the run had `has_changes == 'true'`.
- Check the "Discord notification" step log for errors.

### How to test without waiting for midnight

Use **Actions** → **Alpha to Alpha-Backup Sync** → **Run workflow**. Ensure `alpha` has at least one commit in the last 24 hours.

---

## See Also

- **Workflow file**: [.github/workflows/alpha-backup-sync.yml](../.github/workflows/alpha-backup-sync.yml)
- **Nightly workflow**: [.github/workflows/nightly.yml](../.github/workflows/nightly.yml)
- [GitHub: Events that trigger workflows – schedule](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)
- [GitHub: Using the GITHUB_TOKEN](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)