---
id: packaging
title: Packaging, build, and publish
scope: packages/*/*.gemspec, packages/*/src/**/version.rb, lib/rake/gem_tasks.rake
triggers:
  - editing a package gemspec
  - changing require_paths, files, or metadata
  - building, versioning, or publishing a gem
---

# packaging

Manage gemspecs, builds, versioning, and publishing for br-utils-ruby packages. All paths are relative to the repo root.

> Ruby packages **do** have a build step (`gem build` via `rake build`). The build is fully driven by `lib/rake/gem_tasks.rake` — do not hand-roll a different layout or invoke `gem build` with ad-hoc flags unless you are debugging.

## Repository constraints

- Every package uses a hyphenated `<pkg>.gemspec` next to a `src/` layout (`require_paths = ["src"]`).
- **Do not run `rake release` or `gem push`** — publishing to RubyGems is the developer's responsibility (see [`context/ci-release.md`](ci-release.md)).
- `<Pkg>::VERSION` is a **placeholder** (`'0.0.0'`) in `src/<gem>/version.rb`. The real version is written in at publish time by the release workflow. Do **not** bump `version.rb`.
- Do not commit build artifacts (`*.gem`, `pkg/`). They are ignored.

## Gemspec anatomy

Copy the shape from `packages/cnpj-gen/cnpj-gen.gemspec`. Required fields:

```ruby
# frozen_string_literal: true

require_relative 'src/cnpj-gen/version'

Gem::Specification.new do |spec|
  spec.name          = 'cnpj-gen'          # equals the folder name
  spec.version       = CnpjGen::VERSION
  spec.authors       = ['Julio L. Muller']
  spec.email         = ['juliolmuller@outlook.com']
  spec.summary       = '...'
  spec.description   = '...'
  spec.homepage      = 'https://github.com/LacusSolutions/br-utils-ruby'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.1'
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'
  spec.files         = Dir['src/**/*'] + ['LICENSE', 'README.md', 'README.pt.md', 'CHANGELOG.md']
  spec.require_paths = ['src']
  spec.add_dependency 'cnpj-dv', '>= 2.0.0', '< 2.1.0'
  spec.add_dependency 'lacus-utils', '>= 1.1.0', '< 2.0.0'
end
```

Foundation (`lacus-utils`) omits `README.pt.md` from `spec.files`. Do not use `path:` in the gemspec.

### Public-API-relevant keys

Changes to `spec.name`, `required_ruby_version`, or runtime `add_dependency` are **public API** — coordinate through [`context/public-api.md`](public-api.md) and add a CHANGELOG entry. Changes to `add_development_dependency`, metadata test flags, or file lists that do not drop `src/` are dev-only.

### Version file

```ruby
# frozen_string_literal: true

module CnpjGen
  VERSION = '0.0.0'
end
```

Leave `VERSION` as `'0.0.0'`. Propose the next SemVer only in `CHANGELOG.md`.

## Build / clean commands

From a package directory (`packages/<pkg>/`):

```bash
bundle exec rake build        # gem build → <gem>-<version>.gem (after clean)
bundle exec rake gem:clean    # remove *.gem and pkg/
```

The package `Rakefile` loads `lib/rake/gem_tasks.rake` and `lib/rake/rspec_tasks.rake`. Do not duplicate those tasks.

Root `rake release` (used by the release-gem action) requires `RELEASE_PACKAGE=<dir>` and runs that package's `rake release` (build + `gem push`). Agents must **not** run it.

## Publish (developer only)

The release workflow overwrites `VERSION` in place, then publishes via `rubygems/release-gem` with OIDC trusted publishing. Agents must **not** run this — see [`context/ci-release.md`](ci-release.md).

Preview notes locally:

```bash
ruby bin/release-notes cnpj-gen              # latest CHANGELOG section
ruby bin/release-notes cnpj-gen --version 1.0.0
```

## Checklist

- [ ] `spec.name` matches the folder / intended RubyGems name
- [ ] `spec.version` reads `<Namespace>::VERSION`; source `VERSION` left as `'0.0.0'`
- [ ] `required_ruby_version = '>= 3.1'`
- [ ] `require_paths = ['src']`; `spec.files` includes `src/**/*` plus LICENSE / READMEs / CHANGELOG
- [ ] Runtime `add_dependency` follows [`context/dependencies.md`](dependencies.md)
- [ ] `bundle exec rake build` succeeds from the package directory
- [ ] Public-API-relevant gemspec changes have a CHANGELOG entry

## Package-level overrides

Before applying this harness, check whether the target package defines `packages/<pkg>/AGENTS.md` or `packages/<pkg>/context/`. If either exists and contradicts this file on the same topic, **follow the package-level instruction** (see [`context/README.md`](README.md#instruction-precedence)).

## Reference

| Concern | Path |
|---------|------|
| Canonical leaf gemspec | `packages/cnpj-gen/cnpj-gen.gemspec` |
| Foundation gemspec | `packages/lacus-utils/lacus-utils.gemspec` |
| Shared gem tasks | `lib/rake/gem_tasks.rake` |
| Release-notes CLI | `bin/release-notes` |
