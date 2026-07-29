# Hubbard-Holstein full-MPS baseline

This file defines the stable scope, representation, delivery stages, and acceptance gates for the repository's one-dimensional Hubbard-Holstein baseline.

## Purpose

Build a minimal open-boundary full-MPS reference for later controlled comparison with NGSMPS.
This task delivers the FiniteMPS baseline and reproducible driver, not production-scale runs, cross-repository execution, or comparative scientific conclusions.

The Hamiltonian is

```text
H = -t sum(i=1:L-1, sigma) (cdag[i,sigma] c[i+1,sigma] + h.c.)
    + U sum(i) n[i,up] n[i,down]
    + omega sum(i) bdag[i] b[i]
    + g sum(i) (b[i] + bdag[i]) n[i].
```

`nmax` is the largest retained phonon occupation, `db = nmax + 1`, `x = b + bdag`, and the phonon zero-point constant is omitted.
The couplings are real and `omega > 0`; this condition is required by the phonon-vacuum and displaced-oscillator oracles.
The first baseline accepts even electron number with `Nup = Ndown` in the existing `U₁ charge × SU₂ spin` singlet sector; half filling is a smoke-test point rather than a model restriction.

## Representation

- One physical cell is exactly one MPS site with `Pcell = fuse(Pelectron ⊗ Pboson)` and dimension `4 * (nmax + 1)`.
- The boson occupies only the trivial electronic symmetry sector; boson-number `U(1)` is not introduced.
- One fusion map constructs all lifted operators: `Oe ⊗ Ib`, `Ie ⊗ Ob`, `n ⊗ (b + bdag)`, and `Ze ⊗ Ib`.
- Rank-3 fermionic hopping channels retain their auxiliary symmetry leg, with TensorKit domains, codomains, permutations, and fusion maps verified explicitly.
- The implementation belongs under `example/HubbardHolstein/`; it does not add a FiniteMPS export or public API.

## Delivery stages

Each stage starts from the latest accepted `origin/main`, uses an independent `feat/hubbard-holstein-<stage>` branch, and is merged only after human review.

| Stage | Deliverable | Exit evidence |
| --- | --- | --- |
| Contract | This durable contract and its documentation route | Contract PR accepted |
| Local space | Truncated boson, fused space, parity, density, double occupancy, phonon number, displacement, Holstein, and hopping operators | `dim(Pcell) = 4 * (nmax + 1)`, `bdag = adjoint(b)`, `nb = bdag * b`, `x = adjoint(x)`, the finite-cutoff commutator, expected lifted commutators, `Z^2 = I`, and `nmax = 0` reduction |
| Model | `InteractionTree`/`AutomataMPO`, fixed-sector random MPS, energy, norm, and local observables | Hermiticity; `nmax = 0` Hubbard reduction; `g = 0` Hubbard-vacuum factorization; analytic free electrons; `t = 0` convergence toward displaced-oscillator energies |
| ED | Independent occupation-basis small-system oracle | MPO/ED agreement around `1e-10` to `1e-12` and random-state expectation agreement around `1e-10`, with representational limits reported |
| CBE-DMRG | One-site CBE-DMRG with an explicit outer `D` schedule | Energy and CBE, Lanczos, truncation, and timing diagnostics; ED energy agreement around `1e-8`, or a justified error-based tolerance, when ED is available |
| Benchmark | Configurable `L`, `nmax`, and `D` sweeps with JLD2 output | Deterministic tiny smoke run and result round-trip |

The ED stage may be deferred without blocking CBE-DMRG or driver implementation.
Until ED supplies an independent generic interacting-model oracle, the deliverable is a limiting-case-validated baseline rather than fully comparison-ready.
Its dense occupation-basis Hamiltonian must not reuse `InteractionTree`, `addIntr!`, or `AutomataMPO`.

The finite-cutoff boson oracle is `[b, bdag] = I - (nmax + 1) |nmax><nmax|`.

## Result artifact

`example/HubbardHolstein/Project.toml` may add JLD2 without changing the root package dependencies.
Each result records:

- schema version; `L`, `Ne`, `t`, `U`, `omega`, `g`, `nmax`, `D_schedule`, convergence thresholds, and seed;
- Git revision, Julia/package versions, thread and BLAS context;
- initial and final MPS, norms, energies, observables, and bond dimensions;
- total, hopping, Hubbard, phonon, and Holstein energies;
- local density, double occupancy, phonon number, displacement, and density-displacement coupling;
- sweep, target `D`, energy change, CBE, Lanczos, truncation, timing, and convergence histories;
- physical, MPS-bond, and MPO-bond dimensions, convergence status, and stop reason.

Parameters and diagnostics remain available as ordinary scalars and arrays even though the MPS objects retain Julia types.
Result files omit reconstructible MPOs, environments, and contraction caches, and the first baseline does not implement checkpoint/resume.
This task does not run or commit production-scale result files.

## Acceptance and exclusions

New stochastic tests use deterministic seeds.
Every stage runs focused tests and the full package test command; documentation changes also run the prescribed Documenter build.
Pull requests record the commit SHA, exact commands, outcomes, and known limitations and are reviewed manually; this task does not add package-test CI.
The phonon cutoff `nmax` and MPS bond dimension `D` remain independent convergence axes.

Local Basis Optimization, pseudosites, NGS or transformed Hamiltonians, phonon dispersion, nonlocal electron-phonon coupling, periodic boundaries, unrelated core refactors, and production benchmark runs are out of scope.
No stage weakens an oracle or redesigns core MPS, MPO, Environment, InteractionTree, or CBE boundaries without minimal failing evidence and renewed approval.

## Repository delivery

Stage branches push only to `origin` and target `swanchristmas/main`.
They are not stacked, are not merged by the coding agent, and do not target `Qiaoyi-Li/main`; transient logs and blockers stay in pull-request bodies.
The next implementation gate after this contract merges is the composite local-space stage.

## See also

- [Documentation map](README.md) defines the `docs/` directory boundary.
- [Codebase map](codebase.md) routes implementation and test discovery.
- [Testing policy](../decisions/testing-policy.md) defines acceptable evidence.
- [Delivery policy](../decisions/delivery.md) defines repository actions and completion reporting.
