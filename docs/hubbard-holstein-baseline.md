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

`L` is the number of physical electron-phonon cells, `nmax` is the largest retained phonon occupation, `db = nmax + 1`, `x = b + bdag`, and the phonon zero-point constant is omitted.
The couplings are real and `omega > 0`; this condition is required by the phonon-vacuum and displaced-oscillator oracles.
The first baseline accepts even electron number `Ne` in the existing `U₁ charge × SU₂ spin` total-spin singlet sector; the independent occupation-basis ED oracle uses `Nup = Ndown = Ne / 2`, and half filling `Ne = L` is a smoke-test point rather than a model restriction.

## Representation

Fusing one cell would place its full `4 * db` Hilbert space on one MPS local leg.
This Hubbard-Holstein baseline instead accepts additional electron-phonon entanglement cuts so that electron and phonon degrees of freedom remain separate alternating sites; this changes the tensor-network topology, not the physical cell Hilbert-space dimension.

- Cell `i` maps to adjacent MPS sites `electron_site(i) = 2i - 1` and `phonon_site(i) = 2i`, so the MPS/MPO length is `2L`.
- Electron sites use `Pe = U1SU2Fermion.pspace`; phonon sites use `Pb = Rep[U₁×SU₂]((0, 0) => db)`, without a boson-number `U(1)`.
- Site data are ordinary heterogeneous vectors `pspaces = [Pe, Pb, ...]` and `Zsites = [Ze, nothing, ...]`; `nothing` means that Jordan-Wigner parity is not applied on a bosonic phonon site.
- Electron `Z`, density, double occupancy, and hopping channels remain on electron sites, while `b`, `bdag`, phonon number, and displacement remain on phonon sites.
- The physically onsite Holstein coupling becomes an MPS two-site `(n, x)` term on adjacent electron and phonon sites; electron hopping crosses the intervening phonon identity and needs no fused or lifted operator.
- Every `addIntr!` and `addObs!` call must receive the complete `pspaces` vector; fermionic terms also receive `Zsites`.
- `nmax = 0` retains `2L` sites, with one-dimensional phonon sites and `b = bdag = nb = x = 0`.
- The implementation remains under `example/HubbardHolstein/`; it adds no FiniteMPS export or public API.

## Delivery stages

Contract changes precede implementation changes and receive human review; after Local-space acceptance, each later stage starts from the latest accepted `origin/main`, uses an independent `feat/hubbard-holstein-<stage>` branch, and is merged only after human review.

| Stage | Deliverable | Exit evidence |
| --- | --- | --- |
| Contract | This alternating-site contract and its documentation route | Contract revision accepted before implementation changes |
| Local space | Separate electron and truncated-boson spaces, bare operators, and an alternating-site `AutomataMPO` compatibility smoke | Boson algebra and finite-cutoff commutator; `nmax = 0` trivial phonon site; adjacent Holstein term; electron hopping across the correct phonon identity with parity only on electron sites |
| Model | Production `2L` layout vectors, `InteractionTree`/`AutomataMPO`, fixed-sector random MPS, energy, norm, and local observables | Hermiticity; `nmax = 0` Hubbard equivalence; `g = 0` Hubbard-vacuum factorization; analytic free electrons; `t = 0` convergence toward displaced-oscillator energies |
| ED | Independent occupation-basis small-system oracle | MPO/ED agreement around `1e-10` to `1e-12` and random-state expectation agreement around `1e-10`, with representational limits reported |
| CBE-DMRG | One-site CBE-DMRG over `2L` sites with one explicit outer `D` schedule | Energy and site/bond-kind CBE, Lanczos, truncation, and timing diagnostics; ED energy agreement around `1e-8`, or a justified error-based tolerance, when ED is available |
| Benchmark | Configurable `L`, `nmax`, and `D` sweeps with JLD2 output | Deterministic tiny smoke run and result round-trip |

The ED stage may be deferred without blocking CBE-DMRG or driver implementation.
Until ED supplies an independent generic interacting-model oracle, the deliverable is a limiting-case-validated baseline rather than fully comparison-ready.
Its dense occupation-basis Hamiltonian must not reuse `InteractionTree`, `addIntr!`, or `AutomataMPO`.

The finite-cutoff boson oracle is `[b, bdag] = I_b - (nmax + 1) |nmax><nmax|`.
At `nmax = 0`, Hubbard reduction means matching energies, Hamiltonian actions, and electronic observables after removing trivial one-dimensional phonon factors, not comparing MPS or MPO containers.
The electron local `U₁` label is `n - 1`, so the physical total label is `Ne - L`; the current random-MPS boundary convention uses left label `L - Ne`.

## Result artifact

`example/HubbardHolstein/Project.toml` may add JLD2 without changing the root package dependencies.
Each result records:

- schema version; `L`, `Ne`, `t`, `U`, `omega`, `g`, `nmax`, `D_schedule`, convergence thresholds, seed, Git revision, Julia/package versions, and thread/BLAS context;
- initial and final MPS, norms, and topology metadata including `mps_length = 2L`, `site_kind[1:2L]`, and `bond_kind[1:2L-1]`;
- total, hopping, Hubbard, phonon, and Holstein energies normalized per physical cell, plus density, double occupancy, phonon number, displacement, and density-displacement observables indexed by cell `i = 1:L`;
- MPS/MPO dimensions and CBE, Lanczos, truncation, and timing diagnostics indexed by MPS site `s = 1:2L` or internal bond `b = 1:2L-1`, while sweep histories, convergence status, and stop reason remain sweep- or run-scoped.

Parameters and diagnostics remain available as ordinary scalars and arrays even though the MPS objects retain Julia types.
Result files omit reconstructible MPOs, environments, and contraction caches, and the first baseline does not implement checkpoint/resume.
This task does not run or commit production-scale result files.

## Acceptance and exclusions

New stochastic tests use deterministic seeds.
Every stage runs focused tests and the full package test command; documentation changes also run the prescribed Documenter build.
Pull requests record the commit SHA, exact commands, outcomes, and known limitations and are reviewed manually; this task does not add package-test CI.
The phonon cutoff `nmax` and MPS bond dimension `D` remain independent convergence axes.
The alternating representation is a decision for this Hubbard-Holstein baseline, not a mandatory representation for every mixed-degree-of-freedom model.

Local Basis Optimization, pseudosites, NGS or transformed Hamiltonians, phonon dispersion, nonlocal electron-phonon coupling, periodic boundaries, unrelated core refactors, and production benchmark runs are out of scope.
These alternating sites are not pseudosites: each phonon mode remains one site containing the full `db`-dimensional truncated occupation space.
No stage weakens an oracle or redesigns core MPS, MPO, Environment, InteractionTree, or CBE boundaries without minimal failing evidence and renewed approval.

## Repository delivery

Stage branches push only to `origin` and target `swanchristmas/main`.
They are not stacked, are not merged by the coding agent, and do not target `Qiaoyi-Li/main`; transient logs and blockers stay in pull-request bodies.

## Implementation ownership

The repo-private implementation is owned by [the Hubbard-Holstein example](../example/HubbardHolstein/), with acceptance coverage in [the Hubbard-Holstein tests](../test/HubbardHolstein/runtests.jl).
Local-space implementation changes require prior acceptance of this contract, and the Model stage follows only after the revised Local-space stage is accepted.

## See also

- [Documentation map](README.md) defines the `docs/` directory boundary.
- [Codebase map](codebase.md) routes implementation and test discovery.
- [Testing policy](../decisions/testing-policy.md) defines acceptable evidence.
- [Delivery policy](../decisions/delivery.md) defines repository actions and completion reporting.
