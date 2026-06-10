# PR Branch Policy Workflow

## Quick Reference

| Item | Value |
|------|-------|
| Workflow file | `.github/workflows/pr-branch-policy.yml` |
| Workflow name (Actions UI) | **PR branch policy** |
| Job name | `policy` |
| Trigger | `pull_request` (`opened`, `synchronize`, `reopened`) |
| Runner | `ubuntu-latest` |
| Permissions | `contents: read`, `pull-requests: read` |
| Script | `.github/scripts/Invoke-BranchPolicyCheck.ps1` |

## Overview

Validates same-repository pull requests against [branch policy](../BranchPolicyandWorkflowHardening.md) rules: allowed base/head pairs and `.github/`-only merges from `master` to release lines. Does **not** require release branches to contain `master` in Git history.

**Rollout:** warn-only by default (`BRANCH_POLICY_ENFORCE` unset). Set `BRANCH_POLICY_ENFORCE=true` to fail the check.

## Trigger Conditions

- Runs on internal PRs only (`head.repo` must equal this repository).
- Skipped when `BRANCH_POLICY_DISABLED=true`.

## Kill Switches and Variables

| Variable | Effect |
|----------|--------|
| `BRANCH_POLICY_DISABLED=true` | Disables this workflow |
| `BRANCH_POLICY_ENFORCE=true` | Violations fail the job |
| `BRANCH_POLICY_ENFORCE` unset / `false` | Violations are warnings; job passes |

## Related Documentation

- [Branch policy and workflow hardening](../BranchPolicyandWorkflowHardening.md) — full rules, troubleshooting, rollout
- [Branch promotion policy](../BranchPromotionPolicy.md) — `alpha` → `canary` → `gold` → `master` promotion guards (separate workflows)
- [.github/BRANCH_POLICY.md](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/BRANCH_POLICY.md) — cheat sheet
