# frozen_string_literal: true

class BrUtils
  # CNPJ formatting utilities re-exported from +cnpj-fmt+ (via +cnpj-utilities+).
  #
  # Nested package module — same object as +::CnpjFmt+ (Options, helpers, errors,
  # types).
  CnpjFmt = ::CnpjFmt

  # Main-class shortcut for {CnpjFmt::CnpjFormatter}.
  CnpjFormatter = CnpjFmt::CnpjFormatter

  # Main-class shortcut for {CnpjFmt::CnpjFormatterOptions}.
  CnpjFormatterOptions = CnpjFmt::CnpjFormatterOptions

  # Main-class shortcut for {CnpjFmt::Error}.
  CnpjFormatterError = CnpjFmt::Error
end
