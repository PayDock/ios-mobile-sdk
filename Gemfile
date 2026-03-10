source "https://rubygems.org"

gem "fastlane", "~> 2.232" # Updated for fastlane-plugin-firebase_app_distribution compatibility (requires >= 2.232.0)
gem "octokit", "~> 4.0"
gem "abbrev" # Required for Ruby 3.4.0+
gem "nkf" # Required for Ruby 3.4.0+ - provides kconv functionality that was removed from stdlib

# Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
