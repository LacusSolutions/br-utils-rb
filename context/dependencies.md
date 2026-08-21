---
id: dependencies
title: Dependency policy
scope: packages/*/*.gemspec, Gemfile, config/gems.yml
triggers:
  - adding a new RubyGems dependency
  - adding a dev dependency or changing the root Gemfile
  - changing runtime dependency constraints
  - deciding whether a dependency is allowed
  - exploring the internal dependency graph
  - identifying downstream packages affected by a dep change
---

# dependencies

Manage dependencies in the br-utils-ruby monorepo following the rules below. All paths are relative to the repo root.

## Repository constraints

### Hard rules

- **Always ask the developer** before adding any new runtime or dev dependency to any package or the root. Do not assume approval is implied by any task description.
- Follow the strict **dependency direction** — upstream packages must not depend on downstream ones:

```
lacus-utils → {cpf,cnpj}-dv → {cpf,cnpj}-{gen,val}
lacus-utils → {cpf,cnpj}-fmt
{cpf,cnpj}-{fmt,gen,val} → {cpf,cnpj}-utilities → br-utilities
```

`{cpf,cnpj}-fmt` do **not** depend on `-dv`. Reverse edges (e.g. `lacus-utils` requiring `cnpj-fmt`) are forbidden.

- Shared dev tooling lives in the root `Gemfile` — do not add per-package RuboCop or other lint gems. Each package `Gemfile` lists `gemspec` plus a `:test` group (`rake`, `rspec`) only.
- Internal dependencies in the **gemspec** reference **published RubyGems versions**, never `path:`. Path overrides belong only in a package `Gemfile` when developing against unpublished local code.

### When developer approval is NOT needed

Bumping an **already-declared internal dependency** to a new published range that mirrors what a sibling package uses (e.g. raising `cnpj-dv` from `>= 2.0.0, < 2.1.0` to `>= 2.1.0, < 2.2.0` across packages) is safe to replicate without explicit approval. Verify the existing declaration before updating.

## Before changing dependencies

1. Check the target package `*.gemspec` `add_dependency` lines.
2. Check the root `Gemfile` and the package `:test` group to confirm shared tooling is not already available.
3. Identify downstream packages affected by an internal dep bump (see [Inspecting internal dependencies](#inspecting-internal-dependencies)).
4. Confirm the proposed edge respects [dependency direction](#dependency-direction-reference).
5. If the edge is new, update `config/gems.yml` and run `rake monorepo:check_cycles`.
6. If approval is needed, stop and ask — do not speculatively add the dependency.

## Inspecting internal dependencies

`config/gems.yml` is the single source of truth for gem names, directories, and internal edges. The root `Rakefile` topologically sorts it (`rake monorepo:order`, `rake monorepo:check_cycles`, `rake monorepo:each[task]`).

```bash
rake monorepo:check_cycles    # fail if the DAG has a cycle
rake monorepo:order           # list gems leaves-first
```

## Internal dependencies (RubyGems versioning)

Ruby packages depend on each other via published RubyGems version constraints in the gemspec:

```ruby
spec.add_dependency 'cnpj-dv', '>= 2.0.0', '< 2.1.0'
spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
```

The package `Gemfile` is `gemspec` plus a `:test` group. When a dependent gem is not yet on RubyGems (or you need local unreleased changes), add a `path:` override for **every** internal gem in the closure (direct + transitive); otherwise Bundler tries to resolve unpublished gems from RubyGems and fails. Do not put `path:` in the gemspec.

### Version constraint convention

- **BR Utils monorepo packages** (`cpf-*`, `cnpj-*`, `*-utilities`, `br-utilities`): pin to a single minor line — `'>= X.Y.0', '< X.(Y+1).0'` — allowing only patch updates.
- **`lacus-utils`** (standalone foundation package with its own roadmap): allow the whole major line — `'>= X.Y.0', '< (X+1).0.0'` — so bug fixes and new features are adopted while excluding major versions.

When bumping a monorepo internal dependency, look up the latest published tag:

```bash
cd ruby && git tag -l '<gem-name>@*' | grep -vE '(rc|beta|alpha|dev)' | sort -V | tail -n 1
```

Strip the `<gem-name>@` prefix (e.g. `2.0.3`) and write the new pinned range.

## Dependency direction reference

| Package | Allowed upstream deps |
|---------|----------------------|
| `lacus-utils` | (none — foundation) |
| `{cpf,cnpj}-dv` | `lacus-utils` |
| `{cpf,cnpj}-fmt` | `lacus-utils` |
| `{cpf,cnpj}-{gen,val}` | `lacus-utils`, same-domain `-dv` |
| `{cpf,cnpj}-utilities` | all same-domain leaf packages (`-fmt`, `-gen`, `-val`) |
| `br-utilities` | `cpf-utilities`, `cnpj-utilities` (and by extension all leaves) |

## Root and package Gemfiles

Root `Gemfile`: tooling only — `rake`, `rubocop`, `rubocop-packaging`, `rubocop-rspec`, `rspec`. Do not add runtime gems here.

Package `Gemfile`:

```ruby
# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :test do
  gem 'rake', '~> 13.2'
  gem 'rspec', '~> 3.13'
end
```

Do not duplicate RuboCop into package Gemfiles.

## Changelog

Adding or bumping a runtime constraint in the gemspec is user-facing and requires a CHANGELOG entry (see [`context/changelogs.md`](changelogs.md)). Changing the root `Gemfile`, a package `:test` group, or `Gemfile.lock` does not.

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference

| Concern | Path |
|---------|------|
| Internal DAG | `config/gems.yml` |
| Cycle / order tasks | `rake monorepo:check_cycles`, `rake monorepo:order` |
| Root dev tooling | `Gemfile` |
| Package runtime deps | `packages/<pkg>/<pkg>.gemspec` `add_dependency` |
| Canonical package config | `packages/cnpj-gen/cnpj-gen.gemspec` |
