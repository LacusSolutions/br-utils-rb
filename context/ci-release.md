---
id: ci-release
title: CI and release awareness
scope: .github/workflows/
triggers:
  - editing CI or release workflow files
  - understanding the build and test pipeline
  - verifying local changes before claiming done
  - investigating a CI failure
---

# ci-release

This harness documents CI and release workflows for awareness. Agents do **not** run releases or publish. All paths are relative to the repo root.

## Repository constraints

- **Do not run** `rake release`, `gem push`, create GitHub Releases, or push git tags. Only the developer (via the release workflow) does that.
- CI workflow edits must stay within `.github/workflows/`.
- Do not add secrets, tokens, or credentials to workflow files.
- Before claiming any implementation task is done, validate locally with the commands in [Local validation](#local-validation-commands).

## CI workflow (`.github/workflows/ci.yml`)

Triggered on every push to any branch and on `workflow_dispatch`.

### Discovery step

CI first **dynamically discovers** packages by scanning `packages/*/`:

- A package joins the **test** matrix if it has both `<pkg>.gemspec` and a `tests/` directory.

Adding a new package is picked up automatically once it has a gemspec and `tests/`.

### Matrix jobs

| Job | Workflow | Matrix |
|-----|----------|--------|
| Lint | `.github/workflows/.lint.yml` | Ruby `[3.1, 3.2, 3.3, 3.4, 4.0]` (repo-wide RuboCop) |
| Test | `.github/workflows/.test.yml` | `packages × Ruby [3.1, 3.2, 3.3, 3.4, 4.0]` |
| Monorepo DAG | inline | Ruby 3.2 — `bundle exec rake monorepo:check_cycles` |

Lint is **not** per-package; one RuboCop run covers the whole tree per Ruby version. Tests `cd packages/<pkg> && bundle install && bundle exec rake test`.

## Release workflow (`.github/workflows/release.yml`)

Triggered by **manual `workflow_dispatch`** only. Inputs: `package` (required — the **folder** name), `version` (optional — defaults to the latest section in `CHANGELOG.md`).

Steps:
1. Run lint + test for the package (reusable workflows; min/max Ruby from repo variables).
2. Prepare release notes from `packages/<pkg>/CHANGELOG.md` via `bin/release-notes`; read the gem name from the gemspec.
3. Validate git state: the tag `<gem-name>@X.Y.Z` must not already exist, and a `<pkg>/main` branch must exist.
4. Write the version into `packages/<dir>/src/<gem-name>/version.rb`, then build and publish via `rubygems/release-gem` (OIDC trusted publishing).
5. Create a GitHub Release with tag `<gem-name>@X.Y.Z` (marked pre-release when the version contains a letter, e.g. `1.2.3.rc1`).

Agents never trigger or simulate this workflow. If you need to release a package, ask the developer.

## Other workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `subtrees-sync.yml` | push to `main` | Sync each package to its `<pkg>/main` branch |
| `license-update.yml` | LICENSE change | Propagate root `LICENSE` to packages |
| `pr-author-assign.yml` | PR opened | Auto-assign the PR author |

Agents do not interact with these directly.

## Local validation commands

Run these from the repo root before declaring any implementation task complete:

```bash
# CI-equivalent
rake lint
rake monorepo:check_cycles
rake monorepo:each[test]

# Isolated to one package
cd packages/<pkg> && bundle exec rake test
```

If any command fails, fix the issue before marking the task done.

## When to edit workflow files

Edit `.github/workflows/*.yml` only when:
- Adding a new job or check required by a tooling decision.
- Bumping a pinned action version (actions are pinned by SHA) after developer approval.
- Fixing a broken workflow step.

Workflow file changes are dev-only and do **not** require a CHANGELOG entry.

## Reference

| Concern | Path |
|---------|------|
| CI entry | `.github/workflows/ci.yml` |
| Reusable lint workflow | `.github/workflows/.lint.yml` |
| Reusable test workflow | `.github/workflows/.test.yml` |
| Release workflow | `.github/workflows/release.yml` |
| Subtree sync | `.github/workflows/subtrees-sync.yml` |
| Release-notes CLI | `bin/release-notes` |
| Changelog harness | [`context/changelogs.md`](changelogs.md) |
