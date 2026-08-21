# AGENTS.md

This file is the **primary entry point** for AI agents working in the Ruby subrepo. Read this file first. It provides baseline rules for every task and links to the specialized harnesses in [`context/`](context/) for task-specific instructions.

**Reference standard:** all packages follow a single, current generation — there is no legacy/migration split. `packages/cnpj-*` and `packages/cpf-*` are symmetric modern implementations (options classes with property setters, the two-category error hierarchy, RSpec Better Specs). Use `packages/cnpj-gen` and `packages/cnpj-utilities` as canonical references for new or updated packages.

## Instruction precedence

When instructions conflict, **the more specific scope wins**:

1. **`packages/<pkg>/context/`** — package-level harness (if present)
2. **`packages/<pkg>/AGENTS.md`** — package-level agent rules (if present)
3. **Repository root** — [`context/`](context/) harnesses, then this file

Apply every layer relevant to your task. Where a package-level `AGENTS.md` or `context/` entry contradicts or overrides root-level guidance, follow the package-level instruction.

---

## Root-level guidelines

### Runtime and package manager

The project uses **Ruby** (`>= 3.1`, CI tests 3.1 through 4.0) and **Bundler**. Each package has its own `Gemfile` / `*.gemspec` — there is no hoisted monorepo install. Install root tooling, then work per package:

```bash
bundle install                              # root: Rake, RuboCop, RSpec
cd packages/cnpj-gen && bundle install      # one package + its gemspec deps
```

Do not assume a root-level install covers package dependencies. Prefer Bundler over any other Ruby package manager.

### Dependencies

See [`context/dependencies.md`](context/dependencies.md) for the full policy (approval, RubyGems versioning, internal dep direction, `config/gems.yml` DAG).

### Project structure

The repository is a monorepo with 12 independent gems under `packages/*`. Source is shipped as installed gems; source lives under `src/` (`require_paths = ["src"]`).

```
packages/
  lacus-utils/     # Shared helpers (RubyGems: lacus-utils, require: lacus-utils)
  cpf-dv/          # CPF check digits
  cpf-fmt/         # CPF formatter
  cpf-gen/         # CPF generator
  cpf-val/         # CPF validator
  cpf-utilities/   # CPF domain aggregator (module/class: CpfUtils)
  cnpj-dv/         # CNPJ check digits
  cnpj-fmt/        # CNPJ formatter
  cnpj-gen/        # CNPJ generator
  cnpj-val/        # CNPJ validator
  cnpj-utilities/  # CNPJ domain aggregator (module/class: CnpjUtils)
  br-utilities/    # Top-level CPF + CNPJ aggregator (class: BrUtils)
```

