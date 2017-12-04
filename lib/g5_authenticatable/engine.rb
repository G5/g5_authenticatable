# frozen_string_literal: true

require 'rolify'
require 'pundit'

module G5Authenticatable
  # Rails engine for authentication/authorization against G5 Auth server
  class Engine < ::Rails::Engine
    isolate_namespace G5Authenticatable

    config.generators do |g|
      g.orm :active_record
      g.test_framework :rspec
    end

    initializer 'g5_authenticatable.filter_access_token' do |app|
      app.config.filter_parameters += [:access_token]
    end
  end
end
