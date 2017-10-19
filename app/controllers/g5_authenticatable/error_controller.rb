# frozen_string_literal: true

module G5Authenticatable
  # For handling errors returned by the auth server
  class ErrorController < G5Authenticatable::ApplicationController
    def auth_error
      flash[:error] = 'There was a problem with the Auth Server!'
    end
  end
end
