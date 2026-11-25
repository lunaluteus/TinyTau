---
name: GitHub Actions and Documentation Guide
description: Explains the GitHub Actions workflows for Lean verification, roadmap integrity, and Pages deployment.
---

## GitHub Actions Workflow

[TinyTau CI](/.github/workflows/ci.yml) runs on pushes to `main` or `master` and on pull requests.

- **Human Check** compares the human-authored files in `roadmap/` with the upstream tree pinned in [the sync record](/.tinytau/sync.yml), using the ownership rules in [the roadmap schema](/.tinytau/schema/roadmap.md).
- **Build** runs [Lean verification](/.tinytau/guide/build.md). On pushes to `main` or `master`, the same job uses Quarto and doc-gen4 to render the site with the compiled Lean project. It uploads the generated site for deployment.
- **Pages** deploys the site artifact to GitHub Pages.
- **Add Tag** runs after deployment on pushes to existing branches and tags Lean toolchain updates. A tagging error remains visible in the step log and is treated as non-blocking.

Pull requests end after **Build**.
