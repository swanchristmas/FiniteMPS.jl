# Implementation Policy

This file defines how implementation topology evolves from declared structure into working semantics without unnecessary expansion.

## Topology Evolution

Treat structure and behavior as coupled axes:

- Vertical evolution creates skeletons before internal logic so syntactic topology exists before unit semantics fill it.
- Horizontal evolution follows the “make it work, make it right, make it fast” sequence[^three-m]:
  1. write the smallest plain-code implementation that satisfies the contract;
  2. simplify the working code and align its units with the declared topology;
  3. optimize only against explicit performance evidence and a relevant benchmark.

## Complexity Boundary

- Follow the KISS principle[^kiss]: prefer the smallest conceptual diff that satisfies the contract.
  - If the requested scope is over-designed, surface the simpler route before implementation.
- Add abstraction only when required by multiple concrete uses or an explicit contract boundary.

## Redesign Gate

When implementation friction appears, produce the smallest failing evidence before proposing a broader redesign.

A broader redesign must identify which existing boundary fails and why a local correction is insufficient.

[^three-m]: Emre Demircan, [“Make It Work, Make It Right, Make It Fast: The Three Steps to Quality Code”](https://medium.com/@edemircan/make-it-work-make-it-right-make-it-fast-the-three-steps-to-quality-code-e452160595c9), Medium, February 13, 2025.
[^kiss]: [“KISS principle”](https://en.wikipedia.org/wiki/KISS_principle), Wikipedia.
