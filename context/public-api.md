---
id: public-api
title: Public API change coordination
scope: packages/*/src/, packages/*/tests/, packages/*/README.md, packages/*/CHANGELOG.md
triggers:
  - adding, removing, or renaming a public class or method
  - changing a method, constructor, or helper signature
  - adding or changing options or defaults
  - changing a package's exported surface
  - behavior changes visible to package consumers
  - reviewing a PR that modifies the public API
---

# public-api

This is a meta-checklist harness. When a change touches the public API of any `packages/*` package, use this file as the coordination checklist — it ties together the specialized harnesses that each govern one artifact type. All paths are relative to the repo root.

## What counts as a public API change

A change is public-API if it affects anything a downstream RubyGems consumer would observe:

- Adding, removing, or renaming an exported class, module function, constant, or error
- Changing a method or function signature (parameter name, keyword-only-ness, order, default)
- Adding or removing an option from an options class, or changing an option's `DEFAULT_*`
- Changing raised or constructed error types or their class hierarchy
- Changing the require path or moving a symbol between modules that alters how consumers load it
- Changing gemspec `add_dependency`, `spec.name`, or `required_ruby_version`

Changes that are **not** public-API: specs, CI configs, private helpers, `add_development_dependency`, `Gemfile` / `Gemfile.lock`, `.rubocop.yml`.

## Coordinated artifacts checklist

For every public API change, work through the following in order:

| # | Artifact | Harness |
|---|----------|---------|
| 1 | Source (`src/`) changes + `errors.rb` + `types.rb` | [`context/package-arch.md`](package-arch.md), [`context/errors.md`](errors.md) |
| 2 | YARD on all changed/new symbols | [`context/yard.md`](yard.md) |
| 3 | Behavior specs | [`context/unit-tests.md`](unit-tests.md) |
| 4 | README update (options table, usage example, error docs) | [`context/readme-docs.md`](readme-docs.md) |
| 5 | CHANGELOG entry | [`context/changelogs.md`](changelogs.md) |
| 6 | Gemspec `add_dependency` / `required_ruby_version` (if changed) | [`context/packaging.md`](packaging.md), [`context/dependencies.md`](dependencies.md) |
| 7 | Domain parity check (if `cpf-*` / `cnpj-*`) | [`context/domain-parity.md`](domain-parity.md) |
| 8 | Aggregator cascade (if a sub-package changed) | [`context/aggregator-package.md`](aggregator-package.md) |

> There is no separate "distribution test" step — the require contract is validated by `require '<gem>'` in the behavior specs plus RuboCop. When a symbol is added/removed, update the entry-file YARD public-API list and any spec that requires it.

## Decision flow

```
src/ change?
  │
  ├─ yes → always update behavior specs (step 3)
  │
  └─ export surface change? (new/removed/renamed public class, helper, constant, error)
       │
       ├─ yes → update README (step 4) and entry-file YARD (step 1)
       │
       └─ user-facing? (src/, gemspec runtime keys, public README)
            │
            ├─ yes → add CHANGELOG entry (step 5)
            │
            └─ dev-only (specs, CI, lint, dev deps) → skip CHANGELOG
```

## Before starting

1. Identify all packages affected (direct change + any aggregator that wraps the changed package).
2. For each affected package, run through the 8-step checklist above.
3. Do not mark a task complete until every artifact step is verified or explicitly skipped with a reason.

## Aggregator cascade

When changing a sub-package public API, check whether the aggregator wrapping it needs updating:

| Changed sub-package | Check aggregator |
|--------------------|-----------------|
| `cpf-{fmt,gen,val}` | `cpf-utilities` re-exports + `CpfUtils` class |
| `cnpj-{fmt,gen,val}` | `cnpj-utilities` re-exports + `CnpjUtils` class |
| `cpf-utilities` or `cnpj-utilities` | `br-utilities` (`BrUtils.cpf` / `BrUtils.cnpj`) |

If the aggregator does not yet expose a new symbol or delegate a new method/option, update its `src/` and re-export files. See [`context/aggregator-package.md`](aggregator-package.md).

## Checklist

- [ ] All `src/` changes implemented per [`context/package-arch.md`](package-arch.md)
- [ ] Errors follow [`context/errors.md`](errors.md)
- [ ] YARD updated on all changed symbols per [`context/yard.md`](yard.md)
- [ ] Behavior specs added or updated in `tests/`
- [ ] README updated if an option, default, or public behavior changed
- [ ] CHANGELOG entry added unless the change is entirely dev-only
- [ ] Gemspec `add_dependency` / `required_ruby_version` updated if needed
- [ ] Domain parity check done if the change is in `cpf-*` or `cnpj-*`
- [ ] Aggregator packages updated if a new symbol needs re-exporting or delegating

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).
