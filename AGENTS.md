# AGENTS.md

This file is the executable contract boundary for local coding agents: keep only rules that constrain read/change/decision/verification behavior, and move project facts, rationale, and plans elsewhere.

## Context precedence

When instructions conflict, follow this priority: user prompt > AGENTS.md > local code comments > repository docs, and report back the mismatch.

## Project governance

Read the relevant durable contract before working in its area:

- [development.md](decisions/development.md): roles, uncertainty routing, and workflow change control;
- [implementation-policy.md](decisions/implementation-policy.md): topology evolution, complexity boundaries, and redesign evidence;
- [testing-policy.md](decisions/testing-policy.md): public behavior and independent acceptance evidence;
- [documentation-style.md](decisions/documentation-style.md): documentation ownership and authoring rules;
- [delivery.md](decisions/delivery.md): completion, validation, reporting, and repository actions.

Do not modify project scope, dependencies, or public contracts without explicit maintainer approval.

## Project orientation

Read the [codebase map](docs/codebase.md) to locate implementation, examples, tests, and public documentation before changing code, then verify its guidance against the current source and tests.

## Core boundaries

Contract precedes implementation; "why" precedes "how".

- do not weaken tests, oracles, or acceptance thresholds to make an implementation pass;
- the diff is limited to the requested scope;
- do not commit, push, or open pull requests unless explicitly requested.

## Validation

- For package behavior, run `julia --project=. -e 'using Pkg; Pkg.test()'`.
- For documentation changes, run `julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'` and then the default fast build with `julia --project=docs/ docs/make.jl`.
- When changing the Hubbard or Heisenberg numerical tutorials or their static figures, also run `FINITEMPS_RUN_HEAVY_DOCS=true JULIA_NUM_THREADS=1 julia --project=docs/ docs/make.jl` and review all six generated figures before refreshing the committed copies.

Complete work according to [delivery.md](decisions/delivery.md), including validation and reporting requirements.
