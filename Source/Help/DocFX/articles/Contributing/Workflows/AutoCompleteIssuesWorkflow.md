# Auto-complete Linked Issues Workflow

## Quick Reference

- Workflow file: `.github/workflows/auto-complete-issues.yml`
- Workflow name: `Auto-complete linked issues`
- Triggers: `pull_request_target` (`closed`), `workflow_dispatch`
- Runner: `ubuntu-latest`
- Permissions: `issues: write`, `pull-requests: read`
- Primary action: `actions/github-script@v9`

## Purpose

`auto-complete-issues.yml` automates issue lifecycle cleanup when a pull request is merged.

When conditions are met, the workflow:

1. Finds linked issues for the merged PR.
2. Adds a completion label based on issue title prefix:
   - `[Bug]` -> `fixed`
   - `[Feature Request]` -> `completed`
3. Closes the issue (if still open).
4. Removes all assignees.

This implements the behavior requested in issue [#3550](https://github.com/Krypton-Suite/Standard-Toolkit/issues/3550).

---

## Workflow File

- Path: `.github/workflows/auto-complete-issues.yml`
- Workflow name: `Auto-complete linked issues`
- Runtime: `ubuntu-latest`
- Engine: `actions/github-script@v9`

---

## Triggers

### Automatic trigger

```yaml
on:
  pull_request_target:
    types: [closed]
```

The workflow starts when a PR is closed, then exits early unless:

- `pr.merged == true`

### Manual trigger

```yaml
on:
  workflow_dispatch:
    inputs:
      pr_number:
        type: number
      dry_run:
        type: boolean
        default: true
```

Manual runs fetch PR metadata via `pulls.get` and apply the same merged-PR validation.

---

## Permissions and Security Model

### Permissions requested

```yaml
permissions:
  issues: write
  pull-requests: read
```

These are the minimum permissions needed to:

- Read PR metadata and body
- Read and update issues
- Add/remove labels
- Remove assignees

### Why `pull_request_target` is used

`pull_request_target` executes in the context of the base repository (not fork workflow files), which allows write operations using `GITHUB_TOKEN`.

Risk is controlled because this workflow:

- does not check out code
- does not execute scripts from PR contents
- only acts on GitHub API metadata
- restricts operations to merged PR events only

---

## Processing Pipeline

The script follows a deterministic pipeline:

1. **Load event context**
   - Detect whether run is automatic or `workflow_dispatch`.
   - Parse `dry_run`.
2. **Load PR**
   - Automatic: use `context.payload.pull_request`.
   - Manual: fetch PR by `pr_number`.
3. **Gate checks**
   - Require merged PR.
   - Use actual PR `head`/`base` refs from event/API metadata (no hardcoded branch gate).
4. **Discover linked issues**
   - Primary: GraphQL `closingIssuesReferences(first: 100)`.
   - Fallback: regex scan of PR body for closing keywords.
5. **Process each issue**
   - Fetch issue by number.
   - Ignore references that are actually pull requests.
   - Derive completion label from title prefix.
   - Add label if needed.
   - Close issue if open.
   - Remove assignees if present.
6. **Log outcomes**
   - Success and skip paths are logged explicitly.
   - Partial failures are logged as warnings; processing continues.

---

## Linked Issue Discovery Details

### Primary method: GraphQL closing references

The workflow queries:

- `repository.pullRequest(number: X).closingIssuesReferences`

This is the most reliable way to honor GitHub-native closing semantics.

### Fallback method: regex in PR body

If GraphQL returns no issues (or fails), a fallback regex scans PR body text:

```text
\b(?:close[sd]?|fix(?:e[sd])?|resolve[sd]?)\s+#(\d+)\b
```

Matches examples like:

- `close #123`
- `closes #123`
- `fixed #123`
- `resolves #123`

Numbers are deduplicated with a `Set`.

---

## Labeling Rules

Label assignment is title-prefix based and case-insensitive:

- `/^\[bug\]:?/i` -> add `fixed`
- `/^\[feature request\]:?/i` -> add `completed`

Notes:

- If title does not match either pattern, no completion label is added.
- If target label already exists, no duplicate add is attempted.
- Missing labels produce warning logs and do not fail the entire workflow.

---

## Dry Run Behavior

`dry_run` is only honored for `workflow_dispatch` runs.

- `dry_run=true`:
  - No mutations are performed.
  - Logs emit explicit `"[dry-run] Would ..."` messages.
- `dry_run=false`:
  - Mutations are executed (label/close/unassign).

Automatic PR-close events always run in live mode.

---

## Operational Runbook

### Manual validation before enabling broader usage

1. Open **Actions** -> **Auto-complete linked issues**.
2. Run workflow with:
   - `pr_number`: a known merged PR
   - `dry_run`: `true`
3. Verify logs:
   - branch-direction gate result
   - issue detection output
   - expected label/close/unassign actions
4. Re-run with `dry_run=false` for an approved test PR.

### Expected skip conditions

- PR closed without merge
- No linked issues detected
- Referenced number is a PR, not an issue

These are healthy no-op states, not failures.

---

## Troubleshooting

### No issues were processed

Check:

- PR actually merged
- PR has closing references (`Fixes #...`) or native linked issues

### Labels were not added

Check:

- Label names exist exactly as `fixed` and `completed`
- Issue title prefix is present:
  - `[Bug]`
  - `[Feature Request]`

### Assignees not removed

Check:

- Issue had assignees at processing time
- Run was not `dry_run=true`

### Manual run failed with invalid PR input

Check:

- `pr_number` is numeric and corresponds to an existing PR in this repository

---

## Known Constraints

- Only up to first 100 GraphQL closing references are queried.
- Regex fallback only parses issue references in PR body, not comments.
- Completion label is inferred from title convention, not issue form metadata.

---

## Maintenance Guidance

### If label taxonomy changes

Update mapping logic:

- `[Bug]` -> replacement for `fixed`
- `[Feature Request]` -> replacement for `completed`

### If issue title conventions change

Update regex checks for title prefixes to match new conventions.

---

## Suggested Future Enhancements

1. Move expected branch names to repository variables for zero-code reconfiguration.
2. Add optional comment on closed issue linking back to merged PR.
3. Add metric-style summary output (counts of labeled/closed/unassigned/skipped).
4. Add support for additional title conventions (`[Other Issues]`, `[Question]`) if policy requires.

---

## Quick Reference

- **Workflow file**: `.github/workflows/auto-complete-issues.yml`
- **Manual test mode**: `workflow_dispatch` + `dry_run=true`
- **Branch context source**: PR metadata (`head`/`base` refs)
- **Completion labels**:
  - `[Bug]` -> `fixed`
  - `[Feature Request]` -> `completed`
