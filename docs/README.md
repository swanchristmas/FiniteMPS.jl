# Documentation

This directory owns the Documenter site source and the repository-facing maps that explain how FiniteMPS.jl is organized.

## Published documentation

- [src/index.md](src/index.md) is the public site entry point and organizes tutorials, local spaces, library references, and the API index.
- [make.jl](make.jl) defines the site navigation, build, and deployment behavior.
- [Project.toml](Project.toml) defines the documentation environment.

Install the documentation environment from the repository root:

```bash
julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
```

The default build executes lightweight examples and uses the committed Hubbard and Heisenberg figures:

```bash
julia --project=docs/ docs/make.jl
```

Run the seeded numerical tutorials explicitly, using one Julia thread:

```bash
FINITEMPS_RUN_HEAVY_DOCS=true JULIA_NUM_THREADS=1 julia --project=docs/ docs/make.jl
```

The heavy build writes six figures under `docs/build/tutorial/figs_Heisenberg/` and `docs/build/tutorial/figs_Hubbard/`.
Review every generated figure, then copy the approved PNG files into the matching directories under `docs/src/tutorial/` to refresh the published static assets.
Static figures are scientific review artifacts, not byte-for-byte regression oracles across dependency versions.

The regular Documentation workflow enforces the fast-build boundary.
The manual Heavy Documentation workflow runs the full numerical source, uploads the complete `docs/build` artifact, and never deploys the site.

## Repository navigation

- [codebase.md](codebase.md) routes contributors and coding agents through the implementation, examples, tests, and public documentation.
- [hubbard-holstein-baseline.md](hubbard-holstein-baseline.md) records the staged contract and acceptance gates for the repository's full-MPS Hubbard-Holstein reference.
- [FiniteMPS.jl](../README.md) introduces package capabilities, installation, and user-facing examples.

## See also

- [decisions/](../decisions/) records development-process decisions, which do not belong here.
