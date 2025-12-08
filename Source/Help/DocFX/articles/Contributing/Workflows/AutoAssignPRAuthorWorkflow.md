# Auto-Assign PR Author Workflow

## Overview

The Auto-Assign PR Author workflow automatically assigns the pull request author as an assignee when a new pull request is opened. This ensures that PR authors are immediately notified of any activity on their pull requests and helps maintain clear ownership.

## Purpose

- **Automated Assignment**: Eliminates the need for manual assignment of PR authors
- **Dependabot Handling**: Special handling for Dependabot PRs assigns the repository owner instead
- **Non-Intrusive**: Only assigns if no assignees are already present

## Trigger Conditions

### Events

- **`pull_request_target`** with type `opened`
  - Triggers when a pull request is opened
  - Uses `pull_request_target` to access repository context even for forks

### Permissions

- `issues: write` - Required to modify issue/PR assignments
- `pull-requests: write` - Required to assign PR authors

## Workflow Structure

### Job: `assign-author`

**Runner**: `ubuntu-latest`

**Steps**:

1. **Assign PR author**
   - Uses `actions/github-script@v8` to execute JavaScript
   - Accesses PR context via `context.payload.pull_request`
   - Determines assignee based on branch name
   - Assigns only if no assignees exist

## Detailed Behavior

### Assignee Selection Logic

```javascript
let assignee = context.actor;  // Default: PR author

if (branch.startsWith('dependabot/')) {
  assignee = owner;  // Repository owner for Dependabot PRs
}
```

**Rules**:
1. **Standard PRs**: Assigns the PR author (`context.actor`)
2. **Dependabot PRs**: Assigns the repository owner when branch starts with `dependabot/`
3. **Existing Assignees**: Skips assignment if PR already has assignees

### Assignment Process

1. Extracts repository owner and name from `context.repo`
2. Gets PR details from `context.payload.pull_request`
3. Determines the appropriate assignee
4. Checks if PR already has assignees
5. Adds assignee if none exist

## Security Considerations

### `pull_request_target` Event

This workflow uses `pull_request_target` instead of `pull_request` to:
- Access repository context even for PRs from forks
- Use `GITHUB_TOKEN` with write permissions
- Avoid security risks from untrusted code

**Important**: The workflow script itself is trusted (runs from the base repository), but it processes data from potentially untrusted PRs. The current implementation only reads PR metadata and doesn't execute untrusted code.

## Example Scenarios

### Scenario 1: Standard PR from Contributor

**Input**: PR opened by `@contributor` from branch `feature/new-feature`

**Result**: `@contributor` is assigned to the PR

### Scenario 2: Dependabot PR

**Input**: PR opened by `@dependabot[bot]` from branch `dependabot/nuget/microsoft.net.test.sdk`

**Result**: Repository owner is assigned (not Dependabot)

### Scenario 3: PR with Existing Assignees

**Input**: PR opened with `@maintainer` already assigned

**Result**: No additional assignment (workflow skips)

## Configuration

### No Configuration Required

This workflow requires no secrets, variables, or environment configuration. It uses the default `GITHUB_TOKEN` provided by GitHub Actions.

## Troubleshooting

### PR Author Not Assigned

**Possible Causes**:
1. PR already has assignees - This is expected behavior
2. Workflow failed to run - Check Actions tab for errors
3. Permission issues - Verify workflow has `issues: write` and `pull-requests: write` permissions

**Solutions**:
- Check workflow run logs in the Actions tab
- Verify the PR trigger conditions are met
- Ensure workflow file is in `.github/workflows/` directory

### Dependabot PRs Not Assigned Correctly

**Check**:
- Branch name starts with `dependabot/`
- Repository owner is correctly identified
- Workflow has necessary permissions

## Related Workflows

- **Build Workflow**: Runs on PRs to validate changes
- **Auto-Label Issue Areas**: Similar automation for issues

## Code Reference

**File**: `.github/workflows/auto-assign-pr-author.yml`

**Key Components**:
- Event: `pull_request_target` with type `opened`
- Action: `actions/github-script@v8`
- Logic: Branch-based assignee selection

## Maintenance Notes

- The workflow is lightweight and requires minimal maintenance
- Branch name patterns (e.g., `dependabot/`) should be updated if Dependabot changes its naming convention
- Consider adding support for other bot types if needed in the future

