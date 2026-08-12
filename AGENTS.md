# AGENTS.md

FiniteMPS.jl is a Julia 1.11 package for finite MPS/MPO calculations built on TensorKit.

## Project context

- Read the [codebase map](docs/codebase.md) before changing implementation, examples, tests, or public documentation, then verify its route against the current source.
- Read the [Hubbard-Holstein baseline](docs/hubbard-holstein-baseline.md) before changing that example or its staged acceptance contracts.
- Use [`finite-mps-fork`](.agents/skills/finite-mps-fork/SKILL.md) when synchronizing an upstream release tag, checking fork divergence, preserving upstream ancestry, or preparing a contribution to `Qiaoyi-Li/FiniteMPS.jl`.

## Validation routing

- For package behavior, run `julia --project=. -e 'using Pkg; Pkg.test()'`.
- For documentation changes, install the documentation environment with `julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'`, then run the default fast build with `julia --project=docs/ docs/make.jl`.
- When changing the Hubbard or Heisenberg numerical tutorials, their static figures, numerical dependencies, or heavy-workflow behavior, also run `FINITEMPS_RUN_HEAVY_DOCS=true JULIA_NUM_THREADS=4 julia --project=docs/ docs/make.jl` and review all six generated figures.
- Follow the fast/heavy triggers, artifact procedure, and 120-minute workflow boundary in [the documentation contract](docs/README.md).
