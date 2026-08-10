![br-utilities for Ruby](https://br-utils.vercel.app/img/cover_br-utils.jpg)

[![Gem Version](https://img.shields.io/gem/v/br-utilities)](https://rubygems.org/gems/br-utilities)
[![Gem Downloads](https://img.shields.io/gem/dt/br-utilities)](https://rubygems.org/gems/br-utilities)
[![Ruby Version](https://img.shields.io/gem/rv/br-utilities)](https://www.ruby-lang.org/)
[![Test Status](https://img.shields.io/github/actions/workflow/status/LacusSolutions/br-utils-ruby/ci.yml?label=ci/cd)](https://github.com/LacusSolutions/br-utils-ruby/actions)
[![Last Update Date](https://img.shields.io/github/last-commit/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby)
[![Project License](https://img.shields.io/github/license/LacusSolutions/br-utils-ruby)](https://github.com/LacusSolutions/br-utils-ruby/blob/main/LICENSE)

> 🚀 **Full support for the [new alphanumeric CNPJ format](https://github.com/user-attachments/files/23937961/calculodvcnpjalfanaumerico.pdf).**

> 🌎 [Acessar documentação em português](./README.pt.md)

A Ruby toolkit to handle the main operations with Brazilian-related data: CPF (Individual's Taxpayer ID) and CNPJ (Business Tax ID). It wraps [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) and [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) in a single façade class (`BrUtils`).

## Ruby Support

| ![Ruby 3.1](https://img.shields.io/badge/Ruby-3.1-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.2](https://img.shields.io/badge/Ruby-3.2-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.3](https://img.shields.io/badge/Ruby-3.3-CC342D?logo=ruby&logoColor=white) | ![Ruby 3.4](https://img.shields.io/badge/Ruby-3.4-CC342D?logo=ruby&logoColor=white) | ![Ruby 4.0](https://img.shields.io/badge/Ruby-4.0-CC342D?logo=ruby&logoColor=white) |
| --- | --- | --- | --- | --- |
| Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ | Passing ✔ |

Requires Ruby **≥ 3.1** (see `required_ruby_version` in the gemspec).

## Features

- ✅ **Unified top-level API**: Class helpers `BrUtils.cpf` / `.cnpj` alias `BrUtils::DEFAULT`; each domain offers `format`, `generate`, and `is_valid`
- ✅ **Bundled domains**: [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) and [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) installed together
- ✅ **Alphanumeric CNPJ**: Full support for the new alphanumeric CNPJ format (introduced in 2026)
- ✅ **Reusable instance**: `BrUtils` class with optional default CPF and CNPJ settings (nested mappings, flat component kwargs, or pre-built utils instances)
- ✅ **Two-tier access**: Prefer main-class shortcuts at the façade root (`BrUtils::CpfFormatter`, `BrUtils::CnpjValidator`, …); Options, helpers, and errors live under nested package modules (`BrUtils::CpfFmt`, `BrUtils::CnpjUtils`, …). Root siblings (`CpfUtils`, `CnpjUtils`, `CpfFmt`, …) still work
- ✅ **Per-call overrides**: Configure defaults on the façade / domain utils; override options on a single `format` / `generate` / `is_valid` call
- ✅ **Error handling**: Domain errors propagate unchanged from the bundled packages; this gem defines `BrUtils::TypeMismatchError` and `BrUtils::InvalidArgumentCombinationError` for API misuse

## Installation

Install the gem directly:

```bash
gem install br-utilities
```

Or add it to your `Gemfile` and run `bundle install`:

```ruby
gem 'br-utilities'
```

This installs **`br-utilities`** together with [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) and [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) (which in turn pull in the CPF and CNPJ component packages). You do **not** need separate `gem install` / `gem` lines for the domain packages when using **`br-utilities`**.

## Require

```ruby
require 'br-utilities'
```

## Quick Start

Prefer the aggregator class helpers (`BrUtils.cpf` / `BrUtils.cnpj`) for one-off calls — they forward to `BrUtils::DEFAULT`:

```ruby
require 'br-utilities'

cpf = '12345678909'
cnpj = '03603568000195'

# CPF (personal ID)
BrUtils.cpf.format(cpf)              # => "123.456.789-09"
BrUtils.cpf.generate(format: true)   # => e.g. "478.442.410-55"
BrUtils.cpf.is_valid('123.456.789-09') # => true

# CNPJ (business ID)
BrUtils.cnpj.format(cnpj)            # => "03.603.568/0001-95"
BrUtils.cnpj.generate(format: true)  # => e.g. "AB.123.CDE/0001-55"
BrUtils.cnpj.is_valid('98765432000198') # => true
```

**With domain aggregators:**

```ruby
require 'br-utilities'

cpf = '12345678909'
cnpj = '03603568000195'

CpfUtils.format(cpf)      # => "123.456.789-09"
CnpjUtils.format(cnpj)    # => "03.603.568/0001-95"
CpfUtils.is_valid(cpf)    # => true
CnpjUtils.is_valid(cnpj)  # => true
```

**With functional helpers** (root sibling modules, loaded by this gem):

```ruby
require 'br-utilities'

cpf = '12345678909'
cnpj = '03603568000195'

CpfFmt.cpf_fmt(cpf)     # => "123.456.789-09"
CpfVal.cpf_val(cpf)     # => true
CnpjFmt.cnpj_fmt(cnpj)  # => "03.603.568/0001-95"
CnpjVal.cnpj_val(cnpj)  # => true
```

## Usage

You can work in these equivalent ways:

1. **`BrUtils.cpf` / `.cnpj`** — class helpers for quick one-off calls (forward to `DEFAULT`).
2. **`BrUtils::DEFAULT`** — mutable shared singleton (same object the class helpers use; process-wide / not thread-isolated).
3. **`BrUtils.new`** — configurable instance with shared defaults across both CPF and CNPJ domains.
4. **Domain aggregators** — `CpfUtils` / `CnpjUtils` (or `BrUtils::CpfUtils` / `BrUtils::CnpjUtils`) directly.
5. **Main classes under `BrUtils`** — `BrUtils::CpfFormatter`, `BrUtils::CnpjGenerator`, and related shortcuts.
6. **Nested package modules** — Options, helpers, errors, and types via `BrUtils::CpfFmt` / `CpfGen` / `CpfVal` / `CnpjFmt` / `CnpjGen` / `CnpjVal` / `CpfUtils` / `CnpjUtils`.
7. **Root sibling modules** (still supported) — `CpfFmt`, `CnpjUtils`, and the rest unchanged.

All approaches expose the same options and behavior within each domain. For exhaustive option tables and component-specific details, see the README of each [bundled package](#bundled-packages).

### Class helpers (`BrUtils.cpf` / `.cnpj`)

These class methods return the same domain utils instances as `BrUtils::DEFAULT`. Prefer them for one-off calls:

```ruby
BrUtils.cpf.format('12345678909')
BrUtils.cpf.generate(format: true)
BrUtils.cpf.is_valid('12345678909')

BrUtils.cnpj.format('03603568000195')
BrUtils.cnpj.generate(type: 'numeric')
BrUtils.cnpj.is_valid('98765432000198')
```

### `BrUtils::DEFAULT` (default instance)

`BrUtils::DEFAULT` is the pre-built, **mutable** singleton behind the class helpers (parity with the JS default export / Python `br_utils`). Its configuration is **process-wide and shared across threads**: mutating it (e.g. `DEFAULT.cpf = …`) affects subsequent `BrUtils.cpf` / `.cnpj` calls for every caller in the process. Prefer `BrUtils.new` or per-call options for concurrent or isolated work; custom instances stay independent of `DEFAULT`:

```ruby
BrUtils::DEFAULT.cpf = CpfUtils.new(formatter: { dash_key: '|' })
BrUtils.cpf.format('12345678909')   # => "123.456.789|09"

custom = BrUtils.new
custom.cpf.format('12345678909')    # => "123.456.789-09" (unaffected)
```

### `BrUtils` (class)

For custom default CPF or CNPJ utils, create your own instance:

```ruby
require 'br-utilities'

utils = BrUtils.new(
  cpf: {
    formatter: { hidden: true, hidden_key: '#' },
    generator: { format: true }
  },
  cnpj: {
    formatter: { hidden: true },
    generator: { type: 'numeric', format: true },
    validator: { type: 'numeric' }
  }
)

utils.cpf.format('12345678909')        # => "123.###.###-##"
utils.cpf.generate                     # => e.g. "005.265.352-88"
utils.cnpj.format('03603568000195')    # => "03.603.***/****-**"
utils.cnpj.generate                    # => e.g. "73.008.535/0005-06"

# Access or replace internal domain instances
utils.cpf    # => CpfUtils
utils.cnpj   # => CnpjUtils
```

- **`BrUtils.new(settings = nil, **keywords)`**: Optional settings. Pass either a settings `Hash` with `:cpf` and/or `:cnpj` keys, **or** the same keys (plus flat component kwargs) as keyword arguments — not both (passing both raises `BrUtils::InvalidArgumentCombinationError`).
  - **`:cpf` / `:cnpj`**: A pre-built `CpfUtils` / `CnpjUtils` instance **or** a configuration `Hash` spread into the corresponding utils constructor. Within that `Hash`, each resource key (`:formatter`, `:generator`, and `:validator` for CNPJ) accepts either an options object or a mapping of option values.
  - **`:cpf_formatter`**, **`:cpf_generator`**, **`:cnpj_formatter`**, **`:cnpj_generator`**, **`:cnpj_validator`**: Flat convenience arguments when only individual components need customization. They are ignored when the corresponding `:cpf` or `:cnpj` argument is provided.
- **`#cpf`**, **`#cnpj`**: Accessors (getters and setters) for the domain utils instances. Setters accept a utils instance, a configuration `Hash`, or `nil` to reset to defaults (replaces the entire instance; does not merge).

Flat constructor options (alternative to nested `:cpf` / `:cnpj` mappings):

```ruby
require 'br-utilities'

utils = BrUtils.new(
  cpf_formatter: CpfFmt::CpfFormatterOptions.new(hidden: true, hidden_key: '#'),
  cpf_generator: CpfGen::CpfGeneratorOptions.new(format: true),
  cnpj_formatter: CnpjFmt::CnpjFormatterOptions.new(hidden: true, hidden_key: '#'),
  cnpj_generator: CnpjGen::CnpjGeneratorOptions.new(format: true, type: 'numeric'),
  cnpj_validator: CnpjVal::CnpjValidatorOptions.new(type: 'numeric')
)
```

Passing a settings `Hash` positional argument together with any keyword raises:

```ruby
BrUtils.new({ cpf: {} }, cnpj: CnpjUtils.new)
# raises BrUtils::InvalidArgumentCombinationError
```

### Instance defaults and per-call overrides

```ruby
require 'br-utilities'

utils = BrUtils.new(
  cpf: {
    formatter: { hidden: true, hidden_key: '#' },
    generator: { format: true }
  },
  cnpj: {
    formatter: { hidden: true, hidden_key: '#' },
    generator: { format: true },
    validator: { type: 'numeric' }
  }
)

cpf = '12345678909'
cnpj = '03603568000195'

utils.cpf.format(cpf)                  # => "123.###.###-##"
utils.cpf.format(cpf, hidden: false)   # this call only: unmasked
utils.cpf.generate(format: false)      # this call only: compact output

utils.cnpj.format(cnpj)                  # => "03.603.###/####-##"
utils.cnpj.format(cnpj, hidden: false)   # this call only: unmasked
utils.cnpj.is_valid('1QB5UKALPYFP59')    # => false (instance validator is numeric-only)
utils.cnpj.is_valid(                     # => true for this call
  '1QB5UKALPYFP59',
  type: 'alphanumeric'
)
```

Passing a `CnpjFmt::CnpjFormatterOptions`, `CnpjGen::CnpjGeneratorOptions`, or `CnpjVal::CnpjValidatorOptions` instance into the `BrUtils` constructor stores that object by reference — mutating it later affects subsequent calls with no per-call override.

To change a single nested option without replacing the whole domain utils, mutate via the domain accessors (e.g. `utils.cpf.formatter.options.hidden = true`).

### CPF operations

CPF methods are accessed via `BrUtils.cpf`, `utils.cpf`, `CpfUtils`, or the `CpfFmt` / `CpfGen` / `CpfVal` helpers. CPF uses the API from [`cpf-utilities`](../cpf-utilities/README.md).

#### Formatting (`#format` / `CpfFmt.cpf_fmt`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | When `true`, mask digits in `hidden_start`–`hidden_end` with `hidden_key` |
| `hidden_key` | `String` | `'*'` | Character(s) used to replace masked digits |
| `hidden_start` | `Integer` | `3` | Start index (0–10, inclusive) of the range to hide |
| `hidden_end` | `Integer` | `10` | End index (0–10, inclusive) of the range to hide |
| `dot_key` | `String` | `'.'` | Dot delimiter (e.g. in `123.456.789`) |
| `dash_key` | `String` | `'-'` | Dash delimiter (e.g. before check digits `…-09`) |
| `escape` | `Boolean` | `false` | When `true`, escape HTML special characters in the result |
| `encode` | `Boolean` | `false` | When `true`, URL-encode the result (similar to JavaScript `encodeURIComponent`) |
| `on_fail` | `Proc` / callable | returns `''` | Callback when sanitized input length ≠ 11; return value is used as result |

Default **`on_fail`** returns an empty string. Invalid length does **not** raise from `#format`.

```ruby
require 'br-utilities'

cpf = '12345678909'

BrUtils.cpf.format(cpf)                              # => "123.456.789-09"
BrUtils.cpf.format(cpf, hidden: true, hidden_key: '#') # => "123.###.###-##"
BrUtils.cpf.format(cpf, dot_key: '', dash_key: '_')  # => "123456789_09"

CpfFmt.cpf_fmt(cpf, hidden: true)                    # => "123.***.***-**"
```

#### Generation (`#generate` / `CpfGen.cpf_gen`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | When `true`, return the generated CPF in standard format (`000.000.000-00`) |
| `prefix` | `String` | `''` | Partial start string (0–9 digits). Non-digits are stripped; missing characters are generated and check digits computed. Prefixes longer than 9 digits are truncated silently. |

Prefix rules: the base (first 9 digits) cannot be all zeros; 9 repeated digits (e.g. `999999999`) are not allowed.

```ruby
require 'br-utilities'

BrUtils.cpf.generate                       # => e.g. "11508890048"
BrUtils.cpf.generate(format: true)         # => e.g. "661.134.831-00"
BrUtils.cpf.generate(prefix: '123456789')  # => "12345678909"
CpfGen.cpf_gen(prefix: '123456789', format: true) # => "123.456.789-09"
```

#### Validation (`#is_valid` / `CpfVal.cpf_val`)

Accepts formatted or unformatted CPF strings (or an `Array` of strings). Returns **`true`** or **`false`** without raising for invalid CPF. No validator options exist.

```ruby
require 'br-utilities'

BrUtils.cpf.is_valid('12345678909')      # => true
BrUtils.cpf.is_valid('123.456.789-09')   # => true
BrUtils.cpf.is_valid('12345678900')      # => false
CpfVal.cpf_val('12345678909')            # => true
```

### CNPJ operations

CNPJ methods are accessed via `BrUtils.cnpj`, `utils.cnpj`, `CnpjUtils`, or the `CnpjFmt` / `CnpjGen` / `CnpjVal` helpers. CNPJ uses the API from [`cnpj-utilities`](../cnpj-utilities/README.md).

#### Formatting (`#format` / `CnpjFmt.cnpj_fmt`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `hidden` | `Boolean` | `false` | When `true`, mask characters in `hidden_start`–`hidden_end` with `hidden_key` |
| `hidden_key` | `String` | `'*'` | Character(s) used to replace masked characters |
| `hidden_start` | `Integer` | `5` | Start index (0–13, inclusive) of the range to hide |
| `hidden_end` | `Integer` | `13` | End index (0–13, inclusive) of the range to hide |
| `dot_key` | `String` | `'.'` | Dot delimiter (e.g. in `12.345.678`) |
| `slash_key` | `String` | `'/'` | Slash delimiter (e.g. before branch `…/0001-90`) |
| `dash_key` | `String` | `'-'` | Dash delimiter (e.g. before check digits `…-90`) |
| `escape` | `Boolean` | `false` | When `true`, escape HTML special characters in the result |
| `encode` | `Boolean` | `false` | When `true`, URL-encode the result (similar to JavaScript `encodeURIComponent`) |
| `on_fail` | `Proc` / callable | returns `''` | Callback when sanitized input length ≠ 14; return value is used as result |

Default **`on_fail`** returns an empty string. Wrong input types raise **`CnpjFmt::TypeMismatchError`**.

```ruby
require 'br-utilities'

cnpj = '03603568000195'

BrUtils.cnpj.format(cnpj)              # => "03.603.568/0001-95"
BrUtils.cnpj.format('12ABC34500DE99')  # => "12.ABC.345/00DE-99"
BrUtils.cnpj.format(                   # => "03.603.###/####-##"
  cnpj,
  hidden: true,
  hidden_key: '#'
)
BrUtils.cnpj.format(                   # => "03603568|0001_95"
  cnpj,
  dot_key: '',
  slash_key: '|',
  dash_key: '_'
)

CnpjFmt.cnpj_fmt(cnpj)                 # => "03.603.568/0001-95"
```

#### Generation (`#generate` / `CnpjGen.cnpj_gen`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `format` | `Boolean` | `false` | When `true`, return the generated CNPJ in standard format (`00.000.000/0000-00`) |
| `prefix` | `String` | `''` | Partial start string (0–12 alphanumeric chars). Missing characters are generated and check digits computed. |
| `type` | `String` | `'alphanumeric'` | Character set for the randomly generated part: `'numeric'`, `'alphabetic'`, or `'alphanumeric'`. **Check digits are always numeric.** |

Prefix rules: base ID (first 8 chars) and branch ID (chars 9–12) cannot be all zeros; 12 repeated digits (e.g. `111111111111`) are also not allowed.

```ruby
require 'br-utilities'

BrUtils.cnpj.generate               # => e.g. "1GJTR3J3XSSA96"
BrUtils.cnpj.generate(format: true) # => e.g. "V1.J0V.8WE/DVZ7-50"
BrUtils.cnpj.generate(              # => e.g. "12345678855883"
  prefix: '12345678',
  type: 'numeric'
)
CnpjGen.cnpj_gen(type: 'numeric')   # => e.g. "65453043000178"
```

#### Validation (`#is_valid` / `CnpjVal.cnpj_val`)

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `case_sensitive` | `Boolean` | `true` | When `false`, lowercase letters are accepted for alphanumeric CNPJ (input is uppercased before validation). |
| `type` | `String` | `'alphanumeric'` | `'numeric'`: only digits (0–9); `'alphanumeric'`: digits and letters (0–9, A–Z). |

```ruby
require 'br-utilities'

BrUtils.cnpj.is_valid('98765432000198')   # => true
BrUtils.cnpj.is_valid('98765432000199')   # => false
BrUtils.cnpj.is_valid('1QB5UKALPYFP59')   # => true
BrUtils.cnpj.is_valid('1QB5UKALpyfp59')   # => false
BrUtils.cnpj.is_valid(                     # => true
  '1QB5UKALpyfp59',
  case_sensitive: false
)
BrUtils.cnpj.is_valid(                     # => false
  '1QB5UKALPYFP59',
  type: 'numeric'
)

CnpjVal.cnpj_val('98765432000198')                         # => true
CnpjVal.cnpj_val('1QB5UKALpyfp59', case_sensitive: false)  # => true
CnpjVal.cnpj_val('1QB5UKALPYFP59', type: 'numeric')        # => false
```

Invalid CNPJ returns **`false`** without raising. Wrong input types raise **`CnpjVal::TypeMismatchError`**.

### Domain aggregators (standalone)

Use `CpfUtils` or `CnpjUtils` directly when you only need one domain:

```ruby
require 'br-utilities'

cpf_utils = CpfUtils.new(
  formatter: { hidden: true },
  generator: { format: true }
)

cnpj_utils = CnpjUtils.new(
  formatter: { hidden: true },
  generator: { format: true },
  validator: { type: 'numeric' }
)

cpf_utils.format('12345678909')       # => "123.***.***-**"
cnpj_utils.format('03603568000195')   # => "03.603.***/****-**"
```

### Accessing components

Each domain aggregator exposes its internal formatter, generator, and validator:

```ruby
require 'br-utilities'

utils = BrUtils.new

utils.cpf.formatter.format('12345678909', hidden: true)  # => "123.***.***-**"
utils.cpf.generator.generate(format: true)               # => e.g. "545.507.690-68"
utils.cpf.validator.is_valid('12345678909')              # => true

utils.cnpj.formatter.format('12ABC34500DE99')            # => "12.ABC.345/00DE-99"
utils.cnpj.generator.generate(format: true)              # => e.g. "8O.BE5.2KL/UI0Y-06"
utils.cnpj.validator.is_valid('03603568000195')          # => true
```

### Using component classes and nested modules

Preferred paths after `require 'br-utilities'`:

```ruby
require 'br-utilities'

# Main classes at the façade root
formatter = BrUtils::CpfFormatter.new(hidden: true)
generator = BrUtils::CnpjGenerator.new(type: 'numeric')
validator = BrUtils::CnpjValidator.new

formatter.format('12345678909')   # => "123.***.***-**"

# Options, helpers, and errors under nested package modules
options = BrUtils::CpfFmt::CpfFormatterOptions.new(dash_key: '|')
BrUtils::CpfFmt.cpf_fmt('12345678909')   # => "123.456.789-09"

begin
  BrUtils::CnpjFmt.cnpj_fmt(12_345)
rescue BrUtils::CnpjFmt::TypeMismatchError
  # wrong input type
end
```

Root siblings remain supported (same objects as the nests):

```ruby
CpfFmt.cpf_fmt('12345678909', dash_key: '|')   # => "123.456.789|09"
CpfGen.cpf_gen(format: true)                   # => e.g. "478.442.410-55"
CpfVal.cpf_val('12345678909')                  # => true
CnpjFmt.cnpj_fmt('01ABC234000X56', slash_key: '|') # => "01.ABC.234|000X-56"
CnpjGen.cnpj_gen(type: 'numeric')              # => e.g. "65453043000178"
CnpjVal.cnpj_val('9JN7MGLJZXIO50')             # => true
```

See [`cpf-utilities`](../cpf-utilities/README.md) and [`cnpj-utilities`](../cnpj-utilities/README.md) for full option and error details.

### Mixing styles

Use `BrUtils` where a shared configuration helps, and standalone components or helpers elsewhere — they are the same underlying classes:

```ruby
require 'br-utilities'

utils = BrUtils.new(cnpj: { validator: { type: 'numeric' } })

# Via façade
utils.cpf.format('12345678909')   # => "123.456.789-09"

# Via component returned by the façade
utils.cnpj.formatter.format('12ABC34500DE99')   # => "12.ABC.345/00DE-99"

# Via a separate component instance
BrUtils::CnpjFormatter.new.format('03603568000195')   # => "03.603.568/0001-95"

# Via functional helpers
CpfFmt.cpf_fmt('12345678909')           # => "123.456.789-09"
CnpjVal.cnpj_val('98.765.432/0001-98')  # => true
```

## API

### Exports

After `require 'br-utilities'`:

- **`BrUtils`**: Façade class to create an instance with optional default CPF and CNPJ utils settings.
- **`BrUtils.cpf` / `.cnpj`**: Class helpers that forward to `BrUtils::DEFAULT` domain accessors.
- **`BrUtils::DEFAULT`**: Mutable pre-built `BrUtils` instance (same object the class helpers use). Process-wide / shared across threads — prefer `BrUtils.new` or per-call options under concurrency.
- **`BrUtils::VERSION`**: Gem version string.
- **Main-class shortcuts**: `BrUtils::CpfFormatter`, `BrUtils::CpfFormatterOptions`, `BrUtils::CpfGenerator`, `BrUtils::CpfGeneratorOptions`, `BrUtils::CpfValidator`, `BrUtils::CnpjFormatter`, `BrUtils::CnpjFormatterOptions`, `BrUtils::CnpjGenerator`, `BrUtils::CnpjGeneratorOptions`, `BrUtils::CnpjValidator`, `BrUtils::CnpjValidatorOptions` (same objects as the sibling classes). Error-marker shortcuts: `BrUtils::CpfFormatterError`, `BrUtils::CpfGeneratorError`, `BrUtils::CpfValidatorError`, `BrUtils::CnpjFormatterError`, `BrUtils::CnpjGeneratorError`, `BrUtils::CnpjValidatorError`.
- **Nested package modules**: `BrUtils::CpfUtils`, `BrUtils::CnpjUtils`, `BrUtils::CpfFmt`, `BrUtils::CpfGen`, `BrUtils::CpfVal`, `BrUtils::CnpjFmt`, `BrUtils::CnpjGen`, `BrUtils::CnpjVal` — full sibling surface (Options, helpers, errors, types).
- **Root sibling modules** (still supported): `CpfUtils`, `CnpjUtils`, `CpfFmt`, `CpfGen`, `CpfVal`, `CnpjFmt`, `CnpjGen`, `CnpjVal` — same objects as the nests.

### Errors & Exceptions

`BrUtils` defines only API-misuse errors for this gem’s argument rules. Domain errors are raised by the bundled packages and propagate unchanged.

#### Defined by `br-utilities`

Errors defined by this gem are **API misuse** only (wrong type or invalid argument combination). Every custom error includes the `BrUtils::Error` marker module. This gem defines **no** `BrUtils::DomainError` and no domain leaves — domain failures come only from the [bundled packages](#propagated-from-bundled-packages) and keep those packages’ namespaces (`CpfFmt::…`, `CnpjGen::…`, …).

`rescue BrUtils::Error` catches **only** errors this gem raises. It does **not** catch component errors that propagate unchanged.

##### Summary

| Class | Inherits from | Category | Trigger condition |
|-------|---------------|----------|-------------------|
| `BrUtils::InvalidArgumentCombinationError` | `BrUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (+ `include BrUtils::Error`) | API misuse | Non-`nil` settings `Hash` passed together with any non-`nil` keyword argument |
| `BrUtils::TypeMismatchError` | `BrUtils::TypeMismatchError < TypeError < StandardError` (+ `include BrUtils::Error`) | API misuse | Non-`nil` `settings` argument to `BrUtils.new` is not a `Hash` |

##### `BrUtils::Error` (marker module)

- **Inheritance:** module marker mixed into every custom error this gem raises via `include` (not a class).
- **Category:** N/A (rescue target only) — not a failure mode by itself.
- **When it is raised:** Never raised directly; included by every custom error this gem raises.
- **Example:** N/A
- **How to rescue it:**

```ruby
rescue BrUtils::Error
  # TypeMismatchError, InvalidArgumentCombinationError from this gem only
  # (not CpfFmt::*, CnpjGen::*, or other bundled-package errors)
```

##### `BrUtils::TypeMismatchError`

- **Inheritance:** `BrUtils::TypeMismatchError < TypeError < StandardError` (includes `BrUtils::Error`)
- **Category:** API misuse — the caller passed a value of the wrong type.
- **When it is raised:** Raised when `BrUtils.new` receives a non-`nil` `settings` argument that is not a `Hash`.
- **Example:**

```ruby
BrUtils.new('not-a-hash')   # raises BrUtils::TypeMismatchError
BrUtils.new(false)          # raises BrUtils::TypeMismatchError (false is non-nil)
```

- **How to rescue it:**

```ruby
rescue BrUtils::TypeMismatchError
  # this gem's type-contract violation

rescue TypeError
  # native type errors, including this gem's TypeMismatchError
```

##### `BrUtils::InvalidArgumentCombinationError`

- **Inheritance:** `BrUtils::InvalidArgumentCombinationError < ArgumentError < StandardError` (includes `BrUtils::Error`)
- **Category:** API misuse — the caller mixed mutually exclusive argument patterns.
- **When it is raised:** Raised when `BrUtils.new` receives both a non-`nil` settings `Hash` and any non-`nil` keyword argument (`cpf:`, `cnpj:`, `cpf_formatter:`, …) at the same time.
- **Example:**

```ruby
BrUtils.new({ cpf: { formatter: { hidden: true } } }, cnpj: { formatter: { hidden: true } })
# raises BrUtils::InvalidArgumentCombinationError
```

- **How to rescue it:**

```ruby
rescue BrUtils::InvalidArgumentCombinationError
  # this gem's invalid signature combination

rescue ArgumentError
  # native argument errors, including this gem's InvalidArgumentCombinationError
```

##### Rescue granularity

Each level is shown as its own standalone example (do not merge them into one `rescue` ladder — a broad native handler would make narrower clauses unreachable).

```ruby
require 'br-utilities'

# 1) Single native class — catches misuse errors of that kind,
#    including non-library ones already handled elsewhere in the consumer's code.
begin
  BrUtils.new('not-a-hash')
rescue TypeError
  # BrUtils::TypeMismatchError and any other TypeError (library or not)
end

begin
  BrUtils.new({ cpf: {} }, cnpj: CnpjUtils.new)
rescue ArgumentError
  # BrUtils::InvalidArgumentCombinationError and any other ArgumentError (library or not)
end
```

```ruby
require 'br-utilities'

# 2) BrUtils::DomainError — not applicable: this gem defines no DomainError
#    (and no domain leaves). Domain failures come from bundled packages only.
# begin
#   BrUtils.new(cpf: { formatter: { hidden_start: -1 } })
# rescue BrUtils::DomainError  # NameError — constant is not defined
# end
```

```ruby
require 'br-utilities'

# 3) BrUtils::Error — catches everything this gem raises, regardless of native ancestry.
#    Does not catch CpfFmt::*, CnpjGen::*, or other bundled-package errors.
begin
  BrUtils.new('not-a-hash')
rescue BrUtils::Error
  # every custom error that includes BrUtils::Error
end
```

```ruby
require 'br-utilities'

# 4) Specific leaf class — catches only that exact failure mode.
begin
  BrUtils.new('not-a-hash')
rescue BrUtils::TypeMismatchError
  # only BrUtils::TypeMismatchError
end
```

#### Propagated from bundled packages

`BrUtils` does not redefine domain exception types. Construction, setters, and domain method calls raise the same errors as [`cpf-utilities`](../cpf-utilities/README.md) and [`cnpj-utilities`](../cnpj-utilities/README.md):

- **CPF formatting**: `CpfFmt::TypeMismatchError`, `CpfFmt::OutOfRangeError`, `CpfFmt::ValidationError`, `CpfFmt::InvalidLengthError` (passed to `on_fail`, not raised by `#format`), and related classes.
- **CPF generation**: `CpfGen::TypeMismatchError`, `CpfGen::ValidationError`, and related classes.
- **CPF validation**: `CpfVal::TypeMismatchError` and related classes.
- **CNPJ formatting**: `CnpjFmt::TypeMismatchError`, `CnpjFmt::OutOfRangeError`, `CnpjFmt::ValidationError`, `CnpjFmt::InvalidLengthError` (passed to `on_fail`), and related classes.
- **CNPJ generation**: `CnpjGen::TypeMismatchError`, `CnpjGen::ValidationError`, and related classes.
- **CNPJ validation**: `CnpjVal::TypeMismatchError`, `CnpjVal::ValidationError`, and related classes.

Invalid option types are typically **`TypeError`** subclasses (`*::TypeMismatchError`); invalid option values are domain errors under each package’s `DomainError` hierarchy. CPF and CNPJ validation failures return `false`. Formatting length failures are handled by **`on_fail`** (default returns an empty string).

```ruby
require 'br-utilities'

begin
  BrUtils.new.cnpj.format(12_345)
rescue CnpjFmt::TypeMismatchError => e
  puts e.message
end

begin
  BrUtils.new.cnpj.is_valid(12_345_678_000_198)
rescue CnpjVal::TypeMismatchError => e
  puts e.message
end

# Custom on_fail for invalid length
custom_fail = ->(value, _exception) { "Invalid: #{value}" }

BrUtils.cpf.format('short', on_fail: custom_fail)    # => "Invalid: short"
BrUtils.cnpj.format('short', on_fail: custom_fail)   # => "Invalid: short"
BrUtils.cpf.format('short')                          # => "" (default on_fail)
```

For exhaustive exception lists and edge-case behavior, see each [bundled package](#bundled-packages) README.

### Bundled packages

| Package | Main resources | README |
|---------|----------------|--------|
| [`cpf-utilities`](https://rubygems.org/gems/cpf-utilities) | `CpfUtils`, `CpfFormatter`, `CpfGenerator`, `CpfValidator`, `CpfFmt.cpf_fmt`, `CpfGen.cpf_gen`, `CpfVal.cpf_val` | [docs](../cpf-utilities/README.md) |
| [`cnpj-utilities`](https://rubygems.org/gems/cnpj-utilities) | `CnpjUtils`, `CnpjFormatter`, `CnpjGenerator`, `CnpjValidator`, `CnpjFmt.cnpj_fmt`, `CnpjGen.cnpj_gen`, `CnpjVal.cnpj_val` | [docs](../cnpj-utilities/README.md) |

All of the above are pulled in as dependencies of **`br-utilities`**. Interactive demos: [CPF](https://cpf-utils.vercel.app/) and [CNPJ](https://cnpj-utils.vercel.app/).

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
