# frozen_string_literal: true

require 'g5_authenticatable/engine'

require 'devise_g5_authenticatable'
require 'g5_authenticatable_api'
require 'g5_updatable'

module G5Authenticatable
  # When enabled, access tokens are always validated against the auth
  # server, even when that token is associated with an authenticated user.
  # Disabled by default, meaning that tokens are only validated if
  # they are explicitly passed in on an API request.
  @@strict_token_validation = false
  mattr_reader :strict_token_validation

  def self.strict_token_validation=(validate)
    @@strict_token_validation =
      G5AuthenticatableApi.strict_token_validation =
        Devise.g5_strict_token_validation = validate
  end
end
