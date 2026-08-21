---
id: readme-docs
title: Package README authoring
scope: packages/*/README.md, packages/*/README.pt.md
triggers:
  - creating or updating a package README
  - rewriting or reviewing README.md or README.pt.md
  - editing the root Ruby repository README
  - RubyGems or package documentation
  - translating README to Portuguese (README.pt.md)
---

# readme-docs

Author and maintain `README.md` files under `packages/<pkg>/` following the established br-utils-ruby conventions. All paths are relative to the repo root.

## Repository constraints

### Root README

The root `README.md` at `ruby/README.md` documents the `br-utilities` project. Edit it directly.

### Portuguese parity

English `README.md` is the source of truth for structure and content. Any change to a package's `README.md` must be reflected in that package's `README.pt.md` (faithful translation), **except** the English-only elements listed below. Most packages have both; `lacus-utils` (foundation) has English only.

**Omit from `README.pt.md` (English `README.md` only):**

- The **badges row** (RubyGems / CI / license shields). Keep the cover image (or H1) and optional callouts.
- The **`## Ruby Support`** section (and its Portuguese heading `## Suporte a Ruby`). Do not translate or recreate the Ruby version badge table in Portuguese docs.

### Changelog links

Package `CHANGELOG.md` files are edited manually. READMEs link to the changelog in the footer only (`See [CHANGELOG](./CHANGELOG.md) …`). Do not recap changelog content in the README.

### Error documentation

The `## API` errors subsection must follow [`context/errors.md`](errors.md) (five-part entries, summary table, rescue granularity). That harness owns the shape; this file owns where it sits in the README.

### Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Before writing

1. Check for `packages/<pkg>/AGENTS.md` and `packages/<pkg>/context/`; apply overrides when present.
2. Read `packages/<pkg>/<pkg>.gemspec` for the gem name and description.
3. Read `src/` (and the entry-file public-API list) to list public classes, helpers, constants, and errors accurately.
4. Skim specs in `tests/` for realistic examples.
5. Identify the **package archetype** (below) — section depth depends on it.
6. Check the counterpart package in the other domain (e.g. `cnpj-gen` when documenting `cpf-gen`).

## Package archetypes

| Archetype | Examples | Distinct traits |
|-----------|----------|-----------------|
| **Foundation** | `lacus-utils` | H1 title; per-function API docs; no formatter/generator/validator usage sections |
| **Single-purpose** | `cnpj-fmt`, `cnpj-val`, `cnpj-gen`, `cnpj-dv`, `cpf-*` | Cover image; Usage + API; options tables; class + helper function pattern |
| **Aggregator** | `cnpj-utilities`, `cpf-utilities` | Cover image; wraps leaf packages; Usage inlines sub-options; links to leaf READMEs |
| **Top aggregator** | `br-utilities` | Cover image; wraps both domains; links to domain aggregator READMEs |

Special sections (only when relevant): `## Calculation algorithm` for DV packages; an announcement blockquote for major features (e.g. alphanumeric CNPJ).

## Section order (mandatory)

```
[Cover image OR H1 title]
[Badges row]            ← English README.md only; omit from README.pt.md
[Optional blockquote callouts]
[One-paragraph description]
## Ruby Support         ← English README.md only; omit from README.pt.md
## Features
## Installation
## Require
## Quick Start
## Usage              ← omit for foundation packages
## API
[## Calculation algorithm]  ← DV packages only
## Contribution & Support
## License
## Changelog
---
Made with ❤️ by Lacus Solutions
```

Single-purpose packages include `## Require` (`require '<gem>'`) after Installation. Aggregators may fold require into Installation / Quick Start when that matches the sibling.

## Header block

### Cover image (single-purpose & aggregator)

```markdown
![<pkg> for Ruby](https://br-utils.vercel.app/img/cover_<pkg>.jpg)
```

Use the package folder slug (e.g. `cnpj-gen`). Foundation packages use an H1 instead.

### Badges (six, in this order) — English only

> Include only in `README.md`. Never add these shields to `README.pt.md`.

Replace `<gem-name>` with the gemspec `spec.name`:

```markdown
[![Gem Version](https://img.shields.io/gem/v/<gem-name>)](https://rubygems.org/gems/<gem-name>)
[![Gem Downloads](https://img.shields.io/gem/dt/<gem-name>)](https://rubygems.org/gems/<gem-name>)
[![Ruby Version](https://img.shields.io/gem/rv/<gem-name>)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)
```

### Optional callouts (before description)

Feature announcement (when applicable) and the Portuguese doc link:

```markdown
> 🚀 **Full support for the [new alphanumeric CNPJ format](...).**

> 🌎 [Acessar documentação em português](./README.pt.md)
```

### Description (one paragraph)

> A Ruby **{noun}** to **{primary action}** **{subject}** ({expanded name}).

## Ruby Support — English only

> Include only in `README.md`. Omit from `README.pt.md` (do not add `## Suporte a Ruby`).

Use the Ruby version badge table (not plain text). Copy from `packages/cnpj-gen/README.md` and keep versions aligned with `required_ruby_version` / CI (`>= 3.1`, 3.1 through 4.0):

