---
id: aggregator-package
title: Aggregator package implementation
scope: packages/cpf-utilities/src/, packages/cnpj-utilities/src/, packages/br-utilities/src/
triggers:
  - implementing or changing an aggregator package
  - adding a method or option to CpfUtils, CnpjUtils, or BrUtils
  - reviewing aggregator src/ structure
  - updating cpf-utilities or cnpj-utilities after a sub-package API change
---

# aggregator-package

Implement and maintain the three aggregator gems (`cpf-utilities`, `cnpj-utilities`, `br-utilities`) that bundle leaf packages into a unified API. All paths are relative to the repo root.

Applies to aggregator gems such as `*-utilities` and `br-utilities` that load component packages and expose a unified façade.

## Repository constraints

- Aggregator packages are **thin wrappers** — they delegate to leaf-package instances and add no new business logic.
- Aggregators depend on leaf packages via their published RubyGems versions; leaf packages must not depend on aggregators (see [`context/dependencies.md`](dependencies.md)).
- Aggregator specs `require` the leaf gems (`require 'cnpj-fmt'`).

## `src/` layout

### Domain aggregator (`cnpj-utilities`)

```
src/cnpj-utilities.rb              # promote CnpjUtils module → class; require façade + re-exports
src/cnpj-utilities/
  version.rb                       # placeholder module so the gemspec can read VERSION
  errors.rb                        # aggregator-owned misuse leaves only
  cnpj_utils.rb                    # CnpjUtils façade + DEFAULT + class helpers
  cnpj_fmt.rb                      # nest + shortcuts
  cnpj_gen.rb
  cnpj_val.rb
```

`version.rb` defines a placeholder **module** so the gemspec can read `CnpjUtils::VERSION`. The entry file promotes it to the **class** consumers instantiate (`unless CnpjUtils.is_a?(Class)` → `remove_const` / `Class.new` / restore `VERSION`). Require the re-export files from the entry point **after** class/module promotion and **after** the façade implementation file.

### Top aggregator (`br-utilities`)

```
src/br-utilities.rb                # promote BrUtils module → class
src/br-utilities/
  version.rb
  errors.rb
  br_utils.rb                      # BrUtils façade exposing #cpf / #cnpj + DEFAULT
  cpf_fmt.rb, cpf_gen.rb, cpf_val.rb, cpf_utils.rb
  cnpj_fmt.rb, cnpj_gen.rb, cnpj_val.rb, cnpj_utils.rb
```

## Re-export shape

- One re-export file per component under `src/<agg-pkg>/<component_snake>.rb` (e.g. `src/cnpj-utilities/cnpj_fmt.rb`).
- Nest the full sibling module on the façade: `<Utils>::CnpjFmt = ::CnpjFmt` (same-object assignment only — no wrappers).
- Root shortcuts for the **main class** (e.g. `<Utils>::CnpjFormatter = CnpjFmt::CnpjFormatter`).
- Helpers and types stay under the nested module — do not add new root aliases for them.
- The shipped aggregators also alias the Options class and the sibling `Error` marker as `<Component>Error` (`CnpjFormatterOptions`, `CnpjFormatterError`). Treat those as established public API — do not remove them, and match that trio when adding a **new** component re-export. Do not invent further root aliases (no helper, type, or extra error-leaf shortcuts).
- Root sibling modules (`CnpjFmt`, `CnpjGen`, `CnpjVal`, …) remain supported unchanged after `require 'cnpj-utilities'`.

```ruby
class CnpjUtils
  CnpjFmt = ::CnpjFmt

  CnpjFormatter = CnpjFmt::CnpjFormatter
  CnpjFormatterOptions = CnpjFmt::CnpjFormatterOptions
  CnpjFormatterError = CnpjFmt::Error
end
```

Shipped reference: `packages/cnpj-utilities`.

## Constructor pattern

The façade accepts a settings `Hash` **or** keyword component overrides — never both (`InvalidArgumentCombinationError`). Each component may be omitted (defaults used), or passed as an instance, an `*Options` instance, a `Hash` of options, or a duck-typed double:

