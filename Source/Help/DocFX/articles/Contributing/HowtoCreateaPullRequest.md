# How to Create a Pull Request

This document will take you through the steps of creating a new pull request. ***Note:*** This document uses the `Standard-Toolkit`, but the procedure is the same for `Extended-Toolkit`.

1) Requirements
    a) A copy of [GitHub Desktop](https://desktop.github.com/)
    b) A copy of either [Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) or [Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit)

## Steps

### Step 1

 Clone a copy of either [Standard-Toolkit](https://github.com/Krypton-Suite/Standard-Toolkit) or [Extended-Toolkit](https://github.com/Krypton-Suite/Extended-Toolkit) with [GitHub Desktop](https://desktop.github.com/)

![Step 1: Cloning repository with GitHub Desktop](Making%20a%20Pull%20Request/Step%201.png)

### Step 2

 Once cloned to your computer, open up GitHub Desktop, navigate to the repository then change the branch from `main` to `alpha`.

![Step 2: Change branch from main to alpha in GitHub Desktop](Making%20a%20Pull%20Request/Step%202.png)

 (**Note:** You may see different branch names)

### Step 3

 In the same menu as before, click 'New branch', in the new window, create a name for your branch, making sure it is based on `alpha`.

![New branch dialog in GitHub Desktop](Making%20a%20Pull%20Request/Step%203a.png)

![Enter branch name in GitHub Desktop](Making%20a%20Pull%20Request/Step%203b.png)

### Step 4

 Once you have made your changes, press the 'Publish branch' button in GitHub Desktop

![Publish branch button in GitHub Desktop](Making%20a%20Pull%20Request/Step%204.png)

### Step 5

Once you have published your branch, click 'Preview Pull Request'

![Step 5: Preview Pull Request in GitHub Desktop](Making%20a%20Pull%20Request/Step%205.png)

### Step 6

Once you have clicked 'Preview Pull Request', the following window will appear

![Step 6: Create pull request window in GitHub Desktop](Making%20a%20Pull%20Request/Step%206.png)

Please ensure that `alpha` is selected ***before*** clicking 'Create pull request'

### Step 7

Once you have clicked 'Create pull request', GitHub Desktop will launch your default web browser. From there, please type in your notes, then assign either `@Smurf-IV`, `@Wagnerp`, `@giduac`, `@tobitege`, `@KamaniAR` or `@lesandrog` before clicking 'Create pull request'. From there, we will review your changes, and sometimes ask you to make changes if necessary. Once the changes are merged, please then delete your branch to avoid "stale branches".

![Step 7: Pull request details in web browser](Making%20a%20Pull%20Request/Step%207.png)

### Animation

![Animation: Creating a pull request in GitHub Desktop](https://github.com/Krypton-Suite/Documentation/blob/main/Assets/Miscellaneous/Making%20a%20Pull%20Request/Creating%20a%20pull%20request.gif?raw=true)

### Additional Notes

1) Please remember to always update `Changelog.md` with any changes that you have made. This is located in ***Documents\Changelog\Changelog.md***.

2) We ask you to provide a build report when submitting a pull request. This allows us to verify that there are no errors within the code. To do this, simply execute `run.cmd` from the root directory. Choose option '4' -> '1'. Once completed, it should show something like this:

   ![Build log example output](Making%20a%20Pull%20Request/Build%20Log%20Example.png)

   Simply take a snippet of the log, then paste it into your pull request description.

**Note:** As of version 100, we have introduced workflows. Each time a pull request is updated, it will automatically compile the code.

### Branch policy checks

Same-repository pull requests also run the **PR branch policy** workflow. It may report **warnings** (default) for issues such as:

- Attempting to merge a release line into `master` instead of using a feature branch.
- Merging `master` into a release branch with changes outside `.github/` (use the automated **Sync .github from master** workflow instead).

See [Branch policy and workflow hardening](BranchPolicyandWorkflowHardening.md) and [BRANCH_POLICY](https://github.com/Krypton-Suite/Standard-Toolkit/tree/master/.github/BRANCH_POLICY.md).

### Release promotion (maintainers)

This guide covers **contributor** PRs into **`alpha`**. Moving code toward stable production uses a separate promotion chain:

```text
alpha → canary → gold → master
```

Each step is a pull request in the same repository. Guard workflows validate allowed source branches; repository rulesets block direct pushes. See [Branch promotion policy](BranchPromotionPolicy.md) for the full procedure.
