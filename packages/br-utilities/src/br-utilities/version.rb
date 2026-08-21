# frozen_string_literal: true

# Placeholder module so the gemspec (and any early require of this file) can read
# {BrUtils::VERSION}. The gem entry point promotes +BrUtils+ to a class and
# reopens it for the façade implementation.
module BrUtils
  # Gem version string. Placeholder replaced at build/publish time.
  #
  # @return [String]
  VERSION = '0.0.0'
end
