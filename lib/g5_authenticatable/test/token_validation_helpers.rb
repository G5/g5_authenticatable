# frozen_string_literal: true

module G5Authenticatable
  module Test
    # Helpers for stubbing token validation requests
    module TokenValidationHelpers
      def stub_valid_access_token(token_value)
        stub_request(:get, "#{ENV['G5_AUTH_ENDPOINT']}/oauth/token/info")
          .with(headers: { 'Authorization' => "Bearer #{token_value}" })
          .to_return(status: 200, body: '', headers: {})
      end

      def stub_invalid_access_token(token_value)
        stub_request(:get, "#{ENV['G5_AUTH_ENDPOINT']}/oauth/token/info")
          .with(headers: { 'Authorization' => "Bearer #{token_value}" })
          .to_return(status: 401,
                     headers: { 'Content-Type' => 'application/json;' \
                                ' charset=utf-8',
                                'Cache-Control' => 'no-cache' },
                     body: { 'error' => 'invalid_token',
                             'error_description' => 'The access token expired' }
                           .to_json)
      end
    end
  end
end

RSpec.configure do |config|
  config.include G5Authenticatable::Test::TokenValidationHelpers
end
