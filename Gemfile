# frozen_string_literal: true

source 'https://rubygems.org'

# Declare your gem's dependencies in g5_authenticatable.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Gems used by the dummy application
gem 'active_model_serializers', '<= 0.10.0' # For compatibility with ruby 2.0.0
gem 'grape'
gem 'jquery-rails'
gem 'pg'
gem 'rails', '4.2.8'

group :test, :development do
  gem 'appraisal'
  gem 'dotenv-rails'
  gem 'pry-byebug'
  gem 'rspec-rails', '~> 3.6'
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'capybara'
  gem 'codeclimate-test-reporter'
  gem 'generator_spec'
  gem 'rspec-activemodel-mocks'
  gem 'rspec-http', require: 'rspec/http'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'simplecov', require: false
end

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.
gem 'devise_g5_authenticatable', github: 'G5/devise_g5_authenticatable',
                                 branch: 'rails5'
