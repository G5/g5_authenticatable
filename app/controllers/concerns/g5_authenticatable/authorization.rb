# frozen_string_literal: true

module G5Authenticatable
  # Authorization helpers and error handling for controllers
  module Authorization
    extend ActiveSupport::Concern

    included do
      include Pundit
      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    end

    def user_not_authorized
      respond_to do |format|
        format.json do
          render status: :forbidden, json: { error: 'Access forbidden' }
        end
        format.html do
          render status: :forbidden, file: Rails.root.join('public', '403.html')
        end
      end
    end
  end
end
