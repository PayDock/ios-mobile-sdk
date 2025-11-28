# Ensure kconv is available for Ruby 3.4+ (required for native extension builds and fastlane)
# RUBYOPT is set in CI variables, but we ensure it's set here as well for child processes
if [[ "$RUBYOPT" != *"-rkconv"* ]]; then
  export RUBYOPT="${RUBYOPT} -rkconv"
fi

gem install bundler -v 2.5.23
bundle config set path 'vendor/bundle'
bundle install