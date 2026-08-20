# frozen_string_literal: true

require 'spec_helper'

# Combined behavioural suite for BrUtils (JS / PHP / Python reference tests).
#
# Dropped cases (not meaningful in Ruby):
# - js/packages/br-utils/tests/output.spec.ts — UMD/CJS/ESM bundles, .d.ts wiring,
#   global variable attachment, and export-string parsing (JS packaging only).
# - JavaScript `undefined` nullish values — Ruby uses `nil` only.
# - PHP getCpfUtils() / getCnpjUtils() accessor names — Ruby uses #cpf / #cnpj
#   (JS/Python parity per AGENTS.md).
# - PHP read-only cpf/cnpj (no setters) — Ruby implements setters like JS/Python.
# - PHP CnpjType / CnpjValidationType enums — Ruby uses string type values.
# - PHP legacy CPF v1 InvalidArgumentException for formatter/generator options —
#   Ruby mirrors JS/Python v2 structured errors (CpfFmt::*/CpfGen::*).
# - PHP phpunit/Cpf/* legacy CPF v1 component suites — Ruby aligns with
#   cpf-utilities v2, not PHP CPF v1.
# - Python __slots__ / dynamic-attribute restriction — optional in Ruby; AGENTS.md
#   does not require freezing or slot-like attribute locking.
# - BrUtils Options class fold/#set/nil-setter contracts — BrUtils has no Options
#   class (settings are a Hash or domain utils instances; Options live on
#   cpf-fmt / cnpj-fmt / … siblings).
# - BrUtils.format / .generate / .is_valid class helpers — façade owns wiring only
#   (cpf/cnpj); domain operations live on CpfUtils / CnpjUtils (and their DEFAULT).

def compact_options(**kwargs)
  kwargs.compact
end

def expect_options_containing(actual, expected)
  expected.each do |key, value|
    expect(actual[key]).to eq(value)
  end
end

CPF_FORMAT_FACTORIES = {
  constructor_hash: lambda { |cpf, dot_key = nil, dash_key = nil|
    utils = BrUtils.new(cpf: { formatter: compact_options(dot_key: dot_key, dash_key: dash_key) })
    utils.cpf.format(cpf)
  },
  method_keywords: lambda { |cpf, dot_key = nil, dash_key = nil|
    BrUtils.new.cpf.format(cpf, dot_key: dot_key, dash_key: dash_key)
  }
}.freeze

CPF_GENERATE_FACTORIES = {
  constructor_hash: lambda { |format: nil, prefix: nil|
    utils = BrUtils.new(cpf: { generator: compact_options(format: format, prefix: prefix) })
    utils.cpf.generate
  },
  method_keywords: lambda { |format: nil, prefix: nil|
    BrUtils.new.cpf.generate(format: format, prefix: prefix)
  }
}.freeze

CNPJ_FORMAT_FACTORIES = {
  constructor_hash: lambda { |cnpj, slash_key = nil|
    utils = BrUtils.new(cnpj: { formatter: compact_options(slash_key: slash_key) })
    utils.cnpj.format(cnpj)
  },
  constructor_options: lambda { |cnpj, slash_key = nil|
    options = CnpjFmt::CnpjFormatterOptions.new(compact_options(slash_key: slash_key))
    utils = BrUtils.new(cnpj: { formatter: options })
    utils.cnpj.format(cnpj)
  },
  method_keywords: lambda { |cnpj, slash_key = nil|
    BrUtils.new.cnpj.format(cnpj, slash_key: slash_key)
  },
  method_options: lambda { |cnpj, slash_key = nil|
    options = CnpjFmt::CnpjFormatterOptions.new(compact_options(slash_key: slash_key))
    BrUtils.new.cnpj.format(cnpj, options)
  }
}.freeze

CNPJ_GENERATE_FACTORIES = {
  constructor_hash: lambda { |format: nil, prefix: nil, type: nil|
    utils = BrUtils.new(
      cnpj: { generator: compact_options(format: format, prefix: prefix, type: type) }
    )
    utils.cnpj.generate
  },
  constructor_options: lambda { |format: nil, prefix: nil, type: nil|
    options = CnpjGen::CnpjGeneratorOptions.new(
      compact_options(format: format, prefix: prefix, type: type)
    )
    utils = BrUtils.new(cnpj: { generator: options })
    utils.cnpj.generate
  },
  method_keywords: lambda { |format: nil, prefix: nil, type: nil|
    BrUtils.new.cnpj.generate(format: format, prefix: prefix, type: type)
  },
  method_options: lambda { |format: nil, prefix: nil, type: nil|
    options = CnpjGen::CnpjGeneratorOptions.new(
      compact_options(format: format, prefix: prefix, type: type)
    )
    BrUtils.new.cnpj.generate(options)
  }
}.freeze

