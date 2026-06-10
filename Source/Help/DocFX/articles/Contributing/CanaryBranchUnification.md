# Unifying `canary` and `Canary` branches

**Status:** Planned maintainer migration (not automated by branch policy).

**Why:** Two branch names exist today:

| Branch | Used by |
|--------|---------|
| `canary` (lowercase) | `build.yml`, `release.yml`, `codeql.yml`, `repo-mirror.yml`, branch policy sync |
| `Canary` (capital C) | `canary.yml` (standalone Canary Release workflow) |

Policy treats **both** as downstream lines. Contributors and CI can target the wrong ref. Unification removes duplicate configuration and sync PRs.

---

## Preconditions

- [ ] Agree on the **canonical name** (recommended: `canary` lowercase, matching mirror and `release.yml`).
- [ ] Confirm which branch on GitHub actually receives day-to-day pushes today.
- [ ] Schedule a quiet window (no active release in flight).

---

## Migration checklist (canonical = `canary`)

### 1. GitHub

1. If `Canary` has commits not on `canary`, merge or fast-forward:
   ```bash
   git fetch origin canary Canary
   git checkout canary
   git merge origin/Canary   # resolve conflicts if any
   git push origin canary
   ```
2. Update default branch protection / rulesets if they reference `Canary`.
3. Delete remote branch `Canary` after verification:
   ```bash
   git push origin --delete Canary
   ```

### 2. Workflows

1. Change [canary.yml](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/workflows/canary.yml):
   - `on.push.branches`: `Canary` → `canary`
   - Security verify branch: `refs/heads/Canary` → `refs/heads/canary`
   - `checkout` ref: `Canary` → `canary`
2. Search repo for `Canary` branch references (README badges, changelog links).
3. Remove `Canary` from [.github/branch-policy.json](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/branch-policy.json) `downstreamBranches` and `longLivedHeadBranches` once the branch is deleted.

### 3. Branch policy and sync

- After deletion, only `canary` remains in `syncGithubFromMasterTargets` (already listed).
- Re-run **Sync .github from master** if needed.

### 4. External systems

- [repo-mirror.yml](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/workflows/repo-mirror.yml) already mirrors `canary`.
- Update any fork docs, Discord runbooks, or NuGet release notes that link to `/tree/Canary`.

### 5. Verify

- [ ] Push to `canary` triggers `build.yml` and `release.yml` jobs.
- [ ] Retire or repoint standalone `canary.yml` if `release.yml` `release-canary` job fully replaces it.
- [ ] No open PRs use `Canary` as head or base.

---

## Rollback

Recreate `Canary` from `canary` tip and revert workflow edits if a release window requires the old setup.

---

## Related

- [BranchPolicyandWorkflowHardening.md](BranchPolicyandWorkflowHardening.md)
