# frozen_string_literal: true

class BrUtils
  # CNPJ validation utilities re-exported from +cnpj-val+ (via +cnpj-utilities+).
  #
  # Nested package module — same object as +::CnpjVal+ (Options, helpers, errors,
  # types).
  CnpjVal = ::CnpjVal

  # Main-class shortcut for {CnpjVal::CnpjValidator}.
  CnpjValidator = CnpjVal::CnpjValidator

  # Main-class shortcut for {CnpjVal::CnpjValidatorOptions}.
  CnpjValidatorOptions = CnpjVal::CnpjValidatorOptions

  # Main-class shortcut for {CnpjVal::Error}.
  CnpjValidatorError = CnpjVal::Error
end