CNPJ_IS_VALID_FACTORIES = {
  constructor_hash: lambda { |cnpj, type: nil, case_sensitive: nil|
    utils = BrUtils.new(
      cnpj: { validator: compact_options(type: type, case_sensitive: case_sensitive) }
    )
    utils.cnpj.is_valid(cnpj)
  },
  constructor_options: lambda { |cnpj, type: nil, case_sensitive: nil|
    options = CnpjVal::CnpjValidatorOptions.new(
      compact_options(type: type, case_sensitive: case_sensitive)
    )
    utils = BrUtils.new(cnpj: { validator: options })
    utils.cnpj.is_valid(cnpj)
  },
  method_keywords: lambda { |cnpj, type: nil, case_sensitive: nil|
    BrUtils.new.cnpj.is_valid(cnpj, type: type, case_sensitive: case_sensitive)
  },
  method_options: lambda { |cnpj, type: nil, case_sensitive: nil|
    options = CnpjVal::CnpjValidatorOptions.new(
      compact_options(type: type, case_sensitive: case_sensitive)
    )
    BrUtils.new.cnpj.is_valid(cnpj, options)
  }
}.freeze

CPF_FORMAT_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to #format as keywords', :method_keywords]
].freeze

CPF_GENERATE_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to #generate as keywords', :method_keywords]
].freeze

CNPJ_FORMAT_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CnpjFormatterOptions', :constructor_options],
  ['when options are passed to #format as keywords', :method_keywords],
  ['when options are passed to #format as CnpjFormatterOptions', :method_options]
].freeze

CNPJ_GENERATE_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CnpjGeneratorOptions', :constructor_options],
  ['when options are passed to #generate as keywords', :method_keywords],
  ['when options are passed to #generate as CnpjGeneratorOptions', :method_options]
].freeze

CNPJ_IS_VALID_FACTORY_CONTEXTS = [
  ['when options are passed to the constructor as a Hash', :constructor_hash],
  ['when options are passed to the constructor as CnpjValidatorOptions', :constructor_options],
  ['when options are passed to #is_valid as keywords', :method_keywords],
  ['when options are passed to #is_valid as CnpjValidatorOptions', :method_options]
].freeze