```ruby
def initialize(settings = nil, **keywords)
  resolved = Helpers.resolve_settings(settings, keywords)
  @formatter = Helpers.resolve_formatter(resolved[:formatter])
  @generator = Helpers.resolve_generator(resolved[:generator])
  @validator = Helpers.resolve_validator(resolved[:validator])
end
```

Each `resolve_*` helper normalizes the input: pass through an existing component instance, construct from an `*Options` instance or `Hash`, build a default when `nil`, or keep a duck-typed object by reference.

`BrUtils` composes the two domain aggregators and additionally accepts flattened per-component kwargs (`cpf_formatter:`, `cnpj_validator:`, …) plus whole-domain `cpf:` / `cnpj:` overrides.

## Properties and setters

Expose each component as a reader plus a writer that **fully replaces** the component (re-running the same `resolve_*` logic). To tweak a single option the caller should mutate the live instance (e.g. `utils.formatter.options.hidden = true`).

## Default singleton + class helpers

When the façade mirrors a JS default export / Python module-level singleton:

- Expose a mutable constant `<Utils>::DEFAULT = new` (UPPERCASE names a constant binding, not an immutable value — do not freeze the instance).
- Add class-method aliases for each façade operation that forward to `DEFAULT` (e.g. `CnpjUtils.format` / `.generate` / `.is_valid`). Prefer these in end-user docs as the quick path.
- Mutating `DEFAULT` affects subsequent class-helper calls process-wide (shared across threads). `CnpjUtils.new` (custom) instances stay independent.
- Specs: helper existence, parity with `DEFAULT`, mutability coupling with restore, custom-instance independence.

`br-utilities` exposes `BrUtils::DEFAULT` plus class helpers `BrUtils.cpf` / `BrUtils.cnpj`.

## Delegating methods

Each façade method forwards directly to the corresponding component, threading through per-call options and keyword overrides with the same mutually exclusive rule. Do **not** add business logic. Keep `#is_valid` (not `#valid?`) for JS/Python parity; disable `Naming/PredicatePrefix` on those methods with a comment.

## Errors on the aggregator

Aggregators define only the misuse leaves they raise themselves (typically `TypeMismatchError` and `InvalidArgumentCombinationError` plus the `Error` marker). Domain errors propagate unchanged from the bundled packages — do not wrap or re-raise them as aggregator types. Follow [`context/errors.md`](errors.md).

## YARD on the façade

The constructor and delegating methods must `@raise` every error that the composed components can raise (see [`context/yard.md`](yard.md)). Aggregate the union of the leaf packages' failure modes.

## Aggregator cascade after a leaf API change

When a leaf package gains a new option, method, or error:

1. Add or thread the new option through the façade constructor / method kwargs.
2. Extend the `@raise` tags for any new errors.
3. Add a delegation method if the leaf gains a new method.
4. Re-export any new public shortcut from the component file (and, for `br-utilities`, from the matching `cpf_*.rb` / `cnpj_*.rb`).
5. Update the aggregator's `README.md` options table.
6. Add a CHANGELOG entry per [`context/changelogs.md`](changelogs.md), including an `Updated dependencies` group.

## Checklist

- [ ] Entry file promotes the placeholder module to a class, then requires the façade and re-exports
- [ ] One re-export file per component: nest + main-class / Options / Error shortcuts
- [ ] Façade constructor accepts instance / `*Options` / `Hash` / `nil` per component; settings Hash XOR keywords
- [ ] All delegation methods call component methods directly (no added logic)
- [ ] Property setters fully re-resolve their component
- [ ] `DEFAULT` + class helpers; specs cover mutability and custom-instance independence
- [ ] YARD lists every `@raise` from all composed components
- [ ] New leaf symbols re-exported through the aggregator (and `BrUtils` nests)
- [ ] CHANGELOG entry added if public API changed
- [ ] README options table reflects component option changes
- [ ] Specs validate delegation behavior

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference

| Concern | Canonical file |
|---------|---------------|
| Domain aggregator class | `packages/cnpj-utilities/src/cnpj-utilities/cnpj_utils.rb` |
| Re-export shape | `packages/cnpj-utilities/src/cnpj-utilities/cnpj_fmt.rb` |
| Entry-file promotion | `packages/cnpj-utilities/src/cnpj-utilities.rb` |
| Top aggregator façade | `packages/br-utilities/src/br-utilities/br_utils.rb` |
