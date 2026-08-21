---
id: package-arch
title: Package implementation architecture
scope: packages/*/src/**/*.rb
triggers:
  - implementing or changing package source code
  - adding a new class, error, or option
  - designing or reviewing src/ layout
  - adding error handling (raising vs on_fail)
  - changing or adding module-function helpers
  - working on the errors or types modules
---

# package-arch

Follow the repeatable implementation architecture when adding or changing source code in any `packages/*` package. All paths are relative to the repo root.

## Single generation

Unlike the sibling PHP subrepo, the Ruby monorepo has **one current generation** — CPF and CNPJ are symmetric modern implementations. There is no legacy pattern to avoid. Use the CNPJ packages as the canonical reference for every archetype.

## Package archetypes

| Archetype | Examples | Role |
|-----------|----------|------|
| **DV** (check digits) | `cpf-dv`, `cnpj-dv` | Main class only; no helper function |
| **Val** (validator) | `cpf-val`, `cnpj-val` | Main class + module-function helper + Options (CNPJ only) |
| **Fmt** (formatter) | `cpf-fmt`, `cnpj-fmt` | Main class + module-function helper + Options |
| **Gen** (generator) | `cpf-gen`, `cnpj-gen` | Main class + module-function helper + Options |
| **Foundation** | `lacus-utils` | Named module functions only; no aggregator |
| **Aggregator** | `cpf-utilities`, `cnpj-utilities`, `br-utilities` | Façade class wrapping leaf packages |

## Require namespaces

Source lives under `src/`. The require path equals the gem name (hyphenated). Module names are CamelCase; `*-dv` → `*DV`.

| Folder / gem | `require` | Root namespace | Entry file |
|--------------|-----------|----------------|------------|
| `cnpj-gen` (and most) | `cnpj-gen` | `CnpjGen` | `src/cnpj-gen.rb` |
| `cnpj-dv` | `cnpj-dv` | `CnpjDV` | `src/cnpj-dv.rb` |
| `lacus-utils` | `lacus-utils` | `LacusUtils` | `src/lacus-utils.rb` |
| `cnpj-utilities` | `cnpj-utilities` | `CnpjUtils` | `src/cnpj-utilities.rb` |
| `br-utilities` | `br-utilities` | `BrUtils` | `src/br-utilities.rb` |

## Canonical `src/` layout

### DV

```
src/<gem>.rb                       # namespace module + public constants
src/<gem>/
  version.rb                       # VERSION = '0.0.0'
  <domain>_check_digits.rb         # Main class + LENGTH constants
  errors.rb                        # Error hierarchy
```

### Val / Fmt / Gen

```
src/<gem>.rb                       # namespace module + public constants
src/<gem>/
  version.rb
  <domain>_<role>.rb               # Main class  (e.g. cnpj_generator.rb → CnpjGenerator)
  <domain>_<role>_options.rb       # Options class + DEFAULT_* + LENGTH constants
  <gem_snake>.rb                   # module-function helper (e.g. cnpj_gen.rb → CnpjGen.cnpj_gen)
  errors.rb
  types.rb                         # allowed-value constants, input predicates
  utils.rb                         # private package helpers (when needed)
```

