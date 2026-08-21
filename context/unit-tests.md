---
id: unit-tests
title: Package unit tests
scope: packages/*/tests/
triggers:
  - writing or updating unit tests
  - adding test coverage for new behavior
  - fixing failing tests
  - reviewing test changes
  - running package tests
---

# unit-tests

Write and maintain specs under `packages/<pkg>/tests/` using the established br-utils-ruby conventions. All paths are relative to the repo root.

## Repository constraints

### Runner and style

Tests use **RSpec** with Better Specs nesting (`describe` / `context` / `it`). Do not add other test frameworks (Minitest, test-unit, etc.).

Shared configuration lives in `tests/spec_helper.rb` (expect syntax, no monkey patching, random order). Each package's `tests/spec_helper.rb` loads the shared helper and then `require`s the gem:

```ruby
# frozen_string_literal: true

require_relative '../../../tests/spec_helper'
require 'cnpj-gen'
```

Root `.rspec` sets `--default-path tests`, `--pattern 'tests/**/*.spec.rb'`, and documentation format.

### Location and naming

- Specs live in `tests/` at the package root (never under `src/`).
- Files use the `.spec.rb` suffix and **snake_case** names.
- Name the file after the unit under test (e.g. `src/cnpj-gen/cnpj_generator.rb` → `tests/cnpj_generator.spec.rb`).
- Specs are organized by behavior, not as a 1:1 mirror of `src/`.

### Requires

- Require the installed gem (`require 'cnpj-gen'`). Packages resolve via their own `Gemfile` / gemspec — do not load `../src` with `$LOAD_PATH` hacks.
- Aggregator specs require leaf gems as needed (`require 'cnpj-fmt'`).

### Lint

Specs are linted by the root RuboCop run (`rake lint`). `Metrics/BlockLength` is excluded for `tests/**/*`. Follow existing patterns in sibling spec files.

### Changelog

Test-only changes are **dev-only** — do not add a changelog entry for spec edits, coverage tooling, or test refactors with no user-facing change.

### Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

---

## Before writing tests

1. Check for `packages/<pkg>/AGENTS.md` and `packages/<pkg>/context/`; apply overrides when present.
2. Read the source file(s) under test and list public behaviors, options, and error paths.
3. Skim existing specs in `packages/<pkg>/tests/` — match structure, naming, and assertion style.
4. Identify the **package archetype** (below); only create or extend the spec files that archetype uses.

---

## Package archetypes

| Archetype | Examples | Typical spec files |
|-----------|----------|-------------------|
| **Foundation** | `lacus-utils` | One `*.spec.rb` per `src/` module |
| **Single-purpose** | `cnpj-fmt`, `cnpj-val`, `cnpj-gen`, `cnpj-dv`, `cpf-*` | Main class spec, options spec, helper spec, `errors.spec.rb` |
| **Aggregator** | `cnpj-utilities`, `cpf-utilities`, `br-utilities` | Aggregator class spec (helpers, `DEFAULT` mutability, custom-instance independence, re-exports) |

## Spec file roles

| File pattern | Tests |
|--------------|-------|
| `<module>.spec.rb` | Primary class from `src/<gem>/<module>.rb` — constructor, methods, edge cases, `on_fail` |
| `<pkg_snake>.spec.rb` | Module-function helper (e.g. `cnpj_gen`) — delegates to the class; input/output contract |
| `<resource>_options.spec.rb` | Options class — defaults, validation, setters, invalid inputs |
| `errors.spec.rb` | Error classes — inheritance, message, structured attributes |

---

## Structure and style (Better Specs)

Use nested `describe` / `context` for grouping and `it` for individual behaviors. Prefer `expect` syntax, `subject` / `let` over instance variables, and `# frozen_string_literal: true` on every spec file.

```ruby
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CnpjGen::CnpjGenerator do
  describe '#generate' do
    it 'returns a 14-character string' do
      cnpj = described_class.new.generate

      expect(cnpj).to be_a(String)
      expect(cnpj.length).to eq(14)
    end

    context 'when format is true' do
      it 'returns a formatted string' do
        cnpj = described_class.new(format: true).generate

        expect(cnpj).to include('.', '/')
      end
    end

    it 'raises when prefix is invalid' do
      expect { described_class.new(prefix: '00000000').generate }
        .to raise_error(CnpjGen::ValidationError)
    end
  end
end
```

### Rules

- **`describe`** — class, method (`#generate`, `.cnpj_gen`), or constant.
- **`context`** — condition (`when format is true`, `with an invalid prefix`).
- **`it`** — one behavior per example; present-tense phrasing (`returns …`, `raises …`, `calls on_fail …`).
- **Arrange–act–assert** — keep each example focused.
- Use `described_class` when it stays readable; name the class explicitly in helpers/spies.

### Error and callback testing

Two patterns, matching the source's raise vs `on_fail` model (see [`context/package-arch.md`](package-arch.md#error-handling-raise-vs-on_fail) and [`context/errors.md`](errors.md)):

1. **Raised errors** — assert the class and (optionally) structured attributes:

```ruby
it 'raises when type is invalid' do
  expect { CnpjGen::CnpjGeneratorOptions.new(type: 123) }
    .to raise_error(CnpjGen::TypeMismatchError) { |error|
      expect(error.expected_type).to eq('string')
    }
end
```

2. **`on_fail` callback** — pass a spy callback in the options and assert it is invoked (used by formatters/validators for length failures that do not raise by default):

```ruby
it 'calls on_fail when length is invalid' do
  calls = []
  CnpjFmt::CnpjFormatter.new(
    on_fail: ->(_value, error) { calls << error; '' }
  ).format('123')

  expect(calls.size).to eq(1)
  expect(calls.first).to be_a(CnpjFmt::InvalidLengthError)
end
```

### Cross-language alignment

The Ruby packages mirror the JS, PHP, and Python reference suites. Prefer extending existing reference-suite cases over inventing new ones; document any dropped or Ruby-specific cases in a comment at the top of the spec file.

---

## Running tests

From the **ruby/** repository root:

| Goal | Command |
|------|---------|
| All packages (build order) | `rake monorepo:each[test]` |
| Root tooling specs (`tests/commit_lint`, `tests/release_notes`) | `rake test` |
| Single package | `cd packages/cnpj-gen && bundle exec rake test` |

From a package directory (`packages/<pkg>/`): `bundle exec rake test` (uses `lib/rake/rspec_tasks.rake`).

CI discovers packages that have both a `*.gemspec` and a `tests/` directory (see [`context/ci-release.md`](ci-release.md)).

---

## Checklist for agents

- [ ] New behavior has at least one focused `it` in the appropriate `*.spec.rb`.
- [ ] Error paths covered: misuse (`raise`), domain (`raise`), length failures (`on_fail`), invalid options.
- [ ] Options spec covers defaults and all validation branches.
- [ ] `errors.spec.rb` verifies inheritance chain, message, and structured attributes.
- [ ] Style matches siblings: nested `describe` / `context` / `it`, `require 'spec_helper'`.
- [ ] `bundle exec rake test` passes from the package directory.
- [ ] No new test frameworks or dependencies without developer approval.
