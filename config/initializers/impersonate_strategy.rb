# frozen_string_literal: true

require 'devise/strategies/authenticatable'
require 'devise/strategies/base'

module Devise
  module Strategies
    class ImpersonateStrategy < Authenticatable
      include ::G5Authenticatable::ImpersonateSessionable

      # Prevents unauthorized users to impersonate another user when visiting
      # the correct URL
      def valid?
        allowed = user_to_impersonate.present? &&
                  able_to_impersonate?(impersonation_user, user_to_impersonate)
        return allowed if allowed
        clear_impersonation_keys
        true
      rescue # Safety net
        clear_impersonation_keys
        false
      end

      def authenticate!
        if user_to_impersonate.present?
          success!(user_to_impersonate)
        else
          clear_impersonation_keys
          fail('You do not have sufficient access to this account')
        end
      end
    end
  end
end
