# frozen_string_literal: true

require 'cpf-utilities'
require 'cnpj-utilities'

require_relative 'errors'

# Unified API for Brazilian-related data, like CPF (Cadastro de Pessoa Física)
# and CNPJ (Cadastro Nacional da Pessoa Jurídica). Provides a unified interface
# for formatting, generating, and validating data. Aggregates configurable
# {CpfUtils} and {CnpjUtils} instances behind a single façade.
#
# Public API:
#
# - {BrUtils.cpf}, {BrUtils.cnpj} — class helpers that alias {BrUtils::DEFAULT}
#   (preferred quick path for domain accessors)
# - {BrUtils::DEFAULT} — mutable process-wide singleton (JS/Python parity; not
#   thread-isolated — prefer {.new} under concurrency)
# - {BrUtils#cpf}, {BrUtils#cnpj} — instance accessors with setters
# - {BrUtils::VERSION}
# - {BrUtils::InvalidArgumentCombinationError}, {BrUtils::TypeMismatchError}
#
# Two-tier access: main-class shortcuts ({BrUtils::CpfFormatter}, etc.) and
# nested package modules ({BrUtils::CpfFmt}, {BrUtils::CpfUtils}, etc.). Root
# siblings ({CpfUtils}, {CnpjUtils}, {CpfFmt}, …) remain loadable after
# +require 'br-utilities'+.
#
# Mutating {BrUtils::DEFAULT} (e.g. via setters) affects subsequent class-helper
# calls process-wide (shared across threads). Prefer {BrUtils.new} for concurrent
# or isolated work. Custom instances are independent of +DEFAULT+.
#
# @example
#   require 'br-utilities'
#
#   BrUtils.cpf.format('12345678909') # => "123.456.789-09"
#   BrUtils.cnpj.is_valid('91415732000793') # => true
class BrUtils
  SETTINGS_KEYS = %i[cpf cnpj].freeze
  FLAT_KEYS = %i[cpf_formatter cpf_generator cnpj_formatter cnpj_generator cnpj_validator].freeze
  KEYWORD_KEYS = (SETTINGS_KEYS + FLAT_KEYS).freeze

  private_constant :SETTINGS_KEYS, :FLAT_KEYS, :KEYWORD_KEYS

  # Internal helpers for resolving domain utils from settings / keyword arguments.
  module Helpers
    module_function

    def resolve_settings(settings, keywords)
      keyword_settings = compact_keywords(keywords)
      raise_ambiguous_settings! if !settings.nil? && !keyword_settings.empty?
      return normalize_settings(settings) unless settings.nil?

      keyword_settings
    end

    def normalize_settings(settings)
      raise TypeMismatchError, "BrUtils settings must be a Hash. Got #{settings.class}." unless settings.is_a?(Hash)

      SETTINGS_KEYS.each_with_object({}) do |key, resolved|
        if settings.key?(key)
          resolved[key] = settings[key]
        elsif settings.key?(key.to_s)
          resolved[key] = settings[key.to_s]
        end
      end
    end

    def compact_keywords(keywords)
      KEYWORD_KEYS.each_with_object({}) do |key, resolved|
        value = keywords[key]
        resolved[key] = value unless value.nil?
      end
    end

    def resolve_cpf_utils(resolved)
      return resolve_utils(CpfUtils, resolved[:cpf]) if resolved.key?(:cpf)
      return CpfUtils.new unless cpf_flat?(resolved)

      CpfUtils.new(formatter: resolved[:cpf_formatter], generator: resolved[:cpf_generator])
    end

    def cpf_flat?(resolved)
      resolved.key?(:cpf_formatter) || resolved.key?(:cpf_generator)
    end

    def resolve_cnpj_utils(resolved)
      return resolve_utils(CnpjUtils, resolved[:cnpj]) if resolved.key?(:cnpj)
      return CnpjUtils.new unless cnpj_flat?(resolved)

      CnpjUtils.new(
        formatter: resolved[:cnpj_formatter],
        generator: resolved[:cnpj_generator],
        validator: resolved[:cnpj_validator]
      )
    end

    def cnpj_flat?(resolved)
      resolved.key?(:cnpj_formatter) || resolved.key?(:cnpj_generator) || resolved.key?(:cnpj_validator)
    end

    def resolve_utils(utils_cls, value)
      return utils_cls.new if value.nil?
      return value if value.is_a?(utils_cls)
      return utils_cls.new(value) if value.is_a?(Hash)

      # Duck-typed / test doubles: use the given object by reference (Python parity).
      value
    end

    def raise_ambiguous_settings!
      option_keywords = KEYWORD_KEYS.map { |key| "#{key}:" }.join(', ')

      raise InvalidArgumentCombinationError,
            'Pass either a settings Hash to `settings`, or keyword arguments ' \
            "(#{option_keywords}), not both."
    end
  end
  private_constant :Helpers

  # Creates a new {BrUtils} instance with customized options. All options are
  # optional. If any option is omitted, it falls back to its default value.
  #
  # Each of +:cpf+ and +:cnpj+ accepts either a pre-built utils instance or a
  # configuration {Hash} spread into the corresponding {CpfUtils} / {CnpjUtils}
  # constructor. Within that Hash, each resource key (+formatter+, +generator+,
  # and +validator+ for CNPJ) accepts either an options object or a mapping of
  # option values.
  #
  # Flat +:cpf_formatter+ / +:cpf_generator+ and +:cnpj_formatter+ /
  # +:cnpj_generator+ / +:cnpj_validator+ arguments are supported as a
  # convenience when only individual components need customization. They are
  # ignored when the corresponding +:cpf+ or +:cnpj+ argument is provided.
  #
  # +settings+ and the keyword arguments are never merged with each other: when
  # +settings+ is given (a {Hash} with +:cpf+ and/or +:cnpj+ keys), it alone
  # determines the domains; otherwise, the domains are built exclusively from the
  # keyword arguments. Passing +settings+ together with any non-+nil+ keyword
  # argument raises {InvalidArgumentCombinationError} instead of silently
  # ignoring the keywords.
  #
  # @param settings [Hash, nil] settings Hash with +:cpf+ and/or +:cnpj+ keys
  #   (each a utils instance, settings Hash, or +nil+)
  # @param keywords [Hash] +:cpf+, +:cnpj+, and/or flat component kwargs
  #   (mutually exclusive with +settings+)
  # @raise [InvalidArgumentCombinationError] if +settings+ and a keyword argument
  #   are both given
  # @raise [TypeMismatchError] if +settings+ is given and is not a +Hash+
  # @raise [CnpjFmt::TypeMismatchError] if CNPJ formatter options have an invalid
  #   type
  # @raise [CnpjFmt::OutOfRangeError] if CNPJ formatter +hidden_start+ or
  #   +hidden_end+ are out of valid range
  # @raise [CnpjFmt::ValidationError] if any CNPJ formatter key option contains a
  #   disallowed character
  # @raise [CnpjGen::TypeMismatchError] if CNPJ generator options have an invalid
  #   type
  # @raise [CnpjGen::ValidationError] if CNPJ generator +prefix+ is invalid or
  #   +type+ is not allowed
  # @raise [CnpjVal::TypeMismatchError] if CNPJ validator options have an invalid
  #   type
  # @raise [CnpjVal::ValidationError] if CNPJ validator +type+ is not allowed
  # @raise [CpfFmt::TypeMismatchError] if CPF formatter options have an invalid
  #   type
  # @raise [CpfFmt::OutOfRangeError] if CPF formatter +hidden_start+ or
  #   +hidden_end+ are out of valid range
  # @raise [CpfFmt::ValidationError] if any CPF formatter key option contains a
  #   disallowed character
  # @raise [CpfGen::TypeMismatchError] if CPF generator options have an invalid
  #   type
  # @raise [CpfGen::ValidationError] if CPF generator +prefix+ is invalid
  def initialize(settings = nil, **keywords)
    resolved = Helpers.resolve_settings(settings, keywords)

    @cpf = Helpers.resolve_cpf_utils(resolved)
    @cnpj = Helpers.resolve_cnpj_utils(resolved)
  end

  # Access the CPF utilities instance.
  #
  # @return [CpfUtils]
  attr_reader :cpf

  # Access the CNPJ utilities instance.
  #
  # @return [CnpjUtils]
  attr_reader :cnpj

  # Sets the active CPF utilities instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CpfUtils}
  # 2. A {Hash} of {CpfUtils} component settings
  # 3. A partial {Hash} with options for the CPF utilities
  # 4. +nil+ creates a brand new instance of {CpfUtils} with the default options
  #
  # Note that this resets the CPF utilities instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly and use the CPF utilities'
  # setters and methods (e.g. +utils.cpf.formatter.options.hidden = true+).
  #
  # @param value [CpfUtils, Hash, nil]
  # @raise [CpfFmt::TypeMismatchError] if formatter options have an invalid type
  # @raise [CpfFmt::OutOfRangeError] if formatter +hidden_start+ or +hidden_end+
  #   are out of valid range
  # @raise [CpfFmt::ValidationError] if any formatter key option contains a
  #   disallowed character
  # @raise [CpfGen::TypeMismatchError] if generator options have an invalid type
  # @raise [CpfGen::ValidationError] if generator +prefix+ is invalid
  def cpf=(value)
    @cpf = Helpers.resolve_utils(CpfUtils, value)
  end

  # Sets the active CNPJ utilities instance.
  #
  # It is flexible and can handle any of these inputs:
  #
  # 1. A complete new instance of {CnpjUtils}
  # 2. A {Hash} of {CnpjUtils} component settings
  # 3. A partial {Hash} with options for the CNPJ utilities
  # 4. +nil+ creates a brand new instance of {CnpjUtils} with the default options
  #
  # Note that this resets the CNPJ utilities instance completely. Any previous
  # options will be overridden. To alter only a single option or a few options
  # of the existing instance, access it directly and use the CNPJ utilities'
  # setters and methods (e.g. +utils.cnpj.generator.options.type = 'numeric'+).
  #
  # @param value [CnpjUtils, Hash, nil]
  # @raise [CnpjFmt::TypeMismatchError] if formatter options have an invalid type
  # @raise [CnpjFmt::OutOfRangeError] if formatter +hidden_start+ or +hidden_end+
  #   are out of valid range
  # @raise [CnpjFmt::ValidationError] if any formatter key option contains a
  #   disallowed character
  # @raise [CnpjGen::TypeMismatchError] if generator options have an invalid type
  # @raise [CnpjGen::ValidationError] if generator +prefix+ is invalid or +type+
  #   is not allowed
  # @raise [CnpjVal::TypeMismatchError] if validator options have an invalid type
  # @raise [CnpjVal::ValidationError] if validator +type+ is not allowed
  def cnpj=(value)
    @cnpj = Helpers.resolve_utils(CnpjUtils, value)
  end

  # Default {BrUtils} instance with default CPF and CNPJ utilities (parity with
  # the JS default export / Python +br_utils+ singleton). Configuration is
  # process-wide and shared across threads: mutating this instance (e.g. via
  # setters) affects subsequent {BrUtils.cpf} and {BrUtils.cnpj} calls for every
  # caller in the process. Prefer {BrUtils.new} for threaded or isolated work.
  DEFAULT = new

  class << self
    # Access the CPF utilities from {DEFAULT} (alias of {BrUtils#cpf} on that
    # instance).
    #
    # @return [CpfUtils]
    # @see BrUtils#cpf
    def cpf
      DEFAULT.cpf
    end

    # Access the CNPJ utilities from {DEFAULT} (alias of {BrUtils#cnpj} on that
    # instance).
    #
    # @return [CnpjUtils]
    # @see BrUtils#cnpj
    def cnpj
      DEFAULT.cnpj
    end
  end
end
