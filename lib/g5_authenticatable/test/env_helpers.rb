# frozen_string_literal: true

module G5Authenticatable
  module Test
    # Helper methods for stubbing environment variables
    module EnvHelpers
      def stub_env_var(name, value)
        stub_const('ENV', ENV.to_hash.merge(name => value))
      end
    end
  end
end

RSpec.configure do |config|
  config.include G5Authenticatable::Test::EnvHelpers

  config.before(:each) do
    stub_env_var('G5_AUTH_ENDPOINT', 'https://test.auth.host')
  end
end
