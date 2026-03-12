#!/bin/bash
set -e

# Install bundler first
gem install bundler -v 2.5.23

# Configure bundler
bundle config set path 'vendor/bundle'

# Configure bundler to use single job to ensure environment variables are inherited
# This prevents parallel workers from losing environment variables
bundle config set --local jobs 1

# For Ruby 3.4+, kconv was removed from stdlib and is provided by the nkf gem
# The nkf gem has a circular dependency: its extconf.rb requires 'nkf' to build nkf
# Workaround: Create a minimal nkf stub that extconf.rb can use during build
TEMP_STUB_DIR=$(mktemp -d)

# Create nkf stub (for nkf's extconf.rb circular dependency)
cat > "$TEMP_STUB_DIR/nkf.rb" << 'RUBYEOF'
# Minimal nkf stub to break circular dependency during nkf gem build
# nkf's extconf.rb requires 'nkf', so we provide a minimal stub
module NKF
  AUTO = 0
  JIS = 1
  EUC = 2
  SJIS = 3
  UTF8 = 4
  UTF16 = 5
  UTF32 = 6
  BINARY = 7
  NOCONV = 8
  UNKNOWN = 9
  
  def self.nkf(opt, str)
    str.to_s.dup.force_encoding('UTF-8')
  end
  
  def self.guess(str)
    UTF8
  end
end
RUBYEOF

# Create kconv stub (for other gems that require kconv)
cat > "$TEMP_STUB_DIR/kconv.rb" << 'RUBYEOF'
# Minimal kconv stub for gems that require kconv during build
# This will be replaced by nkf's kconv after nkf is built
begin
  require 'nkf'
  # If nkf is available, use it
rescue LoadError
  # Otherwise provide minimal stub
  module Kconv
    AUTO = 0
    JIS = 1
    EUC = 2
    SJIS = 3
    UTF8 = 4
    UTF16 = 5
    UTF32 = 6
    BINARY = 7
    NOCONV = 8
    UNKNOWN = 9
    
    def self.toutf8(str)
      str.to_s.dup.force_encoding('UTF-8')
    end
    
    def self.toeuc(str)
      str.to_s.dup.force_encoding('EUC-JP')
    end
    
    def self.tosjis(str)
      str.to_s.dup.force_encoding('Shift_JIS')
    end
  end
end
RUBYEOF

# Add stubs to load path (nkf must come first)
export RUBYLIB="$TEMP_STUB_DIR:$RUBYLIB"
echo "Created nkf and kconv stubs to break circular dependencies"

echo "Installing all gems (nkf will rebuild with extensions now)..."
bundle install || {
  echo "Bundle install failed, cleaning up and retrying..."
  rm -rf "$TEMP_STUB_DIR"
  # Try without the stub - maybe bundler can handle it
  bundle install
}

# Clean up stub
rm -rf "$TEMP_STUB_DIR"

echo "✅ Bundle installation complete"

