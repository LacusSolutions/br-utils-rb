# frozen_string_literal: true

class BrUtils
  # CPF generation utilities re-exported from +cpf-gen+ (via +cpf-utilities+).
  #
  # Nested package module — same object as +::CpfGen+ (Options, helpers, errors,
  # types).
  CpfGen = ::CpfGen

  # Main-class shortcut for {CpfGen::CpfGenerator}.
  CpfGenerator = CpfGen::CpfGenerator

  # Main-class shortcut for {CpfGen::CpfGeneratorOptions}.
  CpfGeneratorOptions = CpfGen::CpfGeneratorOptions

  # Main-class shortcut for {CpfGen::Error}.
  CpfGeneratorError = CpfGen::Error
end
