---
id: new-package
title: Scaffold a new package
scope: packages/
triggers:
  - adding a new package to the monorepo
  - scaffolding a new cpf-*, cnpj-*, or br-* package
  - creating a new workspace member
---

# new-package

Step-by-step checklist for adding a new package to the br-utils-ruby monorepo. Adding a package is a rare, high-blast-radius operation. All paths are relative to the repo root.

## Prerequisites

- **Developer approval is required** before adding any new package or dependency. Stop and confirm before starting. See [`context/dependencies.md`](dependencies.md).
- Identify the archetype (DV / Val / Fmt / Gen / Foundation / Aggregator) — this determines the `src/` layout. See [`context/package-arch.md`](package-arch.md).
- Identify the canonical sibling to clone from (table below).

## Clone-from table

| New package type | Clone from |
|-----------------|-----------|
| `{domain}-fmt` | `cnpj-fmt` |
| `{domain}-val` | `cnpj-val` |
| `{domain}-gen` | `cnpj-gen` |
| `{domain}-dv` | `cnpj-dv` |
| `{domain}-utilities` (aggregator) | `cnpj-utilities` |
| `br-*` (multi-domain aggregator) | `br-utilities` |
| Foundation utility | `lacus-utils` |

## Step 1 — Create the directory structure

The require path and gem name equal the folder name (hyphenated). The root namespace is CamelCase (`cnpj-gen` → `CnpjGen`; `*-dv` → `*DV`).

```
packages/<pkg>/
  src/<pkg>.rb
  src/<pkg>/
    version.rb
    <domain>_<role>.rb          # main class (or <domain>_check_digits.rb for DV)
    <domain>_<role>_options.rb  # Val/Fmt/Gen only (omit for cpf-val-style packages)
    <pkg_snake>.rb              # module-function helper (Val/Fmt/Gen only)
    errors.rb
    types.rb                    # when the package exposes input/option types
  tests/
    spec_helper.rb
    <module>.spec.rb
    errors.spec.rb
  <pkg>.gemspec
  Gemfile
  Rakefile
  README.md
  README.pt.md                  # omit for foundation
  CHANGELOG.md
  LICENSE
```

## Step 2 — Gemspec, Gemfile, Rakefile

Copy from the sibling package of the same archetype and update all package-specific fields (`spec.name`, `summary`, `description`, `add_dependency`). Follow [`context/packaging.md`](packaging.md). Ensure:

- `spec.version` reads `<Namespace>::VERSION` from `src/<pkg>/version.rb`.
- `required_ruby_version = '>= 3.1'`.
- `require_paths = ['src']`.
- Runtime `add_dependency` respects [dependency direction](dependencies.md#dependency-direction-reference).
- `Gemfile` is `gemspec` plus a `:test` group (`rake`, `rspec`).
- `Rakefile` loads `lib/rake/gem_tasks.rake` and `lib/rake/rspec_tasks.rake` from the repo root.

## Step 3 — Register in `config/gems.yml`

Add the gem with its `dir` and `dependencies`. Run `rake monorepo:check_cycles`. CI discovers the package automatically once it has `<pkg>.gemspec` and `tests/` (see [`context/ci-release.md`](ci-release.md)).

## Step 4 — Implement `src/`

Follow [`context/package-arch.md`](package-arch.md):

- Choose the archetype layout (DV / Val / Fmt / Gen / Foundation / Aggregator).
- Write `errors.rb` per [`context/errors.md`](errors.md) (define only leaves you raise or construct).
- Write the module-function helper for Val/Fmt/Gen.
- Write `types.rb` when the package exposes input predicates or allowed-value constants.
- Document the public API on `src/<pkg>.rb` with YARD per [`context/yard.md`](yard.md).
- Leave `VERSION = '0.0.0'`.

## Step 5 — Add `tests/`

Follow [`context/unit-tests.md`](unit-tests.md): `spec_helper.rb` loads `../../../tests/spec_helper` and `require`s the gem; add main class spec, options spec, helper spec, and `errors.spec.rb`.

## Step 6 — Install and verify

```bash
cd packages/<pkg> && bundle install
bundle exec rake test
cd ../.. && rake lint
rake monorepo:check_cycles
```

## Step 7 — README and CHANGELOG

- Write `README.md` and `README.pt.md` per [`context/readme-docs.md`](readme-docs.md).
- Create `CHANGELOG.md` with a `## 1.0.0` section (heading `# <gem-name>`) per [`context/changelogs.md`](changelogs.md).

## Step 8 — Commit scope

If the folder name is new, add a matching scope to `lib/commit_lint.rb` `SCOPES` (and this file's sibling docs). Remember the exceptions: `lacus-utils` → `utils`, `*-utilities` → `*-utils`, `br-utilities` → `br-utils`.

## Final checklist

- [ ] Directory structure matches the archetype
- [ ] Gemspec: correct `name`, `VERSION` attr, `required_ruby_version`, `src/` require path
- [ ] `Gemfile` + `Rakefile` copied from sibling
- [ ] `config/gems.yml` updated; `rake monorepo:check_cycles` passes
- [ ] `src/` implemented per `package-arch.md` and `errors.md`
- [ ] `tests/` implemented per `unit-tests.md`
- [ ] Internal `add_dependency` respects dependency direction
- [ ] `bundle exec rake test` passes in the package
- [ ] `rake lint` passes
- [ ] `README.md` and `README.pt.md` written (except foundation Portuguese)
- [ ] `CHANGELOG.md` created with initial `## 1.0.0` section
- [ ] Commit scope added to `lib/commit_lint.rb` if the folder name is new

## Package-level overrides

Before applying this harness, check whether a package-level `AGENTS.md` or `context/` directory was created for this package. If so, follow it over this file for any conflicting instructions (see [`context/README.md`](README.md#instruction-precedence)).