```markdown
## Ruby Support

| ![Ruby 3.1](...) | ![Ruby 3.2](...) | ![Ruby 3.3](...) | ![Ruby 3.4](...) | ![Ruby 4.0](...) |
| --- | --- | --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).
```

## Features

```markdown
- ✅ **{Short label}**: {One sentence benefit or capability}
```

Standard features to include when applicable: **Flexible input**, **Alphanumeric CNPJ** (CNPJ only), **Formatting/Masking**, **Reusable instance**, **Keyword overrides**, **Minimal dependencies** (name internal deps), **Error handling** (API misuse vs domain + `Error` marker).

## Installation

```markdown
## Installation

Install the gem directly:

```bash
gem install <gem-name>
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem '<gem-name>'
```
```

## Require

```markdown
## Require

```ruby
require '<gem-name>'
```
```

## Quick Start

Show `require` then 2–5 lines of the most common usage with output in comments:

```ruby
require 'cnpj-gen'

CnpjGen.cnpj_gen                       # => e.g. "AB123CDE000155"
CnpjGen.cnpj_gen(format: true)         # => e.g. "AB.123.CDE/0001-55"
CnpjGen.cnpj_gen(type: 'numeric')      # => e.g. "65453043000178"
```

Mention that options can also be passed as a `Hash` (`CnpjGen.cnpj_gen({ format: true })`).

## Usage

Structure with `###` subsections. Include an **options table** (Option / Type / Default / Description) whose defaults match the source `DEFAULT_*` constants, then a subsection per public entry point:

- **`{Namespace}.{helper}` (helper function)** — one-shot wrapper; document positional `options` and keyword overrides; state that they are mutually exclusive.
- **`{ClassName}` (class)** — constructor + methods + `options` reader; show reusable-instance and per-call-override examples.
- **`{ClassName}Options` (class)** — merge semantics, property setters (reject `nil`; reset via `DEFAULT_*`), `#set`, `#all`, `DEFAULT_*` constants.

Aggregators document `DEFAULT` + class helpers and the two-tier access (root shortcuts vs nested package modules).

## API

List all public symbols, then an errors subsection that follows [`context/errors.md`](errors.md):

- Five-part entry per raised or constructed leaf (inheritance, category, when, example, rescue/handle).
- Summary table (misuse first, then domain; alphabetical within category).
- Rescue-granularity section with the four levels, using **real** library classes.

## Footer sections (copy verbatim, adjust paths)

```markdown
## Contribution & Support

We welcome contributions! Please see our [Contributing Guidelines](https://github.com/LacusSolutions/br-utils-ruby/blob/main/CONTRIBUTING.md) for details. If you find this project helpful, please consider:

- ⭐ Starring the repository
- 🤝 Contributing to the codebase
- 💡 [Suggesting new features](https://github.com/LacusSolutions/br-utils-ruby/issues)
- 🐛 [Reporting bugs](https://github.com/LacusSolutions/br-utils-ruby/issues)

## License

This project is licensed under the MIT License — see the [LICENSE](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE) file for details.

## Changelog

See [CHANGELOG](./CHANGELOG.md) for a list of changes and version history.

---

Made with ❤️ by [Lacus Solutions](https://github.com/LacusSolutions)
```

## Writing style

| Rule | Detail |
|------|--------|
| Language | English in `README.md`; mirror structure in `README.pt.md` except badges and `## Ruby Support` / `## Suporte a Ruby` (English only) |
| Voice | Direct, technical, third-person; present tense |
| Formatting | Backticks for identifiers, options, types; **bold** for symbol names in prose |
| Code | Ruby fenced blocks; `# =>` comments with realistic domain values |
| Links | Relative repo links (`./README.pt.md`, `./CHANGELOG.md`); rubygems.org for package links |
| Accuracy | Document actual exports and defaults from source — never invent APIs |

## Workflow checklist

```
- [ ] Archetype identified (foundation / single-purpose / aggregator)
- [ ] Gem name matches gemspec spec.name
- [ ] All public exports documented under ## API
- [ ] Ruby Support versions match required_ruby_version / CI
- [ ] Installation shows gem install / Gemfile
- [ ] Require shows require '<gem-name>'
- [ ] Quick Start shows require + realistic output
- [ ] Options table defaults match source DEFAULT_* constants
- [ ] Error docs follow context/errors.md (five-part + table + granularity)
- [ ] Leaf README links present (aggregators)
- [ ] CHANGELOG footer links to ./CHANGELOG.md
- [ ] README.pt.md present (except lacus-utils) and updated when README.md changes
- [ ] README.pt.md omits badges row and ## Suporte a Ruby
- [ ] Footer boilerplate unchanged
```

## Reference packages

| Archetype | Canonical example |
|-----------|-------------------|
| Formatter | `packages/cnpj-fmt/README.md` |
| Validator | `packages/cnpj-val/README.md` |
| Generator | `packages/cnpj-gen/README.md` |
| Check digits | `packages/cnpj-dv/README.md` |
| Domain aggregator | `packages/cnpj-utilities/README.md` |
| Top-level aggregator | `packages/br-utilities/README.md` |
