# Alpha to Alpha-Backup Sync (GitHub Actions)

## Table of Contents

1. [Overview](#overview)
2. [Key Features](#key-features)
3. [Requirements](#requirements)
4. [Triggers](#triggers)
5. [Setup](#setup)
6. [Workflow Logic (Step by Step)](#workflow-logic-step-by-step)
7. [Discord Notifications](#discord-notifications)
8. [Automating the Merge (Auto-Merge)](#automating-the-merge-auto-merge)
9. [Security and Permissions](#security-and-permissions)
10. [Edge Cases and Behaviour](#edge-cases-and-behaviour)
11. [Troubleshooting](#troubleshooting)
12. [See Also](#see-also)

---

## Overview

The **Alpha to Alpha-Backup Sync** workflow is a GitHub Actions automation that keeps a backup of the `alpha` branch by creating a pull request from `alpha` into `alpha-backup` whenever `alpha` has received commits in the last 24 hours. It runs at midnight UTC (or on manual trigger) and, when appropriate, ensures the `alpha-backup` branch exists, opens or reuses a PR from `alpha` to `alpha-backup`, and optionally sends a Discord notification.

### Purpose

- **Backup**: Maintain a separate branch (`alpha-backup`) that can be updated via a PR, giving visibility and optional review before the backup is updated.
- **Automation**: No manual copying of `alpha`; the workflow detects recent activity and proposes the sync via a PR.
- **Visibility**: Optional Discord notifications when a sync run detects changes and creates or finds an open PR.

### Architecture (High Level)

1. **Trigger**: Schedule (midnight UTC) or manual.
2. **Check**: Count commits on `alpha` in the last 24 hours.
3. **If no recent commits**: Workflow exits without creating branches or PRs.
4. **If recent commits exist**:
   - Ensure `alpha-backup` exists (create it from `alpha` if it does not).
   - Compare `alpha-backup` with `alpha`; if `alpha` is ahead, create an open PR from `alpha` into `alpha-backup` (or reuse an existing one).
   - Optionally send a Discord notification with branch/PR and run details.

The actual “copy” of `alpha` onto `alpha-backup` happens when that PR is merged (manually or via auto-merge).

---

## Key Features

| Feature | Description |
|--------|-------------|
| **24-hour window** | Only acts when `alpha` has at least one commit in the last 24 hours. |
| **Branch creation** | Creates `alpha-backup` from current `alpha` if the branch does not exist. |
| **PR-based sync** | Sync is proposed via a PR (base: `alpha-backup`, head: `alpha`), not a direct push. |
| **No duplicate PRs** | Reuses an existing open PR from `alpha` → `alpha-backup` instead of opening another. |
| **No no-op PRs** | Does not open a PR when `alpha-backup` is already up to date with `alpha`. |
| **Discord (optional)** | Can post a summary to Discord when changes are detected; requires a webhook secret. |
| **Manual run** | Can be triggered from the Actions tab via **Run workflow**. |

---

## Requirements

- **Repository**: GitHub repository containing an `alpha` branch.
- **Permissions**: Workflow needs `contents: write` and `pull-requests: write` (see [Security and Permissions](#security-and-permissions)).
- **Discord (optional)**: A Discord webhook URL stored as a repository secret if you want notifications.

---

## Triggers

| Trigger | When |
|--------|------|
| **Schedule** | Daily at **00:00 UTC** (`cron: '0 0 * * *'`). |
| **Manual** | **Actions** → **Alpha to Alpha-Backup Sync** → **Run workflow** → **Run workflow**. |

Scheduled runs are subject to [GitHub Actions schedule limits](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule); if the repository is inactive, scheduled workflows may not run every day.

---

## Setup

### 1. Workflow file

The workflow is defined in:

```
.github/workflows/alpha-backup-sync.yml
```

No code changes are required for basic operation once the file is in the default branch and the repo has Actions enabled.

### 2. Branch protection (optional)

If `alpha-backup` is protected:

- The workflow uses `GITHUB_TOKEN`, which respects branch protection. Ensure the token can push to `alpha-backup` (e.g. allow Actions to bypass or use a PAT with appropriate permissions if you switch to a different token).
- If you use **Require a pull request before merging**, the workflow’s PR can be merged after review or via auto-merge.

### 3. Discord (optional)

To enable Discord notifications:

1. In your Discord server, create an **Incoming Webhook** (Channel → Integrations → Webhooks).
2. Copy the webhook URL.
3. In the repo: **Settings** → **Secrets and variables** → **Actions** → **Secrets**.
4. Add a new repository secret:
   - **Name**: `DISCORD_WEBHOOK_ALPHA_BACKUP`
   - **Value**: the Discord webhook URL

If this secret is not set, the workflow still runs but skips the Discord step without failing.

---

## Workflow Logic (Step by Step)

### Step 1: Checkout

- **Action**: `actions/checkout@v6`
- **Ref**: `alpha`
- **fetch-depth**: `0` (full history for `git rev-list --since`).

The job runs on `ubuntu-latest` and has full clone of `alpha`.

### Step 2: Check for changes on alpha in last 24 hours

- **Id**: `check_changes`
- **Logic**:
  - Computes a timestamp for “24 hours ago” in UTC.
  - Runs: `git rev-list --count --since="<timestamp>" alpha`.
  - If count &gt; 0: sets output `has_changes=true`; otherwise `has_changes=false`.

All subsequent steps that create the branch, create/find the PR, or send Discord run only when `has_changes == 'true'`.

### Step 3: Ensure alpha-backup exists

- **Id**: `ensure_backup`
- **Runs when**: `steps.check_changes.outputs.has_changes == 'true'`
- **Tool**: `actions/github-script@v8` (GitHub REST/API).
- **Logic**:
  1. Call `repos.getBranch` for `alpha-backup`.
  2. If the branch exists: log and return `'exists'`.
  3. If the branch does not exist (404):
     - Get the SHA of `refs/heads/alpha` via `git.getRef`.
     - Create `refs/heads/alpha-backup` pointing at that SHA via `git.createRef`.
     - Log and return `'created'`.
- **Output**: `steps.ensure_backup.outputs.result` is either `'exists'` or `'created'`.

This guarantees `alpha-backup` exists before the PR step. On first run, `alpha-backup` is created as a copy of `alpha` at that moment.

### Step 4: Create PR from alpha to alpha-backup

- **Id**: `create_pr`
- **Runs when**: `steps.check_changes.outputs.has_changes == 'true'`
- **Tool**: `actions/github-script@v8`.
- **Logic**:
  1. **Compare**: `repos.compareCommitsWithBasehead` with `basehead: 'alpha-backup...alpha'` (commits in `alpha` not in `alpha-backup`).
  2. If `ahead_by === 0`: log “no PR needed”, return `{ pr_created: false, pr_number: '', pr_url: '' }`.
  3. **Existing PR**: `pulls.list` with `state: 'open'`, `head: '<owner>:alpha'`, `base: 'alpha-backup'`. If any open PR exists: use its number and `html_url`, return them in the result object (no new PR).
  4. **New PR**: `pulls.create` with base `alpha-backup`, head `alpha`, fixed title/body. Return `{ pr_created: true, pr_number, pr_url }`.
- **Output**: `steps.create_pr.outputs.result` is a JSON object with `pr_created`, `pr_number`, and `pr_url` (used by Discord).

So: a PR is only created when `alpha` is ahead of `alpha-backup` and there is no open PR from `alpha` → `alpha-backup` already.

### Step 5: Discord notification

- **Runs when**: `steps.check_changes.outputs.has_changes == 'true'`
- **Behaviour**:
  - If `DISCORD_WEBHOOK_ALPHA_BACKUP` is not set: log and exit 0 (no failure).
  - Otherwise: build a Discord embed payload with:
    - Title: “Alpha → Alpha-Backup Sync”
    - Description: states that alpha had commits in the last 24 hours; whether `alpha-backup` was created or already existed; link to the PR (if any); link to the workflow run.
  - POST the payload to the webhook with `curl`.

Branch-created vs already-existed is derived from `steps.ensure_backup.outputs.result == 'created'`. PR link comes from parsing `steps.create_pr.outputs.result` (e.g. with `jq`) for `pr_url` and `pr_number`.

---

## Discord Notifications

### When a notification is sent

- Only when **alpha had at least one commit in the last 24 hours** (`has_changes == 'true'`).
- Only if the repository secret **`DISCORD_WEBHOOK_ALPHA_BACKUP`** is set.

### What the message contains

- **Title**: “Alpha → Alpha-Backup Sync”
- **Description** (summary):
  - That alpha had commits in the last 24 hours.
  - Whether `alpha-backup` was created (did not exist) or already existed.
  - A link to the PR (if one exists or was just created).
  - A link to the workflow run.
- **Footer**: “Alpha Backup Sync”
- **Colour**: Blue (3447003).

### Using the same channel as Nightly

You can reuse the same Discord channel as the nightly workflow by pointing `DISCORD_WEBHOOK_ALPHA_BACKUP` to the same webhook URL as `DISCORD_WEBHOOK_NIGHTLY`, or use a different webhook for a different channel.

---

## Automating the Merge (Auto-Merge)

The workflow only **opens** (or finds) the PR; it does not merge it. To make the backup update automatically:

1. In the repo: **Settings** → **General** → **Pull Requests** → enable **Allow auto-merge**.
2. When the workflow opens a PR “chore: sync alpha → alpha-backup (automated)”:
   - Open the PR.
   - Click **Enable auto-merge** and choose merge method (merge commit, squash, rebase) and conditions (e.g. “Merge when branch is up to date” or when checks pass, if you add required status checks).

After that, each time the workflow opens a sync PR, it can be merged automatically so `alpha-backup` stays in sync with `alpha` without manual merge clicks.

---

## Security and Permissions

### Workflow permissions

The workflow declares:

```yaml
permissions:
  contents: write   # Create/update refs (e.g. create alpha-backup)
  pull-requests: write   # Create and read PRs
```

- **contents: write**: Needed to create the `alpha-backup` branch via the Git/Refs API when it does not exist.
- **pull-requests: write**: Needed to list and create pull requests.

### Token

The job uses the default **`GITHUB_TOKEN`** provided by the Actions runner. It is scoped to the repository and respects branch protection and repo rules. No Personal Access Token or other secrets are required for core behaviour.

### What the workflow does not do

- It does not push directly to `alpha` or any other branch except by creating the ref for `alpha-backup` when missing.
- It does not delete branches or force-push.
- It does not merge the PR; merging is done by a user or by auto-merge.

---

## Edge Cases and Behaviour

| Scenario | Behaviour |
|----------|-----------|
| **alpha-backup does not exist** | Branch is created from current `alpha` SHA. No PR is created (alpha and alpha-backup are identical). Discord (if configured) reports that the branch was created. |
| **alpha-backup exists, alpha is ahead** | An open PR from `alpha` → `alpha-backup` is created (or reused if one already exists). Discord can include the PR link. |
| **alpha-backup exists and is up to date with alpha** | No PR is created. Discord still runs (if webhook set) and reports that alpha had recent commits; PR link may be empty if no open PR. |
| **Open PR already exists** | No second PR; the existing PR’s number and URL are used in the script output and can appear in Discord. |
| **No commits on alpha in last 24 hours** | All steps after “Check for changes” are skipped. No branch creation, no PR, no Discord. |
| **Manual run with no recent commits** | Same as above: no branch/PR/Discord. |
| **Scheduled run skipped by GitHub** | If the repo is inactive, GitHub may skip scheduled runs; use manual run to test. |

---

## Troubleshooting

### Workflow does not run at midnight

- Confirm the workflow file is on the default branch and that Actions are enabled.
- Check **Actions** → **Alpha to Alpha-Backup Sync** for run history. GitHub can skip scheduled runs for inactive repos; trigger manually to verify.

### alpha-backup was not created

- Ensure the job has **contents: write** and that branch protection or rules do not block creation of `alpha-backup` by the `GITHUB_TOKEN`.
- Check the “Ensure alpha-backup exists” step log for API errors (e.g. 403).

### No PR is created even though alpha has new commits

- Verify “Check for changes” reports `has_changes=true` and “Create PR” step runs.
- In “Create PR”, check the compare result: if `ahead_by === 0`, no PR is opened (e.g. first run after creating `alpha-backup` from `alpha`).
- If an open PR from `alpha` → `alpha-backup` already exists, the workflow reuses it and does not open a second one.

### Discord notification not received

- Confirm the repository secret **`DISCORD_WEBHOOK_ALPHA_BACKUP`** is set and that the workflow run had `has_changes == 'true'`.
- Check the “Discord notification” step log for “DISCORD_WEBHOOK_ALPHA_BACKUP not set” or HTTP errors from the webhook.

### How to test without waiting for midnight

Use **Actions** → **Alpha to Alpha-Backup Sync** → **Run workflow** → **Run workflow**. Ensure `alpha` has at least one commit in the last 24 hours if you want to test branch creation, PR creation, and Discord.

---

## See Also

- **Workflow file**: [.github/workflows/alpha-backup-sync.yml](../.github/workflows/alpha-backup-sync.yml)
- **Nightly workflow** (also uses 24-hour change check and Discord): [.github/workflows/nightly.yml](../.github/workflows/nightly.yml)
- [GitHub: Events that trigger workflows – schedule](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows#schedule)
- [GitHub: Using the GITHUB_TOKEN](https://docs.github.com/en/actions/security-guides/automatic-token-authentication)
