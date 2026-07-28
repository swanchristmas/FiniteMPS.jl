# Testing Policy

This file defines how tests express public boundaries before implementation details.

Tests should specify:

- accepted inputs;
- observable outputs;
- invariants;
- error behavior;
- minimal integration paths;
- acceptance thresholds and external oracles when relevant.

Tests should not specify:

- private helper layout;
- incidental intermediate state;
- implementation ordering;
- formatting-only behavior.

Write tests against the public boundary before relying on internals. If a test must depend on hidden implementation details, refactor until the real boundary is explicit.

An implementation must not change expected results, acceptance thresholds, or external oracles merely to make itself pass.
