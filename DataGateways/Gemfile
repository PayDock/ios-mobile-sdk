source "https://rubygems.org"

gem "fastlane", "~> 2.229" # Updated for Ruby 3.4 support (2.229.0+ includes Ruby 3.4 fixes)
gem "octokit", "~> 4.0"
gem "abbrev" # Required for Ruby 3.4.0+
gem "nkf" # Required for Ruby 3.4.0+ - provides kconv functionality that was removed from stdlib

# Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)

