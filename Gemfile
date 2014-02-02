source 'https://rubygems.org'
source "https://#{ENV['GEMFURY_TOKEN']}@gem.fury.io/me/"

# Declare your gem's dependencies in g5_authenticatable.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Gems used by the dummy application
gem 'rails', '~> 3.2.15'
gem 'jquery-rails'
gem 'sqlite3'

group :test do
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'simplecov'
  gem 'codeclimate-test-reporter'
  gem 'webmock'
end

group :test, :development do
  gem 'rspec-rails', '~> 2.14'
  gem 'pry'
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.
gem 'devise_g5_authenticatable', git: 'git@github.com:g5search/devise_g5_authenticatable.git',
                                 branch: 'engine_tasks'

# To use debugger
# gem 'debugger'
