---
name: finite-mps-fork
description: Synchronize the swanchristmas FiniteMPS.jl fork from Qiaoyi-Li release tags and prepare clean contributions back to upstream. Use when checking fork divergence, merging an upstream tag, preserving upstream ancestry through a pull request, or creating an upstream contribution branch that must exclude fork-only context.
---

# FiniteMPS Fork Delivery

Preserve the distinction between the personal integration fork and the upstream package while producing reviewable Git ancestry and validation evidence.

## Establish the live boundary

- Treat `origin` (`swanchristmas/FiniteMPS.jl`) as the personal integration repository and `origin/main` as its baseline.
- Treat `upstream` (`Qiaoyi-Li/FiniteMPS.jl`) as the release source and upstream-contribution target.
- Before a mutation, inspect the current worktree, all relevant remotes, the exact branch heads, and any annotated and peeled tag objects.
- Use an independent worktree for delivery work. Preserve unrelated working-tree changes and stashes without applying, rewriting, or deleting them.

## Synchronize an upstream release tag

1. Fetch `origin`, `upstream`, and tags. Record the annotated tag object and its peeled commit.
2. Compare the peeled tag with `upstream/main`. If upstream has advanced, synchronize only the approved tag and report the later commits separately.
3. Create `sync/upstream-vX.Y.Z` from the live, exact `origin/main` commit.
4. Merge the peeled tag commit with `git merge --no-ff`. Keep the sync branch free of fork-only fixes, formatting changes, and test commits.
5. Inspect the merge parents, commit graph, merge tree, and upstream range. Confirm that the result contains the expected upstream change and no unrelated fork change.
6. Run one full package test, the default fast documentation build, and any focused oracle required by the upstream change. Run Heavy Documentation only under the triggers in [the documentation contract](../../../docs/README.md).
7. Recheck the live remote SHAs before a normal push. Open a pull request to `swanchristmas/main` and record the exact base, head, commands, results, and limitations.
8. Require the maintainer to choose **Create a merge commit**. Do not squash or rebase a synchronization PR.
9. After merge, confirm that the peeled tag commit is an ancestor of `origin/main`, that the tag is no longer behind the fork, and that the post-merge Documentation check passes.

## Prepare a contribution to upstream

1. Fetch the live `upstream/main` and create `pr/<topic>` from its exact commit in an independent worktree.
2. Cherry-pick only portable feature commits. Exclude repository harness files, fork synchronization commits, fork-only context, and unrelated local changes.
3. Inspect `git log --oneline upstream/main..HEAD` and `git diff --name-status upstream/main...HEAD` before validation.
4. Run the focused checks for the changed behavior plus the package and documentation checks required by [AGENTS.md](../../../AGENTS.md).
5. Push the branch to `origin`, then open a cross-fork pull request from `swanchristmas:pr/<topic>` to `Qiaoyi-Li:main`.

## Stop and report

Stop before pushing or merging when any of these occurs:

- a live branch, tag object, or peeled tag commit differs from the recorded SHA;
- the ordinary merge conflicts or produces unexpected parents, files, or ancestry;
- the first package test execution, focused oracle, or required documentation build fails;
- the worktree contains changes outside the intended delivery;
- validation exposes a scientific or behavioral difference that lacks an approved oracle.

When a pure upstream merge inherits a source-quality finding, reproduce it on the exact upstream range and report it instead of silently adding a fork-only repair. The maintainer retains authority for every pull-request merge and any expansion beyond the approved release tag or contribution scope.
