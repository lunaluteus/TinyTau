---
name: Worker Mode `Fix`
description: Diagnose and resolve the latest failed CI workflow run on the current branch before taking on any other mode.
---

## Procedure

1. **Inspect Failed Runs**: Using the failing workflow run(s) detected during mode selection in [`worker.md`](./worker.md) (or via `gh run list --branch <branch> --limit 20 --json databaseId,workflowName,status,conclusion,createdAt,url`), inspect the failure logs:

   ```sh
   gh run view <run-id> --log-failed
   ```

2. **Diagnose & Fix Root Cause**:

   - **`Lean Action` failure**: Reproduce locally with `lake build --wfail`, fix compilation errors, warnings, or non-standard axioms (no `sorry`, `admit`, `native_decide`, or custom `axiom`s), and re-verify per [`guide/build.md`](/.tinytau/guide/build.md).
   - **`Compare Human Roadmap` failure**: Run `bash .tinytau/scripts/compare-human.sh` locally. Never modify `.tinytau/sync.yml` or alter human-authored `roadmap/` files away from upstream; restore any accidentally modified human-authored file to match `human-repo` at `.tinytau/sync.yml`'s `human-sha`.
   - **`Pages` failure**: Reproduce locally with `bash .tinytau/scripts/build-roadmap.sh`, `lake build --wfail`, and `bash .tinytau/scripts/build-docs.sh` as needed per [`guide/tooling.md`](/.tinytau/guide/tooling.md), and fix broken `*-ai.qmd` / `*-ai.yml` / Quarto / `doc-gen4` issues.
   - **Other workflow failure**: Inspect the failed step and fix the underlying configuration or code issue cleanly.

3. **Self-Check & Commit**: Verify the fix locally against the failing check's requirements and [`guide/rubrics.md`](/.tinytau/guide/rubrics.md), then commit per [`worker.md`](./worker.md#committing-work) (the `gh.push-min-interval` throttle does not apply when pushing a CI fix).
