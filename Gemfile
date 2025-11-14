source "https://rubygems.org"

gem "fastlane", "2.228.0"
gem "octokit", "~> 4.0"
gem "abbrev" # Required for Ruby 3.4.0+

# Fastlane plugins
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
