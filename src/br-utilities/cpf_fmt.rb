# frozen_string_literal: true

class BrUtils
  # CPF formatting utilities re-exported from +cpf-fmt+ (via +cpf-utilities+).
  #
  # Nested package module — same object as +::CpfFmt+ (Options, helpers, errors,
  # types).
  CpfFmt = ::CpfFmt

  # Main-class shortcut for {CpfFmt::CpfFormatter}.
  CpfFormatter = CpfFmt::CpfFormatter

  # Main-class shortcut for {CpfFmt::CpfFormatterOptions}.
  CpfFormatterOptions = CpfFmt::CpfFormatterOptions

  # Main-class shortcut for {CpfFmt::Error}.
  CpfFormatterError = CpfFmt::Error
end
