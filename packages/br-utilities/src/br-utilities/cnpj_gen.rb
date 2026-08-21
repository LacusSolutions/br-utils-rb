# frozen_string_literal: true

class BrUtils
  # CNPJ generation utilities re-exported from +cnpj-gen+ (via +cnpj-utilities+).
  #
  # Nested package module — same object as +::CnpjGen+ (Options, helpers, errors,
  # types).
  CnpjGen = ::CnpjGen

  # Main-class shortcut for {CnpjGen::CnpjGenerator}.
  CnpjGenerator = CnpjGen::CnpjGenerator

  # Main-class shortcut for {CnpjGen::CnpjGeneratorOptions}.
  CnpjGeneratorOptions = CnpjGen::CnpjGeneratorOptions

  # Main-class shortcut for {CnpjGen::Error}.
  CnpjGeneratorError = CnpjGen::Error
end
