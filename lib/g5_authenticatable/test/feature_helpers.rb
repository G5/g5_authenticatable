# frozen_string_literal: true

module G5Authenticatable
  module Test
    # Helpers for feature specs
    module FeatureHelpers
      def stub_g5_omniauth(user, options = {})
        OmniAuth.config.mock_auth[:g5] = OmniAuth::AuthHash.new({
          uid: user.uid,
          provider: 'g5',
          info: basic_auth_info(user),
          credentials: { token: user.g5_access_token },
          extra: extra_auth_info(user)
        }.merge(options))
      end

      def stub_g5_invalid_credentials
        OmniAuth.config.mock_auth[:g5] = :invalid_credentials
      end

      def visit_path_and_login_with(path, user)
        stub_g5_omniauth(user)
        stub_valid_access_token(user.g5_access_token)
        visit path
      end

      private

      def basic_auth_info(user)
        {
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name,
          phone: user.phone_number
        }
      end

      def extra_auth_info(user)
        {
          title: user.title,
          organization_name: user.organization_name,
          roles: user.roles.collect do |role|
            { name: role.name, type: 'GLOBAL', urn: nil }
          end,
          raw_info: { accessible_applications: [{ url: 'global' }],
                      restricted_application_redirect_url: 'https://imc.com'}
        }
      end
    end
  end
end

RSpec.shared_context 'auth' do
  include G5Authenticatable::Test::FeatureHelpers

  let(:user) { FactoryBot.create(:g5_authenticatable_user) }

  before do
    stub_g5_omniauth(user)
    stub_valid_access_token(user.g5_access_token)
  end
end

RSpec.configure do |config|
  config.before(:each) { OmniAuth.config.test_mode = true }
  config.after(:each) { OmniAuth.config.test_mode = false }

  config.include G5Authenticatable::Test::FeatureHelpers, type: :feature
  config.include_context 'auth', auth: true
end
