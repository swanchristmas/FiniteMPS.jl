# Documentation style

This file defines the conventions for all natural-language documentation in this repository, including markdown files, docstrings, comments, and pseudo-code.

## File and Directory Contracts

- Every file's first non-heading sentence states the file's essence.
- Every `README.md` defines its directory's contract.
- Child files specialize the directory contract instead of restating it. Possible links to others should be listed in the ending section `## See also`.
- Content belongs in a file only when that file's boundary explains why it belongs there.
- Delete prose that changes no decision, behavior, or reader action.

## Authoring Workflow

- Create headings before prose.
- Prefer pseudo-code to prose in planning when it clarifies language-independent design before implementation.

## Budget and Formatting

Markdown files should stay under 100 lines. If a file grows beyond that, apply:

1. pruning — delete stale, repeated, or non-actionable text;
2. refactor — split durable subtopics into linked files;
3. compress — shorten language without weakening the contract.

- Do not manually reflow code only for visual alignment.
- Do not hard-wrap Markdown, comments, git commit messages, or docstrings merely to satisfy a visual line length.
- For prose, prefer semantic line breaks: one sentence or one logical clause per line when helpful.

## Markdown file references

- Use Markdown links, `[name](path)`, for repository files that function as documentation nodes.
- Use inline code only when referring to a literal filename, directory, command, glob pattern, or path fragment rather than creating a navigational edge. For example, `**/*.md`.
- Dangling links are allowed only for planned committed files, where the link intentionally marks a documentation node that should be created.
- Repeat the link when the reference still has navigational value.

## Public/private boundary

- Referencing the role of the private directory `notes_local/` is allowed; it is part of the repository topology.
- Committed documentation must not depend on the contents of a specific private file.
- The test is whether the private content would guide a future diff.
  - If it would, it is vital and must be promoted: summarize it in one sentence in place;
  - if one sentence is not enough, the file's ownership boundary is wrong — reorganize the content into its correct public home.
- If it is only personal-reminder rationale, it stays in `notes_local/` with no public link.
