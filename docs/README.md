# Documentation

This directory owns the Documenter site source and the repository-facing maps that explain how FiniteMPS.jl is organized.

## Published documentation

- [src/index.md](src/index.md) is the public site entry point and organizes tutorials, local spaces, library references, and the API index.
- [make.jl](make.jl) defines the site navigation, build, and deployment behavior.
- [Project.toml](Project.toml) defines the documentation environment.

## Documentation validation

Long-running tensor-network calculations verify scientific tutorial results, but they do not improve feedback for ordinary prose or API-documentation edits.
Running DMRG, SETTN, and TDVP on every push would make routine validation take about an hour and let a numerical failure block unrelated site changes.
The default build therefore renders reviewed static figures, while the heavy build reruns the numerical source only when its results may have changed.

### Fast build

Install the documentation environment from the repository root:

```bash
julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
```

The default build executes lightweight examples and uses the committed Hubbard and Heisenberg figures:

```bash
julia --project=docs/ docs/make.jl
```

Use this build for every documentation change and for routine CI.
It executes lightweight examples but does not run the Hubbard or Heisenberg DMRG, SETTN, or TDVP calculations.

### Heavy numerical build

Run the heavy validation when a change can alter the Hubbard or Heisenberg results:

- tutorial source, random seed, algorithm, sweep, truncation, or other numerical parameters change;
- a documentation dependency changes in a way that can affect the numerical execution;
- the six committed static figures need to be refreshed;
- the heavy workflow itself changes and must be checked once on `main` after merge.

Ordinary prose, navigation, or API-reference edits require only the fast build.

Run the seeded numerical tutorials locally with a fixed four-thread Julia boundary:

```bash
FINITEMPS_RUN_HEAVY_DOCS=true JULIA_NUM_THREADS=4 julia --project=docs/ docs/make.jl
```

After the [Heavy Documentation workflow](../.github/workflows/documentation-heavy.yml) is present on the default branch, run it on GitHub through **Actions → Heavy Documentation → Run workflow**, selecting the branch to validate.
The workflow pins Julia 1.11 and four Julia threads, retains a 120-minute timeout to bound hangs or performance regressions, and uploads the complete `docs/build` directory.
It runs only when explicitly dispatched and never deploys the documentation site.

Download the `heavy-documentation-<commit SHA>` artifact and review all six figures under `tutorial/figs_Heisenberg/` and `tutorial/figs_Hubbard/`.
Only after scientific review should approved PNG files be copied into the matching directories under `docs/src/tutorial/` and committed.
The figures are review artifacts, not byte-for-byte regression oracles across dependency versions.

## Repository navigation

- [codebase.md](codebase.md) routes contributors and coding agents through the implementation, examples, tests, and public documentation.
- [hubbard-holstein-baseline.md](hubbard-holstein-baseline.md) records the staged contract and acceptance gates for the repository's full-MPS Hubbard-Holstein reference.
- [FiniteMPS.jl](../README.md) introduces package capabilities, installation, and user-facing examples.
