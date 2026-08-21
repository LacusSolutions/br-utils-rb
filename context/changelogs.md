---
id: changelogs
title: Changelog entries
scope: packages/*/CHANGELOG.md
triggers:
  - creating or editing a CHANGELOG.md entry
  - deciding whether a change needs a changelog entry
  - choosing a SemVer bump level
  - reviewing changelog entries before release
---

# changelogs

Maintain `packages/<pkg>/CHANGELOG.md` files following the rules below. All `git tag` and SemVer lookups must run from inside the Ruby subrepo (`cd ruby/`) — the workspace root is not a Git repo.

> A Cursor workspace hook (`.cursor/rules/ruby/changelog-keeper.mdc` and `changelog-package.mdc`) automates this at the end of turns that touch `ruby/`. This harness is the tool-agnostic version of those rules; keep the two consistent.

## Repository constraints

- `packages/<pkg>/CHANGELOG.md` files are the **only** files agents create or edit in this workflow.
- Do **not** run `rake release`, `gem push`, create GitHub Releases, or push git tags. Only the developer does that.
- Do **not** edit released sections — once tagged, history is immutable.
- Do **not** edit the top-level `# <pkg>` heading.
- Do **not** bump `packages/<pkg>/src/<gem>/version.rb` — `VERSION` is a `0.0.0` placeholder replaced at publish time.

## Naming: heading and tag prefix

The `CHANGELOG.md` heading and the git tag prefix both use the **gem name** from the gemspec `spec.name`. In this monorepo that equals the package folder name for every package (including `lacus-utils` and `br-utilities`).

## Step 1 — Determine the latest released version

```bash
cd ruby && git tag -l '<gem-name>@*' | grep -vE '(rc|beta|alpha|dev)' | sort -V | tail -n 3
```

The last line is the latest released stable version. Strip the `<gem-name>@` prefix to get the bare SemVer (e.g. `1.0.0`). Treat tags containing `rc`, `beta`, `alpha`, or `dev` as pre-releases and ignore them unless they are the only tags.

If no stable tag exists, the package has never been released — the first proposed version is `1.0.0`.

## Step 2 — Inspect the top of `CHANGELOG.md`

The file always starts with `# <gem-name>` followed by version blocks. Look at the **top-most** `## x.y.z` heading:

- If it **equals** the latest released tag → the section is released. **Prepend a new section** with a freshly proposed version above it.
- If it is **greater** than the latest released tag → the section is the current in-progress version. **Append or refine** that section instead of creating a new one. If a new change is more severe than the proposed bump (e.g. a breaking change arrives when the section was a patch), **promote** the heading (`## 1.0.1` → `## 2.0.0`) and reorganize the bullets.

## Step 3 — Skip dev-only changes

The changelog is for **end users** of the package on RubyGems. If every in-scope change is purely internal and invisible to consumers, do **not** add an entry.

### Dev-only (skip):

- Tests, fixtures, spec helpers — anything under `tests/`.
- Coverage tooling, `.rspec_status`, `coverage/`.
- Linter / formatter configs — `.rubocop.yml`, `.standard.yml`, `.editorconfig`.
- CI workflows under `.github/` and helper tasks in `Rakefile` / `lib/`.
- Gemspec edits touching only `add_development_dependency`, metadata test/dev flags, or file lists that exclude `src/` content.
- `Gemfile` / `Gemfile.lock` regeneration when no runtime dependency changed.
- The placeholder `version.rb`.
- Repo hygiene — `.gitignore`, `.gitattributes`.

### User-facing (entry needed):

If even one in-scope change is user-facing, add an entry documenting **only** the user-facing parts:

- Anything under `src/` except the placeholder `version.rb`.
- Gemspec runtime `add_dependency`, `spec.name`, `summary`, or `required_ruby_version`.
- A public `README.md` correction.

## Step 4 — Choose the next version using SemVer

Based on all user-facing changes since the latest released tag (cumulative — not just this turn):

| Level | When to use |
|-------|-------------|
| **major** | Removal or rename of a public class/method/module; signature change that breaks callers; raising the minimum Ruby version; behavior change that breaks existing usage; internal-dependency major bump surfacing through the public API |
| **minor** | New public class, method, keyword argument, error type, or feature behind an existing entry point |
| **patch** | Bug fix in `src/`; runtime dependency bump that does not surface; internal-dependency patch propagated as "Updated dependencies"; user-visible `README.md` fix |

If the in-progress section already proposes a higher bump, **do not downgrade** it.

## Step 5 — Format

Match the style already used in this repo (see `packages/cnpj-gen/CHANGELOG.md`, `packages/cpf-utilities/CHANGELOG.md`, `packages/br-utilities/CHANGELOG.md`). Top-level template:

```markdown
# <gem-name>

## <next-version>

### <Section heading>

- **<Topic>** — one-sentence description.

## <previous-version>

...
```

Common section headings, in this order when present:

- `### 🚀 Stable Version Released!` — only for the very first `1.0.0` release; followed by a 4–8 bullet feature overview and the line `For detailed usage and API reference, see the [README](./README.md).`
- `### 🎉 v<N> at a glance 🎊` — only for new major releases beyond `1.0.0`.
- `### BREAKING CHANGES` — required when bumping major. One bullet per break.
- `### New features` (or `### New Features`)
- `### Improvements`
- `### Bug fixes`
- `### Patch Changes` — one bullet per change. End with an `Updated dependencies` group when internal deps changed:

```markdown
### Patch Changes

- Updated dependencies
  - `cpf-gen`: 1.0.0 → 1.0.1
  - `cpf-val`: 1.0.0 → 1.0.1
```

Bullets may lead with a commit short-SHA when the change maps to a specific commit (`cafaf27: **Type checks** — …`).

## Step 6 — Conciseness rules (strict)

- **One sentence per bullet.** Two short sentences only when the second is a brief migration tip.
- **Lead with a bold topic** (`**`-wrapped, 1–4 words) OR a commit short-SHA, then an em-dash or colon, then the description.
- **No expository prose.** Don't explain motivation, internals, or test details. Link to docs instead of recapping them.
- **Use backticks** for every class, method, module, argument, file path, and CLI flag mentioned.
- **Prefer the smallest accurate description.** "Fix `CpfVal.cpf_val` ignoring leading zeros." beats a paragraph.
- **Limit each version section to ≤ 8 bullets total** across all sub-headings.

## Examples

Minimal patch:

```markdown
# cnpj-fmt

## 1.0.1

### Bug fixes

- **Array input** — Fix off-by-one in `CnpjFormatter#format` when input is an array of strings.
```

Minor addition:

```markdown
## 1.1.0

### New features

- **`strict` option** — `CnpjValidator` now accepts a `strict` option that rejects numeric-only CNPJs when `type` is `"alphanumeric"`.
```

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference

| Concern | Path |
|---------|------|
| Format reference | `packages/cnpj-gen/CHANGELOG.md` |
| Aggregator format reference | `packages/br-utilities/CHANGELOG.md` |
| Tag lookup | `cd ruby && git tag -l '<gem-name>@*' \| sort -V` |
