---
id: yard
title: YARD conventions
scope: packages/*/src/**/*.rb
triggers:
  - adding or updating YARD comments
  - documenting a new class, method, or constant
  - reviewing documentation on a changed API
  - adding @raise, @param, or @return tags
---

# yard

Write and maintain YARD comments for all exported and internal API symbols across br-utils-ruby packages. All paths are relative to the repo root.

## Repository constraints

- **All public symbols get YARD** — modules, exported classes, methods, module functions, constants, and error classes.
- RuboCop `Style/Documentation` is **disabled**; YARD is the documentation standard, not `# @return` noise to satisfy a cop.
- Do **not** narrate implementation steps or restate what the code obviously does. Document intent, behavior, constraints, and what can go wrong.
- Tone: concise and user-facing, as if writing RubyGems package documentation.
- Follow the reference implementations: `packages/cnpj-gen/src/cnpj-gen/cnpj_generator.rb`, `cnpj_generator_options.rb`, `errors.rb`, `cnpj-gen.rb`.

## Before writing YARD

1. Read the symbol's source and any related options and errors files.
2. Identify: what it does, what can go wrong (errors raised or `on_fail` invoked), what options control behavior.
3. Skim YARD in sibling files in the same package — match style and verbosity.

## Markup

- Wrap identifiers, option names, and literal values in `+plus+` (YARD italic/code), not Markdown backticks inside comments.
- Cross-reference other symbols with `{CnpjGeneratorOptions}`, `{#generate}`, `{CnpjGen.cnpj_gen}`.
- Use a one-sentence summary paragraph; add more paragraphs only when constraints or usage notes are needed.

## Module / entry-file comments

Every entry file (`src/<gem>.rb`) starts with a module comment that lists the public API and the two error categories:

```ruby
# Generates valid CNPJ (Cadastro Nacional da Pessoa Jurídica) identifiers.
#
# Errors fall into two categories:
#
# - *API misuse* — … Raised as {CnpjGen::TypeMismatchError} or
#   {CnpjGen::InvalidArgumentCombinationError}.
# - *Domain errors* — … raise {CnpjGen::ValidationError} under
#   {CnpjGen::DomainError}.
#
# Every custom error includes the {CnpjGen::Error} marker module so consumers can
# +rescue CnpjGen::Error+ for a library-wide catch.
#
# Public API:
#
# - {CnpjGen.cnpj_gen}
# - {CnpjGen::CnpjGenerator}, {CnpjGen::CnpjGeneratorOptions}
#
# @example
#   require 'cnpj-gen'
#
#   CnpjGen.cnpj_gen # => e.g. "AB123CDE000155"
module CnpjGen
end
```

## Class comments

```ruby
# Generator for CNPJ identifiers. Builds valid 14-character CNPJ values by
# combining an optional +prefix+ with a randomly generated sequence and
# computed check digits. Options control +prefix+, character +type+, and
# whether the result is formatted (+00.000.000/0000-00+).
class CnpjGenerator
```

## Method and function comments

Describe behavior, not implementation. Document the mutually exclusive `options` vs keywords rule, per-call merge semantics, and every failure mode.

```ruby
# Generates a valid CNPJ value.
#
# +options+ and the keyword arguments are never merged with each other: when
# +options+ is given it alone overrides the instance defaults for this call;
# otherwise any non-+nil+ keyword argument overrides the instance defaults.
# Passing both raises {InvalidArgumentCombinationError}.
#
# @param options [CnpjGeneratorOptions, Hash, nil] per-call option overrides
# @param keywords [Hash] per-call option keyword overrides (mutually exclusive
#   with +options+; see {CnpjGeneratorOptions})
# @return [String] generated CNPJ
# @raise [InvalidArgumentCombinationError] if +options+ and a keyword argument are both given
# @raise [TypeMismatchError] if any option has an invalid type
# @raise [ValidationError] if +prefix+ is invalid or +type+ is not allowed
def generate(options = nil, **keywords)
```

### Tag conventions

- **`@raise`** — list every error that can propagate, each with a one-clause trigger. This is the most important section — never omit it when the symbol can fail. Mention `on_fail` in prose for Fmt/Val length failures that do not raise.
- **`@param` / `@return`** — use when the name and Ruby types are not obvious from the signature. Do not invent a tag for every trivial getter.
- **`@example`** — use on helpers and entry points where a concrete snippet clarifies output.
- **`@see`** — only when it genuinely aids navigation (e.g. a helper pointing to its class).
- **`@return` on `attr_reader`** — document the reader when the object identity matters (e.g. "the same instance used internally").

## Constant comments

Document public constants above the assignment:

```ruby
# The standard length of a CNPJ identifier (14 alphanumeric characters).
CNPJ_LENGTH = 14
```

Document `DEFAULT_*` option constants the same way.

## Error class comments

```ruby
# Marker module mixed into every custom error raised by this library.
#
# Use +rescue CnpjGen::Error+ to catch every library error regardless of native
# ancestry.
module Error; end

# API misuse error raised when an argument's runtime type does not match the
# type required by the API contract.
class TypeMismatchError < TypeError
  include Error

  # @return [Object] the offending input value
  attr_reader :actual_input
```

Base/ancestor classes explain inheritance and the native superclass. Concrete leaves document the specific failure and the structured attributes they expose. README documentation of errors follows the five-part shape in [`context/errors.md`](errors.md) — YARD does not replace that README section.

## What not to document

- Do not add `@param` for every keyword when the options class already documents them — point at `{CnpjGeneratorOptions}` instead.
- Do not add `@return` for trivial writers.
- Do not narrate obvious code.
- Do not use Markdown headings inside YARD comments.

## Checklist

- [ ] Every entry file has a module comment listing the public API and error categories
- [ ] Every exported class, method, and module function has a comment
- [ ] `@raise` lists every propagating error with a concrete class + trigger
- [ ] `on_fail`-based failures (Fmt / Val) are mentioned where relevant
- [ ] Constants and `DEFAULT_*` values have comments
- [ ] Identifiers use `+plus+`; cross-refs use `{Class}` / `{#method}`
- [ ] No narration of obvious code

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference

| Concern | Canonical example |
|---------|-------------------|
| Class + method comments | `packages/cnpj-gen/src/cnpj-gen/cnpj_generator.rb` |
| Options class | `packages/cnpj-gen/src/cnpj-gen/cnpj_generator_options.rb` |
| Error hierarchy comments | `packages/cnpj-gen/src/cnpj-gen/errors.rb` |
| Entry-file module comment | `packages/cnpj-gen/src/cnpj-gen.rb` |
| Helper `@example` | `packages/cnpj-gen/src/cnpj-gen/cnpj_gen.rb` |
