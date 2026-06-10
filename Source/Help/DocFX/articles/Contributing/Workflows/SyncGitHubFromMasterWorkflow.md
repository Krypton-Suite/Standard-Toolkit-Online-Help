# Sync .github from Master Workflow

## Quick Reference

| Item | Value |
|------|-------|
| Workflow file | `.github/workflows/sync-github-from-master.yml` |
| Workflow name (Actions UI) | **Sync .github from master** |
| Triggers | Push to `master` (`.github/**`), weekly schedule, `workflow_dispatch` |
| Runner | `ubuntu-latest` |
| Permissions | `contents: write`, `pull-requests: write` |

## Overview

Opens pull requests that copy **only** the `.github/` directory from `master` onto downstream release branches listed in `syncGithubFromMasterTargets` in [branch-policy.json](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/branch-policy.json).

Typical targets: `alpha`, `canary`, `gold`, `prerelease`, `V105-LTS`, `V85-LTS`, `V110`.

**Not a merge of `master`:** the job checks out the target branch tip, then runs `git checkout origin/master -- .github`. That replaces the `.github/` tree with the files from `master` at that moment. Downstream branches do **not** need to contain `master` in Git history.

## Behaviour

1. For each target branch, create or update `sync/github-from-master-<target>` from `origin/<target>`.
2. Run `git checkout origin/master -- .github` (path copy from `master`, not `git merge master`).
3. If there are changes, force-push the sync branch and open a PR (or skip if one is already open).
4. Label `chore:workflow-sync` when the label exists.

## Kill Switch

| Variable | Effect |
|----------|--------|
| `SYNC_GITHUB_FROM_MASTER_DISABLED=true` | Disables this workflow |

## Related Documentation

- [Branch policy and workflow hardening](../BranchPolicyandWorkflowHardening.md) — why `.github/`-only propagation exists
- [PR branch policy workflow](PRBranchPolicyWorkflow.md) — validates manual PRs that use `master` as head
