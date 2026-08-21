---
id: lint-config
title: Lint and format configuration
scope: .rubocop.yml, Rakefile, lib/rake/lint_tasks.rake, .githooks/
triggers:
  - changing the shared RuboCop configuration
  - modifying lint Rake tasks
  - understanding how lint runs per-package vs root
  - editing git hooks
---

# lint-config

Manage the lint and format setup for br-utils-ruby packages. All paths are relative to the repo root.

## Repository constraints

- **Do not duplicate lint config in packages.** Shared config lives in root `.rubocop.yml`; lint tasks live in `lib/rake/lint_tasks.rake`.
- **Do not add per-package `.rubocop.yml` files.** Every package shares the root config.
- Lint and format config changes are **dev-only** — they do not require a CHANGELOG entry.

## Shared lint/format setup

Linting and formatting use **RuboCop** with two plugins:

- **rubocop-rspec** — specs under `tests/**/*.spec.rb`
- **rubocop-packaging** — gemspec hygiene

### RuboCop (`.rubocop.yml`)

- `TargetRubyVersion: 3.1`, `NewCops: enable`.
- `Layout/LineLength` max **120**.
- `Style/FrozenStringLiteralComment`: `always`.
- `Style/Documentation`: **disabled** — YARD comments are the documentation standard (see [`context/yard.md`](yard.md)), not RuboCop `MissingDocumentation`.
- `Naming/FileName` excluded under `packages/**/*` — hyphenated require paths (`cnpj-gen.rb`) are intentional.
- `Metrics/BlockLength` excluded for Rakefiles and `tests/**/*`.

### What gets linted

`rake lint` runs `bundle exec rubocop` from the **ruby/** root and covers the whole tree (packages, `lib/`, `bin/`, Rakefiles). There is no per-package lint invocation in CI.

## Running lint

From the **ruby/** repository root:

```bash
rake lint                     # check (what CI runs: bundle exec rubocop)
rake format                   # auto-correct safe offenses (rubocop -a)
rake lint:autocorrect_all     # auto-correct including unsafe (rubocop -A)
rake lint:commits             # conventional commits in origin/main..HEAD
```

Override the commit range with `COMMIT_RANGE=… rake lint:commits`.

## Git hooks (`.githooks/`)

Install with `rake hooks:install` (points `core.hooksPath` at `.githooks/`). Undo with `rake hooks:uninstall`.

| Hook | Stage | What it does |
|------|-------|--------------|
| `pre-commit` | pre-commit | `rubocop --autocorrect` on staged Ruby files; re-stages only linting changes; aborts if offenses remain |
| `commit-msg` | commit-msg | Validates conventional commit message + scope via `bin/commit-lint` |
| `pre-push` | pre-push | `rake test` plus `rake monorepo:each[test]`; delete-only pushes skip the suite |

Both `pre-commit` and `pre-push` prefer `bundle exec` and fall back to `ruby -S bundle exec` when the local `bundle` binstub cannot locate Ruby.

## When to edit the shared config

- **Edit `.rubocop.yml` / `lib/rake/lint_tasks.rake`** only when the change applies to **all** packages (e.g. raising line length, enabling a new cop).
- **Add a package-level override** only when a package genuinely cannot follow the root config — document the reason in the package's `AGENTS.md`.

## Checklist

- [ ] No per-package `.rubocop.yml` or `.standard.yml` added
- [ ] `rake lint` passes from the root
- [ ] Config change applies uniformly to all packages
- [ ] No CHANGELOG entry added for lint/format config changes

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference

| Concern | Path |
|---------|------|
| RuboCop config | `.rubocop.yml` |
| Lint tasks | `lib/rake/lint_tasks.rake` |
| CLI entry | `rake lint`, `rake format` |
| Git hooks | `.githooks/` |
| Commit linter | `lib/commit_lint.rb`, `bin/commit-lint` |
