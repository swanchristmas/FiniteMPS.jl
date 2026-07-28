# Delivery Policy

This file defines when work is complete and how an agent hands it back to the developer.

## Definition of Done

A task is done only when:

- the diff is limited to the requested scope;
- relevant tests were added or updated;
- validation commands ran or the reason for not running is stated.

Project validation commands are recorded in [AGENTS.md](../AGENTS.md), following the change control in [development.md](development.md).

## Repository Actions

The developer reviews the diff and normally performs the commit manually.

The `swanchristmas/main` branch, configured locally as `origin/main`, is the personal integration baseline and may include the local agent harness; `Qiaoyi-Li/FiniteMPS.jl`, configured as `upstream`, remains the source used for synchronization and upstream contributions.

Prepare an upstream contribution without carrying the harness into its diff:

1. fetch `upstream` and create `pr/<topic>` from the latest `upstream/main`;
2. cherry-pick only the feature commits;
3. inspect `git log --oneline upstream/main..HEAD` and `git diff --name-status upstream/main...HEAD`, then run the relevant validation;
4. push the branch to `origin` and open a pull request with `swanchristmas:pr/<topic>` as the compare branch and `Qiaoyi-Li:main` as the base branch.

## Completion Report

After completing a task, report:

- what changed;
- what was validated;
- what was not validated and why;
- any remaining blocker;
- a suggested commit message.

## Commit Attribution

Suggested commit messages use an `Assisted-By: <agent> <email>` instead of `Co-Authored-By:`.
