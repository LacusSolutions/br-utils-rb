# br-utilities

## 1.0.0

### 🚀 Stable Version Released!

Unified toolkit to deal with Brazilian documents (CPF and CNPJ): validation, formatting, and generation of valid IDs. Main features:

- **Unified façade**: `BrUtils` aggregates configurable `CpfUtils` and `CnpjUtils` behind `#cpf` / `#cnpj` accessors (with setters; `nil` resets to defaults).
- **Constructor flexibility**: accept a settings `Hash` or keyword args (`cpf:` / `cnpj:` nested mappings, or flat `cpf_formatter:` / `cnpj_validator:`-style kwargs; nested wins when both present).
- **Quick helpers**: `BrUtils.cpf` / `.cnpj` delegate to `BrUtils::DEFAULT.cpf` / `.cnpj` (process-wide; prefer `BrUtils.new` under concurrency).
- **Two-tier re-exports**: main classes at the façade root (`BrUtils::CpfFormatter`, `BrUtils::CnpjValidator`, …); full sibling surface under `BrUtils::CpfFmt` / `CpfUtils` / `CnpjFmt` / ….
- **One install**: depends on `cpf-utilities` and `cnpj-utilities` so both domains ship without requiring each gem separately.
- **Alphanumeric CNPJ**: CNPJ path supports 14-character alphanumeric IDs via `cnpj-utilities` (numeric CPF via `cpf-utilities`).
- **Structured errors**: `BrUtils::TypeMismatchError` / `InvalidArgumentCombinationError` (+ `BrUtils::Error` marker) for façade misuse; README documents every propagated `CpfFmt` / `CpfGen` / `CpfVal` / `CnpjFmt` / `CnpjGen` / `CnpjVal` leaf (including `on_fail` `InvalidLengthError`).

For detailed usage and API reference, see the [README](./README.md).
