# frozen_string_literal: true

class BrUtils
  # CPF validation utilities re-exported from +cpf-val+ (via +cpf-utilities+).
  #
  # Nested package module — same object as +::CpfVal+ (helpers, errors, types).
  CpfVal = ::CpfVal

  # Main-class shortcut for {CpfVal::CpfValidator}.
  CpfValidator = CpfVal::CpfValidator

  # Main-class shortcut for {CpfVal::Error}.
  CpfValidatorError = CpfVal::Error
end
