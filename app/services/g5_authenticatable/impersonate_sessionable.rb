module G5Authenticatable
  module ImpersonateSessionable
    extend ActiveSupport::Concern

    def impersonation_user?
      impersonation_user.present?
    end

    def impersonation_user
      user_by_uid(impersonate_admin_uid)
    end

    def user_to_impersonate
      user_by_uid(impersonating_user_uid)
    end

    def clear_impersonation_keys
      impersonate_admin_uid = nil
      impersonating_user_uid = nil
      impersonating_user_callback_url = nil
    end

    # Checks if the user by param is able to impersonate the second user by param
    def check_impersonation_access?(user_impersonating, resource)
      able_to_impersonate?(user_impersonating, resource)
    end

    private

    def able_to_impersonate?(user_impersonating, resource)
      return false unless user_impersonating.present? && resource.present?
      if user_impersonating.has_role?(:super_admin) ||
         (user_impersonating.has_role?(:admin) && !resource.has_role?(:super_admin))
        true
      else
        false
      end
    end

    def user_by_uid(uid)
      G5Authenticatable::User.find_by_uid(uid)
    rescue ActiveRecord::RecordNotFound
      nil
    end

    # Let's just keep this key secret. you know.. for security reasons.
    IMPERSONATE_SESSION_KEY = 'devise.g5_authenticatable.Xf1eP3hCjC'
    IMPERSONATING_USER_SESSION_KEY = 'devise.g5_authenticatable.Zk35J5adER'
    IMPERSONATING_USER_SESSION_CALLBACK_URL = 'devise.g5_authenticatable.callcbak_url'

    def impersonate_admin_uid
      request.env['rack.session'][IMPERSONATE_SESSION_KEY]
    end

    def impersonate_admin_uid=(uid)
      request.env['rack.session'][IMPERSONATE_SESSION_KEY] = uid
    end

    def impersonate_admin_uid?
      request.env['rack.session'] && request.env['rack.session'][IMPERSONATE_SESSION_KEY].present?
    end

    def impersonating_user_uid
      request.env['rack.session'][IMPERSONATING_USER_SESSION_KEY]
    end

    def impersonating_user_uid=(uid)
      request.env['rack.session'][IMPERSONATING_USER_SESSION_KEY] = uid
    end

    def impersonating_user_uid?
      request.env['rack.session'] && request.env['rack.session'][IMPERSONATING_USER_SESSION_KEY].present?
    end

    def impersonating_user_callback_url
      request.env['rack.session'][IMPERSONATING_USER_SESSION_CALLBACK_URL] || ''
    end

    def impersonating_user_callback_url=(callback_url)
      request.env['rack.session'][IMPERSONATING_USER_SESSION_CALLBACK_URL] = callback_url
    end
  end
end