> A package with no configurable options omits the `<domain>_<role>_options.rb` file (and its `DEFAULT_*` constants). `cpf-val` is the current example — the CPF validator takes no options, unlike `cnpj-val`. See [`context/domain-parity.md`](domain-parity.md#intentional-divergences-not-bugs).

### Foundation (`lacus-utils`)

```
src/lacus-utils.rb
src/lacus-utils/
  version.rb
  describe_type.rb
  generate_random_sequence.rb
```

### Aggregator (`cnpj-utilities`)

```
src/cnpj-utilities.rb              # promotes CnpjUtils module → class; requires re-exports
src/cnpj-utilities/
  version.rb
  errors.rb
  cnpj_utils.rb                    # Façade class + DEFAULT + class helpers
  cnpj_fmt.rb                      # nest + shortcuts
  cnpj_gen.rb
  cnpj_val.rb
```

See [`context/aggregator-package.md`](aggregator-package.md) for re-export and `DEFAULT` rules.

## Public exports (entry file)

Every package exposes its public API from `src/<gem>.rb`. The file requires nested files, opens the root namespace, and documents the public surface in a YARD module comment. Constants that belong on the namespace (e.g. `CNPJ_LENGTH`) are assigned there.

There is no `__all__` equivalent — the public surface is whatever the entry file and nested files define as public constants/methods. Keep the surface small; hide helpers with `private_constant` or `private`.

```ruby
# frozen_string_literal: true

require_relative 'cnpj-gen/version'
require_relative 'cnpj-gen/errors'
require_relative 'cnpj-gen/types'
require_relative 'cnpj-gen/cnpj_generator_options'
require_relative 'cnpj-gen/utils'
require_relative 'cnpj-gen/cnpj_generator'
require_relative 'cnpj-gen/cnpj_gen'

# Generates valid CNPJ identifiers.
#
# Public API: {CnpjGen.cnpj_gen}, {CnpjGen::CnpjGenerator}, …
module CnpjGen
  CNPJ_LENGTH = CnpjGeneratorOptions::CNPJ_LENGTH
end
```

`VERSION` stays `'0.0.0'` in source; the real version is injected at publish time (see [`context/packaging.md`](packaging.md)).

## Main class pattern

- Accept an optional first positional `options` argument (an options instance, a `Hash`, or `nil`) plus keyword overrides.
- **`options` and keywords are mutually exclusive.** Passing both raises `InvalidArgumentCombinationError` — never silently ignore keywords.
- Expose an `options` reader returning the internal options instance; mutating it affects future calls that omit per-call options.
- When `options` is an options **instance**, use it by reference (no copy). When it is a `Hash`, construct a new options object.

```ruby
class CnpjGenerator
  attr_reader :options

  def initialize(options = nil, **keywords)
    @options = resolve_default_options(options, keywords)
  end

  def generate(options = nil, **keywords)
    actual_options = resolve_call_options(options, keywords)
    # …
  end
end
```

## Module-function helper pattern (Val / Fmt / Gen)

Each leaf package ships a one-shot helper named after the package (`cnpj_gen`, `cnpj_fmt`, `cnpj_val`) that constructs the class and calls its single action:

```ruby
module CnpjGen
  module_function

  def cnpj_gen(options = nil, **keywords)
    CnpjGenerator.new(options, **keywords).generate
  end
end
```

Rationale: the helper is a stateless call-once API; the class is a stateful, reusable, configurable API. Both are first-class entry points. Prefer `module_function` or `def self.` to match the sibling of the same archetype.

## Options class pattern (Fmt / Gen / Val)

Options are **regular classes with property setters**.

- Defaults live as class constants `DEFAULT_<OPTION>` (and a `DEFAULTS` hash / `OPTION_KEYS` list).
- The constructor folds positional `Hash`/instance layers left to right, then applies keyword overrides. Unresolved keys fall back to `DEFAULT_*`.
- Each option is an `attr`-style reader plus a validating writer. Writers **never accept `nil`** — pass the matching `DEFAULT_*` constant to reset.
- Type failures raise `TypeMismatchError`; value failures raise a domain leaf (`ValidationError`, `OutOfRangeError`, …).
- Expose `#all` returning a shallow copy of the resolved options, and `#set` that updates provided fields and returns `self`.

```ruby
def type=(value)
  raise TypeMismatchError.new(value, 'string', option_name: 'type') unless value.is_a?(String)
  unless CNPJ_TYPE_VALUES.include?(value)
    raise ValidationError.new('type', value, expected_values: CNPJ_TYPE_OPTIONS_ORDER)
  end
  @options[:type] = value
end
```

## Error handling: raise vs `on_fail`

Error classes follow [`context/errors.md`](errors.md) (two categories, native superclasses, `Error` marker, `DomainError`). Handling at the call site:

| Failure | Handling |
|---------|----------|
| **API misuse** (wrong type, invalid argument combination) | Always `raise` the misuse leaf |
| **Domain / value failures** (invalid prefix, out-of-range option) | `raise` the domain leaf |
| **Input length / normalization failure** (Fmt / Val) | Construct `InvalidLengthError` and pass it to the configured `on_fail` callback as a `DomainError`; the callback return value is the result. The default `on_fail` returns an empty string and must never raise |

## `errors.rb` and `types.rb`

- `errors.rb` defines only the leaves the package raises or constructs — see [`context/errors.md`](errors.md#6-catalog-of-standard-leaves-define-only-what-you-use).
- Concrete leaves store structured attributes (`actual_input`, `actual_type`, `expected_type`, `option_name`, `reason`, `expected_values`, …) for callers to inspect.
- `types.rb` holds allowed-value constants, input predicates (`CnpjInput`), and documentation-only input aliases (`CnpjGeneratorOptionsInput = Object`).

## Dependency direction

```
lacus-utils → {cpf,cnpj}-dv → {cpf,cnpj}-{gen,val}
lacus-utils → {cpf,cnpj}-fmt
{cpf,cnpj}-{fmt,gen,val} → {cpf,cnpj}-utilities → br-utilities
```

Upstream packages must not require downstream ones. `lacus-utils` is a leaf with no internal deps. `{cpf,cnpj}-fmt` do not depend on `-dv`. To inspect the live graph, see [`context/dependencies.md`](dependencies.md#inspecting-internal-dependencies).

## Checklist

- [ ] `src/` layout matches the archetype (DV / Val / Fmt / Gen / Foundation / Aggregator)
- [ ] `# frozen_string_literal: true` on every file
- [ ] Public API documented on the entry file; `VERSION = '0.0.0'` left as placeholder
- [ ] Module-function helper present for Val/Fmt/Gen; class is the primary entry point for DV
- [ ] Options are classes with property setters; defaults as `DEFAULT_*` constants; setters reject `nil`
- [ ] `options` argument and keyword overrides are mutually exclusive (`InvalidArgumentCombinationError`)
- [ ] Errors follow [`context/errors.md`](errors.md); length failures on Fmt/Val use `on_fail`
- [ ] YARD on all exported symbols per [`context/yard.md`](yard.md)
- [ ] Tests per [`context/unit-tests.md`](unit-tests.md)

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference packages

| Archetype | Canonical package | Key files |
|-----------|------------------|-----------|
| DV | `cnpj-dv` | `src/cnpj-dv/cnpj_check_digits.rb`, `src/cnpj-dv/errors.rb` |
| Fmt | `cnpj-fmt` | `src/cnpj-fmt/cnpj_formatter.rb`, `..._options.rb`, `cnpj_fmt.rb` |
| Val | `cnpj-val` | `src/cnpj-val/cnpj_validator.rb`, `..._options.rb`, `types.rb` |
| Gen | `cnpj-gen` | `src/cnpj-gen/cnpj_generator.rb`, `..._options.rb`, `cnpj_gen.rb` |
| Foundation | `lacus-utils` | `src/lacus-utils/describe_type.rb` |
| Aggregator | `cnpj-utilities` | `src/cnpj-utilities/cnpj_utils.rb` |
| Top aggregator | `br-utilities` | `src/br-utilities/br_utils.rb`, `cpf_*.rb`, `cnpj_*.rb` |
