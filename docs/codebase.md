# Codebase map

This file routes contributors and coding agents from a task to the authoritative implementation, examples, tests, and public documentation.

FiniteMPS.jl is a Julia 1.11 package built on TensorKit for finite MPS/MPO calculations of ground-state, finite-temperature, and dynamical properties.
A typical workflow moves from local spaces through interaction and MPO construction, environments and projective Hamiltonians, numerical algorithms, and observable evaluation.

## Source map

The include and export order in [FiniteMPS.jl](../src/FiniteMPS.jl) is the authoritative map of package composition.

| Concern | Start here |
| --- | --- |
| Tensor classification and storage | [TensorWrapper/](../src/TensorWrapper/), [MPS/](../src/MPS/), [MPO/](../src/MPO/), and [SparseMPO/](../src/SparseMPO/) |
| Contraction state and effective Hamiltonians | [Environment/](../src/Environment/) and [ProjectiveHam/](../src/ProjectiveHam/) |
| Hamiltonian construction from arbitrary interactions | [IntrTree/](../src/IntrTree/) and `AutomataMPO` |
| Observables and imaginary-time proxies | [Observables/](../src/Observables/) |
| DMRG, TDVP, Lanczos, SETTN/tanTRG, and CBE | [Algorithm/](../src/Algorithm/) |
| MPS/MPO algebra operations | [Algebra/](../src/Algebra/) |
| Spin and fermion physical spaces | [LocalSpace/](../src/LocalSpace/) |
| Runtime initialization, defaults, and utilities | [init.jl](../src/init.jl), [Globals.jl](../src/Globals.jl), [Defaults.jl](../src/Defaults.jl), and [utils/](../src/utils/) |

## Evidence and examples

- [Public documentation](src/index.md) describes supported workflows and API surfaces for users.
- [Examples](../example/) exercise high-level free-fermion and Heisenberg XXZ workflows, including DMRG, dynamics, and finite-temperature calculations.
- [Tests](../test/runtests.jl) currently cover TensorKit replacement operations, observable trees, Automata MPO/free-fermion behavior, and multi-site observable contractions, including fermionic cases; they are not a complete algorithm inventory.

Use this map for navigation only.
Before changing behavior, confirm the relevant contract in current source, tests, and public documentation, and add acceptance evidence at the boundary being changed.

## See also

- [Documentation map](README.md) explains the `docs/` directory.
- [Project README](../README.md) gives the package overview and installation path.
- [Hubbard-Holstein baseline](hubbard-holstein-baseline.md) owns the alternating-site example contract and staged acceptance gates.
