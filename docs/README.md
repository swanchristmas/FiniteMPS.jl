# Documentation

This directory owns the Documenter site source and the repository-facing maps that explain how FiniteMPS.jl is organized.

## Published documentation

- [src/index.md](src/index.md) is the public site entry point and organizes tutorials, local spaces, library references, and the API index.
- [make.jl](make.jl) defines the site navigation, build, and deployment behavior.
- [Project.toml](Project.toml) defines the documentation environment.

Build the site from the repository root:

```bash
julia --project=docs/ -e 'using Pkg; Pkg.develop(PackageSpec(path=pwd())); Pkg.instantiate()'
julia --project=docs/ docs/make.jl
```

## Repository navigation

- [codebase.md](codebase.md) routes contributors and coding agents through the implementation, examples, tests, and public documentation.
- [hubbard-holstein-baseline.md](hubbard-holstein-baseline.md) records the staged contract and acceptance gates for the repository's full-MPS Hubbard-Holstein reference.
- [FiniteMPS.jl](../README.md) introduces package capabilities, installation, and user-facing examples.

## See also

- [decisions/](../decisions/) records development-process decisions, which do not belong here.