RSpec.describe BrUtils do
  def default_cpf_formatter_options_snapshot
    CpfFmt::CpfFormatterOptions.new.all
  end

  def default_cpf_generator_options_snapshot
    CpfGen::CpfGeneratorOptions.new.all
  end

  def default_cnpj_formatter_options_snapshot
    CnpjFmt::CnpjFormatterOptions.new.all
  end

  def default_cnpj_generator_options_snapshot
    CnpjGen::CnpjGeneratorOptions.new.all
  end

  def default_cnpj_validator_options_snapshot
    CnpjVal::CnpjValidatorOptions.new.all
  end

  describe 'DEFAULT' do
    it 'is an instance of BrUtils' do
      expect(described_class::DEFAULT).to be_a(described_class)
    end

    it 'exposes cpf and cnpj domain utils' do
      aggregate_failures do
        expect(described_class::DEFAULT.cpf).to be_a(CpfUtils)
        expect(described_class::DEFAULT.cnpj).to be_a(CnpjUtils)
      end
    end
  end

  describe 'class helpers' do
    # BrUtils façade operations are domain accessors; class helpers forward to DEFAULT.
    it 'exposes cpf and cnpj' do
      aggregate_failures do
        expect(described_class).to respond_to(:cpf)
        expect(described_class).to respond_to(:cnpj)
      end
    end

    context 'when calling through the class' do
      it 'returns the same cpf as DEFAULT' do
        expect(described_class.cpf).to equal(described_class::DEFAULT.cpf)
      end

      it 'returns the same cnpj as DEFAULT' do
        expect(described_class.cnpj).to equal(described_class::DEFAULT.cnpj)
      end
    end

    context 'when DEFAULT is mutated' do
      around do |example|
        original_cpf = described_class::DEFAULT.cpf
        original_cnpj = described_class::DEFAULT.cnpj
        example.run
        described_class::DEFAULT.cpf = original_cpf
        described_class::DEFAULT.cnpj = original_cnpj
      end

      it 'affects subsequent class helper cpf calls' do
        replacement = CpfUtils.new(formatter: { dash_key: '|' })
        described_class::DEFAULT.cpf = replacement

        aggregate_failures do
          expect(described_class.cpf).to equal(replacement)
          expect(described_class.cpf.format('12345678909')).to eq('123.456.789|09')
        end
      end

      it 'affects subsequent class helper cnpj calls' do
        replacement = CnpjUtils.new(formatter: { slash_key: '|' })
        described_class::DEFAULT.cnpj = replacement

        aggregate_failures do
          expect(described_class.cnpj).to equal(replacement)
          expect(described_class.cnpj.format('01ABC234000X56')).to eq('01.ABC.234|000X-56')
        end
      end

      it 'does not affect a custom instance' do
        custom = described_class.new
        described_class::DEFAULT.cpf = CpfUtils.new(formatter: { dash_key: '|' })
        described_class::DEFAULT.cnpj = CnpjUtils.new(formatter: { slash_key: '|' })

        aggregate_failures do
          expect(custom.cpf.format('12345678909')).to eq('123.456.789-09')
          expect(custom.cnpj.format('01ABC234000X56')).to eq('01.ABC.234/000X-56')
        end
      end
    end
  end

  describe 'loaded sibling packages' do
    it 'makes cpf-utilities symbols available' do
      aggregate_failures do
        expect(defined?(CpfUtils)).to eq('constant')
        expect(defined?(CpfFmt::CpfFormatter)).to eq('constant')
        expect(defined?(CpfGen::CpfGenerator)).to eq('constant')
        expect(defined?(CpfVal::CpfValidator)).to eq('constant')
        expect(CpfFmt).to respond_to(:cpf_fmt)
        expect(CpfGen).to respond_to(:cpf_gen)
        expect(CpfVal).to respond_to(:cpf_val)
      end
    end

    it 'makes cnpj-utilities symbols available' do
      aggregate_failures do
        expect(defined?(CnpjUtils)).to eq('constant')
        expect(defined?(CnpjFmt::CnpjFormatter)).to eq('constant')
        expect(defined?(CnpjGen::CnpjGenerator)).to eq('constant')
        expect(defined?(CnpjVal::CnpjValidator)).to eq('constant')
        expect(CnpjFmt).to respond_to(:cnpj_fmt)
        expect(CnpjGen).to respond_to(:cnpj_gen)
        expect(CnpjVal).to respond_to(:cnpj_val)
      end
    end
  end

  describe 'two-tier BrUtils re-exports' do
    it 'nests sibling modules as the same objects' do
      aggregate_failures do
        expect(described_class::CpfUtils).to equal(CpfUtils)
        expect(described_class::CnpjUtils).to equal(CnpjUtils)
        expect(described_class::CpfFmt).to equal(CpfFmt)
        expect(described_class::CpfGen).to equal(CpfGen)
        expect(described_class::CpfVal).to equal(CpfVal)
        expect(described_class::CnpjFmt).to equal(CnpjFmt)
        expect(described_class::CnpjGen).to equal(CnpjGen)
        expect(described_class::CnpjVal).to equal(CnpjVal)
      end
    end

    it 'aliases main cpf classes at the façade root' do
      aggregate_failures do
        expect(described_class::CpfFormatter).to equal(CpfFmt::CpfFormatter)
        expect(described_class::CpfFormatterOptions).to equal(CpfFmt::CpfFormatterOptions)
        expect(described_class::CpfGenerator).to equal(CpfGen::CpfGenerator)
        expect(described_class::CpfGeneratorOptions).to equal(CpfGen::CpfGeneratorOptions)
        expect(described_class::CpfValidator).to equal(CpfVal::CpfValidator)
      end
    end

    it 'aliases main cnpj classes at the façade root' do
      aggregate_failures do
        expect(described_class::CnpjFormatter).to equal(CnpjFmt::CnpjFormatter)
        expect(described_class::CnpjFormatterOptions).to equal(CnpjFmt::CnpjFormatterOptions)
        expect(described_class::CnpjGenerator).to equal(CnpjGen::CnpjGenerator)
        expect(described_class::CnpjGeneratorOptions).to equal(CnpjGen::CnpjGeneratorOptions)
        expect(described_class::CnpjValidator).to equal(CnpjVal::CnpjValidator)
        expect(described_class::CnpjValidatorOptions).to equal(CnpjVal::CnpjValidatorOptions)
      end
    end

    context 'with nested surface smoke' do
      it 'exposes Options through the nest' do
        options = described_class::CpfFmt::CpfFormatterOptions.new(hidden: true)

        expect(options.hidden).to be(true)
      end

      it 'exposes helpers through the nest' do
        expect(described_class::CpfFmt.cpf_fmt('12345678909')).to eq('123.456.789-09')
      end

      it 'exposes an error class through the nest' do
        expect(described_class::CnpjFmt::OutOfRangeError).to equal(CnpjFmt::OutOfRangeError)
      end
    end
  end

  describe '#initialize' do
    context 'when called with no arguments' do
      subject(:utils) { described_class.new }

      it 'creates default domain utils instances' do
        aggregate_failures do
          expect(utils.cpf).to be_a(CpfUtils)
          expect(utils.cnpj).to be_a(CnpjUtils)
        end
      end

      it 'uses default domain component options' do
        aggregate_failures do
          expect_options_containing(
            utils.cpf.formatter.options.all,
            default_cpf_formatter_options_snapshot
          )
          expect_options_containing(
            utils.cpf.generator.options.all,
            default_cpf_generator_options_snapshot
          )
          expect_options_containing(
            utils.cnpj.formatter.options.all,
            default_cnpj_formatter_options_snapshot
          )
          expect_options_containing(
            utils.cnpj.generator.options.all,
            default_cnpj_generator_options_snapshot
          )
          expect_options_containing(
            utils.cnpj.validator.options.all,
            default_cnpj_validator_options_snapshot
          )
        end
      end
    end

    context 'when called with instances of resources' do
      it 'uses the passed CnpjUtils directly' do
        cnpj_utils = CnpjUtils.new
        utils = described_class.new(cnpj: cnpj_utils)

        aggregate_failures do
          expect(utils.cnpj).to be_a(CnpjUtils)
          expect(utils.cnpj).to equal(cnpj_utils)
        end
      end

      it 'uses the passed CpfUtils directly' do
        cpf_utils = CpfUtils.new
        utils = described_class.new(cpf: cpf_utils)

        aggregate_failures do
          expect(utils.cpf).to be_a(CpfUtils)
          expect(utils.cpf).to equal(cpf_utils)
        end
      end

      it 'uses the passed resources directly' do
        cnpj_utils = CnpjUtils.new
        cpf_utils = CpfUtils.new
        utils = described_class.new(cnpj: cnpj_utils, cpf: cpf_utils)

        aggregate_failures do
          expect(utils.cnpj).to equal(cnpj_utils)
          expect(utils.cpf).to equal(cpf_utils)
        end
      end
    end

    context 'when called with literal Hash parameters' do
      let(:cnpj_utils_options) do
        {
          formatter: {
            hidden: true,
            hidden_key: '#',
            hidden_start: 8,
            hidden_end: 11,
            dot_key: '_',
            slash_key: '|',
            dash_key: ' dv '
          },
          generator: {
            format: true,
            prefix: '12345678',
            type: 'numeric'
          },
          validator: {
            type: 'numeric'
          }
        }
      end

      let(:cpf_utils_options) do
        {
          formatter: {
            hidden: true,
            hidden_key: '#',
            hidden_start: 8,
            hidden_end: 10,
            dot_key: '_',
            dash_key: ' dv '
          },
          generator: {
            format: true,
            prefix: '12345678'
          }
        }
      end

      it 'builds CnpjUtils from nested option hashes' do
        utils = described_class.new(cnpj: cnpj_utils_options)

        aggregate_failures do
          expect(utils.cnpj).to be_a(CnpjUtils)
          expect(utils.cnpj.formatter).to be_a(CnpjFmt::CnpjFormatter)
          expect_options_containing(utils.cnpj.formatter.options.all, cnpj_utils_options[:formatter])
          expect(utils.cnpj.generator).to be_a(CnpjGen::CnpjGenerator)
          expect_options_containing(utils.cnpj.generator.options.all, cnpj_utils_options[:generator])
          expect(utils.cnpj.validator).to be_a(CnpjVal::CnpjValidator)
          expect_options_containing(utils.cnpj.validator.options.all, cnpj_utils_options[:validator])
        end
      end

      it 'builds CpfUtils from nested option hashes' do
        utils = described_class.new(cpf: cpf_utils_options)

        aggregate_failures do
          expect(utils.cpf).to be_a(CpfUtils)
          expect(utils.cpf.formatter).to be_a(CpfFmt::CpfFormatter)
          expect_options_containing(utils.cpf.formatter.options.all, cpf_utils_options[:formatter])
          expect(utils.cpf.generator).to be_a(CpfGen::CpfGenerator)
          expect_options_containing(utils.cpf.generator.options.all, cpf_utils_options[:generator])
        end
      end
    end

    context 'when called with flat formatter and generator options' do
      it 'applies cpf_formatter options' do
        formatter_options = CpfFmt::CpfFormatterOptions.new(hidden: true, hidden_key: 'X')
        utils = described_class.new(cpf_formatter: formatter_options)

        aggregate_failures do
          expect(utils.cpf.formatter.options).to equal(formatter_options)
          expect(utils.cpf.format('12345678901')).to eq('123.XXX.XXX-XX')
        end
      end

      it 'applies cpf_generator options' do
        generator_options = CpfGen::CpfGeneratorOptions.new(format: true, prefix: '123456789')
        utils = described_class.new(cpf_generator: generator_options)

        aggregate_failures do
          expect(utils.cpf.generator.options).to equal(generator_options)
          expect(utils.cpf.generate).to start_with('123.456.789-')
        end
      end

      it 'applies cnpj_formatter options' do
        formatter_options = CnpjFmt::CnpjFormatterOptions.new(hidden: true, hidden_key: 'X')
        utils = described_class.new(cnpj_formatter: formatter_options)

        aggregate_failures do
          expect(utils.cnpj.formatter.options).to equal(formatter_options)
          expect(utils.cnpj.format('11222333000181')).to eq('11.222.XXX/XXXX-XX')
        end
      end

      it 'applies cnpj_generator options' do
        generator_options = CnpjGen::CnpjGeneratorOptions.new(format: true, prefix: '11222333')
        utils = described_class.new(cnpj_generator: generator_options)

        aggregate_failures do
          expect(utils.cnpj.generator.options).to equal(generator_options)
          expect(utils.cnpj.generate).to start_with('11.222.333/')
        end
      end

      it 'applies all flat options together' do
        cpf_fmt_opts = CpfFmt::CpfFormatterOptions.new(hidden: true)
        cpf_gen_opts = CpfGen::CpfGeneratorOptions.new(format: true)
        cnpj_fmt_opts = CnpjFmt::CnpjFormatterOptions.new(hidden: true)
        cnpj_gen_opts = CnpjGen::CnpjGeneratorOptions.new(format: true)

        utils = described_class.new(
          cpf_formatter: cpf_fmt_opts,
          cpf_generator: cpf_gen_opts,
          cnpj_formatter: cnpj_fmt_opts,
          cnpj_generator: cnpj_gen_opts
        )

        aggregate_failures do
          expect(utils.cpf.formatter.options).to equal(cpf_fmt_opts)
          expect(utils.cpf.generator.options).to equal(cpf_gen_opts)
          expect(utils.cnpj.formatter.options).to equal(cnpj_fmt_opts)
          expect(utils.cnpj.generator.options).to equal(cnpj_gen_opts)
        end
      end
    end

    context 'when called with nested settings hashes' do
      it 'configures CPF formatter and generator from hashes' do
        formatter_options = {
          hidden: true,
          hidden_key: '#',
          hidden_start: 8,
          hidden_end: 10,
          dot_key: '_',
          dash_key: ' dv '
        }
        generator_options = { format: true, prefix: '12345678' }

        utils = described_class.new(
          cpf: {
            formatter: formatter_options,
            generator: generator_options
          }
        )

        aggregate_failures do
          expect_options_containing(utils.cpf.formatter.options.all, formatter_options)
          expect_options_containing(utils.cpf.generator.options.all, generator_options)
        end
      end

      it 'configures CNPJ components from hashes' do
        formatter_options = { slash_key: '|' }
        generator_options = { format: true, prefix: '12345' }
        validator_options = { type: 'numeric', case_sensitive: false }

        utils = described_class.new(
          cnpj: {
            formatter: formatter_options,
            generator: generator_options,
            validator: validator_options
          }
        )

        aggregate_failures do
          expect_options_containing(utils.cnpj.formatter.options.all, formatter_options)
          expect_options_containing(utils.cnpj.generator.options.all, generator_options)
          expect_options_containing(utils.cnpj.validator.options.all, validator_options)
        end
      end

      it 'keeps provided options instances by reference' do
        cnpj_formatter_options = CnpjFmt::CnpjFormatterOptions.new
        cnpj_generator_options = CnpjGen::CnpjGeneratorOptions.new
        cnpj_validator_options = CnpjVal::CnpjValidatorOptions.new

        utils = described_class.new(
          cnpj: {
            formatter: cnpj_formatter_options,
            generator: cnpj_generator_options,
            validator: cnpj_validator_options
          }
        )

        aggregate_failures do
          expect(utils.cnpj.formatter.options).to equal(cnpj_formatter_options)
          expect(utils.cnpj.generator.options).to equal(cnpj_generator_options)
          expect(utils.cnpj.validator.options).to equal(cnpj_validator_options)
        end
      end

      it 'reflects later mutation of shared options' do
        cnpj_formatter_options = CnpjFmt::CnpjFormatterOptions.new
        utils = described_class.new(cnpj: { formatter: cnpj_formatter_options })

        cnpj_formatter_options.dash_key = '|'

        expect(utils.cnpj.formatter.options.all[:dash_key]).to eq('|')
      end
    end

    context 'when called with a settings Hash' do
      it 'adopts nested domain utils from the Hash' do
        cpf_utils = CpfUtils.new
        cnpj_utils = CnpjUtils.new
        utils = described_class.new({ cpf: cpf_utils, cnpj: cnpj_utils })

        aggregate_failures do
          expect(utils.cpf).to equal(cpf_utils)
          expect(utils.cnpj).to equal(cnpj_utils)
        end
      end

      it 'adopts domain utils from string keys' do
        cpf_utils = CpfUtils.new
        cnpj_utils = CnpjUtils.new
        utils = described_class.new({ 'cpf' => cpf_utils, 'cnpj' => cnpj_utils })

        aggregate_failures do
          expect(utils.cpf).to equal(cpf_utils)
          expect(utils.cnpj).to equal(cnpj_utils)
        end
      end
    end

    context 'when a domain keyword and its flat keyword are both given' do
      it 'ignores the flat keyword' do
        cpf_utils = CpfUtils.new
        utils = described_class.new(
          cpf: cpf_utils,
          cpf_formatter: CpfFmt::CpfFormatterOptions.new(dash_key: '|')
        )

        aggregate_failures do
          expect(utils.cpf).to equal(cpf_utils)
          expect(utils.cpf.formatter.options.all[:dash_key]).to eq('-')
        end
      end
    end

    context 'when called with a non-Hash settings value' do
      it 'raises TypeMismatchError for a string' do
        expect { described_class.new('not-a-hash') }
          .to raise_error(BrUtils::TypeMismatchError, /settings must be a Hash/)
      end

      it 'raises TypeMismatchError for false' do
        expect { described_class.new(false) }
          .to raise_error(BrUtils::TypeMismatchError, /settings must be a Hash/)
      end

      it 'raises TypeMismatchError for an array' do
        expect { described_class.new([]) }
          .to raise_error(BrUtils::TypeMismatchError, /settings must be a Hash/)
      end
    end

    context 'when called with invalid options' do
      it 'raises CPF formatter OutOfRangeError' do
        expect { described_class.new(cpf: { formatter: { hidden_start: -1 } }) }
          .to raise_error(CpfFmt::OutOfRangeError)
      end

      it 'raises CPF generator ValidationError' do
        expect { described_class.new(cpf: { generator: { prefix: '000000000' } }) }
          .to raise_error(CpfGen::ValidationError)
      end

      it 'raises CNPJ formatter OutOfRangeError' do
        expect { described_class.new(cnpj: { formatter: { hidden_start: -1 } }) }
          .to raise_error(CnpjFmt::OutOfRangeError)
      end

      it 'raises CNPJ formatter ValidationError' do
        expect { described_class.new(cnpj: { formatter: { dash_key: "\u00e5" } }) }
          .to raise_error(CnpjFmt::ValidationError)
      end

      it 'raises CNPJ generator ValidationError for prefix' do
        expect { described_class.new(cnpj: { generator: { prefix: '00000000' } }) }
          .to raise_error(CnpjGen::ValidationError)
      end

      it 'raises CNPJ generator ValidationError for type' do
        expect { described_class.new(cnpj: { generator: { type: 'invalid' } }) }
          .to raise_error(CnpjGen::ValidationError)
      end

      it 'raises CNPJ generator TypeMismatchError' do
        expect { described_class.new(cnpj: { generator: { prefix: 123 } }) }
          .to raise_error(CnpjGen::TypeMismatchError)
      end

      it 'raises CNPJ validator ValidationError' do
        expect { described_class.new(cnpj: { validator: { type: 'invalid' } }) }
          .to raise_error(CnpjVal::ValidationError)
      end
    end

    context 'when called with both a settings Hash and keywords' do
      it 'raises InvalidArgumentCombinationError' do
        expect do
          described_class.new({ cpf: {} }, cnpj: CnpjUtils.new)
        end.to raise_error(BrUtils::InvalidArgumentCombinationError)
      end

      it 'raises for false settings with keywords' do
        expect do
          described_class.new(false, cpf: {})
        end.to raise_error(BrUtils::InvalidArgumentCombinationError)
      end
    end
  end

  describe 'resource accessors' do
    subject(:utils) { described_class.new }

    it 'returns the CpfUtils instance' do
      expect(utils.cpf).to be_a(CpfUtils)
    end

    it 'returns the CpfFormatter instance' do
      expect(utils.cpf.formatter).to be_a(CpfFmt::CpfFormatter)
    end

    it 'returns the CpfGenerator instance' do
      expect(utils.cpf.generator).to be_a(CpfGen::CpfGenerator)
    end

    it 'returns the CpfValidator instance' do
      expect(utils.cpf.validator).to be_a(CpfVal::CpfValidator)
    end

    it 'returns the CnpjUtils instance' do
      expect(utils.cnpj).to be_a(CnpjUtils)
    end

    it 'returns the CnpjFormatter instance' do
      expect(utils.cnpj.formatter).to be_a(CnpjFmt::CnpjFormatter)
    end

    it 'returns the CnpjGenerator instance' do
      expect(utils.cnpj.generator).to be_a(CnpjGen::CnpjGenerator)
    end

    it 'returns the CnpjValidator instance' do
      expect(utils.cnpj.validator).to be_a(CnpjVal::CnpjValidator)
    end
  end

  describe '#cnpj=' do
    subject(:utils) { described_class.new }

    context 'when called with a CnpjUtils instance' do
      it 'sets the CnpjUtils instance' do
        cnpj_utils = CnpjUtils.new
        utils.cnpj = cnpj_utils

        expect(utils.cnpj).to equal(cnpj_utils)
      end
    end

    context 'when called with literal Hash parameters' do
      let(:cnpj_utils_options) do
        {
          formatter: {
            hidden: true,
            hidden_key: '#',
            hidden_start: 8,
            hidden_end: 11,
            dot_key: '_',
            slash_key: '|',
            dash_key: ' dv '
          },
          generator: {
            format: true,
            prefix: '12345678',
            type: 'numeric'
          },
          validator: {
            type: 'numeric'
          }
        }
      end

      it 'sets CnpjUtils built from options' do
        utils.cnpj = cnpj_utils_options

        aggregate_failures do
          expect(utils.cnpj).to be_a(CnpjUtils)
          expect_options_containing(utils.cnpj.formatter.options.all, cnpj_utils_options[:formatter])
          expect_options_containing(utils.cnpj.generator.options.all, cnpj_utils_options[:generator])
          expect_options_containing(utils.cnpj.validator.options.all, cnpj_utils_options[:validator])
        end
      end
    end

    context 'when called with nil' do
      it 'creates a new default CnpjUtils' do
        original = utils.cnpj
        utils.cnpj = nil

        aggregate_failures do
          expect(utils.cnpj).to be_a(CnpjUtils)
          expect(utils.cnpj).not_to equal(original)
        end
      end
    end
  end

  describe '#cpf=' do
    subject(:utils) { described_class.new }

    context 'when called with a CpfUtils instance' do
      it 'sets the CpfUtils instance' do
        cpf_utils = CpfUtils.new
        utils.cpf = cpf_utils

        expect(utils.cpf).to equal(cpf_utils)
      end
    end

    context 'when called with literal Hash parameters' do
      let(:cpf_utils_options) do
        {
          formatter: {
            hidden: true,
            hidden_key: '#',
            hidden_start: 8,
            hidden_end: 10,
            dot_key: '_',
            dash_key: ' dv '
          },
          generator: {
            format: true,
            prefix: '12345678'
          }
        }
      end

      it 'sets CpfUtils built from options' do
        utils.cpf = cpf_utils_options

        aggregate_failures do
          expect(utils.cpf).to be_a(CpfUtils)
          expect_options_containing(utils.cpf.formatter.options.all, cpf_utils_options[:formatter])
          expect_options_containing(utils.cpf.generator.options.all, cpf_utils_options[:generator])
        end
      end
    end

    context 'when called with nil' do
      it 'creates a new default CpfUtils' do
        original = utils.cpf
        utils.cpf = nil

        aggregate_failures do
          expect(utils.cpf).to be_a(CpfUtils)
          expect(utils.cpf).not_to equal(original)
        end
      end
    end
  end

  describe 'CPF utils through BrUtils' do
    describe '#format' do
      CPF_FORMAT_FACTORY_CONTEXTS.each do |context_description, factory_key|
        context context_description do
          let(:format_fn) { CPF_FORMAT_FACTORIES.fetch(factory_key) }

          it 'matches CpfFormatter#format behavior' do
            input = '80976511061'
            formatter = CpfFmt::CpfFormatter.new

            expect(format_fn.call(input)).to eq(formatter.format(input))
          end

          it 'forwards formatting options' do
            expect(format_fn.call('80976511061', '_', ' dv ')).to eq('809_765_110 dv 61')
          end
        end
      end

      context 'when constructor formatter defaults are set' do
        it 'applies defaults when method options are omitted' do
          utils = described_class.new(
            cpf: {
              formatter: {
                hidden: true,
                hidden_key: '#'
              }
            }
          )

          expect(utils.cpf.format('80976511061')).to include('#')
        end
      end

      it 'formats a basic CPF string' do
        expect(described_class.new.cpf.format('12345678901')).to eq('123.456.789-01')
      end
    end

    describe '#generate' do
      CPF_GENERATE_FACTORY_CONTEXTS.each do |context_description, factory_key|
        context context_description do
          let(:generate_fn) { CPF_GENERATE_FACTORIES.fetch(factory_key) }

          it 'matches CpfGenerator length behavior' do
            generator = CpfGen::CpfGenerator.new
            result = generate_fn.call

            aggregate_failures do
              expect(result).to match(/\A\d{11}\z/)
              expect(result.length).to eq(generator.generate.length)
            end
          end

          it 'forwards generation options' do
            result = generate_fn.call(format: true, prefix: '12345')

            expect(result).to match(/\A123\.45\d\.\d{3}-\d{2}\z/)
          end

          it 'returns a deterministic CPF for a full prefix' do
            prefix = '123456789'
            results = Array.new(20) { generate_fn.call(prefix: prefix) }

            expect(results.uniq.size).to eq(1)
          end
        end
      end

      it 'generates an 11-digit CPF' do
        expect(described_class.new.cpf.generate.length).to eq(11)
      end
    end

    describe '#is_valid' do
      it 'returns true for a valid CPF' do
        expect(described_class.new.cpf.is_valid('52998224725')).to be(true)
      end

      it 'returns false for an invalid CPF' do
        expect(described_class.new.cpf.is_valid('12345678901')).to be(false)
      end
    end
  end

  describe 'CNPJ utils through BrUtils' do
    describe '#format' do
      CNPJ_FORMAT_FACTORY_CONTEXTS.each do |context_description, factory_key|
        context context_description do
          let(:format_fn) { CNPJ_FORMAT_FACTORIES.fetch(factory_key) }

          it 'matches CnpjFormatter#format behavior' do
            input = '91415732000793'
            formatter = CnpjFmt::CnpjFormatter.new

            expect(format_fn.call(input)).to eq(formatter.format(input))
          end

          it 'forwards formatting options' do
            expect(format_fn.call('01ABC234000X56', '|')).to eq('01.ABC.234|000X-56')
          end
        end
      end

      context 'when constructor formatter defaults are set' do
        it 'applies defaults when method options are omitted' do
          utils = described_class.new(
            cnpj: {
              formatter: {
                hidden: true,
                hidden_key: '#'
              }
            }
          )

          expect(utils.cnpj.format('12ABC34500DE99')).to include('#')
        end
      end

      it 'formats a basic CNPJ string' do
        expect(described_class.new.cnpj.format('12345678000195')).to eq('12.345.678/0001-95')
      end
    end

    describe '#generate' do
      CNPJ_GENERATE_FACTORY_CONTEXTS.each do |context_description, factory_key|
        context context_description do
          let(:generate_fn) { CNPJ_GENERATE_FACTORIES.fetch(factory_key) }

          it 'matches CnpjGenerator length behavior' do
            generator = CnpjGen::CnpjGenerator.new
            result = generate_fn.call

            aggregate_failures do
              expect(result).to match(/\A[0-9A-Z]{14}\z/)
              expect(result.length).to eq(generator.generate.length)
            end
          end

          it 'forwards generation options' do
            result = generate_fn.call(format: true, prefix: '12345', type: 'numeric')

            expect(result).to match(%r{\A12\.345\.\d{3}/\d{4}-\d{2}\z})
          end

          it 'returns a deterministic CNPJ for a full prefix' do
            prefix = '123456780009'
            results = Array.new(20) { generate_fn.call(prefix: prefix) }

            expect(results.uniq.size).to eq(1)
          end
        end
      end

      it 'generates a 14-character CNPJ' do
        expect(described_class.new.cnpj.generate.length).to eq(14)
      end
    end

    describe '#is_valid' do
      CNPJ_IS_VALID_FACTORY_CONTEXTS.each do |context_description, factory_key|
        context context_description do
          let(:is_valid_fn) { CNPJ_IS_VALID_FACTORIES.fetch(factory_key) }

          it 'matches CnpjValidator#is_valid behavior' do
            input = '91415732000793'
            validator = CnpjVal::CnpjValidator.new

            expect(is_valid_fn.call(input)).to eq(validator.is_valid(input))
          end

          it 'forwards validation options' do
            input = '1QB5UKALPYFP59'

            aggregate_failures do
              expect(is_valid_fn.call(input, type: 'numeric')).to be(false)
              expect(is_valid_fn.call(input, type: 'alphanumeric')).to be(true)
            end
          end

          it 'validates formatted and unformatted strings' do
            aggregate_failures do
              expect(is_valid_fn.call('1QB5UKALPYFP59')).to be(true)
              expect(is_valid_fn.call('1QB5.UKAL.PYF/P59')).to be(true)
              expect(is_valid_fn.call('AB123CDE0001555')).to be(false)
            end
          end
        end
      end

      it 'returns true for a valid numeric CNPJ' do
        expect(described_class.new.cnpj.is_valid('11222333000181')).to be(true)
      end

      it 'returns false for an invalid CNPJ' do
        expect(described_class.new.cnpj.is_valid('11111111111111')).to be(false)
      end
    end
  end

  describe 'package smoke' do
    it 'exposes BrUtils as a class' do
      aggregate_failures do
        expect(described_class).to be_a(Class)
        expect(described_class.new).to be_a(described_class)
      end
    end

    it 'exposes a VERSION string' do
      expect(described_class::VERSION).to be_a(String).and match(/\A\d+\.\d+\.\d+\z/)
    end
  end
end
