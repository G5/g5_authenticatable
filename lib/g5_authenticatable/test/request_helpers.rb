# frozen_string_literal: true

module G5Authenticatable
  module Test
    # Helper methods for login/logout during request specs
    module RequestHelpers
      include Warden::Test::Helpers

      def login_user(user)
        login_as(user, scope: :user)
      end

      def logout_user
        logout :user
      end
    end
  end
end

RSpec.shared_context 'auth request', auth_request: true do
  include G5Authenticatable::Test::RequestHelpers

  let(:user) { FactoryGirl.create(:g5_authenticatable_user) }

  before do
    login_user(user)
    stub_valid_access_token(user.g5_access_token)
  end

  after { logout_user }
end

RSpec.configure do |config|
  config.include G5Authenticatable::Test::RequestHelpers, type: :request
  config.after { Warden.test_reset! }
end
