# frozen_string_literal: true

require 'cpf-utilities'
require 'cnpj-utilities'
require_relative 'br-utilities/version'

# Entry point for the +br-utilities+ gem.
#
# Loads sibling packages (+cpf-utilities+, +cnpj-utilities+) and defines the
# {BrUtils} façade class. +version.rb+ defines a placeholder module so the
# gemspec can read {BrUtils::VERSION}; this file promotes it to the class
# consumers instantiate.
#
# Two-tier access after +require 'br-utilities'+:
#
# - *Main shortcuts* at the façade root: {BrUtils::CpfFormatter},
#   {BrUtils::CnpjFormatter}, etc.
# - *Package nests* for the full sibling surface (Options, helpers, errors,
#   types): {BrUtils::CpfFmt}, {BrUtils::CnpjUtils}, etc. (same objects as
#   +::CpfFmt+, +::CnpjUtils+, …).
# - Root siblings (+CpfUtils+, +CnpjUtils+, +CpfFmt+, …) remain supported
#   unchanged.
unless BrUtils.is_a?(Class)
  version = BrUtils::VERSION
  Object.send(:remove_const, :BrUtils)
  BrUtils = Class.new
  BrUtils.const_set(:VERSION, version)
end

require_relative 'br-utilities/errors'
require_relative 'br-utilities/br_utils'
require_relative 'br-utilities/cpf_fmt'
require_relative 'br-utilities/cpf_gen'
require_relative 'br-utilities/cpf_val'
require_relative 'br-utilities/cpf_utils'
require_relative 'br-utilities/cnpj_fmt'
require_relative 'br-utilities/cnpj_gen'
require_relative 'br-utilities/cnpj_val'
require_relative 'br-utilities/cnpj_utils'
