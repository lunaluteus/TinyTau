---
name: Lean Build and Verification Standard
description: Defines the Lean verification requirements enforced by GitHub Actions.
---

[TinyTau CI](/.github/workflows/ci.yml) runs both Lean checks below on pull requests and publishing pushes.

1. **Warning-Free Build**: `lake build --wfail` succeeds with zero errors and zero warnings (`build-args: "--wfail"`).
2. **Standard Axioms Only**: All declarations depend only on `propext`, `Classical.choice`, and `Quot.sound` (`axiom-audit-allow: "propext,Classical.choice,Quot.sound"`). Do not leave `sorry` / `admit` (`sorryAx`), `native_decide` (`Lean.ofReduceBool`), or custom `axiom`s; CI verifies this via `axiom-audit`.