Gem names and package directories match (`cnpj-gen` → gem `cnpj-gen`, `require 'cnpj-gen'`). Module names are CamelCase; `*-dv` becomes `*DV` (`cnpj-dv` → `CnpjDV`). Aggregator folders use `*-utilities` while commit scopes use `*-utils` (see [Commit and standards](#commit-and-standards)).

### Configurations

Shared tooling lives at the Ruby subrepo root:

- `Rakefile` — monorepo tasks (`rake lint`, `rake test`, `rake monorepo:each[test]`, …)
- `Gemfile` — root dev tooling only (Rake, RuboCop, RSpec)
- `.rubocop.yml` — shared RuboCop config (line length 120, `TargetRubyVersion: 3.1`)
- `config/gems.yml` — gem name → dir + internal deps (DAG)
- `.githooks/` — pre-commit, commit-msg, pre-push (enable with `rake hooks:install`)
- `lib/` — commit linter, release-notes extractor, shared Rake tasks
- `bin/commit-lint`, `bin/release-notes` — CLI helpers

Prefer changing these only when necessary and in line with existing patterns. Do not add per-package RuboCop config files.

### Package strategy

Packages are split by domain (`lacus-utils`, `cpf-*`, `cnpj-*`, `br-utilities`). Follow the existing dependency direction:

```
lacus-utils → {cpf,cnpj}-dv → {cpf,cnpj}-{gen,val}
lacus-utils → {cpf,cnpj}-fmt
{cpf,cnpj}-{fmt,gen,val} → {cpf,cnpj}-utilities → br-utilities
```

`{cpf,cnpj}-fmt` do **not** depend on `-dv`. Upstream packages must not require downstream ones.

### Lint and format

Linting and formatting use **RuboCop** (with `rubocop-rspec` and `rubocop-packaging`). Run from the subrepo root:

```bash
rake lint                     # check (CI equivalent)
rake format                   # auto-correct safe offenses (rubocop -a)
rake lint:autocorrect_all     # auto-correct including unsafe (rubocop -A)
```

See [`context/lint-config.md`](context/lint-config.md) for the full setup and the rule against per-package config files.

### Commit and standards

A **pure-Ruby** conventional-commits linter (`lib/commit_lint.rb`, hook in `.githooks/commit-msg`) enforces the message format. Use the **scope** (not always the folder name) when changes are isolated to one package: `<type>(<scope>): <message>` (e.g. `fix(cnpj-val): correct check digit`).

Valid scopes: `br-utils`, `cnpj-fmt`, `cnpj-dv`, `cnpj-gen`, `cnpj-val`, `cnpj-utils`, `cpf-fmt`, `cpf-dv`, `cpf-gen`, `cpf-val`, `cpf-utils`, `utils`. Folder → scope exceptions: `lacus-utils` → `utils`, `*-utilities` → `*-utils`, `br-utilities` → `br-utils`.

Install hooks with `rake hooks:install`. Lint a range with `rake lint:commits`.

### CI

See [`context/ci-release.md`](context/ci-release.md) for the full pipeline (matrix Ruby versions, reusable lint and test workflows, what agents must not run, local validation commands).

---

## Package-specific guidelines

### Ruby version and style

- Require `spec.required_ruby_version = '>= 3.1'` in every package gemspec.
- Add `# frozen_string_literal: true` to every Ruby file.
- Use 2-space indent; keep lines within 120 characters.

### Lint / format (DRY)

See [`context/lint-config.md`](context/lint-config.md) for the shared config, run flow, and the rule against adding per-package lint config files.

### Source layout

- Source must live under `src/`; the gemspec uses `require_paths = ["src"]`.
- The entry file is hyphenated to match the require path (`src/cnpj-gen.rb`).
- Nested files under `src/<gem-name>/` mix hyphenated require paths with snake_case implementation files.
- Specs live under `tests/` (not under `src/`).

### Errors

See [`context/errors.md`](context/errors.md) for the mandatory two-category hierarchy (API misuse vs domain), native superclass mapping, `Error` marker module, `DomainError`, documentation shape, and checklist. Do not invent an alternate hierarchy.

### YARD

See [`context/yard.md`](context/yard.md) for conventions (class/method docs, `@raise`, `@param`, `@return`, `{Class}` links, `+code+` markup, tone).

### Commit scope

If a commit touches only one package directory (`packages/<pkg-name>/`), use that package's **scope** from [Commit and standards](#commit-and-standards) (e.g. `docs(cnpj-utils): update README` for `packages/cnpj-utilities/`).

### Changelog

See [`context/changelogs.md`](context/changelogs.md) for the full workflow (when to add an entry, SemVer bump decision, format, section headings, conciseness rules). Agents **do** edit `packages/<pkg>/CHANGELOG.md` directly — changelogs are managed manually. Do **not** bump `src/<gem>/version.rb` (`VERSION` is a `0.0.0` placeholder replaced at publish time).

### API and docs

Use [`context/public-api.md`](context/public-api.md) as the coordination checklist for any public API change (new class, method signature, option, error, or export). It links to the specialized harnesses for source, YARD, tests, README, and changelog. All README rules are in [`context/readme-docs.md`](context/readme-docs.md).

### CHANGELOG.md

Edit `packages/<pkg>/CHANGELOG.md` following the rules in [`context/changelogs.md`](context/changelogs.md). Do **not** run `rake release` or `gem push` — those publish to RubyGems and are the developer's responsibility.

---

## Agent harnesses

Task-specific instructions live in [`context/`](context/). The harness catalog — IDs, files, and triggers — is [`context/README.md`](context/README.md). Read and follow the matching harness file **in full** before starting the task.

A package may define its own `packages/<pkg>/context/` or `packages/<pkg>/AGENTS.md`; those override conflicting root harness or README rules for that package (see [Instruction precedence](#instruction-precedence) above).

### Skill ↔ harness mapping

Cursor agents may load these workspace skills as a shortcut; each skill is a thin pointer to the canonical harness:

| Cursor skill | Harness file | When triggered |
|--------------|-------------|----------------|
| `readme-rb` | [`context/readme-docs.md`](context/readme-docs.md) | Writing or reviewing `README.md` / `README.pt.md` |
| `unit-tests-rb` | [`context/unit-tests.md`](context/unit-tests.md) | Writing, reviewing, or running tests |
| `changelogs-rb` | [`context/changelogs.md`](context/changelogs.md) | Editing `CHANGELOG.md`; choosing a SemVer bump |
| `package-arch-rb` | [`context/package-arch.md`](context/package-arch.md) | Adding or changing `src/` code |
| `public-api-rb` | [`context/public-api.md`](context/public-api.md) | Any public API change |
| `new-package-rb` | [`context/new-package.md`](context/new-package.md) | Scaffolding a new package |
| `lint-config-rb` | [`context/lint-config.md`](context/lint-config.md) | Editing lint/format config |
| `yard-rb` | [`context/yard.md`](context/yard.md) | Adding or reviewing YARD comments |
| `packaging-rb` | [`context/packaging.md`](context/packaging.md) | Editing a gemspec, building, or publishing |
| `errors-rb` | [`context/errors.md`](context/errors.md) | Adding, changing, or documenting error classes |
| `domain-parity-rb` | [`context/domain-parity.md`](context/domain-parity.md) | CPF ↔ CNPJ parity check |
| `aggregator-package-rb` | [`context/aggregator-package.md`](context/aggregator-package.md) | Working on `cpf-utilities`, `cnpj-utilities`, or `br-utilities` |
| `ci-release-rb` | [`context/ci-release.md`](context/ci-release.md) | Editing CI workflows; local validation |
| `dependencies-rb` | [`context/dependencies.md`](context/dependencies.md) | Adding or changing dependencies |

---

## Key paths

| Purpose | Path |
|---------|------|
| Agent harnesses (catalog) | `context/` |
| Local Ruby pin | `.ruby-version` (`3.2.0`; gemspecs/CI require `>= 3.1`) |
| Shared RuboCop config | `.rubocop.yml` |
| Monorepo DAG | `config/gems.yml` |
| Root Rake entry | `Rakefile` (`rake lint`, `rake test`, `rake monorepo:each[test]`) |
| Root tooling specs | `tests/` (`commit_lint`, `release_notes`) |
| Shared Rake tasks | `lib/rake/` (`lint_tasks.rake`, `rspec_tasks.rake`, `gem_tasks.rake`, `hooks_tasks.rake`) |
| Conventional-commit linter | `lib/commit_lint.rb` / `bin/commit-lint` |
| Release-notes extractor | `lib/release_notes.rb` / `bin/release-notes` |
| Git hooks | `.githooks/` (`rake hooks:install`) |
| CI / release workflows | `.github/workflows/` |
| Root Bundler config | `Gemfile` |
| Package gemspec | `packages/*/<pkg>.gemspec` |
| Package changelogs | `packages/*/CHANGELOG.md` |
